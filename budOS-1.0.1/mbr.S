;主引导程序
;
;LOADER_BASE_ADDR equ 0xA000
;LOADER_START_SECTOR equ 0x2
;------------------------------------------
%include "boot.inc"
SECTION MBR vstart=0x7c00
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov sp, 0x7c00
    mov ax, 0xb800
    mov gs, ax

;------------------------------------------
;上卷窗口 INT0x10 0x06
;------------------------------------------
    mov ax, 0600h
    mov bx, 0700h
    mov cx, 0
    mov dx, 184fh
    int 10h
;------------------------------------------
    mov byte [gs:0x00], 'B'
    mov byte [gs:0x01], 0x71

    mov byte [gs:0x02], 'u'
    mov byte [gs:0x03], 0x71

    mov byte [gs:0x04], 'd'
    mov byte [gs:0x05], 0x71

    mov byte [gs:0x06], 'd'
    mov byte [gs:0x07], 0x71

    mov byte [gs:0x08], 'i'
    mov byte [gs:0x09], 0x71

    mov byte [gs:0x0a], 'n'
    mov byte [gs:0x0b], 0x71

    mov byte [gs:0x0c], 'g'
    mov byte [gs:0x0d], 0x71

    mov byte [gs:0x0e], 'p'
    mov byte [gs:0x0f], 0x71

    mov byte [gs:0x10], 'o'
    mov byte [gs:0x11], 0x71

    mov byte [gs:0x12], 'p'
    mov byte [gs:0x13], 0x71

    mov byte [gs:0x14], ' '
    mov byte [gs:0x15], 0x71

    mov byte [gs:0x16], 'i'
    mov byte [gs:0x17], 0x71

    mov byte [gs:0x18], 's'
    mov byte [gs:0x19], 0x71

    mov byte [gs:0x1a], ' '
    mov byte [gs:0x1b], 0x71

    mov byte [gs:0x1c], 'c'
    mov byte [gs:0x1d], 0x71

    mov byte [gs:0x1e], 'o'
    mov byte [gs:0x1f], 0x71

    mov byte [gs:0x20], 'm'
    mov byte [gs:0x21], 0x71

    mov byte [gs:0x22], 'i'
    mov byte [gs:0x23], 0x71

    mov byte [gs:0x24], 'n'
    mov byte [gs:0x25], 0x71

    mov byte [gs:0x26], 'g'
    mov byte [gs:0x27], 0x71

    mov byte [gs:0x28], '!'
    mov byte [gs:0x29], 0x71

    mov eax, LOADER_START_SECTOR ;LBA扇区号
    mov bx, LOADER_BASE_ADDR ;读入的内存地址
    mov cx, 1 ;读入的扇区数
    call rd_disk_m_16

    jmp LOADER_BASE_ADDR

;读取硬盘n个扇区
rd_disk_m_16:
    mov esi, eax ;备份
    mov di, cx ;备份
;读写硬盘
;第1步：设置要读取的扇区数
    mov dx, 0x1f2
    mov al, cl
    out dx, al

    mov eax, esi

;第2步：将LBA地址存入0x1f3～0x1f6
    mov dx, 0x1f3
    out dx, al

    mov cl, 8
    shr eax, cl
    mov dx, 0x1f4
    out dx, al

    shr eax, cl
    mov dx, 0x1f5
    out dx, al

    shr eax, cl
    and al, 0x0f
    or al, 0xe0
    mov dx, 0x1f6
    out dx, al

;第3步：向0x1f7端口写入读命令，0x20
    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

;第4步：检测硬盘状态
.not_ready:
    nop
    in al, dx
    and al, 0x88
    cmp al, 0x08
    jnz .not_ready

;第5步：从0x1f0端口读数据
    mov ax, di
    mov dx, 256
    mul dx
    mov cx, ax
    mov dx, 0x1f0

.go_on_read:
    in ax, dx
    mov [bx], ax
    add bx, 2
    loop .go_on_read
    ret

    times 510 - ($ - $$) db 0
    db 0x55, 0xaa
