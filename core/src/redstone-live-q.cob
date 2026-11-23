*> Live redstone, the sulfur cube swallowing of the dispenser (docs/protocol/30-redstone-4 sections 3.1 rule 2 and 4.12, `SulfurCubeBlockDispenseItemBehavior`; task T29574), reached from RL-DISP-MORE for an item of the
*> tag sulfur_cube_swallowable (SULFUR-ARCH-MASK) that nobody wears. For each sulfur cube in the front cell's box, in the order of the entity table, `equipItem(stack)` is tried: false for a baby cube (size 1) and
*> when the stack is the item the cube already has in its BODY slot; otherwise the previous BODY item (if any) is dropped as an item entity at the cube's top (SULFUR-DROP-ITEM), the BODY slot takes one of the item
*> (SULFUR-EQUIP) and the result is true: the dispenser's stack shrinks by 1 and the search stops. With none the item takes the default drop. The box of a cube is 0.49 wide and high per size (STDMOB-SLIME-SPLIT).
*> Not done: the tnt of 4.14, which tries the same swallow first (it is dispensed by RL-DISP-HOOK before these behaviours), the drop-when-killed flag of the new BODY item (SULFUR-DEATH drops it anyway), the entity
*> order of the level (the table order is used), the pickup of dispenser items of a cube that cannot swallow.
*> Entry points:
*>   RL-DISP-SWALLOW USING dim, front x, y, z, item, consumed out      consumed 1 when a cube took the item (the dispenser spends it), else 0

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-DISP-SWALLOW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY P49NSTATE.
 LOCAL-STORAGE SECTION.
 01 LS-I                   BINARY-LONG.
 01 LS-M                   BINARY-LONG.
 01 LS-HALF                FLOAT-LONG.
 01 LS-HEIGHT              FLOAT-LONG.
 01 LS-HIT                 BINARY-LONG.
 01 LS-BABY                BINARY-LONG.
 01 LS-PREVIOUS            BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-CONSUMED             BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-ITEM L-CONSUMED.
     MOVE 0 TO L-CONSUMED
     PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > EN-COUNT OR L-CONSUMED = 1
         IF EN-USED(LS-I) = 1 AND EN-DIM(LS-I) = L-DIM AND EN-HEALTH(LS-I) > 0
             CALL "STDMOB-INDEX" USING EN-TYPE(LS-I) LS-M
             IF LS-M > 0 AND SM-KEY(LS-M) = "sulfur_cube"
                 COMPUTE LS-HALF = 0.245 * EN-VARIANT(LS-I)
                 COMPUTE LS-HEIGHT = 0.49 * EN-VARIANT(LS-I)
                 CALL "RL-BOX-IN-CELL" USING EN-X(LS-I) EN-Y(LS-I) EN-Z(LS-I) LS-HALF LS-HEIGHT L-X L-Y L-Z LS-HIT
                 CALL "SULFUR-BABY" USING LS-I LS-BABY
                 CALL "PN-ROW-OPEN" USING LS-I
                 IF LS-HIT = 1 AND LS-BABY = 0 AND PN-BODY(LS-I) NOT = L-ITEM + 1
                     CALL "SULFUR-EQUIP" USING LS-I L-ITEM LS-PREVIOUS
                     IF LS-PREVIOUS >= 0
                         CALL "SULFUR-DROP-ITEM" USING LS-I LS-PREVIOUS
                     END-IF
                     MOVE 1 TO L-CONSUMED
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RL-DISP-SWALLOW.
