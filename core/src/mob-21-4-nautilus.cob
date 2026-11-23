*> Nautilus and zombie nautilus (wrap C round 7, T24090; docs/protocol/44-residual-mob-questions-7-aquatic.md sections 9.3 and 10 with 21 section 4.10). Rows: core/copy/MOBROWS9.cpy (the nautilus, SM-KIND 7)
*> and core/copy/MOBROWSZN.cpy (the zombie nautilus, SM-KIND 8); STDMOB-AQUATIC-STEP calls NAUTILUS-TICK. Per-row state is WC-NAU-* of core/copy/WCSTATE.cpy; EN-FOE / EN-FOE-ID = the ATTACK_TARGET
*> (the tracker row of a player's entity or a mob, and its entity id), EN-ANGER = the ticks left of the ANGRY_AT memory (400, 10.5), EN-TAMED / EN-OWNER-UUID the TamableAnimal state (10.2),
*> EN-VARIANT of a zombie nautilus its variant id (0 temperate, 1 warm; 10.1), EN-FLEE the AnimalPanic of the nautilus (speed 1.6).
*> Entry points:
*>   NAUTILUS-FINALIZE USING row                   the variant of a zombie nautilus: warm when the biome at its block is in tag spawns_coral_variant_zombie_nautilus (priority 1), else temperate (10.1)
*>   NAUTILUS-NEEDED USING row, needed (inout)     1 when the entity data of the row differs from the defaults (tame, dash, a warm variant)
*>   NAUTILUS-DATA USING row, PB-BUFFER            Set Entity Data entries: index 18 BYTE (tame 4), 19 owner, 20 dash BOOLEAN, 21 variant (zombie nautilus only; serializer 32)
*>   NAUTILUS-HURT USING row, attacker player row  NautilusAi.setAngerTarget: a player that is attackable becomes ANGRY_AT for 400 ticks
*>   NAUTILUS-PICK USING row, table row            StartAttacking(findNearestValidAttackTarget): 10.5 (Q7-NAU-TARGET): the ANGRY_AT entity, else (cooldown absent) a 50 percent roll for the nearest pufferfish in water
*>   NAUTILUS-CHARGE-START / -CHARGE / -STOP       ChargeAttack(80, ..., speed 0.6 / 0.5, 2.0, 12.0, 11.0): 10.6
*>   NAUTILUS-TEMPT USING row, table row, tempted out   FollowTemptation (10.5, 10.8): the nearest player within 10 holding nautilus_food, speed 1.3 (nautilus) or 0.9, stop distance 3.5 (adult) or 2.5
*>   NAUTILUS-USE USING player row, entity row, held key, handled out   taming with pufferfish (1 in 3), feeding a tame one (10.2)
*>   NAUTILUS-TICK USING row, table row, in water  the brain of both kinds: countdowns, the target, the charge, temptation, the stroll (AQUA-SWIM, RandomStroll.swim(1.0))
*> Gaps (recorded on T24090): line of sight of the charge and the target sensor, the hit test uses axis-aligned boxes of the entity types, no knockback resistance of mob targets, the angry attacker must
*> be a player (mob attackers do not reach NAUTILUS-HURT), love mode (AnimalMakeLove), the swim controls' turn rates. The home restriction of a tame one is in mob-nautilus-home.cob.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NAUTILUS-FINALIZE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-BIOME               BINARY-LONG.
 01 WS-WARM                BINARY-LONG.
 01 WS-OUT                 BINARY-LONG.
 01 WS-TREG                PIC X(48) VALUE "worldgen/biome".
 01 WS-TTAG                PIC X(112) VALUE "minecraft:spawns_coral_variant_zombie_nautilus".
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     COMPUTE WS-X = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-Y = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-Z = FUNCTION INTEGER(EN-Z(L-ROW))
     MOVE 0 TO WS-WARM
     CALL "MS6-BIOME-ID-AT" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-BIOME
     IF WS-BIOME >= 0
         CALL "CONTENT-TAG-HAS" USING WS-TREG WS-TTAG WS-BIOME WS-WARM
     END-IF
     CALL "Q7-NAU-VARIANT" USING WS-WARM WS-OUT
     MOVE WS-OUT TO EN-VARIANT(L-ROW)
     GOBACK.
 END PROGRAM NAUTILUS-FINALIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NAUTILUS-NEEDED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WCSTATE.
 01 WS-KEY                 PIC X(24).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-NEEDED               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-NEEDED.
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     IF WS-KEY = "nautilus" OR "zombie_nautilus"
         CALL "WC-ROW-OPEN" USING L-ROW
         IF EN-TAMED(L-ROW) = 1 OR WC-NAU-DASH(L-ROW) = 1 OR WC-NAU-DASH-CD(L-ROW) > 0 OR (WS-KEY = "zombie_nautilus" AND EN-VARIANT(L-ROW) > 0)
             MOVE 1 TO L-NEEDED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM NAUTILUS-NEEDED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NAUTILUS-DATA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WCSTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==ND-==.
 01 WS-KEY                 PIC X(24).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 COPY PROTO.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     IF NOT (WS-KEY = "nautilus" OR "zombie_nautilus")
         GOBACK
     END-IF
     CALL "WC-ROW-OPEN" USING L-ROW
*>   TamableAnimal (10.2): index 18 BYTE flags, 0x04 tame; index 19 the owner (OPTIONAL_LIVING_ENTITY_REFERENCE, serializer 13).
     IF EN-TAMED(L-ROW) = 1
         INITIALIZE ND-METADATA-ENTRY
         MOVE 18 TO ND-MD-INDEX
         MOVE ND-MDS-BYTE TO ND-MD-SERIALIZER
         MOVE 4 TO ND-MD-INT
         CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER ND-METADATA-ENTRY
         IF EN-OWNER-UUID(L-ROW) NOT = SPACES
             INITIALIZE ND-METADATA-ENTRY-X
             MOVE 19 TO ND-MX-INDEX
             MOVE 13 TO ND-MX-SERIALIZER
             MOVE 1 TO ND-MX-PRESENT
             MOVE EN-OWNER-UUID(L-ROW) TO ND-MX-UUID
             CALL "PB-PUT-METADATA-ENTRY-X" USING PB-BUFFER ND-METADATA-ENTRY-X
         END-IF
     END-IF
*>   Index 20, the dash flag (10.4).
     IF WC-NAU-DASH(L-ROW) = 1 OR WC-NAU-DASH-CD(L-ROW) > 0
         INITIALIZE ND-METADATA-ENTRY
         MOVE 20 TO ND-MD-INDEX
         MOVE ND-MDS-BOOLEAN TO ND-MD-SERIALIZER
         MOVE WC-NAU-DASH(L-ROW) TO ND-MD-INT
         CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER ND-METADATA-ENTRY
     END-IF
*>   Index 21, the variant of a zombie nautilus: a registry id (serializer 32 ZOMBIE_NAUTILUS_VARIANT), sent when it is not the default 0. The two variant files, temperate and warm, are the ids 0 and 1
*>   of the synced registry (the entries are sorted by key), so EN-VARIANT is the id.
     IF WS-KEY = "zombie_nautilus" AND EN-VARIANT(L-ROW) > 0
         INITIALIZE ND-METADATA-ENTRY-X
         MOVE 21 TO ND-MX-INDEX
         MOVE 32 TO ND-MX-SERIALIZER
         MOVE EN-VARIANT(L-ROW) TO ND-MX-INT
         CALL "PB-PUT-METADATA-ENTRY-X" USING PB-BUFFER ND-METADATA-ENTRY-X
     END-IF
     GOBACK.
 END PROGRAM NAUTILUS-DATA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NAUTILUS-HURT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WCSTATE.
 01 WS-KEY                 PIC X(24).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ATTACKER             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ATTACKER.
     IF L-ATTACKER = 0
         GOBACK
     END-IF
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     IF NOT (WS-KEY = "nautilus" OR "zombie_nautilus")
         GOBACK
     END-IF
*>   isEntityAttackableIgnoringLineOfSight: a creative or spectator player cannot be attacked, so it does not become the target.
     IF PL-MODE(L-ATTACKER) = 1 OR PL-MODE(L-ATTACKER) = 3
         GOBACK
     END-IF
     CALL "WC-ROW-OPEN" USING L-ROW
     MOVE 400 TO EN-ANGER(L-ROW)
     MOVE PL-ENTITY-ID(L-ATTACKER) TO WC-NAU-ANGRY(L-ROW)
     GOBACK.
 END PROGRAM NAUTILUS-HURT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NAUTILUS-STOP.
*> USING row: ChargeAttack.stop: CHARGE_COOLDOWN_TICKS 80 (timeBetweenAttacks) and ATTACK_TARGET erased.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WCSTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE 80 TO WC-NAU-CHARGE-CD(L-ROW)
     MOVE 0 TO WC-NAU-CHARGING(L-ROW) EN-FOE(L-ROW) EN-FOE-ID(L-ROW)
     GOBACK.
 END PROGRAM NAUTILUS-STOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NAUTILUS-PICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WCSTATE.
 COPY STDMOBS.
 01 WS-N                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-BREEDING            BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-ANGRY               BINARY-LONG.
 01 WS-CD                  BINARY-LONG.
 01 WS-ROLL                BINARY-LONG.
 01 WS-HOSTILE             BINARY-LONG.
 01 WS-TARGET              BINARY-LONG.
 01 WS-SETCD               BINARY-LONG.
 01 WS-WET                 BINARY-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-SALT                BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-BEST                FLOAT-LONG.
 01 WS-PUFFER              BINARY-LONG.
 01 WS-SELF-WET            BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-M.
     MOVE 0 TO WS-BREEDING WS-BABY WS-ANGRY WS-CD WS-ROLL WS-HOSTILE WS-FOUND WS-PUFFER
     IF EN-LOVE(L-ROW) > 0
         MOVE 1 TO WS-BREEDING
     END-IF
     IF EN-MOBAGE(L-ROW) < 0
         MOVE 1 TO WS-BABY
     END-IF
     IF WC-NAU-ATTACK-CD(L-ROW) > 0
         MOVE 1 TO WS-CD
     END-IF
*>   ANGRY_AT resolves to a living entity of the dimension that is in water and attackable (a survival or adventure player, or a living mob).
     IF EN-ANGER(L-ROW) > 0 AND WC-NAU-ANGRY(L-ROW) > 0
         PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT OR WS-FOUND > 0
             IF EN-USED(WS-N) = 1 AND EN-ID(WS-N) = WC-NAU-ANGRY(L-ROW) AND EN-DIM(WS-N) = EN-DIM(L-ROW)
                 MOVE WS-N TO WS-FOUND
             END-IF
         END-PERFORM
         IF WS-FOUND > 0
             CALL "NAUTILUS-ATTACKABLE" USING WS-FOUND WS-ANGRY
         END-IF
     END-IF
*>   Without an angry target and without the cooldown: the 50 percent roll (nextFloat < 0.5 gives no target) and the nearest pufferfish in water within the sensor box.
     IF WS-ANGRY = 0 AND WS-CD = 0
         MOVE 42 TO WS-SALT
         CALL "AQUA-RAND" USING L-ROW WS-SALT WS-R
         IF WS-R < 0.5
             MOVE 1 TO WS-ROLL
         END-IF
         MOVE 256 TO WS-BEST
         PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
             IF WS-N NOT = L-ROW AND EN-USED(WS-N) = 1 AND EN-DIM(WS-N) = EN-DIM(L-ROW) AND EN-PLAYER(WS-N) = 0
                 CALL "STDMOB-INDEX" USING EN-TYPE(WS-N) WS-S
                 IF WS-S > 0 AND EN-HEALTH(WS-N) > 0
                     IF SM-KEY(WS-S) = "pufferfish"
                         COMPUTE WS-D2 = (EN-X(WS-N) - EN-X(L-ROW)) ** 2 + (EN-Y(WS-N) - EN-Y(L-ROW)) ** 2 + (EN-Z(WS-N) - EN-Z(L-ROW)) ** 2
                         CALL "FLUID-TOUCHES-WATER" USING EN-DIM(WS-N) EN-X(WS-N) EN-Y(WS-N) EN-Z(WS-N) WS-WET
                         IF WS-WET = 1 AND WS-D2 <= WS-BEST
                             MOVE WS-D2 TO WS-BEST
                             MOVE WS-N TO WS-PUFFER
                             MOVE 1 TO WS-HOSTILE
                         END-IF
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     CALL "Q7-NAU-TARGET" USING WS-BREEDING WS-SELF-WET WS-BABY EN-TAMED(L-ROW) WS-ANGRY WS-CD WS-ROLL WS-HOSTILE WS-TARGET WS-SETCD
     IF WS-SETCD = 1
         MOVE 43 TO WS-SALT
         CALL "AQUA-RAND" USING L-ROW WS-SALT WS-R
         COMPUTE WC-NAU-ATTACK-CD(L-ROW) = 2400 + WS-R * 1201
     END-IF
     IF WS-TARGET = 1
         IF WS-ANGRY = 1
             MOVE WS-FOUND TO WS-N
         ELSE
             MOVE WS-PUFFER TO WS-N
         END-IF
         MOVE WS-N TO EN-FOE(L-ROW)
         MOVE EN-ID(WS-N) TO EN-FOE-ID(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM NAUTILUS-PICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NAUTILUS-ATTACKABLE.
*> USING tracker row of the candidate, ok out: the candidate is a living entity that is in water and attackable: a player with health that is in survival or adventure, or a mob with health (10.5 rule 2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-WET                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-OK.
     MOVE 0 TO L-OK
     IF EN-PLAYER(L-N) > 0
         IF PL-HEALTH(EN-PLAYER(L-N)) = 0 OR PL-MODE(EN-PLAYER(L-N)) = 1 OR PL-MODE(EN-PLAYER(L-N)) = 3
             GOBACK
         END-IF
     ELSE
         IF EN-HEALTH(L-N) = 0
             GOBACK
         END-IF
     END-IF
     CALL "FLUID-TOUCHES-WATER" USING EN-DIM(L-N) EN-X(L-N) EN-Y(L-N) EN-Z(L-N) WS-WET
     MOVE WS-WET TO L-OK
     GOBACK.
 END PROGRAM NAUTILUS-ATTACKABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NAUTILUS-CHARGE-START.
*> USING row, table row, started out: ChargeAttack.start (10.6): chargeVelocity = normalize(target - own) x speed (0.6 nautilus, 0.5 zombie nautilus; positions are the feet positions), startPosition = the
*> animal's position. When canStillUse does not hold at once (the target is 11 blocks or farther) the behaviour stops with the cooldown (the framework's first tickOrStop).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WCSTATE.
 COPY STDMOBS.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-D2T                 FLOAT-LONG.
 01 WS-D2S                 FLOAT-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-SIGHT               BINARY-LONG VALUE 1.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-STARTED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-M L-STARTED.
     MOVE 0 TO L-STARTED
     COMPUTE WS-DX = EN-X(EN-FOE(L-ROW)) - EN-X(L-ROW)
     COMPUTE WS-DY = EN-Y(EN-FOE(L-ROW)) - EN-Y(L-ROW)
     COMPUTE WS-DZ = EN-Z(EN-FOE(L-ROW)) - EN-Z(L-ROW)
     MOVE 0.6 TO WS-SPEED
     IF SM-KIND(L-M) = 8
         MOVE 0.5 TO WS-SPEED
     END-IF
     CALL "Q7-NAU-CHARGE-VEL" USING WS-DX WS-DY WS-DZ WS-SPEED WS-VX WS-VZ WS-VY
     COMPUTE WS-D2T = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
     CALL "Q7-NAU-CHARGE-USE" USING WS-ONE EN-TAMED(L-ROW) WS-D2S WS-D2T WS-SIGHT WC-NAU-CHARGE-CD(L-ROW) WS-OK
     IF WS-OK = 0
         CALL "NAUTILUS-STOP" USING L-ROW
         GOBACK
     END-IF
     COMPUTE WC-NAU-VX(L-ROW) = WS-VX * 1000
     COMPUTE WC-NAU-VY(L-ROW) = WS-VY * 1000
     COMPUTE WC-NAU-VZ(L-ROW) = WS-VZ * 1000
     COMPUTE WC-NAU-SX(L-ROW) = EN-X(L-ROW) * 1000
     COMPUTE WC-NAU-SY(L-ROW) = EN-Y(L-ROW) * 1000
     COMPUTE WC-NAU-SZ(L-ROW) = EN-Z(L-ROW) * 1000
     MOVE 1 TO WC-NAU-CHARGING(L-ROW) L-STARTED
     GOBACK.
 END PROGRAM NAUTILUS-CHARGE-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NAUTILUS-HIT.
*> USING row, table row, victim tracker row: dealDamageToTarget (the attack damage as a mob hit: a player takes the difficulty-scaled HEALTH-MOB-HIT, a mob HEALTH-MOB-DAMAGE) and dealKnockBack
*> (10.6): force = clamp(speed x movement speed, 0.2, 2.0) x 2.0 (no Speed or Slowness), pushed along the charge direction (the target's motion halved first), the animal's own horizontal motion x 0.6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WCSTATE.
 COPY RULES.
 COPY STDMOBS.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-ATTR                FLOAT-LONG.
 01 WS-FORCE               FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-NO-AMP              BINARY-LONG VALUE 0.
 01 WS-CAUSE               BINARY-LONG VALUE 7.
 01 WS-VX                  BINARY-LONG.
 01 WS-VY                  BINARY-LONG.
 01 WS-VZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-T                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-M L-T.
     IF EN-PLAYER(L-T) > 0
         CALL "HEALTH-MOB-HIT" USING EN-PLAYER(L-T) SM-ATTACK(L-M) L-ROW
     ELSE
         CALL "HEALTH-MOB-DAMAGE" USING L-T SM-ATTACK(L-M) WS-CAUSE WS-ZERO
     END-IF
     MOVE 0.6 TO WS-SPEED
     IF SM-KIND(L-M) = 8
         MOVE 0.5 TO WS-SPEED
     END-IF
     COMPUTE WS-ATTR = SM-WALK-MILLI(L-M) / 1000
     CALL "Q7-NAU-KNOCKBACK" USING WS-SPEED WS-ATTR WS-ZERO WS-NO-AMP WS-FORCE
     COMPUTE WS-DX = WC-NAU-VX(L-ROW) / 1000
     COMPUTE WS-DZ = WC-NAU-VZ(L-ROW) / 1000
     COMPUTE WS-LEN = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
     IF WS-LEN > 0
         COMPUTE WS-DX = WS-DX / WS-LEN * WS-FORCE
         COMPUTE WS-DZ = WS-DZ / WS-LEN * WS-FORCE
         IF EN-PLAYER(L-T) > 0
*>           The core keeps no velocity of a player: the push is the whole motion.
             COMPUTE WS-VX = WS-DX * 1000
             MOVE 0 TO WS-VY
             COMPUTE WS-VZ = WS-DZ * 1000
             CALL "COMBAT-MOTION-SEND" USING EN-PLAYER(L-T) WS-VX WS-VY WS-VZ
         ELSE
             COMPUTE EN-VX(L-T) = EN-VX(L-T) / 2 + WS-DX
             COMPUTE EN-VZ(L-T) = EN-VZ(L-T) / 2 + WS-DZ
         END-IF
     END-IF
     COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) * 0.6
     COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) * 0.6
     GOBACK.
 END PROGRAM NAUTILUS-HIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NAUTILUS-CHARGE.
*> USING row, table row: one tick of a running charge (10.6): canStillUse (Q7-NAU-CHARGE-USE: the target is there, the animal is not tame, within 12 blocks of the start and 11 of the target; the line of
*> sight is taken as given), the 60-tick duration, the velocity overwritten with the charge velocity, and the first living entity whose box meets the animal's own box and that is attackable takes the
*> hit (NAUTILUS-HIT) and ends the charge. The end of a charge (hit, canStillUse false, duration) is NAUTILUS-STOP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY WCSTATE.
 COPY STDMOBS.
 01 WS-T                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-D2S                 FLOAT-LONG.
 01 WS-D2T                 FLOAT-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-SIGHT               BINARY-LONG VALUE 1.
 01 WS-ALIVE               BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-HALF-A              FLOAT-LONG.
 01 WS-HALF-B              FLOAT-LONG.
 01 WS-HEIGHT-A            FLOAT-LONG.
 01 WS-HEIGHT-B            FLOAT-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-PLAYER-OK           BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-M.
     MOVE EN-FOE(L-ROW) TO WS-T
     MOVE 0 TO WS-ALIVE
     IF WS-T > 0
         IF EN-USED(WS-T) = 1 AND EN-ID(WS-T) = EN-FOE-ID(L-ROW)
             MOVE 1 TO WS-ALIVE
             IF EN-PLAYER(WS-T) > 0
                 IF PL-HEALTH(EN-PLAYER(WS-T)) = 0
                     MOVE 0 TO WS-ALIVE
                 END-IF
             ELSE
                 IF EN-HEALTH(WS-T) = 0
                     MOVE 0 TO WS-ALIVE
                 END-IF
             END-IF
         END-IF
     END-IF
     IF WS-ALIVE = 0
         CALL "NAUTILUS-STOP" USING L-ROW
         GOBACK
     END-IF
     COMPUTE WS-D2S = (EN-X(L-ROW) * 1000 - WC-NAU-SX(L-ROW)) ** 2 + (EN-Y(L-ROW) * 1000 - WC-NAU-SY(L-ROW)) ** 2
         + (EN-Z(L-ROW) * 1000 - WC-NAU-SZ(L-ROW)) ** 2
     COMPUTE WS-D2S = WS-D2S / 1000000
     COMPUTE WS-D2T = (EN-X(WS-T) - EN-X(L-ROW)) ** 2 + (EN-Y(WS-T) - EN-Y(L-ROW)) ** 2 + (EN-Z(WS-T) - EN-Z(L-ROW)) ** 2
     CALL "Q7-NAU-CHARGE-USE" USING WS-ONE EN-TAMED(L-ROW) WS-D2S WS-D2T WS-SIGHT WC-NAU-CHARGE-CD(L-ROW) WS-OK
     ADD 1 TO WC-NAU-CHARGING(L-ROW)
     IF WS-OK = 0 OR WC-NAU-CHARGING(L-ROW) > 60
         CALL "NAUTILUS-STOP" USING L-ROW
         GOBACK
     END-IF
     COMPUTE EN-VX(L-ROW) = WC-NAU-VX(L-ROW) / 1000
     COMPUTE EN-VY(L-ROW) = WC-NAU-VY(L-ROW) / 1000
     COMPUTE EN-VZ(L-ROW) = WC-NAU-VZ(L-ROW) / 1000
*>   The first attackable living entity whose box meets the animal's own box (not inflated): the animal is 0.875 wide and 0.95 tall.
     COMPUTE WS-TYPE = EN-TYPE(L-ROW) + 1
     COMPUTE WS-HALF-A = ET-WIDTH-MILLI(WS-TYPE) / 2000
     COMPUTE WS-HEIGHT-A = ET-HEIGHT-MILLI(WS-TYPE) / 1000
     MOVE 0 TO WS-HIT
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT OR WS-HIT > 0
         IF WS-N NOT = L-ROW AND EN-USED(WS-N) = 1 AND EN-DIM(WS-N) = EN-DIM(L-ROW)
             CALL "NAUTILUS-ATTACKABLE" USING WS-N WS-PLAYER-OK
             IF WS-PLAYER-OK = 1
                 COMPUTE WS-TYPE = EN-TYPE(WS-N) + 1
                 COMPUTE WS-HALF-B = ET-WIDTH-MILLI(WS-TYPE) / 2000
                 COMPUTE WS-HEIGHT-B = ET-HEIGHT-MILLI(WS-TYPE) / 1000
                 COMPUTE WS-DX = FUNCTION ABS(EN-X(WS-N) - EN-X(L-ROW))
                 COMPUTE WS-DZ = FUNCTION ABS(EN-Z(WS-N) - EN-Z(L-ROW))
                 IF WS-DX < WS-HALF-A + WS-HALF-B AND WS-DZ < WS-HALF-A + WS-HALF-B
                         AND EN-Y(WS-N) < EN-Y(L-ROW) + WS-HEIGHT-A AND EN-Y(L-ROW) < EN-Y(WS-N) + WS-HEIGHT-B
                     MOVE WS-N TO WS-HIT
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF WS-HIT > 0
         CALL "NAUTILUS-HIT" USING L-ROW L-M WS-HIT
         CALL "NAUTILUS-STOP" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM NAUTILUS-CHARGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NAUTILUS-TEMPT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-P                   BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-LIMIT               FLOAT-LONG.
 01 WS-STOP                FLOAT-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-KEY48               PIC X(48).
 01 WS-ITEM                PIC X(24).
 01 WS-FOOD                BINARY-LONG.
 01 WS-TAMING              BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-TEMPTED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-M L-TEMPTED.
     MOVE 0 TO L-TEMPTED
     MOVE 0 TO WS-BEST
     MOVE 100 TO WS-LIMIT
*>   TemptingSensor (2.5): the nearest player that is not a spectator within the tempt range 10 and holds an item of tag nautilus_food in the main hand.
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-STATE(WS-P) = PS-ALIVE AND PL-MODE(WS-P) NOT = 3 AND PL-DIM(WS-P) = EN-DIM(L-ROW)
             COMPUTE WS-D2 = (PL-X(WS-P) - EN-X(L-ROW)) ** 2 + (PL-Y(WS-P) - EN-Y(L-ROW)) ** 2 + (PL-Z(WS-P) - EN-Z(L-ROW)) ** 2
             IF WS-D2 <= WS-LIMIT AND PL-SLOT-COUNT(WS-P, PL-HELD(WS-P) + 1) > 0
                 CALL "TOOLUSE-KEY" USING PL-SLOT-ITEM(WS-P, PL-HELD(WS-P) + 1) WS-KEY48
                 MOVE WS-KEY48 TO WS-ITEM
                 CALL "Q7-NAU-FOOD" USING WS-ITEM WS-FOOD WS-TAMING
                 IF WS-FOOD > 0
                     MOVE WS-D2 TO WS-LIMIT
                     MOVE WS-P TO WS-BEST
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF WS-BEST = 0
         GOBACK
     END-IF
     MOVE 1 TO L-TEMPTED
*>   FollowTemptation: speed 1.3 (nautilus) or 0.9 (zombie nautilus) and the stop distance 3.5 for an adult, 2.5 for a baby; within it the animal stands.
     MOVE 1.3 TO WS-SPEED
     IF SM-KIND(L-M) = 8
         MOVE 0.9 TO WS-SPEED
     END-IF
     MOVE 3.5 TO WS-STOP
     IF EN-MOBAGE(L-ROW) < 0
         MOVE 2.5 TO WS-STOP
     END-IF
     IF WS-LIMIT > WS-STOP * WS-STOP
         MOVE PL-X(WS-BEST) TO WS-X
         MOVE PL-Y(WS-BEST) TO WS-Y
         MOVE PL-Z(WS-BEST) TO WS-Z
         CALL "AQUA-CHASE" USING L-ROW WS-X WS-Y WS-Z WS-SPEED
     END-IF
     GOBACK.
 END PROGRAM NAUTILUS-TEMPT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NAUTILUS-USE.
*> USING player row, entity row, held key (PIC X(24)), handled out: the main hand on an adult nautilus or zombie nautilus (10.2). An untamed one fed pufferfish or a pufferfish bucket (tag
*> nautilus_taming_items) uses one item (a bucket becomes a water bucket) and nextInt(3) = 0 tames it: the player is the owner, Entity Event 7 (hearts), else Entity Event 6 (smoke). A tame one fed an
*> item of tag nautilus_food (fish, bucket food) while below its max health of 15 heals 2.0 x nutrition (1.0 for a bucket, which has no food component) and uses the item. Fish do not tame
*> (for an untamed adult isFood is the taming tag). A baby follows the Animal rules (not here). Not built: the inventory screen of a tame one with secondary use, riding, equipping armor and a saddle.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-KEY                 PIC X(24).
 01 WS-FOOD                BINARY-LONG.
 01 WS-TAMING              BINARY-LONG.
 01 WS-SALT                BINARY-LONG VALUE 33.
 01 WS-BOUND               BINARY-LONG VALUE 3.
 01 WS-DRAW                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-EVENT               BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-NUTRITION           BINARY-LONG.
 01 WS-MAX                 BINARY-LONG VALUE 15.
 01 WS-MULT                BINARY-LONG VALUE 2.
 01 WS-NEW                 BINARY-LONG.
 01 WS-WATER               PIC X(24) VALUE "water_bucket".
 01 WS-WATER-ID            BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-HELD                 PIC X(24).
 01 L-USED                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ENTITY L-HELD L-USED.
     MOVE 0 TO L-USED
     CALL "MOB-SPECIES-KEY" USING L-ENTITY WS-KEY
     IF NOT (WS-KEY = "nautilus" OR "zombie_nautilus") OR EN-MOBAGE(L-ENTITY) < 0
         GOBACK
     END-IF
     CALL "Q7-NAU-FOOD" USING L-HELD WS-FOOD WS-TAMING
     IF WS-FOOD = 0
         GOBACK
     END-IF
     IF EN-TAMED(L-ENTITY) = 0 AND WS-TAMING = 0
         GOBACK
     END-IF
     IF EN-TAMED(L-ENTITY) = 1 AND EN-HEALTH(L-ENTITY) >= WS-MAX
         GOBACK
     END-IF
*>   usePlayerItem: one item is used; a bucket food leaves a water bucket in the hand.
     IF WS-FOOD = 2
         CALL "MOB-ITEM-ID" USING WS-WATER WS-WATER-ID
         CALL "MOB-SWAP" USING L-ROW WS-WATER-ID
     ELSE
         CALL "MOB-TAKE" USING L-ROW
     END-IF
     MOVE 1 TO L-USED
     IF EN-TAMED(L-ENTITY) = 1
         EVALUATE L-HELD
             WHEN "cooked_cod"
                 MOVE 5 TO WS-NUTRITION
             WHEN "cooked_salmon"
                 MOVE 6 TO WS-NUTRITION
             WHEN "cod" WHEN "salmon"
                 MOVE 2 TO WS-NUTRITION
             WHEN OTHER
                 MOVE 1 TO WS-NUTRITION
         END-EVALUATE
         CALL "M195-HEAL" USING EN-HEALTH(L-ENTITY) WS-MAX WS-NUTRITION WS-MULT WS-NEW
         MOVE WS-NEW TO EN-HEALTH(L-ENTITY)
         GOBACK
     END-IF
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
     CALL "M188-TAME-TRY" USING WS-DRAW WS-OK
     MOVE 6 TO WS-EVENT
     IF WS-OK = 1
         MOVE 7 TO WS-EVENT
         MOVE 1 TO EN-TAMED(L-ENTITY)
         MOVE PL-UUID(L-ROW) TO EN-OWNER-UUID(L-ENTITY)
         MOVE 0 TO EN-COOLDOWN(L-ENTITY) EN-FOE(L-ENTITY) EN-FOE-ID(L-ENTITY)
     END-IF
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "ENTITY-EVENT-BUILD" USING EN-ID(L-ENTITY) WS-EVENT PB-BUFFER
     CALL "HEALTH-VIEWERS-SEND" USING L-ENTITY PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     IF WS-OK = 1
         CALL "MOB-DATA-SEND" USING L-ENTITY
     END-IF
     GOBACK.
 END PROGRAM NAUTILUS-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NAUTILUS-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WCSTATE.
 COPY STDMOBS.
 01 WS-R                   FLOAT-LONG.
 01 WS-SALT                BINARY-LONG.
 01 WS-STARTED             BINARY-LONG.
 01 WS-TEMPTED             BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-WET                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-M L-WET.
     CALL "WC-ROW-OPEN" USING L-ROW
*>   finalizeSpawn / initMemories: a fresh ATTACK_TARGET_COOLDOWN of uniform(2400, 3600) (10.5).
     IF WC-NAU-INIT(L-ROW) = 0
         MOVE 1 TO WC-NAU-INIT(L-ROW)
         MOVE 41 TO WS-SALT
         CALL "AQUA-RAND" USING L-ROW WS-SALT WS-R
         COMPUTE WC-NAU-ATTACK-CD(L-ROW) = 2400 + WS-R * 1201
     END-IF
*>   checkRestriction before the brain (44-7 section 10.4): the home of a tame one.
     CALL "NAUTILUS-RESTRICT" USING L-ROW
*>   CORE: the three cooldown countdowns and the expiry of ANGRY_AT.
     IF WC-NAU-ATTACK-CD(L-ROW) > 0
         SUBTRACT 1 FROM WC-NAU-ATTACK-CD(L-ROW)
     END-IF
     IF WC-NAU-CHARGE-CD(L-ROW) > 0
         SUBTRACT 1 FROM WC-NAU-CHARGE-CD(L-ROW)
     END-IF
     CALL "NAUTILUS-DASH-TICK" USING L-ROW
     IF EN-ANGER(L-ROW) > 0
         SUBTRACT 1 FROM EN-ANGER(L-ROW)
         IF EN-ANGER(L-ROW) = 0
             MOVE 0 TO WC-NAU-ANGRY(L-ROW)
         END-IF
     END-IF
     IF L-WET = 0
         GOBACK
     END-IF
*>   FIGHT first: a running charge, or the start of one (ATTACK_TARGET present, CHARGE_COOLDOWN_TICKS absent, not tempted by a player).
     IF WC-NAU-CHARGING(L-ROW) > 0
         CALL "NAUTILUS-CHARGE" USING L-ROW L-M
         GOBACK
     END-IF
     IF EN-FOE(L-ROW) = 0
         CALL "NAUTILUS-PICK" USING L-ROW L-M
     END-IF
     IF EN-FOE(L-ROW) > 0 AND WC-NAU-CHARGE-CD(L-ROW) = 0
         CALL "NAUTILUS-CHARGE-START" USING L-ROW L-M WS-STARTED
         IF WS-STARTED = 1
             CALL "NAUTILUS-CHARGE" USING L-ROW L-M
             GOBACK
         END-IF
     END-IF
*>   IDLE: panic (the nautilus), temptation, then the stroll (AQUA-SWIM carries the panic of EN-FLEE).
     CALL "NAUTILUS-TEMPT" USING L-ROW L-M WS-TEMPTED
     IF WS-TEMPTED = 0 OR EN-FLEE(L-ROW) > 0
         CALL "AQUA-SWIM" USING L-ROW L-M
     END-IF
     GOBACK.
 END PROGRAM NAUTILUS-TICK.
