*> Frame interpolation (lane bugsmooth; docs/protocol/53 section 7 and 15.2, 12 section 7.2, 34-1 section 4): the world moves in client ticks of 50 ms, a frame is
*> drawn between two ticks, and what is drawn is lerp(partial, the state one tick ago, the state now) with partial the part of the tick the frame is in, so that
*> the movement of the player, of every replica entity and the field of view change in every frame and not 20 times a second. SMOOTH-PARTIAL sets CL-PARTIAL from
*> the tick clock each frame (1 = the tick's own state: CL-INTERP 0, which every client test but the smooth ones runs with); SMOOTH-STORE keeps the state of the
*> player at the start of a tick (PL-O*); SMOOTH-PLAYER gives the player's feet and eye height at the partial tick (CAMERA-PLACE, the own figure); SMOOTH-FOV the field
*> of view modifier; SMOOTH-ENTITIES puts the interpolated position, yaw, pitch and head yaw of every used replica row in place for the frame's meshes (mode 1) and
*> puts the tick's own state back (mode 0). The block target, the movement packets and the physics never see an interpolated value: only the meshes of a frame
*> are built between the two calls. Rotations take the short way round (rotLerp, 34-1 section 4.1).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SMOOTH-PARTIAL.
*> USING CLIENT-STATE: CL-PARTIAL = 1 - (time to the next tick) / 50 ms, clamped to 0 .. 1, when CL-INTERP is 1 (a tick that is overdue, as in a paused
*> world, is 1); 1 otherwise.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 1 TO CL-PARTIAL
     IF CL-INTERP = 1
         COMPUTE CL-PARTIAL = FUNCTION MAX(0, FUNCTION MIN(1, 1 - (CL-NEXT-TICK - CL-NOW-MS) / CL-TICK-MS))
     END-IF
     GOBACK.
 END PROGRAM SMOOTH-PARTIAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SMOOTH-STORE.
*> USING CLIENT-STATE: at the start of a client tick, before the player moves: the position, eye height and field of view modifier of the tick that ends are the
*> state one tick ago (PL-O*). The view bobbing state of 53 section 15.2 moves on here too, as vanilla does at the start of the tick's aiStep: walkDistO and bobO take the
*> old values, and the bob amount eases 0.4 of the way to its target f (0 when the player is in the air, dead or dying, or swimming; else the smaller of 0.1 and the
*> horizontal speed left over from the tick before: the step of that tick after the drag of ordinary ground, 0.546, 53 section 15.2). deathTime counts up while the
*> health is 0 or less, at most to 20, and is 0 while alive (12 section 6.1 step 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE PL-X TO PL-OX
     MOVE PL-Y TO PL-OY
     MOVE PL-Z TO PL-OZ
     MOVE PL-EYE TO PL-OEYE
     MOVE PL-FOV-MOD TO PL-OFOV
     MOVE 1 TO PL-OSET
     MOVE PL-WALK TO PL-WALK-O
     MOVE PL-BOB TO PL-BOB-O
     MOVE 0 TO WS-F
     IF PL-ON-GROUND = 1 AND PL-HEALTH > 0 AND PL-SWIMMING = 0
         COMPUTE WS-F = FUNCTION MIN(0.1, FUNCTION SQRT(PL-MOVE-X * PL-MOVE-X + PL-MOVE-Z * PL-MOVE-Z) * 0.546)
     END-IF
     COMPUTE PL-BOB = PL-BOB + (WS-F - PL-BOB) * 0.4
     IF PL-HEALTH > 0
         MOVE 0 TO PL-DEATH-TIME
     END-IF
     IF PL-HEALTH <= 0 AND PL-DEATH-TIME < 20
         ADD 1 TO PL-DEATH-TIME
     END-IF
     GOBACK.
 END PROGRAM SMOOTH-STORE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SMOOTH-WALK.
*> USING CLIENT-STATE: after the player moved in a client tick (PHYS-TICK): walkDist grows by 0.6 x the horizontal distance the position changed since SMOOTH-STORE
*> (any mode and pose, 53 section 15.2; a position correction between ticks is not walking: SMOOTH-STORE took the position after it).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     COMPUTE WS-DX = PL-X - PL-OX
     COMPUTE WS-DZ = PL-Z - PL-OZ
     COMPUTE PL-WALK = PL-WALK + 0.6 * FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
     GOBACK.
 END PROGRAM SMOOTH-WALK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SMOOTH-PLAYER.
*> USING CLIENT-STATE, x y z (FLOAT-LONG out: the feet at the partial tick), eye height (FLOAT-LONG out: the camera's height above the feet at the partial tick:
*> the smoothed PL-EYE of 53 section 7, the pose's PHYS-EYE while it is not set). With no state one tick ago (PL-OSET 0) these are the current ones.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-EYE                 FLOAT-LONG.
 01 WS-OEYE                FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-EYE                  FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z L-EYE.
     MOVE PL-X TO L-X
     MOVE PL-Y TO L-Y
     MOVE PL-Z TO L-Z
     CALL "PHYS-EYE" USING PL-POSE WS-EYE
     IF PL-EYE > 0
         MOVE PL-EYE TO WS-EYE
     END-IF
     MOVE WS-EYE TO L-EYE
     IF PL-OSET = 1
         MOVE WS-EYE TO WS-OEYE
         IF PL-OEYE > 0
             MOVE PL-OEYE TO WS-OEYE
         END-IF
         COMPUTE L-X = PL-OX + (PL-X - PL-OX) * CL-PARTIAL
         COMPUTE L-Y = PL-OY + (PL-Y - PL-OY) * CL-PARTIAL
         COMPUTE L-Z = PL-OZ + (PL-Z - PL-OZ) * CL-PARTIAL
         COMPUTE L-EYE = WS-OEYE + (WS-EYE - WS-OEYE) * CL-PARTIAL
     END-IF
     GOBACK.
 END PROGRAM SMOOTH-PLAYER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SMOOTH-FOV.
*> USING CLIENT-STATE, modifier (FLOAT-LONG out): the field of view modifier of the frame, lerp(partial, the previous tick's, now) (12 section 7.2); the current one
*> while there is no previous one (PL-OSET 0, or a modifier of 0 = not set yet).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-FOV                  FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-FOV.
     MOVE PL-FOV-MOD TO L-FOV
     IF PL-OSET = 1 AND PL-OFOV > 0 AND PL-FOV-MOD > 0
         COMPUTE L-FOV = PL-OFOV + (PL-FOV-MOD - PL-OFOV) * CL-PARTIAL
     END-IF
     GOBACK.
 END PROGRAM SMOOTH-FOV.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SMOOTH-ENTITIES.
*> USING CLIENT-STATE, mode (BINARY-LONG): 2 = a client tick: the state of every used row now is the state one tick ago (EN-O*; the packets of the tick then move
*> the rows on), 1 = every used row gets position, yaw, pitch and head yaw at the partial tick (the tick's own state is kept aside), 0 = the kept state is put back. Does nothing at partial 1 or with CL-INTERP 0 (mode 1 keeps nothing, so mode 0 puts nothing back).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEPT                BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-SAVE.
    05 WS-ROW              OCCURS 256 TIMES.
       10 WS-SX            FLOAT-LONG.
       10 WS-SY            FLOAT-LONG.
       10 WS-SZ            FLOAT-LONG.
       10 WS-SYAW          FLOAT-SHORT.
       10 WS-SPITCH        FLOAT-SHORT.
       10 WS-SHEAD         FLOAT-SHORT.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-MODE                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-MODE.
     IF L-MODE = 2
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
             IF EN-USED(WS-I) = 1
                 MOVE EN-X(WS-I) TO EN-OX(WS-I)
                 MOVE EN-Y(WS-I) TO EN-OY(WS-I)
                 MOVE EN-Z(WS-I) TO EN-OZ(WS-I)
                 MOVE EN-YAW(WS-I) TO EN-OYAW(WS-I)
                 MOVE EN-PITCH(WS-I) TO EN-OPITCH(WS-I)
                 MOVE EN-HEAD-YAW(WS-I) TO EN-OHEAD(WS-I)
             END-IF
         END-PERFORM
         GOBACK
     END-IF
     IF L-MODE = 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-KEPT
             MOVE WS-SX(WS-I) TO EN-X(WS-I)
             MOVE WS-SY(WS-I) TO EN-Y(WS-I)
             MOVE WS-SZ(WS-I) TO EN-Z(WS-I)
             MOVE WS-SYAW(WS-I) TO EN-YAW(WS-I)
             MOVE WS-SPITCH(WS-I) TO EN-PITCH(WS-I)
             MOVE WS-SHEAD(WS-I) TO EN-HEAD-YAW(WS-I)
         END-PERFORM
         MOVE 0 TO WS-KEPT
         GOBACK
     END-IF
     MOVE 0 TO WS-KEPT
     IF CL-INTERP = 0 OR CL-PARTIAL >= 1
         GOBACK
     END-IF
     MOVE FUNCTION MIN(EN-COUNT, 256) TO WS-KEPT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-KEPT
         MOVE EN-X(WS-I) TO WS-SX(WS-I)
         MOVE EN-Y(WS-I) TO WS-SY(WS-I)
         MOVE EN-Z(WS-I) TO WS-SZ(WS-I)
         MOVE EN-YAW(WS-I) TO WS-SYAW(WS-I)
         MOVE EN-PITCH(WS-I) TO WS-SPITCH(WS-I)
         MOVE EN-HEAD-YAW(WS-I) TO WS-SHEAD(WS-I)
         IF EN-USED(WS-I) = 1
             COMPUTE EN-X(WS-I) = EN-OX(WS-I) + (EN-X(WS-I) - EN-OX(WS-I)) * CL-PARTIAL
             COMPUTE EN-Y(WS-I) = EN-OY(WS-I) + (EN-Y(WS-I) - EN-OY(WS-I)) * CL-PARTIAL
             COMPUTE EN-Z(WS-I) = EN-OZ(WS-I) + (EN-Z(WS-I) - EN-OZ(WS-I)) * CL-PARTIAL
*>           rotLerp(t, a, b) = a + t x wrapDegrees(b - a): the pitch is a plain lerp.
             MOVE EN-OYAW(WS-I) TO WS-A
             MOVE EN-YAW(WS-I) TO WS-B
             COMPUTE WS-D = FUNCTION MOD(WS-B - WS-A + 180, 360) - 180
             COMPUTE EN-YAW(WS-I) = WS-A + WS-D * CL-PARTIAL
             MOVE EN-OHEAD(WS-I) TO WS-A
             MOVE EN-HEAD-YAW(WS-I) TO WS-B
             COMPUTE WS-D = FUNCTION MOD(WS-B - WS-A + 180, 360) - 180
             COMPUTE EN-HEAD-YAW(WS-I) = WS-A + WS-D * CL-PARTIAL
             COMPUTE EN-PITCH(WS-I) = EN-OPITCH(WS-I) + (EN-PITCH(WS-I) - EN-OPITCH(WS-I)) * CL-PARTIAL
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SMOOTH-ENTITIES.
