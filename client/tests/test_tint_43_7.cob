*> Acceptance test of docs/protocol/43-tint-sources.md section 7 (item tint sources): the seven
*> source types with their defaults, the shipped item list of 7.1 (V12, V15), the worn armour layer
*> rule 7.2, the potion colour 7.3 (V13) and leather dye mixing 7.4 (the worked example), with V14.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TINT-43-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLTINT.
 COPY CLTINTI.
 COPY TESTLIB.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              PIC X(8).
 01 WS-NAME                PIC X(32).
 01 WS-DYED                BINARY-LONG.
 01 WS-LAYER               BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-VALUE               BINARY-DOUBLE.
 01 WS-DEFAULT             BINARY-DOUBLE.
 01 WS-T                   COMP-2.
 01 WS-D                   COMP-2.
 01 WS-DYEABLE             BINARY-LONG.
 01 WS-HAS-UNDYED          BINARY-LONG.
 01 WS-UNDYED              BINARY-DOUBLE.
 01 WS-DYE                 BINARY-DOUBLE.
 01 WS-COLOUR              BINARY-DOUBLE.
 01 WS-INDEX               BINARY-LONG.
 PROCEDURE DIVISION.
*>   constant: opaque(value).
     INITIALIZE TINT-ITEM
     MOVE 1 TO TI-TYPE
     MOVE 1193046 TO TI-VALUE
     CALL "TINT-ITEM-COLOR" USING TINT-ITEM
     MOVE "acceptance US11 43§7 Item tint sources: constant is opaque" TO WS-CASE
     MOVE "FF123456" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TI-COLOUR
*>   dye: the component as opaque rgb, else the default unchanged (it keeps its own alpha).
     INITIALIZE TINT-ITEM
     MOVE 2 TO TI-TYPE
     MOVE 1 TO TI-HAS-DYE
     MOVE 11546150 TO TI-DYE-RGB
     MOVE 4288701760 TO TI-DEFAULT
     CALL "TINT-ITEM-COLOR" USING TINT-ITEM
     MOVE "acceptance US11 43§7 Item tint sources: V12 dyed leather is the component" TO WS-CASE
     MOVE "FFB02E26" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TI-COLOUR
     MOVE 0 TO TI-HAS-DYE
     CALL "TINT-ITEM-COLOR" USING TINT-ITEM
     MOVE "acceptance US11 43§7 Item tint sources: V12 undyed leather is the default" TO WS-CASE
     MOVE "FFA06540" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TI-COLOUR
     MOVE 1193046 TO TI-DEFAULT
     CALL "TINT-ITEM-COLOR" USING TINT-ITEM
     MOVE "acceptance US11 43§7 Item tint sources: the dye default keeps its alpha" TO WS-CASE
     MOVE "00123456" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TI-COLOUR
*>   grass: the colormap at the source's climate (no biome, no modifier).
     COMPUTE WS-INDEX = 127 * 256 + 127 + 1
     MOVE 4286365035 TO TT-MAP-GRASS(WS-INDEX)
     INITIALIZE TINT-ITEM
     MOVE 3 TO TI-TYPE
     MOVE 0.5 TO TI-TEMP
     MOVE 1.0 TO TI-DOWN
     CALL "TINT-ITEM-COLOR" USING TINT-ITEM
     MOVE "acceptance US11 43§7 Item tint sources: grass source at (0.5, 1.0)" TO WS-CASE
     MOVE "FF7CBD6B" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TI-COLOUR
*>   firework: none gives the default, one colour opaque, several the per-channel mean (V14).
     INITIALIZE TINT-ITEM
     MOVE 4 TO TI-TYPE
     MOVE 4287269514 TO TI-DEFAULT
     CALL "TINT-ITEM-COLOR" USING TINT-ITEM
     MOVE "acceptance US11 43§7 Item tint sources: V14 firework star without colours" TO WS-CASE
     MOVE "FF8A8A8A" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TI-COLOUR
     MOVE 1 TO TI-FW-COUNT
     MOVE 255 TO TI-FW-RGB(1)
     CALL "TINT-ITEM-COLOR" USING TINT-ITEM
     MOVE "acceptance US11 43§7 Item tint sources: one firework colour is opaque" TO WS-CASE
     MOVE "FF0000FF" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TI-COLOUR
     MOVE 2 TO TI-FW-COUNT
     MOVE 16711680 TO TI-FW-RGB(1)
     MOVE 255 TO TI-FW-RGB(2)
     CALL "TINT-ITEM-COLOR" USING TINT-ITEM
     MOVE "acceptance US11 43§7 Item tint sources: V14 red and blue give FF7F007F" TO WS-CASE
     MOVE "FF7F007F" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TI-COLOUR
*>   potion: no component gives the default, a water bottle (no effects) too (V13), 7.3 weights.
     INITIALIZE TINT-ITEM
     MOVE 5 TO TI-TYPE
     MOVE 4281884102 TO TI-DEFAULT
     MOVE -1 TO TI-CUSTOM
     CALL "TINT-ITEM-COLOR" USING TINT-ITEM
     MOVE "acceptance US11 43§7 Item tint sources: potion without component is the default" TO WS-CASE
     MOVE "FF385DC6" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TI-COLOUR
     MOVE 1 TO TI-HAS-POTION
     CALL "TINT-ITEM-COLOR" USING TINT-ITEM
     MOVE "acceptance US11 43§7 Item tint sources: V13 water bottle is FF385DC6" TO WS-CASE
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TI-COLOUR
     MOVE 2 TO TI-EFF-COUNT
     MOVE 0 TO TI-EFF-ID(1)
     MOVE 1 TO TI-EFF-AMP(1)
     MOVE 1 TO TI-EFF-VISIBLE(1)
     MOVE 4 TO TI-EFF-ID(2)
     MOVE 0 TO TI-EFF-AMP(2)
     MOVE 1 TO TI-EFF-VISIBLE(2)
     CALL "TINT-ITEM-COLOR" USING TINT-ITEM
     MOVE "acceptance US11 43§7 Item tint sources: 7.3 Speed II plus Strength I" TO WS-CASE
     MOVE "FF77DFAA" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TI-COLOUR
     MOVE 0 TO TI-EFF-VISIBLE(2)
     CALL "TINT-ITEM-COLOR" USING TINT-ITEM
     MOVE "acceptance US11 43§7 Item tint sources: an invisible effect does not count" TO WS-CASE
     MOVE "FF33EBFF" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TI-COLOUR
     MOVE 0 TO TI-EFF-VISIBLE(1)
     CALL "TINT-ITEM-COLOR" USING TINT-ITEM
     MOVE "acceptance US11 43§7 Item tint sources: only invisible effects give the default" TO WS-CASE
     MOVE "FF385DC6" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TI-COLOUR
     MOVE 16711935 TO TI-CUSTOM
     CALL "TINT-ITEM-COLOR" USING TINT-ITEM
     MOVE "acceptance US11 43§7 Item tint sources: a custom colour wins" TO WS-CASE
     MOVE "FFFF00FF" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TI-COLOUR
*>   team: the holder's team colour, else the default.
     INITIALIZE TINT-ITEM
     MOVE 6 TO TI-TYPE
     MOVE 4278255360 TO TI-DEFAULT
     MOVE 12 TO TI-TEAM-ID
     CALL "TINT-ITEM-COLOR" USING TINT-ITEM
     MOVE "acceptance US11 43§7 Item tint sources: team red" TO WS-CASE
     MOVE "FFFF5555" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TI-COLOUR
     MOVE -1 TO TI-TEAM-ID
     CALL "TINT-ITEM-COLOR" USING TINT-ITEM
     MOVE "acceptance US11 43§7 Item tint sources: no team is the opaque default" TO WS-CASE
     MOVE "FF00FF00" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TI-COLOUR
*>   custom_model_data: the colour at the index, else the default.
     INITIALIZE TINT-ITEM
     MOVE 7 TO TI-TYPE
     MOVE 255 TO TI-DEFAULT
     MOVE 2 TO TI-CMD-COUNT
     MOVE 65280 TO TI-CMD-COLOUR(1)
     MOVE 16711680 TO TI-CMD-COLOUR(2)
     MOVE 1 TO TI-INDEX
     CALL "TINT-ITEM-COLOR" USING TINT-ITEM
     MOVE "acceptance US11 43§7 Item tint sources: custom model data index 1" TO WS-CASE
     MOVE "FFFF0000" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TI-COLOUR
     MOVE 2 TO TI-INDEX
     CALL "TINT-ITEM-COLOR" USING TINT-ITEM
     MOVE "acceptance US11 43§7 Item tint sources: custom model data past the list" TO WS-CASE
     MOVE "FF0000FF" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TI-COLOUR
*>   7.1: the item list. oak_leaves layer 0 constant FF48B518, layer 1 untinted.
     MOVE "oak_leaves" TO WS-NAME
     MOVE 0 TO WS-DYED WS-LAYER
     MOVE 1 TO WS-TYPE
     MOVE 4282955032 TO WS-VALUE
     PERFORM CHECK-ITEM
     MOVE 1 TO WS-LAYER
     MOVE 0 TO WS-TYPE
     PERFORM CHECK-ITEM
     MOVE "spruce_leaves" TO WS-NAME
     MOVE 0 TO WS-LAYER
     MOVE 1 TO WS-TYPE
     MOVE 4284586337 TO WS-VALUE
     PERFORM CHECK-ITEM
     MOVE "birch_leaves" TO WS-NAME
     MOVE 4286621525 TO WS-VALUE
     PERFORM CHECK-ITEM
     MOVE "mangrove_leaves" TO WS-NAME
     MOVE 4287809096 TO WS-VALUE
     PERFORM CHECK-ITEM
     MOVE "lily_pad" TO WS-NAME
     MOVE 4285645660 TO WS-VALUE
     PERFORM CHECK-ITEM
     MOVE "vine" TO WS-NAME
     MOVE 4282955032 TO WS-VALUE
     PERFORM CHECK-ITEM
     MOVE "grass_block" TO WS-NAME
     MOVE 3 TO WS-TYPE
     PERFORM CHECK-ITEM
     MOVE "large_fern" TO WS-NAME
     PERFORM CHECK-ITEM
     MOVE "leather_boots" TO WS-NAME
     MOVE 2 TO WS-TYPE
     MOVE 4288701760 TO WS-VALUE
     PERFORM CHECK-ITEM
     MOVE "leather_horse_armor" TO WS-NAME
     PERFORM CHECK-ITEM
     MOVE "splash_potion" TO WS-NAME
     MOVE 5 TO WS-TYPE
     MOVE 4281884102 TO WS-VALUE
     PERFORM CHECK-ITEM
     MOVE "tipped_arrow" TO WS-NAME
     PERFORM CHECK-ITEM
     MOVE "firework_star" TO WS-NAME
     MOVE 1 TO WS-TYPE
     MOVE 4294967295 TO WS-VALUE
     PERFORM CHECK-ITEM
     MOVE 1 TO WS-LAYER
     MOVE 4 TO WS-TYPE
     MOVE 4287269514 TO WS-VALUE
     PERFORM CHECK-ITEM
*>   V15: wolf armour undyed has no tints at all; dyed: layer 0 FFFFFFFF constant, layer 1 dye default 0.
     MOVE "wolf_armor" TO WS-NAME
     MOVE 0 TO WS-DYED WS-LAYER WS-TYPE
     PERFORM CHECK-ITEM
     MOVE 1 TO WS-DYED
     MOVE 1 TO WS-TYPE
     MOVE 4294967295 TO WS-VALUE
     PERFORM CHECK-ITEM
     MOVE 1 TO WS-LAYER
     MOVE 2 TO WS-TYPE
     MOVE 0 TO WS-VALUE
     PERFORM CHECK-ITEM
     MOVE "oak_leaves" TO WS-NAME
     MOVE 0 TO WS-DYED
     MOVE -1 TO WS-LAYER
     MOVE 0 TO WS-TYPE
     PERFORM CHECK-ITEM
*>   Items that are not listed have no tints.
     MOVE "sugar_cane" TO WS-NAME
     MOVE 0 TO WS-DYED WS-LAYER WS-TYPE
     PERFORM CHECK-ITEM
     MOVE "filled_map" TO WS-NAME
     PERFORM CHECK-ITEM
*>   7.2: a layer with no dyeable entry is white; dyeable takes the dye, else the undyed colour
*>   (opaque), else 0 (the layer is not drawn).
     MOVE 0 TO WS-DYEABLE WS-HAS-UNDYED
     MOVE 0 TO WS-UNDYED
     MOVE 4288701760 TO WS-DYE
     CALL "TINT-ARMOUR-LAYER" USING WS-DYEABLE WS-HAS-UNDYED WS-UNDYED WS-DYE WS-COLOUR
     MOVE "acceptance US11 43§7 Item tint sources: 7.2 layer without dyeable is white" TO WS-CASE
     MOVE "FFFFFFFF" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
     MOVE 1 TO WS-DYEABLE
     CALL "TINT-ARMOUR-LAYER" USING WS-DYEABLE WS-HAS-UNDYED WS-UNDYED WS-DYE WS-COLOUR
     MOVE "acceptance US11 43§7 Item tint sources: 7.2 dyeable layer takes the dye" TO WS-CASE
     MOVE "FFA06540" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
     MOVE 0 TO WS-DYE
     MOVE 1 TO WS-HAS-UNDYED
     MOVE 10511680 TO WS-UNDYED
     CALL "TINT-ARMOUR-LAYER" USING WS-DYEABLE WS-HAS-UNDYED WS-UNDYED WS-DYE WS-COLOUR
     MOVE "acceptance US11 43§7 Item tint sources: 7.2 undyed layer takes color_when_undyed" TO WS-CASE
     MOVE "FFA06540" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
     MOVE 0 TO WS-HAS-UNDYED
     CALL "TINT-ARMOUR-LAYER" USING WS-DYEABLE WS-HAS-UNDYED WS-UNDYED WS-DYE WS-COLOUR
     MOVE "acceptance US11 43§7 Item tint sources: 7.2 undyed scute overlay is 0 and skipped"
         TO WS-CASE
     MOVE "00000000" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
*>   7.4: undyed leather with Red then Blue gives AD5398; one red dye gives its own colour.
     INITIALIZE TINT-MIX
     MOVE 2 TO TM-COUNT
     MOVE 14 TO TM-DYE(1)
     MOVE 11 TO TM-DYE(2)
     CALL "TINT-DYE-MIX" USING TINT-MIX
     MOVE TM-RESULT TO WS-COLOUR
     MOVE "acceptance US11 43§7 Item tint sources: 7.4 red then blue is AD5398" TO WS-CASE
     MOVE "00AD5398" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
     MOVE 1 TO TM-COUNT
     CALL "TINT-DYE-MIX" USING TINT-MIX
     MOVE TM-RESULT TO WS-COLOUR
     MOVE "acceptance US11 43§7 Item tint sources: 7.4 one red dye is its own colour" TO WS-CASE
     MOVE "00B02E26" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
     MOVE 1 TO TM-HAS-DYED
     MOVE 11546150 TO TM-DYED
     MOVE 1 TO TM-COUNT
     MOVE 15 TO TM-DYE(1)
     CALL "TINT-DYE-MIX" USING TINT-MIX
     MOVE TM-RESULT TO WS-COLOUR
     MOVE "acceptance US11 43§7 Item tint sources: 7.4 dyed leather with black" TO WS-CASE
     MOVE "00682523" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
     STOP RUN.

*> One row of 7.1: the source of (WS-NAME, WS-DYED, WS-LAYER) is of type WS-TYPE with WS-VALUE
*> (the constant, or the dye, firework or potion default; grass 0.5 and 1.0).
 CHECK-ITEM.
     CALL "TINT-ITEM-SOURCE" USING WS-NAME WS-DYED WS-LAYER TINT-ITEM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US11 43§7 Item tint sources: 7.1 " FUNCTION TRIM(WS-NAME)
         " layer type" DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-TYPE TO TL-EXPECTED-N
     MOVE TI-TYPE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-TYPE NOT = 0 AND WS-TYPE NOT = 3
         MOVE SPACES TO TL-CASE
         STRING "acceptance US11 43§7 Item tint sources: 7.1 " FUNCTION TRIM(WS-NAME)
             " layer value" DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-VALUE TO TL-EXPECTED-N
         IF WS-TYPE = 1
             MOVE TI-VALUE TO TL-OBSERVED-N
         ELSE
             MOVE TI-DEFAULT TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-IF.
 END PROGRAM TEST-TINT-43-7.
 COPY TINTTEST.
