*> Acceptance test (lane bugusein, T63302; docs/protocol/29 section 9 use rules, 25 section 6.3): the click that Use Item On consumed is not used again by Use Item. The client sends
*> Use Item On for the block aimed at and then Use Item for the held item (the server decides); a block that takes the click (a door, a crafting table, a lever) leaves nothing for
*> the item, so a thrown ender pearl, snowball or egg is not also thrown. A block that does nothing with the click (plain stone) passes it on: the item is used. The flag
*> lasts for the tick of the Use Item On only (TS-CLICK-TICK, CTOOLS.cpy), so a Use Item of a later tick is used.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGUSEIN-CLICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CMENU.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-TYPE-PEARL          BINARY-LONG.
 01 WS-TYPE-SNOW           BINARY-LONG.
 01 WS-TYPE-EGG            BINARY-LONG.
 01 WS-TYPE-BOAT           BINARY-LONG.
 01 WS-YAW0                FLOAT-SHORT VALUE 0.
 01 WS-PITCH60             FLOAT-SHORT VALUE 60.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-TICKS               BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-FACE                BINARY-LONG VALUE 2.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-PAIRS               PIC X(160).
 01 WS-BLOCK-KEY           PIC X(112).
 01 WS-TEXT                PIC X(160).
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              BINARY-DOUBLE.
 01 WS-OBSERVE             BINARY-DOUBLE.
 PROCEDURE DIVISION.
     CALL "RT-OPEN" USING WS-PLAYER WS-CONN WS-FLOOR WS-CX WS-CZ
     MOVE "ender_pearl" TO WS-KEY
     CALL "RT-ENTITY-ID" USING WS-KEY WS-TYPE-PEARL
     MOVE "snowball" TO WS-KEY
     CALL "RT-ENTITY-ID" USING WS-KEY WS-TYPE-SNOW
     MOVE "egg" TO WS-KEY
     CALL "RT-ENTITY-ID" USING WS-KEY WS-TYPE-EGG
     MOVE "oak_boat" TO WS-KEY
     CALL "RT-ENTITY-ID" USING WS-KEY WS-TYPE-BOAT
     MOVE 0 TO PL-YAW(WS-PLAYER) PL-PITCH(WS-PLAYER)
     MOVE WS-CX TO WS-BX
     MOVE WS-FLOOR TO WS-BY
     ADD 1 TO WS-BY
     COMPUTE WS-BZ = WS-CZ + 2
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS

*>   An ender pearl used on a door: the door opens and the pearl stays in the hand.
     MOVE "oak_door" TO WS-BLOCK-KEY
     MOVE "facing=north,half=lower,hinge=left,open=false,powered=false" TO WS-PAIRS
     PERFORM PUT-BLOCK
     ADD 1 TO WS-BY
     MOVE "facing=north,half=upper,hinge=left,open=false,powered=false" TO WS-PAIRS
     PERFORM PUT-BLOCK
     SUBTRACT 1 FROM WS-BY
     MOVE "ender_pearl" TO WS-KEY
     CALL "RT-GIVE1" USING WS-PLAYER WS-KEY WS-THREE
     PERFORM CLICK-AND-USE
     CALL "WORLD-GET-BLOCK" USING PL-DIM(WS-PLAYER) WS-BX WS-BY WS-BZ WS-STATE
     CALL "BLOCKS-STATE-PROPS" USING WS-STATE WS-TEXT
     MOVE "acceptance bugusein 29 9: Use Item On a door with an ender pearl in hand opens the door" TO WS-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE "facing=north,half=lower,hinge=left,open=true,powered=false" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "RT-COUNT" USING WS-TYPE-PEARL WS-COUNT WS-ROW
     MOVE "acceptance bugusein 29 9: and the Use Item that follows in the same tick throws no pearl" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-COUNT TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance bugusein 29 9: and the pearls stay three" TO WS-CASE
     MOVE 3 TO WS-EXPECT
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-OBSERVE
     PERFORM CHECK-N

*>   A snowball used on a crafting table: the window opens, nothing is thrown.
     MOVE "crafting_table" TO WS-BLOCK-KEY
     MOVE SPACES TO WS-PAIRS
     PERFORM PUT-BLOCK
     MOVE "snowball" TO WS-KEY
     CALL "RT-GIVE1" USING WS-PLAYER WS-KEY WS-THREE
     PERFORM CLICK-AND-USE
     CALL "RT-COUNT" USING WS-TYPE-SNOW WS-COUNT WS-ROW
     MOVE "acceptance bugusein 29 9: a snowball used on a crafting table throws nothing" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-COUNT TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance bugusein 29 9: and the crafting window is open" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF MN-WINDOW(WS-PLAYER) NOT = 0
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     MOVE 0 TO MN-WINDOW(WS-PLAYER)

*>   An egg used on a lever.
     MOVE "lever" TO WS-BLOCK-KEY
     MOVE SPACES TO WS-PAIRS
     PERFORM PUT-BLOCK
     MOVE "egg" TO WS-KEY
     CALL "RT-GIVE1" USING WS-PLAYER WS-KEY WS-THREE
     PERFORM CLICK-AND-USE
     CALL "RT-COUNT" USING WS-TYPE-EGG WS-COUNT WS-ROW
     MOVE "acceptance bugusein 29 9: an egg used on a lever throws no egg" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-COUNT TO WS-OBSERVE
     PERFORM CHECK-N

*>   Plain stone does nothing with the click: the pearl is thrown by the Use Item that follows.
     MOVE "stone" TO WS-BLOCK-KEY
     MOVE SPACES TO WS-PAIRS
     PERFORM PUT-BLOCK
     MOVE "ender_pearl" TO WS-KEY
     CALL "RT-GIVE1" USING WS-PLAYER WS-KEY WS-THREE
     PERFORM CLICK-AND-USE
     CALL "RT-COUNT" USING WS-TYPE-PEARL WS-COUNT WS-ROW
     MOVE "acceptance bugusein 29 9: a pearl used on plain stone is thrown by the Use Item" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-COUNT TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance bugusein 29 9: and the survival stack loses one" TO WS-CASE
     MOVE 2 TO WS-EXPECT
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-OBSERVE
     PERFORM CHECK-N

*>   The click of a door lasts one tick: a Use Item of the next tick throws.
     CALL "ENTITY-REMOVE" USING WS-ROW
     MOVE "oak_door" TO WS-BLOCK-KEY
     MOVE "facing=north,half=lower,hinge=left,open=false,powered=false" TO WS-PAIRS
     PERFORM PUT-BLOCK
     MOVE "ender_pearl" TO WS-KEY
     CALL "RT-GIVE1" USING WS-PLAYER WS-KEY WS-THREE
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-BX WS-BY WS-BZ WS-FACE WS-SEQ
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-USE-ITEM" USING WS-CONN
     CALL "RT-COUNT" USING WS-TYPE-PEARL WS-COUNT WS-ROW
     MOVE "acceptance bugusein 29 9: a pearl used one tick after the door click is thrown" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-COUNT TO WS-OBSERVE
     PERFORM CHECK-N

*>   A boat used on the ground (Use Item On the floor, then Use Item looking 60 degrees down) is placed on the surface where the pick ray meets it and used up: plain ground
*>   takes no click, and the boat's box does not overlap the ground it stands on (44 part 8: the boat is created at the exact hit location).
     MOVE "oak_boat" TO WS-KEY
     CALL "RT-GIVE1" USING WS-PLAYER WS-KEY WS-ONE
     COMPUTE WS-BY = WS-FLOOR
     COMPUTE WS-BZ = WS-CZ
     ADD 1 TO WS-SEQ
     MOVE 1 TO WS-FACE
     CALL "TEST-USE-ON" USING WS-CONN WS-BX WS-BY WS-BZ WS-FACE WS-SEQ
     CALL "RT-USE-ITEM-AT" USING WS-CONN WS-YAW0 WS-PITCH60
     CALL "RT-COUNT" USING WS-TYPE-BOAT WS-COUNT WS-ROW
     MOVE "acceptance bugusein 44-8: a boat used on the stone ground is placed (one oak_boat entity)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-COUNT TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance bugusein 44-8: and the survival player's boat is used up" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-OBSERVE
     PERFORM CHECK-N
     STOP RUN.

 PUT-BLOCK.
     MOVE SPACES TO WS-TEXT
     CALL "BLOCKS-STATE-OF" USING WS-BLOCK-KEY WS-PAIRS WS-STATE
     CALL "WORLD-SET-BLOCK" USING PL-DIM(WS-PLAYER) WS-BX WS-BY WS-BZ WS-STATE.

 CLICK-AND-USE.
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0
             IF EN-TYPE(WS-ROW) = WS-TYPE-PEARL OR EN-TYPE(WS-ROW) = WS-TYPE-SNOW OR EN-TYPE(WS-ROW) = WS-TYPE-EGG
                 CALL "ENTITY-REMOVE" USING WS-ROW
             END-IF
         END-IF
     END-PERFORM
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-BX WS-BY WS-BZ WS-FACE WS-SEQ
     CALL "TEST-USE-ITEM" USING WS-CONN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-BUGUSEIN-CLICK.
 COPY CORETEST.
 COPY RANGEDTEST.
