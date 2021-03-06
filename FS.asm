InfoSector:
	dd 40045005h			   ; Correct FlFS 0.1 signature
	db 01				   ; Autorun file index

	times 512-($-InfoSector) db 0

DescriptorSectors:
	Boot.sb:			   ; First file is kernel (and second stage bootloader), linked with the sectors after boot sector.
		db 00000001b 		   ; Flags. First bit - Present flag, second bit - Segmentation flag - does this descriptor show a segmentation table for the file (if the file is in pieces around the disk, AKA fragmented).
		
		db '12Boot.sb'		   ; Filename. 
		times 15-($-Boot.sb-1) db 0  ; Padding. 	
		
		db 0			   ; Emergency terminator for filename
		
		db 00000000b		   ; Owning userID. Two most significant bits show cpu ring.
		db 12			   ; Size of file in sectors.
		
		db 0
	
	Terminal.ub:
		db 00000001b
		
		db 'Terminal.ub'
		times 15-($-Terminal.ub-1) db 0
		
		db 0
		
		db 11000000b
		
		db 1+3
		
		db 0

	Snake.ub:
		db 00000001b
		
		db 'Snake.ub'
		times 15-($-Snake.ub-1) db 0
		
		db 0
		
		db 11000000b
		
		db 1+3
		
		db 0
	
	HexEdit.ub:
		db 00000001b
		
		db 'HexEdit.ub'
		times 15-($-HexEdit.ub-1) db 0
		
		db 0
		
		db 11000000b
		
		db 1+3
		
		db 0


	times 3*512-($-DescriptorSectors) db 0

