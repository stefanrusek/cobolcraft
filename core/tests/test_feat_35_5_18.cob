*> Implementation test of the bonus chest (docs/protocol/35-worldgen-features-5-water-and-surface.md section 18; core/src/feat-bonus.cob): the data feature compiles (type 5); the x values of the
*> chunk and then the z values are shuffled (Util.shuffle of the ints: 15 draws each); in that order the first column whose MOTION_BLOCKING_NO_LEAVES cell is air or has an empty collision shape
*> gets a chest, with a loot table request of chests/spawn_bonus_chest and the seed nextLong(), and a torch on each of its four horizontal neighbours with a full block below; compared with an
*> independent model over 12 worlds of leaves, short grass and air above a grass floor, plus a world whose every column is blocked (false after the 30 draws, nothing written).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-5-18.
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
 COPY GENBE.
 COPY XORO.
 COPY XORO REPLACING ==XR-STATE== BY ==XR2-STATE== LEADING ==XR-== BY ==X2-==.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/water".
 01 WS-PTR                 USAGE POINTER.
 01 WS-AREA                PIC X(304640) BASED.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
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
 01 WS-DRAW                BINARY-LONG.
 01 WS-SEEDNO              BINARY-LONG.
 01 WS-SEEDTXT             PIC 99.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-MIDX                BINARY-LONG.
 01 WS-SH.
    05 WS-OS               BINARY-LONG OCCURS 2048 TIMES.
 01 WS-S-STONE             BINARY-LONG.
 01 WS-S-GRASS             BINARY-LONG.
 01 WS-S-LEAVES            BINARY-LONG.
 01 WS-S-SHORT             BINARY-LONG.
 01 WS-S-CHEST             BINARY-LONG.
 01 WS-S-TORCH             BINARY-LONG.
 01 WS-B-LEAVES            BINARY-LONG.
 01 WS-N-CHESTS            BINARY-LONG VALUE 0.
 01 WS-N-TORCHES           BINARY-LONG VALUE 0.
 01 WS-N-SHORT             BINARY-LONG VALUE 0.
 01 WS-MODEL-RESULT        BINARY-LONG.
 01 WS-DEAD                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
*> model state
 01 M-XS.
    05 M-XV                BINARY-LONG OCCURS 16 TIMES.
 01 M-ZS.
    05 M-ZV                BINARY-LONG OCCURS 16 TIMES.
 01 M-I                    BINARY-LONG.
 01 M-J                    BINARY-LONG.
 01 M-N                    BINARY-LONG.
 01 M-SWAP                 BINARY-LONG.
 01 M-DONE                 BINARY-LONG.
 01 M-X                    BINARY-LONG.
 01 M-Z                    BINARY-LONG.
 01 M-LONG                 BINARY-DOUBLE.
 01 M-ST                   BINARY-LONG.
 01 M-RX                   BINARY-LONG.
 01 M-RY                   BINARY-LONG.
 01 M-RZ                   BINARY-LONG.
 01 M-K                    BINARY-LONG.
 01 M-EXP-X                BINARY-LONG.
 01 M-EXP-Z                BINARY-LONG.
 01 M-EXP-SEED             BINARY-DOUBLE.
 01 M-DXS.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE -1.
 01 M-DX-TAB REDEFINES M-DXS.
    05 M-DX                BINARY-LONG OCCURS 4 TIMES.
 01 M-DZS.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
 01 M-DZ-TAB REDEFINES M-DZS.
    05 M-DZ                BINARY-LONG OCCURS 4 TIMES.
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
     MOVE "grass_block" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-GRASS
     MOVE "oak_leaves" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-LEAVES
     MOVE "short_grass" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-SHORT
     MOVE "chest" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-CHEST
     MOVE "torch" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-TORCH
     MOVE "minecraft:bonus_t" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-5§18: the data feature compiles as a bonus_chest (5)" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE 5 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-5§18: the block table has the blocks of the test" TO WS-CASE
     MOVE 1 TO WS-OBS
     IF WS-S-CHEST = 0 OR WS-S-TORCH = 0 OR WS-S-LEAVES = 0 OR WS-S-SHORT = 0
         MOVE 0 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

     PERFORM VARYING WS-SEEDNO FROM 1 BY 1 UNTIL WS-SEEDNO > 13
         COMPUTE WS-SEED = WS-SEEDNO * 8101
         MOVE WS-SEEDNO TO WS-SEEDTXT
         MOVE 0 TO WS-DEAD
         IF WS-SEEDNO = 13
             MOVE 1 TO WS-DEAD
         END-IF
         PERFORM NEW-WORLD
         MOVE 24 TO WS-X
         MOVE 64 TO WS-Y
         MOVE 40 TO WS-Z
         PERFORM SAVE-WORLD
         PERFORM MODEL-RUN
         MOVE 0 TO GBL-COUNT
         CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
         PERFORM COMPARE-WORLD
         MOVE SPACES TO WS-CASE
         STRING "35-5§18: world " WS-SEEDTXT " the cells equal the model" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-BAD TO WS-OBS
         MOVE 0 TO WS-EXP
         PERFORM ASSERT-N
         MOVE SPACES TO WS-CASE
         STRING "35-5§18: world " WS-SEEDTXT " the result and the random state equal the model's" DELIMITED BY SIZE INTO WS-CASE
         MOVE 1000 TO WS-DRAW
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-DRAW WS-OBS
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-DRAW WS-EXP
         COMPUTE WS-OBS = WS-RESULT * 1000 + WS-OBS
         COMPUTE WS-EXP = WS-MODEL-RESULT * 1000 + WS-EXP
         PERFORM ASSERT-N
         MOVE SPACES TO WS-CASE
         STRING "35-5§18: world " WS-SEEDTXT " the loot request is the model's" DELIMITED BY SIZE INTO WS-CASE
         IF WS-MODEL-RESULT = 1
             MOVE 0 TO WS-OBS
             IF GBL-COUNT = 1 AND GBL-KIND(1) = 1 AND GBL-X(1) = M-EXP-X AND GBL-Y(1) = 64 AND GBL-Z(1) = M-EXP-Z
                 AND GBL-SEED(1) = M-EXP-SEED AND GBL-LOOT(1) = "minecraft:chests/spawn_bonus_chest"
                 MOVE 1 TO WS-OBS
             END-IF
         ELSE
             MOVE GBL-COUNT TO WS-OBS
             ADD 1 TO WS-OBS
         END-IF
         MOVE 1 TO WS-EXP
         PERFORM ASSERT-N
     END-PERFORM
     MOVE "35-5§18: chests were placed" TO WS-CASE
     MOVE WS-N-CHESTS TO WS-OBS
     MOVE 12 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-5§18: torches were placed" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-N-TORCHES > 10
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-5§18: a short grass cell took a chest in some world" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-N-SHORT > 0
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM ASSERT-N
     MOVE 1 TO FI-GATE
     MOVE "minecraft:bonus_chest" TO WS-FTKEY
     CALL "FR-GATE" USING WS-FTKEY WS-COUNT
     MOVE "35-5§18: the gate does not admit a bonus_chest placed feature (no biome lists one)" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     STOP RUN
     .
 SAVE-WORLD.
     PERFORM VARYING WS-QZ FROM 32 BY 1 UNTIL WS-QZ > 47
         PERFORM VARYING WS-QX FROM 16 BY 1 UNTIL WS-QX > 31
             PERFORM VARYING WS-QY FROM 62 BY 1 UNTIL WS-QY > 69
                 COMPUTE WS-MIDX = (WS-QY - 62) * 256 + (WS-QZ - 32) * 16 + (WS-QX - 16) + 1
                 CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
                 MOVE WS-STATE TO WS-OS(WS-MIDX)
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
 COMPARE-WORLD.
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-QZ FROM 32 BY 1 UNTIL WS-QZ > 47
         PERFORM VARYING WS-QX FROM 16 BY 1 UNTIL WS-QX > 31
             PERFORM VARYING WS-QY FROM 62 BY 1 UNTIL WS-QY > 69
                 COMPUTE WS-MIDX = (WS-QY - 62) * 256 + (WS-QZ - 32) * 16 + (WS-QX - 16) + 1
                 CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
                 IF WS-STATE NOT = WS-OS(WS-MIDX)
                     ADD 1 TO WS-BAD
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
*> NEW-WORLD: chunk (1, 2): stone to y 62, grass_block at 63; at y 64 oak_leaves over three columns in four, short_grass over one in eight of the rest (WS-DEAD 1: leaves everywhere); both random sources seeded
 NEW-WORLD.
     SET ADDRESS OF WS-AREA TO WS-PTR
     MOVE LOW-VALUES TO WS-AREA
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     PERFORM VARYING WS-X FROM 16 BY 1 UNTIL WS-X > 31
         PERFORM VARYING WS-Z FROM 32 BY 1 UNTIL WS-Z > 47
             PERFORM VARYING WS-Y FROM 40 BY 1 UNTIL WS-Y > 62
                 CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-S-STONE WS-FLAGS WS-OK
             END-PERFORM
             MOVE 63 TO WS-Y
             CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-S-GRASS WS-FLAGS WS-OK
             MOVE 64 TO WS-Y
             COMPUTE WS-K = FUNCTION MOD(WS-X * 7 + WS-Z * 3 + WS-SEEDNO, 8)
             EVALUATE TRUE
                 WHEN WS-DEAD = 1
                     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-S-LEAVES WS-FLAGS WS-OK
                 WHEN WS-K < 6
                     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-S-LEAVES WS-FLAGS WS-OK
                 WHEN WS-K = 6
                     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-S-SHORT WS-FLAGS WS-OK
             END-EVALUATE
         END-PERFORM
     END-PERFORM
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
     .
*> ---- the model
 M-GET.
     MOVE 0 TO M-ST
     IF M-RX >= 16 AND M-RX <= 31 AND M-RZ >= 32 AND M-RZ <= 47 AND M-RY >= 62 AND M-RY <= 69
         COMPUTE WS-MIDX = (M-RY - 62) * 256 + (M-RZ - 32) * 16 + (M-RX - 16) + 1
         MOVE WS-OS(WS-MIDX) TO M-ST
     END-IF
     .
 M-PUT.
     IF M-RX >= 16 AND M-RX <= 31 AND M-RZ >= 32 AND M-RZ <= 47 AND M-RY >= 62 AND M-RY <= 69
         COMPUTE WS-MIDX = (M-RY - 62) * 256 + (M-RZ - 32) * 16 + (M-RX - 16) + 1
         MOVE M-ST TO WS-OS(WS-MIDX)
     END-IF
     .
 MODEL-RUN.
     MOVE 0 TO WS-MODEL-RESULT
     PERFORM VARYING M-I FROM 1 BY 1 UNTIL M-I > 16
         COMPUTE M-XV(M-I) = 15 + M-I
         COMPUTE M-ZV(M-I) = 31 + M-I
     END-PERFORM
     MOVE 16 TO M-N
     PERFORM UNTIL M-N < 2
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-N M-J
         MOVE M-XV(M-N) TO M-SWAP
         MOVE M-XV(M-J + 1) TO M-XV(M-N)
         MOVE M-SWAP TO M-XV(M-J + 1)
         SUBTRACT 1 FROM M-N
     END-PERFORM
     MOVE 16 TO M-N
     PERFORM UNTIL M-N < 2
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-N M-J
         MOVE M-ZV(M-N) TO M-SWAP
         MOVE M-ZV(M-J + 1) TO M-ZV(M-N)
         MOVE M-SWAP TO M-ZV(M-J + 1)
         SUBTRACT 1 FROM M-N
     END-PERFORM
     MOVE 0 TO M-DONE
     PERFORM VARYING M-I FROM 1 BY 1 UNTIL M-I > 16 OR M-DONE = 1
         PERFORM VARYING M-J FROM 1 BY 1 UNTIL M-J > 16 OR M-DONE = 1
             MOVE M-XV(M-I) TO M-X
             MOVE M-ZV(M-J) TO M-Z
*>           the world's top solid block is the grass at 63, so the MOTION_BLOCKING_NO_LEAVES cell is y 64
             MOVE M-X TO M-RX
             MOVE M-Z TO M-RZ
             MOVE 64 TO M-RY
             PERFORM M-GET
             IF M-ST = 0 OR M-ST = WS-S-SHORT
                 MOVE 1 TO M-DONE
                 IF M-ST = WS-S-SHORT
                     ADD 1 TO WS-N-SHORT
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     IF M-DONE = 0
         EXIT PARAGRAPH
     END-IF
     MOVE 1 TO WS-MODEL-RESULT
     MOVE M-XV(M-I - 1) TO M-X
     MOVE M-ZV(M-J - 1) TO M-Z
     MOVE M-X TO M-EXP-X
     MOVE M-Z TO M-EXP-Z
     MOVE M-X TO M-RX
     MOVE M-Z TO M-RZ
     MOVE 64 TO M-RY
     MOVE WS-S-CHEST TO M-ST
     PERFORM M-PUT
     ADD 1 TO WS-N-CHESTS
     CALL "F351-NEXT-LONG" USING XR2-STATE M-LONG
     MOVE M-LONG TO M-EXP-SEED
     PERFORM VARYING M-K FROM 1 BY 1 UNTIL M-K > 4
         COMPUTE M-RX = M-X + M-DX(M-K)
         COMPUTE M-RZ = M-Z + M-DZ(M-K)
*>       a torch stands where the block below (grass, a full block; outside the chunk nothing) carries it
         COMPUTE M-RY = 63
         PERFORM M-GET
         IF M-ST = WS-S-GRASS
             MOVE 64 TO M-RY
             MOVE WS-S-TORCH TO M-ST
             PERFORM M-PUT
             IF M-RX >= 16 AND M-RX <= 31 AND M-RZ >= 32 AND M-RZ <= 47
                 ADD 1 TO WS-N-TORCHES
             END-IF
         END-IF
     END-PERFORM
     .
 COPY FWTEST.
 END PROGRAM TEST-FEAT-35-5-18.
 COPY CORETEST.
