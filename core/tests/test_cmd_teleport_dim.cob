*> Acceptance test of `teleport` to a destination in another dimension (docs/protocol/16-commands-catalog.md §5.2, 15 §7.6): the target changes
*> dimension with the destination (DIM-SWITCH: Respawn and arrival packets) and stands at its position. Extra dimensions are on; Bob has been moved
*> to cobolcraft:subroutine. Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-TELEPORT-DIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-ALICE          BINARY-LONG.
 01 WS-ID-BOB            BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-NUM                 BINARY-DOUBLE.
 01 WS-RESULT              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-DIM                BINARY-LONG VALUE 2.
 01 WS-PX                 FLOAT-LONG VALUE 3.5.
 01 WS-PY                 FLOAT-LONG VALUE 40.
 01 WS-PZ                 FLOAT-LONG VALUE 3.5.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 1 TO CS-EXTRA-DIMENSIONS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     MOVE "Bob" TO WS-NAME
     MOVE 3 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-BOB
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-DISCARD
     CALL "DIM-SWITCH" USING CN-PLAYER(WS-ID-BOB) WS-DIM WS-PX WS-PY WS-PZ
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-DISCARD
     MOVE "acceptance US13 /teleport Bob is in dimension 2" TO TL-CASE
     MOVE PL-DIM(CN-PLAYER(WS-ID-BOB)) TO WS-NUM
     MOVE 2 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /teleport a target is moved to a destination" & " in another dimension" TO TL-CASE
     MOVE "tp Alice Bob" TO WS-LINE
     MOVE "commands.teleport.success.entity.single(Alice,Bob)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /teleport Alice is in dimension 2" TO TL-CASE
     MOVE PL-DIM(CN-PLAYER(WS-ID-ALICE)) TO WS-NUM
     MOVE 2 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /teleport Alice stands at Bob's x (3.5, twic" & "e 7)" TO TL-CASE
     COMPUTE WS-NUM = PL-X(CN-PLAYER(WS-ID-ALICE)) * 2
     MOVE 7 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     GOBACK.
 END PROGRAM TEST-CMD-TELEPORT-DIM.

 COPY CORETEST.
 COPY CMDTEST.
