*> Acceptance test (lane p49a; docs/protocol/19-mobs-land-friendly-and-neutral.md section 25.4 Wandering trader spawn chance, with 19 section 23 and 45-entity-nbt-6 section 9): the
*> spawner subtracts 1200 from the stored delay every cycle and acts at 0 or below (reset to 24000, chance clamp(old + 25, 25, 75) before the roll); the roll is nextInt(100) and the
*> spawn is attempted when it is at most the OLD chance; success resets the chance to 25, failure leaves it raised (so the next day's chance is 75). The document 19 section 25.4
*> says the roll is compared with the raised chance (51 percent); 45-6 section 9 (and this test) compare with the old one: the conflict is recorded in the lane report.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-19-25-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-DELAY              BINARY-LONG.
 01 WS-CHANCE             BINARY-LONG.
 01 WS-ROLL               BINARY-LONG.
 01 WS-ATTEMPT            BINARY-LONG.
 01 WS-SPAWNED            BINARY-LONG.
 01 WS-I                  BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
*>   A fresh world: 24000 and 25; 19 cycles of 1200 do nothing (delay 1200 left), the 20th acts.
     MOVE 24000 TO WS-DELAY
     MOVE 25 TO WS-CHANCE
     MOVE 0 TO WS-ROLL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 19
         CALL "WT-CYCLE" USING WS-DELAY WS-CHANCE WS-ROLL WS-ATTEMPT
     END-PERFORM
     MOVE "acceptance US15 19§25.4 Wandering trader spawn chance: 19 cycles leave the delay at 1200 and the chance at 25" TO TL-CASE
     MOVE 120025 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-DELAY * 100 + WS-CHANCE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 25 TO WS-ROLL
     CALL "WT-CYCLE" USING WS-DELAY WS-CHANCE WS-ROLL WS-ATTEMPT
     MOVE "acceptance US15 19§25.4 Wandering trader spawn chance: the 20th cycle resets the delay to 24000 and raises the chance to 50" TO TL-CASE
     MOVE 2400050 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-DELAY * 100 + WS-CHANCE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§25.4 Wandering trader spawn chance: a roll of 25 is at most the old chance 25: attempt" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-ATTEMPT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The attempt fails (the 9 in 10 abort): the chance stays 50; the next day's cycle raises it to 75.
     MOVE 0 TO WS-SPAWNED
     CALL "WT-RESULT" USING WS-CHANCE WS-SPAWNED
     MOVE "acceptance US15 19§25.4 Wandering trader spawn chance: a failed attempt leaves the raised chance 50" TO TL-CASE
     MOVE 50 TO TL-EXPECTED-N
     MOVE WS-CHANCE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1200 TO WS-DELAY
     MOVE 50 TO WS-ROLL
     CALL "WT-CYCLE" USING WS-DELAY WS-CHANCE WS-ROLL WS-ATTEMPT
     MOVE "acceptance US15 19§25.4 Wandering trader spawn chance: the next day the chance is 75 and a roll of 50 (the old chance) still attempts" TO TL-CASE
     MOVE 175 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-ATTEMPT * 100 + WS-CHANCE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1200 TO WS-DELAY
     MOVE 51 TO WS-ROLL
     MOVE 50 TO WS-CHANCE
     CALL "WT-CYCLE" USING WS-DELAY WS-CHANCE WS-ROLL WS-ATTEMPT
     MOVE "acceptance US15 19§25.4 Wandering trader spawn chance: a roll of 51 is above the old chance 50: no attempt" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ATTEMPT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The cap: from 75 the chance stays 75.
     MOVE 1200 TO WS-DELAY
     MOVE 75 TO WS-CHANCE
     MOVE 99 TO WS-ROLL
     CALL "WT-CYCLE" USING WS-DELAY WS-CHANCE WS-ROLL WS-ATTEMPT
     MOVE "acceptance US15 19§25.4 Wandering trader spawn chance: the chance is capped at 75" TO TL-CASE
     MOVE 75 TO TL-EXPECTED-N
     MOVE WS-CHANCE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A successful spawn resets the chance to 25.
     MOVE 1 TO WS-SPAWNED
     CALL "WT-RESULT" USING WS-CHANCE WS-SPAWNED
     MOVE "acceptance US15 19§25.4 Wandering trader spawn chance: a successful spawn resets the chance to 25" TO TL-CASE
     MOVE 25 TO TL-EXPECTED-N
     MOVE WS-CHANCE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-19-25-4.
