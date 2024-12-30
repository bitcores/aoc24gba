
 ;								D	A	Y			1
 ; screen is effectively 30x20, seeing we aren't scrolling we can just use that
Tilemap:	;Tile numbers 32*20 - PPPPVHTT,TTTTTTTT
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0x24,0x21,0x39,0,0,0x10,0x12,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0x30,0x21,0x32,0x34,0,0x11,0x1A,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0x30,0x21,0x32,0x34,0,0x12,0x1A,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	
 ; all the stupid palettes
Palettes:
    .word 0b0000000000000000; ;0  %-BBBBBGGGGGRRRRR
    .word 0b0010100101001010; ;1  %-BBBBBGGGGGRRRRR
    .word 0b0101011010110101; ;2  %-BBBBBGGGGGRRRRR
    .word 0b0111111111111111; ;3  %-BBBBBGGGGGRRRRR
    .word 0b0100000000000000; ;4  %-BBBBBGGGGGRRRRR
    .word 0b0100000000010000; ;5  %-BBBBBGGGGGRRRRR
    .word 0b0100001000000000; ;6  %-BBBBBGGGGGRRRRR
    .word 0b0100111110010011; ;7  %-BBBBBGGGGGRRRRR
    .word 0b0111110000010000; ;8  %-BBBBBGGGGGRRRRR
    .word 0b0000000000011111; ;9  %-BBBBBGGGGGRRRRR
    .word 0b0000001111100000; ;10  %-BBBBBGGGGGRRRRR
    .word 0b0000001111111111; ;11  %-BBBBBGGGGGRRRRR
    .word 0b0111110000000000; ;12  %-BBBBBGGGGGRRRRR
    .word 0b0111110000011111; ;13  %-BBBBBGGGGGRRRRR
    .word 0b0111111111100000; ;14  %-BBBBBGGGGGRRRRR
	.word 0b0111111111111111; ;15  %-BBBBBGGGGGRRRRR
	.word 0b0000000000000000; ;0  %-BBBBBGGGGGRRRRR
    .word 0b0010100101001010; ;1  %-BBBBBGGGGGRRRRR
	.word 0b0111111111111111; ;2  %-BBBBBGGGGGRRRRR
    .word 0b0101011010110101; ;3  %-BBBBBGGGGGRRRRR
    .word 0b0100000000000000; ;4  %-BBBBBGGGGGRRRRR
    .word 0b0100000000010000; ;5  %-BBBBBGGGGGRRRRR
    .word 0b0100001000000000; ;6  %-BBBBBGGGGGRRRRR
    .word 0b0100111110010011; ;7  %-BBBBBGGGGGRRRRR
    .word 0b0111110000010000; ;8  %-BBBBBGGGGGRRRRR
    .word 0b0000000000011111; ;9  %-BBBBBGGGGGRRRRR
    .word 0b0000001111100000; ;10  %-BBBBBGGGGGRRRRR
    .word 0b0000001111111111; ;11  %-BBBBBGGGGGRRRRR
    .word 0b0111110000000000; ;12  %-BBBBBGGGGGRRRRR
    .word 0b0111110000011111; ;13  %-BBBBBGGGGGRRRRR
    .word 0b0111111111100000; ;14  %-BBBBBGGGGGRRRRR
	.word 0b0111111111111111; ;15  %-BBBBBGGGGGRRRRR
	.word 0b0000000000000000; ;0  %-BBBBBGGGGGRRRRR
    .word 0b0010100101001010; ;1  %-BBBBBGGGGGRRRRR
	.word 0b0000001111100000; ;2  %-BBBBBGGGGGRRRRR
    .word 0b0101011010110101; ;3  %-BBBBBGGGGGRRRRR
    .word 0b0100000000000000; ;4  %-BBBBBGGGGGRRRRR
    .word 0b0100000000010000; ;5  %-BBBBBGGGGGRRRRR
    .word 0b0100001000000000; ;6  %-BBBBBGGGGGRRRRR
    .word 0b0100111110010011; ;7  %-BBBBBGGGGGRRRRR
    .word 0b0111110000010000; ;8  %-BBBBBGGGGGRRRRR
    .word 0b0000000000011111; ;9  %-BBBBBGGGGGRRRRR
    .word 0b0111111111111111; ;10  %-BBBBBGGGGGRRRRR
    .word 0b0000001111111111; ;11  %-BBBBBGGGGGRRRRR
    .word 0b0111110000000000; ;12  %-BBBBBGGGGGRRRRR
    .word 0b0111110000011111; ;13  %-BBBBBGGGGGRRRRR
    .word 0b0111111111100000; ;14  %-BBBBBGGGGGRRRRR
	.word 0b0111111111111111; ;15  %-BBBBBGGGGGRRRRR