*> Acceptance test of docs/protocol/16-commands-catalog.md §5.7 `damage` (permission level 2) with 14a: damage <target> <amount> [<damageType> [at <location> |
*> by <entity> [from <cause>]]] hurts one entity (a player through HEALTH-HURT, a mob through HEALTH-MOB-DAMAGE) and tells commands.damage.success [amount, name]
*> (broadcast); a target that ignores the damage (creative, inside the hurt window, not living) is commands.damage.invulnerable; the result is 1. Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-DAMAGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY CITEMS.
 01 WS-ID-OPAL           BINARY-LONG.
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
 01 WS-I                   BINARY-LONG.
 01 WS-MOB                 BINARY-LONG.
 01 WS-ITEM-ROW            BINARY-LONG.
 01 WS-Y                   FLOAT-LONG VALUE 70.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ZERO-B              FLOAT-LONG VALUE 0.
 01 WS-ZERO-C              FLOAT-LONG VALUE 0.
 01 WS-STONE               BINARY-LONG VALUE 1.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-DELAY               BINARY-LONG VALUE 0.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-SX                  FLOAT-LONG VALUE 30.
 01 WS-SZ                  FLOAT-LONG VALUE 30.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     MOVE "Cleo" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-CLEO
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-CLEO WS-DISCARD
     MOVE 30 TO PL-HEALTH(CN-PLAYER(WS-ID-ALICE))
     MOVE 0 TO PL-MODE(CN-PLAYER(WS-ID-ALICE))
     MOVE "acceptance US13 /damage default type: Applied 4.0 damage to Alice" TO TL-CASE
     MOVE "damage Alice 4" TO WS-LINE
     MOVE "commands.damage.success(4.0,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /damage Alice lost 4 health" TO TL-CASE
     MOVE PL-HEALTH(CN-PLAYER(WS-ID-ALICE)) TO WS-NUM
     MOVE 26 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /damage inside the hurt window the target ignores it" TO TL-CASE
     MOVE "damage Alice 2" TO WS-LINE
     MOVE "commands.damage.invulnerable()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     CALL "TEST-TICKS" USING 30
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /damage a damage type and a fraction: Applied 1.5" TO TL-CASE
     MOVE "damage Alice 1.5 cobolcraft:hail" TO WS-LINE
     MOVE "commands.damage.success(1.5,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     CALL "TEST-TICKS" USING 30
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /damage a type of the standard keys: minecraft:fall" TO TL-CASE
     MOVE "damage Alice 0 minecraft:fall" TO WS-LINE
     MOVE "commands.damage.success(0.0,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     CALL "TEST-TICKS" USING 30
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /damage an unknown damage type" TO TL-CASE
     MOVE "damage Alice 1 cobolcraft:nothing" TO WS-LINE
     MOVE "argument.resource.not_found(cobolcraft:nothing,minecraft:damage_type) |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /damage at a location" TO TL-CASE
     MOVE "damage Alice 1 generic at 1 64 1" TO WS-LINE
     MOVE "commands.damage.success(1.0,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     CALL "TEST-TICKS" USING 30
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /damage by an entity (a player attacker)" TO TL-CASE
     MOVE "damage Alice 1 minecraft:player_attack by Cleo" TO WS-LINE
     MOVE "commands.damage.success(1.0,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     CALL "TEST-TICKS" USING 30
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /damage by an entity from a cause" TO TL-CASE
     MOVE "damage Alice 1 minecraft:mob_attack by Cleo from Opal" TO WS-LINE
     MOVE "commands.damage.success(1.0,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     CALL "TEST-TICKS" USING 30
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /damage a starve type" TO TL-CASE
     MOVE "damage Alice 1 minecraft:starve" TO WS-LINE
     MOVE "commands.damage.success(1.0,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     CALL "TEST-TICKS" USING 30
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /damage the result is 1" TO TL-CASE
     MOVE "damage Alice 1" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /damage a creative player (the default mode) ignores it" TO TL-CASE
     MOVE "damage Cleo 3" TO WS-LINE
     MOVE "commands.damage.invulnerable()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /damage a mob to damage" TO TL-CASE
     MOVE "summon cobolcraft:sodgrazer 5.0 64.0 5.0" TO WS-LINE
     MOVE "commands.summon.success(cobolcraft:sodgrazer)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     PERFORM FIND-MOB
     MOVE EN-HEALTH(WS-MOB) TO WS-NUM
     MOVE "acceptance US13 /damage a mob: Applied 1.0 damage to the mob" TO TL-CASE
     MOVE "damage @e[type=cobolcraft:sodgrazer,x=5,y=64,z=5,sort=nearest,limit=1] 1" TO WS-LINE
     MOVE "commands.damage.success(1.0,cobolcraft:sodgrazer)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /damage the mob lost 1 health" TO TL-CASE
     COMPUTE WS-EXPECTED-N = WS-NUM - 1
     MOVE EN-HEALTH(WS-MOB) TO WS-NUM
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /damage a mob dies of enough damage" TO TL-CASE
     CALL "TEST-TICKS" USING 30
     MOVE "damage @e[type=cobolcraft:sodgrazer,x=5,y=64,z=5,sort=nearest,limit=1] 1000" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     PERFORM FIND-MOB
     MOVE WS-MOB TO WS-NUM
     MOVE 0 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /damage by a mob" TO TL-CASE
     MOVE "summon cobolcraft:sodgrazer 5.0 64.0 5.0" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-TICKS" USING 30
     MOVE "damage Alice 1 minecraft:mob_attack by @e[type=cobolcraft:sodgrazer,x=5,y=64,z=5,sort=nearest,limit=1]" TO WS-LINE
     MOVE "commands.damage.success(1.0,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "damage @e[type=cobolcraft:sodgrazer,x=5,y=64,z=5,sort=nearest,limit=1] 1000" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "acceptance US13 /damage a ground item is not living: invulnerable" TO TL-CASE
     CALL "GI-SPAWN" USING WS-DIM WS-SX WS-Y WS-SZ WS-ZERO WS-ZERO-B WS-ZERO-C WS-STONE WS-ONE WS-DELAY WS-ITEM-ROW
     MOVE "damage @e[type=cobolcraft:loose_item,limit=1] 1" TO WS-LINE
     MOVE "commands.damage.invulnerable()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /damage a negative amount is out of range" TO TL-CASE
     MOVE "damage Alice -1" TO WS-LINE
     MOVE "argument.float.low(0.0,-1.0) |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /damage a player without operator status does not know the command" TO TL-CASE
     MOVE "damage Opal 1" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /damage the console prints the English text" TO TL-CASE
     CALL "TEST-TICKS" USING 30
     MOVE "damage Alice 1" TO WS-LINE
     MOVE "Applied 1.0 damage to Alice" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.

*> The row of the sodgrazer in CORE-ENTITIES in WS-MOB (0 = none).
 FIND-MOB.
     MOVE 0 TO WS-MOB
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-X(WS-I) = 5.0 AND EN-TYPE(WS-I) NOT = CR-LOOSE-ITEM
             MOVE WS-I TO WS-MOB
         END-IF
     END-PERFORM.
 END PROGRAM TEST-CMD-DAMAGE.

 COPY CORETEST.
 COPY CMDTEST.
