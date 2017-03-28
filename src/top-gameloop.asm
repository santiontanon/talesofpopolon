;-----------------------------------------------
; Main game loop!
Game_Loop:    
    call initializeGame
    ; load the first map:
    ld hl,map_tunnel1_pletter
Game_Loop_after_setting_map:
    call loadMap
    call update_UI_keys
    call update_UI_health
    call update_UI_mana
    call raycast_reset    

    ;; the very first time, start by rendering the background:
    call raycastCompleteRender
    
Game_Loop_loop:

;    out (#2c),a    

    ;; ---- SUBFRAME 1 ----
    call Game_Update_Cycle
    call Game_updateRaycastVariables
    call raycast_reset_clear_buffer
    ld hl,initial_rendering_blocks
    ld de,raycast_first_column
    push de
    ldi
    ldi
    call raycast_render_to_buffer

    ;; ---- SUBFRAME 2 ----
    ld a,(MSXTurboRMode)
    dec a
    call nz,Game_Update_Cycle
    ld hl,initial_rendering_blocks+1
    pop de
    push de
    ldi
    ldi
    call raycast_render_to_buffer

    ;; ---- SUBFRAME 3 ----
    call Game_Update_Cycle
    ld hl,initial_rendering_blocks+2
    pop de
    push de
    ldi
    ldi
    call raycast_render_to_buffer

    ;; ---- SUBFRAME 4 ----
    ld a,(MSXTurboRMode)
    dec a
    call nz,Game_Update_Cycle
    ld hl,initial_rendering_blocks+3
    pop de
    ldi
    ldi
    call raycast_render_to_buffer
    call raycast_render_buffer

    ld a,(raycast_screen_size_change_requested)
    or a
    call nz,Game_trigger_screen_size_change
    ld a,(CPUmode_change_requested)
    or a
    call nz,Game_trigger_CPUmode_change
    xor a
    ld (raycast_screen_size_change_requested),a
    ld (CPUmode_change_requested),a

    call saveLastRaycastVariables

;    out (#2d),a    

    jr Game_Loop_loop


raycastCompleteRender:
    call Game_updateRaycastVariables
    call raycast_reset_clear_buffer
    ld a,(initial_rendering_blocks)
    ld (raycast_first_column),a
    ld a,(initial_rendering_blocks+4)
    ld (raycast_last_column),a
    call raycast_render_to_buffer
    call raycast_render_buffer
saveLastRaycastVariables:
    ld a,(raycast_camera_x)
    ld (last_raycast_camera_x),a
    ld a,(raycast_camera_y)
    ld (last_raycast_camera_y),a
    ld a,(raycast_angle_offset)
    ld b,a
    ld a,(raycast_player_angle)
    add a,b
    ld (last_raycast_player_angle),a
    ret


Game_updateRaycastVariables:
    ;; angle:
    ld de,player_angle
    ld a,(de)
    ld hl,raycast_angle_offset
    sub (hl)
    ld (raycast_player_angle),a

    ;; position:
    ld hl,cos_table_x12
    ld b,0
    ld a,(de)
    add a,128
    ld c,a
    add hl,bc
    add hl,bc
    push hl
    ld c,(hl)
    inc hl
    ld b,(hl)
    ld hl,(player_precision_x)
    add hl,bc
    ld a,h
    ld (raycast_camera_x),a

    pop hl
    ld bc,sin_table_x12-cos_table_x12
    add hl,bc
    ld c,(hl)
    inc hl
    ld b,(hl)
    ld hl,(player_precision_y)
    add hl,bc
    ld a,h
    ld (raycast_camera_y),a

    ret


Game_trigger_screen_size_change:
    ld a,(initial_rendering_blocks+4)
    cp 192
    ld hl,ROM_initial_rendering_blocks_160
    jr z,Game_trigger_screen_size_change2
    cp 160
    ld hl,ROM_initial_rendering_blocks_128
    jr z,Game_trigger_screen_size_change2
    ld hl,ROM_initial_rendering_blocks_192

Game_trigger_screen_size_change2:
    ld de,initial_rendering_blocks
    ld bc,18
    ldir
    jp raycast_reset
    

;-----------------------------------------------
; modes are:
; 0: Z80
; 1: R800 smooth
; 2: R800 fast
Game_trigger_CPUmode_change:
    ld a,(CHGCPU)
    cp #C3
    ret nz  ; if we are not in a turbo R, just ignore
    ld hl,MSXTurboRMode
    inc (hl)
    ld a,(hl)
    cp 3
    jr nz,Game_trigger_CPUmode_change_noreset
    xor a
    ld (hl),a
Game_trigger_CPUmode_change_noreset:
    or a
    jr z,Game_trigger_CPUmode_change_z80
Game_trigger_CPUmode_change_r800:
    dec a
    jr z,Game_trigger_CPUmode_change_r800_smooth
    ld hl,UI_message_r800fast_mode
    ld c,UI_message_r800fast_mode_end-UI_message_r800fast_mode
Game_trigger_CPUmode_change_r800_b:
    call displayUIMessage
    ld a,#82       ; R800 DRAM
    jp CHGCPU
Game_trigger_CPUmode_change_r800_smooth:
    ld hl,UI_message_r800smooth_mode
    ld c,UI_message_r800smooth_mode_end-UI_message_r800smooth_mode
    jr Game_trigger_CPUmode_change_r800_b
Game_trigger_CPUmode_change_z80:
    ld hl,UI_message_z80_mode
    ld c,UI_message_z80_mode_end-UI_message_z80_mode
    call displayUIMessage
    ld a,#80       ; Z80 DRAM
    jp CHGCPU


initializeGame:
    call clearScreenLeftToRight
    call initializeMemory
    ld bc,#e301  ;; write #e2 in VDP register #01 (activate sprites, generate interrupts, 16x16 sprites with magnification)
    call WRTVDP

    call StopPlayingMusic
    ld a,8
    ld (Music_tempo),a
    ld hl,LoPInGameSongPletter
    call PlayCompressedSong

    ld hl,textures_pletter
    ld de,textures
    call pletter_unpack

    call setupSprites

    jp setupUIPatterns
