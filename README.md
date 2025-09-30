# Haven

My personal neovim configuraton This neovim flake is based off of [Gerg-L's](https://github.com/Gerg-L)
[Minimal Neovim Wrapper (mnv)](https://gerg-l.github.io/mnw/).

This was chosen as it is a simple interface to wrap neovim configuration and plugins but also does not require
any special nix-isms. The goal of this configuration is to be used either via nix or just cloning this into
a ~/.config directory.

## Resources and References

### Neovim

- [MariaSolOs](https://github.com/MariaSolOs/dotfiles/tree/main/.config/nvim)

- [echasnovski](https://github.com/echasnovski/nvim)

- [LazyVim](https://github.com/LazyVim/LazyVim)
  - This is the best neovim distribution and has great concepts and ideas

### Nix

- [Gerg-L/nvim-flake](https://github.com/Gerg-L/nvim-flake)
  - Creators configuration and example of how to use it in an actual project
  - handle other packages like blink-cmp building as well and has auto update GHA workflows

- [HeitorAugustoLN/nvim-config](https://github.com/HeitorAugustoLN/nvim-config)
  - Uses flake-parts and npins to structure flake
