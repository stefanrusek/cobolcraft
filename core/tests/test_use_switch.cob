*> Implementation test (002-lane-play2 defect 2; docs/protocol/30 part 5 sections 2 and 3, part 7 doors, 29 section 9): Use Item On with an empty
*> hand on a lever toggles powered, on a button presses it (powered true, released after 20 ticks for stone and 30 for wood), on a wooden door
*> (both halves), trapdoor and fence gate toggles open, and does nothing on an iron door or while sneaking with an item held (the item is used on
*> the block instead). Standard block tables (TEST-STANDARD-TABLES), Alice survival with an empty hand.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-USE-SWITCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG VALUE 20.
 01 WS-Y                   BINARY-LONG VALUE 101.
 01 WS-Z                   BINARY-LONG VALUE 20.
 01 WS-Y2                  BINARY-LONG VALUE 102.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-STATE               BINARY-LONG.
 01 WS-NOW                 BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-TEXT                PIC X(160).
 01 WS-CHUNK               PIC X(4096).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     CALL "TEST-STANDARD-TABLES"
     CALL "GB-RULES-OPEN"
     CALL "SW-RULES-OPEN"
     CALL "SW-RULES-OPEN"
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     PERFORM VARYING WS-NOW FROM 1 BY 1 UNTIL WS-NOW > 36
         MOVE 0 TO PL-SLOT-COUNT(WS-ROW, WS-NOW) PL-SLOT-ITEM(WS-ROW, WS-NOW)
     END-PERFORM
     MOVE "T" TO TL-MODE

*>   The lever.
     MOVE "lever" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     PERFORM PUT-BLOCK
     PERFORM USE-IT
     MOVE "test use switch: an empty hand on a lever sets powered" TO TL-CASE
     MOVE "face=wall,facing=north,powered=true" TO TL-EXPECTED
     PERFORM CHECK-PROPS
     PERFORM USE-IT
     MOVE "test use switch: and a second click clears it" TO TL-CASE
     MOVE "face=wall,facing=north,powered=false" TO TL-EXPECTED
     PERFORM CHECK-PROPS

*>   A stone button is released after 20 ticks, an oak button after 30.
     MOVE "stone_button" TO WS-KEY
     PERFORM PUT-BLOCK
     PERFORM USE-IT
     MOVE "test use switch: a stone button is pressed" TO TL-CASE
     MOVE "face=wall,facing=north,powered=true" TO TL-EXPECTED
     PERFORM CHECK-PROPS
     MOVE 19 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE "test use switch: a stone button is still pressed after 19 ticks" TO TL-CASE
     PERFORM CHECK-PROPS
     MOVE 3 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE "test use switch: a stone button is released after 22 ticks" TO TL-CASE
     MOVE "face=wall,facing=north,powered=false" TO TL-EXPECTED
     PERFORM CHECK-PROPS
     MOVE "oak_button" TO WS-KEY
     PERFORM PUT-BLOCK
     PERFORM USE-IT
*>   A second click on a pressed button changes nothing and does not move the release time.
     PERFORM USE-IT
     MOVE 25 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE "test use switch: an oak button is still pressed after 25 ticks" TO TL-CASE
     MOVE "face=wall,facing=north,powered=true" TO TL-EXPECTED
     PERFORM CHECK-PROPS
     MOVE 8 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE "test use switch: an oak button is released after 33 ticks" TO TL-CASE
     MOVE "face=wall,facing=north,powered=false" TO TL-EXPECTED
     PERFORM CHECK-PROPS

*>   Doors: both halves.
     MOVE "oak_door" TO WS-KEY
     MOVE "facing=north,half=lower,hinge=left,open=false,powered=false" TO WS-PAIRS
     PERFORM PUT-BLOCK
     MOVE "facing=north,half=upper,hinge=left,open=false,powered=false" TO WS-PAIRS
     MOVE WS-Y2 TO WS-NOW
     PERFORM PUT-BLOCK-ABOVE
     PERFORM USE-IT
     MOVE "test use switch: an empty hand on a wooden door opens the lower half" TO TL-CASE
     MOVE "facing=north,half=lower,hinge=left,open=true,powered=false" TO TL-EXPECTED
     PERFORM CHECK-PROPS
     MOVE "test use switch: and the upper half" TO TL-CASE
     MOVE "facing=north,half=upper,hinge=left,open=true,powered=false" TO TL-EXPECTED
     PERFORM CHECK-PROPS-ABOVE
     PERFORM USE-IT
     MOVE "test use switch: a second click closes the lower half" TO TL-CASE
     MOVE "facing=north,half=lower,hinge=left,open=false,powered=false" TO TL-EXPECTED
     PERFORM CHECK-PROPS
     MOVE "test use switch: and the upper half" TO TL-CASE
     MOVE "facing=north,half=upper,hinge=left,open=false,powered=false" TO TL-EXPECTED
     PERFORM CHECK-PROPS-ABOVE
*>   A click on the upper half works the same.
     MOVE WS-Y2 TO WS-Y
     PERFORM USE-IT
     MOVE 101 TO WS-Y
     MOVE "test use switch: a click on the upper half opens the lower half too" TO TL-CASE
     MOVE "facing=north,half=lower,hinge=left,open=true,powered=false" TO TL-EXPECTED
     PERFORM CHECK-PROPS
     MOVE "air" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     PERFORM PUT-BLOCK-ABOVE

*>   Trapdoor and fence gate.
     MOVE "oak_trapdoor" TO WS-KEY
     PERFORM PUT-BLOCK
     PERFORM USE-IT
     MOVE "test use switch: a trapdoor opens" TO TL-CASE
     MOVE "facing=north,half=bottom,open=true,powered=false,waterlogged=false" TO TL-EXPECTED
     PERFORM CHECK-PROPS
     MOVE "oak_fence_gate" TO WS-KEY
     PERFORM PUT-BLOCK
     PERFORM USE-IT
     MOVE "test use switch: a fence gate opens" TO TL-CASE
     MOVE "facing=north,in_wall=false,open=true,powered=false" TO TL-EXPECTED
     PERFORM CHECK-PROPS

*>   Iron: not by hand.
     MOVE "iron_door" TO WS-KEY
     PERFORM PUT-BLOCK
     PERFORM USE-IT
     MOVE "test use switch: an iron door does not open by hand" TO TL-CASE
     MOVE "facing=north,half=lower,hinge=left,open=false,powered=false" TO TL-EXPECTED
     PERFORM CHECK-PROPS
     MOVE "iron_trapdoor" TO WS-KEY
     PERFORM PUT-BLOCK
     PERFORM USE-IT
     MOVE "test use switch: an iron trapdoor does not open by hand" TO TL-CASE
     MOVE "facing=north,half=bottom,open=false,powered=false,waterlogged=false" TO TL-EXPECTED
     PERFORM CHECK-PROPS

*>   Sneaking with an item held: the item is used on the block, the lever stays (its wall block is behind it, as a lever without support breaks, T10305).
     MOVE "stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     ADD 1 TO WS-Z
     PERFORM PUT-BLOCK
     SUBTRACT 1 FROM WS-Z
     MOVE "lever" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     PERFORM PUT-BLOCK
     MOVE 1 TO PL-SNEAKING(WS-ROW)
     MOVE 2 TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 1)
     PERFORM USE-IT
     MOVE "test use switch: sneaking with an item held leaves a lever alone" TO TL-CASE
     MOVE "face=wall,facing=north,powered=false" TO TL-EXPECTED
     PERFORM CHECK-PROPS
     STOP RUN.

 PUT-BLOCK.
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE.

 PUT-BLOCK-ABOVE.
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y2 WS-Z WS-STATE.

 USE-IT.
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-ALICE WS-X WS-Y WS-Z WS-FACE WS-SEQ
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-CHUNK.

 CHECK-PROPS.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "BLOCKS-STATE-PROPS" USING WS-STATE WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-PROPS-ABOVE.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y2 WS-Z WS-STATE
     CALL "BLOCKS-STATE-PROPS" USING WS-STATE WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-USE-SWITCH.

 COPY CORETEST.
