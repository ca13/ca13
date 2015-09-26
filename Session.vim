let SessionLoad = 1
if &cp | set nocp | endif
let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
let v:this_session=expand("<sfile>:p")
silent only
cd ~/ca13
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
set shortmess=aoO
badd +0 .vimrc
argglobal
silent! argdel *
argadd .vimrc
edit .vimrc
set splitbelow splitright
wincmd t
set winheight=1 winwidth=1
argglobal
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
1,10fold
12,21fold
25,54fold
56,64fold
66,69fold
23,70fold
74,90fold
92,100fold
102,128fold
130,136fold
72,137fold
141,149fold
155,166fold
168,175fold
177,182fold
188,204fold
206,222fold
224,248fold
250,255fold
257,263fold
265,270fold
272,277fold
279,287fold
289,302fold
304,316fold
318,323fold
325,333fold
335,343fold
345,353fold
355,360fold
362,367fold
369,379fold
381,386fold
184,388fold
151,391fold
139,391fold
395,405fold
409,424fold
426,440fold
442,445fold
407,446fold
448,461fold
463,471fold
473,479fold
483,495fold
497,501fold
503,513fold
515,518fold
520,530fold
532,536fold
538,545fold
481,546fold
551,572fold
574,584fold
586,592fold
594,598fold
600,612fold
548,613fold
615,622fold
624,629fold
631,639fold
641,647fold
654,670fold
672,687fold
689,698fold
649,699fold
703,707fold
709,712fold
714,716fold
718,721fold
723,725fold
701,739fold
743,747fold
749,757fold
741,757fold
393,757fold
759,779fold
784,791fold
793,798fold
800,805fold
807,811fold
813,820fold
822,826fold
828,831fold
833,836fold
838,841fold
843,847fold
849,852fold
854,857fold
859,863fold
865,869fold
871,874fold
876,879fold
881,888fold
890,893fold
781,894fold
898,904fold
906,912fold
914,917fold
919,922fold
924,934fold
936,951fold
953,970fold
972,983fold
985,989fold
896,990fold
995,1014fold
1016,1037fold
1039,1060fold
1062,1069fold
1071,1086fold
1088,1095fold
1097,1103fold
1105,1119fold
1121,1136fold
1138,1146fold
1148,1160fold
1166,1208fold
1210,1328fold
1330,1430fold
1432,1447fold
1162,1448fold
1162,1449fold
992,1449fold
1451,1458fold
let s:l = 1 - ((0 * winheight(0) + 8) / 17)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
1
normal! 0
lcd ~/ca13
tabnext 1
if exists('s:wipebuf')
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=999 winwidth=84 shortmess=filnxtToO
let s:sx = expand("<sfile>:p:r")."x.vim"
if file_readable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &so = s:so_save | let &siso = s:siso_save
let g:this_session = v:this_session
let g:this_obsession = v:this_session
let g:this_obsession_status = 2
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
