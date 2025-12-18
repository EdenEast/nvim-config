_: {
  perSystem = {pkgs, ...}: {
    packages = {
      blink-pairs = pkgs.rustPlatform.buildRustPackage rec {
        pname = "blink.pairs";
        version = "0.3.0-unstable-2025-09-05";

        src = pkgs.fetchFromGitHub {
          owner = "Saghen";
          repo = "blink.pairs";
          rev = "c2d4030c10e6628de159cbac79a32a70ad746290";
          hash = "sha256-0S8/MQLpnYmwEIqWCU6TBr/NibagfaWkqMOTv7He2Zg=";
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

