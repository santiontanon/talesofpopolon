    include "../top-constants.asm"

    org #4000   ; Start in the 2nd slot

;-----------------------------------------------
    db "AB"     ; ROM signature
    dw Execute  ; start address
    db 0,0,0,0,0,0,0,0,0,0,0,0
;-----------------------------------------------

; I brought this piece of data here, to use 12 bytes that were being wasted
; because of the 256-alignment of a table in top-auxiliar.asm
splash_line1:  ; length 12
    db "BRAIN  GAMES" 

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

    call Game_trigger_CPUmode_change    ; if we are in a turbo R, switch to R800 smooth mode
    
    ld a,2      ; Change screen mode
    call CHGMOD

    ; Change background colors:
    xor a
    ld (BAKCLR),a
    ld (BDRCLR),a
    call CHGCLR

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
    db #f0  ; unused

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

UI_message_equip_secondary_barehand:
    db "MANOS"
UI_message_equip_secondary_barehand_end:
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

title_press_space:  ; length: 19
    db " ESPACIO PARA JUGAR"

title_credits:  ; length 20
    db "SANTI ONTANON   2017"

fadeInTitleColors:  ; the two zeroes at the beginning and end are sentinels
    db 0,#ff,#ef,#7f,#5f,#4f,0
End:


    ds ((($-1)/#4000)+1)*#4000-$


;-----------------------------------------------
; Cartridge ends here, below is just a definition of the RAM space used by the game 
;-----------------------------------------------

    org #c000   ; RAM goes to the 4th slot
RAM:    
; Space for ROMtoRAM:
player_precision_x:     ds virtual 2
player_precision_y:     ds virtual 2
player_angle:           ds virtual 1
; game state variables:
game_cycle:             ds virtual 1
player_map:             ds virtual 1
player_x:               ds virtual 1
player_y:               ds virtual 1
player_health:          ds virtual 1
available_weapons:      ds virtual N_WEAPONS
available_secondary_weapons:    ds virtual N_SECONDARY_WEAPONS
available_armors:       ds virtual N_ARMORS
previous_keymatrix0:    ds virtual 1
;; Table that stores which patterns are currently loaded on the VDP sprite 
;; patterns 24 - 31.
;; the number here indexes the list of enemy sprite patterns (enemySpritePatterns)
spritePatternCacheTable:        ds virtual 8
texture_colors:         ds virtual 9

initial_rendering_blocks:   ds virtual 5
initial_rendering_address:  ds virtual 8
amoount_of_bytes_to_render: ds virtual 1
raycast_angle_offset:       ds virtual 1
raycast_amount_to_clear:    ds virtual 2
raycast_sprite_angle_cutoff: ds virtual 1


AdditionalRAM:  ;; things that are not copied from ROM at the beginning

game_state:             ds virtual 1
;; stores which exit the player entered, to know which map to load in the inter-map state
exit_entered: 
;; temporary variable used in the title screen for storing animation state
title_state:            ds virtual 1
title_state2:           ds virtual 1

memoryToClearOnNewGame:

game_over_cycle:        ds virtual 1
player_hit_timmer:      ds virtual 1
player_mana:            ds virtual 1
player_keys:            ds virtual 1
player_state:           ds virtual 1
player_state_cycle:     ds virtual 1
spritePatternCacheTableNextToErase:     ds virtual 1

; sprites:
knight_sprite_attributes:           ds virtual 4
knight_sprite_outline_attributes:   ds virtual 4
sword_sprite_attributes:            ds virtual 4
other_sprite_attributes:            ds virtual 4*(N_SPRITE_DEPTHS*N_SPRITES_PER_DEPTH)
knight_animation_frame:             ds virtual 1

sprites_available_per_depth:        ds virtual N_SPRITE_DEPTHS
assignSprite_y:                     ds virtual 1
assignSprite_x:                     ds virtual 1
assignSprite_sprite:                ds virtual 1
assignSprite_color:                 ds virtual 1
assignSprite_bank:                  ds virtual 1
assigningSpritesForAnEnemy:         ds virtual 1

; position of the camera in the frame that is currently rendered in the screen:
last_raycast_camera_x:              ds virtual 1
last_raycast_camera_y:              ds virtual 1
last_raycast_player_angle:          ds virtual 1

;; global game state:
globalState_doorsOpen:              ds virtual N_MAPS*MAX_DOORS_PER_MAP
globalState_itemsPickedUp:          ds virtual N_MAPS*MAX_PICKUPS_PER_MAP
globalState_BossesKilled:           ds virtual 4
current_weapon:                     ds virtual 1
current_secondary_weapon:           ds virtual 1
current_armor:                      ds virtual 1
current_armor_color:                ds virtual 1
arrow_data:                         ds virtual ARROW_STRUCT_SIZE*MAX_ARROWS
hourglass_timer:                    ds virtual 1
current_UI_message:                 ds virtual 32
current_UI_message_timer:           ds virtual 1
; whether SPACE/TRIGGER1 or M/TRIGGER2 were pressed in the previous game cycle or not
previous_trigger1:                  ds virtual 1
previous_trigger2:                  ds virtual 1

raycast_screen_size_change_requested:   ds virtual 1
CPUmode_change_requested:           ds virtual 1    

endOfMemoryToClearOnNewGame:

story_skip:                         ds virtual 1

; raycast variables:
raycast_player_x:                   ds virtual 1
raycast_player_y:                   ds virtual 1
raycast_camera_x:                   ds virtual 1
raycast_camera_y:                   ds virtual 1
raycast_player_angle:               ds virtual 1
raycast_first_column:               ds virtual 1
raycast_last_column:                ds virtual 1
raycast_column:                     ds virtual 1
raycast_row:                        ds virtual 1
;raycast_ray_x:                      ds virtual 1
;raycast_ray_y:                      ds virtual 1
raycast_camera_offset:              ds virtual 1
raycast_buffer_offset_bank1:        ds virtual 2
raycast_buffer_offset_bank2:        ds virtual 2
;raycast_previous_ray_x:             ds virtual 1
;raycast_previous_ray_y:             ds virtual 1
raycast_column_pixel_mask:          ds virtual 1
;raycast_floor_texture_type:         ds virtual 1
raycast_floor_texture_color:        ds virtual 1
;raycast_ceiling_texture_type:       ds virtual 1
raycast_ceiling_texture_color:      ds virtual 1
;; only the most significant byte, since the textures are 256-aligned:
raycast_texture_ptr:                ds virtual 1
raycast_column_x_offs_table_xangle_times_32:    ds virtual 2
;raycast_column_y_offs_table_xangle_times_32:    ds virtual 2
raycast_buffer:                     ds virtual (32-RAYCAST_SIDE_BORDER*2)*8*16
raycast_color_buffer:               ds virtual (32-RAYCAST_SIDE_BORDER*2)*8*16+1    ;; we add one, since to make it faster, in raycast_reset_clear_buffer, I overflow for one byte 

; sound variables:
Music_tempo:                        ds virtual 1
SFX_play:                           ds virtual 1
MUSIC_play:                         ds virtual 1
MUSIC_tempo_counter:                ds virtual 1
MUSIC_instruments:                  ds virtual 3
MUSIC_channel3_instrument_buffer:   ds virtual 1    ;; this stores the instrument of channel 3, which is special, since SFX might overwrite it
;MUSIC_skip_counter:                 ds virtual 1
MUSIC_start_pointer:                ds virtual 2  
SFX_pointer:                        ds virtual 2
MUSIC_pointer:                      ds virtual 2
;MUSIC_repeat_stack_ptr:             ds virtual 2
;MUSIC_repeat_stack:                 ds virtual 4*3
MUSIC_instrument_envelope_ptr:      ds virtual 3*2
;HKSAVE:                             ds virtual 5
music_buffer:                       ds virtual MAX_SONG_SIZE

MSXTurboRMode:                      ds virtual 1

patternCopyBuffer2:
password_buffer:                    ds virtual 32

textures_before:
    ;; align the map with multiples of 256 bytes, so that I can address them directly by 
    ;; modifying the low byte of the registers
    ds virtual ((($-1)/#100)+1)*#100-$

textures:                           ds virtual 16*16*9 ; only 9 textures at a time are allowed (due to memory constraints)

currentMap:                         ds virtual 16*16

patternCopyBuffer:                  ; this is used as an intermediate buffer, to copy patterns from one page of VDP to another
;; stores the texture of the floor (calculated in the ceiling)
raycast_floor_texture_buffer:       ds virtual 32

currentMapPickups:                  ds virtual 1+4*MAX_PICKUPS_PER_MAP
currentMapEnemies:                  ds virtual 1+ENEMY_STRUCT_SIZE*MAX_ENEMIES_PER_MAP
currentMapEvents:                   ds virtual 1+3*MAX_EVENTS_PER_MAP
currentMapMessages:                 ds virtual 4*22*MAX_MESSAGES_PER_MAP

currentMapDoorLocations:            ds virtual MAX_DOORS_PER_MAP

endOfRAM:

