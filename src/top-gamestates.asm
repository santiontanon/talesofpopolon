;-----------------------------------------------
; Determines which game loop to change to, given the current game state
change_game_state:
    ld (game_state),a
    or a
;    cp GAME_STATE_SPLASH
    jp z,SplashScreen_Loop
    dec a
;    cp GAME_STATE_TITLE
    jp z,TitleScreen_Loop
    dec a
;    cp GAME_STATE_STORY
    jp z,GameStory_Loop
    dec a
;    cp GAME_STATE_PLAYING
    jp z,Game_Loop
    dec a
;    cp GAME_STATE_GAME_OVER
    jr z,GameOver_Loop
    dec a
;    cp GAME_STATE_ENTER_MAP
    jp z,EnterMap_Loop
;    cp GAME_STATE_ENDING
    jp Ending_Loop

GameOver_Loop:
    call StopPlayingMusic
    ; no need to change tempo, since it must be 8 at this point
    ld hl,LoPGameOverSongPletter
    call PlayCompressedSong

    ld a,200
    ld (knight_sprite_attributes+8),a    ; place the sword sprites somewhere outside of the screen
    ld (knight_sprite_attributes+12),a    ; place the sword sprites somewhere outside of the screen

GameOver_Loop_loop1:
    call Game_Update_Cycle_playerdead
    call GameOver_updateknightSprites
    ld a,(game_over_cycle)
    inc a
    ld (game_over_cycle),a
    cp 16
    jr z,GameOver_Loop_loop1_done
    ; slow down the game:
    halt
    halt
    halt
    halt
    halt
    jr GameOver_Loop_loop1
GameOver_updateknightSprites:
    ; make the knight sprite sink over time:
    ; copy (16-a) bytes (bc) from knight_sprites (hl) to SPRTBL2+KNIGHT_SPRITE*32+a (de)

    ld a,(game_over_cycle)
    push af
    ld de,SPRTBL2+KNIGHT_SPRITE*32
    ADD_DE_A
    ld hl,knight_sprites+32
    ld a,(game_over_cycle)
    neg
    add a,16
    ld c,a
    ld b,0  ;; bc = 16 - a
    push bc
    call LDIRVM   
    pop bc

    pop af
;    ld a,(game_over_cycle)
    push af
    ld de,SPRTBL2+KNIGHT_OUTLINE_SPRITE*32
    ADD_DE_A
    ld hl,knight_sprites_outline+32
    push bc
    call LDIRVM   
    pop bc

    pop af
;    ld a,(game_over_cycle)
    push af
    ld de,SPRTBL2+KNIGHT_SPRITE*32+16
    ADD_DE_A
    ld hl,knight_sprites+32+16
    push bc
    call LDIRVM   
    pop bc

    pop af
;    ld a,(game_over_cycle)
    ld de,SPRTBL2+KNIGHT_OUTLINE_SPRITE*32+16
    ADD_DE_A
    ld hl,knight_sprites_outline+32+16
    jp LDIRVM   


GameOver_Loop_loop1_done:
    call clearScreenLeftToRight
    call decodePatternsToAllBanks

    ; print game over string:
    ld hl,UI_message_game_over
    ld de,NAMTBL2+256+12
    ld bc,9
    call LDIRVM

GameOver_Loop_loop2:
    halt
    call checkTrigger1
    jr z,GameOver_Loop_loop2

GameOver_goto_splash_screen:
    xor a
;    ld a,GAME_STATE_SPLASH
;    ld (game_state),a
    jp change_game_state



EnterMap_Loop:
    call clearAllTheSprites
    call raycast_reset_clear_buffer
    call raycast_render_buffer

    ld a,(player_x)
    ld (player_precision_x+1),a
    ld a,(player_y)
    ld (player_precision_y+1),a
    xor a
    ld (player_precision_x),a
    ld (player_precision_y),a

    call Game_updateRaycastVariables
    call raycastCompleteRender
    ld a,GAME_STATE_PLAYING
    ld (game_state),a
    jp Game_Loop_loop
