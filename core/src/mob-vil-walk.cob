*> The walk target of a villager brain (docs/protocol/18 section 4.5 memory walk_target, 44 part 3 sections 2.8 and 2.17; lane 002-lane-p49p). A behaviour that wants the villager somewhere puts
*> the memory MT-WALK-TARGET (the block, NUM the speed modifier in thousandths of the base speed 0.5, NUM2 how close is close enough); VL-WALK-TICK, run every tick, turns it into the walk the
*> standard mob step already has (EN-DEST-X, EN-DEST-Y, EN-DEST-Z and EN-COOLDOWN ticks left: STDMOB-HEAD searches a path with STDMOB-PATH and follows it, so the walk is a path walk, not a straight
*> line) and ends it: arriving within the close-enough distance erases the memory and the cant_reach marker; a walk that ran out of time (EN-COOLDOWN 0: no path, or the way was too long)
*> erases the target and leaves MT-CANT-REACH-SINCE, which SetWalkTargetFromBlockMemory reads (give up after 1200 ticks and release the point of interest). The speed modifier is recorded but not
*> applied: every villager walk is at the standard mob speed (gap: the brain's speeds 0.4, 1.1, 1.25 and 1.5 of 19 section 22.3 are not modelled).
*>   VL-WALK-SET USING row, slot, dim, x, y, z, speed (FLOAT-LONG, a multiple of s), close enough     set walk_target and start walking (EN-DEST-*, 200 ticks)
*>   VL-WALK-TICK USING row, slot                                                                    follow or end the walk target
*>   VL-WALK-GY USING row, y (BINARY-LONG in/out)                                                      the y of the walk target of a villager (STDMOB-STEP: the cell the path search aims at)
*>   VL-WALK-STOP USING row, slot                                                                    erase walk_target and stop the walk

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-WALK-SET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VLMEM.
 COPY CORESTATE.
 01 WS-SPEED-MILLI          BINARY-LONG.
 01 WS-NONE                 BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-SLOT                  BINARY-LONG.
 01 L-DIM                   BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 01 L-SPEED                 FLOAT-LONG.
 01 L-CLOSE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-DIM L-X L-Y L-Z L-SPEED L-CLOSE.
     COMPUTE WS-SPEED-MILLI = L-SPEED * 1000
     CALL "VM-PUT" USING L-SLOT MT-WALK-TARGET L-DIM L-X L-Y L-Z WS-SPEED-MILLI L-CLOSE WS-NONE
     MOVE L-X TO EN-DEST-X(L-ROW)
     MOVE L-Y TO EN-DEST-Y(L-ROW)
     MOVE L-Z TO EN-DEST-Z(L-ROW)
     MOVE 200 TO EN-COOLDOWN(L-ROW)
     MOVE 0 TO EN-PATH-TICKS(L-ROW) EN-WAY-X(L-ROW) EN-WAY-Z(L-ROW)
     GOBACK.
 END PROGRAM VL-WALK-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-WALK-STOP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VLMEM.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-SLOT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT.
     CALL "VM-ERASE" USING L-SLOT MT-WALK-TARGET
     MOVE 0 TO EN-COOLDOWN(L-ROW)
     GOBACK.
 END PROGRAM VL-WALK-STOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-WALK-GY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VLMEM.
 COPY CORESTATE.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-NO                   BINARY-LONG VALUE 0.
 01 WS-PRESENT              BINARY-LONG.
 01 WS-DIM                  BINARY-LONG.
 01 WS-X                    BINARY-LONG.
 01 WS-Y                    BINARY-LONG.
 01 WS-Z                    BINARY-LONG.
 01 WS-NUM                  BINARY-LONG.
 01 WS-NUM2                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-Y.
     CALL "VL-FIND" USING EN-ID(L-ROW) WS-NO WS-SLOT
     IF WS-SLOT > 0
         CALL "VM-GET" USING WS-SLOT MT-WALK-TARGET WS-PRESENT WS-DIM WS-X WS-Y WS-Z WS-NUM WS-NUM2
         IF WS-PRESENT = 1
             MOVE WS-Y TO L-Y
         END-IF
     END-IF
     GOBACK.
 END PROGRAM VL-WALK-GY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-WALK-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VLMEM.
 COPY CORESTATE.
 01 WS-PRESENT              BINARY-LONG.
 01 WS-DIM                  BINARY-LONG.
 01 WS-X                    BINARY-LONG.
 01 WS-Y                    BINARY-LONG.
 01 WS-Z                    BINARY-LONG.
 01 WS-SPEED                BINARY-LONG.
 01 WS-CLOSE                BINARY-LONG.
 01 WS-D2                   FLOAT-LONG.
 01 WS-LIMIT                FLOAT-LONG.
 01 WS-HAS                  BINARY-LONG.
 01 WS-NONE                 BINARY-LONG VALUE 0.
 01 WS-NOW                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-SLOT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT.
     CALL "VM-GET" USING L-SLOT MT-WALK-TARGET WS-PRESENT WS-DIM WS-X WS-Y WS-Z WS-SPEED WS-CLOSE
     IF WS-PRESENT = 0
         GOBACK
     END-IF
     CALL "VL-BRAIN-DIST" USING L-ROW WS-X WS-Y WS-Z WS-D2
     MOVE WS-CLOSE TO WS-LIMIT
     IF WS-LIMIT < 1
         MOVE 1 TO WS-LIMIT
     END-IF
     EVALUATE TRUE
         WHEN WS-DIM NOT = EN-DIM(L-ROW)
*>           Another dimension: nothing to walk to.
             CALL "VM-ERASE" USING L-SLOT MT-WALK-TARGET
         WHEN WS-D2 <= WS-LIMIT * WS-LIMIT
*>           Arrived.
             CALL "VM-ERASE" USING L-SLOT MT-WALK-TARGET
             CALL "VM-ERASE" USING L-SLOT MT-CANT-REACH-SINCE
             MOVE 0 TO EN-COOLDOWN(L-ROW)
         WHEN EN-COOLDOWN(L-ROW) = 0
*>           The walk ran out of time: the target could not be reached.
             CALL "VM-ERASE" USING L-SLOT MT-WALK-TARGET
             CALL "VM-HAS" USING L-SLOT MT-CANT-REACH-SINCE WS-HAS
             IF WS-HAS = 0
                 MOVE CW-TICKS TO WS-NOW
                 CALL "VM-PUT" USING L-SLOT MT-CANT-REACH-SINCE WS-DIM WS-X WS-Y WS-Z WS-NOW WS-NONE WS-NONE
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM VL-WALK-TICK.
