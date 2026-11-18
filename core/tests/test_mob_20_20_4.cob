*> Acceptance test (002-lane-p49b; docs/protocol/20 section 20.4 and 4.1): zombie reinforcement chance at spawn. A zombie finalized on Hard with effective difficulty 3
*> (special multiplier 0.5): the base chance is nextDouble x 0.1 (never above 0.1, mean 0.05); with probability 0.05 x 0.5 = 0.025 it is a leader and the chance gains
*> 0.5 + nextDouble x 0.25 (0.5 to 0.75 more). The chance is held in ten-thousandths (EN-REINF). When hurt on Hard the caller's chance falls by 0.05 and never below 0
*> (STDMOB-REINFORCE, test_mob_20_4_1 for the spawn side of the called zombie).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-20-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY XORO REPLACING LEADING ==XR-== BY ==XR-==.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-INHABITED           BINARY-DOUBLE VALUE 0.
 01 WS-MOON                BINARY-LONG VALUE 0.
 01 WS-EFF                 BINARY-LONG.
 01 WS-SPECIAL             BINARY-LONG.
 01 WS-LEADERS             BINARY-LONG VALUE 0.
 01 WS-BASE-N              BINARY-LONG VALUE 0.
 01 WS-BASE-SUM            BINARY-LONG VALUE 0.
 01 WS-BASE-MAX            BINARY-LONG VALUE 0.
 01 WS-LEAD-MIN            BINARY-LONG VALUE 99999.
 01 WS-LEAD-MAX            BINARY-LONG VALUE 0.
 01 WS-MEAN                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE 3 TO BW-DIFFICULTY
     MOVE 6000 TO CW-TIME
     MOVE 1512000 TO CW-GAME-TIME
     MOVE 0 TO CW-TICKS
     CALL "STDMOB-DIFFICULTY" USING BW-DIFFICULTY CW-GAME-TIME WS-INHABITED WS-MOON WS-EFF
     CALL "STDMOB-SPECIAL" USING WS-EFF WS-SPECIAL
     MOVE "acceptance US15 20§20.4 Hard at game time 1512000: effective difficulty 3, special multiplier 0.5" TO TL-CASE
     MOVE 3000500 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-EFF * 1000 + WS-SPECIAL
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 8
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4000
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "STDMOB-FINALIZE" USING XR-STATE WS-ROW
         IF EN-REINF(WS-ROW) >= 5000
             ADD 1 TO WS-LEADERS
             IF EN-REINF(WS-ROW) < WS-LEAD-MIN
                 MOVE EN-REINF(WS-ROW) TO WS-LEAD-MIN
             END-IF
             IF EN-REINF(WS-ROW) > WS-LEAD-MAX
                 MOVE EN-REINF(WS-ROW) TO WS-LEAD-MAX
             END-IF
         ELSE
             ADD 1 TO WS-BASE-N
             ADD EN-REINF(WS-ROW) TO WS-BASE-SUM
             IF EN-REINF(WS-ROW) > WS-BASE-MAX
                 MOVE EN-REINF(WS-ROW) TO WS-BASE-MAX
             END-IF
         END-IF
     END-PERFORM
     COMPUTE WS-MEAN = WS-BASE-SUM / WS-BASE-N
     MOVE "acceptance US15 20§20.4 base chance is below 0.1 (1000 ten-thousandths)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-BASE-MAX <= 1000
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§20.4 base chance mean is about 0.05" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-MEAN >= 450 AND WS-MEAN <= 550
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§20.4 about 0.025 of zombies are leaders (100 in 4000)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-LEADERS >= 60 AND WS-LEADERS <= 150
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§20.4 a leader's chance is 0.5 to 0.85 (base up to 0.1 plus 0.5 to 0.75)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-LEAD-MIN >= 5000 AND WS-LEAD-MAX <= 8500
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-20-20-4.
 COPY CORETEST.
 COPY MOBSPTEST.
