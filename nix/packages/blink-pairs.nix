_: {
  perSystem = {pkgs, ...}: {
    packages = {
      blink-pairs = let
        rustNightly = pkgs.rust-bin.nightly.latest.default;
        rustPlatform = pkgs.makeRustPlatform {
          cargo = rustNightly;
          rustc = rustNightly;
        };
      in
        rustPlatform.buildRustPackage {
          pname = "blink.pairs";
          version = "0.5.0-unstable-2026-03-27";

          src = pkgs.fetchFromGitHub {
            owner = "Saghen";
            repo = "blink.pairs";
            rev = "2da33da164fbbf5cf52214fb9e7db1096d55e0dc";
            hash = "sha256-DIw9l9NXFi6S4j1dF3a7nMBEwKA5o65NySeaYPO4ZiY=";
          };

          cargoHash = "sha256-Cn9zRsQkBwaKbBD/JEpFMBOF6CBZTDx7fQa6Aoic4YU=";

          # Tries to call git
          preBuild = ''
            rm build.rs
            rustc --version
          '';

          doCheck = false;
          postInstall = ''
            cp -r lua "$out"
            mkdir -p "$out/target"
            mv "$out/lib" "$out/target/release"
          '';

          # Don't move /doc to $out/share
          forceShare = [];
        };
    };
  };
}
# NOTE: Can we search though npins and find blink-pairs and use that for the source and version?

