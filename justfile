set positional-arguments

profile op="snacks":
  NVIM_PROFILE={{op}} nvim

install appname="nvim-haven":
  @NVIM_APPNAME="{{appname}}" nvim --clean --headless -u ./npack.lua +PackInstall +qa

clean appname="nvim-haven":
  @NVIM_APPNAME="{{appname}}" nvim --clean --headless -u ./npack.lua +PackClean +qa

link name="nvim":
  @ln -s $(pwd) $HOME/.config/{{name}}

unlink name="nvim":
  #!/usr/bin/env bash
  if [ -L $HOME/.config/{{name}} ] && [ "$(readlink $HOME/.config/{{name}})" == "$(pwd)" ]; then
    rm $HOME/.config/{{name}}
  fi
