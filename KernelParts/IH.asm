Exceptions:
    .UD:
        
    
    .DF:
        
    
    .NP:
        
    
    .GP:
        cli      ;ff4
        push eax 
        push ebx 
        push ecx 
        push edx 
        push edi 
        push esi 
        add esp, 24 ;fd8
        
        pop eax
        pop ebx
        pop cx
        pop edx
        
        push edx
        push cx
        push ebx
        
        sub esp, 24+4
        push word 'GP'
        
        call .Panic
        
        add esp, 2
        pop esi
        pop edi
        pop edx
        pop ecx
        pop ebx
        pop eax
        
        add esp, 4
        
        push eax
        
        add esp, 4
        pop eax
        add eax, 3
        push eax
        sub esp, 4
        
        pop eax
        
        sti
        iret
    
    .Panic:
        push ax
        push ecx
        
        xor ecx, ecx
        xor eax, eax
        int 30h
        
        pop ecx
        pop ax
        add esp, 4
        pop ax
        sub esp, 6
        
        xchg bx, bx
        
        ret

IRQ:
    .Timer:
        cli
        pusha
       	push ds
	
	mov ax, 0x18
	mov ds, ax
	
	mov ecx, ds:[0x10]
	
	pop ds

	call Display.ReDraw

        mov al, 0x20
        out 0x20, al
        
        popa
        sti
        iret
    
    .PS2:
	cli
	pusha
	push ds
	
	mov ax, 0x18
	mov ds, ax
	mov dl, [ds:0x14]
	mov ebx, [ds:0x15]
	
	test dl, 1
	je .PS2.1
	
	mov ax, 0x40
	mov ds, ax

	.PS2.1:
	
	in al, 0x60
	
	mov [ds:ebx], al
	
	mov al, 0x20
        out 0x20, al
        
        popa
        sti
        iret

