_: {
  perSystem = {pkgs, ...}: {
    packages = {
      blink-pairs = pkgs.rustPlatform.buildRustPackage rec {
        pname = "blink.pairs";
        version = "0.4.1-unstable-2025-12-08";

        src = pkgs.fetchFromGitHub {
          owner = "Saghen";
          repo = "blink.pairs";
          rev = "65978aadaf9b7d6cae59c1c51cf2b366b370546e";
          hash = "sha256-CwaO17nCTb2lvqY3dupi0RXKlpOFUwhqLwVW3djAQyU=";
        };

        cargoHash = "sha256-Cn9zRsQkBwaKbBD/JEpFMBOF6CBZTDx7fQa6Aoic4YU=";

        # Tries to call git
        preBuild = ''
          rm build.rs
        '';

        doCheck = false;
        postInstall = ''
          cp -r lua "$out"
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
# NOTE: Can we search though npins and find blink-pairs and use that for the source and version?

