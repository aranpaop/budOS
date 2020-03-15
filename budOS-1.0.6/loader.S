    org 0x900
    jmp Label_LoaderStart
%include "bootloader_utils.inc"

LOADER_STACK_TOP equ 0x900

;gdt
DESC_G_4K equ     0b1_00000000000000000000000
DESC_D_32 equ      0b1_0000000000000000000000
DESC_L equ          0b0_000000000000000000000
DESC_AVL equ         0b0_00000000000000000000
DESC_LIMIT_CODE2 equ  0b1111_0000000000000000
DESC_LIMIT_DATA2 equ DESC_LIMIT_CODE2
DESC_LIMIT_VIDEO2 equ 0b0000_0000000000000000
DESC_P equ                0b1_000000000000000
DESC_DPL_0 equ             0b00_0000000000000
DESC_DPL_1 equ             0b01_0000000000000
DESC_DPL_2 equ             0b10_0000000000000
DESC_DPL_3 equ             0b11_0000000000000
DESC_S_CODE equ              0b1_000000000000
DESC_S_DATA equ DESC_S_CODE
DESC_S_sys equ               0b0_000000000000
DESC_TYPE_CODE equ            0b1000_00000000
DESC_TYPE_DATA equ            0b0010_00000000

DESC_CODE_HIGH4 equ (0x00 << 24) + DESC_G_4K + DESC_D_32 + \
    DESC_L + DESC_AVL + DESC_LIMIT_CODE2 + DESC_P + \
    DESC_DPL_0 + DESC_S_CODE + DESC_TYPE_CODE + 0x00

DESC_DATA_HIGH4 equ (0x00 << 24) + DESC_G_4K + DESC_D_32 + \
    DESC_L + DESC_AVL + DESC_LIMIT_DATA2 + DESC_P + \
    DESC_DPL_0 + DESC_S_DATA + DESC_TYPE_DATA + 0x00

DESC_VIDEO_HIGH4 equ (0x00 << 24) + DESC_G_4K + DESC_D_32 + \
    DESC_L + DESC_AVL + DESC_LIMIT_VIDEO2 + DESC_P + \
    DESC_DPL_0 + DESC_S_DATA + DESC_TYPE_DATA + 0x0b

;construct gdt
GDT_BASE:
    dd 0x00000000
    dd 0x00000000

CODE_DESC:
    dd 0x0000FFFF
    dd DESC_CODE_HIGH4

DATA_STACK_DESC:
    dd 0x0000FFFF
    dd DESC_DATA_HIGH4

VIDEO_DESC:
    dw 0x0007
    dw 0x8000
    dd DESC_VIDEO_HIGH4

GDT_SIZE equ $ - GDT_BASE
GDT_LIMIT equ GDT_SIZE - 1
times 60 dq 0 ;reserved

SELECTOR_CODE equ (0x0001 << 3) + TI_GDT + RPL0
SELECTOR_DATA equ (0x0002 << 3) + TI_GDT + RPL0
SELECTOR_VIDEO equ (0x0003 << 3) + TI_GDT + RPL0

GDT_PTR:
    dw GDT_LIMIT
    dd GDT_BASE

;selector
RPL0 equ 0b00
RPL1 equ 0b01
RPL2 equ 0b10
RPL3 equ 0b11
TI_GDT equ 0b000
TI_LDT equ 0b100

LoaderMsg db 'Start loader'

Label_LoaderStart:
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov ss, ax
    mov sp, 0x900

    mov bp, LoaderMsg
    mov cx, 12
    mov dx, 0x0100
    call BPFunc_DisplayString

    call BPFunc_EnterProtectMode

    jmp dword SELECTOR_CODE:Label_ProtectModeStart

[bits 32]
Label_ProtectModeStart:
    mov ax, SELECTOR_DATA
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, LOADER_STACK_TOP
    mov ax, SELECTOR_VIDEO
    mov gs, ax

    mov byte [gs:320], 'S'
    mov byte [gs:321], 0x71

    mov byte [gs:322], 't'
    mov byte [gs:323], 0x71

    mov byte [gs:324], 'a'
    mov byte [gs:325], 0x71

    mov byte [gs:326], 'r'
    mov byte [gs:327], 0x71

    mov byte [gs:328], 't'
    mov byte [gs:329], 0x71

    mov byte [gs:330], ' '
    mov byte [gs:331], 0x71

    mov byte [gs:332], 'p'
    mov byte [gs:333], 0x71

    mov byte [gs:334], 'r'
    mov byte [gs:335], 0x71

    mov byte [gs:336], 'o'
    mov byte [gs:337], 0x71

    mov byte [gs:338], 't'
    mov byte [gs:339], 0x71

    mov byte [gs:340], 'e'
    mov byte [gs:341], 0x71

    mov byte [gs:342], 'c'
    mov byte [gs:343], 0x71

    mov byte [gs:344], 't'
    mov byte [gs:345], 0x71

    mov byte [gs:346], ' '
    mov byte [gs:347], 0x71

    mov byte [gs:348], 'm'
    mov byte [gs:349], 0x71

    mov byte [gs:350], 'o'
    mov byte [gs:351], 0x71

    mov byte [gs:352], 'd'
    mov byte [gs:353], 0x71

    mov byte [gs:354], 'e'
    mov byte [gs:355], 0x71

    jmp $

[bits 16]
;======= BPFunc_EnterProtectMode()
;@param None
;@return None
BPFunc_EnterProtectMode:
    in al, 0x92
    or al, 0x02
    out 0x92, al
    lgdt [GDT_PTR]
    mov eax, cr0
    or eax, 0x00000001
    mov cr0, eax
    ret
