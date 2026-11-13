*> Implementation test of the generation-workers key (server/src/config-file.cob; operator-surface §2, docs/design/generation-worker.md): a missing key
*> sizes the pool from the processors (auto); auto does the same; 0 to 4 set the pool size exactly; a later line wins.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CONFIG-WORKERS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COREAPI.
 COPY TESTLIB.
 01 WS-SCRATCH             PIC X(256) VALUE "build/server-test-config-workers".
 01 WS-CONF                PIC X(4096).
 01 WS-PORT                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-AUTO                BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "SVT-SCRATCH" USING WS-SCRATCH
     CALL "GEN-WORKERS-AUTO"
     CALL "GEN-WORKERS-GET" USING WS-AUTO
     MOVE 0 TO WS-N
     CALL "GEN-WORKERS-CONFIG" USING WS-N
     MOVE "port=25565" TO WS-CONF
     CALL "SVT-WRITE-CONF" USING WS-CONF
     CALL "SV-CONFIG-LOAD" USING CORE-SETTINGS WS-PORT
     CALL "GEN-WORKERS-GET" USING WS-N
     MOVE "test config workers without the key the pool is sized from the processors" TO TL-CASE
     MOVE WS-N TO TL-OBSERVED-N
     MOVE WS-AUTO TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "port=25565|generation-workers=2" TO WS-CONF
     CALL "SVT-WRITE-CONF" USING WS-CONF
     CALL "SV-CONFIG-LOAD" USING CORE-SETTINGS WS-PORT
     CALL "GEN-WORKERS-GET" USING WS-N
     MOVE "test config workers generation-workers=2 sets two workers" TO TL-CASE
     MOVE WS-N TO TL-OBSERVED-N
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "port=25565|generation-workers=0" TO WS-CONF
     CALL "SVT-WRITE-CONF" USING WS-CONF
     CALL "SV-CONFIG-LOAD" USING CORE-SETTINGS WS-PORT
     CALL "GEN-WORKERS-GET" USING WS-N
     MOVE "test config workers generation-workers=0 turns the workers off" TO TL-CASE
     MOVE WS-N TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "port=25565|generation-workers=4|generation-workers=auto" TO WS-CONF
     CALL "SVT-WRITE-CONF" USING WS-CONF
     CALL "SV-CONFIG-LOAD" USING CORE-SETTINGS WS-PORT
     CALL "GEN-WORKERS-GET" USING WS-N
     MOVE "test config workers a later line wins and auto is the processor-sized pool" TO TL-CASE
     MOVE WS-N TO TL-OBSERVED-N
     MOVE WS-AUTO TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "port=25565|generation-workers=4" TO WS-CONF
     CALL "SVT-WRITE-CONF" USING WS-CONF
     CALL "SV-CONFIG-LOAD" USING CORE-SETTINGS WS-PORT
     CALL "GEN-WORKERS-GET" USING WS-N
     MOVE "test config workers generation-workers=4 is the largest pool" TO TL-CASE
     MOVE WS-N TO TL-OBSERVED-N
     MOVE 4 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-CONFIG-WORKERS.
 COPY SVTEST.
