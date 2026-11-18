*> Acceptance test (lane p49a; docs/protocol/18-mob-framework.md section 7.1 Finishing a spawn): the local difficulty ranges of 7.1.3 (Easy 0.75 to 1.5, Normal 1.5 to
*> 4.0, Hard 2.25 to 6.75), the special multiplier (0 below 2.0, 1.0 from 4.0, linear between), the monster equipment roll of 7.1.2 (no armor when nextFloat >= 0.15 x special)
*> and the mob flags of steps 1 and 2 (left-handed on about 5 percent, the follow_range spread within +-0.11485: asserted in test_mob_18_2_10_nbt).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-7-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY XORO.
 01 WS-DIFF                BINARY-LONG.
 01 WS-TIME                BINARY-DOUBLE.
 01 WS-INHABITED           BINARY-DOUBLE.
 01 WS-MOON                BINARY-LONG.
 01 WS-EFF                 BINARY-LONG.
 01 WS-MULT                BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-TIER                BINARY-LONG.
 01 WS-SLOTS               BINARY-LONG.
 01 WS-SPECIAL             BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ARMORED             BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
*>   Easy: day time 0, no inhabited time, new moon: 1 x 0.75; the top: day time 1512000, inhabited time 3600000, full moon: 1 x (0.75 + 0.25 + 0.5).
     MOVE 1 TO WS-DIFF
     MOVE 0 TO WS-TIME WS-INHABITED WS-MOON
     CALL "STDMOB-DIFFICULTY" USING WS-DIFF WS-TIME WS-INHABITED WS-MOON WS-EFF
     MOVE "acceptance US15 18§7.1 Finishing a spawn: Easy at the start is 0.75" TO TL-CASE
     MOVE 750 TO TL-EXPECTED-N
     MOVE WS-EFF TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1512000 TO WS-TIME
     MOVE 3600000 TO WS-INHABITED
     MOVE 1000 TO WS-MOON
     CALL "STDMOB-DIFFICULTY" USING WS-DIFF WS-TIME WS-INHABITED WS-MOON WS-EFF
     MOVE "acceptance US15 18§7.1 Finishing a spawn: Easy at the top is 1.5" TO TL-CASE
     MOVE 1500 TO TL-EXPECTED-N
     MOVE WS-EFF TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Normal: 1.5 to 4.0.
     MOVE 2 TO WS-DIFF
     MOVE 0 TO WS-TIME WS-INHABITED WS-MOON
     CALL "STDMOB-DIFFICULTY" USING WS-DIFF WS-TIME WS-INHABITED WS-MOON WS-EFF
     MOVE "acceptance US15 18§7.1 Finishing a spawn: Normal at the start is 1.5" TO TL-CASE
     MOVE 1500 TO TL-EXPECTED-N
     MOVE WS-EFF TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1512000 TO WS-TIME
     MOVE 3600000 TO WS-INHABITED
     MOVE 1000 TO WS-MOON
     CALL "STDMOB-DIFFICULTY" USING WS-DIFF WS-TIME WS-INHABITED WS-MOON WS-EFF
     MOVE "acceptance US15 18§7.1 Finishing a spawn: Normal at the top is 4.0" TO TL-CASE
     MOVE 4000 TO TL-EXPECTED-N
     MOVE WS-EFF TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Hard: 2.25 to 6.75.
     MOVE 3 TO WS-DIFF
     MOVE 0 TO WS-TIME WS-INHABITED WS-MOON
     CALL "STDMOB-DIFFICULTY" USING WS-DIFF WS-TIME WS-INHABITED WS-MOON WS-EFF
     MOVE "acceptance US15 18§7.1 Finishing a spawn: Hard at the start is 2.25" TO TL-CASE
     MOVE 2250 TO TL-EXPECTED-N
     MOVE WS-EFF TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1512000 TO WS-TIME
     MOVE 3600000 TO WS-INHABITED
     MOVE 1000 TO WS-MOON
     CALL "STDMOB-DIFFICULTY" USING WS-DIFF WS-TIME WS-INHABITED WS-MOON WS-EFF
     MOVE "acceptance US15 18§7.1 Finishing a spawn: Hard at the top is 6.75" TO TL-CASE
     MOVE 6750 TO TL-EXPECTED-N
     MOVE WS-EFF TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Peaceful is 0.
     MOVE 0 TO WS-DIFF
     CALL "STDMOB-DIFFICULTY" USING WS-DIFF WS-TIME WS-INHABITED WS-MOON WS-EFF
     MOVE "acceptance US15 18§7.1 Finishing a spawn: Peaceful is 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-EFF TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The special multiplier: 0 below 2.0, 1.0 from 4.0, (eff - 2) / 2 between.
     MOVE 1999 TO WS-EFF
     CALL "STDMOB-SPECIAL" USING WS-EFF WS-MULT
     MOVE "acceptance US15 18§7.1 Finishing a spawn: the special multiplier below 2.0 is 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-MULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3000 TO WS-EFF
     CALL "STDMOB-SPECIAL" USING WS-EFF WS-MULT
     MOVE "acceptance US15 18§7.1 Finishing a spawn: at 3.0 it is 0.5" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-MULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4000 TO WS-EFF
     CALL "STDMOB-SPECIAL" USING WS-EFF WS-MULT
     MOVE "acceptance US15 18§7.1 Finishing a spawn: from 4.0 it is 1.0" TO TL-CASE
     MOVE 1000 TO TL-EXPECTED-N
     MOVE WS-MULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Equipment: with special 0 nothing is ever worn; with special 1.0 about 15 percent of the mobs wear armor.
     MOVE 0 TO WS-ARMORED WS-SPECIAL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 300
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "STDMOB-EQUIP-ROLL" USING XR-STATE WS-DIFF WS-SPECIAL WS-TIER WS-SLOTS
         IF WS-SLOTS > 0
             ADD 1 TO WS-ARMORED
         END-IF
     END-PERFORM
     MOVE "acceptance US15 18§7.1 Finishing a spawn: with the special multiplier 0 no mob wears armor" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ARMORED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-ARMORED
     MOVE 1000 TO WS-SPECIAL
     MOVE 2 TO WS-DIFF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 300
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "STDMOB-EQUIP-ROLL" USING XR-STATE WS-DIFF WS-SPECIAL WS-TIER WS-SLOTS
         IF WS-SLOTS > 0
             ADD 1 TO WS-ARMORED
         END-IF
     END-PERFORM
     MOVE "acceptance US15 18§7.1 Finishing a spawn: with the special multiplier 1.0 about 15 percent of 300 mobs wear armor (25 to 70)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ARMORED >= 25 AND WS-ARMORED <= 70
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-18-7-1.
