*> Acceptance test (lane p49w; docs/protocol/20 section 15.1, 29 sections 8 and 9 (BLOCK_PLACE, BLOCK_DESTROY), 17 section 4 and 18 section 2 (entity_damage, entity_die), 20 section 6.2 (explode), 44-8 section 6.1 (projectile_shoot)):
*> the game events the core posts, in a standard world of the generated vanilla data pack (CC_GENERATED_DIR, skipped as a pass without it). GE-LAST (GAMEEVENT.cpy) records what was posted; a warden 10 blocks west of the
*> player is the listener that shows who hears it.
*> - a player places a block (Use Item On): block_place at the block centre, the player the source, the placed state the affected state; wool is not heard (dampens_vibrations);
*> - a player breaks a block (survival at once, creative): block_destroy at the block centre with the state it had; a creative player is posted but not heard;
*> - a hurt living entity posts entity_damage at its own position with itself as the source (a player, a mob); lethal damage posts it too, and then entity_die; the dying are not heard (canTargetEntity);
*> - an explosion posts explode at its centre with its source entity; an arrow posts projectile_shoot at its position with its owner as the source.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-WARDEN-EVENTS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY STDMOBS.
 COPY WARDENSTATE.
 COPY GAMEEVENT.
 COPY RULES.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-PROW                BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-WTYPE               BINARY-LONG.
 01 WS-ZTYPE               BINARY-LONG.
 01 WS-WARDEN              BINARY-LONG.
 01 WS-ZOMBIE              BINARY-LONG.
 01 WS-ZCODE               BINARY-LONG.
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
 01 WS-PX                  BINARY-LONG.
 01 WS-SKIP                BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-STONE               BINARY-LONG.
 01 WS-WOOL                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-COUNT0              BINARY-DOUBLE.
 01 WS-IID                 BINARY-LONG.
 01 WS-BID                 BINARY-LONG.
 01 WS-IROW                PIC X(270).
 01 WS-BROW                PIC X(819).
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-ACTION              BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-NONE2               BINARY-LONG VALUE 0.
 01 WS-POWER               FLOAT-LONG VALUE 0.1.
 01 WS-DESTROY             BINARY-LONG VALUE 0.
 01 WS-CX                  FLOAT-LONG.
 01 WS-CY                  FLOAT-LONG.
 01 WS-CZ                  FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG VALUE 0.
 01 WS-VY                  FLOAT-LONG VALUE 0.
 01 WS-VZ                  FLOAT-LONG VALUE 1.
 01 WS-BASE                BINARY-LONG VALUE 2000.
 01 WS-ARROW               BINARY-LONG.
 01 WS-NAME-OBSERVED       PIC X(32).
 PROCEDURE DIVISION.
     CALL "WEV-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance US15 20§15 warden events: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-ENTITY-ROW(WS-PLAYER) TO WS-PROW
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE "minecraft:warden" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-WTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE "minecraft:white_wool" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-WOOL
     MOVE 201 TO PL-Y(WS-PLAYER)
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     MOVE 201 TO WS-BY
     COMPUTE WS-FX = WS-BX - 20
     COMPUTE WS-FZ = WS-BZ - 20
     MOVE 200 TO WS-FY
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     MOVE 12001 TO CW-TIME
     MOVE 1000 TO CW-TICKS
     COMPUTE WS-PX = WS-BX + 2
*>   Stone and white wool are the held items (hotbar slots 1 and 2); a placed stone breaks at once.
     MOVE "minecraft:stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BID WS-BROW WS-STATUS
     MOVE 0 TO CB-BREAK-MS(WS-BID + 1)
     MOVE "minecraft:stone" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-IID WS-IROW WS-STATUS
     MOVE WS-IID TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 40 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE "minecraft:white_wool" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-IID WS-IROW WS-STATUS
     MOVE WS-IID TO PL-SLOT-ITEM(WS-PLAYER, 2)
     MOVE 40 TO PL-SLOT-COUNT(WS-PLAYER, 2)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 2)
     MOVE 0 TO PL-HELD(WS-PLAYER)

     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-PX WS-BY WS-BZ WS-AIR
*>   1. Placing: stone on the floor at (px, 200, bz) puts the block at (px, 201, bz), 12 blocks east of the warden's column: the event is at its centre (px + 0.5, 201.5, bz + 0.5), the listener point 2.465 above the
*>   feet at y 201, so the distance is sqrt(144 + 1.965 squared) = 12.16 and the warden is told 12 ticks later.
     PERFORM NEW-SCENE
     MOVE GE-COUNT TO WS-COUNT0
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-PX WS-FY WS-BZ WS-FACE WS-SEQ
     MOVE "placing a block posts block_place" TO TL-CASE
     MOVE "block_place" TO TL-EXPECTED
     MOVE GE-NAME TO TL-OBSERVED
     PERFORM CASE-TEXT
     MOVE "exactly one event was posted" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-COUNT0 + 1
     MOVE GE-COUNT TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "its source is the player's entity" TO TL-CASE
     MOVE WS-PROW TO TL-EXPECTED-N
     MOVE GE-SOURCE TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "its affected state is the placed state (stone)" TO TL-CASE
     MOVE WS-STONE TO TL-EXPECTED-N
     MOVE GE-STATE TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "its position is the block centre (x)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-PX * 1000 + 500
     COMPUTE TL-OBSERVED-N ROUNDED = GE-X * 1000
     PERFORM CASE-LINE
     MOVE "its position is the block centre (y)" TO TL-CASE
     MOVE 201500 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = GE-Y * 1000
     PERFORM CASE-LINE
     MOVE "the warden hears it: due after floor(12.16) = 12 ticks" TO TL-CASE
     COMPUTE TL-EXPECTED-N = CW-TICKS + 12
     MOVE WD-V-DUE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "and the source is the player" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE WD-V-SRC(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM END-SCENE

*>   2. Breaking the placed stone (Start Digging, instant in survival): block_destroy with the old state.
     PERFORM NEW-SCENE
     MOVE GE-COUNT TO WS-COUNT0
     MOVE 0 TO WS-ACTION
     ADD 1 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-CONN WS-ACTION WS-PX WS-BY WS-BZ WS-FACE WS-SEQ
     MOVE "breaking a block posts block_destroy" TO TL-CASE
     MOVE "block_destroy" TO TL-EXPECTED
     MOVE GE-NAME TO TL-OBSERVED
     PERFORM CASE-TEXT
     MOVE "exactly one event was posted" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-COUNT0 + 1
     MOVE GE-COUNT TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "its affected state is the state the block had (stone)" TO TL-CASE
     MOVE WS-STONE TO TL-EXPECTED-N
     MOVE GE-STATE TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "the warden hears it" TO TL-CASE
     COMPUTE TL-EXPECTED-N = CW-TICKS + 12
     MOVE WD-V-DUE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM END-SCENE

*>   Creative: the block goes at once; the event is posted but a creative player cannot be targeted, so nobody is told.
     PERFORM NEW-SCENE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-PX WS-BY WS-BZ WS-STONE
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE GE-COUNT TO WS-COUNT0
     ADD 1 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-CONN WS-ACTION WS-PX WS-BY WS-BZ WS-FACE WS-SEQ
     MOVE "a creative break posts block_destroy" TO TL-CASE
     MOVE "block_destroy" TO TL-EXPECTED
     MOVE GE-NAME TO TL-OBSERVED
     PERFORM CASE-TEXT
     MOVE "with the old state" TO TL-CASE
     MOVE WS-STONE TO TL-EXPECTED-N
     MOVE GE-STATE TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "a creative player is not heard by the warden" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-V-DUE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM END-SCENE

*>   Wool is held in slot 2: placing it posts the event with the wool state, which dampens it.
     PERFORM NEW-SCENE
     MOVE 1 TO PL-HELD(WS-PLAYER)
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-PX WS-FY WS-BZ WS-FACE WS-SEQ
     MOVE 0 TO PL-HELD(WS-PLAYER)
     MOVE "placing wool posts block_place with the wool state" TO TL-CASE
     MOVE WS-WOOL TO TL-EXPECTED-N
     MOVE GE-STATE TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "and the warden does not hear it (dampens_vibrations)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-V-DUE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-PX WS-BY WS-BZ WS-AIR
     PERFORM END-SCENE

*>   3. Damage. A hurt player posts entity_damage at its own position with itself as the source.
     PERFORM NEW-SCENE
     MOVE GE-COUNT TO WS-COUNT0
     MOVE 1 TO WS-AMOUNT
     MOVE CAUSE-MOB TO WS-CAUSE
     CALL "HEALTH-DAMAGE" USING WS-PLAYER WS-AMOUNT WS-CAUSE WS-NONE WS-NONE2
     MOVE "a hurt player posts entity_damage" TO TL-CASE
     MOVE "entity_damage" TO TL-EXPECTED
     MOVE GE-NAME TO TL-OBSERVED
     PERFORM CASE-TEXT
     MOVE "with the player's entity as the source" TO TL-CASE
     MOVE WS-PROW TO TL-EXPECTED-N
     MOVE GE-SOURCE TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "at the player's position (x)" TO TL-CASE
     COMPUTE TL-EXPECTED-N ROUNDED = PL-X(WS-PLAYER) * 1000
     COMPUTE TL-OBSERVED-N ROUNDED = GE-X * 1000
     PERFORM CASE-LINE
     MOVE "the warden hears it: due after floor(10.3) = 10 ticks" TO TL-CASE
     COMPUTE TL-EXPECTED-N = CW-TICKS + 10
     MOVE WD-V-DUE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM END-SCENE

*>   A hurt zombie (a mob victim, 1 of its 20 points): the event is at the zombie with the zombie as the source; the warden hears it too.
     PERFORM NEW-SCENE
     MOVE GE-COUNT TO WS-COUNT0
     CALL "HEALTH-MOB-DAMAGE" USING WS-ZOMBIE WS-AMOUNT WS-CAUSE WS-NONE
     MOVE "a hurt mob posts entity_damage with itself as the source" TO TL-CASE
     MOVE WS-ZOMBIE TO TL-EXPECTED-N
     MOVE GE-SOURCE TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "entity_damage is the name" TO TL-CASE
     MOVE "entity_damage" TO TL-EXPECTED
     MOVE GE-NAME TO TL-OBSERVED
     PERFORM CASE-TEXT
     MOVE "one event for one hit" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-COUNT0 + 1
     MOVE GE-COUNT TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "the warden hears it: the source is the mob" TO TL-CASE
     MOVE WS-ZCODE TO TL-EXPECTED-N
     MOVE WD-V-SRC(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 0 TO EN-HURT(WS-ZOMBIE)
*>   A second hit after the hurt window: lethal. entity_damage, then entity_die at the mob; nobody hears a dying source.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WD-MAX
         MOVE 0 TO WD-V-DUE(WS-I)
     END-PERFORM
     MOVE 50 TO WS-AMOUNT
     MOVE GE-COUNT TO WS-COUNT0
     CALL "HEALTH-MOB-DAMAGE" USING WS-ZOMBIE WS-AMOUNT WS-CAUSE WS-NONE
     MOVE "a lethal hit posts entity_damage and then entity_die" TO TL-CASE
     MOVE "entity_die" TO TL-EXPECTED
     MOVE GE-NAME TO TL-OBSERVED
     PERFORM CASE-TEXT
     MOVE "two events: damage and death" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-COUNT0 + 2
     MOVE GE-COUNT TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "the source of entity_die is the dying mob" TO TL-CASE
     MOVE WS-ZOMBIE TO TL-EXPECTED-N
     MOVE GE-SOURCE TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "a dying mob cannot be targeted: the warden does not hear its death" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-V-DUE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM END-SCENE

*>   4. An explosion far from every entity (power 0.1) 6 east and 8 north of the warden: explode at its centre, no source; the distance to the listener point is sqrt(36 + 64 + 1.965 squared) = 10.19: 10 ticks.
     PERFORM NEW-SCENE
     COMPUTE WS-CX = WS-BX + 0.5 - 9.5 + 6
     COMPUTE WS-CY = 201.5
     COMPUTE WS-CZ = WS-BZ + 0.5 - 8
     MOVE GE-COUNT TO WS-COUNT0
     CALL "EXPLODE-RUN" USING WS-DIM WS-CX WS-CY WS-CZ WS-POWER WS-DESTROY WS-NONE
     MOVE "an explosion posts explode" TO TL-CASE
     MOVE "explode" TO TL-EXPECTED
     MOVE GE-NAME TO TL-OBSERVED
     PERFORM CASE-TEXT
     MOVE "first and once (nothing else is posted by it)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-COUNT0 + 1
     MOVE GE-COUNT TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "at its centre (z)" TO TL-CASE
     COMPUTE TL-EXPECTED-N ROUNDED = WS-CZ * 1000
     COMPUTE TL-OBSERVED-N ROUNDED = GE-Z * 1000
     PERFORM CASE-LINE
     MOVE "with no source entity" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE GE-SOURCE TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "the warden hears it after 10 ticks" TO TL-CASE
     COMPUTE TL-EXPECTED-N = CW-TICKS + 10
     MOVE WD-V-DUE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM END-SCENE

*>   An explosion whose source is the zombie: the event carries the zombie.
     PERFORM NEW-SCENE
     CALL "EXPLODE-RUN" USING WS-DIM WS-CX WS-CY WS-CZ WS-POWER WS-DESTROY WS-ZOMBIE
     MOVE "an explosion of a mob names the mob as the source" TO TL-CASE
     MOVE WS-ZOMBIE TO TL-EXPECTED-N
     MOVE GE-SOURCE TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM END-SCENE

*>   5. An arrow shot by the player: projectile_shoot at the arrow's position with the owner (the player's entity) as the source; the warden hears the player.
     PERFORM NEW-SCENE
     MOVE GE-COUNT TO WS-COUNT0
     MOVE WS-BX TO WS-CX
     COMPUTE WS-CX = WS-BX + 0.5
     MOVE 202 TO WS-CY
     COMPUTE WS-CZ = WS-BZ + 0.5
     COMPUTE WS-CX = WS-CX + 5
     CALL "ARROW-SPAWN" USING WS-DIM WS-CX WS-CY WS-CZ WS-VX WS-VY WS-VZ WS-BASE PL-ENTITY-ID(WS-PLAYER) WS-ARROW
*>   Projectile.tick posts projectile_shoot on the arrow's first tick (30-8 14.2.1), not at the spawn
     CALL "ARROW-STEP" USING WS-ARROW
     MOVE "an arrow posts projectile_shoot on its first tick" TO TL-CASE
     MOVE "projectile_shoot" TO TL-EXPECTED
     MOVE GE-NAME TO TL-OBSERVED
     PERFORM CASE-TEXT
     MOVE "the source is its owner, the player" TO TL-CASE
     MOVE WS-PROW TO TL-EXPECTED-N
     MOVE GE-SOURCE TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "the warden hears the player" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE WD-V-SRC(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "ENTITY-REMOVE" USING WS-ARROW
     MOVE 0 TO WS-ARROW
     COMPUTE WS-CX = WS-CX + 5
     CALL "ARROW-SPAWN" USING WS-DIM WS-CX WS-CY WS-CZ WS-VX WS-VY WS-VZ WS-BASE WS-NONE WS-ARROW
     CALL "ARROW-STEP" USING WS-ARROW
     MOVE "an arrow with no owner in the tracker has no source" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE GE-SOURCE TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "ENTITY-REMOVE" USING WS-ARROW
     PERFORM END-SCENE

*>   6. The player's death: entity_die at the player (a dead player is not heard). The last scene: the death sends the death screen.
     PERFORM NEW-SCENE
     MOVE 100 TO WS-AMOUNT
     CALL "HEALTH-DAMAGE" USING WS-PLAYER WS-AMOUNT WS-CAUSE WS-NONE WS-NONE2
     MOVE "a lethal hit on a player ends with entity_die" TO TL-CASE
     MOVE "entity_die" TO TL-EXPECTED
     MOVE GE-NAME TO TL-OBSERVED
     PERFORM CASE-TEXT
     MOVE "its source is the player's entity" TO TL-CASE
     MOVE WS-PROW TO TL-EXPECTED-N
     MOVE GE-SOURCE TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM END-SCENE
     STOP RUN.

 CASE-LINE.
     MOVE SPACES TO WS-ENTITY-ROW
     STRING "acceptance US15 20§15 warden events: " DELIMITED BY SIZE FUNCTION TRIM(TL-CASE) DELIMITED BY SIZE INTO WS-ENTITY-ROW
     MOVE WS-ENTITY-ROW TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .

 CASE-TEXT.
     MOVE "T" TO TL-MODE
     PERFORM CASE-LINE
     MOVE "N" TO TL-MODE
     .

*> A warden 10 blocks west of the player (survival, alive), a zombie at the player's place, no vibration pending.
 NEW-SCENE.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WD-MAX
         INITIALIZE WD-ENTRY(WS-I)
     END-PERFORM
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE WS-Z = WS-BZ + 0.5
     COMPUTE WS-X0 = WS-BX + 0.5 - 10
     MOVE 201 TO WS-Y
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE PS-ALIVE TO PL-STATE(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     MOVE WS-X TO PL-X(WS-PLAYER)
     MOVE WS-Y TO PL-Y(WS-PLAYER)
     MOVE WS-Z TO PL-Z(WS-PLAYER)
     CALL "MOB-SPAWN" USING WS-DIM WS-WTYPE WS-X0 WS-Y WS-Z WS-YAW WS-WARDEN
     CALL "WD-FIND" USING EN-ID(WS-WARDEN) WS-ONE WS-W
     MOVE 0 TO EN-WAKE(WS-WARDEN) EN-TARGET(WS-WARDEN)
     CALL "MOB-SPAWN" USING WS-DIM WS-ZTYPE WS-X WS-Y WS-Z WS-YAW WS-ZOMBIE
     COMPUTE WS-ZCODE = CORE-MAX-PLAYERS + WS-ZOMBIE
     MOVE 1 TO WS-AMOUNT
     MOVE CAUSE-MOB TO WS-CAUSE
     .

 END-SCENE.
     IF EN-USED(WS-WARDEN) = 1
         CALL "ENTITY-REMOVE" USING WS-WARDEN
     END-IF
     IF EN-USED(WS-ZOMBIE) = 1
         CALL "ENTITY-REMOVE" USING WS-ZOMBIE
     END-IF
     .
 END PROGRAM ACC-US15-WARDEN-EVENTS.
 COPY CORETEST.
 COPY MOBSPTEST.

*> WEV-OPEN USING skip out: 1 and nothing opened when the generated packs are missing; else a standard world (view distance 2, hostile mobs on: a warden is a hostile mob and is removed when they are off).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. WEV-OPEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 LINKAGE SECTION.
 01 L-SKIP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SKIP.
     MOVE 0 TO L-SKIP
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE 1 TO L-SKIP
         GOBACK
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 1 TO CS-HOSTILE-MOBS
     MOVE 0 TO CS-WEATHER-CHANGES
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     GOBACK.
 END PROGRAM WEV-OPEN.
