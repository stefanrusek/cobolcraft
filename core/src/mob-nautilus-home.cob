*> The home of a tame nautilus or zombie nautilus (wrap I2 round 5, T24090; docs/protocol/44-residual-mob-questions-7-aquatic.md section 10.4 "Restriction radius", 10.2 step 3, and 44-3 section B
*> for the random position helpers). The home is the saved home_radius and home_pos of the entity (EK-HOME-ON, -RADIUS, -X, -Y, -Z of ENKFIELDS.cpy; ENTITY-KEEP-WRITE saves them).
*>   NAUTILUS-RESTRICT USING row      checkRestriction, each AI step before the brain: while tame and neither leashed nor a vehicle the radius is 32 for an adult with an empty saddle slot and 16
*>                                    otherwise; a home of that radius whose block is closer than radius + 8 to the block of the nautilus stays, else the home becomes the nautilus's block with that radius
*>   NAUTILUS-HOME-CELL USING row, x, y, z (BINARY-LONG block), ok out   RandomStroll.swim's candidate (getPos(mob, 10, 7)) is rejected (ok 0) when the mob is restricted (it has a home and the centre
*>                                    of the home block is closer than radius + 10 + 1 to the mob) and the cell is not within the home (block distance squared below radius squared)
*>   NAUTILUS-HOME-CLEAR USING row    clearHome
*>   NAUTILUS-RIDE-END USING player row, row   doPlayerRide of a tame nautilus (the player does not use secondary use) that ended with no passenger: clearHome

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NAUTILUS-RESTRICT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY ENKEEP.
 01 WS-RADIUS              BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-KEEP                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF EN-TAMED(L-ROW) = 0 OR EN-LEASH(L-ROW) > 0 OR EN-LEASH-KNOT(L-ROW) > 0 OR EN-RIDER(L-ROW) > 0 OR EN-PASS(L-ROW) > 0
         GOBACK
     END-IF
     MOVE 16 TO WS-RADIUS
     IF EN-MOBAGE(L-ROW) >= 0 AND EN-SADDLE(L-ROW) = 0
         MOVE 32 TO WS-RADIUS
     END-IF
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(L-ROW))
     MOVE 0 TO WS-KEEP
     IF EK-HOME-ON(L-ROW) = 1 AND EK-HOME-RADIUS(L-ROW) = WS-RADIUS
         COMPUTE WS-DX = WS-BX - EK-HOME-X(L-ROW)
         COMPUTE WS-DY = WS-BY - EK-HOME-Y(L-ROW)
         COMPUTE WS-DZ = WS-BZ - EK-HOME-Z(L-ROW)
         COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
         COMPUTE WS-LIMIT = (WS-RADIUS + 8) * (WS-RADIUS + 8)
         IF WS-D2 < WS-LIMIT
             MOVE 1 TO WS-KEEP
         END-IF
     END-IF
     IF WS-KEEP = 0
         MOVE 1 TO EK-HOME-ON(L-ROW)
         MOVE WS-RADIUS TO EK-HOME-RADIUS(L-ROW)
         MOVE WS-BX TO EK-HOME-X(L-ROW)
         MOVE WS-BY TO EK-HOME-Y(L-ROW)
         MOVE WS-BZ TO EK-HOME-Z(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM NAUTILUS-RESTRICT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NAUTILUS-HOME-CELL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY ENKEEP.
 01 WS-REACH               BINARY-LONG.
 01 WS-REACH2              BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-C2                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-OK.
     MOVE 1 TO L-OK
     IF EK-HOME-ON(L-ROW) = 0 OR EK-HOME-RADIUS(L-ROW) < 0
         GOBACK
     END-IF
*>   mobRestricted(mob, 10): the centre of the home block is closer than radius + 10 + 1 to the mob's position (strict).
     COMPUTE WS-REACH = EK-HOME-RADIUS(L-ROW) + 11
     COMPUTE WS-REACH2 = WS-REACH * WS-REACH
     COMPUTE WS-DX = EK-HOME-X(L-ROW) + 0.5 - EN-X(L-ROW)
     COMPUTE WS-DY = EK-HOME-Y(L-ROW) + 0.5 - EN-Y(L-ROW)
     COMPUTE WS-DZ = EK-HOME-Z(L-ROW) + 0.5 - EN-Z(L-ROW)
     COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
     IF WS-D2 >= WS-REACH2
         GOBACK
     END-IF
*>   isWithinHome(cell): the block distance squared from the home block is below radius squared.
     COMPUTE WS-CX = L-X - EK-HOME-X(L-ROW)
     COMPUTE WS-CY = L-Y - EK-HOME-Y(L-ROW)
     COMPUTE WS-CZ = L-Z - EK-HOME-Z(L-ROW)
     COMPUTE WS-C2 = WS-CX * WS-CX + WS-CY * WS-CY + WS-CZ * WS-CZ
     IF WS-C2 >= EK-HOME-RADIUS(L-ROW) * EK-HOME-RADIUS(L-ROW)
         MOVE 0 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM NAUTILUS-HOME-CELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NAUTILUS-HOME-CLEAR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY ENKEEP.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE 0 TO EK-HOME-ON(L-ROW)
     GOBACK.
 END PROGRAM NAUTILUS-HOME-CLEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NAUTILUS-RIDE-END.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ROW.
     IF EN-TAMED(L-ROW) = 1 AND PL-SNEAKING(L-PLAYER) = 0 AND EN-RIDER(L-ROW) = 0
         CALL "NAUTILUS-HOME-CLEAR" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM NAUTILUS-RIDE-END.
