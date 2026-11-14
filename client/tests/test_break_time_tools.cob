*> Implementation test of the break time with a tool in a standard set (CONTROLS-BREAK-TIME; 13 section 2.1, 17 section 1.3; lane mining:
*> breaking stone with a wooden pickaxe was as slow as by hand): the held item's tool rules give the speed and the correct tool for
*> drops, so the client waits as long as the server's progress needs: time = hardness x 1.5 s (x 5 s without the correct tool) divided
*> by the speed. A wooden pickaxe: stone 1,125 ms, iron ore 7,500 ms (the block needs a stone tool, the speed stays 2); a stone pickaxe
*> iron ore 1,125 ms; an iron pickaxe diamond ore 750 ms, a stone one 3,750 ms; the hand 7,500 ms on stone; a wooden axe on an oak log
*> (hardness 2, no tool required) 1,500 ms and a wooden shovel on dirt 400 ms. The effects of the player: haste II multiplies the speed
*> by 1.4, mining fatigue I by 0.3, eyes in water by 0.2 (13 section 2.1 steps 3, 4, 6); the airborne division by 5 and the Efficiency
*> enchantment are not applied by the client (the server finishes late breaks by its own progress).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BREAK-TIME-TOOLS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-REGISTRY            PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112).
 01 WS-MEMBERS.
    05 WS-MEMBER           BINARY-LONG OCCURS 3 TIMES.
 01 WS-ONE                BINARY-LONG VALUE 1.
 01 WS-COUNT               BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 PIC X(819).
 01 WS-IROW                PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-MS                  BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-IRON-ORE            BINARY-LONG.
 01 WS-DIAMOND-ORE         BINARY-LONG.
 01 WS-E1                  PIC -(8)9.
 01 WS-NAMED               PIC X(112).
 01 WS-TRIMMED             PIC X(400).
 PROCEDURE DIVISION.
     INITIALIZE CT-SET
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 1 TO CT-OPEN
     MOVE "stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-STONE WS-ROW WS-STATUS
     MOVE "iron_ore" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-IRON-ORE WS-ROW WS-STATUS
     MOVE "diamond_ore" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-DIAMOND-ORE WS-ROW WS-STATUS
     MOVE WS-STONE TO WS-MEMBER(1)
     MOVE WS-IRON-ORE TO WS-MEMBER(2)
     MOVE WS-DIAMOND-ORE TO WS-MEMBER(3)
     MOVE 3 TO WS-COUNT
     MOVE "minecraft:mineable/pickaxe" TO WS-TAG
     CALL "TAG-PUT" USING WS-REGISTRY WS-TAG WS-COUNT WS-MEMBERS WS-STATUS
     MOVE WS-IRON-ORE TO WS-MEMBER(1)
     MOVE WS-DIAMOND-ORE TO WS-MEMBER(2)
     MOVE 2 TO WS-COUNT
     MOVE "minecraft:incorrect_for_wooden_tool" TO WS-TAG
     CALL "TAG-PUT" USING WS-REGISTRY WS-TAG WS-COUNT WS-MEMBERS WS-STATUS
     MOVE "minecraft:incorrect_for_stone_tool" TO WS-TAG
     MOVE WS-DIAMOND-ORE TO WS-MEMBER(1)
     MOVE 1 TO WS-COUNT
     CALL "TAG-PUT" USING WS-REGISTRY WS-TAG WS-COUNT WS-MEMBERS WS-STATUS

     MOVE "oak_log" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-MEMBER(1) WS-ROW WS-STATUS
     MOVE "minecraft:mineable/axe" TO WS-TAG
     CALL "TAG-PUT" USING WS-REGISTRY WS-TAG WS-ONE WS-MEMBERS WS-STATUS
     MOVE "dirt" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-MEMBER(1) WS-ROW WS-STATUS
     MOVE "minecraft:mineable/shovel" TO WS-TAG
     CALL "TAG-PUT" USING WS-REGISTRY WS-TAG WS-ONE WS-MEMBERS WS-STATUS

     MOVE "break time with tools: wooden pickaxe stone 1150, iron ore 7500 (needs stone), stone pickaxe iron ore 1150, "
         & "iron pickaxe diamond ore 750, stone pickaxe diamond ore 3750, hand stone 7500" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE "wooden_pickaxe" TO WS-KEY
     MOVE WS-STONE TO WS-ID
     PERFORM ADD-TIME
     MOVE WS-IRON-ORE TO WS-ID
     PERFORM ADD-TIME
     MOVE "stone_pickaxe" TO WS-KEY
     PERFORM ADD-TIME
     MOVE "iron_pickaxe" TO WS-KEY
     MOVE WS-DIAMOND-ORE TO WS-ID
     PERFORM ADD-TIME
     MOVE "stone_pickaxe" TO WS-KEY
     PERFORM ADD-TIME
     MOVE SPACES TO WS-KEY
     MOVE WS-STONE TO WS-ID
     PERFORM ADD-TIME
     MOVE "1150 7500 1150 750 3750 7500" TO TL-EXPECTED
     MOVE FUNCTION TRIM(TL-OBSERVED) TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "break time with tools: a wooden axe on an oak log 1500 and a wooden shovel on dirt 400 (no tool required)"
         TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE "wooden_axe" TO WS-KEY
     MOVE "oak_log" TO WS-NAMED
     PERFORM ADD-NAMED
     MOVE "wooden_shovel" TO WS-KEY
     MOVE "dirt" TO WS-NAMED
     PERFORM ADD-NAMED
     MOVE "1500 400" TO TL-EXPECTED
     MOVE FUNCTION TRIM(TL-OBSERVED) TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "break time with effects: an iron pickaxe on stone with haste II and mining fatigue I 900 ms, a wooden pickaxe "
         & "with the eyes in water 5650 ms" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE 3 TO EF-COUNT
     MOVE 2 TO EF-ID(1)
     MOVE 1 TO EF-AMP(1)
     MOVE 2 TO EF-ID(2)
     MOVE 0 TO EF-AMP(2)
     MOVE 3 TO EF-ID(3)
     MOVE 0 TO EF-AMP(3)
     MOVE "iron_pickaxe" TO WS-KEY
     MOVE WS-STONE TO WS-ID
     PERFORM ADD-TIME
     MOVE 0 TO EF-COUNT
     MOVE 1 TO PL-EYES-WATER
     MOVE "wooden_pickaxe" TO WS-KEY
     PERFORM ADD-TIME
     MOVE "900 5650" TO TL-EXPECTED
     MOVE FUNCTION TRIM(TL-OBSERVED) TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "break time of a block of hardness 0 (torch) is instant: 0 ms" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE SPACES TO WS-KEY
     MOVE "torch" TO WS-NAMED
     PERFORM ADD-NAMED
     MOVE "0" TO TL-EXPECTED
     MOVE FUNCTION TRIM(TL-OBSERVED) TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO CT-OPEN CT-STATE-COUNT
     STOP RUN.

*> Appends the break time of block id WS-ID with item WS-KEY (blank: the hand) to TL-OBSERVED.
 ADD-TIME.
     MOVE 0 TO WS-ITEM
     IF WS-KEY NOT = SPACES
         CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-IROW WS-STATUS
     END-IF
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-STATE WS-STATUS
     CALL "CONTROLS-BREAK-TIME" USING CLIENT-STATE WS-STATE WS-ITEM WS-MS
     MOVE WS-MS TO WS-E1
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED.

*> The same for the block named WS-NAMED.
 ADD-NAMED.
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-NAMED WS-ID WS-ROW WS-STATUS
     PERFORM ADD-TIME.
 END PROGRAM TEST-BREAK-TIME-TOOLS.
 COPY CLTEST.
