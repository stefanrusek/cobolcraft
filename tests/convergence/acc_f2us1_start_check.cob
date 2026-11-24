*> Convergence acceptance test of the start-up check on real data (spec 002 US1; FR-001, FR-002, SC-012;
*> docs/protocol/22 sections 8.2 and 9.2): the extraction tool runs on the operator's jar (tmp/minecraft-26.3-client.jar,
*> git-ignored; the test fails loudly without it) into build/generated-test, then the client's start-up check reports
*> the packs ok, a server started on the same directory with world-type=standard opens the standard set with the packs
*> ok and the registries loaded (no loader refused the data: the server would have exited with code 10), and after the
*> manifest is changed to name another jar (a tampered manifest) both the client's check and the server's check (the same core program, CORE-PACKS-STATUS
*> of the generated directory) report stale.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US1-START-CHECK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-f2us1-start-check".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 28.
 01 WS-CONF                PIC X(1024)
     VALUE "view-distance=2|hostile-mobs=false|world-type=standard|generated-dir=../../generated-test".
 01 WS-GENERATED           PIC X(20) VALUE "build/generated-test".
 01 WS-DIR-FULL            PIC X(1100).
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-COMMAND             PIC X(300).
 01 WS-RETURN              BINARY-LONG.
 01 WS-STATUS-CLIENT       BINARY-LONG.
 01 WS-STATUS-SERVER       BINARY-LONG.
 01 WS-REASON              PIC X(128).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-COMMAND
     STRING "build/bin/cobolcraft-extract --jar tmp/minecraft-26.3-client.jar "
         "--generated-dir build/generated-test --force --quiet" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND RETURNING WS-RETURN
     MOVE "T" TO TL-MODE
     MOVE "acceptance US1 given the operator's jar when the extraction tool runs then it ends with exit 0"
         TO TL-CASE
     MOVE "exit 0" TO TL-EXPECTED
     MOVE WS-RETURN TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING "exit " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-ALICE
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE SPACES TO CL-GENERATED-DIR
     MOVE WS-GENERATED TO CL-GENERATED-DIR
     MOVE 20 TO CL-GENERATED-DIR-LENGTH
     CALL "PACKS-STATUS-CHECK" USING CLIENT-STATE
     MOVE CL-PACKS-STATUS TO WS-STATUS-CLIENT
     CALL "CV-SERVER-START" USING CONVH WS-CONF
     MOVE "acceptance US1 SC-012 given the extracted packs when the client checks them and a server "
         & "opens a standard world on them then the client reports ok, the server's set is the "
         & "standard one with the packs ok and the registries loaded" TO TL-CASE
     MOVE "client 0 set 0 open 1 packs 0 registries 1" TO TL-EXPECTED
     MOVE WS-STATUS-CLIENT TO WS-E1
     MOVE CT-SET-TYPE TO WS-E2
     MOVE 0 TO WS-E3
     IF CT-BLOCK-COUNT > 1000 AND CT-ITEM-COUNT > 1000
         MOVE 1 TO WS-E3
     END-IF
     MOVE SPACES TO TL-OBSERVED
     STRING "client " FUNCTION TRIM(WS-E1) " set " FUNCTION TRIM(WS-E2) " open " CT-OPEN
         " packs " CT-PACKS-STATUS " registries " FUNCTION TRIM(WS-E3)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CV-SERVER-STOP" USING CONVH

*>   A tampered manifest is stale for both.
     MOVE SPACES TO WS-COMMAND
     STRING "sed -i.bak 's/^jar-sha256=4/jar-sha256=5/' build/generated-test/manifest.txt"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND RETURNING WS-RETURN
     CALL "PACKS-STATUS-CHECK" USING CLIENT-STATE
     MOVE CL-PACKS-STATUS TO WS-STATUS-CLIENT
     MOVE SPACES TO WS-DIR-FULL
     MOVE WS-GENERATED TO WS-DIR-FULL
     CALL "CORE-PACKS-STATUS" USING WS-DIR-FULL WS-STATUS-SERVER WS-REASON
     MOVE "acceptance US1 SC-012 given a manifest naming another jar (its sha256 line changed) when the client and the server check the "
         & "packs then both report stale" TO TL-CASE
     MOVE "client 3 server 3" TO TL-EXPECTED
     MOVE WS-STATUS-CLIENT TO WS-E1
     MOVE WS-STATUS-SERVER TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "client " FUNCTION TRIM(WS-E1) " server " FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-F2US1-START-CHECK.
