		    ;---------------------00 - NULL
    mov edi, GDTTableLoc
    mov dword [edi], 0
    add edi, 4
    mov dword [edi], 0
    add edi, 4
                    ;---------------------08 - Stack
		    ;500 - 1500
    mov ax, 0x14ff
    mov [edi], ax
    
    add edi, 2
    
    push ax
    mov ax, 0x500
    mov [edi], ax
    pop ax
    
    add edi, 2
    
    xor ecx, ecx
    mov ch, 01010000b
    shl ecx, 8
    mov ch, 10010010b
    mov [edi], ecx
    
    add edi, 4
                    ;---------------------10 - TSS
		    ;1500 - 1564
    add ax, 0x65
    mov word [edi], 0x64
    
    add edi, 2
    push ax
    
    sub ax, 0x64
    mov [edi], ax
    
    pop ax    
    add edi, 2
    
    xor ecx, ecx
    mov ch, 0x40
    shl ecx, 8
    mov ch, 0x89
    mov [edi], ecx
    
    add edi, 4
   		    ;----------------------18 - Kernel Data
		    ;1565 - 145ff
    add ax, 0x4600-0x64-0x1500-1
    mov [edi], ax
    
    add edi, 2
    push ax
    sub ax, 0x4600-0x64-0x1500-2
    mov [edi], ax
    pop ax
    
    add edi, 2
    
    xor ecx, ecx
    mov ch, 01010001b
    shl ecx, 8
    mov ch, 10010010b
    mov [edi], ecx
    
    add edi, 4
    
    inc ax
    mov bx, ax      ;---------------------20 - Kernel Code
		    ;14600 - 159ff
    add ax, 0x13FF
    mov [edi], ax
    
    add edi, 2
    
    mov [edi], bx
    
    add edi, 2
    
    xor ecx, ecx
    mov ch, 01010001b
    shl ecx, 8
    mov ch, 10011010b
    mov cl, 1
    mov [edi], ecx
    
    add edi, 4      ;---------------------28 - Screen
    		    ;b8000 - bffff
    mov bx, 0x8000
    mov ax, 0xFFFF
    mov [edi], ax
    
    add edi, 2
    
    mov [edi], bx
    
    add edi, 2
    
    xor ecx, ecx
    mov ch, 01011011b
    shl ecx, 8
    mov ch, 10010010b
    mov cl, 0xB
    mov [edi], ecx
    
    add edi, 4      ;---------------------30 - Hookpoints
		    ;14300 - 145ff
    
    mov bx, 0x4300
    mov ax, 0x45ff
    mov [edi], ax
    
    add edi, 2
    
    mov [edi], bx
    
    add edi, 2
    
    xor ecx, ecx
    mov ch, 01010001b
    shl ecx, 8
    mov ch, 10010010b
    mov cl, 0x1
    mov [edi], ecx
    
    add edi, 4      ;---------------------38 - VidBuffer Pointers
		    ;15a00 - 15fff
    
    mov bx, 0x5A00
    mov ax, 0x5FFF
    mov [edi], ax
    
    add edi, 2
    
    mov [edi], bx
    
    add edi, 2
    
    xor ecx, ecx
    mov ch, 01010001b
    shl ecx, 8
    mov ch, 10010010b
    mov cl, 0x1
    mov [edi], ecx
    
    add edi, 4      ;---------------------40 - USER Data
		    ;100000 - ffffffff
    
    mov bx, 0x0000
    mov ax, 0xFFFF
    mov [edi], ax
    
    add edi, 2
    
    mov [edi], bx
    
    add edi, 2
    
    xor ecx, ecx
    mov ch, 11011111b
    shl ecx, 8
    mov ch, 10010010b
    mov cl, 0x10
    mov [edi], ecx
    
    add edi, 4      ;---------------------48 - USER Code
		    ;100000 - ffffffff
    
    mov bx, 0x0000
    mov ax, 0xFFFF
    mov [edi], ax
    
    add edi, 2
    
    mov [edi], bx
    
    add edi, 2
    
    xor ecx, ecx
    mov ch, 11011111b
    shl ecx, 8
    mov ch, 10011010b
    mov cl, 0x10
    mov [edi], ecx
    
    add edi, 4      ;---------------------
    
    mov esi, edi
    sub esi, GDTTableLoc
    dec esi
    mov [edi], si
    mov eax, edi
    add edi, 2
    mov dword [edi], GDTTableLoc
    
    xchg bx, bx
    
    lgdt [eax]
    
    jmp 0x20:ReloadGDT
    
    ReloadGDT:

