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
649,687fold
691,695fold
697,700fold
702,704fold
706,709fold
711,713fold
689,727fold
731,735fold
737,745fold
729,745fold
393,745fold
747,767fold
772,779fold
781,786fold
788,793fold
795,799fold
801,808fold
810,814fold
816,819fold
821,824fold
826,829fold
831,835fold
837,840fold
842,845fold
847,851fold
853,857fold
859,862fold
864,867fold
869,876fold
878,881fold
769,882fold
886,892fold
894,900fold
902,905fold
907,910fold
912,922fold
924,939fold
941,958fold
960,971fold
973,977fold
884,978fold
983,1002fold
1004,1025fold
1027,1048fold
1050,1057fold
1059,1074fold
1076,1083fold
1085,1091fold
1093,1107fold
1109,1125fold
1127,1135fold
1137,1149fold
1155,1197fold
1199,1317fold
1319,1419fold
1421,1436fold
1151,1437fold
1151,1438fold
980,1438fold
1440,1447fold
let s:l = 648 - ((255 * winheight(0) + 9) / 18)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
648
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
