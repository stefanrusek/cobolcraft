*> Fox hunting (002-lane-mobsa2; docs/protocol/44-residual-mob-questions-4-land-animals.md section 4; 19 section 7).
*> - The flags byte (metadata 19, EN-FOX-FLAGS): 4 crouching, 8 interested, 16 pouncing, 32 sleeping, 64 faceplanted, 128 defending.
*> - StalkPrey: not sleeping, prey farther than squared distance 36 and the fox not crouching and not interested: walk toward it; within 36 the fox stops and is interested and crouching.
*>   At the stop of the goal a clear path keeps both flags, a blocked one clears them.
*> - The crouch amount rises by 0.2 a tick to 5.0 while crouching (EN-FOX-CROUCH counts 0 to 25) and is 0 when not crouching.
*> - FoxPounce needs a fully crouched fox (25 ticks) and a living target: it adds (0.8 x dir.x, 0.9, 0.8 x dir.z) to the motion, dir the normalised vector to the target on all three axes,
*>   sets pouncing and clears interested. It goes on while the target lives and the fox is in the air; the vertical speed and pitch conditions of the doc are not applied (landing ends it).
*> Open items: the pounce goal's test that the target's motion direction equals its facing (the target has no facing here), faceplant, sleeping, shelter, eating berries.
*>
*> Entry points:
*>   M44-FOX-STALK USING row, squared distance, walk out     one tick of the goal
*>   M44-FOX-STALK-STOP USING row, path clear                 the stop of the goal
*>   M44-FOX-CROUCH-TICK USING row                            the crouch counter
*>   M44-FOX-POUNCE USING row, dx, dy, dz, started out        the start of a pounce (the vector from the fox to the target)
*>   M44-FOX-POUNCE-STILL USING row, target alive, continues out

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-FOX-STALK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-Q                   BINARY-LONG.
 01 WS-SLEEP               BINARY-LONG.
 01 WS-CROUCH              BINARY-LONG.
 01 WS-INTEREST            BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-D2                   FLOAT-LONG.
 01 L-WALK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-D2 L-WALK.
     MOVE 0 TO L-WALK
     COMPUTE WS-Q = EN-FOX-FLAGS(L-ROW) / 4
     MOVE FUNCTION MOD(WS-Q, 2) TO WS-CROUCH
     COMPUTE WS-Q = EN-FOX-FLAGS(L-ROW) / 8
     MOVE FUNCTION MOD(WS-Q, 2) TO WS-INTEREST
     COMPUTE WS-Q = EN-FOX-FLAGS(L-ROW) / 32
     MOVE FUNCTION MOD(WS-Q, 2) TO WS-SLEEP
     IF WS-SLEEP = 0 AND WS-CROUCH = 0 AND WS-INTEREST = 0
         IF L-D2 > 36
             MOVE 1 TO L-WALK
         ELSE
             ADD 12 TO EN-FOX-FLAGS(L-ROW)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM M44-FOX-STALK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-FOX-STALK-STOP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-Q                   BINARY-LONG.
 01 WS-BIT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-CLEAR                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-CLEAR.
*>   Both flags are first taken off, then put back when the path is clear.
     COMPUTE WS-Q = EN-FOX-FLAGS(L-ROW) / 4
     MOVE FUNCTION MOD(WS-Q, 2) TO WS-BIT
     IF WS-BIT = 1
         SUBTRACT 4 FROM EN-FOX-FLAGS(L-ROW)
     END-IF
     COMPUTE WS-Q = EN-FOX-FLAGS(L-ROW) / 8
     MOVE FUNCTION MOD(WS-Q, 2) TO WS-BIT
     IF WS-BIT = 1
         SUBTRACT 8 FROM EN-FOX-FLAGS(L-ROW)
     END-IF
     IF L-CLEAR = 1
         ADD 12 TO EN-FOX-FLAGS(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM M44-FOX-STALK-STOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-FOX-CROUCH-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-Q                   BINARY-LONG.
 01 WS-BIT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     COMPUTE WS-Q = EN-FOX-FLAGS(L-ROW) / 4
     MOVE FUNCTION MOD(WS-Q, 2) TO WS-BIT
     IF WS-BIT = 1
         IF EN-FOX-CROUCH(L-ROW) < 25
             ADD 1 TO EN-FOX-CROUCH(L-ROW)
         END-IF
     ELSE
         MOVE 0 TO EN-FOX-CROUCH(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM M44-FOX-CROUCH-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-FOX-POUNCE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-BIT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DX                   FLOAT-LONG.
 01 L-DY                   FLOAT-LONG.
 01 L-DZ                   FLOAT-LONG.
 01 L-STARTED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-DX L-DY L-DZ L-STARTED.
     MOVE 0 TO L-STARTED
     COMPUTE WS-Q = EN-FOX-FLAGS(L-ROW) / 4
     MOVE FUNCTION MOD(WS-Q, 2) TO WS-BIT
     COMPUTE WS-LEN = FUNCTION SQRT(L-DX * L-DX + L-DY * L-DY + L-DZ * L-DZ)
     IF WS-BIT = 1 AND EN-FOX-CROUCH(L-ROW) >= 25 AND WS-LEN > 0
         MOVE 1 TO L-STARTED
         COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) + 0.8 * L-DX / WS-LEN
         COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) + 0.9
         COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) + 0.8 * L-DZ / WS-LEN
         ADD 16 TO EN-FOX-FLAGS(L-ROW)
         COMPUTE WS-Q = EN-FOX-FLAGS(L-ROW) / 8
         MOVE FUNCTION MOD(WS-Q, 2) TO WS-BIT
         IF WS-BIT = 1
             SUBTRACT 8 FROM EN-FOX-FLAGS(L-ROW)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM M44-FOX-POUNCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-FOX-POUNCE-STILL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-Q                   BINARY-LONG.
 01 WS-BIT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ALIVE                BINARY-LONG.
 01 L-CONT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ALIVE L-CONT.
     MOVE 0 TO L-CONT
     IF L-ALIVE = 1 AND EN-ON-GROUND(L-ROW) = 0
         MOVE 1 TO L-CONT
     END-IF
     IF L-CONT = 0
         COMPUTE WS-Q = EN-FOX-FLAGS(L-ROW) / 16
         MOVE FUNCTION MOD(WS-Q, 2) TO WS-BIT
         IF WS-BIT = 1
             SUBTRACT 16 FROM EN-FOX-FLAGS(L-ROW)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM M44-FOX-POUNCE-STILL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-FOX-HUNT.
*> USING row, hx out, hz out, walk out: one tick of the hunt of a chicken or rabbit within 32 blocks (EN-FOE is the prey): the crouch counter, the pounce while it lasts, a pounce
*> when fully crouched, else the stalk (walk 1 with the heading hx, hz at the walk speed 0.3). A pounce that ended releases the stalk (flags off) for this tick; with no prey the flags are off.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(24).
 01 WS-E                   BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 01 WS-BEST-D2             FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-POUNCING            BINARY-LONG.
 01 WS-ALIVE               BINARY-LONG.
 01 WS-CONT                BINARY-LONG.
 01 WS-STARTED             BINARY-LONG.
 01 WS-CLEAR               BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-WALK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HX L-HZ L-WALK.
     MOVE 0 TO L-HX L-HZ L-WALK WS-CLEAR
     CALL "M44-FOX-CROUCH-TICK" USING L-ROW
*>   The prey must still be there.
     MOVE 0 TO WS-ALIVE
     IF EN-FOE(L-ROW) > 0
         IF EN-USED(EN-FOE(L-ROW)) = 1 AND EN-ID(EN-FOE(L-ROW)) = EN-FOE-ID(L-ROW) AND EN-HEALTH(EN-FOE(L-ROW)) > 0
             MOVE 1 TO WS-ALIVE
         ELSE
             MOVE 0 TO EN-FOE(L-ROW) EN-FOE-ID(L-ROW)
         END-IF
     END-IF
     COMPUTE WS-Q = EN-FOX-FLAGS(L-ROW) / 16
     MOVE FUNCTION MOD(WS-Q, 2) TO WS-POUNCING
     IF WS-POUNCING = 1
         CALL "M44-FOX-POUNCE-STILL" USING L-ROW WS-ALIVE WS-CONT
         IF WS-CONT = 1
             GOBACK
         END-IF
         CALL "M44-FOX-STALK-STOP" USING L-ROW WS-CLEAR
         GOBACK
     END-IF
*>   No prey: look for the nearest chicken or rabbit within the follow range 32.
     IF WS-ALIVE = 0
         CALL "M44-FOX-STALK-STOP" USING L-ROW WS-CLEAR
         MOVE 0 TO WS-BEST
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
             IF EN-USED(WS-E) = 1 AND EN-PLAYER(WS-E) = 0 AND EN-DIM(WS-E) = EN-DIM(L-ROW) AND EN-HEALTH(WS-E) > 0
                 CALL "MOB-SPECIES-KEY" USING WS-E WS-KEY
                 IF WS-KEY = "chicken" OR "rabbit"
                     COMPUTE WS-D2 = (EN-X(WS-E) - EN-X(L-ROW)) ** 2 + (EN-Y(WS-E) - EN-Y(L-ROW)) ** 2 + (EN-Z(WS-E) - EN-Z(L-ROW)) ** 2
                     IF WS-D2 <= 1024 AND (WS-BEST = 0 OR WS-D2 < WS-BEST-D2)
                         MOVE WS-E TO WS-BEST
                         MOVE WS-D2 TO WS-BEST-D2
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
         IF WS-BEST = 0
             GOBACK
         END-IF
         MOVE WS-BEST TO EN-FOE(L-ROW)
         MOVE EN-ID(WS-BEST) TO EN-FOE-ID(L-ROW)
     END-IF
     COMPUTE WS-DX = EN-X(EN-FOE(L-ROW)) - EN-X(L-ROW)
     COMPUTE WS-DY = EN-Y(EN-FOE(L-ROW)) - EN-Y(L-ROW)
     COMPUTE WS-DZ = EN-Z(EN-FOE(L-ROW)) - EN-Z(L-ROW)
     CALL "M44-FOX-POUNCE" USING L-ROW WS-DX WS-DY WS-DZ WS-STARTED
     IF WS-STARTED = 1
         GOBACK
     END-IF
     COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
     CALL "M44-FOX-STALK" USING L-ROW WS-D2 L-WALK
     IF L-WALK = 1
         COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
         IF WS-H > 0
             COMPUTE L-HX = WS-DX / WS-H * 0.3
             COMPUTE L-HZ = WS-DZ / WS-H * 0.3
         END-IF
     END-IF
*>   FoxMeleeAttack (44 part 4 section 4): the prey in reach is bitten. The melee goal's own walk (1.2) never starts here: the stalk keeps the fox crouched and still within 6 blocks until the pounce, which
*>   brings it into reach (a gap of the stalk model: the priorities 5 and 6 of the doc hold the MOVE flag).
     CALL "M44-FOX-MELEE" USING L-ROW WS-HIT
     IF EN-HEALTH(EN-FOE(L-ROW)) = 0
         MOVE 0 TO EN-FOE(L-ROW) EN-FOE-ID(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM M44-FOX-HUNT.
