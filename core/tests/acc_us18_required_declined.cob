*> Acceptance test, US18-7 server side (spec US18 scenario 7; docs/protocol/08 §9.7, §9.8;
*> standin-content §17 cobolcraft.disconnect.pack_required; 09 §3.1 row "Disconnect (pack
*> required)"): a player who declines (action 1) a pack the server offered as required is sent the
*> configuration Disconnect with the §17 required-pack text (byte-equal to
*> config-s2c-02-disconnect-pack-required.hex), nothing else, and the connection is closed.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US18-REQUIRED-DECLINED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ID                  BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-ACTION              BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-TEXT                PIC X(256).
 01 WS-EDIT                PIC -(9)9.
 01 WS-FIXTURE             PIC X(256)
     VALUE "contract/fixtures/wire/config-s2c-02-disconnect-pack-required.hex".
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE 1 TO CS-PACK-OFFERED
     MOVE "00112233-4455-6677-8899-aabbccddeeff" TO CS-PACK-ID
     MOVE "http://127.0.0.1:8080/pack.zip" TO CS-PACK-URL
     MOVE "da39a3ee5e6b4b0d3255bfef95601890afd80709" TO CS-PACK-SHA1
     MOVE 1 TO CS-PACK-REQUIRED
     MOVE SPACES TO CS-PACK-PROMPT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS

*>   Given a required pack offered to a configuring player.
     CALL "TEST-CONFIGURE" USING WS-NAME WS-NAME-LENGTH WS-ID
     CALL "TEST-DRAIN-IDS" USING WS-ID WS-IDS

*>   When the player declines it.
     MOVE 1 TO WS-ACTION
     CALL "TEST-PACK-RESPONSE" USING WS-ID WS-ACTION
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING WS-ID PB-BUFFER WS-CLOSE
     CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME

     MOVE "acceptance US18-7 given a required pack when the player declines then they are "
         & "disconnected with the §17 required-pack text "
         & "(config-s2c-02-disconnect-pack-required.hex)" TO TL-CASE
     CALL "TEST-SAME-AS-FIXTURE" USING PK-BUFFER WS-FIXTURE TESTLIB-ASSERT

     MOVE "acceptance US18-7 given a required pack when the player declines then the Disconnect "
         & "is the only packet, the connection is closed and no player is in play" TO TL-CASE
     MOVE 0 TO WS-COUNT
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE SPACES TO WS-TEXT
     MOVE WS-COUNT TO WS-EDIT
     STRING "more packets " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
     MOVE WS-CLOSE TO WS-EDIT
     STRING FUNCTION TRIM(WS-TEXT) " close " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
         INTO WS-TEXT
     CALL "CORE-STATUS-GET" USING CORE-STATUS
     MOVE CST-PLAYERS-ONLINE TO WS-EDIT
     STRING FUNCTION TRIM(WS-TEXT) " online " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
         INTO WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE "more packets 0 close 1 online 0" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-FREE" USING PK-BUFFER
     STOP RUN.
 END PROGRAM ACC-US18-REQUIRED-DECLINED.

 COPY CORETEST.
