;-----------------------------------------------
; - renders the screen from the point of view of (raycast_camera_x), (raycast_camera_y), 
;   (raycast_player_angle) to raycast_buffer
; - the variables (raycast_first_column) and (raycast_last_column) control which columns
;   to render. This is useful, so I can split the rendering across multiple frames (in each
;   frame only rendering a few columns).
raycast_render_to_buffer:
    ld a,(raycast_camera_x)
    ld iyl,a
    ld a,(raycast_camera_y)
    ld iyh,a

    ld a,(raycast_first_column)
    ld (raycast_column),a

raycast_render_next_column:
    ;; render one column
    ;; Get the pixel mask we need for this column:
    ;; a is expected to have (raycast_column)
    ld h,pixel_bit_masks/256
    ld c,a  ; 'c' contains (raycast_column)
    and #07
    ld l,a
    ld a,(hl)
    ld (raycast_column_pixel_mask),a

    ;; compute the offset in the render buffer where this column starts:
    ;; offset = (raycast_column/8)*8*8
    ld a,c  ;; at this point, c still has (raycast_column)
    and #f8
    ld l,a
    xor a
    ld h,a
    add hl,hl
    add hl,hl
    add hl,hl
    ex de,hl
    ld hl,raycast_buffer
    add hl,de
    ld (raycast_buffer_offset_bank1),hl
    ld hl,raycast_buffer+(32-RAYCAST_SIDE_BORDER*2)*8*8
    add hl,de
    ld (raycast_buffer_offset_bank2),hl

    ;; hl = (raycast_player_angle)*4 + (raycast_column)
    ld b,a  ;; at this point, a is still has 0
    ld hl,raycast_player_angle
    ld l,(hl)
    ld h,a  ;; hl = (raycast_player_angle)

    add hl,hl   ;; hl*4
    add hl,hl
    add hl,bc   ;; hl = (raycast_player_angle)*4 + (raycast_column)

    ld a,l  ;; we should divide the lower byte by 2 (since render angles are between 0 - 127).
            ;; however, we later need to multiply by 32. So, we just clear the lowest bit, and then
            ;; later we will just have to multiply by 16
    and #fe
    ld l,a

    ;; The following code is 4 almost exact replicas of each other, one for each of the four quadrants,
    ;; it looks extremely wasteful, but by having it replicated four times, I avoid a few memory accesses,
    ;; and comparisons, saving a lot of CPU time:
    ld a,h
    and #03
    or a ; same as cp 0, but faster
    jp z,raycast_render_first_quadrant_precompute
    dec a
    jp z,raycast_render_second_quadrant_precompute
    dec a
    jp z,raycast_render_third_quadrant_precompute

;; -------------------------------------
;; ---- CEILING RENDERING (FOURTH QUADRANT) STARTS HERE ----
;; -------------------------------------
raycast_render_fourth_quadrant_precompute:
    ;; cache the offset to the ray_x_offs_table and ray_y_offs_table tables:
    ld h,0
    ld a,254
    sub l
    ld l,a
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    ld de,(ray_x_offs_table+(8-RAYCAST_ROWS_PER_BANK)*4)-1
    add hl,de
    push hl
    ld b,h
    ld c,l

    ;; get the mask we should apply to the pixel:
    ld hl,raycast_column_pixel_mask
    ld d,(hl)  ;; d now has the mask we should apply to every pixel along the wall

    ld e,iyh

    ld hl,(ray_x_offs_table+ray_y_offs_table-32)-1
    xor a
    sbc hl,bc

;    ld (raycast_column_y_offs_table_xangle_times_32),hl

    ld bc,(raycast_buffer_offset_bank1)
    exx
    pop hl  ; we recover the value of (raycast_column_x_offs_table_xangle_times_32)
    ld ixh,a    ;; ixh contains the raycast row 
;    xor a

raycast_render_next_pixel_ceiling_fourth_quadrant:
    ;; at this point, a and e contain (raycast_row)
    ;; do not consider the middle pixels (visibility is too far)
    cp RAYCAST_DISTANCE_THRESHOLD
    jp p,raycast_render_bg

    ld a,iyl
    inc hl
    add a,(hl)  ;; a = raycast_camera_x + ray_x_offs_table[xangle(bc)*32+y(e)]
;    ld (raycast_ray_x),a
    ld b,a

;    ld a,(raycast_camera_y)
    exx
    ld a,e  ; e contains (raycast_camera_y)
    ; the alternate HL register has the value of (raycast_column_y_offs_table_xangle_times_32)
    inc hl  ; we increase it at each row, so, we don't have to actually add "DE"
    sub (hl)  ;; a = raycast_camera_y + ray_y_offs_table[xangle(bc)*32+y(e)]
    exx
;    ld (raycast_ray_y),a
    ld c,a

    ;; a = currentMap[(raycast_ray_x/16)+(raycast_ray_y/16)*16];
    and #f0     ;; at this point a contains (raycast_ray_y)
    ld e,a
    ld a,b
    rlca
    rlca
    rlca
    rlca
    and #0f ; these sequence of 5 instructions, is equivalent to 4 sra a, but faster
    add a,e
    ld d,currentMap/256
    ld e,a
    ld a,(de)  ;; a = currentMap[(raycast_ray_x/16)+(raycast_ray_y/16)*16];

    or a ; same as cp 0, but faster
    jp nz,raycast_render_wall_from_fourth_quadrant

    ;; save the previous offset, raycast_ray_x, and raycast_ray_y
;    ld a,e
;    ld (raycast_previous_map_offset),a
    ld ixl,e
;    ld (raycast_previous_ray_x),bc

    ;; --------------------------------
    ;; render one pixel of ceiling texture:
raycast_render_ceiling_fourth_quadrant:
    ; precalculate the floor texture for later on: 
    ; b contains (raycast_ray_x), and c contains (raycast_ray_y)
    ld a,c
    xor b
    and #08
    ;; store the texture for later use during floor rendering
    ld d,raycast_floor_texture_buffer/256
    ld e,ixh
    ld (de),a

    ld a,c
    and b
    and #04
    jp z,raycast_render_done_with_ceiling_pixel_fourth_quadrant

    ;; texture is 1, render pixel:
    exx
    ld a,(bc)
    or d
    ld (bc),a   ;; render pixel
    inc bc
    IF RAYCAST_SCANLINES = 0
        ld (bc),a
    ENDIF
    inc bc
    exx
    inc ixh
    ld a,ixh  ;; since 'raycast_render_next_pixel_ceiling' expects the (raycast_row) to be in a
    jp raycast_render_next_pixel_ceiling_fourth_quadrant

raycast_render_done_with_ceiling_pixel_fourth_quadrant:
    exx
    inc bc
    inc bc
    exx
    inc ixh
    ld a,ixh  ;; since 'raycast_render_next_pixel_ceiling' expects the (raycast_row) to be in a
    jp raycast_render_next_pixel_ceiling_fourth_quadrant


;; -------------------------------------
;; ---- CEILING RENDERING (FIRST QUADRANT) STARTS HERE ----
;; -------------------------------------
raycast_render_first_quadrant_precompute:
    ld h,0
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    ld de,(ray_x_offs_table+(8-RAYCAST_ROWS_PER_BANK)*4)-1
    add hl,de
    push hl
    ld b,h
    ld c,l

    ;; get the mask we should apply to the pixel:
    ld hl,raycast_column_pixel_mask
    ld d,(hl)  ;; d now has the mask we should apply to every pixel along the wall

    ld e,iyh   ;; we store (raycast_camera_y) in the alternate "e"

    ld hl,(ray_x_offs_table+ray_y_offs_table-32)-1
    xor a
    sbc hl,bc
;    ld (raycast_column_y_offs_table_xangle_times_32),hl

    ld bc,(raycast_buffer_offset_bank1)
    exx
;    xor a
    pop hl  ; we recover the value of (raycast_column_x_offs_table_xangle_times_32)
    ld ixh,a    ;; ixh contains the raycast row 

raycast_render_next_pixel_ceiling_first_quadrant:
    ;; at this point, a and e contain (raycast_row)
    ;; do not consider the middle pixels (visibility is too far)
    cp RAYCAST_DISTANCE_THRESHOLD
    jp p,raycast_render_bg

    ld a,iyl
    inc hl
    add a,(hl)  ;; a = raycast_camera_x + ray_x_offs_table[xangle(bc)*32+y(e)]
;    ld (raycast_ray_x),a
    ld b,a

;    ld a,(raycast_camera_y)
    exx
    ld a,e  ; e contains (raycast_camera_y)
    ; the alternate HL register has the value of (raycast_column_y_offs_table_xangle_times_32)
    inc hl  ; we increase it at each row, so, we don't have to actually add "DE"
    add a,(hl)  ;; a = raycast_camera_y + ray_y_offs_table[xangle(bc)*32+y(e)]
    exx
;    ld (raycast_ray_y),a
    ld c,a

    ;; a = currentMap[(raycast_ray_x/16)+(raycast_ray_y/16)*16];
    and #f0     ;; at this point a contains (raycast_ray_y)
    ld e,a
    ld a,b
    rlca
    rlca
    rlca
    rlca
    and #0f ; these sequence of 5 instructions, is equivalent to 4 sra a, but faster
    add a,e
    ld d,currentMap/256
    ld e,a
    ld a,(de)  ;; a = currentMap[(raycast_ray_x/16)+(raycast_ray_y/16)*16];

    or a ; same as cp 0, but faster
    jp nz,raycast_render_wall_from_first_quadrant

    ;; save the previous offset, raycast_ray_x, and raycast_ray_y
;    ld a,e
;    ld (raycast_previous_map_offset),a
    ld ixl,e
;    ld (raycast_previous_ray_x),bc

    ;; --------------------------------
    ;; render one pixel of ceiling texture:
raycast_render_ceiling_first_quadrant:
    ; precalculate the floor texture for later on:
    ; b contains (raycast_ray_x), and c contains (raycast_ray_y)
    ld a,c
    xor b
    and #08
    ;; store the texture for later use during floor rendering
    ld d,raycast_floor_texture_buffer/256
    ld e,ixh
    ld (de),a

    ld a,c
    and b
    and #04
    jp z,raycast_render_done_with_ceiling_pixel_first_quadrant

    ;; texture is 1, render pixel:
    exx
    ld a,(bc)
    or d
    ld (bc),a   ;; render pixel
    inc bc
    IF RAYCAST_SCANLINES = 0
        ld (bc),a
    ENDIF
    inc bc
    exx
    inc ixh
    ld a,ixh  ;; since 'raycast_render_next_pixel_ceiling' expects the (raycast_row) to be in a
    jp raycast_render_next_pixel_ceiling_first_quadrant

raycast_render_done_with_ceiling_pixel_first_quadrant:
    exx
    inc bc
    inc bc
    exx
    inc ixh
    ld a,ixh  ;; since 'raycast_render_next_pixel_ceiling' expects the (raycast_row) to be in a
    jp raycast_render_next_pixel_ceiling_first_quadrant

;; -------------------------------------
;; ---- CEILING RENDERING (SECOND QUADRANT) STARTS HERE ----
;; -------------------------------------
raycast_render_second_quadrant_precompute:
    ;; cache the offset to the ray_x_offs_table and ray_y_offs_table tables:
    ld h,0
    ld a,254
    sub l
    ld l,a
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    ld de,(ray_x_offs_table+(8-RAYCAST_ROWS_PER_BANK)*4)-1
    add hl,de
    push hl
    ld b,h
    ld c,l

    ;; get the mask we should apply to the pixel:
    ld hl,raycast_column_pixel_mask
    ld d,(hl)  ;; d now has the mask we should apply to every pixel along the wall

    ld e,iyh   ;; we store (raycast_camera_y) in the alternate "e"

    ld hl,(ray_x_offs_table+ray_y_offs_table-32)-1
    xor a
    sbc hl,bc
    
;    ld (raycast_column_y_offs_table_xangle_times_32),hl

    ld bc,(raycast_buffer_offset_bank1)
    exx
;    xor a
    pop hl  ; we recover the value of (raycast_column_x_offs_table_xangle_times_32)
    ld ixh,a    ;; ixh contains the raycast row 

raycast_render_next_pixel_ceiling_second_quadrant:
    ;; at this point, a and e contain (raycast_row)
    ;; do not consider the middle pixels (visibility is too far)
    cp RAYCAST_DISTANCE_THRESHOLD
    jp p,raycast_render_bg

    inc hl
    ld b,(hl)  ;; a = raycast_camera_x + ray_x_offs_table[xangle(bc)*32+y(e)]
    ld a,iyl
    sub b       ;; a = raycast_camera_x - ray_x_offs_table[xangle(bc)*32+y(e)]
;    ld (raycast_ray_x),a
    ld b,a

;    ld a,(raycast_camera_y)
    exx
    ld a,e  ; e contains (raycast_camera_y)
    ; the alternate HL register has the value of (raycast_column_y_offs_table_xangle_times_32)
    inc hl  ; we increase it at each row, so, we don't have to actually add "DE"
    add a,(hl)  ;; a = raycast_camera_y + ray_y_offs_table[xangle(bc)*32+y(e)]
    exx
;    ld (raycast_ray_y),a
    ld c,a

    ;; a = currentMap[(raycast_ray_x/16)+(raycast_ray_y/16)*16];
    and #f0     ;; at this point a contains (raycast_ray_y)
    ld e,a
    ld a,b
    rlca
    rlca
    rlca
    rlca
    and #0f ; these sequence of 5 instructions, is equivalent to 4 sra a, but faster
    add a,e
    ld d,currentMap/256
    ld e,a
    ld a,(de)  ;; a = currentMap[(raycast_ray_x/16)+(raycast_ray_y/16)*16];

    or a ; same as cp 0, but faster
    jp nz,raycast_render_wall_from_second_quadrant

    ;; save the previous offset, raycast_ray_x, and raycast_ray_y
;    ld a,e
;    ld (raycast_previous_map_offset),a
    ld ixl,e
;    ld (raycast_previous_ray_x),bc

    ;; --------------------------------
    ;; render one pixel of ceiling texture:
raycast_render_ceiling_second_quadrant:
    ; precalculate the floor texture for later on:
    ; b contains (raycast_ray_x), and c contains (raycast_ray_y)
    ld a,c
    xor b
    and #08
    ;; store the texture for later use during floor rendering
    ld d,raycast_floor_texture_buffer/256
    ld e,ixh
    ld (de),a

    ld a,c
    and b
    and #04
    jp z,raycast_render_done_with_ceiling_pixel_second_quadrant

    ;; texture is 1, render pixel:
    exx
    ld a,(bc)
    or d
    ld (bc),a   ;; render pixel
    inc bc
    IF RAYCAST_SCANLINES = 0
        ld (bc),a
    ENDIF
    inc bc
    exx
    inc ixh
    ld a,ixh  ;; since 'raycast_render_next_pixel_ceiling' expects the (raycast_row) to be in a
    jp raycast_render_next_pixel_ceiling_second_quadrant

raycast_render_done_with_ceiling_pixel_second_quadrant:
    exx
    inc bc
    inc bc
    exx
    inc ixh
    ld a,ixh  ;; since 'raycast_render_next_pixel_ceiling' expects the (raycast_row) to be in a
    jp raycast_render_next_pixel_ceiling_second_quadrant

;; -------------------------------------
;; ---- CEILING RENDERING (THIRD QUADRANT) STARTS HERE ----
;; -------------------------------------
raycast_render_third_quadrant_precompute:
    ld h,0
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    ld de,(ray_x_offs_table+(8-RAYCAST_ROWS_PER_BANK)*4)-1
    add hl,de
    push hl
    ld b,h
    ld c,l

    ;; get the mask we should apply to the pixel:
    ld hl,raycast_column_pixel_mask
    ld d,(hl)  ;; d now has the mask we should apply to every pixel along the wall

    ld e,iyh  ;; we store (raycast_camera_y) in the alternate "e"

    ld hl,(ray_x_offs_table+ray_y_offs_table-32)-1
    xor a
    sbc hl,bc
;    ld (raycast_column_y_offs_table_xangle_times_32),hl

    ld bc,(raycast_buffer_offset_bank1)
    exx
;    xor a
    pop hl  ; we recover the value of (raycast_column_x_offs_table_xangle_times_32)
    ld ixh,a    ;; ixh contains the raycast row 

raycast_render_next_pixel_ceiling_third_quadrant:
    ;; at this point, a and e contain (raycast_row)
    ;; do not consider the middle pixels (visibility is too far)
    cp RAYCAST_DISTANCE_THRESHOLD
    jp p,raycast_render_bg

    inc hl
    ld b,(hl)  ;; a = raycast_camera_x + ray_x_offs_table[xangle(bc)*32+y(e)]
    ld a,iyl
    sub b       ;; a = raycast_camera_x - ray_x_offs_table[xangle(bc)*32+y(e)]
;    ld (raycast_ray_x),a
    ld b,a

;    ld a,(raycast_camera_y)
    exx
    ld a,e  ; e contains (raycast_camera_y)
    ; the alternate HL register has the value of (raycast_column_y_offs_table_xangle_times_32)
    inc hl  ; we increase it at each row, so, we don't have to actually add "DE"
    sub (hl)  ;; a = raycast_camera_y + ray_y_offs_table[xangle(bc)*32+y(e)]
    exx
;    ld (raycast_ray_y),a
    ld c,a

    ;; a = currentMap[(raycast_ray_x/16)+(raycast_ray_y/16)*16];
    and #f0     ;; at this point a contains (raycast_ray_y)
    ld e,a
    ld a,b
    rlca
    rlca
    rlca
    rlca
    and #0f ; these sequence of 5 instructions, is equivalent to 4 sra a, but faster
    add a,e
    ld d,currentMap/256
    ld e,a
    ld a,(de)  ;; a = currentMap[(raycast_ray_x/16)+(raycast_ray_y/16)*16];

    or a ; same as cp 0, but faster
    jp nz,raycast_render_wall_from_third_quadrant

    ;; save the previous offset, raycast_ray_x, and raycast_ray_y
;    ld a,e
;    ld (raycast_previous_map_offset),a
    ld ixl,e
;    ld (raycast_previous_ray_x),bc

    ;; --------------------------------
    ;; render one pixel of ceiling texture:
raycast_render_ceiling_third_quadrant:
    ; precalculate the floor texture for later on:
    ; b contains (raycast_ray_x), and c contains (raycast_ray_y)
    ld a,c
    xor b
    and #08
    ;; store the texture for later use during floor rendering
    ld d,raycast_floor_texture_buffer/256
    ld e,ixh
    ld (de),a

    ld a,c
    and b
    and #04
    jp z,raycast_render_done_with_ceiling_pixel_third_quadrant

    ;; texture is 1, render pixel:
    exx
    ld a,(bc)
    or d
    ld (bc),a   ;; render pixel
    inc bc
    IF RAYCAST_SCANLINES = 0
        ld (bc),a
    ENDIF
    inc bc
    exx
    inc ixh
    ld a,ixh  ;; since 'raycast_render_next_pixel_ceiling' expects the (raycast_row) to be in a
    jp raycast_render_next_pixel_ceiling_third_quadrant

raycast_render_done_with_ceiling_pixel_third_quadrant:
    exx
    inc bc
    inc bc
    exx
    inc ixh
    ld a,ixh  ;; since 'raycast_render_next_pixel_ceiling' expects the (raycast_row) to be in a
    jp raycast_render_next_pixel_ceiling_third_quadrant


;; -------------------------------------
;; ---- BACKGROUND RENDERING STARTS HERE ----
;; -------------------------------------

    ;; Skips all the middle pixels (those that are too far to render)
raycast_render_bg:
    exx
    ld hl,(raycast_buffer_offset_bank2)
    ld bc,(RAYCAST_ROWS_PER_BANK*4-RAYCAST_DISTANCE_THRESHOLD)*2
    add hl,bc
    ld a,RAYCAST_ROWS_PER_BANK*8-RAYCAST_DISTANCE_THRESHOLD
    jp raycast_render_start_floor

;; -------------------------------------
;; ---- WALL RENDERING STARTS HERE ----
;; -------------------------------------

;; These four functions re-calculate the map position where the previous ray hit (it's faster to recalculate it
;; once, than to store it at each iteration):
raycast_render_wall_from_first_quadrant:
    ld a,iyl
    dec hl
    add a,(hl)  ;; a = raycast_camera_x + ray_x_offs_table[xangle(bc)*32+y(e)]
    ld h,d
    ld d,a

    exx
    ld a,e  ; e contains (raycast_camera_y)
    dec hl
    add a,(hl)  ;; a = raycast_camera_y + ray_y_offs_table[xangle(bc)*32+y(e)]
    exx
    ld e,a
    jp raycast_render_wall


raycast_render_wall_from_second_quadrant:
    dec hl
    ld h,(hl)  ;; a = raycast_camera_x + ray_x_offs_table[xangle(bc)*32+y(e)]
    ld a,iyl
    sub h       ;; a = raycast_camera_x - ray_x_offs_table[xangle(bc)*32+y(e)]
    ld h,d
    ld d,a

    exx
    dec hl
    ld a,e  ; e contains (raycast_camera_y)
    add a,(hl)  ;; a = raycast_camera_y + ray_y_offs_table[xangle(bc)*32+y(e)]
    exx
    ld e,a
    jp raycast_render_wall


raycast_render_wall_from_third_quadrant:
    dec hl
    ld h,(hl)  ;; a = raycast_camera_x + ray_x_offs_table[xangle(bc)*32+y(e)]
    ld a,iyl
    sub h       ;; a = raycast_camera_x - ray_x_offs_table[xangle(bc)*32+y(e)]
    ld h,d
    ld d,a

    exx
    ld a,e  ; e contains (raycast_camera_y)
    dec hl
    sub (hl)  ;; a = raycast_camera_y + ray_y_offs_table[xangle(bc)*32+y(e)]
    exx
    ld e,a
    jp raycast_render_wall


raycast_render_wall_from_fourth_quadrant:
    ld a,iyl
    dec hl
    add a,(hl)  ;; a = raycast_camera_x + ray_x_offs_table[xangle(bc)*32+y(e)]
    ld h,d
    ld d,a

    exx
    ld a,e  ; e contains (raycast_camera_y)
    dec hl
    sub (hl)  ;; a = raycast_camera_y + ray_y_offs_table[xangle(bc)*32+y(e)]
    exx
    ld e,a
;    jp raycast_render_wall


    ;; --------------------------------
    ;; render a whole vertical wall line of pixels:
    ;; at this point h points to the current map
raycast_render_wall:
    ld a,ixh
    ;; check if the wall is too close to be rendered:
    or a
    jp z,raycast_render_pause_equivalent_time_of_rendering_column
    ld (raycast_row),a

;    ld h,d

    ;; determine the side of the wall we are colliding with, and the x coordinate of the texture:
    ;; We are going to cast a ray from (raycast_previous_ray_x),(raycast_previous_ray_y) to b,c
;    ld a,(raycast_previous_map_offset)
    ld a,ixl
    ld l,a
;    ld de,(raycast_previous_ray_x)
    
raycast_render_wall_determine_texture_and_column:
    ld a,d
    cp b
    jp z,raycast_render_wall_do_not_move_in_x
    jp m,raycast_render_wall_increase_x
raycast_render_wall_decrease_x:
    dec d
    ld a,d
    and #0f
    cp #0f  ;; check if we need to change the map offset
    jp nz,raycast_render_wall_done_with_x
    dec l
    ld a,(hl)
    or a
    jp nz,raycast_render_wall_collision_moving_in_x
    jp raycast_render_wall_done_with_x

raycast_render_wall_increase_x:
    inc d
    ld a,d
    and #0f
    or a  ;; check if we need to change the map offset
    jp nz,raycast_render_wall_done_with_x
    inc l
    ld a,(hl)
    or a
    jp nz,raycast_render_wall_collision_moving_in_x
    jp raycast_render_wall_done_with_x

raycast_render_wall_collision_moving_in_x:
    ld b,a
    ld a,e
    and #0f
    ld d,a
    ld a,b    
    jp raycast_render_wall_texture_and_column_determined

raycast_render_wall_done_with_x:
raycast_render_wall_do_not_move_in_x:
    ld a,e
    cp c
    jp z,raycast_render_wall_determine_texture_and_column
    jp m,raycast_render_wall_increase_y
raycast_render_wall_decrease_y:
    dec e
    ld a,e
    and #0f
    cp #0f  ;; check if we need to change the map offset
    jp nz,raycast_render_wall_determine_texture_and_column
    ld a,l
    sub 16
    ld l,a
    ld a,(hl)
    or a
    jp nz,raycast_render_wall_collision_moving_in_y
    jp raycast_render_wall_determine_texture_and_column

raycast_render_wall_increase_y:
    inc e
    ld a,e
    and #0f
    or a  ;; check if we need to change the map offset
    jp nz,raycast_render_wall_determine_texture_and_column
    ld a,l
    add a,16
    ld l,a
    ld a,(hl)
    or a
    jp nz,raycast_render_wall_collision_moving_in_y
    jp raycast_render_wall_determine_texture_and_column

raycast_render_wall_collision_moving_in_y:
    ld b,a
    ld a,d
    and #0f
    ld d,a
    ld a,b    
;    jp raycast_render_wall_texture_and_column_determined


raycast_render_wall_texture_and_column_determined:
    ; d has the texture x coordinate
    ; a has the texture ID

    ;; get the proper texture:
    ; animation of texture 8 (alternates 8 and 9):
    cp 8
    jp nz,raycast_render_wall_texture_and_column_determined_next
    ld a,(game_cycle)
    and #04
    ld a,8
    jp nz,raycast_render_wall_texture_and_column_determined_next
    ld a,9
raycast_render_wall_texture_and_column_determined_next:

    ld h,(textures/256)-1   ; we subtract 1, since texture IDs start at 1
    ld c,a
    add a,h
    ld (raycast_texture_ptr),a
    IF RAYCAST_COLOR = 1
        ld hl,texture_colors-1  ; we subtract 1, since texture IDs start at 1
        ld b,0
        add hl,bc
        ld a,(hl)
        ld ixh,a
    ENDIF

    ld b,0
    ld a,(raycast_row)
    ld c,a
    ld hl,texture_vertical_rate_table+(8-RAYCAST_ROWS_PER_BANK)*4*2
    add hl,bc
    add hl,bc
    ld c,(hl)
    inc hl
    ld b,(hl)   ; bc now contains the increment at which we have to move vertically through the texture

    ;; height of the wall is (32-y)*2: (we should only enter here if (raycast_row) is < 32, so, we can safely use (raycast_row) as "y")
    cpl
    add a,RAYCAST_ROWS_PER_BANK*4+1    ;; a = 32-(raycast_row)
    ld e,a        ;; e has the height of the wall/2
    push de
    exx

    ld hl,raycast_column_pixel_mask
    ld d,(hl)

raycast_render_wall_loop_start:    
    ; bc still contains (raycast_buffer_offset_bank1)
    ld a,(raycast_texture_ptr)
    ld h,a
    ld e,a   
    exx
    ld a,(raycast_row)  ;; we advance the (raycast_row) to after the wall is rendered
    add a,e
    add a,e
    ld (raycast_row),a

    ld hl,0

raycast_render_wall_loop_top_half:
    ;; get the texture pixel:
    ld a,h
    add hl,bc
    and #f0
    add a,d ; d contains the x offset of the texture
    exx 

    ld l,a  ; h has (raycast_texture_ptr)
    ld a,(hl)

    ;; if the texture is 0, skip pixel
    or a ; same as cp 0, but faster
    jp z,raycast_render_wall_loop_top_half_continue

    ld a,(bc)
    or d
    ld (bc),a   ;; render pixel
    inc bc
    IF RAYCAST_SCANLINES = 0
        ld (bc),a   ;; render pixel
    ENDIF
    inc bc
    ;; render color:
    IF RAYCAST_COLOR = 1
            ld hl,raycast_color_buffer-(raycast_buffer+2)
            add hl,bc
            ld a,ixh
            ld (hl),a
            IF RAYCAST_SCANLINES = 0
                inc hl
                ld (hl),a
            ENDIF
        ENDIF
        ld h,e  ; e also has (raycast_texture_ptr), we restore it to h
    ENDIF
    exx
    dec e
    jp nz,raycast_render_wall_loop_top_half
    jp raycast_render_wall_loop_bottom_half_pre

raycast_render_wall_loop_top_half_continue:
    inc bc
    inc bc
    exx
    dec e
    jp nz,raycast_render_wall_loop_top_half

raycast_render_wall_loop_bottom_half_pre:
    pop de  ; we get the height of the wall, and the texture x coordinate again
    exx
    ld bc,(raycast_buffer_offset_bank2)
    exx
raycast_render_wall_loop_bottom_half:
    ;; get the texture pixel:
    ld a,h
    add hl,bc
    and #f0
    add a,d ; d contains the x offset of the texture
    exx 

    ld l,a  ; h has (raycast_texture_ptr)
    ld a,(hl)

    ;; if the texture is 0, skip pixel
    or a ; same as cp 0, but faster
    jp z,raycast_render_wall_loop_bottom_half_continue

    ld a,(bc)
    or d
    ld (bc),a   ;; render pixel
    inc bc
    IF RAYCAST_SCANLINES = 0
        ld (bc),a   ;; render pixel
    ENDIF
    inc bc
    ;; render color:
    IF RAYCAST_COLOR = 1
            ld hl,raycast_color_buffer-(raycast_buffer+2)
            add hl,bc
            ld a,ixh
            ld (hl),a
            IF RAYCAST_SCANLINES = 0
                inc hl
                ld (hl),a
            ENDIF
            ld h,e  ; e also has (raycast_texture_ptr), we restore it to h
        ENDIF
    ENDIF

    exx
    dec e
    jp nz,raycast_render_wall_loop_bottom_half
    jp raycast_render_start_floor_from_wall


raycast_render_wall_loop_bottom_half_continue:
    inc bc
    inc bc
    exx
    dec e
    jp nz,raycast_render_wall_loop_bottom_half

;; -------------------------------------
;; ---- FLOOR RENDERING STARTS HERE ----
;; -------------------------------------

raycast_render_start_floor_from_wall:
    ;; make the connection between wall and floor always black, to minimize color clash
    ld a,(raycast_row)
    add a,2
    exx
    ld hl,4
    add hl,bc

raycast_render_start_floor:
    ;; a contains (raycast_row)
    ;; d contains the mask we should apply to the pixel
    cp RAYCAST_ROWS_PER_BANK*8-1   ;; we cut it one pixel short
    jp p,raycast_render_done_with_column

    ;; from this point, on, we forget about updating raycast_row, and just keep 63-raycast_row in a
    cpl
    add a,(RAYCAST_ROWS_PER_BANK*8-1)+1
    ld b,raycast_floor_texture_buffer/256
    ld c,a

raycast_render_next_pixel_floor:
    ;; retrieve the texture offset stored during ceiling rendering:
    ld a,(bc)
    or a ; same as cp 0, but faster
    jp z,raycast_render_done_with_floor_pixel

    ;; texture is 1, render pixel:
    ld a,(hl)
    or d
    ld (hl),a   ;; render pixel
    inc hl
    IF RAYCAST_SCANLINES = 0
        ld (hl),a
    ENDIF
    inc hl
    dec c
    jp nz,raycast_render_next_pixel_floor
    jp raycast_render_done_with_column

raycast_render_done_with_floor_pixel:
    inc hl
    inc hl
    dec c
    jp nz,raycast_render_next_pixel_floor

raycast_render_done_with_column:
    ld a,(raycast_column)
    add a,2
    ld (raycast_column),a
    ld hl,raycast_last_column
    cp (hl)
    jp nz,raycast_render_next_column
    ret
    

raycast_render_pause_equivalent_time_of_rendering_column:
    ; Just do nothing for a while, to compensate for the fact that this column will not be rendered.
    ; Otherwise, the game speeds up when getting too close to a wall:
    ld b,200
raycast_render_pause_equivalent_time_of_rendering_column_loop1:
    nop
    djnz raycast_render_pause_equivalent_time_of_rendering_column_loop1
    ld b,0
raycast_render_pause_equivalent_time_of_rendering_column_loop2:
    nop
    djnz raycast_render_pause_equivalent_time_of_rendering_column_loop2
    jp raycast_render_done_with_column

;-----------------------------------------------
; Copies the render buffer to video memory
raycast_render_buffer:
    ld hl,(initial_rendering_address)
    call SETWRT
    ld hl,raycast_buffer
    ld a,(amoount_of_bytes_to_render)
raycast_render_buffer_loop1:
    ld bc,256*256+VDP_DATA  ;; (256*256 is basically 0, but just for clarity, so I remember this copies 256 bytes)
raycast_render_buffer_loop1_b:
    outi
    jp nz,raycast_render_buffer_loop1_b
    dec a
    jp nz, raycast_render_buffer_loop1

    IF RAYCAST_COLOR = 1
        ld hl,(initial_rendering_address+2)
        call SETWRT
        ld hl,raycast_color_buffer
        ld a,(amoount_of_bytes_to_render)
raycast_render_buffer_loop3:
        ld bc,256*256+VDP_DATA  ;; (256*256 is basically 0, but just for clarity, so I remember this copies 256 bytes)
raycast_render_buffer_loop3_b:
        outi
        jp nz,raycast_render_buffer_loop3_b
        dec a
        jp nz, raycast_render_buffer_loop3
    ENDIF

    ld hl,(initial_rendering_address+4)
    call SETWRT
    ld hl,raycast_buffer+(32-RAYCAST_SIDE_BORDER*2)*8*8
    ld a,(amoount_of_bytes_to_render)
    ;ld a,((32-RAYCAST_SIDE_BORDER*2)*8*8)/256
raycast_render_buffer_loop2:
    ld bc,256*256+VDP_DATA  ;; (256*256 is basically 0, but just for clarity, so I remember this copies 256 bytes)
raycast_render_buffer_loop2_b:
    outi
    jp nz,raycast_render_buffer_loop2_b
    dec a
    jp nz, raycast_render_buffer_loop2

    IF RAYCAST_COLOR = 1
        ld hl,(initial_rendering_address+6)
        call SETWRT
        ld hl,raycast_color_buffer+(32-RAYCAST_SIDE_BORDER*2)*8*8
        ld a,(amoount_of_bytes_to_render)
;        ld a,((32-RAYCAST_SIDE_BORDER*2)*8*8)/256
raycast_render_buffer_loop4:
        ld bc,256*256+VDP_DATA  ;; (256*256 is basically 0, but just for clarity, so I remember this copies 256 bytes)
raycast_render_buffer_loop4_b:
        outi
        jp nz,raycast_render_buffer_loop4_b
        dec a
        jp nz, raycast_render_buffer_loop4        
    ENDIF

    ret


;-----------------------------------------------
; Reset the VRAM to start ray casting:
; - sets the default colors to the ground color
; - sets the name table
; - resets the raycast buffer to all 0s
raycast_reset:
    ; set colors
    ld a,#f0
    ld bc,256*8*2
    ld hl,CLRTBL2
    call FILVRM

    xor a
    ld bc,256*8*2
    ld hl,CHRTBL2
    call FILVRM

    ; set the name table (first clear it to "RAYCAST_BORDER_PATTERN")
    IF RAYCAST_SIDE_BORDER > 0
    ld c,8
    ld b,32
    ld hl,raycast_buffer
    ld a,RAYCAST_BORDER_PATTERN
raycast_reset_loop1:
    ld (hl),a
    inc hl
    djnz raycast_reset_loop1
    dec c
    jp nz,raycast_reset_loop1
    ENDIF

    ; now set the names for the area that will be drawn
    ld hl,raycast_buffer+RAYCAST_SIDE_BORDER
    ld d,0
raycast_reset_loop2:
    ld b,32-(RAYCAST_SIDE_BORDER*2)
    ld a,d
raycast_reset_loop2_a:
    ld (hl),a
    inc hl
    add a,8
    djnz raycast_reset_loop2_a
    ld bc,RAYCAST_SIDE_BORDER*2
    add hl,bc
    inc d
    ld a,d
    cp 8
    jp nz,raycast_reset_loop2

    ;; reset the top 2 banks:
    ld bc,256
    ld de,NAMTBL2
    ld hl,raycast_buffer
    call LDIRVM

    ld bc,256
    ld de,NAMTBL2+256
    ld hl,raycast_buffer
    call LDIRVM

    ; clear the raycast buffers:
raycast_reset_clear_buffer:
    ld hl,raycast_buffer
    ld de,raycast_buffer+1
    xor a
    ld (hl),a
;    ld bc,(32-RAYCAST_SIDE_BORDER*2)*8*8*2
    ld bc,(raycast_amount_to_clear)
raycast_reset_clear_buffer_loop1:
    REPT 16
    ldi
    ENDM
    jp pe,raycast_reset_clear_buffer_loop1

    ld hl,raycast_buffer+(32-RAYCAST_SIDE_BORDER*2)*8*8
    ld de,raycast_buffer+(32-RAYCAST_SIDE_BORDER*2)*8*8+1
    xor a
    ld (hl),a
;    ld bc,(32-RAYCAST_SIDE_BORDER*2)*8*8*2
    ld bc,(raycast_amount_to_clear)
raycast_reset_clear_buffer_loop2:
    REPT 16
    ldi
    ENDM
    jp pe,raycast_reset_clear_buffer_loop2

    IF RAYCAST_COLOR = 1
        ld hl,raycast_color_buffer
        ld de,raycast_color_buffer+1
        ld a,(raycast_ceiling_texture_color)
        ld (hl),a
        ld bc,(raycast_amount_to_clear)
;        ld bc,(32-RAYCAST_SIDE_BORDER*2)*8*8
raycast_reset_clear_buffer_loop3:
        REPT 16
        ldi
        ENDM
        jp pe,raycast_reset_clear_buffer_loop3

        ld hl,raycast_color_buffer+(32-RAYCAST_SIDE_BORDER*2)*8*8
        ld de,raycast_color_buffer+(32-RAYCAST_SIDE_BORDER*2)*8*8+1
        ld a,(raycast_floor_texture_color)
        ld (hl),a
;        ld bc,(32-RAYCAST_SIDE_BORDER*2)*8*8
        ld bc,(raycast_amount_to_clear)
raycast_reset_clear_buffer_loop4:
        REPT 16
        ldi
        ENDM
        jp pe,raycast_reset_clear_buffer_loop4
    ENDIF
    ret


    include "top-raycasting-rayxoffstable.asm"

textures_pletter:
    incbin "tocompress/textures.plt"

textures_catacombs_pletter:
    incbin "tocompress/textures-catacombs.plt"

    include "top-raycasting-textureverticalratetable.asm"
