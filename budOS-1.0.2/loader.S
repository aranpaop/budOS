%include "boot.inc"
section loader vstart=LOADER_BASE_ADDR
LOADER_STACK_TOP equ LOADER_BASE_ADDR
jmp loader_start

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
times 60 dq 0
;equals (CODE_DESC - GDT_BASE) / 8 + TIGDT + RPL)
SELECTOR_CODE equ (0x0001 << 3) + TI_GDT + RPL0
SELECTOR_DATA equ (0x0002 << 3) + TI_GDT + RPL0
SELECTOR_VIDEO equ (0x0003 << 3) + TI_GDT + RPL0

gdt_ptr:
    dw GDT_LIMIT
    dd GDT_BASE
loadermsg:
    db 'Loader in real.'

loader_start:
;INT 0x10 0x13 print string
    mov sp, LOADER_BASE_ADDR
    mov bp, loadermsg
    mov cx, 15
    mov ax, 0x1301
    mov bx, 0x001f
    mov dx, 0x1800
    int 0x10

;enter protect mode
;open A20
in al, 0x92
or al, 0000_0010b
out 0x92, al

;load gdt
lgdt [gdt_ptr]

;set cr0
mov eax, cr0
or eax, 0x00000001
mov cr0, eax

jmp dword SELECTOR_CODE:p_mode_start

[bits 32]
p_mode_start:
    mov ax, SELECTOR_DATA
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, LOADER_STACK_TOP
    mov ax, SELECTOR_VIDEO
    mov gs, ax

    mov byte [gs:160], 'I'
    mov byte [gs:161], 0x71

    mov byte [gs:162], 'n'
    mov byte [gs:163], 0x71

    mov byte [gs:164], ' '
    mov byte [gs:165], 0x71

    mov byte [gs:166], 'p'
    mov byte [gs:167], 0x71

    mov byte [gs:168], '_'
    mov byte [gs:169], 0x71

    mov byte [gs:170], 'm'
    mov byte [gs:171], 0x71

    mov byte [gs:172], 'o'
    mov byte [gs:173], 0x71

    mov byte [gs:174], 'd'
    mov byte [gs:175], 0x71

    mov byte [gs:176], 'e'
    mov byte [gs:177], 0x71

    mov byte [gs:178], '.'
    mov byte [gs:179], 0x71

    jmp $
