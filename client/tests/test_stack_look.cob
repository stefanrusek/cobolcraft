*> Test of STACK-LOOK (client/src/stack-look.cob; lane itemcomp, T9611; docs/protocol/43 section 7 dye tint, 17 section 1.2): the facts of an item stack's components that the models lane draws:
*> the dye colour (dyed_color 47, -1 when absent), the glint (enchantments 13 or stored_enchantments 45 with at least one entry, or enchantment_glint_override 21 true; a removed
*> component or override false gives none) and the potion id (potion_contents 53, -1 when none).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STACK-LOOK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY PROTO.
 01 WS-DYE                 BINARY-LONG.
 01 WS-GLINT               BINARY-LONG.
 01 WS-POTION              BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE

     MOVE "test stack look a plain stack has no dye, no glint and no potion" TO TL-CASE
     INITIALIZE PB-ITEMSTACK-X
     MOVE 1 TO PB-ISX-COUNT
     MOVE 5 TO PB-ISX-ITEM
     PERFORM SHOW
     MOVE "-1 0 -1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test stack look dyed_color 47 gives its RGB, enchantments 13 give glint, potion_contents 53 gives the potion" TO TL-CASE
     INITIALIZE PB-ITEMSTACK-X
     MOVE 1 TO PB-ISX-COUNT
     MOVE 3 TO PB-ISX-ADDED-COUNT
     MOVE 13 TO PB-ISX-TYPE(1)
     MOVE 3 TO PB-ISX-VALUE-LENGTH(1)
     MOVE X"010001" TO PB-ISX-VALUE(1)(1:3)
     MOVE 47 TO PB-ISX-TYPE(2)
     MOVE 4 TO PB-ISX-VALUE-LENGTH(2)
     MOVE X"00B02E26" TO PB-ISX-VALUE(2)(1:4)
     MOVE 53 TO PB-ISX-TYPE(3)
     MOVE 5 TO PB-ISX-VALUE-LENGTH(3)
     MOVE X"0118000000" TO PB-ISX-VALUE(3)(1:5)
     PERFORM SHOW
     MOVE "11546150 1 24" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test stack look stored_enchantments 45 give glint, an empty list does not, an override of false and a removed glint override do not" TO TL-CASE
     INITIALIZE PB-ITEMSTACK-X
     MOVE 1 TO PB-ISX-COUNT
     MOVE 1 TO PB-ISX-ADDED-COUNT
     MOVE 45 TO PB-ISX-TYPE(1)
     MOVE 3 TO PB-ISX-VALUE-LENGTH(1)
     MOVE X"010002" TO PB-ISX-VALUE(1)(1:3)
     PERFORM SHOW
     MOVE WS-GLINT TO WS-E3
     INITIALIZE PB-ITEMSTACK-X
     MOVE 1 TO PB-ISX-COUNT
     MOVE 2 TO PB-ISX-ADDED-COUNT
     MOVE 13 TO PB-ISX-TYPE(1)
     MOVE 1 TO PB-ISX-VALUE-LENGTH(1)
     MOVE X"00" TO PB-ISX-VALUE(1)(1:1)
     MOVE 21 TO PB-ISX-TYPE(2)
     MOVE 1 TO PB-ISX-VALUE-LENGTH(2)
     MOVE X"00" TO PB-ISX-VALUE(2)(1:1)
     CALL "STACK-LOOK" USING PB-ITEMSTACK-X WS-DYE WS-GLINT WS-POTION
     MOVE WS-GLINT TO WS-E1
     MOVE X"01" TO PB-ISX-VALUE(2)(1:1)
     CALL "STACK-LOOK" USING PB-ITEMSTACK-X WS-DYE WS-GLINT WS-POTION
     MOVE WS-GLINT TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 0 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test stack look a patch that removes dyed_color or potion_contents has neither" TO TL-CASE
     INITIALIZE PB-ITEMSTACK-X
     MOVE 1 TO PB-ISX-COUNT
     MOVE 2 TO PB-ISX-REMOVED-COUNT
     MOVE 47 TO PB-ISX-REMOVED(1)
     MOVE 53 TO PB-ISX-REMOVED(2)
     PERFORM SHOW
     MOVE "-1 0 -1" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 SHOW.
     CALL "STACK-LOOK" USING PB-ITEMSTACK-X WS-DYE WS-GLINT WS-POTION
     MOVE WS-DYE TO WS-E1
     MOVE WS-GLINT TO WS-E2
     MOVE WS-POTION TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED.

 CHECK.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-STACK-LOOK.
