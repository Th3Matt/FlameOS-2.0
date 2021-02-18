
GDTTableLoc equ 0x13A00
IDTTableLoc equ GDTTableLoc-0x1500-0x64+0xFA
ErrorBackground equ 0x6

    [ BITS 32 ]
    [ ORG 0x0 ]

KernStart:
    xchg bx, bx
    
    mov ax, 0x10
    mov ds, ax
    mov ss, ax
    mov sp, 0x1500

    mov dx, 0x3DA
    in al, dx
    mov dx, 0x3C0
    mov al, 0x30
    out dx, al
    inc dx
    in al, dx
    and al, 0xF7
    dec dx
    out dx, al  
    
    mov edi, 0x500
    
    .Clear:				; Clearing space for some data structures.
        mov dword [edi], 0
        add edi, 4
        
        cmp edi, 0x14600
        jl .Clear
    
    mov byte [0x15A00], 00000011b
    mov byte [0x15A01], 0
    mov dword [0x15A02], 0
    
    xchg bx, bx
    mov edi, 0x16000
    mov esi, 0x14600+Strings.Panic1
    mov ecx, (80*2)
    mov ah, 0xC

    .Clear2:				; Writing the kernel panic screen to "Cached Screens"...
        mov al, [esi]
        mov word [edi], ax
        add edi, 2
        inc esi
        
        loop .Clear2
    
    xchg bx, bx
    mov ecx, (80*3)
    mov ah, 0x0+(ErrorBackground<<4)

    .Clear3:				; ...Writing some more of it in a different color...
        mov al, [esi]
        mov word [edi], ax
        add edi, 2
        inc esi
        
        loop .Clear3
    
    mov ecx, (80*18)
    mov ah, 0xF+(ErrorBackground<<4)

    .Clear4:				; ... and again ...
        mov al, [esi]
        mov word [edi], ax
        add edi, 2
        inc esi
        
        loop .Clear4
    
    mov ecx, (80*2)
    mov ah, 0xC
    
    .Clear5:				; ... and again.
        mov al, [esi]
        mov word [edi], ax
        add edi, 2
        inc esi
        
        loop .Clear5
    
    mov ecx, 8
    add edi, 0xFA0
    xchg bx, bx

    .Clear6:				; Adding a Hex conversion table
        mov ax, [esi]
        mov word [edi], ax
        add edi, 2
        add esi, 2
        
        loop .Clear6
    
    mov dword [1500+0x03], 0x1000
    
    mov word [1500+0x07], 0x8
    
    mov word [1500+0x62], 0x64

    xchg bx, bx
    
 %include 'KernelParts/GDT.asm'
    
    mov ax, 0x8
    mov ss, ax
    mov ax, 0x18
    mov ds, ax
    mov esp, 0x1000
    mov bp, 0
    
    mov ax, 0x28
    mov gs, ax
    
    call Display.Clear
    
    mov eax, 0x0A440A47			; Printing "GDT" in green
    mov edi, 0
    mov [gs:edi], eax
    add edi, 4
    mov eax, 0x0A54
    mov gs:[edi], eax
    add edi, 4
    
    mov ax, 0x10
    ltr ax
    
    .setPIC:
        mov al, 0x11
        out 0x20, al
        
        mov al, 0x11
        out 0xA0, al
        
        mov al, 0x20
        out 0x21, al
        
        mov al, 0x28
        out 0xA1, al
        
        mov al, 0x04
        out 0x21, al
        
        mov al, 0x02
        out 0xA1, al
        
        mov al, 0x01
        out 0x21, al
        
        mov al, 0x01
        out 0xA1, al
        
        mov al, 0x00
        out 0x21, al
        
        mov al, 0x00
        out 0xA1, al
        
    mov al, 11111100b
    out 0x21, al
    
    mov al, 11111111b
    out 0xA1, al
    
    mov eax, 0x0A490A50			; Printing "PIC" in green
    mov gs:[edi], eax
    add edi, 4
    mov eax, 0x0A43
    mov gs:[edi], eax
    add edi, 4
    
    push edi
    					; Setting up IDTR...
    mov edi, 0x14300-0x1500-0x64-6-1
    mov word [edi], 0x14300-6-(IDTTableLoc+0x1564)-1
    inc edi
    inc edi
    mov dword [edi], IDTTableLoc+0x1500+0x64
    
    mov ax, 0x0030
    mov es, ax
    
    ;call IOPrint.Init
    call Timer.init
    call PS2.init
    
    mov ebx, 13
    mov eax, Exceptions.GP

    call IDT.ModEntry
    
    mov ebx, 0x20
    mov eax, IRQ.Timer

    call IDT.ModEntry
    
    xchg bx, bx
    
    mov ebx, 0x21
    mov eax, IRQ.PS2
    
    call IDT.ModEntry
    
    mov ebx, 0x30
    mov eax, Syscall_

    call IDT.ModEntry
    
    mov edi, 0x14300-0x1500-0x64-6-1
    lidt [ds:edi]

    pop edi
	 
    mov eax, 0x0A440A49			; Printing "IDT" in green
    mov gs:[edi], eax
    add edi, 4
    mov eax, 0x0A54
    mov gs:[edi], eax
    add edi, 4

    xchg bx, bx
    
    call ATA.init

    mov eax, 0x0A540A41			; Printing "ATA" in green
    mov gs:[edi], eax
    add edi, 4
    mov eax, 0x0A41
    mov gs:[edi], eax
    add edi, 4    

    push edi
    mov eax, 1
    mov ebx, 11
    mov edi, 0x13600-0x1564-1
    mov dx, 18h
    mov es, dx

    xchg bx, bx

    call ATA.readSectors		; Reading INFO sector
    pop edi
    
    mov eax, 0x0A4E0A49			; Printing "INFO" in green
    mov gs:[edi], eax
    add edi, 4
    mov eax, 0x0A4F0A46
    mov gs:[edi], eax
    add edi, 6
    
    push edi
    
    mov edi, 6
    
    mov ax, 0x38
    mov es, ax
    
    mov byte [es:edi], 00000011b	; Setting up System VidBuffer
    inc edi
    inc edi
    mov dword [es:edi], 0xFA0
    mov edi, 0xFA0
    mov esi, 0
    mov ax, 0x50
    mov es, ax
    
    screencopyloop:			; Copying current screen to current VidBuffer
	mov eax, [gs:esi]
	mov [es:edi], eax
	add esi, 4
	add edi, 4
	
	cmp esi, 0x50*25
	jne screencopyloop
    
    add byte [ds:0x19], 2
    mov dword [ds:0x10], 1
    
    sti

    xchg bx, bx
    
    push ds
    
    mov ax, 0x18
    mov ds, ax
    
    mov eax, dword [ds:0x13600-0x1564]	; Grabbing INFO sector signature
    
    cmp eax, 0x40045005			; Checking said signature
    je $
    
    pop ds
    
    push edi
    mov eax, 3
    mov ebx, 12
    mov edi, 0x13000-0x1564-1
    mov dx, 18h
    mov es, dx

    xchg bx, bx

    call ATA.readSectors		; Reading file descriptor sector
    
    
    mov al, [es:0x13600-0x1564+3]	; Getting terminal file number
    
    xor ecx, ecx
    mov cl, al
    
    xchg bx, bx

    mov eax, 0
    mov edx, 0
    
    call StartProgram

StartProgram:
	pusha
	push ecx

	xor esi, esi

	selectfileloop:			; Selecting terminal file
	add esi, 20
	loop selectfileloop
    
    	dec esi
  	add esi, 0x13000-0x1564
    
 	mov al, [es:esi]
 	mov ebx, edx
	add ebx, 10+2+3
 	mov dx, 40h
 	mov es, dx
	xor edi, edi
 	xchg bx, bx
    	
	call ATA.readSectors		; Reading terminal file
 	xor edi, edi

    	mov ax, 0x38
    	mov es, ax
    	
    	add edi, 6
    	
	xor eax, eax
	
	push ds
	mov ax, 0x18
	mov ds, ax
	mov al, [ds:0x19]
	pop ds

	mov cx, 6

	.loop:
		add edi, eax
		loop .loop
	
    	mov byte [es:edi], 00000001b
    	inc edi
    	inc edi
	
	pop ecx
	
   	mov dword [es:edi], ecx
	
	popa
	pusha

	pushfd
    	push dword 0x48
    	push dword eax
    	
   	xchg bx, bx

   	iret

IDT:
    .ModEntry:
	mov edi, IDTTableLoc-1
	shl ebx, 3
        add edi, ebx	
	
        mov [ds:edi], ax
        
        shr eax, 16
        push ax
        
        add edi, 2
        
        mov ax, 0x20 
        mov [ds:edi], ax
        
        add edi, 2
        
        mov al, 0
        mov ah, 10001110b
        mov [ds:edi], ax
        
        add edi, 2
        
        pop ax
        mov [ds:edi], ax
        
        add edi, 2
        
        ret

%include 'KernelParts/IH.asm'

PS2:
    .init:
	pusha
        
        call .WaitW
        mov al, 0xAD
        out 0x64, al
        
        call .WaitW
        mov al, 0xA7
        out 0x64, al
        
        in al, 0x60
        
        call .WaitW
        mov al, 0x20
        out 0x64, al
        
        call .WaitR
        in al, 0x60
        and al, 10111100b
        push ax
        
        call .WaitW
        mov al, 0x60
        out 0x64, al
        
        call .WaitW
        pop ax
        out 0x64, al
        
        call .WaitW
        mov al, 0xAA
        out 0x64, al
        
        call .WaitR
        in al, 0x60
        cmp al, 0x55
        jne $
        
        call .WaitW
        mov al, 0xAB
        out 0x64, al
        
        call .WaitR
        in al, 0x60
        cmp al, 0
        jne $
        
        call .WaitW
        mov al, 0xAE
        out 0x64, al
         
        .Write1:
            call .WaitW
            mov al, 0xFF
            out 0x60, al
            
            .Write1.ACK:
            
            call .WaitR
            in al, 0x60
            
            cmp al, 0xFA
            je .Write1.ACK
            
            cmp al, 0xFE
            je .Write1
            cmp al, 0xAA
            jne $
            
        .Write2:
            call .WaitW
            mov al, 0xF2
            out 0x60, al
            
            .Write2.ACK:
            
            call .WaitR
            in al, 0x60
            
            cmp al, 0xFA
            je .Write2.ACK
            
            cmp al, 0xFE
            je .Write2
        
        mov bh, al
        
        popa
        ret
    
    .WaitW:
        in al, 0x64
        
        test al, 2
        jnz .WaitW
        ret
    
    .WaitR:
        in al, 0x64
        
        test al, 1
        jz .WaitR
        ret

Timer:
    .init:
	pusha
	
	mov al, 00110100b
	; 00 11 010 0
	out 0x43, al
	
	mov al, 19886 && 0xffff
	out 0x40, al
	mov al, (19886 >> 4) && 0xffff
	out 0x40, al
	
	popa
	ret

Syscall_:
    push fs
    pusha
    
    mov ax, 0x30
    mov fs, ax
    
    xor eax, eax
    .loop:
        cmp ecx, 0
        je .loopend
        add eax, 6
        dec ecx
        jmp .loop
        
    .loopend:
    cmp byte [fs:eax], 1
    stc
    je .run
    popa
    pop fs
    iret
    
    .run:
        xchg bx, bx
        inc eax
        inc eax
        
        mov ebx, [fs:eax]
        
	cli
        mov [gs:0], ebx
        
        popa
        call [gs:0]
        sti

        clc
        iret

Display:
    .Clear:
        pusha
        xor edi, edi
        mov ecx, 3E8h
        
        .Clear.1:
            mov dword [gs:edi], 0
            add edi, 4
            
            loop .Clear.1
        
        popa
        ret
        
    .ClearB:
        pusha
        xor edi, edi
        cmp ecx, 0
        add edi, 2
        
        .ClearB.loop:
            jz .ClearB.loopend
            add edi, 0xFA2
            dec ecx
            jmp .ClearB.loop
        
        .ClearB.loopend:
        
        mov ecx, 3E8h
        push es
        mov ax, 0x38
        mov es, ax
        
        .ClearB.1:
            mov dword [es:edi], 0
            add edi, 4
            
            loop .ClearB.1
        
        pop es
        popa
        ret
    
    .ReDraw:
        ;xchg bx, bx
        pusha
        xor esi, esi
        xor edi, edi
        add esi, 2
        cmp ecx, 0
	jz .ReDraw.loopend
        
        .ReDraw.loop:
            add esi, 0x6
            loop .ReDraw.loop
        
        .ReDraw.loopend:
        
        mov ecx, 3E8h
        push es
	mov ax, 0x38
	mov es, ax
	
	mov ax, 0x50
	
	mov ebx, [es:esi]
	sub esi, 2
	
	test byte [es:esi], 00000010b		; Checker for system flag
	
	jnz .ReDraw.1
	
	mov ax, 0x40
	
	.ReDraw.1:
	
	mov es, ax
	mov esi, ebx
	
        .ReDraw.loop2:
            mov eax, dword [es:esi]
            mov dword [gs:edi], eax
            add edi, 4
            add esi, 4
            
            loop .ReDraw.loop2
        
        pop es
        popa
        ret

%include 'KernelParts/ATA.asm'

Strings:
    .Panic1:
        db '                                                                                '
        db ',---EXCEPTION----------------------------------------------------------------!!!'
        db '                                                                                '
	db '                                                                                '
        db '                                                                                '
	db '                                                                                '
    
    .Panic3:
        db '                                                                                '
        db '                                                                                '
        db '                                                                                '
        db '                                                                                '
        db '  Exception: #// ErrCode: 0x//\\                                                '
        db '                                                                                '
        db '                                                                                '
        db '  EAX: 0x//\\//\\ EBX: 0x//\\//\\ ECX: 0x//\\//\\ EDX: 0x//\\//\\               '
        db '  ESI: 0x//\\//\\ EDI: 0x//\\//\\                                               '
        db '  CS:  0x//\\ DS:  0x//\\ SS:  0x//\\                                           '
        db '                                                                                '
        db '                                EIP:  0x//\\//\\                                '
        db '                                                                                '
    
    .Panic4:
        db '                                                                                '
        db '   |Enter Xit to return to shell, MeM to dump memory, Cnt to continue in EIP|   '
        db '                                                                                '
        db '                                                                                '
        db '--------------------------------------------------------------------------------'	
        db '                                                                                '
    .HexTable:  db '0123456789ABCDEF'

times 10*512-($-$$) db 0

;GDT:
    ;.null:
    ;    dq 0
    
    
    ;.Kstack:
    ;    dw 0x1000
    ;    dw 0x500
    ;    db 0
        
    ;    db 010010010b
    ;    db 011011000b
    ;    db 0
    
    ;.TSS:
    ;    dw 0x64
    ;    dw 0x1500
    ;    db 0
    
    ;    db 0x89
    ;    db 0x40
    ;    db 0
    
    ;.Kdata:
    ;    dw 0x2ABF
    ;    dw 0x1564
    ;    db 0
        
    ;    db 010010010b
    ;    db 011011001b
    ;    db 0
    
    ;.Kcode:
    ;    dw 0x1400
    ;    dw 0x4000
    ;    db 1
        
    ;    db 010011010b
    ;    db 011011000b
    ;    db 0
    
    ;.Ucode:
    ;    dw 0xFFFF
    ;    dw 0x5400
    ;    db 1
        
    ;    db 010011010b
    ;    db 011011111b
    ;    db 0
    
    ;.Udata:
    ;    dw 0xFFFF
    ;    dw 0x5400
    ;    db 1
        
    ;    db 010010010b
    ;    db 011011111b
    ;    db 0
    
