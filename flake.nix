{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
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
      owner = "Gerg-L";
      repo = "mnw";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} (
      inputs.import-tree ./nix
      // {
        systems = import inputs.systems;
        debug = true;
      }
    );

  nixConfig = {
    accept-flake-config = true;
    experimental-features = ["flakes" "nix-command" "pipe-operators"];
    extra-substituters = ["https://edeneast.cachix.org"];
    extra-trusted-public-keys = ["edeneast.cachix.org-1:a4tKrKZgZXXXYhDytg/Z3YcjJ04oz5ormt0Ow6OpExc="];
  };
}
