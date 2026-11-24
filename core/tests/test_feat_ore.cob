*> Implementation test of the generic ore feature (type 31, docs/protocol/11 section 7) and scattered_ore (type 39, docs/protocol/35-worldgen-features-1 section 13) as features of the
*> feature stage (core/src/feat-ore.cob, T1292, T1293): the data feature compiles its targets, size and discard chance (a missing size or chance, a size outside 0..64, a chance outside 0..1 or
*> a missing target list make it unsupported; an empty list is supported), the overworld ore placed features stay with the hard-coded ore pass (FR-GATE keeps them off), and on a window of the
*> real block table every feature of the fixtures runs from 16 seeds. An independent model of the document's text with its own random stream (the same seed) works on a copy of the window:
*> scattered_ore draws nextInt(size + 1), six floats per attempt, spread min(i, 7) and the offsets floor((a - b) * spread + 1/2) (computed in integers on the 24 bit float values); both types go
*> through the acceptance test of 11 section 7.3 (first accepting target writes; no draw for a chance of 0 or 1, one nextFloat per accepted rule otherwise; a face neighbour that is air
*> exposes the block; blocks outside the chunk's columns are not air and not writable). The blob's positions come from the blob geometry of the overworld pass (list mode). Every cell
*> of the window and the position of the random stream must agree with the model.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-ORE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATDATA.
 COPY FEATINDEX.
 COPY FEATLEVEL.
 COPY ORE.
 COPY XORO.
 COPY XORO REPLACING ==XR-STATE== BY ==XR2-STATE== LEADING ==XR-== BY ==X2-==.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/ore".
 01 WS-PTR                 USAGE POINTER.
 01 WS-A                   PIC X(304640) BASED.
 01 WS-KEY                 PIC X(112).
 01 WS-NAME                PIC X(48).
 01 WS-PAIRS               PIC X(160).
 01 WS-FTKEY               PIC X(80).
 01 WS-FT                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-OK                  BINARY-LONG.
 01 WS-CASE                PIC X(200).
 01 WS-OBS                 BINARY-LONG.
 01 WS-EXP                 BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-CX                  BINARY-LONG VALUE 1.
 01 WS-CZ                  BINARY-LONG VALUE 2.
 01 WS-MIN                 BINARY-LONG VALUE 0.
 01 WS-HEIGHT              BINARY-LONG VALUE 128.
 01 WS-SEA                 BINARY-LONG VALUE 32.
 01 WS-OX                  BINARY-LONG VALUE 24.
 01 WS-OY                  BINARY-LONG VALUE 30.
 01 WS-OZ                  BINARY-LONG VALUE 40.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-SC                  BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-WRITTEN             BINARY-LONG.
 01 WS-SEEDS-WROTE         BINARY-LONG.
 01 WS-CELLS-A             BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-P1                  BINARY-LONG.
 01 WS-P2                  BINARY-LONG.
 01 WS-TAG-REG             PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112).
 01 WS-TAG-N               BINARY-LONG.
 01 WS-TAG-IDS.
    05 WS-TAG-ID           BINARY-LONG OCCURS 4 TIMES.
 01 WS-TAG-STATUS          BINARY-LONG.
 01 WS-S-ROCK              BINARY-LONG.
 01 WS-S-AIR               BINARY-LONG VALUE 0.
 01 WS-S-A                 BINARY-LONG.
 01 WS-S-B                 BINARY-LONG.
 01 WS-KIND                PIC X.
 01 WS-MODE                BINARY-LONG.
 01 WS-NT                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-K1                  BINARY-LONG.
 01 WS-K2                  BINARY-LONG.
 01 WS-K3                  BINARY-LONG.
 01 WS-K4                  BINARY-LONG.
 01 WS-K5                  BINARY-LONG.
 01 WS-K6                  BINARY-LONG.
 01 WS-SPREAD              BINARY-LONG.
 01 WS-M-N                 BINARY-LONG.
 01 WS-SCN                 PIC 99.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-GX                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-GZ                  BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 01 WS-NB                  BINARY-LONG.
 01 WS-EXPOSED             BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 01 WS-CH                  PIC X.
 01 WS-HAVE                BINARY-LONG.
 01 WS-MINX                BINARY-LONG.
 01 WS-MAXX                BINARY-LONG.
 01 WS-MINY                BINARY-LONG.
 01 WS-MAXY                BINARY-LONG.
 01 WS-MINZ                BINARY-LONG.
 01 WS-MAXZ                BINARY-LONG.
 01 WS-MODEL.
    05 WS-MCELL            PIC X OCCURS 32768 TIMES.
 01 WS-GATE-KEY            PIC X(80).
 01 WS-GATE-FLAG           BINARY-LONG.
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
     PERFORM LOOK-UP

*>   the compiled features
     MOVE "minecraft:ore_plain" TO WS-FTKEY
     PERFORM COMPILE
     MOVE "11§7: the data feature of type ore compiles as type 31 with its one target" TO WS-CASE
     COMPUTE WS-OBS = FT-TYPE(WS-FT) * 10 + FT-B(WS-FT)
     MOVE 311 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "11§7: the size (33) is kept" TO WS-CASE
     MOVE FT-C(WS-FT) TO WS-OBS
     MOVE 33 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "11§7.3: a chance of 0.0 is the no-test mode 0" TO WS-CASE
     MOVE FT-E(WS-FT) TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:ore_guard" TO WS-FTKEY
     PERFORM COMPILE
     MOVE "11§7.3: a chance of 1.0 is the always-test mode 1" TO WS-CASE
     MOVE FT-E(WS-FT) TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:ore_half" TO WS-FTKEY
     PERFORM COMPILE
     MOVE "11§7.3: a chance of 0.5 is the draw mode 2" TO WS-CASE
     MOVE FT-E(WS-FT) TO WS-OBS
     MOVE 2 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:scat_guard" TO WS-FTKEY
     PERFORM COMPILE
     MOVE "35-1§13.1: the data feature of type scattered_ore compiles as type 39 with its one target and size 3" TO WS-CASE
     COMPUTE WS-OBS = FT-TYPE(WS-FT) * 100 + FT-B(WS-FT) * 10 + FT-C(WS-FT)
     MOVE 3913 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:scat_empty" TO WS-FTKEY
     PERFORM COMPILE
     MOVE "35-1§13.1: an empty target list is a supported feature of no targets" TO WS-CASE
     COMPUTE WS-OBS = FT-TYPE(WS-FT) * 10 + FT-B(WS-FT)
     MOVE 390 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:ore_nosize" TO WS-FTKEY
     PERFORM COMPILE
     MOVE "11§7: an ore without size is unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:ore_nochance" TO WS-FTKEY
     PERFORM COMPILE
     MOVE "35-1§13.1: a scattered_ore without discard_chance_on_air_exposure is unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:ore_notargets" TO WS-FTKEY
     PERFORM COMPILE
     MOVE "11§7: an ore without targets is unsupported (the member is required)" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:ore_size65" TO WS-FTKEY
     PERFORM COMPILE
     MOVE "35-1§13.1: a size of 65 is outside 0..64 and unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:ore_neg" TO WS-FTKEY
     PERFORM COMPILE
     MOVE "35-1§13.1: a size of -1 is outside 0..64 and unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:ore_chance2" TO WS-FTKEY
     PERFORM COMPILE
     MOVE "35-1§13.1: a chance of 1.5 is outside 0.0..1.0 and unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:ore_chanceneg" TO WS-FTKEY
     PERFORM COMPILE
     MOVE "35-1§13.1: a chance of -0.5 is outside 0.0..1.0 and unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N

*>   the overworld ore placed features stay with the hard-coded pass of ores.cob
     MOVE 1 TO FI-GATE
     MOVE "minecraft:ore_coal_upper" TO WS-GATE-KEY
     CALL "FR-GATE" USING WS-GATE-KEY WS-GATE-FLAG
     MOVE "35-7§12: the stage's family gate keeps the overworld ore placed features off (ores.cob places them)" TO WS-CASE
     MOVE WS-GATE-FLAG TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 0 TO FI-GATE

*>   the runs
     PERFORM VARYING WS-SC FROM 1 BY 1 UNTIL WS-SC > 8
         PERFORM SET-SCENARIO
         PERFORM RUN-SEEDS
         MOVE WS-BAD TO WS-OBS
         MOVE 0 TO WS-EXP
         PERFORM ASSERT-N
         PERFORM CHECK-WRITES
     END-PERFORM
     STOP RUN.

*> LOOK-UP: the block states the scenarios use, and the tag of the scattered fixtures (base stone: netherrack only here, as the window holds nothing else)
 LOOK-UP.
     MOVE "netherrack" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-ROCK
     COMPUTE WS-TAG-ID(1) = WS-WANT - 1
     MOVE "basalt" TO WS-KEY
     PERFORM WANT-BLOCK
     COMPUTE WS-TAG-ID(2) = WS-WANT - 1
     MOVE "blackstone" TO WS-KEY
     PERFORM WANT-BLOCK
     COMPUTE WS-TAG-ID(3) = WS-WANT - 1
     MOVE 3 TO WS-TAG-N
     MOVE "minecraft:ore_test_base" TO WS-TAG
     CALL "TAG-PUT" USING WS-TAG-REG WS-TAG WS-TAG-N WS-TAG-IDS WS-TAG-STATUS
     .

*> COMPILE: compiles WS-FTKEY into WS-FT
 COMPILE.
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     .

*> SET-SCENARIO: the fixture (WS-FTKEY), the kind (O ore, S scattered_ore), the chance mode, the number of targets and the states they write
 SET-SCENARIO.
     MOVE 1 TO WS-NT
     MOVE SPACES TO WS-CASE
     EVALUATE WS-SC
         WHEN 1
             MOVE "minecraft:ore_plain" TO WS-FTKEY
             MOVE "O" TO WS-KIND
             MOVE 0 TO WS-MODE
             MOVE 33 TO WS-SIZE
             MOVE "magma_block" TO WS-KEY
             MOVE "11§7.2 an ore blob of size 33 (chance 0) turns every netherrack of its balls to magma, as the model says" TO WS-CASE
         WHEN 2
             MOVE "minecraft:ore_guard" TO WS-FTKEY
             MOVE "O" TO WS-KIND
             MOVE 1 TO WS-MODE
             MOVE 14 TO WS-SIZE
             MOVE "magma_block" TO WS-KEY
             MOVE "11§7.3 an ore blob with chance 1.0 skips every block that touches air and draws no float" TO WS-CASE
         WHEN 3
             MOVE "minecraft:ore_half" TO WS-FTKEY
             MOVE "O" TO WS-KIND
             MOVE 2 TO WS-MODE
             MOVE 14 TO WS-SIZE
             MOVE "magma_block" TO WS-KEY
             MOVE "11§7.3 an ore blob with chance 0.5 draws one float per accepted block and looks at the neighbours below 0.5" TO WS-CASE
         WHEN 4
             MOVE "minecraft:ore_two" TO WS-FTKEY
             MOVE "O" TO WS-KIND
             MOVE 2 TO WS-MODE
             MOVE 2 TO WS-NT
             MOVE 20 TO WS-SIZE
             MOVE "gravel" TO WS-KEY
             MOVE "11§7.2 two targets with the same rule: the first that passes the air test writes, the second is tried (and draws) only after a failed air test" TO WS-CASE
         WHEN 5
             MOVE "minecraft:scat_guard" TO WS-FTKEY
             MOVE "S" TO WS-KIND
             MOVE 1 TO WS-MODE
             MOVE 3 TO WS-SIZE
             MOVE "ancient_debris" TO WS-KEY
             MOVE "35-1§13.2 scattered_ore size 3, chance 1.0: nextInt(4) attempts of six floats, a hidden netherrack becomes debris" TO WS-CASE
         WHEN 6
             MOVE "minecraft:scat_half" TO WS-FTKEY
             MOVE "S" TO WS-KIND
             MOVE 2 TO WS-MODE
             MOVE 12 TO WS-SIZE
             MOVE "ancient_debris" TO WS-KEY
             MOVE "35-1§13.2 scattered_ore size 12, chance 0.5: spread min(i, 7), one float per accepted rule" TO WS-CASE
         WHEN 7
             MOVE "minecraft:scat_open" TO WS-FTKEY
             MOVE "S" TO WS-KIND
             MOVE 0 TO WS-MODE
             MOVE 64 TO WS-SIZE
             MOVE "ancient_debris" TO WS-KEY
             MOVE "35-1§13.2 scattered_ore size 64, chance 0.0: no air test, an already written block is rejected by the rule" TO WS-CASE
         WHEN OTHER
             MOVE "minecraft:scat_zero" TO WS-FTKEY
             MOVE "S" TO WS-KIND
             MOVE 1 TO WS-MODE
             MOVE 0 TO WS-SIZE
             MOVE "ancient_debris" TO WS-KEY
             MOVE "35-1§13.2 scattered_ore size 0: nextInt(1) is 0, no attempt, nothing written" TO WS-CASE
     END-EVALUATE
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-A
     MOVE WS-S-A TO WS-S-B
     IF WS-NT = 2
         MOVE "blackstone" TO WS-KEY
         PERFORM WANT-BLOCK
         MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-B
     END-IF
     .

*> RUN-SEEDS: 16 seeds of the feature at the origin; WS-BAD counts the seeds whose window or random stream differs from the model; WS-SEEDS-WROTE the seeds that wrote something
 RUN-SEEDS.
     PERFORM COMPILE
     MOVE 0 TO WS-BAD WS-SEEDS-WROTE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE WS-I TO WS-SEED
         PERFORM MAKE-WINDOW
         CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
         CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
         CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-OX WS-OY WS-OZ WS-OK
         PERFORM MODEL
         PERFORM COMPARE
         MOVE 1000000 TO WS-N
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-P1
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-N WS-P2
         IF WS-P1 NOT = WS-P2 OR WS-OK NOT = 1 OR WS-CELLS-A NOT = 0
             ADD 1 TO WS-BAD
         END-IF
         IF WS-HAVE > 0
             ADD 1 TO WS-SEEDS-WROTE
         END-IF
     END-PERFORM
     .

*> MAKE-WINDOW: the chunk (1, 2) of the level (x 16..31, z 32..47, y 0..127) is air with a netherrack box x 18..30, y 24..36, z 34..46 and an air pocket of two cells off the origin; the model
*> holds the same ('R' rock, '.' air, 'A' and 'B' written by the first and second target)
 MAKE-WINDOW.
     SET ADDRESS OF WS-A TO WS-PTR
     MOVE LOW-VALUES TO WS-A
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     MOVE ALL "." TO WS-MODEL
     PERFORM VARYING WS-X FROM 18 BY 1 UNTIL WS-X > 30
         PERFORM VARYING WS-Y FROM 24 BY 1 UNTIL WS-Y > 36
             PERFORM VARYING WS-Z FROM 34 BY 1 UNTIL WS-Z > 46
                 COMPUTE WS-AT = WS-Y * 256 + (WS-Z - 32) * 16 + (WS-X - 16) + 1
                 MOVE WS-S-ROCK TO CE-STATE(WS-AT)
                 MOVE "R" TO WS-MCELL(WS-AT)
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE WS-AT = 30 * 256 + (38 - 32) * 16 + (22 - 16) + 1
     MOVE 0 TO CE-STATE(WS-AT)
     MOVE "." TO WS-MCELL(WS-AT)
     ADD 256 TO WS-AT
     MOVE 0 TO CE-STATE(WS-AT)
     MOVE "." TO WS-MCELL(WS-AT)
     .

*> MODEL: the document's rules over the model window with the model's own stream (XR2-STATE)
 MODEL.
     MOVE 0 TO WS-HAVE
     IF WS-KIND = "O"
         CALL "FR-ORE-BLOB" USING XR2-STATE WS-SIZE WS-OX WS-OY WS-OZ
         IF OB-NPOS < 1
             ADD 1 TO WS-BAD
         END-IF
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > OB-NPOS
             MOVE OB-POS-X(WS-J) TO WS-PX
             MOVE OB-POS-Y(WS-J) TO WS-PY
             MOVE OB-POS-Z(WS-J) TO WS-PZ
             PERFORM MODEL-TRY
         END-PERFORM
     ELSE
         COMPUTE WS-N = WS-SIZE + 1
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-N WS-M-N
         PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J >= WS-M-N
             MOVE WS-J TO WS-SPREAD
             IF WS-SPREAD > 7
                 MOVE 7 TO WS-SPREAD
             END-IF
             PERFORM DRAW-K1
             PERFORM DRAW-K2
             PERFORM DRAW-K3
             PERFORM DRAW-K4
             PERFORM DRAW-K5
             PERFORM DRAW-K6
             COMPUTE WS-DX = FUNCTION INTEGER(((WS-K1 - WS-K2) * WS-SPREAD + 8388608) / 16777216)
             COMPUTE WS-DY = FUNCTION INTEGER(((WS-K3 - WS-K4) * WS-SPREAD + 8388608) / 16777216)
             COMPUTE WS-DZ = FUNCTION INTEGER(((WS-K5 - WS-K6) * WS-SPREAD + 8388608) / 16777216)
             COMPUTE WS-PX = WS-OX + WS-DX
             COMPUTE WS-PY = WS-OY + WS-DY
             COMPUTE WS-PZ = WS-OZ + WS-DZ
             PERFORM MODEL-TRY
         END-PERFORM
     END-IF
     .
 DRAW-K1.
     CALL "WGR-NEXT-FLOAT" USING XR2-STATE WS-F
     COMPUTE WS-K1 ROUNDED = WS-F * 16777216
     .
 DRAW-K2.
     CALL "WGR-NEXT-FLOAT" USING XR2-STATE WS-F
     COMPUTE WS-K2 ROUNDED = WS-F * 16777216
     .
 DRAW-K3.
     CALL "WGR-NEXT-FLOAT" USING XR2-STATE WS-F
     COMPUTE WS-K3 ROUNDED = WS-F * 16777216
     .
 DRAW-K4.
     CALL "WGR-NEXT-FLOAT" USING XR2-STATE WS-F
     COMPUTE WS-K4 ROUNDED = WS-F * 16777216
     .
 DRAW-K5.
     CALL "WGR-NEXT-FLOAT" USING XR2-STATE WS-F
     COMPUTE WS-K5 ROUNDED = WS-F * 16777216
     .
 DRAW-K6.
     CALL "WGR-NEXT-FLOAT" USING XR2-STATE WS-F
     COMPUTE WS-K6 ROUNDED = WS-F * 16777216
     .

*> MODEL-TRY: 11 section 7.3 at (WS-PX, WS-PY, WS-PZ) over the model window: a position outside the chunk's columns or the build height is not rock; the targets in order, the rule (rock), then the
*> air test of the mode, then the write
 MODEL-TRY.
     COMPUTE WS-GX = WS-PX - 16
     COMPUTE WS-GZ = WS-PZ - 32
     MOVE 0 TO WS-DONE
     IF WS-GX >= 0 AND WS-GX <= 15 AND WS-GZ >= 0 AND WS-GZ <= 15 AND WS-PY >= 0 AND WS-PY <= 127
         COMPUTE WS-AT = WS-PY * 256 + WS-GZ * 16 + WS-GX + 1
         PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > WS-NT OR WS-DONE = 1
             IF WS-MCELL(WS-AT) = "R"
                 PERFORM MODEL-AIR
                 MOVE 1 TO WS-PASS
                 IF WS-MODE = 1
                     IF WS-EXPOSED = 1
                         MOVE 0 TO WS-PASS
                     END-IF
                 END-IF
                 IF WS-MODE = 2
                     CALL "WGR-NEXT-FLOAT" USING XR2-STATE WS-F
                     COMPUTE WS-K1 ROUNDED = WS-F * 16777216
                     IF WS-K1 < 8388608 AND WS-EXPOSED = 1
                         MOVE 0 TO WS-PASS
                     END-IF
                 END-IF
                 IF WS-PASS = 1
                     IF WS-T = 1
                         MOVE "A" TO WS-MCELL(WS-AT)
                     ELSE
                         MOVE "B" TO WS-MCELL(WS-AT)
                     END-IF
                     MOVE 1 TO WS-DONE
                     ADD 1 TO WS-HAVE
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     .

*> MODEL-AIR: WS-EXPOSED = 1 when a face neighbour of the position is air: a neighbour outside the chunk's columns is not air, one outside the build height is (void air)
 MODEL-AIR.
     MOVE 0 TO WS-EXPOSED
     PERFORM VARYING WS-NB FROM 1 BY 1 UNTIL WS-NB > 6
         MOVE WS-GX TO WS-X
         MOVE WS-PY TO WS-Y
         MOVE WS-GZ TO WS-Z
         EVALUATE WS-NB
             WHEN 1
                 SUBTRACT 1 FROM WS-X
             WHEN 2
                 ADD 1 TO WS-X
             WHEN 3
                 SUBTRACT 1 FROM WS-Y
             WHEN 4
                 ADD 1 TO WS-Y
             WHEN 5
                 SUBTRACT 1 FROM WS-Z
             WHEN OTHER
                 ADD 1 TO WS-Z
         END-EVALUATE
         IF WS-Y < 0 OR WS-Y > 127
             MOVE 1 TO WS-EXPOSED
         ELSE
             IF WS-X >= 0 AND WS-X <= 15 AND WS-Z >= 0 AND WS-Z <= 15
                 COMPUTE WS-GY = WS-Y * 256 + WS-Z * 16 + WS-X + 1
                 IF WS-MCELL(WS-GY) = "."
                     MOVE 1 TO WS-EXPOSED
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     .

*> COMPARE: WS-CELLS-A = the number of cells of the real window that differ from the model (rock, air, the first or the second target's state)
 COMPARE.
     MOVE 0 TO WS-CELLS-A
     PERFORM VARYING WS-AT FROM 1 BY 1 UNTIL WS-AT > 32768
         EVALUATE WS-MCELL(WS-AT)
             WHEN "R"
                 MOVE WS-S-ROCK TO WS-STATE
             WHEN "A"
                 MOVE WS-S-A TO WS-STATE
             WHEN "B"
                 MOVE WS-S-B TO WS-STATE
             WHEN OTHER
                 MOVE 0 TO WS-STATE
         END-EVALUATE
         IF CE-STATE(WS-AT) NOT = WS-STATE
             ADD 1 TO WS-CELLS-A
         END-IF
     END-PERFORM
     .

*> CHECK-WRITES: the blobs write in every seed; scattered_ore in some seeds (size 3), in every seed but the draws that give no attempt (sizes 12 and 64), in none (size 0)
 CHECK-WRITES.
     MOVE SPACES TO WS-CASE
     MOVE WS-SC TO WS-SCN
     STRING "scenario " WS-SCN " wrote in the expected seeds" DELIMITED BY SIZE INTO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     EVALUATE WS-SC
         WHEN 8
             MOVE 0 TO WS-EXP
             MOVE WS-SEEDS-WROTE TO WS-OBS
         WHEN 5
             IF WS-SEEDS-WROTE > 0 AND WS-SEEDS-WROTE < 16
                 MOVE 1 TO WS-OBS
             END-IF
         WHEN OTHER
             IF WS-SEEDS-WROTE >= 12
                 MOVE 1 TO WS-OBS
             END-IF
     END-EVALUATE
     PERFORM ASSERT-N
     .
 WANT-BLOCK.
     MOVE WS-KEY TO WS-NAME
     CALL "FD-BLOCK-INDEX" USING WS-NAME WS-WANT
     .
 ASSERT-N.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-OBS TO TL-OBSERVED-N
     MOVE WS-EXP TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
 END PROGRAM TEST-FEAT-ORE.
 COPY NOSPAWN.
 COPY CORETEST.
