#!/usr/bin/env bash
# Checks which configuration the wrapped `nvim` loads.
#
# Contract:
#   - If `$XDG_CONFIG_HOME/${NVIM_APPNAME:-nvim}` has an init.lua or init.vim, that config runs exactly as it would
#     under stock neovim. Nothing from the nix build is on 'runtimepath' or 'packpath'.
#   - Otherwise the bundled haven config runs, with `NVIM_APPNAME` defaulting to `nvim-haven`.
#   - `--clean` and `-u` always behave like stock neovim.
#   - Stock neovim still gets the haven toolchain (LSPs, formatters, ...) appended to PATH.
#
# Usage: tests/config-selection.sh /path/to/bin/nvim
# Requires: jq
set -uo pipefail

nvim=${1:?usage: $0 /path/to/bin/nvim}
failures=0

# Runs nvim in an empty HOME. Prints a JSON summary of what loaded.
#   $1: setup function that populates "$HOME"
#   rest: extra environment assignments, then `--` and extra nvim arguments
probe() {
  local setup=$1
  shift
  local -a envs=() args=()
  while (($#)) && [[ $1 != -- ]]; do
    envs+=("$1")
    shift
  done
  [[ ${1-} == -- ]] && shift
  args=("$@")

  local home
  home=$(mktemp -d)
  (HOME=$home "$setup")
  envs=("${envs[@]//\$HOME/$home}")

  local out=$home/probe.json
  local lua='
    local function from_nix(opt)
      return vim.iter(vim.opt[opt]:get()):any(function(p) return p:find("mnw%-configDir") ~= nil end)
    end
    vim.fn.writefile({ vim.json.encode({
      appname = vim.env.NVIM_APPNAME or vim.NIL,
      config = vim.fn.stdpath("config"),
      user_loads = vim.g.user_loads or 0,
      haven = package.loaded["haven"] ~= nil,
      nix_rtp = from_nix("runtimepath"),
      nix_pp = from_nix("packpath"),
      viminit = vim.env.VIMINIT or vim.NIL,
      errmsg = vim.v.errmsg,
      lua_ls = vim.fn.executable("lua-language-server") == 1,
    }) }, os.getenv("PROBE_OUT"))'

  env -i PATH="$PATH" TMPDIR="${TMPDIR:-/tmp}" HOME="$home" PROBE_OUT="$out" "${envs[@]}" \
    "$nvim" --headless "${args[@]}" "+lua $lua" '+qa!' >/dev/null 2>&1 </dev/null
  cat "$out" 2>/dev/null || echo '{"error":"nvim produced no probe output"}'
  rm -rf "$home"
}

# Asserts a jq expression is true for the probe output.
check() {
  local name=$1 json=$2 expr=$3
  if jq -e "$expr" >/dev/null <<<"$json"; then
    printf 'ok   %s\n' "$name"
  else
    printf 'FAIL %s\n     expected: %s\n     got:      %s\n' "$name" "$expr" "$json"
    failures=$((failures + 1))
  fi
}

user_config='vim.g.user_loads = (vim.g.user_loads or 0) + 1'

no_config() { :; }
nvim_lua() { mkdir -p "$HOME/.config/nvim" && echo "$user_config" >"$HOME/.config/nvim/init.lua"; }
nvim_vim() { mkdir -p "$HOME/.config/nvim" && echo "lua $user_config" >"$HOME/.config/nvim/init.vim"; }
foo_lua() { mkdir -p "$HOME/.config/foo" && echo "$user_config" >"$HOME/.config/foo/init.lua"; }
xdg_lua() { mkdir -p "$HOME/xdg/nvim" && echo "$user_config" >"$HOME/xdg/nvim/init.lua"; }
nvim_dir_only() { mkdir -p "$HOME/.config/nvim/lua"; }

haven='.haven and .user_loads == 0 and .nix_rtp and .viminit == null'
user='(.haven | not) and .user_loads == 1 and .lua_ls and (.nix_rtp | not) and (.nix_pp | not) and .viminit == null'
stock='(.haven | not) and .user_loads == 0 and (.nix_rtp | not) and (.nix_pp | not)'

check "no user config runs haven as nvim-haven" \
  "$(probe no_config)" "$haven and .appname == \"nvim-haven\""
check "config dir without init file still runs haven" \
  "$(probe nvim_dir_only)" "$haven"
check "~/.config/nvim/init.lua overrides haven" \
  "$(probe nvim_lua)" "$user and (.config | endswith(\"/.config/nvim\"))"
check "~/.config/nvim/init.vim overrides haven" \
  "$(probe nvim_vim)" "$user"
check "NVIM_APPNAME=foo with ~/.config/foo/init.lua overrides haven" \
  "$(probe foo_lua NVIM_APPNAME=foo)" "$user and .appname == \"foo\""
check "NVIM_APPNAME=foo without config runs haven as foo" \
  "$(probe no_config NVIM_APPNAME=foo)" "$haven and .appname == \"foo\""
check "NVIM_APPNAME=foo ignores ~/.config/nvim" \
  "$(probe nvim_lua NVIM_APPNAME=foo)" "$haven and .appname == \"foo\""
check "XDG_CONFIG_HOME is respected" \
  "$(probe xdg_lua 'XDG_CONFIG_HOME=$HOME/xdg')" "$user"
check "--clean behaves like stock nvim" \
  "$(probe no_config -- --clean)" "$stock"
check "-u NONE behaves like stock nvim" \
  "$(probe no_config -- -u NONE)" "$stock"

if ((failures)); then
  echo "$failures check(s) failed"
  exit 1
fi
echo "all checks passed"
