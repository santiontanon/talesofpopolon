;-----------------------------------------------
; Splash screen loop
SplashScreen_Loop:
    call clearScreenLeftToRight

    ; set foreground and background of tiles 32 - 96 to 15
    ld a,#ff
    ld bc,(96-32)*8
    ld hl,CLRTBL2+32*8
    push bc
    call FILVRM
    pop bc
    ld hl,CLRTBL2+(256+32)*8
    push bc
    call FILVRM
    pop bc
    ld hl,CLRTBL2+(512+32)*8
    call FILVRM

    ; convert to a white screen by using the animation that uses tiles 12*16+7 to 12*16+11
    xor a
SplashScreen_Loop_fadeToWhite:
    push af
    call hl_equal_a_times_32
    ld bc,NAMTBL2
    add hl,bc
    ld de,-32
    ld a,12*16+11
SplashScreen_Loop_fadeToWhite_internal:
    push hl
    ld bc,NAMTBL2
    sbc hl,bc
    pop hl
    jp m,SplashScreen_Loop_fadeToWhite_internal_skip
    push hl
    ld bc,NAMTBL2+768
    sbc hl,bc
    pop hl
    jp p,SplashScreen_Loop_fadeToWhite_internal_skip
    push hl
    ld bc,32
    call FILVRM
    pop hl
SplashScreen_Loop_fadeToWhite_internal_skip:
    add hl,de
    dec a
    cp 12*16+6
    jr nz,SplashScreen_Loop_fadeToWhite_internal
    pop af
    halt
    inc a
    cp 24+6
    jr nz,SplashScreen_Loop_fadeToWhite

    ld hl,splash_line1
    ld de,NAMTBL2+32*10+10
    ld bc,12
    call LDIRVM

    ld hl,splash_line2
    ld de,NAMTBL2+32*12+12
    ld bc,8
    call LDIRVM

    ; change the foreground color to 14, then 7, then 5, then 4
    ld de,fadeInTitleColors+2
    ld a,(de)
SplashScreen_Loop_fadeTitleIn:
    call SplashScreen_Loop_fadeCycle
    inc de
    ld a,(de)
    or a
    jr nz,SplashScreen_Loop_fadeTitleIn 

    xor a
    ld hl,previous_trigger1
    ld (hl),a

    ld bc,250
SplashScreen_Loop_loop:
    dec bc
    ld a,b
    or c
    jr z,SplashScreen_Loop_done

    halt

    ;; wait for space to be pressed:
    push bc
    call checkTrigger1updatingPrevious
    pop bc
    or a
    jr z,SplashScreen_Loop_loop

SplashScreen_Loop_done:
    ; change the foreground color to 14, then 7, then 5, then 4
    ld de,fadeInTitleColors+5
    ld a,(de)
SplashScreen_Loop_fadeTitleOut:
    call SplashScreen_Loop_fadeCycle
    dec de
    ld a,(de)
    or a
    jr nz,SplashScreen_Loop_fadeTitleOut 

    call clearScreenLeftToRight

    ; set background of tiles 32 - 96 to 0
    call setupPatterns

SplashScreen_Loop_goto_title:
    ; space pressed, move on!
    ld a,GAME_STATE_TITLE
;    ld (game_state),a
    jp change_game_state

SplashScreen_Loop_fadeCycle:
    ld bc,(96-32)*8
    ld hl,CLRTBL2+(256+32)*8
    call FILVRM
    ld b,6
    jp waitBhalts

    