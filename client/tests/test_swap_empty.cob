*> Edge-case test US19 (spec edge case): F with an empty hand, an empty off hand, or both sends the swap each time, and the HUD shows
*> no stale stack: the off-hand slot is in the HUD only while the off hand holds a stack (the server's answer sets it).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SWAP-EMPTY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-TEXT                PIC X(1024).
 01 WS-KEY                 BINARY-LONG VALUE 70.
 01 WS-I                   BINARY-LONG.
 01 WS-OFFS                BINARY-LONG.
 01 WS-CASE                BINARY-LONG.
 01 WS-D1                  PIC 9.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     PERFORM VARYING WS-CASE FROM 1 BY 1 UNTIL WS-CASE > 3
         MOVE 0 TO PL-SLOT-COUNT(PL-HELD + 1) PL-OFFHAND-COUNT
         EVALUATE WS-CASE
             WHEN 1
                 MOVE 4 TO PL-OFFHAND-COUNT
                 MOVE 1 TO PL-OFFHAND-ITEM
             WHEN 2
                 MOVE 4 TO PL-SLOT-COUNT(PL-HELD + 1)
                 MOVE 1 TO PL-SLOT-ITEM(PL-HELD + 1)
         END-EVALUATE
         CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
         CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
         MOVE SPACES TO TL-CASE
         EVALUATE WS-CASE
             WHEN 1
                 MOVE "swap empty: an empty hand with a stack in the off hand sends the swap" TO TL-CASE
             WHEN 2
                 MOVE "swap empty: a stack in hand with an empty off hand sends the swap" TO TL-CASE
             WHEN OTHER
                 MOVE "swap empty: both hands empty sends the swap" TO TL-CASE
         END-EVALUATE
         MOVE "T" TO TL-MODE
         MOVE "290700000000000000000000" TO TL-EXPECTED
         MOVE WS-TEXT TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>       The server's answer (the off hand now empty): the HUD has no off-hand slot.
         MOVE 0 TO PL-OFFHAND-COUNT
         CALL "SCREEN-BUILD" USING CLIENT-STATE
         MOVE 0 TO WS-OFFS
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
             IF SM-W-KIND(WS-I) = WK-SLOT AND SM-W-ARG(WS-I) = 37
                 ADD 1 TO WS-OFFS
             END-IF
         END-PERFORM
         MOVE SPACES TO TL-CASE
         MOVE WS-CASE TO WS-D1
         STRING "swap empty: case " WS-D1 " an empty off hand shows no stale stack in the HUD" DELIMITED BY SIZE INTO TL-CASE
         MOVE "N" TO TL-MODE
         MOVE 0 TO TL-EXPECTED-N
         MOVE WS-OFFS TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     MOVE 3 TO PL-MODE
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "swap empty: a spectator sends nothing" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-SWAP-EMPTY.

 COPY CLTEST.
