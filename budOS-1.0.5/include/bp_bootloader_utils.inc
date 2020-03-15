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

;======= BPFunc_DisplayString(str, len, row, col)
;@param es:bp: string address
;@param cx: string length
;@param dh: row number
;@param dl: column number
;@return None
BPFunc_DisplayString:
    mov ax, 0x1301
    mov bx, 0x0002
    int 0x10
    ret

;======= BPFunc_ReadNSectors(startSector, numSectors, addt)
;@param eax: start sector(LBA28)
;@param cl: number of sectors
;@param es:bx: address of RAM
;@return None
BPFunc_ReadNSectors:
    push ax
    mov al, cl
    mov dx, 0x1f2
    out dx, al
    pop ax
    mov dx, 0x1f3
    out dx, al
    shr eax, 8
    mov dx, 0x1f4
    out dx, al
    shr eax, 8
    mov dx, 0x1f5
    out dx, al
    shr eax, 8
    or al, 0xe0
    mov dx, 0x1f6
    out dx, al
    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

Label_NotReady:
    nop
    mov dx, 0x1f7
    in al, dx
    and al, 0x88
    cmp al, 0x08
    jnz Label_NotReady
    mov ax, 256 ;512 / 2
    mul cl
    mov cx, ax

Label_GoOnRead:
    mov dx, 0x1f0
    in ax, dx
    mov [es:bx], ax
    add bx, 2
    loop Label_GoOnRead
    ret

LOADER_STACK_TOP equ 0x7c00
LOADER_BASE_ADDR equ 0x900
LOADER_START_SECTOR equ 0x2
PAGE_DIR_TABLE_POS equ 0x100000

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

;selector
RPL0 equ 0b00
RPL1 equ 0b01
RPL2 equ 0b10
RPL3 equ 0b11
TI_GDT equ 0b000
TI_LDT equ 0b100

;page
PG_P equ      0b1
PG_RW_R equ  0b00
PG_RW_W equ  0b10
PG_US_S equ 0b000
PG_US_U equ 0b100

;kernel
KERNEL_START_SECTOR equ 0x9
KERNEL_BIN_BASE_ADDR equ 0x70000
KERNEL_ENTRY_POINT equ 0xc0001500
PT_NULL equ 0
