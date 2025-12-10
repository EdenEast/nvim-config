{self, ...}: {
  flake.overlays.default = _final: _prev: {
    neovim-stable = self.packages.stable;
    neovim-nightly = self.packages.nightly;
  };
}
