
; Input: si - Start of string.
 
printStr:
    pusha
    
    .loop:
        mov al, [si]
        
        cmp al, 0
        jne .print
        popa
        ret
        
    .print:
        mov ah, 0x0E
        
        int 0x10
        
        inc si
        jmp .loop



; Input: cx - Hex value.

printHex:
    mov bx, cx
    shr bx, 12
    mov bl, [.HEXTable + bx]
    mov [.HEX+2], bl
    
    mov bx, cx
    shr bx, 8
    and bx, 0fh
    mov bl, [.HEXTable + bx]
    mov [.HEX+3], bl
    
    mov bx, cx
    shr bx, 4
    and bx, 0fh
    mov bl, [.HEXTable + bx]
    mov [.HEX], bl
    
    mov bx, cx
    and bx, 0fh
    mov bl, [.HEXTable + bx]
    mov [.HEX+1], bl
    
    mov si, .HEX
    call printStr
    
    ret
    
    .HEX: db '0000h', 0
    .HEXTable: dw '0123456789ABCDEF'
