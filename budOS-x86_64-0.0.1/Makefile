all: clean build write

clean:
	rm -rf *.bin

build:
	nasm -I include -o BP_Boot.bin BP_Boot.asm
	nasm -I include -o BP_Loader.bin BP_Loader.asm

write:
	dd if=BP_Boot.bin of=/home/buddingpop/tools/bochs/bp_disk_x86_64.img bs=512 count=1 conv=notrunc
	mount /home/buddingpop/tools/bochs/bp_disk_x86_64.img /media/ -t vfat -o loop
	cp BP_Loader.bin /media/
	sync
	umount /media/
