    org 0x10000

    jmp Label_LoaderStart
    nop

%include "BP_CommonDefinitions.inc"
%include "BP_BootLoaderUtils.inc"

LoaderStartMessage db "Start Loader..."

Label_LoaderStart:
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ax, 0
    mov ss, ax
    mov sp, 0x7c00

    mov bp, LoaderStartMessage
    mov cx, Label_LoaderStart - LoaderStartMessage
    call BPFunc_DisplayString

    jmp $
