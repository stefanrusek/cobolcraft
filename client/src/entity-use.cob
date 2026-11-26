*> The viewer's use state of another entity and the goat horn in use (docs/protocol/58-in-use-item-models-and-arm-poses.md sections 2.3, 3.2, 4 and 5.1): the replica fields EN-USE-ACTIVE,
*> EN-USE-ITEM and EN-USE-LEFT (client/copy/CLSTATE.cpy) are `useItem` and `useItemRemaining` of the viewer; the entry 8 receipt starts and clears them (ENTITY-USE-ENTRY8), the client
*> tick counts them down (ENTITY-USE-TICK), and the two readers say whether the stack in a hand is the one being used (`using_item`, ENTITY-USING-HAND) and whether the hand gets the
*> TOOT_HORN arm pose (ENTITY-HORN-POSE). Only the goat horn has a count (140 ticks, 25 part 7 section 12.2); every other item is held with a count of 0 (no pose reads it).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEM-GOAT-HORN.
*> USING CLIENT-STATE, item id, flag out (1 for the item minecraft:goat_horn, else 0; an unknown id and no item are 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NS                  PIC X(16).
 01 WS-PATH                PIC X(40).
 01 WS-MAX                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TOOL                PIC X.
 01 WS-FOOD                BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ITEM                 BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ITEM L-FLAG.
     MOVE 0 TO L-FLAG
     IF L-ITEM >= 0
         CALL "CL-ITEM-INFO" USING CLIENT-STATE L-ITEM WS-NS WS-PATH WS-MAX WS-BLOCK WS-TOOL WS-FOOD WS-KNOWN
         IF WS-KNOWN = 1 AND WS-NS = "minecraft" AND WS-PATH = "goat_horn"
             MOVE 1 TO L-FLAG
         END-IF
     END-IF
     GOBACK.
 END PROGRAM ITEM-GOAT-HORN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-USE-ENTRY8.
*> USING CLIENT-STATE, replica row: the tests of 58 section 2.3, run for every received entry 8 whether or not the byte changed. Start: bit 0 is set and `useItem` is empty: `useItem` is the stack in the
*> hand that bit 1 names at that moment (main hand when clear), and only when that stack is not empty (EN-EQ > 0) the count starts: 140 for a goat horn, 0 for a horn whose patch removed the instrument
*> component (EN-EQ-NOINST) and for every other item (no count is modelled for them); an empty hand leaves `useItem` empty, so the use stays unstarted until a later entry 8 retries it. Clear: bit 0 is clear
*> and `useItem` is not empty: both are emptied. Anything else changes nothing (an entry 8 while the viewer already uses an item does not restart the count).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SLOT                BINARY-LONG.
 01 WS-HORN                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW.
     COMPUTE WS-SLOT = FUNCTION MOD(FUNCTION INTEGER(EN-LIVING(L-ROW) / 2), 2) + 1
     IF FUNCTION MOD(EN-LIVING(L-ROW), 2) = 1
         IF EN-USE-ACTIVE(L-ROW) = 0 AND EN-EQ(L-ROW, WS-SLOT) > 0
             MOVE 1 TO EN-USE-ACTIVE(L-ROW)
             MOVE EN-EQ(L-ROW, WS-SLOT) TO EN-USE-ITEM(L-ROW)
             MOVE 0 TO EN-USE-LEFT(L-ROW)
             CALL "ITEM-GOAT-HORN" USING CLIENT-STATE EN-EQ(L-ROW, WS-SLOT) WS-HORN
             IF WS-HORN = 1 AND EN-EQ-NOINST(L-ROW, WS-SLOT) = 0
                 MOVE 140 TO EN-USE-LEFT(L-ROW)
             END-IF
         END-IF
     ELSE
         IF EN-USE-ACTIVE(L-ROW) = 1
             MOVE 0 TO EN-USE-ACTIVE(L-ROW) EN-USE-ITEM(L-ROW) EN-USE-LEFT(L-ROW)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM ENTITY-USE-ENTRY8.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-USE-TICK.
*> USING CLIENT-STATE, replica row: one client tick of the rule of 58 section 2.2 for a viewer: while bit 0 of the flags says the entity uses an item and the viewer's `useItem` is set, a used hand
*> that still holds the same item counts `useItemRemaining` down (a client never completes a use: it goes below 0 until the clear flag arrives), a used hand with another item stops the use.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW.
     IF FUNCTION MOD(EN-LIVING(L-ROW), 2) = 1 AND EN-USE-ACTIVE(L-ROW) = 1
         COMPUTE WS-SLOT = FUNCTION MOD(FUNCTION INTEGER(EN-LIVING(L-ROW) / 2), 2) + 1
         IF EN-EQ(L-ROW, WS-SLOT) = EN-USE-ITEM(L-ROW)
             SUBTRACT 1 FROM EN-USE-LEFT(L-ROW)
         ELSE
             MOVE 0 TO EN-USE-ACTIVE(L-ROW) EN-USE-ITEM(L-ROW) EN-USE-LEFT(L-ROW)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM ENTITY-USE-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-USING-HAND.
*> USING CLIENT-STATE, replica row, hand slot (1 main, 2 off), flag out: 1 when the property `using_item` is true for the stack in that hand (58 section 3.2): bit 0 of the flags is set, the viewer's
*> `useItem` is set and is the stack of the used hand (bit 1: 0 main, 1 off; the same item, which the viewer's per-tick rule keeps re-pointed at the live stack).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-SLOT L-FLAG.
     MOVE 0 TO L-FLAG
     IF FUNCTION MOD(EN-LIVING(L-ROW), 2) = 1 AND EN-USE-ACTIVE(L-ROW) = 1 AND EN-EQ(L-ROW, L-SLOT) > 0
             AND FUNCTION MOD(FUNCTION INTEGER(EN-LIVING(L-ROW) / 2), 2) = L-SLOT - 1
             AND EN-EQ(L-ROW, L-SLOT) = EN-USE-ITEM(L-ROW)
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM ENTITY-USING-HAND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-HORN-POSE.
*> USING CLIENT-STATE, replica row, hand slot (1 main, 2 off), flag out: 1 when the arm of that hand has the pose TOOT_HORN (58 section 5.1 step 3): the used hand (bit 1 of the flags) is this hand and the
*> viewer's remaining count is above 0, and the stack in this hand is a goat horn (the use animation `toot_horn` is the stack's, not `useItem`'s). Bit 0 is not read.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HORN                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-SLOT L-FLAG.
     MOVE 0 TO L-FLAG
     IF EN-USE-LEFT(L-ROW) > 0 AND EN-EQ(L-ROW, L-SLOT) > 0
             AND FUNCTION MOD(FUNCTION INTEGER(EN-LIVING(L-ROW) / 2), 2) = L-SLOT - 1
         CALL "ITEM-GOAT-HORN" USING CLIENT-STATE EN-EQ(L-ROW, L-SLOT) WS-HORN
         MOVE WS-HORN TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM ENTITY-HORN-POSE.
