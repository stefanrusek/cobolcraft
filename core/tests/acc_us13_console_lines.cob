*> Acceptance test, US13-3 core half (spec US13 scenario 3; contracts/operator-surface.md §3;
*> tasks T619): while a world runs, CORE-CONSOLE-DRAIN yields a line when a player joins
*> ("<name> joined"), chats (the chat line "<name> message" as players see it), changes dimension
*> ("<name> went to <dimension key>"), dies (the death message players see, rendered from its
*> translate key through the en_us texts, docs/protocol/08-resource-packs.md §10.8.2) and leaves
*> ("<name> left").
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US13-CONSOLE-LINES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY RULES.
 01 WS-ALICE-NAME          PIC X(16) VALUE "Alice".
 01 WS-BOB-NAME            PIC X(16) VALUE "Bob".
 01 WS-LENGTH-5            BINARY-LONG VALUE 5.
 01 WS-LENGTH-3            BINARY-LONG VALUE 3.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-ATTACKER            BINARY-LONG.
 01 WS-RESPAWN             BINARY-LONG VALUE 0.
 01 WS-MESSAGE             PIC X(768) VALUE "hello, console".
 01 WS-MESSAGE-LENGTH      BINARY-LONG VALUE 14.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQUENCE            BINARY-LONG VALUE 1.
 01 WS-AREA                PIC X(4096).
 01 WS-TEXT                PIC X(4096).
 01 WS-I                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE CS-HOSTILE-MOBS CS-WEATHER-CHANGES
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 1 TO CS-EXTRA-DIMENSIONS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     PERFORM DRAIN

     MOVE "acceptance US13-3 given a running world when a player joins then the console line is "
         & "<name> joined" TO TL-CASE
     CALL "TEST-JOIN" USING WS-ALICE-NAME WS-LENGTH-5 WS-ALICE
     PERFORM DRAIN
     MOVE "Alice joined" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US13-3 given a running world when a player chats then the console line is "
         & "<name> message as the players see it" TO TL-CASE
     CALL "TEST-CHAT" USING WS-ALICE WS-MESSAGE WS-MESSAGE-LENGTH
     PERFORM DRAIN
     MOVE "<Alice> hello, console" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US13-3 given a running world when a player changes dimension then the "
         & "console line is <name> went to <dimension key>" TO TL-CASE
     MOVE DIM-MAIN TO WS-DIM
     MOVE 6 TO WS-X MOVE 54 TO WS-Y MOVE 12 TO WS-Z
     MOVE TRAVEL-PAD-STATE TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "TEST-USE-ON" USING WS-ALICE WS-X WS-Y WS-Z WS-FACE WS-SEQUENCE
     CALL "TEST-ACCEPT-TELEPORT" USING WS-ALICE
     PERFORM DRAIN
     MOVE "Alice went to cobolcraft:subroutine" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US13-3 given a running world when a player dies then the console line is "
         & "the death message the players see, in en_us text (one and two arguments)" TO TL-CASE
     CALL "TEST-JOIN" USING WS-BOB-NAME WS-LENGTH-3 WS-BOB
     PERFORM DRAIN
     MOVE CN-PLAYER(WS-BOB) TO WS-ROW
     MOVE CAUSE-FALL TO WS-CAUSE
     MOVE 0 TO WS-ATTACKER
     MOVE 0 TO PL-HEALTH(WS-ROW)
     CALL "HEALTH-DIE" USING WS-ROW WS-CAUSE WS-ATTACKER
     CALL "TEST-CLIENT-COMMAND" USING WS-BOB WS-RESPAWN
     MOVE CAUSE-PLAYER TO WS-CAUSE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ATTACKER
     MOVE 0 TO PL-HEALTH(WS-ROW)
     CALL "HEALTH-DIE" USING WS-ROW WS-CAUSE WS-ATTACKER
     PERFORM DRAIN
     MOVE "Bob misjudged the drop | Bob lost a duel with Alice" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US13-3 given a running world when a player leaves then the console line is "
         & "<name> left" TO TL-CASE
     CALL "CORE-CONN-CLOSED" USING WS-ALICE
     PERFORM DRAIN
     MOVE "Alice left" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> Every pending console line, " | "-separated, in WS-TEXT.
 DRAIN.
     MOVE SPACES TO WS-AREA WS-TEXT
     SET CB-ADDR TO ADDRESS OF WS-AREA
     MOVE 4096 TO CB-CAPACITY
     CALL "CORE-CONSOLE-DRAIN" USING CORE-BUFFER
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-LENGTH
         IF WS-AREA(WS-I:1) = X"0A"
             IF WS-I < CB-LENGTH
                 STRING " | " DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
             END-IF
         ELSE
             STRING WS-AREA(WS-I:1) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         END-IF
     END-PERFORM.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US13-CONSOLE-LINES.

 COPY CORETEST.
