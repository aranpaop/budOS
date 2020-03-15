%include "bp_bootloader_utils.inc"
    org LOADER_BASE_ADDR
    jmp Label_LoaderStart

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

Label_LoaderStart:
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov fs, ax

    mov ax, 0x0000
    mov ss, ax
    mov sp, 0x7c00

    BootMsg db 'Start loader...'
    mov bp, $ - BootMsg
    mov dx, 0x0100
    call BPFunc_DisplayString

    call BPFunc_GetTotalMemSize

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

    mov byte [gs:356], '.'
    mov byte [gs:357], 0x71

    mov byte [gs:358], '.'
    mov byte [gs:359], 0x71

    mov byte [gs:360], '.'
    mov byte [gs:361], 0x71

    mov eax, KERNEL_START_SECTOR
    mov ebx, KERNEL_BIN_BASE_ADDR
    mov ecx, 200
    call BPFunc_ReadNSectors

    call BPFunc_SetupPage

    sgdt [GDT_PTR]

    mov ebx, [GDT_PTR + 2]
    or dword [ebx + 0x18 + 4], 0xc0000000
    add dword [GDT_PTR + 2], 0xc0000000
    add esp, 0xc0000000

    mov eax, PAGE_DIR_TABLE_POS
    mov cr3, eax

    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax

    lgdt [GDT_PTR]

    mov byte [gs:480], 'S'
    mov byte [gs:481], 0x71

    mov byte [gs:482], 'e'
    mov byte [gs:483], 0x71

    mov byte [gs:484], 't'
    mov byte [gs:485], 0x71

    mov byte [gs:486], 'u'
    mov byte [gs:487], 0x71

    mov byte [gs:488], 'o'
    mov byte [gs:489], 0x71

    mov byte [gs:490], ' '
    mov byte [gs:491], 0x71

    mov byte [gs:492], 'p'
    mov byte [gs:493], 0x71

    mov byte [gs:494], 'a'
    mov byte [gs:495], 0x71

    mov byte [gs:496], 'g'
    mov byte [gs:497], 0x71

    mov byte [gs:498], 'e'
    mov byte [gs:499], 0x71

    mov byte [gs:500], '.'
    mov byte [gs:501], 0x71

    mov byte [gs:502], '.'
    mov byte [gs:503], 0x71

    mov byte [gs:504], '.'
    mov byte [gs:505], 0x71

    jmp SELECTOR_CODE:Label_EnterKernel

Label_EnterKernel:
    call BPFunc_InitKernel
    mov esp, 0xc009f000
    jmp KERNEL_ENTRY_POINT

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

;======= BPFunc_GetTotalMemSize()
;Wait for realizing
BPFunc_GetTotalMemSize:
    ret

;======= BPFunc_SetupPage()
;param None
;return None
BPFunc_SetupPage:
    mov ecx, 4096
    mov esi, 0

Label_ClearPageDir:
    mov byte [PAGE_DIR_TABLE_POS + esi], 0
    inc esi
    loop Label_ClearPageDir
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

Label_CreatePTE:
    mov [ebx + esi * 4], edx
    add edx, 4096
    inc esi
    loop Label_CreatePTE
    mov eax, PAGE_DIR_TABLE_POS
    add eax, 0x2000
    or eax, PG_US_U | PG_RW_W | PG_P
    mov ebx, PAGE_DIR_TABLE_POS
    mov ecx, 254
    mov esi, 769

Label_CreateKernelPDE:
    mov [ebx + esi * 4], eax
    inc esi
    add eax, 0x1000
    loop Label_CreateKernelPDE
    ret

;======= BPFunc_MemCpy()
BPFunc_MemCpy:
    cld
    push ebp
    mov ebp, esp
    push ecx
    mov edi, [ebp + 8]
    mov esi, [ebp + 12]
    mov ecx, [ebp + 16]
    rep movsb
    pop ecx
    pop ebp
    ret

;======= BPFunc_InitKernel()
BPFunc_InitKernel:
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx
    mov dx, [KERNEL_BIN_BASE_ADDR + 42]
    mov ebx, [KERNEL_BIN_BASE_ADDR + 28]
    add ebx, KERNEL_BIN_BASE_ADDR
    mov cx, [KERNEL_BIN_BASE_ADDR + 44]

Label_EachSegment:
    cmp byte [ebx + 0], PT_NULL
    je Label_PTNULL
    push dword [ebx + 16]
    mov eax, [ebx + 4]
    add eax, KERNEL_BIN_BASE_ADDR
    push eax
    push dword [ebx + 8]
    call BPFunc_MemCpy
    add esp, 12

Label_PTNULL:
    add ebx, edx
    loop Label_EachSegment
    ret
