    org 0x7c00
    jmp Label_BootStart
%include "bp_bootloader_utils.inc"
Label_BootStart:
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov fs, ax

    mov ax, 0x0000
    mov ss, ax
    mov sp, 0x7c00

    call BPFunc_ClearScreen

    BootMsg db 'Start boot...'
    mov bp, $ - BootMsg
    mov dx, 0x0000
    call BPFunc_DisplayString

    mov eax, 1
    mov cl, 4
    mov bx, LOADER_BASE_ADDR
    call BPFunc_ReadNSectors

    jmp LOADER_BASE_ADDR

    times 510 - ($ - $$) db 0
    db 0x55, 0xaa
