clean:
	rm -rf *.bin

build: mbr.S loader.S
	nasm -I include -o mbr.bin mbr.S
	nasm -I include -o loader.bin loader.S

write: mbr.bin loader.bin
	dd if=mbr.bin of=/home/buddingpop/tools/bochs/bp_disk.img seek=0 bs=512 count=1 conv=notrunc
	dd if=loader.bin of=/home/buddingpop/tools/bochs/bp_disk.img seek=2 bs=512 count=4 conv=notrunc
