*> Implementation test of the spring feature (docs/protocol/35-worldgen-features-5-water-and-surface.md section 4; core/src/feat-spring.cob): the data features compile (type 48, a bad block
*> or fluid or a missing state makes the feature unsupported); a spring needs a valid block above, a valid block below (when required), air or a valid block at the origin, and
*> exactly rock_count valid neighbours with hole_count air ones among west, east, north, south and below; it writes the default state (level 0) of the fluid and no draw is made.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-5-SPRING.
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
 01 WS-A                   PIC X(196608) BASED.
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
 01 WS-BOUND              BINARY-LONG VALUE 1000.
 01 WS-D1                  BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "minecraft:base_stone_overworld" TO WS-TAG
     MOVE "stone" TO WS-KEY
     PERFORM WANT-BLOCK
     COMPUTE WS-ID(1) = WS-WANT - 1
     MOVE 1 TO WS-COUNT
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     ALLOCATE 196608 CHARACTERS INITIALIZED RETURNING WS-PTR
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "FD-RESET"

     MOVE "minecraft:sp_water" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-5§4: the data feature spring_water compiles as a spring (48)" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE 48 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-5§4: the defaults are rock_count 4, hole_count 1 and a block below required" TO WS-CASE
     COMPUTE WS-OBS = WA-I(FT-A(WS-FT), 1) * 100 + WA-I(FT-A(WS-FT), 2) * 10 + WA-I(FT-A(WS-FT), 3)
     MOVE 141 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-5§4: the eleven valid blocks of spring_water are listed" TO WS-CASE
     MOVE WA-N(FT-A(WS-FT), 1) TO WS-OBS
     MOVE 11 TO WS-EXP
     PERFORM ASSERT-N

*>   the example of the document: stone at the origin, above and below, north, south and east; air to the west
     PERFORM NEW-WORLD
     PERFORM WALL
     MOVE 24 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 40 TO WS-Z
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-5§4: four valid neighbours and one air hole place the spring" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "water" TO WS-KEY
     MOVE "35-5§4: the spring is the water block at the origin" TO WS-CASE
     PERFORM ASSERT-BLOCK
     MOVE "35-5§4: and it is the default state (level 0, the legacy block of a source)" TO WS-CASE
     MOVE WS-STATE TO WS-OBS
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-EXP
     PERFORM ASSERT-N
     CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
     MOVE "35-5§4: no random draw is made" TO WS-CASE
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-BOUND WS-D1
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-BOUND WS-D2
     MOVE WS-D1 TO WS-OBS
     MOVE WS-D2 TO WS-EXP
     PERFORM ASSERT-N

*>   the west block is stone too: five rocks and no hole, not placed
     PERFORM NEW-WORLD
     PERFORM WALL
     MOVE 23 TO WS-X
     MOVE "stone" TO WS-KEY
     PERFORM PUT-AT
     MOVE 24 TO WS-X
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-5§4: five rocks and no hole do not place spring_water" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "stone" TO WS-KEY
     MOVE "35-5§4: the origin keeps its stone" TO WS-CASE
     PERFORM ASSERT-BLOCK

*>   the block above must be valid
     PERFORM NEW-WORLD
     PERFORM WALL
     MOVE 71 TO WS-Y
     MOVE "air" TO WS-KEY
     PERFORM PUT-AT
     MOVE 70 TO WS-Y
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-5§4: an air block above stops the spring" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   the block below must be valid when required
     PERFORM NEW-WORLD
     PERFORM WALL
     MOVE 69 TO WS-Y
     MOVE "glass" TO WS-KEY
     PERFORM PUT-AT
     MOVE 70 TO WS-Y
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-5§4: a block below that is not valid stops the spring" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   the origin must be air or valid
     PERFORM NEW-WORLD
     PERFORM WALL
     MOVE "glass" TO WS-KEY
     PERFORM PUT-AT
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-5§4: glass at the origin stops the spring" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   an air origin is allowed: it counts as a hole, so the west block is stone and the east block is air
     PERFORM NEW-WORLD
     PERFORM WALL
     MOVE "air" TO WS-KEY
     PERFORM PUT-AT
     MOVE 23 TO WS-X
     MOVE "stone" TO WS-KEY
     PERFORM PUT-AT
     MOVE 25 TO WS-X
     MOVE "air" TO WS-KEY
     PERFORM PUT-AT
     MOVE 24 TO WS-X
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-5§4: an air origin with four rocks (W, N, S, below) and one hole (E) places the spring" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   a lava spring of the closed kind: no block below needed, five rocks of the tag, no hole
     MOVE "minecraft:sp_lava_closed" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-5§4: the closed lava spring takes its valid blocks from a tag" TO WS-CASE
     MOVE WA-N(FT-A(WS-FT), 1) TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-5§4: and reads requires_block_below false, hole_count 0 and rock_count 5" TO WS-CASE
     COMPUTE WS-OBS = WA-I(FT-A(WS-FT), 1) * 100 + WA-I(FT-A(WS-FT), 2) * 10 + WA-I(FT-A(WS-FT), 3)
     MOVE 50 TO WS-EXP
     PERFORM ASSERT-N
     PERFORM NEW-WORLD
     PERFORM WALL
     MOVE 23 TO WS-X
     MOVE "stone" TO WS-KEY
     PERFORM PUT-AT
     MOVE 24 TO WS-X
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-5§4: five rocks and no hole place the closed lava spring" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "lava" TO WS-KEY
     MOVE "35-5§4: the spring is lava" TO WS-CASE
     PERFORM ASSERT-BLOCK
     PERFORM NEW-WORLD
     PERFORM WALL
     MOVE 69 TO WS-Y
     MOVE "air" TO WS-KEY
     PERFORM PUT-AT
     MOVE 23 TO WS-X
     MOVE 70 TO WS-Y
     MOVE "stone" TO WS-KEY
     PERFORM PUT-AT
     MOVE 24 TO WS-X
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-5§4: with the block below not required, an air block below counts as no rock (four rocks, one hole)" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   features that cannot be compiled whole
     MOVE "minecraft:sp_bad_block" TO WS-FTKEY
     PERFORM CHECK-BAD
     MOVE "35-5§4: an unknown valid block makes the spring unsupported" TO WS-CASE
     PERFORM ASSERT-N
     MOVE "minecraft:sp_no_state" TO WS-FTKEY
     PERFORM CHECK-BAD
     MOVE "35-5§4: a spring without a state is unsupported" TO WS-CASE
     PERFORM ASSERT-N
     MOVE "minecraft:sp_bad_fluid" TO WS-FTKEY
     PERFORM CHECK-BAD
     MOVE "35-5§4: a state that names no block is unsupported" TO WS-CASE
     PERFORM ASSERT-N
     MOVE 1 TO FI-GATE
     MOVE "minecraft:spring_water" TO WS-FTKEY
     CALL "FR-GATE" USING WS-FTKEY WS-COUNT
     MOVE "35-5§4: the gate admits the spring placed features" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE FD-WA-COUNT TO WS-COUNT
     MOVE FD-MAX-WA TO FD-WA-COUNT
     MOVE "minecraft:sp_water2" TO WS-FTKEY
     PERFORM CHECK-BAD
     MOVE WS-COUNT TO FD-WA-COUNT
     MOVE "35-5§4: a full feature table makes the spring unsupported" TO WS-CASE
     PERFORM ASSERT-N
     STOP RUN.

 CHECK-BAD.
     MOVE 0 TO FD-BAD
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     .
*> the wall of the document: stone in a 3 x 3 x 3 cube around (24, 70, 40) except the west cell (23, 70, 40), which is air
 WALL.
     MOVE 23 TO WS-X0
     MOVE 25 TO WS-X1
     MOVE 69 TO WS-Y0
     MOVE 71 TO WS-Y1
     MOVE 39 TO WS-Z0
     MOVE 41 TO WS-Z1
     MOVE "stone" TO WS-KEY
     PERFORM FILL-BOX
     MOVE 23 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 40 TO WS-Z
     MOVE "air" TO WS-KEY
     PERFORM PUT-AT
     MOVE 24 TO WS-X
     .
 NEW-WORLD.
*>   an empty chunk (1, 2)
     SET ADDRESS OF WS-A TO WS-PTR
     MOVE LOW-VALUES TO WS-A
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
     MOVE 24 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 40 TO WS-Z
     .
 COPY FWTEST.
 END PROGRAM TEST-FEAT-35-5-SPRING.
 COPY CORETEST.
