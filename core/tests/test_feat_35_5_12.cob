*> Implementation test of block pile (docs/protocol/35-worldgen-features-5-water-and-surface.md section 12; core/src/feat-pile.cob): the data features compile (type 3; a missing state_provider, a rotated
*> provider (not compiled) and a full feature table make the feature unsupported); y below minY + 5 gives false without a draw; otherwise a = 2 + nextInt(2), b = 2 + nextInt(2), and over
*> betweenClosed(pos + (-a, 0, -b), pos + (a, 1, b)) (x fastest, z slowest) a cell takes the provider state when the squared horizontal distance d <= t, t = nextFloat() * 10f - nextFloat() * 6f in float32
*> (the model rounds the integer products to 24 bits by hand), or else when a third draw nextFloat() < 0.031, and the cell is air with a block below that is a full face (nextBoolean for dirt_path);
*> compared with an independent model with a second random source.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-5-12.
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

 01 WS-K                   BINARY-LONG.
 01 WS-PLACED              BINARY-LONG VALUE 0.
 01 WS-PLACED-NOW          BINARY-LONG.
 01 WS-FT2                 BINARY-LONG.
 01 WS-MIDX                BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-KU                  BINARY-DOUBLE.
 01 WS-KV                  BINARY-DOUBLE.
 01 WS-KW                  BINARY-DOUBLE.
 01 WS-V                   BINARY-DOUBLE.
 01 WS-AV                  BINARY-DOUBLE.
 01 WS-P                   BINARY-DOUBLE.
 01 WS-Q                   BINARY-DOUBLE.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-T24                 BINARY-DOUBLE.
 01 WS-D24                 BINARY-DOUBLE.
 01 WS-BITS24              BINARY-LONG VALUE 24.
 01 WS-LIM24               BINARY-DOUBLE VALUE 16777216.
 01 WS-TRY                 BINARY-LONG.
 01 WS-OK-PLACE            BINARY-LONG.
 01 WS-MODEL-RESULT        BINARY-LONG.
 01 WS-B-AIR               BINARY-LONG.
 01 WS-B-MELON             BINARY-LONG.
 01 WS-B-PATH              BINARY-LONG.
 01 WS-S-MELON             BINARY-LONG.
 01 WS-S-HAY-X             BINARY-LONG.
 01 WS-S-HAY-Y             BINARY-LONG.
 01 WS-S-HAY-Z             BINARY-LONG.
 01 WS-FT-MELON            BINARY-LONG.
 01 WS-FT-HAY              BINARY-LONG.
 01 WS-CUR                 BINARY-LONG.
 01 WS-HAY                 BINARY-LONG VALUE 0.
 01 WS-HDIR                BINARY-LONG.
 01 WS-B6                  BINARY-LONG VALUE 6.
 01 WS-N-DIRS              BINARY-LONG VALUE 0.
 01 WS-BELOW-B             BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-XLO                 BINARY-LONG.
 01 WS-ZLO                 BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-BOOL                BINARY-LONG.
 01 WS-BITS1               BINARY-LONG VALUE 1.
 01 WS-BOOLD               BINARY-DOUBLE.
 01 WS-CASE2               PIC X(8).
 01 WS-SAVE-TABLE.
    05 WS-OS               BINARY-LONG OCCURS 1024 TIMES.
 01 WS-B2                  BINARY-LONG VALUE 2.
 01 WS-I                   BINARY-LONG.
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
     MOVE "melon" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-MELON
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-MELON
     MOVE "dirt_path" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-PATH
     MOVE "minecraft:pile_melon" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-5§12: the data feature pile_melon compiles as a block_pile (3)" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE 3 TO WS-EXP
     PERFORM ASSERT-N
     MOVE WS-FT TO WS-FT-MELON
     MOVE "hay_block" TO WS-KEY
     MOVE "axis=x" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-S-HAY-X
     MOVE "axis=y" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-S-HAY-Y
     MOVE "axis=z" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-S-HAY-Z
     MOVE "minecraft:pile_hay" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT-HAY
     CALL "FD-ENSURE-FT" USING WS-FT-HAY
     MOVE "35-5§12: pile_hay (a rotated provider without a direction) compiles as a block_pile (3)" TO WS-CASE
     MOVE FT-TYPE(WS-FT-HAY) TO WS-OBS
     MOVE 3 TO WS-EXP
     PERFORM ASSERT-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE SPACES TO WS-FTKEY
         EVALUATE WS-I
             WHEN 1
                 MOVE "minecraft:pile_hay_down" TO WS-FTKEY
             WHEN 2
                 MOVE "minecraft:pile_hay_up" TO WS-FTKEY
             WHEN 3
                 MOVE "minecraft:pile_hay_north" TO WS-FTKEY
             WHEN 4
                 MOVE "minecraft:pile_hay_south" TO WS-FTKEY
             WHEN 5
                 MOVE "minecraft:pile_hay_west" TO WS-FTKEY
             WHEN OTHER
                 MOVE "minecraft:pile_hay_east" TO WS-FTKEY
         END-EVALUATE
         CALL "FD-GET-FT" USING WS-FTKEY WS-FT2
         CALL "FD-ENSURE-FT" USING WS-FT2
         MOVE SPACES TO WS-CASE
         STRING "35-5§12: a rotated provider with the direction " WS-FTKEY(11:20) " compiles" DELIMITED BY SIZE INTO WS-CASE
         MOVE FT-TYPE(WS-FT2) TO WS-OBS
         MOVE 3 TO WS-EXP
         PERFORM ASSERT-N
     END-PERFORM
     MOVE "minecraft:pile_hay_bad" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT2
     CALL "FD-ENSURE-FT" USING WS-FT2
     MOVE "35-5§12: a rotated provider with an unknown direction is unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT2) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:pile_pumpkin" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT2
     CALL "FD-ENSURE-FT" USING WS-FT2
     MOVE "35-5§12: pile_pumpkin (a weighted provider) compiles too" TO WS-CASE
     MOVE FT-TYPE(WS-FT2) TO WS-OBS
     MOVE 3 TO WS-EXP
     PERFORM ASSERT-N

     PERFORM VARYING WS-SEEDNO FROM 1 BY 1 UNTIL WS-SEEDNO > 24
         COMPUTE WS-SEED = WS-SEEDNO * 3571
         MOVE WS-SEEDNO TO WS-SEEDTXT
         IF WS-SEEDNO > 12
             MOVE 1 TO WS-HAY
             MOVE WS-FT-HAY TO WS-CUR
         ELSE
             MOVE 0 TO WS-HAY
             MOVE WS-FT-MELON TO WS-CUR
         END-IF
         PERFORM NEW-WORLD
         MOVE 24 TO WS-X
         MOVE 64 TO WS-Y
         MOVE 40 TO WS-Z
         PERFORM SAVE-WORLD
         PERFORM MODEL-RUN
         CALL "FR-PLACE-FT" USING XR-STATE WS-CUR WS-X WS-Y WS-Z WS-RESULT
         PERFORM COMPARE-WORLD
         MOVE SPACES TO WS-CASE
         STRING "35-5§12: seed " WS-SEEDTXT " the cells equal the model" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-BAD TO WS-OBS
         MOVE 0 TO WS-EXP
         PERFORM ASSERT-N
         MOVE SPACES TO WS-CASE
         STRING "35-5§12: seed " WS-SEEDTXT " the result and the random state equal the model's" DELIMITED BY SIZE INTO WS-CASE
         MOVE 1000 TO WS-DRAW
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-DRAW WS-OBS
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-DRAW WS-EXP
         COMPUTE WS-OBS = WS-RESULT * 1000 + WS-OBS
         COMPUTE WS-EXP = WS-MODEL-RESULT * 1000 + WS-EXP
         PERFORM ASSERT-N
         ADD WS-PLACED-NOW TO WS-PLACED
     END-PERFORM
     MOVE "35-5§12: the 24 piles placed more than 120 blocks in all" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-PLACED > 120
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   y below minY + 5: false, no draw
     PERFORM NEW-WORLD
     MOVE 24 TO WS-X
     MOVE -60 TO WS-Y
     MOVE 40 TO WS-Z
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-5§12: y below minY + 5 gives false" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 1000 TO WS-DRAW
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-DRAW WS-OBS
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-DRAW WS-EXP
     MOVE "35-5§12: and makes no draw" TO WS-CASE
     PERFORM ASSERT-N

     MOVE "35-5§12: the hay piles drew a direction for every cell" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-N-DIRS > 60
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:pile_noprov" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-5§12: a missing state_provider makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE FD-WA-COUNT TO WS-COUNT
     MOVE FD-MAX-WA TO FD-WA-COUNT
     MOVE "minecraft:pile_full" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE WS-COUNT TO FD-WA-COUNT
     MOVE "35-5§12: a full feature table makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 1 TO FI-GATE
     MOVE "minecraft:pile_melon" TO WS-FTKEY
     CALL "FR-GATE" USING WS-FTKEY WS-COUNT
     MOVE "35-5§12: the gate admits the pile placed features" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     STOP RUN
     .
*> ROUND24: WS-V rounded to 24 significant bits, half to even (the float32 of an integer)
 ROUND24.
     COMPUTE WS-AV = FUNCTION ABS(WS-V)
     MOVE 1 TO WS-P
     PERFORM UNTIL WS-AV < WS-LIM24 * WS-P
         COMPUTE WS-P = WS-P * 2
     END-PERFORM
     IF WS-P > 1
         DIVIDE WS-AV BY WS-P GIVING WS-Q REMAINDER WS-R
         COMPUTE WS-AV = WS-AV
         MOVE WS-AV TO WS-Q
         COMPUTE WS-Q = WS-AV / WS-P
         COMPUTE WS-R = WS-AV - WS-Q * WS-P
         IF WS-R * 2 > WS-P OR (WS-R * 2 = WS-P AND FUNCTION MOD(WS-Q, 2) = 1)
             ADD 1 TO WS-Q
         END-IF
         COMPUTE WS-AV = WS-Q * WS-P
     END-IF
     IF WS-V < 0
         COMPUTE WS-V = 0 - WS-AV
     ELSE
         MOVE WS-AV TO WS-V
     END-IF
     .
 SAVE-WORLD.
     PERFORM VARYING WS-QZ FROM 32 BY 1 UNTIL WS-QZ > 47
         PERFORM VARYING WS-QX FROM 16 BY 1 UNTIL WS-QX > 31
             PERFORM VARYING WS-QY FROM 63 BY 1 UNTIL WS-QY > 66
                 COMPUTE WS-MIDX = (WS-QY - 63) * 256 + (WS-QZ - 32) * 16 + (WS-QX - 16) + 1
                 CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
                 MOVE WS-STATE TO WS-OS(WS-MIDX)
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
*> MODEL-RUN: on the saved states (y 63 to 66, 1024 entries: 4 layers x 256); the placed cells are marked in WS-OS as the melon state; WS-PLACED-NOW counts them
 MODEL-RUN.
     MOVE 0 TO WS-MODEL-RESULT WS-PLACED-NOW
     IF WS-Y < -59
         EXIT PARAGRAPH
     END-IF
     MOVE 1 TO WS-MODEL-RESULT
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-B2 WS-A
     ADD 2 TO WS-A
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-B2 WS-B
     ADD 2 TO WS-B
     COMPUTE WS-XLO = WS-X - WS-A
     COMPUTE WS-ZLO = WS-Z - WS-B
     PERFORM VARYING WS-QZ FROM WS-ZLO BY 1 UNTIL WS-QZ > WS-Z + WS-B
         PERFORM VARYING WS-QY FROM WS-Y BY 1 UNTIL WS-QY > WS-Y + 1
             PERFORM VARYING WS-QX FROM WS-XLO BY 1 UNTIL WS-QX > WS-X + WS-A
                 COMPUTE WS-D = (WS-X - WS-QX) * (WS-X - WS-QX) + (WS-Z - WS-QZ) * (WS-Z - WS-QZ)
                 CALL "WGR-NEXT" USING XR2-STATE WS-BITS24 WS-KU
                 CALL "WGR-NEXT" USING XR2-STATE WS-BITS24 WS-KV
                 COMPUTE WS-V = WS-KU * 10
                 PERFORM ROUND24
                 MOVE WS-V TO WS-T24
                 COMPUTE WS-V = WS-KV * 6
                 PERFORM ROUND24
                 COMPUTE WS-V = WS-T24 - WS-V
                 PERFORM ROUND24
                 COMPUTE WS-D24 = WS-D * WS-LIM24
                 MOVE 0 TO WS-TRY
                 IF WS-D24 <= WS-V
                     MOVE 1 TO WS-TRY
                 ELSE
                     CALL "WGR-NEXT" USING XR2-STATE WS-BITS24 WS-KW
                     IF WS-KW <= 520093
                         MOVE 1 TO WS-TRY
                     END-IF
                 END-IF
                 IF WS-TRY = 1
                     PERFORM MODEL-TRY
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
 MODEL-TRY.
     COMPUTE WS-MIDX = (WS-QY - 63) * 256 + (WS-QZ - 32) * 16 + (WS-QX - 16) + 1
     IF WS-OS(WS-MIDX) = 0
         COMPUTE WS-MIDX = (WS-QY - 1 - 63) * 256 + (WS-QZ - 32) * 16 + (WS-QX - 16) + 1
         MOVE WS-OS(WS-MIDX) TO WS-STATE
         CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
         MOVE 0 TO WS-OK-PLACE
         IF WS-BLOCK = WS-B-PATH
             CALL "WGR-NEXT" USING XR2-STATE WS-BITS1 WS-BOOLD
             MOVE WS-BOOLD TO WS-OK-PLACE
         ELSE
             IF WS-BLOCK > 0
                 MOVE CB-OPAQUE(WS-BLOCK) TO WS-OK-PLACE
             END-IF
         END-IF
         IF WS-OK-PLACE = 1
             COMPUTE WS-MIDX = (WS-QY - 63) * 256 + (WS-QZ - 32) * 16 + (WS-QX - 16) + 1
             MOVE WS-S-MELON TO WS-OS(WS-MIDX)
             IF WS-HAY = 1
*>               the rotated provider: nextInt(6) is the direction (down, up, north, south, west, east), its axis the hay's
                 CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-B6 WS-HDIR
                 EVALUATE WS-HDIR
                     WHEN 0
                     WHEN 1
                         MOVE WS-S-HAY-Y TO WS-OS(WS-MIDX)
                     WHEN 2
                     WHEN 3
                         MOVE WS-S-HAY-Z TO WS-OS(WS-MIDX)
                     WHEN OTHER
                         MOVE WS-S-HAY-X TO WS-OS(WS-MIDX)
                 END-EVALUATE
                 ADD 1 TO WS-N-DIRS
             END-IF
             ADD 1 TO WS-PLACED-NOW
         END-IF
     END-IF
     .
 COMPARE-WORLD.
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-QZ FROM 32 BY 1 UNTIL WS-QZ > 47
         PERFORM VARYING WS-QX FROM 16 BY 1 UNTIL WS-QX > 31
             PERFORM VARYING WS-QY FROM 63 BY 1 UNTIL WS-QY > 66
                 COMPUTE WS-MIDX = (WS-QY - 63) * 256 + (WS-QZ - 32) * 16 + (WS-QX - 16) + 1
                 CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
                 IF WS-STATE NOT = WS-OS(WS-MIDX)
                     ADD 1 TO WS-BAD
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
*> NEW-WORLD: chunk (1, 2): stone to y 62, grass_block at 63 with dirt_path at (24, 63, 40), (25, 63, 41), (23, 63, 39) and (26, 63, 40), air above; both random sources seeded
 NEW-WORLD.
     SET ADDRESS OF WS-AREA TO WS-PTR
     MOVE LOW-VALUES TO WS-AREA
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     MOVE 16 TO WS-X0
     MOVE 31 TO WS-X1
     MOVE 32 TO WS-Z0
     MOVE 47 TO WS-Z1
     MOVE 30 TO WS-Y0
     MOVE 62 TO WS-Y1
     MOVE "stone" TO WS-KEY
     PERFORM FILL-BOX
     MOVE 63 TO WS-Y0
     MOVE 63 TO WS-Y1
     MOVE "grass_block" TO WS-KEY
     PERFORM FILL-BOX
     MOVE 63 TO WS-Y
     MOVE "dirt_path" TO WS-KEY
     MOVE 24 TO WS-X
     MOVE 40 TO WS-Z
     PERFORM PUT-AT
     MOVE 25 TO WS-X
     MOVE 41 TO WS-Z
     PERFORM PUT-AT
     MOVE 23 TO WS-X
     MOVE 39 TO WS-Z
     PERFORM PUT-AT
     MOVE 26 TO WS-X
     MOVE 40 TO WS-Z
     PERFORM PUT-AT
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
     .
 COPY FWTEST.
 END PROGRAM TEST-FEAT-35-5-12.
 COPY NOSPAWN.
 COPY CORETEST.
