*> Real-data test of the coverage audit's ore gap (docs/protocol/35-worldgen-features-7-nether-end-misc.md section 12; 35-1 section 13; 37-nether-5 section 6; T1292, T1293): the generic ore (type 31) and
*> scattered_ore (type 39) are compiled from the real placed-feature data of the Nether (ore_magma, ore_gravel_nether, ore_blackstone, ore_soul_sand, ore_gold_nether, ore_quartz_nether,
*> ore_ancient_debris_large, ore_debris_small: every one is a supported placed feature whose configured feature is of the right type), and a Nether area of a fixed seed (the 3 x 3 chunks
*> around chunk (1, 4) of seed 12345) holds the documented ores after the decoration: cells that the terrain made netherrack are now nether gold ore, nether quartz ore, magma block, gravel,
*> blackstone and ancient debris, inside the heights the documents give (the origin range of the placed feature, minus the blob's reach); no ancient debris touches air (chance 1.0, 35-1 13.1).
*> Needs the generated packs (CC_GENERATED_DIR, default /tmp/cc-test/generated): a pass without them.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-7-12.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CELLS.
 COPY CBLOCKS.
 COPY CELLS REPLACING LEADING ==CE-== BY ==TE-==.
 COPY FEATDATA.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-DIM                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-MARKER              BINARY-LONG.
 01 WS-PLACED              BINARY-LONG.
 01 WS-TERRAIN             PIC X(304640).
 01 WS-FINAL               PIC X(304640).
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 01 WS-NB                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-NAME                PIC X(48).
 01 WS-PFKEY               PIC X(80).
 01 WS-PF                  BINARY-LONG.
 01 WS-FT                  BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-EXP                 BINARY-LONG.
 01 WS-CASE                PIC X(200).
 01 WS-S-ROCK              BINARY-LONG.
 01 WS-ORE-KEYS.
    05 FILLER              PIC X(24) VALUE "nether_gold_ore".
    05 FILLER              PIC X(24) VALUE "nether_quartz_ore".
    05 FILLER              PIC X(24) VALUE "magma_block".
    05 FILLER              PIC X(24) VALUE "gravel".
    05 FILLER              PIC X(24) VALUE "blackstone".
    05 FILLER              PIC X(24) VALUE "ancient_debris".
 01 WS-ORE-TABLE REDEFINES WS-ORE-KEYS.
    05 WS-ORE-KEY          PIC X(24) OCCURS 6 TIMES.
*> per ore: the lowest and highest y a placed cell may have (the origin range of the placed feature widened by the blob's reach: 11 section 7.1: two below, the ball radius above and below; scattered_ore: the spread 7)
 01 WS-ORE-LO-TABLE.
    05 FILLER              BINARY-LONG VALUE 5.
    05 FILLER              BINARY-LONG VALUE 5.
    05 FILLER              BINARY-LONG VALUE 22.
    05 FILLER              BINARY-LONG VALUE 2.
    05 FILLER              BINARY-LONG VALUE 2.
    05 FILLER              BINARY-LONG VALUE 1.
 01 WS-ORE-LO REDEFINES WS-ORE-LO-TABLE.
    05 WS-LO               BINARY-LONG OCCURS 6 TIMES.
 01 WS-ORE-HI-TABLE.
    05 FILLER              BINARY-LONG VALUE 121.
    05 FILLER              BINARY-LONG VALUE 121.
    05 FILLER              BINARY-LONG VALUE 39.
    05 FILLER              BINARY-LONG VALUE 46.
    05 FILLER              BINARY-LONG VALUE 36.
    05 FILLER              BINARY-LONG VALUE 126.
 01 WS-ORE-HI REDEFINES WS-ORE-HI-TABLE.
    05 WS-HI               BINARY-LONG OCCURS 6 TIMES.
 01 WS-ORE-STATE           BINARY-LONG OCCURS 6 TIMES.
 01 WS-ORE-COUNT           BINARY-LONG OCCURS 6 TIMES.
 01 WS-ORE-OUT             BINARY-LONG OCCURS 6 TIMES.
 01 WS-EXPOSED-DEBRIS      BINARY-LONG.
 01 WS-SHOW                PIC -(9)9.
 01 WS-K                   BINARY-LONG.
 01 WS-AIR-AT              BINARY-LONG.
 01 WS-S-AIR               BINARY-LONG.
 01 WS-S-CAVE              BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "N" TO TL-MODE
         MOVE "test feat 35-7 12 no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 1 TO CS-EXTRA-DIMENSIONS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE DIM-STANDARD-NETHER TO WS-DIM
     MOVE 12345 TO CW-SEED
     MOVE "N" TO TL-MODE

*>   the placed features of the data: supported, and their configured features are of the types 31 and 39
     MOVE "ore_magma" TO WS-PFKEY
     MOVE 31 TO WS-EXP
     PERFORM CHECK-PF
     MOVE "ore_gravel_nether" TO WS-PFKEY
     MOVE 31 TO WS-EXP
     PERFORM CHECK-PF
     MOVE "ore_blackstone" TO WS-PFKEY
     MOVE 31 TO WS-EXP
     PERFORM CHECK-PF
     MOVE "ore_soul_sand" TO WS-PFKEY
     MOVE 31 TO WS-EXP
     PERFORM CHECK-PF
     MOVE "ore_gold_nether" TO WS-PFKEY
     MOVE 31 TO WS-EXP
     PERFORM CHECK-PF
     MOVE "ore_quartz_nether" TO WS-PFKEY
     MOVE 31 TO WS-EXP
     PERFORM CHECK-PF
     MOVE "ore_ancient_debris_large" TO WS-PFKEY
     MOVE 39 TO WS-EXP
     PERFORM CHECK-PF
     MOVE "ore_debris_small" TO WS-PFKEY
     MOVE 39 TO WS-EXP
     PERFORM CHECK-PF

*>   the ore blocks of the table and the rock they replace
     MOVE "netherrack" TO WS-NAME
     CALL "FD-BLOCK-INDEX" USING WS-NAME WS-WANT
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-ROCK
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
         MOVE WS-ORE-KEY(WS-K) TO WS-NAME
         CALL "FD-BLOCK-INDEX" USING WS-NAME WS-WANT
         MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-ORE-STATE(WS-K)
         MOVE 0 TO WS-ORE-COUNT(WS-K) WS-ORE-OUT(WS-K)
     END-PERFORM
     MOVE 0 TO WS-EXPOSED-DEBRIS
     MOVE "air" TO WS-NAME
     CALL "FD-BLOCK-INDEX" USING WS-NAME WS-WANT
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-AIR
     MOVE "cave_air" TO WS-NAME
     CALL "FD-BLOCK-INDEX" USING WS-NAME WS-WANT
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-CAVE

*>   the area: terrain, then the decoration of NETHER-GEN-FEATURES on a copy
     PERFORM VARYING WS-CZ FROM 3 BY 1 UNTIL WS-CZ > 5
         PERFORM VARYING WS-CX FROM 0 BY 1 UNTIL WS-CX > 2
             MOVE LOW-VALUES TO WS-TERRAIN
             CALL "NETHER-GEN-CHUNK" USING CW-SEED WS-CX WS-CZ WS-TERRAIN WS-MARKER
             MOVE WS-TERRAIN TO WS-FINAL
             CALL "NETHER-GEN-FEATURES" USING CW-SEED WS-CX WS-CZ WS-FINAL WS-PLACED
             PERFORM SCAN-CHUNK
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
         MOVE WS-ORE-COUNT(WS-K) TO WS-SHOW
         DISPLAY "ore " FUNCTION TRIM(WS-ORE-KEY(WS-K)) " cells from netherrack: " FUNCTION TRIM(WS-SHOW)
     END-PERFORM
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
         MOVE SPACES TO WS-CASE
         STRING "35-7§12 the area holds " FUNCTION TRIM(WS-ORE-KEY(WS-K)) " made from netherrack by the decoration" DELIMITED BY SIZE INTO WS-CASE
         MOVE 0 TO WS-OBS
         IF WS-ORE-COUNT(WS-K) > 0
             MOVE 1 TO WS-OBS
         END-IF
         MOVE 1 TO WS-EXP
         PERFORM ASSERT-N
         MOVE SPACES TO WS-CASE
         STRING "37-5§6 no " FUNCTION TRIM(WS-ORE-KEY(WS-K)) " placed outside the heights its placed feature allows" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-ORE-OUT(WS-K) TO WS-OBS
         MOVE 0 TO WS-EXP
         PERFORM ASSERT-N
     END-PERFORM
     MOVE "35-1§13.1 no ancient debris placed by the decoration touches air (chance 1.0)" TO WS-CASE
     MOVE WS-EXPOSED-DEBRIS TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     STOP RUN.

*> CHECK-PF: the placed feature WS-PFKEY (no namespace) compiles (status 1) with a configured feature of the type WS-EXP; one case each
 CHECK-PF.
     MOVE SPACES TO WS-NAME
     STRING "minecraft:" FUNCTION TRIM(WS-PFKEY) DELIMITED BY SIZE INTO WS-NAME
     MOVE SPACES TO WS-CASE
     STRING "37-5§6 the placed feature " FUNCTION TRIM(WS-PFKEY) " compiles to a configured feature of the type 31 (ore) or 39 (scattered_ore)"
         DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-NAME TO WS-PFKEY
     CALL "FD-GET-PF" USING WS-PFKEY WS-PF
     CALL "FD-ENSURE-PF" USING WS-PF
     MOVE 0 TO WS-OBS
     IF PF-STATUS(WS-PF) = 1
         MOVE PF-FT(WS-PF) TO WS-FT
         CALL "FD-ENSURE-FT" USING WS-FT
         MOVE FT-TYPE(WS-FT) TO WS-OBS
     END-IF
     PERFORM ASSERT-N
     .

*> SCAN-CHUNK: for every cell that was netherrack in the terrain and holds one of the six ore blocks after the decoration: the count, the height test, the air test of the debris
 SCAN-CHUNK.
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF WS-FINAL
     SET ADDRESS OF TE-CHUNK TO ADDRESS OF WS-TERRAIN
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 127
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 15
             PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 15
                 COMPUTE WS-AT = WS-Y * 256 + WS-Z * 16 + WS-X + 1
                 IF TE-STATE(WS-AT) = WS-S-ROCK AND CE-STATE(WS-AT) NOT = WS-S-ROCK
                     PERFORM SCAN-CELL
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
 SCAN-CELL.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
         IF CE-STATE(WS-AT) = WS-ORE-STATE(WS-K)
             ADD 1 TO WS-ORE-COUNT(WS-K)
             IF WS-Y < WS-LO(WS-K) OR WS-Y > WS-HI(WS-K)
                 ADD 1 TO WS-ORE-OUT(WS-K)
             END-IF
             IF WS-K = 6
                 PERFORM SCAN-DEBRIS-AIR
             END-IF
         END-IF
     END-PERFORM
     .
*> SCAN-DEBRIS-AIR: counts the debris cell when a face neighbour inside the chunk's columns is air (state 0, or the cave air of the terrain)
 SCAN-DEBRIS-AIR.
     PERFORM VARYING WS-NB FROM 1 BY 1 UNTIL WS-NB > 6
         MOVE WS-X TO WS-NX
         MOVE WS-Y TO WS-NY
         MOVE WS-Z TO WS-NZ
         EVALUATE WS-NB
             WHEN 1
                 SUBTRACT 1 FROM WS-NX
             WHEN 2
                 ADD 1 TO WS-NX
             WHEN 3
                 SUBTRACT 1 FROM WS-NY
             WHEN 4
                 ADD 1 TO WS-NY
             WHEN 5
                 SUBTRACT 1 FROM WS-NZ
             WHEN OTHER
                 ADD 1 TO WS-NZ
         END-EVALUATE
         IF WS-NX >= 0 AND WS-NX <= 15 AND WS-NZ >= 0 AND WS-NZ <= 15 AND WS-NY >= 0 AND WS-NY <= 127
             COMPUTE WS-AIR-AT = WS-NY * 256 + WS-NZ * 16 + WS-NX + 1
             IF CE-STATE(WS-AIR-AT) = WS-S-AIR OR CE-STATE(WS-AIR-AT) = WS-S-CAVE
                 ADD 1 TO WS-EXPOSED-DEBRIS
             END-IF
         END-IF
     END-PERFORM
     .
 ASSERT-N.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-OBS TO TL-OBSERVED-N
     MOVE WS-EXP TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
 END PROGRAM TEST-FEAT-35-7-12.
 COPY NOSPAWN.
 COPY CORETEST.
