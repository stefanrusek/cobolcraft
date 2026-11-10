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
