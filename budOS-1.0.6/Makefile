clean:
	rm -rf *.bin

build:
	nasm -I include -o boot.bin boot.S
	nasm -I include -o loader.bin loader.S

write:
	dd if=boot.bin of=/home/buddingpop/tools/bochs/bp_disk.img bs=512 count=1 conv=notrunc
	dd if=loader.bin of=/home/buddingpop/tools/bochs/bp_disk.img seek=2 bs=512 count=4 conv=notrunc
