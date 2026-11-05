*> Mobs (US9; standin-content §12, §3, §10.2; data-model §7; docs/protocol/09-cobolcraft-profile.md
*> §3.3 Mobs rows). The mob types and rules are core/copy/MOBS.cpy.
*>
*> A mob is a row of the entity tracker (CORE-ENTITIES) of a mob entity type (sodgrazer 2, abend 3)
*> with no player: EN-X to EN-YAW its position and yaw, EN-VY its vertical velocity, EN-ON-GROUND,
*> and the mob fields EN-HEALTH to EN-COOLDOWN (CORESTATE.cpy). Its UUID has the most significant 64
*> bits 0 and the least significant 64 bits = the entity id (09 §3.3). Viewers see it like any
*> tracked entity (core/src/entities.cob): Add Entity (movement (0, 0, 0)) on entering view, Move
*> Entity / Rotate Head after each tick in which its position or yaw changed, Remove Entities.
*>
*> Per tick (CORE-TICK): MOBS-SPAWN-TICK is step 5 of standin §9.5 (spawning, §12.4), MOBS-TICK
*> step 6 (the hostile-mobs removal, then each mob in ascending entity id order: hurt cooldown, AI
*> §12.3, physics §12.2). Damage from player attacks is HEALTH-MOB-DAMAGE (core/src/health.cob),
*> which ends in MOB-DEFEAT at 0 health. AI state is not saved (§12.3).
*>
*> Entry points:
*>   MOB-SPAWN USING dim, entity type (BINARY-LONG), x, y, z (FLOAT-LONG), yaw (FLOAT-SHORT), row
*>     out (BINARY-LONG)                           a new mob, full health, idle, sent to its viewers
*>   MOB-DEFEAT USING row                          health 0: removed, its yield on the ground
*>   MOBS-SPAWN-TICK                               spawning (step 5)
*>   MOBS-TICK                                     the mobs (step 6)
*> Internal: MOB-SPAWN-TRY, MOB-SPAWN-RULE (spawning), MOB-STEP, MOB-TARGET, MOB-YAW-TOWARD, MOB-AI,
*> MOB-PHYSICS (one mob's tick).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-SPAWN.
*> USING dimension row, entity type, x, y, z, yaw, row out: a new mob of that type at that position
*> with that yaw, full health (§12.1), no motion, standing still until its first wander decision
*> (§12.3); it enters the tracker (Add Entity to every player who sees it).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY MOBS.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-YAW                  FLOAT-SHORT.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-TYPE L-X L-Y L-Z L-YAW L-ROW.
     CALL "ENTITY-ALLOC" USING WS-ROW
     CALL "ENTITY-NEW-ID" USING EN-ID(WS-ROW)
     MOVE L-TYPE TO EN-TYPE(WS-ROW)
     CALL "ENTITY-SET-UUID" USING WS-ROW
     MOVE L-DIM TO EN-DIM(WS-ROW)
     MOVE L-X TO EN-X(WS-ROW)
     MOVE L-Y TO EN-Y(WS-ROW)
     MOVE L-Z TO EN-Z(WS-ROW)
     MOVE L-YAW TO EN-YAW(WS-ROW)
     MOVE MB-HEALTH(L-TYPE - MOB-FIRST-TYPE + 1) TO EN-HEALTH(WS-ROW)
     CALL "ENTITY-TRACK" USING WS-ROW
     MOVE WS-ROW TO L-ROW
     GOBACK.
 END PROGRAM MOB-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-DEFEAT.
*> USING tracker row (BINARY-LONG) of a mob whose health reached 0 (§12.5): it is removed (Remove
*> Entities to its viewers) and its yield (§12.1) appears as one ground item at its position with no
*> motion and the mob-defeat pickup delay (§9.1, RULES.cpy RULE-GI-BREAK-DELAY).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY MOBS.
 COPY RULES.
 01 WS-M                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG VALUE 0.
 01 WS-VY                  FLOAT-LONG VALUE 0.
 01 WS-VZ                  FLOAT-LONG VALUE 0.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-DELAY               BINARY-LONG.
 01 WS-ITEM-ROW            BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     COMPUTE WS-M = EN-TYPE(L-ROW) - MOB-FIRST-TYPE + 1
     MOVE EN-DIM(L-ROW) TO WS-DIM
     MOVE EN-X(L-ROW) TO WS-X
     MOVE EN-Y(L-ROW) TO WS-Y
     MOVE EN-Z(L-ROW) TO WS-Z
     MOVE MB-YIELD-ITEM(WS-M) TO WS-ITEM
     MOVE MB-YIELD-COUNT(WS-M) TO WS-COUNT
     MOVE RULE-GI-BREAK-DELAY TO WS-DELAY
     CALL "ENTITY-REMOVE" USING L-ROW
     CALL "GI-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-ITEM WS-COUNT
         WS-DELAY WS-ITEM-ROW
     GOBACK.
 END PROGRAM MOB-DEFEAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-SPAWN-RULE.
*> USING dimension row, spawn rule row (MOBS.cpy MS-ENTRY), column x, column z, top (BINARY-LONG:
*> the column and the y of its highest non-void block), r (BINARY-DOUBLE, the §12.4 hash): §12.4
*> steps 4 to 6 for the rule that matched the dimension and the time of day.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BLOCKS.
 COPY DIMENSIONS.
 COPY MOBS.
 COPY CHUNKMEM.
 01 WS-STATE               BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CHUNK               BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-SY                  FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-NEAR                FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-Q                   BINARY-DOUBLE.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 COPY COREAPI.
 01 L-DIM                  BINARY-LONG.
 01 L-RULE                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-R                    BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-DIM L-RULE L-X L-Z L-TOP L-R.
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
*>   4. The ground block and the block light at top + 1.
     IF MS-GROUND(L-RULE) >= 0
         CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-TOP L-Z WS-STATE
         IF SB-BLOCK(WS-STATE + 1) NOT = MS-GROUND(L-RULE)
             GOBACK
         END-IF
     END-IF
     COMPUTE WS-Y = L-TOP + 1
     IF MS-LIGHT(L-RULE) >= 0
         COMPUTE WS-CX = (L-X - FUNCTION MOD(L-X, 16)) / 16
         COMPUTE WS-CZ = (L-Z - FUNCTION MOD(L-Z, 16)) / 16
         CALL "WORLD-CHUNK" USING L-DIM WS-CX WS-CZ WS-CHUNK
         SET ADDRESS OF CM-CHUNK TO CK-ADDR(WS-CHUNK)
         IF CM-BLOCK((WS-Y - DM-MIN-Y(L-DIM)) * 256 + (L-Z - WS-CZ * 16) * 16 + L-X - WS-CX * 16 + 1)
                 > MS-LIGHT(L-RULE)
             GOBACK
         END-IF
     END-IF
*>   5. The hostile-mobs setting, the dimension's cap of the type, players near the position.
     MOVE MS-TYPE(L-RULE) TO WS-TYPE
     COMPUTE WS-M = WS-TYPE - MOB-FIRST-TYPE + 1
     IF MB-KIND(WS-M) = MOB-HOSTILE AND CS-HOSTILE-MOBS NOT = 1
         GOBACK
     END-IF
     MOVE 0 TO WS-N
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = WS-TYPE AND EN-DIM(WS-E) = L-DIM
             COMPUTE WS-CX = FUNCTION INTEGER(EN-X(WS-E) / 16)
             COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(WS-E) / 16)
             CALL "WORLD-FIND" USING L-DIM WS-CX WS-CZ WS-CHUNK
             IF WS-CHUNK > 0
                 ADD 1 TO WS-N
             END-IF
         END-IF
     END-PERFORM
     IF WS-N >= MB-CAP(WS-M)
         GOBACK
     END-IF
     COMPUTE WS-X = L-X + 0.5
     MOVE WS-Y TO WS-SY
     COMPUTE WS-Z = L-Z + 0.5
     COMPUTE WS-NEAR = (MOB-SPAWN-NEAR-MILLI / 1000) ** 2
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ROW(WS-P) > 0 AND PL-DIM(WS-P) = L-DIM
                 AND (PL-X(WS-P) - WS-X) ** 2 + (PL-Y(WS-P) - WS-SY) ** 2
                     + (PL-Z(WS-P) - WS-Z) ** 2 <= WS-NEAR
             GOBACK
         END-IF
     END-PERFORM
*>   6. One mob of the type, yaw ((r div 1681) mod 8) x 45.
     COMPUTE WS-Q = L-R / (MOB-SPAWN-SPREAD * MOB-SPAWN-SPREAD)
     COMPUTE WS-YAW = FUNCTION MOD(WS-Q, MOB-YAW-DIRECTIONS) * MOB-YAW-STEP
     CALL "MOB-SPAWN" USING L-DIM WS-TYPE WS-X WS-SY WS-Z WS-YAW WS-ROW
     GOBACK.
 END PROGRAM MOB-SPAWN-RULE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-SPAWN-TRY.
*> USING dimension row, player row (BINARY-LONG): §12.4 steps 1 to 3 for one alive player, then the
*> first spawn rule of the dimension whose time matches (MOB-SPAWN-RULE).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY MOBS.
 01 WS-COUNT               BINARY-LONG VALUE 4.
 01 WS-ARGS.
    05 WS-ARG              BINARY-DOUBLE OCCURS 16 TIMES.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-Q                   BINARY-DOUBLE.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CHUNK               BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-NIGHT               BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-PLAYER.
*>   1. and 2. The column offset.
     COMPUTE WS-ARG(1) = L-DIM - 1
     COMPUTE WS-ARG(2) = FUNCTION INTEGER(PL-X(L-PLAYER))
     COMPUTE WS-ARG(3) = FUNCTION INTEGER(PL-Z(L-PLAYER))
     MOVE CW-TIME TO WS-ARG(4)
     CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
     COMPUTE WS-DX = FUNCTION MOD(WS-R, MOB-SPAWN-SPREAD) - MOB-SPAWN-OFFSET
     COMPUTE WS-Q = WS-R / MOB-SPAWN-SPREAD
     COMPUTE WS-DZ = FUNCTION MOD(WS-Q, MOB-SPAWN-SPREAD) - MOB-SPAWN-OFFSET
     IF FUNCTION ABS(WS-DX) < MOB-SPAWN-MIN AND FUNCTION ABS(WS-DZ) < MOB-SPAWN-MIN
         GOBACK
     END-IF
*>   3. A loaded column with two void cells above its highest block, inside the height range.
     COMPUTE WS-X = WS-ARG(2) + WS-DX
     COMPUTE WS-Z = WS-ARG(3) + WS-DZ
     COMPUTE WS-CX = (WS-X - FUNCTION MOD(WS-X, 16)) / 16
     COMPUTE WS-CZ = (WS-Z - FUNCTION MOD(WS-Z, 16)) / 16
     CALL "WORLD-FIND" USING L-DIM WS-CX WS-CZ WS-CHUNK
     IF WS-CHUNK = 0
         GOBACK
     END-IF
     COMPUTE WS-TOP = DM-MIN-Y(L-DIM) + DM-HEIGHT(L-DIM) - 1
     MOVE 0 TO WS-STATE
     PERFORM UNTIL WS-STATE NOT = 0 OR WS-TOP < DM-MIN-Y(L-DIM)
         CALL "WORLD-GET-BLOCK" USING L-DIM WS-X WS-TOP WS-Z WS-STATE
         IF WS-STATE = 0
             SUBTRACT 1 FROM WS-TOP
         END-IF
     END-PERFORM
     IF WS-TOP + 2 >= DM-MIN-Y(L-DIM) + DM-HEIGHT(L-DIM)
         GOBACK
     END-IF
*>   4. to 6. The first rule of the dimension for the time of day (§4.8 night).
     MOVE 0 TO WS-NIGHT
     IF CW-TIME >= MOB-NIGHT-START AND CW-TIME < MOB-NIGHT-END
         MOVE 1 TO WS-NIGHT
     END-IF
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > MOB-SPAWN-RULE-COUNT OR WS-DONE = 1
         IF MS-DIM(WS-I) = L-DIM AND (MS-TIME(WS-I) = MOB-TIME-ANY
                 OR (MS-TIME(WS-I) = MOB-TIME-DAY AND WS-NIGHT = 0)
                 OR (MS-TIME(WS-I) = MOB-TIME-NIGHT AND WS-NIGHT = 1))
             MOVE 1 TO WS-DONE
             CALL "MOB-SPAWN-RULE" USING L-DIM WS-I WS-X WS-Z WS-TOP WS-R
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MOB-SPAWN-TRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOBS-SPAWN-TICK.
*> No parameters; step 5 of standin §9.5. On ticks with Time mod 100 = 0, for each enabled dimension
*> in order, each alive player in it in entering order (PL-ENTERED) tries one spawn
*> (MOB-SPAWN-TRY).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY MOBS.
 01 WS-D                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-SHIFT               PIC 9.
 01 WS-ORDERS.
    05 WS-ORDER            BINARY-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION.
     IF FUNCTION MOD(CW-TIME, MOB-SPAWN-TICKS) NOT = 0
         GOBACK
     END-IF
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > CW-DIM-COUNT
         MOVE CW-DIM(WS-D) TO WS-DIM
         MOVE 0 TO WS-N
         PERFORM VARYING WS-PLAYER FROM 1 BY 1 UNTIL WS-PLAYER > CORE-MAX-PLAYERS
             IF PL-USED(WS-PLAYER) = 1 AND PL-STATE(WS-PLAYER) = PS-ALIVE
                     AND PL-DIM(WS-PLAYER) = WS-DIM
                 ADD 1 TO WS-N
                 MOVE WS-N TO WS-I
                 MOVE 1 TO WS-SHIFT
                 PERFORM UNTIL WS-SHIFT = 0
                     MOVE 0 TO WS-SHIFT
                     IF WS-I > 1
                         COMPUTE WS-J = WS-I - 1
                         IF PL-ENTERED(WS-ORDER(WS-J)) > PL-ENTERED(WS-PLAYER)
                             MOVE WS-ORDER(WS-J) TO WS-ORDER(WS-I)
                             MOVE WS-J TO WS-I
                             MOVE 1 TO WS-SHIFT
                         END-IF
                     END-IF
                 END-PERFORM
                 MOVE WS-PLAYER TO WS-ORDER(WS-I)
             END-IF
         END-PERFORM
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
             CALL "MOB-SPAWN-TRY" USING WS-DIM WS-ORDER(WS-I)
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM MOBS-SPAWN-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-YAW-TOWARD.
*> USING dx, dz (FLOAT-LONG, a horizontal direction), yaw (FLOAT-SHORT, in: the current yaw, out:
*> the yaw facing that direction): yaw = atan2(-dx, dz) in degrees (protocol yaw: 0 faces +Z, 90
*> faces -X), computed as 2 x atan(-dx / (sqrt(dx^2 + dz^2) + dz)), which is 180 when the direction
*> is exactly -Z; a zero direction leaves the yaw.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DEN                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DX                   FLOAT-LONG.
 01 L-DZ                   FLOAT-LONG.
 01 L-YAW                  FLOAT-SHORT.
 PROCEDURE DIVISION USING L-DX L-DZ L-YAW.
     COMPUTE WS-DEN = FUNCTION SQRT(L-DX * L-DX + L-DZ * L-DZ) + L-DZ
     EVALUATE TRUE
         WHEN WS-DEN NOT = 0
             COMPUTE L-YAW = 2 * FUNCTION ATAN(- L-DX / WS-DEN) * 180 / FUNCTION PI
         WHEN L-DZ < 0
             MOVE 180 TO L-YAW
     END-EVALUATE
     GOBACK.
 END PROGRAM MOB-YAW-TOWARD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-TARGET.
*> USING tracker row (BINARY-LONG) of a hostile mob: its target (§12.3 Target). A target is dropped
*> when that player is gone (left, or its row now holds another player), is not alive, is not in
*> survival, is in another dimension or is farther than the give-up range. Without a target the
*> mob takes the nearest alive survival player of its dimension within the notice range (3D
*> distance between positions; ties: the earliest-entering player, PL-ENTERED).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY MOBS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-BEST-D2             FLOAT-LONG.
 01 WS-LIMIT               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE L-ROW TO WS-ROW
     COMPUTE WS-M = EN-TYPE(WS-ROW) - MOB-FIRST-TYPE + 1
     MOVE EN-TARGET(WS-ROW) TO WS-P
     IF WS-P > 0
         COMPUTE WS-LIMIT = (MB-GIVE-UP-MILLI(WS-M) / 1000) ** 2
         COMPUTE WS-D2 = (PL-X(WS-P) - EN-X(WS-ROW)) ** 2 + (PL-Y(WS-P) - EN-Y(WS-ROW)) ** 2
             + (PL-Z(WS-P) - EN-Z(WS-ROW)) ** 2
         IF PL-USED(WS-P) NOT = 1 OR PL-ENTITY-ID(WS-P) NOT = EN-TARGET-ID(WS-ROW)
                 OR PL-STATE(WS-P) NOT = PS-ALIVE OR PL-MODE(WS-P) NOT = 0
                 OR PL-DIM(WS-P) NOT = EN-DIM(WS-ROW) OR WS-D2 > WS-LIMIT
             MOVE 0 TO EN-TARGET(WS-ROW) EN-TARGET-ID(WS-ROW)
         END-IF
     END-IF
     IF EN-TARGET(WS-ROW) > 0
         GOBACK
     END-IF
     COMPUTE WS-LIMIT = (MB-NOTICE-MILLI(WS-M) / 1000) ** 2
     MOVE 0 TO WS-BEST
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-STATE(WS-P) = PS-ALIVE AND PL-MODE(WS-P) = 0
                 AND PL-DIM(WS-P) = EN-DIM(WS-ROW)
             COMPUTE WS-D2 = (PL-X(WS-P) - EN-X(WS-ROW)) ** 2
                 + (PL-Y(WS-P) - EN-Y(WS-ROW)) ** 2 + (PL-Z(WS-P) - EN-Z(WS-ROW)) ** 2
             IF WS-D2 <= WS-LIMIT AND (WS-BEST = 0 OR WS-D2 < WS-BEST-D2
                     OR (WS-D2 = WS-BEST-D2 AND PL-ENTERED(WS-P) < PL-ENTERED(WS-BEST)))
                 MOVE WS-P TO WS-BEST
                 MOVE WS-D2 TO WS-BEST-D2
             END-IF
         END-IF
     END-PERFORM
     IF WS-BEST > 0
         MOVE WS-BEST TO EN-TARGET(WS-ROW)
         MOVE PL-ENTITY-ID(WS-BEST) TO EN-TARGET-ID(WS-ROW)
     END-IF
     GOBACK.
 END PROGRAM MOB-TARGET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-AI.
*> USING tracker row (BINARY-LONG) of a mob, hx, hz out (FLOAT-LONG, the wanted horizontal velocity),
*> yaw (FLOAT-SHORT, in: the mob's yaw, out: its new yaw): the §12.3 behaviour for one tick.
*> The attack cooldown decreases by 1 (never below 0). A hostile mob updates its target
*> (MOB-TARGET).
*> Pursue (a mob with a target): it faces the target; (hx, hz) = the pursue speed x the unit
*> horizontal vector towards it while the horizontal distance is above 1.0, else (0, 0). Attack:
*> with the target within the attack reach (3D) and the cooldown at 0, the target takes the
*> damage of the mob's attack cause (HEALTH-DAMAGE: RULES.cpy amount and damage type, source = the
*> mob) and the cooldown becomes the type's attack cooldown.
*> Flee (a mob fleeing after a hit, HEALTH-MOB-DAMAGE): for its flee ticks it faces directly away
*> from the attacker's position (followed while that player stays in the dimension; if they share x
*> and z, the current yaw) and moves that way at its flee speed.
*> Wander (otherwise): on ticks with Time mod 80 = 0 the mob decides (r = H(floor(x), floor(y),
*> floor(z), Time)): r mod 3 = 0 stands still, otherwise yaw ((r div 3) mod 8) x 45 and (hx, hz) =
*> (-sin(yaw), cos(yaw)) x the wander speed until the next decision.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY MOBS.
 COPY RULES.
 01 WS-COUNT               BINARY-LONG VALUE 4.
 01 WS-ARGS.
    05 WS-ARG              BINARY-DOUBLE OCCURS 16 TIMES.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-Q                   BINARY-DOUBLE.
 01 WS-M                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-RADIANS             FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-REACH               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-YAW                  FLOAT-SHORT.
 PROCEDURE DIVISION USING L-ROW L-HX L-HZ L-YAW.
     COMPUTE WS-M = EN-TYPE(L-ROW) - MOB-FIRST-TYPE + 1
     IF EN-COOLDOWN(L-ROW) > 0
         SUBTRACT 1 FROM EN-COOLDOWN(L-ROW)
     END-IF
     IF MB-KIND(WS-M) = MOB-HOSTILE
         CALL "MOB-TARGET" USING L-ROW
     END-IF
     IF EN-TARGET(L-ROW) > 0
         MOVE EN-TARGET(L-ROW) TO WS-P
         COMPUTE WS-DX = PL-X(WS-P) - EN-X(L-ROW)
         COMPUTE WS-DY = PL-Y(WS-P) - EN-Y(L-ROW)
         COMPUTE WS-DZ = PL-Z(WS-P) - EN-Z(L-ROW)
         CALL "MOB-YAW-TOWARD" USING WS-DX WS-DZ L-YAW
         COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
         MOVE 0 TO L-HX L-HZ
         IF WS-H > MOB-PURSUE-STOP-MILLI / 1000
             COMPUTE WS-SPEED = MB-PURSUE-MILLI(WS-M) / 1000
             COMPUTE L-HX = WS-SPEED * WS-DX / WS-H
             COMPUTE L-HZ = WS-SPEED * WS-DZ / WS-H
         END-IF
         COMPUTE WS-REACH = MB-REACH-MILLI(WS-M) / 1000
         IF EN-COOLDOWN(L-ROW) = 0
                 AND WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ <= WS-REACH * WS-REACH
             MOVE MB-CAUSE(WS-M) TO WS-CAUSE
             MOVE MB-COOLDOWN(WS-M) TO EN-COOLDOWN(L-ROW)
             CALL "HEALTH-DAMAGE" USING WS-P RULE-CAUSE-AMOUNT(WS-CAUSE) WS-CAUSE EN-ID(L-ROW)
                 WS-NONE
         END-IF
         GOBACK
     END-IF
     IF EN-FLEE(L-ROW) > 0
         SUBTRACT 1 FROM EN-FLEE(L-ROW)
         MOVE EN-FLEE-PLAYER(L-ROW) TO WS-P
         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ID(WS-P) = EN-FLEE-ID(L-ROW)
                 AND PL-DIM(WS-P) = EN-DIM(L-ROW)
             MOVE PL-X(WS-P) TO EN-FLEE-X(L-ROW)
             MOVE PL-Z(WS-P) TO EN-FLEE-Z(L-ROW)
         END-IF
         COMPUTE WS-DX = EN-X(L-ROW) - EN-FLEE-X(L-ROW)
         COMPUTE WS-DZ = EN-Z(L-ROW) - EN-FLEE-Z(L-ROW)
         CALL "MOB-YAW-TOWARD" USING WS-DX WS-DZ L-YAW
         COMPUTE WS-SPEED = MB-FLEE-MILLI(WS-M) / 1000
         COMPUTE WS-RADIANS = L-YAW * FUNCTION PI / 180
         COMPUTE L-HX = - FUNCTION SIN(WS-RADIANS) * WS-SPEED
         COMPUTE L-HZ = FUNCTION COS(WS-RADIANS) * WS-SPEED
         GOBACK
     END-IF
     IF FUNCTION MOD(CW-TIME, MOB-DECIDE-TICKS) = 0
         COMPUTE WS-ARG(1) = FUNCTION INTEGER(EN-X(L-ROW))
         COMPUTE WS-ARG(2) = FUNCTION INTEGER(EN-Y(L-ROW))
         COMPUTE WS-ARG(3) = FUNCTION INTEGER(EN-Z(L-ROW))
         MOVE CW-TIME TO WS-ARG(4)
         CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
         MOVE 0 TO EN-WANDER-X(L-ROW) EN-WANDER-Z(L-ROW)
         IF FUNCTION MOD(WS-R, MOB-STAND-MOD) NOT = 0
             COMPUTE WS-Q = WS-R / MOB-STAND-MOD
             COMPUTE L-YAW = FUNCTION MOD(WS-Q, MOB-YAW-DIRECTIONS) * MOB-YAW-STEP
             COMPUTE WS-SPEED = MB-WANDER-MILLI(WS-M) / 1000
             COMPUTE WS-RADIANS = L-YAW * FUNCTION PI / 180
             COMPUTE EN-WANDER-X(L-ROW) = - FUNCTION SIN(WS-RADIANS) * WS-SPEED
             COMPUTE EN-WANDER-Z(L-ROW) = FUNCTION COS(WS-RADIANS) * WS-SPEED
         END-IF
     END-IF
     MOVE EN-WANDER-X(L-ROW) TO L-HX
     MOVE EN-WANDER-Z(L-ROW) TO L-HZ
     GOBACK.
 END PROGRAM MOB-AI.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-PHYSICS.
*> USING tracker row (BINARY-LONG) of a mob, hx, hz (FLOAT-LONG), yaw (FLOAT-SHORT): §12.2 for one
*> tick. vy <- (vy - 0.05) x 0.96; the move along Y by vy is blocked when the mob's box
*> (ENTITY-BOX-HITS) would overlap a solid cell: y then rests on top of the highest overlapped cell,
*> vy 0, on the ground (vy is never positive: mobs do not jump, so a blocked move is downward);
*> otherwise y moves and the mob is not on the ground. Then the moves along X by hx and along Z by
*> hz: a blocked one is retried, for a mob on the ground, 1 block higher (step-up), else that
*> coordinate stays. When the position or the yaw changed, the viewers are sent the movement
*> (ENTITY-MOVE, pitch 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY MOBS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-NEW                 FLOAT-LONG.
 01 WS-UP                  FLOAT-LONG.
 01 WS-GROUND              BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-YAW                  FLOAT-SHORT.
 PROCEDURE DIVISION USING L-ROW L-HX L-HZ L-YAW.
     MOVE L-ROW TO WS-ROW
     MOVE EN-DIM(WS-ROW) TO WS-DIM
     MOVE EN-TYPE(WS-ROW) TO WS-TYPE
     MOVE EN-X(WS-ROW) TO WS-X
     MOVE EN-Y(WS-ROW) TO WS-Y
     MOVE EN-Z(WS-ROW) TO WS-Z
*>   1. and 2. Gravity, vertical drag, the move along Y.
     COMPUTE WS-VY = (EN-VY(WS-ROW) - MOB-GRAVITY-MILLI / 1000) * MOB-DRAG-MILLI / 1000
     COMPUTE WS-NEW = WS-Y + WS-VY
     CALL "ENTITY-BOX-HITS" USING WS-DIM WS-TYPE WS-X WS-NEW WS-Z WS-HIT WS-TOP
     IF WS-HIT = 0
         MOVE WS-NEW TO WS-Y
         MOVE 0 TO WS-GROUND
     ELSE
         COMPUTE WS-Y = WS-TOP + 1
         MOVE 0 TO WS-VY
         MOVE 1 TO WS-GROUND
     END-IF
*>   3. The moves along X and Z, each with the step-up retry.
     COMPUTE WS-NEW = WS-X + L-HX
     CALL "ENTITY-BOX-HITS" USING WS-DIM WS-TYPE WS-NEW WS-Y WS-Z WS-HIT WS-TOP
     COMPUTE WS-UP = WS-Y + MOB-STEP-UP
     IF WS-HIT = 1 AND WS-GROUND = 1
         CALL "ENTITY-BOX-HITS" USING WS-DIM WS-TYPE WS-NEW WS-UP WS-Z WS-HIT WS-TOP
         IF WS-HIT = 0
             MOVE WS-UP TO WS-Y
         END-IF
     END-IF
     IF WS-HIT = 0
         MOVE WS-NEW TO WS-X
     END-IF
     COMPUTE WS-NEW = WS-Z + L-HZ
     CALL "ENTITY-BOX-HITS" USING WS-DIM WS-TYPE WS-X WS-Y WS-NEW WS-HIT WS-TOP
     COMPUTE WS-UP = WS-Y + MOB-STEP-UP
     IF WS-HIT = 1 AND WS-GROUND = 1
         CALL "ENTITY-BOX-HITS" USING WS-DIM WS-TYPE WS-X WS-UP WS-NEW WS-HIT WS-TOP
         IF WS-HIT = 0
             MOVE WS-UP TO WS-Y
         END-IF
     END-IF
     IF WS-HIT = 0
         MOVE WS-NEW TO WS-Z
     END-IF
     MOVE WS-VY TO EN-VY(WS-ROW)
     IF WS-X NOT = EN-X(WS-ROW) OR WS-Y NOT = EN-Y(WS-ROW) OR WS-Z NOT = EN-Z(WS-ROW)
             OR L-YAW NOT = EN-YAW(WS-ROW)
         CALL "ENTITY-MOVE" USING WS-ROW WS-X WS-Y WS-Z L-YAW WS-PITCH WS-GROUND
     END-IF
     MOVE WS-GROUND TO EN-ON-GROUND(WS-ROW)
     GOBACK.
 END PROGRAM MOB-PHYSICS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-STEP.
*> USING tracker row (BINARY-LONG) of a mob whose chunk is loaded (otherwise nothing happens): step
*> 6 of standin §9.5 for one mob: the hurt cooldown decreases (§10.2), then the AI (MOB-AI) and the
*> physics (MOB-PHYSICS).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CHUNK               BINARY-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE L-ROW TO WS-ROW
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(WS-ROW) / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(WS-ROW) / 16)
     CALL "WORLD-FIND" USING EN-DIM(WS-ROW) WS-CX WS-CZ WS-CHUNK
     IF WS-CHUNK = 0
         GOBACK
     END-IF
     IF EN-HURT(WS-ROW) > 0
         SUBTRACT 1 FROM EN-HURT(WS-ROW)
     END-IF
     MOVE EN-YAW(WS-ROW) TO WS-YAW
     CALL "MOB-AI" USING WS-ROW WS-HX WS-HZ WS-YAW
     CALL "MOB-PHYSICS" USING WS-ROW WS-HX WS-HZ WS-YAW
     GOBACK.
 END PROGRAM MOB-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOBS-TICK.
*> No parameters; step 6 of standin §9.5. While the hostile-mobs setting is off, every hostile mob
*> is removed first (Remove Entities, US9-6, §12.4). Then MOB-STEP for every mob in ascending
*> entity id order (insertion by EN-ID into a list of tracker rows).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY MOBS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-SHIFT               PIC 9.
 01 WS-ORDERS.
    05 WS-ORDER            BINARY-LONG OCCURS 1024 TIMES.
 LINKAGE SECTION.
 COPY COREAPI.
 PROCEDURE DIVISION.
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
     MOVE 0 TO WS-N
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-TYPE(WS-ROW) >= MOB-FIRST-TYPE AND CS-HOSTILE-MOBS NOT = 1
                 AND MB-KIND(EN-TYPE(WS-ROW) - MOB-FIRST-TYPE + 1) = MOB-HOSTILE
             CALL "ENTITY-REMOVE" USING WS-ROW
         END-IF
         IF EN-USED(WS-ROW) = 1 AND EN-TYPE(WS-ROW) >= MOB-FIRST-TYPE
             ADD 1 TO WS-N
             MOVE WS-N TO WS-I
             MOVE 1 TO WS-SHIFT
             PERFORM UNTIL WS-SHIFT = 0
                 MOVE 0 TO WS-SHIFT
                 IF WS-I > 1
                     COMPUTE WS-J = WS-I - 1
                     IF EN-ID(WS-ORDER(WS-J)) > EN-ID(WS-ROW)
                         MOVE WS-ORDER(WS-J) TO WS-ORDER(WS-I)
                         MOVE WS-J TO WS-I
                         MOVE 1 TO WS-SHIFT
                     END-IF
                 END-IF
             END-PERFORM
             MOVE WS-ROW TO WS-ORDER(WS-I)
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         CALL "MOB-STEP" USING WS-ORDER(WS-I)
     END-PERFORM
     GOBACK.
 END PROGRAM MOBS-TICK.
