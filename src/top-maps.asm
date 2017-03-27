;-----------------------------------------------
; Decompresses and Copies the map pointed by hl to currentMap.
; It assumes that the variable (player_map) already contains the ID of the map
; we are loading, and re-opens the doors that should be open, and removes pickups 
; that were already picked up.
; - hl: pointer to the map to load
loadMap:
    ld de,raycast_buffer
    push de
    call pletter_unpack

    ; floor and ceiling types:
    pop hl  ; recover "raycast_buffer"
    ld de,raycast_floor_texture_color
    ldi
    ldi

    ; copy the map:
    ld de,currentMap
    ld bc,16*16
    ldir
    ; copy the pickups:
    ld de,currentMapPickups
    ld a,(hl)   ; n pickups
    add a,a
    add a,a
    inc a
    ld c,a
;    ld b,0 ; b must be 0 at this point
    ldir
    ; copy the enemies:
    ld de,currentMapEnemies
    ld a,(hl)   ; n enemies
    add a,a
    add a,a
    add a,a  
    add a,(hl)  ; a = a*9
    inc a
    ld c,a
;    ld b,0 ; b must be 0 at this point
    ldir
    ; copy the events:
    ld de,currentMapEvents
    ld a,(hl)   ; n events
    add a,a
    add a,(hl)  ; a = a*3
    inc a
    ld c,a
;    ld b,0 ; b must be 0 at this point
    ldir
    ; copy the messages:
    ld de,currentMapMessages
    ld c,(hl)
    inc hl
    ld b,(hl)
    inc hl
    ld a,b
    or c
    jr z,loadMap_finding_doors   ;; skip if we need to just copy 0 bytes
    ldir

loadMap_finding_doors:
    ; find all the doors:
    xor a
    ld hl,currentMapDoorLocations
    ld (hl),a
    inc hl
    ld (hl),a    ;; this assumes that MAX_DOORS_PER_MAP = 2
    dec hl
    ld de,currentMap
    ld b,0
loadMap_find_all_doors:
    ld a,(de)
    cp MAP_TILE_DOOR
    jr nz,loadMap_find_all_doors_nodoor
    ld (hl),e
    inc hl
loadMap_find_all_doors_nodoor:
    inc de
    djnz loadMap_find_all_doors

    ; reopen the doors that are supposed to be open:
    ld a,(player_map)
    add a,a  ; a = (player_map)*2
    ld ix,currentMapDoorLocations
    ld hl,globalState_doorsOpen
    ADD_HL_A    ; hl = globalState_doorsOpen + (player_map)*2
    ld b,MAX_DOORS_PER_MAP
loadMap_reopening_doors_loop:
    ld d,currentMap/256
    ld a,(hl)
    or a
    jr z,loadMap_reopening_doors_loop_doorclosed
    ld e,(ix)   ; get the position of the door
    xor a
    ld (de),a
loadMap_reopening_doors_loop_doorclosed:
    inc hl
    inc ix
    djnz loadMap_reopening_doors_loop
loadMap_reopening_doors_loop_done:

    ; remove already picked-up items:
    ld a,(player_map)
    add a,a
    add a,a
    add a,a
    add a,a
    ld hl,globalState_itemsPickedUp
    ADD_HL_A    ; hl = globalState_itemsPickedUp + (player_map)*16
    ld de,currentMapPickups+1
    ld b,MAX_PICKUPS_PER_MAP
loadMap_remove_pickedup_items_loop:
    ld a,(hl)
    or a
    jr z,loadMap_remove_pickedup_items_loop_not_picked_up
    ; picked up
    xor a
    ld (de),a   ; clear the pick-up
loadMap_remove_pickedup_items_loop_not_picked_up:
    inc hl
    inc de
    inc de
    inc de
    inc de
    djnz loadMap_remove_pickedup_items_loop

    ; remove killed bosses:
    ld a,(player_map)
    cp MAP_CATACOMBS2
    jr z,loadmap_remove_killed_ker
    cp MAP_MEDUSA2
    jr z,loadmap_remove_killed_medusa
    cp MAP_KERES2
    jr z,loadmap_remove_killed_final_kers
    ret


loadmap_remove_killed_ker:
    ld a,(globalState_BossesKilled)
loadmap_remove_killed_ker_2:
    or a
    ret z
    xor a
    ld (currentMapEnemies+1),a
    ret

loadmap_remove_killed_medusa:
    ld a,(globalState_BossesKilled+1)
    jr loadmap_remove_killed_ker_2
;    or a
;    ret z
;    xor a
;    ld (currentMapEnemies+1),a
;    ret

loadmap_remove_killed_final_kers:
    ld a,(globalState_BossesKilled+3)
    or a
    jp z,loadmap_remove_killed_final_kers2
    xor a
    ld (currentMapEnemies+1+ENEMY_STRUCT_SIZE),a
loadmap_remove_killed_final_kers2:
    ld a,(globalState_BossesKilled+2)
    jr loadmap_remove_killed_ker_2
;    or a
;    ret z
;    xor a
;    ld (currentMapEnemies+1),a
;    ret


;-----------------------------------------------
; Gets the tile type at the position in the map indicated by (player_x), (player_y)
; - input;
;   - b: y coordinate
;   - c: x coordinate
; - output:
;   - a: currentMap[(c/16)+(b/16)*16];
getMapPosition:
    push bc
    ld a,b
    and #f0     
    ld b,a
    ld a,c
    rlca
    rlca
    rlca
    rlca
    and #0f ; these sequence of 5 instructions, is equivalent to 4 srl a, but faster
    add a,b
    ld b,currentMap/256
    ld c,a
    ld a,(bc)  ;; a = currentMap[(player_x/16)+(player_y/16)*16];
    pop bc
    ret


;-----------------------------------------------
; opens the door in the map in position:
;   - b: y coordinate
;   - c: x coordinate
; returns:
;   - a: tile in the map in the specified position after opening the door
openDoor:
    ld a,(player_keys)
    or a
    jp z,openDoor_nokeys
    dec a
    ld (player_keys),a
    call update_UI_keys
    ld a,b
    and #f0     
    ld b,a
    ld a,c
    rlca
    rlca
    rlca
    rlca
    and #0f ; these sequence of 5 instructions, is equivalent to 4 srl a, but faster
    add a,b
    push hl
    ld h,currentMap/256
    ld l,a
    xor a
    ld (hl),a  ;; currentMap[(player_x/16)+(player_y/16)*16] = 0;
    ld b,l  ;; offset of the door

    ; record the open door in the first empty position of globalState_doorsOpen+(player_map)*2:
    ld a,(player_map)
    add a,a  ; a = (player_map)*2
    ld de,currentMapDoorLocations
    ld hl,globalState_doorsOpen
    ADD_HL_A    ; hl = globalState_doorsOpen + (player_map)*2
openDoor_findSpot_loop:
    ld a,(de)
    cp b
    jp z,openDoor_foundSpot
    inc de
    inc hl
    jr openDoor_findSpot_loop
openDoor_foundSpot:
    ld (hl),1   ; mark the door as open

    ld hl,SFX_door_open
    call playSFX
    pop hl
    xor a 
    ret
openDoor_nokeys:
    ld a,MAP_TILE_DOOR
    ret


;-----------------------------------------------
; checks whether a given position is in the light of sight of the camera
; for this, this function uses a Bresenham line drawing algorithm to draw a line from:
;   - ((last_raycast_camera_x),(last_raycast_camera_y)) to ((ix+1),(ix+2))
;   - z flag is set if the position is in line of sight
lineOfSightCheck:
    ld a,(last_raycast_camera_y)
    xor (ix+2)
    and #f0
    jp z,quick_lineOfSightCheck_x

    ld a,(last_raycast_camera_x)
    xor (ix+1)
    and #f0
    jp z,quick_lineOfSightCheck_y

    ld a,(last_raycast_camera_y)
    ld d,a
    ld a,(ix+2)
    sub d
    ld d,a  ; d = delta_y

    ld a,(last_raycast_camera_x)
    ld e,a
    ld a,(ix+1)
    sub e
    ld e,a  ; e = delta_x
    ld c,1      ; c = 1 marks that we just started, and that the camera might be inside of a wall, but it's fine

    ; start position in  ((last_raycast_camera_x),(last_raycast_camera_y)):
    ld hl,(last_raycast_camera_x)

lineOfSightCheck_deltas_computed:
    ld a,e
    or a
    jp m,lineOfSightCheck_negative_delta_x

    ld a,d
    or a
    jp m,lineOfSightCheck_3rd_4th_quadrant
lineOfSightCheck_1st_2nd_quadrant:
    ; we know we are either in the 1st or 2nd quadrant:
    ; y
    ; |    /
    ; | 1 /
    ; |  /
    ; | / 2
    ; |/
    ; +-----x 
    cp e   
    jp m,lineOfSightCheck_2nd_quadrant
lineOfSightCheck_1st_quadrant:
    ; delta_y is positive and |delta_y| > |delta_x|
    ld a,e
    add a,a
    sub d       ; a = error_term = 2*|delta_x| - delta_y
    ld b,d      ; we will execute "d" iterations
lineOfSightCheck_1st_quadrant_loop:
    call lineOfSightCheck_collision_check
    ret nz
    or a
    jp m,lineOfSightCheck_1st_quadrant_continue
    inc l   ; move on the x dimension
    sub d
lineOfSightCheck_1st_quadrant_continue:
    add a,e
    inc h   ; move on the y dimension
    djnz lineOfSightCheck_1st_quadrant_loop
    xor a
    ret

lineOfSightCheck_2nd_quadrant:
    ; delta_y is positive and |delta_y| < |delta_x|
    ld a,d
    add a,a
    sub e       ; a = error_term = 2*|delta_y| - delta_x
    ld b,e      ; we will execute "e" iterations
lineOfSightCheck_2nd_quadrant_loop:
    call lineOfSightCheck_collision_check
    ret nz
    or a
    jp m,lineOfSightCheck_2nd_quadrant_continue
    inc h   ; move on the y dimension
    sub e
lineOfSightCheck_2nd_quadrant_continue:
    add a,d
    inc l   ; move on the x dimension
    djnz lineOfSightCheck_2nd_quadrant_loop
    xor a
    ret

lineOfSightCheck_3rd_4th_quadrant:
    ; we know we are either in the 3rd or 4th quadrant:
    ; +-----x 
    ; |\
    ; | \ 3
    ; |  \
    ; | 4 \
    ; |    \
    ; -y
    ld a,e
    add a,d   ; a = |delta_x| - |delta_y|
    jp m,lineOfSightCheck_4th_quadrant
lineOfSightCheck_3rd_quadrant:
    ; delta_y is negative and |delta_y| < |delta_x|
    xor a
    sub d
    add a,a
    sub e       ; a = error_term = 2*|delta_y| - delta_x
    ld b,e      ; we will execute "e" iterations
lineOfSightCheck_3rd_quadrant_loop:
    call lineOfSightCheck_collision_check
    ret nz
    or a
    jp m,lineOfSightCheck_3rd_quadrant_continue
    dec h   ; move on the y dimension
    sub e
lineOfSightCheck_3rd_quadrant_continue:
    sub d   ; we subtract, since d is negative
    inc l   ; move on the x dimension
    djnz lineOfSightCheck_3rd_quadrant_loop
    xor a
    ret
    
lineOfSightCheck_4th_quadrant:
    ; delta_y is negative and |delta_y| > |delta_x|
    xor a
    sub d
    ld b,a      ; we will execute "|d|" iterations
    ld a,e      
    add a,a
    add a,d       ; a = error_term = 2*|delta_x| - |delta_y|
lineOfSightCheck_4th_quadrant_loop:
    call lineOfSightCheck_collision_check
    ret nz
    or a
    jp m,lineOfSightCheck_4th_quadrant_continue
    inc l   ; move on the x dimension
    add a,d     ; we add, since d is negative
lineOfSightCheck_4th_quadrant_continue:
    add a,e
    dec h   ; move on the y dimension
    djnz lineOfSightCheck_4th_quadrant_loop
    xor a
    ret

lineOfSightCheck_negative_delta_x:
    ld a,d
    or a
    jp m,lineOfSightCheck_5th_6th_quadrant
lineOfSightCheck_7th_8th_quadrant:
    ; we know we are either in the 7th or 8th quadrant:
    ;       y
    ;  \    |
    ;   \ 8 |
    ;    \  |
    ;   7 \ |
    ;      \|
    ; -x----+
    add a,e ;   a = |delta_y| - |delta_x|
    jp m,lineOfSightCheck_7th_quadrant
lineOfSightCheck_8th_quadrant:
    ; delta_y is positive and |delta_y| > |delta_x|
    ld a,e
    neg
    add a,a
    sub d       ; a = error_term = 2*|delta_x| - |delta_y|
    ld b,d      ; we will execute "d" iterations
lineOfSightCheck_8th_quadrant_loop:
    call lineOfSightCheck_collision_check
    ret nz
    or a
    jp m,lineOfSightCheck_8th_quadrant_continue
    dec l   ; move on the x dimension
    sub d
lineOfSightCheck_8th_quadrant_continue:
    sub e
    inc h   ; move on the y dimension
    djnz lineOfSightCheck_8th_quadrant_loop
    xor a
    ret

lineOfSightCheck_7th_quadrant:
    ; delta_y is positive and |delta_y| < |delta_x|
    ld a,e      
    neg
    ld b,a      ; we will execute "|e|" iterations
    ld a,d
    add a,a
    add a,e       ; a = error_term = 2*|delta_y| - |delta_x|
lineOfSightCheck_7th_quadrant_loop:
    call lineOfSightCheck_collision_check
    ret nz
    or a
    jp m,lineOfSightCheck_7th_quadrant_continue
    inc h   ; move on the y dimension
    add a,e
lineOfSightCheck_7th_quadrant_continue:
    add a,d
    dec l   ; move on the x dimension
    djnz lineOfSightCheck_7th_quadrant_loop
    xor a
    ret

lineOfSightCheck_5th_6th_quadrant:
    ; we know we are either in the 5th or 6th quadrant:
    ; -x----+
    ;      /|
    ;   6 / |
    ;    /  |
    ;   / 5 |
    ;  /    |
    ;      -y
    neg
    add a,e ; a = |delta_y| - |delta_x|
    jp p,lineOfSightCheck_5th_quadrant
lineOfSightCheck_6th_quadrant:
    ; delta_y is negative and |delta_y| < |delta_x|
    ld a,e      
    neg
    ld b,a      ; we will execute "|e|" iterations
    xor a
    sub d
    add a,a
    add a,e       ; a = error_term = 2*|delta_y| - |delta_x|
lineOfSightCheck_6th_quadrant_loop:
    call lineOfSightCheck_collision_check
    ret nz
    or a
    jp m,lineOfSightCheck_6th_quadrant_continue
    dec h   ; move on the y dimension
    add a,e
lineOfSightCheck_6th_quadrant_continue:
    sub d   ; we subtract, since d is negative
    dec l   ; move on the x dimension
    djnz lineOfSightCheck_6th_quadrant_loop
    xor a
    ret
    
lineOfSightCheck_5th_quadrant:
    ; delta_y is negative and |delta_y| > |delta_x|
    xor a
    sub d
    ld b,a      ; we will execute "|d|" iterations
    ld a,e      
    neg
    add a,a
    add a,d       ; a = error_term = 2*|delta_x| - |delta_y|
lineOfSightCheck_5th_quadrant_loop:
    call lineOfSightCheck_collision_check
    ret nz
    or a
    jp m,lineOfSightCheck_5th_quadrant_continue
    dec l   ; move on the x dimension
    add a,d     ; we add, since d is negative
lineOfSightCheck_5th_quadrant_continue:
    sub e
    dec h   ; move on the y dimension
    djnz lineOfSightCheck_5th_quadrant_loop
    xor a
    ret


lineOfSightCheck_collision_check:
    push hl
    push bc
    ld b,a
    ld a,l
    rlca
    rlca
    rlca
    rlca
    and #0f ; these sequence of 5 instructions, is equivalent to 4 srl a, but faster
    ld l,a
    ld a,h
    and #f0
    add a,l
    ld l,a
    ld h,currentMap/256
    ld a,(hl)
    or a
    jp z,lineOfSightCheck_collision_no_wall
    ld a,c
    or a
    jp z,lineOfSightCheck_collision_wall
    ; it's a wall, but since c = 1 (it might be the camera starting inside of a wall, so ignore)
    xor a   ; clear the flags as if there was no collision
    ld a,b
    pop bc
    pop hl
    ret

lineOfSightCheck_collision_wall:
    or #80  ; set the flags for collision
    ld a,b
    pop bc
    pop hl
    ret

lineOfSightCheck_collision_no_wall:
    ld a,b
    pop bc
    pop hl
    ld c,0  ; we mark that we have reached a stated where we are not inside of a wall
    ret


quick_lineOfSightCheck_x:
    ; this code does a line-of-sight-check at coarse map coordinates:
    ld a,(last_raycast_camera_x)
    rlca
    rlca
    rlca
    rlca
    and #0f ; these sequence of 5 instructions, is equivalent to 4 srl a, but faster
    ld b,a  ; we store coarse "x" coordinates for later
    ld a,(last_raycast_camera_y)
    and #f0
    add a,b
    ld l,a
    ld h,currentMap/256 ; hl now has the map pointer of ((last_raycast_camera_x),(last_raycast_camera_y))

    ld c,(ix+1)
    srl c
    srl c
    srl c
    srl c   ; now "b" has the coarse start "x", and "c" the coarse target "x"

    ;; we skip the first tile of the map, since the camera could start inside of a wall
    ld a,b
    cp c    ; if we made it to "x", no collision! return! (z flag is set, so, we are good)
    ret z 
    jp p,quick_lineOfSightCheck_x_decrease
    jp quick_lineOfSightCheck_x_increase

quick_lineOfSightCheck_x_loop:
    ld a,(hl)
    or a
    ret nz  ; if we find a wall, we stop!
    ld a,b
    cp c    ; if we made it to "x", no collision! return! (z flag is set, so, we are good)
    ret z 
    jp p,quick_lineOfSightCheck_x_decrease
quick_lineOfSightCheck_x_increase:
    inc a
    ld b,a
    inc l
    jp quick_lineOfSightCheck_x_loop
quick_lineOfSightCheck_x_decrease:
    dec a
    ld b,a
    dec l
    jp quick_lineOfSightCheck_x_loop


quick_lineOfSightCheck_y:
    ; this code does a line-of-sight-check at coarse map coordinates:
    ld a,(last_raycast_camera_x)
    rlca
    rlca
    rlca
    rlca
    and #0f ; these sequence of 5 instructions, is equivalent to 4 srl a, but faster
    ld c,a
    ld a,(last_raycast_camera_y)
    ld b,a
    and #f0
    add a,c
    ld l,a
    ld h,currentMap/256 ; hl now has the map pointer of ((last_raycast_camera_x),(last_raycast_camera_y))

    srl b
    srl b
    srl b
    srl b
    ld c,(ix+2)
    srl c
    srl c
    srl c
    srl c   ; now "b" has the coarse start "x", and "c" the coarse target "x"

    ;; we skip the first tile of the map, since the camera could start inside of a wall
    ld a,b
    cp c    ; if we made it to "x", no collision! return! (z flag is set, so, we are good)
    ret z 
    jp p,quick_lineOfSightCheck_y_decrease
    jp quick_lineOfSightCheck_y_increase

quick_lineOfSightCheck_y_loop:
    ld a,(hl)
    or a
    ret nz  ; if we find a wall, we stop!
    ld a,b
    cp c    ; if we made it to "y", no collision! return! (z flag is set, so, we are good)
    ret z 
    jp p,quick_lineOfSightCheck_y_decrease
quick_lineOfSightCheck_y_increase:
    inc a
    ld b,a
    ld a,l
    add a,16
    ld l,a
    jp quick_lineOfSightCheck_y_loop
quick_lineOfSightCheck_y_decrease:
    dec a
    ld b,a
    ld a,l
    add a,-16
    ld l,a
    jp quick_lineOfSightCheck_y_loop


