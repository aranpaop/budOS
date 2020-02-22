clean:
	rm -rf *.img

img: budOS.asm
	nasm budOS.asm -o budOS.img

run: budOS.img
	qemu-system-x86_64 budOS.img