*> Acceptance test of docs/protocol/44-residual-mob-questions-x2-continuation.md section 5 as rule functions (lane 002-lane-p49j-b, T24400 range): chest vehicles: the loot table unpack conditions, the save format, the destruction rules and the piglin anger filters (5.1). The container itself and its menu are not built (no entity container store).

*> The functions of core/src/q44-44-x2.cob are not called by a tick (no engine for them yet, see the lane task list).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-X2-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-CASE                PIC X(160).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-A                  FLOAT-LONG.
 01 WS-B                  FLOAT-LONG.
 01 WS-C                  FLOAT-LONG.
 01 WS-D                  FLOAT-LONG.
 01 WS-E                  FLOAT-LONG.
 01 WS-F                  FLOAT-LONG.
 01 WS-G                  FLOAT-LONG.
 01 WS-H                  FLOAT-LONG.
 01 WS-J                  FLOAT-LONG.
 01 WS-K                  FLOAT-LONG.
 01 WS-N1                 BINARY-LONG.
 01 WS-N2                 BINARY-LONG.
 01 WS-N3                 BINARY-LONG.
 01 WS-N4                 BINARY-LONG.
 01 WS-N5                 BINARY-LONG.
 01 WS-N6                 BINARY-LONG.
 01 WS-N7                 BINARY-LONG.
 01 WS-N8                 BINARY-LONG.
 01 WS-N9                 BINARY-LONG.
 01 WS-N10                 BINARY-LONG.
 01 WS-N11                 BINARY-LONG.
 01 WS-N12                 BINARY-LONG.
 01 WS-CHAIN.
    05 WS-LEVEL OCCURS 5 TIMES.
       10 WS-AMP            BINARY-LONG.
       10 WS-DUR            BINARY-LONG.
       10 WS-ACTIVE         BINARY-LONG.
 01 WS-TAB.
    05 WS-TN                BINARY-LONG.
    05 WS-TC OCCURS 6 TIMES.
       10 WS-TA             BINARY-LONG.
       10 WS-TB             BINARY-LONG.
       10 WS-TD             BINARY-LONG.
 01 WS-COL.
    05 WS-CELL OCCURS 14 TIMES.
       10 WS-CE             BINARY-LONG.
       10 WS-CF             BINARY-LONG.
 01 WS-S1                  PIC X(32).
 01 WS-S2                  PIC X(32).
 01 WS-S3                  PIC X(32).
 01 WS-S4                  PIC X(32).
 01 WS-S5                  PIC X(32).
 01 WS-S6                  PIC X(32).
 PROCEDURE DIVISION.
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "X2-LOOT-UNPACK" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6 WS-N7
     MOVE "acceptance US15 44-x2§5 loot unpack with a null player: unpacks" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-x2§5 loot unpack with a null player: key cleared" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N7
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-x2§5 loot unpack with a null player: no criterion and no luck" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5 + WS-N6
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 1 TO WS-N3
     CALL "X2-LOOT-UNPACK" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6 WS-N7
     MOVE "acceptance US15 44-x2§5 loot unpack by the opening player: the criterion fires" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-x2§5 loot unpack by the opening player: luck is a parameter" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N6
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 1 TO WS-N3
     CALL "X2-LOOT-UNPACK" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6 WS-N7
     MOVE "acceptance US15 44-x2§5 loot unpack without a key does nothing" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4 + WS-N7
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 1 TO WS-N3
     CALL "X2-LOOT-UNPACK" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6 WS-N7
     MOVE "acceptance US15 44-x2§5 loot unpack on a client does nothing" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4 + WS-N7
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     CALL "X2-CHEST-SAVE" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§5 save format with a loot table and seed 0: key only (no Items, no seed)" TO WS-CASE
     MOVE 100 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4 * 100 + WS-N3 * 10 + WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 99 TO WS-N2
     CALL "X2-CHEST-SAVE" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§5 save format with a loot table and a seed: key and LootTableSeed, no Items" TO WS-CASE
     MOVE 101 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4 * 100 + WS-N3 * 10 + WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 99 TO WS-N2
     CALL "X2-CHEST-SAVE" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§5 save format without a loot table: Items only" TO WS-CASE
     MOVE 10 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4 * 100 + WS-N3 * 10 + WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     CALL "X2-CHEST-DESTROY" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x2§5 destroy with entity_drops: the contents drop" TO WS-CASE
     MOVE 10 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3 * 10 + WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     CALL "X2-CHEST-DESTROY" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x2§5 destroy by a Player: piglins are angered as well" TO WS-CASE
     MOVE 11 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3 * 10 + WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-N2
     CALL "X2-CHEST-DESTROY" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x2§5 destroy without entity_drops: nothing, no anger" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3 * 10 + WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 1 TO WS-N3
     CALL "X2-ANGER-FILTER" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x2§5 5.1 an idle piglin that can see the player is angered (requireSight true)" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "X2-ANGER-FILTER" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x2§5 5.1 an idle piglin that cannot see him is not (requireSight true)" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "X2-ANGER-FILTER" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x2§5 5.1 with requireSight false sight is not needed" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 1 TO WS-N3
     CALL "X2-ANGER-FILTER" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x2§5 5.1 a piglin that is not idle is never angered" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     STOP RUN.
 END PROGRAM TEST-Q44-44-X2-5.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 LINKAGE SECTION.
 01 L-CASE                 PIC X(160).
 01 L-EXPECTED             BINARY-LONG.
 01 L-OBSERVED             BINARY-LONG.
 PROCEDURE DIVISION USING L-CASE L-EXPECTED L-OBSERVED.
     MOVE "N" TO TL-MODE
     MOVE L-CASE TO TL-CASE
     MOVE L-EXPECTED TO TL-EXPECTED-N
     MOVE L-OBSERVED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-CHK.
