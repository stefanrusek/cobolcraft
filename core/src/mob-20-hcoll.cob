*> The horizontal-collision flag of a moving mob and what 20 section 7.1 and section 13.6 do with it (002-lane-p49n; docs/protocol/18 section 3.3, 20 sections 7.1 and 13.6).
*> State: P49NSTATE.cpy.
*>
*>   PN-ROW-OPEN USING tracker row: makes the entry of the row the entity's own (clears a stale one).
*>   PN-HCOLL-SET USING tracker row, hcoll, vy (FLOAT-LONG, in and out): MOB-PHYSICS stores whether its move was blocked horizontally; a mob whose climbing flag is set
*>     (onClimbable) that collided horizontally gets the vertical velocity 0.2 (18 section 3.2 travelInAir step 4).
*>   PN-HCOLL-GET USING tracker row, hcoll out: the flag of the last move (0 for a stale entry).
*>   SPIDER-CLIMB-TICK USING tracker row: Spider.tick (20 section 7.1): the climbing flag follows the horizontal collision; a change is sent as metadata 16.
*>   RAVAGER-LEAVES USING tracker row: Ravager.aiStep (20 section 13.6): with mob griefing on and a horizontal collision, every leaves block in the bounding box inflated by 0.2 is
*>     destroyed with its drops, and the ravager jumps (vertical velocity 0.42) when it destroyed one and stands on the ground.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PN-ROW-OPEN.
*> USING tracker row: the entry of the row belongs to the entity in it (a stale one of an earlier occupant is cleared).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY P49NSTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF PN-ID(L-ROW) NOT = EN-ID(L-ROW)
         INITIALIZE PN-ROW(L-ROW)
         MOVE EN-ID(L-ROW) TO PN-ID(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM PN-ROW-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PN-HCOLL-SET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY P49NSTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HCOLL                BINARY-LONG.
 01 L-VY                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-HCOLL L-VY.
     IF PN-ID(L-ROW) NOT = EN-ID(L-ROW)
         INITIALIZE PN-ROW(L-ROW)
         MOVE EN-ID(L-ROW) TO PN-ID(L-ROW)
     END-IF
     MOVE L-HCOLL TO PN-HCOLL(L-ROW)
     IF L-HCOLL = 1 AND PN-CLIMB(L-ROW) = 1
         MOVE 0.2 TO L-VY
     END-IF
     GOBACK.
 END PROGRAM PN-HCOLL-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PN-HCOLL-GET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY P49NSTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HCOLL                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HCOLL.
     MOVE 0 TO L-HCOLL
     IF PN-ID(L-ROW) = EN-ID(L-ROW)
         MOVE PN-HCOLL(L-ROW) TO L-HCOLL
     END-IF
     GOBACK.
 END PROGRAM PN-HCOLL-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPIDER-CLIMB-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY P49NSTATE.
 01 WS-HCOLL               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PN-HCOLL-GET" USING L-ROW WS-HCOLL
     IF PN-ID(L-ROW) NOT = EN-ID(L-ROW)
         INITIALIZE PN-ROW(L-ROW)
         MOVE EN-ID(L-ROW) TO PN-ID(L-ROW)
     END-IF
     IF PN-CLIMB(L-ROW) NOT = WS-HCOLL
         MOVE WS-HCOLL TO PN-CLIMB(L-ROW)
         CALL "STDMOB-FLAGS-SEND" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM SPIDER-CLIMB-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAVAGER-LEAVES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY CITEMS.
 01 WS-RULE-NAME           PIC X(40) VALUE "mob_griefing".
 01 WS-RULE                BINARY-DOUBLE.
 01 WS-HCOLL               BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-HALF                FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-DROP                BINARY-LONG VALUE 1.
 01 WS-BUDGET              BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-DESTROYED           BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PN-HCOLL-GET" USING L-ROW WS-HCOLL
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
     IF WS-HCOLL = 0 OR WS-RULE = 0
         GOBACK
     END-IF
     COMPUTE WS-TYPE = EN-TYPE(L-ROW) + 1
     COMPUTE WS-HALF = ET-WIDTH-MILLI(WS-TYPE) / 2000 + 0.2
     COMPUTE WS-HEIGHT = ET-HEIGHT-MILLI(WS-TYPE) / 1000 + 0.2
     COMPUTE WS-X0 = FUNCTION INTEGER(EN-X(L-ROW) - WS-HALF)
     COMPUTE WS-X1 = FUNCTION INTEGER(EN-X(L-ROW) + WS-HALF)
     COMPUTE WS-Y0 = FUNCTION INTEGER(EN-Y(L-ROW) - 0.2)
     COMPUTE WS-Y1 = FUNCTION INTEGER(EN-Y(L-ROW) + WS-HEIGHT)
     COMPUTE WS-Z0 = FUNCTION INTEGER(EN-Z(L-ROW) - WS-HALF)
     COMPUTE WS-Z1 = FUNCTION INTEGER(EN-Z(L-ROW) + WS-HALF)
     MOVE 0 TO WS-DESTROYED
     PERFORM VARYING WS-X FROM WS-X0 BY 1 UNTIL WS-X > WS-X1
         PERFORM VARYING WS-Y FROM WS-Y0 BY 1 UNTIL WS-Y > WS-Y1
             PERFORM VARYING WS-Z FROM WS-Z0 BY 1 UNTIL WS-Z > WS-Z1
                 CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-STATE
                 MOVE CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) TO WS-KEY
                 COMPUTE WS-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-KEY))
                 IF WS-STATE NOT = 0 AND WS-LENGTH > 7
                     IF WS-KEY(WS-LENGTH - 6:7) = "_leaves"
                         MOVE 512 TO WS-BUDGET
                         CALL "LEVEL-DESTROY-BLOCK" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-DROP WS-BUDGET WS-RESULT
                         MOVE 1 TO WS-DESTROYED
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     IF WS-DESTROYED = 1 AND EN-ON-GROUND(L-ROW) = 1
         IF EN-VY(L-ROW) < 0.42
             MOVE 0.42 TO EN-VY(L-ROW)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RAVAGER-LEAVES.
