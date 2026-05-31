#!/usr/bin/env bash
set -u -o pipefail

ROOT="${1:-$(pwd)}"
LOCKFILES=(start.json opt.json)
TMP="$(mktemp -d -t nvim-plugin-review.XXXXXX)"
trap 'rm -rf "$TMP"' EXIT
cd "$ROOT" || exit 1

need() { command -v "$1" >/dev/null || { echo "missing required command: $1" >&2; exit 1; }; }
need git
need jq

updates="$TMP/updates.tsv"
: > "$updates"

for lock in "${LOCKFILES[@]}"; do
  [ -f "$lock" ] || continue
  old="$TMP/old-$lock"
  if ! git show "HEAD:$lock" > "$old" 2>/dev/null; then
    echo '{"pins":{}}' > "$old"
  fi
  jq -r --arg lock "$lock" --slurpfile old "$old" '
    .pins as $new
    | ($old[0].pins // {}) as $oldpins
    | $new | to_entries[]
    | .key as $name
    | .value as $pin
    | ($oldpins[$name] // {}) as $oldpin
    | select(($oldpin.revision // "") != ($pin.revision // ""))
    | select(($oldpin.revision // "") != "" and ($pin.revision // "") != "")
    | [$lock, $name, $pin.repository.owner, $pin.repository.repo, $oldpin.revision, $pin.revision, ($oldpin.version // ""), ($pin.version // "")] | @tsv
  ' "$lock" >> "$updates"
done

if [ ! -s "$updates" ]; then
  echo "No plugin revision updates detected versus HEAD."
  exit 0
fi

count=$(wc -l < "$updates" | tr -d ' ')
echo "Detected $count updated plugin(s):"
while IFS=$'\t' read -r lock name owner repo oldrev newrev oldver newver; do
  ver=""
  [ -n "$oldver$newver" ] && ver=" ($oldver -> $newver)"
  echo "- $lock: $name ${oldrev:0:12} -> ${newrev:0:12}$ver"
done < "$updates"

high=0
while IFS=$'\t' read -r lock name owner repo oldrev newrev oldver newver; do
  echo
  echo "## $name ($owner/$repo)"
  bare="$TMP/${owner}__${repo}.git"
  url="https://github.com/$owner/$repo.git"
  if ! git clone --quiet --bare --filter=blob:none "$url" "$bare" 2>"$TMP/clone.err"; then
    echo "HIGH: unable to clone $url: $(<"$TMP/clone.err")"
    high=$((high + 1))
    continue
  fi
  if ! git -C "$bare" fetch --quiet origin "$oldrev" "$newrev" 2>"$TMP/fetch.err"; then
    echo "HIGH: unable to fetch revisions: $(<"$TMP/fetch.err")"
    high=$((high + 1))
    continue
  fi

  git -C "$bare" diff --stat "$oldrev..$newrev" || true

  git -C "$bare" diff --name-only "$oldrev..$newrev" \
    | grep -Ei '(^|/)(build|install|postinstall|Makefile|CMakeLists\.txt|package\.json|Cargo\.toml|go\.mod|\.github/workflows/)' \
    | sed 's/^/MED: risky changed file: /' || true

  findings="$TMP/findings-$name.txt"
  git -C "$bare" diff --unified=0 "$oldrev..$newrev" \
    | awk '
      /^\+\+\+ b\// {file=substr($0,7); next}
      /^\+/ && !/^\+\+\+/ {print file ": " substr($0,2)}
    ' \
    | grep -Ei '\b(os\.execute|io\.popen|vim\.system|vim\.fn\.system2?|systemlist|jobstart|termopen|uv\.spawn|vim\.loop\.spawn|loadstring|load[[:space:]]*\(|dofile[[:space:]]*\(|ffi|socket|https?|curl|wget|plenary\.curl|os\.getenv|vim\.env|GITHUB_TOKEN|API_KEY|TOKEN|SECRET|PASSWORD|io\.open|writefile|vim\.fs\.rm|os\.remove|rm[[:space:]]+-rf|npm[[:space:]]+install|cargo[[:space:]]+build|go[[:space:]]+build|make[[:space:]])\b' \
    > "$findings" || true

  if [ -s "$findings" ]; then
    while IFS= read -r line; do
      sev="MED"
      if [[ "$line" =~ (os\.execute|io\.popen|vim\.system|vim\.fn\.system|systemlist|jobstart|termopen|spawn|loadstring|dofile|curl.*\||wget.*\||sh[[:space:]]+-c|bash[[:space:]]+-c) ]]; then
        sev="HIGH"
        high=$((high + 1))
      fi
      printf '%s: suspicious added line: %.220s\n' "$sev" "$line"
    done < "$findings"
  else
    echo "No scripted risk patterns found. Manual review still required."
  fi
done < "$updates"

if [ "$high" -gt 0 ]; then
  echo
  echo "Result: $high HIGH finding(s). Manually review before accepting updates."
  exit 2
fi

echo
echo "Result: no HIGH scripted findings. Complete manual review/checks before committing."
