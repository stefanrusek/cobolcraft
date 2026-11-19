*> Implementation test (lane p49w; a standard world of the generated vanilla data pack (CC_GENERATED_DIR), skipped as a pass without it: the wool tags are data; docs/protocol/30-redstone-8 sections 2, 3.1, 3.5, 3.6; 20 section 15.1): the game event emitter GAME-EVENT and the rules it applies before a listener hears an event.
*> - the warden's listenable tag (flap out, shriek and the tendrils in, the zero-frequency events out), the frequency of an event, the sneaking tag (step);
*> - the shared validity: a spectator source, the warden itself and wool as the affected state are not valid; a sneaking player's step is filtered, its block_destroy is not;
*> - occlusion: a wall of wool across the line hides the event, a hole in it lets the event through; six rays from 0.00001 around the event centre, occluded only when every ray meets wool (a diagonal neighbour:
*>   wool on one of the two side cells leaves two rays clear, on both none); computed independently (exact rational voxel walk).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GAME-EVENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY STDMOBS.
 COPY WARDENSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-PROW                BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-WARDEN              BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 40.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-WOOL                BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-NONE                BINARY-LONG VALUE -1.
 01 WS-EVENT               PIC X(32).
 01 WS-SKIP                BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FREQ                BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-OCCLUDED            BINARY-LONG.
 01 WS-EX                  FLOAT-LONG.
 01 WS-EY                  FLOAT-LONG.
 01 WS-EZ                  FLOAT-LONG.
 01 WS-LX                  FLOAT-LONG.
 01 WS-LY                  FLOAT-LONG.
 01 WS-LZ                  FLOAT-LONG.
 01 WS-SOURCE              BINARY-LONG.
 01 WS-TICKS0              BINARY-DOUBLE.
 PROCEDURE DIVISION.
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "implementation 30-8 game events: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 201 TO PL-Y(WS-PLAYER)
     MOVE PL-ENTITY-ROW(WS-PLAYER) TO WS-PROW
     MOVE "N" TO TL-MODE
     MOVE "minecraft:warden" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X)
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y)
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z)
     COMPUTE WS-FX = WS-BX - 20
     COMPUTE WS-FZ = WS-BZ - 20
     MOVE 200 TO WS-FY
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     MOVE "minecraft:white_wool" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-WOOL
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE 12001 TO CW-TIME

*>   1. The tags and the frequency table.
     MOVE "step" TO WS-EVENT
     PERFORM CHECK-LISTENS-1
     MOVE "flap" TO WS-EVENT
     PERFORM CHECK-LISTENS-0
     MOVE "shriek" TO WS-EVENT
     PERFORM CHECK-LISTENS-1
     MOVE "sculk_sensor_tendrils_clicking" TO WS-EVENT
     PERFORM CHECK-LISTENS-1
     MOVE "jukebox_play" TO WS-EVENT
     PERFORM CHECK-LISTENS-0
     MOVE "item_interact_start" TO WS-EVENT
     PERFORM CHECK-LISTENS-0
     MOVE "resonate_3" TO WS-EVENT
     PERFORM CHECK-LISTENS-1
     MOVE "explode" TO WS-EVENT
     PERFORM CHECK-LISTENS-1
     MOVE "no_such_event" TO WS-EVENT
     PERFORM CHECK-LISTENS-0
     MOVE "block_destroy" TO WS-EVENT
     CALL "GAME-EVENT-FREQUENCY" USING WS-EVENT WS-FREQ
     MOVE "the frequency of block_destroy is 12 (30 section 3.1)" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE WS-FREQ TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "entity_die" TO WS-EVENT
     CALL "GAME-EVENT-FREQUENCY" USING WS-EVENT WS-FREQ
     MOVE "the frequency of entity_die is 15" TO TL-CASE
     MOVE 15 TO TL-EXPECTED-N
     MOVE WS-FREQ TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "step" TO WS-EVENT
     CALL "GAME-EVENT-SNEAKS" USING WS-EVENT WS-FLAG
     MOVE "step is in ignore_vibrations_sneaking" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "block_place" TO WS-EVENT
     CALL "GAME-EVENT-SNEAKS" USING WS-EVENT WS-FLAG
     MOVE "block_place is not in ignore_vibrations_sneaking" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     PERFORM CASE-LINE

*>   2. The emitter against a warden 10 blocks west of the player (same height): the listener point is 2.465 above its feet, so the distance is 10.3 and the travel time 10 ticks.
     MOVE 1000 TO CW-TICKS
     PERFORM NEW-WARDEN
     MOVE "step" TO WS-EVENT
     CALL "GAME-EVENT-AT" USING WS-EVENT WS-PROW
     MOVE "a survival player's step is heard: due after floor(10.3) = 10 ticks" TO TL-CASE
     COMPUTE TL-EXPECTED-N = CW-TICKS + 10
     MOVE WD-V-DUE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "and its source is the player" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE WD-V-SRC(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "ENTITY-REMOVE" USING WS-WARDEN

     PERFORM NEW-WARDEN
     MOVE 2 TO PL-POSE-FLAGS(WS-PLAYER)
     MOVE "step" TO WS-EVENT
     CALL "GAME-EVENT-AT" USING WS-EVENT WS-PROW
     MOVE "a sneaking player's step is filtered (ignore_vibrations_sneaking)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-V-DUE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "block_destroy" TO WS-EVENT
     CALL "GAME-EVENT-AT" USING WS-EVENT WS-PROW
     MOVE "a sneaking player's block_destroy is not filtered: heard" TO TL-CASE
     COMPUTE TL-EXPECTED-N = CW-TICKS + 10
     MOVE WD-V-DUE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 0 TO PL-POSE-FLAGS(WS-PLAYER)
     CALL "ENTITY-REMOVE" USING WS-WARDEN

     PERFORM NEW-WARDEN
     MOVE 3 TO PL-MODE(WS-PLAYER)
     MOVE "block_destroy" TO WS-EVENT
     CALL "GAME-EVENT-AT" USING WS-EVENT WS-PROW
     MOVE "a spectator source is not valid" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-V-DUE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 0 TO PL-MODE(WS-PLAYER)
     CALL "ENTITY-REMOVE" USING WS-WARDEN

     PERFORM NEW-WARDEN
     CALL "GAME-EVENT-AT" USING WS-EVENT WS-WARDEN
     MOVE "the warden dampens vibrations: it never hears its own event" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-V-DUE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "ENTITY-REMOVE" USING WS-WARDEN

     PERFORM NEW-WARDEN
     MOVE "block_destroy" TO WS-EVENT
     CALL "GAME-EVENT" USING WS-DIM WS-X WS-Y WS-Z WS-EVENT WS-PROW WS-WOOL
     MOVE "wool as the affected state dampens the event (block tag dampens_vibrations)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-V-DUE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "GAME-EVENT" USING WS-DIM WS-X WS-Y WS-Z WS-EVENT WS-PROW WS-STONE
     MOVE "stone as the affected state does not" TO TL-CASE
     COMPUTE TL-EXPECTED-N = CW-TICKS + 10
     MOVE WD-V-DUE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "ENTITY-REMOVE" USING WS-WARDEN

     PERFORM NEW-WARDEN
     MOVE "flap" TO WS-EVENT
     CALL "GAME-EVENT" USING WS-DIM WS-X WS-Y WS-Z WS-EVENT WS-PROW WS-NONE
     MOVE "flap is not in warden_can_listen" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-V-DUE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "item_interact_start" TO WS-EVENT
     CALL "GAME-EVENT" USING WS-DIM WS-X WS-Y WS-Z WS-EVENT WS-PROW WS-NONE
     MOVE "an event of frequency 0 is dropped" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-V-DUE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "shriek" TO WS-EVENT
     CALL "GAME-EVENT" USING WS-DIM WS-X WS-Y WS-Z WS-EVENT WS-PROW WS-NONE
     MOVE "a shriek is heard although its frequency is 0" TO TL-CASE
     COMPUTE TL-EXPECTED-N = CW-TICKS + 10
     MOVE WD-V-DUE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "ENTITY-REMOVE" USING WS-WARDEN

*>   3. Occlusion. A wall of wool (x = player block - 5, 7 high, 7 wide) across the line hides the event; a hole where the line crosses it (cell y + 1, the line is at y + 1.5 there) lets it through.
     PERFORM NEW-WARDEN
     COMPUTE WS-CX = WS-BX - 5
     PERFORM VARYING WS-CY FROM WS-FY BY 1 UNTIL WS-CY > WS-BY + 3
         COMPUTE WS-CZ = WS-BZ - 3
         PERFORM UNTIL WS-CZ > WS-BZ + 3
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-WOOL
             ADD 1 TO WS-CZ
         END-PERFORM
     END-PERFORM
     MOVE "block_destroy" TO WS-EVENT
     CALL "GAME-EVENT" USING WS-DIM WS-X WS-Y WS-Z WS-EVENT WS-PROW WS-NONE
     MOVE "a wall of wool across the line occludes the event" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-V-DUE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     COMPUTE WS-CY = WS-BY + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-BZ WS-AIR
     CALL "GAME-EVENT" USING WS-DIM WS-X WS-Y WS-Z WS-EVENT WS-PROW WS-NONE
     MOVE "a hole in the wall where the line crosses lets the event through" TO TL-CASE
     COMPUTE TL-EXPECTED-N = CW-TICKS + 10
     MOVE WD-V-DUE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "ENTITY-REMOVE" USING WS-WARDEN

*>   The six rays: event cell (bx, by, bz), listener cell one step on x and z. Rays down, up, north, east pass the x neighbour first, south and west the z neighbour first.
     MOVE WS-BX TO WS-CX
     MOVE WS-BZ TO WS-CZ
     COMPUTE WS-EX = WS-BX + 0.7
     COMPUTE WS-EY = WS-BY + 0.3
     COMPUTE WS-EZ = WS-BZ + 0.2
     COMPUTE WS-LX = WS-BX + 1.9
     COMPUTE WS-LY = WS-BY + 0.9
     COMPUTE WS-LZ = WS-BZ + 1.5
     CALL "GAME-EVENT-OCCLUDED" USING WS-DIM WS-EX WS-EY WS-EZ WS-LX WS-LY WS-LZ WS-OCCLUDED
     MOVE "no wool: not occluded" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OCCLUDED TO TL-OBSERVED-N
     PERFORM CASE-LINE
     COMPUTE WS-CX = WS-BX + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-BY WS-BZ WS-WOOL
     CALL "GAME-EVENT-OCCLUDED" USING WS-DIM WS-EX WS-EY WS-EZ WS-LX WS-LY WS-LZ WS-OCCLUDED
     MOVE "wool on the x side cell only: the south and west rays are clear, not occluded" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OCCLUDED TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-BY WS-BZ WS-AIR
     COMPUTE WS-CZ = WS-BZ + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-CZ WS-WOOL
     CALL "GAME-EVENT-OCCLUDED" USING WS-DIM WS-EX WS-EY WS-EZ WS-LX WS-LY WS-LZ WS-OCCLUDED
     MOVE "wool on the z side cell only: the other four rays are clear, not occluded" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OCCLUDED TO TL-OBSERVED-N
     PERFORM CASE-LINE
     COMPUTE WS-CX = WS-BX + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-BY WS-BZ WS-WOOL
     CALL "GAME-EVENT-OCCLUDED" USING WS-DIM WS-EX WS-EY WS-EZ WS-LX WS-LY WS-LZ WS-OCCLUDED
     MOVE "wool on both side cells: every ray meets it, occluded" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OCCLUDED TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-BY WS-BZ WS-AIR
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-CZ WS-AIR
     MOVE "a stone block on the side cell does not occlude (only the wool tag does)" TO TL-CASE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-BY WS-BZ WS-STONE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-CZ WS-STONE
     CALL "GAME-EVENT-OCCLUDED" USING WS-DIM WS-EX WS-EY WS-EZ WS-LX WS-LY WS-LZ WS-OCCLUDED
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OCCLUDED TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-BY WS-BZ WS-AIR
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-CZ WS-AIR
*>   A straight ray with the vertical offsets: the line down one column crosses wool in the middle cell.
     COMPUTE WS-EX = WS-BX + 0.5
     COMPUTE WS-EY = WS-BY + 0.5
     COMPUTE WS-EZ = WS-BZ + 0.5
     COMPUTE WS-LX = WS-BX + 0.5
     COMPUTE WS-LY = WS-BY + 4.5
     COMPUTE WS-LZ = WS-BZ + 0.5
     COMPUTE WS-CY = WS-BY + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CY WS-BZ WS-WOOL
     CALL "GAME-EVENT-OCCLUDED" USING WS-DIM WS-EX WS-EY WS-EZ WS-LX WS-LY WS-LZ WS-OCCLUDED
     MOVE "a wool block in the column between two points on one vertical line occludes" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OCCLUDED TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CY WS-BZ WS-AIR
*>   The same line walked downwards and in the other horizontal directions.
     COMPUTE WS-CY = WS-BY + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CY WS-BZ WS-WOOL
     CALL "GAME-EVENT-OCCLUDED" USING WS-DIM WS-LX WS-LY WS-LZ WS-EX WS-EY WS-EZ WS-OCCLUDED
     MOVE "walked from the top to the bottom it is occluded too" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OCCLUDED TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CY WS-BZ WS-AIR
     COMPUTE WS-EX = WS-BX - 3.5
     COMPUTE WS-EZ = WS-BZ - 3.5
     COMPUTE WS-LX = WS-BX - 5.5
     COMPUTE WS-LZ = WS-BZ - 5.5
     COMPUTE WS-LY = WS-BY + 0.5
     COMPUTE WS-CX = WS-BX - 5
     COMPUTE WS-CZ = WS-BZ - 4
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-BY WS-CZ WS-WOOL
     CALL "GAME-EVENT-OCCLUDED" USING WS-DIM WS-EX WS-EY WS-EZ WS-LX WS-LY WS-LZ WS-OCCLUDED
     MOVE "a diagonal line towards negative x and z, wool on one of the two cells beside the diagonal: the rays split, not occluded" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OCCLUDED TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-BY WS-CZ WS-AIR
     STOP RUN.

 CHECK-LISTENS-1.
     CALL "GAME-EVENT-LISTENS" USING WS-EVENT WS-FLAG
     MOVE SPACES TO TL-CASE
     STRING FUNCTION TRIM(WS-EVENT) DELIMITED BY SIZE " is in warden_can_listen" DELIMITED BY SIZE INTO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     PERFORM CASE-LINE
     .

 CHECK-LISTENS-0.
     CALL "GAME-EVENT-LISTENS" USING WS-EVENT WS-FLAG
     MOVE SPACES TO TL-CASE
     STRING FUNCTION TRIM(WS-EVENT) DELIMITED BY SIZE " is not in warden_can_listen" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     PERFORM CASE-LINE
     .

 CASE-LINE.
     MOVE SPACES TO WS-ENTITY-ROW
     STRING "implementation 30-8 game events: " DELIMITED BY SIZE FUNCTION TRIM(TL-CASE) DELIMITED BY SIZE INTO WS-ENTITY-ROW
     MOVE WS-ENTITY-ROW TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .

*> A new warden 10 blocks west of the player (survival, alive), its state slot with no cooldown: the next event is heard when valid.
 NEW-WARDEN.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WD-MAX
         INITIALIZE WD-ENTRY(WS-I)
     END-PERFORM
     COMPUTE WS-X0 = WS-BX + 0.5 - 10
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE WS-Z = WS-BZ + 0.5
     MOVE WS-BY TO WS-Y
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE PS-ALIVE TO PL-STATE(WS-PLAYER)
     MOVE WS-X TO PL-X(WS-PLAYER)
     MOVE WS-Y TO PL-Y(WS-PLAYER)
     MOVE WS-Z TO PL-Z(WS-PLAYER)
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-WARDEN
     CALL "WD-FIND" USING EN-ID(WS-WARDEN) WS-ONE WS-W
     MOVE 5 TO WD-SENSOR(WS-W)
     MOVE 0 TO EN-WAKE(WS-WARDEN) EN-TARGET(WS-WARDEN)
     .
 END PROGRAM TEST-GAME-EVENT.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY PORTALTEST.
