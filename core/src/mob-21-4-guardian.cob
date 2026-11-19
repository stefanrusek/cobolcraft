*> Guardian and elder guardian (lane p49d; docs/protocol/21 section 4.8 with doc 44 part 7 section 5). Rows: core/copy/MOBROWS9.cpy (SM-KIND 6, the monster category in water);
*> STDMOB-AQUATIC-STEP calls GUARDIAN-TICK each tick. Tracker fields it reuses: EN-FOE / EN-FOE-ID = the target (the tracker row of a player's entity or a mob, and its entity id),
*> EN-SHOOT-TIME = attackTime of GuardianAttackGoal (-10 when the goal starts), EN-STRAFE-CW = isMoving (1 while it swims toward a stroll destination), EN-SWIM-SPEED = the move speed.
*> Entry points:
*>   GUARDIAN-DURATION USING table row, ticks out: the beam duration, 80 (guardian) or 60 (elder guardian).
*>   GUARDIAN-DAMAGE USING table row, damage out: the beam damage: 1, +2 on Hard, +2 more for the elder guardian.
*>   GUARDIAN-TICK USING row, table row, in water: the target goal (every 10 ticks the nearest survival or adventure player, squid, glow squid or axolotl within 16 blocks and more than
*>     3 away), GuardianAttackGoal (attackTime from -10; at 0 the active attack target metadata 17 and entity event 21; at the beam duration the beam's magic damage and then the melee hit; the
*>     target is dropped; a guardian stops when a target comes within 3 blocks), the stroll (AQUA-SWIM, 1 / 80 a tick) with the move control's wobble, and for the elder guardian the effect.
*>   GUARDIAN-ELDER USING row: every 1200 ticks Mining Fatigue III for 6000 ticks to the survival or adventure players within 50 blocks (not when theirs is a level III with more than 1199 ticks
*>     left) and Game Event 10 to each of them (value 1).
*>   GUARDIAN-THORNS USING row, cause, attacker player row: called by HEALTH-MOB-DAMAGE: a player's hit on a guardian that is not moving costs the attacker 2 (thorns).
*> Gaps: line of sight of the target goal and of the attack, the home position (MoveTowardsRestriction; the elder's home of radius 16), the stroll triggered by damage and by an attack, team
*> alliances, the silent flag, the moving metadata (16), and the death message of the beam (indirectMagic has no cause of its own: CAUSE-COMMAND, as thrown-44.cob).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GUARDIAN-DURATION.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STDMOBS.
 LINKAGE SECTION.
 01 L-M                    BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 PROCEDURE DIVISION USING L-M L-TICKS.
     MOVE 80 TO L-TICKS
     IF SM-KEY(L-M) = "elder_guardian"
         MOVE 60 TO L-TICKS
     END-IF
     GOBACK.
 END PROGRAM GUARDIAN-DURATION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GUARDIAN-DAMAGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRWORLD.
 COPY STDMOBS.
 LINKAGE SECTION.
 01 L-M                    BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 PROCEDURE DIVISION USING L-M L-DAMAGE.
     CALL "BR-WORLD-READY"
     MOVE 1 TO L-DAMAGE
     IF BW-DIFFICULTY = 3
         ADD 2 TO L-DAMAGE
     END-IF
     IF SM-KEY(L-M) = "elder_guardian"
         ADD 2 TO L-DAMAGE
     END-IF
     GOBACK.
 END PROGRAM GUARDIAN-DAMAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GUARDIAN-THORNS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RULES.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 01 WS-MILLI               BINARY-LONG VALUE 2000.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-CAUSE                BINARY-LONG.
 01 L-ATTACKER             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-CAUSE L-ATTACKER.
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF WS-M > 0
         IF (SM-KEY(WS-M) = "guardian" OR "elder_guardian") AND EN-STRAFE-CW(L-ROW) = 0 AND L-CAUSE = CAUSE-PLAYER AND L-ATTACKER > 0
             CALL "HEALTH-HURT" USING L-ATTACKER WS-MILLI CAUSE-MOB EN-ID(L-ROW) WS-NONE WS-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GUARDIAN-THORNS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GUARDIAN-ELDER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-P                   BINARY-LONG.
 01 WS-FATIGUE             BINARY-LONG VALUE 3.
 01 WS-AMP                 BINARY-LONG VALUE 2.
 01 WS-DURATION            BINARY-LONG VALUE 6000.
 01 WS-FLAGS               BINARY-LONG VALUE 6.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-EVENT               BINARY-LONG VALUE 10.
 01 WS-VALUE               FLOAT-SHORT VALUE 1.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF FUNCTION MOD(CW-TIME + EN-ID(L-ROW), 1200) NOT = 0
         GOBACK
     END-IF
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-DIM(WS-P) = EN-DIM(L-ROW) AND (PL-MODE(WS-P) = 0 OR PL-MODE(WS-P) = 2)
             COMPUTE WS-D2 = (PL-X(WS-P) - EN-X(L-ROW)) ** 2 + (PL-Y(WS-P) - EN-Y(L-ROW)) ** 2 + (PL-Z(WS-P) - EN-Z(L-ROW)) ** 2
             CALL "EFFECT-LEVEL" USING WS-P WS-FATIGUE WS-LEVEL WS-TICKS
             IF WS-D2 < 2500 AND (WS-LEVEL < 3 OR (WS-TICKS >= 0 AND WS-TICKS <= 1199))
                 CALL "EFFECT-ADD" USING WS-P WS-FATIGUE WS-AMP WS-DURATION WS-FLAGS
                 CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
                 CALL "PLAY-GAME-EVENT-BUILD" USING WS-EVENT WS-VALUE PB-BUFFER
                 CALL "CORE-SEND" USING PL-CONN(WS-P) PB-BUFFER
                 CALL "PB-FREE" USING PB-BUFFER
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GUARDIAN-ELDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GUARDIAN-SCAN.
*> USING row, target out (tracker row of the entity, 0 none): GuardianAttackSelector over the nearest candidates: a survival or adventure player, a squid or glow squid or an axolotl whose
*> distance squared from the guardian is above 9, within the follow range of 16 blocks (squared 256); the nearest wins.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-N                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-BEST                FLOAT-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-TARGET               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-TARGET.
     MOVE 0 TO L-TARGET
     MOVE 257 TO WS-BEST
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
         IF WS-N NOT = L-ROW AND EN-USED(WS-N) = 1 AND EN-DIM(WS-N) = EN-DIM(L-ROW)
             MOVE 0 TO WS-OK
             IF EN-PLAYER(WS-N) > 0
                 IF PL-HEALTH(EN-PLAYER(WS-N)) > 0 AND (PL-MODE(EN-PLAYER(WS-N)) = 0 OR PL-MODE(EN-PLAYER(WS-N)) = 2)
                     MOVE 1 TO WS-OK
                 END-IF
             ELSE
                 CALL "STDMOB-INDEX" USING EN-TYPE(WS-N) WS-S
                 IF WS-S > 0 AND EN-HEALTH(WS-N) > 0
                     IF SM-KEY(WS-S) = "squid" OR "glow_squid" OR "axolotl"
                         MOVE 1 TO WS-OK
                     END-IF
                 END-IF
             END-IF
             COMPUTE WS-D2 = (EN-X(WS-N) - EN-X(L-ROW)) ** 2 + (EN-Y(WS-N) - EN-Y(L-ROW)) ** 2 + (EN-Z(WS-N) - EN-Z(L-ROW)) ** 2
             IF WS-OK = 1 AND WS-D2 > 9 AND WS-D2 < WS-BEST
                 MOVE WS-N TO L-TARGET
                 MOVE WS-D2 TO WS-BEST
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GUARDIAN-SCAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GUARDIAN-BEAM.
*> USING row, table row, target row: the end of the beam: the target takes the beam damage as magic damage of the guardian and then the guardian's melee hit (ATTACK_DAMAGE).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RULES.
 COPY STDMOBS.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-MILLI               BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-RESULT              BINARY-LONG.
 01 WS-CAUSE-MOB           BINARY-LONG VALUE 7.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-T                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-M L-T.
     CALL "GUARDIAN-DAMAGE" USING L-M WS-DAMAGE
     IF EN-PLAYER(L-T) > 0
         COMPUTE WS-MILLI = WS-DAMAGE * 1000
         CALL "HEALTH-HURT" USING EN-PLAYER(L-T) WS-MILLI CAUSE-COMMAND EN-ID(L-ROW) WS-NONE WS-RESULT
         CALL "HEALTH-MOB-HIT" USING EN-PLAYER(L-T) SM-ATTACK(L-M) L-ROW
     ELSE
         CALL "HEALTH-MOB-DAMAGE" USING L-T WS-DAMAGE WS-CAUSE-MOB WS-NONE
         CALL "HEALTH-MOB-DAMAGE" USING L-T SM-ATTACK(L-M) WS-CAUSE-MOB WS-NONE
     END-IF
     GOBACK.
 END PROGRAM GUARDIAN-BEAM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GUARDIAN-STOP.
*> USING row: the stop of the attack goal: the active attack target metadata 17 is 0 and the target is forgotten.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "AQUA-STATE-SEND" USING L-ROW WS-ZERO
     MOVE 0 TO EN-FOE(L-ROW) EN-FOE-ID(L-ROW) EN-SHOOT-TIME(L-ROW)
     GOBACK.
 END PROGRAM GUARDIAN-STOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GUARDIAN-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 COPY STDMOBS.
 01 WS-T                   BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-ALIVE               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-EVENT               BINARY-LONG VALUE 21.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-RADIANS             FLOAT-LONG.
 01 WS-WOBBLE              FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-WET                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-M L-WET.
     IF SM-KEY(L-M) = "elder_guardian"
         CALL "GUARDIAN-ELDER" USING L-ROW
     END-IF
     MOVE 0 TO WS-ALIVE
     MOVE EN-FOE(L-ROW) TO WS-T
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
             COMPUTE WS-D2 = (EN-X(WS-T) - EN-X(L-ROW)) ** 2 + (EN-Y(WS-T) - EN-Y(L-ROW)) ** 2 + (EN-Z(WS-T) - EN-Z(L-ROW)) ** 2
             IF WS-D2 > 256 OR (WS-D2 <= 9 AND SM-KEY(L-M) NOT = "elder_guardian")
                 MOVE 0 TO WS-ALIVE
             END-IF
         END-IF
         IF WS-ALIVE = 0
             CALL "GUARDIAN-STOP" USING L-ROW
         END-IF
     END-IF
     IF L-WET = 0
         MOVE 0 TO EN-STRAFE-CW(L-ROW)
         GOBACK
     END-IF
     IF EN-FOE(L-ROW) = 0 AND FUNCTION MOD(CW-TIME + EN-ID(L-ROW), 10) = 0
         CALL "GUARDIAN-SCAN" USING L-ROW WS-T
         IF WS-T > 0
             MOVE WS-T TO EN-FOE(L-ROW)
             MOVE EN-ID(WS-T) TO EN-FOE-ID(L-ROW)
             MOVE -10 TO EN-SHOOT-TIME(L-ROW)
         END-IF
     END-IF
     MOVE EN-FOE(L-ROW) TO WS-T
     IF WS-T > 0
         ADD 1 TO EN-SHOOT-TIME(L-ROW)
         MOVE 0 TO EN-SWIM-SPEED(L-ROW) EN-STRAFE-CW(L-ROW)
         IF EN-SHOOT-TIME(L-ROW) = 0
             CALL "AQUA-STATE-SEND" USING L-ROW EN-FOE-ID(L-ROW)
             CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
             CALL "ENTITY-EVENT-BUILD" USING EN-ID(L-ROW) WS-EVENT PB-BUFFER
             CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
             CALL "PB-FREE" USING PB-BUFFER
         END-IF
         CALL "GUARDIAN-DURATION" USING L-M WS-TICKS
         IF EN-SHOOT-TIME(L-ROW) >= WS-TICKS
             CALL "GUARDIAN-BEAM" USING L-ROW L-M WS-T
             CALL "GUARDIAN-STOP" USING L-ROW
         END-IF
         GOBACK
     END-IF
     CALL "AQUA-SWIM" USING L-ROW L-M
     IF EN-SWIM-SPEED(L-ROW) > 0
         MOVE 1 TO EN-STRAFE-CW(L-ROW)
*>       The wobble of GuardianMoveControl: sin((tick + id) x 0.5) x 0.05 along the heading and sin((tick + id) x 0.75) x 0.05 vertically.
         COMPUTE WS-RADIANS = EN-YAW(L-ROW) * FUNCTION PI / 180
         COMPUTE WS-WOBBLE = FUNCTION SIN((CW-TIME + EN-ID(L-ROW)) * 0.5) * 0.05
         COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) - FUNCTION SIN(WS-RADIANS) * WS-WOBBLE
         COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) + FUNCTION COS(WS-RADIANS) * WS-WOBBLE
         COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) + FUNCTION SIN((CW-TIME + EN-ID(L-ROW)) * 0.75) * 0.05
     ELSE
         MOVE 0 TO EN-STRAFE-CW(L-ROW)
*>       Neither moving nor targeting: it sinks by 0.005 a tick.
         COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) - 0.005
     END-IF
     GOBACK.
 END PROGRAM GUARDIAN-TICK.
