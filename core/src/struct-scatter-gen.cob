*> Generated geometry tables of the scattered feature pieces (docs/protocol/36-structures-4-scattered-and-small.md sections 3 to 5): one line per operation of the document's tables, in order,
*> run by SCP-RUN (core/src/struct-scatter.cob). Ops: B/K x0 y0 z0 x1 y1 z1 edge fill (generateBox, K = skipAir); R x0 y0 z0 x1 y1 z1 (generateBox with the moss selector, 4.2);
*> P spec x y z ... (placeBlock); F spec x0 z0 x1 z1 y (fillColumnDown per column, x outer); D n spec x y z table (createDispenser, flag n); H n x y z table (createChest, flag n).
*> A spec is a block name (without minecraft:) with optional [property=value,...] in the piece's local north frame; rotation and mirror are applied by SCP-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCP-HUT-POST.
*> postProcess of the swamp hut (5.2 steps 1 to 5, then 5.4 and 44-2 10.7): when the world position of local (2, 2, 5) is inside the write box, one persistent witch and one persistent cat are
*> asked of the entity channel at the centre of that block (yaw 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
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
 01 WS-LX                  BINARY-LONG VALUE 2.
 01 WS-LY                  BINARY-LONG VALUE 2.
 01 WS-LZ                  BINARY-LONG VALUE 5.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-WITCH               PIC X(32) VALUE "minecraft:witch".
 01 WS-CAT                 PIC X(32) VALUE "minecraft:cat".
 01 WS-PERSISTENT          BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "SCP-RUN" USING L-ROW WS-OPS WS-COUNT
     CALL "SPB-WORLD" USING L-ROW WS-LX WS-LY WS-LZ WS-WX WS-WY WS-WZ
     CALL "SPB-BOX-INSIDE" USING SP-WBOX WS-WX WS-WY WS-WZ WS-IN
     IF WS-IN = 1
         COMPUTE WS-FX = WS-WX + 0.5
         MOVE WS-WY TO WS-FY
         COMPUTE WS-FZ = WS-WZ + 0.5
         CALL "GENT-ADD-MOB" USING WS-FX WS-FY WS-FZ WS-WITCH WS-PERSISTENT
         CALL "GENT-ADD-MOB" USING WS-FX WS-FY WS-FZ WS-CAT WS-PERSISTENT
     END-IF
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

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCP-DESERT-A.
*> the desert pyramid's blocks (3.3 steps 1 to 20), the four chests (3.4), the stairs of the cellar (C1) and the fixed sand of C2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OPS.
    05 FILLER              PIC X(100) VALUE "B 0 -4 0 20 0 20 sandstone sandstone".
    05 FILLER              PIC X(100) VALUE "B 1 1 1 19 1 19 sandstone sandstone".
    05 FILLER              PIC X(100) VALUE "B 2 1 2 18 1 18 air air".
    05 FILLER              PIC X(100) VALUE "B 2 2 2 18 2 18 sandstone sandstone".
    05 FILLER              PIC X(100) VALUE "B 3 2 3 17 2 17 air air".
    05 FILLER              PIC X(100) VALUE "B 3 3 3 17 3 17 sandstone sandstone".
    05 FILLER              PIC X(100) VALUE "B 4 3 4 16 3 16 air air".
    05 FILLER              PIC X(100) VALUE "B 4 4 4 16 4 16 sandstone sandstone".
    05 FILLER              PIC X(100) VALUE "B 5 4 5 15 4 15 air air".
    05 FILLER              PIC X(100) VALUE "B 5 5 5 15 5 15 sandstone sandstone".
    05 FILLER              PIC X(100) VALUE "B 6 5 6 14 5 14 air air".
    05 FILLER              PIC X(100) VALUE "B 6 6 6 14 6 14 sandstone sandstone".
    05 FILLER              PIC X(100) VALUE "B 7 6 7 13 6 13 air air".
    05 FILLER              PIC X(100) VALUE "B 7 7 7 13 7 13 sandstone sandstone".
    05 FILLER              PIC X(100) VALUE "B 8 7 8 12 7 12 air air".
    05 FILLER              PIC X(100) VALUE "B 8 8 8 12 8 12 sandstone sandstone".
    05 FILLER              PIC X(100) VALUE "B 9 8 9 11 8 11 air air".
    05 FILLER              PIC X(100) VALUE "B 9 9 9 11 9 11 sandstone sandstone".
    05 FILLER              PIC X(100) VALUE "B 10 9 10 10 9 10 air air".
    05 FILLER              PIC X(100) VALUE "F sandstone 0 0 20 20 -5".
    05 FILLER              PIC X(100) VALUE "B 0 0 0 4 9 4 sandstone air".
    05 FILLER              PIC X(100) VALUE "B 1 10 1 3 10 3 sandstone sandstone".
    05 FILLER              PIC X(100) VALUE "P sandstone_stairs[facing=north] 2 10 0".
    05 FILLER              PIC X(100) VALUE "P sandstone_stairs[facing=south] 2 10 4".
    05 FILLER              PIC X(100) VALUE "P sandstone_stairs[facing=east] 0 10 2".
    05 FILLER              PIC X(100) VALUE "P sandstone_stairs[facing=west] 4 10 2".
    05 FILLER              PIC X(100) VALUE "B 16 0 0 20 9 4 sandstone air".
    05 FILLER              PIC X(100) VALUE "B 17 10 1 19 10 3 sandstone sandstone".
    05 FILLER              PIC X(100) VALUE "P sandstone_stairs[facing=north] 18 10 0".
    05 FILLER              PIC X(100) VALUE "P sandstone_stairs[facing=south] 18 10 4".
    05 FILLER              PIC X(100) VALUE "P sandstone_stairs[facing=east] 16 10 2".
    05 FILLER              PIC X(100) VALUE "P sandstone_stairs[facing=west] 20 10 2".
    05 FILLER              PIC X(100) VALUE "B 8 0 0 12 4 4 sandstone air".
    05 FILLER              PIC X(100) VALUE "B 9 1 0 11 3 4 air air".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 9 1 1 9 2 1 9 3 1 10 3 1 11 3 1 11 2 1".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 11 1 1".
    05 FILLER              PIC X(100) VALUE "B 4 1 1 8 3 3 sandstone air".
    05 FILLER              PIC X(100) VALUE "B 4 1 2 8 2 2 air air".
    05 FILLER              PIC X(100) VALUE "B 12 1 1 16 3 3 sandstone air".
    05 FILLER              PIC X(100) VALUE "B 12 1 2 16 2 2 air air".
    05 FILLER              PIC X(100) VALUE "B 5 4 5 15 4 15 sandstone sandstone".
    05 FILLER              PIC X(100) VALUE "B 9 4 9 11 4 11 air air".
    05 FILLER              PIC X(100) VALUE "B 8 1 8 8 3 8 cut_sandstone cut_sandstone".
    05 FILLER              PIC X(100) VALUE "B 12 1 8 12 3 8 cut_sandstone cut_sandstone".
    05 FILLER              PIC X(100) VALUE "B 8 1 12 8 3 12 cut_sandstone cut_sandstone".
    05 FILLER              PIC X(100) VALUE "B 12 1 12 12 3 12 cut_sandstone cut_sandstone".
    05 FILLER              PIC X(100) VALUE "B 1 1 5 4 4 11 sandstone sandstone".
    05 FILLER              PIC X(100) VALUE "B 16 1 5 19 4 11 sandstone sandstone".
    05 FILLER              PIC X(100) VALUE "B 6 7 9 6 7 11 sandstone sandstone".
    05 FILLER              PIC X(100) VALUE "B 14 7 9 14 7 11 sandstone sandstone".
    05 FILLER              PIC X(100) VALUE "B 5 5 9 5 7 11 cut_sandstone cut_sandstone".
    05 FILLER              PIC X(100) VALUE "B 15 5 9 15 7 11 cut_sandstone cut_sandstone".
    05 FILLER              PIC X(100) VALUE "P air 5 5 10 5 6 10 6 6 10 15 5 10 15 6 10 14 6 10".
    05 FILLER              PIC X(100) VALUE "B 2 4 4 2 6 4 air air".
    05 FILLER              PIC X(100) VALUE "B 18 4 4 18 6 4 air air".
    05 FILLER              PIC X(100) VALUE "P sandstone_stairs[facing=north] 2 4 5 2 3 4 18 4 5 18 3 4".
    05 FILLER              PIC X(100) VALUE "B 1 1 3 2 2 3 sandstone sandstone".
    05 FILLER              PIC X(100) VALUE "B 18 1 3 19 2 3 sandstone sandstone".
    05 FILLER              PIC X(100) VALUE "P sandstone 1 1 2 19 1 2".
    05 FILLER              PIC X(100) VALUE "P sandstone_slab 1 2 2 19 2 2".
    05 FILLER              PIC X(100) VALUE "P sandstone_stairs[facing=west] 2 1 2".
    05 FILLER              PIC X(100) VALUE "P sandstone_stairs[facing=east] 18 1 2".
    05 FILLER              PIC X(100) VALUE "B 4 3 5 4 3 17 sandstone sandstone".
    05 FILLER              PIC X(100) VALUE "B 16 3 5 16 3 17 sandstone sandstone".
    05 FILLER              PIC X(100) VALUE "B 3 1 5 4 2 16 air air".
    05 FILLER              PIC X(100) VALUE "B 15 1 5 16 2 16 air air".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 4 1 5 16 1 5".
    05 FILLER              PIC X(100) VALUE "P chiseled_sandstone 4 2 5 16 2 5".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 4 1 7 16 1 7".
    05 FILLER              PIC X(100) VALUE "P chiseled_sandstone 4 2 7 16 2 7".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 4 1 9 16 1 9".
    05 FILLER              PIC X(100) VALUE "P chiseled_sandstone 4 2 9 16 2 9".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 4 1 11 16 1 11".
    05 FILLER              PIC X(100) VALUE "P chiseled_sandstone 4 2 11 16 2 11".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 4 1 13 16 1 13".
    05 FILLER              PIC X(100) VALUE "P chiseled_sandstone 4 2 13 16 2 13".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 4 1 15 16 1 15".
    05 FILLER              PIC X(100) VALUE "P chiseled_sandstone 4 2 15 16 2 15".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 4 1 17 16 1 17".
    05 FILLER              PIC X(100) VALUE "P chiseled_sandstone 4 2 17 16 2 17".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 10 0 7 10 0 8 9 0 9 11 0 9 8 0 10 12 0 10".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 7 0 10 13 0 10 9 0 11 11 0 11 10 0 12 10 0 13".
    05 FILLER              PIC X(100) VALUE "P blue_terracotta 10 0 10".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 0 2 1".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 0 2 2".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 0 2 3".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 0 3 1".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 0 3 2".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 0 3 3".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 0 4 1".
    05 FILLER              PIC X(100) VALUE "P chiseled_sandstone 0 4 2".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 0 4 3".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 0 5 1".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 0 5 2".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 0 5 3".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 0 6 1".
    05 FILLER              PIC X(100) VALUE "P chiseled_sandstone 0 6 2".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 0 6 3".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 0 7 1".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 0 7 2".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 0 7 3".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 0 8 1".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 0 8 2".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 0 8 3".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 20 2 1".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 20 2 2".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 20 2 3".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 20 3 1".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 20 3 2".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 20 3 3".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 20 4 1".
    05 FILLER              PIC X(100) VALUE "P chiseled_sandstone 20 4 2".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 20 4 3".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 20 5 1".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 20 5 2".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 20 5 3".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 20 6 1".
    05 FILLER              PIC X(100) VALUE "P chiseled_sandstone 20 6 2".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 20 6 3".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 20 7 1".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 20 7 2".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 20 7 3".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 20 8 1".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 20 8 2".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 20 8 3".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 1 2 0".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 2 2 0".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 3 2 0".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 1 3 0".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 2 3 0".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 3 3 0".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 1 4 0".
    05 FILLER              PIC X(100) VALUE "P chiseled_sandstone 2 4 0".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 3 4 0".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 1 5 0".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 2 5 0".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 3 5 0".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 1 6 0".
    05 FILLER              PIC X(100) VALUE "P chiseled_sandstone 2 6 0".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 3 6 0".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 1 7 0".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 2 7 0".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 3 7 0".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 1 8 0".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 2 8 0".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 3 8 0".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 17 2 0".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 18 2 0".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 19 2 0".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 17 3 0".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 18 3 0".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 19 3 0".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 17 4 0".
    05 FILLER              PIC X(100) VALUE "P chiseled_sandstone 18 4 0".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 19 4 0".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 17 5 0".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 18 5 0".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 19 5 0".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 17 6 0".
    05 FILLER              PIC X(100) VALUE "P chiseled_sandstone 18 6 0".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 19 6 0".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 17 7 0".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 18 7 0".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 19 7 0".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 17 8 0".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 18 8 0".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 19 8 0".
    05 FILLER              PIC X(100) VALUE "B 8 4 0 12 6 0 cut_sandstone cut_sandstone".
    05 FILLER              PIC X(100) VALUE "P air 8 6 0 12 6 0".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 9 5 0 11 5 0".
    05 FILLER              PIC X(100) VALUE "P chiseled_sandstone 10 5 0".
    05 FILLER              PIC X(100) VALUE "B 8 -14 8 12 -11 12 cut_sandstone cut_sandstone".
    05 FILLER              PIC X(100) VALUE "B 8 -10 8 12 -10 12 chiseled_sandstone chiseled_sandstone".
    05 FILLER              PIC X(100) VALUE "B 8 -9 8 12 -9 12 cut_sandstone cut_sandstone".
    05 FILLER              PIC X(100) VALUE "B 8 -8 8 12 -1 12 sandstone sandstone".
    05 FILLER              PIC X(100) VALUE "B 9 -11 9 11 -1 11 air air".
    05 FILLER              PIC X(100) VALUE "P stone_pressure_plate 10 -11 10".
    05 FILLER              PIC X(100) VALUE "B 9 -13 9 11 -13 11 tnt air".
    05 FILLER              PIC X(100) VALUE "P air 8 -11 10 8 -10 10".
    05 FILLER              PIC X(100) VALUE "P chiseled_sandstone 7 -10 10".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 7 -11 10".
    05 FILLER              PIC X(100) VALUE "P air 12 -11 10 12 -10 10".
    05 FILLER              PIC X(100) VALUE "P chiseled_sandstone 13 -10 10".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 13 -11 10".
    05 FILLER              PIC X(100) VALUE "P air 10 -11 8 10 -10 8".
    05 FILLER              PIC X(100) VALUE "P chiseled_sandstone 10 -10 7".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 10 -11 7".
    05 FILLER              PIC X(100) VALUE "P air 10 -11 12 10 -10 12".
    05 FILLER              PIC X(100) VALUE "P chiseled_sandstone 10 -10 13".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 10 -11 13".
    05 FILLER              PIC X(100) VALUE "H 1 10 -11 8 minecraft:chests/desert_pyramid".
    05 FILLER              PIC X(100) VALUE "H 2 12 -11 10 minecraft:chests/desert_pyramid".
    05 FILLER              PIC X(100) VALUE "H 3 10 -11 12 minecraft:chests/desert_pyramid".
    05 FILLER              PIC X(100) VALUE "H 4 8 -11 10 minecraft:chests/desert_pyramid".
    05 FILLER              PIC X(100) VALUE "P sandstone_stairs[facing=west] 13 -1 17 14 -2 17 15 -3 17".
    05 FILLER              PIC X(100) VALUE "P sand 12 0 17 13 0 17 14 0 17 15 0 17 16 0 17".
    05 FILLER              PIC X(100) VALUE "P sand 14 -1 17".
    05 FILLER              PIC X(100) VALUE "P sand 15 -2 17".
    05 FILLER              PIC X(100) VALUE "P sandstone 16 -2 17".
    05 FILLER              PIC X(100) VALUE "P sand 16 -3 17".
 01 WS-COUNT               BINARY-LONG VALUE 200.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "SCP-RUN" USING L-ROW WS-OPS WS-COUNT
     GOBACK.
 END PROGRAM SCP-DESERT-A.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCP-DESERT-B.
*> the cellar's walls (3.4 C3, generateBox with skipAir).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OPS.
    05 FILLER              PIC X(100) VALUE "K 13 -3 10 13 -3 15 cut_sandstone cut_sandstone".
    05 FILLER              PIC X(100) VALUE "K 19 -3 10 19 -3 15 cut_sandstone cut_sandstone".
    05 FILLER              PIC X(100) VALUE "K 13 -3 10 19 -3 11 cut_sandstone cut_sandstone".
    05 FILLER              PIC X(100) VALUE "K 13 -3 16 19 -3 16 cut_sandstone cut_sandstone".
    05 FILLER              PIC X(100) VALUE "K 13 -2 10 13 -2 15 chiseled_sandstone chiseled_sandstone".
    05 FILLER              PIC X(100) VALUE "K 19 -2 10 19 -2 15 chiseled_sandstone chiseled_sandstone".
    05 FILLER              PIC X(100) VALUE "K 13 -2 10 19 -2 11 chiseled_sandstone chiseled_sandstone".
    05 FILLER              PIC X(100) VALUE "K 13 -2 16 19 -2 16 chiseled_sandstone chiseled_sandstone".
    05 FILLER              PIC X(100) VALUE "K 13 -1 10 13 -1 15 cut_sandstone cut_sandstone".
    05 FILLER              PIC X(100) VALUE "K 19 -1 10 19 -1 15 cut_sandstone cut_sandstone".
    05 FILLER              PIC X(100) VALUE "K 13 -1 10 19 -1 11 cut_sandstone cut_sandstone".
    05 FILLER              PIC X(100) VALUE "K 13 -1 16 19 -1 16 cut_sandstone cut_sandstone".
 01 WS-COUNT               BINARY-LONG VALUE 12.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "SCP-RUN" USING L-ROW WS-OPS WS-COUNT
     GOBACK.
 END PROGRAM SCP-DESERT-B.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCP-DESERT-C.
*> the cellar's floor and arms (3.4 C5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OPS.
    05 FILLER              PIC X(100) VALUE "P blue_terracotta 16 -4 13".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 17 -4 12 17 -4 14 15 -4 12 15 -4 14 18 -4 13 14 -4 13".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 16 -4 15 16 -4 11".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 19 -4 13".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 20 -3 13".
    05 FILLER              PIC X(100) VALUE "P chiseled_sandstone 20 -2 13".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 13 -4 13".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 12 -3 13".
    05 FILLER              PIC X(100) VALUE "P chiseled_sandstone 12 -2 13".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 16 -4 16".
    05 FILLER              PIC X(100) VALUE "P orange_terracotta 16 -4 10".
    05 FILLER              PIC X(100) VALUE "P cut_sandstone 16 -3 9".
    05 FILLER              PIC X(100) VALUE "P chiseled_sandstone 16 -2 9".
 01 WS-COUNT               BINARY-LONG VALUE 13.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "SCP-RUN" USING L-ROW WS-OPS WS-COUNT
     GOBACK.
 END PROGRAM SCP-DESERT-C.
