*> Generated geometry tables of the scattered feature pieces (docs/protocol/36-structures-4-scattered-and-small.md sections 3 to 5): one line per operation of the document's tables, in order,
*> run by SCP-RUN (core/src/struct-scatter.cob). Ops: B/K x0 y0 z0 x1 y1 z1 edge fill (generateBox, K = skipAir); R x0 y0 z0 x1 y1 z1 (generateBox with the moss selector, 4.2);
*> P spec x y z ... (placeBlock); F spec x0 z0 x1 z1 y (fillColumnDown per column, x outer); D n spec x y z table (createDispenser, flag n); H n x y z table (createChest, flag n).
*> A spec is a block name (without minecraft:) with optional [property=value,...] in the piece's local north frame; rotation and mirror are applied by SCP-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCP-HUT-POST.
*> postProcess of the swamp hut (5.2 steps 1 to 5; the witch and the cat of 5.4 are not made: no entity channel).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OPS.
    05 FILLER              PIC X(100) VALUE "B 1 1 1 5 1 7 spruce_planks spruce_planks".
    05 FILLER              PIC X(100) VALUE "B 1 4 2 5 4 7 spruce_planks spruce_planks".
    05 FILLER              PIC X(100) VALUE "B 2 1 0 4 1 0 spruce_planks spruce_planks".
    05 FILLER              PIC X(100) VALUE "B 2 2 2 3 3 2 spruce_planks spruce_planks".
    05 FILLER              PIC X(100) VALUE "B 1 2 3 1 3 6 spruce_planks spruce_planks".
    05 FILLER              PIC X(100) VALUE "B 5 2 3 5 3 6 spruce_planks spruce_planks".
    05 FILLER              PIC X(100) VALUE "B 2 2 7 4 3 7 spruce_planks spruce_planks".
    05 FILLER              PIC X(100) VALUE "B 1 0 2 1 3 2 oak_log oak_log".
    05 FILLER              PIC X(100) VALUE "B 5 0 2 5 3 2 oak_log oak_log".
    05 FILLER              PIC X(100) VALUE "B 1 0 7 1 3 7 oak_log oak_log".
    05 FILLER              PIC X(100) VALUE "B 5 0 7 5 3 7 oak_log oak_log".
    05 FILLER              PIC X(100) VALUE "P oak_fence 2 3 2 3 3 7".
    05 FILLER              PIC X(100) VALUE "P air 1 3 4 5 3 4 5 3 5".
    05 FILLER              PIC X(100) VALUE "P potted_red_mushroom 1 3 5".
    05 FILLER              PIC X(100) VALUE "P crafting_table 3 2 6".
    05 FILLER              PIC X(100) VALUE "P cauldron 4 2 6".
    05 FILLER              PIC X(100) VALUE "P oak_fence 1 2 1 5 2 1".
    05 FILLER              PIC X(100) VALUE "B 0 4 1 6 4 1 spruce_stairs[facing=north] spruce_stairs[facing=north]".
    05 FILLER              PIC X(100) VALUE "B 0 4 2 0 4 7 spruce_stairs[facing=east] spruce_stairs[facing=east]".
    05 FILLER              PIC X(100) VALUE "B 6 4 2 6 4 7 spruce_stairs[facing=west] spruce_stairs[facing=west]".
    05 FILLER              PIC X(100) VALUE "B 0 4 8 6 4 8 spruce_stairs[facing=south] spruce_stairs[facing=south]".
    05 FILLER              PIC X(100) VALUE "P spruce_stairs[facing=north,shape=outer_right] 0 4 1".
    05 FILLER              PIC X(100) VALUE "P spruce_stairs[facing=north,shape=outer_left] 6 4 1".
    05 FILLER              PIC X(100) VALUE "P spruce_stairs[facing=south,shape=outer_left] 0 4 8".
    05 FILLER              PIC X(100) VALUE "P spruce_stairs[facing=south,shape=outer_right] 6 4 8".
    05 FILLER              PIC X(100) VALUE "F oak_log 1 2 1 2 -1".
    05 FILLER              PIC X(100) VALUE "F oak_log 5 2 5 2 -1".
    05 FILLER              PIC X(100) VALUE "F oak_log 1 7 1 7 -1".
    05 FILLER              PIC X(100) VALUE "F oak_log 5 7 5 7 -1".
 01 WS-COUNT               BINARY-LONG VALUE 29.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "SCP-RUN" USING L-ROW WS-OPS WS-COUNT
     GOBACK.
 END PROGRAM SCP-HUT-POST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCP-JUNGLE-POST.
*> postProcess of the jungle temple (4.2, 4.3, 4.4 steps 1 to 21).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OPS.
    05 FILLER              PIC X(100) VALUE "R 0 -4 0 11 0 14".
    05 FILLER              PIC X(100) VALUE "R 2 1 2 9 2 2".
    05 FILLER              PIC X(100) VALUE "R 2 1 12 9 2 12".
    05 FILLER              PIC X(100) VALUE "R 2 1 3 2 2 11".
    05 FILLER              PIC X(100) VALUE "R 9 1 3 9 2 11".
    05 FILLER              PIC X(100) VALUE "R 1 3 1 10 6 1".
    05 FILLER              PIC X(100) VALUE "R 1 3 13 10 6 13".
    05 FILLER              PIC X(100) VALUE "R 1 3 2 1 6 12".
    05 FILLER              PIC X(100) VALUE "R 10 3 2 10 6 12".
    05 FILLER              PIC X(100) VALUE "R 2 3 2 9 3 12".
    05 FILLER              PIC X(100) VALUE "R 2 6 2 9 6 12".
    05 FILLER              PIC X(100) VALUE "R 3 7 3 8 7 11".
    05 FILLER              PIC X(100) VALUE "R 4 8 4 7 8 10".
    05 FILLER              PIC X(100) VALUE "B 3 1 3 8 2 11 air air".
    05 FILLER              PIC X(100) VALUE "B 4 3 6 7 3 9 air air".
    05 FILLER              PIC X(100) VALUE "B 2 4 2 9 5 12 air air".
    05 FILLER              PIC X(100) VALUE "B 4 6 5 7 6 9 air air".
    05 FILLER              PIC X(100) VALUE "B 5 7 6 6 7 8 air air".
    05 FILLER              PIC X(100) VALUE "B 5 1 2 6 2 2 air air".
    05 FILLER              PIC X(100) VALUE "B 5 2 12 6 2 12 air air".
    05 FILLER              PIC X(100) VALUE "B 5 5 1 6 5 1 air air".
    05 FILLER              PIC X(100) VALUE "B 5 5 13 6 5 13 air air".
    05 FILLER              PIC X(100) VALUE "P air 1 5 5 10 5 5 1 5 9 10 5 9".
    05 FILLER              PIC X(100) VALUE "R 2 4 0 2 5 0".
    05 FILLER              PIC X(100) VALUE "R 4 4 0 4 5 0".
    05 FILLER              PIC X(100) VALUE "R 7 4 0 7 5 0".
    05 FILLER              PIC X(100) VALUE "R 9 4 0 9 5 0".
    05 FILLER              PIC X(100) VALUE "R 2 4 14 2 5 14".
    05 FILLER              PIC X(100) VALUE "R 4 4 14 4 5 14".
    05 FILLER              PIC X(100) VALUE "R 7 4 14 7 5 14".
    05 FILLER              PIC X(100) VALUE "R 9 4 14 9 5 14".
    05 FILLER              PIC X(100) VALUE "R 5 6 0 6 6 0".
    05 FILLER              PIC X(100) VALUE "R 0 4 2 0 5 2".
    05 FILLER              PIC X(100) VALUE "R 0 4 4 0 5 4".
    05 FILLER              PIC X(100) VALUE "R 0 4 6 0 5 6".
    05 FILLER              PIC X(100) VALUE "R 0 4 8 0 5 8".
    05 FILLER              PIC X(100) VALUE "R 0 4 10 0 5 10".
    05 FILLER              PIC X(100) VALUE "R 0 4 12 0 5 12".
    05 FILLER              PIC X(100) VALUE "R 0 6 5 0 6 5".
    05 FILLER              PIC X(100) VALUE "R 0 6 9 0 6 9".
    05 FILLER              PIC X(100) VALUE "R 11 4 2 11 5 2".
    05 FILLER              PIC X(100) VALUE "R 11 4 4 11 5 4".
    05 FILLER              PIC X(100) VALUE "R 11 4 6 11 5 6".
    05 FILLER              PIC X(100) VALUE "R 11 4 8 11 5 8".
    05 FILLER              PIC X(100) VALUE "R 11 4 10 11 5 10".
    05 FILLER              PIC X(100) VALUE "R 11 4 12 11 5 12".
    05 FILLER              PIC X(100) VALUE "R 11 6 5 11 6 5".
    05 FILLER              PIC X(100) VALUE "R 11 6 9 11 6 9".
    05 FILLER              PIC X(100) VALUE "R 2 7 2 2 9 2".
    05 FILLER              PIC X(100) VALUE "R 9 7 2 9 9 2".
    05 FILLER              PIC X(100) VALUE "R 2 7 12 2 9 12".
    05 FILLER              PIC X(100) VALUE "R 9 7 12 9 9 12".
    05 FILLER              PIC X(100) VALUE "R 4 9 4 4 9 4".
    05 FILLER              PIC X(100) VALUE "R 7 9 4 7 9 4".
    05 FILLER              PIC X(100) VALUE "R 4 9 10 4 9 10".
    05 FILLER              PIC X(100) VALUE "R 7 9 10 7 9 10".
    05 FILLER              PIC X(100) VALUE "R 5 9 7 6 9 7".
    05 FILLER              PIC X(100) VALUE "P cobblestone_stairs[facing=north] 5 9 6 6 9 6".
    05 FILLER              PIC X(100) VALUE "P cobblestone_stairs[facing=south] 5 9 8 6 9 8".
    05 FILLER              PIC X(100) VALUE "P cobblestone_stairs[facing=north] 4 0 0 5 0 0 6 0 0 7 0 0".
    05 FILLER              PIC X(100) VALUE "P cobblestone_stairs[facing=north] 4 1 8 4 2 9 4 3 10".
    05 FILLER              PIC X(100) VALUE "P cobblestone_stairs[facing=north] 7 1 8 7 2 9 7 3 10".
    05 FILLER              PIC X(100) VALUE "R 4 1 9 4 1 9".
    05 FILLER              PIC X(100) VALUE "R 7 1 9 7 1 9".
    05 FILLER              PIC X(100) VALUE "R 4 1 10 7 2 10".
    05 FILLER              PIC X(100) VALUE "R 5 4 5 6 4 5".
    05 FILLER              PIC X(100) VALUE "P cobblestone_stairs[facing=east] 4 4 5".
    05 FILLER              PIC X(100) VALUE "P cobblestone_stairs[facing=west] 7 4 5".
    05 FILLER              PIC X(100) VALUE "P cobblestone_stairs[facing=south] 5 0 6 6 0 6".
    05 FILLER              PIC X(100) VALUE "B 5 0 7 6 0 9 air air".
    05 FILLER              PIC X(100) VALUE "P cobblestone_stairs[facing=south] 5 -1 7 6 -1 7".
    05 FILLER              PIC X(100) VALUE "B 5 -1 8 6 -1 10 air air".
    05 FILLER              PIC X(100) VALUE "P cobblestone_stairs[facing=south] 5 -2 8 6 -2 8".
    05 FILLER              PIC X(100) VALUE "B 5 -2 9 6 -2 11 air air".
    05 FILLER              PIC X(100) VALUE "P cobblestone_stairs[facing=south] 5 -3 9 6 -3 9".
    05 FILLER              PIC X(100) VALUE "B 5 -3 10 6 -3 12 air air".
    05 FILLER              PIC X(100) VALUE "B 1 -3 12 10 -1 13 air air".
    05 FILLER              PIC X(100) VALUE "B 1 -3 1 3 -1 13 air air".
    05 FILLER              PIC X(100) VALUE "B 1 -3 1 9 -1 5 air air".
    05 FILLER              PIC X(100) VALUE "R 1 -3 1 1 -2 1".
    05 FILLER              PIC X(100) VALUE "R 1 -3 3 1 -2 3".
    05 FILLER              PIC X(100) VALUE "R 1 -3 5 1 -2 5".
    05 FILLER              PIC X(100) VALUE "R 1 -3 7 1 -2 7".
    05 FILLER              PIC X(100) VALUE "R 1 -3 9 1 -2 9".
    05 FILLER              PIC X(100) VALUE "R 1 -3 11 1 -2 11".
    05 FILLER              PIC X(100) VALUE "R 1 -3 13 1 -2 13".
    05 FILLER              PIC X(100) VALUE "R 1 -1 2 3 -1 2".
    05 FILLER              PIC X(100) VALUE "R 1 -1 4 3 -1 4".
    05 FILLER              PIC X(100) VALUE "R 1 -1 6 3 -1 6".
    05 FILLER              PIC X(100) VALUE "R 1 -1 8 3 -1 8".
    05 FILLER              PIC X(100) VALUE "R 1 -1 10 3 -1 10".
    05 FILLER              PIC X(100) VALUE "R 1 -1 12 3 -1 12".
    05 FILLER              PIC X(100) VALUE "R 2 -2 1 5 -2 1".
    05 FILLER              PIC X(100) VALUE "R 7 -2 1 9 -2 1".
    05 FILLER              PIC X(100) VALUE "R 6 -3 1 6 -3 1".
    05 FILLER              PIC X(100) VALUE "R 6 -1 1 6 -1 1".
    05 FILLER              PIC X(100) VALUE "P tripwire_hook[facing=east,attached=true] 1 -3 8".
    05 FILLER              PIC X(100) VALUE "P tripwire_hook[facing=west,attached=true] 4 -3 8".
    05 FILLER              PIC X(100) VALUE "P tripwire[east=true,west=true,attached=true] 2 -3 8 3 -3 8".
    05 FILLER              PIC X(100) VALUE "P redstone_wire[north=side,south=side] 5 -3 7 5 -3 6 5 -3 5 5 -3 4 5 -3 3 5 -3 2".
    05 FILLER              PIC X(100) VALUE "P redstone_wire[north=side,west=side] 5 -3 1".
    05 FILLER              PIC X(100) VALUE "P redstone_wire[east=side,west=side] 4 -3 1".
    05 FILLER              PIC X(100) VALUE "P mossy_cobblestone 3 -3 1".
    05 FILLER              PIC X(100) VALUE "D 1 dispenser[facing=north] 3 -2 1 minecraft:chests/jungle_temple_dispenser".
    05 FILLER              PIC X(100) VALUE "P vine[south=true] 3 -2 2".
    05 FILLER              PIC X(100) VALUE "P tripwire_hook[facing=north,attached=true] 7 -3 1".
    05 FILLER              PIC X(100) VALUE "P tripwire_hook[facing=south,attached=true] 7 -3 5".
    05 FILLER              PIC X(100) VALUE "P tripwire[north=true,south=true,attached=true] 7 -3 2 7 -3 3 7 -3 4".
    05 FILLER              PIC X(100) VALUE "P redstone_wire[east=side,west=side] 8 -3 6".
    05 FILLER              PIC X(100) VALUE "P redstone_wire[west=side,south=side] 9 -3 6".
    05 FILLER              PIC X(100) VALUE "P redstone_wire[north=side,south=up] 9 -3 5".
    05 FILLER              PIC X(100) VALUE "P mossy_cobblestone 9 -3 4".
    05 FILLER              PIC X(100) VALUE "P redstone_wire[north=side,south=side] 9 -2 4".
    05 FILLER              PIC X(100) VALUE "D 2 dispenser[facing=west] 9 -2 3 minecraft:chests/jungle_temple_dispenser".
    05 FILLER              PIC X(100) VALUE "P vine[east=true] 8 -1 3 8 -2 3".
    05 FILLER              PIC X(100) VALUE "H 3 8 -3 3 minecraft:chests/jungle_temple".
    05 FILLER              PIC X(100) VALUE "P mossy_cobblestone 9 -3 2 8 -3 1 4 -3 5 5 -2 5 5 -1 5 6 -3 5".
    05 FILLER              PIC X(100) VALUE "P mossy_cobblestone 7 -2 5 7 -1 5 8 -3 5".
    05 FILLER              PIC X(100) VALUE "R 9 -1 1 9 -1 5".
    05 FILLER              PIC X(100) VALUE "B 8 -3 8 10 -1 10 air air".
    05 FILLER              PIC X(100) VALUE "P chiseled_stone_bricks 8 -2 11 9 -2 11 10 -2 11".
    05 FILLER              PIC X(100) VALUE "P lever[facing=north,face=wall] 8 -2 12 9 -2 12 10 -2 12".
    05 FILLER              PIC X(100) VALUE "R 8 -3 8 8 -3 10".
    05 FILLER              PIC X(100) VALUE "R 10 -3 8 10 -3 10".
    05 FILLER              PIC X(100) VALUE "P mossy_cobblestone 10 -2 9".
    05 FILLER              PIC X(100) VALUE "P redstone_wire[north=side,south=side] 8 -2 9 8 -2 10".
    05 FILLER              PIC X(100) VALUE "P redstone_wire[north=side,south=side,east=side,west=side] 10 -1 9".
    05 FILLER              PIC X(100) VALUE "P sticky_piston[facing=up] 9 -2 8".
    05 FILLER              PIC X(100) VALUE "P sticky_piston[facing=west] 10 -2 8 10 -1 8".
    05 FILLER              PIC X(100) VALUE "P repeater[facing=north] 10 -2 10".
    05 FILLER              PIC X(100) VALUE "H 4 9 -3 10 minecraft:chests/jungle_temple".
 01 WS-COUNT               BINARY-LONG VALUE 131.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "SCP-RUN" USING L-ROW WS-OPS WS-COUNT
     GOBACK.
 END PROGRAM SCP-JUNGLE-POST.
