rm -rf mbr.bin
nasm mbr.S -o mbr.bin
dd if=mbr.bin of=bp_disk.img bs=512 count=1 conv=notrunc
%bochs_path%\bochs -f %bochs_path%\bochsrc
pause