*> Live redstone, the crafter block (docs/protocol/30-redstone-4 section 6, 31-block-entities-2 section 7): a crafter that receives a redstone pulse crafts the recipe its nine slots show, 4 ticks later.
*> neighborChanged (6.2): powered (hasNeighborSignal at the crafter itself, no quasi-connectivity) and not `triggered`: the tick is scheduled in 4 and `triggered` is written (flags 2) with the
*> block entity's; not powered and `triggered`: `triggered` and `crafting` are written false. A crafter placed with `triggered` already set schedules the same tick (setPlacedBy).
*> dispenseFrom (6.3): the 3x3 grid of the slots is matched against the crafting recipes (CRAFT-MATCH-X, all the serializers of the crafting bench); no recipe, or a result that is empty: level event 1050
*> and nothing else. Otherwise the block entity counts 6 ticks of crafting, `crafting` is written true (flags 2), the result is output (6.4) and every non-empty slot shrinks by 1 (BE2-CRAFTER-CRAFT).
*> Output (6.4): the container in front (HOPPER-CONTAINER: a chest, a double chest, a hopper, a furnace, a crafter ...) takes the items one at a time through the face that looks back at the crafter (the
*> two container paths of 6.4 move the same items: a whole stack is a run of single items for every container this core has); what it does not take is dropped as one item entity of the whole rest
*> 0.7 in front of the crafter (DefaultDispenseItemBehavior.spawnItem, accuracy 6) with level events 1049 and 2010 (the data of 2010 is the front). When the container took everything, nothing
*> else happens: no event, no drop. The ticker (31-2 7.3): 6 ticks after the craft `crafting` is written false (flags 3).
*> Deviations: the crafting remainder of an ingredient (a bucket, a bottle: `recipe.getRemainingItems`) is not made, as the crafting bench makes none (no item of the content tables has one); the advancement
*> trigger crafter_recipe_crafted of 6.4 step 4 is not sent (the advancement tree has no such trigger); `onCraftedBySystem` of the result does nothing here.
*> Entry points:
*>   RL-CRAFTER-HOOK USING kind, dimension row, x, y, z, state, old state    kinds 1 (onPlace), 3 (neighborChanged) and 7 (the scheduled tick: dispenseFrom) of a crafter (class 35)
*>   RL-CRAFTER-OUT USING dimension row, x, y, z, front, item, count, patch handle    dispenseItem (6.4) of one stack
*>   RL-CRAFTER-TICK USING block entity index    the ticker of 31-2 7.3, called once per game tick by RL-CONTAINER-TICK for a crafter

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-CRAFTER-OUT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-FACE                BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-REST                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-EVENT               BINARY-LONG.
 01 WS-DATA                BINARY-LONG.
 01 WS-EXCLUDED            BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FRONT                BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-FRONT L-ITEM L-COUNT L-VAR.
     CALL "RS1-STEP" USING L-FRONT WS-DX WS-DY WS-DZ
     COMPUTE WS-FX = L-X + WS-DX
     COMPUTE WS-FY = L-Y + WS-DY
     COMPUTE WS-FZ = L-Z + WS-DZ
     MOVE L-COUNT TO WS-REST
     CALL "HOPPER-CONTAINER" USING L-DIM WS-FX WS-FY WS-FZ WS-INDEX WS-SIZE
     IF WS-INDEX > 0
*>       the face of the container that looks back at the crafter (front.getOpposite(): 0 down, 1 up, 2 a side)
         EVALUATE L-FRONT
             WHEN 0
                 MOVE 1 TO WS-FACE
             WHEN 1
                 MOVE 0 TO WS-FACE
             WHEN OTHER
                 MOVE 2 TO WS-FACE
         END-EVALUATE
         MOVE 0 TO WS-LEFT
         PERFORM UNTIL WS-REST = 0 OR WS-LEFT = 1
             CALL "HOPPER-ADD-ONE" USING WS-INDEX L-ITEM L-VAR WS-FACE WS-LEFT
             IF WS-LEFT = 0
                 SUBTRACT 1 FROM WS-REST
             END-IF
         END-PERFORM
     END-IF
     IF WS-REST > 0
         CALL "GI-DISPENSE-STACK" USING L-DIM L-X L-Y L-Z L-FRONT L-ITEM WS-REST L-VAR WS-ROW
         MOVE 1049 TO WS-EVENT
         MOVE 0 TO WS-DATA
         CALL "LEVEL-EVENT" USING L-DIM WS-EVENT L-X L-Y L-Z WS-DATA WS-EXCLUDED
         MOVE 2010 TO WS-EVENT
         MOVE L-FRONT TO WS-DATA
         CALL "LEVEL-EVENT" USING L-DIM WS-EVENT L-X L-Y L-Z WS-DATA WS-EXCLUDED
     END-IF
     GOBACK.
 END PROGRAM RL-CRAFTER-OUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-CRAFTER-HOOK RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY BESTATE.
 COPY RSLIVE.
 01 WS-TRIGGERED           PIC X(16) VALUE "triggered".
 01 WS-CRAFTING            PIC X(16) VALUE "crafting".
 01 WS-WIDTH               BINARY-LONG VALUE 3.
 01 WS-HEIGHT              BINARY-LONG VALUE 3.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-DELAY               BINARY-LONG VALUE 4.
 LOCAL-STORAGE SECTION.
 01 LS-SAME                BINARY-LONG.
 01 LS-TRIG                BINARY-LONG.
 01 LS-BLOCK               BINARY-LONG.
 01 LS-TYPE                BINARY-LONG VALUE 1.
 01 LS-PRIO                BINARY-LONG VALUE 0.
 01 LS-RESULT              BINARY-LONG.
 01 LS-INDEX               BINARY-LONG.
 01 LS-ENTITY              BINARY-LONG.
 01 LS-POWERED             BINARY-LONG.
 01 LS-SCHEDULE            BINARY-LONG.
 01 LS-NEW-TRIG            BINARY-LONG.
 01 LS-OFF                 BINARY-LONG.
 01 LS-NEW                 BINARY-LONG.
 01 LS-NEXT                BINARY-LONG.
 01 LS-FLAGS               BINARY-LONG VALUE 2.
 01 LS-BUDGET              BINARY-LONG VALUE 512.
 01 LS-S                   BINARY-LONG.
 01 LS-ITEMS.
    05 LS-ITEM             BINARY-LONG OCCURS 9 TIMES.
 01 LS-VARS.
    05 LS-VAR              BINARY-LONG OCCURS 9 TIMES.
 01 LS-ROW                 BINARY-LONG.
 01 LS-RITEM               BINARY-LONG.
 01 LS-RCOUNT              BINARY-LONG.
 01 LS-RVAR                BINARY-LONG.
 01 LS-EVENT               BINARY-LONG.
 01 LS-FOUND               BINARY-LONG.
 01 LS-EMPTY               BINARY-LONG.
 01 LS-DATA                BINARY-LONG VALUE 0.
 01 LS-EXCLUDED            BINARY-LONG VALUE 0.
 01 LS-CRAFTING            BINARY-LONG.
 01 LS-FRONT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-OLD                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-DIM L-X L-Y L-Z L-STATE L-OLD.
     MOVE CB-S-BLOCK(L-STATE + 1) TO LS-BLOCK
     CALL "RL-GET-BOOL" USING L-STATE WS-TRIGGERED LS-TRIG
     EVALUATE L-KIND
         WHEN 1
*>           setPlacedBy (6.2): a crafter placed already triggered schedules its tick
             CALL "RL-SAME-BLOCK" USING L-STATE L-OLD LS-SAME
             IF LS-SAME = 0 AND LS-TRIG = 1
                 CALL "BT-SCHEDULE" USING L-DIM LS-TYPE LS-BLOCK L-X L-Y L-Z WS-DELAY LS-PRIO LS-RESULT
             END-IF
         WHEN 3
*>           neighborChanged (6.2)
             CALL "BE-FIND" USING L-DIM L-X L-Y L-Z LS-INDEX
             MOVE 0 TO LS-ENTITY
             IF LS-INDEX > 0
                 MOVE 1 TO LS-ENTITY
             END-IF
             CALL "RL-HAS-SIGNAL" USING L-DIM L-X L-Y L-Z LS-POWERED
             CALL "BE2-CRAFTER-NEIGHBOR" USING LS-POWERED LS-TRIG LS-ENTITY LS-SCHEDULE LS-NEW-TRIG LS-OFF
             IF LS-SCHEDULE > 0
                 CALL "BT-SCHEDULE" USING L-DIM LS-TYPE LS-BLOCK L-X L-Y L-Z LS-SCHEDULE LS-PRIO LS-RESULT
             END-IF
             IF LS-NEW-TRIG NOT = LS-TRIG
                 CALL "RL-SET-BOOL" USING L-STATE WS-TRIGGERED LS-NEW-TRIG LS-NEW
                 IF LS-OFF = 1
                     CALL "RL-SET-BOOL" USING LS-NEW WS-CRAFTING WS-ZERO LS-NEXT
                     MOVE LS-NEXT TO LS-NEW
                 END-IF
                 CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-NEW LS-FLAGS LS-BUDGET LS-RESULT
                 MOVE LS-NEW-TRIG TO BE-XI(LS-INDEX, 2)
                 CALL "BE-MARK-CHUNK" USING LS-INDEX
             END-IF
         WHEN 7
*>           dispenseFrom (6.3)
             CALL "BE-FIND" USING L-DIM L-X L-Y L-Z LS-INDEX
             IF LS-INDEX = 0
                 GOBACK
             END-IF
             PERFORM VARYING LS-S FROM 1 BY 1 UNTIL LS-S > 9
                 MOVE 0 TO LS-ITEM(LS-S) LS-VAR(LS-S)
                 IF BE-SLOT-COUNT(LS-INDEX, LS-S) > 0
                     MOVE BE-SLOT-ITEM(LS-INDEX, LS-S) TO LS-ITEM(LS-S)
                     MOVE BE-SLOT-VAR(LS-INDEX, LS-S) TO LS-VAR(LS-S)
                 END-IF
             END-PERFORM
             CALL "CRAFT-MATCH-X" USING WS-WIDTH WS-HEIGHT LS-ITEMS LS-VARS LS-ROW LS-RITEM LS-RCOUNT LS-RVAR
             MOVE 0 TO LS-FOUND LS-EMPTY
             IF LS-ROW > 0
                 MOVE 1 TO LS-FOUND
             END-IF
             IF LS-RITEM = 0 OR LS-RCOUNT = 0
                 MOVE 1 TO LS-EMPTY
             END-IF
             CALL "BE2-CRAFTER-CRAFT" USING LS-INDEX LS-FOUND LS-EMPTY LS-EVENT LS-CRAFTING
             IF LS-EVENT > 0
                 CALL "LEVEL-EVENT" USING L-DIM LS-EVENT L-X L-Y L-Z LS-DATA LS-EXCLUDED
                 GOBACK
             END-IF
             CALL "RL-SET-BOOL" USING L-STATE WS-CRAFTING WS-ONE LS-NEW
             CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-NEW LS-FLAGS LS-BUDGET LS-RESULT
             MOVE RL-S-DIR(L-STATE + 1) TO LS-FRONT
             CALL "RL-CRAFTER-OUT" USING L-DIM L-X L-Y L-Z LS-FRONT LS-RITEM LS-RCOUNT LS-RVAR
     END-EVALUATE
     GOBACK.
 END PROGRAM RL-CRAFTER-HOOK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-CRAFTER-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-CRAFTING            PIC X(16) VALUE "crafting".
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-OFF                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX.
     CALL "BE2-CRAFTER-TICK" USING L-INDEX WS-OFF
     IF WS-OFF = 1
         CALL "WORLD-GET-BLOCK" USING BE-DIM(L-INDEX) BE-X(L-INDEX) BE-Y(L-INDEX) BE-Z(L-INDEX) WS-STATE
         CALL "RL-SET-BOOL" USING WS-STATE WS-CRAFTING WS-ZERO WS-NEW
         CALL "LEVEL-SET-BLOCK" USING BE-DIM(L-INDEX) BE-X(L-INDEX) BE-Y(L-INDEX) BE-Z(L-INDEX) WS-NEW WS-FLAGS WS-BUDGET WS-RESULT
     END-IF
     GOBACK.
 END PROGRAM RL-CRAFTER-TICK.
