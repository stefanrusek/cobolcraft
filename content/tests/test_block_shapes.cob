*> Test of content/src/block-shapes.cob (T4500 to T4503; docs/protocol/51-block-shapes.md): BSH-BUILD fills the collision and outline
*> shape of every state of the open set by class and property; the shapes are read back as text "x1,y1,z1,x2,y2,z2;..." in
*> thousandths of a pixel ("-" for the empty shape). Also BSH-COLL-ID, BSH-OUT-ID, BSH-OVERLAPS, BSH-CLIP and BSH-RAY.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BLOCK-SHAPES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CTBSHAPE.
 01 WS-STATE               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-DIST                FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-BOX.
    05 WS-B                FLOAT-LONG OCCURS 6 TIMES.
 01 WS-ORG.
    05 WS-O                FLOAT-LONG OCCURS 3 TIMES.
 01 WS-DIR.
    05 WS-D                FLOAT-LONG OCCURS 3 TIMES.
 01 WS-KEY                 PIC X(40).
 01 WS-P1                  PIC X(80).
 01 WS-P2                  PIC X(80).
 01 WS-P3                  PIC X(80).
 01 WS-WHICH               BINARY-LONG.
 01 WS-EXPECT              PIC X(300).
 01 WS-CASE                PIC X(80).
 PROCEDURE DIVISION.
*>   No set open: nothing is built and every state but 0 is a full cube.
     MOVE 0 TO CT-OPEN
     CALL "BSH-BUILD"
     MOVE "shapes: no set, not ready" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE BSH-READY TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE 5 TO WS-STATE
     CALL "BSH-COLL-ID" USING WS-STATE WS-ID
     MOVE "shapes: unbuilt collision of a state is the full cube" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-ID TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE 0 TO WS-STATE
     CALL "BSH-OUT-ID" USING WS-STATE WS-ID
     MOVE "shapes: unbuilt outline of state 0 is empty" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ID TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE 5 TO WS-STATE
     CALL "BSH-OUT-ID" USING WS-STATE WS-ID
     MOVE "shapes: unbuilt outline of a state is the full cube" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-ID TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE 0 TO WS-STATE
     CALL "BSH-COLL-ID" USING WS-STATE WS-ID
     MOVE "shapes: unbuilt collision of state 0 is empty" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ID TO TL-OBSERVED-N
     PERFORM ASSERT-N

     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "BSH-BUILD"
     MOVE "shapes: standard set is ready" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE BSH-READY TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE 99999 TO WS-STATE
     CALL "BSH-COLL-ID" USING WS-STATE WS-ID
     MOVE "shapes: a state beyond the table is the full cube" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-ID TO TL-OBSERVED-N
     PERFORM ASSERT-N

*>   Defaults.
     MOVE "stone" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "stone collision" TO WS-CASE
     MOVE "0,0,0,16000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "stone outline" TO WS-CASE
     PERFORM CHECK-OUT
     MOVE "air" TO WS-KEY
     MOVE "air collision" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "air outline" TO WS-CASE
     PERFORM CHECK-OUT
     MOVE "water" TO WS-KEY
     MOVE "water has no outline" TO WS-CASE
     PERFORM CHECK-OUT
     MOVE "cobweb" TO WS-KEY
     MOVE "cobweb has no collision" TO WS-CASE
     PERFORM CHECK-COLL
     MOVE "cobweb outline is the full cube" TO WS-CASE
     MOVE "0,0,0,16000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT

*>   Slabs.
     MOVE "oak_slab" TO WS-KEY
     MOVE "type=bottom" TO WS-P1
     MOVE "bottom slab collision" TO WS-CASE
     MOVE "0,0,0,16000,8000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "bottom slab outline" TO WS-CASE
     PERFORM CHECK-OUT
     MOVE "type=top" TO WS-P1
     MOVE "top slab collision" TO WS-CASE
     MOVE "0,8000,0,16000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "type=double" TO WS-P1
     MOVE "double slab collision" TO WS-CASE
     MOVE "0,0,0,16000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
*>   Stairs: straight, inner and outer corners, top half.
     MOVE "oak_stairs" TO WS-KEY
     MOVE "facing=north" TO WS-P1
     MOVE "half=bottom" TO WS-P2
     MOVE "shape=straight" TO WS-P3
     MOVE "stairs north straight" TO WS-CASE
     MOVE "0,0,0,16000,8000,16000;0,8000,0,16000,16000,8000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "facing=east" TO WS-P1
     MOVE "stairs east straight" TO WS-CASE
     MOVE "0,0,0,16000,8000,16000;8000,8000,0,16000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "facing=north" TO WS-P1
     MOVE "shape=outer_left" TO WS-P3
     MOVE "stairs north outer_left" TO WS-CASE
     MOVE "0,0,0,16000,8000,16000;0,8000,0,8000,16000,8000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "shape=outer_right" TO WS-P3
     MOVE "stairs north outer_right" TO WS-CASE
     MOVE "0,0,0,16000,8000,16000;8000,8000,0,16000,16000,8000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "shape=inner_right" TO WS-P3
     MOVE "stairs north inner_right" TO WS-CASE
     MOVE "0,0,0,16000,8000,16000;0,8000,0,16000,16000,8000;8000,8000,0,16000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "shape=inner_left" TO WS-P3
     MOVE "stairs north inner_left" TO WS-CASE
     MOVE "0,0,0,16000,8000,16000;0,8000,0,8000,16000,16000;0,8000,0,16000,16000,8000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "half=top" TO WS-P2
     MOVE "shape=straight" TO WS-P3
     MOVE "stairs top north straight" TO WS-CASE
     MOVE "0,8000,0,16000,16000,16000;0,0,0,16000,8000,8000" TO WS-EXPECT
     PERFORM CHECK-COLL

*>   Doors: closed (a panel against the opposite edge), open with each hinge.
     MOVE "oak_door" TO WS-KEY
     MOVE "facing=north" TO WS-P1
     MOVE "open=false" TO WS-P2
     MOVE SPACES TO WS-P3
     MOVE "door closed north" TO WS-CASE
     MOVE "0,0,13000,16000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "open=true" TO WS-P2
     MOVE "hinge=left" TO WS-P3
     MOVE "door open north hinge left" TO WS-CASE
     MOVE "0,0,0,3000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "hinge=right" TO WS-P3
     MOVE "door open north hinge right" TO WS-CASE
     MOVE "13000,0,0,16000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
*>   Trapdoors.
     MOVE "oak_trapdoor" TO WS-KEY
     MOVE "open=false" TO WS-P1
     MOVE "half=bottom" TO WS-P2
     MOVE SPACES TO WS-P3
     MOVE "trapdoor closed bottom" TO WS-CASE
     MOVE "0,0,0,16000,3000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "half=top" TO WS-P2
     MOVE "trapdoor closed top" TO WS-CASE
     MOVE "0,13000,0,16000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "open=true" TO WS-P1
     MOVE "facing=south" TO WS-P2
     MOVE "trapdoor open south" TO WS-CASE
     MOVE "0,0,0,16000,16000,3000" TO WS-EXPECT
     PERFORM CHECK-COLL
*>   Fences, gates, walls, panes.
     MOVE "oak_fence" TO WS-KEY
     MOVE "north=true,east=false,south=false,west=false" TO WS-P1
     MOVE SPACES TO WS-P2 WS-P3
     MOVE "fence collision is 24 high" TO WS-CASE
     MOVE "6000,0,6000,10000,24000,10000;6000,0,0,10000,24000,8000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "fence outline is 16 high" TO WS-CASE
     MOVE "6000,0,6000,10000,16000,10000;6000,0,0,10000,16000,8000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "oak_fence_gate" TO WS-KEY
     MOVE "open=true,in_wall=false" TO WS-P1
     MOVE SPACES TO WS-P2 WS-P3
     MOVE "open gate has no collision" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "open gate keeps its outline" TO WS-CASE
     MOVE "0,0,6000,16000,16000,10000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "open=false" TO WS-P1
     MOVE "in_wall=false" TO WS-P2
     MOVE "closed gate collision" TO WS-CASE
     MOVE "0,0,6000,16000,24000,10000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "closed gate outline" TO WS-CASE
     MOVE "0,0,6000,16000,16000,10000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "in_wall=true" TO WS-P2
     MOVE "in-wall gate outline" TO WS-CASE
     MOVE "0,0,6000,16000,13000,10000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "cobblestone_wall" TO WS-KEY
     MOVE "up=true" TO WS-P1
     MOVE "north=low" TO WS-P2
     MOVE "east=tall" TO WS-P3
     MOVE "wall collision" TO WS-CASE
     MOVE "4000,0,4000,12000,24000,12000;5000,0,0,11000,24000,11000;5000,0,5000,16000,24000,11000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "wall outline" TO WS-CASE
     MOVE "4000,0,4000,12000,16000,12000;5000,0,0,11000,14000,11000;5000,0,5000,16000,16000,11000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "up=false" TO WS-P1
     MOVE "north=none" TO WS-P2
     MOVE "east=none" TO WS-P3
     MOVE "wall with no post and no arm" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "glass_pane" TO WS-KEY
     MOVE "north=false,east=true,south=false,west=false" TO WS-P1
     MOVE SPACES TO WS-P2 WS-P3
     MOVE "pane post and east arm" TO WS-CASE
     MOVE "7000,0,7000,9000,16000,9000;8000,0,7000,16000,16000,9000" TO WS-EXPECT
     PERFORM CHECK-COLL

*>   The no-collision blocks keep an outline.
     MOVE "torch" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "torch has no collision" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "torch outline" TO WS-CASE
     MOVE "6000,0,6000,10000,10000,10000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "wall_torch" TO WS-KEY
     MOVE "facing=east" TO WS-P1
     MOVE "wall torch outline east" TO WS-CASE
     MOVE "0,3000,5500,5000,13000,10500" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "stone_button" TO WS-KEY
     MOVE "face=floor" TO WS-P1
     MOVE "facing=north" TO WS-P2
     MOVE "powered=false" TO WS-P3
     MOVE "button has no collision" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "floor button outline" TO WS-CASE
     MOVE "5000,0,6000,11000,2000,10000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "face=wall" TO WS-P1
     MOVE "powered=true" TO WS-P3
     MOVE "pressed wall button outline" TO WS-CASE
     MOVE "5000,6000,15000,11000,10000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "face=ceiling" TO WS-P1
     MOVE "ceiling button outline" TO WS-CASE
     MOVE "5000,15000,6000,11000,16000,10000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "lever" TO WS-KEY
     MOVE "face=wall" TO WS-P1
     MOVE "facing=north" TO WS-P2
     MOVE SPACES TO WS-P3
     MOVE "lever outline" TO WS-CASE
     MOVE "5000,4000,10000,11000,12000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "ladder" TO WS-KEY
     MOVE "facing=north" TO WS-P1
     MOVE SPACES TO WS-P2
     MOVE "ladder is a thin panel" TO WS-CASE
     MOVE "0,0,13000,16000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "vine" TO WS-KEY
     MOVE "north=true,east=false,south=false,west=false,up=false" TO WS-P1
     MOVE SPACES TO WS-P2
     MOVE "vine outline is a sheet" TO WS-CASE
     MOVE "0,0,0,16000,16000,1000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "vine has no collision" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "north=false,east=false,south=false,west=false,up=false" TO WS-P1
     MOVE "vine with no face set" TO WS-CASE
     MOVE "0,0,0,16000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "glow_lichen" TO WS-KEY
     MOVE "down=true,up=false,north=false,east=false,south=false,west=false" TO WS-P1
     MOVE SPACES TO WS-P2 WS-P3
     MOVE "lichen floor sheet" TO WS-CASE
     MOVE "0,0,0,16000,1000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT

*>   Low blocks, by number and by switch.
     MOVE "snow" TO WS-KEY
     MOVE "layers=1" TO WS-P1
     MOVE SPACES TO WS-P2 WS-P3
     MOVE "one snow layer has no collision" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "one snow layer outline" TO WS-CASE
     MOVE "0,0,0,16000,2000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "layers=8" TO WS-P1
     MOVE "eight snow layers collision" TO WS-CASE
     MOVE "0,0,0,16000,14000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "wheat" TO WS-KEY
     MOVE "age=3" TO WS-P1
     MOVE "wheat outline" TO WS-CASE
     MOVE "0,0,0,16000,8000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "wheat collision" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "farmland" TO WS-KEY
     MOVE SPACES TO WS-P1
     MOVE "farmland is 15 high" TO WS-CASE
     MOVE "0,0,0,16000,15000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "soul_sand" TO WS-KEY
     MOVE "soul sand collision is 14 high" TO WS-CASE
     MOVE "0,0,0,16000,14000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "soul sand outline is the full cube" TO WS-CASE
     MOVE "0,0,0,16000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "white_carpet" TO WS-KEY
     MOVE "carpet is 1 high" TO WS-CASE
     MOVE "0,0,0,16000,1000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "oak_pressure_plate" TO WS-KEY
     MOVE "powered=false" TO WS-P1
     MOVE "plate outline" TO WS-CASE
     MOVE "1000,0,1000,15000,1000,15000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "powered=true" TO WS-P1
     MOVE "pressed plate outline" TO WS-CASE
     MOVE "1000,0,1000,15000,500,15000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "heavy_weighted_pressure_plate" TO WS-KEY
     MOVE "power=0" TO WS-P1
     MOVE "weighted plate released" TO WS-CASE
     MOVE "1000,0,1000,15000,1000,15000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "power=7" TO WS-P1
     MOVE "weighted plate pressed" TO WS-CASE
     MOVE "1000,0,1000,15000,500,15000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "rail" TO WS-KEY
     MOVE "shape=north_south" TO WS-P1
     MOVE "flat rail outline" TO WS-CASE
     MOVE "0,0,0,16000,2000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "shape=ascending_east" TO WS-P1
     MOVE "sloped rail outline" TO WS-CASE
     MOVE "0,0,0,16000,8000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "lantern" TO WS-KEY
     MOVE "hanging=true" TO WS-P1
     MOVE "hanging lantern collision" TO WS-CASE
     MOVE "6000,8000,6000,10000,10000,10000;5000,1000,5000,11000,8000,11000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "hanging=false" TO WS-P1
     MOVE "standing lantern collision" TO WS-CASE
     MOVE "6000,7000,6000,10000,9000,10000;5000,0,5000,11000,7000,11000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "end_rod" TO WS-KEY
     MOVE "facing=up" TO WS-P1
     MOVE "end rod pointing up" TO WS-CASE
     MOVE "6000,0,6000,10000,16000,10000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "anvil" TO WS-KEY
     MOVE "facing=north" TO WS-P1
     MOVE "anvil facing north has 4 boxes" TO WS-CASE
     MOVE "2000,0,2000,14000,4000,14000;4000,4000,3000,12000,5000,13000;6000,5000,4000,10000,10000,12000;3000,10000,0,13000,16000,16000" TO
         WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "iron_chain" TO WS-KEY
     MOVE "axis=y" TO WS-P1
     MOVE "chain along y" TO WS-CASE
     MOVE "6500,0,6500,9500,16000,9500" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "white_candle" TO WS-KEY
     MOVE "candles=3" TO WS-P1
     MOVE "three candles" TO WS-CASE
     MOVE "5000,0,6000,10000,6000,11000" TO WS-EXPECT
     PERFORM CHECK-COLL

*>   Shape queries on a bottom slab at cell (0, 0, 0) (state found by key and property).
     MOVE "oak_slab" TO WS-KEY
     MOVE "type=bottom" TO WS-P1
     MOVE SPACES TO WS-P2 WS-P3
     PERFORM FIND-STATE
     CALL "BSH-COLL-ID" USING WS-STATE WS-ID
     MOVE 0 TO WS-CX WS-CY WS-CZ
     MOVE 0.3 TO WS-B(1)
     MOVE 0.4 TO WS-B(2)
     MOVE 0.3 TO WS-B(3)
     MOVE 0.7 TO WS-B(4)
     MOVE 2.15 TO WS-B(5)
     MOVE 0.7 TO WS-B(6)
     CALL "BSH-OVERLAPS" USING WS-ID WS-CX WS-CY WS-CZ WS-BOX WS-HIT
     MOVE "overlap: a body inside the lower half hits the slab" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-HIT TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE 0.5 TO WS-B(2)
     CALL "BSH-OVERLAPS" USING WS-ID WS-CX WS-CY WS-CZ WS-BOX WS-HIT
     MOVE "overlap: a body standing on the slab does not" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-HIT TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE 1 TO WS-B(2)
     MOVE 2.75 TO WS-B(5)
     MOVE -1 TO WS-DIST
     MOVE 2 TO WS-AXIS
     CALL "BSH-CLIP" USING WS-ID WS-CX WS-CY WS-CZ WS-BOX WS-AXIS WS-DIST
     MOVE "clip: falling onto the slab stops at its top" TO TL-CASE
     MOVE -0.5 TO WS-T
     PERFORM ASSERT-FLOAT
     MOVE 3 TO WS-AXIS
     MOVE 0.2 TO WS-B(1)
     MOVE 0.55 TO WS-B(4)
     MOVE 0.7 TO WS-B(3)
     MOVE 1.05 TO WS-B(6)
     MOVE 0.6 TO WS-B(2)
     MOVE 2.35 TO WS-B(5)
     MOVE -2 TO WS-DIST
     CALL "BSH-CLIP" USING WS-ID WS-CX WS-CY WS-CZ WS-BOX WS-AXIS WS-DIST
     MOVE "clip: a body above the slab walks past it" TO TL-CASE
     MOVE -2 TO WS-T
     PERFORM ASSERT-FLOAT
     MOVE 0.1 TO WS-B(2)
     MOVE 1.85 TO WS-B(5)
     MOVE 0.2 TO WS-B(1)
     MOVE -0.5 TO WS-B(3)
     MOVE -0.15 TO WS-B(6)
     MOVE 2 TO WS-DIST
     CALL "BSH-CLIP" USING WS-ID WS-CX WS-CY WS-CZ WS-BOX WS-AXIS WS-DIST
     MOVE "clip: walking into the side of the slab stops at its face" TO TL-CASE
     MOVE 0.15 TO WS-T
     PERFORM ASSERT-FLOAT
     MOVE 0.1 TO WS-B(2)
     MOVE 1.85 TO WS-B(5)
     MOVE 1.15 TO WS-B(3)
     MOVE 1.5 TO WS-B(6)
     MOVE -2 TO WS-DIST
     CALL "BSH-CLIP" USING WS-ID WS-CX WS-CY WS-CZ WS-BOX WS-AXIS WS-DIST
     MOVE "clip: walking back into the slab stops at its far face" TO TL-CASE
     MOVE -0.15 TO WS-T
     PERFORM ASSERT-FLOAT

     MOVE 0.5 TO WS-O(1) WS-O(3)
     MOVE 1.5 TO WS-O(2)
     MOVE 0 TO WS-D(1) WS-D(3)
     MOVE -1 TO WS-D(2)
     CALL "BSH-RAY" USING WS-ID WS-CX WS-CY WS-CZ WS-ORG WS-DIR WS-T WS-AXIS
     MOVE "ray: down onto the slab hits its top face at 1.0" TO TL-CASE
     MOVE 1 TO WS-DIST
     MOVE WS-T TO TL-OBSERVED-N
     PERFORM ASSERT-RAY
     MOVE "ray: the face axis is y" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-AXIS TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE 0.75 TO WS-O(2)
     MOVE -2 TO WS-O(1)
     MOVE 1 TO WS-D(1)
     MOVE 0 TO WS-D(2)
     CALL "BSH-RAY" USING WS-ID WS-CX WS-CY WS-CZ WS-ORG WS-DIR WS-T WS-AXIS
     MOVE "ray: along the cell above the slab misses it" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     MOVE WS-T TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE 0.25 TO WS-O(2)
     CALL "BSH-RAY" USING WS-ID WS-CX WS-CY WS-CZ WS-ORG WS-DIR WS-T WS-AXIS
     MOVE "ray: along the lower half enters the west face at 2.0" TO TL-CASE
     MOVE 2 TO WS-DIST
     MOVE WS-T TO TL-OBSERVED-N
     PERFORM ASSERT-RAY
     MOVE 1 TO TL-EXPECTED-N
     MOVE "ray: the face axis is x" TO TL-CASE
     MOVE WS-AXIS TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE 1.5 TO WS-O(3)
     CALL "BSH-RAY" USING WS-ID WS-CX WS-CY WS-CZ WS-ORG WS-DIR WS-T WS-AXIS
     MOVE "ray: a parallel ray outside the cell misses" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     MOVE WS-T TO TL-OBSERVED-N
     PERFORM ASSERT-N

*>   Two boxes: the nearer one wins the ray (an inner stair seen from the side).
     MOVE "oak_stairs" TO WS-KEY
     MOVE "facing=north" TO WS-P1
     MOVE "half=bottom" TO WS-P2
     MOVE "shape=straight" TO WS-P3
     PERFORM FIND-STATE
     CALL "BSH-OUT-ID" USING WS-STATE WS-ID
     MOVE 0.5 TO WS-O(1)
     MOVE 0.75 TO WS-O(2)
     MOVE -2 TO WS-O(3)
     MOVE 0 TO WS-D(1) WS-D(2)
     MOVE 1 TO WS-D(3)
     CALL "BSH-RAY" USING WS-ID WS-CX WS-CY WS-CZ WS-ORG WS-DIR WS-T WS-AXIS
     MOVE "ray: a stair step upper box is entered first" TO TL-CASE
     MOVE 2 TO WS-DIST
     MOVE WS-T TO TL-OBSERVED-N
     PERFORM ASSERT-RAY
     MOVE 0.75 TO WS-O(2)
     MOVE 2 TO WS-O(3)
     MOVE -1 TO WS-D(3)
     CALL "BSH-RAY" USING WS-ID WS-CX WS-CY WS-CZ WS-ORG WS-DIR WS-T WS-AXIS
     MOVE "ray: from the other side the upper box is met at its back face" TO TL-CASE
     MOVE 1.5 TO WS-DIST
     MOVE WS-T TO TL-OBSERVED-N
     PERFORM ASSERT-RAY

*>   The shape table is full: a new shape is the full cube.
     MOVE 2000 TO BSH-COUNT
     INITIALIZE BSC-SHAPE
     MOVE 1 TO BSC-N
     MOVE 1234 TO BSC-V(1, 4)
     MOVE 16000 TO BSC-V(1, 5) BSC-V(1, 6)
     CALL "BSH-INTERN" USING WS-ID
     MOVE "shapes: a full table answers the full cube" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-ID TO TL-OBSERVED-N
     PERFORM ASSERT-N
     GOBACK.

 FIND-STATE.
     CALL "BSH-TEST-FIND" USING WS-KEY WS-P1 WS-P2 WS-P3 WS-STATE.

 CHECK-COLL.
     PERFORM FIND-STATE
     CALL "BSH-COLL-ID" USING WS-STATE WS-ID
     CALL "BSH-TEST-TEXT" USING WS-ID TL-OBSERVED
     PERFORM ASSERT-SHAPE.

 CHECK-OUT.
     PERFORM FIND-STATE
     CALL "BSH-OUT-ID" USING WS-STATE WS-ID
     CALL "BSH-TEST-TEXT" USING WS-ID TL-OBSERVED
     PERFORM ASSERT-SHAPE.

 ASSERT-SHAPE.
     MOVE "T" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-N.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> A float expected in WS-T against the distance WS-DIST (to a millionth).
 ASSERT-FLOAT.
     COMPUTE TL-EXPECTED-N ROUNDED = WS-T * 1000000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-DIST * 1000000
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> The ray distance WS-DIST expected against the observed one (set in TL-OBSERVED-N as the float itself).
 ASSERT-RAY.
     COMPUTE TL-EXPECTED-N ROUNDED = WS-DIST * 1000000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-T * 1000000
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-BLOCK-SHAPES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSH-TEST-FIND.
*> USING block key, three texts of comma separated "name=value" constraints (spaces = none), state out: the first state of the block
*> that holds them all.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CTPROPS.
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 PIC X(819).
 01 WS-VIEW REDEFINES WS-ROW.
    05 FILLER              PIC X(359).
    05 WS-R-COUNT          PIC X(4).
    05 WS-R-FIRST          PIC X(5).
    05 FILLER              PIC X(451).
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-STATES              BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-LIST                PIC X(120).
 01 WS-POINTER             BINARY-LONG.
 01 WS-WANT                PIC X(40).
 01 WS-HAVE                PIC X(60).
 LINKAGE SECTION.
 01 L-KEY                  PIC X(40).
 01 L-P1                   PIC X(80).
 01 L-P2                   PIC X(80).
 01 L-P3                   PIC X(80).
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-P1 L-P2 L-P3 L-STATE.
     MOVE L-KEY TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     COMPUTE WS-FIRST = FUNCTION NUMVAL(WS-R-FIRST)
     COMPUTE WS-STATES = FUNCTION NUMVAL(WS-R-COUNT)
     MOVE SPACES TO WS-LIST
     STRING FUNCTION TRIM(L-P1) "," FUNCTION TRIM(L-P2) "," FUNCTION TRIM(L-P3) "," DELIMITED BY SIZE INTO WS-LIST
     MOVE WS-FIRST TO L-STATE
     MOVE 0 TO WS-OK
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-STATES OR WS-OK = 1
         COMPUTE WS-STATE = WS-FIRST + WS-I
         CALL "CONTENT-STATE-PROPS" USING WS-STATE CT-PROPS WS-STATUS
         MOVE 1 TO WS-OK
         MOVE 1 TO WS-POINTER
         PERFORM UNTIL WS-POINTER > 120
             MOVE SPACES TO WS-WANT
             UNSTRING WS-LIST DELIMITED BY "," INTO WS-WANT WITH POINTER WS-POINTER
             IF WS-WANT NOT = SPACES
                 MOVE 0 TO WS-HAS
                 PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > CTP-COUNT
                     MOVE SPACES TO WS-HAVE
                     STRING FUNCTION TRIM(CTP-NAME(WS-J)) "=" FUNCTION TRIM(CTP-VALUE(WS-J)) DELIMITED BY SIZE INTO WS-HAVE
                     IF WS-HAVE = WS-WANT
                         MOVE 1 TO WS-HAS
                     END-IF
                 END-PERFORM
                 IF WS-HAS = 0
                     MOVE 0 TO WS-OK
                 END-IF
             END-IF
         END-PERFORM
         IF WS-OK = 1
             MOVE WS-STATE TO L-STATE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BSH-TEST-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSH-TEST-TEXT.
*> USING shape id, text out (PIC X(1024)): "x1,y1,z1,x2,y2,z2" per box, joined by ";"; "-" for the empty shape.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTBSHAPE.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-NUMBER              PIC -(8)9.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING L-ID L-TEXT.
     MOVE SPACES TO L-TEXT
     MOVE 1 TO WS-POS
     IF BSH-N(L-ID + 1) = 0
         MOVE "-" TO L-TEXT
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BSH-N(L-ID + 1)
         IF WS-I > 1
             MOVE ";" TO L-TEXT(WS-POS:1)
             ADD 1 TO WS-POS
         END-IF
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
             IF WS-K > 1
                 MOVE "," TO L-TEXT(WS-POS:1)
                 ADD 1 TO WS-POS
             END-IF
             MOVE BSH-V(L-ID + 1, WS-I, WS-K) TO WS-NUMBER
             STRING FUNCTION TRIM(WS-NUMBER) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-POS
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM BSH-TEST-TEXT.
