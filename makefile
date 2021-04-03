BuildFS: FS.bin
	cp "Builds/FS.bin" "Builds/FlameOS.img"
	truncate --size 1M "Builds/FlameOS.img" 
	if test -f "Builds/FlameOS.vdi"; then rm "Builds/FlameOS.vdi"; fi
	VBoxManage convertfromraw "Builds/FlameOS.img" "Builds/FlameOS.vdi"

FS.bin: Bootloader
	nasm -fbin Kernel.asm -o "Builds/FS1.bin"
	nasm -fbin Bootloader -o "Builds/BL.bin"
	nasm -fbin FS.asm -o "Builds/FS2.bin"
	nasm -fbin "FS/Terminal.asm" -o "Builds/Terminal.bin"
	nasm -fbin "FS/Snake.asm" -o "Builds/Snake.bin"
	dd if="Builds/BL.bin" of="Builds/FS.bin" bs=512 conv=notrunc
	dd if="Builds/FS1.bin" of="Builds/FS.bin" bs=512 seek=1 conv=notrunc
	dd if="Builds/FS2.bin" of="Builds/FS.bin" bs=512 seek=13 conv=notrunc
	dd if="Builds/Terminal.bin" of="Builds/FS.bin" bs=512 seek=17 conv=notrunc
	dd if="Builds/Snake.bin" of="Builds/FS.bin" bs=512 seek=21 conv=notrunc

