*> contract_wire_server.cob chunk cases (test infrastructure; docs/protocol/09-cobolcraft-profile.md
*> §3.2): the core's Level Chunk With Light for chunk (0, 0) of cobolcraft:main, Chunk Batch Start,
*> Chunk Batch Finished (9) and Set Chunk Cache Center (-1, 2) equal their fixtures; the serverbound
*> Chunk Batch Received fixture decodes to desired chunks per tick 9.0.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. WIRE-CHUNK-CASES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-RATE                FLOAT-SHORT.
 01 WS-PATH                PIC X(256).
 01 WS-PTR                 BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT-RATE           PIC -(5)9.9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY

     MOVE "contract wire server Level Chunk With Light of chunk (0, 0) of cobolcraft:main equals "
         & "play-s2c-2e-level-chunk-with-light-spawn.hex" TO TL-CASE
     MOVE 0 TO WS-CX WS-CZ
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CHUNK-PACKET-BUILD" USING WS-DIM WS-CX WS-CZ PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-2e-level-chunk-with-light-spawn.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server Chunk Batch Start equals play-s2c-0c-chunk-batch-start.hex"
         TO TL-CASE
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CHUNK-BATCH-START-BUILD" USING PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-0c-chunk-batch-start.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server Chunk Batch Finished of 9 chunks equals "
         & "play-s2c-0b-chunk-batch-finished.hex" TO TL-CASE
     MOVE 9 TO WS-COUNT
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CHUNK-BATCH-FINISHED-BUILD" USING WS-COUNT PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-0b-chunk-batch-finished.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server Set Chunk Cache Center (-1, 2) equals "
         & "play-s2c-60-set-chunk-cache-center.hex" TO TL-CASE
     MOVE -1 TO WS-CX
     MOVE 2 TO WS-CZ
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CHUNK-CACHE-CENTER-BUILD" USING WS-CX WS-CZ PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-60-set-chunk-cache-center.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server Chunk Batch Received decodes: id 11, desired chunks per tick 9.0, "
         & "no bytes left" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-0b-chunk-batch-received.hex" TO WS-PATH
     CALL "TEST-LOAD-HEX" USING WS-PATH PB-BUFFER
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
     CALL "PB-GET-FLOAT" USING PB-BUFFER WS-RATE
     MOVE "T" TO TL-MODE
     MOVE "11 9.0 0 0" TO TL-EXPECTED
     MOVE WS-ID TO WS-EDIT
     MOVE WS-RATE TO WS-EDIT-RATE
     COMPUTE WS-COUNT = PB-LENGTH - PB-POS
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT-RATE) " " PB-ERROR " "
         DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
     MOVE WS-COUNT TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM WIRE-CHUNK-CASES.
