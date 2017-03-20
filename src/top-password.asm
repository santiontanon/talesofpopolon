;-----------------------------------------------
; Entering password game state
Password_loop:
    call clearScreenLeftToRight

    ; print enter password string:
    ld hl,UI_message_enter_password
    ld de,NAMTBL2+256+9
    ld bc,14
    call LDIRVM

    ; reset the password string:
    ld hl,patternCopyBuffer
    ld de,patternCopyBuffer+1
    xor a
    ld (hl),a
    ld bc,31
    ldir

    call getcharacter_nonwaiting_reset
    ld de,patternCopyBuffer
    ld hl,NAMTBL2+256+32*2+12
    xor a
    ld (game_cycle),a
Password_loop_loop:
    halt
    exx
    call getcharacter_nonwaiting
    exx
    cp 8
    jr z,Password_loop_delete
    cp 13   ;; ENTER
    jr z,Password_loop_TestPassword
    cp 27   ;; ESC
    jp z,TitleScreen_Loop
    or a
    jr nz,Password_loop_insertCharacter

    ld a,(game_cycle)
    inc a
    ld (game_cycle),a
    and #08
    jr z,Password_loop_draw_cursor    
    jr Password_loop_draw_character


Password_loop_draw_cursor:
    ld a,193
;    ld hl,NAMTBL2+256+32*2+12
    call WRTVRM
    jr Password_loop_loop


Password_loop_draw_character:
    ld a,(de)
;    ld hl,NAMTBL2+256+32*2+12
    call WRTVRM
    jr Password_loop_loop


Password_loop_delete:
    ld a,e
    cp patternCopyBuffer%256
    jr z,Password_loop_delete_nodec
    cp (patternCopyBuffer+8)%256
    jr z,Password_loop_delete_up_a_line
    xor a
    call WRTVRM ; delete the cursor
Password_loop_delete_bforedec:
    dec de
    dec hl
Password_loop_delete_nodec:
    xor a
    ld (de),a
    jr Password_loop_loop

Password_loop_delete_up_a_line:
    xor a
    call WRTVRM ; delete the cursor
    ld hl,NAMTBL2+256+32*2+12+8
    jr Password_loop_delete_bforedec

Password_loop_insertCharacter:
    ld b,a
    ld a,e
    cp (patternCopyBuffer+16)%256
    jr z,Password_loop_loop
    ld a,b
    ld (de),a
    call WRTVRM
    inc de
    inc hl
    ld a,e
    cp (patternCopyBuffer+8)%256
    jr z,Password_loop_delete_down_a_line
    jr Password_loop_loop

Password_loop_delete_down_a_line:
    ld hl,NAMTBL2+256+32*3+12
    jr Password_loop_loop


;-----------------------------------------------
; Checks whether the password is correct, decodes it and starts the game
Password_loop_TestPassword:
    exx ; save DE/HL for the password loop
    ; test if it works
    ld hl,patternCopyBuffer
    ld de,password_buffer
    ld b,16
    ld c,0  ; c will keep the XOR
Password_loop_TestPassword_to_bytes:
    ld a,(hl)
    cp 'A'
    jp m,Password_loop_TestPassword_noletter
    sub 43   ; make the letters be just before the numbers
Password_loop_TestPassword_noletter:
    sub 22  ;; so that 'A' is 0, and '0' is 26
    ld (de),a
    xor c
    ld c,a
    inc hl
    inc de
    djnz Password_loop_TestPassword_to_bytes

    or a
    jr z,Password_loop_TestPassword_passesXORtest

    ld hl,SFX_playerhit
    call playSFX
Password_loop_TestPassword_doesnotpasshealthtest:
    exx ; restore DE/HL for the password loop
    jp Password_loop_loop

Password_loop_TestPassword_passesXORtest:
    ; check health is > 0:
    ld a,(password_buffer+1)
    or a
    jr z,Password_loop_TestPassword_doesnotpasshealthtest

    call initializeGame

    ; decode password:
    ; health:
    ld hl,password_buffer+1
    ld a,(hl)
    ld (player_health),a
    inc hl
    ; mana:
    ld a,(hl)
    ld (player_mana),a
    inc hl

    ; weapons and secondary weapons:
    ld de,available_weapons+1
    ld a,1
    ld b,(hl)
    bit 0,b
    jr z,Password_loop_TestPassword_no_sword
    ld (de),a
Password_loop_TestPassword_no_sword:
    inc de
    bit 1,b
    jr z,Password_loop_TestPassword_no_goldsword
    ld (de),a
Password_loop_TestPassword_no_goldsword:
    ld de,available_secondary_weapons+1
    bit 2,b
    jr z,Password_loop_TestPassword_no_arrows
    ld (de),a
Password_loop_TestPassword_no_arrows:
    inc de
    bit 3,b
    jr z,Password_loop_TestPassword_no_icearrows
    ld (de),a
Password_loop_TestPassword_no_icearrows:
    inc de
    bit 4,b
    jr z,Password_loop_TestPassword_no_hourglass
    ld (de),a
Password_loop_TestPassword_no_hourglass:
    inc hl

    ; decode armors:
    ld de,available_armors+1
    ld b,2
Pasword_lop_TestPassword_decoding_armors_loop:
    ld c,(hl)
    bit 4,c
    jr z,Password_loop_TestPassword_no_armor
    ld (de),a
Password_loop_TestPassword_no_armor:
    inc de
    inc hl
    djnz Pasword_lop_TestPassword_decoding_armors_loop

    ; decode keys:
    xor a
    ld c,(hl)
    bit 4,c
    jr z,Password_loop_TestPassword_no_keys1
    inc a
Password_loop_TestPassword_no_keys1:
    inc hl
    ld c,(hl)
    bit 4,c
    jr z,Password_loop_TestPassword_no_keys2
    inc a
    inc a
Password_loop_TestPassword_no_keys2:
    inc hl
    ld (player_keys),a

    ; decode bosses:
    ld de,globalState_BossesKilled
    ld b,4
    ld a,1
Pasword_lop_TestPassword_decoding_bosses_loop:
    ld c,(hl)
    bit 4,c
    jr z,Password_loop_TestPassword_boss_alive
    ld (de),a
Password_loop_TestPassword_boss_alive:
    inc de
    inc hl
    djnz Pasword_lop_TestPassword_decoding_bosses_loop

    ; decode doors:
    ld hl,password_buffer+4 ;; the position where the doors start to be decoded
    ld de,globalState_doorsOpen
    ld b,4  ; loop 4 times, each loop does 2 maps, so this decodes the first 8 maps, which are the only ones encoded in the password
Pasword_lop_TestPassword_decoding_doors_loop:
    ld c,(hl)
    bit 0,c
    jr z,Pasword_lop_TestPassword_decoding_doors_door1_closed
    ld (de),a
Pasword_lop_TestPassword_decoding_doors_door1_closed:
    inc de
    bit 1,c
    jr z,Pasword_lop_TestPassword_decoding_doors_door2_closed
    ld (de),a
Pasword_lop_TestPassword_decoding_doors_door2_closed:
    inc de
    bit 2,c
    jr z,Pasword_lop_TestPassword_decoding_doors_door3_closed
    ld (de),a
Pasword_lop_TestPassword_decoding_doors_door3_closed:
    inc de
    bit 3,c
    jr z,Pasword_lop_TestPassword_decoding_doors_door4_closed
    ld (de),a
Pasword_lop_TestPassword_decoding_doors_door4_closed:
    inc hl
    inc de
    djnz Pasword_lop_TestPassword_decoding_doors_loop

    ; decode items:
    ld de,globalState_itemsPickedUp
    ld b,8  ; loop 8 times, once per map
Pasword_lop_TestPassword_decoding_items_loop:
    ld c,(hl)
    bit 0,c
    jr z,Pasword_lop_TestPassword_decoding_items_item1_notpickedup
    ld (de),a
Pasword_lop_TestPassword_decoding_items_item1_notpickedup:
    inc de
    bit 1,c
    jr z,Pasword_lop_TestPassword_decoding_items_item2_notpickedup
    ld (de),a
Pasword_lop_TestPassword_decoding_items_item2_notpickedup:
    inc de
    bit 2,c
    jr z,Pasword_lop_TestPassword_decoding_items_item3_notpickedup
    ld (de),a
Pasword_lop_TestPassword_decoding_items_item3_notpickedup:
    inc de
    bit 3,c
    jr z,Pasword_lop_TestPassword_decoding_items_item4_notpickedup
    ld (de),a
Pasword_lop_TestPassword_decoding_items_item4_notpickedup:
    inc hl
    inc de
    ; inc HL MAX_PICKUPS_PER_MAP-4
    push bc
    ld bc,MAX_PICKUPS_PER_MAP-4
    ex de,hl
    add hl,bc
    ex de,hl
    pop bc
    djnz Pasword_lop_TestPassword_decoding_items_loop

    ld a,1
    ld (globalState_itemsPickedUp+4),a  ;; the 5th item (a key) needs to have been picked up to 
                                        ;; save a password, but we are not saving it to save a bit

    ; decode start location:
    ; assume it's fortress1:
    ld a,MAP_FORTRESS1
    ld (player_map),a
    ld hl,map_fortress1_pletter
    ld a,12*16+8
    ld (player_y),a
    ld (player_precision_y+1),a
    ld a,(password_buffer+12)
    bit 4,a
    jr z,Pasword_lop_TestPassword_decoding_startlocation_its_fortress1
    ; set fortress 2:
    ld a,MAP_FORTRESS2
    ld (player_map),a
    ld hl,map_fortress2_pletter
    ld a,6*16+8
    ld (player_x),a
    ld (player_precision_x+1),a
    ld a,8*16+8
    ld (player_y),a
    ld (player_precision_y+1),a
    ld a,#a0
    ld (texture_colors+7),a
    ld (texture_colors+8),a
Pasword_lop_TestPassword_decoding_startlocation_its_fortress1:

    ld a,GAME_STATE_PLAYING
    ld (game_state),a
    jp Game_Loop_after_setting_map


;-----------------------------------------------
;; Adapted from the CHGET routine here: https://sourceforge.net/p/cbios/cbios/ci/master/tree/src/main.asm#l289
;; It returns 0 if no key is ready to be read
;; If a key is ready to be read, it checks if it is one of these:
;; - ESC / DELETE / ENTER
;; - 'a' - 'z' (converts it to upper case and returns)
;; - 'Z' - 'Z'
;; - otherwise, it returns 0
getcharacter_nonwaiting:
    ld hl,(GETPNT)
    ld de,(PUTPNT)
    call DCOMPR
    jr z,getcharacter_nonwaiting_invalidkey
    ;; there is a character ready to be read:
    ld a,(hl)
    push af
    inc hl
    ld a,l
    cp #00ff & (KEYBUF + 40)
    jr nz,getcharacter_nonwaiting_nowrap
    ld hl,KEYBUF
getcharacter_nonwaiting_nowrap:
    ld (GETPNT),hl
    pop af
    cp 8    ;; DELETE
    ret z
    cp 13   ;; ENTER
    ret z
    cp 27   ;; ESC
    ret z
    cp 'z'+1
    jp p,getcharacter_nonwaiting_invalidkey
    cp 'a'
    jp p,getcharacter_nonwaiting_lower_case
getcharacter_nonwaiting_after_converting_to_upper_case
    cp 'Z'+1
    jp p,getcharacter_nonwaiting_invalidkey
    cp 'A'
    ret p
    cp '9'+1
    jp p,getcharacter_nonwaiting_invalidkey
    cp '0'
    ret p
getcharacter_nonwaiting_invalidkey:
    xor a
    ret
getcharacter_nonwaiting_lower_case:
    add a,'A'-'a'
    jr getcharacter_nonwaiting_after_converting_to_upper_case

getcharacter_nonwaiting_reset:
    di
    ld hl,(PUTPNT)
    ld (GETPNT),hl
    ei
    ret


;-----------------------------------------------
; Generates a password based on the current state, 
; and displays it as a message
triggerEvent_generatePassword: 
    ; Generate password in "patternCopyBuffer" 
    ; health and mana:
    ld hl,player_health
    ld de,patternCopyBuffer+1   ;; +1 since the first byte is the XOR
    ldi ; player health
    ldi ; player mana
    ; weapons:
    ld hl,available_weapons+1
    ld b,(hl) ; first bit of the available weapons (sword)    
    inc hl
    ld a,(hl)
    or a
    jr z,triggerEvent_generatePassword_no_gold_sword
    set 1,b ; gold sword
triggerEvent_generatePassword_no_gold_sword:
    ld hl,available_secondary_weapons+1
    ld a,(hl)
    or a
    jr z,triggerEvent_generatePassword_no_arrows
    set 2,b ; arrows
triggerEvent_generatePassword_no_arrows:
    inc hl
    ld a,(hl)
    or a
    jr z,triggerEvent_generatePassword_no_ice_arrows
    set 3,b ; ice arrows
triggerEvent_generatePassword_no_ice_arrows:
    inc hl
    ld a,(hl)
    or a
    jr z,triggerEvent_generatePassword_no_hourglass
    set 4,b ; hourglass
triggerEvent_generatePassword_no_hourglass:
    ex de,hl
    ld (hl),b
    inc hl

    ; armors:
    ld de,available_armors+1
    ld a,(de)
    or a
    jr z,triggerEvent_generatePassword_no_silver_armor
    ld a,#10
triggerEvent_generatePassword_no_silver_armor:
    ld (hl),a
    inc de
    inc hl
    ld a,(de)
    or a
    jr z,triggerEvent_generatePassword_no_golden_armor
    ld a,#10
triggerEvent_generatePassword_no_golden_armor:
    ld (hl),a
    inc hl

    ; keys:
    ld a,(player_keys)
    ld b,0
    bit 0,a
    jr z,triggerEvent_generatePassword_keysbit0_zero
    ld b,#10
triggerEvent_generatePassword_keysbit0_zero:
    ld (hl),b
    inc hl
    ld b,0
    bit 1,a
    jr z,triggerEvent_generatePassword_keysbit1_zero
    ld b,#10
triggerEvent_generatePassword_keysbit1_zero:
    ld (hl),b
    inc hl

    ; bosses:
    ld b,4
    ld de,globalState_BossesKilled
triggerEvent_generatePassword_bosskilled_loop:
    ld a,(de)
    or a
    jr z,triggerEvent_generatePassword_bosskilled_zero
    ld a,#10
triggerEvent_generatePassword_bosskilled_zero:
    ld (hl),a
    inc hl
    inc de
    djnz triggerEvent_generatePassword_bosskilled_loop

    ; save the save location (fortress1 or fortress2):
    ld a,#10
    ld (hl),a   ; save "fortress2" temporarily

    ld a,(player_map)
    cp MAP_FORTRESS1
    jr nz,triggerEvent_generatePassword_savelocation_fortress2
    xor a
    ld (hl),a   ; save "fortress1"
triggerEvent_generatePassword_savelocation_fortress2:
    ; set to 0 the last 3 bytes of the password
    inc hl
    xor a
    ld (hl),a
    inc hl
    ld (hl),a
    inc hl
    ld (hl),a

    ; doors:
    ld hl,patternCopyBuffer+4
    ld de,globalState_doorsOpen
    ld b,4
triggerEvent_generatePassword_doors_loop:
    ld c,(hl)
    ld a,(de)
    or a
    jr z,triggerEvent_generatePassword_doors1_zero
    set 0,c
triggerEvent_generatePassword_doors1_zero:
    inc de
    ld a,(de)
    or a
    jr z,triggerEvent_generatePassword_doors2_zero
    set 1,c
triggerEvent_generatePassword_doors2_zero:
    inc de
    ld a,(de)
    or a
    jr z,triggerEvent_generatePassword_doors3_zero
    set 2,c
triggerEvent_generatePassword_doors3_zero:
    inc de
    ld a,(de)
    or a
    jr z,triggerEvent_generatePassword_doors4_zero
    set 3,c
triggerEvent_generatePassword_doors4_zero:
    ld (hl),c
    inc hl
    inc de
    djnz triggerEvent_generatePassword_doors_loop

    ; items:
    ld de,globalState_itemsPickedUp
    ld b,8
triggerEvent_generatePassword_items_loop:
    ld c,(hl)
    ld a,(de)
    or a
    jr z,triggerEvent_generatePassword_items1_zero
    set 0,c
triggerEvent_generatePassword_items1_zero:
    inc de
    ld a,(de)
    or a
    jr z,triggerEvent_generatePassword_items2_zero
    set 1,c
triggerEvent_generatePassword_items2_zero:
    inc de
    ld a,(de)
    or a
    jr z,triggerEvent_generatePassword_items3_zero
    set 2,c
triggerEvent_generatePassword_items3_zero:
    inc de
    ld a,(de)
    or a
    jr z,triggerEvent_generatePassword_items4_zero
    set 3,c
triggerEvent_generatePassword_items4_zero:
    ld (hl),c
    inc hl

    push bc
    ld bc,MAX_PICKUPS_PER_MAP-3
    ex de,hl
    add hl,bc
    ex de,hl
    pop bc

    djnz triggerEvent_generatePassword_items_loop

    ; XOR:
    ld hl,patternCopyBuffer+1
    ld b,15
    xor a
triggerEvent_generatePassword_xor_loop
    xor (hl)
    inc hl
    djnz triggerEvent_generatePassword_xor_loop
    ld (patternCopyBuffer),a

    ; copy to currentMapMessages + 44 + 8
    ; (which has a template for it):
    ; by turning it into characters
    ld hl,patternCopyBuffer
    ld de,currentMapMessages + 44 + 7
    ld b,8
triggerEvent_generatePassword_convert_to_characters_line1:
    ld a,(hl)
    cp 26
    jp p,triggerEvent_generatePassword_convert_to_characters_line1_number
    add a,'A'
    jr triggerEvent_generatePassword_convert_to_characters_line1_continue
triggerEvent_generatePassword_convert_to_characters_line1_number:
    add a,'0'-26
triggerEvent_generatePassword_convert_to_characters_line1_continue:
    ld (de),a
    inc hl
    inc de
    djnz triggerEvent_generatePassword_convert_to_characters_line1

    ld de,currentMapMessages + 66 + 7
    ld b,8
triggerEvent_generatePassword_convert_to_characters_line2:
    ld a,(hl)
    cp 26
    jp p,triggerEvent_generatePassword_convert_to_characters_line2_number
    add a,'A'
    jr triggerEvent_generatePassword_convert_to_characters_line2_continue
triggerEvent_generatePassword_convert_to_characters_line2_number:
    add a,'0'-26
triggerEvent_generatePassword_convert_to_characters_line2_continue:
    ld (de),a
    inc hl
    inc de
    djnz triggerEvent_generatePassword_convert_to_characters_line2

    jp triggerEvent_Message1
