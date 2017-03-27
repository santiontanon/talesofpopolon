;-----------------------------------------------
;; clear sprites:
clearAllTheSprites:
    xor a
    ld bc,32*4
    ld hl,SPRATR2
    jp FILVRM

;-----------------------------------------------
; Fills the whole screen with the pattern in register 'a'
FILLSCREEN:
    ld bc,768
    ld hl,NAMTBL2
    jp FILVRM

;-----------------------------------------------
; initializes the sprite data
setupSprites:
    ld hl,knight_sprite_attributes
    ;; knight
    ld (hl),127-32
    inc hl
    ld (hl),128-24
    inc hl
    ld (hl),KNIGHT_SPRITE*4
    inc hl
    ld a,KNIGHT_COLOR
    ld (hl),a
    inc hl
    ld (current_armor_color),a  
    ld (hl),127-34
    inc hl
    ld (hl),128-24
    inc hl
    ld (hl),KNIGHT_OUTLINE_SPRITE*4
    inc hl
    ld (hl),KNIGHT_OUTLINE_COLOR
    inc hl
    ;; sword
    ld (hl),200   ; somewhere away from the main screen
    inc hl
    ld (hl),128-24
    inc hl
    ld (hl),SWORD_SPRITE*4
    inc hl
    ld (hl),0 ;; initially, we set it to transparent

    ld hl,sword_sprite
    ld de,SPRTBL2+SWORD_SPRITE*32
    ld bc,32
    call LDIRVM    

    ; unpack the sprites
    ld hl,base_sprites_pletter
    ld de,raycast_buffer
    call pletter_unpack

    ; set up the arrows + pickup sprites:
    ld hl,raycast_buffer
    ld de,SPRTBL2+SPRITE_PATTERN_ARROW*32
    ld bc,32*20
    jp LDIRVM    


;-----------------------------------------------
; resets the sprite assignment table at the beginning of each frame:
resetSpriteAssignment:
    ld hl,sprites_available_per_depth
    ld a,N_SPRITES_PER_DEPTH
    REPT N_SPRITE_DEPTHS
    ld (hl),a
    inc hl
    ENDM

    ; clear the sprite attributes:
    ld hl,other_sprite_attributes
    ld de,other_sprite_attributes+1
    xor a
    ld (hl),a
    ld bc,4*(N_SPRITE_DEPTHS*N_SPRITES_PER_DEPTH)-1
    ldir

    ret


;-----------------------------------------------
; Assigns all the sprites corresponding to the pickups in a map to the sprite table
assignPickupSprites:
    ld bc,4
    ld hl,currentMapPickups
    ld a,(hl)   ; n pickups
    inc hl
assignPickupSprites_loop:
    or a
    ret z
    push af
    ld a,(hl)
    or a
    jp z,assignPickupSprites_skip
    push hl
    pop ix

    push hl ; I save the registers here, since assignSprite has many "ret" points, and it'll be a waste of memory to have pops all over
    push bc
    call assignSprite
    pop bc
    pop hl
assignPickupSprites_skip:
    pop af
    add hl,bc
    dec a
    jp assignPickupSprites_loop


;-----------------------------------------------
; Assigns all the sprites corresponding to the arrows the player can fire to the sprite table
assignArrowSprites:
    ld hl,arrow_data
    ld a,(hl)
    or a
    call nz,assignArrowSprites_assignArrow
    ld hl,arrow_data+ARROW_STRUCT_SIZE
    ld a,(hl)
    or a
    jp nz,assignArrowSprites_assignArrow
    ret

assignArrowSprites_assignArrow:
    push hl
    pop ix
    ld bc,6     ; if we add 6 to "ix", then (ix+1),(ix+2) is x,y and (ix+3) is the sprite, as expected by assignSprite
    add ix,bc
    jp assignSprite
    

;-----------------------------------------------
; this function corresponds to the shared code between the "assignSprite" function 
; in this file, and the "assignEnemySprite" function in the enemies file
assignSprite_prefilter:
    ; 1) Calculate it's depth and y coordinate: 
    ld a,(last_raycast_camera_x)
    ld c,(ix+1)
    sub c
    ld d,a  ;; save the signed version for later use
    or a
    jp p,assignSprite_positive_x_diff
    neg
assignSprite_positive_x_diff:
    cp 64
    ret p   ;; if the difference in x is larger than 64, sprite is too far
    ld c,a

    ld a,(last_raycast_camera_y)
    ld b,(ix+2)
    sub b
    ld e,a  ;; save the signed version for later use
    or a
    jp p,assignSprite_positive_y_diff
    neg
assignSprite_positive_y_diff:
    cp 64
    ret p   ;; if the difference in y is larger than 64, sprite is too far
    ld b,a

    ;; b,c now contain the difference in x and y coordinates among the player and the sprite:
    ;; compute b*64 + c
    sla b
    sla b
    ld h,0
    ld l,b
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl   ;; hl = b*64
    ld b,0
    add hl,bc
    ld bc,distance_to_y_table
    add hl,bc
    ld a,(hl)   ;; y coordinate:
    ld (assignSprite_y),a
    ; y >= 72: bank 0
    ; y >= 64: bank 1
    ; y >= 56: bank 2
    ; bank 3 otherwise
    cp 72
    jp p,assignSprite_bank0
    cp 64
    jp p,assignSprite_bank1
    cp 56
    jp p,assignSprite_bank2
assignSprite_bank3:
    ld a,3
    ld (assignSprite_bank),a
    jp assignSprite_done_with_bank_assignment
assignSprite_bank0:
    xor a
    ld (assignSprite_bank),a
    jp assignSprite_done_with_bank_assignment
assignSprite_bank1:
    ld a,1
    ld (assignSprite_bank),a
    jp assignSprite_done_with_bank_assignment
assignSprite_bank2:
    ld a,2
    ld (assignSprite_bank),a
assignSprite_done_with_bank_assignment:

    ; - see if we have space in the bank:
    ld hl,sprites_available_per_depth
    ADD_HL_A
    ld a,(hl)
    or a
    ret z   ;; if we don't have space, just return

    ; 2) Calculate it's x position: 
    ld b,d  ; x
    ld c,e  ; y
    call atan2  ;; a now has the angle
    add a,128   ;; due to the coordinate system I use, the angle is reversed
    ld b,a
    ld a,(last_raycast_player_angle)
    sub b           ;; a now has the angle with respect to the player angle
    ld b,a

    ;; make sure it's inside of the screen:
    ;; for the 192-pixel wide mode, this is between -24 to 24
    ;; for the 160-pixel wide mode, this is between -20 to 20
    ;; for the 128-pixel wide mode, this is between -16 to 16
    or a
    jp p,assignSprite_positive_angle_diff
    neg
assignSprite_positive_angle_diff:
    ld hl,raycast_sprite_angle_cutoff
    cp (hl)
    ret p

    ld a,b
    neg
    sla a
    sla a
    add a,128-16    ;; 0 degrees of difference correspond to position (128 - 16) in the screen
    ld (assignSprite_x),a

    ; 3) make sure it's not occluded by any wall:    
    call lineOfSightCheck
    ret nz
    ld a,(assigningSpritesForAnEnemy)
    or a
    jp z,assignSprite_continue
    jp assignEnemySprite_continue


;-----------------------------------------------
; - places a sprite in the sprite assignment table for rendering in the next frame
; - parameters:
;   IX: pointer to the item parameters (type, x, y)
assignSprite:
    jp assignSprite_prefilter
assignSprite_continue:
    ; 4) get the type of the pickup/enemy, and assign a sprite:
    ld a,(assignSprite_bank)
    ld b,a
    ld a,(ix+3)
    ;; ice arrows have a fake sprite number, so that we can paint them of different color
    or a
    jp nz,assignSprite_not_an_icearrow
    ld a,SPRITE_PATTERN_ARROW
assignSprite_not_an_icearrow:
    add a,b
    add a,a
    add a,a
    ld (assignSprite_sprite),a

    ld a,(ix+3)
    srl a
    srl a
    ld hl,item_sprite_colors
    ADD_HL_A
    ld a,(hl)
    ld (assignSprite_color),a

    ; 5) assign the sprite to the table:
    ld a,(assignSprite_bank)
    ld b,a
    ld hl,sprites_available_per_depth
    ADD_HL_A
    dec (hl)
    ld a,(hl)
    sla b
    sla b   ;; note: this assumes that N_SPRITES_PER_DEPTH = 4
    add a,b
    ld de,other_sprite_attributes
    add a,a   
    add a,a   
    ADD_DE_A
    ld hl,assignSprite_y
    ldi
    ldi
    ldi
    ldi
    ret


;-----------------------------------------------
; sets the proper sprites for the knight and outline
updateKightSprites:
    ld hl,SPRTBL2+KNIGHT_SPRITE*32
    call SETWRT
    ld b,0
    ld a,(knight_animation_frame) ;; (knight_animation_frame) is the offset of the sprite
    ld c,a
    ld hl,knight_sprites
    add hl,bc
;    ld bc,32*256+VDP_DATA
    ld b,32
    ld a,(VDP.DW)
    ld c,a
    push bc
updateKightSprites_loop1: 
    outi
    jp nz,updateKightSprites_loop1

    ;; outline sprite follows knight sprite:	
    ld bc,knight_sprites_outline-knight_sprites-32
	
    add hl,bc
    pop bc
;    ld bc,32*256+VDP_DATA
updateKightSprites_loop2:
    outi
    jp nz,updateKightSprites_loop2
    ret


;-----------------------------------------------
; Updates all the sprite attribute tables to draw all the sprites
drawSprites:
    ld hl,SPRATR2+KNIGHT_SPRITE*4
    call SETWRT
    
    ld hl,knight_sprite_attributes
    ;; draw knight + knight_outline + sword + all the sprites in the assignment table
;    ld bc,4*(3+N_SPRITE_DEPTHS*N_SPRITES_PER_DEPTH)*256 + VDP_DATA
    ld b,4*(3+N_SPRITE_DEPTHS*N_SPRITES_PER_DEPTH)
    ld a,(VDP.DW)
    ld c,a
drawSprites_loop:
    outi
    jp nz,drawSprites_loop
    ret


;-----------------------------------------------
; Decodes the graphic patterns, and copies them to video memory
setupPatterns:
    xor a
    ld hl,NAMTBL2
    ld bc,256*3
    call FILVRM
;    jp decodePatternsToAllBanks


;-----------------------------------------------
; Decodes the graphics to all 3 banks:
decodePatternsToAllBanks:
    ld hl,patterns_pletter
    ld de,raycast_buffer
    call pletter_unpack

    ld hl,raycast_buffer
    ld de,CHRTBL2
    ld bc,256*8
    push bc
    push hl
    call LDIRVM

    pop hl
    pop bc
    ld de,CHRTBL2+256*8
    push bc
    push hl
    call LDIRVM
    pop hl
    pop bc

    ld de,CHRTBL2+256*8*2
    push bc
    call LDIRVM

    pop bc
    ld hl,raycast_buffer+2048
    ld de,CLRTBL2
    push bc
    push hl
    call LDIRVM

    pop hl
    pop bc
    ld de,CLRTBL2+256*8
    push bc
    push hl
    call LDIRVM

    pop hl
    pop bc
    ld de,CLRTBL2+256*8*2
    jp LDIRVM


;-----------------------------------------------
; Decodes the UI graphics, and renders the initial UI frame
setupUIPatterns:
    ; clear all the patterns of the first 2 banks:
    xor a
    ld hl,CHRTBL2
    ld bc,256*8*2
    call FILVRM

    ; copy name table:
    ld hl,ui
    ld de,raycast_buffer
    call pletter_unpack

    ld hl,raycast_buffer
    ld de,NAMTBL2+32*8*2
    ld bc,32*8
    jp LDIRVM


;-----------------------------------------------
; updates the UI when the player picks up or uses a key:
; destroys af
update_UI_keys:
    ; clear keys:
    push hl
    push bc
    ld a,141
    ld bc,4
    ld hl,NAMTBL2+21*32+25
    call FILVRM

    ; draw keys:
    ld a,(player_keys)
    or a
    jp z,update_UI_keys_nokeys
    ld b,0
    ld c,a
    ld hl,NAMTBL2+21*32+25
    ld a,191
    call FILVRM
update_UI_keys_nokeys:
    pop bc
    pop hl
    ret


;-----------------------------------------------
; updates the UI when the health of the player changes
; destroys af
update_UI_health:
    push hl
    push bc
    xor a
    ld bc,8
    ld hl,NAMTBL2+19*32+7
    call FILVRM
    ld a,(player_health)
    or a
    jp z,update_UI_health_done
    srl a   ; divide by two
    or a
    jp z,update_UI_health_last_bar
    ld b,0
    ld c,a
    ld hl,NAMTBL2+19*32+7
    ld a,192
    call FILVRM
update_UI_health_last_bar:
    ld a,(player_health)
    and #01
    or a
    jp z,update_UI_health_done
    ld hl,NAMTBL2+19*32+7
    ld a,(player_health)
    srl a
    ADD_HL_A
    ld a,193
    ld bc,1
    call FILVRM

update_UI_health_done:
    pop bc
    pop hl
    ret


;-----------------------------------------------
; updates the UI when the mana of the player changes
; destroys af
update_UI_mana:
    push hl
    push bc
    xor a
    ld bc,8
    ld hl,NAMTBL2+21*32+7
    call FILVRM
    ld a,(player_mana)
    or a
    jp z,update_UI_mana_done
    srl a   ; divide by four
    srl a
    or a
    jp z,update_UI_mana_last_tile
    ld b,0
    ld c,a
    ld hl,NAMTBL2+21*32+7
    ld a,194
    call FILVRM

    ld hl,NAMTBL2+21*32+7
    ld a,(player_mana)
    srl a   ; divide by four
    srl a
    ADD_HL_A

update_UI_mana_last_tile:
    ld a,(player_mana)
    and #03
    or a
    jp z,update_UI_mana_done
    dec a
    jp z,update_UI_mana_one
    dec a
    jp z,update_UI_mana_two
update_UI_mana_three:  
    ld a,118
    call WRTVRM
    jp update_UI_mana_done
update_UI_mana_two:  
    ld a,255
    call WRTVRM
    jp update_UI_mana_done
update_UI_mana_one:  
    ld a,195
    call WRTVRM

update_UI_mana_done:
    pop bc
    pop hl
    ret


;-----------------------------------------------
; Clears the screen left to right
clearScreenLeftToRight:
    call clearAllTheSprites

    ;; make sure character 0 is empty on the top two banks:
    xor a
    ld bc,8
    ld hl,CLRTBL2
    call FILVRM
    xor a
    ld bc,8
    ld hl,CLRTBL2+256*8
    call FILVRM

    ld a,32
    ld bc,0
clearScreenLeftToRightExternalLoop
    push af
    push bc
    ld a,24
    ld hl,NAMTBL2
    add hl,bc
clearScreenLeftToRightLoop:
    push hl
    push af
    xor a
    ld bc,1
    call FILVRM
    pop af
    pop hl
    ld bc,32
    add hl,bc
    dec a
    jr nz,clearScreenLeftToRightLoop
    pop bc
    pop af
    inc bc
    dec a
    halt
    jr nz,clearScreenLeftToRightExternalLoop
    ret    


item_sprite_colors: ; sprite/4 indexes this table (only used for arrows, chests, potions, hearts and keys)
    db 7,9  ;; ice arrows / arrows
    db 10,7,5,10    ;; chests / potions / hearts / keys


knight_sprites:
    ; walk sprite1
    db #0f,#1f,#1f,#1f,#1f,#1f,#07,#00,#1b,#3b,#37,#27,#00,#07,#06,#00
    db #f0,#f8,#f8,#f8,#f8,#f8,#e0,#00,#d8,#dc,#ec,#04,#e0,#60,#40,#00
    ; walk sprite2
    db #00,#0f,#1f,#1f,#1f,#1f,#1f,#04,#1b,#3b,#37,#20,#07,#06,#02,#00
    db #00,#f0,#f8,#f8,#f8,#f8,#f8,#20,#d8,#dc,#ec,#e4,#00,#e0,#60,#00
    ; sword swing sprite
    db #00,#0f,#1f,#1f,#1f,#1f,#1f,#04,#1b,#3b,#37,#27,#00,#07,#06,#00
    db #00,#f0,#f8,#f8,#f8,#f8,#f0,#20,#d0,#e0,#e0,#00,#e0,#60,#40,#00


knight_sprites_outline:
    ; walk sprite1
    db #0f,#10,#20,#23,#20,#20,#20,#18,#1f,#24,#44,#48,#58,#2f,#08,#09
    db #f0,#08,#04,#c4,#04,#04,#04,#18,#f8,#24,#22,#12,#fa,#14,#90,#a0
    ; walk sprite2
    db #00,#0f,#10,#20,#23,#20,#20,#20,#1b,#24,#44,#48,#5f,#28,#09,#05
    db #00,#f0,#08,#04,#c4,#04,#04,#04,#d8,#24,#22,#12,#1a,#f4,#10,#90
    ; sword swing sprite
    db #00,#0f,#10,#20,#23,#20,#20,#20,#1b,#24,#44,#48,#58,#2f,#08,#09
    db #00,#f0,#08,#04,#c4,#04,#04,#08,#d8,#28,#10,#10,#f0,#10,#90,#a0


sword_sprite:
    db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
    db #00,#80,#c0,#c0,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00

goldsword_sprite:
    db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
    db #80,#c0,#c0,#c0,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00


base_sprites_pletter:
    incbin "tocompress/base-sprites.plt"

patterns_pletter:
    incbin "tocompress/patterns.plt"

ui:
    incbin "tocompress/ui.plt"

ROM_barehand_weapon_patterns:
    db   0,208,209
    db 210,211,212
    db 213,214,215
ROM_sword_weapon_patterns:
    db 224,225,  0
    db 226,227,228
    db   0,229,230
ROM_goldsword_weapon_patterns:
    db 231,232,  0
    db 233,234,235
    db   0,236,237

ROM_barehand_secondaryweapon_patterns:
    db 216,217,  0
    db 218,219,220
    db 221,222,223
ROM_arrow_secondaryweapon_patterns:
    db 238,239,  0
    db 240,241,242
    db 243,244,245
ROM_icearrow_secondaryweapon_patterns:
    db 246,247,0
    db 248,249,250
    db 251,252,253
ROM_hourglass_secondaryweapon_patterns:
    db 119,120,121
    db 122,123,124
    db 125,126,127
