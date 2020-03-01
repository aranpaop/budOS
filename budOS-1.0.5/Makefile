clean:
	rm -rf *.bin
	rm -rf kernel/*.o kernel/*.bin
	rm -rf lib/kernel/*.o

build:
	nasm -I include -o mbr.bin mbr.S
	nasm -I include -o loader.bin loader.S
	nasm -f elf -o lib/kernel/print.o lib/kernel/print.S
	gcc -I lib/kernel -c -m32 -o kernel/main.o kernel/main.c
	ld -m elf_i386 -Ttext 0xc0001500 -e main -o kernel.bin kernel/main.o lib/kernel/print.o

write:
	dd if=mbr.bin of=/home/buddingpop/tools/bochs/bp_disk.img seek=0 bs=512 count=1 conv=notrunc
	dd if=loader.bin of=/home/buddingpop/tools/bochs/bp_disk.img seek=2 bs=512 count=4 conv=notrunc
	dd if=kernel.bin of=/home/buddingpop/tools/bochs/bp_disk.img seek=9 bs=512 count=200 conv=notrunc
