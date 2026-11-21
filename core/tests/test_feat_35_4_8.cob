*> Implementation test of multiface_growth (docs/protocol/35-worldgen-features-4 section 8; core/src/feat-multi.cob): the data features compile (type 28; a block that is not a multiface
*> block, an unknown block, a missing block or placement set, an unknown set member or a full feature table make the feature unsupported; defaults search_range 10 and chance 0.5);
*> placements in hand-made worlds change exactly the cells the rules of 8.1 and 8.2 give, drawing from a second random source seeded alike: the shuffle of the valid directions (Util.shuffle:
*> nextInt(i) for i = n down to 2), the nextFloat of the spread chance, the shuffle of the six directions, the three spread types (same position, same plane, wrap around), the search of
*> step 4 with its per direction shuffle, the waterlogged flag of a water source, a cell that already holds the block. The random state after every placement equals the model's.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-4-8.
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
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/multi".
 01 WS-PTR                 USAGE POINTER.
 01 WS-A                   PIC X(304640) BASED.
 01 WS-MODEL.
    05 WS-MS               BINARY-LONG OCCURS 98304 TIMES.
 01 WS-LIST.
    05 WS-L OCCURS 64 TIMES.
       10 WS-LX            BINARY-LONG.
       10 WS-LY            BINARY-LONG.
       10 WS-LZ            BINARY-LONG.
 01 WS-NCH                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
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
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-KEY                 PIC X(112).
 01 WS-NAME                PIC X(48).
 01 WS-FTKEY               PIC X(80).
 01 WS-PAIRS               PIC X(160).
 01 WS-PTEXT               PIC X(160).
 01 WS-CASE                PIC X(200).
 01 WS-OBS                 BINARY-LONG.
 01 WS-EXP                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-CHANCE              FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-M                  BINARY-LONG.
 01 WS-NM                 PIC X(11).
 01 WS-NL                 BINARY-LONG.
 01 WS-HITS                BINARY-LONG.
 01 WS-SPREADS             BINARY-LONG.
 01 WS-ORD.
    05 WS-O                BINARY-LONG OCCURS 6 TIMES.
 01 WS-D                   BINARY-LONG.
 01 WS-XD                  BINARY-LONG.
 01 WS-FACES               PIC X(6).
 01 WS-WANT-FACES          PIC X(6).
 01 WS-WL                  BINARY-LONG.
 01 WS-WANT-WL             BINARY-LONG.
 01 WS-S-STONE             BINARY-LONG.
 01 WS-N-LICHEN            BINARY-LONG.
 01 WS-N-VEIN              BINARY-LONG.
 01 WS-TALLY               BINARY-LONG.
*> directions by ordinal (DOWN 0, UP 1, NORTH 2, SOUTH 3, WEST 4, EAST 5): the step and the property name
 01 WS-STEPS.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
 01 WS-STEP-T REDEFINES WS-STEPS.
    05 WS-STEP OCCURS 6 TIMES.
       10 WS-SX            BINARY-LONG.
       10 WS-SY            BINARY-LONG.
       10 WS-SZ            BINARY-LONG.
 01 WS-NAMES.
    05 FILLER PIC X(11) VALUE "down=true".
    05 FILLER PIC X(11) VALUE "up=true".
    05 FILLER PIC X(11) VALUE "north=true".
    05 FILLER PIC X(11) VALUE "south=true".
    05 FILLER PIC X(11) VALUE "west=true".
    05 FILLER PIC X(11) VALUE "east=true".
 01 WS-NAME-T REDEFINES WS-NAMES.
    05 WS-DNAME            PIC X(11) OCCURS 6 TIMES.
 01 WS-NLEN.
    05 FILLER BINARY-LONG VALUE 9.
    05 FILLER BINARY-LONG VALUE 7.
    05 FILLER BINARY-LONG VALUE 10.
    05 FILLER BINARY-LONG VALUE 10.
    05 FILLER BINARY-LONG VALUE 9.
    05 FILLER BINARY-LONG VALUE 9.
 01 WS-NLEN-T REDEFINES WS-NLEN.
    05 WS-DLEN             BINARY-LONG OCCURS 6 TIMES.
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
     MOVE "stone" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-STONE
     MOVE "glow_lichen" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-N-LICHEN
     MOVE "sculk_vein" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-N-VEIN

*>   the data features compile
     MOVE "minecraft:mf_all" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE "35-4§8: the data feature mf_all compiles as multiface_growth (28)" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE 28 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:mf_default" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE "35-4§8: a feature with only block, set and a placement flag compiles" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE 28 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-4§8: search_range defaults to 10" TO WS-CASE
     MOVE WA-I(FT-A(WS-FT), 2) TO WS-OBS
     MOVE 10 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-4§8: chance_of_spreading defaults to 0.5 (as a float)" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WA-F(FT-A(WS-FT), 1) = 0.5
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-4§8: only the floor flag is set (floor 1, ceiling 0, wall 0)" TO WS-CASE
     COMPUTE WS-OBS = WA-I(FT-A(WS-FT), 3) * 100 + WA-I(FT-A(WS-FT), 4) * 10 + WA-I(FT-A(WS-FT), 5)
     MOVE 100 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:mf_all" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE "35-4§8: all three placements read (111)" TO WS-CASE
     COMPUTE WS-OBS = WA-I(FT-A(WS-FT), 3) * 100 + WA-I(FT-A(WS-FT), 4) * 10 + WA-I(FT-A(WS-FT), 5)
     MOVE 111 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-4§8: the block of the feature is glow_lichen" TO WS-CASE
     MOVE WA-I(FT-A(WS-FT), 1) TO WS-OBS
     MOVE WS-N-LICHEN TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:mf_sculk" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE "35-4§8: sculk_vein is a multiface block too" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE 28 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:mf_bad_block" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE "35-4§8: a block without face properties (stone) is unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:mf_big_block" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE "35-4§8: a block with more than 128 states (note_block) is not a multiface block" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:mf_bad_range" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE "35-4§8: a search_range that is not a number is unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:mf_bad_chance" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE "35-4§8: a chance_of_spreading that is not a number is unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:mf_unknown_block" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE "35-4§8: an unknown block is unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:mf_no_block" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE "35-4§8: a missing block is unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:mf_no_set" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE "35-4§8: a missing can_be_placed_on is unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:mf_bad_set" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE "35-4§8: an unknown block in can_be_placed_on is unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE FD-WA-COUNT TO WS-COUNT
     MOVE FD-MAX-WA TO FD-WA-COUNT
     MOVE "minecraft:mf_full" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE WS-COUNT TO FD-WA-COUNT
     MOVE "35-4§8: a full feature table makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N

*>   the gate
     MOVE 1 TO FI-GATE
     MOVE "minecraft:glow_lichen" TO WS-FTKEY
     CALL "FR-GATE" USING WS-FTKEY WS-COUNT
     MOVE "35-4§8: the gate admits glow_lichen" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:sculk_vein" TO WS-FTKEY
     CALL "FR-GATE" USING WS-FTKEY WS-COUNT
     MOVE "35-4§8: and sculk_vein" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   a pocket of air in the stone, every placement on, the spread chance 1: one face, then a second at the same position (SAME_POSITION)
     MOVE "minecraft:mf_all" TO WS-FTKEY
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-SEED FROM 11 BY 1 UNTIL WS-SEED > 20
         PERFORM NEW-WORLD
         PERFORM CARVE-POCKET
         PERFORM START-RUN
         PERFORM MODEL-ORIGIN-ALL
         MOVE 1 TO WS-CHANCE
         PERFORM MODEL-SPREAD
         PERFORM CHECK-POCKET
     END-PERFORM
     MOVE "35-4§8.2: a pocket in stone gets two faces (shuffle, float, shuffle of the six), random state as modelled, ten seeds" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   chance 0: one face, the float is drawn
     MOVE "minecraft:mf_none" TO WS-FTKEY
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-SEED FROM 11 BY 1 UNTIL WS-SEED > 20
         PERFORM NEW-WORLD
         PERFORM CARVE-POCKET
         PERFORM START-RUN
         PERFORM MODEL-ORIGIN-ALL
         MOVE 0 TO WS-CHANCE
         PERFORM MODEL-SPREAD
         PERFORM CHECK-POCKET
     END-PERFORM
     MOVE "35-4§8.2: with chance 0 the pocket gets one face and the float is drawn, ten seeds" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   ceiling only: a list of one is not shuffled; chance 0.5 spreads for some seeds
     MOVE "minecraft:mf_ceil" TO WS-FTKEY
     MOVE 0 TO WS-BAD WS-SPREADS
     PERFORM VARYING WS-SEED FROM 11 BY 1 UNTIL WS-SEED > 30
         PERFORM NEW-WORLD
         PERFORM CARVE-POCKET
         PERFORM START-RUN
         MOVE 1 TO WS-O(1)
         MOVE 1 TO WS-N
         PERFORM MODEL-SHUFFLE
         MOVE WS-O(1) TO WS-D
         MOVE 0.5 TO WS-CHANCE
         PERFORM MODEL-SPREAD
         PERFORM CHECK-POCKET
         MOVE 0 TO WS-T
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
             IF WS-WANT-FACES(WS-K:1) = "1"
                 ADD 1 TO WS-T
             END-IF
         END-PERFORM
         IF WS-T = 2
             ADD 1 TO WS-SPREADS
         END-IF
     END-PERFORM
     MOVE "35-4§8.2: a ceiling only feature puts UP (no shuffle draws), spreads or not by the float, random state as modelled, twenty seeds" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-4§8.2: and both outcomes of the float occurred among the seeds" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-SPREADS > 0 AND WS-SPREADS < 20
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   an origin inside stone is not air or water: false, nothing drawn
     MOVE "minecraft:mf_all" TO WS-FTKEY
     MOVE 11 TO WS-SEED
     PERFORM NEW-WORLD
     MOVE 24 TO WS-OX
     MOVE 50 TO WS-OY
     MOVE 40 TO WS-OZ
     PERFORM START-RUN
     PERFORM RNG-EQUAL
     MOVE "35-4§8.2 step 1: an origin inside stone gives false, no change, no draw" TO WS-CASE
     COMPUTE WS-OBS = WS-RESULT * 1000 + WS-NCH * 10 + WS-OK
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   a pocket whose walls are dirt (not in the set): the search of step 4 draws a shuffle of six, then one of five per direction, and every cursor is a solid cell
     MOVE "minecraft:mf_all" TO WS-FTKEY
     MOVE 11 TO WS-SEED
     PERFORM NEW-WORLD
     PERFORM CARVE-POCKET
     MOVE "dirt" TO WS-KEY
     PERFORM DIRT-WALLS
     PERFORM START-RUN
     MOVE 6 TO WS-N
     PERFORM SHUFFLE-SIX
     PERFORM VARYING WS-M FROM 1 BY 1 UNTIL WS-M > 6
         PERFORM MODEL-FIVE
     END-PERFORM
     PERFORM RNG-EQUAL
     MOVE "35-4§8.2 step 4: no neighbour in the set: false, nothing changed, six shuffles of five drawn" TO WS-CASE
     COMPUTE WS-OBS = WS-RESULT * 100 + WS-NCH * 10 + WS-OK
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   step 4 success: the floor is two cells below the origin, the cell next to it takes the face
     MOVE "minecraft:mf_floor0" TO WS-FTKEY
     MOVE 11 TO WS-SEED
     PERFORM NEW-WORLD
     MOVE 24 TO WS-OX
     MOVE 64 TO WS-OY
     MOVE 40 TO WS-OZ
     PERFORM START-RUN
     MOVE 1 TO WS-O(1)
     PERFORM DRAW-FLOAT
     PERFORM RNG-EQUAL
     MOVE "35-4§8.2 step 4: the cell below the origin takes the DOWN face, the float is drawn" TO WS-CASE
     COMPUTE WS-OBS = WS-RESULT * 1000 + WS-NCH * 100 + WS-OK
     MOVE 1101 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 24 TO WS-X
     MOVE 63 TO WS-Y
     MOVE 40 TO WS-Z
     PERFORM FACES-AT
     MOVE "35-4§8.2 step 4: the new cell has the face DOWN only" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-FACES = "100000"
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   three cells above the floor: nothing to attach to within one step
     MOVE 66 TO WS-OY
     PERFORM NEW-WORLD
     PERFORM START-RUN
     PERFORM RNG-EQUAL
     MOVE "35-4§8.2 step 4: out of reach of the set, false, no change, no draw" TO WS-CASE
     COMPUTE WS-OBS = WS-RESULT * 100 + WS-NCH * 10 + WS-OK
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   a null state for placement ends the call: the cell below the origin already has the DOWN face
     MOVE 64 TO WS-OY
     PERFORM NEW-WORLD
     MOVE 24 TO WS-X
     MOVE 63 TO WS-Y
     MOVE 40 TO WS-Z
     MOVE "100000" TO WS-FACES
     MOVE 0 TO WS-WL
     PERFORM PUT-FACES
     PERFORM SNAPSHOT
     PERFORM START-RUN
     PERFORM RNG-EQUAL
     MOVE "35-4§8.2: a cell that already has the face gives a null state and false, no change, no draw" TO WS-CASE
     COMPUTE WS-OBS = WS-RESULT * 100 + WS-NCH * 10 + WS-OK
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   a cell that already holds the block gets one more face (the state itself is the base)
     PERFORM NEW-WORLD
     MOVE 24 TO WS-X
     MOVE 63 TO WS-Y
     MOVE 40 TO WS-Z
     MOVE "001000" TO WS-FACES
     MOVE 0 TO WS-WL
     PERFORM PUT-FACES
     PERFORM SNAPSHOT
     PERFORM START-RUN
     MOVE 1 TO WS-O(1)
     PERFORM DRAW-FLOAT
     PERFORM RNG-EQUAL
     MOVE "35-4§8.1: a cell that holds the block takes the new face on top of its own" TO WS-CASE
     COMPUTE WS-OBS = WS-RESULT * 1000 + WS-NCH * 100 + WS-OK
     MOVE 1101 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 24 TO WS-X
     MOVE 63 TO WS-Y
     MOVE 40 TO WS-Z
     PERFORM FACES-AT
     MOVE "35-4§8.1: and its faces are NORTH and DOWN" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-FACES = "101000"
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   water: a source gives a waterlogged block, a flowing cell does not
     MOVE "minecraft:mf_none" TO WS-FTKEY
     MOVE 11 TO WS-SEED
     PERFORM NEW-WORLD
     PERFORM CARVE-POCKET
     MOVE "water" TO WS-KEY
     MOVE 24 TO WS-X
     MOVE 50 TO WS-Y
     MOVE 40 TO WS-Z
     PERFORM PUT-AT
     PERFORM SNAPSHOT
     PERFORM START-RUN
     MOVE 24 TO WS-X
     MOVE 50 TO WS-Y
     MOVE 40 TO WS-Z
     PERFORM FACES-AT
     MOVE "35-4§8.1: a water source origin gives a waterlogged lichen" TO WS-CASE
     COMPUTE WS-OBS = WS-RESULT * 10 + WS-WL
     MOVE 11 TO WS-EXP
     PERFORM ASSERT-N
     PERFORM NEW-WORLD
     PERFORM CARVE-POCKET
     MOVE "water" TO WS-KEY
     MOVE "level=1" TO WS-PAIRS
     PERFORM PUT-PAIRS
     PERFORM SNAPSHOT
     PERFORM START-RUN
     MOVE 24 TO WS-X
     MOVE 50 TO WS-Y
     MOVE 40 TO WS-Z
     PERFORM FACES-AT
     MOVE "35-4§8.1: a flowing water origin gives a lichen that is not waterlogged" TO WS-CASE
     COMPUTE WS-OBS = WS-RESULT * 10 + WS-WL
     MOVE 10 TO WS-EXP
     PERFORM ASSERT-N

*>   the flat floor: the spread goes to the cell beside the origin (SAME_PLANE)
     MOVE "minecraft:mf_floor" TO WS-FTKEY
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-SEED FROM 11 BY 1 UNTIL WS-SEED > 20
         PERFORM NEW-WORLD
         MOVE 24 TO WS-OX
         MOVE 63 TO WS-OY
         MOVE 40 TO WS-OZ
         PERFORM START-RUN
         MOVE 0 TO WS-O(1)
         PERFORM DRAW-FLOAT
         PERFORM SHUFFLE-SIX
         PERFORM FIRST-HORIZONTAL
         PERFORM RNG-EQUAL
         IF WS-RESULT NOT = 1 OR WS-NCH NOT = 2 OR WS-OK NOT = 1
             ADD 1 TO WS-BAD
         END-IF
         MOVE WS-OX TO WS-X
         MOVE WS-OY TO WS-Y
         MOVE WS-OZ TO WS-Z
         PERFORM FACES-AT
         IF WS-FACES NOT = "100000"
             ADD 1 TO WS-BAD
         END-IF
         COMPUTE WS-X = WS-OX + WS-SX(WS-XD + 1)
         COMPUTE WS-Z = WS-OZ + WS-SZ(WS-XD + 1)
         PERFORM FACES-AT
         IF WS-FACES NOT = "100000"
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "35-4§8.1: on a flat floor the spread (same plane) puts DOWN on the cell beside the origin, random state as modelled, ten seeds" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   the four cells beside the origin hold water sources: the spread (same plane) goes into one of them, and the block there is waterlogged
     MOVE "minecraft:mf_floor" TO WS-FTKEY
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-SEED FROM 11 BY 1 UNTIL WS-SEED > 14
         PERFORM NEW-WORLD
         MOVE "water" TO WS-KEY
         MOVE 24 TO WS-OX
         MOVE 63 TO WS-OY
         MOVE 40 TO WS-OZ
         PERFORM VARYING WS-M FROM 3 BY 1 UNTIL WS-M > 6
             COMPUTE WS-X = WS-OX + WS-SX(WS-M)
             MOVE 63 TO WS-Y
             COMPUTE WS-Z = WS-OZ + WS-SZ(WS-M)
             PERFORM PUT-AT
         END-PERFORM
         PERFORM SNAPSHOT
         PERFORM START-RUN
         MOVE 0 TO WS-O(1)
         PERFORM DRAW-FLOAT
         PERFORM SHUFFLE-SIX
         PERFORM FIRST-HORIZONTAL
         PERFORM RNG-EQUAL
         IF WS-RESULT NOT = 1 OR WS-NCH NOT = 2 OR WS-OK NOT = 1
             ADD 1 TO WS-BAD
         END-IF
         COMPUTE WS-X = WS-OX + WS-SX(WS-XD + 1)
         MOVE 63 TO WS-Y
         COMPUTE WS-Z = WS-OZ + WS-SZ(WS-XD + 1)
         PERFORM FACES-AT
         IF WS-FACES NOT = "100000" OR WS-WL NOT = 1
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "35-4§8.1: a water source beside the origin can be spread into and the lichen there is waterlogged, four seeds" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   a stone pillar in a pit: the spread wraps around the edge (WRAP_AROUND)
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-SEED FROM 11 BY 1 UNTIL WS-SEED > 20
         PERFORM NEW-WORLD
         PERFORM CARVE-PILLAR
         MOVE 24 TO WS-OX
         MOVE 63 TO WS-OY
         MOVE 45 TO WS-OZ
         PERFORM START-RUN
         MOVE 0 TO WS-O(1)
         PERFORM DRAW-FLOAT
         PERFORM SHUFFLE-SIX
         PERFORM FIRST-HORIZONTAL
         PERFORM RNG-EQUAL
         IF WS-RESULT NOT = 1 OR WS-NCH NOT = 2 OR WS-OK NOT = 1
             ADD 1 TO WS-BAD
         END-IF
         COMPUTE WS-X = WS-OX + WS-SX(WS-XD + 1)
         COMPUTE WS-Y = WS-OY - 1
         COMPUTE WS-Z = WS-OZ + WS-SZ(WS-XD + 1)
         PERFORM FACES-AT
         MOVE "000000" TO WS-WANT-FACES
         IF FUNCTION MOD(WS-XD, 2) = 0
             COMPUTE WS-T = WS-XD + 2
         ELSE
             MOVE WS-XD TO WS-T
         END-IF
         MOVE "1" TO WS-WANT-FACES(WS-T:1)
         IF WS-FACES NOT = WS-WANT-FACES
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "35-4§8.1: around a pillar top the spread (wrap around) puts the opposite face on the cell beside the pillar, ten seeds" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   sculk_vein as the block: its own face properties
     MOVE "minecraft:mf_sculk" TO WS-FTKEY
     MOVE 12 TO WS-SEED
     PERFORM NEW-WORLD
     PERFORM CARVE-POCKET
     PERFORM START-RUN
     PERFORM MODEL-ORIGIN-ALL
     MOVE 1 TO WS-CHANCE
     PERFORM MODEL-SPREAD
     PERFORM CHECK-POCKET
     MOVE "35-4§8: sculk_vein placed by the same rules (two faces as modelled)" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     STOP RUN.

 COMPILE-FT.
     MOVE 0 TO FD-BAD
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     .
*> NEW-WORLD: chunk (1, 2): stone y 40 to 62, air above, stone y 70 to 80; the model snapshot is taken at once
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
     PERFORM SNAPSHOT
     .
 SNAPSHOT.
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     PERFORM VARYING WS-INDEX FROM 1 BY 1 UNTIL WS-INDEX > 98304
         MOVE CE-STATE(WS-INDEX) TO WS-MS(WS-INDEX)
     END-PERFORM
     .
*> CARVE-POCKET: one air cell at (24, 50, 40) inside the stone (the origin of the pocket cases)
 CARVE-POCKET.
     MOVE 24 TO WS-OX
     MOVE 50 TO WS-OY
     MOVE 40 TO WS-OZ
     MOVE WS-OX TO WS-X
     MOVE WS-OY TO WS-Y
     MOVE WS-OZ TO WS-Z
     MOVE "air" TO WS-KEY
     PERFORM PUT-AT
     PERFORM SNAPSHOT
     .
*> DIRT-WALLS: dirt (WS-KEY) on the six cells around the pocket
 DIRT-WALLS.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
         COMPUTE WS-X = WS-OX + WS-SX(WS-K)
         COMPUTE WS-Y = WS-OY + WS-SY(WS-K)
         COMPUTE WS-Z = WS-OZ + WS-SZ(WS-K)
         PERFORM PUT-AT
     END-PERFORM
     PERFORM SNAPSHOT
     .
*> CARVE-PILLAR: a pit of air x 22..26, y 61..62, z 44..46 with a stone pillar at (24, 61..62, 45)
 CARVE-PILLAR.
     MOVE 22 TO WS-X0
     MOVE 26 TO WS-X1
     MOVE 61 TO WS-Y0
     MOVE 62 TO WS-Y1
     MOVE 44 TO WS-Z0
     MOVE 46 TO WS-Z1
     MOVE "air" TO WS-KEY
     PERFORM FILL-BOX
     MOVE 24 TO WS-X0
     MOVE 24 TO WS-X1
     MOVE 45 TO WS-Z0
     MOVE 45 TO WS-Z1
     MOVE "stone" TO WS-KEY
     PERFORM FILL-BOX
     PERFORM SNAPSHOT
     .
*> START-RUN: seeds both random sources with WS-SEED, places the feature WS-FTKEY at (WS-OX, WS-OY, WS-OZ) (the origin of the last carve; the defaults of the cases that set none are 24, 64, 40
*> after NEW-WORLD alone), then lists the changed cells: WS-NCH of them in WS-L (WS-OK 1 when the list did not overflow)
 START-RUN.
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-OX WS-OY WS-OZ WS-RESULT
     MOVE 0 TO WS-NCH
     MOVE 1 TO WS-OK
     PERFORM VARYING WS-X FROM 16 BY 1 UNTIL WS-X > 31
         PERFORM VARYING WS-Z FROM 32 BY 1 UNTIL WS-Z > 47
             PERFORM VARYING WS-Y FROM 40 BY 1 UNTIL WS-Y > 80
                 COMPUTE WS-INDEX = (WS-Y + 64) * 256 + (WS-Z - 32) * 16 + (WS-X - 16) + 1
                 CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
                 IF WS-STATE NOT = WS-MS(WS-INDEX)
                     IF WS-NCH < 64
                         ADD 1 TO WS-NCH
                         MOVE WS-X TO WS-LX(WS-NCH)
                         MOVE WS-Y TO WS-LY(WS-NCH)
                         MOVE WS-Z TO WS-LZ(WS-NCH)
                     ELSE
                         MOVE 0 TO WS-OK
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
*> the cases that call START-RUN without a carve use the origin (24, WS-OY, 40); RNG-EQUAL sets WS-OK to the equality of the two random states (WS-OK is then no list flag): the cases read WS-OK
*> after it, as the last digit of their observation
 RNG-EQUAL.
     MOVE 0 TO WS-OK
     IF XR-LO = X2-LO AND XR-HI = X2-HI
         MOVE 1 TO WS-OK
     END-IF
     .
*> DRAW-FLOAT: the model draws one float; WS-F is its value
 DRAW-FLOAT.
     CALL "WGR-NEXT-FLOAT" USING XR2-STATE WS-F
     .
*> MODEL-SHUFFLE: shuffles WS-O(1 .. WS-N) like Util.shuffle (nextInt(i) for i = n down to 2, swap i - 1 and the drawn index)
 MODEL-SHUFFLE.
     PERFORM VARYING WS-I FROM WS-N BY -1 UNTIL WS-I < 2
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-I WS-J
         COMPUTE WS-K = WS-J + 1
         MOVE WS-O(WS-K) TO WS-T
         MOVE WS-O(WS-I) TO WS-O(WS-K)
         MOVE WS-T TO WS-O(WS-I)
     END-PERFORM
     .
*> MODEL-FIVE: a shuffle of five elements (four draws)
 MODEL-FIVE.
     MOVE 5 TO WS-N
     PERFORM MODEL-SHUFFLE
     .
*> SHUFFLE-SIX: WS-O = the six directions shuffled
 SHUFFLE-SIX.
     MOVE 6 TO WS-N
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
         COMPUTE WS-T = WS-K - 1
         MOVE WS-T TO WS-O(WS-K)
     END-PERFORM
     PERFORM MODEL-SHUFFLE
     .
*> FIRST-HORIZONTAL: WS-XD = the first horizontal direction (ordinal 2 to 5) of the shuffled WS-O
 FIRST-HORIZONTAL.
     MOVE -1 TO WS-XD
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6 OR WS-XD >= 0
         IF WS-O(WS-K) >= 2
             MOVE WS-O(WS-K) TO WS-XD
         END-IF
     END-PERFORM
     .
*> MODEL-ORIGIN-ALL: the valid directions UP, DOWN, NORTH, EAST, SOUTH, WEST (ordinals 1, 0, 2, 5, 3, 4) shuffled; WS-D the first (every neighbour is stone in the set)
 MODEL-ORIGIN-ALL.
     MOVE 1 TO WS-O(1)
     MOVE 0 TO WS-O(2)
     MOVE 2 TO WS-O(3)
     MOVE 5 TO WS-O(4)
     MOVE 3 TO WS-O(5)
     MOVE 4 TO WS-O(6)
     MOVE 6 TO WS-N
     PERFORM MODEL-SHUFFLE
     MOVE WS-O(1) TO WS-D
     .
*> MODEL-SPREAD: the float is drawn; when it is under WS-CHANCE the six directions are shuffled and the second face is the first direction on another axis than WS-D (a pocket: the same position
*> is always valid); WS-WANT-FACES is the expected face set
 MODEL-SPREAD.
     MOVE "000000" TO WS-WANT-FACES
     COMPUTE WS-T = WS-D + 1
     MOVE "1" TO WS-WANT-FACES(WS-T:1)
     PERFORM DRAW-FLOAT
     IF WS-F < WS-CHANCE
         PERFORM SHUFFLE-SIX
         MOVE -1 TO WS-XD
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6 OR WS-XD >= 0
             COMPUTE WS-I = WS-D / 2
             COMPUTE WS-J = WS-O(WS-K) / 2
             IF WS-I NOT = WS-J
                 MOVE WS-O(WS-K) TO WS-XD
             END-IF
         END-PERFORM
         COMPUTE WS-T = WS-XD + 1
         MOVE "1" TO WS-WANT-FACES(WS-T:1)
     END-IF
     .
*> CHECK-POCKET: the result is true, one cell changed (the pocket), its faces are WS-WANT-FACES and it is not waterlogged, the random states agree; a mismatch adds one to WS-BAD
 CHECK-POCKET.
     PERFORM RNG-EQUAL
     IF WS-RESULT NOT = 1 OR WS-NCH NOT = 1 OR WS-OK NOT = 1
         ADD 1 TO WS-BAD
     END-IF
     MOVE WS-OX TO WS-X
     MOVE WS-OY TO WS-Y
     MOVE WS-OZ TO WS-Z
     PERFORM FACES-AT
     IF WS-FACES NOT = WS-WANT-FACES OR WS-WL NOT = 0
         ADD 1 TO WS-BAD
     END-IF
     .
*> FACES-AT: WS-FACES = the face booleans of the block state at (WS-X, WS-Y, WS-Z) by direction ordinal, WS-WL the waterlogged flag
 FACES-AT.
     CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
     CALL "BLOCKS-STATE-PROPS" USING WS-STATE WS-PTEXT
     MOVE "000000" TO WS-FACES
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
         MOVE 0 TO WS-TALLY
         MOVE WS-DNAME(WS-K) TO WS-NM
         MOVE WS-DLEN(WS-K) TO WS-NL
         INSPECT WS-PTEXT TALLYING WS-TALLY FOR ALL WS-NM(1:WS-NL)
         IF WS-TALLY > 0
             MOVE "1" TO WS-FACES(WS-K:1)
         END-IF
     END-PERFORM
     MOVE 0 TO WS-WL
     MOVE 0 TO WS-TALLY
     INSPECT WS-PTEXT TALLYING WS-TALLY FOR ALL "waterlogged=true"
     IF WS-TALLY > 0
         MOVE 1 TO WS-WL
     END-IF
     .
*> PUT-FACES: a glow_lichen state with the faces WS-FACES (and waterlogged WS-WL) at (WS-X, WS-Y, WS-Z)
 PUT-FACES.
     MOVE SPACES TO WS-PAIRS
     MOVE 1 TO WS-I
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
         MOVE WS-DNAME(WS-K) TO WS-NM
         COMPUTE WS-NL = WS-DLEN(WS-K) - 5
         IF WS-FACES(WS-K:1) = "1"
             STRING WS-NM(1:WS-NL) "=true," DELIMITED BY SIZE INTO WS-PAIRS WITH POINTER WS-I
         ELSE
             STRING WS-NM(1:WS-NL) "=false," DELIMITED BY SIZE INTO WS-PAIRS WITH POINTER WS-I
         END-IF
     END-PERFORM
     IF WS-WL = 1
         STRING "waterlogged=true" DELIMITED BY SIZE INTO WS-PAIRS WITH POINTER WS-I
     ELSE
         STRING "waterlogged=false" DELIMITED BY SIZE INTO WS-PAIRS WITH POINTER WS-I
     END-IF
     MOVE "glow_lichen" TO WS-KEY
     PERFORM PUT-PAIRS
     .
 COPY FWTEST.
 END PROGRAM TEST-FEAT-35-4-8.
 COPY NOSPAWN.
 COPY CORETEST.
