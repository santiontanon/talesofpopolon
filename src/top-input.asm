;-----------------------------------------------
; checks for the status of trigger 1
checkTrigger1:
    ld a,#08    ;; get the status of the 8th keyboard row (to get SPACE and arrow keys)
    call SNSMAT
    cpl 
    and #01
    ret nz
    call readJoystick1Status
    and #10
    ret


;-----------------------------------------------
; checks for the status of trigger 2
checkTrigger2:
    ld a,#04    ;; get the status of the 4th keyboard row (to get M key)
    call SNSMAT
    cpl 
    and #04
    ret nz
    call readJoystick1Status
    and #20
    ret


;-----------------------------------------------
readJoystick1Status:
    ld a,15 ; read the joystick 1 status:
    call RDPSG
    and #bf
    ld e,a
    ld a,15
    call WRTPSG
    dec a
    call RDPSG
    cpl ; invert the bits (so that '1' means direction pressed)
    ret

;-----------------------------------------------
; checks for the status of trigger 1, sets 'a' to 1 if trigger 1 was just pressed,
; and updates (previous_trigger1) with the latest state of trigger 1
; - modifies bc 
checkTrigger1updatingPrevious:
    push hl
    push de
    call checkTrigger1
    ld hl,previous_trigger1
    ld b,(hl)
    ld (hl),a
    pop de
    pop hl
    or a
    ret z
    xor b
    ret


chheckInput_get_P:
    ld a,#04    ;; get the status of the 4th keyboard row (to get the P key)
    call SNSMAT 
    bit 5,a ;; "P"
    ret

checkInput_pause:
    ; pause music:
    xor a
    ld (MUSIC_play),a
    call CLEAR_PSG_VOLUME
    ld hl,SFX_item_pickup
    call playSFX
    ; display pause message:
    ld hl,UI_message_pause
    ld c,UI_message_pause_end-UI_message_pause
    call displayUIMessage

checkInput_pause_loop:
    call chheckInput_get_P
    jr nz,checkInput_pause_p_released
    halt
    jr checkInput_pause_loop
checkInput_pause_p_released:
    call chheckInput_get_P
    jr z,checkInput_pause_p_pressed_again
    halt
    jr checkInput_pause_p_released
checkInput_pause_p_pressed_again:
    call chheckInput_get_P
    jr nz,checkInput_pause_resume_game
    halt
    jr checkInput_pause_p_pressed_again
checkInput_pause_resume_game:
    ; resume music:
    ld a,1
    ld (MUSIC_play),a
    ret


;-----------------------------------------------
; checks all the player input (left/right/thrust/fire)
checkInput:
    ld a,(previous_keymatrix0)
    ld b,a
    xor a       ;; get the status of the 0th keyboard row (to get status of "1", "2" and "3")
    call SNSMAT
    ld (previous_keymatrix0),a
    xor b   ;; we have a 1 on those that have changed
    and b   ;; we have a 1 on those that have changed, and that were not pressed before
    bit 0,a ;; "0"
    call nz,checkInput_request_screen_size_change
    bit 1,a ;; "1"
    call nz,ChangeWeapon
    bit 2,a ;; "2"
    call nz,ChangeSecondaryWeapon
    bit 3,a ;; "3"
    call nz,ChangeArmor

    ld a,#04    ;; get the status of the 4th keyboard row (to get the M, R and P key)
    call SNSMAT 
    cpl
    bit 7,a ;; "R"
    call nz,checkInput_request_CPUmode_change
    bit 5,a ;; "P"
    call nz,checkInput_pause
    and #04     ;; we keep the status of M
    ld b,a
    ld a,#08    ;; get the status of the 8th keyboard row (to get SPACE and arrow keys)
    call SNSMAT 
    cpl
    and #f1     ;; keep only the arrow keys and space
    or b        ;; we bring the state of M from before
    jr z,Readjoystick   ;; if no key was pressed, then check the joystick
    bit 0,a
    call nz,Trigger1Pressed    ;; when trigger 1 is hold, movement changes, so, we have a different function
    bit 2,a
    call nz,Trigger2Pressed
    bit 7,a
    call nz,TurnRight
    bit 4,a
    call nz,TurnLeft
    bit 5,a
    call nz,MoveForward
    bit 6,a
    call nz,MoveBackwards

    ld hl,previous_trigger1
    bit 0,a
    jr nz,checkInput_trigger1WasPressed
    ld (hl),0
    jr checkInput_checkTrigger2
checkInput_trigger1WasPressed:
    ld (hl),1
checkInput_checkTrigger2:
    ld hl,previous_trigger2
    bit 2,a
    jr nz,checkInput_trigger2WasPressed
    ld (hl),0
    ret
checkInput_trigger2WasPressed:
    ld (hl),1
    ret

Readjoystick:   
    ;; Using BIOS calls:
    call readJoystick1Status
    bit 4,a
    call nz,Trigger1Pressed    ;; when trigger 1 is hold, movement changes, so, we have a different function
    bit 5,a
    call nz,Trigger2Pressed
    bit 3,a
    call nz,TurnRight
    bit 2,a
    call nz,TurnLeft
    bit 0,a
    call nz,MoveForward
    bit 1,a
    call nz,MoveBackwards

    ld hl,previous_trigger1
    bit 4,a
    jr nz,Readjoystick_trigger1WasPressed
    ld (hl),0
    jr Readjoystick_checkTrigger2
Readjoystick_trigger1WasPressed:
    ld (hl),1
Readjoystick_checkTrigger2:
    ld hl,previous_trigger2
    bit 5,a
    jr nz,Readjoystick_trigger2WasPressed
    ld (hl),0
    ret
Readjoystick_trigger2WasPressed:
    ld (hl),1
    ret


checkInput_request_screen_size_change:
    ld hl,raycast_screen_size_change_requested
    ld (hl),1
    ret

checkInput_request_CPUmode_change:
    push af
    ld hl,CPUmode_change_requested
    ld (hl),1
checkInput_request_CPUmode_change_wait_for_R_released:
    call chheckInput_get_P    
    bit 7,a 
    jr z,checkInput_request_CPUmode_change_wait_for_R_released   
    pop af
    ret


Trigger1Pressed:
    push af
    ld a,(previous_trigger1)
    or a
    jr nz,Trigger1Pressed_continue
    ld a,(player_state)
    cp PLAYER_STATE_WALKING
    jr nz,Trigger1Pressed_continue
    ld a,PLAYER_STATE_ATTACK
    ld (player_state),a
    xor a
    ld (player_state_cycle),a
    call playerWeaponSwing

Trigger1Pressed_continue:
    pop af
    ret

Trigger2Pressed:
    push af
    ld a,(previous_trigger2)
    or a
    jr nz,Trigger2Pressed_continue

    ;; fire arrow:
    ld a,(current_secondary_weapon)
    or a
    jr z,Trigger2Pressed_continue   ;; if no secondary weapon selected
    dec a
    call z,fireArrow   ;; if arrows are selected
    dec a
    call z,fireIceArrow   ;; if ice arrows are selected
    dec a
    call z,triggerHourglass   ;; if hourglass is selected
Trigger2Pressed_continue:
    pop af
    ret

TurnLeft:
    push af
    ld a,(previous_trigger1)
    or a
    jp nz,MoveLeft_nopush
    ld a,(player_angle)
    add a,-4
    ld (player_angle),a
    pop af
    ret

TurnRight:  
    push af
    ld a,(previous_trigger1)
    or a
    jp nz,MoveRight_nopush
    ld a,(player_angle)
    add a,4
    ld (player_angle),a
    pop af
    ret

MoveForward:  
    push af
    ld hl,cos_table
    ld b,0
    ld a,(player_angle)
    ld c,a
    add hl,bc
    add hl,bc
    push hl
    ld c,(hl)
    inc hl
    ld b,(hl)
    ld hl,(player_precision_x)
    add hl,bc
    ld a,(player_y)
    ld b,a
    ld c,h
    call getMapPosition
    cp MAP_TILE_DOOR    
    call z,openDoor   ; after this call, "a" contains the new value of the map position (0 if the door was open, or MAP_TILE_DOOR otherwise)
    cp MAP_TILE_EXIT
    jr z,popHLAndJumpToWalkedIntoAnExit
    cp MAP_TILE_EXIT2
    jr z,popHLAndJumpToWalkedIntoAnExit
    cp MAP_TILE_MIRROR_WALL
    call z,walkedIntoAMirrorWall
    or a
    jr nz,MoveForward_skip_x
    ld (player_precision_x),hl
    ld a,h
    ld (player_x),a
MoveForward_skip_x:
    pop hl
    ld bc,sin_table-cos_table
    add hl,bc
;    ld hl,sin_table
;    ld b,0
;    ld a,(player_angle)
;    ld c,a
;    add hl,bc
;    add hl,bc
    ld c,(hl)
    inc hl
    ld b,(hl)
    ld hl,(player_precision_y)
    add hl,bc
    ld a,(player_x)
    ld c,a
    ld b,h
    call getMapPosition
    cp MAP_TILE_DOOR    
    call z,openDoor   ; after this call, "a" contains the new value of the map position (0 if the door was open, or MAP_TILE_DOOR otherwise)
    cp MAP_TILE_EXIT
    jp z,walkedIntoAnExit
    cp MAP_TILE_EXIT2
    jp z,walkedIntoAnExit
    cp MAP_TILE_MIRROR_WALL
    call z,walkedIntoAMirrorWall
    or a
    jr nz,MoveForward_skip_y
    ld (player_precision_y),hl
    ld a,h
    ld (player_y),a
MoveForward_skip_y:
    call checkPickups
    pop af
    ret

popHLAndJumpToWalkedIntoAnExit:
    pop hl
    jp walkedIntoAnExit

MoveBackwards:  
    push af
    ld a,(player_angle)
    add a,128
    ld (player_angle),a
    call MoveForward
    ld a,(player_angle)
    add a,128
    ld (player_angle),a
MoveBackwards_do_not_reset_angle:
    pop af
    ret

MoveRight:  
    push af
MoveRight_nopush:
    ld a,(player_angle)
    add a,64
    ld (player_angle),a
    call MoveForward
    ld a,(player_angle)
    add a,-64
    ld (player_angle),a
    pop af
    ret

MoveLeft:  
    push af
MoveLeft_nopush:
    ld a,(player_angle)
    add a,-64
    ld (player_angle),a
    call MoveForward
    ld a,(player_angle)
    add a,64
    ld (player_angle),a
    pop af
    ret

fireArrow:
    push af
    ld a,(player_mana)
    or a
    jr z,fireArrow_continue
    ld hl,arrow_data  ; since there can be at most 2 arrows in screen at a time, we just unroll the search loop:
    ld a,(hl)
    or a
    jr z,fireArrow_slot_found
    ld hl,arrow_data+ARROW_STRUCT_SIZE
    ld a,(hl)
    or a
    jr z,fireArrow_slot_found
    jr fireArrow_continue   

fireArrow_slot_found:
    ld a,(player_mana)  ;; use up one heart:
    dec a
    ld (player_mana),a
    ld (hl),ITEM_ARROW   ; state: arrow
fireArrow_slot_found_continue:
    call update_UI_mana
    ; actually fire the arrow: arrow type, low bytes of x,y, precision x,y direction, high bytes of x,y, sprite (10 bytes)
    inc hl
    ld de,player_precision_x
    ex de,hl
    ldi ; player_precision_x
;    ldi
    inc hl
    ldi ; player_precision_y
;    ldi
    ld hl,cos_table
    ld b,0
    ld a,(player_angle)
    ld c,a
    add hl,bc
    add hl,bc
    push hl
    ldi ; direction_vector_x
    ldi
    pop hl
    ld bc,sin_table-cos_table
    add hl,bc
    ldi ; direction_vector_y
    ldi
    ld a,(player_x)
    ld (de),a
    inc de
    ld a,(player_y)
    ld (de),a
    inc de
    ld a,(current_secondary_weapon)
    dec a
    jr nz,fireArrow_setIceArrowSprite
    ld a,SPRITE_PATTERN_ARROW
    jr fireArrow_spriteSet
fireArrow_setIceArrowSprite:
    ld a,SPRITE_PATTERN_ICEARROW
fireArrow_spriteSet:
    ld (de),a

    ; play SFX:
    ld hl,SFX_fire_arrow
    call playSFX

fireArrow_continue:
    pop af
    ret


fireIceArrow:
    push af
    ld a,(player_mana)
    cp 2
    jp m,fireArrow_continue
    ld hl,arrow_data  ; since there can be at most 2 arrows in screen at a time, we just unroll the search loop:
    ld a,(hl)
    or a
    jr z,fireIceArrow_slot_found
    ld hl,arrow_data+ARROW_STRUCT_SIZE
    ld a,(hl)
    or a
    jr z,fireIceArrow_slot_found
    jr fireArrow_continue   

fireIceArrow_slot_found:
    ld a,(player_mana)  ;; use up two hearts:
    dec a
    dec a
    ld (player_mana),a
    ld (hl),ITEM_ICEARROW   ; state: ice arrow
    jr fireArrow_slot_found_continue


triggerHourglass:
    push af
    ld a,(player_mana)
    cp 4
    jp m,triggerHourglass_continue
    ld a,(hourglass_timer)
    or a
    jr nz,triggerHourglass_continue

    call pauseMusic

    ld a,HOURGLASS_TIME
    ld (hourglass_timer),a
    ld a,(player_mana)
    sub 4
    ld (player_mana),a
    call update_UI_mana
triggerHourglass_continue:
    pop af
    ret


