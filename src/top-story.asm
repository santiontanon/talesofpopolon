;-----------------------------------------------
; Story screen loop
GameStory_Loop:
    call clearScreenLeftToRight
;    ld a,8
;    ld (Music_tempo),a
    ld hl,LoPStorySongPletter
    call PlayCompressedSong

    ; 1) decompress the story text:
    ld hl,story_pletter
    ld de,raycast_buffer
    push de
    call pletter_unpack

    ; 2) story block 1:
    pop de
    ld a,story_block1_lines
    call GameStory_block_loop

    ; 3) story block 2:
    ld bc,18
    ld de,story_image1_name_table
    ld hl,story_image1_pattern_data
    call GameStory_draw_vignette
    ld de,raycast_buffer+story_block1_lines*32
    ld a,story_block2_lines
    call GameStory_block_loop

    ; 4) story block 3:
    ld bc,15
    ld de,story_image2_name_table
    ld hl,story_image2_pattern_data
    call GameStory_draw_vignette
    ld de,raycast_buffer+(story_block1_lines+story_block2_lines)*32
    ld a,story_block3_lines
    call GameStory_block_loop

    ; 5) story block 4:
    ld bc,18   ; fortress
    ld de,story_image3_name_table
    ld hl,story_image3_pattern_data
    call GameStory_draw_vignette
    ld de,raycast_buffer+(story_block1_lines+story_block2_lines+story_block3_lines)*32
    ld a,story_block4_lines
    call GameStory_block_loop

    call StopPlayingMusic

    jp SplashScreen_Loop_goto_title


;-----------------------------------------------
; Ending screen loop
Ending_Loop:
    call clearScreenLeftToRight
    call decodePatternsToAllBanks
    ld hl,LoPStorySongPletter
    call PlayCompressedSong

    ; 1) decompress the ending text:
    ld hl,ending_pletter
    ld de,raycast_buffer
    push de
    call pletter_unpack

    ; 2) ending block 1:
    ld bc,15
    ld de,story_image2_name_table
    ld hl,story_image2_pattern_data
    call GameStory_draw_vignette
    pop de
    ld a,ending_block1_lines
    call GameStory_block_loop

    call StopPlayingMusic

    jp GameOver_goto_splash_screen


;-----------------------------------------------
; displays one story block:
; parameters:
;   de: pointer to the text
;   a: number of lines
GameStory_block_loop:
    ld c,a  
    xor a
    ld (story_skip),a
    ld hl,NAMTBL2+8*32
GameStory_block_loop_next_line:
    push bc
    ld b,32
GameStory_block_loop_line_loop:
    ld a,(de)
    push hl
    push de
    call WRTVRM

    cp ' '
    jr z,GameStory_block_loop_line_loop_after_wait

    ld a,(story_skip)
    or a
    jr nz,GameStory_block_loop_line_loop_after_wait

    push bc
    call checkTrigger1updatingPrevious
    pop bc
    or a
    jr z,GameStory_block_loop_after_skip
    ld a,1
    ld (story_skip),a
GameStory_block_loop_after_skip:

    halt
    halt
    halt
    halt

GameStory_block_loop_line_loop_after_wait:
    pop de
    pop hl
    inc de
    inc hl

    djnz GameStory_block_loop_line_loop
    pop bc
    dec c
    jr nz,GameStory_block_loop_next_line

    ld bc,30*50 ; wait for 30 seconds on 50Hz machines (a bit less on 60Hz ones)
GameStory_block_loop_wait_for_user:
    halt
    dec bc
    ld a,b
    or c
    jr z,GameStory_block_loop_wait_for_user_end   ; after a while, we return
    push bc
    call checkTrigger1updatingPrevious
    pop bc
    or a
    jr z,GameStory_block_loop_wait_for_user
GameStory_block_loop_wait_for_user_end:
    jp clearScreenLeftToRight


;-----------------------------------------------
; displays a vignette for the story:
; parameters:
;   bc: number of patterns in the compressed data
;   de: pointer to the name table of the vignette
;   hl: pointer to the compressed pattern and attribute data
GameStory_draw_vignette:
    push de
    push bc

    ; unpack the pattern and attribute data:
    ld de,raycast_color_buffer
    call pletter_unpack

    ; copy the pattern data:
    ld hl,raycast_color_buffer
    ld de,CHRTBL2+100*8
    ld bc,18*8  ; it's probably less, but in this way, I don't need to compute it
    call LDIRVM
    ; copy the color data:
    pop hl  ; number of patterns
    add hl,hl
    add hl,hl
    add hl,hl
    ld bc,raycast_color_buffer
    add hl,bc   ; hl = raycast_color_buffer + numpatterns*8
    ld de,CLRTBL2+100*8
    ld bc,18*8  ; it's probably less, but in this way, I don't need to compute it
    call LDIRVM
    ; copy the name table:
    pop hl  ; we pop "pointer to the name table of the vignette" into hl
    ld de,NAMTBL2+32*2+12
    ld bc,7
    push bc
    push hl
    call LDIRVM

    pop hl
    pop bc
    push bc
    add hl,bc
    ld de,NAMTBL2+32*3+12
    push hl
    call LDIRVM

    pop hl
    pop bc
    add hl,bc
    ld de,NAMTBL2+32*4+12
    call LDIRVM

    ; write under bar:
    ld hl,NAMTBL2+32*5+11
    ld a,16
    call WRTVRM
    ld hl,NAMTBL2+32*5+12
    ld a,17
    ld bc,7
    call FILVRM
    ld hl,NAMTBL2+32*5+19
    ld a,18
    jp WRTVRM


; story block sizes:
story_block1_lines: EQU 7
story_block2_lines: EQU 7
story_block3_lines: EQU 7
story_block4_lines: EQU 10

ending_block1_lines: EQU 11


story_pletter:
    incbin "tocompress/story.plt"

ending_pletter:
    incbin "tocompress/ending.plt"

    include "top-story-patterns.asm"
