*> Acceptance test of docs/protocol/36-structures-5-mineshaft-stronghold.md section 2.13 (loot, spawners, summary of mineshaft random draws, T1504): the only spawner is the cave spider spawner of a
*> spider corridor (one per such corridor; a corridor has rails with probability 1/3 and, among those without, a spider with 1/23, so never both); and postProcess runs once per chunk the piece touches
*> with the chunk's shared random: cells outside the chunk's write box are skipped by placeBlock but their draws (generateMaybeBox, cobweb and torch chances) are still consumed, so a corridor that
*> straddles two chunks leaves the decoration random in the same state whichever chunk writes it, while the cells written differ. Checked for a railed corridor and a spider corridor.
*> The chest minecart itself (1 percent per side per section, loot abandoned_mineshaft) is not made: see the lane notes (the minecart container and its loot table are not specified).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-5-2-13.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATLEVEL.
 COPY STRUCTPIECE.
 COPY STRUCTBLK.
 COPY GENBE.
 01 WS-SDIR                PIC X(1100) VALUE "core/tests/fixtures/struct-ms".
 01 WS-STATUS              BINARY-LONG.
 01 WS-PTR                 USAGE POINTER.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==A-==.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-CX                  BINARY-LONG VALUE 0.
 01 WS-CZ                  BINARY-LONG VALUE 0.
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-I                   BINARY-LONG.
 01 WS-PT                  BINARY-LONG VALUE 0.
 01 WS-PO                  BINARY-LONG VALUE 3.
 01 WS-MST                 BINARY-LONG VALUE 0.
 01 WS-DEP                 BINARY-LONG VALUE 0.
 01 WS-F1                  BINARY-LONG.
 01 WS-F2                  BINARY-LONG.
 01 WS-CASE                BINARY-LONG.
 01 WS-LO0                 BINARY-DOUBLE.
 01 WS-HI0                 BINARY-DOUBLE.
 01 WS-LO1                 BINARY-DOUBLE.
 01 WS-HI1                 BINARY-DOUBLE.
 01 WS-AIR-0               BINARY-LONG.
 01 WS-AIR-1               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-STATE               BINARY-DOUBLE UNSIGNED.
 01 WS-DIR                 BINARY-LONG VALUE 3.
 01 WS-DEPTH               BINARY-LONG VALUE 3.
 01 WS-RAILS               BINARY-LONG.
 01 WS-SPIDERS             BINARY-LONG.
 01 WS-BOTH                BINARY-LONG.
 01 WS-MADE                BINARY-LONG.
 01 WS-X0B                 BINARY-LONG.
 01 WS-Y0B                 BINARY-LONG.
 01 WS-Z0B                 BINARY-LONG.
 01 WS-X1B                 BINARY-LONG.
 01 WS-Y1B                 BINARY-LONG.
 01 WS-Z1B                 BINARY-LONG.
 01 WS-ZERO0               BINARY-LONG VALUE 0.
 01 WS-N                   BINARY-LONG.
 01 WS-DRAWN               FLOAT-LONG.
 01 WS-CHANCE-ALL          FLOAT-LONG VALUE 0.8.
 01 WS-CHANCE-ONE          FLOAT-LONG VALUE 1.0.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-XR== LEADING ==XR-== BY ==WX-==.
 01 WS-X0                  BINARY-LONG VALUE 100.
 01 WS-Y0                  BINARY-LONG VALUE 40.
 01 WS-Z0                  BINARY-LONG VALUE 200.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "STRUCT-LOAD" USING WS-SDIR WS-STATUS
     ALLOCATE 304640 CHARACTERS INITIALIZED RETURNING WS-PTR
     MOVE SPACES TO WS-PAIRS
     MOVE "minecraft:stone" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STONE
     CALL "MSP-BLOCKS"
     MOVE SBK-S-CAVE-AIR TO WS-AIR
*>   a box along x from 10 to 24 (135 cells, 3 x 3 x 15), drawn by generateMaybeBox from chunk 0 and from chunk 1: the write box holds part of it, every cell still draws its nextFloat
     MOVE 0 TO WS-CX
     PERFORM RUN-BOX
     MOVE SP-XR-LO TO WS-LO0
     MOVE SP-XR-HI TO WS-HI0
     PERFORM COUNT-AIR
     MOVE WS-N TO WS-AIR-0
     MOVE 1 TO WS-CX
     PERFORM RUN-BOX
     MOVE SP-XR-LO TO WS-LO1
     MOVE SP-XR-HI TO WS-HI1
     PERFORM COUNT-AIR
     MOVE WS-N TO WS-AIR-1
*>   the model: 135 nextFloat from the same start
     MOVE 5 TO WX-LO
     MOVE 7 TO WX-HI
     PERFORM 135 TIMES
         CALL "WGR-NEXT-FLOAT" USING WS-XR WS-DRAWN
     END-PERFORM
     MOVE "acceptance US12 36-5§2.13 Summary of draws: generateMaybeBox of 135 cells half outside the write box draws 135 nextFloat in chunk 0 and in chunk 1 (cells outside are skipped, their draws are not)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-LO0 = WX-LO AND WS-HI0 = WX-HI AND WS-LO1 = WX-LO AND WS-HI1 = WX-HI
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-5§2.13 Summary of draws: chunk 0's pass wrote the air of its 54 cells (x 10 to 15) at the chance 0.8: between 30 and 54 cells" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-AIR-0 >= 30 AND WS-AIR-0 <= 54
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-5§2.13 Summary of draws: chunk 1's pass wrote its 81 cells (x 16 to 24): between 55 and 81 cells" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-AIR-1 >= 55 AND WS-AIR-1 <= 81
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   maybeGenerateBlock outside the write box still draws once
     MOVE 0 TO WS-CX
     PERFORM RUN-BOX
     MOVE 5 TO SP-XR-LO
     MOVE 7 TO SP-XR-HI
     MOVE 40 TO WS-X
     MOVE 50 TO WS-Y
     MOVE 40 TO WS-Z
     CALL "MSP-MAYBE-BLOCK" USING WS-ROW WS-CHANCE-ONE WS-X WS-Y WS-Z SBK-S-COBWEB
     MOVE 5 TO WX-LO
     MOVE 7 TO WX-HI
     CALL "WGR-NEXT-FLOAT" USING WS-XR WS-DRAWN
     MOVE "acceptance US12 36-5§2.13 Summary of draws: maybeGenerateBlock of a cell far outside the write box draws its one nextFloat" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF SP-XR-LO = WX-LO AND SP-XR-HI = WX-HI
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the spawner count and the rails or spider split over many corridors: MS-CREATE of a free site
     MOVE 0 TO WS-RAILS WS-SPIDERS WS-BOTH WS-MADE
     PERFORM VARYING WS-SEED FROM 1 BY 1 UNTIL WS-SEED > 3000
         CALL "SPB-RESET"
         MOVE WS-SEED TO WS-STATE
         CALL "JRAND-SET-SEED" USING SP-RNG WS-STATE
         CALL "MS-CREATE" USING WS-X0 WS-Y0 WS-Z0 WS-DIR WS-DEPTH WS-MST WS-ROW
         IF WS-ROW > 0 AND SP-TYPE(WS-ROW) = 0
             ADD 1 TO WS-MADE
             IF SP-F1(WS-ROW) = 1
                 ADD 1 TO WS-RAILS
             END-IF
             IF SP-F2(WS-ROW) = 1
                 ADD 1 TO WS-SPIDERS
             END-IF
             IF SP-F1(WS-ROW) = 1 AND SP-F2(WS-ROW) = 1
                 ADD 1 TO WS-BOTH
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-5§2.13 Summary of draws: no corridor of 3000 has both rails and a spider (the spider is drawn only without rails)" TO TL-CASE
     MOVE WS-BOTH TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the class draw makes a corridor in 70 percent of the cases: about 2100 of 3000; a third have rails (about 700) and 1/23 of the rest (about periods 61)
     MOVE "acceptance US12 36-5§2.13 Summary of draws: rails in a third of the corridors (between 30 and 37 percent)" TO TL-CASE
     COMPUTE WS-I = WS-RAILS * 100 / WS-MADE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-I >= 30 AND WS-I <= 37
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-5§2.13 Summary of draws: spider corridors are 1/23 of the corridors without rails (between 3 and 6 percent of those)" TO TL-CASE
     COMPUTE WS-I = WS-SPIDERS * 1000 / (WS-MADE - WS-RAILS)
     MOVE 0 TO TL-OBSERVED-N
     IF WS-I >= 30 AND WS-I <= 60
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 RUN-BOX.
     CALL "SPB-RESET"
     MOVE 0 TO GBL-COUNT GBL-LOST
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     MOVE LOW-VALUES TO CE-CHUNK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 135 * 256
         MOVE WS-STONE TO CE-STATE(WS-I)
     END-PERFORM
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     CALL "MSP-OPEN"
     MOVE 5 TO SP-XR-LO
     MOVE 7 TO SP-XR-HI
     MOVE 10 TO A-X0
     MOVE 50 TO A-Y0
     MOVE 0 TO A-Z0
     MOVE 24 TO A-X1
     MOVE 52 TO A-Y1
     MOVE 2 TO A-Z1
     CALL "SPB-ADD" USING WS-PT WS-PO WS-DEP WS-MST WS-BOX WS-ROW
*>   in the piece's frame (east: local z runs along world x): local (0,0,0) to (2,2,14) is world x 10 to 24, y 50 to 52, z 0 to 2
     MOVE 0 TO WS-X0B
     MOVE 0 TO WS-Y0B
     MOVE 0 TO WS-Z0B
     MOVE 2 TO WS-X1B
     MOVE 2 TO WS-Y1B
     MOVE 14 TO WS-Z1B
     CALL "MSP-MAYBE-BOX" USING WS-ROW WS-CHANCE-ALL WS-X0B WS-Y0B WS-Z0B WS-X1B WS-Y1B WS-Z1B SBK-S-CAVE-AIR BY CONTENT SBK-S-CAVE-AIR BY REFERENCE WS-ZERO0 BY CONTENT WS-ZERO0.
 COUNT-AIR.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 135 * 256
         IF CE-STATE(WS-I) = WS-AIR
             ADD 1 TO WS-N
         END-IF
     END-PERFORM.
 CELL-STATE.
     COMPUTE WS-I = (WS-Y + 64) * 256 + WS-Z * 16 + WS-X + 1
     MOVE CE-STATE(WS-I) TO WS-S.
 END PROGRAM TEST-STRUCT-36-5-2-13.
 COPY CORETEST.
