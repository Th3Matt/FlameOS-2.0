[ BITS 32 ]
[ ORG 0x0 ]

VidBuffer equ 0x200*(1+3)
KeyPress equ VidBuffer+80*25*2
PromptLen equ FlameSH_NF-FlameSH_Prompt

INFO:
	.Entrypoint: 	dd 0x200
	.Vidbuffer:	dd VidBuffer
	.Keypress:	dd KeyPress
	.Stack:		dd KeyPress+0x500 

times 0x200-($-INFO) db 0

Terminal:
	mov bx, es
	shr bx, 3
	inc bx
	shl bx, 8
	or bl, 00000011b
	mov cl, 5
	mov edx, AllocateMemory
	int 0x31
	
	mov ax, 0x0+4+1
	mov ds, ax

	.resetPrompt:
		mov edi, VidBuffer
		xor ecx, ecx
		mov cl, [CurrentLine]
		mov eax, 80*2
		
		mul ecx

		add edi, eax
		xor eax, eax

		mov esi, FlameSH_Prompt
		mov ah, 0x0f

	.promptloop:
		mov al, [esi]
		mov word [edi], ax
		
		inc esi
		inc edi
		inc edi
		
		cmp byte [esi], 0
		jnz .promptloop
	
	.inputloop:
		mov ecx, 1
		int 0x30
		cmp byte [KeyPress], 0
		jz .inputloop
	
	mov esi, ScanMap
	test byte [KeyboardControlSpecial], 2
	jz .input.skipcaps

	add esi, 0xBB
	.input.skipcaps:

	xor eax, eax
	mov al, [KeyPress]
	cmp al, 0xBB
	ja .inputend
	add esi, eax
	
	mov al, [esi]
	cmp al, 3
	jng .inputspecial
	
	mov edi, VidBuffer+PromptLen*2
	xor ebx, ebx
	mov bl, [PointerPos]
	shl bl, 1
	add edi, ebx
	
	xor ecx, ecx
	mov cl, [CurrentLine]
	push eax
	mov eax, 0x50*2
	mul ecx
	add edi, eax
	pop eax

	mov ah, 0x0f
	mov [edi], ax
	inc byte [PointerPos]
	
	.inputend:
		and byte [KeyboardControlSpecial], 0xFE
		mov byte [KeyPress], 0
		jmp .inputloop
	
	.inputspecial:
		cmp al, 1
		jl .inputend
		jg .inputspecial2
		
	.inputenter:
		test byte [KeyboardControlSpecial], 1
		jnz .inputend
		
		xchg bx, bx
		inc byte [CurrentLine]
		 
		mov edi, 0x400+0x1000	
		mov esi, VidBuffer+PromptLen*2

		mov eax, 0x50*2
		xor ecx, ecx
		mov cl, [CurrentLine]
		dec ecx
		mul ecx
		add esi, eax
		
		call FileFind
		jc .inputenter.notfound
		
		mov eax, esi
		inc eax
		mov ebx, 20
		mul ebx
		
		mov edi, eax
		xor eax, eax
		push ds
		mov ax, 0x50+1
		mov ds, ax
		mov al, [ds:edi-2]
		pop ds
		mov ebx, 0x200
		mul ebx
		push eax
		
		mov bx, 0x60+1
		mov es, bx
		xor ebx, ebx
		mov edi, NextLDTEntry
		push ds
		mov ax, 0x0+4+1
		mov ds, ax
		
		inc word [edi]
		inc word [edi]
		mov bx, [edi]
		pop ds
		
		mov eax, 64/8
		mul ebx
		mov edi, eax
		
		pop eax

		.WriteEntries:
			mov cx, 0x0FFF
    			div cx
    			inc ax
    			cmp dx, 0
    			jz .noremainder
    			inc ax
    			.noremainder:
    			mov cx, ax
			add cx, [es:0]
			mov bx, [es:0]
			
    			mov [es:edi], cx
    			push ecx
    			
   			add edi, 2
    			
			shl ebx, 8+4
			add ebx, 0x1000
    			mov [es:edi], bx
    			
    			add edi, 2
    			
    			shr ecx, 4*4
    			and ch, 00001111b
    			or ch, 11010000b
    			shl ecx, 8
    			mov ch, 11010010b
			ror ebx, 16
    			mov cl, bl
			ror ebx, 16
    			mov [es:edi], ecx
			
    			add edi, 4
		    	
    			pop ecx
    			mov [es:edi], cx
    		
    			add edi, 2
    		
   			mov [es:edi], bx
    
    			add edi, 2
    		
    			shr ecx, 4*4
    			and ch, 00001111b
   			or ch, 11010000b
   			shl ecx, 8
    			mov ch, 11011010b
    			ror ebx, 16
    			mov cl, bl
			ror ebx, 16
    			mov [es:edi], ecx
		
		mov eax, esi
		mov ebx, 0x2
		mov edi, 2
		mov ecx, 3
		int 0x30 ;Calling LoadFile
		
		mov ax, 0x10+4+2
		mov es, ax
		mov ebx, 0x18+4+2
		mov ecx, 2
		mov dx, 0x0+4+1
		mov fs, dx
		push ds
		int 0x30 ;Calling StartFile
		pop ds
		
		.inputenter.newline:
			
		inc byte [CurrentLine]
		or byte [KeyboardControlSpecial], 1
		mov byte [PointerPos], 0
		mov byte [KeyPress], 0
		jmp .resetPrompt
	
	.inputenter.notfound:
		mov edi, VidBuffer
		xor ecx, ecx
		xor eax, eax
		mov cl, [CurrentLine]
		mov eax, 80*2
		mul ecx
		add edi, eax
		
		mov esi, FlameSH_NF
		mov ah, 0x0f

		.inputenter.notfound.print:
			mov al, [esi]
			mov word [edi], ax
			
			inc esi
			inc edi
			inc edi
			
			cmp byte [esi], 0
			jnz .inputenter.notfound.print

		jmp .inputenter.newline

	
	.inputspecial2:
		cmp al, 2
		jg .inputcaps
		cmp byte [PointerPos], 0
		jz .inputend
		dec byte [PointerPos]
		
	.inputdelete:
		mov edi, VidBuffer+PromptLen*2
		xor ebx, ebx
		mov bl, [PointerPos]
		shl bl, 1
		add edi, ebx
		
		xor ecx, ecx
		mov cl, [CurrentLine]
		mov eax, 0x50*2
		mul ecx
		add edi, eax
		
		mov ax, 0x0f00
		mov [edi], ax
		jmp .inputend
	
	.inputcaps:
		xor byte [KeyboardControlSpecial], 2
		
		jmp .inputend

FileFind:
	push edi
	push ecx
	push ebx
	push eax
	push ds

	cmp byte [es:esi], 0
	stc
	jz .NameCheck.end
	
	mov ax, 0x50+1
	mov ds, ax
	
	mov edi, 1
	xor ebx, ebx
	xor ecx, ecx

	.NameCheck:
		cmp byte [es:esi], 0
		clc
		jz .NameCheck.check
		
		mov al, [es:esi]
		cmp [edi], al
		je .NameCheck.correct

		sub esi, ebx
		sub edi, ebx
		xor ebx, ebx
		add edi, 20
		inc ecx
		cmp edi, 0x200*3
		jl .NameCheck
		stc
		jmp .NameCheck.end
		
		.NameCheck.correct:
			inc esi
			inc edi
			inc esi
			
			inc ebx
			jmp .NameCheck
		
	.NameCheck.check:
		cmp byte [edi], 0
		jne .NameCheck.error
		cmp ebx, 0
		jne .NameCheck.end
	.NameCheck.error:
		stc
	.NameCheck.end:
		pop ds
		pop eax
		pop ebx
		mov esi, ecx
		pop ecx
		pop edi
		ret

AllocateMemory: ; eax - # of pages to allocate
	pusha
	push es
	
	mov ecx, eax
	mov ax, 0x60+1
	mov es, ax
	xor eax, eax
	xor ebx, ebx
	mov ax, [NextLDTEntry]
	shl eax, 3

	add cx, [es:eax]
	mov bx, [es:eax]

    	mov [es:edi], cx
    	
   	add edi, 2
    	
	shl ebx, 8+4
	add ebx, 0x1000
    	mov [es:edi], bx
    	
    	add edi, 2
    			
    	shr ecx, 4*4
    	and ch, 00001111b
    	or ch, 11010000b
    	shl ecx, 8
    	mov ch, 11010010b
	ror ebx, 16
    	mov cl, bl
	
	ror ebx, 16
    	mov [es:edi], ecx

	inc byte [NumberOfAllocatedLDTEntries]
	inc word [NextLDTEntry]
	
	pop es
	popa
	mov ecx, 4
	int 30h


FlameSH_Prompt: db 'FlameShell| ', 0
FlameSH_NF:     db 'FSH: File not found. ', 0

PointerPos: db 0
CurrentLine: db 0
KeyboardControlSpecial: db 0					; 0 bit - is last key pressed is enter, 1 bit - capslock

ScanMap:
     	db 0x0, 0x0, '1', '2', '3', '4', '5', '6', '7', '8'
     	db '9', '0', '-', '=', 0x2, 0x0, 'q', 'w', 'e', 'r'
	db 't', 'y', 'u', 'i', 'o', 'p', '[', ']', 0x1, 0x0
        db 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';'
        db '`', '`', 0x3, '\', 'z', 'x', 'c', 'v', 'b', 'n'
        db 'm', ',', '.', '/', 0x0, '*', 0x0, ' '

	times 0xBA-($-ScanMap) db 0
	
	db 0x3

ScanMap2:
     	db 0x0, 0x0, '1', '2', '3', '4', '5', '6', '7', '8'
     	db '9', '0', '-', '=', 0x2, 0x0, 'Q', 'W', 'E', 'R'
	db 'T', 'Y', 'U', 'I', 'O', 'P', '[', ']', 0x1, 0x0
        db 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ';'
        db '`', '`', 0x0, '\', 'Z', 'X', 'C', 'V', 'B', 'N'
        db 'M', ',', '.', '/', 0x0, '*', 0x0, ' '

        times 0xAA-($-ScanMap2) db 0

	db 0x3

	times 0xBA-($-ScanMap2) db 0
	
	db 0x3


db 0x11, 0x55

NextLDTEntry: dw 0
times 0x200*3-($-Terminal)-1 db 0
NumberOfAllocatedLDTEntries: db 0
