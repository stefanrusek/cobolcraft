*> The thrown experience bottle (docs/protocol/21 section 8.13; 44-8 sections 6.5 and 10.4; 25-6 section 10.1), lane p49f. A bottle is a tracker row of the standard entity type
*> experience_bottle with a PROJSTATE.cpy entry of PJ-KIND 40 (XB-KIND): gravity 0.07 and the thrown drag 0.99 (THROWN-FLY), a hit of a block or an entity ends it. A player throws it with
*> Use Item (THROWN-ITEM-USE: offset -20 degrees, speed 0.7; the inaccuracy is not modelled, like the other thrown items).
*> On a hit (server): level event 2002 with the colour -13083194 and level event 1053 at the block of the hit; the amount 3 + nextInt(5) + nextInt(5) goes to ExperienceOrb.awardWithDirection
*> at the hit location along the direction (the unit normal of the hit face for a block, else the negative of the bottle's velocity); the bottle is gone.
*> Approximations: the hit location of a block is the last free sample of the flight (at most 0.1 block before the face), the item stack metadata (8) is not sent (the client draws the default item),
*> a silent bottle does not exist.
*>
*> Entry points:
*>   XP-BOTTLE-AMOUNT USING amount out                      3 + nextInt(5) + nextInt(5)
*>   XP-BOTTLE-NORMAL USING row, nx, ny, nz out (FLOAT-LONG)   the unit normal of the face a bottle that just stopped at a block hit (from its position and velocity)
*>   XP-BOTTLE-HIT USING row, hit (1 block, 2 entity)        the hit: events, award, removal
*>   XP-BOTTLE-STEP USING row                               one tick

 IDENTIFICATION DIVISION.
 PROGRAM-ID. XP-BOTTLE-AMOUNT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SALT                BINARY-LONG VALUE 213.
 01 WS-BOUND               BINARY-LONG VALUE 5.
 01 WS-R1                  BINARY-LONG.
 01 WS-R2                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-AMOUNT               BINARY-LONG.
 PROCEDURE DIVISION USING L-AMOUNT.
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R1
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R2
     COMPUTE L-AMOUNT = 3 + WS-R1 + WS-R2
     GOBACK.
 END PROGRAM XP-BOTTLE-AMOUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. XP-BOTTLE-NORMAL.
*> The flight of THROWN-FLY2 walks the new velocity in steps of at most 0.1 block and stops at the last free sample P, so the solid sample is P + v / steps. The face crossed first on the way from
*> P to it (the axis whose cell boundary comes at the smallest fraction) gives the normal, pointing against the movement on that axis; with no crossed axis the normal is the reverse of the velocity.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-STEPS               BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-C0                  BINARY-LONG.
 01 WS-C1                  BINARY-LONG.
 01 WS-BEST                FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-EDGE                FLOAT-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-SIGN                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-NX                   FLOAT-LONG.
 01 L-NY                   FLOAT-LONG.
 01 L-NZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-NX L-NY L-NZ.
     MOVE 0 TO L-NX L-NY L-NZ WS-AXIS
     COMPUTE WS-SPEED = FUNCTION SQRT(EN-VX(L-ROW) * EN-VX(L-ROW) + EN-VY(L-ROW) * EN-VY(L-ROW) + EN-VZ(L-ROW) * EN-VZ(L-ROW))
     IF WS-SPEED = 0
         MOVE 1 TO L-NY
         GOBACK
     END-IF
     COMPUTE WS-STEPS = FUNCTION INTEGER(WS-SPEED / 0.1) + 1
     COMPUTE WS-DX = EN-VX(L-ROW) / WS-STEPS
     COMPUTE WS-DY = EN-VY(L-ROW) / WS-STEPS
     COMPUTE WS-DZ = EN-VZ(L-ROW) / WS-STEPS
     MOVE 2 TO WS-BEST
     COMPUTE WS-C0 = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-C1 = FUNCTION INTEGER(EN-X(L-ROW) + WS-DX)
     IF WS-C0 NOT = WS-C1
         IF WS-DX > 0
             COMPUTE WS-EDGE = WS-C1
         ELSE
             COMPUTE WS-EDGE = WS-C0
         END-IF
         COMPUTE WS-T = (WS-EDGE - EN-X(L-ROW)) / WS-DX
         IF WS-T < WS-BEST
             MOVE WS-T TO WS-BEST
             MOVE 1 TO WS-AXIS
             IF WS-DX > 0
                 MOVE -1 TO WS-SIGN
             ELSE
                 MOVE 1 TO WS-SIGN
             END-IF
         END-IF
     END-IF
     COMPUTE WS-C0 = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-C1 = FUNCTION INTEGER(EN-Y(L-ROW) + WS-DY)
     IF WS-C0 NOT = WS-C1
         IF WS-DY > 0
             COMPUTE WS-EDGE = WS-C1
         ELSE
             COMPUTE WS-EDGE = WS-C0
         END-IF
         COMPUTE WS-T = (WS-EDGE - EN-Y(L-ROW)) / WS-DY
         IF WS-T < WS-BEST
             MOVE WS-T TO WS-BEST
             MOVE 2 TO WS-AXIS
             IF WS-DY > 0
                 MOVE -1 TO WS-SIGN
             ELSE
                 MOVE 1 TO WS-SIGN
             END-IF
         END-IF
     END-IF
     COMPUTE WS-C0 = FUNCTION INTEGER(EN-Z(L-ROW))
     COMPUTE WS-C1 = FUNCTION INTEGER(EN-Z(L-ROW) + WS-DZ)
     IF WS-C0 NOT = WS-C1
         IF WS-DZ > 0
             COMPUTE WS-EDGE = WS-C1
         ELSE
             COMPUTE WS-EDGE = WS-C0
         END-IF
         COMPUTE WS-T = (WS-EDGE - EN-Z(L-ROW)) / WS-DZ
         IF WS-T < WS-BEST
             MOVE WS-T TO WS-BEST
             MOVE 3 TO WS-AXIS
             IF WS-DZ > 0
                 MOVE -1 TO WS-SIGN
             ELSE
                 MOVE 1 TO WS-SIGN
             END-IF
         END-IF
     END-IF
     EVALUATE WS-AXIS
         WHEN 1
             MOVE WS-SIGN TO L-NX
         WHEN 2
             MOVE WS-SIGN TO L-NY
         WHEN 3
             MOVE WS-SIGN TO L-NZ
         WHEN OTHER
             COMPUTE L-NX = 0 - EN-VX(L-ROW) / WS-SPEED
             COMPUTE L-NY = 0 - EN-VY(L-ROW) / WS-SPEED
             COMPUTE L-NZ = 0 - EN-VZ(L-ROW) / WS-SPEED
     END-EVALUATE
     GOBACK.
 END PROGRAM XP-BOTTLE-NORMAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. XP-BOTTLE-HIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-EVENT-SPLASH        BINARY-LONG VALUE 2002.
 01 WS-EVENT-SOUND         BINARY-LONG VALUE 1053.
 01 WS-COLOUR              BINARY-LONG VALUE -13083194.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-NONE2               BINARY-LONG VALUE 0.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-NX                  FLOAT-LONG.
 01 WS-NY                  FLOAT-LONG.
 01 WS-NZ                  FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HIT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HIT.
     IF L-HIT = 1
         CALL "XP-BOTTLE-NORMAL" USING L-ROW WS-NX WS-NY WS-NZ
     ELSE
         COMPUTE WS-NX = 0 - EN-VX(L-ROW)
         COMPUTE WS-NY = 0 - EN-VY(L-ROW)
         COMPUTE WS-NZ = 0 - EN-VZ(L-ROW)
     END-IF
     MOVE EN-X(L-ROW) TO WS-X
     MOVE EN-Y(L-ROW) TO WS-Y
     MOVE EN-Z(L-ROW) TO WS-Z
     MOVE EN-DIM(L-ROW) TO WS-DIM
     COMPUTE WS-CX = FUNCTION INTEGER(WS-X)
     COMPUTE WS-CY = FUNCTION INTEGER(WS-Y)
     COMPUTE WS-CZ = FUNCTION INTEGER(WS-Z)
     CALL "LEVEL-EVENT" USING WS-DIM WS-EVENT-SPLASH WS-CX WS-CY WS-CZ WS-COLOUR WS-NONE
     CALL "LEVEL-EVENT" USING WS-DIM WS-EVENT-SOUND WS-CX WS-CY WS-CZ WS-NONE2 WS-NONE
     CALL "XP-BOTTLE-AMOUNT" USING WS-AMOUNT
     CALL "XP-AWARD-DIR" USING WS-DIM WS-X WS-Y WS-Z WS-AMOUNT WS-NX WS-NY WS-NZ
     CALL "PJ-DROP" USING L-ROW
     GOBACK.
 END PROGRAM XP-BOTTLE-HIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. XP-BOTTLE-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-GRAVITY             FLOAT-LONG VALUE 0.07.
 01 WS-HIT                 BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "THROWN-FLY" USING L-ROW WS-GRAVITY WS-HIT WS-ENTITY WS-PLAYER
     IF WS-HIT > 0
         CALL "XP-BOTTLE-HIT" USING L-ROW WS-HIT
     END-IF
     GOBACK.
 END PROGRAM XP-BOTTLE-STEP.
