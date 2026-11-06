*> Acceptance test, US14-5 and the US14/US15 edge cases (spec US14 scenario 5; FR-016; standin-content
*> §16.1 target rule, §16.2 rows 4 and 5, §16.3): granting (promote) or revoking (demote) operator
*> status confirms to the sender, tells the player (promote.notice / demote.notice) and sends them
*> the new command tree at once; an operator may revoke their own status, also as the last
*> operator, and the console keeps operator permission; a valid name of a player who has never
*> joined works (offline UUID); the host of a client-hosted world cannot be demoted.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-OP-CHANGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==ST-==.
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
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     PERFORM JOIN-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     CALL "TEST-DRAIN-CHAT" USING WS-OPAL WS-TEXT
     MOVE "acceptance US14-5 when an operator grants operator status to Alice then "
         & "the sender is sent promote.done" TO TL-CASE
     MOVE "promote Alice" TO WS-LINE
     MOVE "cobolcraft.command.promote.done(Alice)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-5 when operator status is granted then Alice is told and "
         & "is sent the operator command tree at once" TO TL-CASE
     MOVE WS-ALICE TO WS-ID
     PERFORM TREE-OF
     MOVE "cobolcraft.command.promote.notice() / tree operator" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-5 Alice now holds operator status: she may run an operator "
         & "command" TO TL-CASE
     MOVE "clock 100" TO WS-LINE
     CALL "TEST-COMMAND" USING WS-ALICE WS-LINE
     CALL "TEST-DRAIN-CHAT" USING WS-ALICE WS-TEXT
     MOVE "cobolcraft.command.clock.done(100)" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-5 granting operator status to a player who holds it "
         & "changes nothing and sends promote.already" TO TL-CASE
     MOVE "promote Alice" TO WS-LINE
     MOVE "cobolcraft.command.promote.already(Alice)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-5 when an operator revokes Alice's operator status then "
         & "the sender is sent demote.done" TO TL-CASE
     MOVE "demote Alice" TO WS-LINE
     MOVE "cobolcraft.command.demote.done(Alice)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-5 when operator status is revoked then Alice is told and "
         & "is sent the everyone command tree at once" TO TL-CASE
     MOVE WS-ALICE TO WS-ID
     PERFORM TREE-OF
     MOVE "cobolcraft.command.demote.notice() / tree everyone" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-5 revoking operator status from a player who does not hold "
         & "it sends demote.not_operator" TO TL-CASE
     MOVE "demote Alice" TO WS-LINE
     MOVE "cobolcraft.command.demote.not_operator(Alice)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-5 an invalid name sends invalid_name and changes nothing" TO TL-CASE
     MOVE "promote no-one" TO WS-LINE
     MOVE "cobolcraft.command.invalid_name(no-one)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-5 demoting an invalid name sends invalid_name and changes nothing"
         TO TL-CASE
     MOVE "demote no-one" TO WS-LINE
     MOVE "cobolcraft.command.invalid_name(no-one)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-5 naming a valid offline player who has never joined "
         & "works, the identity coming from the name's offline UUID" TO TL-CASE
     MOVE "promote Newbie" TO WS-LINE
     MOVE "cobolcraft.command.promote.done(Newbie)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-5 the never-joined player promoted while offline holds "
         & "operator status when they join" TO TL-CASE
     MOVE "Newbie" TO WS-NAME
     MOVE 6 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-UNDRAINED" USING WS-NAME WS-NAME-LENGTH WS-ID
     PERFORM TREE-OF
     MOVE "tree operator" TO TL-EXPECTED
     MOVE WS-TEXT(4:) TO WS-AREA
     MOVE WS-AREA TO WS-TEXT
     PERFORM CHECK-TEXT
     MOVE "US14/US15 edge an operator revoking their own status takes effect: the "
         & "other operators lose theirs first, then Opal, the last operator, demotes "
         & "herself" TO TL-CASE
     MOVE "demote Newbie" TO WS-LINE
     MOVE "cobolcraft.command.demote.done(Newbie)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "demote Opal" TO WS-LINE
     CALL "TEST-COMMAND" USING WS-OPAL WS-LINE
     MOVE WS-OPAL TO WS-ID
     PERFORM TREE-OF
     MOVE "US14/US15 edge the last operator revoking their own status is confirmed, "
         & "told and sent the everyone tree" TO TL-CASE
     MOVE "cobolcraft.command.demote.done(Opal) | cobolcraft.command.demote.notice() / tree "
         & "everyone" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "US14/US15 edge after revoking her own status Opal may not use operator "
         & "commands" TO TL-CASE
     MOVE "clock 5" TO WS-LINE
     MOVE "cobolcraft.command.not_permitted(clock)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "US14/US15 edge with no operator left the console keeps operator permission "
         & "and can grant it again" TO TL-CASE
     MOVE "promote Opal" TO WS-LINE
     PERFORM CONSOLE-RUN
     MOVE "Opal now holds operator status" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE 2 TO CS-HOST-KIND
     MOVE "Hosty" TO CS-HOST-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     PERFORM JOIN-OPAL
     MOVE "Hosty" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID
     MOVE "US14 edge in a world opened to others, demoting the host changes nothing "
         & "and sends is_host" TO TL-CASE
     MOVE "demote Hosty" TO WS-LINE
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

*> WS-TEXT: the System Chat of WS-ID, then " / tree " and "operator", "everyone" or "none" for the
*> Commands packet it was sent.
 TREE-OF.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING WS-ID PB-BUFFER WS-CLOSE
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-N
     MOVE "none" TO WS-PATH
     PERFORM CHAT-AND-TREE.

*> Appends the System Chat texts of the drained stream in PB-BUFFER, then the tree kind.
 CHAT-AND-TREE.
     CALL "PB-INIT" USING ST-BUFFER WS-CAPACITY
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER ST-BUFFER WS-MINUS-ONE WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0 AND WS-PACKET-ID = 124
             CALL "PB-GET-TEXT" USING ST-BUFFER ST-TEXT
             IF WS-N > 1
                 STRING " | " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-N
             END-IF
             STRING ST-TX-VALUE(1:ST-TX-LENGTH) "(" DELIMITED BY SIZE INTO WS-TEXT POINTER WS-N
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > ST-TX-ARG-COUNT
                 STRING ST-TX-ARG-VALUE(WS-I)(1:ST-TX-ARG-LENGTH(WS-I)) DELIMITED BY SIZE
                     INTO WS-TEXT POINTER WS-N
             END-PERFORM
             STRING ")" DELIMITED BY SIZE INTO WS-TEXT POINTER WS-N
         END-IF
         IF WS-OUTCOME = 0 AND WS-PACKET-ID = 16
             MOVE "everyone" TO WS-PATH
             IF ST-LENGTH > 100
                 MOVE "operator" TO WS-PATH
             END-IF
         END-IF
     END-PERFORM
     STRING " / tree " FUNCTION TRIM(WS-PATH) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-N
     CALL "PB-FREE" USING ST-BUFFER
     CALL "PB-FREE" USING PB-BUFFER.

 END PROGRAM ACC-US14-OP-CHANGE.

 COPY CORETEST.
