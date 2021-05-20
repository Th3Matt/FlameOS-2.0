[ org 0 ]
[ BITS 32 ]

VidBuffer equ 0x200*(1+2)
KeyPress equ VidBuffer+80*25*2

INFO:
	.Entrypoint:	dd 0x200
	.Vidbuffer:	dd VidBuffer
	.Keypress:	dd KeyPress
	.Stack:		dd KeyPress+0x500 

times 512-($-$$) db 0

Program:
	mov ax, es
	mov ds, ax
	mov edi, VidBuffer+80*11*2+35*2
	mov esi, NamePrompt
	mov ah, 0xf0
	
	.DrawUI.1:
		mov al, [esi]
		mov [edi], ax
		inc esi
		inc edi
		inc edi
		cmp byte [esi], 0
		jnz .DrawUI.1
	
	.NameEntry:
		mov byte [KeyPress], 0
		mov ecx, 1
		int 0x30
		
		cmp byte [KeyPress], 0
		jz .NameEntry
		
		cmp byte [KeyPress], 0xBB
		ja .NameEntry 
		
		mov edi, VidBuffer+80*12*2+33*2
		xor eax, eax
		mov al, [CursorPos]
		shl ax, 1
		add edi, eax
		xor eax, eax
		mov esi, ScanMap
		mov al, [KeyPress]
		add esi, eax
		
		test byte [Flags], 1
		jz .NameEntry.PastCapsCheck
		add esi, 0xBB
		.NameEntry.PastCapsCheck:
		
		mov al, [esi]
		
		cmp al, 1
		jl .NameEntry
		je .FileLoad
		cmp al, 3
		jl .NameEntry.Backspace
		je .NameEntry.CapsToggle
		cmp al, 5
		jl .Exit
		
		mov ah, 0x0f
		mov [edi], ax
		inc byte [CursorPos]
		test byte [Flags], 2
		jnz .InvalidFileNameMessageDelete

		jmp .NameEntry
	
	.NameEntry.CapsToggle:
		xor byte [Flags], 1
		jmp .NameEntry
	
	.NameEntry.Backspace:
		dec byte [CursorPos]
		mov word [edi-2], 0
		jmp .NameEntry
	
	.Exit:
		mov ecx, 4
		int 0x30

		iret

	.FileLoad:
		mov al, [CursorPos]
		shl ax, 1
		sub edi, eax
		mov esi, edi
		call FileFind
		jc .InvalidFileNameMessageWrite
		
		mov eax, 0x200
		mul cx
		
		xor edx, edx
		mov ecx, 0xFFF
		div cx
		inc eax
		
		mov ecx, 5
		int 0x30
		
		mov ax, es
		add ax, 16
		shr ax, 3
		mov ds, ax
		mov bx, ax
		mov ax, si
		mov ecx, 3
		int 0x30
		
		xor esi, esi
		mov edi, 0x600
		xor eax, eax
		xor edx, edx
		mov bh, 0x0f
		
		.loopFileContents:
			not edx
			mov ax, [esi]
			inc esi
		
		.loopFileContents.WriteHex:
			push ax
			and ax, 0xf0
			shr ax, 4
			add ax, HexTable
			mov bl, [eax]
			mov [edi], bx
			inc edi
			inc edi
			pop ax
			
			push ax
			and ax, 0xf
			add ax, HexTable
			mov bl, [eax]
			mov [edi], bx
			inc edi
			inc edi
			pop ax
			
			shr ax, 8
			shr dx, 8
			jnz .loopFileContents.WriteHex
			
			mov bl, ' '
			mov [edi], bx
			inc edi
			inc edi
			
			loop .loopFileContents

	.Main:
		jmp .Main
	
	.InvalidFileNameMessageWrite:
		or byte [Flags], 2
		mov edi, VidBuffer+80*13*2+32*2
		mov esi, InvalidFileName
		mov ah, 0x4F
		
		.DrawUI.2:
			mov al, [esi]
			mov [edi], ax
			inc esi
			inc edi
			inc edi
			cmp byte [esi], 0
			jnz .DrawUI.2

		jmp .NameEntry
	
	.InvalidFileNameMessageDelete:
		xor byte [Flags], 2
		mov edi, VidBuffer+80*13*2+32*2
		mov ecx, 19
		xor eax, eax
		
		.DrawUI.3:
			mov [edi], ax
			inc edi
			inc edi
			loop .DrawUI.3

		jmp .NameEntry



HexTable: db '0123456789ABCDEF'
FileFind:
	push edi
	push ebx
	push eax
	push ds

	cmp byte [es:esi], 0
	stc
	jz .NameCheck.end
	
	mov ax, 0x50+2
	mov ds, ax
	
	mov edi, 1
	xor ebx, ebx
	xor ecx, ecx

	.NameCheck:
		cmp byte [es:esi], 0
		clc
		jz .NameCheck.check
		
		mov al, [edi]
		cmp [es:esi], al
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
		jne .NameCheck
		cmp ebx, 0
		jne .NameCheck.end
	.NameCheck.error:
		stc
	.NameCheck.end:
		mov esi, ecx
		mov eax, 20
		pushfd
		mul cx
		mov ecx, [eax+18]
		popfd
		pop ds
		pop eax
		pop ebx
		pop edi
		ret

ScanMap:
     	db 0x0, 0x4, '1', '2', '3', '4', '5', '6', '7', '8'
     	db '9', '0', '-', '=', 0x2, 0x0, 'q', 'w', 'e', 'r'
	db 't', 'y', 'u', 'i', 'o', 'p', '[', ']', 0x1, 0x0
        db 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';'
        db '`', '`', 0x3, '\', 'z', 'x', 'c', 'v', 'b', 'n'
        db 'm', ',', '.', '/', 0x0, '*', 0x0, ' '

	times 0xBA-($-ScanMap) db 0
	
	db 0x3

ScanMap2:
     	db 0x0, 0x4, '1', '2', '3', '4', '5', '6', '7', '8'
     	db '9', '0', '-', '=', 0x2, 0x0, 'Q', 'W', 'E', 'R'
	db 'T', 'Y', 'U', 'I', 'O', 'P', '[', ']', 0x1, 0x0
        db 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ';'
        db '`', '`', 0x0, '\', 'Z', 'X', 'C', 'V', 'B', 'N'
        db 'M', ',', '.', '/', 0x0, '*', 0x0, ' '

        times 0xAA-($-ScanMap2) db 0

	db 0x3

	times 0xBA-($-ScanMap2) db 0
	
	db 0x3

Flags: db 0 ; 0 bit - Uppercase, 1 bit - InvalidFileName message shown.
CursorPos: db 0
NamePrompt: db 'File name:', 0
InvalidFileName: db 'Invalid file name', 0
times 512*3-($-Program) db 0
