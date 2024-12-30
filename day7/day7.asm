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

	.equ resx,  0x59
	.equ res1y, 0x30
	.equ res2y, 0x58
	.equ res1p, 0x1000
	.equ res2p, 0x2000

	.equ res1b, interam+32
	.equ res1d, interam+48
	.equ res2b, interam+64
	.equ res2d, interam+80


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

	ldr r1,Tilemap2Addr
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

	mov r4, #0x4000000
	add r4, r4, #0x10
	mov r2, #0
	strh r2, [r4]

	bl SolveDay
	
	mov r4, #0x4000000
	add r4, r4, #0x10
	mov r2, #256
	strh r2, [r4]

	b forever

	.align 4
framecnt:
	.long interam+0
ISR_PTR:
	.long 0x03007FFC
ISR_HNLD:
	.long interrupt_handler
PalettesAddr:
	.long Palettes
TilemapAddr:
	.long Tilemap
Tilemap2Addr:
	.long Tilemap2
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
		mov r6, #15
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
	
	mov r6, #15
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
	mov r3, #0
	ldr r1, Result1Addr
	ldr r2, Result2Addr

	str r0, [r1,r3]
	str r0, [r2,r3]
	mov r3, #4
	str r0, [r1,r3]
	str r0, [r2,r3]
		
	LDMFD sp!,{r0-r12, pc}	

dubdab:
	STMFD sp!, {r0-r12, lr}
	mov r7, #15
	mov r3, #7
	mov r2, #3
	mov r1, #0
	ldr r0, [r9, r3]
	cmp r0, #0
	beq skiphigh
highloop:
	ldrb r0, [r9, r3]
	mov r1, r1, lsl #8
	add r1, r1, r0
	sub r3, r3, #1
	cmp r3, r2
	bne highloop
	bl pushbits

skiphigh:
	mov r3, r2
	mov r1, #0
lowloop:
	ldrb r0, [r9, r3]
	mov r1, r1, lsl #8
	add r1, r1, r0
	subs r3, r3, #1
	bpl lowloop
	bl pushbits
	b exitdubdab

pushbits:
	mov r11, r14
	mov r4, #31
	mov r3, #0
bitloop:
	movs r1, r1, lsl #1
	mov r6, #0
	adc r6, r6, #0
	bl dubdabroll
	add r3, r3, #1
	cmp r3, #3
	subeq r7, r7, #1
	moveq r3, #0
	subs r4, r4, #1
	bpl bitloop
	mov r14, r11
	bx lr

exitdubdab:
	LDMFD sp!, {r0-r12, pc}

dubdabroll:
	STMFD sp!, {r0-r12, lr}
	mov r10, #15
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
	cmp r10, r7
	beq exitrolloop
	subs r10, r10, #1
	bpl rolloop
exitrolloop:
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
ascinum:
	.long interam+2
leftdec:
	.long interam+3
leftb:
	.long interam+20
valarr:
	.long interam+112
bcdnum:
	.long interam+176
onecon:
	.long interam+208
ascilens:
	.long interam+224

	.align 4
SolveDay:
	STMFD sp!, {r0-r12, lr}

	ldr r8, inputAddr ; our read pointer
	ldr r9, input_endAddr

	mov r1, #0
	ldr r0, ascinum
	strb r1, [r0]
	ldr r0, valarr
	strw r1, [r0]

readloop:
	cmp r8, r9 ; if it is greater or equal, we are at the end
	bge finishday

	ldrb r0, [r8]
	cmp r0, #0x0A
	beq convertval
	cmp r0, #0x20
	beq convertval
	cmp r0, #0x3A
	beq convertleft

	and r0, r0, #0x0F
	ldr r3, ascinum
	ldrb r2, [r3]
	add r2, r2, #1
	strb r0, [r3, r2]
	strb r2, [r3]

incoffset:
	add r8, r8, #1
	b readloop

convertleft:
	bl getleftbin
	add r8, r8, #1
	b incoffset

convertval:
	ldr r3, ascinum
	ldrb r2, [r3]
	cmp r2, #0
	beq incoffset ; probably end of input

	mov r7, #0
	mov r5, #1
	mov r6, #10
loopconv:
	ldrb r4, [r3, r2]
	mul r1, r4, r5
	add r7, r7, r1
	mul r1, r5, r6
	mov r5, r1
	subs r2, r2, #1
	bne loopconv

	mov r5, #2
	ldr r3, valarr
	ldrh r2, [r3]
	add r2, r2, #1
	mul r4, r2, r5
	strh r7, [r3, r4]
	strh r2, [r3]

	bl storeasci

	cmp r0, #0x20
	beq incoffset
	
	mov r0, #0
	; branch to evaluate the line
	bl silversolver
	cmp r0, #1
	blne goldsolver

	; prepare for next line
	mov r2, #0
	strh r2, [r3]
	b incoffset

finishday:
	LDMFD sp!, {r0-r12, pc}

storeasci:
	STMFD sp!, {r0-r12, lr}
	ldr r8, ascinum
	ldr r5, ascilens
	
	ldrb r3, [r8] ; store asci lengths in list at offset
	strb r3, [r5, r2]

	bl cleanascinum	

	LDMFD sp!, {r0-r12, pc}

bcdtobin:
	STMFD sp!, {r0-r4,r7-r12, lr}
	ldr r8, ascinum
	ldrb r9, [r8]
	mov r10, #1
	mov r4, #10
	mov r12, #9 ; maximum 32bit
	mov r5, #0
	mov r6, #0
looplowmul:
	ldrb r0, [r8, r9]
	mul r1, r0, r10
	add r5, r5, r1
	subs r9, r9, #1
	beq exitbcdtobin
	subs r12, r12, #1
	mulne r1, r10, r4
	movne r10, r1
	bne looplowmul

	; if we make it here, we need to do umull
	mov r11, #0
loophimul:
	mul r1, r4, r11 ; 64bit multiply
	mov r11, r1
	umull r0, r1, r4, r10
	mov r10, r0
	add r11, r11, r1

	ldrb r0, [r8, r9]
	mul r3, r0, r11 ; 64bit multiply
	umull r2, r1, r0, r10
	add r3, r3, r1
	adds r5, r5, r2
	adc r6, r6, r3

	subs r9, r9, #1
	bne loophimul
exitbcdtobin:
	strb r9, [r8]

	LDMFD sp!, {r0-r4,r7-r12, pc}

getleftbin:
	STMFD sp!, {r0-r12, lr}

	bl bcdtobin
	mov r4, #0
	ldr r8, leftb
; bottom half of the 64 bit number
	str r5, [r8, r4]
	mov r4, #4
; top half of the number
	str r6, [r8, r4]

	LDMFD sp!, {r0-r12, pc}

silversolver:
	STMFD sp!, {r1-r12, lr}
	mov r12, r13
	ldr r3, valarr ; set up initial value
	mov r2, #2
	ldrh r5, [r3, r2]
	mov r6, #0
	ldrh r7, [r3] ; set up initial value, len of vals
	mov r2, #1
	bl recurse
	mov r0, #0
exitsolver:
	mov r13, r12
	LDMFD sp!, {r1-r12, pc}

; we're going to only copy four registers per level
; of recursion, and jump to exitsolver to invalidate
; the stack
recurse:
	STMFD sp!, {r0-r6, lr}
	mov r4, #2
	add r2, r2, #1
	mul r10, r2, r4
	mov r0, r5 ; the "present" state of r0, r1
	mov r1, r6
	ldrh r4, [r3, r10]

	adds r5, r0, r4 ; 64bit add
	adc r6, r1, #0

	cmp r2, r7
	bleq silvercheck ; if the last val check
	bl overcheck
	cmp r11, #1
	beq skiptosmul
	cmp r2, r7
	blne recurse ; otherwise recurse
skiptosmul:
	mul r6, r1, r4 ; 64bit multiply
	umull r5, r9, r0, r4
	add r6, r6, r9

	cmp r2, r7
	bleq silvercheck
	bl overcheck
	cmp r11, #1
	beq skiptosend
	cmp r2, r7
	blne recurse
skiptosend:
	LDMFD sp!, {r0-r6, pc}

silvercheck:
	STMFD sp!, {lr}
	
	mov r10, #0
	ldr r8, leftb
	ldr r9, [r8, r10]
	cmp r5, r9
	bne exitsilvercheck
	mov r10, #4
	ldr r9, [r8, r10]
	cmp r6, r9
	bne exitsilvercheck
	
	mov r10, #0
	ldr r8, Res1Addr
	ldr r9, [r8, r10]
	adds r9, r9, r5
	str r9, [r8, r10]
	mov r10, #4
	ldr r9, [r8, r10]
	adc r9, r9, r6
	str r9, [r8, r10]
	; if silver solves, add to gold
	; only run gold check if silver doesn't solve
	mov r10, #0
	ldr r8, Res2Addr
	ldr r9, [r8, r10]
	adds r9, r9, r5
	str r9, [r8, r10]
	mov r10, #4
	ldr r9, [r8, r10]
	adc r9, r9, r6
	str r9, [r8, r10]
	mov r0, #1
	
	bl enableinterrupt
	b exitsolver ; jump out of solver, invalidate stack

exitsilvercheck:
	LDMFD sp!, {pc}

overcheck:
	STMFD sp!, {lr}
	mov r11, #0

	mov r10, #4
	ldr r8, leftb
	ldr r9, [r8, r10]
	cmp r6, r9
	bhi overit
	blo notover
	mov r10, #0
	ldr r9, [r8, r10]
	cmp r5, r9
	bls notover
overit:
	mov r11, #1
notover:
	LDMFD sp!, {pc}

	
goldsolver:
	STMFD sp!, {r0-r12, lr}
	mov r12, r13
	ldr r3, valarr ; set up initial value
	mov r2, #2
	ldrh r5, [r3, r2]
	mov r6, #0
	ldrh r7, [r3] ; set up initial value, len of vals
	mov r2, #1
	bl goldrecurse
	
exitgoldsolver:
	mov r13, r12
	LDMFD sp!, {r0-r12, pc}

; we're going to only copy four registers per level
; of recursion, and jump to exitsolver to invalidate
; the stack
goldrecurse:
	STMFD sp!, {r0-r6, lr}
	mov r4, #2
	add r2, r2, #1
	mul r10, r2, r4
	mov r0, r5 ; the "present" state of r0, r1
	mov r1, r6
	ldrh r4, [r3, r10]

	bl concatnums
	
	cmp r2, r7
	bleq goldcheck
	bl overcheck
	cmp r11, #1
	beq skiptogmul
	cmp r2, r7
	blne goldrecurse

skiptogmul:
	mul r6, r1, r4 ; 64bit multiply
	umull r5, r9, r0, r4
	add r6, r6, r9

	cmp r2, r7
	bleq goldcheck
	bl overcheck
	cmp r11, #1
	beq skiptogadd
	cmp r2, r7
	blne goldrecurse
	
skiptogadd:
	adds r5, r0, r4 ; 64bit add
	adc r6, r1, #0

	cmp r2, r7
	bleq goldcheck ; if the last val check
	bl overcheck
	cmp r11, #1
	beq skiptogend
	cmp r2, r7
	blne goldrecurse ; otherwise recurse
	
skiptogend:
	LDMFD sp!, {r0-r6, pc}

goldcheck:
	STMFD sp!, {lr}
	
	mov r10, #0
	ldr r8, leftb
	ldr r9, [r8, r10]
	cmp r5, r9
	bne exitgoldcheck
	mov r10, #4
	ldr r9, [r8, r10]
	cmp r6, r9
	bne exitgoldcheck
	
	mov r10, #0
	ldr r8, Res2Addr
	ldr r9, [r8, r10]
	adds r9, r9, r5
	str r9, [r8, r10]
	mov r10, #4
	ldr r9, [r8, r10]
	adc r9, r9, r6
	str r9, [r8, r10]

	bl enableinterrupt
	b exitgoldsolver ; jump out of solver, invalidate stack

exitgoldcheck:
	LDMFD sp!, {pc}

concatnums:
	STMFD sp!, {r0-r4,r7-r12, lr}
	mov r9, #10
	mov r10, #1

	ldr r8, ascilens
	ldrb r7, [r8, r2]
	
makemul:
	mul r3, r10, r9
	mov r10, r3
	subs r7, r7, #1
	bne makemul

doconcat:
	mul r6, r1, r10 ; 64bit multiply
	umull r5, r9, r0, r10
	add r6, r6, r9

	adds r5, r5, r4
	adc r6, r6, #0

	LDMFD sp!, {r0-r4,r7-r12, pc}

cleanascinum:
	STMFD sp!, {r0-r2, lr}
	mov r2, #0
	mov r1, #16
cleanloop:
	strb r2, [r8, r1]
	subs r1, r1, #1
	bpl cleanloop

	LDMFD sp!, {r0-r2, pc}


inputAddr:
	.long input
input_endAddr:
	.long input_end
	

	.align 4
 ; append the input last because.... reasons?
input:
	.incbin "input7.txt"
input_end:

