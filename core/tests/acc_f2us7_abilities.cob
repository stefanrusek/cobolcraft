*> Acceptance test US7-2 (T0363; docs/protocol/13 section 1.4; 05a 0x41, 05c 0x28; core/src/play.cob PLAY-ABILITIES-BUILD, movement.cob
*> MOVE-ABILITIES): Player Abilities grants the flight flags only in creative (0x0D, plus 0x02 while flying) and spectator (0x07: invulnerable,
*> can fly, flying) and never in survival or adventure, whatever the player's flying state; a survival client that asks to start flying is
*> ignored and the next Player Abilities states not flying.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US7-ABILITIES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-MODE                PIC 9.
 01 WS-FLYING              PIC 9.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-REQUEST-ID          BINARY-LONG VALUE 40.
 01 WS-FLY-BIT             BINARY-LONG VALUE 2.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.
 01 WS-EDIT4               PIC -(9)9.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY

     MOVE "acceptance US7-2 given a player not flying when Player Abilities is built then survival and adventure get "
         & "no flags, creative 0x0D and spectator 0x07" TO TL-CASE
     MOVE 0 TO WS-FLYING
     MOVE 0 TO WS-MODE
     PERFORM BUILD-FLAGS
     MOVE WS-FLAGS TO WS-A
     MOVE 1 TO WS-MODE
     PERFORM BUILD-FLAGS
     MOVE WS-FLAGS TO WS-B
     MOVE 2 TO WS-MODE
     PERFORM BUILD-FLAGS
     MOVE WS-FLAGS TO WS-C
     MOVE 3 TO WS-MODE
     PERFORM BUILD-FLAGS
     MOVE WS-FLAGS TO WS-D
     MOVE WS-A TO WS-EDIT
     MOVE WS-B TO WS-EDIT2
     MOVE WS-C TO WS-EDIT3
     MOVE WS-D TO WS-EDIT4
     MOVE SPACES TO TL-OBSERVED
     STRING "survival " FUNCTION TRIM(WS-EDIT) " creative " FUNCTION TRIM(WS-EDIT2) " adventure "
         FUNCTION TRIM(WS-EDIT3) " spectator " FUNCTION TRIM(WS-EDIT4) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "survival 0 creative 13 adventure 0 spectator 7" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US7-2 given a flying state when Player Abilities is built then only creative adds the flying bit, "
         & "survival and adventure still get none" TO TL-CASE
     MOVE 1 TO WS-FLYING
     MOVE 0 TO WS-MODE
     PERFORM BUILD-FLAGS
     MOVE WS-FLAGS TO WS-A
     MOVE 1 TO WS-MODE
     PERFORM BUILD-FLAGS
     MOVE WS-FLAGS TO WS-B
     MOVE 2 TO WS-MODE
     PERFORM BUILD-FLAGS
     MOVE WS-FLAGS TO WS-C
     MOVE WS-A TO WS-EDIT
     MOVE WS-B TO WS-EDIT2
     MOVE WS-C TO WS-EDIT3
     MOVE SPACES TO TL-OBSERVED
     STRING "survival " FUNCTION TRIM(WS-EDIT) " creative " FUNCTION TRIM(WS-EDIT2) " adventure "
         FUNCTION TRIM(WS-EDIT3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "survival 0 creative 15 adventure 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US7-2 given a survival player when the client asks to start flying then the request is ignored "
         & "and the next Player Abilities states not flying" TO TL-CASE
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-REQUEST-ID
     CALL "PB-PUT-BYTE" USING PB-BUFFER WS-FLY-BIT
     CALL "TEST-FEED-BUFFER" USING WS-CONN PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE PL-MODE(WS-ROW) TO WS-MODE
     MOVE PL-FLYING(WS-ROW) TO WS-FLYING
     PERFORM BUILD-FLAGS
     MOVE PL-MODE(WS-ROW) TO WS-EDIT
     MOVE PL-FLYING(WS-ROW) TO WS-EDIT2
     MOVE WS-FLAGS TO WS-EDIT3
     MOVE SPACES TO TL-OBSERVED
     STRING "mode " FUNCTION TRIM(WS-EDIT) " flying " FUNCTION TRIM(WS-EDIT2) " flags " FUNCTION TRIM(WS-EDIT3)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "mode 0 flying 0 flags 0" TO TL-EXPECTED
     PERFORM CHECK
     GOBACK.

*> Builds Player Abilities for WS-MODE and WS-FLYING and reads the flags byte back into WS-FLAGS.
 BUILD-FLAGS.
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-ABILITIES-BUILD" USING WS-MODE WS-FLYING PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-GET-BYTE" USING PB-BUFFER WS-FLAGS.

 CHECK.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-F2US7-ABILITIES.
 COPY CORETEST.
