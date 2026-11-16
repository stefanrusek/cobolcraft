*> Implementation test of underwater magma (docs/protocol/35-worldgen-features-5-water-and-surface.md section 15; core/src/feat-magma.cob): the data feature compiles (type 52; a missing range makes it
*> unsupported); the origin must be water and the floor (the first non-water block within the search range going down, 1 to 4 below) must exist, else false; the 27 cells around the floor are walked
*> x fastest, then y, then z: a draw nextFloat() < 0.5 keeps a cell, which takes magma when it is not water or air, the block below and the four side neighbours are opaque (a written magma block is seen by later
*> cells); the result is whether one was written; against an independent model with a second random source.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-5-15.
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
    05 WS-MODEL-CELL       PIC 9 OCCURS 6144 TIMES.

 01 WS-SH.
    05 WS-SK               PIC 9 OCCURS 6144 TIMES.
 01 WS-PLACED              BINARY-LONG VALUE 0.
 01 WS-K                   BINARY-LONG.
 01 WS-NK                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-POSY                BINARY-LONG.
 01 WS-MIDX                BINARY-LONG.
 01 WS-FLOAT               FLOAT-LONG.
 01 WS-HALF                FLOAT-LONG VALUE 0.5.
 01 WS-MODEL-RESULT        BINARY-LONG.
 01 WS-B-WATER             BINARY-LONG.
 01 WS-B-MAGMA             BINARY-LONG.
 01 WS-B-STONE             BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-CENTRE-Y            BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-I2                  BINARY-LONG.
 01 WS-ZZ                  BINARY-LONG.
 01 WS-XLO                 BINARY-LONG.
 01 WS-YLO                 BINARY-LONG.
 01 WS-ZLO                 BINARY-LONG.
 01 WS-XX                  BINARY-LONG.
 01 WS-YY                  BINARY-LONG.
 01 WS-SIDE.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
 01 WS-SIDE-TABLE REDEFINES WS-SIDE.
    05 WS-SD OCCURS 4 TIMES.
       10 WS-SDX           BINARY-LONG.
       10 WS-SDZ           BINARY-LONG.
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
     MOVE "magma_block" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-MAGMA
     MOVE "stone" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-STONE
     MOVE "minecraft:um" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-5§15: the data feature compiles as underwater_magma (52)" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE 52 TO WS-EXP
     PERFORM ASSERT-N

     PERFORM VARYING WS-SEEDNO FROM 1 BY 1 UNTIL WS-SEEDNO > 15
         COMPUTE WS-SEED = WS-SEEDNO * 6151
         MOVE WS-SEEDNO TO WS-SEEDTXT
         PERFORM NEW-WORLD
         COMPUTE WS-K = FUNCTION MOD(WS-SEEDNO, 5) + 1
         COMPUTE WS-POSY = 55 + WS-K
         MOVE 24 TO WS-X
         MOVE 40 TO WS-Z
         MOVE WS-POSY TO WS-Y
         PERFORM SHADOW-LOAD
         PERFORM MODEL-RUN
         CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
         PERFORM COMPARE-SHADOW
         MOVE SPACES TO WS-CASE
         STRING "35-5§15: seed " WS-SEEDTXT " the cells equal the model" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-BAD TO WS-OBS
         MOVE 0 TO WS-EXP
         PERFORM ASSERT-N
         MOVE SPACES TO WS-CASE
         STRING "35-5§15: seed " WS-SEEDTXT " the result and the random state equal the model's" DELIMITED BY SIZE INTO WS-CASE
         MOVE 1000 TO WS-DRAW
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-DRAW WS-OBS
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-DRAW WS-EXP
         COMPUTE WS-OBS = WS-RESULT * 1000 + WS-OBS
         COMPUTE WS-EXP = WS-MODEL-RESULT * 1000 + WS-EXP
         PERFORM ASSERT-N
         ADD WS-RESULT TO WS-PLACED
     END-PERFORM
     MOVE "35-5§15: magma was placed for the 12 seeds that have a floor in range" TO WS-CASE
     MOVE WS-PLACED TO WS-OBS
     MOVE 12 TO WS-EXP
     PERFORM ASSERT-N

*>   the worked example: water two above the stone, the floor is the stone; five above there is none
     PERFORM NEW-WORLD
     MOVE 24 TO WS-X
     MOVE 40 TO WS-Z
     MOVE 61 TO WS-Y
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-5§15: five water blocks above the floor gives false (no floor in range)" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 30 TO WS-Y
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-5§15: an origin that is not water gives false" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

     MOVE "minecraft:um_norange" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-5§15: a missing floor_search_range makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE FD-WA-COUNT TO WS-COUNT
     MOVE FD-MAX-WA TO FD-WA-COUNT
     MOVE "minecraft:um_full" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE WS-COUNT TO FD-WA-COUNT
     MOVE "35-5§15: a full feature table makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 1 TO FI-GATE
     MOVE "minecraft:underwater_magma" TO WS-FTKEY
     CALL "FR-GATE" USING WS-FTKEY WS-COUNT
     MOVE "35-5§15: the gate admits underwater_magma" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     STOP RUN
     .
*> kinds: 1 air, 2 water, 3 opaque, 4 magma, 0 other
 KIND-OF.
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     MOVE 0 TO WS-NK
     EVALUATE TRUE
         WHEN WS-BLOCK = WS-B-WATER
             MOVE 2 TO WS-NK
         WHEN WS-BLOCK = WS-B-MAGMA
             MOVE 4 TO WS-NK
         WHEN WS-STATE = 0
             MOVE 1 TO WS-NK
         WHEN WS-BLOCK > 0
             IF CB-OPAQUE(WS-BLOCK) = 1
                 MOVE 3 TO WS-NK
             END-IF
     END-EVALUATE
     .
 SHADOW-LOAD.
     PERFORM VARYING WS-QX FROM 16 BY 1 UNTIL WS-QX > 31
         PERFORM VARYING WS-QZ FROM 32 BY 1 UNTIL WS-QZ > 47
             PERFORM VARYING WS-QY FROM 40 BY 1 UNTIL WS-QY > 63
                 CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
                 PERFORM KIND-OF
                 COMPUTE WS-MIDX = (WS-QY - 40) * 256 + (WS-QZ - 32) * 16 + (WS-QX - 16) + 1
                 MOVE WS-NK TO WS-SK(WS-MIDX)
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
 SHADOW-AT.
     COMPUTE WS-MIDX = (WS-QY - 40) * 256 + (WS-QZ - 32) * 16 + (WS-QX - 16) + 1
     MOVE WS-SK(WS-MIDX) TO WS-NK
     .
 MODEL-RUN.
     MOVE 0 TO WS-MODEL-RESULT
     MOVE WS-X TO WS-QX
     MOVE WS-Y TO WS-QY
     MOVE WS-Z TO WS-QZ
     PERFORM SHADOW-AT
     IF WS-NK NOT = 2
         EXIT PARAGRAPH
     END-IF
     MOVE WS-Y TO WS-CENTRE-Y
     MOVE 1 TO WS-I2
     PERFORM UNTIL WS-I2 >= 5
         MOVE WS-CENTRE-Y TO WS-QY
         PERFORM SHADOW-AT
         IF WS-NK NOT = 2
             EXIT PERFORM
         END-IF
         SUBTRACT 1 FROM WS-CENTRE-Y
         ADD 1 TO WS-I2
     END-PERFORM
     MOVE WS-CENTRE-Y TO WS-QY
     PERFORM SHADOW-AT
     IF WS-NK = 2
         EXIT PARAGRAPH
     END-IF
     COMPUTE WS-XLO = WS-X - 1
     COMPUTE WS-YLO = WS-CENTRE-Y - 1
     COMPUTE WS-ZLO = WS-Z - 1
     PERFORM VARYING WS-ZZ FROM WS-ZLO BY 1 UNTIL WS-ZZ > WS-Z + 1
         PERFORM VARYING WS-YY FROM WS-YLO BY 1 UNTIL WS-YY > WS-CENTRE-Y + 1
             PERFORM VARYING WS-XX FROM WS-XLO BY 1 UNTIL WS-XX > WS-X + 1
                 CALL "WGR-NEXT-FLOAT" USING XR2-STATE WS-FLOAT
                 IF WS-FLOAT < WS-HALF
                     PERFORM MODEL-CELL
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
 MODEL-CELL.
     MOVE WS-XX TO WS-QX
     MOVE WS-YY TO WS-QY
     MOVE WS-ZZ TO WS-QZ
     PERFORM SHADOW-AT
     MOVE 1 TO WS-VALID
     IF WS-NK = 1 OR WS-NK = 2
         MOVE 0 TO WS-VALID
     END-IF
     COMPUTE WS-QY = WS-YY - 1
     PERFORM SHADOW-AT
     IF WS-NK NOT = 3 AND WS-NK NOT = 4
         MOVE 0 TO WS-VALID
     END-IF
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         COMPUTE WS-QX = WS-XX + WS-SDX(WS-K)
         MOVE WS-YY TO WS-QY
         COMPUTE WS-QZ = WS-ZZ + WS-SDZ(WS-K)
         PERFORM SHADOW-AT
         IF WS-NK NOT = 3 AND WS-NK NOT = 4
             MOVE 0 TO WS-VALID
         END-IF
     END-PERFORM
     IF WS-VALID = 1
         MOVE WS-XX TO WS-QX
         MOVE WS-YY TO WS-QY
         MOVE WS-ZZ TO WS-QZ
         COMPUTE WS-MIDX = (WS-QY - 40) * 256 + (WS-QZ - 32) * 16 + (WS-QX - 16) + 1
         MOVE 4 TO WS-SK(WS-MIDX)
         MOVE 1 TO WS-MODEL-RESULT
     END-IF
     .
 COMPARE-SHADOW.
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-QX FROM 16 BY 1 UNTIL WS-QX > 31
         PERFORM VARYING WS-QZ FROM 32 BY 1 UNTIL WS-QZ > 47
             PERFORM VARYING WS-QY FROM 40 BY 1 UNTIL WS-QY > 63
                 CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
                 PERFORM KIND-OF
                 MOVE WS-NK TO WS-I2
                 PERFORM SHADOW-AT
                 IF WS-NK NOT = WS-I2
                     ADD 1 TO WS-BAD
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
*> NEW-WORLD: chunk (1, 2): stone to y 55 (floor top), water 56 to 63, a water notch at (25, 55, 40) and an air pocket at (23, 54, 41); both random sources seeded
 NEW-WORLD.
     SET ADDRESS OF WS-A TO WS-PTR
     MOVE LOW-VALUES TO WS-A
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     MOVE 16 TO WS-X0
     MOVE 31 TO WS-X1
     MOVE 32 TO WS-Z0
     MOVE 47 TO WS-Z1
     MOVE 30 TO WS-Y0
     MOVE 55 TO WS-Y1
     MOVE "stone" TO WS-KEY
     PERFORM FILL-BOX
     MOVE 56 TO WS-Y0
     MOVE 63 TO WS-Y1
     MOVE "water" TO WS-KEY
     PERFORM FILL-BOX
     MOVE 25 TO WS-X
     MOVE 55 TO WS-Y
     MOVE 40 TO WS-Z
     PERFORM PUT-AT
     MOVE 23 TO WS-X
     MOVE 54 TO WS-Y
     MOVE 41 TO WS-Z
     MOVE "air" TO WS-KEY
     PERFORM PUT-AT
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
     .
 COPY FWTEST.
 END PROGRAM TEST-FEAT-35-5-15.
 COPY CORETEST.
