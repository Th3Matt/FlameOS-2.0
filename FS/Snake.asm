[ BITS 32 ]
[ ORG 0x0 ]

VidBuffer equ 0x200*(1+3)
KeyPress equ VidBuffer+80*25*2

INFO:
	.Entrypoint: 	dd 0x200
	.Vidbuffer:	dd VidBuffer
	.Keypress:	dd KeyPress
	.Stack:		dd KeyPress+0x500 

times 512-($-$$) db 0
Game:
	sub bx, 8
	mov ds, bx

	.DrawUI:

		mov edi, VidBuffer+80*2*2
		mov ecx, 80

		.DrawUI.Loop1:
			mov byte [edi], '='
			mov byte [edi+1], 0x0f
			inc edi
			inc edi
			loop .DrawUI.Loop1
	
	xchg bx, bx
	mov edi, VidBuffer+80*2*(8+3)+(40-5)*2
	mov ah, 0xF0
	mov esi, SnakeText
	
	.DrawUI.Loop2:
		mov al, [esi]
		cmp al, 0
		jz .DrawUI.PostLoop2
		mov [edi], ax
		inc esi
		inc edi
		inc edi
		jmp .DrawUI.Loop2
	.DrawUI.PostLoop2:

	add edi, 80*2-5*2-21*2
	mov ah, 0x0F
	mov esi, SnakeHelp
	
	.DrawUI.Loop3:
		mov al, [esi]
		cmp al, 0
		jz .DrawUI.PostLoop3
		mov [edi], ax
		inc esi
		inc edi
		inc edi
		jmp .DrawUI.Loop3
	.DrawUI.PostLoop3:

	mov byte [KeyPress], 0
	
	mov ecx, 1
	int 0x30

	cmp byte [KeyPress], 0x39
	je .StartGame
	
	cmp byte [KeyPress], 0x10
	jne .DrawUI.PostLoop3
	mov ecx, 4
	int 0x30 ; exit
	
	iret ; if failed, crash
	.StartGame:
	
	mov al, [KeyPress]
	mov ah, [KeyPress]
	mov [Random], ax

	mov word [HeadX], (40)+(11<<(1*8))
	mov word [EndX], (40)+(8<<(1*8))
	mov word [FoodX], 0
	mov byte [Length], 3
	mov byte [HeadDirection], 1
	
	mov edi, VidBuffer+80*2*3
	mov ecx, 80*(25-3)
	.DrawUI.ClearLoop:
		mov word [edi], 0
		inc edi
		inc edi
		loop .DrawUI.ClearLoop

	mov edi, VidBuffer+80*2*(8+3)+40*2
	mov cx, 0xAA02
	mov word [edi], cx
	add edi, 80*2
	mov word [edi], cx
	add edi, 80*2
	mov word [edi], cx
	
	.Main:
		mov byte [KeyPress], 0
		
		mov ecx, 1
		int 0x30
		cmp byte [KeyPress], 0
		jnz .keyPressed
		inc byte [CountOfCycles]

	.Move:
		mov al, [CountOfCycles]
		cmp al, 100
		jl .Main
		
		cmp byte [FoodX], 0
		jnz .Move.CheckFood
		
		mov al, [Random]
		cmp al, 80
		jb .Move.FoodXSelected
		mov bl, 80
		div bl
		.Move.FoodXSelected:
		mov byte [FoodX], ah
		mov dl, [Random+1]

		cmp dl, 21
		jb .Move.FoodYSelected
		mov bx, 21
		mov al, dl
		xor edx, edx
		div bx
		.Move.FoodYSelected:
		mov byte [FoodY], dl
		
		mov edi, VidBuffer
		xor eax, eax
		xor ebx, ebx
		mov al, [FoodY]
		add al, 3
		mov cl, 80
		mul cl
		mov bl, [FoodX]
		add ax, bx
		shl ax, 1
		add di, ax
		mov word [edi], 0xEE00
		
		.Move.CheckFood:
			mov al, [HeadX]
			cmp [FoodX], al
			jne .Move.DrawSegment
			
			mov al, [HeadY]
			cmp [FoodY], al
			jne .Move.DrawSegment
			
			inc byte [Length]
			mov byte [FoodX], 0
			
		.Move.DrawSegment:
			xchg bx, bx
			mov byte [CountOfCycles], 0
			
			mov edi, VidBuffer
			xor eax, eax
			xor ebx, ebx
			mov al, [HeadY]
			add al, 3
			mov cl, 80
			mul cl
			mov bl, [HeadX]
			add ax, bx
			shl ax, 1
			add di, ax
			mov al, [HeadDirection]
			mov byte [edi], al
			mov byte [edi+1], 0xAA
		
			mov al, [HeadDirection]
			
			test byte [HeadDirection], 1
			jnz .Move.Horiz
		
		.Move.Vert:
			test al, 2
			jz .Move.Vert.1
			cmp byte [HeadY], 21
			je .Move.Vert.1
			inc byte [HeadY]
			.Move.Vert.1:
			
			test al, 2
			jnz .Move.Vert.2
			cmp byte [HeadY], 0
			je .Move.Vert.2
			dec byte [HeadY]
			.Move.Vert.2:
			
			jmp .Move.CheckSnake

		.Move.Horiz:
			test al, 2
			jz .Move.Horiz.1
			cmp byte [HeadX], 0
			je .Move.Horiz.1
			dec byte [HeadX]
			.Move.Horiz.1:

			test al, 2
			jnz .Move.Horiz.2
			cmp byte [HeadX], 79
			je .Move.Horiz.2
			inc byte [HeadX]
			.Move.Horiz.2:
			
		.Move.CheckSnake:
			mov bh, 0
			mov al, [HeadY]
			add al, 3
			mov bl, 80
			mul bl
			mov bh, 0
			mov bl, [HeadX]
			add ax, bx
			and eax, 0x0000FFFF
			shl eax, 1
			add eax, VidBuffer
			cmp byte [eax+1], 0xAA
 			je .GameOver

		.DeleteEnd:
			mov edi, VidBuffer
			xor eax, eax
			xor ebx, ebx
			mov al, [EndY]
			add al, 3
			mov cl, 80
			mul cl
			mov bl, [EndX]
			add ax, bx
			shl ax, 1
			add di, ax
			mov al, [edi]
			mov byte [edi+1], 0x00
			
			cmp byte [HeadDirection], 1
			jl .DeleteEnd.Check1
			je .DeleteEnd.Check2
			cmp byte [HeadDirection], 4
			jl .DeleteEnd.Check3
			je .DeleteEnd.Check4
			
			.DeleteEnd.Check1:

			cmp byte [HeadY], 0
			jne .DeleteEnd.Exec
			jmp .Main

			.DeleteEnd.Check2:

			cmp byte [HeadX], 79
			jne .DeleteEnd.Exec
			jmp .Main
			
			.DeleteEnd.Check3:

			cmp byte [HeadX], 24-3
			jne .DeleteEnd.Exec
			jmp .Main

			.DeleteEnd.Check4:

			cmp byte [HeadX], 0
			jne .DeleteEnd.Exec
			jmp .Main
			
			.DeleteEnd.Exec:
			test byte [edi], 1
			jnz .DeleteEnd.Horiz
			
			.DeleteEnd.Vert:
				and ax, 2
				add [EndY], al
				dec byte [EndY]
				
				jmp .Main
			
			.DeleteEnd.Horiz:
				and ax, 2
				sub [EndX], al
				inc byte [EndX]
				
				jmp .Main
	.keyPressed:
		xor ebx, ebx
		mov bl, [CountOfCycles]
		mov al, [KeyPress]
		cmp al, 0x11
		je .keyPressed.W

		cmp al, 0x1E
		je .keyPressed.A

		cmp al, 0x1F
		je .keyPressed.S

		cmp al, 0x20
		je .keyPressed.D
		
		cmp al, 0x10
		jne .Main

		.keyPressed.Q:
			mov ecx, 4
			jmp .DrawUI

		.keyPressed.W:
			mov byte [HeadDirection], 0
			
			cmp word [Random], 0
			jp .keyPressed.W.1
			add word [Random], bx
			jmp .keyPressed.ClearPressed
			
			.keyPressed.W.1:
			ror word [Random], 1
			jmp .keyPressed.ClearPressed

		.keyPressed.A:
			mov byte [HeadDirection], 3
			
			cmp word [Random], 0
			jp .keyPressed.A.1
			sub word [Random], bx
			jmp .keyPressed.ClearPressed
			
			.keyPressed.A.1:
			rol word [Random], 1
			jmp .keyPressed.ClearPressed

		.keyPressed.S:
			mov byte [HeadDirection], 2
			
			cmp word [Random], 0
			jp .keyPressed.S.1
			rol word [Random], 2
			jmp .keyPressed.ClearPressed
			
			.keyPressed.S.1:
			sub word [Random], bx
			jmp .keyPressed.ClearPressed

		
		.keyPressed.D:
			mov byte [HeadDirection], 1
			
			cmp word [Random], 0
			jp .keyPressed.D.1
			add word [Random], bx
			jmp .keyPressed.ClearPressed
			
			.keyPressed.D.1:
			ror word [Random], 2

		.keyPressed.ClearPressed:
			jmp .Main
	.GameOver:
		mov edi, VidBuffer+80*2*(8+3)+(40-5)*2
		mov ah, 0xF4
		mov esi, SnakeGameOver
		
		.GameOver.Loop:
			mov al, [esi]
			cmp al, 0
			jz .GameOver.PostLoop
			mov [edi], ax
			inc esi
			inc edi
			inc edi
			jmp .GameOver.Loop
		.GameOver.PostLoop:
			mov ecx, 1
			int 0x30
			cmp byte [KeyPress], 0x10
			jne .GameOver.PostLoop
			jmp .DrawUI

CountOfCycles: db 0
HeadX: db 40
HeadY: db 11
EndX: db 40
EndY: db 8
FoodX: db 0
FoodY: db 0
SnakeText: db 'SNAKE  0.2', 0
SnakeHelp: db 'Spacebar to begin, q to quit, WASD to move', 0
SnakeGameOver: db 'GAME OVER', 0

Random: dw 0
			; 	010	000	000     000
HeadDirection: db 1 ; -->	000 - 0 001 - 1 000 - 2 100 - 3	
Length: db 3		; 	000	000	010     000
Score: dd 0
times 512*3-($-Game) db 0

