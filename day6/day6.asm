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
bl enableinterrupt

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

	str r0, [r1]
	str r0, [r2]
		
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
	
	mov r0, #0x04000004
	mov r1, #0
	strh r1, [r0]
exitinterrupt:
	LDMFD sp!, {r0-r12, pc}

enableinterrupt:
	STMFD sp!, {r0-r1, lr}
	
	mov r0, #0x04000004
	mov r1, #0x08
	strh r1, [r0]

	LDMFD sp!, {r0-r1, pc}

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
gridwidth:
	.long interam+8
gridmem:
	.long interam+160
testpath:
	.long interam+17408
	

	.align 4
SolveDay:
	STMFD sp!, {r0-r12, lr}

	ldr r8, inputAddr ; our read pointer
	ldr r9, input_endAddr
	mov r10, #0
	sub r1, r9, r8
	ldr r2, gridmem
copyloop:
	ldrb r0, [r8, r10]
	strb r0, [r2, r10]
	add r10, r10, #1
	cmp r10, r1
	bne copyloop
	
	ldr r8, gridmem
	mov r7, r8
	add r9, r8, r10

	mov r10, #0
	ldr r5, gridwidth
	str r10, [r5]
findwidth:
	ldrb r0, [r8, r10]
	cmp r0, #0x0A
	add r10, r10, #1
	bne findwidth
	str r10, [r5]
	
findstart:
	ldrb r0, [r8, r10]
	cmp r0, #0x5E
	addne r10, r10, #1
	bne findstart
	
	add r8, r8, r10
	mov r3, #0x58
	strb r3, [r8]
	
	; ready to start moving
	mov r6, #0 ; direction- 0N, 1W, 2S, 3E
	ldr r1, [r5]
loopgrid:
	cmp r6, #0
	subeq r10, r8, r1
	cmp r6, #1
	addeq r10, r8, #1
	cmp r6, #2
	addeq r10, r8, r1
	cmp r6, #3
	subeq r10, r8, #1

	bl goldeval ; look for potential loop
	
	ldrb r0, [r10]
	bl boundscheck
	cmp r2, #1
	beq finishday

	cmp r0, #0x23
	beq doturn
	mov r8, r10
	bl addpath	
	b loopgrid

doturn:
	add r6, r6, #1
	cmp r6, #4
	moveq r6, #0
	b loopgrid

finishday:
	ldr r4, Res1Addr
	ldr r3, [r4]
	add r3, r3, #1
	str r3, [r4]
	
	LDMFD sp!, {r0-r12, pc}

boundscheck: ; r2 returns if in bounds
	mov r2, #0
	cmp r0, #0x0A ; /n means side bound
	moveq r2, #1
	bxeq lr

	cmp r10, r7 ; upper bound
	movlt r2, #1
	bxlt lr

	cmp r10, r9 ; lower bound
	movge r2, #1
	bxge lr

	bx lr	
	
addpath:
	STMFD sp!, {r0-r12, lr}
	
	ldrb r1, [r8]
	cmp r1, #0x58
	beq exitaddpath

	mov r1, #0x58
	strb r1, [r8]
	ldr r4, Res1Addr
	ldr r3, [r4]
	add r3, r3, #1
	str r3, [r4]
	bl enableinterrupt
exitaddpath:
	LDMFD sp!, {r0-r12, pc}

goldeval:
	STMFD sp!, {r0-r12, lr}
	mov r5, #4
	; if its a brick, abort
	ldrb r0, [r10]
	cmp r0, #0x23
	beq exitgoldtest

	; if it is out of bounds, abort
	mov r11, r8
	mov r8, r10
	bl boundscheck
	cmp r2, #1
	beq exitgoldtest
	mov r8, r11

	; check if in paths
	bl inpathchk
	cmp r2, #1
	beq exitgoldtest

	mov r11, r10 ; actual position of potential obstruction
	mov r12, r8, lsl #2
	add r12, r12, r6 ; combined position+direction
	ldr r4, testpath
	mov r3, #1
	mul r2, r3, r5
	str r12, [r4, r2]
	str r3, [r4]
	
	add r6, r6, #1
	cmp r6, #4
	moveq r6, #0

	mov r10, r8
testloop:
	ldr r0, gridwidth
	ldr r1, [r0]
	cmp r6, #0
	subeq r10, r8, r1
	cmp r6, #1
	addeq r10, r8, #1
	cmp r6, #2
	addeq r10, r8, r1
	cmp r6, #3
	subeq r10, r8, #1
	
	ldrb r0, [r10]
	bl boundscheck
	cmp r2, #1
	beq exitgoldtest

	cmp r0, #0x23
	beq dogoldturn
	cmp r10, r11 ; hitting the obstruction again
	beq dogoldturn
	mov r8, r10
	b testloop

dogoldturn:
	bl testpathchk
	cmp r2, #1
	beq exitgoldtest
	
	add r6, r6, #1
	cmp r6, #4
	moveq r6, #0
	b testloop

exitgoldtest:
	LDMFD sp!, {r0-r12, pc}

inpathchk:
	mov r0, r14
	mov r2, #0
	ldrb r4, [r10]
	cmp r4, #0x58
	bne exitpathchk
	mov r2, #1
exitpathchk:
	mov r14, r0
	bx lr

testpathchk:
	mov r0, r14
	mov r12, r8, lsl #2
	add r12, r12, r6 ; combined position+direction
	ldr r4, testpath
	ldr r3, [r4]
	cmp r3, #0
	beq addtotest
looptestpath:
	mul r2, r3, r5
	ldr r1, [r4, r2]
	cmp r1, r12
	beq addgold
	subs r3, r3, #1
	bne looptestpath
addtotest:	
	ldr r3, [r4]
	add r3, r3, #1
	mul r2, r3, r5
	str r12, [r4, r2]
	str r3, [r4]
	b exittestpath

addgold:
	ldr r4, Res2Addr
	ldr r3, [r4]
	add r3, r3, #1
	str r3, [r4]	
	mov r2, #1
	bl enableinterrupt
exittestpath:
	mov r14, r0
	bx lr

inputAddr:
	.long input
input_endAddr:
	.long input_end
	

	.align 4
 ; append the input last because.... reasons?
input:
	.incbin "input6.txt"
input_end:

