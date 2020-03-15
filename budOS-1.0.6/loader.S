    org 0x900
    jmp Label_LoaderStart
%include "bootloader_utils.inc"

LoaderMsg db 'Start loader'

Label_LoaderStart:
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov ss, ax
    mov sp, 0x7c00

    mov bp, LoaderMsg
    mov cx, 12
    mov dx, 0x0100
    call BPFunc_DisplayString

    jmp $
