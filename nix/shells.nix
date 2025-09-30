{inputs, ...}: {
  imports = [inputs.flake-root.flakeModule];

  perSystem = {
    config,
    inputs',
    lib,
    pkgs,
    self',
    system,
    ...
  }: {
    devShells = let
      mkNpinsWrapper = name: lockfile:
        pkgs.writeShellScriptBin name ''
          tree_root=''$(${lib.getExe config.flake-root.package})
          function list() {
            ${pkgs.npins}/bin/npins --lock-file $tree_root/${lockfile} show \
            | ${pkgs.ripgrep}/bin/rg --color=never "^([\w\-\_\.]+):.*" --replace '$1'
          }

          function ex() {
            ${pkgs.npins}/bin/npins --lock-file $tree_root/${lockfile} "$@"
          }

          if [ "$1" = "list" ]; then
            list
          elif [ "$1" = "add" ]; then
            shift
            ex add github "$@"
          elif [ "$1" = "remove" ] && [ $# -eq 1 ]; then
            for package in "$(list | ${pkgs.fzf}/bin/fzf -m)"; do
              ex remove "$package"
            done
          else
            ex "$@"
          fi
        '';

      start = mkNpinsWrapper "start" "start.json";
      opt = mkNpinsWrapper "opt" "opt.json";

      update = let
        color = "\\033[0;33m";
        reset = "\\033[0m";
      in
        pkgs.writeShellScriptBin "update" ''
          echo -e "${color}Updating start plugins${reset}"
          ${pkgs.npins}/bin/npins --lock-file ./start.json update -f 2>&1 | { grep '.*Changes:$\|.*url:.*' || true; }
          echo -e "${color}Updating opt plugins${reset}"
          ${pkgs.npins}/bin/npins --lock-file ./opt.json update -f 2>&1 | { grep '.*Changes:$\|.*url:.*' || true; }

          echo -e "${color}Updating blink-cmp${reset}"
          ${pkgs.nix-update}/bin/nix-update -F blink-cmp --version=branch --option extra-experimental-features pipe-operators
          echo -e "${color}Updating blink-pairs${reset}"
          ${pkgs.nix-update}/bin/nix-update -F blink-pairs --version=branch --option extra-experimental-features pipe-operators
        '';

      profile = pkgs.writeShellScriptBin "profile" ''NVIM_PROFILE="snacks" nvim'';
      trace = pkgs.writeShellScriptBin "trace" ''NVIM_PROFILE="trace" nvim'';

      packages = with pkgs; [npins just start opt update watchexec profile trace];
      plugins = self'.packages.default.passthru.config.plugins.start ++ self'.packages.default.passthru.config.plugins.opt;
    in {
      default = self'.devShells.nightly;

      stable = pkgs.mkShell {
        name = "haven";
        inputsFrom = [config.flake-root.devShell];
        packages = packages ++ [self'.packages.stable.devMode];
        shellHook =
          config.pre-commit.installationScript
          + ''
            ln -fs ${
              pkgs.mk-luarc-json {
                inherit plugins;
                lua-version = "jit51";
              }
            } .luarc.json
          '';
      };

      nightly = pkgs.mkShell {
        name = "haven";
        inputsFrom = [config.flake-root.devShell];
        packages = packages ++ [self'.packages.nightly.devMode];
        shellHook =
          config.pre-commit.installationScript
          + ''
            ln -fs ${
              pkgs.mk-luarc-json {
                inherit plugins;
                lua-version = "jit51";
                nvim = inputs'.neovim-nightly-overlay.packages.neovim;
              }
            } .luarc.json
          '';
      };
    };
  };
}
