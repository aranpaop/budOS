clean:
	rm -rf *.bin
	rm -rf kernel/*.o kernel/*.bin

build: mbr.S loader.S kernel/main.c
	nasm -I include -o mbr.bin mbr.S
	nasm -I include -o loader.bin loader.S
	gcc -c -m32 -o kernel/main.o kernel/main.c
	ld -m elf_i386 -Ttext 0xc0001500 -e main -o kernel/main.bin kernel/main.o

write: mbr.bin loader.bin kernel/main.bin
	dd if=mbr.bin of=/home/buddingpop/tools/bochs/bp_disk.img seek=0 bs=512 count=1 conv=notrunc
	dd if=loader.bin of=/home/buddingpop/tools/bochs/bp_disk.img seek=2 bs=512 count=4 conv=notrunc
	dd if=kernel/main.bin of=/home/buddingpop/tools/bochs/bp_disk.img seek=9 bs=512 count=200 conv=notrunc
