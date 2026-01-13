{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    flake-parts = {
      type = "github";
      owner = "hercules-ci";
      repo = "flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-root = {
      type = "github";
      owner = "srid";
      repo = "flake-root";
    };
    import-tree = {
      type = "github";
      owner = "vic";
      repo = "import-tree";
    };
    gen-luarc = {
      type = "github";
      owner = "mrcjkb";
      repo = "nix-gen-luarc-json";
      inputs = {
        flake-parts.follows = "flake-parts";
        git-hooks.follows = "git-hooks";
        nixpkgs.follows = "nixpkgs";
      };
    };
    systems = {
      type = "github";
      owner = "nix-systems";
      repo = "default";
    };
    treefmt-nix = {
      type = "github";
      owner = "numtide";
      repo = "treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks = {
      type = "github";
      owner = "cachix";
      repo = "git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay = {
      type = "github";
      owner = "nix-community";
      repo = "neovim-nightly-overlay";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };
    mnw = {
      type = "github";
      owner = "EdenEast";
      repo = "mnw";
      ref = "dev";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./nix
      // {
        systems = import inputs.systems;
        debug = true;
      });

  # nixConfig = {
  #   experimental-features = [
  #     "flakes"
  #     "nix-command"
  #     "pipe-operators"
  #   ];
  # };
}
