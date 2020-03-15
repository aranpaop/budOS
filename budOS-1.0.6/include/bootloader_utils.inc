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

;======= BPFunc_ReadNSectors(startSector, numSectors, addr)
;@param eax: start sector(LBA28)
;@param cx: number of sectors
;@param es:bx: address of RAM
;@return None
BPFunc_ReadNSectors:
    push cx
    push eax
    mov al, cl
    mov dx, 0x1f2
    out dx, al
    pop eax
    mov dx, 0x1f3
    out dx, al
    shr eax, 8
    mov dx, 0x1f4
    out dx, al
    shr eax, 8
    mov dx, 0x1f5
    out dx, al
    shr eax, 8
    and al, 0x0f
    or al, 0xe0
    mov dx, 0x1f6
    out dx, al
    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

Label_NotReady:
    nop
    in al, dx
    and al, 0x88
    cmp al, 0x08
    jnz Label_NotReady
    pop ax
    mov cx, 256 ;512 / 2
    mul cx
    mov cx, ax
    mov dx, 0x1f0

Label_GoOnRead:
    in ax, dx
    mov [es:bx], ax
    add bx, 2
    loop Label_GoOnRead
    ret
