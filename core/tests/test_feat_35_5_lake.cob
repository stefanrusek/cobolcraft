*> Implementation test of the lake feature (docs/protocol/35-worldgen-features-5-water-and-surface.md section 3; core/src/feat-lake.cob): the data features compile (type 25; an unknown barrier, a
*> missing predicate or a full table make the feature unsupported); the mask of 4 to 7 ellipsoids (steps 2 and 3) equals an independent per-cell evaluation of the formula for several seeds;
*> a placed lake has cave air in the upper four layers of the mask and the fluid in the lower four, stone in the border cells of the lower layers and in the border cells of the upper layers
*> whose barrier draw (nextInt(2), x, z, y order, after the blob draws) is 1; the validity pass (a liquid border above the fluid layers, a border below that is not solid, the can_place_feature
*> predicate, a position too close to the bottom) stops the lake before anything is written; the replace predicates keep the blocks of their tags; an air barrier is not drawn.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-5-LAKE.
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
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
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
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-CX                  BINARY-LONG VALUE 1.
 01 WS-CZ                  BINARY-LONG VALUE 2.
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-OK                  BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 5.
 01 WS-KEY                 PIC X(112).
 01 WS-NAME                PIC X(48).
 01 WS-FTKEY               PIC X(80).
 01 WS-PAIRS               PIC X(160).
 01 WS-CASE                PIC X(200).
 01 WS-OBS                 BINARY-LONG.
 01 WS-EXP                 BINARY-LONG.
 01 WS-REG                 PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112).
 01 WS-IDS.
    05 WS-ID               BINARY-LONG OCCURS 4 TIMES.
 01 WS-COUNT               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-BOUND               BINARY-LONG VALUE 1000.
 01 WS-D1                  BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 01 WS-MASK                PIC X(2048).
 01 WS-MASK2               PIC X(2048).
 01 WS-BORDER              PIC X(2048).
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-LAVA                BINARY-LONG.
 01 WS-CAVE                BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-DIRT                BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-PICK                BINARY-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-DA                  FLOAT-LONG.
 01 WS-DB                  FLOAT-LONG.
 01 WS-DC                  FLOAT-LONG.
 01 WS-DCX                 FLOAT-LONG.
 01 WS-DCY                 FLOAT-LONG.
 01 WS-DCZ                 FLOAT-LONG.
 01 WS-NXF                 FLOAT-LONG.
 01 WS-NYF                 FLOAT-LONG.
 01 WS-NZF                 FLOAT-LONG.
 01 WS-SUM                 FLOAT-LONG.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-DIRS.
    05 FILLER PIC X(18) VALUE "-1 0 0 1 0 0 0-1 0".
 01 WS-OFFS.
    05 WS-OFF OCCURS 6 TIMES.
       10 WS-ODX           BINARY-LONG.
       10 WS-ODY           BINARY-LONG.
       10 WS-ODZ           BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     PERFORM SET-OFFSETS
     MOVE "minecraft:features_cannot_replace" TO WS-TAG
     MOVE "bedrock" TO WS-KEY
     PERFORM WANT-BLOCK
     COMPUTE WS-ID(1) = WS-WANT - 1
     MOVE 1 TO WS-COUNT
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     MOVE "minecraft:lava_pool_stone_cannot_replace" TO WS-TAG
     MOVE "oak_log" TO WS-KEY
     PERFORM WANT-BLOCK
     COMPUTE WS-ID(2) = WS-WANT - 1
     MOVE 2 TO WS-COUNT
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "FD-RESET"
     MOVE "lava" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-LAVA
     MOVE "cave_air" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-CAVE
     MOVE "stone" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-STONE
     MOVE "dirt" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-DIRT

     MOVE "minecraft:lake_lava" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-5§3: the data feature lake_lava compiles as a lake (25)" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE 25 TO WS-EXP
     PERFORM ASSERT-N

*>   the mask: an independent per-cell evaluation of 3.2 step 3 for six seeds
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE WS-I TO WS-SEED
         CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
         CALL "FR-LAKE-MASK" USING XR-STATE WS-MASK
         CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
         PERFORM REPLAY-MASK
         IF WS-MASK NOT = WS-MASK2
             ADD 1 TO WS-BAD
         END-IF
         MOVE 0 TO WS-N
         INSPECT WS-MASK TALLYING WS-N FOR ALL "1"
         IF WS-N < 20
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "35-5§3.2 steps 2 and 3: the mask of six seeds equals the formula cell by cell and is a real pool" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   a lake in dirt: the lava layers, the cave air above, the stone border
     MOVE 5 TO WS-SEED
     PERFORM NEW-WORLD
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-5§3: a lake in solid ground is placed" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
     PERFORM REPLAY-MASK
     MOVE WS-MASK2 TO WS-MASK
     PERFORM FIND-BORDER
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 15
         PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 15
             PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 7
                 COMPUTE WS-INDEX = (WS-I * 16 + WS-K) * 8 + WS-J + 1
                 COMPUTE WS-X = 16 + WS-I
                 COMPUTE WS-Y = 66 + WS-J
                 COMPUTE WS-Z = 32 + WS-K
                 CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
                 EVALUATE TRUE
                     WHEN WS-MASK(WS-INDEX:1) = "1" AND WS-J < 4
                         MOVE WS-LAVA TO WS-EXP
                     WHEN WS-MASK(WS-INDEX:1) = "1"
                         MOVE WS-CAVE TO WS-EXP
                     WHEN WS-BORDER(WS-INDEX:1) = "1" AND WS-J < 4
                         MOVE WS-STONE TO WS-EXP
                     WHEN WS-BORDER(WS-INDEX:1) = "1"
                         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-TWO WS-DRAW
                         IF WS-DRAW = 1
                             MOVE WS-STONE TO WS-EXP
                         ELSE
                             MOVE WS-DIRT TO WS-EXP
                         END-IF
                     WHEN OTHER
                         MOVE WS-DIRT TO WS-EXP
                 END-EVALUATE
                 IF WS-STATE NOT = WS-EXP
                     ADD 1 TO WS-BAD
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE "35-5§3.2 steps 6 and 7: fluid and cave air in the mask, a stone border with the replayed barrier draws" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-5§3.2: the draws that follow are those of the replay (no other use of the random source)" TO WS-CASE
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-BOUND WS-D1
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-BOUND WS-D2
     MOVE WS-D1 TO WS-OBS
     MOVE WS-D2 TO WS-EXP
     PERFORM ASSERT-N

*>   a liquid border cell in the upper layers stops the lake (nothing written)
     PERFORM NEW-WORLD
     CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
     PERFORM REPLAY-MASK
     MOVE WS-MASK2 TO WS-MASK
     PERFORM FIND-BORDER
     MOVE 4 TO WS-J
     PERFORM PICK-BORDER-AT-LAYER
     MOVE "water" TO WS-KEY
     PERFORM PUT-PICK
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-5§3.2 step 5.1: water in a border cell of the air layers stops the lake" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     PERFORM COUNT-WRITES
     MOVE "35-5§3.2 step 5: and nothing was written (only the planted cell differs from dirt)" TO WS-CASE
     MOVE WS-N TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   a border cell below the surface that is not solid stops the lake
     PERFORM NEW-WORLD
     MOVE 1 TO WS-J
     PERFORM PICK-BORDER-AT-LAYER
     MOVE "air" TO WS-KEY
     PERFORM PUT-PICK
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-5§3.2 step 5.2: air in a border cell of the fluid layers stops the lake" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     PERFORM COUNT-WRITES
     MOVE "35-5§3.2 step 5: and nothing was written (only the planted cell differs from dirt)" TO WS-CASE
     MOVE WS-N TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   a border cell that is already the fluid is allowed there
     PERFORM NEW-WORLD
     MOVE 1 TO WS-J
     PERFORM PICK-BORDER-AT-LAYER
     COMPUTE WS-OBS = 0
     MOVE WS-LAVA TO WS-STATE
     CALL "FL-SET-STATE" USING WS-PX WS-PY WS-PZ WS-STATE WS-FLAGS WS-OK
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-5§3.2 step 5.2: a border cell that holds the fluid state is allowed" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   the replace predicates: bedrock in the pool is kept, an oak log in a lower border cell is kept
     PERFORM NEW-WORLD
     MOVE 1 TO WS-J
     PERFORM PICK-MASK-AT-LAYER
     MOVE "bedrock" TO WS-KEY
     PERFORM PUT-PICK
     MOVE WS-PX TO WS-NX
     MOVE WS-PY TO WS-NY
     MOVE WS-PZ TO WS-NZ
     MOVE 2 TO WS-J
     PERFORM PICK-BORDER-AT-LAYER
     MOVE "oak_log" TO WS-KEY
     PERFORM PUT-PICK
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-5§3.2 step 6: a lake over bedrock and a log is still placed" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE WS-NX TO WS-X
     MOVE WS-NY TO WS-Y
     MOVE WS-NZ TO WS-Z
     MOVE "bedrock" TO WS-KEY
     MOVE "35-5§3.2 step 6: a block of features_cannot_replace is not replaced" TO WS-CASE
     PERFORM ASSERT-BLOCK
     MOVE WS-PX TO WS-X
     MOVE WS-PY TO WS-Y
     MOVE WS-PZ TO WS-Z
     MOVE "oak_log" TO WS-KEY
     MOVE "35-5§3.2 step 7: a block of lava_pool_stone_cannot_replace is not replaced by the barrier" TO WS-CASE
     PERFORM ASSERT-BLOCK

*>   a feature whose can_place_feature fails on the border (stone border, dirt required)
     MOVE "minecraft:lake_dirt_only" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     PERFORM NEW-WORLD
     MOVE 16 TO WS-X0
     MOVE 31 TO WS-X1
     MOVE 60 TO WS-Y0
     MOVE 80 TO WS-Y1
     MOVE 32 TO WS-Z0
     MOVE 47 TO WS-Z1
     MOVE "stone" TO WS-KEY
     PERFORM FILL-BOX
     MOVE 24 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 40 TO WS-Z
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-5§3.2 step 5.3: a border cell that fails can_place_feature stops the lake" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   an air barrier is not drawn and not written
     MOVE "minecraft:lake_air_barrier" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     PERFORM NEW-WORLD
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-5§3.2 step 7: a lake with an air barrier is placed" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
     PERFORM REPLAY-MASK
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-BOUND WS-D1
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-BOUND WS-D2
     MOVE "35-5§3.2 step 7: and no barrier draw is made" TO WS-CASE
     MOVE WS-D1 TO WS-OBS
     MOVE WS-D2 TO WS-EXP
     PERFORM ASSERT-N

*>   too close to the bottom: no draw
     MOVE "minecraft:lake_lava" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     PERFORM NEW-WORLD
     MOVE -60 TO WS-Y
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-5§3.2 step 1: a position at minY + 4 or below gives false" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-BOUND WS-D1
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-BOUND WS-D2
     MOVE "35-5§3.2 step 1: and makes no draw" TO WS-CASE
     MOVE WS-D1 TO WS-OBS
     MOVE WS-D2 TO WS-EXP
     PERFORM ASSERT-N

*>   a water lake: step 8 turns a source of water of layer 4 into ice in a cold biome (a corner of the window is no mask or border cell)
     MOVE 2 TO CBI-COUNT
     MOVE 0 TO CBI-TEMPERATURE(1) CBI-FROZEN(1) CBI-FROZEN(2) CBI-PRECIPITATION(1) CBI-PRECIPITATION(2)
     MOVE 0.8 TO CBI-TEMPERATURE(2)
     MOVE "minecraft:lake_water" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     PERFORM NEW-WORLD
     MOVE 16 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 32 TO WS-Z
     MOVE "water" TO WS-KEY
     PERFORM PUT-AT
     MOVE 31 TO WS-X
     MOVE "level=5" TO WS-PAIRS
     PERFORM PUT-PAIRS
     MOVE 24 TO WS-X
     MOVE 40 TO WS-Z
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-5§3.2: a water lake is placed" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 16 TO WS-X
     MOVE 32 TO WS-Z
     MOVE "ice" TO WS-KEY
     MOVE "35-5§3.2 step 8: a source of water at layer 4 in a cold biome freezes" TO WS-CASE
     PERFORM ASSERT-BLOCK
     MOVE 31 TO WS-X
     MOVE "water" TO WS-KEY
     MOVE "35-5§3.2 step 8: flowing water at layer 4 does not" TO WS-CASE
     PERFORM ASSERT-BLOCK
     PERFORM NEW-WORLD
     MOVE 16 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 32 TO WS-Z
     MOVE "water" TO WS-KEY
     PERFORM PUT-AT
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 1536
         MOVE 1 TO CE-BIOME(WS-J)
     END-PERFORM
     MOVE 24 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 40 TO WS-Z
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE 16 TO WS-X
     MOVE 32 TO WS-Z
     MOVE "water" TO WS-KEY
     MOVE "35-5§3.2 step 8: in a warm biome the source stays water" TO WS-CASE
     PERFORM ASSERT-BLOCK
     MOVE 24 TO WS-X
     MOVE 40 TO WS-Z
     MOVE 1 TO FI-GATE
     MOVE "minecraft:lake_lava_surface" TO WS-FTKEY
     CALL "FR-GATE" USING WS-FTKEY WS-COUNT
     MOVE "35-5§3: the gate admits the lake placed features" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
*>   features that cannot be compiled whole
     MOVE "minecraft:lake_bad_barrier" TO WS-FTKEY
     PERFORM CHECK-BAD
     MOVE "35-5§3: an unknown barrier block makes the lake unsupported" TO WS-CASE
     PERFORM ASSERT-N
     MOVE "minecraft:lake_no_pred" TO WS-FTKEY
     PERFORM CHECK-BAD
     MOVE "35-5§3: a lake without can_place_feature is unsupported" TO WS-CASE
     PERFORM ASSERT-N
     MOVE FD-WA-COUNT TO WS-COUNT
     MOVE FD-MAX-WA TO FD-WA-COUNT
     MOVE "minecraft:lake_lava2" TO WS-FTKEY
     PERFORM CHECK-BAD
     MOVE WS-COUNT TO FD-WA-COUNT
     MOVE "35-5§3: a full feature table makes the lake unsupported" TO WS-CASE
     PERFORM ASSERT-N
     MOVE CB-BLOCK-COUNT TO WS-COUNT
     MOVE 1 TO CB-BLOCK-COUNT
     MOVE "minecraft:lake_lava2" TO WS-FTKEY
     MOVE 0 TO FD-BAD
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     MOVE 0 TO FT-TYPE(WS-FT)
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE WS-COUNT TO CB-BLOCK-COUNT
     MOVE "35-5§3: a block table without cave_air makes the lake unsupported" TO WS-CASE
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     STOP RUN.

 CHECK-BAD.
     MOVE 0 TO FD-BAD
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     .
 SET-OFFSETS.
     MOVE -1 TO WS-ODX(1)
     MOVE 0 TO WS-ODY(1) WS-ODZ(1)
     MOVE 1 TO WS-ODX(2)
     MOVE 0 TO WS-ODY(2) WS-ODZ(2)
     MOVE 0 TO WS-ODX(3) WS-ODZ(3)
     MOVE -1 TO WS-ODY(3)
     MOVE 0 TO WS-ODX(4) WS-ODZ(4)
     MOVE 1 TO WS-ODY(4)
     MOVE 0 TO WS-ODX(5) WS-ODY(5)
     MOVE -1 TO WS-ODZ(5)
     MOVE 0 TO WS-ODX(6) WS-ODY(6)
     MOVE 1 TO WS-ODZ(6)
     .
*> REPLAY-MASK: WS-MASK2 from the random source XR2-STATE, cell by cell as the document says (nx, ny, nz per cell)
 REPLAY-MASK.
     MOVE ALL "0" TO WS-MASK2
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-FOUR WS-N
     ADD 4 TO WS-N
     PERFORM WS-N TIMES
         CALL "WGR-NEXT-DOUBLE" USING XR2-STATE WS-D
         COMPUTE WS-DA = WS-D * 6 + 3
         CALL "WGR-NEXT-DOUBLE" USING XR2-STATE WS-D
         COMPUTE WS-DB = WS-D * 4 + 2
         CALL "WGR-NEXT-DOUBLE" USING XR2-STATE WS-D
         COMPUTE WS-DC = WS-D * 6 + 3
         CALL "WGR-NEXT-DOUBLE" USING XR2-STATE WS-D
         COMPUTE WS-DCX = WS-D * (16 - WS-DA - 2) + 1 + WS-DA / 2
         CALL "WGR-NEXT-DOUBLE" USING XR2-STATE WS-D
         COMPUTE WS-DCY = WS-D * (8 - WS-DB - 4) + 2 + WS-DB / 2
         CALL "WGR-NEXT-DOUBLE" USING XR2-STATE WS-D
         COMPUTE WS-DCZ = WS-D * (16 - WS-DC - 2) + 1 + WS-DC / 2
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 14
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 14
                 PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 6
                     COMPUTE WS-NXF = (WS-I - WS-DCX) / (WS-DA / 2)
                     COMPUTE WS-NYF = (WS-J - WS-DCY) / (WS-DB / 2)
                     COMPUTE WS-NZF = (WS-K - WS-DCZ) / (WS-DC / 2)
                     COMPUTE WS-SUM = WS-NXF * WS-NXF + WS-NYF * WS-NYF + WS-NZF * WS-NZF
                     IF WS-SUM < WS-ONE
                         COMPUTE WS-INDEX = (WS-I * 16 + WS-K) * 8 + WS-J + 1
                         MOVE "1" TO WS-MASK2(WS-INDEX:1)
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
*> FIND-BORDER: WS-BORDER from WS-MASK: a cell outside the mask with a neighbour of the window inside it
 FIND-BORDER.
     MOVE ALL "0" TO WS-BORDER
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 15
         PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 15
             PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 7
                 COMPUTE WS-INDEX = (WS-I * 16 + WS-K) * 8 + WS-J + 1
                 IF WS-MASK(WS-INDEX:1) = "0"
                     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 6
                         COMPUTE WS-NX = WS-I + WS-ODX(WS-N)
                         COMPUTE WS-NY = WS-J + WS-ODY(WS-N)
                         COMPUTE WS-NZ = WS-K + WS-ODZ(WS-N)
                         IF WS-NX >= 0 AND WS-NX <= 15 AND WS-NY >= 0 AND WS-NY <= 7 AND WS-NZ >= 0 AND WS-NZ <= 15
                             COMPUTE WS-D1 = (WS-NX * 16 + WS-NZ) * 8 + WS-NY + 1
                             IF WS-MASK(WS-D1:1) = "1"
                                 MOVE "1" TO WS-BORDER(WS-INDEX:1)
                             END-IF
                         END-IF
                     END-PERFORM
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
*> PICK-BORDER-AT-LAYER: the first border cell (x, z, y order) of layer WS-J: its world cell in WS-PX, WS-PY, WS-PZ
 PICK-BORDER-AT-LAYER.
     MOVE 0 TO WS-PICK
     MOVE WS-BORDER TO WS-MASK2
     PERFORM PICK-IN-MASK2
     .
 PICK-MASK-AT-LAYER.
     MOVE WS-MASK TO WS-MASK2
     PERFORM PICK-IN-MASK2
     .
 PICK-IN-MASK2.
     MOVE 0 TO WS-PICK
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 15 OR WS-PICK = 1
         PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 15 OR WS-PICK = 1
             COMPUTE WS-INDEX = (WS-I * 16 + WS-K) * 8 + WS-J + 1
             IF WS-MASK2(WS-INDEX:1) = "1"
                 MOVE 1 TO WS-PICK
                 COMPUTE WS-PX = 16 + WS-I
                 COMPUTE WS-PY = 66 + WS-J
                 COMPUTE WS-PZ = 32 + WS-K
             END-IF
         END-PERFORM
     END-PERFORM
     .
 PUT-PICK.
     MOVE WS-PX TO WS-X
     MOVE WS-PY TO WS-Y
     MOVE WS-PZ TO WS-Z
     PERFORM PUT-AT
     MOVE 24 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 40 TO WS-Z
     .
*> COUNT-WRITES: WS-N = the cells of the window area that are not dirt
 COUNT-WRITES.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-X FROM 16 BY 1 UNTIL WS-X > 31
         PERFORM VARYING WS-Z FROM 32 BY 1 UNTIL WS-Z > 47
             PERFORM VARYING WS-Y FROM 66 BY 1 UNTIL WS-Y > 73
                 CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
                 IF WS-STATE NOT = WS-DIRT
                     ADD 1 TO WS-N
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 24 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 40 TO WS-Z
     .
*> NEW-WORLD: chunk (1, 2) of dirt from y 60 to 80, the random sources of WS-SEED, the lake origin (24, 70, 40)
 NEW-WORLD.
     SET ADDRESS OF WS-A TO WS-PTR
     MOVE LOW-VALUES TO WS-A
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     MOVE 16 TO WS-X0
     MOVE 31 TO WS-X1
     MOVE 60 TO WS-Y0
     MOVE 80 TO WS-Y1
     MOVE 32 TO WS-Z0
     MOVE 47 TO WS-Z1
     MOVE "dirt" TO WS-KEY
     PERFORM FILL-BOX
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
     MOVE 24 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 40 TO WS-Z
     .
 COPY FWTEST.
 END PROGRAM TEST-FEAT-35-5-LAKE.
 COPY CORETEST.
