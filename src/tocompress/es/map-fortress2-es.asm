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
    db 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
    db 2,2,2,2,2,2,2,4,2,2,2,2,2,2,2,2
    db 2,2,2,2,2,7,2,0,2,7,2,2,2,2,2,2
    db 2,2,2,2,5,0,0,0,0,0,6,0,0,4,2,2
    db 2,2,2,2,2,2,0,0,0,2,2,2,2,2,2,2
    db 2,2,2,2,2,2,2,8,2,2,2,4,2,2,2,2
    db 2,2,2,2,2,2,0,0,0,2,2,0,2,2,2,2
    db 2,2,2,2,5,0,0,0,0,0,0,0,2,2,2,2
    db 2,2,2,2,2,7,2,2,2,7,2,2,2,2,2,2
    db 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
    db 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
    db 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
    db 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
    db 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
    db 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
pickups:
    db 0
    ; item type, x, y, sprite
enemies:
    db 2
    ; enemy type, x, y, sprite, color, hit points, state1, state2, state3
    db ENEMY_SWITCH     ,5*16+8, 4*16+8,    ENEMY_SWITCH_RIGHT_SPRITE_PATTERN,   15, 1,SWITCH_STATE_RIGHT,EVENT_OPEN_GATE,10+4*16
    db ENEMY_SWITCH     ,12*16+8, 4*16+8,    ENEMY_SWITCH_RIGHT_SPRITE_PATTERN,  15, 1,SWITCH_STATE_RIGHT,EVENT_OPEN_GATE,10+4*16

events_map:
    db 2
    ; x, y, event ID (the first 4 IDs are reserved for 4 potential messages below (each of them
    ;                        4 lines of 22 characters each))
    db #50,#40,1
    db #50,#80,EVENT_PASSWORD
messages_map:
    dw 22*8 ;; length of the message data block below
    db "   LA ESTATUA DICE:   "
    db "                      "
    db "                      "
    db "                      "

    db "   LA ESTATUA DICE:   "
    db "LAS KERES CAPTURARON A"
    db "UN GORGON QUE GUARDA  "
    db "SU MORADA! PREPARATE! "
