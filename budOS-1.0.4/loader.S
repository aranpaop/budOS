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

;0x0b03
total_mem_bytes:
    dd 0

gdt_ptr:
    dw GDT_LIMIT
    dd GDT_BASE

ards_buf:
    times 244 db 0
ards_nr:
    dw 0

loader_start:
;int 15h, eax=0000E820h, edx=534D4150h
    xor ebx, ebx
    mov edx, 0x534d4150
    mov di, ards_buf

.e820_mem_get_loop:
    mov eax, 0x0000e820
    mov ecx, 20
    int 0x15
    jc .e820_mem_get_failed
    add di, cx
    inc word [ards_nr]
    cmp ebx, 0
    jnz .e820_mem_get_loop

    mov cx, [ards_nr]
    mov ebx, ards_buf
    xor edx, edx

.find_max_mem_area:
    mov eax, [ebx]
    add eax, [ebx+8]
    add ebx, 20
    cmp edx, eax
    jge .next_ards
    mov edx, eax

.next_ards:
    loop .find_max_mem_area
    jmp .mem_get_ok

.e820_mem_get_failed:
    mov byte [gs:0x2a], 'F'
    mov byte [gs:0x2b], 0x71

    mov byte [gs:0x2c], 'A'
    mov byte [gs:0x2d], 0x71

    mov byte [gs:0x2e], 'I'
    mov byte [gs:0x2f], 0x71

    mov byte [gs:0x30], 'L'
    mov byte [gs:0x31], 0x71

    mov byte [gs:0x32], '!'
    mov byte [gs:0x33], 0x71

    jmp $

.mem_get_ok:
    mov [total_mem_bytes], edx

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

    call setup_page

    sgdt [gdt_ptr]

    mov ebx, [gdt_ptr + 2]
    or dword [ebx + 0x18 + 4], 0xc0000000
    add dword [gdt_ptr + 2], 0xc0000000
    add esp, 0xc0000000

    mov eax, PAGE_DIR_TABLE_POS
    mov cr3, eax

    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax

    lgdt [gdt_ptr]

    mov byte [gs:320], 'V'
    mov byte [gs:321], 0x71

    jmp $

setup_page:
    mov ecx, 4096
    mov esi, 0

.clear_page_dir:
    mov byte [PAGE_DIR_TABLE_POS + esi], 0
    inc esi
    loop .clear_page_dir

.create_pde:
    mov eax, PAGE_DIR_TABLE_POS
    add eax, 0x1000
    mov ebx, eax

    or eax, PG_US_U | PG_RW_W | PG_P
    mov [PAGE_DIR_TABLE_POS + 0x00], eax
    mov [PAGE_DIR_TABLE_POS + 0xc00], eax
    sub eax, 0x1000
    mov [PAGE_DIR_TABLE_POS + 4092], eax

    mov ecx, 256
    mov esi, 0
    mov edx, PG_US_U | PG_RW_W | PG_P

.create_pte:
    mov [ebx + esi * 4], edx
    add edx, 4096
    inc esi
    loop .create_pte

    mov eax, PAGE_DIR_TABLE_POS
    add eax, 0x2000
    or eax, PG_US_U | PG_RW_W | PG_P
    mov ebx, PAGE_DIR_TABLE_POS
    mov ecx, 254
    mov esi, 769

.create_kernel_pde:
    mov [ebx + esi * 4], eax
    inc esi
    add eax, 0x1000
    loop .create_kernel_pde
    ret
