 
enableA20:
    ; BIOS
    pusha
    mov ax, 0x2401
    int 0x15
    
    call testA20
    cmp ax, 1
    je .enabled
    
    ; Keyboard Controller
    sti
    
    call .WaitA
    mov al, 0xad
    out 0x64, al
    
    call .WaitA
    mov al, 0xd8
    out 0x64, al
    
    call .WaitB
    in al, 0x60
    push ax
    
    call .WaitA
    mov al, 0xd1
    out 0x64, al
    
    call .WaitA
    pop ax
    or ax, 2
    out 0x60, al
    
    call .WaitA
    mov al, 0xae
    out 0x64, al
    
    call .WaitA
    
    jmp .T3
    
    .WaitA:
        in al, 0x64
        test al, 2
        jnz .WaitA
        ret
    
    .WaitB:
        in al, 0x64
        test al, 1
        jz .WaitB
        ret
        
    .T3:
        sti
    
    call testA20
    cmp ax, 1
    je .enabled
    
    ; Fast A20
    
    in al, 0x92
    or al, 2
    out 0x92, al
    
    call testA20
    cmp ax, 1
    je .enabled
    
    ; Failed
    
    mov si, .Failed
    call printStr
    
    jmp $
    
    .enabled:
        popa
        ret
    
    .Failed: db 'Failed to enable A20.', 0x0a, 0x0d, 0

; Output: ax - 1 if enabled, 0 if not enabled

testA20:
    pusha
    
    mov ax, [0x7dfe]
    
    push bx
    mov bx, 0xffff
    mov es, bx
    pop bx
    
    mov bx, 0x7e0e
    
    mov dx, [es:bx]
    
    cmp ax, dx
    jne .enabled
    
    popa
    
    xor ax, ax
    ret
    
    .enabled:
        popa
        
        mov ax, 1
        ret
