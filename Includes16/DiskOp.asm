
; Input: dl - drive to load from, al - ammount of sectors to load, bx - buffer address

diskLoad:
    pusha
    
    .reset:
        push ax
        xor ax, ax
        
        int 0x13
        
    .load:
        pop ax
        popa
        pusha
        
        mov ch, 0x00
        mov dh, 0
        
        push ax
        mov ah, 0x02

        int 0x13
        
        jc .counter
        
        mov cl, al
        pop ax
        cmp al, cl
        je .done
        
    .counter:
        mov cx, 3
        cmp [.C], cx
        je .err
        mov cx, 1
        add [.C], cx
        jmp .reset
    
    .C: db 0x0
    
    .Error: db 'Error reading sectors.', 0
    
    .err:
        mov si, .Error
        call printStr
        
        jmp $
    
    .done:
        popa
        ret
