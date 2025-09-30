# docs on re-defining pkgs:
#   - https://flake.parts/module-arguments#pkgs
#   - https://flake.parts/overlays.html#consuming-an-overlay
{inputs, ...}: {
  perSystem = {system, ...}: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [
        inputs.gen-luarc.overlays.default
        (_final: prev: {
          git-graph = prev.git-graph.overrideAttrs (_old: {
            buildInputs = [prev.pkgs.zlib];
            meta.broken = false;
          });
        })
      ];
    };
  };
}
