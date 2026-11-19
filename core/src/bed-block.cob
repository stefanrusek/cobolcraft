*> The two halves of a bed (operator report of try16: a bed item placed only a foot, breaking the foot dropped nothing and left the head, breaking the head left the foot;
*> docs/protocol/24 part 2 section 5 (BedBlock: property part head or foot, facing, occupied; the placement and the survive rule of the Beds row), 29 sections 3.2, 3.3 and
*> 10.4). Vanilla: BedBlock.setPlacedBy places the head half one cell along the facing after the foot; a half whose partner is gone becomes air on its neighbour shape
*> update (the rule 21 of support-29.cob, so the update engine destroys it with its drops: the loot table's part = head condition makes the item drop once, from the head half,
*> whichever half was broken); BedBlock.playerWillDestroy removes the head half of a broken foot at once, without drops and without a shape update, when the player prevents
*> block drops (creative).
*> Entry points:
*>   BED-PART USING state, part out (BINARY-LONG: 0 the block has no part property of foot or head, 1 foot, 2 head), partner dx, dz out (BINARY-LONG: the step from this half to the other)
*>   BED-PLACE-HEAD USING dim, x, y, z (the cell of the foot just placed), state (the foot's state): places the head half after a foot (nothing for another state)
*>   BED-CREATIVE-BREAK USING dim, x, y, z (the cell about to be broken by a creative player), state (its state), player row (excluded from the effect): when it is a foot, its head half is removed first (level
*>     event 2001 for it, flags 35: no drops, no shape update)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BED-PART.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-PART-NAME           PIC X(24) VALUE "part".
 01 WS-FACING-NAME         PIC X(24) VALUE "facing".
 01 WS-TEXT                PIC X(32).
 01 WS-FOUND               BINARY-LONG.
 01 WS-FACING              BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-PART                 BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-PART L-DX L-DZ.
     MOVE 0 TO L-PART L-DX L-DZ
     MOVE SPACES TO WS-TEXT
     CALL "BLOCK-STATE-PROP" USING WS-MODE L-STATE WS-PART-NAME WS-TEXT WS-FOUND
     IF WS-FOUND = 0
         GOBACK
     END-IF
     EVALUATE WS-TEXT
         WHEN "foot"
             MOVE 1 TO L-PART
         WHEN "head"
             MOVE 2 TO L-PART
     END-EVALUATE
*>   The foot's partner lies along the facing, the head's against it.
     MOVE SPACES TO WS-TEXT
     CALL "BLOCK-STATE-PROP" USING WS-MODE L-STATE WS-FACING-NAME WS-TEXT WS-FOUND
     CALL "PS-DIR-OF" USING WS-TEXT WS-FACING
     MOVE WS-FACING TO WS-DIR
     IF L-PART = 2
         CALL "PS-OPP" USING WS-FACING WS-DIR
     END-IF
     CALL "PS-DIR-STEP" USING WS-DIR L-DX WS-DY L-DZ
     GOBACK.
 END PROGRAM BED-PART.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BED-PLACE-HEAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PART                BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-HEAD-X              BINARY-LONG.
 01 WS-HEAD-Z              BINARY-LONG.
 01 WS-HEAD                BINARY-LONG.
 01 WS-PART-NAME           PIC X(24) VALUE "part".
 01 WS-HEAD-TEXT           PIC X(32) VALUE "head".
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE.
     CALL "BED-PART" USING L-STATE WS-PART WS-DX WS-DZ
     IF WS-PART = 1
         COMPUTE WS-HEAD-X = L-X + WS-DX
         COMPUTE WS-HEAD-Z = L-Z + WS-DZ
         MOVE L-STATE TO WS-HEAD
         CALL "PS-PUT" USING WS-HEAD WS-PART-NAME WS-HEAD-TEXT
         CALL "BLOCK-CHANGE" USING L-DIM WS-HEAD-X L-Y WS-HEAD-Z WS-HEAD
     END-IF
     GOBACK.
 END PROGRAM BED-PLACE-HEAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BED-CREATIVE-BREAK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-PART                BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-OTHER-X             BINARY-LONG.
 01 WS-OTHER-Z             BINARY-LONG.
 01 WS-OTHER               BINARY-LONG.
 01 WS-OTHER-PART          BINARY-LONG.
 01 WS-ODX                 BINARY-LONG.
 01 WS-ODZ                 BINARY-LONG.
 01 WS-EVENT               BINARY-LONG VALUE 2001.
 01 WS-FLAGS               BINARY-LONG VALUE 35.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-ROW.
     CALL "BED-PART" USING L-STATE WS-PART WS-DX WS-DZ
     IF WS-PART = 1
         COMPUTE WS-OTHER-X = L-X + WS-DX
         COMPUTE WS-OTHER-Z = L-Z + WS-DZ
         CALL "WORLD-GET-BLOCK" USING L-DIM WS-OTHER-X L-Y WS-OTHER-Z WS-OTHER
         CALL "BED-PART" USING WS-OTHER WS-OTHER-PART WS-ODX WS-ODZ
         IF WS-OTHER-PART = 2 AND CB-S-BLOCK(WS-OTHER + 1) = CB-S-BLOCK(L-STATE + 1)
             CALL "LEVEL-EVENT" USING L-DIM WS-EVENT WS-OTHER-X L-Y WS-OTHER-Z WS-OTHER L-ROW
             CALL "LEVEL-SET-BLOCK" USING L-DIM WS-OTHER-X L-Y WS-OTHER-Z WS-AIR WS-FLAGS WS-BUDGET WS-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BED-CREATIVE-BREAK.
