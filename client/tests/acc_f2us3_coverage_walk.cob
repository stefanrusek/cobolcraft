*> Acceptance test US3-2 (spec 002 SC-001; FR-015), real input (tmp/Faithful 32x - 26.3.zip, tmp/minecraft-26.3-client.jar;
*> the test FAILS loudly when absent): the checklist walk of docs/design/faithful-pack-mapping.md sections 3 to 6. With
*> the generated packs, the Faithful skin and Faithful enabled: every checklist texture of blocks, items, mobs, GUI
*> sprites, particles, weather and font resolves to the Faithful zip (the top of the stack); the block atlas holds
*> the skin's minecraft: block sprites at 32 pixels and the baked models of the cobolcraft blocks use no
*> missing-texture sprite; the item icons of the tools are the skin's; the weather atlas takes the pack's rain and
*> snow images (128 wide, 512 high) under the skin. (FR-015 keeps the stripes where the pack does not cover.)
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US3-COVERAGE-WALK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-GAME                PIC X(64) VALUE "build/generated-test/f2-walk".
 01 WS-GAME-LENGTH         BINARY-LONG VALUE 28.
 01 WS-COMMAND             PIC X(1024).
 01 WS-EXIT                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-ANY                 BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-PACK                BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-NAME                PIC X(80).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-E1                  PIC Z(3)9.
 01 WS-E2                  PIC Z(3)9.
 01 WS-LIST.
    05 FILLER PIC X(64) VALUE "assets/minecraft/textures/block/bedrock.png".
    05 FILLER PIC X(64) VALUE "assets/minecraft/textures/block/stone.png".
    05 FILLER PIC X(64) VALUE "assets/minecraft/textures/block/dirt.png".
    05 FILLER PIC X(64) VALUE "assets/minecraft/textures/block/sand.png".
    05 FILLER PIC X(64) VALUE "assets/minecraft/textures/block/glass.png".
    05 FILLER PIC X(64) VALUE "assets/minecraft/textures/block/redstone_lamp_on.png".
    05 FILLER PIC X(64) VALUE "assets/minecraft/textures/block/redstone_lamp.png".
    05 FILLER PIC X(64) VALUE "assets/minecraft/textures/block/netherrack.png".
    05 FILLER PIC X(64) VALUE "assets/minecraft/textures/block/crafting_table_top.png".
    05 FILLER PIC X(64) VALUE "assets/minecraft/textures/block/crafting_table_side.png".
    05 FILLER PIC X(64) VALUE "assets/minecraft/textures/item/iron_pickaxe.png".
    05 FILLER PIC X(64) VALUE "assets/minecraft/textures/item/iron_shovel.png".
    05 FILLER PIC X(64) VALUE "assets/minecraft/textures/item/beef.png".
    05 FILLER PIC X(64) VALUE "assets/minecraft/textures/item/cooked_beef.png".
    05 FILLER PIC X(64) VALUE "assets/minecraft/textures/item/cake.png".
    05 FILLER PIC X(64) VALUE "assets/minecraft/textures/item/amethyst_shard.png".
    05 FILLER PIC X(64) VALUE "assets/minecraft/textures/entity/player/wide/steve.png".
    05 FILLER PIC X(64) VALUE "assets/minecraft/textures/entity/cow/cow_temperate.png".
    05 FILLER PIC X(64) VALUE "assets/minecraft/textures/entity/slime/slime.png".
    05 FILLER PIC X(64) VALUE "assets/minecraft/textures/gui/sprites/hud/hotbar.png".
    05 FILLER PIC X(64) VALUE "assets/minecraft/textures/gui/sprites/hud/heart/full.png".
    05 FILLER PIC X(64) VALUE "assets/minecraft/textures/gui/sprites/hud/food_full.png".
    05 FILLER PIC X(64) VALUE "assets/minecraft/textures/gui/sprites/container/slot.png".
    05 FILLER PIC X(64) VALUE "assets/minecraft/textures/gui/sprites/widget/button.png".
    05 FILLER PIC X(64) VALUE "assets/minecraft/textures/gui/sprites/tooltip/background.png".
    05 FILLER PIC X(64) VALUE "assets/minecraft/textures/gui/container/inventory.png".
    05 FILLER PIC X(64) VALUE "assets/minecraft/textures/particle/flame.png".
    05 FILLER PIC X(64) VALUE "assets/minecraft/textures/environment/rain.png".
    05 FILLER PIC X(64) VALUE "assets/minecraft/textures/environment/snow.png".
    05 FILLER PIC X(64) VALUE "assets/minecraft/textures/font/ascii.png".
 01 WS-LIST-TABLE REDEFINES WS-LIST.
    05 WS-LIST-PATH         PIC X(64) OCCURS 30 TIMES.
 01 WS-BLOCKS.
    05 FILLER PIC X(32) VALUE "minecraft:block/bedrock".
    05 FILLER PIC X(32) VALUE "minecraft:block/stone".
    05 FILLER PIC X(32) VALUE "minecraft:block/dirt".
    05 FILLER PIC X(32) VALUE "minecraft:block/sand".
    05 FILLER PIC X(32) VALUE "minecraft:block/glass".
    05 FILLER PIC X(32) VALUE "minecraft:block/redstone_lamp_on".
    05 FILLER PIC X(32) VALUE "minecraft:block/redstone_lamp".
    05 FILLER PIC X(32) VALUE "minecraft:block/netherrack".
 01 WS-BLOCK-TABLE REDEFINES WS-BLOCKS.
    05 WS-BLOCK-ID          PIC X(32) OCCURS 8 TIMES.
 PROCEDURE DIVISION.
     CALL "SYSTEM" USING 'test -f "tmp/Faithful 32x - 26.3.zip" && test -f tmp/minecraft-26.3-client.jar'
     MOVE RETURN-CODE TO WS-EXIT
     MOVE "acceptance US3-2 the real inputs are present (no skips)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-EXIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-COMMAND
     STRING "rm -rf build/generated-test/f2-walk && mkdir -p build/generated-test/f2-walk/resourcepacks "
         "&& make -C extract bin >/dev/null 2>&1; build/bin/cobolcraft-extract --jar tmp/minecraft-26.3-client.jar "
         "--game-dir build/generated-test/f2-walk --generated-dir build/generated-test/f2-walk/generated "
         "--quiet >/dev/null && cp 'tmp/Faithful 32x - 26.3.zip' build/generated-test/f2-walk/resourcepacks/"
         X"00" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE RETURN-CODE TO WS-EXIT
     MOVE "acceptance US3-2 the extraction and the copy of the Faithful zip succeed" TO TL-CASE
     MOVE WS-EXIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     PERFORM START-CLIENT
     MOVE ACT-PACKS TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ANY WS-FOUND
     MOVE ACT-SELECT TO WS-ACTION
     MOVE 2 TO WS-ARG
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE ACT-PACK-ENABLE TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ANY WS-FOUND
     MOVE ACT-SELECT TO WS-ACTION
     MOVE 1 TO WS-ARG
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE ACT-PACK-ENABLE TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ANY WS-FOUND
     MOVE ACT-PACKS-DONE TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ANY WS-FOUND

*>   Every checklist texture resolves to the top of the stack, the Faithful zip.
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30
         MOVE SPACES TO WS-PATH
         MOVE WS-LIST-PATH(WS-I) TO WS-PATH
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PATH)) TO WS-LENGTH
         CALL "PACK-RESOLVE" USING CLIENT-STATE WS-PATH WS-LENGTH WS-PACK
         IF WS-PACK NOT = PK-COUNT
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US3-2 each of the 30 checklist textures (blocks, items, mobs, GUI, particle, weather, "
         & "font) resolves to the Faithful zip" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The block atlas holds the skin's block sprites at 32 pixels.
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         MOVE WS-BLOCK-ID(WS-I) TO WS-NAME
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-NAME)) TO WS-NAME-LENGTH
         CALL "ATLAS-FIND" USING CLIENT-STATE WS-NAME WS-NAME-LENGTH WS-SPRITE
         IF WS-SPRITE = 0
             ADD 1 TO WS-BAD
         ELSE
             IF AT-SW(WS-SPRITE) NOT = 32 OR AT-PACK(WS-SPRITE) NOT = PK-COUNT
                 ADD 1 TO WS-BAD
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US3-2 the 8 skin block sprites are in the block atlas at 32 pixels from Faithful" TO TL-CASE
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   No baked quad of a cobolcraft block state is the missing texture (sprite 1).
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > CL-STAND-STATES
         PERFORM VARYING WS-Q FROM 1 BY 1 UNTIL WS-Q > BM-QUAD-COUNT(WS-I)
             IF BM-SPRITE(WS-I, WS-Q) = 1
                 ADD 1 TO WS-BAD
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US3-2 no quad of a cobolcraft block state is the missing-texture stripes" TO TL-CASE
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Item icons: pry_bar (item 10) is the skin's iron pickaxe; none of the 17 drawn items is the stripes.
     MOVE IT-SPRITE(11) TO WS-SPRITE
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > CL-ITEM-COUNT
         IF IT-SPRITE(WS-I) = 1
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US3-2 the item icons: pry_bar is minecraft:item/iron_pickaxe and no icon is the "
         & "stripes" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-BAD TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING AT-NAME(WS-SPRITE)(1:AT-NAME-LENGTH(WS-SPRITE)) " bad " FUNCTION TRIM(WS-E1)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "minecraft:item/iron_pickaxe bad 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Weather under the skin: the pack's rain and snow images (128 x 512).
     MOVE XA-IM-W(1) TO WS-E1
     MOVE XA-IM-H(1) TO WS-E2
     MOVE "acceptance US3-2 the weather atlas takes the pack's rain image under the skin (128 x 512)"
         TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "128x512" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 START-CLIENT.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE "Alice" TO CL-NAME
     MOVE 5 TO CL-NAME-LENGTH
     MOVE WS-GAME TO CL-GAME-DIR
     MOVE WS-GAME-LENGTH TO CL-GAME-DIR-LENGTH
     CALL "CL-START" USING CLIENT-STATE
     CALL "TEST-STEP" USING CLIENT-STATE.

 END PROGRAM ACC-F2US3-COVERAGE-WALK.
 COPY CLTEST.
