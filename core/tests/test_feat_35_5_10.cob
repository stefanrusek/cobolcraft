*> Implementation test of blue ice (docs/protocol/35-worldgen-features-5-water-and-surface.md section 10; core/src/feat-ice.cob): the data feature compiles (type 4; a full feature table makes it
*> unsupported); the origin must not be above sea level - 1, must be water or have water below, and needs a packed_ice neighbour (up, north, south, west, east); then blue ice is written at it and
*> 200 attempts (dy = nextInt(5) - nextInt(6), spread 3 + dy / 2 for dy < 2, the offset draws) turn an air, water, packed_ice or ice cell with a blue_ice neighbour (down, up, north, south, west, east)
*> into blue ice, cell by cell against an independent model on a shadow array with a second random source.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-5-10.
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
 01 WS-BAD                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-BOUND               BINARY-LONG VALUE 2.
 01 WS-DRAW                BINARY-LONG.
 01 WS-S-MOSSY             BINARY-LONG.
 01 WS-SEEDNO              BINARY-LONG.
 01 WS-SEEDTXT             PIC 99.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-ORIGIN-Y            BINARY-LONG.
 01 WS-MPX                 BINARY-LONG.
 01 WS-MPY                 BINARY-LONG.
 01 WS-MPZ                 BINARY-LONG.
 01 WS-RX                  BINARY-LONG.
 01 WS-RY                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-REP                 BINARY-LONG.
 01 WS-CX2                 BINARY-LONG.
 01 WS-CY2                 BINARY-LONG.
 01 WS-CZ2                 BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-FF                  FLOAT-LONG.
 01 WS-CELLS               BINARY-LONG.
 01 WS-OBSERVED-CELLS      BINARY-LONG.
 01 WS-MODEL.
    05 WS-MODEL-CELL       PIC 9 OCCURS 4096 TIMES.
 01 WS-MIDX                BINARY-LONG.

 01 WS-SH.
    05 WS-SK               PIC 9 OCCURS 4096 TIMES.
 01 WS-K                   BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-SPREAD              BINARY-LONG.
 01 WS-A1                  BINARY-LONG.
 01 WS-A2                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-NB                  BINARY-LONG.
 01 WS-B6                  BINARY-LONG VALUE 6.
 01 WS-B5                  BINARY-LONG VALUE 5.
 01 WS-REPS                BINARY-LONG.
 01 WS-NK                  BINARY-LONG.
 01 WS-HALF                BINARY-LONG.
 01 WS-QUOT                BINARY-LONG.
 01 WS-DIRS.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
 01 WS-DIR-TABLE REDEFINES WS-DIRS.
    05 WS-DIR6 OCCURS 6 TIMES.
       10 WS-DDX           BINARY-LONG.
       10 WS-DDY           BINARY-LONG.
       10 WS-DDZ           BINARY-LONG.
 01 WS-B-WATER             BINARY-LONG.
 01 WS-B-PACKED            BINARY-LONG.
 01 WS-B-ICE               BINARY-LONG.
 01 WS-B-BLUE              BINARY-LONG.
 01 WS-S-BLUE              BINARY-LONG.
 01 WS-MODEL-RESULT        BINARY-LONG.
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
     MOVE "water" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-WATER
     MOVE "packed_ice" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-PACKED
     MOVE "ice" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-ICE
     MOVE "blue_ice" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-BLUE
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-BLUE
     MOVE "minecraft:blue_ice" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-5§10: the data feature blue_ice compiles (4)" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE 4 TO WS-EXP
     PERFORM ASSERT-N

     PERFORM VARYING WS-SEEDNO FROM 1 BY 1 UNTIL WS-SEEDNO > 8
         COMPUTE WS-SEED = WS-SEEDNO * 104729
         MOVE WS-SEEDNO TO WS-SEEDTXT
         PERFORM NEW-WORLD
         MOVE 24 TO WS-X
         MOVE 52 TO WS-Y
         MOVE 40 TO WS-Z
         PERFORM SHADOW-LOAD
         PERFORM MODEL-RUN
         CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
         PERFORM COMPARE-SHADOW
         MOVE SPACES TO WS-CASE
         STRING "35-5§10: seed " WS-SEEDTXT " the cells equal the model" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-BAD TO WS-OBS
         MOVE 0 TO WS-EXP
         PERFORM ASSERT-N
         MOVE 0 TO WS-REP
         PERFORM VARYING WS-MIDX FROM 1 BY 1 UNTIL WS-MIDX > 4096
             IF WS-SK(WS-MIDX) = 5
                 ADD 1 TO WS-REP
             END-IF
         END-PERFORM
         MOVE SPACES TO WS-CASE
         STRING "35-5§10: seed " WS-SEEDTXT " the model spread blue ice over more than 10 cells" DELIMITED BY SIZE INTO WS-CASE
         MOVE 0 TO WS-OBS
         IF WS-REP > 10
             MOVE 1 TO WS-OBS
         END-IF
         MOVE 1 TO WS-EXP
         PERFORM ASSERT-N
         MOVE SPACES TO WS-CASE
         STRING "35-5§10: seed " WS-SEEDTXT " the result and the random state equal the model's" DELIMITED BY SIZE INTO WS-CASE
         MOVE 1000 TO WS-DRAW
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-DRAW WS-OBS
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-DRAW WS-EXP
         COMPUTE WS-OBS = WS-RESULT * 10000 + WS-OBS
         COMPUTE WS-EXP = WS-MODEL-RESULT * 10000 + WS-EXP
         PERFORM ASSERT-N
     END-PERFORM

*>   refusals: above sea level - 1, neither water nor water below, no packed_ice neighbour: false and no draw
     MOVE 5 TO WS-SEED
     PERFORM NEW-WORLD
     MOVE 24 TO WS-X
     MOVE 63 TO WS-Y
     MOVE 40 TO WS-Z
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-5§10: y above sea level - 1 gives false" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 56 TO WS-Y
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-5§10: air at the origin and no water below gives false" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 44 TO WS-Y
     MOVE 18 TO WS-X
     MOVE 34 TO WS-Z
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-5§10: water with no packed_ice neighbour gives false" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
*>   water below but air at the origin (y 55 above the ice? the layer at 53 and 54): origin at the water surface cell below packed ice
     MOVE 24 TO WS-X
     MOVE 40 TO WS-Z
     MOVE 52 TO WS-Y
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-5§10: water at the origin with packed_ice above gives true" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 55 TO WS-Y
     MOVE 26 TO WS-X
     MOVE 40 TO WS-Z
     MOVE "air" TO WS-KEY
     PERFORM PUT-AT
     MOVE 54 TO WS-Y
     MOVE "water" TO WS-KEY
     PERFORM PUT-AT
     MOVE 55 TO WS-Y
     MOVE 27 TO WS-X
     MOVE "packed_ice" TO WS-KEY
     PERFORM PUT-AT
     MOVE 26 TO WS-X
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-5§10: air at the origin with water below and a packed_ice neighbour (east) gives true" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

     MOVE FD-WA-COUNT TO WS-COUNT
     MOVE FD-MAX-WA TO FD-WA-COUNT
     MOVE "minecraft:blue_ice_full" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE WS-COUNT TO FD-WA-COUNT
     MOVE "35-5§10: a full feature table makes blue ice unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 1 TO FI-GATE
     MOVE "minecraft:blue_ice" TO WS-FTKEY
     CALL "FR-GATE" USING WS-FTKEY WS-COUNT
     MOVE "35-5§10: the gate admits the blue_ice placed feature" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     STOP RUN
     .
*> kind of a state: 1 air, 2 water, 3 packed_ice, 4 ice, 5 blue_ice, 0 other
 KIND-OF.
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     MOVE 0 TO WS-NK
     EVALUATE TRUE
         WHEN WS-BLOCK = WS-B-WATER
             MOVE 2 TO WS-NK
         WHEN WS-BLOCK = WS-B-PACKED
             MOVE 3 TO WS-NK
         WHEN WS-BLOCK = WS-B-ICE
             MOVE 4 TO WS-NK
         WHEN WS-BLOCK = WS-B-BLUE
             MOVE 5 TO WS-NK
         WHEN WS-STATE = 0
             MOVE 1 TO WS-NK
     END-EVALUATE
     .
 SHADOW-LOAD.
     PERFORM VARYING WS-QX FROM 16 BY 1 UNTIL WS-QX > 31
         PERFORM VARYING WS-QZ FROM 32 BY 1 UNTIL WS-QZ > 47
             PERFORM VARYING WS-QY FROM 40 BY 1 UNTIL WS-QY > 55
                 CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
                 PERFORM KIND-OF
                 COMPUTE WS-MIDX = (WS-QY - 40) * 256 + (WS-QZ - 32) * 16 + (WS-QX - 16) + 1
                 MOVE WS-NK TO WS-SK(WS-MIDX)
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
*> SHADOW-AT: WS-NK = kind of the shadow cell (WS-QX, WS-QY, WS-QZ), 0 outside the shadow box
 SHADOW-AT.
     MOVE 0 TO WS-NK
     IF WS-QX >= 16 AND WS-QX <= 31 AND WS-QZ >= 32 AND WS-QZ <= 47 AND WS-QY >= 40 AND WS-QY <= 55
         COMPUTE WS-MIDX = (WS-QY - 40) * 256 + (WS-QZ - 32) * 16 + (WS-QX - 16) + 1
         MOVE WS-SK(WS-MIDX) TO WS-NK
     END-IF
     .
 SHADOW-PUT-BLUE.
     COMPUTE WS-MIDX = (WS-QY - 40) * 256 + (WS-QZ - 32) * 16 + (WS-QX - 16) + 1
     MOVE 5 TO WS-SK(WS-MIDX)
     .
 MODEL-RUN.
     MOVE 0 TO WS-MODEL-RESULT
     MOVE WS-X TO WS-QX
     MOVE WS-Y TO WS-QY
     MOVE WS-Z TO WS-QZ
     PERFORM SHADOW-AT
     MOVE WS-NK TO WS-K
     COMPUTE WS-QY = WS-Y - 1
     PERFORM SHADOW-AT
     IF WS-Y > 62 OR (WS-K NOT = 2 AND WS-NK NOT = 2)
         EXIT PARAGRAPH
     END-IF
     MOVE 0 TO WS-NB
     PERFORM VARYING WS-REPS FROM 2 BY 1 UNTIL WS-REPS > 6
         COMPUTE WS-QX = WS-X + WS-DDX(WS-REPS)
         COMPUTE WS-QY = WS-Y + WS-DDY(WS-REPS)
         COMPUTE WS-QZ = WS-Z + WS-DDZ(WS-REPS)
         PERFORM SHADOW-AT
         IF WS-NK = 3
             MOVE 1 TO WS-NB
         END-IF
     END-PERFORM
     IF WS-NB = 0
         EXIT PARAGRAPH
     END-IF
     MOVE 1 TO WS-MODEL-RESULT
     MOVE WS-X TO WS-QX
     MOVE WS-Y TO WS-QY
     MOVE WS-Z TO WS-QZ
     PERFORM SHADOW-PUT-BLUE
     PERFORM 200 TIMES
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-B5 WS-A1
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-B6 WS-A2
         COMPUTE WS-DY = WS-A1 - WS-A2
         MOVE 3 TO WS-SPREAD
         IF WS-DY < 2
             DIVIDE WS-DY BY 2 GIVING WS-QUOT
             COMPUTE WS-SPREAD = 3 + WS-QUOT
         END-IF
         IF WS-SPREAD >= 1
             CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-SPREAD WS-A1
             CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-SPREAD WS-A2
             COMPUTE WS-QX = WS-X + WS-A1 - WS-A2
             COMPUTE WS-QY = WS-Y + WS-DY
             CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-SPREAD WS-A1
             CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-SPREAD WS-A2
             COMPUTE WS-QZ = WS-Z + WS-A1 - WS-A2
             PERFORM SHADOW-AT
             IF WS-NK >= 1 AND WS-NK <= 4
                 MOVE WS-QX TO WS-LX
                 MOVE WS-QY TO WS-LY
                 MOVE WS-QZ TO WS-LZ
                 MOVE 0 TO WS-NB
                 PERFORM VARYING WS-REPS FROM 1 BY 1 UNTIL WS-REPS > 6
                     COMPUTE WS-QX = WS-LX + WS-DDX(WS-REPS)
                     COMPUTE WS-QY = WS-LY + WS-DDY(WS-REPS)
                     COMPUTE WS-QZ = WS-LZ + WS-DDZ(WS-REPS)
                     PERFORM SHADOW-AT
                     IF WS-NK = 5
                         MOVE 1 TO WS-NB
                     END-IF
                 END-PERFORM
                 IF WS-NB = 1
                     MOVE WS-LX TO WS-QX
                     MOVE WS-LY TO WS-QY
                     MOVE WS-LZ TO WS-QZ
                     PERFORM SHADOW-PUT-BLUE
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     .
 COMPARE-SHADOW.
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-QX FROM 16 BY 1 UNTIL WS-QX > 31
         PERFORM VARYING WS-QZ FROM 32 BY 1 UNTIL WS-QZ > 47
             PERFORM VARYING WS-QY FROM 40 BY 1 UNTIL WS-QY > 55
                 CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
                 PERFORM KIND-OF
                 PERFORM SHADOW-AT
                 MOVE WS-NK TO WS-K
                 CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
                 PERFORM KIND-OF
                 IF WS-NK NOT = WS-K
                     ADD 1 TO WS-BAD
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
*> NEW-WORLD: chunk (1, 2): stone to y 39, water 40 to 52, a packed_ice layer at 53 over x 20 to 28, z 36 to 44 with ice at 54 over x 22 to 26, z 38 to 42, air above; both random sources seeded
 NEW-WORLD.
     SET ADDRESS OF WS-A TO WS-PTR
     MOVE LOW-VALUES TO WS-A
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     MOVE 16 TO WS-X0
     MOVE 31 TO WS-X1
     MOVE 32 TO WS-Z0
     MOVE 47 TO WS-Z1
     MOVE 30 TO WS-Y0
     MOVE 39 TO WS-Y1
     MOVE "stone" TO WS-KEY
     PERFORM FILL-BOX
     MOVE 40 TO WS-Y0
     MOVE 52 TO WS-Y1
     MOVE "water" TO WS-KEY
     PERFORM FILL-BOX
     MOVE 20 TO WS-X0
     MOVE 28 TO WS-X1
     MOVE 36 TO WS-Z0
     MOVE 44 TO WS-Z1
     MOVE 53 TO WS-Y0
     MOVE 53 TO WS-Y1
     MOVE "packed_ice" TO WS-KEY
     PERFORM FILL-BOX
     MOVE 22 TO WS-X0
     MOVE 26 TO WS-X1
     MOVE 38 TO WS-Z0
     MOVE 42 TO WS-Z1
     MOVE 54 TO WS-Y0
     MOVE 54 TO WS-Y1
     MOVE "ice" TO WS-KEY
     PERFORM FILL-BOX
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
     .
 COPY FWTEST.
 END PROGRAM TEST-FEAT-35-5-10.
 COPY CORETEST.
