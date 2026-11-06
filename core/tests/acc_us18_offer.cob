*> Acceptance test, US18-6 server side (spec US18 scenario 6; FR-009 pack offer; docs/protocol/03
*> "Configuration sequence" task 3 server_resource_pack; 08 §9.2, §9.7; 09 §3.1 rows 0x09, 0x06): a
*> server configured to offer a pack sends Resource Pack Push after Update Tags, carrying the
*> configured URL, hash, id, required flag and prompt (byte-equal to the 09 §3.1 fixtures), then
*> waits: the non-terminal actions 3 accepted and 4 downloaded send nothing, and configuration
*> continues with Finish Configuration after a terminal action (0, 2, 5, 6, 7, and 1 for a pack
*> that is not required), after which the client's Finish Configuration moves the player to play.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US18-OFFER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ID                  BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-PUSH-ID             BINARY-LONG VALUE 9.
 01 WS-FOUND               BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-REQUIRED            BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-IDS                 PIC X(1024).
 01 WS-TEXT                PIC X(4096).
 01 WS-WANT                PIC X(4096).
 01 WS-PTR                 BINARY-LONG.
 01 WS-WANT-PTR            BINARY-LONG.
 01 WS-EDIT                PIC 9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 1 TO CS-PACK-OFFERED
     MOVE "00112233-4455-6677-8899-aabbccddeeff" TO CS-PACK-ID
     MOVE "http://127.0.0.1:8080/pack.zip" TO CS-PACK-URL
     MOVE "da39a3ee5e6b4b0d3255bfef95601890afd80709" TO CS-PACK-SHA1
     MOVE 1 TO CS-PACK-REQUIRED
     MOVE "Please accept the CobolCraft pack" TO CS-PACK-PROMPT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY

*>   Given a configured (required, with prompt) pack, when a player configures.
     MOVE "acceptance US18-6 given a configured pack when a player configures then Resource "
         & "Pack Push follows Update Tags and no Finish Configuration is sent yet" TO TL-CASE
     MOVE "Alice" TO WS-NAME
     CALL "TEST-CONFIGURE" USING WS-NAME WS-NAME-LENGTH WS-ID
     CALL "TEST-DRAIN-IDS" USING WS-ID WS-IDS
     MOVE "T" TO TL-MODE
     MOVE "2 1 13 15 7x18 14 9" TO TL-EXPECTED
     MOVE WS-IDS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CORE-CONN-CLOSED" USING WS-ID

     MOVE "acceptance US18-6 given a configured pack when a player configures then Resource "
         & "Pack Push carries the URL, hash, id, required flag and prompt "
         & "(config-s2c-09-resource-pack-push-required-prompt.hex)" TO TL-CASE
     MOVE "Bob" TO WS-NAME
     MOVE 3 TO WS-NAME-LENGTH
     CALL "TEST-CONFIGURE" USING WS-NAME WS-NAME-LENGTH WS-ID
     CALL "TEST-DRAIN-PACKET" USING WS-ID WS-PUSH-ID PB-BUFFER WS-FOUND
     MOVE "contract/fixtures/wire/config-s2c-09-resource-pack-push-required-prompt.hex"
         TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

*>   When the client answers accepted, downloaded, then successfully loaded.
     MOVE "acceptance US18-6 given the offered pack when the client answers accepted, "
         & "downloaded, successfully loaded then Finish Configuration follows only the terminal "
         & "action and the client's Finish Configuration enters play" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE 3 TO WS-ACTION
     CALL "TEST-PACK-RESPONSE" USING WS-ID WS-ACTION
     CALL "TEST-DRAIN-IDS" USING WS-ID WS-IDS
     STRING "accepted [" FUNCTION TRIM(WS-IDS) "]" DELIMITED BY SIZE INTO WS-TEXT
     MOVE 4 TO WS-ACTION
     CALL "TEST-PACK-RESPONSE" USING WS-ID WS-ACTION
     CALL "TEST-DRAIN-IDS" USING WS-ID WS-IDS
     STRING FUNCTION TRIM(WS-TEXT) " downloaded [" FUNCTION TRIM(WS-IDS) "]" DELIMITED BY SIZE
         INTO WS-TEXT
     MOVE 0 TO WS-ACTION
     CALL "TEST-PACK-RESPONSE" USING WS-ID WS-ACTION
     CALL "TEST-DRAIN-IDS" USING WS-ID WS-IDS
     STRING FUNCTION TRIM(WS-TEXT) " loaded [" FUNCTION TRIM(WS-IDS) "]" DELIMITED BY SIZE
         INTO WS-TEXT
     MOVE "contract/fixtures/wire/config-c2s-03-finish-configuration.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-ID WS-PATH
     IF CN-PHASE(WS-ID) = PH-PLAY AND CN-CLOSE(WS-ID) = 0
         STRING FUNCTION TRIM(WS-TEXT) " in play" DELIMITED BY SIZE INTO WS-TEXT
     END-IF
     MOVE "T" TO TL-MODE
     MOVE "accepted [] downloaded [] loaded [3] in play" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CORE-CONN-CLOSED" USING WS-ID

*>   Every other terminal action also lets configuration continue: required pack 2, 5, 6, 7;
*>   optional pack 1, 2, 5, 6, 7.
     MOVE "acceptance US18-6 given a configured pack when the client answers any terminal action "
         & "other than declining a required pack then configuration continues with Finish "
         & "Configuration" TO TL-CASE
     MOVE SPACES TO WS-TEXT WS-WANT
     MOVE 1 TO WS-PTR WS-WANT-PTR
     MOVE "Carol" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     PERFORM VARYING WS-REQUIRED FROM 1 BY -1 UNTIL WS-REQUIRED < 0
         MOVE WS-REQUIRED TO CS-PACK-REQUIRED
         CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
         PERFORM VARYING WS-ACTION FROM 0 BY 1 UNTIL WS-ACTION > 7
             IF WS-ACTION NOT = 0 AND WS-ACTION NOT = 3 AND WS-ACTION NOT = 4
                     AND NOT (WS-ACTION = 1 AND WS-REQUIRED = 1)
                 CALL "TEST-CONFIGURE" USING WS-NAME WS-NAME-LENGTH WS-ID
                 CALL "TEST-DRAIN-IDS" USING WS-ID WS-IDS
                 CALL "TEST-PACK-RESPONSE" USING WS-ID WS-ACTION
                 CALL "TEST-DRAIN-IDS" USING WS-ID WS-IDS
                 MOVE WS-REQUIRED TO WS-EDIT
                 STRING "required " WS-EDIT " action " DELIMITED BY SIZE
                     INTO WS-TEXT WITH POINTER WS-PTR
                 MOVE WS-ACTION TO WS-EDIT
                 STRING WS-EDIT " [" FUNCTION TRIM(WS-IDS) "] close " DELIMITED BY SIZE
                     INTO WS-TEXT WITH POINTER WS-PTR
                 MOVE CN-CLOSE(WS-ID) TO WS-EDIT
                 STRING WS-EDIT "; " DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
                 MOVE WS-REQUIRED TO WS-EDIT
                 STRING "required " WS-EDIT " action " DELIMITED BY SIZE
                     INTO WS-WANT WITH POINTER WS-WANT-PTR
                 MOVE WS-ACTION TO WS-EDIT
                 STRING WS-EDIT " [3] close 0; " DELIMITED BY SIZE
                     INTO WS-WANT WITH POINTER WS-WANT-PTR
                 CALL "CORE-CONN-CLOSED" USING WS-ID
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "T" TO TL-MODE
     MOVE WS-WANT TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "PB-FREE" USING PB-BUFFER
     STOP RUN.
 END PROGRAM ACC-US18-OFFER.

 COPY CORETEST.
