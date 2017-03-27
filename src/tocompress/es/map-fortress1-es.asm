	include "../top-constants.asm"

	org #0000

floortypeandcolor:
;    db 0
    db #e0
ceilingtypeandcolor:
;    db 0
    db #f0   
map:
	db 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
    db 2,0,0,0,0,0,0,0,0,0,0,6,0,0,0,2
    db 2,0,0,0,2,2,0,0,0,0,2,2,0,0,0,2
    db 2,0,2,0,2,2,0,0,0,0,2,2,0,0,0,2
    db 2,0,2,0,2,2,2,2,6,2,2,2,0,2,2,2
    db 2,0,2,0,2,2,0,0,0,0,2,2,0,2,2,2
    db 2,0,2,0,2,2,0,0,0,0,2,2,0,2,2,2
    db 2,5,2,0,2,2,2,2,8,2,2,2,0,2,2,2
    db 2,2,2,0,0,0,2,2,0,2,0,3,0,2,2,2
    db 2,5,2,0,2,0,2,2,4,2,0,2,0,2,2,2
    db 2,0,2,0,2,0,2,5,5,2,0,2,0,2,4,2
    db 2,0,2,0,7,0,0,0,0,0,0,7,0,2,0,2
    db 2,0,0,0,2,0,0,0,0,0,0,2,0,0,0,2
    db 2,0,0,0,7,0,2,0,0,2,0,7,5,2,2,2
    db 4,0,0,0,2,0,0,0,0,0,0,2,2,2,2,2
    db 2,2,2,2,2,2,2,6,6,2,2,2,2,2,2,2
pickups:
    db 1
    ; item type, x, y, sprite
    db ITEM_KEY   , 1*16+8,6*16+8,SPRITE_PATTERN_KEY
enemies:
    db 12
    ; enemy type, x, y, sprite, color, hit points, state1, state2, state3
    db ENEMY_RAT_V      , 3*16+8, 1*16+8,    ENEMY_RAT_SPRITE_PATTERN,      13, 1,0,0,0
    db ENEMY_RAT_V      ,12*16+8, 1*16+8,    ENEMY_RAT_SPRITE_PATTERN,      13, 1,0,0,0
    db ENEMY_SNAKE      , 1*16+8, 1*16+8,    ENEMY_SNAKE_SPRITE_PATTERN,    12, 1,0,0,0       
    db ENEMY_SNAKE      , 1*16+8, 5*16+8,    ENEMY_SNAKE_SPRITE_PATTERN,    12, 1,0,0,0       
    db ENEMY_BLOB       , 5*16+8, 8*16+8,    ENEMY_BLOB_SPRITE_PATTERN,     12, 4,0,0,0        
    db ENEMY_BLOB       ,10*16+8, 8*16+8,    ENEMY_BLOB_SPRITE_PATTERN,     12, 4,0,0,0        
    db ENEMY_BLOB       ,12*16+8, 4*16+8,    ENEMY_BLOB_SPRITE_PATTERN,      8, 6,0,0,0        
    db ENEMY_SNAKE      , 7*16+4, 3*16+8,    ENEMY_SNAKE_SPRITE_PATTERN,    10, 2,0,0,0       
    db ENEMY_SNAKE      , 9*16+12,3*16+8,    ENEMY_SNAKE_SPRITE_PATTERN,    10, 2,0,0,0  
    ; for switches, state1 is the initial state, state2 is the event triggered, state3 is the parameter of the event
    db ENEMY_SWITCH     ,14*16+8, 1*16+8,    ENEMY_SWITCH_RIGHT_SPRITE_PATTERN,   15, 1,SWITCH_STATE_RIGHT,EVENT_OPEN_GATE,8+4*16
    db ENEMY_SWITCH     ,14*16+8, 3*16+8,    ENEMY_SWITCH_RIGHT_SPRITE_PATTERN,   15, 1,SWITCH_STATE_RIGHT,EVENT_OPEN_GATE,11+1*16
    db ENEMY_SWITCH     , 6*16+8, 5*16+8,    ENEMY_SWITCH_RIGHT_SPRITE_PATTERN,   15, 1,SWITCH_STATE_RIGHT,EVENT_OPEN_GATE,8+4*16  

events_map:
    db 3
    ; x, y, event ID (the first 4 IDs are reserved for 4 potential messages below (each of them
    ;                        4 lines of 22 characters each))
    db #10,#60,1
    db #c0,#c0,2
    db #10,#a0,EVENT_PASSWORD
messages_map:
    dw 22*12 ;; length of the message data block below
    db "   LA ESTATUA DICE:   "
    db "                      "
    db "                      "
    db "                      "

    db "   LA ESTATUA DICE:   "
    db "DEBES VESTIR DE PLATA "
    db "PARA CRUZAR EL ESPEJO!"
    db "                      "

    db "   LA ESTATUA DICE:   "
    db "LAS CATACUMBAS. DONDE "
    db "LAS ALMAS PERDIDAS SON"
    db "ENCADENADAS...        "
