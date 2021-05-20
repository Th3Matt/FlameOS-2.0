Exceptions:
    .DE:
       	xchg bx, bx
        cli      ;ff4
        push eax 
        push ebx 
        push ecx 
        push edx 
        push edi 
        push esi 
        add esp, 24 ;fd8
        
        pop ebx
        pop ecx
        pop edx
        mov eax, 0xFFFF
        
        push ecx
        push ebx
        
        sub esp, 24+4
        push word 'DE'
        
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
 
    .SS:
    	xchg bx, bx
	
	xor ebp, ebp
	not ebp
	
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
        pop ecx
        pop edx
        
        push edx
        push ecx
        push ebx
        
        sub esp, 24+4
        push word 'SS'
        
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


    .UD:
       	xchg bx, bx
        cli      ;ff4
        push eax 
        push ebx 
        push ecx 
        push edx 
        push edi 
        push esi 
        add esp, 24 ;fd8
        
        pop ebx
        pop ecx
        pop edx
        mov eax, 0xFFFF
        
        push ecx
        push ebx
        
        sub esp, 24+4
        push word 'UD'
        
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
 
    
    .DF:
        xchg bx, bx
	
	mov esp, 0x1000
	
        cli      ;ff4
        push eax 
        push ebx 
        push ecx 
        push edx 
        push edi 
        push esi 
        
	xor edx, edx
	xor ecx, ecx
	xor ebx, ebx
	xor eax, eax
	
        sub esp, 24+4
        push word 'DF'
        
        call .Panic
        
        add esp, 2
        pop esi
        pop edi
        pop edx
        pop ecx
        pop ebx
        pop eax
        
        sti
        iret

    
    .NP:
       xchg bx, bx
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
        pop ecx
        pop edx
        
        push edx
        push ecx
        push ebx
        
        sub esp, 24+4
        push word 'NP'
        
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
    
    .GP:
    	xchg bx, bx
        cli      ;ff4
        push eax 
        push ebx 
        push ecx 
        push edx 
        push edi 
        push esi 
        add esp, 24 ;fd8
        
        pop eax	; error code
        pop ebx ; EIP
        pop ecx ; CS
        pop edx ; EFLAGS?
        
        push edx
        push ecx
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
    	xchg bx, bx
    	push edx
    	push ebx
        push eax
        push ecx
        push ds
	mov ebp, esp ; copying the safe stack location for the stack dance

	xchg bx, bx
	add esp, 20+4
	pop cx
	sub esp, 20-4+4+2
	
	mov ax, 0x48
	mov ds, ax

	mov edi, (8*80+14)*2

	mov [edi], cl   ; setting up exception screen
	inc edi
	inc edi ; saving bytes as (inc edi inc edi) < (add edi, 2)
	mov [edi], ch

	add edi, 13*2
	
	xchg bx, bx
	pop ecx
	pop edx	; pop eax
	pop ebx
	pop eax ; pop edx
	
	mov esi, 0
	xchg ebp, esp ; begining the stack dance (attempting to not overwrite important data on the stack by switching esp to a safe location)
	call .HexWrite4 ; ErrCode
	xchg ebp, esp
	
	add edi, (80*3-22)*2
	add esp, 4+4*6
	pop edx
	sub esp, 8
	
	xchg ebp, esp
	call .HexWrite8	; eax
	xchg ebp, esp
	
	add edi, 9*2
	pop edx
	sub esp, 8
	
	xchg ebp, esp
	call .HexWrite8 ; ebx
	xchg ebp, esp
	
	add edi, 9*2
	pop edx
	sub esp, 8
	
	xchg ebp, esp
	call .HexWrite8	; ecx
	xchg ebp, esp
	
	add edi, 9*2
	pop edx
	sub esp, 8
	
	xchg ebp, esp
	call .HexWrite8 ; edx
	xchg ebp, esp

	add edi, (81-(8*4+8*3))*2
	pop edx
	sub esp, 8
	
	xchg ebp, esp
	call .HexWrite8 ; esi
	xchg ebp, esp
	
	add edi, 9*2
	pop edx
	sub esp, 8
	
	xchg ebp, esp
	call .HexWrite8 ; edi
	xchg ebp, esp

	add edi, (81-8*3)*2
	mov edx, ecx
	
	xchg ebp, esp
	call .HexWrite4	; cs
	xchg ebp, esp
	
	add edi, (4+5)*2
	sub esp, 4*(5+1)
	pop edx
	push edx
	call .HexWrite4
	
	add edi, (80*2+10+6)*2
	
	mov edx, ebx
	call .HexWrite8 ; eip
	
	mov ax, 0x18
	mov ds, ax
        xor ecx, ecx
	mov ds:[0x10], ecx
	call Display.ReDraw

	jmp $

    .HexWrite2: ; Write whatever is in dl in hex, reqires esi to point to a HexTable with 0s between entries
	push ebx
	push dx
	
	shr dl, 4
	
	xor ebx, ebx
	mov bl, dl
	mov esi, 0
	add esi, ebx
	shl esi, 1
	mov dl, [esi]
	shr esi, 1
	mov [edi], dl
	sub esi, ebx

	pop dx
	
	and dl, 0x0F

	inc edi
	inc edi
	xor ebx, ebx
	mov bl, dl
	add esi, ebx
	shl esi, 1
	mov dl, [esi]
	shr esi, 1
	mov [edi], dl
	
	pop ebx

	ret
    
    .HexWrite4: ; Write whatever is in dx in hex
    	push dx
	
	xchg dl, dh
	call .HexWrite2
	xchg dl, dh
	inc edi
	inc edi
	call .HexWrite2
	
	pop dx
	ret
	
    .HexWrite8: ; Write whatever is in edx in hex
    	push edx
	
	ror edx, 16
	call .HexWrite4
	inc edi
	inc edi
	ror edx, 16
	call .HexWrite4
	
	pop edx
	ret

    	

IRQ:
    .Timer:
        cli
        pusha
	
	xor ecx, ecx ; Screen redraw
	int 0x30

        mov al, 0x20
        out 0x20, al
        
        popa
        sti
        iret
    
    .PS2:
	cli
	;xchg bx, bx
	;ud2

	pusha
	push ds
	
	mov ax, 0x18
	mov ds, ax
	mov dl, [0x20]
	mov ebx, [0x23]
	
	test dl, 1
	je .PS2.1
	
	mov ax, [0x21]
	mov ds, ax

	.PS2.1:
	
	in al, 0x60
	
	mov [ds:ebx], al
	
	mov al, 0x20
        out 0x20, al
        
	pop ds
        popa
        sti
        iret

