# Haven

My personal neovim configuraton This neovim flake is based off of [Gerg-L's](https://github.com/Gerg-L)
[Minimal Neovim Wrapper (mnv)](https://gerg-l.github.io/mnw/).

This was chosen as it is a simple interface to wrap neovim configuration and plugins but also does not require
any special nix-isms. The goal of this configuration is to be used either via nix or just cloning this into
a ~/.config directory.

## Which config runs

The nix package's `nvim` picks a config each time it starts:

1. If `$XDG_CONFIG_HOME/${NVIM_APPNAME:-nvim}` has an `init.lua` or `init.vim`, that config wins. Neovim runs as
   stock, with nothing from the nix build on `runtimepath` or `packpath`. The haven toolchain (LSPs, formatters, ...)
   is still appended to `PATH`.
2. `--clean` and `-u` also run stock neovim.
3. Otherwise the bundled haven config runs with nix-provided plugins. `NVIM_APPNAME` defaults to `nvim-haven`.

To use the bundled config while a `~/.config/nvim` exists, pick an app name with no config:
`NVIM_APPNAME=nvim-haven nvim`.

### Without nix

```sh
just link     # symlink this repo to ~/.config/nvim
just install  # clone the pinned plugins into ~/.local/share/nvim/site/pack/haven
```

`tests/config-selection.sh` proves these rules against a built `nvim`. `nix flake check` runs it for both packages.

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
