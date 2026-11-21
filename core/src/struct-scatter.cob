*> The scattered feature pieces: swamp hut, jungle temple (docs/protocol/36-structures-4-scattered-and-small.md sections 2.3, 4, 5; the desert pyramid of section 3 is added in
*> struct-scatter-gen.cob and struct-scatter-desert.cob). A piece is built at (16 cx, 64, 16 cz) with a random horizontal direction from the start random; its postProcess writes the blocks of the
*> document's tables (struct-scatter-gen.cob: one line per operation, run by SCP-RUN), clipped to the chunk being placed (SP-WBOX) like every piece.
*> Piece types (SP-TYPE): 101 desert pyramid, 102 jungle temple, 103 swamp hut. SP-F1 to SP-F4 are the placed flags of the containers (jungle: trap 1, trap 2, main chest, hidden chest).
*>
*> Heights: the document's ground adjusters (2.3) read the live heightmap MOTION_BLOCKING_NO_LEAVES of the chunks being generated, which makes the piece's height depend on which chunk is
*> decorated first. Here the piece's height is the same for every pass: updateAverageGroundHeight takes the average over every column of the piece's box (vanilla counts only the columns inside
*> the first decorated chunk's write box and then keeps the result), and the heightmap is the base height of the column (STRUCT-BASE-HEIGHT kind 0: stone or water from the noise terrain,
*> without surface rules, carvers or features; MOTION_BLOCKING_NO_LEAVES differs only where a carver or an earlier feature changed the top, and leaves are not placed yet at this step).
*> Deviations: the witch and the cat of the hut (5.4) go to the entity channel (SCP-HUT-POST); fluid ticks and the shape-check marks of placeBlock are not made; the neighbour blocks
*> that reorient (36-1 6.5) reads for a chest lie in the chunk window, a neighbour in another chunk reads as air.
*>
*> Entry points:
*>   STRUCT-SCATTER-FIND-POINT USING structure row, seed, chunk x, chunk z, x out, y out, z out, valid out, done out (1 when the structure is one of these): findGenerationPoint
*>   SCP-POST USING row: postProcess of a piece of type 101 to 103 (the height adjuster, then the blocks)
*>   SCP-RUN USING row, operations (one 100 byte line each), count: the interpreter of the generated tables
*>   SCP-STATE USING row, spec (PIC X(60)), state out: a block state of the local north frame with the piece's mirror and rotation applied

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCP-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-NAME                PIC X(60).
 01 WS-REST                PIC X(60).
 01 WS-PAIRS               PIC X(600).
 01 WS-KEY                 PIC X(112).
 01 WS-MIRROR              BINARY-LONG.
 01 WS-ROT                 BINARY-LONG.
 01 WS-OUT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SPEC                 PIC X(60).
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SPEC L-STATE.
     MOVE SPACES TO WS-NAME WS-REST WS-PAIRS WS-KEY
     UNSTRING L-SPEC DELIMITED BY "[" INTO WS-NAME WS-REST
     UNSTRING WS-REST DELIMITED BY "]" INTO WS-PAIRS
     STRING "minecraft:" FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO WS-KEY
     CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS L-STATE
*>   setOrientation (2.3): south mirrors left-right; west mirrors and turns clockwise; east turns clockwise; north (and none) do neither
     MOVE 0 TO WS-MIRROR WS-ROT
     EVALUATE SP-ORIENT(L-ROW)
         WHEN 0
             MOVE 1 TO WS-MIRROR
         WHEN 1
             MOVE 1 TO WS-MIRROR
             MOVE 1 TO WS-ROT
         WHEN 3
             MOVE 1 TO WS-ROT
     END-EVALUATE
     CALL "BLOCK-MIRROR-STATE" USING L-STATE WS-MIRROR WS-OUT
     CALL "BLOCK-ROTATE-STATE" USING WS-OUT WS-ROT L-STATE
     GOBACK.
 END PROGRAM SCP-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCP-SET.
*> USING row, local x y z, state: placeBlock (2.3) without the fluid tick: the state is written (flags 2) when its world position is inside the write box.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-STATE.
     CALL "SPB-WORLD" USING L-ROW L-X L-Y L-Z WS-WX WS-WY WS-WZ
     CALL "SPB-BOX-INSIDE" USING SP-WBOX WS-WX WS-WY WS-WZ WS-IN
     IF WS-IN = 1
         CALL "FL-SET-STATE" USING WS-WX WS-WY WS-WZ L-STATE WS-FLAGS WS-OK
     END-IF
     GOBACK.
 END PROGRAM SCP-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCP-BOX.
*> USING row, x0 y0 z0 x1 y1 z1, edge state, fill state, skip air: generateBox (36-1 6.5), y outermost, then x, then z; skipAir leaves a cell that holds air.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 01 L-EDGE                 BINARY-LONG.
 01 L-FILL                 BINARY-LONG.
 01 L-SKIP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1 L-EDGE L-FILL L-SKIP.
     PERFORM VARYING WS-Y FROM L-Y0 BY 1 UNTIL WS-Y > L-Y1
         PERFORM VARYING WS-X FROM L-X0 BY 1 UNTIL WS-X > L-X1
             PERFORM VARYING WS-Z FROM L-Z0 BY 1 UNTIL WS-Z > L-Z1
                 MOVE 0 TO WS-CLASS
                 IF L-SKIP = 1
                     CALL "MSP-GET" USING L-ROW WS-X WS-Y WS-Z WS-STATE
                     CALL "FL-CLASS" USING WS-STATE WS-CLASS
                 END-IF
                 IF WS-CLASS NOT = 1
                     IF WS-Y = L-Y0 OR WS-Y = L-Y1 OR WS-X = L-X0 OR WS-X = L-X1 OR WS-Z = L-Z0 OR WS-Z = L-Z1
                         CALL "SCP-SET" USING L-ROW WS-X WS-Y WS-Z L-EDGE
                     ELSE
                         CALL "SCP-SET" USING L-ROW WS-X WS-Y WS-Z L-FILL
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM SCP-BOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCP-MOSS.
*> USING row, x0 y0 z0 x1 y1 z1: generateBox with the moss stone selector of the jungle temple (4.2): one nextFloat of the piece random per cell, below 0.4f cobblestone, else mossy cobblestone.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-XR== LEADING ==XR-== BY ==WX-==.
 01 WS-COBBLE              BINARY-LONG.
 01 WS-MOSSY               BINARY-LONG.
 01 WS-SPEC                PIC X(60).
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-DRAW                FLOAT-LONG.
 01 WS-CHANCE              FLOAT-LONG VALUE 0.4000000059604645.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1.
     MOVE "cobblestone" TO WS-SPEC
     CALL "SCP-STATE" USING L-ROW WS-SPEC WS-COBBLE
     MOVE "mossy_cobblestone" TO WS-SPEC
     CALL "SCP-STATE" USING L-ROW WS-SPEC WS-MOSSY
     PERFORM VARYING WS-Y FROM L-Y0 BY 1 UNTIL WS-Y > L-Y1
         PERFORM VARYING WS-X FROM L-X0 BY 1 UNTIL WS-X > L-X1
             PERFORM VARYING WS-Z FROM L-Z0 BY 1 UNTIL WS-Z > L-Z1
                 MOVE SP-XR-LO TO WX-LO
                 MOVE SP-XR-HI TO WX-HI
                 CALL "WGR-NEXT-FLOAT" USING WS-XR WS-DRAW
                 MOVE WX-LO TO SP-XR-LO
                 MOVE WX-HI TO SP-XR-HI
                 IF WS-DRAW < WS-CHANCE
                     CALL "SCP-SET" USING L-ROW WS-X WS-Y WS-Z WS-COBBLE
                 ELSE
                     CALL "SCP-SET" USING L-ROW WS-X WS-Y WS-Z WS-MOSSY
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM SCP-MOSS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCP-COLUMN.
*> USING row, state, x0 z0 x1 z1, y: fillColumnDown (36-1 6.5) for every column of the rectangle (x outer, z inner): from the cell at y, while the block is replaceable by structures (air, a liquid,
*> glow lichen, seagrass, tall seagrass) and its y is above min y + 1, the state is written and the position steps down. A column whose start is outside the write box is skipped.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY STRUCTBLK.
 COPY FEATLEVEL.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-CUR                 BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-GO                  BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-FLOOR               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-STATE L-X0 L-Z0 L-X1 L-Z1 L-Y.
     COMPUTE WS-FLOOR = FL-MIN-Y + 1
     PERFORM VARYING WS-X FROM L-X0 BY 1 UNTIL WS-X > L-X1
         PERFORM VARYING WS-Z FROM L-Z0 BY 1 UNTIL WS-Z > L-Z1
             CALL "SPB-WORLD" USING L-ROW WS-X L-Y WS-Z WS-WX WS-WY WS-WZ
             CALL "SPB-BOX-INSIDE" USING SP-WBOX WS-WX WS-WY WS-WZ WS-IN
             MOVE WS-IN TO WS-GO
             PERFORM UNTIL WS-GO = 0
                 CALL "FL-GET-STATE" USING WS-WX WS-WY WS-WZ WS-CUR
                 CALL "FL-CLASS" USING WS-CUR WS-CLASS
                 CALL "FL-BLOCK-OF" USING WS-CUR WS-B
                 MOVE 0 TO WS-GO
                 IF WS-CLASS = 1 OR WS-CLASS = 2 OR WS-CLASS = 3 OR (WS-B > 0 AND SBK-FLAGS(WS-B) = 2)
                     IF WS-WY > WS-FLOOR
                         CALL "FL-SET-STATE" USING WS-WX WS-WY WS-WZ L-STATE WS-FLAGS WS-OK
                         SUBTRACT 1 FROM WS-WY
                         MOVE 1 TO WS-GO
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM SCP-COLUMN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCP-REORIENT.
*> USING world x y z, state out: StructurePiece.reorient of the default chest (36-1 6.5): the facing is REORIENT-DIR's, the state the chest with that facing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIR                 BINARY-LONG.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:chest".
 01 WS-PAIRS               PIC X(600).
 01 WS-NAMES.
    05 FILLER              PIC X(5) VALUE "north".
    05 FILLER              PIC X(5) VALUE "east ".
    05 FILLER              PIC X(5) VALUE "south".
    05 FILLER              PIC X(5) VALUE "west ".
 01 WS-NAME-TABLE REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(5) OCCURS 4 TIMES.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-STATE.
     CALL "REORIENT-DIR" USING L-X L-Y L-Z WS-DIR
     MOVE SPACES TO WS-PAIRS
     STRING "facing=" FUNCTION TRIM(WS-NAME(WS-DIR + 1)) DELIMITED BY SIZE INTO WS-PAIRS
     CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS L-STATE
     GOBACK.
 END PROGRAM SCP-REORIENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCP-CONTAINER.
*> USING row, local x y z, spec, wanted block key (PIC X(48): "chest" or "dispenser"), loot table (PIC X(48)), placed out: createChest (spec spaces: the reoriented default chest, written as
*> is, 36-1 6.5) or createDispenser (a placeBlock state, so the piece's rotation applies). False when the position is outside the write box or already holds that block; else the block is
*> written, the loot table and the seed random.nextLong() of the piece random go to the block-entity channel, true.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY CBLOCKS.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-CUR                 BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-NOTHING             PIC X(32) VALUE SPACES.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-SPEC                 PIC X(60).
 01 L-WANT                 PIC X(48).
 01 L-LOOT                 PIC X(48).
 01 L-PLACED               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-SPEC L-WANT L-LOOT L-PLACED.
     MOVE 0 TO L-PLACED
     CALL "SPB-WORLD" USING L-ROW L-X L-Y L-Z WS-WX WS-WY WS-WZ
     CALL "SPB-BOX-INSIDE" USING SP-WBOX WS-WX WS-WY WS-WZ WS-IN
     IF WS-IN = 0
         GOBACK
     END-IF
     CALL "FL-GET-STATE" USING WS-WX WS-WY WS-WZ WS-CUR
     CALL "FL-BLOCK-OF" USING WS-CUR WS-B
     IF WS-B > 0 AND CB-KEY(WS-B) = L-WANT
         GOBACK
     END-IF
     IF L-SPEC = SPACES
         CALL "SCP-REORIENT" USING WS-WX WS-WY WS-WZ WS-STATE
     ELSE
         CALL "SCP-STATE" USING L-ROW L-SPEC WS-STATE
     END-IF
     CALL "FL-SET-STATE" USING WS-WX WS-WY WS-WZ WS-STATE WS-FLAGS WS-OK
     CALL "MSP-RNG-LONG" USING WS-SEED
     CALL "GBE-ADD" USING WS-WX WS-WY WS-WZ WS-KIND L-LOOT WS-SEED WS-NOTHING
     MOVE 1 TO L-PLACED
     GOBACK.
 END PROGRAM SCP-CONTAINER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCP-RUN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-ALL                 PIC X(30000) BASED.
 01 WS-LINE                PIC X(100).
 01 WS-TOKENS.
    05 WS-TOK              PIC X(60) OCCURS 24 TIMES.
 01 WS-NTOK                BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-K1                  BINARY-LONG.
 01 WS-K2                  BINARY-LONG.
 01 WS-OFF                 BINARY-LONG.
 01 WS-EDGE                BINARY-LONG.
 01 WS-FILL                BINARY-LONG.
 01 WS-SKIP                BINARY-LONG.
 01 WS-N1                  BINARY-LONG.
 01 WS-N2                  BINARY-LONG.
 01 WS-N3                  BINARY-LONG.
 01 WS-N4                  BINARY-LONG.
 01 WS-N5                  BINARY-LONG.
 01 WS-N6                  BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-PLACED              BINARY-LONG.
 01 WS-WANT                PIC X(48).
 01 WS-LOOT                PIC X(48).
 01 WS-NOSPEC              PIC X(60) VALUE SPACES.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-OPS                  PIC X.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-OPS L-COUNT.
     SET ADDRESS OF WS-ALL TO ADDRESS OF L-OPS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
         COMPUTE WS-OFF = (WS-I - 1) * 100 + 1
         MOVE WS-ALL(WS-OFF:100) TO WS-LINE
         MOVE SPACES TO WS-TOKENS
         MOVE 0 TO WS-NTOK
         MOVE 1 TO WS-PTR
         PERFORM UNTIL WS-PTR > 100
             ADD 1 TO WS-NTOK
             UNSTRING WS-LINE DELIMITED BY ALL SPACE INTO WS-TOK(WS-NTOK) WITH POINTER WS-PTR
         END-PERFORM
         EVALUATE WS-TOK(1)
             WHEN "B" WHEN "K"
                 COMPUTE WS-N1 = FUNCTION NUMVAL(WS-TOK(2))
                 COMPUTE WS-N2 = FUNCTION NUMVAL(WS-TOK(3))
                 COMPUTE WS-N3 = FUNCTION NUMVAL(WS-TOK(4))
                 COMPUTE WS-N4 = FUNCTION NUMVAL(WS-TOK(5))
                 COMPUTE WS-N5 = FUNCTION NUMVAL(WS-TOK(6))
                 COMPUTE WS-N6 = FUNCTION NUMVAL(WS-TOK(7))
                 CALL "SCP-STATE" USING L-ROW WS-TOK(8) WS-EDGE
*>               a line with one block names it for the edge and the fill alike
                 IF WS-TOK(9) = SPACES
                     MOVE WS-EDGE TO WS-FILL
                 ELSE
                     CALL "SCP-STATE" USING L-ROW WS-TOK(9) WS-FILL
                 END-IF
                 MOVE 0 TO WS-SKIP
                 IF WS-TOK(1) = "K"
                     MOVE 1 TO WS-SKIP
                 END-IF
                 CALL "SCP-BOX" USING L-ROW WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6 WS-EDGE WS-FILL WS-SKIP
             WHEN "R"
                 COMPUTE WS-N1 = FUNCTION NUMVAL(WS-TOK(2))
                 COMPUTE WS-N2 = FUNCTION NUMVAL(WS-TOK(3))
                 COMPUTE WS-N3 = FUNCTION NUMVAL(WS-TOK(4))
                 COMPUTE WS-N4 = FUNCTION NUMVAL(WS-TOK(5))
                 COMPUTE WS-N5 = FUNCTION NUMVAL(WS-TOK(6))
                 COMPUTE WS-N6 = FUNCTION NUMVAL(WS-TOK(7))
                 CALL "SCP-MOSS" USING L-ROW WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6
             WHEN "P"
                 CALL "SCP-STATE" USING L-ROW WS-TOK(2) WS-EDGE
                 PERFORM VARYING WS-K FROM 3 BY 3 UNTIL WS-K > WS-NTOK
                     COMPUTE WS-K1 = WS-K + 1
                     COMPUTE WS-K2 = WS-K + 2
                     COMPUTE WS-N1 = FUNCTION NUMVAL(WS-TOK(WS-K))
                     COMPUTE WS-N2 = FUNCTION NUMVAL(WS-TOK(WS-K1))
                     COMPUTE WS-N3 = FUNCTION NUMVAL(WS-TOK(WS-K2))
                     CALL "SCP-SET" USING L-ROW WS-N1 WS-N2 WS-N3 WS-EDGE
                 END-PERFORM
             WHEN "F"
                 COMPUTE WS-N1 = FUNCTION NUMVAL(WS-TOK(3))
                 COMPUTE WS-N2 = FUNCTION NUMVAL(WS-TOK(4))
                 COMPUTE WS-N3 = FUNCTION NUMVAL(WS-TOK(5))
                 COMPUTE WS-N4 = FUNCTION NUMVAL(WS-TOK(6))
                 COMPUTE WS-N5 = FUNCTION NUMVAL(WS-TOK(7))
                 CALL "SCP-STATE" USING L-ROW WS-TOK(2) WS-EDGE
                 CALL "SCP-COLUMN" USING L-ROW WS-EDGE WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
             WHEN "D" WHEN "H"
*>               D n spec x y z table; H n x y z table: the container's placed flag n (SP-F1 to SP-F4) is set once it was created
                 COMPUTE WS-N6 = FUNCTION NUMVAL(WS-TOK(2))
                 EVALUATE WS-N6
                     WHEN 1
                         MOVE SP-F1(L-ROW) TO WS-FLAG
                     WHEN 2
                         MOVE SP-F2(L-ROW) TO WS-FLAG
                     WHEN 3
                         MOVE SP-F3(L-ROW) TO WS-FLAG
                     WHEN OTHER
                         MOVE SP-F4(L-ROW) TO WS-FLAG
                 END-EVALUATE
                 MOVE 0 TO WS-PLACED
                 IF WS-FLAG = 0
                     IF WS-TOK(1) = "D"
                         COMPUTE WS-N1 = FUNCTION NUMVAL(WS-TOK(4))
                         COMPUTE WS-N2 = FUNCTION NUMVAL(WS-TOK(5))
                         COMPUTE WS-N3 = FUNCTION NUMVAL(WS-TOK(6))
                         MOVE "dispenser" TO WS-WANT
                         MOVE WS-TOK(7) TO WS-LOOT
                         CALL "SCP-CONTAINER" USING L-ROW WS-N1 WS-N2 WS-N3 WS-TOK(3) WS-WANT WS-LOOT WS-PLACED
                     ELSE
                         COMPUTE WS-N1 = FUNCTION NUMVAL(WS-TOK(3))
                         COMPUTE WS-N2 = FUNCTION NUMVAL(WS-TOK(4))
                         COMPUTE WS-N3 = FUNCTION NUMVAL(WS-TOK(5))
                         MOVE "chest" TO WS-WANT
                         MOVE WS-TOK(6) TO WS-LOOT
                         CALL "SCP-CONTAINER" USING L-ROW WS-N1 WS-N2 WS-N3 WS-NOSPEC WS-WANT WS-LOOT WS-PLACED
                     END-IF
                 END-IF
                 IF WS-PLACED = 1
                     EVALUATE WS-N6
                         WHEN 1
                             MOVE 1 TO SP-F1(L-ROW)
                         WHEN 2
                             MOVE 1 TO SP-F2(L-ROW)
                         WHEN 3
                             MOVE 1 TO SP-F3(L-ROW)
                         WHEN OTHER
                             MOVE 1 TO SP-F4(L-ROW)
                     END-EVALUATE
                 END-IF
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM SCP-RUN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCP-GROUND.
*> USING row, mode (0 the lowest column height of the whole box, the desert pyramid's updateHeightPositionToLowestGroundHeight; 1 the average, updateAverageGroundHeight, 2.3), offset: moves the
*> piece's box so that its min y is that height plus the offset. The height of a column is its base height (the first y above the stone or water, STRUCT-BASE-HEIGHT kind 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 0.
 01 WS-SUM                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-TARGET              BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-OFFSET               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-MODE L-OFFSET.
     MOVE 0 TO WS-SUM WS-COUNT
     MOVE 100000 TO WS-LOW
     PERFORM VARYING WS-Z FROM SP-Z0(L-ROW) BY 1 UNTIL WS-Z > SP-Z1(L-ROW)
         PERFORM VARYING WS-X FROM SP-X0(L-ROW) BY 1 UNTIL WS-X > SP-X1(L-ROW)
             CALL "STRUCT-BASE-HEIGHT" USING WS-X WS-Z WS-KIND WS-H
             ADD WS-H TO WS-SUM
             ADD 1 TO WS-COUNT
             IF WS-H < WS-LOW
                 MOVE WS-H TO WS-LOW
             END-IF
         END-PERFORM
     END-PERFORM
     IF L-MODE = 0
         MOVE WS-LOW TO WS-TARGET
     ELSE
         COMPUTE WS-TARGET = FUNCTION INTEGER(WS-SUM / WS-COUNT)
     END-IF
     COMPUTE WS-DY = WS-TARGET - SP-Y0(L-ROW) + L-OFFSET
     ADD WS-DY TO SP-Y0(L-ROW) SP-Y1(L-ROW)
     GOBACK.
 END PROGRAM SCP-GROUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCP-POST.
*> USING row: postProcess of a scattered piece: the ground adjuster (2.3), then the piece's blocks.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-AVERAGE             BINARY-LONG VALUE 1.
 01 WS-NO-OFFSET           BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF SP-TYPE(L-ROW) = 101
         CALL "SCP-DESERT-POST" USING L-ROW
         GOBACK
     END-IF
     IF SP-TYPE(L-ROW) = 104
         CALL "SCP-TREASURE-POST" USING L-ROW
         GOBACK
     END-IF
     CALL "SCP-GROUND" USING L-ROW WS-AVERAGE WS-NO-OFFSET
     IF SP-TYPE(L-ROW) = 102
         CALL "SCP-JUNGLE-POST" USING L-ROW
     ELSE
         CALL "SCP-HUT-POST" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM SCP-POST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-SCATTER-FIND-POINT.
*> findGenerationPoint of the swamp hut (5.1: onTopOfChunkCenter, no sea level test) and the jungle temple (SinglePieceStructure, 2.2 item 6: none when the lowest of the four corner heights is
*> below the sea level 63). The start random is seeded by setLargeFeatureSeed; the stub is the top block of the chunk centre's column; the piece is made at (16 cx, 64, 16 cz) with the direction
*> nextInt(4) of north, east, south, west (the only draw of the start random).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-TYPE                BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-HEIGHT              BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 0.
 01 WS-STUB-KIND           BINARY-LONG VALUE 0.
 01 WS-LOW                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-CX2                 BINARY-LONG.
 01 WS-CZ2                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-Y64                 BINARY-LONG VALUE 64.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-NONE                BINARY-LONG VALUE -1.
 01 WS-BX1                 BINARY-LONG.
 01 WS-BY1                 BINARY-LONG.
 01 WS-BZ1                 BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-Y90                 BINARY-LONG VALUE 90.
 01 WS-X1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 WS-DIRS.
    05 FILLER              BINARY-LONG VALUE 2.
    05 FILLER              BINARY-LONG VALUE 3.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
 01 WS-DIR-TABLE REDEFINES WS-DIRS.
    05 WS-DIR-OF           BINARY-LONG OCCURS 4 TIMES.
 LINKAGE SECTION.
 01 L-STRUCT               BINARY-LONG.
 01 L-SEED                 BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STRUCT L-SEED L-CX L-CZ L-X L-Y L-Z L-VALID L-DONE.
     MOVE 1 TO L-DONE
     EVALUATE SDT-KEY(L-STRUCT)
         WHEN "minecraft:desert_pyramid"
             MOVE 101 TO WS-TYPE
             MOVE 21 TO WS-W
             MOVE 15 TO WS-H
             MOVE 21 TO WS-D
         WHEN "minecraft:jungle_pyramid"
             MOVE 102 TO WS-TYPE
             MOVE 12 TO WS-W
             MOVE 10 TO WS-H
             MOVE 15 TO WS-D
         WHEN "minecraft:buried_treasure"
             MOVE 104 TO WS-TYPE
             MOVE 1 TO WS-STUB-KIND
         WHEN "minecraft:swamp_hut"
             MOVE 103 TO WS-TYPE
             MOVE 7 TO WS-W
             MOVE 7 TO WS-H
             MOVE 9 TO WS-D
         WHEN OTHER
             MOVE 0 TO L-DONE
             GOBACK
     END-EVALUATE
     CALL "SPB-RESET"
     COMPUTE WS-USEED = FUNCTION MOD(L-SEED + WS-M64, WS-M64)
     CALL "JRAND-LARGE-FEATURE-SEED" USING SP-RNG WS-USEED L-CX L-CZ
     COMPUTE L-X = L-CX * 16 + 8
     COMPUTE L-Z = L-CZ * 16 + 8
     CALL "STRUCT-BASE-HEIGHT" USING L-X L-Z WS-STUB-KIND WS-HEIGHT
     COMPUTE L-Y = WS-HEIGHT - 1
     MOVE 1 TO L-VALID
*>   the stub only (STRUCT-STUB-OK): the biome at the stub first, so a chunk in the wrong biome costs one height and not the four corners
     IF SD-STUB-ONLY = 1
         CALL "STRUCT-VALID-AT" USING L-STRUCT L-X L-Y L-Z WS-FLAG
         IF WS-FLAG = 0
             MOVE 0 TO L-VALID
             GOBACK
         END-IF
     END-IF
     COMPUTE WS-X0 = L-CX * 16
     COMPUTE WS-Z0 = L-CZ * 16
     IF WS-TYPE = 104
*>       the treasure: no draw; the piece is the block (16 cx + 9, 90, 16 cz + 9), without orientation
         COMPUTE WS-X1 = WS-X0 + 9
         COMPUTE WS-Z1 = WS-Z0 + 9
         MOVE WS-X1 TO WS-BX1
         MOVE WS-Z1 TO WS-BZ1
         MOVE WS-Y90 TO WS-BY1
         CALL "SPB-BOX-NEW" USING WS-X1 WS-Y90 WS-Z1 WS-BX1 WS-BY1 WS-BZ1 WS-BOX
         CALL "SPB-ADD" USING WS-TYPE WS-NONE WS-ZERO WS-ZERO2 WS-BOX WS-ROW
         GOBACK
     END-IF
     IF WS-TYPE NOT = 103
*>       getLowestY: the four corners, the offsets are the full width and depth
         MOVE 100000 TO WS-LOW
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 3
             COMPUTE WS-CX2 = WS-X0
             COMPUTE WS-CZ2 = WS-Z0
             IF WS-I = 1 OR WS-I = 3
                 ADD WS-D TO WS-CZ2
             END-IF
             IF WS-I = 2 OR WS-I = 3
                 ADD WS-W TO WS-CX2
             END-IF
             CALL "STRUCT-BASE-HEIGHT" USING WS-CX2 WS-CZ2 WS-KIND WS-HEIGHT
             SUBTRACT 1 FROM WS-HEIGHT
             IF WS-HEIGHT < WS-LOW
                 MOVE WS-HEIGHT TO WS-LOW
             END-IF
         END-PERFORM
         IF WS-LOW < 63
             MOVE 0 TO L-VALID
             GOBACK
         END-IF
     END-IF
     IF SD-STUB-ONLY = 1
         GOBACK
     END-IF
     MOVE 4 TO WS-BOUND
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-DRAW
     COMPUTE WS-I = WS-DRAW + 1
     MOVE WS-DIR-OF(WS-I) TO WS-DIR
     CALL "SPB-MAKE-BOX" USING WS-X0 WS-Y64 WS-Z0 WS-DIR WS-W WS-H WS-D WS-BOX
     CALL "SPB-ADD" USING WS-TYPE WS-DIR WS-ZERO WS-ZERO2 WS-BOX WS-ROW
     GOBACK.
 END PROGRAM STRUCT-SCATTER-FIND-POINT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCP-TREASURE-POST.
*> USING row: BuriedTreasurePiece.postProcess (36-4 7.2; piece type 104, a one block box at (16 cx + 9, 90, 16 cz + 9), no orientation): h is the first free y of the ocean floor map of the chunk (the
*> window's OCEAN_FLOOR_WG, 35-1 4.2: the piece lies in its own chunk, so the live map is read); from there down to min y the first cell whose block below is sandstone, stone, andesite, granite
*> or diorite takes the chest (createChest, the facing by reorient), after its air or liquid neighbours were filled in the order down, up, north, south, west, east with the sand (or the cell's
*> block when it is none) or, over a void below the neighbour (and not up), the support block; the scan ends there whether or not the chest was made.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY CBLOCKS.
 COPY FEATLEVEL.
 01 WS-ORDINAL             BINARY-LONG VALUE 2.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-CUR                 BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-BN                  BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-CLASS2              BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-STONES              BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-FILL                BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:sand".
 01 WS-PAIRS               PIC X(600) VALUE SPACES.
 01 WS-SAND                BINARY-LONG.
 01 WS-LOOT                PIC X(48) VALUE "minecraft:chests/buried_treasure".
 01 WS-WANT                PIC X(48) VALUE "chest".
 01 WS-NOSPEC              PIC X(60) VALUE SPACES.
 01 WS-PLACED              BINARY-LONG.
 01 WS-LOCAL-Y             BINARY-LONG.
 01 WS-DXS.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 1.
 01 WS-DX-TABLE REDEFINES WS-DXS.
    05 WS-DX               BINARY-LONG OCCURS 6 TIMES.
 01 WS-DYS.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
 01 WS-DY-TABLE REDEFINES WS-DYS.
    05 WS-DY               BINARY-LONG OCCURS 6 TIMES.
 01 WS-DZS.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
 01 WS-DZ-TABLE REDEFINES WS-DZS.
    05 WS-DZ               BINARY-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS WS-SAND
     MOVE SP-X0(L-ROW) TO WS-X
     MOVE SP-Z0(L-ROW) TO WS-Z
     CALL "FL-HEIGHT-OF" USING WS-ORDINAL WS-X WS-Z WS-Y
     MOVE 0 TO WS-DONE
     PERFORM UNTIL WS-Y <= FL-MIN-Y OR WS-DONE = 1
         CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-CUR
         COMPUTE WS-BY = WS-Y - 1
         CALL "FL-GET-STATE" USING WS-X WS-BY WS-Z WS-BELOW
         CALL "FL-BLOCK-OF" USING WS-BELOW WS-B
         MOVE 0 TO WS-STONES
         IF WS-B > 0
             IF CB-KEY(WS-B) = "sandstone" OR "stone" OR "andesite" OR "granite" OR "diorite"
                 MOVE 1 TO WS-STONES
             END-IF
         END-IF
         IF WS-STONES = 1
             CALL "FL-CLASS" USING WS-CUR WS-CLASS
             MOVE WS-CUR TO WS-FILL
             IF WS-CLASS = 1 OR WS-CLASS = 2 OR WS-CLASS = 3
                 MOVE WS-SAND TO WS-FILL
             END-IF
             PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 6
                 COMPUTE WS-NX = WS-X + WS-DX(WS-D)
                 COMPUTE WS-NY = WS-Y + WS-DY(WS-D)
                 COMPUTE WS-NZ = WS-Z + WS-DZ(WS-D)
                 CALL "FL-GET-STATE" USING WS-NX WS-NY WS-NZ WS-N
                 CALL "FL-CLASS" USING WS-N WS-CLASS
                 IF WS-CLASS = 1 OR WS-CLASS = 2 OR WS-CLASS = 3
                     COMPUTE WS-BY = WS-NY - 1
                     CALL "FL-GET-STATE" USING WS-NX WS-BY WS-NZ WS-BN
                     CALL "FL-CLASS" USING WS-BN WS-CLASS2
                     IF (WS-CLASS2 = 1 OR WS-CLASS2 = 2 OR WS-CLASS2 = 3) AND WS-D NOT = 2
                         CALL "FL-SET-STATE" USING WS-NX WS-NY WS-NZ WS-BELOW WS-FLAGS WS-OK
                     ELSE
                         CALL "FL-SET-STATE" USING WS-NX WS-NY WS-NZ WS-FILL WS-FLAGS WS-OK
                     END-IF
                 END-IF
             END-PERFORM
             CALL "SCP-CONTAINER" USING L-ROW WS-X WS-Y WS-Z WS-NOSPEC WS-WANT WS-LOOT WS-PLACED
             MOVE 1 TO WS-DONE
         ELSE
             SUBTRACT 1 FROM WS-Y
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SCP-TREASURE-POST.
