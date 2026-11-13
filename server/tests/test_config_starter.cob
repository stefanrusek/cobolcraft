*> Implementation test of the starter-kit key (server/src/config-file.cob; operator-surface §2, docs/design/world-types.md "Starter kit"): a missing key
*> leaves the kit on; false turns it off, true turns it on again; a later line wins.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CONFIG-STARTER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COREAPI.
 COPY TESTLIB.
 01 WS-SCRATCH             PIC X(256) VALUE "build/server-test-config-starter".
 01 WS-CONF                PIC X(4096).
 01 WS-PORT                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "SVT-SCRATCH" USING WS-SCRATCH
     MOVE 0 TO WS-N
     CALL "STARTER-KIT-CONFIG" USING WS-N
     MOVE "port=25565" TO WS-CONF
     CALL "SVT-WRITE-CONF" USING WS-CONF
     CALL "SV-CONFIG-LOAD" USING CORE-SETTINGS WS-PORT
     CALL "STARTER-KIT-GET" USING WS-N
     MOVE "test config starter without the key the kit is on" TO TL-CASE
     MOVE WS-N TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "port=25565|starter-kit=false" TO WS-CONF
     CALL "SVT-WRITE-CONF" USING WS-CONF
     CALL "SV-CONFIG-LOAD" USING CORE-SETTINGS WS-PORT
     CALL "STARTER-KIT-GET" USING WS-N
     MOVE "test config starter starter-kit=false turns the kit off" TO TL-CASE
     MOVE WS-N TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "port=25565|starter-kit=false|starter-kit=true" TO WS-CONF
     CALL "SVT-WRITE-CONF" USING WS-CONF
     CALL "SV-CONFIG-LOAD" USING CORE-SETTINGS WS-PORT
     CALL "STARTER-KIT-GET" USING WS-N
     MOVE "test config starter a later starter-kit=true wins" TO TL-CASE
     MOVE WS-N TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-CONFIG-STARTER.
 COPY SVTEST.
