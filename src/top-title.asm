;-----------------------------------------------
; Title screen loop
TitleScreen_Loop:
    call StopPlayingMusic
    call clearScreenLeftToRight

    ;; 16x16 sprites:
    ld bc,#e201  ;; write #e2 in VDP register #01 (activate sprites, generate interrupts, 16x16 sprites with no magnification)
    call WRTVDP

    ; render title:
    ld a,1
    ld (title_state),a

TitleScreen_Loop_loop1: ;; "TALES OF" coming in
    ld hl,title_talesof_patterns
    cp 9
    jp p,TitleScreen_Loop_loop1_larger
TitleScreen_Loop_loop1_smaller:
    ld b,0
    ld c,a
    neg
    add a,9
    ADD_HL_A
    ld de,NAMTBL2+32*5
    jr TitleScreen_Loop_loop1_draw
TitleScreen_Loop_loop1_larger:
    sub 9
    ld de,NAMTBL2+32*5
    ADD_DE_A
    ld bc,9
TitleScreen_Loop_loop1_draw:
    call LDIRVM
    call increaseTitleState_and_HaltTwice
    cp 21
    jr nz,TitleScreen_Loop_loop1

    ld a,31
    ld (title_state),a
TitleScreen_Loop_loop2: ;; "POPOLON" coming in
    cp 31-14
    jp m,TitleScreen_Loop_loop2_larger
TitleScreen_Loop_loop2_smaller:
    neg
    add a,32
    ld b,0
    ld c,a
    jr TitleScreen_Loop_loop2_render
TitleScreen_Loop_loop2_larger:
    ld bc,15
TitleScreen_Loop_loop2_render:
    ld a,(title_state)
    push af
    push bc
    ; de = NAMTBL2+32*6 + a
    ld de,NAMTBL2+32*6
    ADD_DE_A
    ld hl,title_popolon_line1_patterns
    call LDIRVM
    pop bc

    pop af
    ld de,NAMTBL2+32*7
    ADD_DE_A
    ld hl,title_popolon_line2_patterns
    call LDIRVM
    call decreaseTitleState_and_HaltTwice
    cp 8
    jr nz,TitleScreen_Loop_loop2

    ld a,22
    ld (title_state),a
TitleScreen_Loop_loop3: ;; "underline" coming in
    ; de = NAMTBL2 + a*32
    call hl_equal_a_times_32
    ld bc,NAMTBL2+7
    add hl,bc
    push hl
    ex de,hl 
    ld hl,title_undertitle_patterns
    ld bc,18
    call LDIRVM

    ; clear the line underneath
    pop hl
    ld bc,32
    add hl,bc
    xor a
    ld bc,18
    call FILVRM
    call decreaseTitleState_and_HaltTwice
    cp 7
    jr nz,TitleScreen_Loop_loop3

    call TitleScreen_setupsprites

    ; display credits
    ld hl,title_credits
    ld de,NAMTBL2+32*23+6
    ld bc,20
    call LDIRVM

    xor a
    ld (title_state),a
    ld (previous_trigger1),a
TitleScreen_Loop_loop:
    call TitleScreen_update_bg_sprites

    ; press space to play
    ld a,(title_state)
    push af
    and #08
    call TitleScreen_Loop_update_press_space
    ; animate warriors:
    pop af
    sra a
    sra a
    and #03
    jr z,TitleScreen_render_warrior1
    dec a
    jr z,TitleScreen_render_warrior2
    dec a
    jr z,TitleScreen_render_warrior3
    jr TitleScreen_render_warrior2


TitleScreen_render_warrior2:
    ld hl,title_warrior_left_2
    jr TitleScreen_render_warrior1_after
;    call TitleScreen_render_warrior
;    jp TitleScreen_Loop_loop_continue

TitleScreen_render_warrior3:
    ld hl,title_warrior_left_3
    jr TitleScreen_render_warrior1_after
;    call TitleScreen_render_warrior
;    jp TitleScreen_Loop_loop_continue


TitleScreen_render_warrior1:
    ld hl,title_warrior_left_1
TitleScreen_render_warrior1_after:
    call TitleScreen_render_warrior
;    jr TitleScreen_Loop_loop_continue


TitleScreen_Loop_loop_continue:
    call increaseTitleState_and_HaltTwice
    or a
    jp z,TitleScreen_Loop_go_to_story

    ;; if trigger 2 is pressed, enter password
    push bc
    call checkTrigger2
    pop bc
    jp nz,Password_loop

    ;; wait for space to be pressed:
    push bc
    call checkTrigger1updatingPrevious
    pop bc
    jr z,TitleScreen_Loop_loop

    ld a,6
    ld (Music_tempo),a
    ld hl,LoPStartSongPletter
    call PlayCompressedSong

    ;; transition animation before playing:
    xor a
    ld (title_state2),a
TitleScreen_Loop_pressed_space_loop:
    call TitleScreen_update_bg_sprites

    ; press space to play flashing fast
    ld a,(title_state2)
    push af
    and #02
    call TitleScreen_Loop_update_press_space

    ; animate warriors:
    pop af
    and #08
    jp z,TitleScreen_render_warrior4
    call TitleScreen_render_warrior5

TitleScreen_Loop_pressed_space_loop_continue:
    call increaseTitleState_and_HaltTwice
    ld hl,title_state2
    inc (hl)
    ld a,(hl)
    cp 64
    jr nz,TitleScreen_Loop_pressed_space_loop

TitleScreen_Loop_play:
    ld a,GAME_STATE_PLAYING
;    ld (game_state),a
    jp change_game_state

TitleScreen_Loop_go_to_story:
    ld a,GAME_STATE_STORY
;    ld (game_state),a
    jp change_game_state

TitleScreen_setupsprites:
    ; decompress the title sprites
    ld hl,title_bg_sprites_pletter
    ld de,raycast_buffer
    call pletter_unpack

    ; we zero out the copy that will be rendered, which will be modified later on:
    xor a
    ld hl,raycast_color_buffer
    ld de,raycast_color_buffer+1
    ld (hl),a
    ld bc,32*12-1
    ldir

    ld hl,raycast_color_buffer
    ld de,SPRTBL2
    ld bc,32*12
    call LDIRVM    

    ld hl,knight_sprite_attributes
;    ld bc,12
    ld e,16
    xor a
TitleScreen_setupsprites_loop:
    ld d,104
    ld b,3
TitleScreen_setupsprites_loop2:
    ld (hl),e
    inc hl
    ld (hl),d
    inc hl
    ld (hl),a
    inc hl
    ld (hl),4
    inc hl
    push af
    ld a,d
    add a,16
    ld d,a
    pop af
    add a,4
    djnz TitleScreen_setupsprites_loop2
    push af
    ld a,e
    add a,16
    ld e,a
    pop af
    cp 48
    jr nz,TitleScreen_setupsprites_loop

    ld hl,knight_sprite_attributes
    ld de,SPRATR2
    ld bc,48
    jp LDIRVM  


TitleScreen_Loop_update_press_space:
    jr z,TitleScreen_Loop_update_press_space_draw
TitleScreen_Loop_update_press_space_clear:
    xor a
    ld hl,NAMTBL2+32*16+(32 - (title_press_space_end - title_press_space))/2
    ld bc,title_press_space_end - title_press_space
    jp FILVRM
TitleScreen_Loop_update_press_space_draw:
    ld hl,title_press_space
    ld de,NAMTBL2+32*16+(32 - (title_press_space_end - title_press_space))/2
    ld bc,title_press_space_end - title_press_space
    jp LDIRVM


decreaseTitleState_and_HaltTwice:
    ld hl,title_state
    dec (hl)
    ld a,(hl)
;    ld a,(title_state)
;    dec a
;    ld (title_state),a
    halt
    halt
    ret


increaseTitleState_and_HaltTwice:
    ld hl,title_state
    inc (hl)
    ld a,(hl)
;    ld a,(title_state)
;    inc a
;    ld (title_state),a
    halt
    halt
    ret


TitleScreen_update_bg_sprites:
    ld a,(title_state)
    push af
    and #80
    jr nz,TitleScreen_update_bg_sprites_second_sprite
    ld hl,raycast_buffer
    jr TitleScreen_update_bg_sprites_copy_sprite
TitleScreen_update_bg_sprites_second_sprite:
    ld hl,raycast_buffer+12*32
TitleScreen_update_bg_sprites_copy_sprite:
    ld de,raycast_color_buffer
    ld bc,32*12
    ldir

    pop af
    and #7f
    cp 14
    jp p,TitleScreen_update_bg_sprites_second_half
    and #fe
    jr TitleScreen_update_bg_sprites_apply_mask
TitleScreen_update_bg_sprites_second_half:
    cp 114
    jp m,TitleScreen_update_bg_sprites_mask_applied
    neg
    add a,127
    and #fe

TitleScreen_update_bg_sprites_apply_mask:
    add a,a
    ; apply a mask:
    ld hl,title_bg_masks
    ADD_HL_A
    exx 
    ld bc,32*12
    ld hl,raycast_color_buffer
TitleScreen_update_bg_sprites_loop:

    ld e,3
TitleScreen_update_bg_sprites_loop_internal:
    ld a,(hl)
    exx
    ld d,(hl)
    inc hl
    and d
    exx
    ld (hl),a
    inc hl    
    dec bc
    dec e
    jr nz,TitleScreen_update_bg_sprites_loop_internal
    
    ld a,(hl)
    exx
    ld d,(hl)
    dec hl
    dec hl
    dec hl
    and d
    exx     
    ld (hl),a
    inc hl    
    dec bc

    ld a,c
    or b
    jr nz,TitleScreen_update_bg_sprites_loop

TitleScreen_update_bg_sprites_mask_applied:
    ld hl,raycast_color_buffer
    ld de,SPRTBL2
    ld bc,32*12
    jp LDIRVM    


TitleScreen_render_warrior4:
    ld hl,title_warrior_left_top_4
    ld de,NAMTBL2+5*32+7
    ld bc,2
    push bc
    call LDIRVM
    ld hl,title_warrior_right_top_4
    ld de,NAMTBL2+5*32+23
    pop bc
    call LDIRVM
    ld hl,title_warrior_left_4
    call TitleScreen_render_warrior
    jp TitleScreen_Loop_pressed_space_loop_continue

TitleScreen_render_warrior5:
    ld hl,title_warrior_left_top_5
    ld de,NAMTBL2+5*32+7
    ld bc,2
    call LDIRVM
    ld hl,title_warrior_right_top_5
    ld de,NAMTBL2+5*32+23
    ld bc,2
    call LDIRVM
    ld hl,title_warrior_left_5
;    jr TitleScreen_render_warrior
;    jp TitleScreen_Loop_pressed_space_loop_continue

TitleScreen_render_warrior:
    push hl
    ld de,NAMTBL2+6*32+7
    ld bc,2
    call LDIRVM
    pop hl
    inc hl
    inc hl
    push hl
    ld de,NAMTBL2+7*32+7
    ld bc,2
    call LDIRVM
    pop hl
    inc hl
    inc hl
    push hl
    ld de,NAMTBL2+6*32+23
    ld bc,2
    call LDIRVM
    pop hl
    inc hl
    inc hl
    ld de,NAMTBL2+7*32+23
    ld bc,2
    jp LDIRVM


title_talesof_patterns: ; length: 9
    db " TALES OF"
title_popolon_line1_patterns:   ; length 15
    db 1,2,3,4,1,2,3,4, 9, 0,3,4,12,13,0
title_popolon_line2_patterns:   ; length 15
    db 5,6,7,8,5,6,7,8,10,11,7,8,14,15,0
title_undertitle_patterns:      ; length 18
    db 16,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,18

title_warrior_left_1:
    db 19,20
    db 21,22
title_warrior_right_1:
    db 36,37
    db 38,39

title_warrior_left_2:
    db 23,24
    db 25,26
title_warrior_right_2:
    db 40,41
    db 42,43

title_warrior_left_3:
    db 27,24
    db 25,26
title_warrior_right_3:
    db 40,47
    db 42,43

title_warrior_left_top_4:
    db 28,0
title_warrior_right_top_4:
    db 0,44
title_warrior_left_4:
    db 29,30
    db 21,22
title_warrior_right_4:
    db 61,62
    db 38,39

title_warrior_left_top_5:
    db 31,98
title_warrior_right_top_5:
    db 99,64
title_warrior_left_5:
    db 95,96
    db 97,35
title_warrior_right_5:
    db 91,92
    db 93,94

title_bg_masks:
    db #08,#00,#80,#00
    db #08,#80,#08,#80
    db #88,#22,#08,#22
    db #bb,#55,#bb,#55
    db #77,#dd,#77,#dd
    db #f7,#7f,#f7,#7f
    db #f7,#ff,#7f,#ff

title_bg_sprites_pletter:
    incbin "tocompress/title-sprites.plt"
