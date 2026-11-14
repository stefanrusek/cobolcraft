*> Acceptance test (US12-3, docs/protocol/39-portals.md section 5.1 step 2): portals saved before a restart are found after it. A creative
*> player lights an overworld portal and steps in (a nether portal is made for her); the world is saved and opened again, so no point of interest
*> is known and no chunk is loaded; the forcer's search of the nether portal's surroundings (PORTAL-LOAD-SAVED, then PORTAL-FIND-EXISTING)
*> loads the saved chunk, records its six portal blocks and finds the portal, and does not load or generate a chunk the region file lacks.
*> Needs the generated packs (a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US12-PORTAL-SAVED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY PORTAL.
 01 WS-SKIP                BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-AXIS                BINARY-LONG VALUE 0.
 01 WS-W                   BINARY-LONG VALUE 2.
 01 WS-H                   BINARY-LONG VALUE 3.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ITEM-KEY            PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW-TEXT            PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-FOUND               BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-NETHER              BINARY-LONG VALUE 1.
 01 WS-RADIUS              BINARY-LONG.
 01 WS-CHUNK-ROW           BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CREATED             BINARY-LONG.
 01 WS-WORLD               PIC X(64) VALUE Z"build/core-test-world".
 01 WS-A                   PIC -(9)9.
 01 WS-B                   PIC -(9)9.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance US12-3 portal saved: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE 1 TO PL-MODE(WS-ROW)
     MOVE DIM-STANDARD-OVERWORLD TO WS-DIM
     MOVE 10 TO WS-X MOVE 100 TO WS-Y MOVE 10 TO WS-Z
     CALL "PT-FRAME" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS WS-W WS-H
     MOVE "flint_and_steel" TO WS-ITEM-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-ITEM-KEY WS-ID WS-ROW-TEXT WS-STATUS
     MOVE WS-ID TO PL-SLOT-ITEM(WS-ROW, 5)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 5)
     MOVE 0 TO PL-SLOT-VAR(WS-ROW, 5)
     MOVE 4 TO WS-SLOT
     CALL "TEST-HELD" USING WS-ALICE WS-SLOT
     MOVE 9 TO WS-X MOVE 99 TO WS-Y
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-ALICE WS-X WS-Y WS-Z WS-FACE WS-SEQ
     MOVE 10.0 TO PL-X(WS-ROW)
     MOVE 100.0 TO PL-Y(WS-ROW)
     MOVE 10.5 TO PL-Z(WS-ROW)
     CALL "TEST-TICKS" USING WS-TWO
     MOVE PL-DIM(WS-ROW) TO WS-A
     COMPUTE WS-PX = FUNCTION INTEGER(PL-X(WS-ROW))
     COMPUTE WS-PY = FUNCTION INTEGER(PL-Y(WS-ROW))
     COMPUTE WS-PZ = FUNCTION INTEGER(PL-Z(WS-ROW))
     MOVE "acceptance US12-3 portal saved: the walk made a nether portal (she is in dim 4)" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-A) TO TL-OBSERVED
     MOVE "4" TO TL-EXPECTED
     PERFORM CHECK

     CALL "CORE-SAVE"
     CALL "CORE-CONN-CLOSED" USING WS-ALICE
     CALL "CORE-WORLD-OPEN" USING WS-WORLD CORE-SETTINGS WS-CREATED
     MOVE PQ-POI-COUNT TO WS-A
     MOVE PQ-RADIUS-NETHER TO WS-RADIUS
     CALL "PORTAL-FIND-EXISTING" USING DIM-STANDARD-NETHER WS-PX WS-PY WS-PZ WS-NETHER WS-FOUND WS-FX WS-FY WS-FZ
     MOVE WS-FOUND TO WS-B
     MOVE "acceptance US12-3 portal saved: after the reopen no point of interest is known and the search finds nothing" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING "points " FUNCTION TRIM(WS-A) " found " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "points 0 found 0" TO TL-EXPECTED
     PERFORM CHECK

     CALL "PORTAL-LOAD-SAVED" USING DIM-STANDARD-NETHER WS-PX WS-PZ WS-RADIUS
     CALL "PORTAL-FIND-EXISTING" USING DIM-STANDARD-NETHER WS-PX WS-PY WS-PZ WS-NETHER WS-FOUND WS-FX WS-FY WS-FZ
     MOVE WS-FOUND TO WS-A
     MOVE PQ-POI-COUNT TO WS-B
     MOVE "acceptance US12-3 portal saved: loading the saved chunks round the origin records the six portal blocks and the portal is found" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING "found " FUNCTION TRIM(WS-A) " points " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "found 1 points 6" TO TL-EXPECTED
     PERFORM CHECK

*>   A chunk of the square the region file lacks stays unloaded (not generated): the one two chunks east of the portal's.
     COMPUTE WS-CX = (WS-PX - FUNCTION MOD(WS-PX, 16)) / 16 + 1
     COMPUTE WS-CZ = (WS-PZ - FUNCTION MOD(WS-PZ, 16)) / 16 + 1
     CALL "WORLD-FIND" USING DIM-STANDARD-NETHER WS-CX WS-CZ WS-CHUNK-ROW
     MOVE WS-CHUNK-ROW TO WS-A
     MOVE "acceptance US12-3 portal saved: a chunk that is not in the region file is not loaded by the search" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-A) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 CHECK.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-F2US12-PORTAL-SAVED.

 COPY CORETEST.
 COPY PORTALTEST.
