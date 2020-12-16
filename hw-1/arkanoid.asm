;x86 assembly

;Data segment
dseg segment 'DATA'
	WINDOW_WIDTH DW 140h   ; sirina prozora (320 px)
	WINDOW_HEIGHT DW 0C8h  ;visina prozora (200 px)
	WINDOW_BOUNDS DW 0     ; promenljiva pomocu koje mozemo izvrsiti ranu detekciju sudara
	
	TIME_AUX DB 0 ; vremenska promenljiva 
	BALL_X DW 000ah ; X pozicija (kolona) lopte
	BALL_Y DW 000ah ; Y pozicija (linija) lopte
	BALL_SIZE DW 04h ; velicina lopte (koliko piksela u sirinu i u visinu)
	BALL_VELOCITY_X DW 05h ; x (horizontalna) komponenta brzine
	BALL_VELOCITY_Y DW 02h ; Y (vertikalna) komponenta brzine
	
	
	BLOK_WIDTH DW 30h; sirina bloka (u pikselima)   
	BLOK_HEIGHT DW 0Ah; visina bloka (u pikslima) 
;prvi red	
	BLOK11_X DW 14h 
	BLOK11_Y DW 0Ah  
	
	BLOK12_X DW 60h 
	BLOK12_Y DW 0Ah  
	
	BLOK13_X DW 0ACh 
	BLOK13_Y DW 0Ah 
	
	BLOK14_X DW 0F8h 
	BLOK14_Y DW 0Ah 
;drugi red
	BLOK21_X DW 14h 
	BLOK21_Y DW 23h 
	
	BLOK22_X DW 60h 
	BLOK22_Y DW 23h 
	
	BLOK23_X DW 0ACh 
	BLOK23_Y DW 23h 
	
	BLOK24_X DW 0F8h 
	BLOK24_Y DW 23h 
;treci red	
	BLOK31_X DW 14h 
	BLOK31_Y DW 3Ch  
	
	BLOK32_X DW 60h 
	BLOK32_Y DW 3Ch  
	
	BLOK33_X DW 0ACh 
	BLOK33_Y DW 3Ch 
	
	BLOK34_X DW 0F8h
	BLOK34_Y DW 3Ch 
;platforma
	PLATFORMA_X DW 80h
	PLATFORMA_Y DW 0BAh 
	PLATFORMA_WIDTH DW 3Eh
	PLATFORMA_HEIGHT DW 07h 
	
	PLATFORMA_BOUNDS DW 1h  

;za unistavanje blokova
	unisten11 DW 1h
	unisten12 DW 1h
	unisten13 DW 1h
	unisten14 DW 1h
	unisten21 DW 1h
	unisten22 DW 1h
	unisten23 DW 1h
	unisten24 DW 1h
	unisten31 DW 1h
	unisten32 DW 1h
	unisten33 DW 1h
	unisten34 DW 1h

	BOJA DW 1h
	
;ispis
	print DB 'GAME OVER (press ESC to exit)', '$'
	printt DB 'CONGRATULATIONS (press ESC to exit)', '$'
	poeni DW 0h

dseg ends


;Code segment
cseg	segment	'CODE'
		assume cs:cseg, ds:dseg, ss:sseg
draw:		
	mov ax, dseg
    mov ds, ax
		
	CHECK_TIME:
	
		mov ah,2Ch ; prekid kojim se dobija sistemsko vreme
		int 21h    ; CH = sati, CL = minuti, DH = sekunde, DL = stotinke
		
		cmp dl,TIME_AUX  ; da li je trenutno vreme jednako prethodnom (TIME_AUX)?
		je CHECK_TIME    ; ako je isto, proveri ponovo; inace ucrtaj loptu, pomeri je....
		
		mov TIME_AUX,dl ; azuriraj vreme
		
		call CLEAR_SCREEN ; obrisi sadrzaj ekrana
		call MOVE_BALL ; pomeri loptu
		call DRAW_BALL  ; ucrtaj  je
		call MOVE_PLATFORMA
		call DRAW_PLATFORMA
		call DRAW_SCORE
		
nacrtaj11:
		mov ax, unisten11
		cmp unisten11,0h	;unisten11=0 -> loptica je dotakla blok
		jz nacrtaj12 
		call DRAW_BLOK11
nacrtaj12:
		mov ax, unisten12
		cmp unisten12,0h
		jz nacrtaj13
		call DRAW_BLOK12
nacrtaj13:
		mov ax, unisten13
		cmp unisten13,0h
		jz nacrtaj14
		call DRAW_BLOK13
nacrtaj14:
		mov ax, unisten14
		cmp unisten14,0h
		jz nacrtaj21	
		call DRAW_BLOK14
nacrtaj21:
		mov ax, unisten21
		cmp unisten21,0h
		jz nacrtaj22		
		call DRAW_BLOK21
nacrtaj22:
		mov ax, unisten22
		cmp unisten22,0h
		jz nacrtaj23
		call DRAW_BLOK22
nacrtaj23:
		mov ax, unisten23
		cmp unisten23,0h
		jz nacrtaj24		
		call DRAW_BLOK23
nacrtaj24:
		mov ax, unisten24
		cmp unisten24,0h
		jz nacrtaj31
		call DRAW_BLOK24
nacrtaj31:
		mov ax, unisten31
		cmp unisten31, 0h
		jz nacrtaj32
		call DRAW_BLOK31
nacrtaj32:
		mov ax, unisten32
		cmp unisten32, 0h
		jz nacrtaj33
		call DRAW_BLOK32
nacrtaj33:
		mov ax, unisten33
		cmp unisten33,0h
		jz nacrtaj34
		call DRAW_BLOK33
nacrtaj34:
		mov ax, unisten34
		cmp unisten34,0h
		jz pobeda
		call DRAW_BLOK34
		
pobeda:
		cmp poeni, 24h
		jne zav
		call kraj
zav:
		
		jmp CHECK_TIME ; proveri vreme ponovo
	
	jmp kraj
	

;--------------------------------------------------------------------------------pomeranje loptice-------------------------------------------	
	MOVE_BALL PROC NEAR
		
		mov ax,BALL_VELOCITY_X    
		add BALL_X,ax  		; pomeri lopticu horizontalno
livica:		
		mov ax,WINDOW_BOUNDS
		cmp BALL_X,ax   
		jg divica
		call NEG_VELOCITY_X         ; BALL_X < 0 + WINDOW_BOUNDS (sudar - leva ivica)
		mov boja, 02h
		
divica:
		mov ax,WINDOW_WIDTH
		sub ax,BALL_SIZE
		sub ax,WINDOW_BOUNDS
		cmp BALL_X,ax	          ;BALL_X > WINDOW_WIDTH - BALL_SIZE  - WINDOW_BOUNDS (sudar - desna ivica)
		jl givica
		call NEG_VELOCITY_X
		mov boja, 02h
		
givica:
		mov ax,BALL_VELOCITY_Y
		add BALL_Y,ax             ; pomeri lopticu vertikalno
		
		mov ax,WINDOW_BOUNDS
		cmp BALL_Y,ax   		;BALL_Y < 0 + WINDOW_BOUNDS (sudar - gornja ivica)
		jg dnjivica
		call NEG_VELOCITY_Y 
		mov boja, 02h
		
dnjivica:
		mov ax,WINDOW_HEIGHT	
		sub ax,BALL_SIZE
		sub ax,WINDOW_BOUNDS
		cmp BALL_Y,ax
		jl pGore
		call kraj
		
pGore:
		mov ax, PLATFORMA_Y
		sub ax,BALL_SIZE 
		cmp BALL_Y,ax
		jl pBOCNE_strane					
		mov ax, PLATFORMA_X
		sub ax, BALL_SIZE
		add ax,PLATFORMA_BOUNDS
		cmp BALL_X,ax
		jl pBOCNE_strane
		mov ax, PLATFORMA_X
		add ax, PLATFORMA_WIDTH
		sub ax,PLATFORMA_BOUNDS
		cmp BALL_X,ax
		jg pBOCNE_strane
		call NEG_VELOCITY_Y
		mov boja, 03h
	
pBOCNE_strane:
		mov ax, PLATFORMA_X
		sub ax,BALL_SIZE
		cmp BALL_X,ax
		jl blok11           	 
		mov ax, PLATFORMA_X
		add ax, PLATFORMA_WIDTH
		cmp BALL_X,ax
		jg blok11						
		mov ax, PLATFORMA_Y
		sub ax,BALL_SIZE 
		add ax,PLATFORMA_BOUNDS
		cmp BALL_Y,ax
		jl blok11
		mov ax, PLATFORMA_Y
		add ax, PLATFORMA_HEIGHT     
		sub ax,PLATFORMA_BOUNDS
		cmp BALL_Y, ax
		jg blok11
		call NEG_VELOCITY_X
		mov boja, 03h
		
blok11:
		cmp unisten11, 0h			;proverava da li je blok vec unisten
		je blok12  
		
		mov ax, BLOK11_Y
		sub ax, BALL_SIZE
		cmp BALL_Y, ax
		jl blok12
		mov ax, BLOK11_Y
		add ax, BLOK_HEIGHT
		cmp BALL_Y, ax
		jg blok12
		mov ax, BLOK11_X
		sub ax, BALL_SIZE
		cmp BALL_X, ax
		jl blok12
		mov ax, BLOK11_X
		add ax, BLOK_WIDTH
		cmp BALL_X, ax
		jg blok12
		mov unisten11, 0h
		call dec_poeni
		call dec_poeni
		call dec_poeni
		mov boja, 04h
		
blok12:
		cmp unisten12, 0h
		je blok13
		
		mov ax, BLOK12_Y
		sub ax, BALL_SIZE
		cmp BALL_Y, ax
		jl blok13
		mov ax, BLOK12_Y
		add ax, BLOK_HEIGHT
		cmp BALL_Y, ax
		jg blok13
		mov ax, BLOK12_X
		sub ax, BALL_SIZE
		cmp BALL_X, ax
		jl blok13
		mov ax, BLOK12_X
		add ax, BLOK_WIDTH
		cmp BALL_X, ax
		jg blok13
		mov unisten12, 0h
		call dec_poeni
		call dec_poeni
		call dec_poeni
		mov boja, 04h
		
blok13:
		cmp unisten13, 0h
		je blok14
		
		mov ax, BLOK13_Y
		sub ax, BALL_SIZE
		cmp BALL_Y, ax
		jl blok14
		mov ax, BLOK13_Y
		add ax, BLOK_HEIGHT
		cmp BALL_Y, ax
		jg blok14
		mov ax, BLOK13_X
		sub ax, BALL_SIZE
		cmp BALL_X, ax
		jl blok14
		mov ax, BLOK13_X
		add ax, BLOK_WIDTH
		cmp BALL_X, ax
		jg blok14
		mov unisten13, 0h
		call dec_poeni
		call dec_poeni
		call dec_poeni
		mov boja, 04h
		
blok14:
		cmp unisten14, 0h
		je blok21
		
		mov ax, BLOK14_Y
		sub ax, BALL_SIZE
		cmp BALL_Y, ax
		jl blok21
		mov ax, BLOK14_Y
		add ax, BLOK_HEIGHT
		cmp BALL_Y, ax
		jg blok21
		mov ax, BLOK14_X
		sub ax, BALL_SIZE
		cmp BALL_X, ax
		jl blok21
		mov ax, BLOK14_X
		add ax, BLOK_WIDTH
		cmp BALL_X, ax
		jg blok21
		mov unisten14, 0h
		call dec_poeni
		call dec_poeni
		call dec_poeni
		mov boja, 04h
		
blok21:
		cmp unisten21, 0h
		je blok22
		
		mov ax, BLOK21_Y
		sub ax, BALL_SIZE
		cmp BALL_Y, ax
		jl blok22
		mov ax, BLOK21_Y
		add ax, BLOK_HEIGHT
		cmp BALL_Y, ax
		jg blok22
		mov ax, BLOK21_X
		sub ax, BALL_SIZE
		cmp BALL_X, ax
		jl blok22
		mov ax, BLOK21_X
		add ax, BLOK_WIDTH
		cmp BALL_X, ax
		jg blok22
		mov unisten21, 0h
		call dec_poeni
		call dec_poeni
		mov boja, 05h
		
blok22:
		cmp unisten22, 0h
		je blok23
		
		mov ax, BLOK22_Y
		sub ax, BALL_SIZE
		cmp BALL_Y, ax
		jl blok23
		mov ax, BLOK22_Y
		add ax, BLOK_HEIGHT
		cmp BALL_Y, ax
		jg blok23
		mov ax, BLOK22_X
		sub ax, BALL_SIZE
		cmp BALL_X, ax
		jl blok23
		mov ax, BLOK22_X
		add ax, BLOK_WIDTH
		cmp BALL_X, ax
		jg blok23
		mov unisten22, 0h	
		call dec_poeni
		call dec_poeni
		mov boja, 05h
		
blok23:
		cmp unisten23, 0h
		je blok24

		mov ax, BLOK23_Y
		sub ax, BALL_SIZE
		cmp BALL_Y, ax
		jl blok24
		mov ax, BLOK23_Y
		add ax, BLOK_HEIGHT
		cmp BALL_Y, ax
		jg blok24
		mov ax, BLOK23_X
		sub ax, BALL_SIZE
		cmp BALL_X, ax
		jl blok24
		mov ax, BLOK23_X
		add ax, BLOK_WIDTH
		cmp BALL_X, ax
		jg blok24
		mov unisten23, 0h
		call dec_poeni
		call dec_poeni
		mov boja, 05h
			
blok24:
		cmp unisten24, 0h
		je blok31
		
		mov ax, BLOK24_Y
		sub ax, BALL_SIZE
		cmp BALL_Y, ax
		jl blok31
		mov ax, BLOK24_Y
		add ax, BLOK_HEIGHT
		cmp BALL_Y, ax
		jg blok31
		mov ax, BLOK24_X
		sub ax, BALL_SIZE
		cmp BALL_X, ax
		jl blok31
		mov ax, BLOK24_X
		add ax, BLOK_WIDTH
		cmp BALL_X, ax
		jg blok31
		mov unisten24, 0h
		call dec_poeni
		call dec_poeni
		mov boja, 05h
			
blok31:
		cmp unisten31, 0h
		je blok32
		
		mov ax, BLOK31_Y
		sub ax, BALL_SIZE
		cmp BALL_Y, ax
		jl blok32
		mov ax, BLOK31_Y
		add ax, BLOK_HEIGHT
		cmp BALL_Y, ax
		jg blok32
		mov ax, BLOK31_X
		sub ax, BALL_SIZE
		cmp BALL_X, ax
		jl blok32
		mov ax, BLOK31_X
		add ax, BLOK_WIDTH
		cmp BALL_X, ax
		jg blok32
		mov unisten31, 0h
		call dec_poeni
		mov boja, 06h
		
blok32:
		cmp unisten32, 0h
		je blok33
		
		mov ax, BLOK32_Y
		sub ax, BALL_SIZE
		cmp BALL_Y, ax
		jl blok33
		mov ax, BLOK32_Y
		add ax, BLOK_HEIGHT
		cmp BALL_Y, ax
		jg blok33
		mov ax, BLOK32_X
		sub ax, BALL_SIZE
		cmp BALL_X, ax
		jl blok33
		mov ax, BLOK32_X
		add ax, BLOK_WIDTH
		cmp BALL_X, ax
		jg blok33
		mov unisten32, 0h
		call dec_poeni
		mov boja, 06h
		
blok33:
		cmp unisten33, 0h
		je blok34
		
		mov ax, BLOK33_Y
		sub ax, BALL_SIZE
		cmp BALL_Y, ax
		jl blok34
		mov ax, BLOK33_Y
		add ax, BLOK_HEIGHT
		cmp BALL_Y, ax
		jg blok34
		mov ax, BLOK33_X
		sub ax, BALL_SIZE
		cmp BALL_X, ax
		jl blok34
		mov ax, BLOK33_X
		add ax, BLOK_WIDTH
		cmp BALL_X, ax
		jg blok34
		mov unisten33, 0h
		call dec_poeni
		mov boja, 06h
		
blok34:
		cmp unisten34, 0h
		je zavrsi
		
		mov ax, BLOK34_Y
		sub ax, BALL_SIZE
		cmp BALL_Y, ax
		jl zavrsi
		mov ax, BLOK34_Y
		add ax, BLOK_HEIGHT
		cmp BALL_Y, ax
		jg zavrsi
		mov ax, BLOK34_X
		sub ax, BALL_SIZE
		cmp BALL_X, ax
		jl zavrsi
		mov ax, BLOK34_X
		add ax, BLOK_WIDTH
		cmp BALL_X, ax
		jg zavrsi
		mov unisten34, 0h
		call dec_poeni
		mov boja, 06h

zavrsi:
		ret


		NEG_VELOCITY_X:
			neg BALL_VELOCITY_X   ;BALL_VELOCITY_X = - BALL_VELOCITY_X
			ret
			
		NEG_VELOCITY_Y:
			neg BALL_VELOCITY_Y   ;BALL_VELOCITY_Y = - BALL_VELOCITY_Y
			ret
		
	MOVE_BALL ENDP
	
	
	DEC_POENI PROC NEAR
		inc poeni
		
		cmp poeni, 0ah
		je deset
		cmp poeni, 1ah
		je dvadeset
		jmp zzavrsi
		
		deset:
			mov poeni, 10h
			jmp zzavrsi
		dvadeset:
			mov poeni, 20h
			jmp zzavrsi
		
		zzavrsi:
			ret
		
	DEC_POENI ENDP
	
	
;---------------------------------------------------------------------------------crtanje loptice------------------------------------------------------	
	DRAW_BALL PROC NEAR
		
		mov cx,BALL_X ; postavi inicijalnu kolonu (X)
		mov dx,BALL_Y ; postavi inicijalni red (Y)
		
		DRAW_BALL_HORIZONTAL:
			mov ah,0Ch ; podesi konfiguraciju za ispis piksela
			
			cmp boja,1h
			jne purple
			mov al,0Fh ; izaberi belu boju
		purple:
			cmp boja,02h  ;sudar leve,desne, gornje - ljubicasta loptica
			jne blue
			mov al,05h
		blue:	
			cmp boja,03h  ;platforma -plava 
			jne red
			mov al,01h
		red:
			cmp boja,04h  ;blok-prvi red (crvena)
			jne yellow
			mov al, 04h
		
		yellow:
			cmp boja,05h  ;blok-drugi red (zuta)
			jne green
			mov al, 0Eh
			
		green:
			cmp boja,06h  ;blok-treci red (zelena)
			jne dalje 
			mov al, 02h
			
			
		dalje:
			mov bh,00h ; 
			int 10h    ; izvrsi konfiguraciju
			
			inc cx     ;cx = cx + 1
			mov ax,cx  
			sub ax,BALL_X ;cx - BALL_X > BALL_SIZE (ako jeste, iscrtali smo za taj red sve kolone; inace nastavljamo dalje)
			cmp ax,BALL_SIZE
			jng DRAW_BALL_HORIZONTAL
			
			mov cx,BALL_X ; vrati cx na inicijalnu kolonu
			inc dx        ; idemo u sledeci red
			
			mov ax,dx    ; dx - BALL_Y > BALL_SIZE (ako jeste, iscrtali smo sve redove piksela; inace nastavljamo dalje)
			sub ax,BALL_Y
			cmp ax,BALL_SIZE
			jng DRAW_BALL_HORIZONTAL
		
		ret
	DRAW_BALL ENDP
	
;---------------------prvi red-----------------
	DRAW_BLOK11 PROC NEAR
		mov cx, BLOK11_X
		mov dx, BLOK11_Y
		
		DRAW_BLOK11_HORIZONTAL:
			mov ah,0Ch
			mov al,04h
			mov bh,00h
			int 10h
			
			inc cx 
			mov ax,cx
			sub ax,BLOK11_X
			cmp ax,BLOK_WIDTH
			jng DRAW_BLOK11_HORIZONTAL
			
			mov cx,BLOK11_X
			
			inc dx
			mov ax,dx
			sub ax,BLOK11_Y
			cmp ax,BLOK_HEIGHT
			jng DRAW_BLOK11_HORIZONTAL
			
			ret
	DRAW_BLOK11 ENDP
	
	DRAW_BLOK12 PROC NEAR
		mov cx, BLOK12_X
		mov dx, BLOK12_Y
		
		DRAW_BLOK12_HORIZONTAL:
			mov ah,0Ch
			mov al,04h
			mov bh,00h
			int 10h
			
			inc cx 
			mov ax,cx
			sub ax,BLOK12_X
			cmp ax,BLOK_WIDTH
			jng DRAW_BLOK12_HORIZONTAL
			
			mov cx,BLOK12_X
			
			inc dx
			mov ax,dx
			sub ax,BLOK12_Y
			cmp ax,BLOK_HEIGHT
			jng DRAW_BLOK12_HORIZONTAL
			
			ret
	DRAW_BLOK12 ENDP
	
	DRAW_BLOK13 PROC NEAR
		mov cx, BLOK13_X
		mov dx, BLOK13_Y
		
		DRAW_BLOK13_HORIZONTAL:
			mov ah,0Ch
			mov al,04h
			mov bh,00h
			int 10h
			
			inc cx 
			mov ax,cx
			sub ax,BLOK13_X
			cmp ax,BLOK_WIDTH
			jng DRAW_BLOK13_HORIZONTAL
			
			mov cx,BLOK13_X
			
			inc dx
			mov ax,dx
			sub ax,BLOK13_Y
			cmp ax,BLOK_HEIGHT
			jng DRAW_BLOK13_HORIZONTAL
			
			ret
	DRAW_BLOK13 ENDP
	
	DRAW_BLOK14 PROC NEAR
		mov cx, BLOK14_X
		mov dx, BLOK14_Y
		
		DRAW_BLOK14_HORIZONTAL:
			mov ah,0Ch
			mov al,04h
			mov bh,00h
			int 10h
			
			inc cx 
			mov ax,cx
			sub ax,BLOK14_X
			cmp ax,BLOK_WIDTH
			jng DRAW_BLOK14_HORIZONTAL
			
			mov cx,BLOK14_X
			
			inc dx
			mov ax,dx
			sub ax,BLOK14_Y
			cmp ax,BLOK_HEIGHT
			jng DRAW_BLOK14_HORIZONTAL
			
			ret
	DRAW_BLOK14 ENDP
	
;--------------------------------drugi red-----------------	
	DRAW_BLOK21 PROC NEAR
		mov cx, BLOK21_X
		mov dx, BLOK21_Y
		
		DRAW_BLOK21_HORIZONTAL:
			mov ah,0Ch
			mov al,0Eh
			mov bh,00h
			int 10h
			
			inc cx 
			mov ax,cx
			sub ax,BLOK21_X
			cmp ax,BLOK_WIDTH
			jng DRAW_BLOK21_HORIZONTAL
			
			mov cx,BLOK21_X
			
			inc dx
			mov ax,dx
			sub ax,BLOK21_Y
			cmp ax,BLOK_HEIGHT
			jng DRAW_BLOK21_HORIZONTAL
			
			ret
	DRAW_BLOK21 ENDP
	
	DRAW_BLOK22 PROC NEAR
		mov cx, BLOK22_X
		mov dx, BLOK22_Y
		
		DRAW_BLOK22_HORIZONTAL:
			mov ah,0Ch
			mov al,0Eh
			mov bh,00h
			int 10h
			
			inc cx 
			mov ax,cx
			sub ax,BLOK22_X
			cmp ax,BLOK_WIDTH
			jng DRAW_BLOK22_HORIZONTAL
			
			mov cx,BLOK22_X
			
			inc dx
			mov ax,dx
			sub ax,BLOK22_Y
			cmp ax,BLOK_HEIGHT
			jng DRAW_BLOK22_HORIZONTAL
			
			ret
	DRAW_BLOK22 ENDP
	
	DRAW_BLOK23 PROC NEAR
		mov cx, BLOK23_X
		mov dx, BLOK23_Y
		
		DRAW_BLOK23_HORIZONTAL:
			mov ah,0Ch
			mov al,0Eh
			mov bh,00h
			int 10h
			
			inc cx 
			mov ax,cx
			sub ax,BLOK23_X
			cmp ax,BLOK_WIDTH
			jng DRAW_BLOK23_HORIZONTAL
			
			mov cx,BLOK23_X
			
			inc dx
			mov ax,dx
			sub ax,BLOK23_Y
			cmp ax,BLOK_HEIGHT
			jng DRAW_BLOK23_HORIZONTAL
			
			ret
	DRAW_BLOK23 ENDP
	
	DRAW_BLOK24 PROC NEAR
		mov cx, BLOK24_X
		mov dx, BLOK24_Y
		
		DRAW_BLOK24_HORIZONTAL:
			mov ah,0Ch
			mov al,0Eh
			mov bh,00h
			int 10h
			
			inc cx 
			mov ax,cx
			sub ax,BLOK24_X
			cmp ax,BLOK_WIDTH
			jng DRAW_BLOK24_HORIZONTAL
			
			mov cx,BLOK24_X
			
			inc dx
			mov ax,dx
			sub ax,BLOK24_Y
			cmp ax,BLOK_HEIGHT
			jng DRAW_BLOK24_HORIZONTAL
			
			ret
	DRAW_BLOK24 ENDP
;-----------------------------------------------treci red-----------
	DRAW_BLOK31 PROC NEAR
		mov cx, BLOK31_X
		mov dx, BLOK31_Y
		
		DRAW_BLOK31_HORIZONTAL:
			mov ah,0Ch
			mov al,02h
			mov bh,00h
			int 10h
			
			inc cx 
			mov ax,cx
			sub ax,BLOK31_X
			cmp ax,BLOK_WIDTH
			jng DRAW_BLOK31_HORIZONTAL
			
			mov cx,BLOK31_X
			
			inc dx
			mov ax,dx
			sub ax,BLOK31_Y
			cmp ax,BLOK_HEIGHT
			jng DRAW_BLOK31_HORIZONTAL
			
			ret
	DRAW_BLOK31 ENDP
	
	DRAW_BLOK32 PROC NEAR
		mov cx, BLOK32_X
		mov dx, BLOK32_Y
		
		DRAW_BLOK32_HORIZONTAL:
			mov ah,0Ch
			mov al,02h
			mov bh,00h
			int 10h
			
			inc cx 
			mov ax,cx
			sub ax,BLOK32_X
			cmp ax,BLOK_WIDTH
			jng DRAW_BLOK32_HORIZONTAL
			
			mov cx,BLOK32_X
			
			inc dx
			mov ax,dx
			sub ax,BLOK32_Y
			cmp ax,BLOK_HEIGHT
			jng DRAW_BLOK32_HORIZONTAL
			
			ret
	DRAW_BLOK32 ENDP
	
	DRAW_BLOK33 PROC NEAR
		mov cx, BLOK33_X
		mov dx, BLOK33_Y
		
		DRAW_BLOK33_HORIZONTAL:
			mov ah,0Ch
			mov al,02h
			mov bh,00h
			int 10h
			
			inc cx 
			mov ax,cx
			sub ax,BLOK33_X
			cmp ax,BLOK_WIDTH
			jng DRAW_BLOK33_HORIZONTAL
			
			mov cx,BLOK33_X
			
			inc dx
			mov ax,dx
			sub ax,BLOK33_Y
			cmp ax,BLOK_HEIGHT
			jng DRAW_BLOK33_HORIZONTAL
			
			ret
	DRAW_BLOK33 ENDP
	
	DRAW_BLOK34 PROC NEAR
		mov cx, BLOK34_X
		mov dx, BLOK34_Y
		
		DRAW_BLOK34_HORIZONTAL:
			mov ah,0Ch
			mov al,02h
			mov bh,00h
			int 10h
			
			inc cx 
			mov ax,cx
			sub ax,BLOK34_X
			cmp ax,BLOK_WIDTH
			jng DRAW_BLOK34_HORIZONTAL
			
			mov cx,BLOK34_X
			
			inc dx
			mov ax,dx
			sub ax,BLOK34_Y
			cmp ax,BLOK_HEIGHT
			jng DRAW_BLOK34_HORIZONTAL
			
			ret
	DRAW_BLOK34 ENDP
	
;-------------------platforma-------------
	DRAW_PLATFORMA PROC NEAR
		mov cx, PLATFORMA_X
		mov dx, PLATFORMA_Y
		
		DRAW_PLATFORMA_HORIZONTAL:
			mov ah,0Ch
			mov al,01h
			mov bh,00h
			int 10h
				
			inc cx 
			mov ax,cx
			sub ax,PLATFORMA_X
			cmp ax,PLATFORMA_WIDTH
			jng DRAW_PLATFORMA_HORIZONTAL
			
			mov cx,PLATFORMA_X
			
			inc dx
			mov ax,dx
			sub ax,PLATFORMA_Y
			cmp ax,PLATFORMA_HEIGHT
			jng DRAW_PLATFORMA_HORIZONTAL
		ret
			
			
	DRAW_PLATFORMA ENDP
	
	
	DRAW_SCORE proc near
		mov ah,02h
		mov bh,00h
		mov dh,00h  ;Y
		mov dl,26h	;X
		int 10h
		mov ah,0eh
		mov al,byte ptr poeni
		and al,0f0h
		mov cl,4
		shr al,cl
		add al,48d
		mov bl,0fh 
		int 10h
		mov al,byte ptr poeni
		and al,0fh
		add al,48d
		int 10h
		ret
	DRAW_SCORE endp
	
	MOVE_PLATFORMA PROC NEAR
		mov ah,01h
			int 16h
			jz bez_pomeranja
			mov ah,00h
			int 16h
			cmp ah,4Bh
			je left
			cmp ah,4Dh
			je right
			
		bez_pomeranja:
			add PLATFORMA_X, 0h
			ret

		left:
			mov ax, PLATFORMA_X
			cmp ax, 0
			jle krajl
			dec PLATFORMA_X
			
			mov ax, PLATFORMA_X
			cmp ax, 0
			jle krajl
			dec PLATFORMA_X
			
			mov ax, PLATFORMA_X
			cmp ax, 0
			jle krajl
			dec PLATFORMA_X
			
			mov ax, PLATFORMA_X
			cmp ax, 0
			jle krajl
			dec PLATFORMA_X
			
			mov ax, PLATFORMA_X
			cmp ax, 0
			jle krajl
			dec PLATFORMA_X
		krajl:
			ret
			
		right:
			mov ax, PLATFORMA_X
			add ax, PLATFORMA_WIDTH
			cmp ax, WINDOW_WIDTH
			jge krajd
			inc PLATFORMA_X
			
			mov ax, PLATFORMA_X
			add ax, PLATFORMA_WIDTH
			cmp ax, WINDOW_WIDTH
			jge krajd
			inc PLATFORMA_X
			
			mov ax, PLATFORMA_X
			add ax, PLATFORMA_WIDTH
			cmp ax, WINDOW_WIDTH
			jge krajd
			inc PLATFORMA_X
			
			mov ax, PLATFORMA_X
			add ax, PLATFORMA_WIDTH
			cmp ax, WINDOW_WIDTH
			jge krajd
			inc PLATFORMA_X
			
		krajd:
			dec PLATFORMA_X
			ret
			
	MOVE_PLATFORMA ENDP
	
	CLEAR_SCREEN PROC NEAR
			mov ah,00h ; postaviti konfiguraciju za video mod
			mov al,13h ;
			int 10h    ; izvrsi konfiguraciju
		
			mov ah,0bh ; postavi konfiguraciju  za boju pozadine
			mov bh,00h ;
			mov bl,00h ; boja pozadine = crna
			int 10h    ; izvrsi konfiguraciju
			
			ret
	CLEAR_SCREEN ENDP

kraj:   	
		call CLEAR_SCREEN
		mov ah,02h   
		mov bh,00h
		mov dh,0Bh	 ;y
		mov dl,04h	;x 
		int 10h
		
		cmp poeni, 24h
		jne game_over
		lea dx, printt
		jmp ispis
	game_over:	
		lea dx,print
	ispis:
		mov ah,09h
		int 21h
		
		exit:
		mov ah,00h
		int 16h
		cmp al,27
		jne exit
		mov ax, 4c00h		 
		int 21h
		
cseg 	ends

sseg segment stack 'STACK' 
     dw 64 dup(?)
sseg ends

end draw
