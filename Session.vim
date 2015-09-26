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
22,32fold
12,33fold
37,66fold
68,76fold
78,81fold
35,82fold
86,102fold
104,112fold
114,140fold
142,148fold
84,149fold
153,161fold
167,178fold
180,187fold
189,194fold
200,216fold
218,234fold
236,260fold
262,267fold
269,275fold
277,282fold
284,289fold
291,299fold
301,314fold
316,328fold
330,335fold
337,345fold
347,355fold
357,365fold
367,372fold
374,379fold
381,391fold
393,398fold
196,400fold
163,403fold
151,403fold
407,417fold
421,436fold
438,452fold
454,457fold
419,458fold
460,473fold
475,483fold
485,491fold
495,507fold
509,513fold
515,525fold
527,530fold
532,542fold
544,548fold
550,557fold
493,558fold
563,584fold
586,596fold
598,604fold
606,610fold
612,624fold
560,625fold
627,634fold
636,641fold
643,651fold
653,659fold
666,682fold
684,699fold
701,710fold
661,711fold
715,719fold
721,724fold
726,728fold
730,733fold
735,737fold
713,751fold
755,759fold
761,769fold
753,769fold
405,769fold
771,791fold
796,803fold
805,810fold
812,817fold
819,823fold
825,832fold
834,838fold
840,843fold
845,848fold
850,853fold
855,859fold
861,864fold
866,869fold
871,875fold
877,881fold
883,886fold
888,891fold
893,900fold
902,905fold
793,906fold
910,916fold
918,924fold
926,929fold
931,934fold
936,946fold
948,963fold
965,982fold
984,995fold
997,1001fold
908,1002fold
1007,1026fold
1028,1049fold
1051,1072fold
1074,1081fold
1083,1098fold
1100,1107fold
1109,1115fold
1117,1131fold
1133,1138fold
1140,1148fold
1150,1162fold
1168,1210fold
1212,1330fold
1332,1432fold
1434,1449fold
1164,1450fold
1164,1451fold
1004,1451fold
1453,1460fold
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
