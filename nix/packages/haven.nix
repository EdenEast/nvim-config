{
  inputs,
  lib,
  ...
}: {
  perSystem = {
    self',
    inputs',
    pkgs,
    ...
  }: {
    packages = let
      npinsToPlugins = input: builtins.mapAttrs (_: v: v {inherit pkgs;}) (import ../_npins.nix {inherit input;});

      # Chooses the config before neovim starts. mnw's `--cmd` and `VIMINIT` inject the bundled config unconditionally,
      # so deciding inside lua is too late to give a user config a clean slate. This runs first in the wrapper script:
      #   - `$XDG_CONFIG_HOME/${NVIM_APPNAME:-nvim}` has an init file, or `--clean`/`-u` is passed: exec stock neovim.
      #   - Otherwise: run the bundled haven config with `NVIM_APPNAME` defaulting to `nvim-haven`.
      # Run `tests/config-selection.sh` (or `nix flake check`) after changing this.
      selectConfig = neovim: ''
        config_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/''${NVIM_APPNAME:-nvim}"
        use_stock=
        if [ -e "$config_dir/init.lua" ] || [ -e "$config_dir/init.vim" ]; then use_stock=1; fi
        for arg in "$@"; do
          case "$arg" in
            --) break ;;
            --clean | -u) use_stock=1 ;;
          esac
        done
        if [ -n "$use_stock" ]; then
          unset VIMINIT
          export PATH="$PATH:${lib.makeBinPath commonArgs.extraBinPath}"
          exec -a "$0" ${lib.getExe neovim} "$@"
        fi
        export NVIM_APPNAME="''${NVIM_APPNAME:-nvim-haven}"
      '';

      wrap = neovim:
        mnwLib.wrap {inherit pkgs;} (commonArgs
          // {
            inherit neovim;
            wrapperArgs = ["--run" (selectConfig neovim)];
          });

      commonArgs = {
        # Set by `selectConfig` instead, which needs to know whether the user set it.
        appName = null;

        extraBinPath = let
          formatters = with pkgs; [
            alejandra
            nixfmt
            stylua
          ];

          languageServers = with pkgs; [
            lua-language-server
            nil
          ];

          languageDebuggers = with pkgs; [
            lldb
          ];

          neovimDependencies = with pkgs;
            [
              fzf
              sd
              nodejs-slim
              ripgrep
            ]
            ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
              pkgs.wl-clipboard
            ];

          pluginDependencies.snacks = with pkgs; [
            fd
            ripgrep
            git-graph
          ];
        in
          lib.pipe (formatters
            ++ languageServers
            ++ languageDebuggers
            ++ neovimDependencies
            ++ builtins.attrValues pluginDependencies) [lib.flatten lib.unique];

        ## experimental-features 'pipe-operators'
        # formatters
        # ++ languageServers
        # ++ neovimDependencies
        # ++ (pluginDependencies |> builtins.attrValues |> lib.flatten)
        # |> lib.unique;

        # mnw loads this through `$VIMINIT`. Clear it so a nested stock nvim (e.g. in `:terminal`) does not inherit it.
        initLua =
          ''
            vim.env.VIMINIT = nil
          ''
          + builtins.readFile ../../init.lua;

        plugins = {
          dev.config = {
            pure = lib.fileset.toSource {
              root = ../../.;
              fileset = lib.fileset.unions [
                ../../after
                ../../compiler
                ../../lua
                ../../init.lua
                ../../filetype.lua
              ];
            };

            impure =
              # This is a hack it should be a absolute path. It will work under these criteria:
              # 1. `NV_PATH` is defined as an env variable
              # 2. `FLAKE_ROOT` is defined as an env variable. This comes from this flake's use of flake-root
              # 3. The current directory is the root of this project
              #
              # This will not work if your cwd does not contian the flake root path at some parent location.
              lib.stringAsChars (x:
                if x == "\n"
                then ""
                else x) ''
                /' .. ((vim.env.NV_PATH and vim.env.NV_PATH)
                  or (vim.env.FLAKE_ROOT and vim.env.FLAKE_ROOT)
                  or vim.uv.cwd():sub(2, -1)):sub(2) .. '
              '';
          };

          startAttrs = npinsToPlugins ../../start.json;
          start =
            (pkgs.vimPlugins.nvim-treesitter.withPlugins
              (
                parsers:
                  builtins.attrValues {
                    inherit
                      (parsers)
                      bash
                      c
                      c_sharp
                      comment
                      cpp
                      fish
                      html
                      javascript
                      json
                      kdl
                      lua
                      markdown
                      markdown_inline
                      nix
                      python
                      rust
                      toml
                      typescript
                      vim
                      yaml
                      ;
                  }
              )).dependencies;

          optAttrs =
            {
              "blink.cmp" = self'.packages.blink-cmp;
              "blink.pairs" = self'.packages.blink-pairs;
            }
            // lib.filterAttrs (name: _: !lib.hasPrefix "blink" name) (npinsToPlugins ../../opt.json);
        };

        providers = {
          nodeJs.enable = false;
          perl.enable = false;
          python3.enable = false;
          ruby.enable = false;
        };
      };

      mnwLib = inputs.mnw.lib;
    in {
      default = self'.packages.nightly;

      nightly = wrap inputs'.neovim-nightly-overlay.packages.neovim;
      stable = wrap pkgs.neovim-unwrapped;
    };
  };
}
