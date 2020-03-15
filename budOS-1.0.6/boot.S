    org 0x7c00
    jmp Label_BootStart
%include "bootloader_utils.inc"

LOADER_BASE_ADDR equ 0x900
LOADER_START_SECTOR equ 2
LOADER_SECTOR_NUMBER equ 4

BootMsg db 'Start boot'

Label_BootStart:
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov ss, ax
    mov sp, 0x7c00

    call BPFunc_ClearScreen

    mov bp, BootMsg
    mov cx, 10
    mov dx, 0x0000
    call BPFunc_DisplayString

    mov eax, LOADER_START_SECTOR
    mov cl, LOADER_SECTOR_NUMBER
    mov bx, LOADER_BASE_ADDR
    call BPFunc_ReadNSectors

    jmp LOADER_BASE_ADDR

;====== BPFunc_ClearScreen()
;@param None
;@return None
BPFunc_ClearScreen:
    mov ax, 0x0600
    mov bh, 0x02
    mov cx, 0x0000
    mov dx, 0x184f
    int 0x10
    ret

    times 510 - ($ - $$) db 0
    dw 0xaa55
