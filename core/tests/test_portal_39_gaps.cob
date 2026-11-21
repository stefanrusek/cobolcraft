*> Implementation test (lane nether; docs/protocol/39-portals.md sections 4 and 5): the failure and edge branches of the portal engine.
*> PORTAL-CREATE makes nothing (ok 0) when no candidate exists and the platform range is empty (upper < lower: a logical height capped at 16); a transfer whose
*> exit portal cannot be made leaves the player where she is; a world without the destination dimension leaves her too (dest 0); a full
*> point-of-interest table drops the new point and keeps the others; a recorded point is not recorded twice. Needs the generated packs.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PORTAL-39-GAPS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY PORTAL.
 COPY PORTALRECT.
 01 WS-SKIP                BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-AXIS                BINARY-LONG VALUE 0.
 01 WS-OK                  BINARY-LONG VALUE 7.
 01 WS-DONE                BINARY-LONG VALUE 7.
 01 WS-SAVE                BINARY-LONG.
 01 WS-SAVE2               BINARY-LONG.
 01 WS-A                   PIC -(9)9.
 01 WS-B                   PIC -(9)9.
 01 WS-C                   PIC -(9)9.
 01 WS-DIM                 BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "test portal 39 gaps: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW

*>   PORTAL-CREATE in a nether capped at logical height 16: no frame fits under the cap and the platform range 70 to top - 9 is empty.
     MOVE 16 TO PQ-LOGICAL-CAP
     MOVE 1000 TO WS-X
     MOVE 40 TO WS-Y
     MOVE 1000 TO WS-Z
     CALL "PORTAL-CREATE" USING DIM-STANDARD-NETHER WS-X WS-Y WS-Z WS-AXIS PORTAL-RECT WS-OK
     MOVE 0 TO PQ-LOGICAL-CAP
     MOVE WS-OK TO WS-A
     MOVE "test portal 39 gaps PORTAL-CREATE with no candidate and upper < lower makes nothing: ok 0" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-A) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     PERFORM CHECK

*>   A transfer to a nether capped at logical height 16 cannot make its exit portal: she stays in the overworld, the cooldown is not consulted here.
     MOVE DIM-STANDARD-OVERWORLD TO PL-DIM(WS-ROW)
     MOVE 10.5 TO PL-X(WS-ROW)
     MOVE 100.0 TO PL-Y(WS-ROW)
     MOVE 10.5 TO PL-Z(WS-ROW)
     MOVE 16 TO PQ-LOGICAL-CAP
     MOVE 10 TO WS-X
     MOVE 100 TO WS-Y
     MOVE 10 TO WS-Z
     CALL "PORTAL-TRAVEL" USING WS-ROW WS-X WS-Y WS-Z WS-DONE
     MOVE 0 TO PQ-LOGICAL-CAP
     MOVE WS-DONE TO WS-A
     MOVE PL-DIM(WS-ROW) TO WS-B
     MOVE "test portal 39 gaps a transfer whose exit portal cannot be made logs the error and leaves her in the overworld" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING "done " FUNCTION TRIM(WS-A) " dim " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "done 0 dim 3" TO TL-EXPECTED
     PERFORM CHECK

*>   A world with only the overworld has no destination (she is back in the overworld first: the failed transfer left her there, row 3).
     MOVE DIM-STANDARD-OVERWORLD TO PL-DIM(WS-ROW)
     MOVE CW-DIM-COUNT TO WS-SAVE
     MOVE 1 TO CW-DIM-COUNT
     MOVE 7 TO WS-DONE
     CALL "PORTAL-TRAVEL" USING WS-ROW WS-X WS-Y WS-Z WS-DONE
     MOVE WS-SAVE TO CW-DIM-COUNT
     MOVE WS-DONE TO WS-A
     MOVE PL-DIM(WS-ROW) TO WS-B
     MOVE "test portal 39 gaps a world without the destination dimension: nothing happens, done 0" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING "done " FUNCTION TRIM(WS-A) " dim " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "done 0 dim 3" TO TL-EXPECTED
     PERFORM CHECK

*>   The point-of-interest table: a point is recorded once, and a full table drops the new one.
     MOVE PQ-POI-COUNT TO WS-SAVE
     MOVE 5 TO WS-X
     MOVE 60 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "PORTAL-POI-ADD" USING DIM-STANDARD-OVERWORLD WS-X WS-Y WS-Z
     CALL "PORTAL-POI-ADD" USING DIM-STANDARD-OVERWORLD WS-X WS-Y WS-Z
     COMPUTE WS-A = PQ-POI-COUNT - WS-SAVE
     MOVE PQ-POI-COUNT TO WS-SAVE2
     MOVE PQ-POI-MAX TO PQ-POI-COUNT
     MOVE 6 TO WS-X
     CALL "PORTAL-POI-ADD" USING DIM-STANDARD-OVERWORLD WS-X WS-Y WS-Z
     MOVE PQ-POI-COUNT TO WS-B
     MOVE WS-SAVE2 TO PQ-POI-COUNT
     MOVE PQ-POI-MAX TO WS-C
     MOVE "test portal 39 gaps a point is recorded once; with the table full a new point is dropped (count stays at the maximum)" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING "added " FUNCTION TRIM(WS-A) " full " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE SPACES TO TL-EXPECTED
     STRING "added 1 full " FUNCTION TRIM(WS-C) DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 CHECK.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-PORTAL-39-GAPS.

 COPY CORETEST.
 COPY PORTALTEST.
