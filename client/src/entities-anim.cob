*> The animation drivers of the replica (docs/protocol/54 sections 1 and 2): the walk animation state of every living entity, derived each client tick from its
*> position change, the damage event's speed, and the swing of the Swing Animation packet. The models read them in ENTITY-MODEL-EMIT (entities-models.cob).
*> Not tracked (the replica has no feed for them; recorded on the task lines): the passenger state (a passenger would stop), the camel's dash and the frog's
*> jump animation states, the sulfur cube's body item, and the Haste and Mining Fatigue effects of other entities (the swing duration is the packet's).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITIES-ANIM-TICK.
*> USING CLIENT-STATE: one client tick (50 ms) of every replica row of a standard world and of the local player's figure: the walk animation (54 section 1.2 and
*> 1.3: d = the position change since the previous tick, vertical only for the bee and the parrot; WalkAnimationState.update(target, smoothing, scale)) and the
*> swing (12 section 6.4: animation = min(ticks / duration, 1) then ticks + 1, ended once ticks exceed the duration).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLMODELS.
 01 WS-R                   BINARY-LONG.
 01 WS-PAD-L               FLOAT-LONG.
 01 WS-PAD-R               FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-TARGET              FLOAT-LONG.
 01 WS-SMOOTH              FLOAT-LONG.
 01 WS-SCALE               FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-YW                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-WET                 BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-BS                  BINARY-LONG.
 01 WS-BK                  BINARY-LONG.
 01 WS-BL                  BINARY-LONG.
 01 WS-CI.
    05 WS-CIV              FLOAT-LONG OCCURS 16 TIMES.
 01 WS-CO.
    05 WS-COV              FLOAT-LONG OCCURS 64 TIMES.
 01 WS-FX.
    05 WS-FXI              FLOAT-LONG OCCURS 16 TIMES.
 01 WS-FX-SITE             PIC X(24) VALUE "fangs_crit".
 01 WS-FX-DRAWS            BINARY-LONG VALUE 72.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > EN-COUNT
         IF EN-USED(WS-R) = 1 AND EN-VANILLA(WS-R) = 1
             COMPUTE WS-DX = EN-X(WS-R) - EN-OX(WS-R)
             COMPUTE WS-DY = EN-Y(WS-R) - EN-OY(WS-R)
             COMPUTE WS-DZ = EN-Z(WS-R) - EN-OZ(WS-R)
             MOVE WS-DY TO WS-VY
             IF EN-KEY(WS-R) NOT = "bee" AND EN-KEY(WS-R) NOT = "parrot"
                 MOVE 0 TO WS-DY
             END-IF
             COMPUTE WS-D = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
             MOVE 0.4 TO WS-SMOOTH
             MOVE 1 TO WS-SCALE
             IF EN-BABY(WS-R) = 1
                 MOVE 3 TO WS-SCALE
             END-IF
             EVALUATE EN-KEY(WS-R)
                 WHEN "creaking"
                     COMPUTE WS-TARGET = FUNCTION MIN(WS-D * 25, 3)
                     MOVE 1 TO WS-SCALE
                 WHEN "frog"
                     COMPUTE WS-TARGET = FUNCTION MIN(WS-D * 25, 1)
                 WHEN "camel"
                     MOVE 0 TO WS-TARGET
                     MOVE 0.2 TO WS-SMOOTH
                     IF EN-POSE(WS-R) = 0
                         COMPUTE WS-TARGET = FUNCTION MIN(WS-D * 6, 1)
                     END-IF
                 WHEN OTHER
                     COMPUTE WS-TARGET = FUNCTION MIN(WS-D * 4, 1)
             END-EVALUATE
             MOVE EN-WALK-POS(WS-R) TO WS-PAD-L
             MOVE EN-WALK-SPEED(WS-R) TO WS-PAD-R
             MOVE EN-WALK-SPEED(WS-R) TO EN-WALK-SPEED-OLD(WS-R)
             COMPUTE EN-WALK-SPEED(WS-R) = EN-WALK-SPEED(WS-R) + (WS-TARGET - EN-WALK-SPEED(WS-R)) * WS-SMOOTH
             COMPUTE EN-WALK-POS(WS-R) = EN-WALK-POS(WS-R) + EN-WALK-SPEED(WS-R)
             MOVE WS-SCALE TO EN-WALK-SCALE(WS-R)
*>           A boat's paddles (34-8 7.3 tick): a held paddle's position advances pi / 8 each tick, a free one is back at 0 (left in EN-WALK-POS, right in EN-WALK-SPEED).
             IF EN-MODEL(WS-R) > 0
                 IF CL-MD-ANIM(EN-MODEL(WS-R)) = "B"
                     MOVE 0 TO EN-WALK-POS(WS-R) EN-WALK-SPEED(WS-R)
                     IF EN-X1(WS-R) = 1
                         COMPUTE EN-WALK-POS(WS-R) = WS-PAD-L + 0.3926991
                     END-IF
                     IF EN-X2(WS-R) = 1
                         COMPUTE EN-WALK-SPEED(WS-R) = WS-PAD-R + 0.3926991
                     END-IF
                 END-IF
             END-IF
*>           The squish of a slime or magma cube (34-6 7.4 AbstractCubeMob.tick): EF6-CUBE-TICK with the on-ground flag of the last movement packet.
             IF EN-KEY(WS-R) = "slime" OR "magma_cube"
                 MOVE EN-SQ(WS-R) TO WS-CIV(1)
                 MOVE EN-SQ-TGT(WS-R) TO WS-CIV(2)
                 MOVE EN-ON-GROUND(WS-R) TO WS-CIV(3)
                 MOVE EN-WOG(WS-R) TO WS-CIV(4)
                 MOVE 0 TO WS-CIV(5)
                 IF EN-KEY(WS-R) = "magma_cube"
                     MOVE 1 TO WS-CIV(5)
                 END-IF
                 CALL "EF6-CUBE-TICK" USING WS-CI WS-CO
                 MOVE WS-COV(1) TO EN-SQ-OLD(WS-R)
                 MOVE WS-COV(2) TO EN-SQ(WS-R)
                 MOVE WS-COV(3) TO EN-SQ-TGT(WS-R)
                 MOVE WS-COV(4) TO EN-WOG(WS-R)
             END-IF
*>           Evoker fangs (34-3 4.8): lifeTicks fall by 1 a tick once the bite started (EM3-FANGS-TICK; the burst of 12 crit particles when lifeTicks reaches 14: ENTITY-MOB-PARTICLES).
             IF EN-KEY(WS-R) = "evoker_fangs"
                 MOVE EN-FA(WS-R) TO WS-CIV(1)
                 MOVE EN-FL(WS-R) TO WS-CIV(2)
                 CALL "EM3-FANGS-TICK" USING WS-CI WS-CO
                 MOVE WS-COV(1) TO EN-FL(WS-R)
                 IF WS-COV(2) = 1
                     MOVE EN-X(WS-R) TO WS-FXI(1)
                     MOVE EN-Y(WS-R) TO WS-FXI(2)
                     MOVE EN-Z(WS-R) TO WS-FXI(3)
                     MOVE 0.5 TO WS-FXI(4)
                     CALL "ENTITY-MOB-PARTICLES" USING CLIENT-STATE WS-FX-SITE WS-FX WS-FX-DRAWS
                 END-IF
             END-IF
*>           The aquatic mobs: whether the middle of the box is in water (34-8 5: a fish out of water lies on its side).
             IF EN-KEY(WS-R) = "squid" OR "glow_squid" OR "cod" OR "salmon" OR "tropical_fish" OR "pufferfish"
                     OR "guardian" OR "elder_guardian"
                 CALL "ENTITY-IN-WATER" USING CLIENT-STATE WS-R WS-WET
                 COMPUTE EN-DRY(WS-R) = 1 - WS-WET
             END-IF
*>           A turtle's flag is isOnLand (34-5 14: not in water and on the ground).
             IF EN-KEY(WS-R) = "turtle"
                 CALL "ENTITY-IN-WATER" USING CLIENT-STATE WS-R WS-WET
                 MOVE 0 TO EN-DRY(WS-R)
                 IF WS-WET = 0 AND EN-ON-GROUND(WS-R) = 1
                     MOVE 1 TO EN-DRY(WS-R)
                 END-IF
             END-IF
*>           The axolotl's four BinaryAnimators (34-8 4.5, baby and adult).
             IF EN-KEY(WS-R) = "axolotl"
                 CALL "ENTITY-AXOLOTL-TICK" USING CLIENT-STATE WS-R
             END-IF
*>           The iron golem's attack and offer-flower ticks fall by 1 a tick (34-3 7).
             IF EN-KEY(WS-R) = "iron_golem"
                 IF EN-ATK(WS-R) > 0
                     SUBTRACT 1 FROM EN-ATK(WS-R)
                 END-IF
                 IF EN-FLW(WS-R) > 0
                     SUBTRACT 1 FROM EN-FLW(WS-R)
                 END-IF
             END-IF
*>           The ender dragon (34-7 8.1, 8.8): the flap time (no phase or wall data in the replica: not sitting, not in a wall) and one history sample (y, yaw wrapped to
*>           -180 to 180) a tick; a dragon with another id than the history's owner restarts the ring.
             IF EN-KEY(WS-R) = "ender_dragon"
                 IF EN-DR-ID NOT = EN-ID(WS-R)
                     MOVE EN-ID(WS-R) TO EN-DR-ID
                     CALL "EF7-HIST-INIT" USING EN-DR-HIST
                 END-IF
                 IF EN-HP(WS-R) > 0
                     COMPUTE WS-D2 = 0.2 / (FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ) * 10 + 1) * 2 ** WS-VY
                     COMPUTE EN-TM(WS-R) = EN-TM(WS-R) + WS-D2
                     COMPUTE WS-YW = EN-YAW(WS-R) - 360 * FUNCTION INTEGER((EN-YAW(WS-R) + 180) / 360)
                     CALL "EF7-HIST-RECORD" USING EN-DR-HIST EN-Y(WS-R) WS-YW
                     CALL "ENTITY-DRAGON-CRYSTAL" USING CLIENT-STATE WS-R
                 ELSE
*>                   A dying dragon (health 0 or less): dragonDeathTime counts up (to the 200 ticks of the death animation); flapTime, the history and the crystal stay (8.1, 8.8).
                     IF EN-DD(WS-R) < 200
                         ADD 1 TO EN-DD(WS-R)
                     END-IF
                 END-IF
             END-IF
*>           A boat (34-8 7.3): hurt time and damage fall by 1 a tick, the bubble column wobble (the bubble multiplier rises by 0.05 with bubble time and falls by 0.1,
*>           clamped to 0 to 1; angle 10 sin(0.5 age) x multiplier), and whether the boat is under water (water at the cell of the top of the box).
*>           A primed TNT's fuse falls by 1 a tick (34-9 13.2: f = fuse at the partial tick 1).
             IF EN-KEY(WS-R) = "tnt" AND EN-VALUE(WS-R) > 0
                 SUBTRACT 1 FROM EN-VALUE(WS-R)
             END-IF
             IF EN-MODEL(WS-R) > 0
                 IF CL-MD-ANIM(EN-MODEL(WS-R)) = "M"
                     IF EN-BHT(WS-R) > 0
                         SUBTRACT 1 FROM EN-BHT(WS-R)
                     END-IF
                     IF EN-BDM(WS-R) > 0
                         COMPUTE EN-BDM(WS-R) = FUNCTION MAX(EN-BDM(WS-R) - 1, 0)
                     END-IF
                 END-IF
                 IF CL-MD-ANIM(EN-MODEL(WS-R)) = "B"
                     IF EN-BHT(WS-R) > 0
                         SUBTRACT 1 FROM EN-BHT(WS-R)
                     END-IF
                     IF EN-BDM(WS-R) > 0
                         COMPUTE EN-BDM(WS-R) = FUNCTION MAX(EN-BDM(WS-R) - 1, 0)
                     END-IF
                     IF EN-BBT(WS-R) > 0
                         COMPUTE EN-BBM(WS-R) = FUNCTION MIN(EN-BBM(WS-R) + 0.05, 1)
                     ELSE
                         COMPUTE EN-BBM(WS-R) = FUNCTION MAX(EN-BBM(WS-R) - 0.1, 0)
                     END-IF
                     COMPUTE EN-BBA(WS-R) = 10 * FUNCTION SIN(0.5 * EN-AGE(WS-R)) * EN-BBM(WS-R)
                     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(WS-R))
                     COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(WS-R) + EN-BOX-HEIGHT(WS-R))
                     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(WS-R))
                     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
                     CALL "WORLD-CELL" USING CLIENT-STATE WS-BX WS-BY WS-BZ WS-BS WS-BK WS-BL
                     MOVE 0 TO EN-BUW(WS-R)
                     IF ST-FLUID(WS-BS + 1) = 1
                         MOVE 1 TO EN-BUW(WS-R)
                     END-IF
                 END-IF
             END-IF
*>           The guardian (34-6 11.4 Guardian.aiStep on the client): tail speed and tail animation, spikes animation (a pseudo-random float out of water, the draw of
*>           the client's random source is not reproducible), the attack time while a target is active (duration 80, elder 60).
             IF EN-KEY(WS-R) = "guardian" OR "elder_guardian"
                 COMPUTE WS-CIV(1) = 1 - EN-DRY(WS-R)
                 MOVE EN-X1(WS-R) TO WS-CIV(2)
                 MOVE EN-TS(WS-R) TO WS-CIV(3)
                 MOVE EN-TM(WS-R) TO WS-CIV(4)
                 MOVE EN-TA(WS-R) TO WS-CIV(5)
                 COMPUTE WS-CIV(6) = FUNCTION MOD(EN-AGE(WS-R) * 0.61803399 + EN-ID(WS-R) * 0.3819660, 1)
                 CALL "EF6-GUARDIAN-TICK" USING WS-CI WS-CO
                 MOVE WS-COV(2) TO EN-TM(WS-R)
                 MOVE WS-COV(3) TO EN-TS(WS-R)
                 MOVE WS-COV(5) TO EN-TA(WS-R)
                 MOVE EN-RS(WS-R) TO WS-CIV(1)
                 MOVE 0 TO WS-CIV(2)
                 IF EN-TGT(WS-R) NOT = 0
                     MOVE 1 TO WS-CIV(2)
                 END-IF
                 MOVE 80 TO WS-CIV(3)
                 IF EN-KEY(WS-R) = "elder_guardian"
                     MOVE 60 TO WS-CIV(3)
                 END-IF
                 CALL "EF6-GUARDIAN-ATTACK-TICK" USING WS-CI WS-CO
                 MOVE WS-COV(1) TO EN-RS(WS-R)
             END-IF
*>           The squid (34-8 2, Squid.aiStep on the client: steps 2 to 4 with the position change as the delta movement): tentacle movement, angle and rotate speed,
*>           then the body rotations. yBodyRot is the replica's yaw (the server sends it).
             IF EN-KEY(WS-R) = "squid" OR "glow_squid"
                 MOVE EN-TM(WS-R) TO WS-CIV(1)
                 MOVE EN-TS(WS-R) TO WS-CIV(2)
                 COMPUTE WS-CIV(3) = 1 - EN-DRY(WS-R)
                 MOVE EN-RS(WS-R) TO WS-CIV(4)
                 CALL "EF8-SQUID-TENTACLE" USING WS-CI WS-CO
                 MOVE WS-COV(1) TO EN-TM(WS-R)
                 MOVE WS-COV(2) TO EN-TA(WS-R)
                 MOVE WS-COV(3) TO EN-RS(WS-R)
                 COMPUTE WS-CIV(1) = 1 - EN-DRY(WS-R)
                 MOVE EN-RS(WS-R) TO WS-CIV(2)
                 MOVE EN-YAW(WS-R) TO WS-CIV(3)
                 MOVE EN-ZR(WS-R) TO WS-CIV(4)
                 MOVE EN-XR(WS-R) TO WS-CIV(5)
                 MOVE WS-DX TO WS-CIV(6)
                 MOVE WS-VY TO WS-CIV(7)
                 MOVE WS-DZ TO WS-CIV(8)
                 CALL "EF8-SQUID-BODY" USING WS-CI WS-CO
                 MOVE WS-COV(2) TO EN-ZR(WS-R)
                 MOVE WS-COV(3) TO EN-XR(WS-R)
             END-IF
             ADD 1 TO EN-AGE(WS-R)
             MOVE EN-X(WS-R) TO EN-OX(WS-R)
             MOVE EN-Y(WS-R) TO EN-OY(WS-R)
             MOVE EN-Z(WS-R) TO EN-OZ(WS-R)
             IF EN-SW-ACTIVE(WS-R) = 1
                 COMPUTE EN-SW-ANIM(WS-R) = FUNCTION MIN(EN-SW-TICKS(WS-R) / EN-SW-DUR(WS-R), 1)
                 ADD 1 TO EN-SW-TICKS(WS-R)
                 IF EN-SW-TICKS(WS-R) > EN-SW-DUR(WS-R)
                     MOVE 0 TO EN-SW-ACTIVE(WS-R) EN-SW-ANIM(WS-R)
                 END-IF
             END-IF
         END-IF
     END-PERFORM
*>   The local player's figure: the first tick only records where it stands.
     IF PL-ANIM-INIT = 0
         MOVE 1 TO PL-ANIM-INIT
         MOVE PL-X TO PL-ANIM-OX
         MOVE PL-Y TO PL-ANIM-OY
         MOVE PL-Z TO PL-ANIM-OZ
     END-IF
     COMPUTE WS-DX = PL-X - PL-ANIM-OX
     COMPUTE WS-DZ = PL-Z - PL-ANIM-OZ
     COMPUTE WS-D = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
     COMPUTE WS-TARGET = FUNCTION MIN(WS-D * 4, 1)
     COMPUTE PL-ANIM-SPEED = PL-ANIM-SPEED + (WS-TARGET - PL-ANIM-SPEED) * 0.4
     COMPUTE PL-ANIM-POS = PL-ANIM-POS + PL-ANIM-SPEED
     ADD 1 TO PL-ANIM-AGE
     MOVE PL-X TO PL-ANIM-OX
     MOVE PL-Y TO PL-ANIM-OY
     MOVE PL-Z TO PL-ANIM-OZ
     GOBACK.
 END PROGRAM ENTITIES-ANIM-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-AXOLOTL-TICK.
*> USING CLIENT-STATE, replica row of an axolotl (a baby also chooses its animation state): Axolotl.baseTick on the client (34-8 4.5): the exclusive state by priority (playing dead, in water: the cell at the middle of the box holds water,
*> on the ground) and the moving flag (the walk speed above 1.0E-5, or a rotation different from the previous tick's) tick the four animators (EN-AX-T, EN-AX-O: 1 playing dead,
*> 2 in water, 3 on the ground, 4 moving; EF8-BINARY-TICK); the rotation of this tick is kept for the next. Called by ENTITIES-ANIM-TICK after the walk animation.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-WET                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-STATE.
    05 WS-ST               BINARY-LONG OCCURS 4 TIMES.
 01 WS-FLAGS.
    05 WS-FL               BINARY-LONG OCCURS 4 TIMES.
 01 WS-NEW                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW.
     CALL "ENTITY-IN-WATER" USING CLIENT-STATE L-ROW WS-WET
     MOVE EN-AX-PD(L-ROW) TO WS-ST(1)
     MOVE WS-WET TO WS-ST(2)
     MOVE EN-ON-GROUND(L-ROW) TO WS-ST(3)
     MOVE 0 TO WS-ST(4)
     IF EN-WALK-SPEED(L-ROW) > 0.00001 OR EN-PITCH(L-ROW) NOT = EN-AX-XR(L-ROW) OR EN-YAW(L-ROW) NOT = EN-AX-YR(L-ROW)
         MOVE 1 TO WS-ST(4)
     END-IF
     CALL "EF8-AXOLOTL-STATE" USING WS-STATE WS-FLAGS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         CALL "EF8-BINARY-TICK" USING EN-AX-T(L-ROW, WS-I) EN-AX-O(L-ROW, WS-I) WS-FL(WS-I)
     END-PERFORM
*>   A baby has one animation state started with startIfStopped(tickCount) (4.5): playing dead; else moving: in water and off the ground swim, out of water on the ground walk, else
*>   walk underwater; else resting: in water off the ground idle underwater, in water on the ground idle underwater on the ground, else idle on the ground. The tick count is EN-AGE.
     IF EN-BABY(L-ROW) = 1
         EVALUATE TRUE
             WHEN EN-AX-PD(L-ROW) NOT = 0
                 MOVE 7 TO WS-NEW
             WHEN WS-ST(4) NOT = 0 AND WS-WET NOT = 0 AND EN-ON-GROUND(L-ROW) = 0
                 MOVE 1 TO WS-NEW
             WHEN WS-ST(4) NOT = 0 AND WS-WET = 0 AND EN-ON-GROUND(L-ROW) NOT = 0
                 MOVE 2 TO WS-NEW
             WHEN WS-ST(4) NOT = 0
                 MOVE 3 TO WS-NEW
             WHEN WS-WET NOT = 0 AND EN-ON-GROUND(L-ROW) = 0
                 MOVE 4 TO WS-NEW
             WHEN WS-WET NOT = 0
                 MOVE 5 TO WS-NEW
             WHEN OTHER
                 MOVE 6 TO WS-NEW
         END-EVALUATE
         IF WS-NEW NOT = EN-AX-BS(L-ROW)
             MOVE WS-NEW TO EN-AX-BS(L-ROW)
             MOVE EN-AGE(L-ROW) TO EN-AX-BT(L-ROW)
         END-IF
     END-IF
     MOVE EN-PITCH(L-ROW) TO EN-AX-XR(L-ROW)
     MOVE EN-YAW(L-ROW) TO EN-AX-YR(L-ROW)
     GOBACK.
 END PROGRAM ENTITY-AXOLOTL-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-HURT.
*> USING CLIENT-STATE, entity id: the damage event (54 section 1.3) sets the walk speed of the entity to 1.5 (the renderer limits it to 1). An unknown id is ignored.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ID.
     CALL "ENTITY-FIND" USING CLIENT-STATE L-ID WS-ROW
     IF WS-ROW > 0
         MOVE 1.5 TO EN-WALK-SPEED(WS-ROW)
     END-IF
     GOBACK.
 END PROGRAM ENTITY-HURT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-SWING-DURATION.
*> USING base duration, Haste amplifier, Mining Fatigue amplifier (-1 = the effect is absent), duration out (all BINARY-LONG): 54 section 2.1 getModifiedSwingDuration:
*> Haste a gives duration - (1 + a), else Mining Fatigue a gives duration + (1 + a) x 2. The result is at least 1 (a guard: the docs give no lower bound and the
*> animation divides by the duration).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BASE                 BINARY-LONG.
 01 L-HASTE                BINARY-LONG.
 01 L-FATIGUE              BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-BASE L-HASTE L-FATIGUE L-OUT.
     MOVE L-BASE TO L-OUT
     EVALUATE TRUE
         WHEN L-HASTE >= 0
             COMPUTE L-OUT = L-BASE - (1 + L-HASTE)
         WHEN L-FATIGUE >= 0
             COMPUTE L-OUT = L-BASE + (1 + L-FATIGUE) * 2
     END-EVALUATE
     IF L-OUT < 1
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM ENTITY-SWING-DURATION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-SWING-START.
*> USING CLIENT-STATE, replica row, hand (0 main, 1 off), animation type (0 none, 1 whack, 2 stab), duration: SwingState.startIfAble (54 section 2.1): a new swing
*> starts only when none runs, or the running one is more than half over (ticks > duration / 2, integer division), or its ticks are 0 or less. It resets the ticks
*> and, when the (hand, type, duration) triple differs from the running one, the animation value.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NONE                BINARY-LONG VALUE -1.
 01 WS-NONE2               BINARY-LONG VALUE -1.
 01 WS-DUR                 BINARY-LONG.
 01 WS-HALF                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-HAND                 BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-DUR                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-HAND L-TYPE L-DUR.
     CALL "ENTITY-SWING-DURATION" USING L-DUR WS-NONE WS-NONE2 WS-DUR
     DIVIDE EN-SW-DUR(L-ROW) BY 2 GIVING WS-HALF
     IF EN-SW-ACTIVE(L-ROW) = 0 OR EN-SW-TICKS(L-ROW) > WS-HALF OR EN-SW-TICKS(L-ROW) <= 0
         IF EN-SW-HAND(L-ROW) NOT = L-HAND OR EN-SW-TYPE(L-ROW) NOT = L-TYPE OR EN-SW-DUR(L-ROW) NOT = WS-DUR
             MOVE 0 TO EN-SW-ANIM(L-ROW)
         END-IF
         MOVE 0 TO EN-SW-TICKS(L-ROW)
         MOVE 1 TO EN-SW-ACTIVE(L-ROW)
         MOVE L-HAND TO EN-SW-HAND(L-ROW)
         MOVE L-TYPE TO EN-SW-TYPE(L-ROW)
         MOVE WS-DUR TO EN-SW-DUR(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM ENTITY-SWING-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-CUBE-SCALE.
*> USING CLIENT-STATE, replica row of a slime or magma cube, x and z scale out, y scale out (FLOAT-LONG): applySizeAndSquish (34-6 7.4): n = the size (1 until the
*> server sent it), q = squish / (n x 0.5 + 1), r = 1 / (q + 1): scale (r x n, n / r, r x n).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CI.
    05 WS-CIV              FLOAT-LONG OCCURS 16 TIMES.
 01 WS-CO.
    05 WS-COV              FLOAT-LONG OCCURS 64 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-XZ                   FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-XZ L-Y.
     MOVE 1 TO WS-CIV(1)
     IF EN-VAR(L-ROW) > 0
         MOVE EN-VAR(L-ROW) TO WS-CIV(1)
     END-IF
     MOVE EN-SQ(L-ROW) TO WS-CIV(2)
     MOVE 0 TO WS-CIV(3)
     CALL "EF6-CUBE-SCALE" USING WS-CI WS-CO
     MOVE WS-COV(1) TO L-XZ
     MOVE WS-COV(2) TO L-Y
     GOBACK.
 END PROGRAM ENTITY-CUBE-SCALE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-IN-WATER.
*> USING CLIENT-STATE, replica row, in water out (BINARY-LONG 0 or 1): 1 when the block cell at the middle of the entity's box (x, y + height / 2, z) holds water
*> (ST-FLUID 1; a cell of an unloaded chunk is air).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLK                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-WET                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-WET.
     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
     COMPUTE WS-X = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-Y = FUNCTION INTEGER(EN-Y(L-ROW) + EN-BOX-HEIGHT(L-ROW) / 2)
     COMPUTE WS-Z = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE WS-SKY WS-BLK
     MOVE 0 TO L-WET
     IF ST-FLUID(WS-STATE + 1) = 1
         MOVE 1 TO L-WET
     END-IF
     GOBACK.
 END PROGRAM ENTITY-IN-WATER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-EVENT.
*> USING CLIENT-STATE, entity id, event (18 section 9 Entity Event): 19 resets a squid's tentacle movement to 0 ("squid animation sync"), 4 starts the bite of evoker
*> fangs; an iron golem's 4 (attack tick 10), 11 (offer flower 400) and 34 (stop). Another event or an unknown id changes nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-EVENT.
     CALL "ENTITY-FIND" USING CLIENT-STATE L-ID WS-ROW
     IF WS-ROW > 0
         IF L-EVENT = 19
             MOVE 0 TO EN-TM(WS-ROW)
         END-IF
         IF L-EVENT = 4 AND EN-KEY(WS-ROW) = "evoker_fangs"
             MOVE 1 TO EN-FA(WS-ROW)
         END-IF
         IF EN-KEY(WS-ROW) = "iron_golem"
             EVALUATE L-EVENT
                 WHEN 4
                     MOVE 10 TO EN-ATK(WS-ROW)
                 WHEN 11
                     MOVE 400 TO EN-FLW(WS-ROW)
                 WHEN 34
                     MOVE 0 TO EN-FLW(WS-ROW)
                 WHEN OTHER
                     CONTINUE
             END-EVALUATE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM ENTITY-EVENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-FANGS-PROGRESS.
*> USING CLIENT-STATE, replica row of evoker fangs, progress out (FLOAT-LONG): EvokerFangs.getAnimationProgress at partial tick 1 (EM3-FANGS-PROGRESS).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CI.
    05 WS-CIV              FLOAT-LONG OCCURS 16 TIMES.
 01 WS-CO.
    05 WS-COV              FLOAT-LONG OCCURS 64 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-P                    FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-P.
     MOVE EN-FA(L-ROW) TO WS-CIV(1)
     MOVE EN-FL(L-ROW) TO WS-CIV(2)
     MOVE 1 TO WS-CIV(3)
     CALL "EM3-FANGS-PROGRESS" USING WS-CI WS-CO
     MOVE WS-COV(1) TO L-P
     GOBACK.
 END PROGRAM ENTITY-FANGS-PROGRESS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-BOAT-SET.
*> USING CLIENT-STATE, replica row, entry index, serializer, int value, float value: the boat's hurt metadata (21 8.8): entry 8 hurt time and 9 hurt direction (VarInt), 10 damage
*> (FLOAT), 13 bubble time (VarInt) of a row drawn by the boat model (code B). Another entry or another mob changes nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLMODELS.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-SERIALIZER           BINARY-LONG.
 01 L-INT                  BINARY-LONG.
 01 L-FLOAT                FLOAT-SHORT.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-INDEX L-SERIALIZER L-INT L-FLOAT.
     IF EN-MODEL(L-ROW) > 0
         IF CL-MD-ANIM(EN-MODEL(L-ROW)) = "B" OR "M"
             EVALUATE TRUE
                 WHEN L-INDEX = 8 AND L-SERIALIZER = 1
                     MOVE L-INT TO EN-BHT(L-ROW)
                 WHEN L-INDEX = 9 AND L-SERIALIZER = 1
                     MOVE L-INT TO EN-BHD(L-ROW)
                 WHEN L-INDEX = 10 AND L-SERIALIZER = 3
                     MOVE L-FLOAT TO EN-BDM(L-ROW)
                 WHEN L-INDEX = 13 AND L-SERIALIZER = 1
                     MOVE L-INT TO EN-BBT(L-ROW)
                 WHEN OTHER
                     CONTINUE
             END-EVALUATE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM ENTITY-BOAT-SET.

