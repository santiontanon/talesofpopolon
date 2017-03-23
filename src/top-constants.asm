;-----------------------------------------------
; BIOS calls:
DCOMPR: equ #0020
ENASLT: equ #0024
WRTVDP: equ #0047
WRTVRM: equ #004d
SETWRT: equ #0053
FILVRM: equ #0056
LDIRMV: equ #0059
LDIRVM: equ #005c
CHGMOD: equ #005f
CHGCLR: equ #0062
GICINI: equ #0090   
WRTPSG: equ #0093 
RDPSG:  equ #0096
CHSNS:  equ #009c
CHGET:  equ #009f
CHPUT:  equ #00a2
GTSTCK: equ #00d5
GTTRIG: equ #00d8
SNSMAT: equ #0141
RSLREG: equ #0138
RDVDP:  equ #013e
KILBUF: equ #0156
CHGCPU:	equ #0180
;-----------------------------------------------
; System variables
;VDP_DATA: equ #98	
VDP.DR:	equ #0006
VDP.DW:	equ #0007
VDP_REGISTER_0: equ #f3df
CLIKSW: equ #f3db       ; keyboard sound
FORCLR: equ #f3e9
BAKCLR: equ #f3ea
BDRCLR: equ #f3eb
PUTPNT: equ #f3f8
GETPNT: equ #f3fa
KEYS:   equ #fbe5    
KEYBUF: equ #fbf0
EXPTBL: equ #fcc1
TIMI:   equ #fd9f       ; timer interrupt hook
HKEY:   equ #fd9a       ; hkey interrupt hook
;-----------------------------------------------
; VRAM map in Screen 2
CHRTBL2:  equ     #0000   ; pattern table address
SPRTBL2:  equ     #3800   ; sprite pattern address          
NAMTBL2:  equ     #1800   ; name table address 
CLRTBL2:  equ     #2000   ; color table address             
SPRATR2:  equ     #1b00   ; sprite attribute address
;-----------------------------------------------
RLE_META: equ	#ff
;-----------------------------------------------
; Raycasting engine configuration:
RAYCAST_SIDE_BORDER:	equ	4	;; if this is changed, I need to change the default values for "ROM_initial_rendering_blocks"
RAYCAST_ROWS_PER_BANK:	equ	8
RAYCAST_SCANLINES: 	equ  	0
RAYCAST_COLOR: 		equ 	1
RAYCAST_BORDER_PATTERN:	equ	255
RAYCAST_DISTANCE_THRESHOLD:	equ (RAYCAST_ROWS_PER_BANK*4)-4

;-----------------------------------------------
; Game constants:
GAME_STATE_SPLASH:	equ	0
GAME_STATE_TITLE:	equ	1
GAME_STATE_STORY:	equ	2
GAME_STATE_PLAYING:	equ	3
GAME_STATE_GAME_OVER:	equ	4
GAME_STATE_ENTER_MAP:	equ	5
GAME_STATE_ENDING:	equ	6


N_SPRITE_DEPTHS:	equ	4
N_SPRITES_PER_DEPTH:	equ	4	; ("assignSprite" assumes this is 4, if this is changed, that function needs to be changed)
; sprites and sprite patterns 0-0 are for knight and sword
FIRST_SPRITE:		equ	4

KNIGHT_SPRITE:		equ	1
KNIGHT_OUTLINE_SPRITE:	equ	2
KNIGHT_COLOR:		equ	7
KNIGHT_SILVER_COLOR:	equ	14
KNIGHT_GOLD_COLOR:	equ	10
KNIGHT_OUTLINE_COLOR: 	equ 	1
SWORD_SPRITE:		equ	3
SWORD_COLOR:		equ	7
GOLDSWORD_COLOR:	equ	10

PLAYER_STATE_WALKING:	equ	0
PLAYER_STATE_ATTACK:	equ	1
PLAYER_STATE_COOLDOWN:	equ	2

N_WEAPONS:		equ 	3
N_SECONDARY_WEAPONS:	equ	4
N_ARMORS:		equ	3

HOURGLASS_TIME:		equ	41

MAX_PICKUPS_PER_MAP:	equ 	16	; if this value is changed, the code that updates globalState_itemsPickedUp has to be changed
MAX_ENEMIES_PER_MAP:	equ 	16
MAX_EVENTS_PER_MAP:	equ	8
MAX_MESSAGES_PER_MAP:	equ	4
MAX_DOORS_PER_MAP:	equ	2	; if this value is changed, the code that updates globalState_doorsOpen has to be changed

MAP_TUNNEL:		equ	0
MAP_FORTRESS1:		equ 	1
MAP_FORTRESS2:		equ 	2
MAP_CATACOMBS1:		equ 	3
MAP_CATACOMBS2:		equ 	4
MAP_MEDUSA1:		equ 	5
MAP_MEDUSA2:		equ 	6
MAP_KERES1:		equ 	7
MAP_KERES2:		equ 	8

N_MAPS:			equ	9

MAX_ARROWS:		equ 	2	; (several memory structures in main assume this value)
ENEMY_STRUCT_SIZE:	equ	9
ARROW_STRUCT_SIZE:	equ	10

ITEM_SWORD:		equ	1
ITEM_GOLDSWORD:		equ	2
ITEM_ARROW:		equ	3
ITEM_ICEARROW:		equ	4
ITEM_HOURGLASS:		equ	5
ITEM_SILVERARMOR:	equ	6
ITEM_GOLDARMOR:		equ	7
ITEM_POTION:		equ	8
ITEM_HEART:		equ	9
ITEM_KEY:		equ	10

; Sprite pattern assignment: (the first 4 are for the knight and sword, and the 4 after that for the secondary weapon)
SPRITE_PATTERN_ARROW:	equ	4
SPRITE_PATTERN_CHEST: 	equ	8
SPRITE_PATTERN_POTION: 	equ	12
SPRITE_PATTERN_HEART: 	equ	16
SPRITE_PATTERN_KEY: 	equ	20
SPRITE_PATTERN_ENEMIES:	equ	24	; the patterns 24 to 31 are reserved for enemies

; this value is fake, when the assignSprite encounters it, it will use it for the color but use the SPRITE_PATTERN_ARROW for the sprite (in this way, I can have different arrow colors)
SPRITE_PATTERN_ICEARROW:equ	0

SPRITE_PATTERN_LARGE:	equ	0	
SPRITE_PATTERN_MEDIUM:	equ	1
SPRITE_PATTERN_SMALL:	equ	2	
SPRITE_PATTERN_TINY:	equ	3	

ENEMY_EXPLOSION_COLOR:	equ	15

; enemy types:
ENEMY_EXPLOSION:	equ	1
ENEMY_RAT_H:		equ	2
ENEMY_RAT_V:		equ	3
ENEMY_BLOB:		equ	4
ENEMY_SKELETON:		equ	5
ENEMY_KNIGHT:		equ	6
ENEMY_SNAKE:		equ	7
ENEMY_MEDUSA:		equ	8
ENEMY_MEDUSA_STONE:	equ	9
ENEMY_KER:		equ	10	; this one drops a key
ENEMY_KER2:		equ	11	; this is the final boss
ENEMY_KER3:		equ	12	; this is the final boss
ENEMY_SWITCH:		equ	13	; this is really not an enemy, but handled as one
ENEMY_BULLET:		equ	14

; indexes of the first patterns of each enemy in the enemy sprite pattern table
ENEMY_EXPLOSION_SPRITE_PATTERN:	equ 0
ENEMY_RAT_SPRITE_PATTERN:	equ 4
ENEMY_BLOB_SPRITE_PATTERN:	equ 12
ENEMY_SKELETON_SPRITE_PATTERN:	equ 20
ENEMY_KNIGHT_SPRITE_PATTERN:	equ 32
ENEMY_SNAKE_SPRITE_PATTERN:	equ 44
ENEMY_MEDUSA_SPRITE_PATTERN:	equ 52
ENEMY_KER_SPRITE_PATTERN:	equ 68
ENEMY_BULLET_SPRITE_PATTERN:	equ 92

ENEMY_SWITCH_RIGHT_SPRITE_PATTERN:	equ 84
ENEMY_SWITCH_LEFT_SPRITE_PATTERN:	equ 88

SWITCH_STATE_RIGHT:		equ 0
SWITCH_STATE_LEFT:		equ 1

MAP_TILE_DOOR:		equ	3
MAP_TILE_EXIT:		equ	4
MAP_TILE_MIRROR_WALL:	equ	8

;-----------------------------------------------
; EVENTS:
EVENT_OPEN_GATE:		equ 4
EVENT_CHANGE_OTHER_SWITCH:	equ 5
EVENT_OPEN_MEDUSA1_GATE:	equ 6
EVENT_PASSWORD:			equ 7

;-----------------------------------------------
; Music related constants:
MAX_SONG_SIZE:			equ 1800	; (since that's about the size of the in-game song)

MUSIC_INSTRUMENT_SQUARE_WAVE:   equ 0
MUSIC_INSTRUMENT_PIANO:         equ 1 
MUSIC_INSTRUMENT_WIND:         	equ 2   

SFX_CMD_END:            	equ #f5
MUSIC_CMD_SET_INSTRUMENT:       equ #f6
MUSIC_CMD_PLAY_INSTRUMENT_CH1:  equ #f7
MUSIC_CMD_PLAY_INSTRUMENT_CH2:  equ #f8
MUSIC_CMD_PLAY_INSTRUMENT_CH3:  equ #f9
;MUSIC_CMD_REPEAT:         equ  #fa
;MUSIC_CMD_END_REPEAT:     equ  #fb
MUSIC_CMD_GOTO:           	equ  #fc
MUSIC_CMD_SKIP:           	equ  #fd
;MUSIC_CMD_MULTISKIP:      equ  #fe
MUSIC_CMD_END:            	equ  #ff

JPCODE:         equ  #C3
