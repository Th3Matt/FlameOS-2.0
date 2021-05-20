
GDTTableLoc equ 0x13A00
IDTTableLoc equ GDTTableLoc-0x1500-0x64+0xFA
ErrorBackground equ 0x6
KernSize equ 12

    [ BITS 32 ]
    [ ORG 0x0 ]

Stage2:
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
    
    mov byte [0x15E00], 00000011b
    mov word [0x15E01], 0
    mov dword [0x15E03], 0
    
    xchg bx, bx
    mov edi, 0x16500
    mov esi, 0x14600+Strings.Panic1
    mov ecx, 80
    mov ah, 0x0

    .Clear2:				; Writing the kernel panic screen to "Cached Screens"...
        mov al, [esi]
        mov word [edi], ax
        add edi, 2
        inc esi
        
        loop .Clear2
    
    mov ecx, 80
    mov ah, 0xC

    .Clear2.1:				; Writing the kernel panic screen to "Cached Screens"...
        mov al, [esi]
        mov word [edi], ax
        add edi, 2
        inc esi
        
        loop .Clear2.1

    
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
    
    mov dword [0x1500+0x04], 0x1000
    
    mov word [0x1500+0x08], 0x8
    
    mov word [0x1500+0x62], 0x64

    xchg bx, bx
    
 %include 'KernelParts/GDT.asm'
Kernel:
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
    
    mov ch, 10001110b
    mov ebx, 0
    mov eax, Exceptions.DE

    call IDT.ModEntry
    
    mov ebx, 6
    mov eax, Exceptions.UD

    call IDT.ModEntry

    mov ebx, 8
    mov eax, Exceptions.DF

    call IDT.ModEntry

    mov ebx, 0xB
    mov eax, Exceptions.NP

    call IDT.ModEntry

    mov ebx, 0xC
    mov eax, Exceptions.SS

    call IDT.ModEntry

    mov ebx, 0xD
    mov eax, Exceptions.GP

    call IDT.ModEntry
    
    mov ebx, 0x20
    mov eax, IRQ.Timer

    call IDT.ModEntry
    
    xchg bx, bx
    
    mov ebx, 0x21
    mov eax, IRQ.PS2
    
    call IDT.ModEntry
    
    mov ch, 11101110b
    mov ebx, 0x30
    mov eax, Syscall_

    call IDT.ModEntry

    mov ch, 10101110b
    mov ebx, 0x31
    mov eax, SyscallDefine

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

    jnc .ATAPassed

    mov eax, 0x0C540C41			; Printing "ATA" in red
    mov gs:[edi], eax
    add edi, 4
    mov eax, 0x0C41
    mov gs:[edi], eax
    add edi, 4 

    jmp $

    .ATAPassed:
    call FuncInit

    mov eax, 0x0A540A41			; Printing "ATA" in green
    mov gs:[edi], eax
    add edi, 4
    mov eax, 0x0A41
    mov gs:[edi], eax
    add edi, 4    
 
    push edi

    mov edi, 7
    
    mov ax, 0x38
    mov es, ax
    
    mov byte [es:edi], 00000011b	; Setting up System VidBuffer
    add edi, 3
    mov dword [es:edi], 0xFA0
    mov edi, 0xFA0
    mov esi, 0
    mov ax, 0x48
    mov es, ax
    
    screencopyloop:			; Copying current screen to current VidBuffer
	mov eax, [gs:esi]
	mov [es:edi], eax
	add esi, 4
	add edi, 4
	
	cmp esi, 0x50*25
	jne screencopyloop
    
    add byte [ds:0x14], 2
    mov dword [ds:0x10], 1
    
    sti

    xchg bx, bx
    
    push ds
    
    mov ax, 0x18
    mov ds, ax
    
    mov eax, 1
    mov ebx, KernSize+1
    mov edi, 0x13600-0x1564-1
    mov dx, 18h
    mov es, dx

    xchg bx, bx

    call ATA.readSectors		; Reading INFO sector
    

    mov eax, dword [ds:0x13600-0x1565]	; Grabbing INFO sector signature
    
    pop ds
    pop edi
    push edi
    add edi, 80*25*2
    xchg bx, bx
    
    cmp eax, 0x40045005			; Checking said signature
    je .infosigpassed
    

    mov eax, 0x0C4E0C49			; Printing "INFO" in red
    mov es:[edi], eax
    add edi, 4
    mov eax, 0x0C4F0C46
    mov es:[edi], eax
    add edi, 6
    
    .error.sig_not_passed:
   	hlt
    	jmp .error.sig_not_passed
    
    .infosigpassed:
    	mov eax, 0x0A4E0A49			; Printing "INFO" in green
    	mov es:[edi], eax
   	add edi, 4
   	mov eax, 0x0A4F0A46
   	mov es:[edi], eax
   	add edi, 6

    mov eax, 3
    mov ebx, KernSize+2
    mov edi, 0x13000-0x1564-1
    mov dx, 18h
    mov es, dx

    xchg bx, bx

    call ATA.readSectors		; Reading file descriptor sector
    
    xor eax, eax
    mov al, [es:0x13600-0x1564+3]	; Getting terminal file number 
    
    xchg bx, bx
    mov di, 0x68
    lldt di
    mov di, 0x61
    mov es, di
    mov di, 0x52
    mov ds, di
    xor edi, edi    ;---------------------05 - 0 - Terminal Data
		    ;100000 - 100600
    mov bx, 0x0000
    xor ecx, ecx
    push eax				; Terminal file number
    mov cl, al
    xor eax, eax
    .fileSelectLoop:
    	add eax, 20
	loop .fileSelectLoop
    
    mov cl, [ds:eax+19-1]
    shl ecx, 4*2+1			; multiplication by 0x200
    mov edx, ecx
    mov ax, dx
    shr edx, 16
    mov cx, 0x0FFF
    div cx
    inc ax
    cmp dx, 0
    jz .noremainder
    inc ax
    .noremainder:
    add ax, 100h
    mov cx, ax

    mov [es:edi], cx
    push ecx
    
    add edi, 2
    
    mov [es:edi], bx
    
    add edi, 2
    
    shr ecx, 4*4
    and ch, 00001111b
    or ch, 11010000b
    shl ecx, 8
    mov ch, 10110010b
    mov cl, 0x10
    mov [es:edi], ecx

    add edi, 4      ;---------------------0B - 1 - Terminal Code
		    ;100000 - 100600
    mov bx, 0x0000
    pop ecx
    mov [es:edi], cx
    
    add edi, 2
    
    mov [es:edi], bx
    
    add edi, 2
    
    shr ecx, 4*4
    and ch, 00001111b
    or ch, 11010000b
    shl ecx, 8
    mov ch, 10111010b
    mov cl, 0x10
    mov [es:edi], ecx
    
    pop eax				; Terminal file number
    
    mov ebx, 0 				; LDT process data entry
    call LoadFile
    mov ax, 1+4
    mov es, ax
    mov ebx, 8+4+1
    call StartFile
    
    cli
    lidt [0x500]			; Triple fault as restart after terminal stops
    int 255

StartFile:	; ebx - LDT code entry for process, es - lDT data entry for process, fs - Current process LDT data entry.
	xchg bx, bx
	pusha
 	xor edi, edi

	xor eax, eax
	
	push ds
	mov ax, 0x18
	mov ds, ax
	mov al, [ds:0x14]
	pop ds

	mov ecx, 7

	mul ecx
	mov edi, eax
	push ds
	mov ax, 0x38
	mov ds, ax
    	mov byte [ds:edi], 00000001b
    	inc edi
	mov ax, es
	mov [edi], ax
    	inc edi
	inc edi
	
	mov eax, [es:0x4]
	
   	mov dword [ds:edi], eax
	
	push ax
	mov ax, 0x18
	mov ds, ax
	pop ax

	inc dword [0x10]  	; Incrementing the "Current Vidbuffer" #
	inc dword [0x14]  	; Incrementing the "Next Vidbuffer" #
	or byte [0x20], 1 	; Seting the Usermode bit in "Keyboard Control"
	mov ax, es
	mov [0x21], ax
	mov eax, [es:0x8] 	; Copying the "Program Keypress location"
	mov dword [0x23], eax	; Seting the "Keypress location"
	
	pop ds
	push fs

	pushfd
	push dword 0x20
	push .iret+1
	
	push es
	mov eax, [es:0xC]
	push eax
	
	sti
	pushfd
    	push dword ebx
    	push dword [es:0x0]
    	
	push es
	mov ax, 0x70
	mov es, ax
	mov eax, esp
	add eax, 4*6
	mov es:[0x4], eax
	pop es
	
   	xchg bx, bx
	
	.iret:
   	iret
	
	pop es ;pop fs
	push ds
	mov ax, 0x18
	mov ds, ax
	dec dword [0x10]  	; Decrementing the "Current Vidbuffer" #
	or byte [0x20], 1 	; Seting the Usermode bit in "Keyboard Control"
	mov ax, es
	mov [0x21], ax
	mov eax, [es:0x8] 	; Copying the "Program Keypress location"
	mov dword [0x23], eax	; Seting the "Keypress location"
	pop ds

	popa
	
	ret

LoadFile:	; ebx - LDT Data entry #, al - file number
	pusha
	push ebx			; Pushing the LDT entry number
	
	xchg bx, bx
	xor ecx, ecx
    	mov cl, al
	mov esi, 0x11A9B
	xor ebx, ebx

	mov ax, 0x18
	mov es, ax

	.selectfileloop:		; Selecting file
	add esi, 20
	add bl, [es:esi-2]		; Adding to start sector #
	jnc .selectfileloop.1
	inc bh
	
	.selectfileloop.1:
	loop .selectfileloop
   	
	add esi, 20
    	
	xor eax, eax
 	mov al, [es:esi-2]
	add ebx, 1+1+3			; Skiping Descriptor Sectors, INFO sector and Boot sector
	
	pop edx	; pop ebx
	shl edx, 3			; Aligning the number of the LDT entry
	
	mov di, 0x60
	mov es, di
	
	xor ecx, ecx
	mov cx, [es:edx+2]
	ror ecx, 16
	mov cl, [es:edx+7]
	and cl, 1111b
	ror ecx, 16
	add ecx, 0xFFF
	xor edi, edi
	
	or edx, 4			; Setting LDT bit
	mov es, dx

	.clearMem:
		mov byte [es:edi], 0
		inc edi
		loop .clearMem
		
 	xchg bx, bx
    	xor edi, edi

	call ATA.readSectors		; Reading file
	
	popa
	ret

FuncInit:
	pusha
	
	push es
	mov ax, 0x30
	mov es, ax
	xor edi, edi

	mov word [es:edi], 1
	mov dword [es:edi+2], Display.ReDraw
	
	add edi, 6

	mov word [es:edi], 1
	mov dword [es:edi+2], Halt

	add edi, 6

	mov word [es:edi], 1
	mov dword [es:edi+2], StartFile
	
	add edi, 6

	mov word [es:edi], 1
	mov dword [es:edi+2], LoadFile

	add edi, 6

	mov word [es:edi], 1
	mov dword [es:edi+2], EndProgram

	pop es
	
	popa
	ret

SyscallDefine:	; bx - Syscall info, cl - # of Syscall, edx - Syscall function.
	pusha
	
	push es
	mov ax, 0x30
	mov es, ax
	mov al, 6
	mov ch, 0
	ror ecx, 16
	xor cx, cx
	ror ecx, 16
	mul cl
	mov edi, eax

	mov word [es:edi], bx
	mov dword [es:edi+2], edx
	
	pop es
	
	popa
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
        mov ah, ch

	
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
    pushf
    push fs
    push eax
    push ebx
    
    mov ax, 0x30
    mov fs, ax
    
    xor eax, eax
    cmp ecx, 0
    je .loopend

    .loop:
        add eax, 6
        loop .loop
        
    .loopend:
    test byte [fs:eax], 00000001b
    stc
    jnz .run
    
    pop ebx
    pop eax
    pop fs
    popf
    iret
    
    .run:
        ;xchg bx, bx
        
        mov ebx, [fs:eax+2]
	ror ebx, 16
	mov bh, [fs:eax+1]
        
	cli
	
	mov ecx, ebx
        
 	pop ebx
	
	test byte [eax], 00000010b
	
  	pop eax
	pop fs
	jnz .UsermodeDefinedSyscall
	ror ecx, 16
        call ecx
    
    .end:
    	popf
   	clc
   	iret
    
    .UsermodeDefinedSyscall:
    	push cx
	dec ch
	shr cx, 8-3
	and cx, 0000000011111000b
	or cl, 00000101b
	mov es, cx
	pop cx
	ror cx, 8
	shl cl, 3
	or cl, 00000101b
	
    	pushfd
	push dword 0x20
	push .iret+1
	
	push es
	push dword [es:0xC]
	
	sti
	pushfd
	push word 0
    	push word cx
	inc esp
	inc esp
	inc esp
	push word 0
	dec esp
	ror cx, 8
	mov ch, 0
	ror ecx, 16
    	push dword ecx

	.iret:
	iret
	
	jmp .end

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
	
	push ds
	mov ax, 0x18
	mov ds, ax
	mov ecx, ds:[0x10]
	pop ds
	
        xor esi, esi
        xor edi, edi
        add esi, 3
        cmp ecx, 0
	jz .ReDraw.loopend
        
        .ReDraw.loop:
            add esi, 0x7
            loop .ReDraw.loop
        
        .ReDraw.loopend:
        
        mov ecx, 3E8h
        push es
	mov ax, 0x38
	mov es, ax
	
	mov ax, 0x48
	
	mov ebx, [es:esi]
	sub esi, 3
	
	test byte [es:esi], 00000010b		; Checker for system flag
	
	jnz .ReDraw.1
	
	mov ax, [es:esi+1]			; Getting the data segment of program
	
	.ReDraw.1:
	
	mov es, ax
	mov esi, ebx
	push gs
	mov ax, 0x28
	mov gs, ax
	
        .ReDraw.loop2:				; Copying to screen
            mov eax, dword [es:esi]
            mov dword [gs:edi], eax
            add edi, 4
            add esi, 4
            
            loop .ReDraw.loop2
        
	pop gs
        pop es
        popa
        ret

%include 'KernelParts/ATA.asm'

Halt:
	pushf
	sti
	hlt
	popf
	ret

EndProgram:	; Returns to the previous program
	push es
	mov ax, 0x70
	mov es, ax
	mov eax, es:[0x4]
	pop es
	mov esp, eax
    	iret


Strings:
    .Panic1:
        db '0123456789ABCDEF                                                                '
        db ',---EXCEPTION----------------------------------------------------------------!!!'
        db '                                                                                '
	db '                                                                                '
        db '                                                                                '
	db '                                                                                '
    
    .Panic3:
        db '                                                                                '
        db '                                                                                '
        db '  Exception: #// ErrCode: 0x//\\                                                '
        db '                                                                                '
        db '                                                                                '
        db '  EAX: 0x//\\//\\ EBX: 0x//\\//\\ ECX: 0x//\\//\\ EDX: 0x//\\//\\               '
        db '  EDI: 0x//\\//\\ ESI: 0x//\\//\\ ESP: 0x//\\//\\                               '
        db '  CS:  0x//\\ DS:  0x//\\ SS:  0x//\\                                           '
        db '                                                                                '
        db '                                EIP:  0x//\\//\\                                '
	db '                                                                                '
        db '                                                                                '
        db '                                                                                '
    
    .Panic4:
        db '                                                                                '
        db '   |Enter Xit to return to shell, MeM to dump memory, Cnt to continue in EIP|   '
        db '                                                                                '
        db '                                                                                '
        db '--------------------------------------------------------------------------------'	
        db '                                                                                '
    .HexTable:  db '0123456789ABCDEF'

times KernSize*512-($-$$) db 0

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
    
