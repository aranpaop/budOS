;Master Boot Record
;
;LOADER_BASE_ADDR equ 0xA000
;LOADER_START_SECTOR equ 0x2
;------------------------------------------
%include "boot.inc"
SECTION MBR vstart=0x7c00
    mov ax, 0x7c00
    mov sp, ax

;------------------------------------------
;INT0x10 0x06 clear screen
;------------------------------------------
    mov ax, 0x0600
    mov bx, 0x0700
    mov cx, 0x0000
    mov dx, 0x184f
    int 0x10
;------------------------------------------

    mov ax, 0xb800
    mov gs, ax

    mov byte [gs:0x00], 'I'
    mov byte [gs:0x01], 0x71

    mov byte [gs:0x02], 'n'
    mov byte [gs:0x03], 0x71

    mov byte [gs:0x04], ' '
    mov byte [gs:0x05], 0x71

    mov byte [gs:0x06], 'M'
    mov byte [gs:0x07], 0x71

    mov byte [gs:0x08], 'B'
    mov byte [gs:0x09], 0x71

    mov byte [gs:0x0a], 'R'
    mov byte [gs:0x0b], 0x71

    mov byte [gs:0x0c], '.'
    mov byte [gs:0x0d], 0x71

    mov eax, LOADER_START_SECTOR
    mov bx, LOADER_BASE_ADDR
    mov cx, 4
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
