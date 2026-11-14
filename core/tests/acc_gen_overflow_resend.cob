*> Acceptance test of the overflow of a feature written into a chunk that a player already has (docs/design/world-types.md "Chunk borders"): the neighbour's blocks are
*> written into the lit chunk and the next tick sends the chunk again (Level Chunk With Light, 0x2E) to the player who sees it, once; nothing is sent when nothing changed.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-GEN-OVERFLOW-RESEND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY GENOVER.
 COPY CELLS.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-CENTER-X(WS-PLAYER) TO WS-CX
     MOVE PL-CENTER-Z(WS-PLAYER) TO WS-CZ
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
     MOVE 1 TO GO-COUNT
     COMPUTE GO-X(1) = WS-CX * 16 + 3
     MOVE 250 TO GO-Y(1)
     COMPUTE GO-Z(1) = WS-CZ * 16 + 4
     MOVE 1 TO GO-STATE(1)
     CALL "OV-ROUTE" USING WS-DIM
     MOVE "acceptance chunk overflow Given a lit chunk the player has, When a neighbour's overflow is written into it, Then it is marked for resend" TO TL-CASE
     COMPUTE TL-OBSERVED-N = CK-LIT(WS-ROW) * 100 + CK-RESEND(WS-ROW) * 10 + GP-FLUSH
     MOVE "N" TO TL-MODE
     MOVE 111 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     CALL "OV-FLUSH"
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "acceptance chunk overflow When the tick flushes, Then the player gets the chunk again, once" TO TL-CASE
     MOVE WS-IDS TO TL-OBSERVED
     MOVE "46" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "OV-FLUSH"
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "acceptance chunk overflow When nothing changed, Then nothing is sent" TO TL-CASE
     MOVE WS-IDS TO TL-OBSERVED
     MOVE SPACES TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-GEN-OVERFLOW-RESEND.

 COPY CORETEST.
