;-----------------------------------------------
; pletter v0.5c msx unpacker
; call unpack with hl pointing to some pletter5 data, and de pointing to the destination.
; changes all registers

GETBIT:  MACRO 
  add a,a
  call z,pletter_getbit
  ENDM

GETBITEXX:  MACRO 
  add a,a
  call z,pletter_getbitexx
  ENDM

pletter_unpack:
  ld a,(hl)
  inc hl
  exx
  ld de,0
  add a,a
  inc a
  rl e
  add a,a
  rl e
  add a,a
  rl e
  rl e
  ld hl,pletter_modes
  add hl,de
  ld e,(hl)
  ld ixl,e
  inc hl
  ld e,(hl)
  ld ixh,e
  ld e,1
  exx
  ld iy,pletter_loop
pletter_literal:
  ldi
pletter_loop:
  GETBIT
  jr nc,pletter_literal
  exx
  ld h,d
  ld l,e
pletter_getlen:
  GETBITEXX
  jr nc,pletter_lenok
pletter_lus:
  GETBITEXX
  adc hl,hl
  ret c
  GETBITEXX
  jr nc,pletter_lenok
  GETBITEXX
  adc hl,hl
  ret c
  GETBITEXX
  jp c,pletter_lus
pletter_lenok:
  inc hl
  exx
  ld c,(hl)
  inc hl
  ld b,0
  bit 7,c
  jp z,pletter_offsok
  jp ix

pletter_mode6:
  GETBIT
  rl b
pletter_mode5:
  GETBIT
  rl b
pletter_mode4:
  GETBIT
  rl b
pletter_mode3:
  GETBIT
  rl b
pletter_mode2:
  GETBIT
  rl b
  GETBIT
  jr nc,pletter_offsok
  or a
  inc b
  res 7,c
pletter_offsok:
  inc bc
  push hl
  exx
  push hl
  exx
  ld l,e
  ld h,d
  sbc hl,bc
  pop bc
  ldir
  pop hl
  jp iy

pletter_getbit:
  ld a,(hl)
  inc hl
  rla
  ret

pletter_getbitexx:
  exx
  ld a,(hl)
  inc hl
  exx
  rla
  ret

pletter_modes:
  dw pletter_offsok
  dw pletter_mode2
  dw pletter_mode3
  dw pletter_mode4
  dw pletter_mode5
  dw pletter_mode6


before_atan_tab:
        ; align to byte        
        ; align #100
        ds ((($-1)/#100)+1)*#100-$
        
        ;;;;;;;; atan(2^(x/32))*128/pi ;;;;;;;;
atan_tab:   
        db #20,#20,#20,#21,#21,#22,#22,#23,#23,#23,#24,#24,#25,#25,#26,#26
        db #26,#27,#27,#28,#28,#28,#29,#29,#2A,#2A,#2A,#2B,#2B,#2C,#2C,#2C
        db #2D,#2D,#2D,#2E,#2E,#2E,#2F,#2F,#2F,#30,#30,#30,#31,#31,#31,#31
        db #32,#32,#32,#32,#33,#33,#33,#33,#34,#34,#34,#34,#35,#35,#35,#35
        db #36,#36,#36,#36,#36,#37,#37,#37,#37,#37,#37,#38,#38,#38,#38,#38
        db #38,#39,#39,#39,#39,#39,#39,#39,#39,#3A,#3A,#3A,#3A,#3A,#3A,#3A
        db #3A,#3B,#3B,#3B,#3B,#3B,#3B,#3B,#3B,#3B,#3B,#3B,#3C,#3C,#3C,#3C
        db #3C,#3C,#3C,#3C,#3C,#3C,#3C,#3C,#3C,#3D,#3D,#3D,#3D,#3D,#3D,#3D
        db #3D,#3D,#3D,#3D,#3D,#3D,#3D,#3D,#3D,#3D,#3D,#3D,#3E,#3E,#3E,#3E
        db #3E,#3E,#3E,#3E,#3E,#3E,#3E,#3E,#3E,#3E,#3E,#3E,#3E,#3E,#3E,#3E
        db #3E,#3E,#3E,#3E,#3E,#3E,#3E,#3E,#3E,#3E,#3E,#3E,#3F,#3F,#3F,#3F
        db #3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F
        db #3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F
        db #3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F
        db #3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F
        db #3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F
 
        ;;;;;;;; log2(x)*32 ;;;;;;;; 
log2_tab:  
        db #00,#00,#20,#32,#40,#4A,#52,#59,#60,#65,#6A,#6E,#72,#76,#79,#7D
        db #80,#82,#85,#87,#8A,#8C,#8E,#90,#92,#94,#96,#98,#99,#9B,#9D,#9E
        db #A0,#A1,#A2,#A4,#A5,#A6,#A7,#A9,#AA,#AB,#AC,#AD,#AE,#AF,#B0,#B1
        db #B2,#B3,#B4,#B5,#B6,#B7,#B8,#B9,#B9,#BA,#BB,#BC,#BD,#BD,#BE,#BF
        db #C0,#C0,#C1,#C2,#C2,#C3,#C4,#C4,#C5,#C6,#C6,#C7,#C7,#C8,#C9,#C9
        db #CA,#CA,#CB,#CC,#CC,#CD,#CD,#CE,#CE,#CF,#CF,#D0,#D0,#D1,#D1,#D2
        db #D2,#D3,#D3,#D4,#D4,#D5,#D5,#D5,#D6,#D6,#D7,#D7,#D8,#D8,#D9,#D9
        db #D9,#DA,#DA,#DB,#DB,#DB,#DC,#DC,#DD,#DD,#DD,#DE,#DE,#DE,#DF,#DF
        db #DF,#E0,#E0,#E1,#E1,#E1,#E2,#E2,#E2,#E3,#E3,#E3,#E4,#E4,#E4,#E5
        db #E5,#E5,#E6,#E6,#E6,#E7,#E7,#E7,#E7,#E8,#E8,#E8,#E9,#E9,#E9,#EA
        db #EA,#EA,#EA,#EB,#EB,#EB,#EC,#EC,#EC,#EC,#ED,#ED,#ED,#ED,#EE,#EE
        db #EE,#EE,#EF,#EF,#EF,#EF,#F0,#F0,#F0,#F1,#F1,#F1,#F1,#F1,#F2,#F2
        db #F2,#F2,#F3,#F3,#F3,#F3,#F4,#F4,#F4,#F4,#F5,#F5,#F5,#F5,#F5,#F6
        db #F6,#F6,#F6,#F7,#F7,#F7,#F7,#F7,#F8,#F8,#F8,#F8,#F9,#F9,#F9,#F9
        db #F9,#FA,#FA,#FA,#FA,#FA,#FB,#FB,#FB,#FB,#FB,#FC,#FC,#FC,#FC,#FC
        db #FD,#FD,#FD,#FD,#FD,#FD,#FE,#FE,#FE,#FE,#FE,#FF,#FF,#FF,#FF,#FF

  include "top-distancetoytable.asm"

; this table is also 256 aligned, since the previous three are
pixel_bit_masks:
    ; handle blocks of 2 pixels at a time
    db #c0, #c0, #30, #30, #0c, #0c, #03, #03

;pixel_bit_masks_zero:
;    ; handle blocks of 2 pixels at a time
;    db #3f, #3f, #cf, #cf, #f3, #f3, #fc, #fc


;-----------------------------------------------
; Source: (thanks to ARTRAG) https://www.msx.org/forum/msx-talk/development/memory-pages-again
; Sets the memory pages to : BIOS, ROM, ROM, RAM
setupROMRAMslots:
    call RSLREG     ; Reads the primary slot register
    rrca
    rrca
    and #03         ; keep the two bits for page 1
    ld c,a
    add a,#C1       
    ld l,a
    ld h,#FC        ; HL = EXPTBL + a
    ld a,(hl)
    and #80         ; keep just the most significant bit (expanded or not)
    or c
    ld c,a          ; c = a || c (a had #80 if slot was expanded, and #00 otherwise)
    inc l           
    inc l
    inc l
    inc l           ; increment 4, in order to get to the corresponding SLTTBL
    ld a,(hl)       
    and #0C         
    or c            ; in A the rom slotvar 
    ld h,#80        ; move page 1 of the ROM to page 2 in main memory
    jp ENASLT       
    
;-----------------------------------------------
; Source: https://www.msx.org/forum/msx-talk/development/8-bit-atan2?page=0
; 8-bit atan2
; Calculate the angle, in a 256-degree circle.
; The trick is to use logarithmic division to get the y/x ratio and
; integrate the power function into the atan table. 
;   input
;   B = x, C = y    in -128,127
;
;   output
;   A = angle       in 0-255
;      |
;  q1  |  q0
;------+-------
;  q3  |  q2
;      |
atan2:  
        ld  de,#8000           
        
        ld  a,c
        add a,d
        rl  e               ; y-                    
        
        ld  a,b
        add a,d
        rl  e               ; x-                    
        
        dec e
        jp  z,atan2_q1
        dec e
        jp  z,atan2_q2
        dec e
        jp  z,atan2_q3
        
atan2_q0:         
        ld  h,log2_tab / 256
        ld  l,b
        
        ld  a,(hl)          ; 32*log2(x)
        ld  l,c
        
        sub (hl)          ; 32*log2(x/y)
        
        jr  nc,atan2_1f           ; |x|>|y|
        neg             ; |x|<|y|   A = 32*log2(y/x)
atan2_1f:      
        ld  l,a

        ld  h,atan_tab / 256
        ld  a,(hl)
        ret c           ; |x|<|y|
        
        neg
        and #3F            ; |x|>|y|
        ret
                
atan2_q1:     
        ld  a,b
        neg
        ld  b,a
        call    atan2_q0
        neg
        and #7F
        ret
        
atan2_q2:     
        ld  a,c
        neg
        ld  c,a
        call    atan2_q0
        neg
        ret     
        
atan2_q3:     
        ld  a,b
        neg
        ld  b,a
        ld  a,c
        neg
        ld  c,a
        call    atan2_q0
        add a,128
        ret



;-----------------------------------------------
; calls "halt" "b" times
waitBhalts:
    halt
    djnz waitBhalts
    ret


;-----------------------------------------------
; hl = a*32
hl_equal_a_times_32:
    ld h,0
    ld l,a
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    ret


;-----------------------------------------------
; Check the amount of VRAM
;checkAmountOfVRAM:
;    xor a
;    ld hl,raycast_double_buffer
;    ld (hl),a
;    inc hl
;    ld (hl),a
;    ld a,(MODE)
;    and #06
;    ret z
;    inc (hl)
;    ret


;-----------------------------------------------
; A couple of useful macros for adding 16 and 8 bit numbers

ADD_HL_A: MACRO 
    add a,l
    ld l,a
    jr nc, $+3
    inc h
    ENDM

ADD_DE_A: MACRO 
    add a,e
    ld e,a
    jr nc, $+3
    inc d
    ENDM    

ADD_HL_A_VIA_BC: MACRO
    ld b,0
    ld c,a
    add hl,bc
    ENDM


;-----------------------------------------------
; macro to print a debug character to screen
;DEBUG: MACRO ?character,?position
;    push hl
;    push af
;    ld hl,NAMTBL2+256+256+7*32
;    ld a,?position
;    ADD_HL_A
;    ld a,?character
;    call WRTVRM
;    pop af
;    pop hl
;    ENDM
