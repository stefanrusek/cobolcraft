*> Test of the icon tints (lane bugguiitems, T59710; docs/protocol/43 section 7 and 7.1; client/src/item-tint.cob, stack-look.cob STACK-TINT, menu.cob MENU-STACK-TINT): the colour a layer
*> of an item's icon is multiplied with (ITEM-NAME-TINT: the constants of the leaves, the vine and the lily pad, the dye default and the dyed_color of leather armour, the wolf armour that is tinted
*> only when dyed, the potion colour from the effects of the potion with the weights of 43 section 7.3 and the default blue without potion_contents, the firework star's two layers), the effect lists of
*> the 46 potions (TINT-POTION-FILL, 25-5 section 9.3), the tint facts a stack carries into its slot (STACK-TINT, MENU-PLAYER-SET, MENU-STACK-PUT, MENU-STACK-TINT) and an item of the stand-in set,
*> which has no tint.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ITEM-TINT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 COPY CLTINTI.
 COPY TESTLIB.
 01 WS-ROW-DATA.
    05 FILLER PIC X(49) VALUE "oak_leaves          +00-0000000001-001+0004764952".
    05 FILLER PIC X(49) VALUE "vine                +00-0000000001-001+0004764952".
    05 FILLER PIC X(49) VALUE "acacia_leaves       +00-0000000001-001+0004764952".
    05 FILLER PIC X(49) VALUE "dark_oak_leaves     +00-0000000001-001+0004764952".
    05 FILLER PIC X(49) VALUE "jungle_leaves       +00-0000000001-001+0004764952".
    05 FILLER PIC X(49) VALUE "spruce_leaves       +00-0000000001-001+0006396257".
    05 FILLER PIC X(49) VALUE "birch_leaves        +00-0000000001-001+0008431445".
    05 FILLER PIC X(49) VALUE "mangrove_leaves     +00-0000000001-001+0009619016".
    05 FILLER PIC X(49) VALUE "lily_pad            +00-0000000001-001+0007455580".
    05 FILLER PIC X(49) VALUE "oak_leaves          +01-0000000001-001-0000000001".
    05 FILLER PIC X(49) VALUE "oak_leaves          -01-0000000001-001-0000000001".
    05 FILLER PIC X(49) VALUE "apple               +00-0000000001-001-0000000001".
    05 FILLER PIC X(49) VALUE "leather_helmet      +00-0000000001-001+0010511680".
    05 FILLER PIC X(49) VALUE "leather_helmet      +00+0011546150-001+0011546150".
    05 FILLER PIC X(49) VALUE "leather_helmet      +01+0011546150-001-0000000001".
    05 FILLER PIC X(49) VALUE "leather_horse_armor +00-0000000001-001+0010511680".
    05 FILLER PIC X(49) VALUE "wolf_armor          +00-0000000001-001-0000000001".
    05 FILLER PIC X(49) VALUE "wolf_armor          +00+0003949738-001+0016777215".
    05 FILLER PIC X(49) VALUE "wolf_armor          +01+0003949738-001+0003949738".
    05 FILLER PIC X(49) VALUE "potion              +00-0000000001-001+0003694022".
    05 FILLER PIC X(49) VALUE "potion              +00-0000000001+000+0003694022".
    05 FILLER PIC X(49) VALUE "potion              +00-0000000001+003+0003694022".
    05 FILLER PIC X(49) VALUE "potion              +00-0000000001+013+0003402751".
    05 FILLER PIC X(49) VALUE "potion              +00-0000000001+015+0003402751".
    05 FILLER PIC X(49) VALUE "potion              +00-0000000001+019+0009274086".
    05 FILLER PIC X(49) VALUE "potion              +00-0000000001+004+0012779366".
    05 FILLER PIC X(49) VALUE "potion              +00-0000000001+026+0011101546".
    05 FILLER PIC X(49) VALUE "potion              +00-0000000001+046+0003694022".
    05 FILLER PIC X(49) VALUE "potion              +01-0000000001+013-0000000001".
    05 FILLER PIC X(49) VALUE "splash_potion       +00-0000000001+013+0003402751".
    05 FILLER PIC X(49) VALUE "tipped_arrow        +00-0000000001+024+0016262179".
    05 FILLER PIC X(49) VALUE "lingering_potion    +00-0000000001+045+0009214860".
    05 FILLER PIC X(49) VALUE "firework_star       +00-0000000001-001+0016777215".
    05 FILLER PIC X(49) VALUE "firework_star       +01-0000000001-001+0009079434".
 01 WS-ROWS REDEFINES WS-ROW-DATA.
    05 WS-RW OCCURS 34 TIMES.
       10 WS-RW-NAME           PIC X(20).
       10 WS-RW-LAYER          PIC S99 SIGN LEADING SEPARATE.
       10 WS-RW-DYE            PIC S9(10) SIGN LEADING SEPARATE.
       10 WS-RW-POTION         PIC S999 SIGN LEADING SEPARATE.
       10 WS-RW-RGB            PIC S9(10) SIGN LEADING SEPARATE.
 01 WS-I                   BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-LAYER               BINARY-LONG.
 01 WS-DYE                 BINARY-LONG.
 01 WS-POTION              BINARY-LONG.
 01 WS-RGB                 BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-TINT.
    05 WS-T                FLOAT-SHORT OCCURS 3 TIMES.
 01 WS-TINTED              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE "N" TO TL-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 34
         MOVE SPACES TO WS-NAME
         MOVE WS-RW-NAME(WS-I) TO WS-NAME
         MOVE WS-RW-LAYER(WS-I) TO WS-LAYER
         MOVE WS-RW-DYE(WS-I) TO WS-DYE
         MOVE WS-RW-POTION(WS-I) TO WS-POTION
         CALL "ITEM-NAME-TINT" USING WS-NAME WS-LAYER WS-DYE WS-POTION WS-RGB
         MOVE SPACES TO TL-CASE
         STRING "item tint " FUNCTION TRIM(WS-NAME) " layer " WS-RW-LAYER(WS-I) " dye " WS-RW-DYE(WS-I) " potion " WS-RW-POTION(WS-I)
             " is the colour of 43 section 7" DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-RW-RGB(WS-I) TO TL-EXPECTED-N
         MOVE WS-RGB TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

*>   The effect lists of the potions: a turtle master brews slowness IV and resistance III (25-5 section 9.3), water has none, an id outside the table leaves the list empty.
     MOVE 19 TO WS-POTION
     CALL "TINT-POTION-FILL" USING WS-POTION TINT-ITEM
     MOVE "item tint the turtle master potion has two effects" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE TI-EFF-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "item tint the turtle master potion: slowness (id 1) amplifier 3 then resistance (id 10) amplifier 2, both visible" TO TL-CASE
     MOVE 1031021 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = TI-EFF-ID(1) * 1000000 + TI-EFF-AMP(1) * 10000 + TI-EFF-ID(2) * 100 + TI-EFF-AMP(2) * 10 + TI-EFF-VISIBLE(2)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-POTION
     CALL "TINT-POTION-FILL" USING WS-POTION TINT-ITEM
     MOVE "item tint the water potion has no effect" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE TI-EFF-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 45 TO WS-POTION
     CALL "TINT-POTION-FILL" USING WS-POTION TINT-ITEM
     MOVE "item tint the last potion (infested) has one effect" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE TI-EFF-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -1 TO WS-POTION
     CALL "TINT-POTION-FILL" USING WS-POTION TINT-ITEM
     MOVE "item tint a negative potion id has no effect" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE TI-EFF-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Every effect of the 46 potions is a known mob effect (an unknown name would be id -1).
     MOVE 0 TO WS-RGB
     PERFORM VARYING WS-ID FROM 0 BY 1 UNTIL WS-ID > 45
         CALL "TINT-POTION-FILL" USING WS-ID TINT-ITEM
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TI-EFF-COUNT
             IF TI-EFF-ID(WS-I) < 0
                 ADD 1 TO WS-RGB
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "item tint every effect of the potion table is a known mob effect" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-RGB TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   STACK-TINT: dyed_color 47 and potion_contents 53 of a stack, each plus 1; a plain stack has neither.
     INITIALIZE PB-ITEMSTACK-X
     MOVE 1 TO PB-ISX-COUNT
     MOVE 5 TO PB-ISX-ITEM
     CALL "STACK-TINT" USING PB-ITEMSTACK-X PL-STACK-DYE PL-STACK-POTION
     MOVE "item tint STACK-TINT of a plain stack: no dye, no potion" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PL-STACK-DYE + PL-STACK-POTION
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     INITIALIZE PB-ITEMSTACK-X
     MOVE 1 TO PB-ISX-COUNT
     MOVE 2 TO PB-ISX-ADDED-COUNT
     MOVE 47 TO PB-ISX-TYPE(1)
     MOVE 4 TO PB-ISX-VALUE-LENGTH(1)
     MOVE X"00B02E26" TO PB-ISX-VALUE(1)(1:4)
     MOVE 53 TO PB-ISX-TYPE(2)
     MOVE 5 TO PB-ISX-VALUE-LENGTH(2)
     MOVE X"0118000000" TO PB-ISX-VALUE(2)(1:5)
     CALL "STACK-TINT" USING PB-ITEMSTACK-X PL-STACK-DYE PL-STACK-POTION
     MOVE "item tint STACK-TINT of a dyed potion: the RGB B02E26 plus 1 and the potion 24 plus 1" TO TL-CASE
     MOVE 1154615125 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PL-STACK-DYE * 100 + PL-STACK-POTION
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The slot takes the facts over from the stack last decoded and gives them back; an empty slot has none; the cursor stack and an argument that is no player slot have none.
     MOVE 3 TO WS-ARG
     MOVE 1 TO WS-COUNT
     MOVE 5 TO WS-ITEM
     MOVE 0 TO WS-DAMAGE
     CALL "MENU-PLAYER-SET" USING CLIENT-STATE WS-ARG WS-COUNT WS-ITEM WS-DAMAGE
     CALL "MENU-STACK-TINT" USING CLIENT-STATE WS-ARG WS-DYE WS-POTION
     MOVE "item tint slot 3 keeps the dye of the stack set into it" TO TL-CASE
     MOVE 11546150 TO TL-EXPECTED-N
     MOVE WS-DYE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "item tint slot 3 keeps the potion of the stack set into it" TO TL-CASE
     MOVE 24 TO TL-EXPECTED-N
     MOVE WS-POTION TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-COUNT
     CALL "MENU-PLAYER-SET" USING CLIENT-STATE WS-ARG WS-COUNT WS-ITEM WS-DAMAGE
     CALL "MENU-STACK-TINT" USING CLIENT-STATE WS-ARG WS-DYE WS-POTION
     MOVE "item tint an emptied slot has no dye and no potion" TO TL-CASE
     MOVE -2 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-DYE + WS-POTION
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 37 TO WS-ARG
     MOVE 1 TO WS-COUNT
     CALL "MENU-PLAYER-SET" USING CLIENT-STATE WS-ARG WS-COUNT WS-ITEM WS-DAMAGE
     CALL "MENU-STACK-TINT" USING CLIENT-STATE WS-ARG WS-DYE WS-POTION
     MOVE "item tint the off hand keeps the dye and the potion of its stack" TO TL-CASE
     MOVE 11546174 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-DYE + WS-POTION
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-COUNT
     CALL "MENU-PLAYER-SET" USING CLIENT-STATE WS-ARG WS-COUNT WS-ITEM WS-DAMAGE
     CALL "MENU-STACK-TINT" USING CLIENT-STATE WS-ARG WS-DYE WS-POTION
     MOVE "item tint an emptied off hand has no dye and no potion" TO TL-CASE
     MOVE -2 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-DYE + WS-POTION
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 36 TO WS-ARG
     CALL "MENU-STACK-TINT" USING CLIENT-STATE WS-ARG WS-DYE WS-POTION
     MOVE "item tint the cursor stack has no dye and no potion" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-DYE + WS-POTION
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 205 TO WS-ARG
     CALL "MENU-STACK-TINT" USING CLIENT-STATE WS-ARG WS-DYE WS-POTION
     MOVE "item tint a recipe book cell has no dye and no potion" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-DYE + WS-POTION
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A local move that empties a slot (MENU-STACK-PUT with count 0) clears what the slot kept.
     MOVE 7 TO WS-ARG
     MOVE 3 TO PL-SLOT-DYE(8)
     MOVE 4 TO PL-SLOT-POTION(8)
     MOVE 1 TO WS-COUNT
     CALL "MENU-STACK-PUT" USING CLIENT-STATE WS-ARG WS-COUNT WS-ITEM WS-DAMAGE
     CALL "MENU-STACK-TINT" USING CLIENT-STATE WS-ARG WS-DYE WS-POTION
     MOVE "item tint a slot that still holds a stack keeps its dye and potion through MENU-STACK-PUT" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-DYE + WS-POTION
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-COUNT
     CALL "MENU-STACK-PUT" USING CLIENT-STATE WS-ARG WS-COUNT WS-ITEM WS-DAMAGE
     CALL "MENU-STACK-TINT" USING CLIENT-STATE WS-ARG WS-DYE WS-POTION
     MOVE "item tint MENU-STACK-PUT with count 0 clears the slot's dye and potion" TO TL-CASE
     MOVE -2 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-DYE + WS-POTION
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 37 TO WS-ARG
     MOVE 3 TO PL-OFFHAND-DYE
     MOVE 4 TO PL-OFFHAND-POTION
     CALL "MENU-STACK-PUT" USING CLIENT-STATE WS-ARG WS-COUNT WS-ITEM WS-DAMAGE
     CALL "MENU-STACK-TINT" USING CLIENT-STATE WS-ARG WS-DYE WS-POTION
     MOVE "item tint MENU-STACK-PUT with count 0 clears the off hand's dye and potion" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-DYE + WS-POTION
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The stand-in set (no standard set open) has no tint: its items and an id it does not know are white.
     MOVE 1 TO WS-ITEM
     MOVE 0 TO WS-LAYER
     MOVE -1 TO WS-DYE WS-POTION
     CALL "ITEM-ICON-TINT" USING CLIENT-STATE WS-ITEM WS-LAYER WS-DYE WS-POTION WS-TINT WS-TINTED
     MOVE "item tint a stand-in item is untinted" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-TINTED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "item tint a stand-in item is white" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-T(1) + WS-T(2) + WS-T(3)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 99999 TO WS-ITEM
     CALL "ITEM-ICON-RGB" USING CLIENT-STATE WS-ITEM WS-LAYER WS-DYE WS-POTION WS-RGB
     MOVE "item tint an item id no set knows is untinted" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     MOVE WS-RGB TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-ITEM-TINT.
