---
name: update-neovim-plugins
description: Updates Neovim plugin pins in this config and reviews the changed plugin code for supply-chain/security risks. Use when the user asks to update Neovim plugins, refresh plugin pins, run npins updates, or audit new/updated Neovim plugins for security issues.
---

# Update Neovim Plugins

## Quick start

From the Neovim config repo:

```bash
git status --short
nix develop -c update
./.pi/skills/update-neovim-plugins/scripts/review-nvim-plugin-updates.sh
```

Then review the report, fix or revert suspicious updates, run checks, and summarize changed plugins plus risks found.

## Workflow

1. **Start clean**
   - Confirm the repo is clean or identify pre-existing user changes.
   - Do not overwrite unrelated user work.
   - Note current `start.json`, `opt.json`, `nix/packages/*.nix`, and `flake.lock` state.

2. **Update pins**
   - Prefer the project command: `nix develop -c update`.
   - If needed, update specific sets manually:
     - `nix develop -c npins --lock-file ./start.json update -f`
     - `nix develop -c npins --lock-file ./opt.json update -f`
   - For plugin package derivations, keep using the project’s update command unless the user asks otherwise.

3. **Install and smoke-test**
   - Run `nix develop -c just install` to fetch/check out pinned plugins.
   - Run available checks, usually `nix flake check` or the repository’s documented check command.
   - If Neovim startup can be tested headlessly, run a minimal startup command and capture failures.

4. **Security review**
   - Run the bundled review script:
     `./.pi/skills/update-neovim-plugins/scripts/review-nvim-plugin-updates.sh`
   - Inspect every HIGH finding manually before approving.
   - For each updated plugin, review upstream diff/release notes when available.
   - Pay special attention to new or changed:
     - shell execution: `os.execute`, `io.popen`, `vim.system`, `vim.fn.system`, `jobstart`, `spawn`
     - network access: HTTP clients, curl/wget, sockets, telemetry, update checkers
     - dynamic code loading: `loadstring`, `load`, `dofile`, LuaJIT FFI
     - filesystem writes outside plugin/cache directories
     - build hooks, generated binaries, native extensions, npm/cargo/go installs
     - credential/env access, GitHub token use, clipboard exfiltration

5. **Decide**
   - Keep low-risk updates that pass checks.
   - Revert or pin back suspicious plugins until reviewed by the user.
   - If risk is ambiguous, present the evidence and ask before proceeding.

## Reporting format

End with:

- Plugins updated: names and old → new revisions/versions.
- Checks run: command and pass/fail.
- Security review: findings by severity and manual judgement.
- Follow-ups: any plugins deferred, reverted, or needing user approval.
