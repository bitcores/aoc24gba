	;.arm                 ; Use arm instruction set.
    ; header...
    .org  0x08000000     ; GBA ROM Address starts at 0x08000000       
	.equ ProgBase,0;0x08000000
    ;.section text			

	.equ exteram, 0x02000000
	.equ interam, 0x03000000
	
	.equ MonitorWidth, 6
 
;000h    4     ROM Entry Point  (32bit ARM branch opcode, eg. "B rom_start") 
    b	GbaStart

	.equ DMA3SAD, 0x40000D4
	.equ DMA3DAD, 0x40000D8
	.equ DMA3CNT_L, 0x40000DC
	.equ DMA3CNT_H, 0x40000DE

	.equ resx,  0x71
	.equ res1y, 0x30
	.equ res2y, 0x58
	.equ res1p, 0x1000
	.equ res2p, 0x2000

	.equ res1b, interam+100
	.equ res1d, interam+105
	.equ res2b, interam+116
	.equ res2d, interam+120


; GBA header data is defined in this file
	.include "gbaheader.asm"
	
	
GbaStart:

	mov sp,#0x03000000			;Init Stack Pointer

		
;GameBoy Advance

	;4000000h - DISPCNT - LCD Control (Read/Write)
		;Bit   Expl.
		;0-2   BG Mode                (0-5=Video Mode 0-5, 6-7=Prohibited)
		;3     Reserved / CGB Mode    (0=GBA, 1=CGB; can be set only by BIOS opcodes)
		;4     Display Frame Select   (0-1=Frame 0-1) (for BG Modes 4,5 only)
		;5     H-Blank Interval Free  (1=Allow access to OAM during H-Blank)
		;6     OBJ Character VRAM Mapping (0=Two dimensional, 1=One dimensional)
		;7     Forced Blank           (1=Allow FAST access to VRAM,Palette,OAM)
		;8     Screen Display BG0  (0=Off, 1=On)
		;9     Screen Display BG1  (0=Off, 1=On)
		;10    Screen Display BG2  (0=Off, 1=On)
		;11    Screen Display BG3  (0=Off, 1=On)
		;12    Screen Display OBJ  (0=Off, 1=On)
		;13    Window 0 Display Flag   (0=Off, 1=On)
		;14    Window 1 Display Flag   (0=Off, 1=On)
		;15    OBJ Window Display Flag (0=Off, 1=On)
 
	mov r4,#0x04000000  ;4000000h - DISPCNT - LCD Control (Read/Write)
	mov r2,#0x400 		;1= Layer 0 on / 0= ScreenMode 0
	str	r2,[r4]         			

		
;4000008h - BG0CNT - BG0 Control (R/W) (BG Modes 0,1 only)	
	;Bit   Expl.
	;0-1   BG Priority           (0-3, 0=Highest)
	;2-3   Character Base Block  (0-3, in units of 16 KBytes) (=BG Tile Data)
	;4-5   Not used (must be zero) (except in NDS mode: MSBs of char base)
	;6     Mosaic                (0=Disable, 1=Enable)
	;7     Colors/Palettes       (0=16/16, 1=256/1)
	;8-12  Screen Base Block     (0-31, in units of 2 KBytes) (=BG Map Data)
	;13    BG0/BG1: Not used (except in NDS mode: Ext Palette Slot for BG0/BG1)
	;13    BG2/BG3: Display Area Overflow (0=Transparent, 1=Wraparound)
	;14-15 Screen Size (0-3)

	
	mov r4,#0x04000000 	;4000008h - BG0CNT - BG0 Control (R/W) (BG Modes 0,1 only)
	add r4,r4,#0x08
	
	mov r2,#0x4004   		;$---4 = Patten Base address=0x06004000 	
	str	r2,[r4]    		;$4--- = ScreenSize=64x32 tilemap

	; set up vblank interrupt
	ldr r0, ISR_HNLD
	ldr r1, ISR_PTR
	str r0, [r1]

	mov r0, #0x04000004
	mov r1, #0x08
	strh r1, [r0]

	mov r0, #0x04000200
	mov r1, #0x01
	strh r1, [r0]

	mov r0, #0x04000208
	mov r1, #0x01
	strh r1, [r0]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	ldr r1,PalettesAddr			;Define palettes
	mov r2,#0x05000000			;-BBBBBGGGGGRRRRR
	mov r3,#16*2			;2 bytes per color
	bl LDIR16

	ldr r1,ChartilesAddr		;Define Tilepatterns
	mov r2,#0x06004000
	mov r3,#Chartiles_end-Chartiles
	bl LDIR16
	
	ldr r1,TilemapAddr			;PPPPVHTTTTTTTTTT
								;P=Palette HV=HV flip T=Tilenum	
	mov r2,#0x06000000		;SC0 (32x32 Left Tiles)
	mov r3,#32*20*2			;2 bytes per tile
	bl LDIR16

	ldr r1,TilemapAddr
	mov r2,#0x06000800		;SC1 (32x32 Right Tiles)
	mov r3,#32*20*2			;2 bytes per tile
	bl LDIR16
	
 ;; load sprites
	ldr r1,PalettesAddr
	mov r2,#0x05000200			;Sprite Palettes
	mov r3,#48*2
	bl LDIR16
	
	ldr r1,ChartilesAddr
	mov r2,#0x06010000		;Sprite Pattern Ram
	mov r3,#Chartiles_end-Chartiles
	bl LDIR16					;Transfer Sprite patterns to Vram
	
	mov r4,#0x04000000  ;DISPCNT -LCD Control
	mov r2,#0x1140    	;1= Sprite on / 1= Layer 0 on / 4= 1D Tile layout 
	str	r2,[r4]         	;0= ScreenMode 0 

bl clearresults
bl cleardecimal

forever:
	bl Readbutton 
	bl clearresults
	bl SolveDay

	b forever

	.align 4
ISR_PTR:
	.long 0x03007FFC
ISR_HNLD:
	.long interrupt_handler
PalettesAddr:
	.long Palettes
TilemapAddr:
	.long Tilemap
ChartilesAddr:
	.long Chartiles
Chartiles_endAddr:
	.long Chartiles_end

ReadButton:
	STMFD sp!, {r0-r12, lr}
	mov r1, #1
	waitRelease:
		;bl Callupdate

		mov r3, #0x4000130
		ldrh r2,[r3]
		and r2, r2, #1
		cmp r2, #0  ; test if A button pressed
		beq setflag
		cmp r1, #1
		beq waitRelease
		b exitbutton

	setflag:
		mov r1, #0
		b waitRelease
	exitbutton:
	LDMFD sp!, {r0-r12, pc}


CallUpdate:
	STMFD sp!,{r0-r12, lr}

	bl cleardecimal
	
	mov r0, #0
	ldr r9, Result1Addr
	ldr r8, Result1DecAddr
	bl dubdab
	mov r9, #res1y
	mov r10, #res1p
	bl UpdateOutput

	ldr r9, Result2Addr
	ldr r8, Result2DecAddr
	bl dubdab
	mov r9, #res2y
	mov r10, #res2p
	bl UpdateOutput

exitupdate:
	LDMFD sp!,{r0-r12, pc}	

UpdateOutput:
	STMFD sp!,{r1-r10, lr}
		mov r6, #9
		mov r5, #8
	loopout:	
		;mov r0, r6	   		;Sprite Num
		;S=Shape (Square /HRect / Vrect)  C=Colors(16/256)  M=Mosiac  
		;T=Transparent  D=Disable/Doublesize  R=Rotation  Y=Ypos
					; SSCMTTDRYYYYYYYY
		mov r1, r9		
			
		;S=Obj Size  VH=V/HFlip  R=Rotation parameter  X=Xpos
					; SSVHRRRXXXXXXXXX
		mul r2, r6, r5
		add r2, r2, #resx 
		
		;C=Color palette   P=Priority   T=Tile Number
			; CCCCPPTTTTTTTTTT
	   	ldrb r4, [r8, r6]
		add r4, r4, #0x10
		mov r3, r10
		add r3, r3, r4
		bl SetSprite

		add r0, r0, #1
		subs r6, r6, #1
		bpl loopout

	LDMFD sp!,{r1-r10, pc}	

Result1Addr:
	.long res1b
Result2Addr:
	.long res2b
Result1DecAddr:
	.long res1d
Result2DecAddr:
	.long res2d
ascinump:
	.long interam+8
	
SetSprite:	;Set Sprite R0... Set Attribute words 1,2,3 to R1,R2,R3
	STMFD sp!,{r0-r12, lr}
	
		mov r4,#0x07000000  	;Sprite (OAM) settings
		add r4,r4,r0,asl #3		;8 bytes per sprite (6 used)	
		
		;S=Shape (Square /HRect / Vrect)  C=Colors(16/256)  M=Mosiac  
		;T=Transparent  D=Disable/Doublesize  R=Rotation  Y=Ypos
		strH	r1,[r4]    		;1st attrib - SSCMTTDRYYYYYYYY
			
		add r4,r4,#2
		
		;S=Obj Size  VH=V/HFlip  R=Rotation parameter  X=Xpos
		strH	r2,[r4]    		;2nd attrib - SSVHRRRXXXXXXXXX
		
		add r4,r4,#2
		
		;C=Color palette   P=Priority   T=Tile Number
		strH	r3,[r4]    		;3rd attrib - CCCCPPTTTTTTTTTT
	
	LDMFD sp!,{r0-r12, pc}	
		
		
cleardecimal:
	STMFD sp!,{r0-r12, lr}
	
	mov r6, #9
	mov r0, #0
	ldr r1, Result1DecAddr
	ldr r2, Result2DecAddr
clearloop:
	strb r0, [r1, r6]
	strb r0, [r2, r6]
	subs r6, r6, #1
	bpl clearloop
		
	LDMFD sp!,{r0-r12, pc}	

clearresults:
	STMFD sp!,{r0-r12, lr}

	mov r0, #0
	ldr r1, Result1Addr
	ldr r2, Result2Addr
	ldr r3, ascinump

	str r0, [r1]
	str r0, [r2]
	str r0, [r3]
		
	LDMFD sp!,{r0-r12, pc}	

dubdab:
	STMFD sp!, {r0-r12, lr}
	mov r3, #3
	mov r1, #0
byteloop:
	ldrb r0, [r9, r3]
	mov r1, r1, lsl #8
	add r1, r1, r0
	subs r3, r3, #1
	bpl byteloop

	mov r4, #31
bitloop:
	movs r1, r1, lsl #1
	mov r6, #0
	adc r6, r6, #0

	bl dubdabroll

	subs r4, r4, #1
	bpl bitloop

	LDMFD sp!, {r0-r12, pc}

dubdabroll:
	STMFD sp!, {r0-r12, lr}
	mov r10, #9
rolloop:
	ldrb r1, [r8, r10]
	and r3, r1, #0x0F
	cmp r3, #5
	addge r1, r1, #3
	mov r2, r1, lsl #1
	add r2, r2, r6
	mov r6, #0
	tst r2, #0x10
	andne r2, r2, #0x0F
	movne r6, #1
	strb r2, [r8, r10]

	subs r10, r10, #1
	bpl rolloop

	LDMFD sp!, {r0-r12, pc}


	.align 4
LDIR16:			;Transfer R3 bytes from [R1] to [R2]
	STMFD sp!,{r0-r12, lr}
LDIR16B:	
		ldrH r5,[r1],#2
		strH r5,[r2],#2	
		
		subs r3, r3, #2		
		bne LDIR16B	
	LDMFD sp!,{r0-r12, pc}
	
interrupt_handler:
	STMFD sp!, {r0-r12, lr}
	
	mov r0, #0x04000202
	ldrh r1, [r0]
	tst r1, #0x01
	beq exitinterrupt

	bl CallUpdate

	mov r1, #0x01
	strh r1, [r0]

exitinterrupt:
	LDMFD sp!, {r0-r12, pc}


	.align 4
Chartiles: 
	.incbin "textchars.bin"
Chartiles_end:

	.align 4
 ; include the background map
	.include "background.asm"

Res1Addr:
	.long res1b
Res2Addr:
	.long res2b
ascinum:
	.long interam+8
xnum:
	.long interam+20
ynum:
	.long interam+24
mulcomp:
	.long 0x286C756D
docomp:
	.long 0x29286F64
dontone:
	.long 0x276E6F64
dontwo:
	.long 0x29287427

	.align 4
SolveDay:
	STMFD sp!, {r0-r12, lr}

	ldr r8, inputAddr
	ldr r9, input_endAddr
	; if we are within 4 bytes of the end, no more data
	sub r9, r9, #4
	
	; if we are adding to part 2
	mov r11, #1
	mov r4, #0

readloop:
	cmp r8, r9 ; if it is equal, we are at the end
	bge finishday
	
	mov r1, #0
	mov r5, #3
getfour:
	mov r1, r1, lsl #8
	ldrb r0, [r8, r5]
	add r1, r1, r0
	subs r5, r5, #1
	bpl getfour
	
	cmp r4, #1
	bne skipdont
	mov r4, #0
	ldr r2, dontwo
	cmp r1, r2
	moveq r11, #0
	beq incoffset
	
skipdont:
	ldr r2, docomp
	cmp r1, r2
	moveq r11, #1
	beq incoffset
	
	ldr r2, dontone
	cmp r1, r2
	bne trymul
	add r8, r8, #3
	mov r4, #1
	b readloop
	
trymul:
	; see if r1 contains "mul("
	ldr r2, mulcomp
	cmp r1, r2
	bleq evalmul
		
incoffset:
	add r8, r8, #1
	b readloop

finishday:
	LDMFD sp!, {r0-r12, pc}


evalmul:
	STMFD sp!, {r0-r12, lr}
	mov r4, #0
	add r8, r8, #4
	
	ldr r6, ascinum
	strb r4, [r6]
	ldr r10, xnum
loopreadnums:
	ldrb r1, [r8]
	; if comma, check that it is valid left number (len 1-3)
	cmp r1, #0x2C
	beq checkvalsplit
	cmp r1, #0x29 ; if ) we might have second number
	beq checkvalend
	cmp r1, #0x30 ; if its an ascii char before 0 leave
	blt endevalmul
	cmp r1, #0x39 ; if its an ascii char after 9 leave
	bgt endevalmul
	
	ldrb r5, [r6]
	cmp r5, #3
	beq endevalmul
	add r5, r5, #1
	and r1, r1, #0x0F
	strb r1, [r6, r5]
	strb r5, [r6]
	
	add r8, r8, #1
	b loopreadnums

checkvalend:
	; if we aren't in second number, exit
	cmp r4, #1
	bne endevalmul
	b checkvalnum
checkvalsplit:
	cmp r4, #0
	bne endevalmul
checkvalnum:
	ldrb r5, [r6]
	cmp r5, #0 ; 0-len number, exit
	beq endevalmul
	
	; convert asci input and store
	bl convertasci
	str r0, [r10]

	; if r4 is #1 we have our two numbers to multiply
	cmp r4, #1
	beq domulnums
	mov r4, #1
	ldr r10, ynum
	add r8, r8, #1
	b loopreadnums
	
domulnums:
	ldr r5, xnum
	ldr r2, [r5]
	ldr r5, ynum
	ldr r1, [r5]
	mul r0, r1, r2

	; r0 has the val to add
	ldr r5, Res1Addr
	ldr r1, [r5]
	add r1, r0, r1
	str r1, [r5]

	cmp r11, #0
	beq endevalmul

	ldr r5, Res2Addr
	ldr r1, [r5]
	add r1, r0, r1
	str r1, [r5]

endevalmul:
	LDMFD sp!, {r0-r12, pc}
	

convertasci:
	STMFD sp!, {r1-r12, lr}
	; value of r0 will be the return number
	mov r0, #0
	mov r3, #1
	mov r4, #10
	ldr r6, ascinum
	ldrb r5, [r6]
loopconv:
	ldrb r2, [r6, r5]
	mul r1, r2, r3
	add r0, r0, r1
	mul r1, r3, r4
	mov r3, r1
	subs r5, r5, #1
	bne loopconv
	
	; reset the asci pointer
	strb r5, [r6]
	
	LDMFD sp!, {r1-r12, pc}

inputAddr:
	.long input
input_endAddr:
	.long input_end
	

	.align 4
 ; append the input last because.... reasons?
input:
	.incbin "input3.txt"
input_end:

