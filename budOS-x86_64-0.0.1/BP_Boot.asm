    org 0x7c00

    jmp Label_BootStart
    nop

%include "BP_CommonDefinitions.inc"
%include "BP_BootLoaderUtils.inc"

BootStartMessage db "Start Boot..."

Label_BootStart:
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ax, 0
    mov ss, ax
    mov sp, 0x7c00

    call BPFunc_ClearScreen

    mov dx, 0
    call BPFunc_SetFocus

    mov bp, BootStartMessage
    mov cx, Label_BootStart - BootStartMessage
    call BPFunc_DisplayString

    call BPFunc_SearchLoader

    call BPFunc_ReadFileByInitClusterNumber

    jmp BaseOfLoader:OffsetOfLoader

    times 510 - ($ - $$) db 0
    dw 0xaa55
