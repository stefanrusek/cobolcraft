*> Acceptance test of docs/protocol/16-commands-catalog.md §5.15 `waypoint` (permission level 2) with 14a: waypoint list | waypoint modify <waypoint> color <team colour> | color hex <hex> |
*> color reset | style reset | style set <style>. The waypoints of the level are the living entities of the source's dimension whose waypoint_transmit_range attribute is above 0 (the default is 0:
*> /attribute raises it); list tells commands.waypoint.list.success [count, dimension id, "x, y, z" block coordinates joined by ", "] or .list.empty [dimension id]; modify keeps the colour
*> (team colour, hex colour, reset) and style (set, reset) of a living entity and tells commands.waypoint.modify.color [colour name or #RRGGBB] / .color.reset / .style (all to the source
*> only); the result is the number of waypoints for list, 1 for modify (the catalog gives none). A ground item cannot be a waypoint (argument.entity.notfound.entity). Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-WAYPOINT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY CITEMS.
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
 01 WS-ALICE-ID            BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-MOB-ID              BINARY-LONG.
 01 WS-HELD-KIND           BINARY-LONG.
 01 WS-HELD-COLOR          BINARY-LONG.
 01 WS-HELD-STYLE          PIC X(64).
 01 WS-ITEM-ROW            BINARY-LONG.
 01 WS-Y                   FLOAT-LONG VALUE 70.
 01 WS-SX                  FLOAT-LONG VALUE 30.
 01 WS-SZ                  FLOAT-LONG VALUE 30.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ZERO-B              FLOAT-LONG VALUE 0.
 01 WS-ZERO-C              FLOAT-LONG VALUE 0.
 01 WS-STONE               BINARY-LONG VALUE 1.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-DELAY               BINARY-LONG VALUE 0.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     MOVE PL-ENTITY-ID(CN-PLAYER(WS-ID-ALICE)) TO WS-ALICE-ID
     MOVE "summon cobolcraft:sodgrazer 5.0 64.0 5.0" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "teleport Alice 20.5 70.0 20.5" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "GI-SPAWN" USING WS-DIM WS-SX WS-Y WS-SZ WS-ZERO WS-ZERO-B WS-ZERO-C WS-STONE WS-ONE WS-DELAY WS-ITEM-ROW
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /waypoint list with no waypoint: No waypoints in cobolcraft:main" TO TL-CASE
     MOVE "waypoint list" TO WS-LINE
     MOVE "commands.waypoint.list.empty(cobolcraft:main)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /waypoint list result is the number of waypoints" TO TL-CASE
     MOVE "waypoint list" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /waypoint a mob is a waypoint once its transmit range is above 0" TO TL-CASE
     MOVE "attribute @e[type=cobolcraft:sodgrazer,x=5,y=64,z=5,sort=nearest,limit=1] minecraft:waypoint_transmit_range base set 100" TO WS-LINE
     MOVE "commands.attribute.base_value.set.success(minecraft:waypoint_transmit_range,cobolcraft:sodgrazer,100.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /waypoint list of one waypoint with its block coordinates" TO TL-CASE
     MOVE "waypoint list" TO WS-LINE
     MOVE "commands.waypoint.list.success(1,cobolcraft:main,5, 64, 5)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /waypoint a player with a transmit range is listed too (players first)" TO TL-CASE
     MOVE "attribute Alice minecraft:waypoint_transmit_range modifier add test:range 5 add_value" TO WS-LINE
     MOVE "commands.attribute.modifier.add.success(test:range,minecraft:waypoint_transmit_range,Alice)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /waypoint list of two waypoints: Alice at 20, 70, 20 then the mob" TO TL-CASE
     MOVE "waypoint list" TO WS-LINE
     MOVE "commands.waypoint.list.success(2,cobolcraft:main,20, 70, 20, 5, 64, 5)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /waypoint list result with two" TO TL-CASE
     MOVE "waypoint list" TO WS-LINE
     MOVE 2 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /waypoint modify color with a team colour: Waypoint color is now red" TO TL-CASE
     MOVE "waypoint modify Alice color red" TO WS-LINE
     MOVE "commands.waypoint.modify.color(red)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /waypoint modify returns 1" TO TL-CASE
     MOVE "waypoint modify Alice color red" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /waypoint the team colour red is kept as colour 12 of kind 1" TO TL-CASE
     CALL "TEST-WP-FIND" USING WS-ALICE-ID WS-HELD-KIND WS-HELD-COLOR WS-HELD-STYLE
     MOVE 1 TO WS-EXPECTED-N
     MOVE WS-HELD-KIND TO WS-NUM
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE 12 TO WS-EXPECTED-N
     MOVE WS-HELD-COLOR TO WS-NUM
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE SPACES TO WS-EXPECTED
     MOVE WS-HELD-STYLE TO WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /waypoint modify color with a hex colour (three digits are doubled)" TO TL-CASE
     MOVE "waypoint modify Alice color hex f80" TO WS-LINE
     MOVE "commands.waypoint.modify.color(#FF8800)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /waypoint the hex colour is kept as the RGB value" TO TL-CASE
     CALL "TEST-WP-FIND" USING WS-ALICE-ID WS-HELD-KIND WS-HELD-COLOR WS-HELD-STYLE
     MOVE 2 TO WS-EXPECTED-N
     MOVE WS-HELD-KIND TO WS-NUM
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE 16746496 TO WS-EXPECTED-N
     MOVE WS-HELD-COLOR TO WS-NUM
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE SPACES TO WS-EXPECTED
     MOVE WS-HELD-STYLE TO WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /waypoint modify color reset: Reset waypoint color" TO TL-CASE
     MOVE "waypoint modify Alice color reset" TO WS-LINE
     MOVE "commands.waypoint.modify.color.reset()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /waypoint after reset no colour is set" TO TL-CASE
     CALL "TEST-WP-FIND" USING WS-ALICE-ID WS-HELD-KIND WS-HELD-COLOR WS-HELD-STYLE
     MOVE 0 TO WS-EXPECTED-N
     MOVE WS-HELD-KIND TO WS-NUM
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE 0 TO WS-EXPECTED-N
     MOVE WS-HELD-COLOR TO WS-NUM
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE SPACES TO WS-EXPECTED
     MOVE WS-HELD-STYLE TO WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /waypoint modify style set: Waypoint style changed" TO TL-CASE
     MOVE "waypoint modify Alice style set arrow" TO WS-LINE
     MOVE "commands.waypoint.modify.style()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /waypoint the style is kept with its namespace" TO TL-CASE
     CALL "TEST-WP-FIND" USING WS-ALICE-ID WS-HELD-KIND WS-HELD-COLOR WS-HELD-STYLE
     MOVE 0 TO WS-EXPECTED-N
     MOVE WS-HELD-KIND TO WS-NUM
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE 0 TO WS-EXPECTED-N
     MOVE WS-HELD-COLOR TO WS-NUM
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "minecraft:arrow" TO WS-EXPECTED
     MOVE WS-HELD-STYLE TO WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /waypoint modify style reset" TO TL-CASE
     MOVE "waypoint modify Alice style reset" TO WS-LINE
     MOVE "commands.waypoint.modify.style()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /waypoint after style reset the default style is used" TO TL-CASE
     CALL "TEST-WP-FIND" USING WS-ALICE-ID WS-HELD-KIND WS-HELD-COLOR WS-HELD-STYLE
     MOVE 0 TO WS-EXPECTED-N
     MOVE WS-HELD-KIND TO WS-NUM
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE 0 TO WS-EXPECTED-N
     MOVE WS-HELD-COLOR TO WS-NUM
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE SPACES TO WS-EXPECTED
     MOVE WS-HELD-STYLE TO WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /waypoint modify a mob with a six-digit hex colour" TO TL-CASE
     MOVE "waypoint modify @e[type=cobolcraft:sodgrazer,x=5,y=64,z=5,sort=nearest,limit=1] color hex 00ff7f" TO WS-LINE
     MOVE "commands.waypoint.modify.color(#00FF7F)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /waypoint a ground item is no waypoint" TO TL-CASE
     MOVE "waypoint modify @e[type=cobolcraft:loose_item,limit=1] color reset" TO WS-LINE
     MOVE "argument.entity.notfound.entity()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE 5 TO WS-X
     MOVE 5 TO WS-Z
     CALL "TEST-MOB-ID" USING WS-X WS-Z WS-MOB-ID
     MOVE "kill @e[type=cobolcraft:sodgrazer,x=5,y=64,z=5,sort=nearest,limit=1]" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "acceptance US13 /waypoint a removed entity's settings are freed and it leaves the list" TO TL-CASE
     MOVE "waypoint list" TO WS-LINE
     MOVE "commands.waypoint.list.success(1,cobolcraft:main,20, 70, 20)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     CALL "TEST-WP-FIND" USING WS-MOB-ID WS-HELD-KIND WS-HELD-COLOR WS-HELD-STYLE
     MOVE -1 TO WS-EXPECTED-N
     MOVE WS-HELD-KIND TO WS-NUM
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /waypoint a player without operator status does not know the command" TO TL-CASE
     MOVE "waypoint list" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /waypoint the console lists the waypoints in English" TO TL-CASE
     MOVE "waypoint list" TO WS-LINE
     MOVE "1 waypoint(s) in cobolcraft:main: 20, 70, 20" TO WS-EXPECTED
     CALL "TA-CHECK-CONSOLE" USING TL-CASE WS-LINE WS-EXPECTED
     GOBACK.
 END PROGRAM TEST-CMD-WAYPOINT.

*> The colour kind, colour and style of the settings of the entity with that network id (kind -1 = no entry).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-WP-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY WPSTORE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-COLOR                BINARY-LONG.
 01 L-STYLE                PIC X(64).
 PROCEDURE DIVISION USING L-ID L-KIND L-COLOR L-STYLE.
     MOVE -1 TO L-KIND
     MOVE 0 TO L-COLOR
     MOVE SPACES TO L-STYLE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WP-MAX
         IF WP-ID(WS-I) = L-ID
             MOVE WP-COLOR-KIND(WS-I) TO L-KIND
             MOVE WP-COLOR(WS-I) TO L-COLOR
             IF WP-STYLE-LENGTH(WS-I) > 0
                 MOVE WP-STYLE(WS-I) TO L-STYLE
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TEST-WP-FIND.

*> The network entity id of the mob that stands at block x, z (in any dimension) of CORE-ENTITIES.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-ID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Z L-ID.
     MOVE 0 TO L-ID
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND FUNCTION ABS(EN-X(WS-I) - L-X) < 0.01
                 AND FUNCTION ABS(EN-Z(WS-I) - L-Z) < 0.01
             MOVE EN-ID(WS-I) TO L-ID
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TEST-MOB-ID.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
