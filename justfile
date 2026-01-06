set positional-arguments
set windows-shell := ["powershell.exe", "-NoLogo", "-Command"]

[unix]
profile op="snacks":
  NVIM_PROFILE={{op}} nvim

[unix]
install appname="nvim-haven":
  @NVIM_APPNAME="{{appname}}" nvim --clean --headless -u ./npack.lua +PackInstall

[unix]
clean appname="nvim-haven":
  @NVIM_APPNAME="{{appname}}" nvim --clean --headless -u ./npack.lua +PackClean

[unix]
uninstall appname="nvim-haven":
  @NVIM_APPNAME="{{appname}}" nvim --clean --headless -u ./npack.lua +PackUninstall

[unix]
status appname="nvim-haven":
  @NVIM_APPNAME="{{appname}}" nvim --clean --headless -u ./npack.lua +PackStatus

[unix]
link name="nvim":
  @ln -s $(pwd) $HOME/.config/{{name}}

[unix]
unlink name="nvim":
  #!/usr/bin/env bash
  if [ -L $HOME/.config/{{name}} ] && [ "$(readlink $HOME/.config/{{name}})" == "$(pwd)" ]; then
    rm $HOME/.config/{{name}}
  fi

# -------------------------------------------------------------------------------------

[unix]
profile op="snacks":
  NVIM_PROFILE={{op}} nvim

[windows]
install appname="nvim-haven":
  @$env:NVIM_APPNAME = "{{appname}}" ; nvim --clean --headless -u ./npack.lua +PackInstall

[windows]
clean appname="nvim-haven":
  @$env:NVIM_APPNAME = "{{appname}}" ; nvim --clean --headless -u ./npack.lua +PackClean

[windows]
uninstall appname="nvim-haven":
  @$env:NVIM_APPNAME = "{{appname}}" ; nvim --clean --headless -u ./npack.lua +PackUninstall

[windows]
status appname="nvim-haven":
  @$env:NVIM_APPNAME = "{{appname}}" ; nvim --clean --headless -u ./npack.lua +PackStatus
