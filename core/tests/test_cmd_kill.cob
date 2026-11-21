*> Acceptance test of docs/protocol/16-commands-catalog.md §5.1 `kill` (permission level 2) with 14a: each target dies (a player: HEALTH-DIE with the
*> cause of the command; a mob: defeated with its yield; a ground item: removed); commands.kill.success.single [name] or .multiple
*> [count] (broadcast; a mob is shown by its entity type key); none is argument.entity.notfound.entity; without a target the source
*> dies (it must be an entity); the result is the number killed. Opal and Bob hold operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-KILL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-BOB            BINARY-LONG.
 01 WS-ID-ALICE          BINARY-LONG.
 01 WS-ID-CLEO           BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-NUM                 BINARY-DOUBLE.
 01 WS-RESULT              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 COPY CITEMS.
 COPY BRWORLD.
 01 WS-IDS                 PIC X(1024).
 01 WS-KEEP                BINARY-LONG.
 01 WS-KEY-TEXT            PIC X(48).
 01 WS-FIND-X              FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE "Bob" TO WS-NAME
     MOVE 3 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-BOB
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     MOVE "Cleo" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-CLEO
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-CLEO WS-DISCARD
     MOVE "acceptance US13 /kill an operator kills a player: Killed Ali" & "ce" TO TL-CASE
     MOVE "kill Alice" TO WS-LINE
     MOVE "cobolcraft.death.command(Alice) | commands.kill.success.sing" & "le(Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /kill Alice is dead (state 2)" TO TL-CASE
     MOVE PL-STATE(CN-PLAYER(WS-ID-ALICE)) TO WS-NUM
     MOVE 2 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /kill the other operator is sent the command" & " as chat.type.admin" TO TL-CASE
     MOVE "cobolcraft.death.command(Alice) | chat.type.admin(Opal,Kille" & "d Alice)" TO WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /kill a mob to kill" TO TL-CASE
     MOVE "summon cobolcraft:sodgrazer 5.0 64.0 5.0" TO WS-LINE
     MOVE "commands.summon.success(cobolcraft:sodgrazer)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /kill a mob by type: Killed the mob" TO TL-CASE
     MOVE "kill @e[type=cobolcraft:sodgrazer]" TO WS-LINE
     MOVE "commands.kill.success.single(cobolcraft:sodgrazer)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /kill the mob is gone" TO TL-CASE
     MOVE "cobolcraft:sodgrazer" TO WS-KEY-TEXT
     MOVE 5.0 TO WS-FIND-X
     PERFORM COUNT-MOBS
     MOVE 0 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /kill none left: No entity was found" TO TL-CASE
     MOVE "kill @e[type=cobolcraft:sodgrazer]" TO WS-LINE
     MOVE "argument.entity.notfound.entity()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /kill two mobs to kill" TO TL-CASE
     MOVE "summon cobolcraft:sodgrazer 5.0 64.0 5.0" TO WS-LINE
     MOVE "commands.summon.success(cobolcraft:sodgrazer)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /kill two mobs to kill" TO TL-CASE
     MOVE "summon cobolcraft:sodgrazer 5.0 64.0 6.0" TO WS-LINE
     MOVE "commands.summon.success(cobolcraft:sodgrazer)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /kill the result is the number killed" TO TL-CASE
     MOVE "kill @e[type=cobolcraft:sodgrazer]" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 2 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-DISCARD
     MOVE "acceptance US13 /kill mobs again" TO TL-CASE
     MOVE "summon cobolcraft:sodgrazer 5.0 64.0 5.0" TO WS-LINE
     MOVE "commands.summon.success(cobolcraft:sodgrazer)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /kill mobs again" TO TL-CASE
     MOVE "summon cobolcraft:sodgrazer 5.0 64.0 6.0" TO WS-LINE
     MOVE "commands.summon.success(cobolcraft:sodgrazer)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /kill several: Killed 2 entities" TO TL-CASE
     MOVE "kill @e[type=cobolcraft:sodgrazer]" TO WS-LINE
     MOVE "commands.kill.success.multiple(2)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /kill a limit with nothing left" TO TL-CASE
     MOVE "kill @e[type=cobolcraft:sodgrazer,limit=1]" TO WS-LINE
     MOVE "argument.entity.notfound.entity()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-DISCARD
     MOVE "acceptance US13 /kill without a target the source dies" TO TL-CASE
     MOVE "kill" TO WS-LINE
     MOVE "cobolcraft.death.command(Bob) | commands.kill.success.single" & "(Bob)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-BOB WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /kill Bob is dead" TO TL-CASE
     MOVE PL-STATE(CN-PLAYER(WS-ID-BOB)) TO WS-NUM
     MOVE 2 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /kill a player by a selector" TO TL-CASE
     MOVE "kill @a[name=Cleo]" TO WS-LINE
     MOVE "cobolcraft.death.command(Cleo) | commands.kill.success.singl" & "e(Cleo)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /kill a name that is not online: No entity w" & "as found" TO TL-CASE
     MOVE "kill Zed" TO WS-LINE
     MOVE "argument.entity.notfound.entity()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     MOVE "acceptance US13 /kill a player without operator status does " & "not know the command" TO TL-CASE
     MOVE "kill" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /kill the console prints the death text and " & "the English text" TO TL-CASE
     MOVE "kill Opal" TO WS-LINE
     MOVE "Opal had their vitality set to zero | Killed Opal" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /kill the console without a target: an entit" & "y is required" TO TL-CASE
     MOVE "kill" TO WS-LINE
     MOVE "An entity is required to run this command here" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.

*> The number of mobs of the entity type key WS-KEY-TEXT standing at x WS-FIND-X, in WS-NUM.
 COUNT-MOBS.
     MOVE 0 TO WS-NUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-X(WS-I) = WS-FIND-X
             COMPUTE WS-KEEP = EN-TYPE(WS-I) + 1
             IF ET-KEY(WS-KEEP) = WS-KEY-TEXT
                 ADD 1 TO WS-NUM
             END-IF
         END-IF
     END-PERFORM.
 END PROGRAM TEST-CMD-KILL.

 COPY CORETEST.
 COPY CMDTEST.
