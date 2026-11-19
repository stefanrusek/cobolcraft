*> Acceptance test (lane p49w; docs/protocol/20 section 15, 15.1, 15.4 and 44-5 section 3.5 and 3.6): the warden's non-player targets, in a standard world of the generated vanilla data pack (CC_GENERATED_DIR, skipped as a pass without it). A zombie stands
*> where the player stands, the warden 10 blocks west:
*> - a living mob that is hurt posts entity_damage with itself as the source: the warden hears it (due after 10 ticks), takes +35 anger on it and a disturbance location at its block; a dead mob, a mob of another dimension and a warden
*>   cannot be targeted (canTargetEntity), so their events are not heard;
*> - the entity sensor picks the first player that can be targeted, else the first non-player, nearest first;
*> - the anger ranking (44-5 3.6): an ANGRY suspect first, then a player before a non-player, then the higher value;
*> - an ANGRY anger on the mob sets the roar target, the roar adds 20 and lasts 84 ticks, then the mob is the attack target (sonic boom cooldown 200); in FIGHT the sonic boom of 10 reaches the mob on the 34th tick of the behaviour
*>   and the melee of 30 kills it; the target is then dropped.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-WARDEN-NONPLAYER.
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
 01 WS-EVENT               PIC X(32).
 01 WS-SKIP                BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-OK                  BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-HEALTH              BINARY-LONG.
 01 WS-ZID                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "WNP-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance US15 20§15 warden non-player: no generated packs here, skipped" TO TL-CASE
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

*>   1. Hearing a mob. The zombie at the player's place is hurt; the event is posted at its feet with itself as the source.
     PERFORM NEW-SCENE
     MOVE "entity_damage" TO WS-EVENT
     CALL "GAME-EVENT-AT" USING WS-EVENT WS-ZOMBIE
     MOVE "a hurt mob's entity_damage is heard: due after floor(10.3) = 10 ticks" TO TL-CASE
     COMPUTE TL-EXPECTED-N = CW-TICKS + 10
     MOVE WD-V-DUE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "and its source is the mob (code 64 + its row)" TO TL-CASE
     MOVE WS-ZCODE TO TL-EXPECTED-N
     MOVE WD-V-SRC(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM 10 TIMES
         ADD 1 TO CW-TICKS
         CALL "MOB-STEP" USING WS-WARDEN
     END-PERFORM
     MOVE "after arrival the mob has 35 anger" TO TL-CASE
     MOVE 35 TO TL-EXPECTED-N
     MOVE WD-ANGER(WS-W, WS-ZCODE) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "the player has none" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-ANGER(WS-W, WS-PLAYER) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "a disturbance location is set at the mob's block" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WD-DISTURB(WS-W) > 0 AND WD-DX(WS-W) = WS-BX AND WD-DZ(WS-W) = WS-BZ
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CASE-LINE
     PERFORM END-SCENE

*>   2. Who can be targeted.
     PERFORM NEW-SCENE
     CALL "WARDEN-CAN-TARGET" USING WS-WARDEN WS-ZCODE WS-OK
     MOVE "a living mob in the warden's dimension can be targeted" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 0 TO EN-HEALTH(WS-ZOMBIE)
     CALL "GAME-EVENT-AT" USING WS-EVENT WS-ZOMBIE
     CALL "WARDEN-CAN-TARGET" USING WS-WARDEN WS-ZCODE WS-OK
     MOVE "a dead mob cannot be targeted" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "and its event is not heard" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-V-DUE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 20 TO EN-HEALTH(WS-ZOMBIE)
     MOVE EN-DIM(WS-ZOMBIE) TO WS-K
     MOVE 77 TO EN-DIM(WS-ZOMBIE)
     CALL "WARDEN-CAN-TARGET" USING WS-WARDEN WS-ZCODE WS-OK
     MOVE "a mob of another dimension cannot be targeted" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE WS-K TO EN-DIM(WS-ZOMBIE)
     COMPUTE WS-I = CORE-MAX-PLAYERS + WS-WARDEN
     CALL "WARDEN-CAN-TARGET" USING WS-WARDEN WS-I WS-OK
     MOVE "a warden cannot be targeted (not even itself)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 0 TO EN-USED(WS-ZOMBIE)
     CALL "WARDEN-CAN-TARGET" USING WS-WARDEN WS-ZCODE WS-OK
     MOVE "a free tracker row cannot be targeted" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 1 TO EN-USED(WS-ZOMBIE)
     PERFORM END-SCENE

*>   3. The entity sensor: the first player that can be targeted (nearest first), else the first non-player. The zombie stands 4 blocks from the warden, the player 10 away.
     PERFORM NEW-SCENE
     COMPUTE EN-X(WS-ZOMBIE) = EN-X(WS-WARDEN) + 4
     MOVE 1 TO WD-SENSOR(WS-W)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "with a player in range the sensor picks the player although the mob is nearer" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE WD-NEAR(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE 1 TO WD-SENSOR(WS-W)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "a creative player cannot be targeted: the sensor picks the mob" TO TL-CASE
     MOVE WS-ZCODE TO TL-EXPECTED-N
     MOVE WD-NEAR(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 0 TO PL-MODE(WS-PLAYER)
     COMPUTE EN-X(WS-ZOMBIE) = EN-X(WS-WARDEN) + 30
     MOVE 1 TO WD-SENSOR(WS-W)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "a mob beyond the follow range of 24 is not picked" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE WD-NEAR(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE 1 TO WD-SENSOR(WS-W)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "nothing to pick: the memory is erased" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-NEAR(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 0 TO PL-MODE(WS-PLAYER)
     PERFORM END-SCENE

*>   4. The anger ranking.
     PERFORM NEW-SCENE
     MOVE 100 TO WD-ANGER(WS-W, WS-ZCODE)
     MOVE 50 TO WD-ANGER(WS-W, WS-PLAYER)
     CALL "WARDEN-ACTIVE" USING WS-WARDEN WS-LEVEL WS-TOP
     MOVE "an ANGRY mob ranks before an AGITATED player: the mob is the top suspect" TO TL-CASE
     MOVE WS-ZCODE TO TL-EXPECTED-N
     MOVE WS-TOP TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "the level is ANGRY (2)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-LEVEL TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 90 TO WD-ANGER(WS-W, WS-PLAYER)
     CALL "WARDEN-ACTIVE" USING WS-WARDEN WS-LEVEL WS-TOP
     MOVE "two ANGRY suspects: the player ranks before the mob" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE WS-TOP TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 30 TO WD-ANGER(WS-W, WS-ZCODE)
     MOVE 20 TO WD-ANGER(WS-W, WS-PLAYER)
     CALL "WARDEN-ACTIVE" USING WS-WARDEN WS-LEVEL WS-TOP
     MOVE "two calm suspects: the player ranks before the mob although its value is lower" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE WS-TOP TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 0 TO WD-ANGER(WS-W, WS-PLAYER)
     CALL "WARDEN-ACTIVE" USING WS-WARDEN WS-LEVEL WS-TOP
     MOVE "a mob alone is the top suspect" TO TL-CASE
     MOVE WS-ZCODE TO TL-EXPECTED-N
     MOVE WS-TOP TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 0 TO WD-ANGER(WS-W, WS-ZCODE)
     PERFORM END-SCENE

*>   5. Roar and fight against a mob. Anger 100 on the zombie, which stands 10 blocks from the warden; no other suspect.
     PERFORM NEW-SCENE
     MOVE 100 TO WD-ANGER(WS-W, WS-ZCODE)
     MOVE 1 TO PL-MODE(WS-PLAYER)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "an ANGRY warden sets the roar target to the mob on its first tick" TO TL-CASE
     MOVE WS-ZCODE TO TL-EXPECTED-N
     MOVE WD-ROAR-TARGET(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "the roar adds 20 anger to the mob" TO TL-CASE
     MOVE 120 TO TL-EXPECTED-N
     MOVE WD-ANGER(WS-W, WS-ZCODE) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 2 TO WS-K
     PERFORM UNTIL EN-FOE(WS-WARDEN) > 0 OR WS-K >= 120
         CALL "MOB-STEP" USING WS-WARDEN
         ADD 1 TO WS-K
     END-PERFORM
     MOVE "the roar ends 84 ticks after it started: the attack target is set on the 86th tick" TO TL-CASE
     MOVE 86 TO TL-EXPECTED-N
     MOVE WS-K TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "the attack target is the mob (its row and entity id)" TO TL-CASE
     MOVE WS-ZOMBIE TO TL-EXPECTED-N
     MOVE EN-FOE(WS-WARDEN) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "its entity id is kept" TO TL-CASE
     MOVE WS-ZID TO TL-EXPECTED-N
     MOVE EN-FOE-ID(WS-WARDEN) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "no player is the target and the roar target memory is erased" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-TARGET(WS-WARDEN) + WD-ROAR-TARGET(WS-W)
     PERFORM CASE-LINE
     MOVE "the sonic boom cooldown is 200" TO TL-CASE
     MOVE 200 TO TL-EXPECTED-N
     MOVE WD-SONIC-CD(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "FIGHT is the activity after the roar" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WD-ACT(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
*>   The boom: with the cooldown gone the behaviour starts, and on its 34th tick the mob takes 10.
     MOVE 0 TO WD-SONIC-CD(WS-W)
     MOVE 0 TO WS-K
     PERFORM UNTIL WD-BOOM(WS-W) >= 34 OR WS-K >= 40
         CALL "MOB-STEP" USING WS-WARDEN
         ADD 1 TO WS-K
     END-PERFORM
     MOVE "the sonic boom is on its 34th tick" TO TL-CASE
     MOVE 34 TO TL-EXPECTED-N
     MOVE WD-BOOM(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "the mob took the boom of 10 (20 health)" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-ZOMBIE) TO TL-OBSERVED-N
     PERFORM CASE-LINE
*>   The warden walks up and kills it with the melee of 30.
     MOVE 0 TO WS-K
     PERFORM UNTIL EN-HEALTH(WS-ZOMBIE) = 0 OR WS-K >= 400
         ADD 1 TO CW-TICKS
         CALL "MOB-STEP" USING WS-WARDEN
         ADD 1 TO WS-K
     END-PERFORM
     MOVE "the warden's melee kills the mob (health 0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-ZOMBIE) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "the dead target is dropped" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-FOE(WS-WARDEN) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 0 TO PL-MODE(WS-PLAYER)
     PERFORM END-SCENE

*>   6. A foe whose tracker row now holds another entity (its entity id differs) is no target: the stop check of the FIGHT activity drops it and its anger.
     PERFORM NEW-SCENE
     MOVE 100 TO WD-ANGER(WS-W, WS-ZCODE)
     MOVE WS-ZOMBIE TO EN-FOE(WS-WARDEN)
     COMPUTE EN-FOE-ID(WS-WARDEN) = WS-ZID + 1000
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE 4 TO WD-ACT(WS-W)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "a foe whose row was taken by another entity is dropped" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-FOE(WS-WARDEN) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "and its anger is cleared" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-ANGER(WS-W, WS-ZCODE) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 0 TO PL-MODE(WS-PLAYER)
     PERFORM END-SCENE
     STOP RUN.

 CASE-LINE.
     MOVE SPACES TO WS-ENTITY-ROW
     STRING "acceptance US15 20§15 warden non-player: " DELIMITED BY SIZE FUNCTION TRIM(TL-CASE) DELIMITED BY SIZE INTO WS-ENTITY-ROW
     MOVE WS-ENTITY-ROW TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .

*> A warden 10 blocks west of the player and a zombie where the player stands (same height): survival player, no cooldowns.
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
     CALL "MOB-SPAWN" USING WS-DIM WS-ZTYPE WS-X WS-Y WS-Z WS-YAW WS-ZOMBIE
     MOVE EN-ID(WS-ZOMBIE) TO WS-ZID
     COMPUTE WS-ZCODE = CORE-MAX-PLAYERS + WS-ZOMBIE
     MOVE "entity_damage" TO WS-EVENT
     .

 END-SCENE.
     CALL "ENTITY-REMOVE" USING WS-WARDEN
     IF EN-USED(WS-ZOMBIE) = 1
         CALL "ENTITY-REMOVE" USING WS-ZOMBIE
     END-IF
     .
 END PROGRAM ACC-US15-WARDEN-NONPLAYER.
 COPY CORETEST.
 COPY MOBSPTEST.

*> WNP-OPEN USING skip out: 1 and nothing opened when the generated packs are missing; else a standard world (view distance 2, hostile mobs on: a warden is a hostile mob and is removed when they are off).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. WNP-OPEN.
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
 END PROGRAM WNP-OPEN.
