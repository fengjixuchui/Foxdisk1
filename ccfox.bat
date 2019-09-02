@echo off
@echo 1 ±‡“Î÷–Œƒ”≤≈Ã∞Ê(ŒﬁOS)foxdisk
if not exist fox.asm goto next
pause
tasm fox.asm
pause
tlink fox.obj
exe2bin fox.exe fox.bin
pause
:next
@echo 2 Compile _Dosfox.asm...
pause
if not exist _Dosfox.asm goto end
tasm _Dosfox.asm
pause
tlink _Dosfox.obj
pause
if exist fox.exe del fox.exe
if exist *.obj del *.obj
if exist *.map del *.map
if exist *.bak del *.bak
:end