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

      packages = with pkgs; [npins just start opt watchexec];
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
