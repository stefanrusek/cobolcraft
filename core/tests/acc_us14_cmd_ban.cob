*> Acceptance test, US14-2 bar (spec US14 scenario 2; FR-016; standin-content §16.1 target rule,
*> §16.2 row 7, §17): the ban command records the identity on the ban list (saved in access.dat),
*> disconnects the player if online with cobolcraft.disconnect.barred
*> (play-s2c-20-disconnect-banned.hex) and confirms with cobolcraft.command.bar.done [name]; it
*> accepts any valid name, online or not (offline UUID); the host of a client-hosted world is
*> refused with is_host.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-CMD-BAN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==ST-==.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-UUID                PIC X(16).
 01 WS-LIST                BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-OPAL                BINARY-LONG.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-CONSOLE             BINARY-LONG VALUE 0.
 01 WS-LINE                PIC X(768).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TEXT                PIC X(4096).
 01 WS-IDS                 PIC X(1024).
 01 WS-PATH                PIC X(256).
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-DEDIT               PIC -(9)9.99.
 01 WS-AREA                PIC X(4096).
 01 WS-MINUS-ONE           BINARY-LONG VALUE -1.
 01 B-AREA                 PIC X(1073741824) BASED.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     PERFORM JOIN-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     CALL "TEST-DRAIN-CHAT" USING WS-OPAL WS-TEXT
     MOVE "acceptance US14-2 when an operator bars Alice then the sender is sent "
         & "bar.done" TO TL-CASE
     MOVE "bar Alice" TO WS-LINE
     MOVE "cobolcraft.command.bar.done(Alice)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 the barred player, online, is disconnected with "
         & "play-s2c-20-disconnect-banned.hex" TO TL-CASE
     MOVE WS-ALICE TO WS-ID
     PERFORM LAST-PACKET
     MOVE "contract/fixtures/wire/play-s2c-20-disconnect-banned.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     MOVE "acceptance US14-2 the ban is recorded: the identity (name and offline "
         & "UUID) is on the ban list" TO TL-CASE
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     PERFORM LISTED
     MOVE "listed" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-2 barring a player already barred changes nothing and "
         & "sends bar.already" TO TL-CASE
     MOVE "bar Alice" TO WS-LINE
     MOVE "cobolcraft.command.bar.already(Alice)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 naming a valid offline player who has never joined "
         & "works, the identity coming from the name's offline UUID" TO TL-CASE
     MOVE "bar Mallory" TO WS-LINE
     MOVE "cobolcraft.command.bar.done(Mallory)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 the never-joined player's identity is on the ban list" TO TL-CASE
     MOVE "Mallory" TO WS-NAME
     MOVE 7 TO WS-NAME-LENGTH
     PERFORM LISTED
     MOVE "listed" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-2 an invalid name sends invalid_name" TO TL-CASE
     MOVE "bar 12345678901234567" TO WS-LINE
     MOVE "cobolcraft.command.invalid_name(12345678901234567)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE 2 TO CS-HOST-KIND
     MOVE "Hosty" TO CS-HOST-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     PERFORM JOIN-OPAL
     MOVE "Hosty" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID
     MOVE "US14 edge in a world opened to others, barring the host changes nothing "
         & "and sends is_host" TO TL-CASE
     MOVE "bar Hosty" TO WS-LINE
     MOVE "cobolcraft.command.is_host(Hosty)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     STOP RUN.

*> Opal holds operator status through the world's operator list.
 JOIN-OPAL.
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "LOGIN-OFFLINE-UUID" USING WS-NAME WS-NAME-LENGTH WS-UUID
     MOVE ACCESS-OPERATORS TO WS-LIST
     CALL "ACCESS-ADD" USING WS-LIST WS-NAME WS-NAME-LENGTH WS-UUID WS-OUTCOME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-OPAL.

*> Opal runs WS-LINE; WS-TEXT is the System Chat she is sent.
 OPAL-RUN.
     CALL "TEST-COMMAND" USING WS-OPAL WS-LINE
     CALL "TEST-DRAIN-CHAT" USING WS-OPAL WS-TEXT.

 OPAL-CHECK.
     PERFORM OPAL-RUN
     PERFORM CHECK-TEXT.

*> The console runs WS-LINE; WS-TEXT is the console lines it printed, separated by " | ".
 CONSOLE-RUN.
     PERFORM CONSOLE-LINES
     COMPUTE WS-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-LINE TRAILING))
     CALL "CMD-RUN" USING WS-CONSOLE WS-LINE WS-LENGTH
     PERFORM CONSOLE-LINES.

 CONSOLE-LINES.
     MOVE SPACES TO WS-AREA WS-TEXT
     SET CB-ADDR TO ADDRESS OF WS-AREA
     MOVE 4096 TO CB-CAPACITY
     CALL "CORE-CONSOLE-DRAIN" USING CORE-BUFFER
     MOVE 1 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-LENGTH
         IF WS-AREA(WS-I:1) = X"0A"
             IF WS-I < CB-LENGTH
                 STRING " | " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-N
             END-IF
         ELSE
             STRING WS-AREA(WS-I:1) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-N
         END-IF
     END-PERFORM.

 CHECK-TEXT.
     MOVE WS-TEXT TO TL-OBSERVED
     PERFORM ASSERT-TEXT.

 ASSERT-TEXT.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> WS-ID's stream: its last packet (id + body) into PB-BUFFER and the close flag.
 LAST-PACKET.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING ST-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING WS-ID ST-BUFFER WS-CLOSE
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
         CALL "TEST-NEXT-PACKET" USING ST-BUFFER PK-BUFFER WS-MINUS-ONE WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0
             CALL "PB-RESET" USING PB-BUFFER
             SET ADDRESS OF B-AREA TO PK-ADDR
             CALL "PB-APPEND-BYTES" USING PB-BUFFER B-AREA PK-LENGTH
         END-IF
         CALL "PB-FREE" USING PK-BUFFER
     END-PERFORM
     CALL "PB-FREE" USING ST-BUFFER.

*> WS-TEXT: "listed" when the identity of WS-NAME is on the ban list, else "not listed".
 LISTED.
     CALL "LOGIN-OFFLINE-UUID" USING WS-NAME WS-NAME-LENGTH WS-UUID
     MOVE ACCESS-BANS TO WS-LIST
     CALL "ACCESS-FIND" USING WS-LIST WS-UUID WS-ROW
     MOVE "not listed" TO WS-TEXT
     IF WS-ROW > 0
         MOVE "listed" TO WS-TEXT
     END-IF.

 END PROGRAM ACC-US14-CMD-BAN.

 COPY CORETEST.
