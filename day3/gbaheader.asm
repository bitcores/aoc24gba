;   this header actually works with my game cart	
;004h    156   Nintendo Logo    (compressed bitmap, required!)
	.byte 0x24,0xFF,0xAE,0x51,0x69,0x9A,0xA2,0x21,0x3D,0x84,0x82,0x0A,0x84,0xE4,0x09,0xAD     ; C
	.byte 0x11,0x24,0x8B,0x98,0xC0,0x81,0x7F,0x21,0xA3,0x52,0xBE,0x19,0x93,0x09,0xCE,0x20     ; D
    .byte 0x10,0x46,0x4A,0x4A,0xF8,0x27,0x31,0xEC,0x58,0xC7,0xE8,0x33,0x82,0xE3,0xCE,0xBF     ; E
    .byte 0x85,0xF4,0xDF,0x94,0xCE,0x4B,0x09,0xC1,0x94,0x56,0x8A,0xC0,0x13,0x72,0xA7,0xFC     ; F
    .byte 0x9F,0x84,0x4D,0x73,0xA3,0xCA,0x9A,0x61,0x58,0x97,0xA3,0x27,0xFC,0x03,0x98,0x76     ; 10
    .byte 0x23,0x1D,0xC7,0x61,0x03,0x04,0xAE,0x56,0xBF,0x38,0x84,0x00,0x40,0xA7,0x0E,0xFD     ; 11
    .byte 0xFF,0x52,0xFE,0x03,0x6F,0x95,0x30,0xF1,0x97,0xFB,0xC0,0x85,0x60,0xD6,0x80,0x25     ; 12
    .byte 0xA9,0x63,0xBE,0x03,0x01,0x4E,0x38,0xE2,0xF9,0xA2,0x34,0xFF,0xBB,0x3E,0x03,0x44     ; 13
    .byte 0x78,0x00,0x90,0xCB,0x88,0x11,0x3A,0x94,0x65,0xC0,0x7C,0x63,0x87,0xF0,0x3C,0xAF     ; 14
	.byte 0xD6,0x25,0xE4,0x8B,0x38,0x0A,0xAC,0x72,0x21,0xD4,0xF8,0x07,0x1A,0x9E,0x7B,0xEB     ; 15
	

;0A0h    12    Game Title       (uppercase ascii, max 12 characters)	
    ;		123456789012
    .ascii "LEARNASM.NET"
;0ACh    4     Game Code        (uppercase ascii, 4 characters)
	
    .ascii "0000"			;Code
;0B0h    2     Maker Code       (uppercase ascii, 2 characters)
    .byte "GB"				;Maker
;0B2h    1     Fixed value      (must be 96h, required!)
	.byte 0x96
;0B3h    1     Main unit code   (00h for current GBA models)
	.byte 0x00
;0B4h    1     Device type      (usually 00h) (bit7=DACS/debug related)
	.byte 0x00
;0B5h    7     Reserved Area    (should be zero filled)
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00
;0BCh    1     Software version (usually 00h)
	.byte 0x00
;0BDh    1     Complement check (header checksum, required!)
	.byte 0x00
;0BEh    2     Reserved Area    (should be zero filled)
	.byte 0x00,0x00
;0C0h    4     RAM Entry Point  (32bit ARM branch opcode, eg. "B ram_start")
	.byte 0x00,0x00,0x00,0x00
;0C4h    1     Boot mode        (init as 00h - BIOS overwrites this value!)
	.byte 0x00
;0C5h    1     Slave ID Number  (init as 00h - BIOS overwrites this value!)
	.byte 0x00
;0C6h    26    Not used         (seems to be unused)
	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;0E0h    4     JOYBUS Entry Pt. (32bit ARM branch opcode, eg. "B joy_start")
	.byte 0x00,0x00,0x00,0x00
