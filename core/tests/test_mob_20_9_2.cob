*> Implementation test (002-lane-mobsfull-h8; docs/protocol/20 section 9.2 Infested blocks): in a world of the stand-in set, which has no silverfish type,
*> breaking an infested block lets nothing out; MOB-STEP of a silverfish runs its wake-up timer. The infested key is set on a block row of the loaded table.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-9-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-BLOCK               BINARY-LONG VALUE 5.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-X                   BINARY-LONG VALUE 3.
 01 WS-Y                   BINARY-LONG VALUE 64.
 01 WS-Z                   BINARY-LONG VALUE 3.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "infested_stone" TO CB-KEY(WS-BLOCK + 1)
     MOVE EN-COUNT TO WS-BEFORE
     CALL "STDMOB-INFESTED-BREAK" USING WS-DIM WS-X WS-Y WS-Z WS-BLOCK
     MOVE "N" TO TL-MODE
     MOVE "acceptance US15 20§9.2 Infested blocks: no silverfish type, nothing comes out" TO TL-CASE
     MOVE WS-BEFORE TO TL-EXPECTED-N
     MOVE EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-20-9-2.
 COPY CORETEST.
