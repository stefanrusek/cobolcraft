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
 01 WS-R                   BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-TARGET              FLOAT-LONG.
 01 WS-SMOOTH              FLOAT-LONG.
 01 WS-SCALE               FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > EN-COUNT
         IF EN-USED(WS-R) = 1 AND EN-VANILLA(WS-R) = 1
             COMPUTE WS-DX = EN-X(WS-R) - EN-OX(WS-R)
             COMPUTE WS-DY = EN-Y(WS-R) - EN-OY(WS-R)
             COMPUTE WS-DZ = EN-Z(WS-R) - EN-OZ(WS-R)
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
             MOVE EN-WALK-SPEED(WS-R) TO EN-WALK-SPEED-OLD(WS-R)
             COMPUTE EN-WALK-SPEED(WS-R) = EN-WALK-SPEED(WS-R) + (WS-TARGET - EN-WALK-SPEED(WS-R)) * WS-SMOOTH
             COMPUTE EN-WALK-POS(WS-R) = EN-WALK-POS(WS-R) + EN-WALK-SPEED(WS-R)
             MOVE WS-SCALE TO EN-WALK-SCALE(WS-R)
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
     MOVE PL-X TO PL-ANIM-OX
     MOVE PL-Y TO PL-ANIM-OY
     MOVE PL-Z TO PL-ANIM-OZ
     GOBACK.
 END PROGRAM ENTITIES-ANIM-TICK.

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
