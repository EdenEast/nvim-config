{...}: {
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    packages = {
      blink-cmp = pkgs.rustPlatform.buildRustPackage rec {
        pname = "blink.cmp";
        version = "1.6.0-unstable-2025-09-05";

        src = pkgs.fetchFromGitHub {
          owner = "Saghen";
          repo = "blink.cmp";
          rev = "fa9e5fa324f8a721a562a7baeba35a0da44ec651";
          hash = "sha256-2Y1ekycQ2CraWxccj9xf+rgPPmrUBLTxumMX99qChA4=";
        };

        cargoHash = "sha256-kO+g9vl7l7grWD7fLyYqDz8e4+yW0LGaKxz2Y1F4efo=";

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

