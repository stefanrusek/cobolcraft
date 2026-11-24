*> The stronghold, part 2: the blocks of its pieces (docs/protocol/36-structures-5-mineshaft-stronghold.md section 3.7, 3.5 for the doors and the selector; 36-1 6.5 for the helpers). The layouts are
*> data (STRUCTSHL.cpy, one script line per box or block), run by SHP-RUN in the piece's local frame: every directional state is the north frame state and passes the mirror and rotation of the
*> piece (SPB-DIR-XFORM; a door's hinge swaps under the mirror). The random is the decoration random SP-XR of 36-1 8; a cell outside the write box is skipped but its draw is made.
*> Deviations: the spawner's entity id (silverfish) goes through the block entity channel and makes no draw (31 section 7 is not built); the chest is oriented by reorient (36-1 6.5) over the
*> neighbours the chunk window holds; the liquid edge test and the shape-check marks are not made (the document gives no liquid test for the stronghold pieces); the loot seed is the next nextLong.
*>
*> Entry points: SH-POST USING row (postProcess of the stronghold piece of the row); SHP-RUN USING row, segment (PIC X(3)), x y z offsets (the script lines of the segment).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHP-PUT.
*> USING row, local x y z, state: placeBlock (the cell inside the write box gets the state, flags 2).
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
 END PROGRAM SHP-PUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHP-TOUCH.
*> USING row, local box x0 y0 z0 x1 y1 z1, flag out: 1 when the world box of the local box meets the write box.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-A.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==A-==.
 01 WS-B.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-C.
    05 L-V                 BINARY-LONG OCCURS 6 TIMES.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-C L-FLAG.
     CALL "SPB-WORLD" USING L-ROW L-V(1) BY CONTENT L-V(2) BY CONTENT L-V(3) BY REFERENCE WS-X0 WS-Y0 WS-Z0
     CALL "SPB-WORLD" USING L-ROW L-V(4) BY CONTENT L-V(5) BY CONTENT L-V(6) BY REFERENCE WS-X1 WS-Y1 WS-Z1
     CALL "SPB-BOX-NEW" USING WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-A
     CALL "SPB-BOX-INTERSECTS" USING WS-A SP-WBOX L-FLAG
     GOBACK.
 END PROGRAM SHP-TOUCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHP-FILL.
*> USING row, local box (six BINARY-LONG), state: generateBox with the same edge and fill state, no skip.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-C.
    05 L-V                 BINARY-LONG OCCURS 6 TIMES.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-C L-STATE.
     CALL "SHP-TOUCH" USING L-ROW L-C WS-FLAG
     IF WS-FLAG = 0
         GOBACK
     END-IF
     PERFORM VARYING WS-Y FROM L-V(2) BY 1 UNTIL WS-Y > L-V(5)
         PERFORM VARYING WS-X FROM L-V(1) BY 1 UNTIL WS-X > L-V(4)
             PERFORM VARYING WS-Z FROM L-V(3) BY 1 UNTIL WS-Z > L-V(6)
                 CALL "SHP-PUT" USING L-ROW WS-X WS-Y WS-Z L-STATE
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM SHP-FILL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHP-SELBOX.
*> USING row, local box, skip air (1 or 0): generateBox with the SmoothStoneSelector (3.5): an inner cell is cave air without a draw, an edge cell takes nextFloat: under 0.2 cracked, under 0.5 mossy,
*> under 0.55 infested stone bricks, else stone bricks. With skipAir a cell that holds air (or lies outside the write box) is skipped before the draw.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY STRUCTBLK.
 COPY CBLOCKS.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-XR== LEADING ==XR-== BY ==WX-==.
 01 WS-EPOCH               BINARY-LONG VALUE -1.
 01 WS-S-PLAIN             BINARY-LONG.
 01 WS-S-CRACKED           BINARY-LONG.
 01 WS-S-MOSSY             BINARY-LONG.
 01 WS-S-INFESTED          BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(600).
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-DRAW                FLOAT-LONG.
 01 WS-EDGE                BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-C.
    05 L-V                 BINARY-LONG OCCURS 6 TIMES.
 01 L-SKIP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-C L-SKIP.
     IF L-SKIP = 1
         CALL "SHP-TOUCH" USING L-ROW L-C WS-FLAG
         IF WS-FLAG = 0
             GOBACK
         END-IF
     END-IF
     CALL "MSP-BLOCKS"
     IF WS-EPOCH NOT = CB-EPOCH
         MOVE SPACES TO WS-PAIRS
         MOVE "minecraft:stone_bricks" TO WS-KEY
         CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS WS-S-PLAIN
         MOVE "minecraft:cracked_stone_bricks" TO WS-KEY
         CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS WS-S-CRACKED
         MOVE "minecraft:mossy_stone_bricks" TO WS-KEY
         CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS WS-S-MOSSY
         MOVE "minecraft:infested_stone_bricks" TO WS-KEY
         CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS WS-S-INFESTED
         MOVE CB-EPOCH TO WS-EPOCH
     END-IF
     PERFORM VARYING WS-Y FROM L-V(2) BY 1 UNTIL WS-Y > L-V(5)
         PERFORM VARYING WS-X FROM L-V(1) BY 1 UNTIL WS-X > L-V(4)
             PERFORM VARYING WS-Z FROM L-V(3) BY 1 UNTIL WS-Z > L-V(6)
                 MOVE 0 TO WS-CLASS
                 IF L-SKIP = 1
                     CALL "MSP-GET" USING L-ROW WS-X WS-Y WS-Z WS-STATE
                     CALL "FL-CLASS" USING WS-STATE WS-CLASS
                 END-IF
                 IF WS-CLASS NOT = 1
                     MOVE 0 TO WS-EDGE
                     IF WS-Y = L-V(2) OR WS-Y = L-V(5) OR WS-X = L-V(1) OR WS-X = L-V(4) OR WS-Z = L-V(3) OR WS-Z = L-V(6)
                         MOVE 1 TO WS-EDGE
                     END-IF
                     IF WS-EDGE = 0
                         MOVE SBK-S-CAVE-AIR TO WS-STATE
                     ELSE
                         MOVE SP-XR-LO TO WX-LO
                         MOVE SP-XR-HI TO WX-HI
                         CALL "WGR-NEXT-FLOAT" USING WS-XR WS-DRAW
                         MOVE WX-LO TO SP-XR-LO
                         MOVE WX-HI TO SP-XR-HI
                         EVALUATE TRUE
                             WHEN WS-DRAW < 0.2
                                 MOVE WS-S-CRACKED TO WS-STATE
                             WHEN WS-DRAW < 0.5
                                 MOVE WS-S-MOSSY TO WS-STATE
                             WHEN WS-DRAW < 0.55
                                 MOVE WS-S-INFESTED TO WS-STATE
                             WHEN OTHER
                                 MOVE WS-S-PLAIN TO WS-STATE
                         END-EVALUATE
                     END-IF
                     CALL "SHP-PUT" USING L-ROW WS-X WS-Y WS-Z WS-STATE
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM SHP-SELBOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHP-DIRNAME.
*> USING row, local direction letter (N E S W), side name out (PIC X(5), "north" and so on): the world side after the mirror and the rotation of the piece.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIR                 BINARY-LONG.
 01 WS-OUT                 BINARY-LONG.
 01 WS-NAMES.
    05 FILLER              PIC X(5) VALUE "south".
    05 FILLER              PIC X(5) VALUE "west ".
    05 FILLER              PIC X(5) VALUE "north".
    05 FILLER              PIC X(5) VALUE "east ".
 01 WS-NAME-TAB REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(5) OCCURS 4 TIMES.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-LETTER               PIC X.
 01 L-SIDE                 PIC X(5).
 PROCEDURE DIVISION USING L-ROW L-LETTER L-SIDE.
     EVALUATE L-LETTER
         WHEN "N" MOVE 2 TO WS-DIR
         WHEN "E" MOVE 3 TO WS-DIR
         WHEN "S" MOVE 0 TO WS-DIR
         WHEN OTHER MOVE 1 TO WS-DIR
     END-EVALUATE
     CALL "SPB-DIR-XFORM" USING L-ROW WS-DIR WS-OUT
     MOVE WS-NAME(WS-OUT + 1) TO L-SIDE
     GOBACK.
 END PROGRAM SHP-DIRNAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHP-RESOLVE.
*> USING row, block argument (PIC X(58): name[key=value,...]), state out: the state of minecraft:name with the properties of the north frame turned by the piece. facing takes a letter
*> (N E S W) as its value; north, south, east and west as keys are the local sides; hinge swaps left and right under the mirror (south and west pieces).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(600).
 01 WS-NAME                PIC X(58).
 01 WS-PROPS               PIC X(58).
 01 WS-PAIR                PIC X(58).
 01 WS-PK                  PIC X(10).
 01 WS-PV                  PIC X(10).
 01 WS-PTR                 BINARY-LONG.
 01 WS-OUT                 BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-SIDE                PIC X(5).
 01 WS-LETTER              PIC X.
 01 WS-VAL                 PIC X(10).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ARG                  PIC X(58).
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ARG L-STATE.
     MOVE SPACES TO WS-NAME WS-PROPS WS-PAIRS WS-KEY
     UNSTRING L-ARG DELIMITED BY "[" OR "]" OR SPACE INTO WS-NAME WS-PROPS
     STRING "minecraft:" FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO WS-KEY
     IF WS-PROPS NOT = SPACES
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PROPS)) TO WS-LEN
         MOVE 1 TO WS-PTR
         MOVE 1 TO WS-OUT
         PERFORM UNTIL WS-PTR > WS-LEN
             MOVE SPACES TO WS-PAIR WS-PK WS-PV
             UNSTRING WS-PROPS(1:WS-LEN) DELIMITED BY "," INTO WS-PAIR WITH POINTER WS-PTR
             UNSTRING WS-PAIR DELIMITED BY "=" INTO WS-PK WS-PV
             MOVE WS-PV TO WS-VAL
             EVALUATE FUNCTION TRIM(WS-PK)
                 WHEN "facing"
                     MOVE WS-PV(1:1) TO WS-LETTER
                     CALL "SHP-DIRNAME" USING L-ROW WS-LETTER WS-SIDE
                     MOVE SPACES TO WS-VAL
                     MOVE FUNCTION TRIM(WS-SIDE) TO WS-VAL
                 WHEN "north"
                     MOVE "N" TO WS-LETTER
                     CALL "SHP-DIRNAME" USING L-ROW WS-LETTER WS-SIDE
                     MOVE SPACES TO WS-PK
                     MOVE FUNCTION TRIM(WS-SIDE) TO WS-PK
                 WHEN "south"
                     MOVE "S" TO WS-LETTER
                     CALL "SHP-DIRNAME" USING L-ROW WS-LETTER WS-SIDE
                     MOVE SPACES TO WS-PK
                     MOVE FUNCTION TRIM(WS-SIDE) TO WS-PK
                 WHEN "east"
                     MOVE "E" TO WS-LETTER
                     CALL "SHP-DIRNAME" USING L-ROW WS-LETTER WS-SIDE
                     MOVE SPACES TO WS-PK
                     MOVE FUNCTION TRIM(WS-SIDE) TO WS-PK
                 WHEN "west"
                     MOVE "W" TO WS-LETTER
                     CALL "SHP-DIRNAME" USING L-ROW WS-LETTER WS-SIDE
                     MOVE SPACES TO WS-PK
                     MOVE FUNCTION TRIM(WS-SIDE) TO WS-PK
                 WHEN "hinge"
                     IF SP-ORIENT(L-ROW) = 0 OR SP-ORIENT(L-ROW) = 1
                         IF FUNCTION TRIM(WS-PV) = "left"
                             MOVE "right" TO WS-VAL
                         ELSE
                             MOVE "left" TO WS-VAL
                         END-IF
                     END-IF
             END-EVALUATE
             IF WS-OUT > 1
                 STRING "," DELIMITED BY SIZE INTO WS-PAIRS WITH POINTER WS-OUT
             END-IF
             STRING FUNCTION TRIM(WS-PK) "=" FUNCTION TRIM(WS-VAL) DELIMITED BY SIZE INTO WS-PAIRS WITH POINTER WS-OUT
         END-PERFORM
     END-IF
     CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS L-STATE
     GOBACK.
 END PROGRAM SHP-RESOLVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHP-CHEST.
*> USING row, local x y z, loot table (PIC X(48)): createChest (36-1 6.5): nothing when the cell is outside the write box or holds a chest; a chest oriented by reorient, then the block entity
*> request with the loot table and the seed nextLong.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY CBLOCKS.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-NB                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-CAND                BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-CHEST               BINARY-LONG.
 01 WS-FULL                BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-CHEST-B             BINARY-LONG.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:chest".
 01 WS-PAIRS               PIC X(600).
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-TEXT                PIC X(32) VALUE SPACES.
 01 WS-DXS.
    05 FILLER              PIC S9 VALUE 0.
    05 FILLER              PIC S9 VALUE 1.
    05 FILLER              PIC S9 VALUE 0.
    05 FILLER              PIC S9 VALUE -1.
 01 WS-DX-TAB REDEFINES WS-DXS.
    05 WS-DX               PIC S9 OCCURS 4 TIMES.
 01 WS-DZS.
    05 FILLER              PIC S9 VALUE -1.
    05 FILLER              PIC S9 VALUE 0.
    05 FILLER              PIC S9 VALUE 1.
    05 FILLER              PIC S9 VALUE 0.
 01 WS-DZ-TAB REDEFINES WS-DZS.
    05 WS-DZ               PIC S9 OCCURS 4 TIMES.
 01 WS-SIDES.
    05 FILLER              PIC X(5) VALUE "north".
    05 FILLER              PIC X(5) VALUE "east ".
    05 FILLER              PIC X(5) VALUE "south".
    05 FILLER              PIC X(5) VALUE "west ".
 01 WS-SIDE-TAB REDEFINES WS-SIDES.
    05 WS-SIDE             PIC X(5) OCCURS 4 TIMES.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-LOOT                 PIC X(48).
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-LOOT.
     CALL "SPB-WORLD" USING L-ROW L-X L-Y L-Z WS-WX WS-WY WS-WZ
     CALL "SPB-BOX-INSIDE" USING SP-WBOX WS-WX WS-WY WS-WZ WS-IN
     IF WS-IN = 0
         GOBACK
     END-IF
     MOVE SPACES TO WS-PAIRS
     CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-CHEST-B
     CALL "FL-GET-STATE" USING WS-WX WS-WY WS-WZ WS-NB
     CALL "FL-BLOCK-OF" USING WS-NB WS-B
     IF WS-B = WS-CHEST-B
         GOBACK
     END-IF
*>   reorient: the facing starts north (index 1 of N E S W)
     MOVE 1 TO WS-D
     MOVE 0 TO WS-CAND WS-STOP WS-CHEST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4 OR WS-STOP = 1 OR WS-CHEST = 1
         COMPUTE WS-X = WS-WX + WS-DX(WS-I)
         COMPUTE WS-Z = WS-WZ + WS-DZ(WS-I)
         CALL "FL-GET-STATE" USING WS-X WS-WY WS-Z WS-NB
         CALL "FL-BLOCK-OF" USING WS-NB WS-B
         IF WS-B = WS-CHEST-B
             MOVE 1 TO WS-CHEST
         ELSE
             CALL "MSP-FULL" USING WS-NB WS-FULL
             IF WS-FULL = 1
                 IF WS-CAND = 0
                     MOVE WS-I TO WS-CAND
                 ELSE
                     MOVE 0 TO WS-CAND
                     MOVE 1 TO WS-STOP
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF WS-CHEST = 0
         IF WS-CAND > 0
             COMPUTE WS-D = FUNCTION MOD(WS-CAND + 1, 4) + 1
         ELSE
*>           no unique solid neighbour: while the cell in front is solid turn (opposite, clockwise, opposite)
             PERFORM VARYING WS-STEP FROM 1 BY 1 UNTIL WS-STEP > 3
                 COMPUTE WS-X = WS-WX + WS-DX(WS-D)
                 COMPUTE WS-Z = WS-WZ + WS-DZ(WS-D)
                 CALL "FL-GET-STATE" USING WS-X WS-WY WS-Z WS-NB
                 CALL "MSP-FULL" USING WS-NB WS-FULL
                 IF WS-FULL = 1
                     EVALUATE WS-STEP
                         WHEN 2
                             COMPUTE WS-D = FUNCTION MOD(WS-D, 4) + 1
                         WHEN OTHER
                             COMPUTE WS-D = FUNCTION MOD(WS-D + 1, 4) + 1
                     END-EVALUATE
                 END-IF
             END-PERFORM
         END-IF
         MOVE SPACES TO WS-PAIRS
         STRING "facing=" FUNCTION TRIM(WS-SIDE(WS-D)) DELIMITED BY SIZE INTO WS-PAIRS
         CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS WS-STATE
     END-IF
     CALL "FL-SET-STATE" USING WS-WX WS-WY WS-WZ WS-STATE WS-FLAGS WS-OK
     CALL "MSP-RNG-LONG" USING WS-SEED
     CALL "GBE-ADD" USING WS-WX WS-WY WS-WZ WS-KIND L-LOOT WS-SEED WS-TEXT
*>   the chest corridor saves that its chest was placed (36-5 3.9 key Chest)
     IF SP-TYPE(L-ROW) = 19
         MOVE 1 TO SP-F2(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM SHP-CHEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHP-RUN RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTSHL.
 COPY STRUCTSH.
 COPY STRUCTPIECE.
 COPY STRUCTBLK.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-XR== LEADING ==XR-== BY ==WX-==.
 LOCAL-STORAGE SECTION.
 01 LS-I                   BINARY-LONG.
 01 LS-C.
    05 LS-V                BINARY-LONG OCCURS 6 TIMES.
 01 LS-K                   BINARY-LONG.
 01 LS-STATE               BINARY-LONG.
 01 LS-SEG                 PIC X(3).
 01 LS-CHANCE              FLOAT-LONG.
 01 LS-DRAW                FLOAT-LONG.
 01 LS-X                   BINARY-LONG.
 01 LS-Y                   BINARY-LONG.
 01 LS-Z                   BINARY-LONG.
 01 LS-SKIP                BINARY-LONG.
 01 LS-FLAG                BINARY-LONG.
 01 LS-ARG                 PIC X(58).
 01 LS-LOOT                PIC X(48).
 01 LS-FACE                PIC X(58).
 01 LS-EYE-TEXT            PIC X(5).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SEG                  PIC X(3).
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SEG L-OX L-OY L-OZ.
     PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > SHL-N
         IF SHL-SEG(LS-I) = L-SEG
             PERFORM VARYING LS-K FROM 1 BY 1 UNTIL LS-K > 6
                 MOVE SHL-C(LS-I, LS-K) TO LS-V(LS-K)
             END-PERFORM
             ADD L-OX TO LS-V(1) LS-V(4)
             ADD L-OY TO LS-V(2) LS-V(5)
             ADD L-OZ TO LS-V(3) LS-V(6)
             MOVE SHL-ARG(LS-I) TO LS-ARG
             EVALUATE SHL-OP(LS-I)
                 WHEN "S"
                     MOVE 1 TO LS-SKIP
                     CALL "SHP-SELBOX" USING L-ROW LS-C LS-SKIP
                 WHEN "s"
                     MOVE 0 TO LS-SKIP
                     CALL "SHP-SELBOX" USING L-ROW LS-C LS-SKIP
                 WHEN "A"
                     CALL "SHP-FILL" USING L-ROW LS-C SBK-S-CAVE-AIR
                 WHEN "K"
                     CALL "SHP-TOUCH" USING L-ROW LS-C LS-FLAG
                     IF LS-FLAG = 1
                         CALL "SHP-RESOLVE" USING L-ROW LS-ARG LS-STATE
                         CALL "SHP-FILL" USING L-ROW LS-C LS-STATE
                     END-IF
                 WHEN "M"
*>                   maybeGenerateBlock: the draw is made whatever the cell
                     COMPUTE LS-CHANCE = FUNCTION NUMVAL(LS-ARG(1:4))
                     MOVE SP-XR-LO TO WX-LO
                     MOVE SP-XR-HI TO WX-HI
                     CALL "WGR-NEXT-FLOAT" USING WS-XR LS-DRAW
                     MOVE WX-LO TO SP-XR-LO
                     MOVE WX-HI TO SP-XR-HI
                     IF LS-DRAW < LS-CHANCE
                         MOVE LS-ARG(6:) TO LS-FACE
                         CALL "SHP-RESOLVE" USING L-ROW LS-FACE LS-STATE
                         CALL "SHP-PUT" USING L-ROW LS-V(1) BY CONTENT LS-V(2) BY CONTENT LS-V(3) BY REFERENCE LS-STATE
                     END-IF
                 WHEN "W"
*>                   generateMaybeBox: a draw for every cell first, then the cell when the draw is not above the chance
                     COMPUTE LS-CHANCE = FUNCTION NUMVAL(LS-ARG(1:4))
                     MOVE LS-ARG(6:) TO LS-FACE
                     CALL "SHP-RESOLVE" USING L-ROW LS-FACE LS-STATE
                     PERFORM VARYING LS-Y FROM LS-V(2) BY 1 UNTIL LS-Y > LS-V(5)
                         PERFORM VARYING LS-X FROM LS-V(1) BY 1 UNTIL LS-X > LS-V(4)
                             PERFORM VARYING LS-Z FROM LS-V(3) BY 1 UNTIL LS-Z > LS-V(6)
                                 MOVE SP-XR-LO TO WX-LO
                                 MOVE SP-XR-HI TO WX-HI
                                 CALL "WGR-NEXT-FLOAT" USING WS-XR LS-DRAW
                                 MOVE WX-LO TO SP-XR-LO
                                 MOVE WX-HI TO SP-XR-HI
                                 IF NOT LS-DRAW > LS-CHANCE
                                     CALL "SHP-PUT" USING L-ROW LS-X LS-Y LS-Z LS-STATE
                                 END-IF
                             END-PERFORM
                         END-PERFORM
                     END-PERFORM
                 WHEN "D"
                     MOVE "DO0" TO LS-SEG
                     COMPUTE LS-FLAG = SP-F1(L-ROW)
                     CALL "SHP-DOOR" USING L-ROW LS-C LS-FLAG
                 WHEN "O"
                     MOVE 0 TO LS-FLAG
                     CALL "SHP-DOOR" USING L-ROW LS-C LS-FLAG
                 WHEN "G"
                     MOVE 2 TO LS-FLAG
                     CALL "SHP-DOOR" USING L-ROW LS-C LS-FLAG
                 WHEN "C"
                     MOVE SPACES TO LS-LOOT
                     MOVE LS-ARG TO LS-LOOT
                     CALL "SHP-CHEST" USING L-ROW LS-V(1) BY CONTENT LS-V(2) BY CONTENT LS-V(3) BY REFERENCE LS-LOOT
                 WHEN "F"
*>                   an end portal frame: facing from the argument, eye from the flags drawn for the room
                     ADD 1 TO SH-EYE-IDX
                     MOVE SPACES TO LS-FACE
                     MOVE "false" TO LS-EYE-TEXT
                     IF SH-EYE(SH-EYE-IDX) = 1
                         MOVE "true" TO LS-EYE-TEXT
                     END-IF
                     STRING "end_portal_frame[facing=" LS-ARG(1:1) ",eye=" FUNCTION TRIM(LS-EYE-TEXT) "]" DELIMITED BY SIZE INTO LS-FACE
                     CALL "SHP-RESOLVE" USING L-ROW LS-FACE LS-STATE
                     CALL "SHP-PUT" USING L-ROW LS-V(1) BY CONTENT LS-V(2) BY CONTENT LS-V(3) BY REFERENCE LS-STATE
             END-EVALUATE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SHP-RUN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHP-DOOR.
*> USING row, local box (six BINARY-LONG), door type (0 opening, 1 wood, 2 grates, 3 iron): generateSmallDoor (3.5), the door script of the type at the door position (the box's first corner).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SEG                 PIC X(3).
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-C.
    05 L-V                 BINARY-LONG OCCURS 6 TIMES.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-C L-FLAG.
     MOVE L-V(1) TO WS-OX
     MOVE L-V(2) TO WS-OY
     MOVE L-V(3) TO WS-OZ
     MOVE "DO0" TO WS-SEG
     MOVE FUNCTION CHAR(L-FLAG + 49) TO WS-SEG(3:1)
     CALL "SHP-RUN" USING L-ROW WS-SEG WS-OX WS-OY WS-OZ
     GOBACK.
 END PROGRAM SHP-DOOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SH-POST-PORTAL.
*> The portal room (3.7): the shell, the lava and the stairs (the script PR0), twelve eye draws (nextFloat above 0.9, all before a frame is placed), the twelve frames, the nine portal blocks when
*> every eye is set, and the silverfish spawner at (5,3,6) when that cell is inside the write box.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTSH.
 COPY STRUCTPIECE.
 COPY STRUCTBLK.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-XR== LEADING ==XR-== BY ==WX-==.
 01 WS-I                   BINARY-LONG.
 01 WS-ALL                 BINARY-LONG.
 01 WS-DRAW                FLOAT-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-LX                  BINARY-LONG VALUE 5.
 01 WS-LY                  BINARY-LONG VALUE 3.
 01 WS-LZ                  BINARY-LONG VALUE 6.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 2.
 01 WS-NOLOOT              PIC X(48) VALUE SPACES.
 01 WS-SEED                BINARY-DOUBLE VALUE 0.
 01 WS-FISH                PIC X(32) VALUE "minecraft:silverfish".
 01 WS-S0                  PIC X(3) VALUE "PR0".
 01 WS-SF                  PIC X(3) VALUE "PFR".
 01 WS-SQ                  PIC X(3).
 01 WS-SQ-NAMES.
    05 FILLER              PIC X(3) VALUE "PQX".
    05 FILLER              PIC X(3) VALUE "PQ0".
 01 WS-SQ-TAB REDEFINES WS-SQ-NAMES.
    05 WS-SQ-NAME          PIC X(3) OCCURS 2 TIMES.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "SHP-RUN" USING L-ROW WS-S0 WS-ZERO BY CONTENT WS-ZERO BY CONTENT WS-ZERO
     MOVE 1 TO WS-ALL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         MOVE SP-XR-LO TO WX-LO
         MOVE SP-XR-HI TO WX-HI
         CALL "WGR-NEXT-FLOAT" USING WS-XR WS-DRAW
         MOVE WX-LO TO SP-XR-LO
         MOVE WX-HI TO SP-XR-HI
         IF WS-DRAW > 0.9
             MOVE 1 TO SH-EYE(WS-I)
         ELSE
             MOVE 0 TO SH-EYE(WS-I)
             MOVE 0 TO WS-ALL
         END-IF
     END-PERFORM
     MOVE 0 TO SH-EYE-IDX
     CALL "SHP-RUN" USING L-ROW WS-SF WS-ZERO BY CONTENT WS-ZERO BY CONTENT WS-ZERO
*>   Every eye set (the drawn flags: probability 0.1 ^ 12) puts the nine portal blocks; otherwise the segment PQX, which has no script line, runs.
     MOVE WS-SQ-NAME(WS-ALL + 1) TO WS-SQ
     CALL "SHP-RUN" USING L-ROW WS-SQ WS-ZERO BY CONTENT WS-ZERO BY CONTENT WS-ZERO
     CALL "SPB-WORLD" USING L-ROW WS-LX WS-LY WS-LZ WS-WX WS-WY WS-WZ
     CALL "SPB-BOX-INSIDE" USING SP-WBOX WS-WX WS-WY WS-WZ WS-IN
     IF WS-IN = 1
         CALL "MSP-PLACE-RAW" USING WS-WX WS-WY WS-WZ SBK-S-SPAWNER
         CALL "GBE-ADD" USING WS-WX WS-WY WS-WZ WS-KIND WS-NOLOOT WS-SEED WS-FISH
*>       the portal room saves that its spawner was placed (36-5 3.9 key Mob)
         MOVE 1 TO SP-F2(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM SH-POST-PORTAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SH-POST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-Z                   BINARY-LONG.
 01 WS-NE                  BINARY-LONG.
 01 WS-SEG                 PIC X(3).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "MSP-BLOCKS"
     MOVE 0 TO WS-NE
     IF SP-ORIENT(L-ROW) = 2 OR SP-ORIENT(L-ROW) = 3
         MOVE 1 TO WS-NE
     END-IF
     EVALUATE SP-TYPE(L-ROW)
         WHEN 30
             MOVE "ST0" TO WS-SEG
             CALL "SHP-RUN" USING L-ROW WS-SEG WS-ZERO BY CONTENT WS-ZERO BY CONTENT WS-ZERO
             IF SP-F2(L-ROW) = 1
                 MOVE "STL" TO WS-SEG
                 CALL "SHP-RUN" USING L-ROW WS-SEG WS-ZERO BY CONTENT WS-ZERO BY CONTENT WS-ZERO
             END-IF
             IF SP-F3(L-ROW) = 1
                 MOVE "STR" TO WS-SEG
                 CALL "SHP-RUN" USING L-ROW WS-SEG WS-ZERO BY CONTENT WS-ZERO BY CONTENT WS-ZERO
             END-IF
         WHEN 19
             MOVE "CC0" TO WS-SEG
             CALL "SHP-RUN" USING L-ROW WS-SEG WS-ZERO BY CONTENT WS-ZERO BY CONTENT WS-ZERO
             MOVE "CC1" TO WS-SEG
             CALL "SHP-RUN" USING L-ROW WS-SEG WS-ZERO BY CONTENT WS-ZERO BY CONTENT WS-ZERO
         WHEN 20
             MOVE "FC0" TO WS-SEG
             PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z >= SP-F2(L-ROW)
                 CALL "SHP-RUN" USING L-ROW WS-SEG WS-ZERO BY CONTENT WS-ZERO BY REFERENCE WS-Z
             END-PERFORM
         WHEN 22
             MOVE "TU0" TO WS-SEG
             CALL "SHP-RUN" USING L-ROW WS-SEG WS-ZERO BY CONTENT WS-ZERO BY CONTENT WS-ZERO
             IF WS-NE = 1
                 MOVE "TUL" TO WS-SEG
             ELSE
                 MOVE "TUR" TO WS-SEG
             END-IF
             CALL "SHP-RUN" USING L-ROW WS-SEG WS-ZERO BY CONTENT WS-ZERO BY CONTENT WS-ZERO
         WHEN 26
             MOVE "TU0" TO WS-SEG
             CALL "SHP-RUN" USING L-ROW WS-SEG WS-ZERO BY CONTENT WS-ZERO BY CONTENT WS-ZERO
             IF WS-NE = 1
                 MOVE "TUR" TO WS-SEG
             ELSE
                 MOVE "TUL" TO WS-SEG
             END-IF
             CALL "SHP-RUN" USING L-ROW WS-SEG WS-ZERO BY CONTENT WS-ZERO BY CONTENT WS-ZERO
         WHEN 27
             MOVE "RC0" TO WS-SEG
             CALL "SHP-RUN" USING L-ROW WS-SEG WS-ZERO BY CONTENT WS-ZERO BY CONTENT WS-ZERO
             IF SP-F2(L-ROW) < 3
                 MOVE "RC1" TO WS-SEG
                 MOVE FUNCTION CHAR(SP-F2(L-ROW) + 50) TO WS-SEG(3:1)
                 CALL "SHP-RUN" USING L-ROW WS-SEG WS-ZERO BY CONTENT WS-ZERO BY CONTENT WS-ZERO
             END-IF
         WHEN 21
             MOVE "F50" TO WS-SEG
             CALL "SHP-RUN" USING L-ROW WS-SEG WS-ZERO BY CONTENT WS-ZERO BY CONTENT WS-ZERO
             IF SP-F2(L-ROW) = 1
                 MOVE "F5A" TO WS-SEG
                 CALL "SHP-RUN" USING L-ROW WS-SEG WS-ZERO BY CONTENT WS-ZERO BY CONTENT WS-ZERO
             END-IF
             IF SP-F4(L-ROW) = 1
                 MOVE "F5B" TO WS-SEG
                 CALL "SHP-RUN" USING L-ROW WS-SEG WS-ZERO BY CONTENT WS-ZERO BY CONTENT WS-ZERO
             END-IF
             IF SP-F3(L-ROW) = 1
                 MOVE "F5C" TO WS-SEG
                 CALL "SHP-RUN" USING L-ROW WS-SEG WS-ZERO BY CONTENT WS-ZERO BY CONTENT WS-ZERO
             END-IF
             IF SP-MST(L-ROW) = 1
                 MOVE "F5D" TO WS-SEG
                 CALL "SHP-RUN" USING L-ROW WS-SEG WS-ZERO BY CONTENT WS-ZERO BY CONTENT WS-ZERO
             END-IF
             MOVE "F5E" TO WS-SEG
             CALL "SHP-RUN" USING L-ROW WS-SEG WS-ZERO BY CONTENT WS-ZERO BY CONTENT WS-ZERO
         WHEN 25
             MOVE "PH0" TO WS-SEG
             CALL "SHP-RUN" USING L-ROW WS-SEG WS-ZERO BY CONTENT WS-ZERO BY CONTENT WS-ZERO
         WHEN 31
             MOVE "SS0" TO WS-SEG
             CALL "SHP-RUN" USING L-ROW WS-SEG WS-ZERO BY CONTENT WS-ZERO BY CONTENT WS-ZERO
         WHEN 28 WHEN 29
             MOVE "SD0" TO WS-SEG
             CALL "SHP-RUN" USING L-ROW WS-SEG WS-ZERO BY CONTENT WS-ZERO BY CONTENT WS-ZERO
         WHEN 23
             IF SP-F2(L-ROW) = 1
                 MOVE "LT0" TO WS-SEG
             ELSE
                 MOVE "LS0" TO WS-SEG
             END-IF
             CALL "SHP-RUN" USING L-ROW WS-SEG WS-ZERO BY CONTENT WS-ZERO BY CONTENT WS-ZERO
             MOVE "LC0" TO WS-SEG
             CALL "SHP-RUN" USING L-ROW WS-SEG WS-ZERO BY CONTENT WS-ZERO BY CONTENT WS-ZERO
             IF SP-F2(L-ROW) = 1
                 MOVE "LD0" TO WS-SEG
                 CALL "SHP-RUN" USING L-ROW WS-SEG WS-ZERO BY CONTENT WS-ZERO BY CONTENT WS-ZERO
             END-IF
             MOVE "LE0" TO WS-SEG
             CALL "SHP-RUN" USING L-ROW WS-SEG WS-ZERO BY CONTENT WS-ZERO BY CONTENT WS-ZERO
             IF SP-F2(L-ROW) = 1
                 MOVE "LE1" TO WS-SEG
                 CALL "SHP-RUN" USING L-ROW WS-SEG WS-ZERO BY CONTENT WS-ZERO BY CONTENT WS-ZERO
             END-IF
         WHEN 24
             CALL "SH-POST-PORTAL" USING L-ROW
     END-EVALUATE
     GOBACK.
 END PROGRAM SH-POST.
