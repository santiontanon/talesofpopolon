    include "../top-constants.asm"

    org #4000   ; Start in the 2nd slot

;-----------------------------------------------
    db "AB"     ; ROM signature
    dw Execute  ; start address
    db 0,0,0,0,0,0,0,0,0,0,0,0
;-----------------------------------------------


;-----------------------------------------------
; Code that gets executed when the game starts
Execute:
    ; init the stack:
    ld sp,#F380
    ; reset some interrupts to make sure it runs in some MSX computers 
    ; with disk controllers installed in some interrupt handlers
    di
    ld a,#C9
    ld (HKEY),a
;    ld (TIMI),a
    ei

    call setupROMRAMslots

    ; Silence and init keyboard:
    xor a
    ld (CLIKSW),a
    ld (MSXTurboRMode),a    ; Z80 mode
    ; Change background colors:
    ld (BAKCLR),a
    ld (BDRCLR),a
    call CHGCLR

    call Game_trigger_CPUmode_change    ; if we are in a turbo R, switch to R800 smooth mode
    
    ; Activate Turbo mode in PAnasonic MSX2+ WX/WSX/FX models:
    ; Code sent to me by Pitpan, taken from here: http://map.grauw.nl/resources/msx_io_ports.php
    ld a,8
    out (#40),a     ;out the manufacturer code 8 (Panasonic) to I/O port 40h
    in a,(#40)      ;read the value you have just written
    cpl             ;complement all bits of the value
    cp 8            ;if it does not match the value you originally wrote,
    jr nz,Not_WX    ;it is not a WX/WSX/FX.
    xor a           ;write 0 to I/O port 41h
    out (#41),a     ;and the mode changes to high-speed clock    
Not_WX:

    ld a,2      ; Change screen mode
    call CHGMOD

    ;; clear the screen, and load graphics
    xor a
    call FILLSCREEN
    call setupPatterns

    call StopPlayingMusic
    call SETUP_MUSIC_INTERRUPT

    xor a
;    ld a,GAME_STATE_SPLASH
;    ld a,GAME_STATE_TITLE
;    ld a,GAME_STATE_STORY
;    ld a,GAME_STATE_PLAYING
;    ld (game_state),a
    jp change_game_state

;-----------------------------------------------
; additional assembler files
    include "../top-auxiliar.asm"
    include "../top-gamestates.asm"
    include "../top-splash.asm"
    include "../top-title.asm"
    include "../top-story.asm"    
    include "../top-gameloop.asm"
    include "../top-gameplay.asm"
    include "../top-input.asm"
    include "../top-sincostables.asm"
    include "../top-gfx.asm"
    include "../top-raycasting.asm"
    include "../top-maps.asm"
    include "../top-enemies.asm"
    include "../top-sound.asm"
    include "../top-password.asm"

story_pletter:
    incbin "tocompress/story-es.plt"
ending_pletter:
    incbin "tocompress/ending-es.plt"
map_tunnel1_pletter:
    incbin "tocompress/map-tunnel1-es.plt"
map_fortress1_pletter:
    incbin "tocompress/map-fortress1-es.plt"
map_fortress2_pletter:
    incbin "tocompress/map-fortress2-es.plt"
map_catacombs1_pletter:
    incbin "tocompress/map-catacombs1-es.plt"
map_catacombs2_pletter:
    incbin "tocompress/map-catacombs2-es.plt"
map_medusa1_pletter:
    incbin "../tocompress/map-medusa1.plt"
map_medusa2_pletter:
    incbin "../tocompress/map-medusa2.plt"
map_keres1_pletter:
    incbin "tocompress/map-keres1-es.plt"
map_keres2_pletter:
    incbin "tocompress/map-keres2-es.plt"

;-----------------------------------------------
; Game variables to be copied to RAM
ROMtoRAM:
ROM_player_precision_x:
    dw (1*16+8)*256
ROM_player_precision_y:
    dw (3*16+8)*256
ROM_player_angle:
    db 0
ROM_game_cycle:
    db 0
ROM_player_map:
    db MAP_TUNNEL
ROM_player_x:
    db 1*16+8
ROM_player_y:
    db 3*16+8
ROM_player_health:
    db 6
ROM_available_weapons:
    db 1,0,0
ROM_available_secondary_weapons:
    db 1,0,0,0
ROM_available_armors:
    db 1,0,0
ROM_previous_keymatrix0:
    db #ff
ROM_spritePatternCacheTable:
    db #ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff

ROM_texture_colors:
    db #80  ; wall 1 
    db #40  ; wall 2
    db #a0  ; door
    db #f0  ; staircase
    db #e0  ; face
    db #f0  ; gate (non - openable door)
    db #70  ; statue
    db #f0  ; mirror wall 
    db #f0  ; staircase
    db #a0  ; prisoner
    db #a0  ; prisoner

;; these define the columns that will be rendered by the raycasting engine at each
;; sub-frame. The first sub-frame renders 0 - 33, the second 34 - 83, etc.
ROM_initial_rendering_blocks_160:
    db 0    ;; note: this assumes that RAYCAST_SIDE_BORDER = 4
    db 34
    db 84
    db 132
    db 160
    dw CHRTBL2+(8*2+8-RAYCAST_ROWS_PER_BANK)*8
    dw CLRTBL2+(8*2+8-RAYCAST_ROWS_PER_BANK)*8
    dw CHRTBL2+(256*8)+2*8*8
    dw CLRTBL2+(256*8)+2*8*8
    db 5
    db 32-(RAYCAST_SIDE_BORDER+2)*2
    dw (32-(RAYCAST_SIDE_BORDER+2)*2)*8*8
    db 20

endROMtoRAM:



ROM_initial_rendering_blocks_192:
    db 0    ;; note: this assumes that RAYCAST_SIDE_BORDER = 4
    db 42
    db 100
    db 158
    db 192
ROM_initial_rendering_address
    dw CHRTBL2+(8-RAYCAST_ROWS_PER_BANK)*8
    dw CLRTBL2+(8-RAYCAST_ROWS_PER_BANK)*8
    dw CHRTBL2+(256*8)
    dw CLRTBL2+(256*8)
ROM_amoount_of_bytes_to_render: ; in units of 256 bytes
    db 6
ROM_raycast_angle_offset:
    db 32-RAYCAST_SIDE_BORDER*2
ROM_raycast_amount_to_clear:
    dw (32-RAYCAST_SIDE_BORDER*2)*8*8
ROM_raycast_sprite_angle_cutoff:
    db 24


ROM_initial_rendering_blocks_128:
    db 0    ;; note: this assumes that RAYCAST_SIDE_BORDER = 4
    db 28
    db 66
    db 104
    db 128
    dw CHRTBL2+(8*4+8-RAYCAST_ROWS_PER_BANK)*8
    dw CLRTBL2+(8*4+8-RAYCAST_ROWS_PER_BANK)*8
    dw CHRTBL2+(256*8)+4*8*8
    dw CLRTBL2+(256*8)+4*8*8
    db 4
    db 32-(RAYCAST_SIDE_BORDER+4)*2
    dw (32-(RAYCAST_SIDE_BORDER+4)*2)*8*8
    db 16

UI_message_equip_barehand:
    db "MANOS"
UI_message_equip_barehand_end:
UI_message_equip_sword:
    db "ESPADA"
UI_message_equip_sword_end:
UI_message_equip_goldsword:
    db "ESPADA DE ORO"
UI_message_equip_goldsword_end:

;UI_message_equip_secondary_barehand:
;    db "MANOS"
;UI_message_equip_secondary_barehand_end:
UI_message_equip_secondary_arrow:
    db "FLECHAS"
UI_message_equip_secondary_arrow_end:
UI_message_equip_secondary_icearrow:
    db "FLECHAS DE HIELO"
UI_message_equip_secondary_icearrow_end:
UI_message_equip_secondary_hourglass:
    db "RELOJ"
UI_message_equip_secondary_hourglass_end:

UI_message_equip_armor_iron:
    db "ARMADURA DE HIERRO"
UI_message_equip_armor_iron_end:
UI_message_equip_armor_silver:
    db "ARMADURA DE PLATA"
UI_message_equip_armor_silver_end:
UI_message_equip_armor_gold:
    db "AMRADURA DE ORO"
UI_message_equip_armor_gold_end:

UI_message_z80_mode:
    db "Z80"
UI_message_z80_mode_end:

UI_message_r800smooth_mode:
    db "R800S"
UI_message_r800smooth_mode_end:

UI_message_r800fast_mode:
    db "R800F"
UI_message_r800fast_mode_end:

UI_message_pause:
    db "PAUSE"
UI_message_pause_end:


UI_message_game_over:
    db "GAME OVER"

UI_message_enter_password:
    db "ENTRA LA CLAVE"
UI_message_enter_password_end:

splash_line2:  ; length 8
    db "PRESENTA"
splash_line1:  ; length 12
    db "BRAIN  GAMES" 

title_press_space:  
    db "PULSA ESPACIO PARA JUGAR"
title_press_space_end:

title_credits:  ; length 20
    db "SANTI ONTANON   2017"

fadeInTitleColors:  ; the two zeroes at the beginning and end are sentinels
    db 0,#ff,#ef,#7f,#5f,#4f,0
End:


    ds ((($-1)/#4000)+1)*#4000-$

    include "../top-ram.asm"
