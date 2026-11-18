*> Acceptance test (US15, FR-036, SC-008; docs/protocol/21 section 4.8 with doc 44 part 7 section 5): the guardian and the elder guardian. Rows (health, attack damage, experience 10, the monster
*> category, removed on Peaceful), the beam duration (80 / 60) and damage (1, +2 on Hard, +2 elder), the attack goal in a tank (target acquired, no damage before the beam is done, entity
*> event 21 at attackTime 0, the beam's damage and the melee hit once the duration has passed, the target dropped), the 3-block rule, squids as targets, thorns while not moving, the
*> elder's Mining Fatigue III every 1200 ticks to the players within 50 blocks (survival only) with Game Event 10, the hop out of water, the stroll, and the spawn predicate (21 section 3.2).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-4-8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY STDMOBS.
 COPY BRWORLD.
 COPY XORO.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-GUARDIAN            BINARY-LONG.
 01 WS-ELDER               BINARY-LONG.
 01 WS-SQUID               BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-ME                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-EROW                BINARY-LONG.
 01 WS-SQ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-HEALTH              FLOAT-SHORT.
 01 WS-LOSS                BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-CAT                 BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-LEVEL               BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-FATIGUE             BINARY-LONG VALUE 3.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-REASON              BINARY-LONG VALUE 0.
 01 WS-OK                  BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG VALUE 3.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-MINX                FLOAT-LONG.
 01 WS-MAXX                FLOAT-LONG.
 01 WS-MINZ                FLOAT-LONG.
 01 WS-MAXZ                FLOAT-LONG.
 01 WS-MAXVY               FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     CALL "AQ-TEST-TANK" USING WS-PLAYER WS-DIM WS-X0 WS-Y0 WS-Z0
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:guardian" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-GUARDIAN WS-ENTITY-ROW WS-STATUS
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:elder_guardian" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ELDER WS-ENTITY-ROW WS-STATUS
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:squid" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-SQUID WS-ENTITY-ROW WS-STATUS
     CALL "STDMOB-INDEX" USING WS-GUARDIAN WS-M
     CALL "STDMOB-INDEX" USING WS-ELDER WS-ME
*>   Rows.
     MOVE "acceptance US15 21§4.8 guardian: max health 30" TO TL-CASE
     MOVE 30 TO TL-EXPECTED-N
     MOVE SM-HEALTH(WS-M) TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE "acceptance US15 21§4.8 guardian: attack damage 6" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE SM-ATTACK(WS-M) TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE "acceptance US15 21§4.8 guardian: experience 10" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE SM-XP(WS-M) TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE "acceptance US15 21§4.8 elder guardian: max health 80" TO TL-CASE
     MOVE 80 TO TL-EXPECTED-N
     MOVE SM-HEALTH(WS-ME) TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE "acceptance US15 21§4.8 elder guardian: attack damage 8" TO TL-CASE
     MOVE 8 TO TL-EXPECTED-N
     MOVE SM-ATTACK(WS-ME) TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE "acceptance US15 21§4.8 elder guardian: experience 10" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE SM-XP(WS-ME) TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE "acceptance US15 21§4.8 the guardian spawns in the monster category (1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     CALL "MS6-ROW-CAT" USING WS-M TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE "acceptance US15 21§4.8 a guardian is a hostile mob for /summon on Peaceful" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     CALL "STDMOB-HOSTILE" USING WS-GUARDIAN TL-OBSERVED-N
     PERFORM CHECK-N
*>   Beam duration and damage.
     CALL "GUARDIAN-DURATION" USING WS-M WS-TICKS
     MOVE "acceptance US15 21§4.8 beam duration of the guardian 80 ticks" TO TL-CASE
     MOVE 80 TO TL-EXPECTED-N
     MOVE WS-TICKS TO TL-OBSERVED-N
     PERFORM CHECK-N
     CALL "GUARDIAN-DURATION" USING WS-ME WS-TICKS
     MOVE "acceptance US15 21§4.8 beam duration of the elder guardian 60 ticks" TO TL-CASE
     MOVE 60 TO TL-EXPECTED-N
     MOVE WS-TICKS TO TL-OBSERVED-N
     PERFORM CHECK-N
     CALL "BR-WORLD-READY"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         MOVE WS-I TO BW-DIFFICULTY
         CALL "GUARDIAN-DAMAGE" USING WS-M WS-DAMAGE
         MOVE "acceptance US15 21§4.8 beam damage of the guardian: 1, 3 on Hard" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         IF WS-I = 3
             MOVE 3 TO TL-EXPECTED-N
         END-IF
         MOVE WS-DAMAGE TO TL-OBSERVED-N
         PERFORM CHECK-N
         CALL "GUARDIAN-DAMAGE" USING WS-ME WS-DAMAGE
         MOVE "acceptance US15 21§4.8 beam damage of the elder: 3, 5 on Hard" TO TL-CASE
         MOVE 3 TO TL-EXPECTED-N
         IF WS-I = 3
             MOVE 5 TO TL-EXPECTED-N
         END-IF
         MOVE WS-DAMAGE TO TL-OBSERVED-N
         PERFORM CHECK-N
     END-PERFORM
     MOVE 2 TO BW-DIFFICULTY
*>   The attack goal: the guardian at the tank's centre, the player (survival) 5 blocks away in the water.
     COMPUTE WS-X = WS-X0 + 2.5
     COMPUTE WS-Y = WS-Y0 + 3.5
     COMPUTE WS-Z = WS-Z0 + 4.5
     CALL "MOB-SPAWN" USING WS-DIM WS-GUARDIAN WS-X WS-Y WS-Z WS-YAW WS-ROW
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 7.5
     COMPUTE PL-Y(WS-PLAYER) = WS-Y0 + 3.5
     COMPUTE PL-Z(WS-PLAYER) = WS-Z0 + 4.5
     MOVE PL-X(WS-PLAYER) TO EN-X(PL-ENTITY-ROW(WS-PLAYER))
     MOVE PL-Y(WS-PLAYER) TO EN-Y(PL-ENTITY-ROW(WS-PLAYER))
     MOVE PL-Z(WS-PLAYER) TO EN-Z(PL-ENTITY-ROW(WS-PLAYER))
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     CALL "TEST-DRAIN-IDS" USING PL-CONN(WS-PLAYER) WS-TEXT
     MOVE 20 TO WS-HEALTH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-ROW
         MOVE WS-X TO EN-X(WS-ROW)
         MOVE WS-Y TO EN-Y(WS-ROW)
         MOVE WS-Z TO EN-Z(WS-ROW)
         MOVE 0 TO EN-VX(WS-ROW) EN-VY(WS-ROW) EN-VZ(WS-ROW)
     END-PERFORM
     MOVE "acceptance US15 21§4.8 the guardian has the player as its target within 30 ticks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-FOE(WS-ROW) = PL-ENTITY-ROW(WS-PLAYER)
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 21§4.8 and no damage yet: the beam takes 80 ticks after attackTime -10 (health 20)" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE PL-HEALTH(WS-PLAYER) TO TL-OBSERVED-N
     PERFORM CHECK-N
     CALL "TEST-DRAIN-IDS" USING PL-CONN(WS-PLAYER) WS-TEXT
     MOVE FUNCTION CONCATENATE(" ", FUNCTION TRIM(WS-TEXT), " ") TO WS-TEXT
     MOVE "acceptance US15 21§4.8 entity event 21 (packet 34) went to the viewers at attackTime 0" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     MOVE 0 TO WS-J
     INSPECT WS-TEXT TALLYING WS-J FOR ALL " 34 " ALL " 34x"
     IF WS-J > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 100 OR PL-HEALTH(WS-PLAYER) < 20
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-ROW
         MOVE WS-X TO EN-X(WS-ROW)
         MOVE WS-Y TO EN-Y(WS-ROW)
         MOVE WS-Z TO EN-Z(WS-ROW)
         MOVE 0 TO EN-VX(WS-ROW) EN-VY(WS-ROW) EN-VZ(WS-ROW)
     END-PERFORM
     MOVE "acceptance US15 21§4.8 the beam lands 90 ticks after the target was taken (attackTime -10 to 80)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-I >= 60 AND WS-I <= 75
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     COMPUTE WS-LOSS = 20 - PL-HEALTH(WS-PLAYER)
     MOVE "acceptance US15 21§4.8 the beam's magic damage 1 and the melee hit 6 share the hurt window: 6 lost" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE WS-LOSS TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE "acceptance US15 21§4.8 the target is dropped after the beam" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-FOE(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK-N
*>   Thorns: not moving, a player's hit costs the attacker 2; moving, nothing.
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     MOVE 0 TO EN-HURT(WS-ROW)
     MOVE 0 TO EN-STRAFE-CW(WS-ROW)
     MOVE 1 TO WS-DAMAGE
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-DAMAGE WS-CAUSE WS-PLAYER
     MOVE "acceptance US15 21§4.8 thorns: a guardian that is not moving hurts the attacker by 2" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = 20 - PL-HEALTH(WS-PLAYER)
     PERFORM CHECK-N
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     MOVE 0 TO EN-HURT(WS-ROW)
     MOVE 1 TO EN-STRAFE-CW(WS-ROW)
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-DAMAGE WS-CAUSE WS-PLAYER
     MOVE "acceptance US15 21§4.8 thorns: not while it is moving" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = 20 - PL-HEALTH(WS-PLAYER)
     PERFORM CHECK-N
*>   A creative player is not a target; a squid is, and a guardian stops when the target comes within 3 blocks.
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE 0 TO EN-FOE(WS-ROW)
     COMPUTE WS-X = WS-X0 + 7.5
     CALL "MOB-SPAWN" USING WS-DIM WS-SQUID WS-X WS-Y WS-Z WS-YAW WS-SQ
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-ROW
         MOVE 0 TO EN-VX(WS-ROW) EN-VY(WS-ROW) EN-VZ(WS-ROW)
         MOVE WS-X TO EN-X(WS-SQ)
     END-PERFORM
     MOVE "acceptance US15 21§4.8 a creative player is no target, a squid within 16 blocks is" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-FOE(WS-ROW) = WS-SQ
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     COMPUTE EN-X(WS-SQ) = EN-X(WS-ROW) + 2
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance US15 21§4.8 a guardian drops a target that is within 3 blocks" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-FOE(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-SQ
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   The stroll: it swims across the tank.
     COMPUTE WS-X = WS-X0 + 4.5
     COMPUTE WS-Y = WS-Y0 + 3.5
     COMPUTE WS-Z = WS-Z0 + 4.5
     CALL "MOB-SPAWN" USING WS-DIM WS-GUARDIAN WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE WS-X TO WS-MINX WS-MAXX
     MOVE WS-Z TO WS-MINZ WS-MAXZ
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1500
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-ROW
         COMPUTE WS-MINX = FUNCTION MIN(WS-MINX, EN-X(WS-ROW))
         COMPUTE WS-MAXX = FUNCTION MAX(WS-MAXX, EN-X(WS-ROW))
         COMPUTE WS-MINZ = FUNCTION MIN(WS-MINZ, EN-Z(WS-ROW))
         COMPUTE WS-MAXZ = FUNCTION MAX(WS-MAXZ, EN-Z(WS-ROW))
     END-PERFORM
     MOVE "acceptance US15 21§4.8 a guardian with no target strolls across its water" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF (WS-MAXX - WS-MINX) + (WS-MAXZ - WS-MINZ) >= 2
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   Out of water on the ground it hops.
     COMPUTE WS-X = WS-X0 + 12.5
     COMPUTE WS-Y = WS-Y0 + 1
     COMPUTE WS-Z = WS-Z0 + 2.5
     CALL "MOB-SPAWN" USING WS-DIM WS-GUARDIAN WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 0 TO WS-MAXVY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-ROW
         COMPUTE WS-MAXVY = FUNCTION MAX(WS-MAXVY, EN-VY(WS-ROW))
     END-PERFORM
     MOVE "acceptance US15 21§4.8 out of water a guardian hops (velocity + 0.5 up) and takes no air damage" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-MAXVY > 0.3 AND EN-HEALTH(WS-ROW) = 30
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   Peaceful removes it.
     CALL "MOB-SPAWN" USING WS-DIM WS-GUARDIAN WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 0 TO BW-DIFFICULTY
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance US15 21§4.8 a guardian is removed on Peaceful" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE 2 TO BW-DIFFICULTY
*>   The elder guardian: at (time + id) mod 1200 = 0 the players within 50 blocks get Mining Fatigue III for 6000 ticks and Game Event 10.
     COMPUTE WS-X = WS-X0 + 2.5
     COMPUTE WS-Y = WS-Y0 + 3.5
     COMPUTE WS-Z = WS-Z0 + 4.5
     CALL "MOB-SPAWN" USING WS-DIM WS-ELDER WS-X WS-Y WS-Z WS-YAW WS-EROW
     MOVE 0 TO PL-MODE(WS-PLAYER)
     CALL "TEST-DRAIN-IDS" USING PL-CONN(WS-PLAYER) WS-TEXT
     COMPUTE CW-TIME = (FUNCTION INTEGER((CW-TIME + EN-ID(WS-EROW)) / 1200) + 1) * 1200 - EN-ID(WS-EROW) - 1
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-EROW
     CALL "EFFECT-LEVEL" USING WS-PLAYER WS-FATIGUE WS-LEVEL WS-LEFT
     MOVE "acceptance US15 21§4.8 the elder guardian gives a survival player within 50 blocks Mining Fatigue III" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-LEVEL TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE "acceptance US15 21§4.8 for 6000 ticks" TO TL-CASE
     MOVE 6000 TO TL-EXPECTED-N
     MOVE WS-LEFT TO TL-OBSERVED-N
     PERFORM CHECK-N
     CALL "TEST-DRAIN-IDS" USING PL-CONN(WS-PLAYER) WS-TEXT
     MOVE FUNCTION CONCATENATE(" ", FUNCTION TRIM(WS-TEXT), " ") TO WS-TEXT
     MOVE "acceptance US15 21§4.8 and Game Event 10 (packet 39) is sent to it" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     MOVE 0 TO WS-J
     INSPECT WS-TEXT TALLYING WS-J FOR ALL " 39 " ALL " 39x"
     IF WS-J > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
*>   Not on other ticks, not for a creative player, not beyond 50 blocks.
     CALL "EFFECT-REMOVE" USING WS-PLAYER WS-FATIGUE
     COMPUTE CW-TIME = CW-TIME + 1
     CALL "MOB-STEP" USING WS-EROW
     CALL "EFFECT-LEVEL" USING WS-PLAYER WS-FATIGUE WS-LEVEL WS-LEFT
     MOVE "acceptance US15 21§4.8 off the 1200-tick beat it gives nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LEVEL TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE 1 TO PL-MODE(WS-PLAYER)
     COMPUTE CW-TIME = (FUNCTION INTEGER((CW-TIME + EN-ID(WS-EROW)) / 1200) + 1) * 1200 - EN-ID(WS-EROW)
     CALL "MOB-STEP" USING WS-EROW
     CALL "EFFECT-LEVEL" USING WS-PLAYER WS-FATIGUE WS-LEVEL WS-LEFT
     MOVE "acceptance US15 44-7§5 a creative player is excluded" TO TL-CASE
     MOVE WS-LEVEL TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE 0 TO PL-MODE(WS-PLAYER)
     COMPUTE PL-X(WS-PLAYER) = EN-X(WS-EROW) + 51
     COMPUTE CW-TIME = (FUNCTION INTEGER((CW-TIME + EN-ID(WS-EROW)) / 1200) + 1) * 1200 - EN-ID(WS-EROW)
     CALL "MOB-STEP" USING WS-EROW
     CALL "EFFECT-LEVEL" USING WS-PLAYER WS-FATIGUE WS-LEVEL WS-LEFT
     MOVE "acceptance US15 44-7§5 a player 51 blocks away is excluded" TO TL-CASE
     MOVE WS-LEVEL TO TL-OBSERVED-N
     PERFORM CHECK-N
     COMPUTE PL-X(WS-PLAYER) = EN-X(WS-EROW) + 49
     MOVE 600 TO WS-TICKS
     MOVE 0 TO WS-FLAG
     CALL "EFFECT-ADD" USING WS-PLAYER WS-FATIGUE WS-ONE WS-TICKS WS-FLAG
     COMPUTE CW-TIME = (FUNCTION INTEGER((CW-TIME + EN-ID(WS-EROW)) / 1200) + 1) * 1200 - EN-ID(WS-EROW)
     CALL "MOB-STEP" USING WS-EROW
     CALL "EFFECT-LEVEL" USING WS-PLAYER WS-FATIGUE WS-LEVEL WS-LEFT
     MOVE "acceptance US15 44-7§5 a lower level (II) is replaced by III" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-LEVEL TO TL-OBSERVED-N
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-EROW
*>   The spawn predicate (21 section 3.2): a water column under a stone roof passes without the draw, an open one only on a draw of 0 of 20; never on Peaceful; a spawner needs no water at the position.
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     COMPUTE WS-BX = WS-X0 + 4
     COMPUTE WS-BY = WS-Y0 + 3
     COMPUTE WS-BZ = WS-Z0 + 4
     MOVE 0 TO WS-PASS
     COMPUTE WS-BY = WS-Y0 + 7
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     COMPUTE WS-BY = WS-Y0 + 3
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-BY WS-BZ WS-REASON WS-OK
         ADD WS-OK TO WS-PASS
     END-PERFORM
     MOVE "acceptance US15 21§3.2 an open water column: the guardian rule passes on about 1 draw in 20 (200 seeds: 3 to 25)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-PASS >= 3 AND WS-PASS <= 25
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     MOVE 0 TO WS-PASS
     COMPUTE WS-BY = WS-Y0 + 7
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE
     COMPUTE WS-BY = WS-Y0 + 3
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-BY WS-BZ WS-REASON WS-OK
         ADD WS-OK TO WS-PASS
     END-PERFORM
     MOVE "acceptance US15 21§3.2 with a solid block above the water the sky is not visible: it passes on every draw" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE WS-PASS TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE 0 TO BW-DIFFICULTY
     CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-BY WS-BZ WS-REASON WS-OK
     MOVE "acceptance US15 21§3.2 on Peaceful it never passes" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE 2 TO BW-DIFFICULTY
     COMPUTE WS-BY = WS-Y0 + 3
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE
     CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-BY WS-BZ WS-REASON WS-OK
     MOVE "acceptance US15 21§3.2 a natural spawn with stone (no water) at the position fails" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE 2 TO WS-REASON
     CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-BY WS-BZ WS-REASON WS-OK
     MOVE "acceptance US15 21§3.2 the same spot for a spawner (water below it, none needed at the position)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM CHECK-N
     STOP RUN.
 CHECK-N.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-21-4-8.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY AQUATEST.
