	include "../top-constants.asm"

	org #0000

floortypeandcolor:
;    db 1
    db #e0
ceilingtypeandcolor:
;    db 0
    db #60   
map:
	db 2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1
	db 2,2,2,2,0,0,2,0,0,0,0,0,0,0,0,1
	db 2,2,2,2,0,0,2,1,1,0,1,1,1,1,0,1
	db 6,0,0,0,0,0,5,1,1,0,0,1,0,1,0,1
	db 2,2,2,2,0,0,2,1,1,1,0,1,0,0,0,1
	db 1,1,2,2,0,0,2,1,1,1,0,1,1,1,1,1
	db 1,1,1,2,2,3,2,1,1,1,0,1,1,1,0,1
	db 1,0,1,1,1,0,1,1,0,0,0,0,0,6,0,1
	db 1,0,1,1,1,0,1,1,1,1,0,1,1,1,1,1
	db 1,8,1,1,1,0,0,0,0,0,0,0,0,0,0,1
	db 1,0,1,1,1,1,0,1,1,1,1,1,1,1,1,1
	db 1,0,0,0,0,0,0,1,1,1,1,2,2,2,2,2
	db 1,1,1,0,1,1,1,1,0,0,0,0,0,2,2,2
	db 1,1,1,0,1,0,0,0,0,0,0,0,0,3,0,5
	db 1,1,1,0,0,0,1,1,0,0,0,0,0,2,0,2
	db 1,1,1,1,1,1,1,1,1,1,1,2,2,2,4,2
pickups_map:
    db 5
    ; item type, x, y, sprite
    db ITEM_SWORD , 12*16+8,3*16+8,SPRITE_PATTERN_CHEST     
    db ITEM_POTION, 14*16+8,9*16+8,SPRITE_PATTERN_POTION
    db ITEM_HOURGLASS , 1*16+8,7*16+8,SPRITE_PATTERN_CHEST     
    db ITEM_KEY   , 5*16+8,3*16+8,SPRITE_PATTERN_KEY
    db ITEM_KEY   , 14*16+8,6*16+8,SPRITE_PATTERN_KEY
enemies_map:
    db 11
    ; enemy type, x, y, sprite, color, hit points, state1, state2, state3
    ; for switches, state1 is the initial state, state2 is the event triggered, state3 is the parameter of the event
    db ENEMY_RAT_V  	,10*16+8, 3*16+8,    ENEMY_RAT_SPRITE_PATTERN,  	13, 1,0,0,0
    db ENEMY_RAT_V  	, 5*16+8, 9*16+8,    ENEMY_RAT_SPRITE_PATTERN,  	13, 1,0,0,0
    db ENEMY_RAT_H   	, 3*16+8,11*16+8,    ENEMY_RAT_SPRITE_PATTERN, 		13, 1,0,0,0        
    db ENEMY_RAT_H   	, 3*16+8,14*16+8,    ENEMY_RAT_SPRITE_PATTERN, 		13, 1,0,0,0       
    db ENEMY_RAT_H   	, 7*16+8, 1*16+8,    ENEMY_RAT_SPRITE_PATTERN, 		13, 1,0,0,0       
    db ENEMY_SNAKE      ,14*16+8, 4*16+8,    ENEMY_SNAKE_SPRITE_PATTERN, 	12, 1,0,0,0       
    db ENEMY_SNAKE      , 7*16+8, 1*16+8,    ENEMY_SNAKE_SPRITE_PATTERN, 	12, 1,0,0,0       
    db ENEMY_SNAKE      ,14*16+8, 9*16+8,    ENEMY_SNAKE_SPRITE_PATTERN, 	12, 1,0,0,0       
    db ENEMY_SNAKE      ,12*16+8,12*16+8,    ENEMY_SNAKE_SPRITE_PATTERN, 	12, 1,0,0,0       
    db ENEMY_SNAKE      ,12*16+8,14*16+8,    ENEMY_SNAKE_SPRITE_PATTERN, 	12, 1,0,0,0       
    db ENEMY_SWITCH     , 7*16+8, 1*16+8,    ENEMY_SWITCH_RIGHT_SPRITE_PATTERN,   15, 1,SWITCH_STATE_RIGHT,EVENT_OPEN_GATE,13+7*16       
events_map:
    db 2
    ; x*16, y*16, event ID  (the first 4 IDs are reserved for 4 potential messages below (each of them
    ;                        4 lines of 22 characters each))
    db #50,#30,0
    db #e0,#d0,1
messages_map:
    dw 22*8 ;; length of the message data block below
    db "   LA ESTATUA DICE:   "
    db "SOY UN MENSAJERO DE   "
    db "THANATOS.TOMA LA LLAVE"
    db "Y ENTRA EN LA CAVERNA!"

    db "   LA ESTATUA DICE:   "
    db "LA ENTRADA HACIA LA   "
    db "FORTALEZA ESTA CERCA. "
    db "ADELANTE, POPOLON!    "
