;====== BPFunc_ClearScreen()
;@param None
;@return None
BPFunc_ClearScreen:
    mov ax, 0x0600
    mov bh, 0x02
    mov cx, 0
    mov dx, 0x184f
    int 0x10
    ret

;======= BPFunc_SetFocus(row, col)
;@param dh: row number
;@param dl: column number
;@return None
BPFunc_SetFocus:
    mov ah, 0x02
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

;======= BPFunc_ConvertLBA2CHS(LBA)
;@param ax: LBA(Logical Block Address)
;@return cx: CS(Sector: bit 0~5, Cylindar high 2 bits(only for hd): bit 6~7, Cylindar low 8 bits: bit 8~15)
;@return dh: H(header)
BPFunc_ConvertLBA2CHS:
    push bx
    mov bl, byte [BPB_SecPerTrk]
    div bl
    mov dh, al
    and dh, 0x01
    shr al, 1
    mov ch, al
    inc ah
    mov cl, ah
    pop bx
    ret

;======= BPFunc_ReadOneSector(LBA)
;@param ax: LBA
;@return None
BPFunc_ReadOneSector:
    call BPFunc_ConvertLBA2CHS
    mov ax, 0x0201
    mov dl, [BS_DrvNum]
    mov bx, TempBufferAddress
    int 0x13
    ;jc Label_ReadSectorFail
    ret

;ReadSectorErr db "Read Sector Fail"
;Label_ReadSectorFail:
    ;mov bp, ReadSectorErr
    ;mov cx, Label_ReadSectorFail - ReadSectorErr
    ;mov dx, 0x1800
    ;call BPFunc_DisplayString
    ;jmp $

;======= BPFunc_SearchLoader()
;@param None
LoaderFileName db "LOADER  BIN"
BPFunc_SearchLoader:
    mov cx, RootDirSectors
    mov ax, SectorNumOfRootDirStart

Label_SearchInRootDir:
    cmp cx, 0
    jz Label_SearchLoaderFail
    dec cx
    push cx
    push ax
    call BPFunc_ReadOneSector
    mov si, LoaderFileName
    mov di, TempBufferAddress
    cld
    mov dx, 16 ;512 / 32

Label_SearchForLoader:
    cmp dx, 0
    jz Label_SearchNextSector
    dec dx
    mov cx, 11

Label_CmpFileName:
    cmp cx, 0
    jz Label_FoundLoader
    dec cx
    cmp al, byte [es:di]
    jnz Label_SearchNextIndex
    inc di
    jmp Label_CmpFileName

Label_SearchNextIndex:
    and di, 0xffe0
    add di, 0x20
    jmp Label_SearchForLoader

Label_SearchNextSector:
    pop ax
    inc ax
    pop cx
    jmp Label_SearchInRootDir

SearchLoaderErr db "Search Loader Fail"
Label_SearchLoaderFail:
    mov bp, SearchLoaderErr
    mov cx, Label_SearchLoaderFail - SearchLoaderErr
    mov dx, 0x1800
    call BPFunc_DisplayString
    jmp $

Label_FoundLoader:
    pop ax
    pop cx
    ret
