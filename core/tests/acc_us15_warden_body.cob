*> Acceptance test (lane p49w; docs/protocol/20 section 15 (Anger: touching; Brain constants), 15.4, 44-5 section 3.2 to 3.4, 53 section 1): the warden's body, in a standard world of the generated vanilla data pack (CC_GENERATED_DIR,
*> skipped as a pass without it).
*> - touching (LivingEntity.pushEntities -> Warden.doPush): a living entity whose box overlaps the warden's (0.9 x 2.9; a player 0.6 x 1.8) adds 35 anger (increaseAngerAt) and starts the 20-tick touch cooldown; a player
*>   that cannot be targeted still starts the cooldown; a spectator is not pushed; a digging or emerging warden ignores pushes;
*> - poses (Set Entity Data index 6 to the players who see the warden, and to a viewer who starts seeing it later): EMERGING while is_emerging, ROARING during the Roar behaviour, SNIFFING from TryToSniff to the end of
*>   Sniffing, DIGGING during Digging, else STANDING (Pose ids 13, 11, 12, 14, 0 of 53 section 1);
*> - Digging in a liquid: off the ground in a liquid the behaviour stops at once and the warden is removed; in the air it does not start.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-WARDEN-BODY.
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
 01 WS-K                   BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 40.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-SKIP                BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-IDS                 PIC X(1024).
 01 WS-WATER               BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "WBD-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance US15 20§15 warden body: no generated packs here, skipped" TO TL-CASE
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
     MOVE "minecraft:water" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-WATER
     MOVE "minecraft:lava" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-LAVA
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

*>   1. Touching. The warden stands at the player's place (dx 0): the first tick adds 35 and starts the cooldown of 20.
     PERFORM NEW-SCENE
     COMPUTE EN-X(WS-WARDEN) = WS-BX + 0.5
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "an overlapping player is touched: anger 35" TO TL-CASE
     MOVE 35 TO TL-EXPECTED-N
     MOVE WD-ANGER(WS-W, WS-PLAYER) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "the touch cooldown is 20" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE WD-TOUCH-CD(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM 19 TIMES
         CALL "MOB-STEP" USING WS-WARDEN
     END-PERFORM
     MOVE "no second touch inside the cooldown (35, less the manager's decay of the 20th tick)" TO TL-CASE
     MOVE 34 TO TL-EXPECTED-N
     MOVE WD-ANGER(WS-W, WS-PLAYER) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "on the 21st tick the cooldown is over: a second touch" TO TL-CASE
     MOVE 69 TO TL-EXPECTED-N
     MOVE WD-ANGER(WS-W, WS-PLAYER) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM END-SCENE

*>   Overlap: 0.75 apart on x touches the boxes only at a face (no overlap), 0.7 overlaps; on y the player's feet 2.8 above the warden's overlap, 2.9 do not.
     PERFORM NEW-SCENE
     COMPUTE EN-X(WS-WARDEN) = WS-BX + 0.5 - 0.75
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "boxes that touch at a face (0.75 apart) do not overlap: no touch" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-TOUCH-CD(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     COMPUTE EN-X(WS-WARDEN) = WS-BX + 0.5 - 0.7
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "0.7 apart overlaps: touched" TO TL-CASE
     MOVE 35 TO TL-EXPECTED-N
     MOVE WD-ANGER(WS-W, WS-PLAYER) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM END-SCENE

     PERFORM NEW-SCENE
     COMPUTE EN-X(WS-WARDEN) = WS-BX + 0.5
     MOVE 203.9 TO PL-Y(WS-PLAYER)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "a player whose feet are at the warden's top (2.9 above its feet): no overlap" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-TOUCH-CD(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 203.8 TO PL-Y(WS-PLAYER)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "feet 2.8 above overlap the top of the warden: touched" TO TL-CASE
     MOVE 35 TO TL-EXPECTED-N
     MOVE WD-ANGER(WS-W, WS-PLAYER) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM END-SCENE

     PERFORM NEW-SCENE
     COMPUTE EN-X(WS-WARDEN) = WS-BX + 0.5
     MOVE 1 TO PL-MODE(WS-PLAYER)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "a creative player: no anger" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-ANGER(WS-W, WS-PLAYER) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "but the push started the cooldown" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE WD-TOUCH-CD(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM END-SCENE

     PERFORM NEW-SCENE
     COMPUTE EN-X(WS-WARDEN) = WS-BX + 0.5
     MOVE 3 TO PL-MODE(WS-PLAYER)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "a spectator is not pushed: no cooldown" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-TOUCH-CD(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM END-SCENE

     PERFORM NEW-SCENE
     COMPUTE EN-X(WS-WARDEN) = WS-BX + 0.5
     MOVE 50 TO WD-EMERGE(WS-W)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "an emerging warden still pushes: only NoAI and the cooldown stop doPush (20 section 15.5)" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE WD-TOUCH-CD(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM END-SCENE

     PERFORM NEW-SCENE
     COMPUTE EN-X(WS-WARDEN) = WS-BX + 0.5 + 8
     COMPUTE EN-X(WS-ZOMBIE) = WS-BX + 0.5 + 8
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "a zombie overlapping the warden is touched: its anger is 35" TO TL-CASE
     MOVE 35 TO TL-EXPECTED-N
     MOVE WD-ANGER(WS-W, WS-ZCODE) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM END-SCENE

*>   2. Poses. A viewer (the player, 10 blocks away) is told every change of pose. Drain what the join sent first.
     PERFORM NEW-SCENE
     MOVE 5 TO WD-SENSOR(WS-W)
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "a new warden stands: pose 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-POSE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "WARDEN-EMERGE" USING WS-WARDEN
     MOVE "WARDEN-EMERGE (a shrieker's warden) sets the pose EMERGING (13)" TO TL-CASE
     MOVE 13 TO TL-EXPECTED-N
     MOVE WD-POSE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "the viewer got one Set Entity Data" TO TL-CASE
     PERFORM CASE-IDS-101
*>   A viewer who starts seeing the warden later is sent the pose after Add Entity.
     MOVE "0" TO VW-SEEN(WS-PLAYER)(WS-WARDEN:1)
     CALL "ENTITY-VIEW-UPDATE" USING WS-PLAYER WS-WARDEN
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "a viewer that starts seeing the warden gets Add Entity and then its pose" TO TL-CASE
     MOVE "1 101" TO TL-EXPECTED
     MOVE WS-IDS(1:5) TO TL-OBSERVED
     MOVE "A" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     PERFORM 133 TIMES
         CALL "MOB-STEP" USING WS-WARDEN
     END-PERFORM
     MOVE "still emerging after 133 ticks" TO TL-CASE
     MOVE 13 TO TL-EXPECTED-N
     MOVE WD-POSE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "the 134th tick ends is_emerging: the pose is STANDING" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-POSE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "and the viewer was told" TO TL-CASE
     PERFORM CASE-IDS-101
     PERFORM END-SCENE

*>   ROARING: the roar target is set on the first tick, Roar starts on the second and lasts 84 ticks.
     PERFORM NEW-SCENE
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE 100 TO WD-ANGER(WS-W, WS-ZCODE)
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     CALL "MOB-STEP" USING WS-WARDEN
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "the Roar behaviour sets the pose ROARING (11)" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     MOVE WD-POSE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 2 TO WS-K
     PERFORM UNTIL EN-FOE(WS-WARDEN) > 0 OR WS-K >= 120
         CALL "MOB-STEP" USING WS-WARDEN
         ADD 1 TO WS-K
     END-PERFORM
     MOVE "the end of the roar returns the pose to STANDING" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-POSE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 0 TO PL-MODE(WS-PLAYER)
     PERFORM END-SCENE

*>   SNIFFING: TryToSniff (nearest_attackable present, no cooldown, no disturbance) sets the pose; Sniffing runs 84 ticks and ends it. Dig cooldown running; the player (survival, 10 blocks away) is nearest_attackable.
     PERFORM NEW-SCENE
     MOVE 1 TO WD-SENSOR(WS-W)
     MOVE 0 TO WS-K
     PERFORM UNTIL WD-SNIFFING(WS-W) = 1 OR WS-K >= 10
         CALL "MOB-STEP" USING WS-WARDEN
         ADD 1 TO WS-K
     END-PERFORM
     MOVE "TryToSniff sets the pose SNIFFING (12)" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE WD-POSE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 0 TO WS-K
     PERFORM UNTIL WD-SNIFFING(WS-W) = 0 OR WS-K >= 100
         CALL "MOB-STEP" USING WS-WARDEN
         ADD 1 TO WS-K
     END-PERFORM
     MOVE "the end of Sniffing returns the pose to STANDING" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-POSE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM END-SCENE

*>   DIGGING on the ground: the dig cooldown is gone, nobody to roar at: Digging starts and the pose is DIGGING (14); after 100 ticks the warden is gone.
     PERFORM NEW-SCENE
     MOVE 0 TO WD-DIG-CD(WS-W)
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE 0 TO WS-K
     PERFORM UNTIL WD-DIGGING(WS-W) > 0 OR WS-K >= 10
         CALL "MOB-STEP" USING WS-WARDEN
         ADD 1 TO WS-K
     END-PERFORM
     MOVE "Digging sets the pose DIGGING (14)" TO TL-CASE
     MOVE 14 TO TL-EXPECTED-N
     MOVE WD-POSE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 0 TO PL-MODE(WS-PLAYER)
     PERFORM END-SCENE

*>   3. Digging in a liquid. A column of water under the warden (no floor there): it floats off the ground in the liquid; Digging stops at once and the warden is removed.
     PERFORM NEW-SCENE
     MOVE 0 TO WD-DIG-CD(WS-W)
     MOVE 1 TO PL-MODE(WS-PLAYER)
     PERFORM VARYING WS-CY FROM 196 BY 1 UNTIL WS-CY > 203
         COMPUTE WS-FX = FUNCTION INTEGER(EN-X(WS-WARDEN))
         COMPUTE WS-FZ = FUNCTION INTEGER(EN-Z(WS-WARDEN))
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-CY WS-FZ WS-WATER
     END-PERFORM
     MOVE 0 TO EN-ON-GROUND(WS-WARDEN)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE 0 TO EN-ON-GROUND(WS-WARDEN)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "in a liquid and off the ground Digging stops at once: the warden is removed" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-WARDEN) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM VARYING WS-CY FROM 196 BY 1 UNTIL WS-CY > 203
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-CY WS-FZ WS-AIR
     END-PERFORM
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-STATE
     MOVE 0 TO PL-MODE(WS-PLAYER)

*>   The same in lava.
     PERFORM NEW-SCENE
     MOVE 0 TO WD-DIG-CD(WS-W)
     MOVE 1 TO PL-MODE(WS-PLAYER)
     PERFORM VARYING WS-CY FROM 196 BY 1 UNTIL WS-CY > 203
         COMPUTE WS-FX = FUNCTION INTEGER(EN-X(WS-WARDEN))
         COMPUTE WS-FZ = FUNCTION INTEGER(EN-Z(WS-WARDEN))
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-CY WS-FZ WS-LAVA
     END-PERFORM
     MOVE 0 TO EN-ON-GROUND(WS-WARDEN)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE 0 TO EN-ON-GROUND(WS-WARDEN)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "in lava and off the ground Digging stops at once too: the warden is removed" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-WARDEN) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM VARYING WS-CY FROM 196 BY 1 UNTIL WS-CY > 203
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-CY WS-FZ WS-AIR
     END-PERFORM
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-STATE
     MOVE 0 TO PL-MODE(WS-PLAYER)

*>   In the air (no ground, no liquid) Digging does not start.
     PERFORM NEW-SCENE
     MOVE 0 TO WD-DIG-CD(WS-W)
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE 215 TO EN-Y(WS-WARDEN)
     MOVE 0 TO EN-ON-GROUND(WS-WARDEN)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE 0 TO EN-ON-GROUND(WS-WARDEN)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "in the air Digging does not start: the warden is still there" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-USED(WS-WARDEN) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "and the pose is STANDING" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-POSE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 0 TO PL-MODE(WS-PLAYER)
     PERFORM END-SCENE
     STOP RUN.

 CASE-LINE.
     MOVE SPACES TO WS-ENTITY-ROW
     STRING "acceptance US15 20§15 warden body: " DELIMITED BY SIZE FUNCTION TRIM(TL-CASE) DELIMITED BY SIZE INTO WS-ENTITY-ROW
     MOVE WS-ENTITY-ROW TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .

*> The ids a viewer received hold exactly one Set Entity Data (101) (the warden may have moved too).
 CASE-IDS-101.
     MOVE 0 TO WS-K
     INSPECT WS-IDS TALLYING WS-K FOR ALL "101"
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-K TO TL-OBSERVED-N
     PERFORM CASE-LINE
     .

*> A warden 10 blocks west of the player (survival, alive) and a zombie at the player's place: no cooldowns, the dig cooldown running, the sensor scan in 5 ticks.
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
     MOVE WS-X TO PL-X(WS-PLAYER)
     MOVE WS-Y TO PL-Y(WS-PLAYER)
     MOVE WS-Z TO PL-Z(WS-PLAYER)
     CALL "MOB-SPAWN" USING WS-DIM WS-WTYPE WS-X0 WS-Y WS-Z WS-YAW WS-WARDEN
     CALL "WD-FIND" USING EN-ID(WS-WARDEN) WS-ONE WS-W
     MOVE 5 TO WD-SENSOR(WS-W)
     MOVE 0 TO EN-WAKE(WS-WARDEN) EN-TARGET(WS-WARDEN)
     CALL "MOB-SPAWN" USING WS-DIM WS-ZTYPE WS-X0 WS-Y WS-Z WS-YAW WS-ZOMBIE
     COMPUTE WS-ZCODE = CORE-MAX-PLAYERS + WS-ZOMBIE
     MOVE EN-X(WS-ZOMBIE) TO WS-X0
     COMPUTE EN-X(WS-ZOMBIE) = WS-BX + 100
     MOVE 0 TO WS-STATE
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     .

 END-SCENE.
     IF EN-USED(WS-WARDEN) = 1
         CALL "ENTITY-REMOVE" USING WS-WARDEN
     END-IF
     IF EN-USED(WS-ZOMBIE) = 1
         CALL "ENTITY-REMOVE" USING WS-ZOMBIE
     END-IF
     .
 END PROGRAM ACC-US15-WARDEN-BODY.
 COPY CORETEST.
 COPY MOBSPTEST.

*> WBD-OPEN USING skip out: 1 and nothing opened when the generated packs are missing; else a standard world (view distance 2, hostile mobs on: a warden is a hostile mob and is removed when they are off).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. WBD-OPEN.
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
 END PROGRAM WBD-OPEN.
