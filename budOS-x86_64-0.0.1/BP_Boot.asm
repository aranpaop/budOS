    org 0x7c00

    jmp Label_BootStart
    nop

%include "BP_CommonDefinitions.inc"
%include "BP_BootLoaderUtils.inc"

BaseOfStack       equ 0x7c00
BaseOfLoader      equ 0x1000
OffsetOfLoader    equ 0
TempBufferAddress equ 0x8000

RootDirSectors          equ 14
SectorNumOfRootDirStart equ 19
SectorNumOfFAT1Start    equ 1
SectorBalance           equ 17

BootStartMessage db "Start Boot..."

Label_BootStart:
    mov sp, BaseOfStack

    call BPFunc_ClearScreen

    mov dx, 0
    call BPFunc_SetFocus

    mov bp, BootStartMessage
    mov cx, Label_BootStart - BootStartMessage
    call BPFunc_DisplayString

    call BPFunc_SearchLoader

    jmp $

    times 510 - ($ - $$) db 0
    dw 0xaa55
