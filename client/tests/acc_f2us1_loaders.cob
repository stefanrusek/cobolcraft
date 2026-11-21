*> Acceptance test US1-4 (spec 002 FR-001, FR-002; SC-012), real input: the operator's jar
*> tmp/minecraft-26.3-client.jar (git-ignored; the test FAILS loudly when it is absent) is extracted by the
*> extraction tool (the repository's `make -C extract bin`) into build/generated-test/client-loaders, and the
*> client's content open of the standard set over that directory reports no loader error: the packs status is
*> ok, CONTENT-OPEN answers CT-OK, and the set holds block states and biomes.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US1-LOADERS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-REASON              PIC X(128).
 01 WS-TYPE                BINARY-LONG.
 01 WS-EXIT                BINARY-LONG.
 01 WS-COMMAND             PIC X(512).
 PROCEDURE DIVISION.
     CALL "SYSTEM" USING "test -f tmp/minecraft-26.3-client.jar"
     MOVE RETURN-CODE TO WS-EXIT
     MOVE "acceptance US1-4 the real jar tmp/minecraft-26.3-client.jar is present (the test needs it; "
         & "no skips)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-EXIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE SPACES TO WS-COMMAND
     STRING "rm -rf build/generated-test/client-loaders && make -C extract bin >/dev/null 2>&1; "
         "build/bin/cobolcraft-extract --jar tmp/minecraft-26.3-client.jar --game-dir "
         "build/generated-test/client-loaders-game --generated-dir build/generated-test/client-loaders "
         "--quiet >/dev/null" X"00" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE RETURN-CODE TO WS-EXIT
     MOVE "acceptance US1-4 given the real jar when the extraction tool runs then it exits 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-EXIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE SPACES TO WS-DIR
     MOVE "build/generated-test/client-loaders" TO WS-DIR
     CALL "CONTENT-PACKS-CHECK" USING WS-DIR WS-STATUS WS-REASON
     MOVE "acceptance US1-4 the extracted packs check ok" TO TL-CASE
     MOVE CT-PACKS-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE CT-TYPE-STANDARD TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE "acceptance US1-4 the standard set opens over the extracted packs: no loader error" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US1-4 the opened set has more than 30,000 block states and registries" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF CT-STATE-COUNT > 30000 AND CT-REGISTRY-COUNT > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CONTENT-CLOSE"
     STOP RUN.
