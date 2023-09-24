if exists("g:loaded_kdir")
  finish
endif
let g:loaded_kdir=1

command! -nargs=0 KDir call kdir#Explorer()
