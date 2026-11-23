*> Implementation test (wrap C round 7, T24090; docs/protocol/44-residual-mob-questions-7-aquatic.md sections 9.3 and 10, 21 section 4.10): the nautilus (kind 7) and the zombie nautilus (kind 8) rows
*> (health 15, attack 3, the categories, not removed in Peaceful), the fresh ATTACK_TARGET_COOLDOWN of 2400 to 3600, the target finder (the pufferfish with the 50 percent roll, the cooldown, a tame
*> nautilus), the anger a player's hit causes (400 ticks, not for a creative player), the charge (velocity 0.6 or 0.5 per tick, the hit's damage and knockback 1.2 or 1.1, the cooldown 80, the 12-block
*> and 60-tick limits, no start at 11 blocks), the entity data (tame flags, owner, the variant of a zombie nautilus), the temptation by a fish and the loot tables.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-NAUTILUS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY CITEMS.
 COPY STDMOBS.
 COPY BRWORLD.
 COPY RULES.
 COPY WCSTATE.
 COPY XORO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MQ-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 7.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-NAUTILUS            BINARY-LONG.
 01 WS-ZOMBIE              BINARY-LONG.
 01 WS-PUFFER              BINARY-LONG.
 01 WS-SQUID               BINARY-LONG.
 01 WS-COD                 BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-MZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROW-A               BINARY-LONG.
 01 WS-PR                  BINARY-LONG.
 01 WS-SQ                  BINARY-LONG.
 01 WS-PF                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-SALT                BINARY-LONG VALUE 42.
 01 WS-FOUND               BINARY-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-PADDED              PIC X(1030).
 01 WS-TALLY               BINARY-LONG.
 01 WS-MDI                 BINARY-LONG.
 01 WS-MDV                 BINARY-LONG.
 01 WS-PK                  BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG VALUE 1.
 01 WS-CAUSE               BINARY-LONG VALUE 3.
 01 WS-KILLER              BINARY-LONG VALUE 0.
 01 WS-DX                  FLOAT-LONG.
 01 WS-HEALTH              BINARY-LONG.
 01 WS-PUFFER-ITEM         BINARY-LONG.
 01 WS-SALMON-ITEM         BINARY-LONG.
 01 WS-PBUCKET             BINARY-LONG.
 01 WS-WBUCKET             BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-STICK               BINARY-LONG.
 01 WS-CCOD                BINARY-LONG.
 01 WS-HAND0               BINARY-LONG VALUE 0.
 01 WS-SNEAK0              BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     CALL "AQ-TEST-TANK" USING WS-PLAYER WS-DIM WS-X0 WS-Y0 WS-Z0
     MOVE "N" TO TL-MODE
     MOVE PL-CONN(WS-PLAYER) TO WS-CONN
     CALL "PB-INIT" USING MQ-BUFFER WS-CAPACITY
     MOVE "minecraft:nautilus" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-NAUTILUS WS-ENTITY-ROW WS-STATUS
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:zombie_nautilus" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZOMBIE WS-ENTITY-ROW WS-STATUS
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:pufferfish" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-PUFFER WS-ENTITY-ROW WS-STATUS
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:squid" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-SQUID WS-ENTITY-ROW WS-STATUS
     CALL "STDMOB-INDEX" USING WS-NAUTILUS WS-M
     CALL "STDMOB-INDEX" USING WS-ZOMBIE WS-MZ
*>   Rows.
     MOVE "implementation 21 4.10 nautilus: max health 15, attack damage 3, kind 7" TO TL-CASE
     MOVE 1537 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = SM-HEALTH(WS-M) * 100 + SM-ATTACK(WS-M) * 10 + SM-KIND(WS-M)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "implementation 21 4.10 zombie nautilus: max health 15, attack damage 3, kind 8, walk 1.1" TO TL-CASE
     MOVE 15381100 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = SM-HEALTH(WS-MZ) * 1000000 + SM-ATTACK(WS-MZ) * 100000 + SM-KIND(WS-MZ) * 10000 + SM-WALK-MILLI(WS-MZ)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MS6-ROW-CAT" USING WS-M TL-OBSERVED-N
     MOVE "implementation 21 4.10 the nautilus is a water creature (category 6)" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MS6-ROW-CAT" USING WS-MZ TL-OBSERVED-N
     MOVE "implementation 21 4.10 the zombie nautilus is a monster (category 1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A fresh nautilus gets ATTACK_TARGET_COOLDOWN uniform(2400, 3600) (10.5), counted down once by the tick.
     COMPUTE WS-X = WS-X0 + 2.5
     COMPUTE WS-Y = WS-Y0 + 3.5
     COMPUTE WS-Z = WS-Z0 + 4.5
     CALL "MOB-SPAWN" USING WS-DIM WS-NAUTILUS WS-X WS-Y WS-Z WS-YAW WS-ROW
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "implementation 44-7 10.5 a fresh nautilus has an ATTACK_TARGET_COOLDOWN of 2399 to 3599 after its first tick" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WC-NAU-ATTACK-CD(WS-ROW) >= 2399 AND WC-NAU-ATTACK-CD(WS-ROW) <= 3599
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Target finder: a pufferfish in water, the cooldown absent, the roll below 0.5 gives none and 0.5 or more takes it; the cooldown is renewed in both cases.
     COMPUTE WS-X = WS-X0 + 5.5
     CALL "MOB-SPAWN" USING WS-DIM WS-PUFFER WS-X WS-Y WS-Z WS-YAW WS-PF
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-T FROM 1000 BY 1 UNTIL WS-FOUND = 1
         MOVE WS-T TO CW-TIME
         CALL "AQUA-RAND" USING WS-ROW WS-SALT WS-R
         IF WS-R < 0.5
             MOVE 1 TO WS-FOUND
         END-IF
     END-PERFORM
     MOVE 0 TO WC-NAU-ATTACK-CD(WS-ROW) EN-FOE(WS-ROW) EN-FOE-ID(WS-ROW)
     CALL "NAUTILUS-PICK" USING WS-ROW WS-M
     MOVE "implementation 44-7 10.5 a roll below 0.5 gives no target but renews the cooldown" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-FOE(WS-ROW) = 0
         ADD 10 TO TL-OBSERVED-N
     END-IF
     IF WC-NAU-ATTACK-CD(WS-ROW) < 2400
         ADD 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-T FROM 1000 BY 1 UNTIL WS-FOUND = 1
         MOVE WS-T TO CW-TIME
         CALL "AQUA-RAND" USING WS-ROW WS-SALT WS-R
         IF WS-R >= 0.5
             MOVE 1 TO WS-FOUND
         END-IF
     END-PERFORM
     MOVE 0 TO WC-NAU-ATTACK-CD(WS-ROW) EN-FOE(WS-ROW) EN-FOE-ID(WS-ROW)
     CALL "NAUTILUS-PICK" USING WS-ROW WS-M
     MOVE "implementation 44-7 10.5 a roll of 0.5 or more takes the nearest pufferfish in water and renews the cooldown to 2400 to 3600" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-FOE(WS-ROW) = WS-PF AND EN-FOE-ID(WS-ROW) = EN-ID(WS-PF)
         ADD 10 TO TL-OBSERVED-N
     END-IF
     IF WC-NAU-ATTACK-CD(WS-ROW) >= 2400 AND WC-NAU-ATTACK-CD(WS-ROW) <= 3600
         ADD 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The cooldown present: no target. A tame nautilus: no target.
     MOVE 0 TO EN-FOE(WS-ROW) EN-FOE-ID(WS-ROW)
     MOVE 100 TO WC-NAU-ATTACK-CD(WS-ROW)
     CALL "NAUTILUS-PICK" USING WS-ROW WS-M
     MOVE "implementation 44-7 10.5 with the ATTACK_TARGET_COOLDOWN present there is no target" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-FOE(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WC-NAU-ATTACK-CD(WS-ROW)
     MOVE 1 TO EN-TAMED(WS-ROW)
     CALL "NAUTILUS-PICK" USING WS-ROW WS-M
     MOVE "implementation 44-7 10.5 a tame nautilus never gets a target" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-FOE(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-TAMED(WS-ROW)
     CALL "ENTITY-REMOVE" USING WS-PF

*>   Entity data of a tame nautilus: metadata 18 BYTE 4 (tame), 19 the owner; a warm zombie nautilus sends metadata 21 (serializer 32, the registry id of warm = 1).
     MOVE 0 TO WS-I
     MOVE 1 TO EN-TAMED(WS-ROW)
     MOVE "0123456789abcdef" TO EN-OWNER-UUID(WS-ROW)
     MOVE WS-ROW TO WS-ROW-A
     MOVE 18 TO WS-MDI
     PERFORM FIND-DATA
     MOVE "implementation 44-7 10.2 metadata 18 of a tame nautilus is 4" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-MDV TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 19 TO WS-MDI
     PERFORM FIND-DATA
     MOVE "implementation 44-7 10.2 metadata 19 (the owner) is present for a tame nautilus" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-MDV NOT = -1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-TAMED(WS-ROW)
     MOVE SPACES TO EN-OWNER-UUID(WS-ROW)
     MOVE 18 TO WS-MDI
     PERFORM FIND-DATA
     MOVE "implementation 44-7 10.2 an untamed nautilus sends no metadata 18" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     MOVE WS-MDV TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-Z = WS-Z0 + 6.5
     COMPUTE WS-X = WS-X0 + 2.5
     CALL "MOB-SPAWN" USING WS-DIM WS-ZOMBIE WS-X WS-Y WS-Z WS-YAW WS-ROW-A
     MOVE 21 TO WS-MDI
     PERFORM FIND-DATA
     MOVE "implementation 44-7 10.1 a temperate zombie nautilus sends no metadata 21" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     MOVE WS-MDV TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO EN-VARIANT(WS-ROW-A)
     PERFORM FIND-DATA
     MOVE "implementation 44-7 10.1 a warm zombie nautilus sends metadata 21 = the registry id of warm (1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-MDV TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO EN-VARIANT(WS-ROW-A)
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     CALL "STDMOB-FINALIZE" USING XR-STATE WS-ROW-A
     MOVE "implementation 44-7 10.1 the variant picked at the test position (not a warm ocean) is temperate (0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-VARIANT(WS-ROW-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Peaceful: the zombie nautilus is not on the notInPeaceful list (20 section 19.4).
     MOVE 0 TO BW-DIFFICULTY
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW-A
     MOVE "implementation 20 19.4 a zombie nautilus is not removed in Peaceful" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO BW-DIFFICULTY
     CALL "ENTITY-REMOVE" USING WS-ROW-A

*>   Anger: a survival player's hit makes the nautilus angry for 400 ticks; a creative player's does not.
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 7.5
     COMPUTE PL-Y(WS-PLAYER) = WS-Y0 + 3.5
     COMPUTE PL-Z(WS-PLAYER) = WS-Z0 + 4.5
     MOVE PL-X(WS-PLAYER) TO EN-X(PL-ENTITY-ROW(WS-PLAYER))
     MOVE PL-Y(WS-PLAYER) TO EN-Y(PL-ENTITY-ROW(WS-PLAYER))
     MOVE PL-Z(WS-PLAYER) TO EN-Z(PL-ENTITY-ROW(WS-PLAYER))
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE 0 TO EN-HURT(WS-ROW) EN-ANGER(WS-ROW)
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-DAMAGE WS-CAUSE WS-PLAYER
     MOVE "implementation 44-7 10.5 a creative player's hit does not anger the nautilus" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-ANGER(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 0 TO EN-HURT(WS-ROW)
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-DAMAGE WS-CAUSE WS-PLAYER
     MOVE "implementation 44-7 10.5 a survival player's hit sets ANGRY_AT for 400 ticks to that player" TO TL-CASE
     MOVE 400 TO TL-EXPECTED-N
     MOVE EN-ANGER(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "implementation 44-7 10.5 ANGRY_AT holds the entity id of the player" TO TL-CASE
     MOVE PL-ENTITY-ID(WS-PLAYER) TO TL-EXPECTED-N
     MOVE WC-NAU-ANGRY(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The charge: the angry nautilus targets the player in water, starts at speed 0.6 along the line to it, hits it for 3 (Normal), pushes it and ends with the cooldown 80.
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE 0 TO EN-FLEE(WS-ROW) EN-HURT(WS-ROW)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     ADD 1 TO CW-TIME
     MOVE 1 TO WC-NAU-ATTACK-CD(WS-ROW)
     MOVE 0 TO WC-NAU-CHARGE-CD(WS-ROW)
     CALL "MOB-STEP" USING WS-ROW
     MOVE "implementation 44-7 10.6 the angry nautilus takes the player as its ATTACK_TARGET and starts to charge" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-FOE(WS-ROW) = PL-ENTITY-ROW(WS-PLAYER)
         ADD 10 TO TL-OBSERVED-N
     END-IF
     IF WC-NAU-CHARGING(WS-ROW) > 0
         ADD 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-LEN = FUNCTION SQRT(WC-NAU-VX(WS-ROW) ** 2 + WC-NAU-VY(WS-ROW) ** 2 + WC-NAU-VZ(WS-ROW) ** 2)
     MOVE "implementation 44-7 10.6 the charge velocity is 0.6 blocks per tick (13.10)" TO TL-CASE
     MOVE 600 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-LEN + 0.5
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-I
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30 OR PL-HEALTH(WS-PLAYER) < 20
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-ROW
     END-PERFORM
     MOVE "implementation 44-7 10.6 the dash hits the player on contact: it loses 3 health" TO TL-CASE
     MOVE 17 TO TL-EXPECTED-N
     MOVE PL-HEALTH(WS-PLAYER) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "implementation 44-7 10.6 the hit ends the charge: CHARGE_COOLDOWN_TICKS 80 and the target erased" TO TL-CASE
     MOVE 80 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WC-NAU-CHARGE-CD(WS-ROW) + EN-FOE(WS-ROW) + WC-NAU-CHARGING(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE 0 TO WS-TALLY
     MOVE SPACES TO WS-PADDED
     STRING " " FUNCTION TRIM(WS-IDS) " " DELIMITED BY SIZE INTO WS-PADDED
     INSPECT WS-PADDED TALLYING WS-TALLY FOR ALL " 103 " ALL " 103x"
     MOVE "implementation 44-7 10.6 the player is knocked back (Set Entity Motion 103)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-TALLY > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   Knockback of a mob: the target squid 5 blocks ahead along +x: the force is 1.2 for the nautilus (13.10: clamp(0.6 x 1.0) x 2.0) and 1.1 for the zombie nautilus (0.5 x 1.1 x 2.0).
     MOVE 1 TO PL-MODE(WS-PLAYER)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         COMPUTE WS-X = WS-X0 + 2.5
         COMPUTE WS-Y = WS-Y0 + 3.5
         COMPUTE WS-Z = WS-Z0 + 4.5
         IF WS-I = 1
             CALL "MOB-SPAWN" USING WS-DIM WS-NAUTILUS WS-X WS-Y WS-Z WS-YAW WS-ROW
         ELSE
             CALL "MOB-SPAWN" USING WS-DIM WS-ZOMBIE WS-X WS-Y WS-Z WS-YAW WS-ROW
         END-IF
         COMPUTE WS-X = WS-X0 + 7.5
         CALL "MOB-SPAWN" USING WS-DIM WS-SQUID WS-X WS-Y WS-Z WS-YAW WS-SQ
         CALL "WC-ROW-OPEN" USING WS-ROW
         MOVE 1 TO WC-NAU-INIT(WS-ROW)
         MOVE 5000 TO WC-NAU-ATTACK-CD(WS-ROW)
         MOVE WS-SQ TO EN-FOE(WS-ROW)
         MOVE EN-ID(WS-SQ) TO EN-FOE-ID(WS-ROW)
         MOVE 0 TO EN-VX(WS-SQ) EN-VY(WS-SQ) EN-VZ(WS-SQ)
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-ROW
         COMPUTE WS-LEN = FUNCTION SQRT(WC-NAU-VX(WS-ROW) ** 2 + WC-NAU-VY(WS-ROW) ** 2 + WC-NAU-VZ(WS-ROW) ** 2)
         IF WS-I = 1
             MOVE "implementation 44-7 13.10 the nautilus charge speed is 0.6" TO TL-CASE
             MOVE 600 TO TL-EXPECTED-N
         ELSE
             MOVE "implementation 44-7 10.8 the zombie nautilus charge speed is 0.5" TO TL-CASE
             MOVE 500 TO TL-EXPECTED-N
         END-IF
         COMPUTE TL-OBSERVED-N = WS-LEN + 0.5
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 30 OR EN-HEALTH(WS-SQ) < 10
             ADD 1 TO CW-TIME
             MOVE 0 TO EN-VX(WS-SQ)
             COMPUTE WS-X = WS-X0 + 7.5
             MOVE WS-X TO EN-X(WS-SQ)
             MOVE WS-Y TO EN-Y(WS-SQ)
             MOVE WS-Z TO EN-Z(WS-SQ)
             CALL "MOB-STEP" USING WS-ROW
         END-PERFORM
         MOVE "implementation 44-7 10.6 the charge hits a mob for the attack damage 3 (squid 10 to 7)" TO TL-CASE
         MOVE 7 TO TL-EXPECTED-N
         MOVE EN-HEALTH(WS-SQ) TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         IF WS-I = 1
             MOVE "implementation 44-7 13.10 the knockback of the nautilus is 1.2 (a mob target: velocity x = 1.2)" TO TL-CASE
             MOVE 1200 TO TL-EXPECTED-N
         ELSE
             MOVE "implementation 44-7 13.10 the knockback of the zombie nautilus is 1.1" TO TL-CASE
             MOVE 1100 TO TL-EXPECTED-N
         END-IF
         COMPUTE TL-OBSERVED-N = EN-VX(WS-SQ) * 1000 + 0.5
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         CALL "ENTITY-REMOVE" USING WS-SQ
         CALL "ENTITY-REMOVE" USING WS-ROW
     END-PERFORM

*>   The limits: 12 blocks from the start ends the charge (13.10 b), so does the 60-tick duration; a target 11 blocks or farther stops it at once with the cooldown.
     COMPUTE WS-X = WS-X0 + 2.5
     COMPUTE WS-Y = WS-Y0 + 3.5
     COMPUTE WS-Z = WS-Z0 + 4.5
     CALL "MOB-SPAWN" USING WS-DIM WS-NAUTILUS WS-X WS-Y WS-Z WS-YAW WS-ROW
     COMPUTE WS-X = WS-X0 + 7.5
     CALL "MOB-SPAWN" USING WS-DIM WS-SQUID WS-X WS-Y WS-Z WS-YAW WS-SQ
     CALL "WC-ROW-OPEN" USING WS-ROW
     MOVE 1 TO WC-NAU-INIT(WS-ROW)
     MOVE 5000 TO WC-NAU-ATTACK-CD(WS-ROW)
     MOVE WS-SQ TO EN-FOE(WS-ROW)
     MOVE EN-ID(WS-SQ) TO EN-FOE-ID(WS-ROW)
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     COMPUTE WC-NAU-SX(WS-ROW) = EN-X(WS-ROW) * 1000 - 12000
     MOVE EN-Y(WS-ROW) TO WS-Y
     COMPUTE WC-NAU-SY(WS-ROW) = WS-Y * 1000
     COMPUTE WC-NAU-SZ(WS-ROW) = EN-Z(WS-ROW) * 1000
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "implementation 44-7 13.10b 12 blocks from the start (squared 144 is not below 144) the charge stops: cooldown 80, target erased" TO TL-CASE
     MOVE 80 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WC-NAU-CHARGE-CD(WS-ROW) + EN-FOE(WS-ROW) + WC-NAU-CHARGING(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WC-NAU-CHARGE-CD(WS-ROW)
     MOVE WS-SQ TO EN-FOE(WS-ROW)
     MOVE EN-ID(WS-SQ) TO EN-FOE-ID(WS-ROW)
     MOVE 61 TO WC-NAU-CHARGING(WS-ROW)
     COMPUTE WC-NAU-SX(WS-ROW) = EN-X(WS-ROW) * 1000
     COMPUTE WC-NAU-SY(WS-ROW) = EN-Y(WS-ROW) * 1000
     COMPUTE WC-NAU-SZ(WS-ROW) = EN-Z(WS-ROW) * 1000
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "implementation 44-7 10.6 after the 60-tick duration the charge stops: cooldown 80" TO TL-CASE
     MOVE 80 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WC-NAU-CHARGE-CD(WS-ROW) + EN-FOE(WS-ROW) + WC-NAU-CHARGING(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WC-NAU-CHARGE-CD(WS-ROW)
     MOVE WS-SQ TO EN-FOE(WS-ROW)
     MOVE EN-ID(WS-SQ) TO EN-FOE-ID(WS-ROW)
     COMPUTE WS-X = EN-X(WS-ROW) + 11.5
     MOVE WS-X TO EN-X(WS-SQ)
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "implementation 44-7 10.6 a target 11 blocks or farther: canStillUse fails at once, cooldown 80, no charge" TO TL-CASE
     MOVE 80 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WC-NAU-CHARGE-CD(WS-ROW) + EN-FOE(WS-ROW) + WC-NAU-CHARGING(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-SQ
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   Temptation (10.5): a player holding a cod within 10 blocks draws the nautilus; the swim goes toward the player.
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE "minecraft:cod" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-COD WS-ITEM-ROW WS-STATUS
     MOVE WS-COD TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE 0 TO PL-HELD(WS-PLAYER)
     COMPUTE WS-X = WS-X0 + 2.5
     COMPUTE WS-Y = WS-Y0 + 3.5
     COMPUTE WS-Z = WS-Z0 + 4.5
     CALL "MOB-SPAWN" USING WS-DIM WS-NAUTILUS WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "WC-ROW-OPEN" USING WS-ROW
     MOVE 1 TO WC-NAU-INIT(WS-ROW)
     MOVE 5000 TO WC-NAU-ATTACK-CD(WS-ROW)
     MOVE 0 TO EN-VX(WS-ROW)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-ROW
     END-PERFORM
     MOVE "implementation 44-7 10.5 a nautilus swims toward a player who holds a cod (the x position grows)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-X(WS-ROW) > WS-X0 + 3.0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ROW
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1)

*>   Taming and feeding (10.2): an adult nautilus 2 blocks from the survival player. A cod does nothing to an untamed one; pufferfish are used one by one until nextInt(3) = 0 tames it (the player
*>   becomes the owner, Entity Event 7); a tame one below max health heals 2.0 x nutrition from a cod (2) and a cooked salmon (6) up to 15; a pufferfish bucket leaves a water bucket.
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE "minecraft:pufferfish" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-PUFFER-ITEM WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:cooked_salmon" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-SALMON-ITEM WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:pufferfish_bucket" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-PBUCKET WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:water_bucket" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-WBUCKET WS-ITEM-ROW WS-STATUS
     COMPUTE WS-X = WS-X0 + 5.5
     COMPUTE WS-Y = WS-Y0 + 3.5
     COMPUTE WS-Z = WS-Z0 + 4.5
     CALL "MOB-SPAWN" USING WS-DIM WS-NAUTILUS WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE EN-ID(WS-ROW) TO WS-ID
     MOVE 0 TO PL-HELD(WS-PLAYER)
     MOVE WS-COD TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 5 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "implementation 44-7 10.2 a cod does not tame and is not used on an untamed nautilus" TO TL-CASE
     MOVE 50 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PL-SLOT-COUNT(WS-PLAYER, 1) * 10 + EN-TAMED(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-PUFFER-ITEM TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 60 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE 0 TO WS-I
     PERFORM UNTIL EN-TAMED(WS-ROW) = 1 OR WS-I >= 50
         ADD 1 TO WS-I
         CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     END-PERFORM
     MOVE "implementation 44-7 10.2 pufferfish tame the nautilus (1 in 3 a use) and every try uses one" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-TAMED(WS-ROW) = 1 AND WS-I >= 1 AND PL-SLOT-COUNT(WS-PLAYER, 1) = 60 - WS-I
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "implementation 44-7 10.2 the owner is the player" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-OWNER-UUID(WS-ROW) = PL-UUID(WS-PLAYER)
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE 0 TO WS-TALLY
     MOVE SPACES TO WS-PADDED
     STRING " " FUNCTION TRIM(WS-IDS) " " DELIMITED BY SIZE INTO WS-PADDED
     INSPECT WS-PADDED TALLYING WS-TALLY FOR ALL " 34 " ALL " 34x"
     MOVE "implementation 44-7 10.2 the taming broadcast Entity Event (packet 34) and Set Entity Data (101)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-TALLY > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 10 TO EN-HEALTH(WS-ROW)
     MOVE WS-COD TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 5 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "implementation 44-7 10.2 a cod heals a tame nautilus by 2.0 x 2 = 4 and is used" TO TL-CASE
     MOVE 1404 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-HEALTH(WS-ROW) * 100 + PL-SLOT-COUNT(WS-PLAYER, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-SALMON-ITEM TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 3 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "implementation 44-7 10.2 a cooked salmon heals 2.0 x 6 but never past the max health 15" TO TL-CASE
     MOVE 1502 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-HEALTH(WS-ROW) * 100 + PL-SLOT-COUNT(WS-PLAYER, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "implementation 44-7 10.2 at full health a tame nautilus takes no food" TO TL-CASE
     MOVE 1502 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-HEALTH(WS-ROW) * 100 + PL-SLOT-COUNT(WS-PLAYER, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ROW
     CALL "MOB-SPAWN" USING WS-DIM WS-NAUTILUS WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE EN-ID(WS-ROW) TO WS-ID
     MOVE WS-PBUCKET TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "implementation 44-7 10.2 a pufferfish bucket used on the nautilus becomes a water bucket" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-SLOT-ITEM(WS-PLAYER, 1) = WS-WBUCKET AND PL-SLOT-COUNT(WS-PLAYER, 1) = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ROW
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1)


*>   More rules: entity data of another species and the dash flag; a hit without a player; target finder refusals (love mode, a baby); attackable tests; a target that dies during the charge;
*>   temptation of a zombie nautilus and of a baby; feeding refusals and nutrition; the countdowns; a dry nautilus; the swim at the nautilus modifier 0.011.
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     COMPUTE WS-X = WS-X0 + 2.5
     COMPUTE WS-Y = WS-Y0 + 3.5
     COMPUTE WS-Z = WS-Z0 + 4.5
     CALL "MOB-SPAWN" USING WS-DIM WS-NAUTILUS WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "WC-ROW-OPEN" USING WS-ROW
     MOVE 1 TO WC-NAU-INIT(WS-ROW)
     MOVE 5000 TO WC-NAU-ATTACK-CD(WS-ROW)
     MOVE 0 TO EN-HURT(WS-ROW)
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-DAMAGE WS-CAUSE WS-KILLER
     MOVE "implementation 44-7 10.5 a hit without an attacker player does not anger the nautilus" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-ANGER(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MOB-SPAWN" USING WS-DIM WS-SQUID WS-X WS-Y WS-Z WS-YAW WS-SQ
     MOVE 0 TO EN-HURT(WS-SQ)
     CALL "HEALTH-MOB-DAMAGE" USING WS-SQ WS-DAMAGE WS-CAUSE WS-PLAYER
     MOVE "implementation 44-7 10.5 a player's hit on another species sets no anger" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-ANGER(WS-SQ) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-SQ TO WS-ROW-A
     MOVE 18 TO WS-MDI
     PERFORM FIND-DATA
     MOVE "implementation 44-7 10.2 another species sends no nautilus entity data (metadata 18 absent)" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     MOVE WS-MDV TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WC-NAU-DASH(WS-ROW)
     MOVE WS-ROW TO WS-ROW-A
     MOVE 20 TO WS-MDI
     PERFORM FIND-DATA
     MOVE "implementation 44-7 10.4 the dash flag is metadata 20 BOOLEAN" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-MDV TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WC-NAU-DASH(WS-ROW)
*>   Target finder refusals: love mode and a baby take no target even with a pufferfish near and a roll of 0.5 or more.
     COMPUTE WS-X = WS-X0 + 5.5
     CALL "MOB-SPAWN" USING WS-DIM WS-PUFFER WS-X WS-Y WS-Z WS-YAW WS-PF
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-T FROM 1000 BY 1 UNTIL WS-FOUND = 1
         MOVE WS-T TO CW-TIME
         CALL "AQUA-RAND" USING WS-ROW WS-SALT WS-R
         IF WS-R >= 0.5
             MOVE 1 TO WS-FOUND
         END-IF
     END-PERFORM
     MOVE 0 TO WC-NAU-ATTACK-CD(WS-ROW) EN-FOE(WS-ROW)
     MOVE 100 TO EN-LOVE(WS-ROW)
     CALL "NAUTILUS-PICK" USING WS-ROW WS-M
     MOVE "implementation 44-7 10.5 a nautilus in love mode takes no target" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-FOE(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-LOVE(WS-ROW) WC-NAU-ATTACK-CD(WS-ROW)
     MOVE -100 TO EN-MOBAGE(WS-ROW)
     CALL "NAUTILUS-PICK" USING WS-ROW WS-M
     MOVE "implementation 44-7 10.5 a baby nautilus takes no target" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-FOE(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-MOBAGE(WS-ROW)
     MOVE 0 TO EN-HEALTH(WS-PF)
     CALL "NAUTILUS-ATTACKABLE" USING WS-PF WS-OK
     MOVE "implementation 44-7 10.5 a mob without health is not attackable" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO PL-MODE(WS-PLAYER)
     CALL "NAUTILUS-ATTACKABLE" USING PL-ENTITY-ROW(WS-PLAYER) WS-OK
     MOVE "implementation 44-7 10.5 a creative player is not attackable" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-MODE(WS-PLAYER)
     CALL "ENTITY-REMOVE" USING WS-PF
*>   A target that dies during the charge ends it (a mob, then a player).
     MOVE 0 TO WC-NAU-CHARGE-CD(WS-ROW)
     MOVE WS-SQ TO EN-FOE(WS-ROW)
     MOVE EN-ID(WS-SQ) TO EN-FOE-ID(WS-ROW)
     COMPUTE WS-X = WS-X0 + 7.5
     MOVE WS-X TO EN-X(WS-SQ)
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE 0 TO EN-HEALTH(WS-SQ)
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "implementation 44-7 10.6 a target mob that dies ends the charge: cooldown 80" TO TL-CASE
     MOVE 80 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WC-NAU-CHARGE-CD(WS-ROW) + EN-FOE(WS-ROW) + WC-NAU-CHARGING(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-SQ
     MOVE 0 TO WC-NAU-CHARGE-CD(WS-ROW)
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE PL-ENTITY-ROW(WS-PLAYER) TO EN-FOE(WS-ROW)
     MOVE EN-ID(PL-ENTITY-ROW(WS-PLAYER)) TO EN-FOE-ID(WS-ROW)
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 8.5
     MOVE PL-X(WS-PLAYER) TO EN-X(PL-ENTITY-ROW(WS-PLAYER))
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE 0 TO PL-HEALTH(WS-PLAYER)
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "implementation 44-7 10.6 a target player with no health ends the charge: cooldown 80" TO TL-CASE
     MOVE 80 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WC-NAU-CHARGE-CD(WS-ROW) + EN-FOE(WS-ROW) + WC-NAU-CHARGING(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
*>   The countdowns: CHARGE_COOLDOWN_TICKS falls by one a tick and ANGRY_AT expires with EN-ANGER.
     MOVE 5 TO WC-NAU-CHARGE-CD(WS-ROW)
     MOVE 1 TO EN-ANGER(WS-ROW)
     MOVE 77 TO WC-NAU-ANGRY(WS-ROW)
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "implementation 44-7 10.5 the charge cooldown counts down and ANGRY_AT expires with its 400 ticks" TO TL-CASE
     MOVE 40 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WC-NAU-CHARGE-CD(WS-ROW) * 10 + WC-NAU-ANGRY(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   A dry nautilus (out of water) does not run the brain: it takes no hunting steps.
     COMPUTE WS-X = WS-X0 + 12.5
     COMPUTE WS-Y = WS-Y0 + 1.0
     COMPUTE WS-Z = WS-Z0 + 2.5
     CALL "MOB-SPAWN" USING WS-DIM WS-NAUTILUS WS-X WS-Y WS-Z WS-YAW WS-ROW
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "implementation 44-7 10.1 a nautilus out of water starts no charge and keeps its health for the first tick" TO TL-CASE
     MOVE 15 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   Temptation of a zombie nautilus and of a baby nautilus by a cod within 10 blocks.
     MOVE WS-COD TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 7.5
     MOVE PL-X(WS-PLAYER) TO EN-X(PL-ENTITY-ROW(WS-PLAYER))
     COMPUTE WS-X = WS-X0 + 2.5
     COMPUTE WS-Y = WS-Y0 + 3.5
     COMPUTE WS-Z = WS-Z0 + 4.5
     CALL "MOB-SPAWN" USING WS-DIM WS-ZOMBIE WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "NAUTILUS-TEMPT" USING WS-ROW WS-MZ WS-OK
     MOVE "implementation 44-7 10.8 a zombie nautilus is tempted by a cod" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ROW
     CALL "MOB-SPAWN" USING WS-DIM WS-NAUTILUS WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE -100 TO EN-MOBAGE(WS-ROW)
     CALL "NAUTILUS-TEMPT" USING WS-ROW WS-M WS-OK
     MOVE "implementation 44-7 10.5 a baby nautilus is tempted by a cod and stops at 2.5 blocks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE EN-ID(WS-ROW) TO WS-ID
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 4.5
     MOVE PL-X(WS-PLAYER) TO EN-X(PL-ENTITY-ROW(WS-PLAYER))
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "implementation 44-7 10.2 a baby nautilus follows the Animal rules: a cod is not used" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-MOBAGE(WS-ROW)
     MOVE "minecraft:stick" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-STICK WS-ITEM-ROW WS-STATUS
     MOVE WS-STICK TO PL-SLOT-ITEM(WS-PLAYER, 1)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "implementation 44-7 10.2 an item that is no nautilus food does nothing" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Nutrition: a tame nautilus at 1 health takes a cooked cod (5) for 10 and a pufferfish (1) for 2.
     MOVE 1 TO EN-TAMED(WS-ROW)
     MOVE 1 TO EN-HEALTH(WS-ROW)
     MOVE "minecraft:cooked_cod" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-CCOD WS-ITEM-ROW WS-STATUS
     MOVE WS-CCOD TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 2 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "implementation 44-7 10.2 a cooked cod heals 2.0 x 5 = 10" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-PUFFER-ITEM TO PL-SLOT-ITEM(WS-PLAYER, 1)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "implementation 44-7 10.2 a pufferfish (nutrition 1) heals a tame one by 2.0" TO TL-CASE
     MOVE 13 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ROW
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1)
*>   The swim: toward a destination 3.5 blocks away along +x the speed lerps to 0.125 of 1.0 and the velocity gains 0.125 x 0.011 = 0.001375 a tick (the nautilus modifier).
     CALL "MOB-SPAWN" USING WS-DIM WS-NAUTILUS WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "WC-ROW-OPEN" USING WS-ROW
     MOVE 1 TO WC-NAU-INIT(WS-ROW)
     MOVE 5000 TO WC-NAU-ATTACK-CD(WS-ROW)
     COMPUTE EN-DEST-X(WS-ROW) = WS-X0 + 6
     COMPUTE EN-DEST-Y(WS-ROW) = WS-Y0 + 3
     COMPUTE EN-DEST-Z(WS-ROW) = WS-Z0 + 4
     MOVE 50 TO EN-COOLDOWN(WS-ROW)
     MOVE EN-X(WS-ROW) TO WS-DX
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     COMPUTE WS-DX = (EN-X(WS-ROW) - WS-DX) * 1000000
     MOVE "implementation 44-7 10.1 the in-water speed modifier of the nautilus is 0.011 (a tick moves it 0.001375)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-DX > 1300 AND WS-DX < 1450
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ROW
     STOP RUN.
 FIND-DATA.
     CALL "PB-RESET" USING MQ-BUFFER
     CALL "MOB-DATA-BUILD" USING WS-ROW-A MQ-BUFFER
     CALL "PB-GET-VARINT" USING MQ-BUFFER WS-PK
     CALL "PB-GET-VARINT" USING MQ-BUFFER WS-PK
     MOVE -1 TO WS-MDV
     MOVE 0 TO WS-DONE
     PERFORM UNTIL WS-DONE = 1
         INITIALIZE MQ-METADATA-ENTRY-X
         CALL "PB-GET-METADATA-ENTRY-X" USING MQ-BUFFER MQ-METADATA-ENTRY-X
         IF MQ-MX-INDEX = MQ-MD-END OR MQ-ERROR = 1
             MOVE 1 TO WS-DONE
         ELSE
             IF MQ-MX-INDEX = WS-MDI
                 MOVE MQ-MX-INT TO WS-MDV
             END-IF
         END-IF
     END-PERFORM.
 END PROGRAM TEST-MOB-NAUTILUS.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY AQUATEST.
