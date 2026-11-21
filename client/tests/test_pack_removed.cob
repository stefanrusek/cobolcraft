*> Edge-case test (spec edge case; FR-012): a pack removed (or renamed) while it is enabled makes the stack fall
*> back to the packs that remain and the pack screen says so: "<pack> cannot be used: the pack is missing"
*> (cobolcraft.screen.packs.problem.missing), and the pack stays enabled in the options (it is back when the
*> file is).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PACK-REMOVED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-pack-removed".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 30.
 01 WS-NAMES               PIC X(256) VALUE "alpha".
 01 WS-IDS                 PIC X(256) VALUE "file/alpha".
 01 WS-SCREEN              BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-HITS                BINARY-LONG.
 01 WS-E1                  PIC 9.
 01 WS-E2                  PIC 9.
 01 WS-E3                  PIC 9.
 01 WS-ID                  PIC X(80).
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-KEY                 PIC X(80) VALUE "cobolcraft.screen.packs.problem.missing".
 01 WS-KEY-LENGTH          BINARY-LONG VALUE 39.
 01 WS-NO-ARG              PIC X(256).
 01 WS-NO-ARG-LENGTH       BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "TEST-PACK-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH WS-NAMES
     CALL "TEST-PACK-ENABLE" USING CLIENT-STATE WS-IDS
     MOVE PK-COUNT TO WS-E1
     CALL "SYSTEM" USING "rm -rf build/client-test-pack-removed/resourcepacks/alpha"
     CALL "LOCAL-PACKS-SCAN" USING CLIENT-STATE
     CALL "PACKS-RELOAD" USING CLIENT-STATE
     MOVE PK-COUNT TO WS-E2
     MOVE OP-COUNT TO WS-E3
     MOVE "pack removed an enabled pack whose folder is gone leaves the built-in pack alone in the "
         & "stack and stays enabled in the options" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     STRING "before " WS-E1 " after " WS-E2 " enabled " WS-E3 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "before 2 after 1 enabled 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SCR-PACKS TO WS-SCREEN
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE ZERO TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "alpha cannot be used: the pack is missing"
     MOVE "pack removed the pack screen says the pack is missing" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-HITS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The same problem is told once however often it is found.
     MOVE "file/alpha" TO WS-ID
     MOVE 10 TO WS-ID-LENGTH
     CALL "PACK-ERROR-NAMED" USING CLIENT-STATE WS-ID WS-ID-LENGTH WS-KEY WS-KEY-LENGTH WS-NO-ARG
         WS-NO-ARG-LENGTH
     MOVE "pack removed the same problem is listed once" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PK-ERROR-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-PACK-REMOVED.
 COPY CLTEST.
 COPY PACKTEST.
