*> Implementation test of the server pack task in core/src/config-phase.cob (US18; 03 task 3
*> server_resource_pack; 08 §9.7): a Resource Pack Response for another pack id is ignored while the
*> task waits; a Finish Configuration before the server's closes the connection; the pack UUID
*> setting is read in either case; an empty hash setting is sent as an empty String.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CONFIG-PACK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ID                  BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-SIX                 BINARY-LONG VALUE 6.
 01 WS-OTHER-UUID          PIC X(16) VALUE ALL "A".
 01 WS-HASH-LENGTH         BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-TEXT                PIC X(256).
 01 WS-EDIT                PIC -(9)9.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE 1 TO CS-PACK-OFFERED
     MOVE "00112233-4455-6677-8899-AABBCCDDEEFF" TO CS-PACK-ID
     MOVE "http://127.0.0.1:8080/pack.zip" TO CS-PACK-URL
     MOVE "da39a3ee5e6b4b0d3255bfef95601890afd80709" TO CS-PACK-SHA1
     MOVE 0 TO CS-PACK-REQUIRED
     MOVE SPACES TO CS-PACK-PROMPT
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY

     MOVE "test config pack an upper-case pack id setting gives the same Push as the lower-case "
         & "fixture" TO TL-CASE
     MOVE "contract/fixtures/wire/config-s2c-09-resource-pack-push-optional.hex" TO WS-PATH
     CALL "CONFIG-PACK-PUSH-BUILD" USING CORE-SETTINGS PB-BUFFER
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "test config pack an empty hash setting is sent as an empty hash String" TO TL-CASE
     MOVE SPACES TO CS-PACK-SHA1
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CONFIG-PACK-PUSH-BUILD" USING CORE-SETTINGS PB-BUFFER
*>   id (1 byte), UUID (16), URL length (1) and URL (30): the hash length is byte 49.
     MOVE 48 TO PB-POS
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-HASH-LENGTH
     MOVE SPACES TO WS-TEXT
     MOVE WS-HASH-LENGTH TO WS-EDIT
     STRING "hash length " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
     MOVE PB-LENGTH TO WS-EDIT
     STRING FUNCTION TRIM(WS-TEXT) " packet " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
         INTO WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE "hash length 0 packet 51" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "da39a3ee5e6b4b0d3255bfef95601890afd80709" TO CS-PACK-SHA1

     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS

     MOVE "test config pack a Resource Pack Response for another pack id is ignored while the "
         & "task waits; the offered id's terminal action then sends Finish Configuration"
         TO TL-CASE
     CALL "TEST-CONFIGURE" USING WS-NAME WS-NAME-LENGTH WS-ID
     CALL "TEST-DRAIN-IDS" USING WS-ID WS-IDS
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-SIX
     CALL "PB-PUT-UUID" USING PB-BUFFER WS-OTHER-UUID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "TEST-FEED-BUFFER" USING WS-ID PB-BUFFER
     CALL "TEST-DRAIN-IDS" USING WS-ID WS-IDS
     MOVE SPACES TO WS-TEXT
     STRING "other [" FUNCTION TRIM(WS-IDS) "]" DELIMITED BY SIZE INTO WS-TEXT
     CALL "TEST-PACK-RESPONSE" USING WS-ID WS-ZERO
     CALL "TEST-DRAIN-IDS" USING WS-ID WS-IDS
     STRING FUNCTION TRIM(WS-TEXT) " offered [" FUNCTION TRIM(WS-IDS) "]" DELIMITED BY SIZE
         INTO WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE "other [] offered [3]" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CORE-CONN-CLOSED" USING WS-ID

     MOVE "test config pack a client Finish Configuration while the pack task waits closes the "
         & "connection" TO TL-CASE
     MOVE "Bob" TO WS-NAME
     MOVE 3 TO WS-NAME-LENGTH
     CALL "TEST-CONFIGURE" USING WS-NAME WS-NAME-LENGTH WS-ID
     CALL "TEST-DRAIN-IDS" USING WS-ID WS-IDS
     MOVE "contract/fixtures/wire/config-c2s-03-finish-configuration.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-ID WS-PATH
     MOVE "T" TO TL-MODE
     MOVE SPACES TO WS-TEXT
     MOVE CN-CLOSE(WS-ID) TO WS-EDIT
     STRING "close " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "close 1" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CORE-CONN-CLOSED" USING WS-ID

     CALL "PB-FREE" USING PB-BUFFER
     STOP RUN.
 END PROGRAM TEST-CONFIG-PACK.

 COPY CORETEST.
