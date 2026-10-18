{lib, ...}: {
  perSystem = {
    pkgs,
    self',
    ...
  }: {
    # Proves the wrapper picks the right config. See `tests/config-selection.sh` for the contract.
    checks = lib.mapAttrs' (name: nvim:
      lib.nameValuePair "config-selection-${name}" (
        pkgs.runCommand "config-selection-${name}" {nativeBuildInputs = [pkgs.jq];} ''
          bash ${../tests/config-selection.sh} ${nvim}/bin/nvim
          touch $out
        ''
      )) {inherit (self'.packages) stable nightly;};
  };
}
