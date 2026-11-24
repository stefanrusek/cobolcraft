*> Acceptance test (lane p70e; docs/protocol/18-mob-framework.md section 9.3, the health slot 9 of every living entity, and 21 section 6.4): the ender dragon is not a table
*> mob (STDMOB-INDEX has no row for it) but its health is synced like one: a viewer that gets the dragon at pairing receives Set Entity Data (0x65) with the health 200, a hit
*> that lowers it sends the new health, a tick that changes nothing sends nothing, and the death tick (health 0) sends 0 so the client can run the death animation.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DRAGON-HEALTH-SLOT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY DRAGSTATE.
 COPY RULES.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG VALUE 0.
 01 WS-Y                   FLOAT-LONG VALUE 100.
 01 WS-Z                   FLOAT-LONG VALUE 0.
 01 WS-PART                BINARY-LONG VALUE 1.
 01 WS-AMOUNT              FLOAT-LONG VALUE 8.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-N                   BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "DRAGON-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-ROW
     MOVE SPACE TO VW-SEEN(WS-PLAYER)(WS-ROW:1)
     CALL "TEST-DRAIN-IDS" USING PL-CONN(WS-PLAYER) WS-TEXT
     CALL "ENTITY-VIEW-UPDATE" USING WS-PLAYER WS-ROW
     CALL "TEST-DRAIN-IDS" USING PL-CONN(WS-PLAYER) WS-TEXT
     MOVE 0 TO WS-N
     INSPECT WS-TEXT TALLYING WS-N FOR ALL "101"
     MOVE "acceptance 18 9.3 the pairing of the dragon sends Set Entity Data (health 200)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance 18 9.3 the pairing remembers the sent health (200000 thousandths)" TO TL-CASE
     MOVE 200000 TO TL-EXPECTED-N
     MOVE EN-HP-SENT(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A head hit of 8 by a player: 192.
     MOVE CAUSE-PLAYER TO WS-CAUSE
     CALL "DRAGON-HURT-PART" USING WS-ROW WS-PART WS-AMOUNT WS-CAUSE WS-PLAYER WS-OK
     CALL "TEST-DRAIN-IDS" USING PL-CONN(WS-PLAYER) WS-TEXT
     MOVE 0 TO WS-N
     INSPECT WS-TEXT TALLYING WS-N FOR ALL "101"
     MOVE "acceptance 18 9.3 a hit of 8 sends the new health to the viewer" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance 18 9.3 after the hit the sent health is 192000 thousandths" TO TL-CASE
     MOVE 192000 TO TL-EXPECTED-N
     MOVE EN-HP-SENT(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The same health again sends nothing.
     CALL "DRAGON-HEALTH-SYNC" USING WS-ROW
     CALL "TEST-DRAIN-IDS" USING PL-CONN(WS-PLAYER) WS-TEXT
     MOVE 0 TO WS-N
     INSPECT WS-TEXT TALLYING WS-N FOR ALL "101"
     MOVE "acceptance 18 9.3 an unchanged health sends nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The death tick: the health is 0 and the viewer is told.
     MOVE 0 TO DG-HP
     CALL "DRAGON-STEP" USING WS-ROW
     CALL "TEST-DRAIN-IDS" USING PL-CONN(WS-PLAYER) WS-TEXT
     MOVE 0 TO WS-N
     INSPECT WS-TEXT TALLYING WS-N FOR ALL "101"
     MOVE "acceptance 18 9.3 the death tick sends the health 0" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance 18 9.3 the sent health after death is 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-HP-SENT(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-DRAGON-HEALTH-SLOT.
 COPY CORETEST.
 COPY MOBSPTEST.
