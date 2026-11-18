*> Block entities, part 2: processing and redstone containers (docs/protocol/31-block-entities-2-processing-and-redstone-containers.md; US12 phase 44).
*> The model is core/src/be-31-1.cob (CORE-BE of BESTATE.cpy); this file holds what is specific to the types of part 2: their registration table (section 1),
*> the hopper's data (section 5.1, 5.2) and insertItem of the dispenser (section 6.2). The saved keys of hopper, dispenser and dropper are written by
*> BE-SAVE and BE-LOAD, their sizes and names come from BE-CONTAINER-SIZE and BE-DEFAULT-NAME (all of 31-1), their menus are menu-container.cob.
*> The server tick of the furnaces, the brewing stand and the crafter, the hopper's transfers and the dispensing are not here: the first three are
*> later sections of this part, the others belong to Phase 43 (redstone).
*>
*>   BE2-REGISTRATION USING type, container size out (-1 none), default name key out (X(32), length 0 none), name length out, ticker out,
*>        base out                                              section 1. Ticker 0 none, 1 furnace serverTick, 2 brewing stand serverTick, 3 hopper
*>        pushItemsTick, 4 crafter serverTick, 6 supplied by the block (the daylight detector). Base 0 plain BlockEntity, 1 BaseContainerBlockEntity,
*>        2 RandomizableContainerBlockEntity. A type of other parts answers size -1, no name, ticker 0, base 0.
*>   BE2-HOPPER-CONSTANTS USING MOVE_ITEM_SPEED out, suck box out (6 BINARY-LONG in sixteenths: x0, y0, z0, x1, y1, z1)       section 5.1
*>   BE2-HOPPER-COOLDOWN USING cooldown time, on cooldown out, on custom cooldown out                                         section 5.2
*>   BE2-INSERT-ITEM USING index, item, count (in: the stack, out: the remainder), patch handle, item's maximum stack         section 6.2 insertItem

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE2-REGISTRATION.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-SIZE                 BINARY-LONG.
 01 L-NAME                 PIC X(32).
 01 L-NAME-LENGTH          BINARY-LONG.
 01 L-TICKER               BINARY-LONG.
 01 L-BASE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-SIZE L-NAME L-NAME-LENGTH L-TICKER L-BASE.
     MOVE -1 TO L-SIZE
     MOVE 0 TO L-TICKER L-BASE L-NAME-LENGTH
     MOVE SPACES TO L-NAME
     EVALUATE L-TYPE
         WHEN 0 WHEN 27 WHEN 28
             MOVE 1 TO L-TICKER L-BASE
         WHEN 12
             MOVE 2 TO L-TICKER
             MOVE 1 TO L-BASE
         WHEN 18
             MOVE 3 TO L-TICKER
             MOVE 2 TO L-BASE
         WHEN 5 WHEN 6
             MOVE 2 TO L-BASE
         WHEN 42
             MOVE 4 TO L-TICKER
             MOVE 2 TO L-BASE
         WHEN 17
             MOVE 6 TO L-TICKER
     END-EVALUATE
     IF L-TYPE = 0 OR L-TYPE = 5 OR L-TYPE = 6 OR L-TYPE = 12 OR L-TYPE = 18 OR L-TYPE = 27 OR L-TYPE = 28 OR L-TYPE = 38
             OR L-TYPE = 42
         CALL "BE-CONTAINER-SIZE" USING L-TYPE L-SIZE
         CALL "BE-DEFAULT-NAME" USING L-TYPE L-NAME L-NAME-LENGTH
     END-IF
     GOBACK.
 END PROGRAM BE2-REGISTRATION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE2-HOPPER-CONSTANTS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SPEED                BINARY-LONG.
 01 L-BOX.
    05 L-BOX-VALUE         BINARY-LONG OCCURS 6 TIMES.
 PROCEDURE DIVISION USING L-SPEED L-BOX.
     MOVE 8 TO L-SPEED
     MOVE 0 TO L-BOX-VALUE(1) L-BOX-VALUE(3)
     MOVE 11 TO L-BOX-VALUE(2)
     MOVE 16 TO L-BOX-VALUE(4) L-BOX-VALUE(6)
     MOVE 32 TO L-BOX-VALUE(5)
     GOBACK.
 END PROGRAM BE2-HOPPER-CONSTANTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE2-HOPPER-COOLDOWN.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COOLDOWN             BINARY-LONG.
 01 L-ON                   BINARY-LONG.
 01 L-CUSTOM               BINARY-LONG.
 PROCEDURE DIVISION USING L-COOLDOWN L-ON L-CUSTOM.
     MOVE 0 TO L-ON L-CUSTOM
     IF L-COOLDOWN > 0
         MOVE 1 TO L-ON
     END-IF
     IF L-COOLDOWN > 8
         MOVE 1 TO L-CUSTOM
     END-IF
     GOBACK.
 END PROGRAM BE2-HOPPER-COOLDOWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE2-INSERT-ITEM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-S                   BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-ROOM                BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-ITEM L-COUNT L-VAR L-MAX.
     CALL "BE-MAX-STACK" USING L-MAX WS-LIMIT
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 9 OR L-COUNT = 0
         IF BE-SLOT-COUNT(L-INDEX, WS-S) = 0
                 OR (BE-SLOT-ITEM(L-INDEX, WS-S) = L-ITEM AND BE-SLOT-VAR(L-INDEX, WS-S) = L-VAR)
             COMPUTE WS-ROOM = WS-LIMIT - BE-SLOT-COUNT(L-INDEX, WS-S)
             COMPUTE WS-N = FUNCTION MIN(L-COUNT, WS-ROOM)
             IF WS-N > 0
                 MOVE L-ITEM TO BE-SLOT-ITEM(L-INDEX, WS-S)
                 MOVE L-VAR TO BE-SLOT-VAR(L-INDEX, WS-S)
                 ADD WS-N TO BE-SLOT-COUNT(L-INDEX, WS-S)
                 SUBTRACT WS-N FROM L-COUNT
                 CALL "BE-MARK-CHUNK" USING L-INDEX
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BE2-INSERT-ITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE2-DAYLIGHT-POWER.
*> USING effective sky brightness (0 to 15), inverted (1 or 0), sun angle in degrees (FLOAT-LONG), power out (31-2 section 9): s = brightness; inverted:
*> s = 15 - s; otherwise when s > 0: a = angle * 0.017453292, the target is 0 when a < pi and 2 pi otherwise, a = a + (target - a) * 0.2,
*> s = round(s * cos a); clamped to 0 to 15.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   FLOAT-LONG.
 01 WS-TARGET              FLOAT-LONG.
 01 WS-S                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-SKY                  BINARY-LONG.
 01 L-INVERTED             BINARY-LONG.
 01 L-ANGLE                FLOAT-LONG.
 01 L-POWER                BINARY-LONG.
 PROCEDURE DIVISION USING L-SKY L-INVERTED L-ANGLE L-POWER.
     MOVE L-SKY TO WS-S
     IF L-INVERTED = 1
         COMPUTE WS-S = 15 - WS-S
     ELSE
         IF WS-S > 0
             COMPUTE WS-A = L-ANGLE * 0.017453292
             MOVE 0 TO WS-TARGET
             IF WS-A >= 3.1415927
                 MOVE 6.2831855 TO WS-TARGET
             END-IF
             COMPUTE WS-A = WS-A + (WS-TARGET - WS-A) * 0.2
             COMPUTE WS-S ROUNDED = WS-S * FUNCTION COS(WS-A)
         END-IF
     END-IF
     MOVE FUNCTION MAX(0, FUNCTION MIN(15, WS-S)) TO L-POWER
     GOBACK.
 END PROGRAM BE2-DAYLIGHT-POWER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE2-SHELF-MAX.
*> USING maximum stack size out: the chiseled bookshelf entity's override (31-2 section 10.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MAX                  BINARY-LONG.
 PROCEDURE DIVISION USING L-MAX.
     MOVE 1 TO L-MAX
     GOBACK.
 END PROGRAM BE2-SHELF-MAX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE2-SHELF-SLOT.
*> USING face of the click (0 down, 1 up, 2 north, 3 south, 4 west, 5 east), the shelf's facing (0 north, 1 east, 2 south, 3 west), the hit location in
*> the block (x, y, z, FLOAT-LONG, 0 to 1), slot out (-1 none): getHitSlot of 31-2 section 10.3. The face must be the facing; u is 1 - x (north),
*> x (south), z (west), 1 - z (east); row = clamp(floor((1 - y) * 2), 0, 1), column = clamp(floor(u * 3), 0, 2); slot = column + 3 row.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FACE-DIR.
    05 FILLER              PIC X(6) VALUE "540231".
 01 FILLER REDEFINES WS-FACE-DIR.
    05 WS-DIR              PIC 9 OCCURS 6 TIMES.
 01 WS-U                   FLOAT-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-COLUMN              BINARY-LONG.
 LINKAGE SECTION.
 01 L-FACE                 BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-FACE L-FACING L-X L-Y L-Z L-SLOT.
     MOVE -1 TO L-SLOT
     IF L-FACE < 2 OR L-FACE > 5
         GOBACK
     END-IF
     IF WS-DIR(L-FACE + 1) NOT = L-FACING
         GOBACK
     END-IF
     EVALUATE L-FACE
         WHEN 2
             COMPUTE WS-U = 1 - L-X
         WHEN 3
             MOVE L-X TO WS-U
         WHEN 4
             MOVE L-Z TO WS-U
         WHEN OTHER
             COMPUTE WS-U = 1 - L-Z
     END-EVALUATE
     COMPUTE WS-ROW = FUNCTION INTEGER((1 - L-Y) * 2)
     COMPUTE WS-COLUMN = FUNCTION INTEGER(WS-U * 3)
     MOVE FUNCTION MAX(0, FUNCTION MIN(1, WS-ROW)) TO WS-ROW
     MOVE FUNCTION MAX(0, FUNCTION MIN(2, WS-COLUMN)) TO WS-COLUMN
     COMPUTE L-SLOT = WS-COLUMN + 3 * WS-ROW
     GOBACK.
 END PROGRAM BE2-SHELF-SLOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE2-SHELF-SIGNAL.
*> USING index, signal out: lastInteractedSlot + 1 (0 for an untouched shelf).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-SIGNAL.
     COMPUTE L-SIGNAL = BE-COOLDOWN(L-INDEX) + 1
     GOBACK.
 END PROGRAM BE2-SHELF-SIGNAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE2-SHELF-UPDATE.
*> USING index, slot, dim: updateState of 31-2 section 10.2: the last interacted slot is the slot, the occupancy properties follow the six slots
*> and the block state is written (Block Update to the viewers) when it changes; the chunk is marked unsaved.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-FAMILY              BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-MASK                BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-SLOT L-DIM.
     MOVE L-SLOT TO BE-COOLDOWN(L-INDEX)
     CALL "WORLD-GET-BLOCK" USING L-DIM BE-X(L-INDEX) BE-Y(L-INDEX) BE-Z(L-INDEX) WS-STATE
     CALL "BE-STATE-FIELDS" USING WS-STATE WS-FAMILY WS-DIR WS-MASK WS-FLAG
     MOVE 0 TO WS-MASK
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 5
         IF BE-SLOT-COUNT(L-INDEX, WS-I + 1) > 0
             COMPUTE WS-MASK = WS-MASK + 2 ** WS-I
         END-IF
     END-PERFORM
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
     CALL "BE-STATE-MAKE" USING WS-BLOCK WS-DIR WS-MASK WS-FLAG WS-NEW
     IF WS-NEW NOT = WS-STATE
         CALL "BLOCK-CHANGE" USING L-DIM BE-X(L-INDEX) BE-Y(L-INDEX) BE-Z(L-INDEX) WS-NEW
     END-IF
     CALL "BE-MARK-CHUNK" USING L-INDEX
     GOBACK.
 END PROGRAM BE2-SHELF-UPDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE2-SHELF-USE.
*> USING connection id, PLAY-SERVERBOUND (Use Item On), block state, handled out: the use of a chiseled bookshelf (31-2 section 10.3). A book of the
*> item tag bookshelf_books used on a free slot of the face goes in (one is used up unless the player is in creative mode); a book on an occupied
*> slot, or an empty hand or a non-book on one, takes the book out into the inventory (what does not fit is thrown, the inventory is resent);
*> any other click on the block does nothing. handled is 1 for every use of a chiseled bookshelf that has its entity. The insert and pickup
*> sounds, the item_used statistic and the game event are not sent.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY BESTATE.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 8192.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-FAMILY              BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-MASK                BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-BE                  BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-HELD                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-BOOK                BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TAG-REGISTRY        PIC X(48) VALUE "item".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:bookshelf_books".
 01 WS-OLD-STATE           BINARY-LONG.
 01 WS-NEW-STATE           BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND L-STATE L-HANDLED.
     MOVE 0 TO L-HANDLED
     CALL "BE-STATE-FIELDS" USING L-STATE WS-FAMILY WS-DIR WS-MASK WS-FLAG
     IF WS-FAMILY NOT = 7
         GOBACK
     END-IF
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-DIM
     CALL "BE-FIND" USING WS-DIM PSB-BX PSB-BY PSB-BZ WS-BE
     IF WS-BE = 0
         GOBACK
     END-IF
     MOVE 1 TO L-HANDLED
     MOVE PSB-CURSOR-X TO WS-X
     MOVE PSB-CURSOR-Y TO WS-Y
     MOVE PSB-CURSOR-Z TO WS-Z
     CALL "BE2-SHELF-SLOT" USING PSB-FACE WS-DIR WS-X WS-Y WS-Z WS-SLOT
     IF WS-SLOT < 0
         GOBACK
     END-IF
     MOVE PL-HELD(WS-ROW) TO WS-HELD
     MOVE 0 TO WS-BOOK
     IF PL-SLOT-COUNT(WS-ROW, WS-HELD + 1) > 0
         MOVE PL-SLOT-ITEM(WS-ROW, WS-HELD + 1) TO WS-ITEM
         CALL "CONTENT-TAG-HAS" USING WS-TAG-REGISTRY WS-TAG WS-ITEM WS-BOOK
     END-IF
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     IF WS-BOOK = 1 AND PSB-HAND = 0 AND BE-SLOT-COUNT(WS-BE, WS-SLOT + 1) = 0
         MOVE WS-ITEM TO BE-SLOT-ITEM(WS-BE, WS-SLOT + 1)
         MOVE 1 TO BE-SLOT-COUNT(WS-BE, WS-SLOT + 1)
         MOVE PL-SLOT-VAR(WS-ROW, WS-HELD + 1) TO BE-SLOT-VAR(WS-BE, WS-SLOT + 1)
         IF PL-MODE(WS-ROW) NOT = 1
             CALL "INV-REMOVE" USING WS-ROW WS-HELD WS-ONE
             COMPUTE PL-STATE-ID(WS-ROW) = FUNCTION MOD(PL-STATE-ID(WS-ROW) + 1, 32768)
             CALL "INV-SLOT-SEND" USING L-ID WS-HELD
         END-IF
         CALL "BE2-SHELF-UPDATE" USING WS-BE WS-SLOT WS-DIM
         GOBACK
     END-IF
     IF BE-SLOT-COUNT(WS-BE, WS-SLOT + 1) > 0
         MOVE BE-SLOT-ITEM(WS-BE, WS-SLOT + 1) TO WS-ITEM
         MOVE BE-SLOT-VAR(WS-BE, WS-SLOT + 1) TO WS-VAR
         MOVE 0 TO BE-SLOT-ITEM(WS-BE, WS-SLOT + 1) BE-SLOT-COUNT(WS-BE, WS-SLOT + 1) BE-SLOT-VAR(WS-BE, WS-SLOT + 1)
         CALL "MENU-RETURN-STACK-X" USING WS-ROW WS-ITEM WS-ONE WS-VAR
         CALL "BE2-SHELF-UPDATE" USING WS-BE WS-SLOT WS-DIM
         CALL "PB-RESET" USING PB-BUFFER
         CALL "PLAY-CONTENT-BUILD" USING WS-ROW PB-BUFFER
         CALL "CORE-SEND" USING L-ID PB-BUFFER
     END-IF
     GOBACK.
 END PROGRAM BE2-SHELF-USE.

*> Brewing stand (4), crafter (7): BE2-BREW-FACE USING face (0 down, 1 up, 2 side), slot list out (5 BINARY-LONG), count out                      4.1
*>   BE2-BREW-TAKE USING slot, holds a glass bottle, allowed out; BE2-BREW-PLACE USING slot, brewing_fuel, has level, reagent accepted, potion input, slot empty, allowed out
*>   BE2-BREW-LOOKUP USING bottle item, bottle patch handle, reagent item, recipe row out (0 none), result item out, result patch handle out: the first brewing row of RC-STORE (serializer 20:
*>        RR-ING 1 the input item, RR-ING 2 the reagent item, RR-RESULT-ID the output, RR-EXTRA "<input potion> <output potion>") whose items match and whose input potion (when it has one) is the potion_contents
*>        potion of the bottle; the result stack is the output item with its potion_contents potion and no other component                                                                          4.4
*>   BE2-BREW-TICK USING index, the uses of the fuel's brewing_fuel component (0 none), its speed (FLOAT-LONG), brew done out (level event 1035), bottles changed out         4.5, 4.6
*>   BE2-CRAFTER-CAN-DISABLE / -SET-STATE / -DISABLED / -CAN-PLACE / -SET-ITEM / -SIGNAL / -DATA / -TICK / -NEIGHBOR / -CRAFT / -PATH / -DROP          7
*>   BE2-SAVE USING index, type, PB-BUFFER and BE2-LOAD-KEY USING index, name, tag, PB-BUFFER, handled out (BEX-SAVE and BEX-LOAD-KEY of be-31-3.cob); BE2-LOAD-DONE USING index
*> The crafting remainder of the fuel and of the ingredient (4.5 step 1, 4.6 step 2) and the crafting recipe match of a crafter's dispenseFrom are not here.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE2-BREW-FACE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FACE                 BINARY-LONG.
 01 L-LIST.
    05 L-SLOT              BINARY-LONG OCCURS 5 TIMES.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-FACE L-LIST L-COUNT.
     INITIALIZE L-LIST
     EVALUATE L-FACE
         WHEN 1
             MOVE 1 TO L-COUNT
             MOVE 3 TO L-SLOT(1)
         WHEN 0
             MOVE 4 TO L-COUNT
             MOVE 1 TO L-SLOT(2)
             MOVE 2 TO L-SLOT(3)
             MOVE 3 TO L-SLOT(4)
         WHEN OTHER
             MOVE 4 TO L-COUNT
             MOVE 1 TO L-SLOT(2)
             MOVE 2 TO L-SLOT(3)
             MOVE 4 TO L-SLOT(4)
     END-EVALUATE
     GOBACK.
 END PROGRAM BE2-BREW-FACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE2-BREW-TAKE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-GLASS                BINARY-LONG.
 01 L-ALLOWED              BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-GLASS L-ALLOWED.
     MOVE 1 TO L-ALLOWED
     IF L-SLOT = 3 AND L-GLASS = 0
         MOVE 0 TO L-ALLOWED
     END-IF
     GOBACK.
 END PROGRAM BE2-BREW-TAKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE2-BREW-PLACE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-FUEL                 BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-REAGENT              BINARY-LONG.
 01 L-INPUT                BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-ALLOWED              BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-FUEL L-LEVEL L-REAGENT L-INPUT L-EMPTY L-ALLOWED.
     MOVE 0 TO L-ALLOWED
     EVALUATE TRUE
         WHEN L-SLOT = 4
             MOVE L-FUEL TO L-ALLOWED
         WHEN L-LEVEL = 0
             MOVE 0 TO L-ALLOWED
         WHEN L-SLOT = 3
             MOVE L-REAGENT TO L-ALLOWED
         WHEN L-INPUT = 1 AND L-EMPTY = 1
             MOVE 1 TO L-ALLOWED
     END-EVALUATE
     GOBACK.
 END PROGRAM BE2-BREW-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE2-BREW-LOOKUP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CTRECIPE.
 01 WS-ROW                 PIC X(270).
 01 WS-VIEW REDEFINES WS-ROW.
    05 FILLER              PIC X(4).
    05 WS-R-KEY            PIC X(38).
    05 FILLER              PIC X(228).
 01 WS-KEY-A               PIC X(112).
 01 WS-KEY-B               PIC X(112).
 01 WS-TOKEN               PIC X(112).
 01 WS-STATUS              BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-RESULT-ROW          PIC X(270).
 01 WS-IN-POTION           PIC X(32).
 01 WS-OUT-POTION          PIC X(32).
 01 WS-IN-ID               BINARY-LONG.
 01 WS-OUT-ID              BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-COLOR               BINARY-LONG.
 01 WS-CUSTOM              BINARY-LONG.
 01 WS-BOTTLE-POTION       BINARY-LONG.
 01 WS-FITS                BINARY-LONG.
 01 WS-A48                 PIC X(48).
 01 WS-B48                 PIC X(48).
 01 WS-ING48               PIC X(48).
 01 WS-IN-BARE             PIC X(48).
 01 WS-RB48                PIC X(48).
 LINKAGE SECTION.
 01 L-BOTTLE               BINARY-LONG.
 01 L-BVAR                 BINARY-LONG.
 01 L-REAGENT              BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-RVAR                 BINARY-LONG.
 PROCEDURE DIVISION USING L-BOTTLE L-BVAR L-REAGENT L-ROW L-RESULT L-RVAR.
     MOVE 0 TO L-ROW L-RESULT L-RVAR
     CALL "CONTENT-ITEM-BY-ID" USING L-BOTTLE WS-ROW WS-STATUS
     IF WS-STATUS NOT = CT-OK
         GOBACK
     END-IF
     MOVE SPACES TO WS-KEY-A
     MOVE WS-R-KEY TO WS-KEY-A
     CALL "CONTENT-ITEM-BY-ID" USING L-REAGENT WS-ROW WS-STATUS
     IF WS-STATUS NOT = CT-OK
         GOBACK
     END-IF
     MOVE SPACES TO WS-KEY-B
     MOVE WS-R-KEY TO WS-KEY-B
     CALL "SC-POTION-GET" USING L-BVAR WS-BOTTLE-POTION WS-HAS WS-COLOR WS-CUSTOM
*>   The keys compare without the namespace: the item rows and the recipe ingredients may spell it either way.
     MOVE WS-KEY-A(1:48) TO WS-ING48
     CALL "KEY-BARE" USING WS-ING48 WS-A48
     MOVE WS-KEY-B(1:48) TO WS-ING48
     CALL "KEY-BARE" USING WS-ING48 WS-B48
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > RC-COUNT OR L-ROW > 0
         MOVE RR-ING(WS-R, 1)(1:48) TO WS-ING48
         CALL "KEY-BARE" USING WS-ING48 WS-IN-BARE
         MOVE RR-ING(WS-R, 2)(1:48) TO WS-ING48
         CALL "KEY-BARE" USING WS-ING48 WS-RB48
         IF RR-SERIALIZER(WS-R) = 20 AND WS-IN-BARE = WS-A48 AND WS-RB48 = WS-B48
             MOVE SPACES TO WS-IN-POTION WS-OUT-POTION
             UNSTRING RR-EXTRA(WS-R) DELIMITED BY SPACE INTO WS-IN-POTION WS-OUT-POTION
             MOVE 1 TO WS-FITS
             IF WS-IN-POTION NOT = SPACES
                 CALL "SC-POTION-ID" USING WS-IN-POTION WS-IN-ID
                 IF WS-IN-ID NOT = WS-BOTTLE-POTION
                     MOVE 0 TO WS-FITS
                 END-IF
             END-IF
             IF WS-FITS = 1
                 MOVE WS-R TO L-ROW
             END-IF
         END-IF
     END-PERFORM
     IF L-ROW > 0
         MOVE RR-RESULT-ID(L-ROW) TO WS-TOKEN
         CALL "CONTENT-ITEM-BY-KEY" USING WS-TOKEN L-RESULT WS-RESULT-ROW WS-STATUS
         MOVE SPACES TO WS-IN-POTION WS-OUT-POTION
         UNSTRING RR-EXTRA(L-ROW) DELIMITED BY SPACE INTO WS-IN-POTION WS-OUT-POTION
         IF WS-OUT-POTION NOT = SPACES
             CALL "SC-POTION-ID" USING WS-OUT-POTION WS-OUT-ID
             CALL "SC-POTION-SET" USING L-RVAR WS-OUT-ID
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BE2-BREW-LOOKUP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE2-BREW-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-S                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-BREWABLE            BINARY-LONG.
 01 WS-FINISHED            BINARY-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-TIME                FLOAT-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-BOTTLE              BINARY-LONG.
 01 WS-REAGENT             BINARY-LONG.
 01 WS-BVAR                BINARY-LONG.
 01 WS-RVAR                BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-USES                 BINARY-LONG.
 01 L-SPEED                FLOAT-LONG.
 01 L-DONE                 BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-USES L-SPEED L-DONE L-CHANGED.
     MOVE 0 TO L-DONE L-CHANGED WS-BREWABLE
     IF BE-XI(L-INDEX, 3) <= 0 AND L-USES > 0 AND BE-SLOT-COUNT(L-INDEX, 5) > 0
         MOVE L-USES TO BE-XI(L-INDEX, 3) BE-XI(L-INDEX, 4)
         MOVE L-SPEED TO BE-XF(L-INDEX, 1)
         SUBTRACT 1 FROM BE-SLOT-COUNT(L-INDEX, 5)
         IF BE-SLOT-COUNT(L-INDEX, 5) = 0
             MOVE 0 TO BE-SLOT-ITEM(L-INDEX, 5) BE-SLOT-VAR(L-INDEX, 5)
         END-IF
         CALL "BE-MARK-CHUNK" USING L-INDEX
     END-IF
     IF BE-SLOT-COUNT(L-INDEX, 4) > 0
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 3 OR WS-BREWABLE = 1
             IF BE-SLOT-COUNT(L-INDEX, WS-S) > 0
                 MOVE BE-SLOT-ITEM(L-INDEX, WS-S) TO WS-BOTTLE
                 MOVE BE-SLOT-VAR(L-INDEX, WS-S) TO WS-BVAR
                 MOVE BE-SLOT-ITEM(L-INDEX, 4) TO WS-REAGENT
                 CALL "BE2-BREW-LOOKUP" USING WS-BOTTLE WS-BVAR WS-REAGENT WS-ROW WS-RESULT WS-RVAR
                 IF WS-ROW > 0
                     MOVE 1 TO WS-BREWABLE
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     IF BE-XI(L-INDEX, 1) > 0
         SUBTRACT 1 FROM BE-XI(L-INDEX, 1)
         IF BE-XI(L-INDEX, 1) = 0 AND WS-BREWABLE = 1
             PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 3
                 IF BE-SLOT-COUNT(L-INDEX, WS-S) > 0
                     MOVE BE-SLOT-ITEM(L-INDEX, WS-S) TO WS-BOTTLE
                     MOVE BE-SLOT-VAR(L-INDEX, WS-S) TO WS-BVAR
                     MOVE BE-SLOT-ITEM(L-INDEX, 4) TO WS-REAGENT
                     CALL "BE2-BREW-LOOKUP" USING WS-BOTTLE WS-BVAR WS-REAGENT WS-ROW WS-RESULT WS-RVAR
                     IF WS-ROW > 0
                         MOVE WS-RESULT TO BE-SLOT-ITEM(L-INDEX, WS-S)
                         MOVE 1 TO BE-SLOT-COUNT(L-INDEX, WS-S)
                         MOVE WS-RVAR TO BE-SLOT-VAR(L-INDEX, WS-S)
                     END-IF
                 END-IF
             END-PERFORM
             SUBTRACT 1 FROM BE-SLOT-COUNT(L-INDEX, 4)
             IF BE-SLOT-COUNT(L-INDEX, 4) = 0
                 MOVE 0 TO BE-SLOT-ITEM(L-INDEX, 4) BE-SLOT-VAR(L-INDEX, 4)
             END-IF
             MOVE 1 TO L-DONE
         ELSE
             IF WS-BREWABLE = 0 OR BE-SLOT-ITEM(L-INDEX, 4) NOT = BE-XI(L-INDEX, 6)
                 MOVE 0 TO BE-XI(L-INDEX, 1)
             END-IF
         END-IF
         CALL "BE-MARK-CHUNK" USING L-INDEX
     ELSE
         IF WS-BREWABLE = 1 AND BE-XI(L-INDEX, 3) > 0
             MOVE 1.0 TO WS-SPEED
             IF BE-XF(L-INDEX, 1) > 0
                 MOVE BE-XF(L-INDEX, 1) TO WS-SPEED
             END-IF
             SUBTRACT 1 FROM BE-XI(L-INDEX, 3)
             COMPUTE WS-TIME = 400 / WS-SPEED
             COMPUTE WS-NEW = 0 - FUNCTION INTEGER(0 - WS-TIME)
             MOVE WS-NEW TO BE-XI(L-INDEX, 1) BE-XI(L-INDEX, 2)
             MOVE BE-SLOT-ITEM(L-INDEX, 4) TO BE-XI(L-INDEX, 6)
             CALL "BE-MARK-CHUNK" USING L-INDEX
         END-IF
     END-IF
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 3
         MOVE 0 TO WS-FLAG
         IF BE-SLOT-COUNT(L-INDEX, WS-S) > 0
             MOVE 1 TO WS-FLAG
         END-IF
         IF WS-FLAG NOT = BE-XI(L-INDEX, 6 + WS-S)
             MOVE WS-FLAG TO BE-XI(L-INDEX, 6 + WS-S)
             MOVE 1 TO L-CHANGED
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BE2-BREW-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE2-CRAFTER-CAN-DISABLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-SLOT L-OK.
     MOVE 0 TO L-OK
     IF L-SLOT >= 0 AND L-SLOT < 9
         IF BE-SLOT-COUNT(L-INDEX, L-SLOT + 1) = 0
             MOVE 1 TO L-OK
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BE2-CRAFTER-CAN-DISABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE2-CRAFTER-SET-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-ENABLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-SLOT L-ENABLED.
     CALL "BE2-CRAFTER-CAN-DISABLE" USING L-INDEX L-SLOT WS-OK
     IF WS-OK = 1
         MOVE 1 TO BE-XI(L-INDEX, L-SLOT + 3)
         IF L-ENABLED = 1
             MOVE 0 TO BE-XI(L-INDEX, L-SLOT + 3)
         END-IF
         CALL "BE-MARK-CHUNK" USING L-INDEX
     END-IF
     GOBACK.
 END PROGRAM BE2-CRAFTER-SET-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE2-CRAFTER-DISABLED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-SLOT L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-SLOT >= 0 AND L-SLOT < 9
         MOVE BE-XI(L-INDEX, L-SLOT + 3) TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM BE2-CRAFTER-DISABLED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE2-CRAFTER-CAN-PLACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-S                   BINARY-LONG.
 01 WS-SMALLER             BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-SLOT L-ITEM L-VAR L-MAX L-RESULT.
     MOVE 0 TO L-RESULT
     IF BE-XI(L-INDEX, L-SLOT + 3) = 1
         GOBACK
     END-IF
     IF BE-SLOT-COUNT(L-INDEX, L-SLOT + 1) = 0
         MOVE 1 TO L-RESULT
         GOBACK
     END-IF
     IF BE-SLOT-COUNT(L-INDEX, L-SLOT + 1) >= L-MAX
         GOBACK
     END-IF
     MOVE 0 TO WS-SMALLER
     PERFORM VARYING WS-S FROM L-SLOT BY 1 UNTIL WS-S > 7 OR WS-SMALLER = 1
         IF BE-XI(L-INDEX, WS-S + 4) = 0
             IF BE-SLOT-COUNT(L-INDEX, WS-S + 2) = 0
                 MOVE 1 TO WS-SMALLER
             END-IF
             IF BE-SLOT-ITEM(L-INDEX, WS-S + 2) = BE-SLOT-ITEM(L-INDEX, L-SLOT + 1)
                     AND BE-SLOT-VAR(L-INDEX, WS-S + 2) = BE-SLOT-VAR(L-INDEX, L-SLOT + 1)
                     AND BE-SLOT-COUNT(L-INDEX, WS-S + 2) < BE-SLOT-COUNT(L-INDEX, L-SLOT + 1)
                 MOVE 1 TO WS-SMALLER
             END-IF
         END-IF
     END-PERFORM
     IF WS-SMALLER = 0
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM BE2-CRAFTER-CAN-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE2-CRAFTER-SET-ITEM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-ENABLED             BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-SLOT L-ITEM L-COUNT L-VAR.
     IF BE-XI(L-INDEX, L-SLOT + 3) = 1
         CALL "BE2-CRAFTER-SET-STATE" USING L-INDEX L-SLOT WS-ENABLED
     END-IF
     MOVE L-ITEM TO BE-SLOT-ITEM(L-INDEX, L-SLOT + 1)
     MOVE L-COUNT TO BE-SLOT-COUNT(L-INDEX, L-SLOT + 1)
     MOVE L-VAR TO BE-SLOT-VAR(L-INDEX, L-SLOT + 1)
     CALL "BE-MARK-CHUNK" USING L-INDEX
     GOBACK.
 END PROGRAM BE2-CRAFTER-SET-ITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE2-CRAFTER-SIGNAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-S                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-SIGNAL.
     MOVE 0 TO L-SIGNAL
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 9
         IF BE-SLOT-COUNT(L-INDEX, WS-S) > 0 OR BE-XI(L-INDEX, WS-S + 2) = 1
             ADD 1 TO L-SIGNAL
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BE2-CRAFTER-SIGNAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE2-CRAFTER-DATA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-S                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-DATA.
    05 L-VALUE             BINARY-LONG OCCURS 10 TIMES.
 PROCEDURE DIVISION USING L-INDEX L-DATA.
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 9
         MOVE BE-XI(L-INDEX, WS-S + 2) TO L-VALUE(WS-S)
     END-PERFORM
     MOVE BE-XI(L-INDEX, 2) TO L-VALUE(10)
     GOBACK.
 END PROGRAM BE2-CRAFTER-DATA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE2-CRAFTER-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-R                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-CRAFTING-OFF         BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-CRAFTING-OFF.
     MOVE 0 TO L-CRAFTING-OFF
     COMPUTE WS-R = BE-XI(L-INDEX, 1) - 1
     IF WS-R >= 0
         MOVE WS-R TO BE-XI(L-INDEX, 1)
         IF WS-R = 0
             MOVE 1 TO L-CRAFTING-OFF
         END-IF
         CALL "BE-MARK-CHUNK" USING L-INDEX
     END-IF
     GOBACK.
 END PROGRAM BE2-CRAFTER-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE2-CRAFTER-NEIGHBOR.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-POWERED              BINARY-LONG.
 01 L-TRIGGERED            BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-SCHEDULE             BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-CRAFTING-OFF         BINARY-LONG.
 PROCEDURE DIVISION USING L-POWERED L-TRIGGERED L-ENTITY L-SCHEDULE L-NEW L-CRAFTING-OFF.
     MOVE 0 TO L-SCHEDULE L-CRAFTING-OFF
     MOVE L-TRIGGERED TO L-NEW
     IF L-ENTITY = 1
         IF L-POWERED = 1 AND L-TRIGGERED = 0
             MOVE 4 TO L-SCHEDULE
             MOVE 1 TO L-NEW
         END-IF
         IF L-POWERED = 0 AND L-TRIGGERED = 1
             MOVE 0 TO L-NEW
             MOVE 1 TO L-CRAFTING-OFF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BE2-CRAFTER-NEIGHBOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE2-CRAFTER-CRAFT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-S                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-CRAFTING             BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-FOUND L-EMPTY L-EVENT L-CRAFTING.
     MOVE 0 TO L-EVENT L-CRAFTING
     IF L-FOUND = 0 OR L-EMPTY = 1
         MOVE 1050 TO L-EVENT
         GOBACK
     END-IF
     MOVE 6 TO BE-XI(L-INDEX, 1)
     MOVE 1 TO L-CRAFTING
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 9
         IF BE-SLOT-COUNT(L-INDEX, WS-S) > 0
             SUBTRACT 1 FROM BE-SLOT-COUNT(L-INDEX, WS-S)
             IF BE-SLOT-COUNT(L-INDEX, WS-S) = 0
                 MOVE 0 TO BE-SLOT-ITEM(L-INDEX, WS-S) BE-SLOT-VAR(L-INDEX, WS-S)
             END-IF
         END-IF
     END-PERFORM
     CALL "BE-MARK-CHUNK" USING L-INDEX
     GOBACK.
 END PROGRAM BE2-CRAFTER-CRAFT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE2-CRAFTER-PATH.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TARGET               BINARY-LONG.
 01 L-CRAFTER              BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-PATH                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TARGET L-CRAFTER L-COUNT L-MAX L-PATH.
     MOVE 0 TO L-PATH
     IF L-TARGET = 1
         MOVE 2 TO L-PATH
         IF L-CRAFTER = 1 OR L-COUNT > L-MAX
             MOVE 1 TO L-PATH
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BE2-CRAFTER-PATH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE2-CRAFTER-DROP.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-REST                 BINARY-LONG.
 01 L-DROP                 BINARY-LONG.
 01 L-ADVANCEMENT          BINARY-LONG.
 01 L-EVENT-1049           BINARY-LONG.
 01 L-EVENT-2010           BINARY-LONG.
 PROCEDURE DIVISION USING L-REST L-DROP L-ADVANCEMENT L-EVENT-1049 L-EVENT-2010.
     MOVE 0 TO L-DROP L-ADVANCEMENT L-EVENT-1049 L-EVENT-2010
     IF L-REST > 0
         MOVE 1 TO L-DROP L-ADVANCEMENT L-EVENT-1049 L-EVENT-2010
     END-IF
     GOBACK.
 END PROGRAM BE2-CRAFTER-DROP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE2-SAVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-LIST.
    05 WS-IDX              BINARY-LONG OCCURS 9 TIMES.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-TYPE PB-BUFFER.
     EVALUATE L-TYPE
         WHEN 12
             MOVE "BrewTime" TO WN
             MOVE 8 TO WL
             CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL BE-XI(L-INDEX, 1)
             MOVE "total_brew_time" TO WN
             MOVE 15 TO WL
             CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL BE-XI(L-INDEX, 2)
             MOVE "Fuel" TO WN
             MOVE 4 TO WL
             CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL BE-XI(L-INDEX, 3)
             MOVE "total_fuel" TO WN
             MOVE 10 TO WL
             CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL BE-XI(L-INDEX, 4)
             MOVE "speed_multiplier" TO WN
             MOVE 16 TO WL
             CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WN WL BE-XF(L-INDEX, 1)
         WHEN 42
             MOVE "crafting_ticks_remaining" TO WN
             MOVE 24 TO WL
             CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL BE-XI(L-INDEX, 1)
             MOVE 0 TO WS-N
             PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 9
                 IF BE-XI(L-INDEX, WS-S + 2) = 1
                     ADD 1 TO WS-N
                     COMPUTE WS-IDX(WS-N) = WS-S - 1
                 END-IF
             END-PERFORM
             MOVE "disabled_slots" TO WN
             MOVE 14 TO WL
             CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-N WS-LIST
             MOVE "triggered" TO WN
             MOVE 9 TO WL
             CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL BE-XI(L-INDEX, 2)
     END-EVALUATE
     GOBACK.
 END PROGRAM BE2-SAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE2-LOAD-KEY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-CAP-INTS            BINARY-LONG VALUE 64.
 01 WS-COUNT               BINARY-LONG.
 01 WS-INTS.
    05 WS-INT              BINARY-LONG OCCURS 64 TIMES.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 01 L-NAME                 PIC X(32).
 01 L-TAG                  BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-NAME L-TAG PB-BUFFER L-HANDLED.
     MOVE 0 TO L-HANDLED
     EVALUATE TRUE
         WHEN BE-TYPE(L-INDEX) = 12 AND L-NAME = "BrewTime" AND L-TAG = 3
             MOVE 1 TO L-HANDLED
             CALL "PB-GET-INT" USING PB-BUFFER BE-XI(L-INDEX, 1)
         WHEN BE-TYPE(L-INDEX) = 12 AND L-NAME = "total_brew_time" AND L-TAG = 3
             MOVE 1 TO L-HANDLED
             CALL "PB-GET-INT" USING PB-BUFFER BE-XI(L-INDEX, 2)
         WHEN BE-TYPE(L-INDEX) = 12 AND L-NAME = "Fuel" AND L-TAG = 3
             MOVE 1 TO L-HANDLED
             CALL "PB-GET-INT" USING PB-BUFFER BE-XI(L-INDEX, 3)
         WHEN BE-TYPE(L-INDEX) = 12 AND L-NAME = "total_fuel" AND L-TAG = 3
             MOVE 1 TO L-HANDLED
             CALL "PB-GET-INT" USING PB-BUFFER BE-XI(L-INDEX, 4)
         WHEN BE-TYPE(L-INDEX) = 12 AND L-NAME = "speed_multiplier" AND L-TAG = 5
             MOVE 1 TO L-HANDLED
             CALL "PB-GET-FLOAT" USING PB-BUFFER BE-XF(L-INDEX, 1)
         WHEN BE-TYPE(L-INDEX) = 42 AND L-NAME = "crafting_ticks_remaining" AND L-TAG = 3
             MOVE 1 TO L-HANDLED
             CALL "PB-GET-INT" USING PB-BUFFER BE-XI(L-INDEX, 1)
         WHEN BE-TYPE(L-INDEX) = 42 AND L-NAME = "triggered" AND L-TAG = 3
             MOVE 1 TO L-HANDLED
             CALL "PB-GET-INT" USING PB-BUFFER BE-XI(L-INDEX, 2)
         WHEN BE-TYPE(L-INDEX) = 42 AND L-NAME = "disabled_slots" AND L-TAG = 11
             MOVE 1 TO L-HANDLED
             CALL "NBT-READ-INT-ARRAY" USING PB-BUFFER WS-CAP-INTS WS-COUNT WS-INTS
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
                 IF WS-INT(WS-I) >= 0 AND WS-INT(WS-I) < 9
                     MOVE 1 TO BE-XI(L-INDEX, WS-INT(WS-I) + 3)
                 END-IF
             END-PERFORM
     END-EVALUATE
     GOBACK.
 END PROGRAM BE2-LOAD-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE2-LOAD-DONE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-S                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX.
     EVALUATE BE-TYPE(L-INDEX)
         WHEN 12
             IF BE-XI(L-INDEX, 1) > 0
                 MOVE BE-SLOT-ITEM(L-INDEX, 4) TO BE-XI(L-INDEX, 6)
             END-IF
         WHEN 42
             PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 9
                 IF BE-SLOT-COUNT(L-INDEX, WS-S) > 0
                     MOVE 0 TO BE-XI(L-INDEX, WS-S + 2)
                 END-IF
             END-PERFORM
     END-EVALUATE
     GOBACK.
 END PROGRAM BE2-LOAD-DONE.
