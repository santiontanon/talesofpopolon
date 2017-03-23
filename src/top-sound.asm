;-----------------------------------------------
; Uncompresses and starts playing a song 
; arguments: 
; - hl: pointer to the compressed data
PlayCompressedSong:
;    push hl
    push de
    push bc
    push af
    ld de,music_buffer
    call pletter_unpack

    di
    ld hl,music_buffer
    ld a,1
    ld (MUSIC_play),a
    ld (MUSIC_pointer),hl
    ld (MUSIC_start_pointer),hl
;    ld hl,MUSIC_repeat_stack
;    ld (MUSIC_repeat_stack_ptr),hl
    ei
    pop af
    pop bc
    pop de
;    pop hl
    ret


;-----------------------------------------------
; Starts playing an SFX
; arguments: 
; - hl: pointer to the SFX to play
playSFX:
    di
    ld (SFX_pointer),hl
    ld a,1
    ld (SFX_play),a
    ei
    ret


;-----------------------------------------------
; Loads the interrupt hook for playing music:
SETUP_MUSIC_INTERRUPT:
    ld a,8
    ld (Music_tempo),a	;; default music tempo

;    ld  hl,TIMI     ;OLD HOOK SAVE
;    ld  de,HKSAVE
;    ld  bc,5
;    ldir

    ld  a,JPCODE    ;NEW HOOK SET
    di
    ld  (TIMI),a
    ld  hl,MUSIC_INT
    ld  (TIMI+1),hl
    ei
    ret

;-----------------------------------------------
; Restores the previous interrupt Hook:
;RESTORE_INTERRUPT:
;    ld  hl,HKSAVE
;    ld  de,TIMI
;    ld  bc,5
;    di
;    ldir
;    ei  
;    call #90 ; reset audio channels
;    ret

;-----------------------------------------------
; Music player interrupt routine
MUSIC_INT:     ; This routine is called 50 or 60 times / sec 
    push af  

    ld a,(MUSIC_play)
    or a
    jp z,MUSIC_INT_NO_MUSIC_NO_POP

    push de
    ;; handle instruments currently playing
    call MUSIC_INT_HANDLE_INSTRUMENTS

    ld a,(MUSIC_tempo_counter)
    or a
    jp nz,MUSIC_INT_skip

;    push ix
    push hl
;    ld ix,(MUSIC_repeat_stack_ptr)
    ld hl,(MUSIC_pointer)
    call MUSIC_INT_INTERNAL
    ld (MUSIC_pointer),hl
;    ld (MUSIC_repeat_stack_ptr),ix
    pop hl
;    pop ix
    ld a,(Music_tempo)
    ld (MUSIC_tempo_counter),a
    jr MUSIC_INT_NO_MUSIC

MUSIC_INT_skip:
    dec a
    ld (MUSIC_tempo_counter),a

MUSIC_INT_NO_MUSIC:
    pop de
MUSIC_INT_NO_MUSIC_NO_POP:
    ld a,(SFX_play)
    or a
    jp z,MUSIC_INT_NO_SFX

    push hl
;    ld ix,(MUSIC_repeat_stack_ptr)
    ld hl,(SFX_pointer)
    call MUSIC_INT_INTERNAL
    ld (SFX_pointer),hl
;    ld (MUSIC_repeat_stack_ptr),ix
    pop hl

MUSIC_INT_NO_SFX:
    pop af
    ret

    

CLEAR_PSG_VOLUME:
    ld a,8
    ld e,0
    call WRTPSG
    ld a,9
    ld e,0
    call WRTPSG
    ld a,10
    ld e,0
    jp WRTPSG


MUSIC_INT_INTERNAL:
;    ld a,(MUSIC_skip_counter)
;    and a
;    jp nz,MUSIC_INT_MULTISKIP_STEP
MUSIC_INT_LOOP:
    ld a,(hl)
    inc hl 

    ; check if it's a special command:
    bit 7,a
    jp z,MUSIC_INT_LOOP_WRTPSG

    cp MUSIC_CMD_SKIP
    ret z

;    cp MUSIC_CMD_MULTISKIP
;    jp z,MUSIC_INT_MULTISKIP

    cp MUSIC_CMD_SET_INSTRUMENT
    jr z,MUSIC_INT_SET_INSTRUMENT

    cp MUSIC_CMD_PLAY_INSTRUMENT_CH1
    jp z,MUSIC_INT_PLAY_INSTRUMENT_CH1

    cp MUSIC_CMD_PLAY_INSTRUMENT_CH2
    jp z,MUSIC_INT_PLAY_INSTRUMENT_CH2

    cp MUSIC_CMD_PLAY_INSTRUMENT_CH3
    jp z,MUSIC_INT_PLAY_INSTRUMENT_CH3

    cp MUSIC_CMD_GOTO
    jp z,MUSIC_INT_GOTO

    cp MUSIC_CMD_END                 
    jr z,MUSIC_INT_END         ;; if the music sound is over, we are done

    cp SFX_CMD_END                 
    jp z,SFX_INT_END         ;; if the SFX sound is over, we are done

;    cp MUSIC_CMD_REPEAT
;    jp z,MUSIC_INT_REPEAT

;    cp MUSIC_CMD_END_REPEAT
;    jp z,MUSIC_INT_END_REPEAT

MUSIC_INT_LOOP_WRTPSG:
    ld e,(hl)             
    inc hl
    call WRTPSG                ;; send command to PSG
    jr MUSIC_INT_LOOP     

MUSIC_INT_END:
    xor a
    ld (MUSIC_play),a
    ret

SFX_INT_END:
    xor a
    ld (SFX_play),a
    ret    

MUSIC_INT_SET_INSTRUMENT:
    ld d,(hl)   ; instrument
    inc hl
    ld a,(hl)   ; channel
    inc hl
    or a
    jp z,MUSIC_INT_SET_INSTRUMENT_CHANNEL0
    dec a
    jp z,MUSIC_INT_SET_INSTRUMENT_CHANNEL1
MUSIC_INT_SET_INSTRUMENT_CHANNEL2:
    ld a,d
    ld (MUSIC_instruments+2),a
    jp MUSIC_INT_LOOP
MUSIC_INT_SET_INSTRUMENT_CHANNEL1:
    ld a,d
    ld (MUSIC_instruments+1),a
    jp MUSIC_INT_LOOP
MUSIC_INT_SET_INSTRUMENT_CHANNEL0:
    ld a,d
    ld (MUSIC_instruments),a
    jp MUSIC_INT_LOOP

MUSIC_INT_PLAY_INSTRUMENT_CH1:
    ld e,(hl)   ; MSB of frequency
    inc hl
    ld a,1
    call WRTPSG
    ld e,(hl)   ; LSB of frequency
    inc hl
    xor a
    call WRTPSG
    ld a,(MUSIC_instruments)
    or a  ; since MUSIC_INSTRUMENT_SQUARE_WAVE = 0
    ; cp MUSIC_INSTRUMENT_SQUARE_WAVE
    jp z,MUSIC_INT_PLAY_INSTRUMENT_CH1_SW
    dec a ; since MUSIC_INSTRUMENT_PIANO = 1
    ;cp MUSIC_INSTRUMENT_PIANO
    jp z,MUSIC_INT_PLAY_INSTRUMENT_CH1_PIANO
MUSIC_INT_PLAY_INSTRUMENT_CH1_WIND:
    ld de,Wind_instrument_profile+1
    ld (MUSIC_instrument_envelope_ptr),de
    ld a,(Wind_instrument_profile)
    ld e,a
    ld a,8
    call WRTPSG 
    jp MUSIC_INT_LOOP

MUSIC_INT_PLAY_INSTRUMENT_CH1_PIANO:
    ld de,Piano_instrument_profile+1
    ld (MUSIC_instrument_envelope_ptr),de
    ld a,(Piano_instrument_profile)
    ld e,a
    ld a,8
    call WRTPSG 
    jp MUSIC_INT_LOOP

MUSIC_INT_PLAY_INSTRUMENT_CH1_SW:
    ld e,8
    ld a,SquareWave_instrument_volume
    call WRTPSG 
    jp MUSIC_INT_LOOP

MUSIC_INT_PLAY_INSTRUMENT_CH2:
    ld e,(hl)   ; MSB of frequency
    inc hl
    ld a,3
    call WRTPSG
    ld e,(hl)   ; LSB of frequency
    inc hl
    ld a,2
    call WRTPSG
    ld a,(MUSIC_instruments+1)
    or a  ; since MUSIC_INSTRUMENT_SQUARE_WAVE = 0
    ;cp MUSIC_INSTRUMENT_SQUARE_WAVE
    jp z,MUSIC_INT_PLAY_INSTRUMENT_CH2_SW
    dec a ; since MUSIC_INSTRUMENT_PIANO = 1
    ;cp MUSIC_INSTRUMENT_PIANO
    jp z,MUSIC_INT_PLAY_INSTRUMENT_CH2_PIANO
MUSIC_INT_PLAY_INSTRUMENT_CH2_WIND:
    ld de,Wind_instrument_profile+1
    ld (MUSIC_instrument_envelope_ptr+2),de
    ld a,(Wind_instrument_profile)
    ld e,a
    ld a,9
    call WRTPSG 
    jp MUSIC_INT_LOOP

MUSIC_INT_PLAY_INSTRUMENT_CH2_PIANO:
    ld de,Piano_instrument_profile+1
    ld (MUSIC_instrument_envelope_ptr+2),de
    ld a,(Piano_instrument_profile)
    ld e,a
    ld a,9
    call WRTPSG 
    jp MUSIC_INT_LOOP

MUSIC_INT_PLAY_INSTRUMENT_CH2_SW:
    ld a,9
    ld e,SquareWave_instrument_volume
    call WRTPSG 
    jp MUSIC_INT_LOOP


MUSIC_INT_PLAY_INSTRUMENT_CH3:
    ld a,(SFX_play)
    or a
    jp nz,MUSIC_INT_PLAY_INSTRUMENT_CH3_IGNORE
    ld e,(hl)   ; MSB of frequency
    inc hl
    ld a,5
    call WRTPSG
    ld e,(hl)   ; LSB of frequency
    inc hl
    ld a,4
    call WRTPSG
    ld a,(MUSIC_instruments+2)
    or a  ; since MUSIC_INSTRUMENT_SQUARE_WAVE = 0
    ;cp MUSIC_INSTRUMENT_SQUARE_WAVE
    jp z,MUSIC_INT_PLAY_INSTRUMENT_CH3_SW
    dec a ; since MUSIC_INSTRUMENT_PIANO = 1
    ;cp MUSIC_INSTRUMENT_PIANO
    jp z,MUSIC_INT_PLAY_INSTRUMENT_CH3_PIANO
MUSIC_INT_PLAY_INSTRUMENT_CH3_WIND:
    ld de,Wind_instrument_profile+1
    ld (MUSIC_instrument_envelope_ptr+4),de
    ld a,(Wind_instrument_profile)
    ld e,a
    ld a,10
    call WRTPSG 
    jp MUSIC_INT_LOOP

MUSIC_INT_PLAY_INSTRUMENT_CH3_PIANO:
    ld de,Piano_instrument_profile+1
    ld (MUSIC_instrument_envelope_ptr+4),de
    ld a,(Piano_instrument_profile)
    ld e,a
    ld a,10
    call WRTPSG 
    jp MUSIC_INT_LOOP

MUSIC_INT_PLAY_INSTRUMENT_CH3_SW:
    ld a,10
    ld e,SquareWave_instrument_volume
    call WRTPSG 
    jp MUSIC_INT_LOOP

MUSIC_INT_PLAY_INSTRUMENT_CH3_IGNORE:
    inc hl
    inc hl
    jp MUSIC_INT_LOOP

MUSIC_INT_HANDLE_INSTRUMENTS:
    ld a,(MUSIC_instruments)
    or a  ; since MUSIC_INSTRUMENT_SQUARE_WAVE = 0
;    cp MUSIC_INSTRUMENT_SQUARE_WAVE
    jp z,MUSIC_INT_HANDLE_INSTRUMENTS_CH2

    ld de,(MUSIC_instrument_envelope_ptr)
    ld a,(de)
    cp #ff
    jp z,MUSIC_INT_HANDLE_INSTRUMENTS_CH2
    inc de
    ld (MUSIC_instrument_envelope_ptr),de
    ld e,a
    ld a,8
    call WRTPSG

MUSIC_INT_HANDLE_INSTRUMENTS_CH2:
    ld a,(MUSIC_instruments+1)
    or a  ; since MUSIC_INSTRUMENT_SQUARE_WAVE = 0
    ; cp MUSIC_INSTRUMENT_SQUARE_WAVE
    jp z,MUSIC_INT_HANDLE_INSTRUMENTS_CH3

    ld de,(MUSIC_instrument_envelope_ptr+2)
    ld a,(de)
    cp #ff
    jp z,MUSIC_INT_HANDLE_INSTRUMENTS_CH3
    inc de
    ld (MUSIC_instrument_envelope_ptr+2),de
    ld e,a
    ld a,9
    call WRTPSG

MUSIC_INT_HANDLE_INSTRUMENTS_CH3:
    ld a,(SFX_play)
    or a
    ret nz  ; if there is an SFX playing, then do not update the instruments in channel 3!
    ld a,(MUSIC_instruments+2)
    or a  ; since MUSIC_INSTRUMENT_SQUARE_WAVE = 0
    ; cp MUSIC_INSTRUMENT_SQUARE_WAVE
    ret z

    ld de,(MUSIC_instrument_envelope_ptr+4)
    ld a,(de)
    cp #ff
    ret z
    inc de
    ld (MUSIC_instrument_envelope_ptr+4),de
    ld e,a
    ld a,10
    jp WRTPSG


MUSIC_INT_GOTO:
    ld e,(hl)
    inc hl
    ld d,(hl)
    ld hl,(MUSIC_start_pointer)
    add hl,de
    jp MUSIC_INT_LOOP


;MUSIC_INT_MULTISKIP:
;    ld a,(hl)
;    inc hl
;    dec a
;    ld (MUSIC_skip_counter),a
;    ret

;MUSIC_INT_MULTISKIP_STEP:
;    dec a
;    ld (MUSIC_skip_counter),a
;    ret

;MUSIC_INT_REPEAT:
;    ld a,(hl)
;    inc hl
;    ld (ix),a
;    ld (ix+1),l
;    ld (ix+2),h
;    inc ix
;    inc ix
;    inc ix
;    jp MUSIC_INT_LOOP

;MUSIC_INT_END_REPEAT:
    ;; decrease the top value of the repeat stack
    ;; if it is 0, pop
    ;; if it is not 0, goto the repeat point
;    ld a,(ix-3)
;    dec a
;    cp 0
;    jp z,MUSIC_INT_END_REPEAT_POP
;    ld (ix-3),a
;    ld l,(ix-2)
;    ld h,(ix-1)
;    jp MUSIC_INT_LOOP

;MUSIC_INT_END_REPEAT_POP:
;    dec ix
;    dec ix
;    dec ix
;    jp MUSIC_INT_LOOP


StopPlayingMusic:
    ld hl,SFX_play
    ld b,6
    xor a
StopPlayingMusic_loop:
    ld (hl),a
    inc hl
    djnz StopPlayingMusic_loop
;    ld (SFX_play),a
;    ld (MUSIC_play),a
;    ld (MUSIC_skip_counter),a
;    ld (MUSIC_tempo_counter),a
;    ld hl,MUSIC_instruments
;    ld (MUSIC_instruments),a
;    ld (hl),a
;    ld (MUSIC_instruments+1),a
;    inc hl
;    ld (hl),a
;    ld (MUSIC_instruments+2),a
;    inc hl
;    ld (hl),a
;    ld hl,MUSIC_repeat_stack
;    ld (MUSIC_repeat_stack_ptr),hl
    jp CLEAR_PSG_VOLUME


pauseMusic:
  xor a
  ld (MUSIC_play),a
  jp CLEAR_PSG_VOLUME


resumeMusic:
  ld a,1
  ld (MUSIC_play),a
  ret


; for making the music louder:
;Piano_instrument_profile:
;    db 5,10,15,14,13,12,11,11,10,10,9,9,8,#ff
;Wind_instrument_profile:
;    db 0,4,8,10,12,13,14, #ff
;SquareWave_instrument_volume:   equ 14

; with these the music is quieter, and the SFX are heard better:
Piano_instrument_profile:
    db 4,8,12,11,10,10,9,9,8,8,7,7,6,#ff
Wind_instrument_profile:
    db 0,3,6,8,10,11,12, #ff
SquareWave_instrument_volume:   equ 12


SFX_fire_arrow:   
  db 4,#00,5,#04    ;; frequency
  db 10,#10          ;; volume
  db 11,#00,12,#10  ;; envelope frequency
  db 13,#09         ;; shape of the envelope
;  db 7,#b8          ;; sets channels to wave
  db MUSIC_CMD_SKIP,MUSIC_CMD_SKIP
  db 4,#00,5,#08    ;; frequency
  db MUSIC_CMD_SKIP, MUSIC_CMD_SKIP, MUSIC_CMD_SKIP, MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP, MUSIC_CMD_SKIP, MUSIC_CMD_SKIP, MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP, MUSIC_CMD_SKIP, MUSIC_CMD_SKIP, MUSIC_CMD_SKIP
  db 10,#00          ;; silence
  db SFX_CMD_END    


SFX_fire_bullet_enemy:   
  db 4,#00,5,#02    ;; frequency
  db 10,#10          ;; volume
  db 11,#00,12,#10  ;; envelope frequency
  db 13,#09         ;; shape of the envelope
;  db 7,#b8          ;; sets channels to wave
  db MUSIC_CMD_SKIP,MUSIC_CMD_SKIP
  db 4,#00,5,#04    ;; frequency
  db MUSIC_CMD_SKIP, MUSIC_CMD_SKIP, MUSIC_CMD_SKIP, MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP, MUSIC_CMD_SKIP, MUSIC_CMD_SKIP, MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP, MUSIC_CMD_SKIP, MUSIC_CMD_SKIP, MUSIC_CMD_SKIP
  db 10,#00          ;; silence
  db SFX_CMD_END    


SFX_sword_swing:
  db  7,#9c    ;; noise in channel C, and tone in channels B and A
  db 10,#0a    ;; volume
  db  6,#16    ;; noise frequency
  db MUSIC_CMD_SKIP
  db 10,#0c    ;; volume
  db  6,#14    ;; noise frequency
  db MUSIC_CMD_SKIP
  db 10,#0f    ;; volume
  db  6,#12    ;; noise frequency
  db MUSIC_CMD_SKIP
  db  6,#10    ;; noise frequency
  db MUSIC_CMD_SKIP
  db 10,#0c    ;; volume
  db  6,#08    ;; noise frequency
  db MUSIC_CMD_SKIP
  db 10,#0a    ;; volume
  db  6,#06    ;; noise frequency
  db MUSIC_CMD_SKIP
  db 10,#08    ;; volume
  db  6,#04    ;; noise frequency
  db MUSIC_CMD_SKIP
  db 10,#06    ;; volume
  db  6,#02    ;; noise frequency
  db MUSIC_CMD_SKIP
  db 10,#04    ;; volume
  db  6,#01    ;; noise frequency
  db MUSIC_CMD_SKIP
  db 10,#02    ;; volume
  db MUSIC_CMD_SKIP
  db  7,#b8    ;; SFX should reset all channels to tone
  db 10,#00    ;; silence
  db SFX_CMD_END    


SFX_hit_enemy:
  db  7,#b8    ;; SFX all channels to tone
  db 10,#0f    ;; volume
  db 4,#0, 5,4 ;; frequency
  db MUSIC_CMD_SKIP
  db 5,5 ;; frequency
  db MUSIC_CMD_SKIP
  db 5,6 ;; frequency
  db MUSIC_CMD_SKIP
  db 5,7 ;; frequency
  db MUSIC_CMD_SKIP
  db 5,8 ;; frequency
  db MUSIC_CMD_SKIP
  db 10,#0d    ;; volume
  db 5,9 ;; frequency
  db MUSIC_CMD_SKIP
  db 10,#0a    ;; volume
  db 5,10 ;; frequency
  db MUSIC_CMD_SKIP
  db 10,#00    ;; volume
  db SFX_CMD_END


SFX_hit_deflected:
  db  7,#9c    ;; noise in channel C, and tone in channels B and A
  db 10,#0f    ;; volume
  db  6,#04    ;; noise frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 10,#00    ;; volume
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP

  db  6,#01    ;; noise frequency
  db 10,#0c    ;; volume
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 10,#00    ;; volume
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP

  db 10,#0a    ;; volume
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db  7,#b8    ;; SFX all channels to tone
  db 10,#0c    ;; volume
  db 4,#20, 5,0 ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 10,#00    ;; volume
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP

  db 10,#0a    ;; volume
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 10,#00    ;; volume
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 10,#08    ;; volume
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 10,#00    ;; volume
  db SFX_CMD_END


SFX_enemy_kill:
  db  7,#b8    ;; SFX all channels to tone

  db 10,#0f    ;; volume
  db 4,0, 5,8 ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
;  db 10,#0d    ;; volume
  db 5,6      ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 10,#0b    ;; volume
  db 5,4      ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 10,#08    ;; volume
  db 5,2      ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP

  db 10,#0d    ;; volume
  db 5,6 ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
;  db 10,#0b    ;; volume
  db 5,4      ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 10,#08    ;; volume
  db 5,3      ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 10,#06    ;; volume
  db 5,2      ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP

  db 10,#0b    ;; volume
  db 5,4 ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
;  db 10,#08    ;; volume
  db 5,3      ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 10,#06    ;; volume
  db 5,2      ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 10,#04    ;; volume
  db 5,1      ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP

  db 10,#00    ;; silence
  db SFX_CMD_END      


SFX_weapon_switch:
  db  7,#b8    ;; SFX all channels to tone

  db 10,#0f    ;; volume
  db 4,0, 5,#01 ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 4,#40,5,#00 ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 10,#0d    ;; volume
  db MUSIC_CMD_SKIP
  db 10,#0b    ;; volume
  db MUSIC_CMD_SKIP
  db 10,#09    ;; volume
  db MUSIC_CMD_SKIP
  db 10,#07    ;; volume
  db MUSIC_CMD_SKIP
  db 10,#05    ;; volume
  db MUSIC_CMD_SKIP
  db 10,#03    ;; volume
  db MUSIC_CMD_SKIP

  db 10,#00    ;; silence
  db SFX_CMD_END 


SFX_item_pickup:
  db  7,#b8    ;; SFX all channels to tone
  db 10,#0f    ;; volume
  db 4,#80, 5,#00 ;; frequency
  db MUSIC_CMD_SKIP
  db 10,#0d    ;; volume
  db MUSIC_CMD_SKIP

  db 10,#0f    ;; volume
  db 4,#70, 5,#00 ;; frequency
  db MUSIC_CMD_SKIP
  db 10,#0d    ;; volume
  db MUSIC_CMD_SKIP

  db 10,#0f    ;; volume
  db 4,#60, 5,#00 ;; frequency
  db MUSIC_CMD_SKIP
  db 10,#0d    ;; volume
  db MUSIC_CMD_SKIP

  db 10,#0f    ;; volume
  db 4,#50, 5,#00 ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 10,#0d    ;; volume
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 10,#0b    ;; volume
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 10,#08    ;; volume
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 10,#06    ;; volume
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 10,#04    ;; volume
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 10,#02    ;; volume
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 10,#00    ;; silence
  db SFX_CMD_END      


SFX_door_open:
  db  7,#b8    ;; SFX all channels to tone
  db 10,#0f    ;; volume
  db 4,#00, 5,#06 ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 4,#80 ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 10,#0e    ;; volume
  db 4,#00 ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 4,#80 ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 10,#0d    ;; volume
  db 4,#00 ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 4,#80 ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 10,#0c    ;; volume
  db 4,#00 ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 4,#80 ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 10,#0b    ;; volume
  db 4,#00 ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 4,#80 ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 10,#0a    ;; volume
  db 4,#00 ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 4,#80 ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 10,#08    ;; volume
  db 4,#00 ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 4,#80 ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 10,#07    ;; volume
  db 4,#00 ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 4,#80 ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 10,#06    ;; volume
  db 4,#00 ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 4,#80 ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 10,#05    ;; volume
  db 4,#00 ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 4,#80 ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 10,#04    ;; volume
  db 4,#00 ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 4,#80 ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 10,#00    ;; silence
  db SFX_CMD_END      


SFX_hourglass:
  db 7,#b8    ;; SFX all channels to tone
  db 10,#0f    ;; volume
  db 4,#40, 5,#00 ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 10,#00    ;; silence
  db SFX_CMD_END      


SFX_playerhit:
  db 7,#b8    ;; SFX all channels to tone
  db 10,#0f    ;; volume
  db 4,#00, 5,#08 ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 5,#04 ;; frequency
  db MUSIC_CMD_SKIP
  db 5,#02 ;; frequency
  db MUSIC_CMD_SKIP
  db 5,#01 ;; frequency
  db MUSIC_CMD_SKIP
  db 4,#80, 5, #00 ;; frequency
  db MUSIC_CMD_SKIP
  db 4,#40 ;; frequency
  db MUSIC_CMD_SKIP
  db 4,#20 ;; frequency
  db MUSIC_CMD_SKIP
  db MUSIC_CMD_SKIP
  db 10,#00    ;; silence
  db SFX_CMD_END   


LoPStorySongPletter:
  incbin "tocompress/ToPStorySong.plt"

LoPInGameSongPletter: 
  incbin "tocompress/ToPInGameSong.plt"

LoPBossSongPletter:  
  incbin "tocompress/ToPBossSong.plt"

LoPStartSongPletter:
  incbin "tocompress/ToPStartSong.plt"

LoPGameOverSongPletter:  
  incbin "tocompress/ToPGameOverSong.plt"
