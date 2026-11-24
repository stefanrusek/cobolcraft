*> Test of the one-time migration (R8; spec edge case): with no options.txt, the legacy options.dat (contract/fixtures/client/options.dat:
*> EnabledPacks "vanilla" and "file/Faithful 32x - 26.3.zip", top first) gives the enabled packs; options.dat is never written again
*> (its bytes are the same after a save) and, once an options.txt exists, it is not read again (a different options.dat is ignored).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-OPTIONS-MIGRATION.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-options-migration".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 35.
 01 WS-DAT                 PIC X(256) VALUE "build/client-test-options-migration/options.dat".
 01 WS-COPY                PIC X(256) VALUE "build/client-test-options-migration/options.dat.copy".
 01 WS-SAME                BINARY-LONG.
 01 WS-D1                  PIC 9.
 PROCEDURE DIVISION.
     CALL "SYSTEM" USING "rm -rf build/client-test-options-migration && mkdir -p build/client-test-options-migration"
     CALL "SYSTEM" USING "cp contract/fixtures/client/options.dat build/client-test-options-migration/options.dat"
     CALL "SYSTEM" USING "cp contract/fixtures/client/options.dat build/client-test-options-migration/options.dat.copy"
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE "Alice" TO CL-NAME
     MOVE 5 TO CL-NAME-LENGTH
     MOVE WS-DIR TO CL-GAME-DIR
     MOVE WS-DIR-LENGTH TO CL-GAME-DIR-LENGTH
     CALL "OPTIONS-LOAD" USING CLIENT-STATE
     MOVE "options migration: options.dat gives the two enabled packs, top first" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "2 vanilla file/Faithful 32x - 26.3.zip" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE OP-COUNT TO WS-D1
     STRING WS-D1 " " OP-ID(1)(1:OP-ID-LENGTH(1)) " " OP-ID(2)(1:OP-ID-LENGTH(2)) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "OPTIONS-SAVE" USING CLIENT-STATE
     CALL "TEST-OPT-SAME" USING WS-DAT WS-COPY WS-SAME
     MOVE "options migration: a save leaves options.dat as it was" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-SAME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "SYSTEM" USING "cp contract/fixtures/client/options-empty.dat build/client-test-options-migration/options.dat"
     CALL "OPTIONS-LOAD" USING CLIENT-STATE
     MOVE "options migration: with options.txt present the options.dat is not read again" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE OP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "SYSTEM" USING "rm build/client-test-options-migration/options.txt"
     CALL "SYSTEM" USING "cp contract/fixtures/client/options-extra-tags.dat build/client-test-options-migration/options.dat"
     CALL "OPTIONS-LOAD" USING CLIENT-STATE
     MOVE "options migration: an options.dat with other tags gives its one pack" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE OP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "SYSTEM" USING "echo garbage > build/client-test-options-migration/options.dat"
     CALL "SYSTEM" USING "rm -f build/client-test-options-migration/options.txt"
     CALL "OPTIONS-LOAD" USING CLIENT-STATE
     MOVE "options migration: an options.dat that cannot be read gives no packs and the game starts" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE OP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-OPTIONS-MIGRATION.

 COPY OPTTEST.
 COPY CLTEST.
