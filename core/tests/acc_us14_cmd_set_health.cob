*> Acceptance test, US14-2 vitality (spec US14 scenario 2; FR-016; standin-content §16.2 row 20, §10.3,
*> §10.6): the set-health command sets a survival player's health to an amount (0 to 20), full (20)
*> or zero (0); the player is sent Set Health and the sender cobolcraft.command.vitality.done [name,
*> new health]; at 0 the player dies (cause cobolcraft.death.command) after the confirmation is
*> sent (US7-4). A creative player gets not_survival, a dead one not_alive.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-CMD-SET-HEALTH.
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
     MOVE "Bob" TO WS-NAME
     MOVE 3 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-BOB
     MOVE "mode Alice survival" TO WS-LINE
     PERFORM OPAL-RUN
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     CALL "TEST-DRAIN-CHAT" USING WS-OPAL WS-TEXT
     MOVE "acceptance US14-2 when an operator sets Alice's health to 10 then the "
         & "sender is sent vitality.done with the name and the new health" TO TL-CASE
     MOVE "vitality Alice 10" TO WS-LINE
     MOVE "cobolcraft.command.vitality.done(Alice,10)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 Alice is sent Set Health with health 10" TO TL-CASE
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE "health 10 food 20" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-2 vitality full sets health 20" TO TL-CASE
     MOVE "vitality Alice full" TO WS-LINE
     MOVE "cobolcraft.command.vitality.done(Alice,20)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 Alice is sent Set Health with health 20" TO TL-CASE
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE "health 20 food 20" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-2 vitality zero sets health 0: the confirmation is sent, "
         & "then the player dies with the command death message" TO TL-CASE
     MOVE "vitality Alice zero" TO WS-LINE
     MOVE "cobolcraft.command.vitality.done(Alice,0) | cobolcraft.death.command(Alice)"
         TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 Alice set to zero health dies (US7-4): Set Health 0, "
         & "Player Combat Kill and the death message" TO TL-CASE
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE PL-ENTITY-ID(CN-PLAYER(WS-ALICE)) TO WS-EDIT
     MOVE SPACES TO TL-EXPECTED
     STRING "health 0 food 20 | kill " FUNCTION TRIM(WS-EDIT) " cobolcraft.death.command(Alice)"
         " | chat cobolcraft.death.command(Alice)" DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-2 setting the health of a dead player sends not_alive" TO TL-CASE
     MOVE "vitality Alice 5" TO WS-LINE
     MOVE "cobolcraft.command.not_alive(Alice)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 setting the health of a creative player sends "
         & "not_survival" TO TL-CASE
     MOVE "vitality Bob 5" TO WS-LINE
     MOVE "cobolcraft.command.not_survival(Bob)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 an amount above 20 is an invalid argument" TO TL-CASE
     MOVE "vitality Bob 21" TO WS-LINE
     MOVE "cobolcraft.command.invalid_argument(21,vitality <player> <amount>)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 naming a player who is not online changes nothing and "
         & "sends the §16 player-not-found message (§16 target rule)" TO TL-CASE
     MOVE "vitality Zed full" TO WS-LINE
     MOVE "cobolcraft.command.player_not_found(Zed)" TO TL-EXPECTED
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

 END PROGRAM ACC-US14-CMD-SET-HEALTH.

 COPY CORETEST.
