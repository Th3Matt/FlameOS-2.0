ATAPort equ 0x1F0
ATAPort2 equ 0x170

ATA:
    .init:
	pusha
	
	xor esi, esi
	mov dx, ATAPort+7	;7
	in al, dx
	
	cmp al, 0xff
	stc
	je .init.noDisk
	clc
	
	dec dx			;6
	mov al, 11100000b
	out dx, al
	
	inc dx
	
	.init.DiskCheck:
	
	mov cx, 5
	
	rep in al, dx
	
	dec dx			;6
	dec dx			;5
	
	mov al, 0
	out dx, al
	
	dec dx			;4
	out dx, al
	dec dx			;3
	out dx, al
	dec dx			;2
	out dx, al
	dec dx			;1
	out dx, al
	
	add dx, 6		;7
	mov al, 0xEC
	out dx, al
	
	in al, dx
	
	cmp al, 0
	jz .init.noDisk
	
	.init.1loop:
	    in al, dx

	    test al, 10000000b
	    jnz .init.1loop
	
	in al, dx
	test al, 0
	jnz .init.error ;jnz .init.notATA
	
	push es
	mov ax, 0x8
	mov es, ax
	
	xor edi, edi
	mov ecx, 256
	sub dx, 7	 	;0
	
	rep insw
	
	
	.init.end:
	    shr esi, 1
	    add dx, 6
	    xor eax, eax
	    in al, dx
	    and al, 00001000b
	    shl al, 3
	    add esi, eax
	    
	    push ds
	    mov ax, 18h
	    mov ds, ax
	    mov eax, esi
	    mov [ds:0], al
	    mov [ds:0xF], al
	    pop ds
	    
	    pop es
	    popa
	    ret
	
    	.init.noDisk:
	    jc .init.error
	     
	    mov dx, ATAPort+6
	    in al, dx
	    test al, 4
	    jnz .init.M_to_S
	    
	    or al, 00010000b
	    jmp .init.DiskCheck
	
	.init.M_to_S:
	    cmp esi, 1
	    je .init.1
 	     
	    mov esi, 1
	    mov dx, ATAPort2+6
	    mov al, 10100000b
	    out dx, al
	    dec dx
	    jmp .init.DiskCheck
 	     
	.init.1:
	    mov dx, ATAPort2+6
	    mov al, 10110000b
	    out dx, al
	    dec dx
	    jmp .init.DiskCheck

	.init.error:
	    stc
	    popa
	    ret

	     
    .readSectors:	;eax - # of sectors to read, ebx - starting sector #, edi - buffer
	pusha
	push eax
	push ebx

	push ds
	push ax
	mov ax, 18h
	mov ds, ax
	mov bl, [ds:0xF]
	pop ax
	pop ds
	
	mov dx, ATAPort
	test bl, 2
	jz .readSectors.Port
	
	mov dx, ATAPort2
	
	.readSectors.Port:	;0 
	
	add dx, 6		;6
	and bl, 1
	shr bl, 4
	mov al, bl
	or al, 01000000b
	out dx, al

	inc dx			;7
	mov ecx, 5
	rep in al, dx
	pop ebx
	
	dec dx			;6
	dec dx			;5
	mov al, 0
	out dx, al
	
	dec dx			;4
	out dx, al
	
	dec dx			;3
	mov al, bl
	out dx, al

	dec dx			;2
	pop eax
	push eax
	out dx, al
	
	add dx, 5		;7
	mov al, 20h 
	out dx, al
	
	.readSectors.wait:
	    in al, dx
	    
	    test al, 1
	    jnz .readSectors.error
	
	    test al, 00001000b
	    jnz .readSectors.read
	
	    jmp .readSectors.wait
	
	
	.readSectors.error:
	    pop eax
	    stc
	    jmp .readSectors.end
	
	
	.readSectors.read:
	    pop eax
	    mov ecx, eax
	    xor eax, eax
	    
	    sub dx, 7
	    
	.readSectors.1:
	    add eax, 0x100
	    loop .readSectors.1
	    
	    mov ecx, eax
	    
	    rep insw
	
	.readSectors.end:
	    popa
 	    ret
	


