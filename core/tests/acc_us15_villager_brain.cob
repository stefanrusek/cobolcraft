*> Acceptance test, the villager schedule and POI claims (docs/protocol/19 sections 22.3, 22.7, 22.8; lane 002-lane-mobsb3, T8106): the activity by day tick, a villager claims the nearest
*> free bed (home), bell (meeting point) and workstation from the POI index and takes the profession next to the workstation, walks to its meeting point at the meet time, goes to bed at
*> rest time and wakes when rest ends, and a villager with no job site block left loses an unused profession.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-VILLAGER-BRAIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY VILSTATE.
 COPY VILPOIX.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-PAIRS               PIC X(160) VALUE SPACES.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-QD                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-HOME                BINARY-LONG VALUE 2.
 01 WS-MEET                BINARY-LONG VALUE 3.
 01 WS-JOB                 BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-DAY                 BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-ACT                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
*>   The schedule (19 section 22.3).
     MOVE 0 TO WS-BABY
     MOVE 5 TO WS-DAY
     PERFORM CHECK-ACT-3
     MOVE 10 TO WS-DAY
     MOVE 0 TO WS-ACT
     PERFORM CHECK-ACT
     MOVE 1999 TO WS-DAY
     PERFORM CHECK-ACT
     MOVE 2000 TO WS-DAY
     MOVE 1 TO WS-ACT
     PERFORM CHECK-ACT
     MOVE 8999 TO WS-DAY
     PERFORM CHECK-ACT
     MOVE 9000 TO WS-DAY
     MOVE 2 TO WS-ACT
     PERFORM CHECK-ACT
     MOVE 10999 TO WS-DAY
     PERFORM CHECK-ACT
     MOVE 11000 TO WS-DAY
     MOVE 0 TO WS-ACT
     PERFORM CHECK-ACT
     MOVE 12000 TO WS-DAY
     PERFORM CHECK-ACT-3
     MOVE 23999 TO WS-DAY
     PERFORM CHECK-ACT-3
     MOVE 1 TO WS-BABY
     MOVE 3000 TO WS-DAY
     MOVE 4 TO WS-ACT
     PERFORM CHECK-ACT
     MOVE 9000 TO WS-DAY
     MOVE 0 TO WS-ACT
     PERFORM CHECK-ACT
*>   The world: a lectern next to the spot, a bed 2 blocks east, a bell above the bed.
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Y0 = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-BX = WS-X0 + 2
     MOVE WS-Y0 TO WS-BY
     MOVE WS-Z0 TO WS-BZ
     MOVE "minecraft:red_bed" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     COMPUTE WS-BY = WS-Y0 + 2
     MOVE "minecraft:bell" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     COMPUTE WS-BX = WS-X0 + 1
     COMPUTE WS-BY = WS-Y0 + 1
     MOVE "minecraft:lectern" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     COMPUTE WS-CX = FUNCTION INTEGER(PL-X(WS-PLAYER) / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(PL-Z(WS-PLAYER) / 16)
     MOVE 0 TO PX-DONE-N
     PERFORM 24 TIMES
         CALL "PXI-SCAN" USING WS-DIM WS-CX WS-CZ
     END-PERFORM
     MOVE "minecraft:villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "VL-FIND" USING EN-ID(WS-ROW) WS-NO WS-SLOT
*>   Daytime 3000 (work): the villager claims home, meeting point and the job site and becomes a librarian.
     MOVE 3000 TO CW-TIME
     MOVE 1000 TO CW-TICKS
     CALL "VL-BRAIN" USING WS-ROW
     CALL "VPX-OF" USING EN-ID(WS-ROW) WS-HOME WS-QD WS-QX WS-QY WS-QZ WS-FOUND
     MOVE "acceptance US15 19§22.7 the villager claims the bed as its home" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "VPX-OF" USING EN-ID(WS-ROW) WS-MEET WS-QD WS-QX WS-QY WS-QZ WS-FOUND
     MOVE "acceptance US15 19§22.7 the villager claims the bell as its meeting point" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "VPX-OF" USING EN-ID(WS-ROW) WS-JOB WS-QD WS-QX WS-QY WS-QZ WS-FOUND
     MOVE "acceptance US15 19§22.7 the villager holds the lectern as its job site" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE "acceptance US15 19§22.7 within 2 blocks of the lectern the villager becomes a librarian" TO TL-CASE
     MOVE "librarian" TO TL-EXPECTED
     MOVE VL-PROF(WS-SLOT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
*>   Meet time at 9500 from 8 blocks west of the bell: the villager is sent to the bell.
     MOVE 9500 TO CW-TIME
     MOVE 1100 TO CW-TICKS
     COMPUTE EN-X(WS-ROW) = WS-X0 - 6
     MOVE 0 TO EN-COOLDOWN(WS-ROW)
     CALL "VL-BRAIN" USING WS-ROW
     COMPUTE WS-QX = WS-X0 + 2
     MOVE "acceptance US15 19§22.3 at meet time a villager far from the bell walks to it (dest x)" TO TL-CASE
     MOVE WS-QX TO TL-EXPECTED-N
     MOVE EN-DEST-X(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§22.3 and the walk has ticks to run" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-COOLDOWN(WS-ROW) > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Rest time at 13000, next to the bed: the villager sleeps.
     MOVE 13000 TO CW-TIME
     MOVE 1200 TO CW-TICKS
     COMPUTE EN-X(WS-ROW) = WS-X0 + 1
     CALL "VL-BRAIN" USING WS-ROW
     MOVE "acceptance US15 19§22.8 at rest time next to its bed the villager sleeps" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE VL-SLEEP(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§22.8 last_slept is the game tick" TO TL-CASE
     MOVE 1200 TO TL-EXPECTED-N
     MOVE VL-LAST-SLEPT(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Morning: it wakes and last_woken is set.
     MOVE 2500 TO CW-TIME
     MOVE 1300 TO CW-TICKS
     CALL "VL-BRAIN" USING WS-ROW
     MOVE "acceptance US15 19§22.8 outside the rest activity the villager wakes" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE VL-SLEEP(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§22.8 last_woken is the game tick" TO TL-CASE
     MOVE 1300 TO TL-EXPECTED-N
     MOVE VL-LAST-WOKEN(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The lectern is removed: the job claim goes, but a villager with a profession and 0 xp at level 1 loses it (ResetProfession).
     COMPUTE WS-BX = WS-X0 + 1
     COMPUTE WS-BY = WS-Y0 + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     MOVE 1500 TO CW-TICKS
     MOVE 0 TO VL-XP(WS-SLOT)
     MOVE 1 TO VL-LEVEL(WS-SLOT)
     CALL "VL-BRAIN" USING WS-ROW
     CALL "VPX-OF" USING EN-ID(WS-ROW) WS-JOB WS-QD WS-QX WS-QY WS-QZ WS-FOUND
     MOVE "acceptance US15 19§22.7 the claim on a vanished job site is released" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE "acceptance US15 19§22.7 ResetProfession: no job site, level 1, no xp: profession none" TO TL-CASE
     MOVE "none" TO TL-EXPECTED
     MOVE VL-PROF(WS-SLOT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 CHECK-ACT-3.
     MOVE 3 TO WS-ACT
     PERFORM CHECK-ACT.

 CHECK-ACT.
     CALL "VIL-DAY-ACT" USING WS-DAY WS-BABY WS-QD
     MOVE "acceptance US15 19§22.3 the activity of the day tick" TO TL-CASE
     MOVE WS-ACT TO TL-EXPECTED-N
     MOVE WS-QD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US15-VILLAGER-BRAIN.
 COPY CORETEST.
 COPY MOBSPTEST.
