*> Implementation test of the vegetation patches (docs/protocol/35-worldgen-features-4 section 9; core/src/feat-patch.cob): the data features compile (types 53 and 56; a missing replaceable set,
*> vegetation feature, depth, radius, vertical range, an unknown ground state or surface, or a full feature table make the feature unsupported); three configured patches (a floor patch with
*> every draw switched on, a ceiling patch whose chances are 0 and draw nothing, a waterlogged patch next to an air pit) change exactly the cells an independent model of section 9 changes,
*> drawing from a second random source seeded alike: the radii, the edge columns, the walk to the surface, the depth and extra bottom layer, the ground layers, the vegetation draw of every
*> ground position in insertion order (the operator decision that replaces the iteration order of Java's HashSet), the unexposed filter, the water and the waterlogged fix of the vegetation.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-4-PATCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY FEATINDEX.
 COPY XORO.
 COPY XORO REPLACING ==XR-STATE== BY ==XR2-STATE== LEADING ==XR-== BY ==X2-==.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/water".
 01 WS-PTR                 USAGE POINTER.
 01 WS-A                   PIC X(304640) BASED.
 01 WS-MODEL.
    05 WS-MS               BINARY-LONG OCCURS 98304 TIMES.
 01 WS-LIST.
    05 WS-L OCCURS 1024 TIMES.
       10 WS-LX            BINARY-LONG.
       10 WS-LY            BINARY-LONG.
       10 WS-LZ            BINARY-LONG.
 01 WS-LCOUNT              BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-PRE                BINARY-LONG VALUE 0.
 01 WS-OY                  BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-FT                  BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-CX                  BINARY-LONG VALUE 1.
 01 WS-CZ                  BINARY-LONG VALUE 2.
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-OK                  BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 11.
 01 WS-KEY                 PIC X(112).
 01 WS-NAME                PIC X(48).
 01 WS-FTKEY               PIC X(80).
 01 WS-PAIRS               PIC X(160).
 01 WS-CASE                PIC X(200).
 01 WS-OBS                 BINARY-LONG.
 01 WS-EXP                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-S-STONE             BINARY-LONG.
 01 WS-S-MOSS              BINARY-LONG.
 01 WS-S-CLAY              BINARY-LONG.
 01 WS-S-GLASS             BINARY-LONG.
 01 WS-S-WATER             BINARY-LONG.
 01 WS-S-SLAB              BINARY-LONG.
 01 WS-S-SLAB-WL           BINARY-LONG.
 01 WS-N-MOSS              BINARY-LONG.
 01 WS-N-GLASS             BINARY-LONG.
 01 WS-N-WATER             BINARY-LONG.
 01 WS-N-SLAB              BINARY-LONG.
 01 WS-N-CLAY              BINARY-LONG.
 01 WS-MODEL-GROUND        BINARY-LONG.
*> the model: configuration of the case and its working fields
 01 M-RLO                  BINARY-LONG.
 01 M-RHI                  BINARY-LONG.
 01 M-DLO                  BINARY-LONG.
 01 M-DHI                  BINARY-LONG.
 01 M-EB                   FLOAT-LONG.
 01 M-EE                   FLOAT-LONG.
 01 M-VC                   FLOAT-LONG.
 01 M-DIR                  BINARY-LONG.
 01 M-WL                   BINARY-LONG.
 01 M-RX                   BINARY-LONG.
 01 M-RZ                   BINARY-LONG.
 01 M-DX                   BINARY-LONG.
 01 M-DZ                   BINARY-LONG.
 01 M-SKIP                 BINARY-LONG.
 01 M-CY                   BINARY-LONG.
 01 M-STEPS                BINARY-LONG.
 01 M-GO                   BINARY-LONG.
 01 M-LAYERS               BINARY-LONG.
 01 M-I                    BINARY-LONG.
 01 M-STOP                 BINARY-LONG.
 01 M-PLACED               BINARY-LONG.
 01 M-GY                   BINARY-LONG.
 01 M-BELOW-Y              BINARY-LONG.
 01 M-CUR                  BINARY-LONG.
 01 M-STURDY               BINARY-LONG.
 01 M-EXPOSED              BINARY-LONG.
 01 M-K                    BINARY-LONG.
 01 M-NX                   BINARY-LONG.
 01 M-NY                   BINARY-LONG.
 01 M-NZ                   BINARY-LONG.
 01 M-B1                   BINARY-LONG.
 01 M-B2                   BINARY-LONG.
 01 M-V                    BINARY-LONG.
 01 M-KEEP                 BINARY-LONG.
 01 M-WX                   BINARY-LONG.
 01 M-WY                   BINARY-LONG.
 01 M-WZ                   BINARY-LONG.
 01 M-VX                   BINARY-LONG.
 01 M-VY                   BINARY-LONG.
 01 M-VZ                   BINARY-LONG.
 01 M-RESULT               BINARY-LONG.
 01 M-NDX.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
 01 M-NDX-T REDEFINES M-NDX.
    05 M-DXS               BINARY-LONG OCCURS 5 TIMES.
 01 M-NDZ.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
 01 M-NDZ-T REDEFINES M-NDZ.
    05 M-DZS               BINARY-LONG OCCURS 5 TIMES.
 01 M-NDY.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE -1.
 01 M-NDY-T REDEFINES M-NDY.
    05 M-DYS               BINARY-LONG OCCURS 5 TIMES.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "FD-RESET"
     PERFORM RESOLVE

*>   the data features compile
     MOVE "minecraft:vp_floor" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-4§9: the data feature vp_floor compiles as a vegetation_patch (53)" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE 53 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:vp_water" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-4§9: and vp_water as a waterlogged_vegetation_patch (56)" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE 56 TO WS-EXP
     PERFORM ASSERT-N

*>   the floor patch: every draw on (edge chance, extra bottom layer, depth, vegetation chance)
     MOVE "minecraft:vp_floor" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     MOVE 2 TO M-RLO
     MOVE 3 TO M-RHI
     MOVE 1 TO M-DLO
     MOVE 2 TO M-DHI
     MOVE 0.5 TO M-EB
     MOVE 0.5 TO M-EE
     MOVE 0.75 TO M-VC
     MOVE -1 TO M-DIR
     MOVE 0 TO M-WL
     MOVE WS-S-MOSS TO WS-MODEL-GROUND
     MOVE 65 TO WS-OY
     PERFORM RUN-CASE
     MOVE "35-4§9: the floor patch changes the cells the model of section 9 changes" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-4§9: and returns true" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     PERFORM COUNT-BLOCKS
     MOVE "35-4§9: moss was laid (more than ten blocks) and the model agrees" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-N-MOSS > 10
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-4§9: some ground positions got the vegetation (glass)" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-N-GLASS > 0
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   the ceiling patch: chances of 0 draw nothing, the ground hangs from the ceiling
     MOVE "minecraft:vp_ceiling" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     MOVE 2 TO M-RLO
     MOVE 2 TO M-RHI
     MOVE 1 TO M-DLO
     MOVE 1 TO M-DHI
     MOVE 0 TO M-EB
     MOVE 0 TO M-EE
     MOVE 0 TO M-VC
     MOVE 1 TO M-DIR
     MOVE 0 TO M-WL
     MOVE WS-S-MOSS TO WS-MODEL-GROUND
     MOVE 66 TO WS-OY
     PERFORM RUN-CASE
     MOVE "35-4§9: the ceiling patch (chances 0) changes the cells of the model" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     PERFORM COUNT-BLOCKS
     MOVE "35-4§9: the ceiling patch laid moss under the ceiling" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-N-MOSS > 10
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-4§9: and the hole of the ceiling column is passed through (moss at y 71)" TO WS-CASE
     MOVE 24 TO WS-X
     MOVE 71 TO WS-Y
     MOVE 41 TO WS-Z
     PERFORM BLOCK-NOW
     MOVE WS-STATE TO WS-OBS
     MOVE WS-S-MOSS TO WS-EXP
     PERFORM ASSERT-N

*>   the waterlogged patch beside an air pit: exposed ground stays, the others turn to water, slabs become waterlogged
     MOVE "minecraft:vp_water" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     MOVE 2 TO M-RLO
     MOVE 3 TO M-RHI
     MOVE 2 TO M-DLO
     MOVE 2 TO M-DHI
     MOVE 0 TO M-EB
     MOVE 0.75 TO M-EE
     MOVE 0.5 TO M-VC
     MOVE -1 TO M-DIR
     MOVE 1 TO M-WL
     MOVE WS-S-CLAY TO WS-MODEL-GROUND
     MOVE 65 TO WS-OY
     PERFORM RUN-CASE
     MOVE "35-4§9.3: the waterlogged patch changes the cells of the model" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-4§9.3: and returns true" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     PERFORM COUNT-BLOCKS
     MOVE "35-4§9.3: water was made (more than five cells)" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-N-WATER > 5
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-4§9.3: a waterlogged slab stands in the water" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-N-SLAB > 0
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-4§9.3: ground next to the pit stays clay (exposed)" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-N-CLAY > 0
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   nothing to do: the origin inside stone (no air to stand in) and a column too high for the walk
     MOVE "minecraft:vp_floor2" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     MOVE 1 TO M-RLO
     MOVE 1 TO M-RHI
     MOVE 1 TO M-DLO
     MOVE 1 TO M-DHI
     MOVE 0 TO M-EB
     MOVE 0 TO M-EE
     MOVE 0 TO M-VC
     MOVE -1 TO M-DIR
     MOVE 0 TO M-WL
     MOVE WS-S-MOSS TO WS-MODEL-GROUND
     MOVE 50 TO WS-OY
     PERFORM RUN-CASE
     MOVE "35-4§9.1: an origin inside stone makes no column (the cursor is not air): false" TO WS-CASE
     COMPUTE WS-OBS = WS-RESULT * 1000 + WS-BAD
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 69 TO WS-OY
     PERFORM RUN-CASE
     MOVE "35-4§9.1: an origin too high (the walk ends in the air above no sturdy floor): false" TO WS-CASE
     COMPUTE WS-OBS = WS-RESULT * 1000 + WS-BAD
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   a ground block that already is the ground state is skipped without moving the cursor (the column still counts as placed)
     MOVE "minecraft:vp_floor2" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     MOVE 1 TO WS-PRE
     MOVE WS-S-MOSS TO WS-MODEL-GROUND
     MOVE 65 TO WS-OY
     PERFORM RUN-CASE
     MOVE 0 TO WS-PRE
     MOVE "35-4§9.1: a ground cell that already holds the ground block is kept and the patch is true" TO WS-CASE
     COMPUTE WS-OBS = WS-RESULT * 1000 + WS-BAD
     MOVE 1000 TO WS-EXP
     PERFORM ASSERT-N

*>   a ground provider without a state stops the column at once: nothing written
     MOVE "minecraft:vp_nostate" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     MOVE 1 TO M-RLO
     MOVE 1 TO M-RHI
     MOVE 65 TO WS-OY
     PERFORM NEW-WORLD
     MOVE 24 TO WS-X
     MOVE 40 TO WS-Z
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-OY WS-Z WS-RESULT
     MOVE ZERO TO WS-BAD
     PERFORM COMPARE-UNCHANGED
     MOVE "35-4§9.1: a ground provider with no state writes nothing and the patch is false" TO WS-CASE
     COMPUTE WS-OBS = WS-RESULT * 1000 + WS-BAD
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   the gate
     MOVE 1 TO FI-GATE
     MOVE "minecraft:lush_caves_vegetation" TO WS-FTKEY
     CALL "FR-GATE" USING WS-FTKEY WS-COUNT
     MOVE "35-4§9: the gate admits lush_caves_vegetation" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:pale_moss_patch" TO WS-FTKEY
     CALL "FR-GATE" USING WS-FTKEY WS-COUNT
     MOVE "35-4§9: and pale_moss_patch" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   features that cannot be compiled whole
     MOVE "minecraft:vp_no_replaceable" TO WS-FTKEY
     PERFORM CHECK-BAD
     MOVE "35-4§9: a patch without replaceable is unsupported" TO WS-CASE
     PERFORM ASSERT-N
     MOVE "minecraft:vp_bad_state" TO WS-FTKEY
     PERFORM CHECK-BAD
     MOVE "35-4§9: a patch with an unknown ground state is unsupported" TO WS-CASE
     PERFORM ASSERT-N
     MOVE "minecraft:vp_no_veg" TO WS-FTKEY
     PERFORM CHECK-BAD
     MOVE "35-4§9: a patch without vegetation_feature is unsupported" TO WS-CASE
     PERFORM ASSERT-N
     MOVE "minecraft:vp_bad_depth" TO WS-FTKEY
     PERFORM CHECK-BAD
     MOVE "35-4§9: a patch whose depth is no int provider is unsupported" TO WS-CASE
     PERFORM ASSERT-N
     MOVE "minecraft:vp_bad_radius" TO WS-FTKEY
     PERFORM CHECK-BAD
     MOVE "35-4§9: a patch without xz_radius is unsupported" TO WS-CASE
     PERFORM ASSERT-N
     MOVE "minecraft:vp_bad_surface" TO WS-FTKEY
     PERFORM CHECK-BAD
     MOVE "35-4§9: a patch with a surface other than floor and ceiling is unsupported" TO WS-CASE
     PERFORM ASSERT-N
     MOVE "minecraft:vp_no_range" TO WS-FTKEY
     PERFORM CHECK-BAD
     MOVE "35-4§9: a patch without vertical_range is unsupported" TO WS-CASE
     PERFORM ASSERT-N
     MOVE "minecraft:vp_no_eb" TO WS-FTKEY
     PERFORM CHECK-BAD
     MOVE "35-4§9: a patch without extra_bottom_block_chance is unsupported" TO WS-CASE
     PERFORM ASSERT-N
     MOVE "minecraft:vp_no_vc" TO WS-FTKEY
     PERFORM CHECK-BAD
     MOVE "35-4§9: a patch without vegetation_chance is unsupported" TO WS-CASE
     PERFORM ASSERT-N
     MOVE "minecraft:vp_no_ee" TO WS-FTKEY
     PERFORM CHECK-BAD
     MOVE "35-4§9: a patch without extra_edge_column_chance is unsupported" TO WS-CASE
     PERFORM ASSERT-N
     MOVE FD-WA-COUNT TO WS-COUNT
     MOVE FD-MAX-WA TO FD-WA-COUNT
     MOVE "minecraft:vp_floor3" TO WS-FTKEY
     PERFORM CHECK-BAD
     MOVE WS-COUNT TO FD-WA-COUNT
     MOVE "35-4§9: a full feature table makes the patch unsupported" TO WS-CASE
     PERFORM ASSERT-N
     STOP RUN.

 CHECK-BAD.
     MOVE 0 TO FD-BAD
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     .
 RESOLVE.
     MOVE "stone" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-STONE
     MOVE "moss_block" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-MOSS
     MOVE "clay" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-CLAY
     MOVE "glass" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-GLASS
     MOVE "water" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-WATER
     MOVE "oak_slab" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-SLAB
     MOVE "type=bottom,waterlogged=true" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-S-SLAB-WL
     .
*> RUN-CASE: a fresh world, the feature WS-FT placed at (24, WS-Y, 40) with the seed WS-SEED, then the model with the second source and the comparison (WS-BAD cells differ)
 RUN-CASE.
     PERFORM NEW-WORLD
     MOVE 24 TO WS-X
     MOVE 40 TO WS-Z
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-OY WS-Z WS-RESULT
     MOVE 24 TO M-WX
     MOVE WS-OY TO M-WY
     MOVE 40 TO M-WZ
     PERFORM MODEL-PATCH
     MOVE 0 TO WS-BAD WS-CHANGED
     PERFORM VARYING WS-X FROM 16 BY 1 UNTIL WS-X > 31
         PERFORM VARYING WS-Z FROM 32 BY 1 UNTIL WS-Z > 47
             PERFORM VARYING WS-Y FROM 55 BY 1 UNTIL WS-Y > 80
                 COMPUTE WS-INDEX = (WS-Y + 64) * 256 + (WS-Z - 32) * 16 + (WS-X - 16) + 1
                 CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
                 IF WS-STATE NOT = WS-MS(WS-INDEX)
                     ADD 1 TO WS-BAD
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     IF WS-RESULT NOT = M-RESULT
         ADD 1000 TO WS-BAD
     END-IF
     .
 COMPARE-UNCHANGED.
     PERFORM VARYING WS-X FROM 16 BY 1 UNTIL WS-X > 31
         PERFORM VARYING WS-Z FROM 32 BY 1 UNTIL WS-Z > 47
             PERFORM VARYING WS-Y FROM 55 BY 1 UNTIL WS-Y > 80
                 COMPUTE WS-INDEX = (WS-Y + 64) * 256 + (WS-Z - 32) * 16 + (WS-X - 16) + 1
                 CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
                 IF WS-STATE NOT = WS-MS(WS-INDEX)
                     ADD 1 TO WS-BAD
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
 COUNT-BLOCKS.
     MOVE 0 TO WS-N-MOSS WS-N-GLASS WS-N-WATER WS-N-SLAB WS-N-CLAY
     PERFORM VARYING WS-X FROM 16 BY 1 UNTIL WS-X > 31
         PERFORM VARYING WS-Z FROM 32 BY 1 UNTIL WS-Z > 47
             PERFORM VARYING WS-Y FROM 55 BY 1 UNTIL WS-Y > 80
                 CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
                 EVALUATE TRUE
                     WHEN WS-STATE = WS-S-MOSS
                         ADD 1 TO WS-N-MOSS
                     WHEN WS-STATE = WS-S-GLASS
                         ADD 1 TO WS-N-GLASS
                     WHEN WS-STATE = WS-S-WATER
                         ADD 1 TO WS-N-WATER
                     WHEN WS-STATE = WS-S-SLAB-WL
                         ADD 1 TO WS-N-SLAB
                     WHEN WS-STATE = WS-S-CLAY
                         ADD 1 TO WS-N-CLAY
                 END-EVALUATE
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
*> GET-M: M-V = the model state at (M-NX, M-NY, M-NZ) (air outside the chunk column); SET-M writes M-V there (nothing outside)
 GET-M.
     MOVE 0 TO M-V
     IF M-NX >= 16 AND M-NX <= 31 AND M-NZ >= 32 AND M-NZ <= 47 AND M-NY >= -64 AND M-NY <= 319
         COMPUTE WS-INDEX = (M-NY + 64) * 256 + (M-NZ - 32) * 16 + (M-NX - 16) + 1
         MOVE WS-MS(WS-INDEX) TO M-V
     END-IF
     .
 SET-M.
     IF M-NX >= 16 AND M-NX <= 31 AND M-NZ >= 32 AND M-NZ <= 47 AND M-NY >= -64 AND M-NY <= 319
         COMPUTE WS-INDEX = (M-NY + 64) * 256 + (M-NZ - 32) * 16 + (M-NX - 16) + 1
         MOVE M-V TO WS-MS(WS-INDEX)
     END-IF
     .
*> M-STURDY-AT: M-STURDY = 1 when the model state at (M-NX, M-NY, M-NZ) is a solid block
 M-STURDY-AT.
     PERFORM GET-M
     MOVE 0 TO M-STURDY
     IF M-V NOT = 0
         CALL "FL-BLOCK-OF" USING M-V M-B1
         MOVE CB-SOLID(M-B1) TO M-STURDY
     END-IF
     .
*> MODEL-PATCH: section 9 over the model array, drawing from the second source seeded like the first
 MODEL-PATCH.
     MOVE 0 TO WS-LCOUNT M-RESULT
     IF M-RLO < M-RHI
         COMPUTE WS-BOUND = M-RHI - M-RLO + 1
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-BOUND WS-DRAW
         COMPUTE M-RX = M-RLO + WS-DRAW + 1
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-BOUND WS-DRAW
         COMPUTE M-RZ = M-RLO + WS-DRAW + 1
     ELSE
         COMPUTE M-RX = M-RLO + 1
         MOVE M-RX TO M-RZ
     END-IF
     COMPUTE M-DX = 0 - M-RX
     PERFORM VARYING M-DX FROM M-DX BY 1 UNTIL M-DX > M-RX
         COMPUTE M-DZ = 0 - M-RZ
         PERFORM VARYING M-DZ FROM M-DZ BY 1 UNTIL M-DZ > M-RZ
             PERFORM MODEL-COLUMN
         END-PERFORM
     END-PERFORM
     IF M-WL = 1
         PERFORM MODEL-UNEXPOSED
     END-IF
     IF WS-LCOUNT > 0
         MOVE 1 TO M-RESULT
     END-IF
     PERFORM MODEL-VEGETATION
     .
 MODEL-COLUMN.
     MOVE 0 TO M-SKIP
     IF (M-DX = M-RX OR M-DX = 0 - M-RX) AND (M-DZ = M-RZ OR M-DZ = 0 - M-RZ)
         MOVE 1 TO M-SKIP
     END-IF
     IF M-SKIP = 0 AND M-EE > 0 AND (M-DX = M-RX OR M-DX = 0 - M-RX OR M-DZ = M-RZ OR M-DZ = 0 - M-RZ)
         CALL "WGR-NEXT-FLOAT" USING XR2-STATE WS-F
         IF WS-F > M-EE
             MOVE 1 TO M-SKIP
         END-IF
     END-IF
     IF M-SKIP = 0
         COMPUTE M-NX = M-WX + M-DX
         COMPUTE M-NZ = M-WZ + M-DZ
         MOVE M-WY TO M-CY
         MOVE 0 TO M-STEPS M-GO
         PERFORM UNTIL M-GO = 1
             MOVE M-CY TO M-NY
             PERFORM GET-M
             IF M-V = 0 AND M-STEPS < 5
                 COMPUTE M-CY = M-CY + M-DIR
                 ADD 1 TO M-STEPS
             ELSE
                 MOVE 1 TO M-GO
             END-IF
         END-PERFORM
         MOVE 0 TO M-STEPS M-GO
         PERFORM UNTIL M-GO = 1
             MOVE M-CY TO M-NY
             PERFORM GET-M
             IF M-V NOT = 0 AND M-STEPS < 5
                 COMPUTE M-CY = M-CY - M-DIR
                 ADD 1 TO M-STEPS
             ELSE
                 MOVE 1 TO M-GO
             END-IF
         END-PERFORM
         MOVE M-CY TO M-NY
         PERFORM GET-M
         MOVE M-V TO M-CUR
         COMPUTE M-BELOW-Y = M-CY + M-DIR
         MOVE M-BELOW-Y TO M-NY
         PERFORM M-STURDY-AT
         IF M-CUR = 0 AND M-STURDY = 1
             PERFORM MODEL-LAYERS
         END-IF
     END-IF
     .
 MODEL-LAYERS.
     IF M-DLO < M-DHI
         COMPUTE WS-BOUND = M-DHI - M-DLO + 1
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-BOUND WS-DRAW
         COMPUTE M-LAYERS = M-DLO + WS-DRAW
     ELSE
         MOVE M-DLO TO M-LAYERS
     END-IF
     IF M-EB > 0
         CALL "WGR-NEXT-FLOAT" USING XR2-STATE WS-F
         IF WS-F < M-EB
             ADD 1 TO M-LAYERS
         END-IF
     END-IF
     MOVE M-BELOW-Y TO M-GY
     MOVE 0 TO M-STOP
     MOVE 1 TO M-PLACED
     PERFORM VARYING M-I FROM 0 BY 1 UNTIL M-I >= M-LAYERS OR M-STOP = 1
         MOVE M-GY TO M-NY
         PERFORM GET-M
         MOVE M-V TO M-CUR
         EVALUATE TRUE
             WHEN M-CUR = WS-MODEL-GROUND
                 CONTINUE
             WHEN M-CUR NOT = WS-S-STONE
                 MOVE 1 TO M-STOP
                 IF M-I = 0
                     MOVE 0 TO M-PLACED
                 END-IF
             WHEN OTHER
                 MOVE WS-MODEL-GROUND TO M-V
                 PERFORM SET-M
                 COMPUTE M-GY = M-GY + M-DIR
         END-EVALUATE
     END-PERFORM
     IF M-PLACED = 1 AND WS-LCOUNT < 1024
         ADD 1 TO WS-LCOUNT
         MOVE M-NX TO WS-LX(WS-LCOUNT)
         MOVE M-BELOW-Y TO WS-LY(WS-LCOUNT)
         MOVE M-NZ TO WS-LZ(WS-LCOUNT)
     END-IF
     .
 MODEL-UNEXPOSED.
     MOVE 0 TO M-KEEP
     PERFORM VARYING M-I FROM 1 BY 1 UNTIL M-I > WS-LCOUNT
         MOVE 0 TO M-EXPOSED
         PERFORM VARYING M-K FROM 1 BY 1 UNTIL M-K > 5
             COMPUTE M-NX = WS-LX(M-I) + M-DXS(M-K)
             COMPUTE M-NY = WS-LY(M-I) + M-DYS(M-K)
             COMPUTE M-NZ = WS-LZ(M-I) + M-DZS(M-K)
             PERFORM M-STURDY-AT
             IF M-STURDY = 0
                 MOVE 1 TO M-EXPOSED
             END-IF
         END-PERFORM
         IF M-EXPOSED = 0
             ADD 1 TO M-KEEP
             MOVE WS-LX(M-I) TO WS-LX(M-KEEP)
             MOVE WS-LY(M-I) TO WS-LY(M-KEEP)
             MOVE WS-LZ(M-I) TO WS-LZ(M-KEEP)
         END-IF
     END-PERFORM
     MOVE M-KEEP TO WS-LCOUNT
     MOVE WS-S-WATER TO M-V
     PERFORM VARYING M-I FROM 1 BY 1 UNTIL M-I > WS-LCOUNT
         MOVE WS-LX(M-I) TO M-NX
         MOVE WS-LY(M-I) TO M-NY
         MOVE WS-LZ(M-I) TO M-NZ
         PERFORM SET-M
     END-PERFORM
     .
*> MODEL-VEGETATION: one draw per position (when the chance is above 0); a floor patch places glass above the ground block, the waterlogged patch a slab in the water (waterlogged by the fix)
 MODEL-VEGETATION.
     PERFORM VARYING M-I FROM 1 BY 1 UNTIL M-I > WS-LCOUNT
         IF M-VC > 0
             CALL "WGR-NEXT-FLOAT" USING XR2-STATE WS-F
             IF WS-F < M-VC
                 MOVE WS-LX(M-I) TO M-NX
                 MOVE WS-LY(M-I) TO M-NY
                 MOVE WS-LZ(M-I) TO M-NZ
                 IF M-WL = 0
                     COMPUTE M-NY = M-NY - M-DIR
                     MOVE M-NY TO M-VY
                     COMPUTE M-NY = M-VY - 1
                     PERFORM GET-M
                     IF M-V NOT = 0
                         MOVE M-VY TO M-NY
                         MOVE WS-S-GLASS TO M-V
                         PERFORM SET-M
                     END-IF
                 ELSE
                     COMPUTE M-NY = M-NY - 1
                     PERFORM GET-M
                     IF M-V NOT = 0
                         MOVE WS-LY(M-I) TO M-NY
                         MOVE WS-S-SLAB-WL TO M-V
                         PERFORM SET-M
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     .
*> NEW-WORLD: chunk (1, 2): stone y 40 to 62 (the floor), air above, stone y 70 to 80 (the ceiling); a pit of air at (26, 62, 41), a hole in the ceiling at (24, 70, 41); the model starts as a copy of the
*> chunk and both random sources are seeded
 NEW-WORLD.
     SET ADDRESS OF WS-A TO WS-PTR
     MOVE LOW-VALUES TO WS-A
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     MOVE 16 TO WS-X0
     MOVE 31 TO WS-X1
     MOVE 32 TO WS-Z0
     MOVE 47 TO WS-Z1
     MOVE 40 TO WS-Y0
     MOVE 62 TO WS-Y1
     MOVE "stone" TO WS-KEY
     PERFORM FILL-BOX
     MOVE 70 TO WS-Y0
     MOVE 80 TO WS-Y1
     PERFORM FILL-BOX
     MOVE 26 TO WS-X
     MOVE 62 TO WS-Y
     MOVE 41 TO WS-Z
     MOVE "air" TO WS-KEY
     PERFORM PUT-AT
     MOVE 24 TO WS-X
     MOVE 70 TO WS-Y
     PERFORM PUT-AT
     IF WS-PRE = 1
         MOVE 24 TO WS-X
         MOVE 62 TO WS-Y
         MOVE 40 TO WS-Z
         MOVE "moss_block" TO WS-KEY
         PERFORM PUT-AT
     END-IF
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     PERFORM VARYING WS-INDEX FROM 1 BY 1 UNTIL WS-INDEX > 98304
         MOVE CE-STATE(WS-INDEX) TO WS-MS(WS-INDEX)
     END-PERFORM
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
     .
 COPY FWTEST.
 END PROGRAM TEST-FEAT-35-4-PATCH.
 COPY NOSPAWN.
 COPY CORETEST.
