*> Test of the blocks of the stronghold pieces (docs/protocol/36-structures-5 section 3.7, 3.5; 36-1 6.5; core/src/struct-sh-place.cob; T10001): the world is a chunk of stone up to y 70.
*> A straight piece (north) has the opening door, the carved inside, the brick shell with the selector's four states and no block outside the write box; the stairs of the straight stairs down
*> face the way of the local frame after the piece's mirror and rotation (north, south, east); the prison hall's iron door has the hinge swapped by the mirror; the chest corridor's chest is
*> a chest; the portal room has the twelve frames in the listed cells with their facings and eye flags, the nine portal blocks only with every eye, and the spawner.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-SH-PLACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATLEVEL.
 COPY STRUCTPIECE.
 COPY STRUCTBLK.
 COPY STRUCTSH.
 01 WS-STATUS              BINARY-LONG.
 01 WS-PTR                 USAGE POINTER.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==A-==.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(600).
 01 WS-CX                  BINARY-LONG VALUE 0.
 01 WS-CZ                  BINARY-LONG VALUE 0.
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-I                   BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-L                   BINARY-LONG.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-PO-ED               PIC 9.
 01 WS-J                   BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-PT                  BINARY-LONG.
 01 WS-PO                  BINARY-LONG.
 01 WS-MST                 BINARY-LONG VALUE 0.
 01 WS-DEP                 BINARY-LONG VALUE 0.
 01 WS-N                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-SEG                 PIC X(3) VALUE "PFR".
 01 WS-SEGQ                PIC X(3) VALUE "PQ0".
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-B                   BINARY-LONG.
 01 WS-STONE-B             BINARY-LONG.
 01 WS-BRICK.
    05 WS-BR               BINARY-LONG OCCURS 4 TIMES.
 01 WS-BRICK-B.
    05 WS-BRB              BINARY-LONG OCCURS 4 TIMES.
 01 WS-STAIR               BINARY-LONG.
 01 WS-FRAME               BINARY-LONG.
 01 WS-EYE                 BINARY-LONG.
 01 WS-FACING              BINARY-LONG.
 01 WS-WANT-FACING         BINARY-LONG.
 01 WS-TEXT                PIC X(60).
 01 WS-DIRS.
    05 FILLER              PIC 9 VALUE 2.
    05 FILLER              PIC 9 VALUE 2.
    05 FILLER              PIC 9 VALUE 2.
    05 FILLER              PIC 9 VALUE 0.
    05 FILLER              PIC 9 VALUE 0.
    05 FILLER              PIC 9 VALUE 0.
    05 FILLER              PIC 9 VALUE 3.
    05 FILLER              PIC 9 VALUE 3.
    05 FILLER              PIC 9 VALUE 3.
    05 FILLER              PIC 9 VALUE 1.
    05 FILLER              PIC 9 VALUE 1.
    05 FILLER              PIC 9 VALUE 1.
 01 WS-DIR-TAB REDEFINES WS-DIRS.
    05 WS-DIR-OF           PIC 9 OCCURS 12 TIMES.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     ALLOCATE 304640 CHARACTERS INITIALIZED RETURNING WS-PTR
     MOVE SPACES TO WS-PAIRS
     MOVE "minecraft:stone" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STONE
     CALL "FL-BLOCK-OF" USING WS-STONE WS-STONE-B
     MOVE "minecraft:stone_bricks" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-BR(1)
     MOVE "minecraft:cracked_stone_bricks" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-BR(2)
     MOVE "minecraft:mossy_stone_bricks" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-BR(3)
     MOVE "minecraft:infested_stone_bricks" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-BR(4)

*>   a straight piece facing north, box (1,40,1)..(5,44,7), no side children
     PERFORM STONE-WORLD
     MOVE 1 TO A-X0 MOVE 40 TO A-Y0 MOVE 1 TO A-Z0 MOVE 5 TO A-X1 MOVE 44 TO A-Y1 MOVE 7 TO A-Z1
     MOVE 30 TO WS-PT
     MOVE 2 TO WS-PO
     PERFORM ADD-PIECE
     CALL "SH-POST" USING WS-ROW
*>   local (1,1,0) is the entry door: opening (entryDoor 0) is cave air at world (2,41,7), (4,43,7) the corner of the box
     MOVE 2 TO WS-X MOVE 41 TO WS-Y MOVE 7 TO WS-Z
     MOVE SBK-S-CAVE-AIR TO WS-WANT
     MOVE "acceptance US12 36-5§3.7 Straight: the entry opening is cave air at the front (local 1,1,0)" TO TL-CASE
     PERFORM CHECK-CELL
     MOVE 3 TO WS-X MOVE 42 TO WS-Y MOVE 4 TO WS-Z
     MOVE "acceptance US12 36-5§3.7 Straight: the inside (local 2,2,3) is cave air" TO TL-CASE
     PERFORM CHECK-CELL
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-Y FROM 40 BY 1 UNTIL WS-Y > 44
         PERFORM VARYING WS-X FROM 1 BY 1 UNTIL WS-X > 5
             PERFORM VARYING WS-Z FROM 1 BY 1 UNTIL WS-Z > 7
                 IF WS-Y = 40 OR WS-Y = 44 OR WS-X = 1 OR WS-X = 5 OR WS-Z = 1 OR WS-Z = 7
                     PERFORM CELL-STATE
                     MOVE 0 TO WS-N
                     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
                         IF WS-S = WS-BR(WS-I)
                             MOVE 1 TO WS-N
                         END-IF
                     END-PERFORM
                     IF WS-S = SBK-S-CAVE-AIR
                         MOVE 1 TO WS-N
                     END-IF
                     IF WS-N = 0
                         ADD 1 TO WS-BAD
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-5§3.7 Straight: every edge cell is a brick state or the carved opening (door cells)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE 0 TO WS-J
         PERFORM VARYING WS-Y FROM 40 BY 1 UNTIL WS-Y > 44
             PERFORM VARYING WS-X FROM 1 BY 1 UNTIL WS-X > 5
                 PERFORM VARYING WS-Z FROM 1 BY 1 UNTIL WS-Z > 7
                     PERFORM CELL-STATE
                     IF WS-S = WS-BR(WS-I)
                         ADD 1 TO WS-J
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-PERFORM
         IF WS-J > 0
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-5§3.5 the selector gives all four brick kinds over the 130 edge cells" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   outside the box nothing is written
     MOVE 6 TO WS-X MOVE 42 TO WS-Y MOVE 4 TO WS-Z
     MOVE WS-STONE TO WS-WANT
     MOVE "acceptance US12 36-5§3.7 Straight: a cell outside the piece's box is left alone" TO TL-CASE
     PERFORM CHECK-CELL

*>   straight stairs down in the four orientations: the stairs face south in the local frame (6 - k, 1 + k)
     PERFORM VARYING WS-L FROM 1 BY 1 UNTIL WS-L > 4
         PERFORM STONE-WORLD
         EVALUATE WS-L
             WHEN 1
                 MOVE 2 TO WS-PO
                 MOVE 1 TO A-X0 MOVE 1 TO A-Z0 MOVE 5 TO A-X1 MOVE 8 TO A-Z1
                 MOVE "facing=south" TO WS-PAIRS
             WHEN 2
                 MOVE 0 TO WS-PO
                 MOVE 1 TO A-X0 MOVE 1 TO A-Z0 MOVE 5 TO A-X1 MOVE 8 TO A-Z1
                 MOVE "facing=north" TO WS-PAIRS
             WHEN 3
                 MOVE 3 TO WS-PO
                 MOVE 1 TO A-X0 MOVE 1 TO A-Z0 MOVE 8 TO A-X1 MOVE 5 TO A-Z1
                 MOVE "facing=west" TO WS-PAIRS
             WHEN OTHER
                 MOVE 1 TO WS-PO
                 MOVE 1 TO A-X0 MOVE 1 TO A-Z0 MOVE 8 TO A-X1 MOVE 5 TO A-Z1
                 MOVE "facing=east" TO WS-PAIRS
         END-EVALUATE
         MOVE "minecraft:cobblestone_stairs" TO WS-KEY
         MOVE FUNCTION CONCATENATE("half=bottom,shape=straight,waterlogged=false,", FUNCTION TRIM(WS-PAIRS)) TO WS-PAIRS
         CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STAIR
         MOVE 40 TO A-Y0
         MOVE 50 TO A-Y1
         MOVE 31 TO WS-PT
         PERFORM ADD-PIECE
         CALL "SH-POST" USING WS-ROW
*>       the first stair (k = 0) is local (1, 6, 1): the front cell next to the entry
         MOVE 1 TO WS-X
         MOVE 6 TO WS-Y
         MOVE 1 TO WS-Z
         CALL "SPB-WORLD" USING WS-ROW WS-X WS-Y WS-Z WS-WX WS-WY WS-WZ
         MOVE WS-WX TO WS-X
         MOVE WS-WY TO WS-Y
         MOVE WS-WZ TO WS-Z
         MOVE WS-STAIR TO WS-WANT
         MOVE SPACES TO TL-CASE
         MOVE WS-PO TO WS-PO-ED
         STRING "acceptance US12 36-5§6 Q1 the stairs of a straight stairs down face the way of the local frame, orientation " WS-PO-ED DELIMITED BY SIZE INTO TL-CASE
         PERFORM CHECK-CELL
     END-PERFORM

*>   the chest corridor's chest (local 3,2,3) of a north piece (1,40,1)..(5,44,7): world (4, 42, 4)
     PERFORM STONE-WORLD
     MOVE 1 TO A-X0 MOVE 40 TO A-Y0 MOVE 1 TO A-Z0 MOVE 5 TO A-X1 MOVE 44 TO A-Y1 MOVE 7 TO A-Z1
     MOVE 19 TO WS-PT
     MOVE 2 TO WS-PO
     PERFORM ADD-PIECE
     CALL "SH-POST" USING WS-ROW
     MOVE 4 TO WS-X MOVE 42 TO WS-Y MOVE 4 TO WS-Z
     PERFORM CELL-STATE
     MOVE "minecraft:chest" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-FRAME
     CALL "FL-BLOCK-OF" USING WS-FRAME WS-I
     CALL "FL-BLOCK-OF" USING WS-S WS-J
     MOVE "acceptance US12 36-5§3.7 ChestCorridor: the chest stands at local (3,2,3)" TO TL-CASE
     MOVE WS-I TO TL-EXPECTED-N
     MOVE WS-J TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the portal room of a north piece (0,40,0)..(10,47,15): frames, lava, spawner
     PERFORM STONE-WORLD
     MOVE 0 TO A-X0 MOVE 40 TO A-Y0 MOVE 0 TO A-Z0 MOVE 10 TO A-X1 MOVE 47 TO A-Y1 MOVE 15 TO A-Z1
     MOVE 24 TO WS-PT
     MOVE 2 TO WS-PO
     PERFORM ADD-PIECE
     CALL "SH-POST" USING WS-ROW
     MOVE 0 TO WS-BAD
     MOVE "minecraft:end_portal_frame" TO WS-KEY
     PERFORM VARYING WS-L FROM 1 BY 1 UNTIL WS-L > 12
         EVALUATE TRUE
             WHEN WS-L <= 3
                 COMPUTE WS-X = 3 + WS-L
                 MOVE 43 TO WS-Y
                 MOVE 7 TO WS-Z
             WHEN WS-L <= 6
                 COMPUTE WS-X = WS-L
                 MOVE 43 TO WS-Y
                 MOVE 3 TO WS-Z
             WHEN WS-L <= 9
                 MOVE 7 TO WS-X
                 MOVE 43 TO WS-Y
                 COMPUTE WS-Z = 15 - (WS-L - 6 + 8)
             WHEN OTHER
                 MOVE 3 TO WS-X
                 MOVE 43 TO WS-Y
                 COMPUTE WS-Z = 15 - (WS-L - 9 + 8)
         END-EVALUATE
         PERFORM CELL-STATE
         CALL "FL-BLOCK-OF" USING WS-S WS-J
         MOVE "minecraft:end_portal_frame" TO WS-KEY
         MOVE SPACES TO WS-PAIRS
         CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-FRAME
         CALL "FL-BLOCK-OF" USING WS-FRAME WS-I
         IF WS-I NOT = WS-J
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-5§3.7 PortalRoom: the twelve end_portal_frame blocks are at the listed cells" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-X MOVE 43 TO WS-Y MOVE 9 TO WS-Z
     MOVE SBK-S-SPAWNER TO WS-WANT
     MOVE "acceptance US12 36-5§3.7 PortalRoom: the spawner stands at local (5,3,6)" TO TL-CASE
     PERFORM CHECK-CELL
     MOVE "minecraft:lava" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-WANT
     MOVE 1 TO WS-X MOVE 41 TO WS-Y MOVE 14 TO WS-Z
     MOVE "acceptance US12 36-5§3.7 PortalRoom: lava at local (1,1,1)" TO TL-CASE
     PERFORM CHECK-CELL
*>   every eye set: the frames have eye true and the nine portal blocks are there (PFR and PQ0 run with the flags)
     PERFORM VARYING WS-L FROM 1 BY 1 UNTIL WS-L > 12
         MOVE 1 TO SH-EYE(WS-L)
     END-PERFORM
     MOVE 0 TO SH-EYE-IDX
     CALL "SHP-RUN" USING WS-ROW WS-SEG WS-ZERO BY CONTENT WS-ZERO BY CONTENT WS-ZERO
     CALL "SHP-RUN" USING WS-ROW WS-SEGQ WS-ZERO BY CONTENT WS-ZERO BY CONTENT WS-ZERO
     MOVE "minecraft:end_portal_frame" TO WS-KEY
     MOVE "eye=true,facing=north" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-WANT
     MOVE 4 TO WS-X MOVE 43 TO WS-Y MOVE 7 TO WS-Z
     MOVE "acceptance US12 36-5§3.7 PortalRoom: frame 0 with its eye is end_portal_frame facing north, eye true" TO TL-CASE
     PERFORM CHECK-CELL
     MOVE "minecraft:end_portal" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-WANT
     MOVE 5 TO WS-X MOVE 43 TO WS-Y MOVE 5 TO WS-Z
     MOVE "acceptance US12 36-5§3.7 PortalRoom: with every eye the centre (5,3,10) is an end_portal block" TO TL-CASE
     PERFORM CHECK-CELL
*>   the prison hall's iron door (local 4,1,2, facing west) of a south piece takes the mirror: hinge right, facing west
     PERFORM STONE-WORLD
     MOVE 0 TO A-X0 MOVE 40 TO A-Y0 MOVE 0 TO A-Z0 MOVE 8 TO A-X1 MOVE 44 TO A-Y1 MOVE 10 TO A-Z1
     MOVE 25 TO WS-PT
     MOVE 0 TO WS-PO
     PERFORM ADD-PIECE
     CALL "SH-POST" USING WS-ROW
     MOVE "minecraft:iron_door" TO WS-KEY
     MOVE "facing=west,half=lower,hinge=right,open=false,powered=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-WANT
     MOVE 4 TO WS-X MOVE 41 TO WS-Y MOVE 2 TO WS-Z
     MOVE "acceptance US12 36-5§6 Q1 the prison hall's iron door of a south piece: facing west, hinge swapped to right" TO TL-CASE
     PERFORM CHECK-CELL
     STOP RUN.

 STONE-WORLD.
     CALL "SPB-RESET"
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     MOVE LOW-VALUES TO CE-CHUNK
     PERFORM VARYING WS-IDX FROM 1 BY 1 UNTIL WS-IDX > 135 * 256
         MOVE WS-STONE TO CE-STATE(WS-IDX)
     END-PERFORM
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     CALL "MSP-OPEN"
     MOVE 5 TO SP-XR-LO
     MOVE 7 TO SP-XR-HI
     CALL "SH-RESET".
 ADD-PIECE.
     CALL "SPB-ADD" USING WS-PT WS-PO WS-DEP WS-MST WS-BOX WS-ROW.
 CELL-STATE.
     COMPUTE WS-IDX = (WS-Y + 64) * 256 + WS-Z * 16 + WS-X + 1
     MOVE CE-STATE(WS-IDX) TO WS-S.
 CHECK-CELL.
     PERFORM CELL-STATE
     MOVE WS-S TO TL-OBSERVED-N
     MOVE WS-WANT TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 END PROGRAM TEST-STRUCT-SH-PLACE.
 COPY CORETEST.
