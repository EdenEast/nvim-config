set positional-arguments

profile op="snacks":
  NVIM_PROFILE={{op}} nvim

install appname="nvim-haven":
  @NVIM_APPNAME="{{appname}}" nvim --clean --headless -u ./npack.lua +PackInstall +qa

clean appname="nvim-haven":
  @NVIM_APPNAME="{{appname}}" nvim --clean --headless -u ./npack.lua +PackClean +qa
