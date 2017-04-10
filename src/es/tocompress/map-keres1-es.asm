	include "../../top-constants.asm"

	org #0000

floortypeandcolor:
;    db 0
    db #e0
ceilingtypeandcolor:
;    db 0
    db #40   
map:
    db 1,1,1,1,5,1,1,1,1,1,7,1,7,1,7,1
    db 1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,4
    db 1,0,0,1,0,1,1,1,1,1,7,1,7,1,7,1
    db 1,0,0,1,0,0,0,0,0,1,1,1,1,1,1,1
    db 1,0,0,1,0,0,0,0,0,1,1,1,0,0,0,1
    db 1,0,1,1,1,1,1,1,0,1,1,1,0,0,0,1
    db 1,0,0,0,0,1,1,1,0,1,1,1,0,0,0,1
    db 1,0,0,0,0,1,1,1,3,1,1,1,1,1,0,1
    db 1,0,0,0,0,1,1,1,0,0,0,0,0,0,0,1
    db 1,0,1,1,0,1,1,1,0,0,0,0,0,0,0,1
    db 1,0,0,1,0,1,1,1,0,0,0,0,0,0,0,1
    db 1,1,0,1,0,3,0,1,1,1,1,1,1,1,0,1
    db 1,1,0,1,1,1,0,1,1,0,7,0,7,0,0,1
    db 9,0,0,1,1,1,0,1,1,0,0,0,0,0,0,1
    db 1,1,0,1,0,6,0,0,0,0,7,0,7,0,0,1
    db 1,1,9,1,1,1,1,1,1,1,1,1,1,1,1,1
pickups:
    db 3
    ; item type, x, y, sprite
    db ITEM_KEY       , 2*16+8, 1*16+8,SPRITE_PATTERN_KEY
    db ITEM_KEY       ,12*16+8, 4*16+8,SPRITE_PATTERN_KEY
    db ITEM_GOLDARMOR , 4*16+8,14*16+8,SPRITE_PATTERN_CHEST     
enemies:
    db 14
    ; enemy type, x, y, sprite, color, hit points, state1, state2, state3
    db ENEMY_SWITCH     , 4*16+8,4*16+8,    ENEMY_SWITCH_RIGHT_SPRITE_PATTERN,   15, 1,SWITCH_STATE_RIGHT,EVENT_OPEN_GATE,5+14*16

    db ENEMY_SNAKE      , 2*16+12,7*16+8,    ENEMY_SNAKE_SPRITE_PATTERN,    10, 2,0,0,0  
    db ENEMY_SNAKE      , 4*16+12,7*16+8,    ENEMY_SNAKE_SPRITE_PATTERN,    10, 2,0,0,0  
    db ENEMY_SNAKE      , 1*16+12,2*16+8,    ENEMY_SNAKE_SPRITE_PATTERN,     9, 3,0,0,0  
    db ENEMY_SNAKE      , 2*16+12,2*16+8,    ENEMY_SNAKE_SPRITE_PATTERN,     9, 3,0,0,0  

    db ENEMY_BLOB       ,10*16+8,13*16+8,    ENEMY_BLOB_SPRITE_PATTERN,      8, 6,0,0,0        
    db ENEMY_BLOB       ,12*16+8,13*16+8,    ENEMY_BLOB_SPRITE_PATTERN,      9, 8,0,0,0        

    db ENEMY_SKELETON   ,11*16+4,10*16+8,    ENEMY_SKELETON_SPRITE_PATTERN,   11, 4,0,0,0       
    db ENEMY_SKELETON   ,11*16+4, 8*16+8,    ENEMY_SKELETON_SPRITE_PATTERN,   11, 4,0,0,0       
    db ENEMY_SKELETON   ,12*16+4, 5*16+8,    ENEMY_SKELETON_SPRITE_PATTERN,   10, 5,0,0,0       
    db ENEMY_SKELETON   ,14*16+4, 5*16+8,    ENEMY_SKELETON_SPRITE_PATTERN,   10, 5,0,0,0       

    db ENEMY_KNIGHT     , 8*16+4, 5*16+8,    ENEMY_KNIGHT_SPRITE_PATTERN,      7, 3,0,0,0       
    db ENEMY_KNIGHT     , 4*16+4, 3*16+8,    ENEMY_KNIGHT_SPRITE_PATTERN,     10, 5,0,0,0       
    db ENEMY_KNIGHT     , 4*16+4, 4*16+8,    ENEMY_KNIGHT_SPRITE_PATTERN,     10, 5,0,0,0       

events_map:
    db 1
    ; x, y, event ID (the first 4 IDs are reserved for 4 potential messages below (each of them
    ;                        4 lines of 22 characters each))
    db #40,#10,0
messages_map:
    dw 22*4 ;; length of the message data block below
    db "   LA ESTATUA DICE:   "
    db "LA MORADA DE LAS KERES"
    db "ESTA CERCA! SUERTE EN "
    db "LA BATALLA FINAL!     "
