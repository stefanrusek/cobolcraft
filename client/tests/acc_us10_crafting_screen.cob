*> Acceptance test of US10-1 and US10-2, the client half (client-surface §3 "Crafting screen: C";
*> standin-content §13 recipes; 08 §10.8.6 cobolcraft.screen.crafting.*; docs/protocol/
*> 09-cobolcraft-profile.md §3.3 Recipe Book Add 0x4B, Place Recipe 0x27): C opens the crafting
*> screen from the world; it lists every recipe of the last Recipe Book Add with its ingredients and
*> result, marks the craftable ones (crafting requirements present) and gives each a Craft control;
*> choosing a craftable recipe sends Place Recipe with its display id, a recipe not marked craftable
*> sends nothing; C and Escape close the screen again.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US10-CRAFTING-SCREEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PATH                PIC X(256).
 01 WS-TEXT                PIC X(1024).
 01 WS-KEY                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-E                   PIC Z(4)9.
 01 WS-E2                  PIC Z(4)9.
 01 WS-ACTION              BINARY-LONG VALUE ACT-CRAFT.
 01 WS-ARG                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 PROCEDURE DIVISION.
*>   Survival; the server's Recipe Book Add for a player holding only 4 greystone (09 §3.3 fixture
*>   note: requirements present only for display id 0).
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE "contract/fixtures/wire/play-s2c-4b-recipe-book-add.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD

     MOVE CC-KEY-C TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE "acceptance US10-1 client half: given the world shown when C is pressed then the "
         & "crafting screen opens with a Craft control for each of the nine recipes, only recipe 0 "
         & "enabled (craftable)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE SM-SCREEN TO WS-E
     STRING "screen " FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-ACTION(WS-I) = ACT-CRAFT AND SM-W-KIND(WS-I) = WK-BUTTON
             MOVE SM-W-ARG(WS-I) TO WS-E
             MOVE SM-W-STATE(WS-I) TO WS-E2
             STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E) ":" FUNCTION TRIM(WS-E2)
                 DELIMITED BY SIZE INTO TL-OBSERVED
         END-IF
     END-PERFORM
     MOVE "screen 7 0:0 1:2 2:2 3:2 4:2 5:2 6:2 7:2 8:2" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance US10-1 client half: the crafting screen lists every recipe with its "
         & "ingredients in standin §13 order and its result, the craftable ones marked ready to "
         & "craft" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "Crafting|4 x Greystone|Makes 2 x Ledger Tile|Ready to craft|Craft|4 x Grit|Makes 2 x "
         & "Lucite|Missing ingredients|Craft|3 x Greystone, 1 x Cardstack|Makes 1 x Pry Bar|"
         & "Missing ingredients|Craft|2 x Greystone, 1 x Cardstack|Makes 1 x Trowel|Missing "
         & "ingredients|Craft|1 x Lucite, 1 x Dump Shard|Makes 2 x Glowtube|Missing ingredients|"
         & "Craft|4 x Turf, 1 x Loam|Makes 1 x Sod Cake|Missing ingredients|Craft|2 x Grazer "
         & "Flank, 1 x Glowtube|Makes 2 x Seared Flank|Missing ingredients|Craft|4 x Ledger Tile, "
         & "2 x Dump Shard, 1 x Glowtube|Makes 1 x GOTO Pad|Missing ingredients|Craft|2 x "
         & "Cardstack, 2 x Lucite|Makes 1 x Dump Shard|Missing ingredients|Craft" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0 TO WS-ARG
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "acceptance US10-2 client half: when the craftable recipe 0 is chosen then Place Recipe "
         & "(container 0, display id 0, use max items false) is sent" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "27000000" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 7 TO WS-ARG
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "US10-3 client half: when recipe 7, not marked craftable, is chosen then nothing is "
         & "sent and the screen stays" TO TL-CASE
     MOVE SM-SCREEN TO WS-E
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E) " [" FUNCTION TRIM(WS-TEXT) "]" DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "7 []" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The server marks recipe 3 craftable too (a later Recipe Book Add, here set in the replica).
     MOVE 1 TO RB-CRAFTABLE(4)
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE 3 TO WS-ARG
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "acceptance US10-2 client half: when recipe 3 is marked craftable and chosen then Place "
         & "Recipe with display id 3 is sent" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "27000300" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE CC-KEY-C TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE SM-SCREEN TO WS-N
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE CC-KEY-ESCAPE TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE "US10 client: given the crafting screen when C is pressed then the world is shown; C "
         & "opens it again and Escape closes it" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = SCR-WORLD * 100 + SCR-WORLD
     COMPUTE TL-OBSERVED-N = WS-N * 100 + SM-SCREEN
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE CC-KEY-T TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE CC-KEY-C TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE "US10 client: given chat open when C is pressed then chat stays open (the crafting "
         & "screen opens only from the world)" TO TL-CASE
     MOVE SCR-CHAT TO TL-EXPECTED-N
     MOVE SM-SCREEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US10-CRAFTING-SCREEN.
 COPY CLTEST.
