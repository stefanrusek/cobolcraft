*> Acceptance test, US17 edge case "a guest joins with the same name as the host" (spec US17 edge
*> cases; FR-010; standin-content §17 cobolcraft.disconnect.name_is_host [name]): in a world opened to
*> others whose host Alice is in play, a network login named Alice is refused with Login Disconnect
*> (byte-equal to login-s2c-00-login-disconnect-name-in-use.hex) and closed; the host stays in play
*> on her own connection.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US17-HOST-NAME.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-ALICE-NAME          PIC X(16) VALUE "Alice".
 01 WS-LENGTH-5            BINARY-LONG VALUE 5.
 01 WS-HOST                BINARY-LONG.
 01 WS-GUEST               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-GUEST-MODE          BINARY-LONG VALUE 0.
 01 WS-GUEST-OPERATOR      BINARY-LONG VALUE 0.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-FIXTURE             PIC X(256)
     VALUE "contract/fixtures/wire/login-s2c-00-login-disconnect-name-in-use.hex".
 01 WS-TEXT                PIC X(256).
 01 WS-EDIT                PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 1 TO CS-HOST-KIND
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE WS-ALICE-NAME TO CS-HOST-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     CALL "TEST-JOIN" USING WS-ALICE-NAME WS-LENGTH-5 WS-HOST
     CALL "CORE-OPEN-TO-OTHERS" USING WS-GUEST-MODE WS-GUEST-OPERATOR

*>   When a guest logs in over a network connection with the host's name.
     MOVE CORE-CONN-NETWORK TO WS-KIND
     CALL "CORE-CONN-OPEN" USING WS-KIND WS-GUEST
     MOVE "contract/fixtures/wire/handshake-c2s-00-intention-login.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-GUEST WS-PATH
     MOVE "contract/fixtures/wire/login-c2s-00-hello.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-GUEST WS-PATH
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING WS-GUEST PB-BUFFER WS-CLOSE
     CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME

     MOVE "acceptance US17 edge given a guest with the host's name when they log in then Login "
         & "Disconnect carries the §17 name-in-use text (login-s2c-00-login-disconnect-name-in-use"
         & ".hex)" TO TL-CASE
     CALL "TEST-SAME-AS-FIXTURE" USING PK-BUFFER WS-FIXTURE TESTLIB-ASSERT

     MOVE "acceptance US17 edge given a guest with the host's name when they log in then the guest "
         & "connection is closed with no player and the host stays in play on her connection"
         TO TL-CASE
     CALL "PLAYER-FIND-NAME" USING WS-ALICE-NAME WS-LENGTH-5 WS-ROW
     MOVE SPACES TO WS-TEXT
     MOVE WS-CLOSE TO WS-EDIT
     STRING "guest close " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
     MOVE CN-PLAYER(WS-GUEST) TO WS-EDIT
     STRING FUNCTION TRIM(WS-TEXT) " player " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
         INTO WS-TEXT
     IF WS-ROW > 0
         IF PL-CONN(WS-ROW) = WS-HOST AND CN-PHASE(WS-HOST) = PH-PLAY AND CN-CLOSE(WS-HOST) = 0
             STRING FUNCTION TRIM(WS-TEXT) "; host in play" DELIMITED BY SIZE INTO WS-TEXT
         END-IF
     END-IF
     CALL "CORE-STATUS-GET" USING CORE-STATUS
     MOVE CST-PLAYERS-ONLINE TO WS-EDIT
     STRING FUNCTION TRIM(WS-TEXT) "; online " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
         INTO WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE "guest close 1 player 0; host in play; online 1" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-FREE" USING PK-BUFFER
     STOP RUN.
 END PROGRAM ACC-US17-HOST-NAME.

 COPY CORETEST.
