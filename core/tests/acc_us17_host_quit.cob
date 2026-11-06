*> Acceptance test, US17-4 and US17-5 core half (spec US17 scenarios 4, 5; FR-014, FR-017;
*> contracts/core-host-api.md §2 CORE-STOP, CORE-OPEN-TO-OTHERS; standin-content §17
*> cobolcraft.disconnect.host_closed). Hosty's single-player world (extra dimensions on) is opened to
*> others; the guests Bob and Carol join over network connections. Bob travels to
*> cobolcraft:subroutine by the goto_pad at (6, 54, 12), steps to (8.5, 35, 13.5) facing yaw 45,
*> pitch 10, and his health, food, held slot and inventory change. When the host quits (CORE-STOP
*> with the host-closed text) the world is saved and each guest's last packet is the host-closed
*> Disconnect (play-s2c-20-disconnect-host-closed.hex, in a compressed frame) with the close flag.
*> When the host reopens the world, opens it to others again and Bob rejoins, Bob's stored state is
*> as he left it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US17-HOST-QUIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-WORLD               PIC X(64) VALUE Z"build/core-test-world".
 01 WS-REASON              PIC X(64) VALUE Z"cobolcraft.disconnect.host_closed".
 01 WS-CREATED             BINARY-LONG.
 01 WS-HOST-NAME           PIC X(16) VALUE "Hosty".
 01 WS-BOB-NAME            PIC X(16) VALUE "Bob".
 01 WS-CAROL-NAME          PIC X(16) VALUE "Carol".
 01 WS-LENGTH-5            BINARY-LONG VALUE 5.
 01 WS-LENGTH-3            BINARY-LONG VALUE 3.
 01 WS-HOST                BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-CAROL               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-GUEST-MODE          BINARY-LONG VALUE 0.
 01 WS-GUEST-OPERATOR      BINARY-LONG VALUE 0.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQUENCE            BINARY-LONG VALUE 1.
 01 WS-MOVE                BINARY-LONG VALUE 31.
 01 WS-FLAGS               BINARY-LONG VALUE 1.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-PITCH               FLOAT-SHORT.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-THRESHOLD           BINARY-LONG VALUE 256.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-CLOSE-BOB           BINARY-LONG.
 01 WS-FIXTURE             PIC X(256)
     VALUE "contract/fixtures/wire/play-s2c-20-disconnect-host-closed.hex".
 01 WS-BOB-BEFORE          PIC X(8192).
 01 WS-TEXT                PIC X(8192).
 01 WS-EDIT                PIC -(9)9.
 01 WS-PACKET              PIC X(65536).
 01 WS-PACKET-LENGTH       BINARY-LONG.
 01 B-AREA                 PIC X(65536) BASED.
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 1 TO CS-HOST-KIND CS-EXTRA-DIMENSIONS
     MOVE 0 TO CS-HOSTILE-MOBS CS-WEATHER-CHANGES
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE WS-HOST-NAME TO CS-HOST-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     CALL "TEST-JOIN" USING WS-HOST-NAME WS-LENGTH-5 WS-HOST
     CALL "CORE-OPEN-TO-OTHERS" USING WS-GUEST-MODE WS-GUEST-OPERATOR
     CALL "TEST-JOIN-NETWORK" USING WS-BOB-NAME WS-LENGTH-3 WS-BOB
     CALL "TEST-JOIN-NETWORK" USING WS-CAROL-NAME WS-LENGTH-5 WS-CAROL

*>   Bob plays: travels, moves, and his health, food, held slot and inventory change.
     MOVE DIM-MAIN TO WS-DIM
     MOVE 6 TO WS-X
     MOVE 54 TO WS-Y
     MOVE 12 TO WS-Z
     MOVE TRAVEL-PAD-STATE TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "TEST-USE-ON" USING WS-BOB WS-X WS-Y WS-Z WS-FACE WS-SEQUENCE
     CALL "TEST-ACCEPT-TELEPORT" USING WS-BOB
     MOVE 8.5 TO WS-FX
     MOVE 35 TO WS-FY
     MOVE 13.5 TO WS-FZ
     MOVE 45 TO WS-YAW
     MOVE 10 TO WS-PITCH
     CALL "TEST-MOVE" USING WS-BOB WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     MOVE CN-PLAYER(WS-BOB) TO WS-ROW
     MOVE 15.5 TO PL-HEALTH(WS-ROW)
     MOVE 12 TO PL-FOOD(WS-ROW)
     MOVE 3 TO PL-HELD(WS-ROW)
     MOVE 1 TO PL-SLOT-ITEM(WS-ROW, 5)
     MOVE 7 TO PL-SLOT-COUNT(WS-ROW, 5)
     CALL "TEST-PLAYER-SNAPSHOT" USING WS-ROW WS-BOB-BEFORE
     MOVE WS-BOB TO WS-ID
     PERFORM DRAIN-LAST
     MOVE WS-CAROL TO WS-ID
     PERFORM DRAIN-LAST

*>   When the host quits.
     CALL "CORE-STOP" USING WS-REASON

     MOVE "acceptance US17-4 given guests when CORE-STOP is called with the host-closed text then "
         & "a guest's last packet is the host-closed Disconnect (play-s2c-20-disconnect-host-closed"
         & ".hex)" TO TL-CASE
     MOVE WS-BOB TO WS-ID
     PERFORM DRAIN-LAST
     MOVE WS-CLOSE TO WS-CLOSE-BOB
     CALL "TEST-SAME-AS-FIXTURE" USING PK-BUFFER WS-FIXTURE TESTLIB-ASSERT
     MOVE "acceptance US17-4 given guests when CORE-STOP is called with the host-closed text then "
         & "the second guest gets the same Disconnect" TO TL-CASE
     MOVE WS-CAROL TO WS-ID
     PERFORM DRAIN-LAST
     CALL "TEST-SAME-AS-FIXTURE" USING PK-BUFFER WS-FIXTURE TESTLIB-ASSERT
     MOVE "acceptance US17-4 given guests when CORE-STOP is called then every guest connection "
         & "gets the close flag and the run state becomes 2" TO TL-CASE
     CALL "CORE-STATUS-GET" USING CORE-STATUS
     MOVE SPACES TO WS-TEXT
     MOVE WS-CLOSE-BOB TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
     MOVE WS-CLOSE TO WS-EDIT
     PERFORM APPEND-EDIT
     MOVE CST-RUN-STATE TO WS-EDIT
     PERFORM APPEND-EDIT
     MOVE "1 1 2" TO TL-EXPECTED
     PERFORM CHECK

*>   The host opens the world again and opens it to others; Bob rejoins.
     CALL "CORE-WORLD-OPEN" USING WS-WORLD CORE-SETTINGS WS-CREATED
     MOVE "acceptance US17-4 when the host quits then the world is saved: reopening finds an "
         & "existing world" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE WS-CREATED TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "0" TO TL-EXPECTED
     PERFORM CHECK
     CALL "TEST-JOIN" USING WS-HOST-NAME WS-LENGTH-5 WS-HOST
     CALL "CORE-OPEN-TO-OTHERS" USING WS-GUEST-MODE WS-GUEST-OPERATOR
     CALL "TEST-JOIN-NETWORK" USING WS-BOB-NAME WS-LENGTH-3 WS-BOB
     MOVE "acceptance US17-5 given a guest has played in the host's world when the host reopens "
         & "it, opens it to others and the guest rejoins then position, dimension, inventory, "
         & "health and food are as left" TO TL-CASE
     CALL "TEST-PLAYER-SNAPSHOT" USING CN-PLAYER(WS-BOB) WS-TEXT
     MOVE WS-BOB-BEFORE TO TL-EXPECTED
     PERFORM CHECK
     MOVE "acceptance US17-5 the rejoined guest is in cobolcraft:subroutine" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE PL-DIM(CN-PLAYER(WS-BOB)) TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     MOVE DIM-SUBROUTINE TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-FREE" USING PK-BUFFER
     STOP RUN.

*> Drains connection WS-ID (a network connection, compressed frames): the last packet's id and body
*> in PK-BUFFER (the frame's Data length VarInt, 0 for a packet below the threshold, removed) and
*> the close flag in WS-CLOSE.
 DRAIN-LAST.
     CALL "PB-RESET" USING PB-BUFFER
     CALL "TEST-DRAIN" USING WS-ID PB-BUFFER WS-CLOSE
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
     END-PERFORM
     SET ADDRESS OF B-AREA TO PK-ADDR
     IF PK-LENGTH > 1 AND B-AREA(1:1) = X"00"
         COMPUTE WS-PACKET-LENGTH = PK-LENGTH - 1
         MOVE B-AREA(2:WS-PACKET-LENGTH) TO WS-PACKET
         CALL "PB-RESET" USING PK-BUFFER
         CALL "PB-APPEND-BYTES" USING PK-BUFFER WS-PACKET WS-PACKET-LENGTH
     END-IF.

 APPEND-EDIT.
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 END PROGRAM ACC-US17-HOST-QUIT.

 COPY CORETEST.
