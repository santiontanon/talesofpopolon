	include "../top-constants.asm"

	org #0000

floortypeandcolor:
;    db 0
    db #60
ceilingtypeandcolor:
;    db 0
    db #d0   
map:
	db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
    db 4,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1
    db 1,0,1,1,1,1,0,0,0,0,0,1,1,1,1,1
    db 8,0,8,1,8,1,0,8,0,8,0,1,1,1,1,1
    db 1,0,1,8,1,1,0,0,0,0,0,1,0,1,1,1
    db 8,0,8,0,8,1,1,6,1,1,1,1,0,1,1,1
    db 1,0,1,0,1,1,1,0,1,1,1,1,0,1,1,1
    db 8,0,8,0,8,1,1,0,0,0,0,0,0,1,1,1
    db 1,0,1,0,1,1,1,1,0,1,1,1,6,1,1,1
    db 1,0,0,0,0,0,0,0,0,6,6,0,0,0,0,4
    db 1,1,1,1,1,3,1,1,3,1,1,1,1,1,1,1
    db 1,0,0,0,0,0,1,0,0,0,1,1,1,1,1,1
    db 1,0,0,0,0,0,1,0,0,0,1,1,1,1,1,1
    db 1,0,0,0,0,0,1,1,0,1,1,1,1,1,1,1
    db 1,0,0,0,0,0,1,1,0,0,0,1,1,1,1,1
    db 1,1,1,1,1,1,1,1,8,1,1,1,1,1,1,1
pickups:
    db 3
    ; item type, x, y, sprite
    db ITEM_KEY   , 3*16+8,5*16+8,SPRITE_PATTERN_KEY
    db ITEM_KEY   ,12*16+8,4*16+8,SPRITE_PATTERN_KEY
    db ITEM_ARROW , 8*16+8,2*16+8,SPRITE_PATTERN_CHEST     
enemies:
    db 12
    ; enemy type, x, y, sprite, color, hit points, state1, state2, state3
    db ENEMY_SNAKE      , 1*16+4, 7*16+8,    ENEMY_SNAKE_SPRITE_PATTERN,    10, 2,0,0,0       
    db ENEMY_SNAKE      , 8*16+4,13*16+8,    ENEMY_SNAKE_SPRITE_PATTERN,    10, 2,0,0,0       
    db ENEMY_SKELETON   , 3*16+4,13*16+8,    ENEMY_SKELETON_SPRITE_PATTERN,    14, 2,0,0,0       
    db ENEMY_SKELETON   , 5*16+4,13*16+8,    ENEMY_SKELETON_SPRITE_PATTERN,    14, 2,0,0,0       
    db ENEMY_SKELETON   , 1*16+4,14*16+8,    ENEMY_SKELETON_SPRITE_PATTERN,    14, 2,0,0,0       
    db ENEMY_SKELETON   , 6*16+4, 4*16+8,    ENEMY_SKELETON_SPRITE_PATTERN,    14, 2,0,0,0       
    db ENEMY_SKELETON   ,10*16+4, 4*16+8,    ENEMY_SKELETON_SPRITE_PATTERN,    14, 2,0,0,0       
    db ENEMY_RAT_H      , 7*16+8, 7*16+8,    ENEMY_RAT_SPRITE_PATTERN,      13, 1,0,0,0        
    ; for switches, state1 is the initial state, state2 is the event triggered, state3 is the parameter of the event
    db ENEMY_SWITCH     , 1*16+8,14*16+8,    ENEMY_SWITCH_RIGHT_SPRITE_PATTERN,   15, 1,SWITCH_STATE_RIGHT,EVENT_OPEN_GATE,7+5*16
    db ENEMY_SWITCH     ,10*16+8,14*16+8,    ENEMY_SWITCH_RIGHT_SPRITE_PATTERN,   15, 1,SWITCH_STATE_RIGHT,EVENT_OPEN_GATE,9+9*16
    db ENEMY_SWITCH     ,10*16+8, 2*16+8,    ENEMY_SWITCH_RIGHT_SPRITE_PATTERN,   15, 1,SWITCH_STATE_RIGHT,EVENT_OPEN_GATE,10+9*16
    db ENEMY_SWITCH     ,12*16+8, 9*16+8,    ENEMY_SWITCH_RIGHT_SPRITE_PATTERN,   15, 1,SWITCH_STATE_RIGHT,EVENT_OPEN_GATE,12+8*16
events_map:
    db 3
    ; x, y, event ID (the first 4 IDs are reserved for 4 potential messages below (each of them
    ;                        4 lines of 22 characters each))
    db #10,#20,0
    db #30,#50,1
    db #80,#E0,2
messages_map:
    dw 22*12 ;; length of the message data block below
    db "OH GODS OF OLYMPUS!   "
    db "THIS PLACE IS FULL OF "
    db "TRAPED SOULS. THIS IS "
    db "A TORTURE CHAMBER!    "

    db "   A PRISONER SAYS:   "
    db "POPOLON! IT IS YOU!!  "
    db "SAVE US! THE KERES DID"
    db "THIS!!                "

    db "   A PRISONER SAYS:   "
    db "THE KERES ARE SPIRITS "
    db "OF DEATH! THEY DESPISE"
    db "THANATOS!             "
