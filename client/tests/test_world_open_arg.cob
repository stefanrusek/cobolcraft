*> Implementation test of WORLD-OPEN-ARG (client/src/screens/world-list.cob; the --world option / CC_WORLD): the
*> named save folder opens as if selected in the world list and Play pressed; a missing folder, a standard
*> world with the packs not ok and a world the core refuses leave the client on the title screen.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-WORLD-OPEN-ARG.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-open-arg".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 26.
 01 WS-COMMAND             PIC X(300).
 01 WS-E1                  PIC 9.
 01 WS-E2                  PIC 99.
 01 WS-X2                  PIC 99.
 01 WS-L1                  PIC 99.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "TEST-SP-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH
     MOVE "mkdir -p build/client-test-open-arg/saves/a_real/dimensions/minecraft/overworld/region" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "cp -R core/tests/fixtures/world26/. build/client-test-open-arg/saves/a_real/" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "mkdir -p build/client-test-open-arg/saves/b_untyped/dimensions/minecraft/overworld/region" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "cp core/tests/fixtures/world26-untyped/level.dat build/client-test-open-arg/saves/b_untyped/level.dat"
         TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "mkdir -p 'build/client-test-open-arg/saves/New World (9)'" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND

*>   No --world: nothing happens, not even a read of saves/.
     MOVE 0 TO CL-WORLD-LENGTH
     CALL "WORLD-OPEN-ARG" USING CLIENT-STATE
     MOVE SM-SCREEN TO WS-E2
     MOVE SP-ACTIVE TO WS-E1
     MOVE WL-COUNT TO WS-L1
     MOVE "world-open-arg given no world named then the title screen stays and nothing opens" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING "screen " WS-E2 " active " WS-E1 " list " WS-L1 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE SPACES TO TL-EXPECTED
     MOVE SCR-TITLE TO WS-X2
     STRING "screen " WS-X2 " active 0 list 00" DELIMITED BY SIZE INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A folder that does not exist.
     MOVE "nowhere" TO CL-WORLD
     MOVE 7 TO CL-WORLD-LENGTH
     CALL "WORLD-OPEN-ARG" USING CLIENT-STATE
     MOVE SM-SCREEN TO WS-E2
     MOVE SP-ACTIVE TO WS-E1
     MOVE "world-open-arg given a folder that is not in saves then the title screen stays" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING "screen " WS-E2 " active " WS-E1 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE SPACES TO TL-EXPECTED
     STRING "screen " WS-X2 " active 0" DELIMITED BY SIZE INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A standard world with the packs not ok.
     MOVE CT-PACKS-STALE TO CL-PACKS-STATUS
     MOVE SPACES TO CL-WORLD
     MOVE "a_real" TO CL-WORLD
     MOVE 6 TO CL-WORLD-LENGTH
     CALL "WORLD-OPEN-ARG" USING CLIENT-STATE
     MOVE SM-SCREEN TO WS-E2
     MOVE SP-ACTIVE TO WS-E1
     MOVE "world-open-arg given a standard world and packs not ok then it is not opened and the title stays" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING "screen " WS-E2 " active " WS-E1 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE SCR-TITLE TO WS-X2
     MOVE SPACES TO TL-EXPECTED
     STRING "screen " WS-X2 " active 0" DELIMITED BY SIZE INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Packs ok: a world the core refuses (no world type).
     MOVE CT-PACKS-OK TO CL-PACKS-STATUS
     MOVE SPACES TO CL-WORLD
     MOVE "b_untyped" TO CL-WORLD
     MOVE 9 TO CL-WORLD-LENGTH
     CALL "WORLD-OPEN-ARG" USING CLIENT-STATE
     MOVE SM-SCREEN TO WS-E2
     MOVE SP-ACTIVE TO WS-E1
     MOVE "world-open-arg given a world the core refuses then it is not opened and the title stays" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING "screen " WS-E2 " active " WS-E1 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE SCR-TITLE TO WS-X2
     MOVE SPACES TO TL-EXPECTED
     STRING "screen " WS-X2 " active 0" DELIMITED BY SIZE INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A folder without level.dat whose name has spaces opens (a new cobolcraft world), on the connecting screen.
     MOVE SPACES TO CL-WORLD
     MOVE "New World (9)" TO CL-WORLD
     MOVE 13 TO CL-WORLD-LENGTH
     CALL "WORLD-OPEN-ARG" USING CLIENT-STATE
     MOVE SM-SCREEN TO WS-E2
     MOVE SP-ACTIVE TO WS-E1
     MOVE "world-open-arg given a save folder then it opens as Play does: hosted and the connecting screen" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING "screen " WS-E2 " active " WS-E1 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE SPACES TO TL-EXPECTED
     MOVE SCR-CONNECTING TO WS-X2
     STRING "screen " WS-X2 " active 1" DELIMITED BY SIZE INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-WORLD-OPEN-ARG.
 COPY CLTEST.
