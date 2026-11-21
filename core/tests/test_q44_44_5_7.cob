*> Breeze attack sensor (docs/protocol/44-residual-mob-questions-5-overworld-hostile.md section 7; lane 002-lane-p49i, T22550; phase task T2742): the pick of nearest_attackable among the
*> nearest living entities, creative and spectator players dropped, the first attackable one in list order (nearest first).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-5-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-EX                  PIC X(64) VALUE ALL "0".
 01 WS-AT                  PIC X(64) VALUE ALL "0".
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG VALUE 24.
 01 WS-CODE                BINARY-LONG VALUE 8.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 3 TO WS-N
     MOVE "000" TO WS-EX(1:3)
     MOVE "011" TO WS-AT(1:3)
     CALL "Q5-BREEZE-PICK" USING WS-N WS-EX WS-AT WS-I
     MOVE "acceptance US15 44-5§7 Breeze attack sensor: the first attackable entity in list order (nearest first)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-I TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "010" TO WS-EX(1:3)
     CALL "Q5-BREEZE-PICK" USING WS-N WS-EX WS-AT WS-I
     MOVE "acceptance US15 44-5§7 Breeze attack sensor: a creative or spectator player is dropped before the test" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-I TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "000" TO WS-AT(1:3)
     CALL "Q5-BREEZE-PICK" USING WS-N WS-EX WS-AT WS-I
     MOVE "acceptance US15 44-5§7 Breeze attack sensor: nothing attackable erases nearest_attackable" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-I TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The scan range and rate are those of the warden sensor (3.5): follow range 24, scan every 20 ticks.
     CALL "Q5-WARDEN-CONST" USING WS-CODE WS-I
     MOVE "acceptance US15 44-5§7 Breeze attack sensor: the scan rate is the default 20 ticks" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE WS-I TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-CODE
     CALL "Q5-WARDEN-CONST" USING WS-CODE WS-I
     MOVE "acceptance US15 44-5§7 Breeze attack sensor: the follow range is 24" TO TL-CASE
     MOVE WS-K TO TL-EXPECTED-N
     MOVE WS-I TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-Q44-44-5-7.
