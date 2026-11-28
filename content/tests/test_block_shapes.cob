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
 01 WS-I                   BINARY-LONG.
 01 WS-OCX                 BINARY-LONG.
 01 WS-OCY                 BINARY-LONG.
 01 WS-OCZ                 BINARY-LONG.
 01 WS-EXP-X               BINARY-LONG.
 01 WS-EXP-Y               BINARY-LONG.
 01 WS-EXP-Z               BINARY-LONG.
 01 WS-OX                  FLOAT-LONG.
 01 WS-OY                  FLOAT-LONG.
 01 WS-OZ                  FLOAT-LONG.
 01 WS-SLIP-TABLE.
    05 FILLER PIC X(40) VALUE "ice".
    05 FILLER BINARY-LONG VALUE 980.
    05 FILLER PIC X(40) VALUE "packed_ice".
    05 FILLER BINARY-LONG VALUE 980.
    05 FILLER PIC X(40) VALUE "frosted_ice".
    05 FILLER BINARY-LONG VALUE 980.
    05 FILLER PIC X(40) VALUE "blue_ice".
    05 FILLER BINARY-LONG VALUE 989.
    05 FILLER PIC X(40) VALUE "slime_block".
    05 FILLER BINARY-LONG VALUE 800.
    05 FILLER PIC X(40) VALUE "stone".
    05 FILLER BINARY-LONG VALUE 0.
 01 WS-SLIP REDEFINES WS-SLIP-TABLE.
    05 WS-SLIP-ROW OCCURS 6 TIMES.
       10 WS-SLIP-KEY      PIC X(40).
       10 WS-SLIP-WANT     BINARY-LONG.
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
     MOVE 77 TO BSH-COUNT
     CALL "BSH-BUILD"
     MOVE "shapes: a set already built is not built again" TO TL-CASE
     MOVE 77 TO TL-EXPECTED-N
     MOVE BSH-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE 0 TO BSH-TYPE
     CALL "BSH-BUILD"
     MOVE "shapes: a built set of another type is built again" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE BSH-TYPE TO TL-OBSERVED-N
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

*>   The climbable states (24 part 1 section 12).
     MOVE "ladder" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     PERFORM FIND-STATE
     MOVE "shapes: a ladder state is climbable" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE BSH-CLIMB(WS-STATE + 1) TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE "stone" TO WS-KEY
     PERFORM FIND-STATE
     MOVE "shapes: a stone state is not climbable" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE BSH-CLIMB(WS-STATE + 1) TO TL-OBSERVED-N
     PERFORM ASSERT-N

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
*>   The height an entity box rests on (BSH-TOP-OVER, lane bugbed): the top of the part the box overlaps, nothing when it only stands on it.
     MOVE 0.4 TO WS-B(2)
     MOVE 2.15 TO WS-B(5)
     MOVE 1 TO WS-B(3)
     MOVE 0.3 TO WS-B(1)
     MOVE 0.7 TO WS-B(4)
     MOVE 0.3 TO WS-B(3)
     MOVE 0.7 TO WS-B(6)
     CALL "BSH-TOP-OVER" USING WS-ID WS-CX WS-CY WS-CZ WS-BOX WS-T
     MOVE "top over: a body inside the lower half of the slab rests on its top, 0.5" TO TL-CASE
     MOVE WS-T TO WS-DIST
     MOVE 0.5 TO WS-T
     PERFORM ASSERT-FLOAT
     MOVE 0.5 TO WS-B(2)
     MOVE 2.25 TO WS-B(5)
     CALL "BSH-TOP-OVER" USING WS-ID WS-CX WS-CY WS-CZ WS-BOX WS-T
     MOVE "top over: a body that only stands on the slab overlaps nothing (-1000000)" TO TL-CASE
     MOVE WS-T TO WS-DIST
     MOVE -1000000 TO WS-T
     PERFORM ASSERT-FLOAT
*>   BSH-TOP (lane p70e's entry point, BSH-TOP-OVER with a hit flag): the same boxes, hit 1 and the top 0.5 inside the slab, hit 0 and top 0 standing on it.
     MOVE 0.4 TO WS-B(2)
     MOVE 2.15 TO WS-B(5)
     CALL "BSH-TOP" USING WS-ID WS-CX WS-CY WS-CZ WS-BOX WS-HIT WS-T
     MOVE "top: a body inside the lower half of the slab hits it and rests on 0.5" TO TL-CASE
     COMPUTE TL-OBSERVED-N ROUNDED = WS-HIT * 1000000 + WS-T * 1000
     MOVE 1000500 TO TL-EXPECTED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.5 TO WS-B(2)
     MOVE 2.25 TO WS-B(5)
     CALL "BSH-TOP" USING WS-ID WS-CX WS-CY WS-CZ WS-BOX WS-HIT WS-T
     MOVE "top: a body that only stands on the slab hits nothing (hit 0, top 0)" TO TL-CASE
     COMPUTE TL-OBSERVED-N ROUNDED = WS-HIT * 1000000 + WS-T * 1000
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
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

*>   T4506: the shapes of 51 section 3 that the tables did not hold (expected boxes computed by an independent script from the rule rows and the
*>   rotation formulas of section 2; a box in thousandths of a pixel).
     MOVE "moving_piston" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "T4506 moving piston has no shape (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "moving_piston" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "T4506 moving piston has no shape (out)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "candle_cake" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "lit=false" TO WS-P1
     MOVE "T4506 candle cake (coll)" TO WS-CASE
     MOVE "1000,0,1000,15000,8000,15000;7000,8000,7000,9000,14000," & "9000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "candle_cake" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "lit=false" TO WS-P1
     MOVE "T4506 candle cake (out)" TO WS-CASE
     MOVE "1000,0,1000,15000,8000,15000;7000,8000,7000,9000,14000," & "9000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "tripwire_hook" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=east" TO WS-P1
     MOVE "T4506 tripwire hook east (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "tripwire_hook" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=east" TO WS-P1
     MOVE "T4506 tripwire hook east (out)" TO WS-CASE
     MOVE "0,0,5000,6000,10000,11000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "amethyst_cluster" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=up" TO WS-P1
     MOVE "T4506 amethyst_cluster facing up (coll)" TO WS-CASE
     MOVE "3000,0,3000,13000,7000,13000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "amethyst_cluster" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=up" TO WS-P1
     MOVE "T4506 amethyst_cluster facing up (out)" TO WS-CASE
     MOVE "3000,0,3000,13000,7000,13000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "amethyst_cluster" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=down" TO WS-P1
     MOVE "T4506 amethyst_cluster facing down (coll)" TO WS-CASE
     MOVE "3000,9000,3000,13000,16000,13000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "amethyst_cluster" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=down" TO WS-P1
     MOVE "T4506 amethyst_cluster facing down (out)" TO WS-CASE
     MOVE "3000,9000,3000,13000,16000,13000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "amethyst_cluster" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=east" TO WS-P1
     MOVE "T4506 amethyst_cluster facing east (coll)" TO WS-CASE
     MOVE "0,3000,3000,7000,13000,13000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "amethyst_cluster" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=east" TO WS-P1
     MOVE "T4506 amethyst_cluster facing east (out)" TO WS-CASE
     MOVE "0,3000,3000,7000,13000,13000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "amethyst_cluster" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=north" TO WS-P1
     MOVE "T4506 amethyst_cluster facing north (coll)" TO WS-CASE
     MOVE "3000,3000,9000,13000,13000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "amethyst_cluster" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=north" TO WS-P1
     MOVE "T4506 amethyst_cluster facing north (out)" TO WS-CASE
     MOVE "3000,3000,9000,13000,13000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "large_amethyst_bud" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=up" TO WS-P1
     MOVE "T4506 large_amethyst_bud facing up (coll)" TO WS-CASE
     MOVE "3000,0,3000,13000,5000,13000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "large_amethyst_bud" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=up" TO WS-P1
     MOVE "T4506 large_amethyst_bud facing up (out)" TO WS-CASE
     MOVE "3000,0,3000,13000,5000,13000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "large_amethyst_bud" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=down" TO WS-P1
     MOVE "T4506 large_amethyst_bud facing down (coll)" TO WS-CASE
     MOVE "3000,11000,3000,13000,16000,13000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "large_amethyst_bud" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=down" TO WS-P1
     MOVE "T4506 large_amethyst_bud facing down (out)" TO WS-CASE
     MOVE "3000,11000,3000,13000,16000,13000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "large_amethyst_bud" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=east" TO WS-P1
     MOVE "T4506 large_amethyst_bud facing east (coll)" TO WS-CASE
     MOVE "0,3000,3000,5000,13000,13000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "large_amethyst_bud" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=east" TO WS-P1
     MOVE "T4506 large_amethyst_bud facing east (out)" TO WS-CASE
     MOVE "0,3000,3000,5000,13000,13000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "large_amethyst_bud" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=north" TO WS-P1
     MOVE "T4506 large_amethyst_bud facing north (coll)" TO WS-CASE
     MOVE "3000,3000,11000,13000,13000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "large_amethyst_bud" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=north" TO WS-P1
     MOVE "T4506 large_amethyst_bud facing north (out)" TO WS-CASE
     MOVE "3000,3000,11000,13000,13000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "medium_amethyst_bud" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=up" TO WS-P1
     MOVE "T4506 medium_amethyst_bud facing up (coll)" TO WS-CASE
     MOVE "3000,0,3000,13000,4000,13000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "medium_amethyst_bud" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=up" TO WS-P1
     MOVE "T4506 medium_amethyst_bud facing up (out)" TO WS-CASE
     MOVE "3000,0,3000,13000,4000,13000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "medium_amethyst_bud" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=down" TO WS-P1
     MOVE "T4506 medium_amethyst_bud facing down (coll)" TO WS-CASE
     MOVE "3000,12000,3000,13000,16000,13000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "medium_amethyst_bud" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=down" TO WS-P1
     MOVE "T4506 medium_amethyst_bud facing down (out)" TO WS-CASE
     MOVE "3000,12000,3000,13000,16000,13000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "medium_amethyst_bud" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=east" TO WS-P1
     MOVE "T4506 medium_amethyst_bud facing east (coll)" TO WS-CASE
     MOVE "0,3000,3000,4000,13000,13000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "medium_amethyst_bud" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=east" TO WS-P1
     MOVE "T4506 medium_amethyst_bud facing east (out)" TO WS-CASE
     MOVE "0,3000,3000,4000,13000,13000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "medium_amethyst_bud" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=north" TO WS-P1
     MOVE "T4506 medium_amethyst_bud facing north (coll)" TO WS-CASE
     MOVE "3000,3000,12000,13000,13000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "medium_amethyst_bud" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=north" TO WS-P1
     MOVE "T4506 medium_amethyst_bud facing north (out)" TO WS-CASE
     MOVE "3000,3000,12000,13000,13000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "small_amethyst_bud" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=up" TO WS-P1
     MOVE "T4506 small_amethyst_bud facing up (coll)" TO WS-CASE
     MOVE "4000,0,4000,12000,3000,12000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "small_amethyst_bud" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=up" TO WS-P1
     MOVE "T4506 small_amethyst_bud facing up (out)" TO WS-CASE
     MOVE "4000,0,4000,12000,3000,12000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "small_amethyst_bud" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=down" TO WS-P1
     MOVE "T4506 small_amethyst_bud facing down (coll)" TO WS-CASE
     MOVE "4000,13000,4000,12000,16000,12000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "small_amethyst_bud" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=down" TO WS-P1
     MOVE "T4506 small_amethyst_bud facing down (out)" TO WS-CASE
     MOVE "4000,13000,4000,12000,16000,12000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "small_amethyst_bud" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=east" TO WS-P1
     MOVE "T4506 small_amethyst_bud facing east (coll)" TO WS-CASE
     MOVE "0,4000,4000,3000,12000,12000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "small_amethyst_bud" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=east" TO WS-P1
     MOVE "T4506 small_amethyst_bud facing east (out)" TO WS-CASE
     MOVE "0,4000,4000,3000,12000,12000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "small_amethyst_bud" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=north" TO WS-P1
     MOVE "T4506 small_amethyst_bud facing north (coll)" TO WS-CASE
     MOVE "4000,4000,13000,12000,12000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "small_amethyst_bud" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=north" TO WS-P1
     MOVE "T4506 small_amethyst_bud facing north (out)" TO WS-CASE
     MOVE "4000,4000,13000,12000,12000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "piston" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "extended=true,facing=up" TO WS-P1
     MOVE "T4506 piston extended facing up (coll)" TO WS-CASE
     MOVE "0,0,0,16000,12000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "piston" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "extended=true,facing=up" TO WS-P1
     MOVE "T4506 piston extended facing up (out)" TO WS-CASE
     MOVE "0,0,0,16000,12000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "piston" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "extended=true,facing=down" TO WS-P1
     MOVE "T4506 piston extended facing down (coll)" TO WS-CASE
     MOVE "0,4000,0,16000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "piston" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "extended=true,facing=down" TO WS-P1
     MOVE "T4506 piston extended facing down (out)" TO WS-CASE
     MOVE "0,4000,0,16000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "piston" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "extended=true,facing=east" TO WS-P1
     MOVE "T4506 piston extended facing east (coll)" TO WS-CASE
     MOVE "0,0,0,12000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "piston" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "extended=true,facing=east" TO WS-P1
     MOVE "T4506 piston extended facing east (out)" TO WS-CASE
     MOVE "0,0,0,12000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "piston" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "extended=true,facing=south" TO WS-P1
     MOVE "T4506 piston extended facing south (coll)" TO WS-CASE
     MOVE "0,0,0,16000,16000,12000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "piston" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "extended=true,facing=south" TO WS-P1
     MOVE "T4506 piston extended facing south (out)" TO WS-CASE
     MOVE "0,0,0,16000,16000,12000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "piston" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "extended=true,facing=west" TO WS-P1
     MOVE "T4506 piston extended facing west (coll)" TO WS-CASE
     MOVE "4000,0,0,16000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "piston" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "extended=true,facing=west" TO WS-P1
     MOVE "T4506 piston extended facing west (out)" TO WS-CASE
     MOVE "4000,0,0,16000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "piston" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "extended=true,facing=north" TO WS-P1
     MOVE "T4506 piston extended facing north (coll)" TO WS-CASE
     MOVE "0,0,4000,16000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "piston" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "extended=true,facing=north" TO WS-P1
     MOVE "T4506 piston extended facing north (out)" TO WS-CASE
     MOVE "0,0,4000,16000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "piston" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "extended=false,facing=up" TO WS-P1
     MOVE "T4506 piston retracted is a full cube (coll)" TO WS-CASE
     MOVE "0,0,0,16000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "piston" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "extended=false,facing=up" TO WS-P1
     MOVE "T4506 piston retracted is a full cube (out)" TO WS-CASE
     MOVE "0,0,0,16000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "sticky_piston" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "extended=true,facing=up" TO WS-P1
     MOVE "T4506 sticky_piston extended facing up (coll)" TO WS-CASE
     MOVE "0,0,0,16000,12000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "sticky_piston" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "extended=true,facing=up" TO WS-P1
     MOVE "T4506 sticky_piston extended facing up (out)" TO WS-CASE
     MOVE "0,0,0,16000,12000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "sticky_piston" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "extended=true,facing=down" TO WS-P1
     MOVE "T4506 sticky_piston extended facing down (coll)" TO WS-CASE
     MOVE "0,4000,0,16000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "sticky_piston" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "extended=true,facing=down" TO WS-P1
     MOVE "T4506 sticky_piston extended facing down (out)" TO WS-CASE
     MOVE "0,4000,0,16000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "sticky_piston" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "extended=true,facing=east" TO WS-P1
     MOVE "T4506 sticky_piston extended facing east (coll)" TO WS-CASE
     MOVE "0,0,0,12000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "sticky_piston" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "extended=true,facing=east" TO WS-P1
     MOVE "T4506 sticky_piston extended facing east (out)" TO WS-CASE
     MOVE "0,0,0,12000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "sticky_piston" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "extended=true,facing=south" TO WS-P1
     MOVE "T4506 sticky_piston extended facing south (coll)" TO WS-CASE
     MOVE "0,0,0,16000,16000,12000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "sticky_piston" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "extended=true,facing=south" TO WS-P1
     MOVE "T4506 sticky_piston extended facing south (out)" TO WS-CASE
     MOVE "0,0,0,16000,16000,12000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "sticky_piston" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "extended=true,facing=west" TO WS-P1
     MOVE "T4506 sticky_piston extended facing west (coll)" TO WS-CASE
     MOVE "4000,0,0,16000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "sticky_piston" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "extended=true,facing=west" TO WS-P1
     MOVE "T4506 sticky_piston extended facing west (out)" TO WS-CASE
     MOVE "4000,0,0,16000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "sticky_piston" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "extended=true,facing=north" TO WS-P1
     MOVE "T4506 sticky_piston extended facing north (coll)" TO WS-CASE
     MOVE "0,0,4000,16000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "sticky_piston" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "extended=true,facing=north" TO WS-P1
     MOVE "T4506 sticky_piston extended facing north (out)" TO WS-CASE
     MOVE "0,0,4000,16000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "sticky_piston" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "extended=false,facing=up" TO WS-P1
     MOVE "T4506 sticky_piston retracted is a full cube (coll)" TO WS-CASE
     MOVE "0,0,0,16000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "sticky_piston" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "extended=false,facing=up" TO WS-P1
     MOVE "T4506 sticky_piston retracted is a full cube (out)" TO WS-CASE
     MOVE "0,0,0,16000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "copper_golem_statue" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=east" TO WS-P1
     MOVE "T4506 copper_golem_statue (coll)" TO WS-CASE
     MOVE "3000,0,3000,13000,14000,13000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "copper_golem_statue" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=east" TO WS-P1
     MOVE "T4506 copper_golem_statue (out)" TO WS-CASE
     MOVE "3000,0,3000,13000,14000,13000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "exposed_copper_golem_statue" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=east" TO WS-P1
     MOVE "T4506 exposed_copper_golem_statue (coll)" TO WS-CASE
     MOVE "3000,0,3000,13000,14000,13000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "exposed_copper_golem_statue" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=east" TO WS-P1
     MOVE "T4506 exposed_copper_golem_statue (out)" TO WS-CASE
     MOVE "3000,0,3000,13000,14000,13000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "oak_shelf" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=north" TO WS-P1
     MOVE "T4506 oak shelf facing north (coll)" TO WS-CASE
     MOVE "0,0,13000,16000,16000,16000;0,12000,11000,16000,16000,1" & "3000;0,0,11000,16000,4000,13000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "oak_shelf" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=north" TO WS-P1
     MOVE "T4506 oak shelf facing north (out)" TO WS-CASE
     MOVE "0,0,13000,16000,16000,16000;0,12000,11000,16000,16000,1" & "3000;0,0,11000,16000,4000,13000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "oak_shelf" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=east" TO WS-P1
     MOVE "T4506 oak shelf facing east (coll)" TO WS-CASE
     MOVE "0,0,0,3000,16000,16000;3000,12000,0,5000,16000,16000;30" & "00,0,0,5000,4000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "oak_shelf" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=east" TO WS-P1
     MOVE "T4506 oak shelf facing east (out)" TO WS-CASE
     MOVE "0,0,0,3000,16000,16000;3000,12000,0,5000,16000,16000;30" & "00,0,0,5000,4000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "attached_pumpkin_stem" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=north" TO WS-P1
     MOVE "T4506 attached pumpkin stem facing north (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "attached_pumpkin_stem" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=north" TO WS-P1
     MOVE "T4506 attached pumpkin stem facing north (out)" TO WS-CASE
     MOVE "6000,0,0,10000,10000,10000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "attached_pumpkin_stem" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=west" TO WS-P1
     MOVE "T4506 attached pumpkin stem facing west (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "attached_pumpkin_stem" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=west" TO WS-P1
     MOVE "T4506 attached pumpkin stem facing west (out)" TO WS-CASE
     MOVE "0,0,6000,10000,10000,10000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "cocoa" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "age=0,facing=south" TO WS-P1
     MOVE "T4506 cocoa age 0 facing south (coll)" TO WS-CASE
     MOVE "6000,7000,11000,10000,12000,15000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "cocoa" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "age=0,facing=south" TO WS-P1
     MOVE "T4506 cocoa age 0 facing south (out)" TO WS-CASE
     MOVE "6000,7000,11000,10000,12000,15000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "cocoa" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "age=0,facing=east" TO WS-P1
     MOVE "T4506 cocoa age 0 facing east (coll)" TO WS-CASE
     MOVE "11000,7000,6000,15000,12000,10000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "cocoa" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "age=0,facing=east" TO WS-P1
     MOVE "T4506 cocoa age 0 facing east (out)" TO WS-CASE
     MOVE "11000,7000,6000,15000,12000,10000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "cocoa" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "age=1,facing=south" TO WS-P1
     MOVE "T4506 cocoa age 1 facing south (coll)" TO WS-CASE
     MOVE "5000,5000,9000,11000,12000,15000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "cocoa" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "age=1,facing=south" TO WS-P1
     MOVE "T4506 cocoa age 1 facing south (out)" TO WS-CASE
     MOVE "5000,5000,9000,11000,12000,15000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "cocoa" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "age=1,facing=east" TO WS-P1
     MOVE "T4506 cocoa age 1 facing east (coll)" TO WS-CASE
     MOVE "9000,5000,5000,15000,12000,11000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "cocoa" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "age=1,facing=east" TO WS-P1
     MOVE "T4506 cocoa age 1 facing east (out)" TO WS-CASE
     MOVE "9000,5000,5000,15000,12000,11000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "cocoa" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "age=2,facing=south" TO WS-P1
     MOVE "T4506 cocoa age 2 facing south (coll)" TO WS-CASE
     MOVE "4000,3000,7000,12000,12000,15000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "cocoa" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "age=2,facing=south" TO WS-P1
     MOVE "T4506 cocoa age 2 facing south (out)" TO WS-CASE
     MOVE "4000,3000,7000,12000,12000,15000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "cocoa" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "age=2,facing=east" TO WS-P1
     MOVE "T4506 cocoa age 2 facing east (coll)" TO WS-CASE
     MOVE "7000,3000,4000,15000,12000,12000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "cocoa" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "age=2,facing=east" TO WS-P1
     MOVE "T4506 cocoa age 2 facing east (out)" TO WS-CASE
     MOVE "7000,3000,4000,15000,12000,12000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "shelf_mushroom" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "age=0,facing=west" TO WS-P1
     MOVE "T4506 shelf mushroom age 0 facing west (coll)" TO WS-CASE
     MOVE "9000,9000,3000,16000,11000,13000;12000,8000,5000,16000," & "9000,11000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "shelf_mushroom" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "age=0,facing=west" TO WS-P1
     MOVE "T4506 shelf mushroom age 0 facing west (out)" TO WS-CASE
     MOVE "9000,9000,3000,16000,11000,13000;12000,8000,5000,16000," & "9000,11000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "shelf_mushroom" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "age=1,facing=west" TO WS-P1
     MOVE "T4506 shelf mushroom age 1 facing west (coll)" TO WS-CASE
     MOVE "6000,8000,1000,16000,11000,15000;10000,6000,4000,16000," & "8000,12000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "shelf_mushroom" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "age=1,facing=west" TO WS-P1
     MOVE "T4506 shelf mushroom age 1 facing west (out)" TO WS-CASE
     MOVE "6000,8000,1000,16000,11000,15000;10000,6000,4000,16000," & "8000,12000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "nether_sprouts" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "T4506 nether_sprouts (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "nether_sprouts" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "T4506 nether_sprouts (out)" TO WS-CASE
     MOVE "2000,0,2000,14000,3000,14000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "weeping_vines" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "T4506 weeping_vines (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "weeping_vines" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "T4506 weeping_vines (out)" TO WS-CASE
     MOVE "4000,9000,4000,12000,16000,12000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "weeping_vines_plant" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "T4506 weeping_vines_plant (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "weeping_vines_plant" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "T4506 weeping_vines_plant (out)" TO WS-CASE
     MOVE "1000,0,1000,15000,16000,15000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "twisting_vines" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "T4506 twisting_vines (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "twisting_vines" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "T4506 twisting_vines (out)" TO WS-CASE
     MOVE "4000,0,4000,12000,15000,12000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "twisting_vines_plant" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "T4506 twisting_vines_plant (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "twisting_vines_plant" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "T4506 twisting_vines_plant (out)" TO WS-CASE
     MOVE "4000,0,4000,12000,16000,12000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "hanging_roots" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "T4506 hanging_roots (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "hanging_roots" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "T4506 hanging_roots (out)" TO WS-CASE
     MOVE "2000,10000,2000,14000,16000,14000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "small_dripleaf" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "T4506 small_dripleaf (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "small_dripleaf" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "T4506 small_dripleaf (out)" TO WS-CASE
     MOVE "2000,0,2000,14000,13000,14000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "short_dry_grass" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "T4506 short_dry_grass (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "short_dry_grass" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "T4506 short_dry_grass (out)" TO WS-CASE
     MOVE "2000,0,2000,14000,10000,14000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "tall_dry_grass" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "T4506 tall_dry_grass (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "tall_dry_grass" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "T4506 tall_dry_grass (out)" TO WS-CASE
     MOVE "1000,0,1000,15000,16000,15000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "tall_seagrass" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "T4506 tall_seagrass (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "tall_seagrass" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "T4506 tall_seagrass (out)" TO WS-CASE
     MOVE "2000,0,2000,14000,16000,14000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "pale_hanging_moss" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "tip=true" TO WS-P1
     MOVE "T4506 hanging moss tip (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "pale_hanging_moss" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "tip=true" TO WS-P1
     MOVE "T4506 hanging moss tip (out)" TO WS-CASE
     MOVE "1000,2000,1000,15000,16000,15000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "pale_hanging_moss" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "tip=false" TO WS-P1
     MOVE "T4506 hanging moss base (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "pale_hanging_moss" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "tip=false" TO WS-P1
     MOVE "T4506 hanging moss base (out)" TO WS-CASE
     MOVE "1000,0,1000,15000,16000,15000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "big_dripleaf_stem" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=east" TO WS-P1
     MOVE "T4506 big dripleaf stem east (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "big_dripleaf_stem" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=east" TO WS-P1
     MOVE "T4506 big dripleaf stem east (out)" TO WS-CASE
     MOVE "1000,0,5000,7000,16000,11000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "pink_petals" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=north,flower_amount=1" TO WS-P1
     MOVE "T4506 pink_petals flower_amount 1 facing north (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "pink_petals" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=north,flower_amount=1" TO WS-P1
     MOVE "T4506 pink_petals flower_amount 1 facing north (out)" TO WS-CASE
     MOVE "0,0,0,8000,3000,8000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "pink_petals" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=east,flower_amount=2" TO WS-P1
     MOVE "T4506 pink_petals flower_amount 2 facing east (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "pink_petals" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=east,flower_amount=2" TO WS-P1
     MOVE "T4506 pink_petals flower_amount 2 facing east (out)" TO WS-CASE
     MOVE "0,0,0,16000,3000,8000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "pink_petals" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=south,flower_amount=3" TO WS-P1
     MOVE "T4506 pink_petals flower_amount 3 facing south (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "pink_petals" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=south,flower_amount=3" TO WS-P1
     MOVE "T4506 pink_petals flower_amount 3 facing south (out)" TO WS-CASE
     MOVE "0,0,0,16000,3000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "pink_petals" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=west,flower_amount=4" TO WS-P1
     MOVE "T4506 pink_petals flower_amount 4 facing west (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "pink_petals" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=west,flower_amount=4" TO WS-P1
     MOVE "T4506 pink_petals flower_amount 4 facing west (out)" TO WS-CASE
     MOVE "0,0,0,16000,3000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "leaf_litter" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=north,segment_amount=1" TO WS-P1
     MOVE "T4506 leaf_litter segment_amount 1 facing north (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "leaf_litter" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=north,segment_amount=1" TO WS-P1
     MOVE "T4506 leaf_litter segment_amount 1 facing north (out)" TO WS-CASE
     MOVE "0,0,0,8000,1000,8000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "leaf_litter" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=east,segment_amount=2" TO WS-P1
     MOVE "T4506 leaf_litter segment_amount 2 facing east (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "leaf_litter" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=east,segment_amount=2" TO WS-P1
     MOVE "T4506 leaf_litter segment_amount 2 facing east (out)" TO WS-CASE
     MOVE "0,0,0,16000,1000,8000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "leaf_litter" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=south,segment_amount=3" TO WS-P1
     MOVE "T4506 leaf_litter segment_amount 3 facing south (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "leaf_litter" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=south,segment_amount=3" TO WS-P1
     MOVE "T4506 leaf_litter segment_amount 3 facing south (out)" TO WS-CASE
     MOVE "0,0,0,16000,1000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "leaf_litter" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=west,segment_amount=4" TO WS-P1
     MOVE "T4506 leaf_litter segment_amount 4 facing west (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "leaf_litter" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=west,segment_amount=4" TO WS-P1
     MOVE "T4506 leaf_litter segment_amount 4 facing west (out)" TO WS-CASE
     MOVE "0,0,0,16000,1000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "pointed_dripstone" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "thickness=tip_merge,vertical_direction=up" TO WS-P1
     MOVE "T4506 pointed_dripstone tip_merge up (coll)" TO WS-CASE
     MOVE "5000,0,5000,11000,16000,11000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "pointed_dripstone" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "thickness=tip_merge,vertical_direction=up" TO WS-P1
     MOVE "T4506 pointed_dripstone tip_merge up (out)" TO WS-CASE
     MOVE "5000,0,5000,11000,16000,11000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "pointed_dripstone" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "thickness=tip,vertical_direction=up" TO WS-P1
     MOVE "T4506 pointed_dripstone tip up (coll)" TO WS-CASE
     MOVE "5000,0,5000,11000,11000,11000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "pointed_dripstone" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "thickness=tip,vertical_direction=up" TO WS-P1
     MOVE "T4506 pointed_dripstone tip up (out)" TO WS-CASE
     MOVE "5000,0,5000,11000,11000,11000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "pointed_dripstone" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "thickness=tip,vertical_direction=down" TO WS-P1
     MOVE "T4506 pointed_dripstone tip down (coll)" TO WS-CASE
     MOVE "5000,5000,5000,11000,16000,11000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "pointed_dripstone" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "thickness=tip,vertical_direction=down" TO WS-P1
     MOVE "T4506 pointed_dripstone tip down (out)" TO WS-CASE
     MOVE "5000,5000,5000,11000,16000,11000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "pointed_dripstone" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "thickness=frustum,vertical_direction=down" TO WS-P1
     MOVE "T4506 pointed_dripstone frustum down (coll)" TO WS-CASE
     MOVE "4000,0,4000,12000,16000,12000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "pointed_dripstone" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "thickness=frustum,vertical_direction=down" TO WS-P1
     MOVE "T4506 pointed_dripstone frustum down (out)" TO WS-CASE
     MOVE "4000,0,4000,12000,16000,12000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "pointed_dripstone" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "thickness=middle,vertical_direction=up" TO WS-P1
     MOVE "T4506 pointed_dripstone middle up (coll)" TO WS-CASE
     MOVE "3000,0,3000,13000,16000,13000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "pointed_dripstone" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "thickness=middle,vertical_direction=up" TO WS-P1
     MOVE "T4506 pointed_dripstone middle up (out)" TO WS-CASE
     MOVE "3000,0,3000,13000,16000,13000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "pointed_dripstone" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "thickness=base,vertical_direction=down" TO WS-P1
     MOVE "T4506 pointed_dripstone base down (coll)" TO WS-CASE
     MOVE "2000,0,2000,14000,16000,14000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "pointed_dripstone" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "thickness=base,vertical_direction=down" TO WS-P1
     MOVE "T4506 pointed_dripstone base down (out)" TO WS-CASE
     MOVE "2000,0,2000,14000,16000,14000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "sulfur_spike" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "thickness=tip_merge,vertical_direction=up" TO WS-P1
     MOVE "T4506 sulfur_spike tip_merge up (coll)" TO WS-CASE
     MOVE "5000,0,5000,11000,16000,11000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "sulfur_spike" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "thickness=tip_merge,vertical_direction=up" TO WS-P1
     MOVE "T4506 sulfur_spike tip_merge up (out)" TO WS-CASE
     MOVE "5000,0,5000,11000,16000,11000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "sulfur_spike" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "thickness=tip,vertical_direction=up" TO WS-P1
     MOVE "T4506 sulfur_spike tip up (coll)" TO WS-CASE
     MOVE "5000,0,5000,11000,11000,11000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "sulfur_spike" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "thickness=tip,vertical_direction=up" TO WS-P1
     MOVE "T4506 sulfur_spike tip up (out)" TO WS-CASE
     MOVE "5000,0,5000,11000,11000,11000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "sulfur_spike" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "thickness=tip,vertical_direction=down" TO WS-P1
     MOVE "T4506 sulfur_spike tip down (coll)" TO WS-CASE
     MOVE "5000,5000,5000,11000,16000,11000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "sulfur_spike" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "thickness=tip,vertical_direction=down" TO WS-P1
     MOVE "T4506 sulfur_spike tip down (out)" TO WS-CASE
     MOVE "5000,5000,5000,11000,16000,11000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "sulfur_spike" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "thickness=frustum,vertical_direction=down" TO WS-P1
     MOVE "T4506 sulfur_spike frustum down (coll)" TO WS-CASE
     MOVE "4000,0,4000,12000,16000,12000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "sulfur_spike" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "thickness=frustum,vertical_direction=down" TO WS-P1
     MOVE "T4506 sulfur_spike frustum down (out)" TO WS-CASE
     MOVE "4000,0,4000,12000,16000,12000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "sulfur_spike" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "thickness=middle,vertical_direction=up" TO WS-P1
     MOVE "T4506 sulfur_spike middle up (coll)" TO WS-CASE
     MOVE "3000,0,3000,13000,16000,13000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "sulfur_spike" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "thickness=middle,vertical_direction=up" TO WS-P1
     MOVE "T4506 sulfur_spike middle up (out)" TO WS-CASE
     MOVE "3000,0,3000,13000,16000,13000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "sulfur_spike" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "thickness=base,vertical_direction=down" TO WS-P1
     MOVE "T4506 sulfur_spike base down (coll)" TO WS-CASE
     MOVE "2000,0,2000,14000,16000,14000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "sulfur_spike" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "thickness=base,vertical_direction=down" TO WS-P1
     MOVE "T4506 sulfur_spike base down (out)" TO WS-CASE
     MOVE "2000,0,2000,14000,16000,14000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "chorus_plant" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "north=false,east=false,south=false,west=false,up=false,down=false" TO WS-P1
     MOVE "T4506 chorus plant with no arm (coll)" TO WS-CASE
     MOVE "3000,3000,3000,13000,13000,13000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "chorus_plant" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "north=false,east=false,south=false,west=false,up=false,down=false" TO WS-P1
     MOVE "T4506 chorus plant with no arm (out)" TO WS-CASE
     MOVE "3000,3000,3000,13000,13000,13000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "chorus_plant" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "north=true,east=false,south=false,west=false,up=true,down=false" TO WS-P1
     MOVE "T4506 chorus plant north and up (coll)" TO WS-CASE
     MOVE "3000,3000,3000,13000,13000,13000;3000,3000,0,13000,1300" & "0,8000;3000,8000,3000,13000,16000,13000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "chorus_plant" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "north=true,east=false,south=false,west=false,up=true,down=false" TO WS-P1
     MOVE "T4506 chorus plant north and up (out)" TO WS-CASE
     MOVE "3000,3000,3000,13000,13000,13000;3000,3000,0,13000,1300" & "0,8000;3000,8000,3000,13000,16000,13000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "chorus_plant" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "north=true,east=true,south=true,west=true,up=true,down=true" TO WS-P1
     MOVE "T4506 chorus plant all arms (coll)" TO WS-CASE
     MOVE "3000,3000,3000,13000,13000,13000;3000,3000,0,13000,1300" & "0,8000;8000,3000,3000,16000,13000,13000;3000,3000,8000," & "13000,13000,16000;0,3000,3000,8000,13000,13000;3000,800" & "0,3000,13000,16000,13000;3000,0,3000,13000,8000,13000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "chorus_plant" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "north=true,east=true,south=true,west=true,up=true,down=true" TO WS-P1
     MOVE "T4506 chorus plant all arms (out)" TO WS-CASE
     MOVE "3000,3000,3000,13000,13000,13000;3000,3000,0,13000,1300" & "0,8000;8000,3000,3000,16000,13000,13000;3000,3000,8000," & "13000,13000,16000;0,3000,3000,8000,13000,13000;3000,800" & "0,3000,13000,16000,13000;3000,0,3000,13000,8000,13000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "sea_pickle" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "pickles=1" TO WS-P1
     MOVE "T4506 sea pickle 1 (coll)" TO WS-CASE
     MOVE "6000,0,6000,10000,6000,10000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "sea_pickle" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "pickles=1" TO WS-P1
     MOVE "T4506 sea pickle 1 (out)" TO WS-CASE
     MOVE "6000,0,6000,10000,6000,10000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "sea_pickle" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "pickles=2" TO WS-P1
     MOVE "T4506 sea pickle 2 (coll)" TO WS-CASE
     MOVE "3000,0,3000,13000,6000,13000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "sea_pickle" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "pickles=2" TO WS-P1
     MOVE "T4506 sea pickle 2 (out)" TO WS-CASE
     MOVE "3000,0,3000,13000,6000,13000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "sea_pickle" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "pickles=3" TO WS-P1
     MOVE "T4506 sea pickle 3 (coll)" TO WS-CASE
     MOVE "2000,0,2000,14000,6000,14000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "sea_pickle" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "pickles=3" TO WS-P1
     MOVE "T4506 sea pickle 3 (out)" TO WS-CASE
     MOVE "2000,0,2000,14000,6000,14000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "sea_pickle" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "pickles=4" TO WS-P1
     MOVE "T4506 sea pickle 4 (coll)" TO WS-CASE
     MOVE "2000,0,2000,14000,7000,14000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "sea_pickle" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "pickles=4" TO WS-P1
     MOVE "T4506 sea pickle 4 (out)" TO WS-CASE
     MOVE "2000,0,2000,14000,7000,14000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "turtle_egg" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "eggs=1" TO WS-P1
     MOVE "T4506 turtle egg 1 (coll)" TO WS-CASE
     MOVE "3000,0,3000,12000,7000,12000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "turtle_egg" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "eggs=1" TO WS-P1
     MOVE "T4506 turtle egg 1 (out)" TO WS-CASE
     MOVE "3000,0,3000,12000,7000,12000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "turtle_egg" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "eggs=2" TO WS-P1
     MOVE "T4506 turtle egg 2 (coll)" TO WS-CASE
     MOVE "1000,0,1000,15000,7000,15000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "turtle_egg" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "eggs=2" TO WS-P1
     MOVE "T4506 turtle egg 2 (out)" TO WS-CASE
     MOVE "1000,0,1000,15000,7000,15000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "turtle_egg" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "eggs=4" TO WS-P1
     MOVE "T4506 turtle egg 4 (coll)" TO WS-CASE
     MOVE "1000,0,1000,15000,7000,15000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "turtle_egg" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "eggs=4" TO WS-P1
     MOVE "T4506 turtle egg 4 (out)" TO WS-CASE
     MOVE "1000,0,1000,15000,7000,15000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "sniffer_egg" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "T4506 sniffer egg (coll)" TO WS-CASE
     MOVE "1000,0,2000,15000,16000,14000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "sniffer_egg" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "T4506 sniffer egg (out)" TO WS-CASE
     MOVE "1000,0,2000,15000,16000,14000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "dried_ghast" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "T4506 dried ghast (coll)" TO WS-CASE
     MOVE "3000,0,3000,13000,10000,13000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "dried_ghast" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "T4506 dried ghast (out)" TO WS-CASE
     MOVE "3000,0,3000,13000,10000,13000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "tube_coral" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "T4506 tube coral (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "tube_coral" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "T4506 tube coral (out)" TO WS-CASE
     MOVE "2000,0,2000,14000,15000,14000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "dead_tube_coral" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "T4506 dead tube coral (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "dead_tube_coral" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "T4506 dead tube coral (out)" TO WS-CASE
     MOVE "2000,0,2000,14000,15000,14000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "tube_coral_fan" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "T4506 tube coral fan (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "tube_coral_fan" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "T4506 tube coral fan (out)" TO WS-CASE
     MOVE "2000,0,2000,14000,4000,14000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "dead_tube_coral_fan" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "T4506 dead tube coral fan (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "dead_tube_coral_fan" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "T4506 dead tube coral fan (out)" TO WS-CASE
     MOVE "2000,0,2000,14000,4000,14000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "tube_coral_wall_fan" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=east" TO WS-P1
     MOVE "T4506 tube coral wall fan east (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "tube_coral_wall_fan" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=east" TO WS-P1
     MOVE "T4506 tube coral wall fan east (out)" TO WS-CASE
     MOVE "0,4000,0,11000,12000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "dead_tube_coral_wall_fan" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=south" TO WS-P1
     MOVE "T4506 dead tube coral wall fan south (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "dead_tube_coral_wall_fan" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=south" TO WS-P1
     MOVE "T4506 dead tube coral wall fan south (out)" TO WS-CASE
     MOVE "0,4000,0,16000,12000,11000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "powder_snow" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "T4506 powder snow (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "powder_snow" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "T4506 powder snow (out)" TO WS-CASE
     MOVE "0,0,0,16000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "pitcher_crop" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "age=0,half=lower" TO WS-P1
     MOVE "T4506 pitcher crop age 0 lower (coll)" TO WS-CASE
     MOVE "5000,-1000,5000,11000,3000,11000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "pitcher_crop" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "age=0,half=lower" TO WS-P1
     MOVE "T4506 pitcher crop age 0 lower (out)" TO WS-CASE
     MOVE "5000,-1000,5000,11000,3000,11000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "pitcher_crop" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "age=1,half=lower" TO WS-P1
     MOVE "T4506 pitcher crop age 1 lower (coll)" TO WS-CASE
     MOVE "3000,-1000,3000,13000,5000,13000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "pitcher_crop" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "age=1,half=lower" TO WS-P1
     MOVE "T4506 pitcher crop age 1 lower (out)" TO WS-CASE
     MOVE "3000,-1000,3000,13000,14000,13000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "pitcher_crop" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "age=2,half=lower" TO WS-P1
     MOVE "T4506 pitcher crop age 2 lower (coll)" TO WS-CASE
     MOVE "3000,-1000,3000,13000,5000,13000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "pitcher_crop" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "age=2,half=lower" TO WS-P1
     MOVE "T4506 pitcher crop age 2 lower (out)" TO WS-CASE
     MOVE "3000,-1000,3000,13000,16000,13000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "pitcher_crop" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "age=3,half=lower" TO WS-P1
     MOVE "T4506 pitcher crop age 3 lower (coll)" TO WS-CASE
     MOVE "3000,-1000,3000,13000,5000,13000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "pitcher_crop" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "age=3,half=lower" TO WS-P1
     MOVE "T4506 pitcher crop age 3 lower (out)" TO WS-CASE
     MOVE "3000,-1000,3000,13000,16000,13000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "pitcher_crop" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "age=4,half=lower" TO WS-P1
     MOVE "T4506 pitcher crop age 4 lower (coll)" TO WS-CASE
     MOVE "3000,-1000,3000,13000,5000,13000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "pitcher_crop" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "age=4,half=lower" TO WS-P1
     MOVE "T4506 pitcher crop age 4 lower (out)" TO WS-CASE
     MOVE "3000,-1000,3000,13000,16000,13000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "pitcher_crop" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "age=3,half=upper" TO WS-P1
     MOVE "T4506 pitcher crop age 3 upper (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "pitcher_crop" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "age=3,half=upper" TO WS-P1
     MOVE "T4506 pitcher crop age 3 upper (out)" TO WS-CASE
     MOVE "3000,0,3000,13000,11000,13000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "pitcher_crop" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "age=4,half=upper" TO WS-P1
     MOVE "T4506 pitcher crop age 4 upper (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "pitcher_crop" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "age=4,half=upper" TO WS-P1
     MOVE "T4506 pitcher crop age 4 upper (out)" TO WS-CASE
     MOVE "3000,0,3000,13000,15000,13000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "torchflower_crop" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "age=0" TO WS-P1
     MOVE "T4506 torchflower crop 0 (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "torchflower_crop" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "age=0" TO WS-P1
     MOVE "T4506 torchflower crop 0 (out)" TO WS-CASE
     MOVE "5000,0,5000,11000,6000,11000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "torchflower_crop" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "age=1" TO WS-P1
     MOVE "T4506 torchflower crop 1 (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "torchflower_crop" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "age=1" TO WS-P1
     MOVE "T4506 torchflower crop 1 (out)" TO WS-CASE
     MOVE "5000,0,5000,11000,10000,11000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "mangrove_propagule" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "hanging=true,age=0" TO WS-P1
     MOVE "T4506 mangrove propagule hanging age 0 (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "mangrove_propagule" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "hanging=true,age=0" TO WS-P1
     MOVE "T4506 mangrove propagule hanging age 0 (out)" TO WS-CASE
     MOVE "7000,13000,7000,9000,16000,9000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "mangrove_propagule" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "hanging=true,age=1" TO WS-P1
     MOVE "T4506 mangrove propagule hanging age 1 (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "mangrove_propagule" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "hanging=true,age=1" TO WS-P1
     MOVE "T4506 mangrove propagule hanging age 1 (out)" TO WS-CASE
     MOVE "7000,10000,7000,9000,16000,9000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "mangrove_propagule" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "hanging=true,age=2" TO WS-P1
     MOVE "T4506 mangrove propagule hanging age 2 (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "mangrove_propagule" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "hanging=true,age=2" TO WS-P1
     MOVE "T4506 mangrove propagule hanging age 2 (out)" TO WS-CASE
     MOVE "7000,7000,7000,9000,16000,9000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "mangrove_propagule" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "hanging=true,age=3" TO WS-P1
     MOVE "T4506 mangrove propagule hanging age 3 (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "mangrove_propagule" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "hanging=true,age=3" TO WS-P1
     MOVE "T4506 mangrove propagule hanging age 3 (out)" TO WS-CASE
     MOVE "7000,3000,7000,9000,16000,9000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "mangrove_propagule" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "hanging=true,age=4" TO WS-P1
     MOVE "T4506 mangrove propagule hanging age 4 (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "mangrove_propagule" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "hanging=true,age=4" TO WS-P1
     MOVE "T4506 mangrove propagule hanging age 4 (out)" TO WS-CASE
     MOVE "7000,0,7000,9000,16000,9000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "mangrove_propagule" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "hanging=false,age=2" TO WS-P1
     MOVE "T4506 mangrove propagule planted (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "mangrove_propagule" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "hanging=false,age=2" TO WS-P1
     MOVE "T4506 mangrove propagule planted (out)" TO WS-CASE
     MOVE "7000,0,7000,9000,16000,9000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "pale_moss_carpet" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "bottom=true,north=low,east=tall,south=none,west=none" TO WS-P1
     MOVE "T4506 moss carpet base with a low north and a tall east (coll)" TO WS-CASE
     MOVE "0,0,0,16000,1000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "pale_moss_carpet" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "bottom=true,north=low,east=tall,south=none,west=none" TO WS-P1
     MOVE "T4506 moss carpet base with a low north and a tall east (out)" TO WS-CASE
     MOVE "0,0,0,16000,1000,16000;0,0,0,16000,10000,1000;15000,0,0" & ",16000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "pale_moss_carpet" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "bottom=false,north=none,east=none,south=low,west=tall" TO WS-P1
     MOVE "T4506 moss carpet without a base keeps the sides (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "pale_moss_carpet" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "bottom=false,north=none,east=none,south=low,west=tall" TO WS-P1
     MOVE "T4506 moss carpet without a base keeps the sides (out)" TO WS-CASE
     MOVE "0,0,15000,16000,10000,16000;0,0,0,1000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "pale_moss_carpet" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "bottom=false,north=none,east=none,south=none,west=none" TO WS-P1
     MOVE "T4506 moss carpet with nothing is the full cube outline (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "pale_moss_carpet" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "bottom=false,north=none,east=none,south=none,west=none" TO WS-P1
     MOVE "T4506 moss carpet with nothing is the full cube outline (out)" TO WS-CASE
     MOVE "0,0,0,16000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "oak_hanging_sign" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "rotation=0" TO WS-P1
     MOVE "T4506 ceiling hanging sign rotation 0 (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "oak_hanging_sign" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "rotation=0" TO WS-P1
     MOVE "T4506 ceiling hanging sign rotation 0 (out)" TO WS-CASE
     MOVE "1000,0,7000,15000,10000,9000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "oak_hanging_sign" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "rotation=8" TO WS-P1
     MOVE "T4506 ceiling hanging sign rotation 8 (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "oak_hanging_sign" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "rotation=8" TO WS-P1
     MOVE "T4506 ceiling hanging sign rotation 8 (out)" TO WS-CASE
     MOVE "1000,0,7000,15000,10000,9000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "oak_hanging_sign" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "rotation=4" TO WS-P1
     MOVE "T4506 ceiling hanging sign rotation 4 (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "oak_hanging_sign" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "rotation=4" TO WS-P1
     MOVE "T4506 ceiling hanging sign rotation 4 (out)" TO WS-CASE
     MOVE "7000,0,1000,9000,10000,15000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "oak_hanging_sign" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "rotation=12" TO WS-P1
     MOVE "T4506 ceiling hanging sign rotation 12 (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "oak_hanging_sign" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "rotation=12" TO WS-P1
     MOVE "T4506 ceiling hanging sign rotation 12 (out)" TO WS-CASE
     MOVE "7000,0,1000,9000,10000,15000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "oak_hanging_sign" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "rotation=5" TO WS-P1
     MOVE "T4506 ceiling hanging sign rotation 5 (coll)" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "oak_hanging_sign" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "rotation=5" TO WS-P1
     MOVE "T4506 ceiling hanging sign rotation 5 (out)" TO WS-CASE
     MOVE "3000,0,3000,13000,16000,13000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "oak_wall_hanging_sign" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=north" TO WS-P1
     MOVE "T4506 wall hanging sign north (coll)" TO WS-CASE
     MOVE "0,14000,6000,16000,16000,10000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "oak_wall_hanging_sign" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=north" TO WS-P1
     MOVE "T4506 wall hanging sign north (out)" TO WS-CASE
     MOVE "0,14000,6000,16000,16000,10000;1000,0,7000,15000,10000," & "9000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "oak_wall_hanging_sign" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=south" TO WS-P1
     MOVE "T4506 wall hanging sign south (coll)" TO WS-CASE
     MOVE "0,14000,6000,16000,16000,10000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "oak_wall_hanging_sign" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=south" TO WS-P1
     MOVE "T4506 wall hanging sign south (out)" TO WS-CASE
     MOVE "0,14000,6000,16000,16000,10000;1000,0,7000,15000,10000," & "9000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "oak_wall_hanging_sign" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=east" TO WS-P1
     MOVE "T4506 wall hanging sign east (coll)" TO WS-CASE
     MOVE "6000,14000,0,10000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "oak_wall_hanging_sign" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=east" TO WS-P1
     MOVE "T4506 wall hanging sign east (out)" TO WS-CASE
     MOVE "6000,14000,0,10000,16000,16000;7000,0,1000,9000,10000,1" & "5000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "oak_wall_hanging_sign" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=west" TO WS-P1
     MOVE "T4506 wall hanging sign west (coll)" TO WS-CASE
     MOVE "6000,14000,0,10000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "oak_wall_hanging_sign" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=west" TO WS-P1
     MOVE "T4506 wall hanging sign west (out)" TO WS-CASE
     MOVE "6000,14000,0,10000,16000,16000;7000,0,1000,9000,10000,1" & "5000" TO WS-EXPECT
     PERFORM CHECK-OUT
*>   T4506: the model offset of 51 section 1.4 (expected values from an independent script of the hash: millionths of a block).
     MOVE "dandelion" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE 1 TO WS-OCX
     MOVE 5 TO WS-OCY
     MOVE 0 TO WS-OCZ
     MOVE 116667 TO WS-EXP-X
     MOVE 0 TO WS-EXP-Y
     MOVE -16667 TO WS-EXP-Z
     MOVE "T4506 offset of dandelion at (1, 0)" TO WS-CASE
     PERFORM CHECK-OFS
     MOVE "short_grass" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE 2 TO WS-OCX
     MOVE 5 TO WS-OCY
     MOVE 0 TO WS-OCZ
     MOVE 0 TO WS-EXP-X
     MOVE 0 TO WS-EXP-Y
     MOVE 0 TO WS-EXP-Z
     MOVE "R4 shape offset of short_grass: the shape stays (the model moves)" TO WS-CASE
     PERFORM CHECK-OFS
     MOVE -183333 TO WS-EXP-X
     MOVE -133333 TO WS-EXP-Y
     MOVE 50000 TO WS-EXP-Z
     MOVE "T4506 model offset of short_grass at (2, 0)" TO WS-CASE
     PERFORM CHECK-MOFS
     MOVE "fern" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE 2 TO WS-OCX
     MOVE 5 TO WS-OCY
     MOVE 0 TO WS-OCZ
     MOVE 0 TO WS-EXP-X
     MOVE 0 TO WS-EXP-Y
     MOVE 0 TO WS-EXP-Z
     MOVE "R4 shape offset of fern: the shape stays (the model moves)" TO WS-CASE
     PERFORM CHECK-OFS
     MOVE -183333 TO WS-EXP-X
     MOVE -133333 TO WS-EXP-Y
     MOVE 50000 TO WS-EXP-Z
     MOVE "T4506 model offset of fern at (2, 0)" TO WS-CASE
     PERFORM CHECK-MOFS
     MOVE "bamboo_sapling" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE 3 TO WS-OCX
     MOVE 5 TO WS-OCY
     MOVE 1 TO WS-OCZ
     MOVE -250000 TO WS-EXP-X
     MOVE 0 TO WS-EXP-Y
     MOVE 216667 TO WS-EXP-Z
     MOVE "T4506 offset of bamboo_sapling at (3, 1)" TO WS-CASE
     PERFORM CHECK-OFS
     MOVE "pointed_dripstone" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "thickness=tip,vertical_direction=up,waterlogged=false" TO WS-P1
     MOVE 3 TO WS-OCX
     MOVE 5 TO WS-OCY
     MOVE 1 TO WS-OCZ
     MOVE -125000 TO WS-EXP-X
     MOVE 0 TO WS-EXP-Y
     MOVE 125000 TO WS-EXP-Z
     MOVE "T4506 offset of pointed_dripstone at (3, 1)" TO WS-CASE
     PERFORM CHECK-OFS
     MOVE "small_dripleaf" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "half=lower,facing=north,waterlogged=false" TO WS-P1
     MOVE 4 TO WS-OCX
     MOVE 5 TO WS-OCY
     MOVE 2 TO WS-OCZ
     MOVE 0 TO WS-EXP-X
     MOVE 0 TO WS-EXP-Y
     MOVE 0 TO WS-EXP-Z
     MOVE "R4 shape offset of small_dripleaf: the shape stays (the model moves)" TO WS-CASE
     PERFORM CHECK-OFS
     MOVE 16667 TO WS-EXP-X
     MOVE -20000 TO WS-EXP-Y
     MOVE -183333 TO WS-EXP-Z
     MOVE "T4506 model offset of small_dripleaf at (4, 2)" TO WS-CASE
     PERFORM CHECK-MOFS
     MOVE "tall_seagrass" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "half=lower" TO WS-P1
     MOVE -3 TO WS-OCX
     MOVE 5 TO WS-OCY
     MOVE -2 TO WS-OCZ
     MOVE 0 TO WS-EXP-X
     MOVE 0 TO WS-EXP-Y
     MOVE 0 TO WS-EXP-Z
     MOVE "R4 shape offset of tall_seagrass: the shape stays (the model moves)" TO WS-CASE
     PERFORM CHECK-OFS
     MOVE -116667 TO WS-EXP-X
     MOVE 0 TO WS-EXP-Y
     MOVE 150000 TO WS-EXP-Z
     MOVE "T4506 model offset of tall_seagrass at (-3, -2)" TO WS-CASE
     PERFORM CHECK-MOFS
     MOVE "bamboo" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE 1 TO WS-OCX
     MOVE 5 TO WS-OCY
     MOVE 0 TO WS-OCZ
     MOVE 116667 TO WS-EXP-X
     MOVE 0 TO WS-EXP-Y
     MOVE -16667 TO WS-EXP-Z
     MOVE "R4 shape offset of bamboo at (1, 0): the shape moves" TO WS-CASE
     PERFORM CHECK-OFS
     MOVE "mangrove_propagule" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE 1 TO WS-OCX
     MOVE 5 TO WS-OCY
     MOVE 0 TO WS-OCZ
     MOVE 116667 TO WS-EXP-X
     MOVE 0 TO WS-EXP-Y
     MOVE -16667 TO WS-EXP-Z
     MOVE "R4 shape offset of mangrove_propagule at (1, 0): the shape moves" TO WS-CASE
     PERFORM CHECK-OFS
     MOVE "open_eyeblossom" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE 1 TO WS-OCX
     MOVE 5 TO WS-OCY
     MOVE 0 TO WS-OCZ
     MOVE 116667 TO WS-EXP-X
     MOVE 0 TO WS-EXP-Y
     MOVE -16667 TO WS-EXP-Z
     MOVE "R4 shape offset of open_eyeblossom at (1, 0): the shape moves" TO WS-CASE
     PERFORM CHECK-OFS
     MOVE "closed_eyeblossom" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE 1 TO WS-OCX
     MOVE 5 TO WS-OCY
     MOVE 0 TO WS-OCZ
     MOVE 116667 TO WS-EXP-X
     MOVE 0 TO WS-EXP-Y
     MOVE -16667 TO WS-EXP-Z
     MOVE "R4 shape offset of closed_eyeblossom at (1, 0): the shape moves" TO WS-CASE
     PERFORM CHECK-OFS
     MOVE "wither_rose" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE 1 TO WS-OCX
     MOVE 5 TO WS-OCY
     MOVE 0 TO WS-OCZ
     MOVE 116667 TO WS-EXP-X
     MOVE 0 TO WS-EXP-Y
     MOVE -16667 TO WS-EXP-Z
     MOVE "R4 shape offset of wither_rose at (1, 0): the shape moves" TO WS-CASE
     PERFORM CHECK-OFS
     MOVE "sulfur_spike" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE 1 TO WS-OCX
     MOVE 5 TO WS-OCY
     MOVE 0 TO WS-OCZ
     MOVE 116667 TO WS-EXP-X
     MOVE 0 TO WS-EXP-Y
     MOVE -16667 TO WS-EXP-Z
     MOVE "R4 shape offset of sulfur_spike at (1, 0): the shape moves" TO WS-CASE
     PERFORM CHECK-OFS
     MOVE "tall_grass" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE 1 TO WS-OCX
     MOVE 5 TO WS-OCY
     MOVE 0 TO WS-OCZ
     MOVE 0 TO WS-EXP-X
     MOVE 0 TO WS-EXP-Y
     MOVE 0 TO WS-EXP-Z
     MOVE "R4 shape offset of tall_grass: only the model moves" TO WS-CASE
     PERFORM CHECK-OFS
     MOVE "large_fern" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE 1 TO WS-OCX
     MOVE 5 TO WS-OCY
     MOVE 0 TO WS-OCZ
     MOVE 0 TO WS-EXP-X
     MOVE 0 TO WS-EXP-Y
     MOVE 0 TO WS-EXP-Z
     MOVE "R4 shape offset of large_fern: only the model moves" TO WS-CASE
     PERFORM CHECK-OFS
     MOVE "rose_bush" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE 1 TO WS-OCX
     MOVE 5 TO WS-OCY
     MOVE 0 TO WS-OCZ
     MOVE 0 TO WS-EXP-X
     MOVE 0 TO WS-EXP-Y
     MOVE 0 TO WS-EXP-Z
     MOVE "R4 shape offset of rose_bush: only the model moves" TO WS-CASE
     PERFORM CHECK-OFS
     MOVE "sunflower" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE 1 TO WS-OCX
     MOVE 5 TO WS-OCY
     MOVE 0 TO WS-OCZ
     MOVE 0 TO WS-EXP-X
     MOVE 0 TO WS-EXP-Y
     MOVE 0 TO WS-EXP-Z
     MOVE "R4 shape offset of sunflower: only the model moves" TO WS-CASE
     PERFORM CHECK-OFS
     MOVE "lilac" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE 1 TO WS-OCX
     MOVE 5 TO WS-OCY
     MOVE 0 TO WS-OCZ
     MOVE 0 TO WS-EXP-X
     MOVE 0 TO WS-EXP-Y
     MOVE 0 TO WS-EXP-Z
     MOVE "R4 shape offset of lilac: only the model moves" TO WS-CASE
     PERFORM CHECK-OFS
     MOVE "peony" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE 1 TO WS-OCX
     MOVE 5 TO WS-OCY
     MOVE 0 TO WS-OCZ
     MOVE 0 TO WS-EXP-X
     MOVE 0 TO WS-EXP-Y
     MOVE 0 TO WS-EXP-Z
     MOVE "R4 shape offset of peony: only the model moves" TO WS-CASE
     PERFORM CHECK-OFS
     MOVE "pitcher_plant" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE 1 TO WS-OCX
     MOVE 5 TO WS-OCY
     MOVE 0 TO WS-OCZ
     MOVE 0 TO WS-EXP-X
     MOVE 0 TO WS-EXP-Y
     MOVE 0 TO WS-EXP-Z
     MOVE "R4 shape offset of pitcher_plant: only the model moves" TO WS-CASE
     PERFORM CHECK-OFS
     MOVE "warped_roots" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE 1 TO WS-OCX
     MOVE 5 TO WS-OCY
     MOVE 0 TO WS-OCZ
     MOVE 0 TO WS-EXP-X
     MOVE 0 TO WS-EXP-Y
     MOVE 0 TO WS-EXP-Z
     MOVE "R4 shape offset of warped_roots: only the model moves" TO WS-CASE
     PERFORM CHECK-OFS
     MOVE "crimson_roots" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE 1 TO WS-OCX
     MOVE 5 TO WS-OCY
     MOVE 0 TO WS-OCZ
     MOVE 0 TO WS-EXP-X
     MOVE 0 TO WS-EXP-Y
     MOVE 0 TO WS-EXP-Z
     MOVE "R4 shape offset of crimson_roots: only the model moves" TO WS-CASE
     PERFORM CHECK-OFS
     MOVE "nether_sprouts" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE 1 TO WS-OCX
     MOVE 5 TO WS-OCY
     MOVE 0 TO WS-OCZ
     MOVE 0 TO WS-EXP-X
     MOVE 0 TO WS-EXP-Y
     MOVE 0 TO WS-EXP-Z
     MOVE "R4 shape offset of nether_sprouts: only the model moves" TO WS-CASE
     PERFORM CHECK-OFS
     MOVE "hanging_roots" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE 1 TO WS-OCX
     MOVE 5 TO WS-OCY
     MOVE 0 TO WS-OCZ
     MOVE 0 TO WS-EXP-X
     MOVE 0 TO WS-EXP-Y
     MOVE 0 TO WS-EXP-Z
     MOVE "R4 shape offset of hanging_roots: only the model moves" TO WS-CASE
     PERFORM CHECK-OFS
     MOVE "tall_seagrass" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE 1 TO WS-OCX
     MOVE 5 TO WS-OCY
     MOVE 0 TO WS-OCZ
     MOVE 0 TO WS-EXP-X
     MOVE 0 TO WS-EXP-Y
     MOVE 0 TO WS-EXP-Z
     MOVE "R4 shape offset of tall_seagrass: only the model moves" TO WS-CASE
     PERFORM CHECK-OFS
     MOVE "stone" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE 2 TO WS-OCX
     MOVE 5 TO WS-OCY
     MOVE 0 TO WS-OCZ
     MOVE 0 TO WS-EXP-X
     MOVE 0 TO WS-EXP-Y
     MOVE 0 TO WS-EXP-Z
     MOVE "T4506 offset of stone at (2, 0)" TO WS-CASE
     PERFORM CHECK-OFS
     MOVE "poppy" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE 0 TO WS-OCX
     MOVE 0 TO WS-OCY
     MOVE 0 TO WS-OCZ
     MOVE -250000 TO WS-EXP-X
     MOVE 0 TO WS-EXP-Y
     MOVE -250000 TO WS-EXP-Z
     MOVE "T4506 offset of poppy at (0, 0)" TO WS-CASE
     PERFORM CHECK-OFS
     MOVE "tall_dry_grass" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE 5 TO WS-OCX
     MOVE 64 TO WS-OCY
     MOVE 1 TO WS-OCZ
     MOVE 0 TO WS-EXP-X
     MOVE 0 TO WS-EXP-Y
     MOVE 0 TO WS-EXP-Z
     MOVE "R4 shape offset of tall_dry_grass: the shape stays (the model moves)" TO WS-CASE
     PERFORM CHECK-OFS
     MOVE -116667 TO WS-EXP-X
     MOVE -133333 TO WS-EXP-Y
     MOVE 16667 TO WS-EXP-Z
     MOVE "T4506 model offset of tall_dry_grass at (5, 1)" TO WS-CASE
     PERFORM CHECK-MOFS
     MOVE "poppy" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE -3 TO WS-OCX
     MOVE 5 TO WS-OCY
     MOVE 2 TO WS-OCZ
     MOVE -216667 TO WS-EXP-X
     MOVE 0 TO WS-EXP-Y
     MOVE -116667 TO WS-EXP-Z
     MOVE "T4506 offset of poppy at (-3, 2): a hash with the sign bit set" TO WS-CASE
     PERFORM CHECK-OFS
     MOVE 0 TO WS-STATE
     MOVE 0 TO WS-OCX WS-OCY WS-OCZ WS-EXP-X WS-EXP-Y WS-EXP-Z
     MOVE "T4506 offset of the void state is none" TO WS-CASE
     PERFORM CHECK-OFS-STATE
     MOVE 99999 TO WS-STATE
     MOVE "T4506 offset of a state past the table is none" TO WS-CASE
     PERFORM CHECK-OFS-STATE
*>   Play2 defect 3: the workstation and container shapes of 51 section 3.5 (hopper, cauldron, composter, grindstone, bell, scaffolding, piston head,
*>   wall skulls, joined chests, beds, lectern). The hopper and the cauldrons (L-shaped legs, 51 section 3.8.1 and 3.8.2) are checked against the model of the doc in test_block_shapes_r4.
     MOVE "composter" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "level=0" TO WS-P1
     MOVE "play2 shape: composter level=0 collision is the level-0 bin" TO WS-CASE
     MOVE "0,0,0,16000,2000,16000;0,2000,0,16000,16000,2000;0,2000,1400" & "0,16000,16000,16000;0,2000,2000,2000,16000,14000;14000,2000," & "2000,16000,16000,14000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "composter" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "level=0" TO WS-P1
     MOVE "play2 shape: composter level=0 outline" TO WS-CASE
     MOVE "0,0,0,16000,2000,16000;0,2000,0,16000,16000,2000;0,2000,1400" & "0,16000,16000,16000;0,2000,2000,2000,16000,14000;14000,2000," & "2000,16000,16000,14000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "composter" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "level=3" TO WS-P1
     MOVE "play2 shape: composter level=3 collision is the level-0 bin" TO WS-CASE
     MOVE "0,0,0,16000,2000,16000;0,2000,0,16000,16000,2000;0,2000,1400" & "0,16000,16000,16000;0,2000,2000,2000,16000,14000;14000,2000," & "2000,16000,16000,14000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "composter" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "level=3" TO WS-P1
     MOVE "play2 shape: composter level=3 outline" TO WS-CASE
     MOVE "0,0,0,16000,7000,16000;0,7000,0,16000,16000,2000;0,7000,1400" & "0,16000,16000,16000;0,7000,2000,2000,16000,14000;14000,7000," & "2000,16000,16000,14000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "composter" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "level=8" TO WS-P1
     MOVE "play2 shape: composter level=8 collision is the level-0 bin" TO WS-CASE
     MOVE "0,0,0,16000,2000,16000;0,2000,0,16000,16000,2000;0,2000,1400" & "0,16000,16000,16000;0,2000,2000,2000,16000,14000;14000,2000," & "2000,16000,16000,14000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "composter" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "level=8" TO WS-P1
     MOVE "play2 shape: composter level=8 outline" TO WS-CASE
     MOVE "0,0,0,16000,15000,16000;0,15000,0,16000,16000,2000;0,15000,1" & "4000,16000,16000,16000;0,15000,2000,2000,16000,14000;14000,1" & "5000,2000,16000,16000,14000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "grindstone" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "face=wall" TO WS-P1
     MOVE "facing=north" TO WS-P2
     MOVE "play2 shape: grindstone face=wall facing=north (collision)" TO WS-CASE
     MOVE "2000,6000,7000,4000,10000,16000;2000,5000,3000,4000,11000,90" & "00;12000,6000,7000,14000,10000,16000;12000,5000,3000,14000,1" & "1000,9000;4000,2000,0,12000,14000,12000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "grindstone" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "face=floor" TO WS-P1
     MOVE "facing=north" TO WS-P2
     MOVE "play2 shape: grindstone face=floor facing=north (collision)" TO WS-CASE
     MOVE "2000,0,6000,4000,9000,10000;2000,7000,5000,4000,13000,11000;" & "12000,0,6000,14000,9000,10000;12000,7000,5000,14000,13000,11" & "000;4000,4000,2000,12000,16000,14000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "grindstone" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "face=ceiling" TO WS-P1
     MOVE "facing=north" TO WS-P2
     MOVE "play2 shape: grindstone face=ceiling facing=north (collision)" TO WS-CASE
     MOVE "2000,7000,6000,4000,16000,10000;2000,3000,5000,4000,9000,110" & "00;12000,7000,6000,14000,16000,10000;12000,3000,5000,14000,9" & "000,11000;4000,0,2000,12000,12000,14000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "grindstone" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "face=wall" TO WS-P1
     MOVE "facing=east" TO WS-P2
     MOVE "play2 shape: grindstone face=wall facing=east is turned east (outline)" TO WS-CASE
     MOVE "0,6000,2000,9000,10000,4000;7000,5000,2000,13000,11000,4000;" & "0,6000,12000,9000,10000,14000;7000,5000,12000,13000,11000,14" & "000;4000,2000,4000,16000,14000,12000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "bell" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "attachment=ceiling" TO WS-P1
     MOVE "facing=north" TO WS-P2
     MOVE "play2 shape: bell ceiling (collision)" TO WS-CASE
     MOVE "5000,6000,5000,11000,13000,11000;4000,4000,4000,12000,6000,1" & "2000;7000,13000,7000,9000,16000,9000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "bell" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "attachment=floor" TO WS-P1
     MOVE "facing=north" TO WS-P2
     MOVE "play2 shape: bell floor facing=north is the frame on the z axis (collision)" TO WS-CASE
     MOVE "0,0,4000,16000,16000,12000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "bell" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "attachment=floor" TO WS-P1
     MOVE "facing=east" TO WS-P2
     MOVE "play2 shape: bell floor facing=east is the frame on the x axis (outline)" TO WS-CASE
     MOVE "4000,0,0,12000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "bell" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "attachment=single_wall" TO WS-P1
     MOVE "facing=south" TO WS-P2
     MOVE "play2 shape: bell single_wall facing=south (collision)" TO WS-CASE
     MOVE "5000,6000,5000,11000,13000,11000;4000,4000,4000,12000,6000,1" & "2000;7000,13000,3000,9000,15000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "bell" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "attachment=double_wall" TO WS-P1
     MOVE "facing=north" TO WS-P2
     MOVE "play2 shape: bell double_wall facing=north (collision)" TO WS-CASE
     MOVE "5000,6000,5000,11000,13000,11000;4000,4000,4000,12000,6000,1" & "2000;7000,13000,0,9000,15000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "bell" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "attachment=double_wall" TO WS-P1
     MOVE "facing=east" TO WS-P2
     MOVE "play2 shape: bell double_wall facing=east (outline)" TO WS-CASE
     MOVE "5000,6000,5000,11000,13000,11000;4000,4000,4000,12000,6000,1" & "2000;0,13000,7000,16000,15000,9000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "scaffolding" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "bottom=false" TO WS-P1
     MOVE "play2 shape: scaffolding table collision is the stable shape" TO WS-CASE
     MOVE "0,14000,0,16000,16000,16000;0,0,0,2000,16000,2000;14000,0,0,16000,16000,2000;14000,0,14000,16000,16000,16000;0,0,14000,2000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "scaffolding" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "bottom=false" TO WS-P1
     MOVE "play2 shape: scaffolding bottom=false outline is the stable shape" TO WS-CASE
     MOVE "0,14000,0,16000,16000,16000;0,0,0,2000,16000,2000;14000,0,0," & "16000,16000,2000;14000,0,14000,16000,16000,16000;0,0,14000,2" & "000,16000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "scaffolding" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "bottom=true" TO WS-P1
     MOVE "play2 shape: scaffolding bottom=true outline is the unstable shape" TO WS-CASE
     MOVE "0,14000,0,16000,16000,16000;0,0,0,2000,16000,2000;14000,0,0," & "16000,16000,2000;14000,0,14000,16000,16000,16000;0,0,14000,2" & "000,16000,16000;0,0,0,16000,2000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "piston_head" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=north" TO WS-P1
     MOVE "short=false" TO WS-P2
     MOVE "play2 shape: piston_head facing=north (collision)" TO WS-CASE
     MOVE "0,0,0,16000,16000,4000;6000,6000,4000,10000,10000,20000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "piston_head" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=south" TO WS-P1
     MOVE "short=false" TO WS-P2
     MOVE "play2 shape: piston_head facing=south (collision)" TO WS-CASE
     MOVE "0,0,12000,16000,16000,16000;6000,6000,-4000,10000,10000,1200" & "0" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "piston_head" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=west" TO WS-P1
     MOVE "short=false" TO WS-P2
     MOVE "play2 shape: piston_head facing=west (collision)" TO WS-CASE
     MOVE "0,0,0,4000,16000,16000;4000,6000,6000,20000,10000,10000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "piston_head" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=east" TO WS-P1
     MOVE "short=false" TO WS-P2
     MOVE "play2 shape: piston_head facing=east (collision)" TO WS-CASE
     MOVE "12000,0,0,16000,16000,16000;-4000,6000,6000,12000,10000,1000" & "0" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "piston_head" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=down" TO WS-P1
     MOVE "short=false" TO WS-P2
     MOVE "play2 shape: piston_head facing=down (collision)" TO WS-CASE
     MOVE "0,0,0,16000,4000,16000;6000,4000,6000,10000,20000,10000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "piston_head" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=up" TO WS-P1
     MOVE "short=false" TO WS-P2
     MOVE "play2 shape: piston_head facing=up (collision)" TO WS-CASE
     MOVE "0,12000,0,16000,16000,16000;6000,-4000,6000,10000,12000,1000" & "0" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "zombie_wall_head" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=north" TO WS-P1
     MOVE "play2 shape: zombie_wall_head facing=north (collision)" TO WS-CASE
     MOVE "4000,4000,8000,12000,12000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "zombie_wall_head" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=east" TO WS-P1
     MOVE "play2 shape: zombie_wall_head facing=east (collision)" TO WS-CASE
     MOVE "0,4000,4000,8000,12000,12000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "zombie_wall_head" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=south" TO WS-P1
     MOVE "play2 shape: zombie_wall_head facing=south (collision)" TO WS-CASE
     MOVE "4000,4000,0,12000,12000,8000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "zombie_wall_head" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=west" TO WS-P1
     MOVE "play2 shape: zombie_wall_head facing=west (collision)" TO WS-CASE
     MOVE "8000,4000,4000,16000,12000,12000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "chest" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "type=single" TO WS-P1
     MOVE "facing=north" TO WS-P2
     MOVE "play2 shape: chest single (collision)" TO WS-CASE
     MOVE "1000,0,1000,15000,14000,15000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "chest" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "type=left" TO WS-P1
     MOVE "facing=north" TO WS-P2
     MOVE "play2 shape: chest left facing=north joins east (collision)" TO WS-CASE
     MOVE "1000,0,1000,16000,14000,15000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "chest" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "type=right" TO WS-P1
     MOVE "facing=north" TO WS-P2
     MOVE "play2 shape: chest right facing=north joins west (collision)" TO WS-CASE
     MOVE "0,0,1000,15000,14000,15000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "chest" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "type=left" TO WS-P1
     MOVE "facing=east" TO WS-P2
     MOVE "play2 shape: chest left facing=east joins south (outline)" TO WS-CASE
     MOVE "1000,0,1000,15000,14000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "chest" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "type=right" TO WS-P1
     MOVE "facing=east" TO WS-P2
     MOVE "play2 shape: chest right facing=east joins north (outline)" TO WS-CASE
     MOVE "1000,0,0,15000,14000,15000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "red_bed" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "part=head" TO WS-P1
     MOVE "facing=north" TO WS-P2
     MOVE "play2 shape: bed head half facing=north: legs at the north end (collision)" TO WS-CASE
     MOVE "0,3000,0,16000,9000,16000;0,0,0,3000,3000,3000;13000,0,0,160" & "00,3000,3000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "red_bed" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "part=foot" TO WS-P1
     MOVE "facing=north" TO WS-P2
     MOVE "play2 shape: bed foot half facing=north: legs at the south end (collision)" TO WS-CASE
     MOVE "0,3000,0,16000,9000,16000;13000,0,13000,16000,3000,16000;0,0" & ",13000,3000,3000,16000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "red_bed" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "part=foot" TO WS-P1
     MOVE "facing=east" TO WS-P2
     MOVE "play2 shape: bed foot half facing=east: legs at the west end (outline)" TO WS-CASE
     MOVE "0,3000,0,16000,9000,16000;0,0,13000,3000,3000,16000;0,0,0,30" & "00,3000,3000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "lectern" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=north" TO WS-P1
     MOVE "play2 shape: lectern facing=north collision is the base and the stand" TO WS-CASE
     MOVE "0,0,0,16000,2000,16000;4000,2000,4000,12000,14000,12000" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "lectern" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=north" TO WS-P1
     MOVE "play2 shape: lectern facing=north outline adds the desk" TO WS-CASE
     MOVE "0,0,0,16000,2000,16000;4000,2000,4000,12000,14000,12000;0,10" & "000,1000,16000,14000,5333;0,12000,5333,16000,16000,9667;0,14" & "000,9667,16000,18000,14000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "lectern" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "facing=east" TO WS-P1
     MOVE "play2 shape: lectern facing=east outline has the desk turned east" TO WS-CASE
     MOVE "0,0,0,16000,2000,16000;4000,2000,4000,12000,14000,12000;1066" & "7,10000,0,15000,14000,16000;6333,12000,0,10667,16000,16000;2" & "000,14000,0,6333,18000,16000" TO WS-EXPECT
     PERFORM CHECK-OUT

*>   Bamboo (R-F43, R-F42; lane fixa A2): a thin collision at every leaves value, an outline by leaves; the sapling has an outline only.
     MOVE "bamboo" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "leaves=none" TO WS-P1
     MOVE "fixa shape: bamboo leaves=none collision is the thin stalk" TO WS-CASE
     MOVE "6500,0,6500,9500,16000,9500" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "fixa shape: bamboo leaves=none outline" TO WS-CASE
     MOVE "5000,0,5000,11000,16000,11000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "leaves=large" TO WS-P1
     MOVE "fixa shape: bamboo leaves=large collision stays thin" TO WS-CASE
     MOVE "6500,0,6500,9500,16000,9500" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "fixa shape: bamboo leaves=large outline is wider" TO WS-CASE
     MOVE "3000,0,3000,13000,16000,13000" TO WS-EXPECT
     PERFORM CHECK-OUT
     MOVE "bamboo_sapling" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "fixa shape: bamboo sapling has no collision" TO WS-CASE
     MOVE "-" TO WS-EXPECT
     PERFORM CHECK-COLL
     MOVE "fixa shape: bamboo sapling outline" TO WS-CASE
     MOVE "4000,0,4000,12000,12000,12000" TO WS-EXPECT
     PERFORM CHECK-OUT

*>   Friction (51 section 1; 18 section 3.2: ice, packed ice, frosted ice 0.98, blue ice 0.989, slime 0.8, everything else the default 0.6 = 0 here).
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE WS-SLIP-KEY(WS-I) TO WS-KEY
         MOVE SPACES TO WS-P1 WS-P2 WS-P3
         CALL "BSH-TEST-FIND" USING WS-KEY WS-P1 WS-P2 WS-P3 WS-STATE
         MOVE SPACES TO TL-CASE
         STRING "fixa friction: " FUNCTION TRIM(WS-KEY) " slipperiness" DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-SLIP-WANT(WS-I) TO TL-EXPECTED-N
         MOVE BSH-SLIP(WS-STATE + 1) TO TL-OBSERVED-N
         PERFORM ASSERT-N
     END-PERFORM

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

 CHECK-OFS.
     PERFORM FIND-STATE
     PERFORM CHECK-OFS-STATE.

 CHECK-MOFS.
     PERFORM FIND-STATE
     CALL "BSH-MODEL-OFFSET" USING WS-STATE WS-OCX WS-OCY WS-OCZ WS-OX WS-OY WS-OZ
     MOVE WS-EXP-X TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-OX * 1000000
     MOVE WS-CASE TO TL-CASE
     PERFORM ASSERT-N
     MOVE WS-EXP-Y TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-OY * 1000000
     PERFORM ASSERT-N
     MOVE WS-EXP-Z TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-OZ * 1000000
     PERFORM ASSERT-N.

 CHECK-OFS-STATE.
     CALL "BSH-OFFSET" USING WS-STATE WS-OCX WS-OCY WS-OCZ WS-OX WS-OY WS-OZ
     MOVE WS-EXP-X TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-OX * 1000000
     MOVE WS-CASE TO TL-CASE
     PERFORM ASSERT-N
     MOVE WS-EXP-Y TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-OY * 1000000
     PERFORM ASSERT-N
     MOVE WS-EXP-Z TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-OZ * 1000000
     PERFORM ASSERT-N.

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
