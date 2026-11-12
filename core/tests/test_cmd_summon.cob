*> Acceptance test of docs/protocol/16-commands-catalog.md §5.8 `summon` (permission level 2) with 14a: the entity type is an entry of the registry
*> minecraft:entity_type that is a mob of the core (cobolcraft:sodgrazer, cobolcraft:abend; the others are entity.not_summonable); the mob
*> appears at the position (the source's without one; components relative or absolute) in the source's dimension with full health and is
*> sent to the players who see it (Add Entity); a monster in Peaceful difficulty or with hostile mobs off is commands.summon.failed.peaceful;
*> a position outside the spawnable bounds is commands.summon.invalidPosition; commands.summon.success [entity] (broadcast); the result is 1.
*> NBT other than {} is BLOCKED (refused). Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-SUMMON.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-ALICE          BINARY-LONG.
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
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     MOVE "acceptance US13 /summon an operator summons a sodgrazer: Sum" & "moned new cobolcraft:sodgrazer" TO TL-CASE
     MOVE "summon cobolcraft:sodgrazer 5.0 64.0 5.0" TO WS-LINE
     MOVE "commands.summon.success(cobolcraft:sodgrazer)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /summon one sodgrazer stands at x 5" TO TL-CASE
     MOVE "cobolcraft:sodgrazer" TO WS-KEY-TEXT
     MOVE 5.0 TO WS-FIND-X
     PERFORM COUNT-MOBS
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /summon Alice is sent Add Entity (1)" TO TL-CASE
     CALL "TEST-DRAIN-IDS" USING WS-ID-ALICE WS-IDS
     MOVE WS-IDS TO WS-TEXT
     MOVE "1" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /summon the namespace of the content set is " & "implied" TO TL-CASE
     MOVE "summon sodgrazer 6.0 64.0 5.0" TO WS-LINE
     MOVE "commands.summon.success(cobolcraft:sodgrazer)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /summon one sodgrazer stands at x 6" TO TL-CASE
     MOVE "cobolcraft:sodgrazer" TO WS-KEY-TEXT
     MOVE 6.0 TO WS-FIND-X
     PERFORM COUNT-MOBS
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE 7.5 TO PL-X(CN-PLAYER(WS-ID-OPAL))
     MOVE 70 TO PL-Y(CN-PLAYER(WS-ID-OPAL))
     MOVE 7.5 TO PL-Z(CN-PLAYER(WS-ID-OPAL))
     MOVE "acceptance US13 /summon without a position: where the source" & " stands" TO TL-CASE
     MOVE "summon cobolcraft:sodgrazer" TO WS-LINE
     MOVE "commands.summon.success(cobolcraft:sodgrazer)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /summon one sodgrazer stands at x 7.5" TO TL-CASE
     MOVE "cobolcraft:sodgrazer" TO WS-KEY-TEXT
     MOVE 7.5 TO WS-FIND-X
     PERFORM COUNT-MOBS
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /summon a relative position" TO TL-CASE
     MOVE "summon cobolcraft:sodgrazer ~1 ~ ~" TO WS-LINE
     MOVE "commands.summon.success(cobolcraft:sodgrazer)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /summon one sodgrazer stands at x 8.5" TO TL-CASE
     MOVE "cobolcraft:sodgrazer" TO WS-KEY-TEXT
     MOVE 8.5 TO WS-FIND-X
     PERFORM COUNT-MOBS
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /summon a monster with hostile mobs on" TO TL-CASE
     MOVE "summon cobolcraft:abend 20.5 64.0 20.5" TO WS-LINE
     MOVE "commands.summon.success(cobolcraft:abend)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /summon one abend stands at x 20.5" TO TL-CASE
     MOVE "cobolcraft:abend" TO WS-KEY-TEXT
     MOVE 20.5 TO WS-FIND-X
     PERFORM COUNT-MOBS
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "BR-WORLD-READY"
     MOVE 0 TO BW-DIFFICULTY
     MOVE "acceptance US13 /summon a monster in Peaceful difficulty: Mo" & "nsters cannot be summoned in Peaceful difficulty" TO TL-CASE
     MOVE "summon cobolcraft:abend 30.5 64.0 20.5" TO WS-LINE
     MOVE "commands.summon.failed.peaceful()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /summon no abend stands at x 30.5" TO TL-CASE
     MOVE "cobolcraft:abend" TO WS-KEY-TEXT
     MOVE 30.5 TO WS-FIND-X
     PERFORM COUNT-MOBS
     MOVE 0 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /summon a sodgrazer is allowed in Peaceful" TO TL-CASE
     MOVE "summon cobolcraft:sodgrazer 31.5 64.0 20.5" TO WS-LINE
     MOVE "commands.summon.success(cobolcraft:sodgrazer)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE 2 TO BW-DIFFICULTY
     MOVE "acceptance US13 /summon outside the spawnable bounds: Invali" & "d position for summon" TO TL-CASE
     MOVE "summon cobolcraft:sodgrazer 30000000.0 64.0 0.0" TO WS-LINE
     MOVE "commands.summon.invalidPosition()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /summon a type that is not a mob of the core" & ": Can't summon entity of type" TO TL-CASE
     MOVE "summon cobolcraft:operator 1.0 64.0 1.0" TO WS-LINE
     MOVE "entity.not_summonable(cobolcraft:operator)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /summon an unknown entity type is a parse er" & "ror (the registry lookup)" TO TL-CASE
     MOVE "summon cobolcraft:nothing" TO WS-LINE
     MOVE "argument.resource.not_found(cobolcraft:nothing,minecraft:ent" & "ity_type) |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /summon an empty NBT is accepted" TO TL-CASE
     MOVE "summon cobolcraft:sodgrazer 1.0 64.0 1.0 {}" TO WS-LINE
     MOVE "commands.summon.success(cobolcraft:sodgrazer)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /summon NBT with content is refused (BLOCKED" & ")" TO TL-CASE
     MOVE "summon cobolcraft:sodgrazer 1.0 64.0 1.0 {Health:5f}" TO WS-LINE
     MOVE "cobolcraft.entity.nbt_unsupported()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /summon summon alone is incomplete" TO TL-CASE
     MOVE "summon" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /summon a player without operator status doe" & "s not know the command" TO TL-CASE
     MOVE "summon cobolcraft:sodgrazer" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /summon the console prints the English text" TO TL-CASE
     MOVE "summon cobolcraft:sodgrazer 40.5 64.0 40.5" TO WS-LINE
     MOVE "Summoned new cobolcraft:sodgrazer" TO WS-EXPECTED
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
 END PROGRAM TEST-CMD-SUMMON.

 COPY CORETEST.
 COPY CMDTEST.
