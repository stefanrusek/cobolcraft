*> Live redstone, more registered behaviours of the dispenser (docs/protocol/30-redstone-4 section 4), reached from RL-DISP-BEHAVE for an item none of its own rules took: the glowstone (4.17) and the chest
*> (4.3). Glowstone: a respawn anchor in front with fewer than 4 charges takes one (the item is spent, click 1000); with 4 charges nothing happens and the item stays (click 1001); any other block
*> leaves the item to the default drop. Chest: a tamed donkey, mule, llama or trader llama in front (its box overlaps the front cell) with no chest takes the chest item (WC-CHEST of WCSTATE.cpy, saved as ChestedHorse; the
*> viewers get Set Entity Data as for a player's chest, mob-19-3c.cob), the item is spent; with none, the default drop.
*> Not done: the respawn anchor's charge sound (the document names `RespawnAnchorBlock.charge` and no sound), the llama's chest flag is not saved or sent (mob-19-3c.cob handles the donkey and the mule), the 27 slots of the new inventory.
*> The wither skeleton skull and the carved pumpkin (4.7, 4.8) and every item that can be worn (4.9) go to redstone-live-o.cob.
*> Entry points:
*>   RL-DISP-MORE USING dim, front x, y, z, facing, item key (PIC X(48), bare), handled out, consumed out, item    handled 1 when a rule ran (consumed: 1 the item is spent, 0 the dry click 1001); 0 for the default

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-DISP-MORE RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY CITEMS.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY WCSTATE.
 01 WS-CHARGES             PIC X(16) VALUE "charges".
 01 WS-KEEP                PIC X(16) VALUE "keep".
 01 WS-DIGITS              PIC X(5) VALUE "01234".
 LOCAL-STORAGE SECTION.
 01 LS-STATE               BINARY-LONG.
 01 LS-BLOCK               BINARY-LONG.
 01 LS-BKEY                PIC X(48).
 01 LS-BBARE               PIC X(48).
 01 LS-OLD                 PIC X(16).
 01 LS-NEW                 BINARY-LONG.
 01 LS-NEXT                PIC X(16).
 01 LS-N                   BINARY-LONG.
 01 LS-FLAGS               BINARY-LONG VALUE 3.
 01 LS-BUDGET              BINARY-LONG VALUE 512.
 01 LS-RESULT              BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-M                   BINARY-LONG.
 01 LS-HALF-W              FLOAT-LONG.
 01 LS-HEIGHT              FLOAT-LONG.
 01 LS-XLO                FLOAT-LONG.
 01 LS-XHI                 FLOAT-LONG.
 01 LS-ZLO                 FLOAT-LONG.
 01 LS-ZHI                 FLOAT-LONG.
 01 LS-YHI                 FLOAT-LONG.
 01 LS-CX1                 FLOAT-LONG.
 01 LS-CY1                 FLOAT-LONG.
 01 LS-CZ1                 FLOAT-LONG.
 01 LS-OVERLAP             BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-BARE                 PIC X(48).
 01 L-HANDLED              BINARY-LONG.
 01 L-CONSUMED             BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-FACING L-BARE L-HANDLED L-CONSUMED L-ITEM.
     MOVE 0 TO L-HANDLED L-CONSUMED
     EVALUATE TRUE
         WHEN L-BARE = "glowstone"
*>           4.17: a respawn anchor takes one charge unless it has 4 (the property `charges` is the only one of the block that is a number 0 to 4)
             CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z LS-STATE
             MOVE CB-S-BLOCK(LS-STATE + 1) TO LS-BLOCK
             MOVE CB-KEY(LS-BLOCK + 1) TO LS-BKEY
             CALL "KEY-BARE" USING LS-BKEY LS-BBARE
             IF LS-BBARE = "respawn_anchor"
                 MOVE 1 TO L-HANDLED
                 CALL "SW-SET-PROP" USING LS-STATE WS-CHARGES WS-KEEP LS-NEW LS-OLD
                 IF LS-OLD NOT = "4"
                     COMPUTE LS-N = FUNCTION NUMVAL(LS-OLD) + 1
                     MOVE SPACES TO LS-NEXT
                     MOVE WS-DIGITS(LS-N + 1:1) TO LS-NEXT(1:1)
                     CALL "SW-SET-PROP" USING LS-STATE WS-CHARGES LS-NEXT LS-NEW LS-OLD
                     CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-NEW LS-FLAGS LS-BUDGET LS-RESULT
                     MOVE 1 TO L-CONSUMED
                 END-IF
             END-IF
         WHEN L-BARE = "chest"
*>           4.3: the first tamed chested animal without a chest whose box overlaps the front cell takes it
             PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > EN-COUNT OR L-HANDLED = 1
                 IF EN-USED(LS-I) = 1 AND EN-DIM(LS-I) = L-DIM AND EN-HEALTH(LS-I) > 0 AND EN-TAMED(LS-I) = 1
                     CALL "STDMOB-INDEX" USING EN-TYPE(LS-I) LS-M
                     IF LS-M > 0
                         IF SM-KEY(LS-M) = "donkey" OR "mule" OR "llama" OR "trader_llama"
                             CALL "WC-ROW-OPEN" USING LS-I
                         END-IF
                         IF (SM-KEY(LS-M) = "donkey" OR "mule" OR "llama" OR "trader_llama") AND WC-CHEST(LS-I) = 0
                             COMPUTE LS-HALF-W = ET-WIDTH-MILLI(EN-TYPE(LS-I) + 1) / 2000
                             COMPUTE LS-HEIGHT = ET-HEIGHT-MILLI(EN-TYPE(LS-I) + 1) / 1000
*>                           the box of the animal against the cell: it must overlap it on all three axes
                             MOVE 1 TO LS-OVERLAP
                             COMPUTE LS-XLO = EN-X(LS-I) - LS-HALF-W
                             COMPUTE LS-XHI = EN-X(LS-I) + LS-HALF-W
                             COMPUTE LS-ZLO = EN-Z(LS-I) - LS-HALF-W
                             COMPUTE LS-ZHI = EN-Z(LS-I) + LS-HALF-W
                             COMPUTE LS-YHI = EN-Y(LS-I) + LS-HEIGHT
                             COMPUTE LS-CX1 = L-X + 1
                             COMPUTE LS-CY1 = L-Y + 1
                             COMPUTE LS-CZ1 = L-Z + 1
                             IF LS-XLO >= LS-CX1 OR LS-XHI <= L-X OR LS-ZLO >= LS-CZ1 OR LS-ZHI <= L-Z
                                     OR EN-Y(LS-I) >= LS-CY1 OR LS-YHI <= L-Y
                                 MOVE 0 TO LS-OVERLAP
                             END-IF
                             IF LS-OVERLAP = 1
                                 MOVE 1 TO WC-CHEST(LS-I)
                                 CALL "MOB-DATA-SEND" USING LS-I
                                 MOVE 1 TO L-HANDLED L-CONSUMED
                             END-IF
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
         WHEN L-BARE = "wither_skeleton_skull" OR L-BARE = "carved_pumpkin"
*>           4.7 and 4.8: placed where a pattern is complete, else worn (redstone-live-o.cob)
             CALL "RL-DISP-HEAD" USING L-DIM L-X L-Y L-Z L-FACING L-BARE L-ITEM L-HANDLED L-CONSUMED
         WHEN OTHER
*>           4.9, the default rule of an item with the equippable component: worn by an armor stand or a player in front, else the default drop
             CALL "RL-DISP-EQUIP" USING L-DIM L-X L-Y L-Z L-ITEM L-CONSUMED
             MOVE L-CONSUMED TO L-HANDLED
     END-EVALUATE
     GOBACK.
 END PROGRAM RL-DISP-MORE.
