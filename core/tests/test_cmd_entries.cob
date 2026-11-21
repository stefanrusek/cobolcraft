*> Acceptance test of the framework entry points no standard command reaches (docs/protocol/15-commands-framework.md §3.3, §7.6): CMD-TELL sends a
*> text to a player as System Chat, BR-MODIFY-CALL (the source modifier of a redirect or fork: no standard command uses one) gives the context
*> one source, the source of the context, so a modified chain still runs with that source. Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-ENTRIES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-ALICE          BINARY-LONG.
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
 COPY BRRUN.
 01 WS-CTX                 BINARY-LONG VALUE 1.
 01 WS-KEY-TEXT            PIC X(72).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     MOVE "commands.seed.success" TO WS-KEY-TEXT
     CALL "BX-KEY" USING PB-TEXT WS-KEY-TEXT
     CALL "CMD-TELL" USING CN-PLAYER(WS-ID-ALICE) PB-TEXT
     MOVE "acceptance US13 /entries a tell is sent to the player as Sys" & "tem Chat" TO TL-CASE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-TEXT
     MOVE "commands.seed.success()" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /entries the modifier gives the context one " & "source" TO TL-CASE
     MOVE 7 TO BM-COUNT
     CALL "BR-MODIFY-CALL" USING WS-CTX
     MOVE BM-COUNT TO WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     GOBACK.
 END PROGRAM TEST-CMD-ENTRIES.

 COPY CORETEST.
 COPY CMDTEST.
