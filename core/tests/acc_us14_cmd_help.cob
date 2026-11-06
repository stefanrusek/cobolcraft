*> Acceptance test, US14-2 howto (spec US14 scenario 2; FR-016; standin-content §16.2 row 1): the help
*> command lists the commands the sender may use with their usage: the confirmation
*> cobolcraft.command.howto.header [number of entries], then one cobolcraft.command.howto.entry
*> [usage string] per usage form, in the §16.2 table order (3 for everyone, 35 for an operator or
*> the console). Opal holds operator status (operator list); Alice does not.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-CMD-HELP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
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
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     PERFORM JOIN-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     CALL "TEST-DRAIN-CHAT" USING WS-OPAL WS-TEXT
     MOVE "acceptance US14-2 given a player without operator status when they run "
         & "howto then they are sent the header with 3 entries and one entry per usage "
         & "form they may use" TO TL-CASE
     MOVE "howto" TO WS-LINE
     MOVE "cobolcraft.command.howto.header(3) | cobolcraft.command.howto.entry(howto) "
         & "| cobolcraft.command.howto.entry(roster) | "
         & "cobolcraft.command.howto.entry(murmur <player> <message...>)" TO TL-EXPECTED
     PERFORM ALICE-CHECK
     MOVE "acceptance US14-2 given an operator when they run howto then they are sent "
         & "the header with 35 entries and every usage form in the §16.2 table order "
         & "(first 1000 characters)" TO TL-CASE
     MOVE "howto" TO WS-LINE
     PERFORM OPAL-RUN
     MOVE WS-TEXT TO WS-AREA
     MOVE WS-AREA(1:1000) TO WS-TEXT
     MOVE "cobolcraft.command.howto.header(35) | "
         & "cobolcraft.command.howto.entry(howto) | cobolcraft.command.howto.entry(roster) "
         & "| cobolcraft.command.howto.entry(murmur <player> <message...>) | "
         & "cobolcraft.command.howto.entry(promote <player>) | "
         & "cobolcraft.command.howto.entry(demote <player>) | "
         & "cobolcraft.command.howto.entry(eject <player> [<reason...>]) | "
         & "cobolcraft.command.howto.entry(bar <player>) | "
         & "cobolcraft.command.howto.entry(unbar <player>) | "
         & "cobolcraft.command.howto.entry(barlist) | "
         & "cobolcraft.command.howto.entry(guestlist on) | "
         & "cobolcraft.command.howto.entry(guestlist off) | "
         & "cobolcraft.command.howto.entry(guestlist add <player>) | "
         & "cobolcraft.command.howto.entry(guestlist remove <player>) | "
         & "cobolcraft.command.howto.entry(guestlist show) | "
         & "cobolcraft.command.howto.entry(mode <player> survival) | "
         & "cobolcraft.command.howto.entry(mode <player> creative) | "
         & "cobolcraft.command.howto.entry(relocate <player> at <x> <y> <z> [<dimension>]) "
         & "| cobolcraft.command.howto.entry(relocate <player> to <target>" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-2 given an operator when they run howto then they are sent "
         & "every usage form in the §16.2 table order (the rest)" TO TL-CASE
     MOVE WS-AREA(1001:) TO WS-TEXT
     MOVE ") | cobolcraft.command.howto.entry(supply <player> <item> [<count>]) | "
         & "cobolcraft.command.howto.entry(empty <player>) | "
         & "cobolcraft.command.howto.entry(vitality <player> <amount>) | "
         & "cobolcraft.command.howto.entry(vitality <player> full) | "
         & "cobolcraft.command.howto.entry(vitality <player> zero) | "
         & "cobolcraft.command.howto.entry(ration <player> <amount>) | "
         & "cobolcraft.command.howto.entry(ration <player> full) | "
         & "cobolcraft.command.howto.entry(ration <player> zero) | "
         & "cobolcraft.command.howto.entry(conjure <mob> <x> <y> <z> [<dimension>]) | "
         & "cobolcraft.command.howto.entry(sweep <what> everywhere) | "
         & "cobolcraft.command.howto.entry(sweep <what> area <dimension> <x1> <y1> <z1> "
         & "<x2> <y2> <z2>) | cobolcraft.command.howto.entry(clock <ticks>) | "
         & "cobolcraft.command.howto.entry(skies <dimension> <kind> [<seconds>]) | "
         & "cobolcraft.command.howto.entry(homestead <x> <y> <z>) | "
         & "cobolcraft.command.howto.entry(announce <message...>) | "
         & "cobolcraft.command.howto.entry(persist) | "
         & "cobolcraft.command.howto.entry(shutdown)" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-2 the console's howto lists every usage form as console "
         & "lines, the header first" TO TL-CASE
     MOVE "howto" TO WS-LINE
     PERFORM CONSOLE-RUN
     MOVE WS-TEXT(1:60) TO TL-OBSERVED
     MOVE "Commands you may use (35): | - howto | - roster | - murmur <" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
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

 ALICE-CHECK.
     CALL "TEST-COMMAND" USING WS-ALICE WS-LINE
     CALL "TEST-DRAIN-CHAT" USING WS-ALICE WS-TEXT
     PERFORM CHECK-TEXT.

 END PROGRAM ACC-US14-CMD-HELP.

 COPY CORETEST.
