{
  inputs,
  lib,
  ...
}: {
  perSystem = {
    config,
    self',
    inputs',
    pkgs,
    system,
    ...
  }: {
    packages = let
      commonArgs = {
        appName = "nvim-haven";

        extraBinPath = let
          formatters = with pkgs; [
            nixfmt
            stylua
          ];

          languageServers = with pkgs; [
            lua-language-server
            nixd
          ];

          neovimDependencies = with pkgs;
            [
              ripgrep
            ]
            ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [pkgs.wl-clipboard];

          pluginDependencies.snacks = with pkgs; [
            fd
            ripgrep
            git-graph
          ];
        in
          lib.pipe
          (formatters ++ languageServers ++ neovimDependencies ++ builtins.attrValues pluginDependencies)
          [
            lib.flatten
            lib.unique
          ];

        ## experimental-features 'pipe-operators'
        # formatters
        # ++ languageServers
        # ++ neovimDependencies
        # ++ (pluginDependencies |> builtins.attrValues |> lib.flatten)
        # |> lib.unique;

        initLua = builtins.readFile ../../init.lua;

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

          start = [pkgs.vimPlugins.nvim-treesitter.withAllGrammars] ++ inputs.mnw.lib.npinsToPlugins pkgs ../../start.json;
          opt =
            [self'.packages.blink-cmp self'.packages.blink-pairs]
            ++ builtins.filter (x: !lib.hasPrefix "blink" x.pname) (inputs.mnw.lib.npinsToPlugins pkgs ../../opt.json);
        };

        providers = {
          nodeJs.enable = false;
          perl.enable = false;
          python3.enable = false;
          ruby.enable = false;
        };
      };
    in {
      default = self'.packages.nightly;

      nightly = inputs.mnw.lib.wrap {inherit pkgs;} (
        commonArgs // {inherit (inputs'.neovim-nightly-overlay.packages) neovim;}
      );
      stable = inputs.mnw.lib.wrap {inherit pkgs;} commonArgs;
    };
  };
}
