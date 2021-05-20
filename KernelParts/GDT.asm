		    ;			Raw Descriptor	Descriptor+RPL  Description
		    ;---------------------00       -      00         -   NULL
    mov edi, GDTTableLoc
    mov dword [edi], 0
    add edi, 4
    mov dword [edi], 0
    add edi, 4
                    ;---------------------08 	   -      08         -   Kernel Stack
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
                    ;---------------------10       -      10         -   TSS
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
   		    ;---------------------18       -      18         -   Kernel Data
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
    mov bx, ax      ;---------------------20       -      20         -   Kernel Code
		    ;14600 - 15dff
    add ax, 0x17FF
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
    
    add edi, 4      ;---------------------28       -      28         -   Screen
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
    
    add edi, 4      ;---------------------30       -      30         -   Hookpoints
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
    
    add edi, 4      ;---------------------38       -      38         -   VidBuffer Pointers
		    ;15e00 - 165ff
    
    mov bx, 0x5E00
    mov ax, 0x65FF
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
    
    add edi, 4      ;---------------------40       -      41         -   r0 User Data access point
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
    
    add edi, 4      ;---------------------48       -      48         -   Kernel VidBuffers
		    ;16500 - 184ff
    
    mov bx, 0x6500
    mov ax, 0x84ff
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

    add edi, 4      ;---------------------50       -      52         -   r2 Descriptor Sectors
		    ;13000 - 13600
    
    mov bx, 0x3000
    mov ax, 0x6000
    mov [edi], ax
    
    add edi, 2
    
    mov [edi], bx
    
    add edi, 2
    
    xor ecx, ecx
    mov ch, 01010001b
    shl ecx, 8
    mov ch, 11010010b
    mov cl, 0x1
    mov [edi], ecx

    add edi, 4      ;---------------------58       -      5A         -   r2 Function Table
		    ;3000 - 13000
    
    mov bx, 0x3000
    mov ax, 0x3000
    mov [edi], ax
    
    add edi, 2
    
    mov [edi], bx
    
    add edi, 2
    
    xor ecx, ecx
    mov ch, 01010001b
    shl ecx, 8
    mov ch, 11010010b
    mov cl, 0x0
    mov [edi], ecx

    add edi, 4      ;---------------------60       -      61         -   r1 LDT editable
		    ;18500 - 18D00
    
    mov bx, 0x8500
    mov ax, 0x8D00
    mov [edi], ax
    
    add edi, 2
    
    mov [edi], bx
    
    add edi, 2
    
    xor ecx, ecx
    mov ch, 01010001b
    shl ecx, 8
    mov ch, 10110010b
    mov cl, 0x1
    mov [edi], ecx

    add edi, 4      ;---------------------68       -      68         -   LDT
		    ;18500 - 18D00
    
    mov bx, 0x8500
    mov ax, 0x8D00
    mov [edi], ax
    
    add edi, 2
    
    mov [edi], bx
    
    add edi, 2
    
    xor ecx, ecx
    mov ch, 01010001b
    shl ecx, 8
    mov ch, 10000010b
    mov cl, 0x1
    mov [edi], ecx

    add edi, 4      ;---------------------70       -      70         -   r0 editable TSS
		    ;1500 - 1564
    
    mov bx, 0x1500
    mov ax, 0x1564
    mov [edi], ax
    
    add edi, 2
    
    mov [edi], bx
    
    add edi, 2
    
    xor ecx, ecx
    mov ch, 01010000b
    shl ecx, 8
    mov ch, 10010010b
    mov cl, 0x0
    mov [edi], ecx



    add edi, 4      ;-------------------
    
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

