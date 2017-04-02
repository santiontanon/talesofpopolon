;-----------------------------------------------
; Assigns all the sprites corresponding to enemies to the sprite table
updateAndAssignEnemySprites:
    ld ix,currentMapEnemies
    ld a,(ix)   ; n enemies
    or a
    ret z
    inc ix
    ld b,a
    ld a,1
    ld (assigningSpritesForAnEnemy),a
updateAndAssignEnemySprites_loop:
    ld a,(ix)
    or a
    jr z,updateAndAssignEnemySprites_skip

    push bc
    call updateEnemy
    call assignEnemySprite
    pop bc

updateAndAssignEnemySprites_skip:
    ld de,ENEMY_STRUCT_SIZE
    add ix,de
    djnz updateAndAssignEnemySprites_loop
    xor a
    ld (assigningSpritesForAnEnemy),a
    ret

;-----------------------------------------------
; Determines if the player is closer than a certain distance to the enemy:
; - ix: pointer to enemy
; - b: maximum distance
; return value is:
; - in the "p" condition (p to true is if player is too far)
; - e,d: have the differences in x and y
isPlayerCloseToEnemy:
    ld a,(player_x)
    sub (ix+1)
    ld e,a
    jp p,isPlayerCloseToEnemy_positive_xdiff
    neg
isPlayerCloseToEnemy_positive_xdiff:
    cp b    ;; only update enemies that are inside of a radius of 4 tiles
    ret p
    ld a,(player_y)
    sub (ix+2)
    ld d,a
    jp p,isPlayerCloseToEnemy_positive_ydiff
    neg
isPlayerCloseToEnemy_positive_ydiff:
    cp b    ;; only update enemies that are inside of a radius of 4 tiles
    ret


;-----------------------------------------------
; Executes one update cycle of an enemy
; - parameters:
;   IX: pointer to the enemy parameters (type, x, y, sprite, color, ...)
updateEnemy:
    ld a,(hourglass_timer)
    or a
    ret nz  ;; if the hourglass is in use, do not update enemies

    ; if they are too far, also do not update them:
    ld b,64
    call isPlayerCloseToEnemy
    ret p

updateEnemy_check_which_enemy:
    ld a,(ix)
    bit 7,a
    jr nz,updateFrozenEnemy

    dec a
;    cp ENEMY_EXPLOSION
    jp z,updateExplosion
    dec a
;    cp ENEMY_RAT_H
    jp z,updateEnemyRatH
    dec a
;    cp ENEMY_RAT_V
    jp z,updateEnemyRatV
    dec a
;    cp ENEMY_BLOB
    jp z,updateEnemyBlob
    dec a
;    cp ENEMY_SKELETON
    jp z,updateEnemySkeleton
    dec a
;    cp ENEMY_KNIGHT
    jp z,updateEnemyKnight
    dec a
;    cp ENEMY_SNAKE
    jp z,updateEnemySnake
    dec a
;    cp ENEMY_MEDUSA
    jp z,updateEnemyMedusa
    dec a
;    cp ENEMY_MEDUSA_STONE
    jp z,updateEnemyMedusa
    dec a
    ; cp ENEMY_KER
    jp z,updateEnemyKer
    dec a
    ;cp ENEMY_KER2
    jp z,updateEnemyKer
    dec a
    ; cp ENEMY_KER3
    jp z,updateEnemyKer
    dec a
    ;; cp ENEMY_SWITCH
    ;; nothing to do for a switch (and yes, "switches" are handled as if they were enemies...)
    ret z
    dec a
;    cp ENEMY_BULLET
    jp z,updateEnemyBullet
    ret


updateFrozenEnemy:
    dec (ix+8)
    ret nz
    ; unfreeze!
    ld a,(ix)
    and #7f
    ld (ix),a
    ld a,(ix+7)
    ld (ix+4),a ; restore the old enemy color
    xor a
    ld (ix+6),a
    ld (ix+7),a
    ;ld (ix+8),a    ; no need to set this to 0, since we already know it is
    ret


checkEnemyHitPlayer:
    ld a,(player_hit_timmer)
    or a
    ret nz  ;; players cannot be hit when player_hit_timmer > 0

    ld b,4
    call isPlayerCloseToEnemy
    ret p
    
checkEnemyHitPlayer_playerBeingHit:
    ;; player being hit: iron armor: -3hp, silver armor: -2hp, gold armor: -1hp
    ld a,(player_health)
    or a
    jr z,checkEnemyHitPlayer_player_dead

;    push hl
    ld hl,SFX_playerhit    
    call playSFX
;    pop hl

    ld hl,player_health
    ld a,(current_armor)
    dec a
    jr z,checkEnemyHitPlayer_lose2hp
    dec a
    jr z,checkEnemyHitPlayer_lose1hp
checkEnemyHitPlayer_lose3hp:
    dec (hl)
    jr z,checkEnemyHitPlayer_player_dead
checkEnemyHitPlayer_lose2hp:
    dec (hl)
    jr z,checkEnemyHitPlayer_player_dead
checkEnemyHitPlayer_lose1hp:
    dec (hl)
    jr nz,checkEnemyHitPlayer_player_not_dead
checkEnemyHitPlayer_player_dead:
    ld a,GAME_STATE_GAME_OVER
    ld (game_state),a
    jp update_UI_health

checkEnemyHitPlayer_player_not_dead:
;    ld (player_health),a
    ld a,16
    ld (player_hit_timmer),a
    jp update_UI_health


updateExplosion:
    dec (ix+6)
    ret nz
    ld (ix),0     ;; make the explosion disappear
    ret

updateEnemyRatH:
    call checkEnemyHitPlayer
    ld a,(game_cycle)
    and #01
    jr z,updateEnemyRat_animation  ;; move only once every 2 cycles
    ld a,(ix+7)   ; state 2 (moving left or right)
    or a
    jr z,updateEnemyRatH_left
updateEnemyRatH_right:
    inc (ix+1)
    ld c,(ix+1)
    ld b,(ix+2)
    call getMapPosition
    or a
    jr z,updateEnemyRat_animation
    ; (collision) change direction
    dec (ix+1)
    xor a
    ld (ix+7),a
    jr updateEnemyRat_animation

updateEnemyRatH_left:
    dec (ix+1)
    ld c,(ix+1)
    ld b,(ix+2)
    call getMapPosition
    or a
    jr z,updateEnemyRat_animation
    ; (collision) change direction
    inc (ix+1)
    ld (ix+7),1

updateEnemyRat_animation:
    ld a,(game_cycle)
    and #02
    jr z,updateEnemyRat_sprite2
    ld (ix+3),ENEMY_RAT_SPRITE_PATTERN
    ret
updateEnemyRat_sprite2:
    ld (ix+3),ENEMY_RAT_SPRITE_PATTERN+4
    ret

updateEnemyRatV:
    call checkEnemyHitPlayer
    ld a,(game_cycle)
    and #01
    jr z,updateEnemyRat_animation  ;; move only once every 2 cycles
    ld a,(ix+7)   ; state 2 (moving up or down)
    or a
    jr z,updateEnemyRatV_up
updateEnemyRatH_down:
    inc (ix+2)
    ld c,(ix+1)
    ld b,(ix+2)
    call getMapPosition
    or a
    jr z,updateEnemyRat_animation
    ; (collision) change direction
    dec (ix+2)
    xor a
    ld (ix+7),a
    jr updateEnemyRat_animation

updateEnemyRatV_up:
    dec (ix+2)
    ld c,(ix+1)
    ld b,(ix+2)
    call getMapPosition
    or a
    jr z,updateEnemyRat_animation
    ; (collision) change direction
    inc (ix+2)
    ld (ix+7),1
    jr updateEnemyRat_animation


updateEnemyBlob:
    ld b,24
    call isPlayerCloseToEnemy
    jp p,updateEnemyBlob_animation

    ; move toward the player:
    ld a,(game_cycle)
    and #03
    call z,moveEnemyTowardED

    ; if the player is close, then check if we are touching the player
    call checkEnemyHitPlayer

updateEnemyBlob_animation
    ld a,(game_cycle)
    and #02
    jr z,updateEnemyBlob_sprite2
    ld (ix+3),ENEMY_BLOB_SPRITE_PATTERN
    ret
updateEnemyBlob_sprite2:
    ld (ix+3),ENEMY_BLOB_SPRITE_PATTERN+4
    ret


updateEnemySkeleton:
    ld b,48
    call isPlayerCloseToEnemy
    jp p,updateEnemySkeleton_animation

    ld a,(game_cycle)
    and #7f
    call z,enemyFireBullet  ; fire a bullet every once in a while    

    ; move toward the player:
    ld a,(game_cycle)
    and #03
    call z,moveEnemyTowardED

    ; if the player is close, then check if we are touching the player
    call checkEnemyHitPlayer

updateEnemySkeleton_animation
    ld a,(game_cycle)
    and #02   
    jr nz,updateEnemySkeleton_sprite2
    ld a,(game_cycle)
    and #04
    jr z,updateEnemySkeleton_sprite3
    ld (ix+3),ENEMY_SKELETON_SPRITE_PATTERN
    ret
updateEnemySkeleton_sprite2:
    ld (ix+3),ENEMY_SKELETON_SPRITE_PATTERN+4
    ret
updateEnemySkeleton_sprite3:
    ld (ix+3),ENEMY_SKELETON_SPRITE_PATTERN+8
    ret


updateEnemyKnight:
    ld b,48
    call isPlayerCloseToEnemy
    jp p,updateEnemyKnight_animation

    ld a,(game_cycle)
    and #7f
    call z,enemyFireBullet  ; fire a bullet every once in a while    

    ; move toward the player:
    ld a,(game_cycle)
    and #03
    call z,moveEnemyTowardED

    ; if the player is close, then check if we are touching the player
    call checkEnemyHitPlayer

updateEnemyKnight_animation
    ld a,(game_cycle)
    and #02   
    jr nz,updateEnemyKnight_sprite2
    ld a,(game_cycle)
    and #04
    jr z,updateEnemyKnight_sprite3
    ld (ix+3),ENEMY_KNIGHT_SPRITE_PATTERN
    ret
updateEnemyKnight_sprite2:
    ld (ix+3),ENEMY_KNIGHT_SPRITE_PATTERN+4
    ret
updateEnemyKnight_sprite3:
    ld (ix+3),ENEMY_KNIGHT_SPRITE_PATTERN+8
    ret


updateEnemySnake:
    ld b,48
    call isPlayerCloseToEnemy
    jp p,updateEnemySnake_animation

    ; move toward the player:
    ld a,(game_cycle)
    and #01
    call z,moveEnemyTowardED

    ; if the player is close, then check if we are touching the player
    call checkEnemyHitPlayer

updateEnemySnake_animation
    ld a,(game_cycle)
    and #02   
    jr nz,updateEnemySnake_sprite2
    ld a,(game_cycle)
    ld (ix+3),ENEMY_SNAKE_SPRITE_PATTERN
    ret
updateEnemySnake_sprite2:
    ld (ix+3),ENEMY_SNAKE_SPRITE_PATTERN+4
    ret


updateEnemyMedusa:
    inc (ix+8)
    ld a,(ix+8) ; state 3  < 64 medusa moves toward player, 64 - 128 stone, then reset
    and #7f
    cp 64
    jp p,updateEnemyMedusa_stone

    ; set medusa to skin color, and set it back to normal medusa:
    ld (ix+4),9
    ld (ix),ENEMY_MEDUSA

    ; check if player is close (no point, since this is larger than the 64 above):
;    ld b,80
;    call isPlayerCloseToEnemy
;    jp p,updateEnemyMedusa_animation

    ; move toward the player:
    ld a,(game_cycle)
    and #01
    call z,moveEnemyTowardED

    ; if the player is close, then check if we are touching the player
    call checkEnemyHitPlayer

updateEnemyMedusa_animation
    ld a,(game_cycle)
    and #02   
    jr nz,updateEnemyMedusa_sprite2
    ld (ix+3),ENEMY_MEDUSA_SPRITE_PATTERN
    ret
updateEnemyMedusa_sprite2:
    ld (ix+3),ENEMY_MEDUSA_SPRITE_PATTERN+8
    ret


updateEnemyMedusa_stone:
    call z,updateEnemyMedusa_spawn_snake    ; spawn a snake when it turns to stone

    ; set medusa to stone color, and make her invulnerable:
    ld (ix+4),14
    ld (ix),ENEMY_MEDUSA_STONE

    jp checkEnemyHitPlayer

updateEnemyMedusa_spawn_snake:
    call enemyFireBullet
    ; enemy type, x, y, sprite, color, hit points, state1, state2, state3
    ld (hl),ENEMY_SNAKE
    inc hl
    inc hl
    inc hl
    ld (hl),ENEMY_SNAKE_SPRITE_PATTERN
    inc hl
    ld (hl),2 ;; color
    ret


updateEnemyKer:
    inc (ix+8)

    ; check if player is close (no point since this is larger than the 64 above):
;    ld b,80
;    call isPlayerCloseToEnemy
;    jp p,updateEnemyKer_animation

    ld a,(game_cycle)
    and #3f
    call z,enemyFireBullet  ; fire a bullet every once in a while    

    ; move toward the player:
    ld a,(ix+8) ; state 3  < 64 ker moves toward player, 64 - 128 freezes
    and #7f
;    cp 104
;    jp p,updateEnemyKer_dash
    cp 64
    jp p,updateEnemyKer_movement_done

updateEnemyKer_dash_regular_movement:
    ld a,(game_cycle)
    and #01
    call z,moveEnemyTowardED
;    jp updateEnemyKer_movement_done

;updateEnemyKer_dash:
;    push de
;    call moveEnemyTowardED
;    pop de
;    jp updateEnemyKer_dash_regular_movement

updateEnemyKer_movement_done:
    ; if the player is close, then check if we are touching the player
    call checkEnemyHitPlayer

updateEnemyKer_animation
    ld a,(game_cycle)
    and #02   
    jr nz,updateEnemyKer_sprite2
    ld (ix+3),ENEMY_KER_SPRITE_PATTERN
    ret
updateEnemyKer_sprite2:
    ld (ix+3),ENEMY_KER_SPRITE_PATTERN+8
    ret


updateEnemyBullet:
    ; state 1 is the angle at which they move
    call moveEnemyBullet
    ld c,(ix+1)
    ld b,(ix+2)
    call getMapPosition
    or a    
    ; make bullet disappear:
    jr z,updateEnemyBullet_noWallHit
    ld (ix),0
    ret
updateEnemyBullet_noWallHit:
    ld a,(player_hit_timmer)
    or a
    ret nz  ;; players cannot be hit when player_hit_timmer > 0

    ld b,2
    call isPlayerCloseToEnemy
    jp m,checkEnemyHitPlayer_playerBeingHit
    ret

moveEnemyBullet:
    ; move in the desired direction:
    ld hl,cos_table
    ld b,0
    ld c,(ix+8) ;; angle of movement of the bullet
    add hl,bc
    add hl,bc
    push hl
    ld c,(hl)
    inc hl
    ld b,(hl)
    ld h,(ix+1)     ; (ix+1),(ix+6) for the 16bit high precision coordinates of the enemy
    ld l,(ix+6)
    add hl,bc
    ld (ix+1),h
    ld (ix+6),l

;    ld hl,sin_table
;    ld b,0
;    ld c,(ix+8) ;; angle of movement of the bullet
;    add hl,bc
;    add hl,bc
    pop hl
    ld bc,sin_table - cos_table
    add hl,bc
    ld c,(hl)
    inc hl
    ld b,(hl)
    ld h,(ix+2)     ; (ix+2),(ix+7) for the 16bit high precision coordinates of the enemy
    ld l,(ix+7)
    add hl,bc
    ld (ix+2),h
    ld (ix+7),l
    ret


;-----------------------------------------------
; Fires a bullet if possible, input:
; - d,e: difference in y,x of the player position
; - at the end, hl contains the pointer to the new bullet
enemyFireBullet:
    ; find available enemy spot:
    ld hl,currentMapEnemies
    ld b,(hl)
    inc hl
enemyFireBullet_loop:
    ld a,(hl)
    or a
    jr z,enemyFireBullet_foundspot
    ld de,ENEMY_STRUCT_SIZE
    add hl,de
    dec b
    jr nz,enemyFireBullet_loop
    ld a,(currentMapEnemies)
    cp MAX_ENEMIES_PER_MAP
    jp m,enemyFireBullet_newspot
    ret
enemyFireBullet_newspot:
    ld a,(currentMapEnemies)
    inc a
    ld (currentMapEnemies),a
enemyFireBullet_foundspot:
    push hl
    ld hl,SFX_fire_bullet_enemy
    call playSFX
    pop hl
    ; enemy type, x, y, sprite, color, hit points, state1, state2, state3
    push hl
    ld (hl),ENEMY_BULLET
    ld a,(ix+1)
    inc hl
    ld (hl),a
    inc hl
    ld a,(ix+2)
    ld (hl),a
    inc hl
    ld (hl),ENEMY_BULLET_SPRITE_PATTERN
    inc hl
    ld (hl),10    ; color
    inc hl
    ld (hl),1     ; hp
    inc hl
    xor a
    ld (hl),a     ; state 1
    inc hl
    ld (hl),a     ; state 2
    inc hl
    push hl
    ; angle between enemy and player:
    ld a,(player_x)
    sub (ix+1)
    ld b,a
    ld a,(player_y)
    sub (ix+2)
    ld c,a
    call atan2
    pop hl
    ld (hl),a   ; state 3
    pop hl  ; we recover the pointer to the beginning of the bullet
    ret


;-----------------------------------------------
; moves the enemy pointed at by ix toward the direction pointed by (e,d) as a vector
; this function assumes that the two state bytes are used to store the lower bytes of the x and y precision coordinates
moveEnemyTowardED:
    ; get the angle toward the desired direction:
    ld b,e  ; xdiff
    ld c,d  ; ydiff
    call atan2

    ; move in the desired direction:
    ld hl,cos_table
    ld b,0
    ld c,a
    add hl,bc
    add hl,bc
    push hl
    ld c,(hl)
    inc hl
    ld b,(hl)
    ld h,(ix+1)     ; (ix+1),(ix+6) for the 16bit high precision coordinates of the enemy
    ld l,(ix+6)
    add hl,bc
    ld b,(ix+2)
    ld c,h
    call getMapPosition
    or a
    jr nz,moveEnemyTowardED_skip_x
    ld (ix+1),h
    ld (ix+6),l
moveEnemyTowardED_skip_x:
    pop hl
    ld bc,sin_table-cos_table
    add hl,bc
    ld c,(hl)
    inc hl
    ld b,(hl)
    ld h,(ix+2)     ; (ix+2),(ix+7) for the 16bit high precision coordinates of the enemy
    ld l,(ix+7)
    add hl,bc
    ld c,(ix+1)
    ld b,h
    call getMapPosition
    or a
    ret nz
    ld (ix+2),h
    ld (ix+7),l
    ret


;-----------------------------------------------
; - places an enemy sprite in the sprite assignment table for rendering in the next frame
; - parameters:
;   IX: pointer to the enemy parameters (type, x, y, sprite, color, ...)
assignEnemySprite:
    jp assignSprite_prefilter
assignEnemySprite_continue:

    ; 4) assign the sprite to the table:
    ld a,(assignSprite_bank)
    ld b,a
    ld hl,sprites_available_per_depth
    ADD_HL_A
    dec (hl)
    ld a,(hl)
    sla b
    sla b   ;; note: this assumes that N_SPRITES_PER_DEPTH = 4
    add a,b ; a = bank*4 + slot inside the bank
    ld de,other_sprite_attributes
    add a,a   
    add a,a   
    ADD_DE_A
    ld a,(ix)
    and #7f ; ignore the MSB (which stores whether the enemy is frozen or not)
    cp ENEMY_MEDUSA
    jp z,assignEnemySprite_medusa
    cp ENEMY_MEDUSA_STONE
    jp z,assignEnemySprite_medusa
    cp ENEMY_KER
    jp z,assignEnemySprite_ker
    cp ENEMY_KER2
    jp z,assignEnemySprite_ker
    cp ENEMY_KER3
    jp z,assignEnemySprite_ker
    ld hl,assignSprite_y
    ldi
    ldi
    push de
    ld a,(assignSprite_bank)
    add a,(ix+3)
    call getOrLoadEnemySpritePattern
    pop de
    ld (de),a
    inc de
    ld a,(ix+4)
    ld (de),a
    ret


assignEnemySprite_medusa:
    ; if bank == 1: y+=2
    ; if bank == 2: y+=6
    ; if bank == 3: y+=11
    ld a,(assignSprite_bank)
    dec a
    jr z,assignEnemySprite_medusa_bank1
    dec a
    jr z,assignEnemySprite_medusa_bank2
    dec a
    jr z,assignEnemySprite_medusa_bank3
assignEnemySprite_medusa_y_adjusted:    
    ld hl,assignSprite_y
    ldi
    ldi
    push de
    ld a,(assignSprite_bank)
    add a,(ix+3)
    add a,4
    call getOrLoadEnemySpritePattern
    pop de
    ld (de),a
    inc de
    ld a,12 ; tail is always green
    ld (de),a

    ;; ensure we have space for the second sprite:
    ld a,(assignSprite_bank)
    ld hl,sprites_available_per_depth
    ADD_HL_A
    ld a,(hl)
    or a
    ret z   ;; if we don't have space, just return
    dec (hl)
    ex de,hl

    ld bc,-7
    add hl,bc
    ld a,(assignSprite_y)
    add a,-32
    ld (hl),a
    inc hl
    ld a,(assignSprite_x)
    ld (hl),a
    inc hl
    ; get which sprite to use
    push hl
    ld a,(assignSprite_bank)
    add a,(ix+3)
    call getOrLoadEnemySpritePattern
    pop hl
    ld (hl),a
    inc hl
    ld a,(ix+4)
    ld (hl),a
    ret

assignEnemySprite_medusa_bank1:
    ld a,(assignSprite_y)
    add a,2
    ld (assignSprite_y),a
    jp assignEnemySprite_medusa_y_adjusted
assignEnemySprite_medusa_bank2:
    ld a,(assignSprite_y)
    add a,6
    ld (assignSprite_y),a
    jp assignEnemySprite_medusa_y_adjusted
assignEnemySprite_medusa_bank3:
    ld a,(assignSprite_y)
    add a,11
    ld (assignSprite_y),a
    jp assignEnemySprite_medusa_y_adjusted


assignEnemySprite_ker:
    ld hl,assignSprite_y
    ld a,(assignSprite_bank)
    and #02
    ld a,(hl)
    jr nz,assignEnemySprite_ker_noyupdate
    sub 16
assignEnemySprite_ker_noyupdate:
    ld (de),a
    inc de
    inc hl
    ldi
    ; get which sprite to use
    push de
    ld a,(assignSprite_bank)
    add a,(ix+3)
    call getOrLoadEnemySpritePattern
    pop de
    ld (de),a
    inc de
    ld a,(ix+4)
    ld (de),a

    ;; ensure we have space for the second sprite:
    ld a,(assignSprite_bank)
    ld hl,sprites_available_per_depth
    ADD_HL_A
    ld a,(hl)
    or a
    ret z   ;; if we don't have space, just return
    dec (hl)
    ex de,hl
    ld bc,-7
    add hl,bc
    ex de,hl
    ld hl,assignSprite_y
    ldi
    ldi
    ; get which sprite to use
    push de
    ld a,(assignSprite_bank)
    add a,(ix+3)
    add a,4
    call getOrLoadEnemySpritePattern
    pop hl
    ld (hl),a
    inc hl
    ld a,15 ; body is always white
    ld (hl),a
    ret


;-----------------------------------------------
; Checks if the sprite pattern identified in 'a' is loaded in the 'spritePatternCacheTable'
; if it is, it returns its index (+24), and if it's not, it loads it into the table, and returns
; the index (+24) where it has been loaded
getOrLoadEnemySpritePattern:
    ; check to see if we have it already loaded in the VDP:
    ld b,a
    ld c,24
    ld hl,spritePatternCacheTable
getOrLoadEnemySpritePattern_loop:
    ld a,(hl)
    cp b
    jr z,getOrLoadEnemySpritePattern_found
    inc hl
    inc c
    ld a,c
    cp 32
    jr nz,getOrLoadEnemySpritePattern_loop

getOrLoadEnemySpritePattern_not_found:
    ; mark the table so that in position (spritePatternCacheTableNextToErase) we now have the new sprite:
    ld hl,spritePatternCacheTable
    ld a,(spritePatternCacheTableNextToErase)
    ADD_HL_A
    ld (hl),b
    ; load pattern 'b' onto position 'a+24'
    ld a,(spritePatternCacheTableNextToErase)
    add a,24
    add a,a
    add a,a
    push af ;; save the index for later
    ld l,a
    ld h,0
    add hl,hl
    add hl,hl
    add hl,hl      ;; hl = a*32
    ld de,SPRTBL2
    add hl,de
    ex de,hl

    ld l,b
    ld h,0
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl      ;; hl = b*32
    ld bc,enemySpritePatterns
    add hl,bc
    ld bc,32
    call LDIRVM

    ; increment the erasing pointer:
    ld hl,spritePatternCacheTableNextToErase
    ld a,(hl)
    inc a
    and #07
    ld (hl),a

    pop af  ;; retrieve the index
    ret

getOrLoadEnemySpritePattern_found:
    ld a,c
    add a,a
    add a,a
    ret



enemySpritePatterns:    ;; from here on, each offset of 32 pixels is a different enemy sprite
explosion_sprite:
    ; LARGE
    db #00,#00,#00,#18,#1c,#0e,#02,#60,#70,#00,#06,#0c,#1c,#19,#01,#00
    db #00,#c0,#c0,#8c,#1c,#38,#20,#0e,#06,#00,#20,#38,#9c,#8c,#80,#00
    ; MEDIUM
    db #00,#00,#00,#00,#00,#0c,#06,#02,#30,#38,#00,#06,#0c,#0c,#00,#00
    db #00,#00,#00,#c0,#80,#98,#30,#20,#00,#1c,#04,#20,#b0,#98,#80,#00
    ; SMALL
    db #00,#00,#00,#00,#00,#00,#00,#04,#02,#00,#0c,#00,#02,#04,#00,#00
    db #00,#00,#00,#00,#00,#00,#80,#90,#20,#00,#18,#00,#20,#90,#80,#00
    ; TINY
    db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#02,#00,#00,#02,#00,#00
    db #00,#00,#00,#00,#00,#00,#00,#00,#00,#80,#20,#00,#00,#20,#80,#00

rat_enemySprite:
    ; sprite 1
    ; LARGE
    db #00,#00,#00,#0f,#10,#20,#41,#00,#19,#37,#0f,#05,#0f,#1e,#18,#00
    db #00,#00,#fc,#02,#7a,#fc,#fc,#7e,#be,#d6,#26,#ac,#28,#40,#00,#00
    ; MEDIUM
    db #00,#00,#00,#03,#0c,#10,#01,#02,#19,#0f,#05,#0f,#1c,#18,#00,#00
    db #00,#00,#00,#c0,#38,#04,#f4,#78,#b8,#78,#78,#58,#50,#80,#00,#00
    ; SMALL:
    db #00,#00,#00,#00,#00,#03,#0c,#00,#03,#00,#0f,#06,#0e,#19,#00,#00
    db #00,#00,#00,#00,#00,#e0,#10,#08,#e8,#f0,#70,#f0,#a0,#00,#00,#00
    ; TINY:
    db #00,#00,#00,#00,#00,#00,#00,#00,#03,#04,#01,#03,#07,#06,#00,#00
    db #00,#00,#00,#00,#00,#00,#00,#00,#e0,#10,#f0,#e0,#e0,#80,#00,#00

    ; sprite 2
    ; LARGE:
    db #00,#01,#06,#08,#10,#10,#21,#03,#02,#19,#37,#0f,#05,#0f,#1e,#18
    db #00,#f8,#04,#02,#7a,#fc,#fc,#fe,#7e,#96,#e6,#2c,#a8,#40,#00,#00
    ; MEDIUM:
    db #00,#00,#01,#06,#08,#10,#01,#03,#02,#19,#0f,#05,#0e,#1c,#18,#00
    db #00,#00,#c0,#30,#08,#04,#f4,#f8,#78,#b8,#78,#58,#50,#80,#00,#00
    ; SMALL:
    db #00,#00,#00,#00,#00,#00,#03,#04,#0b,#00,#0f,#06,#0e,#19,#00,#00
    db #00,#00,#00,#00,#00,#c0,#30,#08,#e8,#f0,#70,#f0,#a0,#00,#00,#00
    ; TINY:
    db #00,#00,#00,#00,#00,#00,#00,#00,#00,#03,#05,#03,#07,#06,#00,#00
    db #00,#00,#00,#00,#00,#00,#00,#00,#e0,#10,#f0,#e0,#e0,#80,#00,#00

blob_enemySprite:
    ; sprite1
    ; LARGE
    db #00,#00,#00,#0b,#07,#07,#0e,#09,#0c,#0f,#1f,#1e,#3d,#61,#03,#00
    db #00,#00,#00,#80,#e8,#f0,#70,#98,#38,#f0,#f8,#fc,#fc,#8e,#02,#00
    ; MEDIUM
    db #00,#00,#00,#00,#00,#01,#0b,#06,#05,#06,#07,#0f,#1e,#31,#03,#00
    db #00,#00,#00,#00,#00,#c0,#e0,#68,#b0,#70,#e0,#e0,#f0,#f8,#0c,#00
    ; SMALL
    db #00,#00,#00,#00,#00,#00,#00,#05,#03,#02,#05,#06,#07,#0f,#19,#00
    db #00,#00,#00,#00,#00,#00,#00,#c0,#e0,#e0,#60,#e0,#e0,#f0,#98,#00
    ; TINY
    db #00,#00,#00,#00,#00,#00,#00,#00,#00,#05,#03,#02,#03,#07,#0d,#00
    db #00,#00,#00,#00,#00,#00,#00,#00,#00,#80,#c0,#c0,#c0,#e0,#b0,#00

    ; sprite4
    ; LARGE
    db #00,#00,#00,#00,#0b,#07,#07,#0e,#09,#0c,#1f,#3e,#7d,#c1,#03,#00
    db #00,#00,#00,#00,#c0,#e8,#f0,#70,#98,#30,#f8,#fc,#fe,#87,#00,#00
    ; MEDIUM
    db #00,#00,#00,#00,#00,#00,#01,#0b,#06,#05,#06,#0f,#3e,#61,#03,#00
    db #00,#00,#00,#00,#00,#00,#c0,#e0,#68,#b0,#70,#e0,#f0,#fc,#00,#00
    ; SMALL
    db #00,#00,#00,#00,#00,#00,#00,#00,#05,#03,#02,#05,#06,#0f,#18,#00
    db #00,#00,#00,#00,#00,#00,#00,#00,#c0,#e0,#e0,#60,#e0,#f0,#d8,#00
    ; TINY
    db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#05,#03,#02,#07,#0d,#00
    db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#80,#c0,#c0,#e0,#b0,#00


skeleton_forward_enemySprite:
    ; sprite1
      ; LARGE:
      db #07,#0f,#09,#09,#0e,#07,#15,#2a,#4b,#81,#87,#9a,#20,#98,#0c,#38
      db #c0,#e0,#20,#20,#e0,#c0,#50,#a8,#a4,#02,#c2,#b2,#08,#32,#60,#38
      ; MEDIUM:
      db #00,#00,#07,#09,#09,#0e,#07,#15,#28,#4b,#41,#47,#0a,#50,#08,#38
      db #00,#00,#c0,#20,#20,#e0,#c0,#50,#28,#a4,#04,#c4,#a0,#14,#20,#38
      ; SMALL:
      db #00,#00,#00,#00,#00,#03,#05,#05,#07,#12,#20,#21,#27,#08,#04,#0c
      db #00,#00,#00,#00,#00,#80,#40,#40,#c0,#90,#08,#08,#c8,#20,#40,#60
      ; TINY:
      db #00,#00,#00,#00,#00,#00,#00,#00,#03,#05,#03,#0a,#10,#13,#02,#06
      db #00,#00,#00,#00,#00,#00,#00,#00,#80,#40,#80,#a0,#10,#90,#80,#c0

    ; sprite2
      ; LARGE:
      db #00,#07,#0f,#09,#09,#0e,#07,#15,#6a,#8b,#81,#9f,#22,#98,#0c,#38
      db #00,#c0,#e0,#20,#20,#e0,#c0,#50,#ac,#a2,#02,#f2,#88,#32,#60,#38
      ; MEDIUM:
      db #00,#00,#00,#07,#09,#09,#0e,#07,#15,#28,#4b,#41,#4f,#12,#48,#38
      db #00,#00,#00,#c0,#20,#20,#e0,#c0,#50,#28,#a4,#04,#e4,#90,#24,#38
      ; SMALL:
      db #00,#00,#00,#00,#00,#00,#03,#05,#05,#07,#12,#20,#21,#2f,#04,#0c
      db #00,#00,#00,#00,#00,#00,#80,#40,#40,#c0,#90,#08,#08,#e8,#40,#60
      ; TINY:
      db #00,#00,#00,#00,#00,#00,#00,#00,#00,#03,#05,#0b,#12,#11,#02,#06
      db #00,#00,#00,#00,#00,#00,#00,#00,#00,#80,#40,#a0,#90,#10,#80,#c0

    ; sprite3
      ; LARGE:
      db #00,#00,#07,#0f,#09,#09,#06,#77,#85,#8a,#81,#1f,#a2,#18,#0c,#38
      db #00,#00,#c0,#e0,#20,#20,#c0,#dc,#42,#a2,#02,#f0,#8a,#30,#60,#38
      ; MEDIUM:
      db #00,#00,#00,#00,#07,#09,#09,#0e,#37,#45,#48,#41,#0f,#52,#08,#38
      db #00,#00,#00,#00,#c0,#20,#20,#e0,#d8,#44,#24,#04,#e0,#94,#20,#38
      ; SMALL:
      db #00,#00,#00,#00,#00,#00,#03,#05,#05,#17,#22,#20,#21,#0f,#04,#0c
      db #00,#00,#00,#00,#00,#00,#80,#40,#40,#d0,#88,#08,#08,#e0,#40,#60
      ; TINY:
      db #00,#00,#00,#00,#00,#00,#00,#00,#00,#03,#0d,#13,#12,#01,#02,#06
      db #00,#00,#00,#00,#00,#00,#00,#00,#00,#80,#60,#90,#90,#00,#80,#c0


knight_enemySprite:
      ; sprite1
      ; LARGE:
      db #00,#0f,#10,#0f,#1a,#1a,#1a,#2f,#70,#6e,#66,#46,#0b,#1d,#0c,#3c
      db #00,#e0,#10,#e0,#b0,#b0,#b0,#00,#fc,#fc,#fc,#fc,#78,#30,#40,#78
      ; MEDIUM:
      db #00,#00,#00,#07,#08,#07,#0a,#0a,#17,#38,#36,#26,#0b,#0d,#04,#1c
      db #00,#00,#00,#c0,#20,#c0,#a0,#a0,#00,#f8,#f8,#f8,#70,#20,#40,#70
      ; SMALL:
      db #00,#00,#00,#00,#00,#00,#07,#0f,#0a,#0a,#07,#18,#17,#13,#02,#06
      db #00,#00,#00,#00,#00,#00,#c0,#e0,#a0,#a0,#c0,#70,#70,#70,#a0,#c0
      ; TINY:
      db #00,#00,#00,#00,#00,#00,#00,#00,#03,#07,#05,#07,#08,#0b,#02,#06
      db #00,#00,#00,#00,#00,#00,#00,#00,#80,#c0,#40,#c0,#e0,#e0,#e0,#c0

      ; sprite2
      ; LARGE:
      db #00,#00,#0f,#10,#0f,#1a,#1a,#1a,#2f,#70,#6e,#66,#4a,#1d,#0c,#3c
      db #00,#00,#e0,#10,#e0,#b0,#b0,#b0,#00,#fc,#fc,#fc,#fc,#78,#30,#48
      ; MEDIUM:
      db #00,#00,#00,#00,#07,#08,#07,#0a,#0a,#17,#38,#36,#2a,#0d,#04,#1c
      db #00,#00,#00,#00,#c0,#20,#c0,#a0,#a0,#00,#f8,#f8,#f8,#70,#20,#50
      ; SMALL:
      db #00,#00,#00,#00,#00,#00,#00,#07,#0f,#0a,#0a,#07,#18,#13,#12,#06
      db #00,#00,#00,#00,#00,#00,#00,#c0,#e0,#a0,#a0,#c0,#70,#70,#70,#a0
      ; TINY:
      db #00,#00,#00,#00,#00,#00,#00,#00,#00,#03,#07,#05,#03,#08,#0a,#06
      db #00,#00,#00,#00,#00,#00,#00,#00,#00,#80,#c0,#40,#e0,#e0,#e0,#c0

      ; sprite3
      ; LARGE:
      db #00,#00,#0f,#10,#0f,#1a,#1a,#1a,#2f,#70,#6e,#66,#4a,#1c,#0c,#3c
      db #00,#00,#e0,#10,#e0,#b0,#b0,#b0,#e0,#00,#fc,#fc,#fc,#fc,#78,#30
      ; MEDIUM:
      db #00,#00,#00,#00,#07,#08,#07,#0a,#0a,#17,#38,#36,#2a,#0c,#04,#1c
      db #00,#00,#00,#00,#c0,#20,#c0,#a0,#a0,#00,#00,#f8,#f8,#f8,#70,#20
      ; SMALL:
      db #00,#00,#00,#00,#00,#00,#00,#07,#0f,#0a,#0a,#07,#18,#13,#12,#06
      db #00,#00,#00,#00,#00,#00,#00,#c0,#e0,#a0,#a0,#80,#e0,#e0,#e0,#40
      ; TTINY:
      db #00,#00,#00,#00,#00,#00,#00,#00,#00,#03,#07,#05,#03,#08,#0a,#06
      db #00,#00,#00,#00,#00,#00,#00,#00,#00,#80,#c0,#40,#e0,#e0,#e0,#c0

snake_enemySprite:
    ; sprite1
    ; LARGE:
    db #00,#00,#00,#07,#0b,#17,#3f,#3d,#33,#03,#07,#07,#07,#07,#07,#03
    db #00,#00,#00,#00,#80,#80,#82,#86,#8c,#98,#9c,#0c,#38,#f8,#f0,#80
    ; MEDIUM:
    db #00,#00,#00,#00,#00,#03,#07,#0b,#1f,#19,#03,#03,#03,#03,#03,#01
    db #00,#00,#00,#00,#00,#00,#80,#80,#88,#90,#90,#18,#18,#38,#f0,#c0
    ; SMALL:
    db #00,#00,#00,#00,#00,#00,#00,#03,#05,#0f,#0d,#01,#03,#03,#03,#01
    db #00,#00,#00,#00,#00,#00,#00,#00,#80,#80,#90,#a0,#20,#20,#e0,#c0
    ; TINY:
    db #00,#00,#00,#00,#00,#00,#00,#00,#00,#03,#05,#07,#01,#01,#01,#00
    db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#20,#20,#e0,#c0

    ; sprite2
    ; LARGE:
    db #00,#00,#00,#00,#0e,#17,#2f,#7d,#7b,#63,#03,#07,#07,#07,#07,#03
    db #00,#00,#00,#00,#00,#00,#90,#98,#8c,#8c,#9c,#18,#38,#f8,#f0,#80
    ; MEDIUM:
    db #00,#00,#00,#00,#00,#00,#06,#0f,#17,#3f,#33,#03,#03,#03,#03,#01
    db #00,#00,#00,#00,#00,#00,#00,#00,#10,#08,#08,#18,#18,#38,#f0,#c0
    ; SMALL:
    db #00,#00,#00,#00,#00,#00,#00,#06,#0b,#1f,#1b,#03,#03,#03,#03,#01
    db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#40,#20,#20,#20,#e0,#c0
    ; TINY:
    db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#03,#05,#07,#01,#01,#00
    db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#20,#20,#e0,#c0


medusa_enemySprite:
    ; TORSO 1:
    ; LARGE:
  db #01, #06, #19, #27, #08, #13, #05, #09, #00, #00, #07, #0f, #1b, #11, #31, #21
  db #e0, #18, #e6, #f9, #c4, #f2, #28, #24, #c0, #00, #38, #fc, #f6, #62, #f3, #f1
    ; MEDIUM
  db #00, #00, #00, #01, #06, #0b, #04, #0b, #05, #00, #00, #07, #0f, #09, #11, #11
  db #00, #00, #00, #e0, #18, #f4, #c8, #f4, #28, #c0, #00, #38, #fc, #e4, #e2, #e2
    ; SMALL
  db #00, #00, #00, #00, #00, #00, #02, #01, #04, #01, #04, #00, #03, #05, #05, #09
  db #00, #00, #00, #00, #00, #00, #20, #c0, #90, #c0, #90, #00, #e0, #d0, #d0, #c8
    ; TINY:
  db #00, #00, #00, #00, #00, #00, #00, #00, #02, #00, #05, #01, #00, #03, #05, #09
  db #00, #00, #00, #00, #00, #00, #00, #00, #40, #00, #a0, #80, #00, #c0, #a0, #90

    ; TAIL 1:
    ; LARGE:
  db #00, #03, #03, #03, #03, #43, #61, #61, #71, #7b, #3f, #3f, #1f, #00, #0a, #00
  db #00, #70, #78, #80, #b8, #bc, #9c, #80, #bc, #bc, #9c, #60, #7c, #b8, #c0, #00
    ; MEDIUM:
  db #00, #03, #03, #03, #01, #21, #21, #33, #3f, #3f, #1f, #00, #05, #00, #00, #00
  db #00, #60, #70, #80, #b8, #b8, #80, #b8, #b8, #80, #38, #50, #60, #00, #00, #00
    ; SMALL:
  db #00, #01, #01, #09, #09, #0f, #0f, #04, #02, #00, #00, #00, #00, #00, #00, #00
  db #00, #60, #00, #60, #00, #60, #00, #60, #c0, #00, #00, #00, #00, #00, #00, #00
    ; TINY:
  db #00, #01, #05, #07, #07, #03, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00
  db #00, #80, #80, #80, #80, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00

    ; TORSO 2:
    ; LARGE:
  db #00, #01, #26, #19, #07, #18, #03, #0d, #01, #00, #07, #0f, #1b, #11, #19, #09
  db #00, #e0, #19, #e6, #f8, #c6, #f0, #2c, #e0, #c0, #38, #fc, #f6, #62, #f6, #f4
    ; MEDIUM:
  db #00, #00, #00, #00, #09, #06, #0b, #04, #03, #05, #00, #07, #0f, #09, #09, #05
  db #00, #00, #00, #00, #e4, #18, #f4, #c8, #f0, #28, #c0, #38, #fc, #e4, #e4, #e8
    ; SMALL:
  db #00, #00, #00, #00, #00, #00, #00, #02, #01, #04, #01, #04, #03, #05, #05, #05
  db #00, #00, #00, #00, #00, #00, #00, #20, #c0, #90, #c0, #90, #60, #d0, #d0, #d0
    ; TINY:
  db #00, #00, #00, #00, #00, #00, #00, #00, #00, #02, #00, #05, #01, #03, #05, #05
  db #00, #00, #00, #00, #00, #00, #00, #00, #00, #40, #00, #a0, #80, #c0, #a0, #a0
    ; TAIL 2:
    ; LARGE:
  db #00, #03, #03, #03, #01, #11, #31, #31, #71, #7b, #3f, #3f, #1f, #00, #0a, #00
  db #00, #70, #78, #80, #bc, #de, #de, #c0, #de, #be, #9c, #60, #7c, #b8, #c0, #00
    ; MEDIUM:
  db #00, #03, #03, #03, #01, #09, #19, #1b, #3f, #3f, #1f, #00, #05, #00, #00, #00
  db #00, #60, #70, #80, #b8, #b8, #80, #b8, #b8, #80, #38, #50, #60, #00, #00, #00
    ; SMALL:
  db #00, #01, #01, #05, #09, #0f, #0f, #04, #02, #00, #00, #00, #00, #00, #00, #00
  db #00, #60, #00, #60, #00, #60, #00, #60, #c0, #00, #00, #00, #00, #00, #00, #00
    ; TINY:
  db #00, #01, #05, #07, #07, #03, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00
  db #00, #80, #80, #80, #80, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00


ker_enemySprite:
    ; HAIR 1:
    ; LARGE:
  db #00, #01, #13, #1b, #0f, #77, #3f, #1f, #11, #00, #06, #00, #01, #01, #00, #00
  db #00, #20, #60, #6c, #78, #f6, #fc, #f8, #88, #00, #60, #00, #80, #80, #00, #00
    ; MEDIUM
  db #00, #00, #00, #00, #01, #0d, #07, #3f, #1f, #1f, #11, #00, #06, #00, #01, #01
  db #00, #00, #00, #00, #20, #68, #f0, #fc, #f8, #f8, #88, #00, #60, #00, #80, #80
    ; SMALL
  db #04, #02, #1b, #0f, #07, #01, #00, #02, #00, #01, #00, #00, #00, #00, #00, #00
  db #a0, #c0, #d8, #f0, #e0, #80, #00, #40, #00, #80, #00, #00, #00, #00, #00, #00
    ; TINY:
  db #00, #00, #00, #00, #05, #03, #03, #01, #00, #00, #00, #00, #00, #00, #00, #00
  db #00, #00, #00, #00, #a0, #c0, #c0, #80, #00, #00, #00, #00, #00, #00, #00, #00

    ; BODY 1:
    ; LARGE:
  db #00, #0e, #71, #f7, #c2, #9c, #bd, #22, #03, #21, #06, #06, #02, #0c, #14, #00
  db #00, #70, #8e, #ef, #43, #39, #bd, #44, #c0, #84, #60, #60, #40, #30, #28, #00
    ; MEDIUM:
  db #00, #00, #00, #0e, #31, #77, #42, #5c, #11, #02, #11, #06, #02, #04, #0c, #00
  db #00, #00, #00, #70, #8c, #ee, #42, #3a, #88, #40, #88, #60, #40, #20, #30, #00
    ; SMALL:
  db #00, #00, #00, #00, #00, #00, #16, #39, #23, #04, #09, #10, #03, #02, #04, #00
  db #00, #00, #00, #00, #00, #00, #68, #9c, #c4, #20, #90, #08, #c0, #40, #20, #00
    ; TINY:
  db #00, #00, #00, #00, #00, #00, #00, #0c, #01, #0d, #08, #01, #01, #02, #02, #00
  db #00, #00, #00, #00, #00, #00, #00, #30, #80, #b0, #10, #80, #80, #40, #40, #00

    ; HAIR 2:
    ; LARGE:
  db #00, #01, #13, #1b, #0f, #77, #3f, #1f, #11, #00, #06, #00, #00, #00, #00, #00
  db #00, #20, #60, #6c, #78, #f6, #fc, #f8, #88, #00, #60, #00, #00, #00, #00, #00
    ; MEDIUM:
  db #00, #00, #00, #00, #01, #0d, #07, #3f, #1f, #1f, #11, #00, #06, #00, #00, #00
  db #00, #00, #00, #00, #20, #68, #f0, #fc, #f8, #f8, #88, #00, #60, #00, #00, #00
    ; SMALL:
  db #04, #02, #1b, #0f, #07, #01, #00, #02, #00, #00, #00, #00, #00, #00, #00, #00
  db #a0, #c0, #d8, #f0, #e0, #80, #00, #40, #00, #00, #00, #00, #00, #00, #00, #00
    ; TINY:
  db #00, #00, #00, #00, #05, #03, #03, #01, #00, #00, #00, #00, #00, #00, #00, #00
  db #00, #00, #00, #00, #a0, #c0, #c0, #80, #00, #00, #00, #00, #00, #00, #00, #00

    ; BODY 2:
    ; LARGE:
  db #00, #6e, #f1, #d7, #83, #8d, #1e, #33, #23, #01, #26, #06, #02, #0c, #14, #00
  db #00, #76, #8f, #eb, #c1, #b1, #78, #cc, #c4, #80, #64, #60, #40, #30, #28, #00
    ; MEDIUM:
  db #00, #00, #00, #2e, #71, #57, #43, #0d, #1a, #13, #01, #16, #02, #04, #0c, #00
  db #00, #00, #00, #74, #8e, #ea, #c2, #b0, #58, #c8, #80, #68, #40, #20, #30, #00
    ; SMALL:
  db #00, #00, #00, #00, #00, #00, #36, #39, #03, #0d, #12, #11, #03, #02, #04, #00
  db #00, #00, #00, #00, #00, #00, #6c, #9c, #c0, #b0, #48, #88, #c0, #40, #20, #00
    ; TINY:
  db #00, #00, #00, #00, #00, #00, #00, #0c, #09, #05, #08, #09, #01, #02, #02, #00
  db #00, #00, #00, #00, #00, #00, #00, #30, #90, #a0, #10, #90, #80, #40, #40, #00

switchRightSprite:
    ; LARGE
    db #00,#00,#00,#00,#00,#00,#00,#03,#04,#0b,#16,#2e,#2f,#2f,#3f,#00
    db #00,#00,#00,#06,#0e,#1c,#38,#d0,#20,#d0,#68,#74,#f4,#f4,#fc,#00
    ; MEDIUM
    db #00,#00,#00,#00,#00,#00,#00,#00,#03,#04,#0b,#16,#16,#17,#1f,#00
    db #00,#00,#00,#00,#00,#0c,#1c,#38,#d0,#20,#d0,#68,#68,#e8,#f8,#00
    ; SMALL
    db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#03,#06,#0e,#0f,#0f,#00
    db #00,#00,#00,#00,#00,#00,#00,#18,#30,#60,#c0,#60,#70,#f0,#f0,#00
    ; TINY
    db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#03,#06,#07,#00
    db #00,#00,#00,#00,#00,#00,#00,#00,#00,#10,#20,#40,#c0,#60,#e0,#00
switchLeftSprite:
    ; LARGE
    db #00,#00,#00,#60,#70,#38,#1c,#0b,#04,#0b,#16,#2e,#2f,#2f,#3f,#00
    db #00,#00,#00,#00,#00,#00,#00,#c0,#20,#d0,#68,#74,#f4,#f4,#fc,#00
    ; MEDIUM
    db #00,#00,#00,#00,#00,#30,#38,#1c,#0b,#04,#0b,#16,#16,#17,#1f,#00
    db #00,#00,#00,#00,#00,#00,#00,#00,#c0,#20,#d0,#68,#68,#e8,#f8,#00
    ; SMALL
    db #00,#00,#00,#00,#00,#00,#00,#18,#0c,#06,#03,#06,#0e,#0f,#0f,#00
    db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#c0,#60,#70,#f0,#f0,#00
    ; TINY
    db #00,#00,#00,#00,#00,#00,#00,#00,#00,#08,#04,#02,#03,#06,#07,#00
    db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#c0,#60,#e0,#00

; Version of the switches that is pressed or not, rather than switching left/right:
;switchRightSprite:
;    ; sprite1
;    db #00,#00,#00,#07,#07,#00,#01,#01,#01,#0f,#10,#2f,#2f,#2f,#3f,#00
;    db #00,#00,#00,#e0,#e0,#00,#80,#80,#80,#f0,#08,#f4,#f4,#f4,#fc,#00
;    ; sprite2
;    db #00,#00,#00,#00,#00,#07,#07,#00,#01,#01,#07,#08,#17,#17,#1f,#00
;    db #00,#00,#00,#00,#00,#e0,#e0,#00,#80,#80,#e0,#10,#e8,#e8,#f8,#00
;    ; sprite3
;    db #00,#00,#00,#00,#00,#00,#00,#03,#00,#01,#01,#07,#08,#0b,#0f,#00
;    db #00,#00,#00,#00,#00,#00,#00,#c0,#00,#80,#80,#e0,#10,#d0,#f0,#00
;    ; sprite4
;    db #00,#00,#00,#00,#00,#00,#00,#00,#00,#03,#01,#01,#03,#05,#07,#00
;    db #00,#00,#00,#00,#00,#00,#00,#00,#00,#80,#00,#00,#80,#40,#c0,#00
;
;switchLeftSprite:
;    ; sprite1
;    db #00,#00,#00,#00,#00,#00,#07,#07,#01,#0f,#10,#2f,#2f,#2f,#3f,#00
;    db #00,#00,#00,#00,#00,#00,#e0,#e0,#80,#f0,#08,#f4,#f4,#f4,#fc,#00
;    ; sprite2
;    db #00,#00,#00,#00,#00,#00,#00,#07,#07,#01,#07,#08,#17,#17,#1f,#00
;    db #00,#00,#00,#00,#00,#00,#00,#e0,#e0,#80,#e0,#10,#e8,#e8,#f8,#00
;    ; sprite3
;    db #00,#00,#00,#00,#00,#00,#00,#00,#00,#03,#00,#07,#08,#0b,#0f,#00
;    db #00,#00,#00,#00,#00,#00,#00,#00,#00,#c0,#00,#e0,#10,#d0,#f0,#00
;    ; sprite4
;    db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#03,#03,#05,#07,#00
;    db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#80,#80,#40,#c0,#00



enemyBulletSprite:
    ; LARGE
    db #00,#00,#00,#00,#00,#00,#00,#00,#01,#02,#03,#03,#01,#00,#00,#00
    db #00,#00,#00,#00,#00,#00,#00,#00,#80,#c0,#c0,#c0,#80,#00,#00,#00
    ; MEDIUM
    db #00,#00,#00,#00,#00,#00,#00,#00,#00,#01,#03,#03,#01,#00,#00,#00
    db #00,#00,#00,#00,#00,#00,#00,#00,#00,#80,#c0,#c0,#80,#00,#00,#00
    ; SMALL
    db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#01,#01,#00,#00,#00
    db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#80,#80,#00,#00,#00
    ; TINY
    db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#01,#00,#00,#00
    db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00


; Unused enemy sprites:
; 
;fireball_enemySprite:
;    ; LARGE
;    db #00,#00,#00,#02,#0f,#07,#1e,#0c,#1c,#0e,#1f,#0f,#05,#00,#00,#00
;    db #00,#00,#00,#60,#e0,#f8,#70,#30,#38,#60,#f0,#e0,#a0,#00,#00,#00
;    ; MEDIUM
;    db #00,#00,#00,#00,#00,#02,#07,#0e,#0c,#04,#0e,#07,#02,#00,#00,#00
;    db #00,#00,#00,#00,#00,#c0,#e0,#70,#20,#30,#60,#e0,#c0,#00,#00,#00
;    ; SMALL
;    db #00,#00,#00,#00,#00,#00,#01,#01,#07,#06,#03,#03,#01,#00,#00,#00
;    db #00,#00,#00,#00,#00,#00,#40,#e0,#60,#30,#70,#e0,#40,#00,#00,#00
;    ; TINY
;    db #00,#00,#00,#00,#00,#00,#00,#00,#03,#02,#06,#03,#01,#00,#00,#00
;    db #00,#00,#00,#00,#00,#00,#00,#80,#c0,#40,#60,#c0,#00,#00,#00,#00
;
;python_enemySprite:
;    ; Sprite 1 (left)
;    ; LARGE: 
;      db #00,#00,#01,#03,#0e,#19,#37,#6f,#5f,#d1,#c0,#c0,#80,#00,#00,#00
;      db #00,#40,#82,#1a,#8f,#c7,#c1,#ea,#db,#b5,#69,#5d,#4e,#11,#1f,#04
;    ; MEDIUM: 
;      db #00,#00,#00,#00,#03,#06,#0d,#1b,#17,#34,#30,#20,#20,#00,#00,#00
;      db #00,#00,#20,#c2,#9a,#4f,#c3,#e0,#eb,#d5,#55,#35,#2a,#2e,#19,#07
;    ; SMALL: 
;      db #00,#00,#00,#00,#00,#00,#00,#00,#01,#02,#02,#02,#00,#00,#00,#00
;      db #00,#00,#00,#00,#00,#10,#60,#81,#67,#fa,#35,#0d,#0e,#0e,#07,#03
;    ; TINY: 
;      db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
;      db #00,#00,#00,#00,#00,#00,#00,#08,#10,#3a,#79,#4d,#02,#06,#07,#03
;    ; Sprite 1 (right)
;    ; LARGE: (
;      db #00,#00,#08,#0b,#1e,#fd,#f2,#4b,#fb,#f0,#50,#f0,#e8,#1e,#61,#de
;      db #00,#00,#00,#00,#00,#80,#c0,#60,#a0,#b2,#32,#36,#0c,#3c,#f8,#70
;    ; MEDIUM:
;      db #00,#00,#00,#10,#16,#fc,#f3,#c5,#f6,#e2,#e0,#e0,#c0,#3f,#c7,#b9
;      db #00,#00,#00,#00,#00,#00,#00,#80,#80,#c0,#c8,#18,#70,#f0,#e0,#80
;    ; SMALL: 
;      db #00,#00,#00,#00,#00,#20,#18,#24,#fa,#d5,#e1,#e1,#c0,#c0,#3f,#ff
;      db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#40,#c0,#80,#00
;    ; TINY: 
;      db #00,#00,#00,#00,#00,#00,#00,#20,#10,#28,#dc,#c4,#80,#84,#78,#e0
;      db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
;
;    ; Sprite 2: (left)
;    ; LARGE: 
;      db #00,#00,#01,#0f,#18,#37,#6f,#df,#c1,#c0,#80,#00,#00,#00,#00,#00
;      db #10,#60,#c0,#02,#da,#cf,#e7,#e9,#da,#b3,#69,#5d,#4d,#10,#1f,#04
;    ; MEDIUM: 
;      db #00,#00,#00,#00,#03,#06,#0d,#1b,#10,#30,#20,#20,#00,#00,#00,#00
;      db #00,#00,#38,#e0,#82,#5a,#ef,#f3,#e8,#5b,#15,#35,#29,#2e,#19,#07
;    ; SMALL: 
;      db #00,#00,#00,#00,#00,#00,#00,#00,#01,#02,#00,#00,#00,#00,#00,#00
;      db #00,#00,#00,#00,#00,#18,#60,#90,#79,#17,#12,#0d,#0d,#0e,#06,#03
;    ; TINY: 
;      db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
;      db #00,#00,#00,#00,#00,#00,#00,#0c,#18,#38,#5a,#0d,#01,#06,#06,#03
;    ; Sprite 2: (right)
;    ; LARGE: 
;      db #10,#0c,#06,#08,#0b,#1e,#fc,#f3,#48,#f8,#f0,#50,#f0,#ee,#01,#de
;      db #00,#00,#00,#00,#00,#80,#c0,#60,#60,#68,#24,#04,#0c,#3c,#f8,#70
;    ; MEDIUM: 
;      db #00,#00,#70,#08,#10,#16,#fd,#f1,#c0,#f0,#e0,#e0,#e0,#df,#07,#b9
;      db #00,#00,#00,#00,#00,#00,#00,#80,#80,#c0,#48,#18,#70,#f0,#e0,#80
;    ; SMALL: 
;      db #00,#00,#00,#00,#00,#60,#18,#04,#22,#f9,#d0,#e0,#e0,#c0,#df,#3f
;      db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#40,#c0,#80,#00
;    ; TINY: 
;      db #00,#00,#00,#00,#00,#00,#00,#60,#30,#18,#24,#c0,#c0,#84,#b8,#60
;      db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
;
;skeleton_left_enemySprite:
;      ; sprite1
;      db #01,#01,#00,#03,#06,#0a,#31,#30,#08,#04,#22,#3b,#26,#44,#0f,#00
;      db #fc,#fe,#e4,#64,#be,#4a,#20,#90,#4c,#36,#1a,#08,#00,#00,#80,#00
;      ; sprite6
;      db #01,#01,#00,#03,#06,#0a,#31,#38,#16,#09,#04,#0c,#18,#30,#7c,#00
;      db #fc,#fe,#e4,#64,#be,#4a,#20,#90,#4c,#36,#9a,#c8,#c0,#f8,#00,#00
;      ; sprite7
;      db #00,#01,#01,#00,#03,#06,#0a,#32,#31,#0c,#02,#0c,#18,#31,#3d,#00
;      db #00,#fc,#fe,#e4,#64,#be,#8a,#40,#30,#cc,#76,#1a,#c8,#80,#e0,#00
