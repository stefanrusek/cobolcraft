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
