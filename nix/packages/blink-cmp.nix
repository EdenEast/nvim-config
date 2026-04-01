_: {
  perSystem = {pkgs, ...}: {
    packages = {
      blink-cmp = pkgs.rustPlatform.buildRustPackage rec {
        pname = "blink.cmp";
        version = "1.10.1-unstable-2026-03-31";

        src = pkgs.fetchFromGitHub {
          owner = "Saghen";
          repo = "blink.cmp";
          rev = "5e088706d92da09949e081cc4d49e2c9ba8cfc8c";
          hash = "sha256-eCMZzC8rGBRutnD84nxGcuDbUSxBXK0clcCept8gDA0=";
        };

        cargoHash = "sha256-3o2n4xwNF9Fc3VlPKf3lnvmN7FVus5jQB8gcXXwz50c=";

        # Tries to call git
        preBuild = ''
          rm build.rs
        '';

        postInstall = ''
          cp -r {lua,plugin} "$out"
          mkdir -p "$out/doc"
          cp 'doc/'*'.txt' "$out/doc/"
          mkdir -p "$out/target"
          mv "$out/lib" "$out/target/release"
        '';

        # Uses rust nightly
        env.RUSTC_BOOTSTRAP = true;
        # Don't move /doc to $out/share
        forceShare = [];
      };
    };
  };
}
# NOTE: Can we search though npins and find blink-cmp and use that for the source and version?

