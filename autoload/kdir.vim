let s:width=nvim_get_option("columns")
let s:height=nvim_get_option("lines")
let s:win1conf={"style":"minimal","relative":"editor","width":s:width/2,"height":s:height/2,"row":s:height/4,"col":s:width/4,"focusable":v:false}
let s:win2conf={"style":"minimal","relative":"editor","width":s:width/2,"height":1,"row":s:height/4-1,"col":s:width/4,"focusable":v:false}
let s:win3conf={"style":"minimal","relative":"editor","width":s:width/2-4,"height":s:height/2-2,"row":s:height/4+1,"col":s:width/4+2,"focusable":v:false}
let s:file_icon="📄 "
let s:folder_icon="📁 "
let s:return_icon="↩︎ "
let s:tab="\t"
let s:shown=0
let s:win_num=0
let s:dir=[]
let s:win2buf=0
let s:path=split(getcwd(),"/")
let s:current_win=0
hi! kdir_background ctermbg=17 ctermfg=50

function kdir#Explorer()
  call s:CreateWin()
  call s:tree()
endfunction

function s:CreateWin()
  if !s:shown
    let s:current_win=win_getid()
    let s:shown=1
    let s:win1_id=nvim_open_win(nvim_create_buf(v:false,v:true),v:true,s:win1conf)
    call nvim_win_set_option(s:win1_id,"winhighlight","Normal:Normal")
    let s:win_num=buffer_number()
    let str1=""
    let str2=""
    for i in range(s:width/2-2)
      let str1=str1."─"
      let str2=str2." "
    endfor
    call setline(1,"┌".str1."┐")
    for i in range(s:height/2)
      call setline(i+2,"│".str2."│")
    endfor
    call setline(s:height/2,"└".str1."┘")
    let s:win2_id=nvim_open_win(nvim_create_buf(v:false,v:true),v:true,s:win2conf)
    call nvim_win_set_option(s:win2_id,"winhighlight","Normal:kdir_background")
    let s:win2buf=buffer_number()
    let s:win3_id=nvim_open_win(nvim_create_buf(v:false,v:true),v:true,s:win3conf)
    call nvim_win_set_option(s:win3_id,"winhighlight","Normal:Normal")
    nnoremap <buffer> <nowait> <silent> <ESC> :q<CR>
    nnoremap <buffer> <silent> <Enter> :call <SID>select()<CR>
    nnoremap <buffer> <silent> a :<CR>
    nnoremap <buffer> <silent> i :<CR>
    nnoremap <buffer> <silent> o :<CR>
    autocmd! WinClosed * :call s:CloseWin()
    autocmd! BufLeave * :call s:CloseWin()
  endif
endfunction

function s:CloseWin()
  if s:shown
    execute "close ".s:win_num
    execute "close ".(s:win_num+1)
    execute "close ".(s:win_num+2)
    let s:shown=0
  endif
  autocmd! WinClosed *
  autocmd! BufLeave *
endfunction

function s:tree()
  for i in range(len(getline(0,"$")))
    d
  endfor
  echo ""
  let s:dir=readdir(".")
  call setline(1,s:return_icon)
  for i in range(len(s:dir))
    if isdirectory(s:dir[i])
      let icon=s:folder_icon
    else
      let icon=s:file_icon
    endif
    call setline(i+2,icon.s:dir[i])
  endfor
  echo 
  call setbufline(s:win2buf,1,"/".join(s:path,"/"))
endfunction

function s:select()
  if s:shown
    let pos=getcurpos()[1]
    if pos==1
      if len(s:path)!=0
	call remove(s:path,-1)
	execute "cd /".join(s:path,"/")
	call s:tree()
      endif
    elseif isdirectory(s:dir[pos-2])
      let s:path=add(s:path,s:dir[pos-2])
      execute "cd /".join(s:path,"/")
      call s:tree()
    else
      call win_execute(s:current_win,"e "."/".join(s:path,"/")."/".s:dir[pos-2])
      call win_gotoid(s:current_win)
    endif
  endif
endfunction
