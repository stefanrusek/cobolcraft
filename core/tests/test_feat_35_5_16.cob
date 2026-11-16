*> Implementation test of the ice spike, type spike (docs/protocol/35-worldgen-features-5-water-and-surface.md section 16; core/src/feat-spike.cob): the data feature compiles (type 47; an unknown state
*> or a missing can_replace makes it unsupported); the origin walks down through air to the ground (false when it is not snow_block); then the draws (up nextInt(4), H = nextInt(4) + 7,
*> Wd = H / 4 + nextInt(2), the rare tall branch), the body (radius ceil((1 - y / H) * Wd), the distance test, the rim draw nextFloat() > 0.75, the mirrored cell) and the pillar base (the countdown
*> columns); every cell compared with an independent model on a shadow array and a second random source (the distance test in exact integers: ((4a - 1)^2 + (4b - 1)^2) * H^2 <= 16 ((H - y) Wd)^2).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-5-16.
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
 01 WS-AREA                PIC X(304640) BASED.
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
    05 WS-OS               BINARY-LONG OCCURS 30976 TIMES.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-MIDX                BINARY-LONG.
 01 WS-B-SNOW              BINARY-LONG.
 01 WS-B-DIRT              BINARY-LONG.
 01 WS-B-ICE               BINARY-LONG.
 01 WS-S-PACKED            BINARY-LONG.
 01 WS-MODEL-RESULT        BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-WD                  BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-YY                  BINARY-LONG.
 01 WS-RAD                 BINARY-LONG.
 01 WS-NUM                 BINARY-LONG.
 01 WS-AX                  BINARY-LONG.
 01 WS-AZ                  BINARY-LONG.
 01 WS-LHS                 BINARY-LONG.
 01 WS-RHS                 BINARY-DOUBLE.
 01 WS-LHSD                BINARY-DOUBLE.
 01 WS-KW                  BINARY-DOUBLE.
 01 WS-BITS24              BINARY-LONG VALUE 24.
 01 WS-N                   BINARY-LONG.
 01 WS-OK-W                BINARY-LONG.
 01 WS-DOWN                BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-CH                  BINARY-LONG.
 01 WS-B4                  BINARY-LONG VALUE 4.
 01 WS-B2                  BINARY-LONG VALUE 2.
 01 WS-B5                  BINARY-LONG VALUE 5.
 01 WS-B60                 BINARY-LONG VALUE 60.
 01 WS-B30                 BINARY-LONG VALUE 30.
 01 WS-PLACED              BINARY-LONG VALUE 0.
 01 WS-PLACED-TALL         BINARY-LONG VALUE 0.
 01 WS-LXX                 BINARY-LONG.
 01 WS-LZZ                 BINARY-LONG.
 01 WS-AXX                 BINARY-LONG.
 01 WS-AZZ                 BINARY-LONG.
 01 WS-CXX                 BINARY-LONG.
 01 WS-CZZ                 BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-TALL                BINARY-LONG VALUE 0.
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
     MOVE "snow_block" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-SNOW
     MOVE "dirt" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-DIRT
     MOVE "ice" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-ICE
     MOVE "packed_ice" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-PACKED
     MOVE "minecraft:spike_ice" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-5§16: the data feature compiles as a spike (47)" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE 47 TO WS-EXP
     PERFORM ASSERT-N

     PERFORM VARYING WS-SEEDNO FROM 1 BY 1 UNTIL WS-SEEDNO > 40
         COMPUTE WS-SEED = WS-SEEDNO * 2371
         MOVE WS-SEEDNO TO WS-SEEDTXT
         PERFORM NEW-WORLD
         MOVE 24 TO WS-X
         MOVE 100 TO WS-Y
         MOVE 40 TO WS-Z
         PERFORM SAVE-WORLD
         PERFORM MODEL-RUN
         CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
         PERFORM COMPARE-WORLD
         MOVE SPACES TO WS-CASE
         STRING "35-5§16: seed " WS-SEEDTXT " the cells equal the model" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-BAD TO WS-OBS
         MOVE 0 TO WS-EXP
         PERFORM ASSERT-N
         MOVE SPACES TO WS-CASE
         STRING "35-5§16: seed " WS-SEEDTXT " the result and the random state equal the model's" DELIMITED BY SIZE INTO WS-CASE
         MOVE 1000 TO WS-DRAW
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-DRAW WS-OBS
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-DRAW WS-EXP
         COMPUTE WS-OBS = WS-RESULT * 1000 + WS-OBS
         COMPUTE WS-EXP = WS-MODEL-RESULT * 1000 + WS-EXP
         PERFORM ASSERT-N
     END-PERFORM
     MOVE "35-5§16: a spike was placed in every run" TO WS-CASE
     MOVE WS-PLACED TO WS-OBS
     MOVE 40 TO WS-EXP
     PERFORM ASSERT-N

*>   the ground is not snow: false after the walk down, no further draw
     PERFORM NEW-WORLD
     MOVE 24 TO WS-X
     MOVE 40 TO WS-Z
     MOVE 62 TO WS-Y
     MOVE "stone" TO WS-KEY
     PERFORM PUT-AT
     MOVE 100 TO WS-Y
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-5§16: a ground that is not snow_block gives false" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 1000 TO WS-DRAW
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-DRAW WS-OBS
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-DRAW WS-EXP
     MOVE "35-5§16: and makes no draw" TO WS-CASE
     PERFORM ASSERT-N
*>   an all-air column walks down to minY + 2 and fails there
     MOVE 24 TO WS-X0
     MOVE 24 TO WS-X1
     MOVE 40 TO WS-Z0
     MOVE 40 TO WS-Z1
     MOVE -64 TO WS-Y0
     MOVE 110 TO WS-Y1
     MOVE "air" TO WS-KEY
     PERFORM FILL-BOX
     MOVE 24 TO WS-X
     MOVE 100 TO WS-Y
     MOVE 40 TO WS-Z
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-5§16: an all-air column gives false at minY + 2" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

     MOVE "minecraft:spike_bad" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-5§16: an unknown state makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:spike_norepl" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-5§16: a missing can_replace makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE FD-WA-COUNT TO WS-COUNT
     MOVE FD-MAX-WA TO FD-WA-COUNT
     MOVE "minecraft:spike_full" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE WS-COUNT TO FD-WA-COUNT
     MOVE "35-5§16: a full feature table makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 1 TO FI-GATE
     MOVE "minecraft:ice_spike" TO WS-FTKEY
     CALL "FR-GATE" USING WS-FTKEY WS-COUNT
     MOVE "35-5§16: the gate admits ice_spike" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     STOP RUN
     .
 SAVE-WORLD.
     PERFORM VARYING WS-QZ FROM 32 BY 1 UNTIL WS-QZ > 47
         PERFORM VARYING WS-QX FROM 16 BY 1 UNTIL WS-QX > 31
             PERFORM VARYING WS-QY FROM 40 BY 1 UNTIL WS-QY > 160
                 COMPUTE WS-MIDX = (WS-QY - 40) * 256 + (WS-QZ - 32) * 16 + (WS-QX - 16) + 1
                 CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
                 MOVE WS-STATE TO WS-OS(WS-MIDX)
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
*> GET-M / PUT-M: the shadow cell (WS-QX, WS-QY, WS-QZ): WS-STATE in / out; a cell outside the box reads as air and is not written
 GET-M.
     MOVE 0 TO WS-STATE
     IF WS-QX >= 16 AND WS-QX <= 31 AND WS-QZ >= 32 AND WS-QZ <= 47 AND WS-QY >= 40 AND WS-QY <= 160
         COMPUTE WS-MIDX = (WS-QY - 40) * 256 + (WS-QZ - 32) * 16 + (WS-QX - 16) + 1
         MOVE WS-OS(WS-MIDX) TO WS-STATE
     END-IF
     .
 PUT-M.
     IF WS-QX >= 16 AND WS-QX <= 31 AND WS-QZ >= 32 AND WS-QZ <= 47 AND WS-QY >= 40 AND WS-QY <= 160
         COMPUTE WS-MIDX = (WS-QY - 40) * 256 + (WS-QZ - 32) * 16 + (WS-QX - 16) + 1
         MOVE WS-S-PACKED TO WS-OS(WS-MIDX)
     END-IF
     .
*> AIR-OR-REPLACE: WS-OK-W 1 when the shadow cell is air, dirt, snow_block or ice
 AIR-OR-REPLACE.
     PERFORM GET-M
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     MOVE 0 TO WS-OK-W
     IF WS-STATE = 0 OR WS-BLOCK = WS-B-DIRT OR WS-BLOCK = WS-B-SNOW OR WS-BLOCK = WS-B-ICE
         MOVE 1 TO WS-OK-W
     END-IF
     .
 MODEL-RUN.
     MOVE 0 TO WS-MODEL-RESULT
     MOVE WS-X TO WS-LX
     MOVE WS-Z TO WS-LZ
     MOVE WS-Y TO WS-MPY
     PERFORM UNTIL WS-MPY <= -62
         MOVE WS-LX TO WS-QX
         MOVE WS-MPY TO WS-QY
         MOVE WS-LZ TO WS-QZ
         PERFORM GET-M
         IF WS-STATE NOT = 0
             EXIT PERFORM
         END-IF
         SUBTRACT 1 FROM WS-MPY
     END-PERFORM
     MOVE WS-LX TO WS-QX
     MOVE WS-MPY TO WS-QY
     MOVE WS-LZ TO WS-QZ
     PERFORM GET-M
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     IF WS-BLOCK NOT = WS-B-SNOW
         EXIT PARAGRAPH
     END-IF
     MOVE 1 TO WS-MODEL-RESULT
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-B4 WS-CH
     ADD WS-CH TO WS-MPY
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-B4 WS-H
     ADD 7 TO WS-H
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-B2 WS-CH
     COMPUTE WS-WD = WS-H / 4 + WS-CH
     IF WS-WD > 1
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-B60 WS-CH
         IF WS-CH = 0
             CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-B30 WS-CH
             COMPUTE WS-MPY = WS-MPY + 10 + WS-CH
         END-IF
     END-IF
     PERFORM VARYING WS-YY FROM 0 BY 1 UNTIL WS-YY >= WS-H
         COMPUTE WS-NUM = (WS-H - WS-YY) * WS-WD
*>       rad = ceil(NUM / H)
         COMPUTE WS-RAD = (WS-NUM + WS-H - 1) / WS-H
         PERFORM MODEL-LAYER
     END-PERFORM
     COMPUTE WS-T = WS-WD - 1
     IF WS-T > 1
         MOVE 1 TO WS-T
     END-IF
     COMPUTE WS-AX = 0 - WS-T
     PERFORM VARYING WS-QX FROM WS-AX BY 1 UNTIL WS-QX > WS-T
         PERFORM VARYING WS-QZ FROM WS-AX BY 1 UNTIL WS-QZ > WS-T
             PERFORM MODEL-COLUMN
         END-PERFORM
     END-PERFORM
     IF WS-MPY > WS-H
         ADD 1 TO WS-PLACED-TALL
     END-IF
     .
 MODEL-LAYER.
     COMPUTE WS-AX = 0 - WS-RAD
     PERFORM VARYING WS-LXX FROM WS-AX BY 1 UNTIL WS-LXX > WS-RAD
         PERFORM VARYING WS-LZZ FROM WS-AX BY 1 UNTIL WS-LZZ > WS-RAD
             COMPUTE WS-AXX = FUNCTION ABS(WS-LXX)
             COMPUTE WS-AZZ = FUNCTION ABS(WS-LZZ)
             COMPUTE WS-LHSD = ((4 * WS-AXX - 1) * (4 * WS-AXX - 1) + (4 * WS-AZZ - 1) * (4 * WS-AZZ - 1)) * WS-H * WS-H
             COMPUTE WS-RHS = 16 * WS-NUM * WS-NUM
             IF (WS-LXX = 0 AND WS-LZZ = 0) OR WS-LHSD <= WS-RHS
                 MOVE 1 TO WS-DOWN
                 IF WS-AXX = WS-RAD OR WS-AZZ = WS-RAD
                     CALL "WGR-NEXT" USING XR2-STATE WS-BITS24 WS-KW
                     IF WS-KW > 12582912
                         MOVE 0 TO WS-DOWN
                     END-IF
                 END-IF
                 IF WS-DOWN = 1
                     COMPUTE WS-QX = WS-LX + WS-LXX
                     COMPUTE WS-QY = WS-MPY + WS-YY
                     COMPUTE WS-QZ = WS-LZ + WS-LZZ
                     PERFORM AIR-OR-REPLACE
                     IF WS-OK-W = 1
                         PERFORM PUT-M
                     END-IF
                     IF WS-YY NOT = 0 AND WS-RAD > 1
                         COMPUTE WS-QY = WS-MPY - WS-YY
                         PERFORM AIR-OR-REPLACE
                         IF WS-OK-W = 1
                             PERFORM PUT-M
                         END-IF
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     .
*> MODEL-COLUMN: the pillar base column of offset (WS-QX, WS-QZ) (the offsets are copied first: the shadow paragraphs use the same fields)
 MODEL-COLUMN.
     MOVE WS-QX TO WS-CXX
     MOVE WS-QZ TO WS-CZZ
     MOVE 50 TO WS-N
     IF FUNCTION ABS(WS-CXX) = 1 AND FUNCTION ABS(WS-CZZ) = 1
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-B5 WS-N
     END-IF
     COMPUTE WS-CY = WS-MPY - 1
     MOVE 0 TO WS-STOP
     PERFORM UNTIL WS-CY <= 50 OR WS-STOP = 1
         COMPUTE WS-QX = WS-LX + WS-CXX
         MOVE WS-CY TO WS-QY
         COMPUTE WS-QZ = WS-LZ + WS-CZZ
         PERFORM AIR-OR-REPLACE
         IF WS-STATE = WS-S-PACKED
             MOVE 1 TO WS-OK-W
         END-IF
         IF WS-OK-W = 1
             PERFORM PUT-M
             SUBTRACT 1 FROM WS-CY
             SUBTRACT 1 FROM WS-N
             IF WS-N <= 0
                 CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-B5 WS-CH
                 COMPUTE WS-CY = WS-CY - WS-CH - 1
                 CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-B5 WS-N
             END-IF
         ELSE
             MOVE 1 TO WS-STOP
         END-IF
     END-PERFORM
     MOVE WS-CXX TO WS-QX
     MOVE WS-CZZ TO WS-QZ
     .
 COMPARE-WORLD.
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-QZ FROM 32 BY 1 UNTIL WS-QZ > 47
         PERFORM VARYING WS-QX FROM 16 BY 1 UNTIL WS-QX > 31
             PERFORM VARYING WS-QY FROM 40 BY 1 UNTIL WS-QY > 160
                 COMPUTE WS-MIDX = (WS-QY - 40) * 256 + (WS-QZ - 32) * 16 + (WS-QX - 16) + 1
                 CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
                 IF WS-STATE NOT = WS-OS(WS-MIDX)
                     ADD 1 TO WS-BAD
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     ADD 1 TO WS-PLACED
     .
*> NEW-WORLD: chunk (1, 2): stone to y 50, snow_block 51 to 62, air above; both random sources seeded
 NEW-WORLD.
     SET ADDRESS OF WS-AREA TO WS-PTR
     MOVE LOW-VALUES TO WS-AREA
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     MOVE 16 TO WS-X0
     MOVE 31 TO WS-X1
     MOVE 32 TO WS-Z0
     MOVE 47 TO WS-Z1
     MOVE 30 TO WS-Y0
     MOVE 50 TO WS-Y1
     MOVE "stone" TO WS-KEY
     PERFORM FILL-BOX
     MOVE 51 TO WS-Y0
     MOVE 62 TO WS-Y1
     MOVE "snow_block" TO WS-KEY
     PERFORM FILL-BOX
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
     .
 COPY FWTEST.
 END PROGRAM TEST-FEAT-35-5-16.
 COPY CORETEST.
