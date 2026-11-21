*> Implementation test (coverage lane A; docs/protocol/16-commands-catalog.md section 10.9; core/src/cmds-data.cob): /compute of a number line longer than 112 characters is read through its first 112 (the command still answers with a compute message).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVA-CMD-COMPUTE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-ID-OPAL             BINARY-LONG.
 01 WS-ID-ALICE            BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-NUM                 BINARY-DOUBLE.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/loot".
 01 WS-STATUS              BINARY-LONG.

 01 WS-PAD PIC X(130) VALUE ALL "0".

 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "LOOT-LOAD" USING WS-DIR WS-STATUS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE SPACES TO WS-LINE
     STRING "compute default float 0." FUNCTION TRIM(WS-PAD) "1" DELIMITED BY SIZE INTO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "test cova cmd compute a number line over 112 characters still answers with a compute message" TO TL-CASE
     MOVE 1 TO WS-EXPECTED-N
     MOVE 0 TO WS-NUM
     IF WS-TEXT(1:22) = "command.compute.result"
         MOVE 1 TO WS-NUM
     END-IF
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     STOP RUN.
 END PROGRAM TEST-COVA-CMD-COMPUTE.

 COPY CORETEST.
 COPY CMDTEST.
