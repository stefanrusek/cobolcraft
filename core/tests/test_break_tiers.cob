*> Test of the tool tier and tool requirement the tables read (13 §2.1 tiers, §2.6 "Req" and tier tags): the tier of a tool
*> from its key (core/src/content-tables.cob ITEM-TOOL-TIER), the block flags CB-TOOL-REQ and CB-NEED-TIER from the row
*> and the tags minecraft:needs_stone_tool, needs_iron_tool and needs_diamond_tool (core/src/block-props.cob), and the
*> ingredient test with the optional minecraft: namespace of a key (core/src/crafting-match.cob).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BREAK-TIERS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY CITEMS.
 01 WS-KEY                 PIC X(48).
 01 WS-TIER                BINARY-LONG.
 01 WS-TEXT                PIC X(200).
 01 WS-EDIT                PIC -(9)9.
 01 WS-BLOCK-KEY           PIC X(112) VALUE "cobolcraft:greystone".
 01 WS-BLOCK-ID            BINARY-LONG.
 01 WS-ROW                 PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-REGISTRY            PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112).
 01 WS-MEMBERS.
    05 WS-MEMBER           BINARY-LONG OCCURS 1 TIMES.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-INGREDIENT          PIC X(800).
 01 WS-ITEM                BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS

     MOVE "test break tiers a tool key gives its tier: wooden and golden 0, stone and copper 1, iron 2, "
         & "diamond, netherite and the cobolcraft tools 3" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE "minecraft:wooden_pickaxe" TO WS-KEY
     PERFORM ADD-TIER
     MOVE "minecraft:golden_shovel" TO WS-KEY
     PERFORM ADD-TIER
     MOVE "minecraft:stone_pickaxe" TO WS-KEY
     PERFORM ADD-TIER
     MOVE "minecraft:copper_pickaxe" TO WS-KEY
     PERFORM ADD-TIER
     MOVE "minecraft:iron_shovel" TO WS-KEY
     PERFORM ADD-TIER
     MOVE "minecraft:diamond_pickaxe" TO WS-KEY
     PERFORM ADD-TIER
     MOVE "cobolcraft:pry_bar" TO WS-KEY
     PERFORM ADD-TIER
     MOVE "0 0 1 1 2 3 3" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test break tiers a block row that requires a tool and is in the three tier tags is "
         & "filled with the requirement and the highest tier (3)" TO TL-CASE
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-BLOCK-KEY WS-BLOCK-ID WS-ROW WS-STATUS
     MOVE WS-ROW TO CT-BLOCK-ROW
     MOVE "yes" TO CT-BR-TOOL-REQUIRED
     MOVE WS-BLOCK-ID TO WS-MEMBER(1)
     MOVE "minecraft:needs_stone_tool" TO WS-TAG
     CALL "TAG-PUT" USING WS-REGISTRY WS-TAG WS-ONE WS-MEMBERS WS-STATUS
     MOVE "minecraft:needs_iron_tool" TO WS-TAG
     CALL "TAG-PUT" USING WS-REGISTRY WS-TAG WS-ONE WS-MEMBERS WS-STATUS
     MOVE "minecraft:needs_diamond_tool" TO WS-TAG
     CALL "TAG-PUT" USING WS-REGISTRY WS-TAG WS-ONE WS-MEMBERS WS-STATUS
     MOVE CT-BLOCK-ROW TO WS-ROW
     CALL "BLOCKS-FILL" USING WS-BLOCK-ID WS-ROW
     MOVE CB-TOOL-REQ(WS-BLOCK-ID + 1) TO WS-EDIT
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
     MOVE CB-NEED-TIER(WS-BLOCK-ID + 1) TO WS-EDIT
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 3" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test break tiers 27§1.3 the ingredient test strips an optional minecraft: from the "
         & "ingredient and from the item key" TO TL-CASE
     MOVE "minecraft:stone" TO IT-KEY(2)
     MOVE 1 TO WS-ITEM
     MOVE SPACES TO WS-INGREDIENT
     MOVE "minecraft:stone" TO WS-INGREDIENT
     CALL "CRAFT-ING-TEST" USING WS-ITEM WS-INGREDIENT WS-RESULT
     MOVE WS-RESULT TO WS-EDIT
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "stone" TO WS-INGREDIENT
     CALL "CRAFT-ING-TEST" USING WS-ITEM WS-INGREDIENT WS-RESULT
     MOVE WS-RESULT TO WS-EDIT
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 1" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 ADD-TIER.
     CALL "ITEM-TOOL-TIER" USING WS-KEY WS-TIER
     MOVE WS-TIER TO WS-EDIT
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE TL-OBSERVED TO WS-TEXT.
 END PROGRAM TEST-BREAK-TIERS.

 COPY CORETEST.
