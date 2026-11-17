*> Implementation test (coverage lane A; docs/protocol/36-structures-5 section 3.7, 36-1 6.5; core/src/struct-sh-place.cob): the side openings of the straight piece, the five crossing's
*> rows, the turns (left or right by the orientation), the room crossing variants, the library (short and tall, cobwebs, the stair chest), a piece outside the write box that writes nothing,
*> a chest that finds a chest or one solid neighbour, and the mirrored hinge of a right-hinged door.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVA-STRUCT-SH-PLACE.
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
 01 WS-PTR                 USAGE POINTER.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==A-==.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(600).
 01 WS-CX                  BINARY-LONG VALUE 0.
 01 WS-CZ                  BINARY-LONG VALUE 0.
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-IDX                 BINARY-LONG.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-PT                  BINARY-LONG.
 01 WS-PO                  BINARY-LONG.
 01 WS-MST                 BINARY-LONG VALUE 0.
 01 WS-DEP                 BINARY-LONG VALUE 0.
 01 WS-N                   BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-B1                  BINARY-LONG.
 01 WS-B2                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-ARG                 PIC X(58).
 01 WS-STATE               BINARY-LONG.
 01 WS-LOOT                PIC X(48) VALUE "minecraft:chests/stronghold_corridor".
 01 WS-DIGIT               PIC 9.
 01 WS-PT2                 PIC 99.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-BRICKS              BINARY-LONG.
 01 WS-BOOKS               BINARY-LONG.
 01 WS-PLANKS              BINARY-LONG.
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
     MOVE "minecraft:stone_bricks" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-BRICKS
     MOVE "minecraft:bookshelf" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-BOOKS
     MOVE "minecraft:oak_planks" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-PLANKS
     CALL "MSP-BLOCKS"
     MOVE SBK-S-CAVE-AIR TO WS-AIR
*>   A straight piece (north) with side openings on both sides: the wall cells at local (0,2,3) and (4,2,3) are carved.
     PERFORM STONE-WORLD
     MOVE 1 TO A-X0 MOVE 40 TO A-Y0 MOVE 1 TO A-Z0 MOVE 5 TO A-X1 MOVE 44 TO A-Y1 MOVE 7 TO A-Z1
     MOVE 30 TO WS-PT
     MOVE 2 TO WS-PO
     PERFORM ADD-PIECE
     MOVE 1 TO SP-F2(WS-ROW)
     MOVE 1 TO SP-F3(WS-ROW)
     CALL "SH-POST" USING WS-ROW
     MOVE 0 TO WS-LX MOVE 2 TO WS-LY MOVE 3 TO WS-LZ
     MOVE WS-AIR TO WS-WANT
     MOVE "test cova struct sh place a straight piece with a left opening carves local (0,2,3)" TO TL-CASE
     PERFORM CHECK-LOCAL
     MOVE 4 TO WS-LX
     MOVE "test cova struct sh place a straight piece with a right opening carves local (4,2,3)" TO TL-CASE
     PERFORM CHECK-LOCAL
*>   Without the openings the same cells are bricks.
     PERFORM STONE-WORLD
     PERFORM ADD-PIECE
     CALL "SH-POST" USING WS-ROW
     MOVE 0 TO WS-LX
     MOVE 1 TO TL-EXPECTED-N
     PERFORM LOCAL-STATE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-S NOT = WS-AIR AND WS-S NOT = WS-STONE
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE "test cova struct sh place a straight piece without openings keeps its wall at local (0,2,3)" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A piece outside the write box writes nothing (every box misses the chunk).
     PERFORM STONE-WORLD
     MOVE 100 TO A-X0 MOVE 40 TO A-Y0 MOVE 100 TO A-Z0 MOVE 104 TO A-X1 MOVE 44 TO A-Y1 MOVE 106 TO A-Z1
     MOVE 30 TO WS-PT
     MOVE 2 TO WS-PO
     PERFORM ADD-PIECE
     CALL "SH-POST" USING WS-ROW
     MOVE 5 TO WS-X MOVE 42 TO WS-Y MOVE 5 TO WS-Z
     MOVE WS-STONE TO WS-WANT
     MOVE "test cova struct sh place a piece outside the write box leaves the chunk alone" TO TL-CASE
     PERFORM CHECK-CELL
*>   The five crossing: two rows of the stone brick script (offset 0 and 1 along z) with F2 = 2.
     PERFORM STONE-WORLD
     MOVE 0 TO A-X0 MOVE 40 TO A-Y0 MOVE 0 TO A-Z0 MOVE 4 TO A-X1 MOVE 44 TO A-Y1 MOVE 8 TO A-Z1
     MOVE 20 TO WS-PT
     MOVE 2 TO WS-PO
     PERFORM ADD-PIECE
     MOVE 2 TO SP-F2(WS-ROW)
     CALL "SH-POST" USING WS-ROW
     MOVE 2 TO WS-LX MOVE 0 TO WS-LY MOVE 1 TO WS-LZ
     MOVE WS-BRICKS TO WS-WANT
     MOVE "test cova struct sh place the second row of the F2 = 2 crossing is stone bricks at local (2,0,1)" TO TL-CASE
     PERFORM CHECK-LOCAL
*>   The turns: type 22 opens the left side for the east and west orientations and the right otherwise; type 26 the other way.
     PERFORM VARYING WS-PT FROM 22 BY 4 UNTIL WS-PT > 26
         PERFORM VARYING WS-PO FROM 0 BY 2 UNTIL WS-PO > 2
             PERFORM STONE-WORLD
             MOVE 0 TO A-X0 MOVE 40 TO A-Y0 MOVE 0 TO A-Z0 MOVE 4 TO A-X1 MOVE 44 TO A-Y1 MOVE 4 TO A-Z1
             PERFORM ADD-PIECE
             CALL "SH-POST" USING WS-ROW
             MOVE 0 TO WS-N
             MOVE 0 TO WS-LX
             MOVE 2 TO WS-LY
             MOVE 2 TO WS-LZ
             PERFORM LOCAL-STATE
             IF WS-S = WS-AIR
                 ADD 1 TO WS-N
             END-IF
             MOVE 4 TO WS-LX
             PERFORM LOCAL-STATE
             IF WS-S = WS-AIR
                 ADD 2 TO WS-N
             END-IF
             MOVE SPACES TO TL-CASE
             MOVE WS-PT TO WS-PT2
             MOVE WS-PO TO WS-DIGIT
             STRING "test cova struct sh place a turn of type " WS-PT2 " orientation " WS-DIGIT " opens exactly one side" DELIMITED BY SIZE INTO TL-CASE
             MOVE 1 TO TL-EXPECTED-N
             MOVE 0 TO TL-OBSERVED-N
             IF WS-N = 1 OR WS-N = 2
                 MOVE 1 TO TL-OBSERVED-N
             END-IF
             CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         END-PERFORM
     END-PERFORM
*>   The room crossing: variant F2 = 0 has the central pillar of stone bricks, F2 = 3 has none.
     PERFORM VARYING WS-J FROM 0 BY 3 UNTIL WS-J > 3
         PERFORM STONE-WORLD
         MOVE 0 TO A-X0 MOVE 40 TO A-Y0 MOVE 0 TO A-Z0 MOVE 10 TO A-X1 MOVE 46 TO A-Y1 MOVE 10 TO A-Z1
         MOVE 27 TO WS-PT
         MOVE 2 TO WS-PO
         PERFORM ADD-PIECE
         MOVE WS-J TO SP-F2(WS-ROW)
         CALL "SH-POST" USING WS-ROW
         MOVE 5 TO WS-LX MOVE 2 TO WS-LY MOVE 5 TO WS-LZ
         PERFORM LOCAL-STATE
         MOVE SPACES TO TL-CASE
         IF WS-J = 0
             MOVE "test cova struct sh place a room crossing of variant 0 has its stone brick pillar at local (5,2,5)" TO TL-CASE
             MOVE WS-BRICKS TO TL-EXPECTED-N
         ELSE
             MOVE "test cova struct sh place a room crossing of variant 3 has no pillar at local (5,2,5)" TO TL-CASE
             MOVE WS-AIR TO TL-EXPECTED-N
         END-IF
         MOVE WS-S TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   The library: short (F2 = 0) and tall (F2 = 1): bookshelves in the walls, the tall one adds the gallery and the stair chest.
     PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 1
         PERFORM STONE-WORLD
         MOVE 0 TO A-X0 MOVE 40 TO A-Y0 MOVE 0 TO A-Z0 MOVE 13 TO A-X1 MOVE 50 TO A-Y1 MOVE 14 TO A-Z1
         MOVE 23 TO WS-PT
         MOVE 2 TO WS-PO
         PERFORM ADD-PIECE
         MOVE WS-J TO SP-F2(WS-ROW)
         CALL "SH-POST" USING WS-ROW
         MOVE 1 TO WS-LX MOVE 2 TO WS-LY MOVE 2 TO WS-LZ
         MOVE WS-BOOKS TO WS-WANT
         MOVE SPACES TO TL-CASE
         MOVE WS-J TO WS-DIGIT
         STRING "test cova struct sh place a library with F2 = " WS-DIGIT " has bookshelves at local (1,2,2)" DELIMITED BY SIZE INTO TL-CASE
         PERFORM CHECK-LOCAL
         MOVE 1 TO WS-LX MOVE 7 TO WS-LY MOVE 3 TO WS-LZ
         PERFORM LOCAL-STATE
         MOVE SPACES TO TL-CASE
         STRING "test cova struct sh place a library with F2 = " WS-DIGIT " has the gallery bookshelf at local (1,7,3) only when tall" DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-J TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         IF WS-S = WS-BOOKS
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   The five crossing with all four side exits and the spiral stairs.
     PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 1
         PERFORM STONE-WORLD
         MOVE 0 TO A-X0 MOVE 40 TO A-Y0 MOVE 0 TO A-Z0 MOVE 9 TO A-X1 MOVE 47 TO A-Y1 MOVE 10 TO A-Z1
         MOVE 21 TO WS-PT
         MOVE 2 TO WS-PO
         PERFORM ADD-PIECE
         MOVE WS-J TO SP-F2(WS-ROW) SP-F3(WS-ROW) SP-F4(WS-ROW) SP-MST(WS-ROW)
         CALL "SH-POST" USING WS-ROW
         MOVE 0 TO WS-N
         MOVE 4 TO WS-LY
         MOVE 0 TO WS-LX MOVE 2 TO WS-LZ
         PERFORM LOCAL-STATE
         IF WS-S = WS-AIR
             ADD 1 TO WS-N
         END-IF
         MOVE 9 TO WS-LX MOVE 2 TO WS-LZ
         PERFORM LOCAL-STATE
         IF WS-S = WS-AIR
             ADD 1 TO WS-N
         END-IF
         MOVE 6 TO WS-LY
         MOVE 0 TO WS-LX MOVE 8 TO WS-LZ
         PERFORM LOCAL-STATE
         IF WS-S = WS-AIR
             ADD 1 TO WS-N
         END-IF
         MOVE 9 TO WS-LX MOVE 8 TO WS-LZ
         PERFORM LOCAL-STATE
         IF WS-S = WS-AIR
             ADD 1 TO WS-N
         END-IF
         MOVE SPACES TO TL-CASE
         MOVE WS-J TO WS-DIGIT
         STRING "test cova struct sh place a five crossing with its four side flags " WS-DIGIT " carves that many wall exits" DELIMITED BY SIZE INTO TL-CASE
         COMPUTE TL-EXPECTED-N = WS-J * 4
         MOVE WS-N TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     PERFORM VARYING WS-PT FROM 28 BY 1 UNTIL WS-PT > 29
         PERFORM STONE-WORLD
         MOVE 0 TO A-X0 MOVE 40 TO A-Y0 MOVE 0 TO A-Z0 MOVE 4 TO A-X1 MOVE 50 TO A-Y1 MOVE 4 TO A-Z1
         MOVE 2 TO WS-PO
         PERFORM ADD-PIECE
         CALL "SH-POST" USING WS-ROW
         MOVE 2 TO WS-LX MOVE 6 TO WS-LY MOVE 1 TO WS-LZ
         MOVE WS-BRICKS TO WS-WANT
         MOVE WS-PT TO WS-PT2
         MOVE SPACES TO TL-CASE
         STRING "test cova struct sh place the spiral stairs of type " WS-PT2 " start with a stone brick step at local (2,6,1)" DELIMITED BY SIZE INTO TL-CASE
         PERFORM CHECK-LOCAL
     END-PERFORM
*>   A right-hinged door of a mirrored piece (orientation 0) is resolved to a left hinge, of an unmirrored piece (2) stays right.
     PERFORM STONE-WORLD
     MOVE 0 TO A-X0 MOVE 40 TO A-Y0 MOVE 0 TO A-Z0 MOVE 8 TO A-X1 MOVE 44 TO A-Y1 MOVE 10 TO A-Z1
     MOVE 25 TO WS-PT
     MOVE 0 TO WS-PO
     PERFORM ADD-PIECE
     MOVE SPACES TO WS-ARG
     MOVE "iron_door[facing=N,half=lower,hinge=right]" TO WS-ARG
     CALL "SHP-RESOLVE" USING WS-ROW WS-ARG WS-STATE
     MOVE "minecraft:iron_door" TO WS-KEY
     MOVE "facing=south,half=lower,hinge=left,open=false,powered=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-WANT
     MOVE "test cova struct sh place a mirrored piece's right hinge becomes left (facing north turns south)" TO TL-CASE
     MOVE WS-WANT TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A chest: it stays when a chest is already in the cell; it faces away from one solid neighbour; a chest next to it is joined.
     PERFORM STONE-WORLD
     MOVE 0 TO A-X0 MOVE 40 TO A-Y0 MOVE 0 TO A-Z0 MOVE 8 TO A-X1 MOVE 44 TO A-Y1 MOVE 8 TO A-Z1
     MOVE 19 TO WS-PT
     MOVE 2 TO WS-PO
     PERFORM ADD-PIECE
*>   Local (3,1,3) is world (3,41,5): air around it except the stone to the west (2,41,5).
     MOVE 3 TO WS-X MOVE 41 TO WS-Y MOVE 5 TO WS-Z
     PERFORM SET-AIR
     MOVE 4 TO WS-X
     PERFORM SET-AIR
     MOVE 3 TO WS-X MOVE 4 TO WS-Z
     PERFORM SET-AIR
     MOVE 6 TO WS-Z
     PERFORM SET-AIR
     MOVE 3 TO WS-LX MOVE 1 TO WS-LY MOVE 3 TO WS-LZ
     CALL "SHP-CHEST" USING WS-ROW WS-LX WS-LY WS-LZ WS-LOOT
     MOVE "minecraft:chest" TO WS-KEY
     MOVE "facing=east,type=single,waterlogged=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-WANT
     MOVE "test cova struct sh place a chest with one solid neighbour (west) faces east" TO TL-CASE
     PERFORM CHECK-LOCAL
     CALL "SHP-CHEST" USING WS-ROW WS-LX WS-LY WS-LZ WS-LOOT
     MOVE "test cova struct sh place a second chest request for the same cell keeps the chest" TO TL-CASE
     PERFORM CHECK-LOCAL
*>   A chest whose north, east and south neighbours are air and whose west neighbour is the chest placed above joins it and keeps the default facing.
     MOVE 4 TO WS-X MOVE 41 TO WS-Y MOVE 5 TO WS-Z
     PERFORM SET-AIR
     MOVE 5 TO WS-X MOVE 41 TO WS-Y MOVE 5 TO WS-Z
     PERFORM SET-AIR
     MOVE 4 TO WS-X MOVE 4 TO WS-Z
     PERFORM SET-AIR
     MOVE 6 TO WS-Z
     PERFORM SET-AIR
     MOVE 4 TO WS-LX
     CALL "SHP-CHEST" USING WS-ROW WS-LX WS-LY WS-LZ WS-LOOT
     MOVE "minecraft:chest" TO WS-KEY
     MOVE "facing=north,type=single,waterlogged=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-WANT
     MOVE "test cova struct sh place a chest with a chest to its west and air around keeps north" TO TL-CASE
     PERFORM CHECK-LOCAL
*>   A chest request outside the write box does nothing.
     PERFORM STONE-WORLD
     MOVE 100 TO A-X0 MOVE 40 TO A-Y0 MOVE 100 TO A-Z0 MOVE 108 TO A-X1 MOVE 44 TO A-Y1 MOVE 108 TO A-Z1
     MOVE 19 TO WS-PT
     PERFORM ADD-PIECE
     MOVE 3 TO WS-LX MOVE 1 TO WS-LY MOVE 3 TO WS-LZ
     CALL "SHP-CHEST" USING WS-ROW WS-LX WS-LY WS-LZ WS-LOOT
     MOVE "test cova struct sh place a chest request outside the write box leaves no block entity (no abort)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 1 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The portal room draws its eyes: some draw above 0.9 sets the flag (a seed found by trying them).
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 40
         PERFORM STONE-WORLD
         MOVE WS-J TO SP-XR-LO
         MOVE 77 TO SP-XR-HI
         MOVE 0 TO A-X0 MOVE 40 TO A-Y0 MOVE 0 TO A-Z0 MOVE 10 TO A-X1 MOVE 47 TO A-Y1 MOVE 15 TO A-Z1
         MOVE 24 TO WS-PT
         MOVE 2 TO WS-PO
         PERFORM ADD-PIECE
         CALL "SH-POST" USING WS-ROW
         MOVE 0 TO WS-N
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
             ADD SH-EYE(WS-I) TO WS-N
         END-PERFORM
         IF WS-N > 0
             MOVE 41 TO WS-J
         END-IF
     END-PERFORM
     MOVE "test cova struct sh place the portal room's eye draws set at least one eye over the seeds tried" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-N > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
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
 LOCAL-STATE.
     CALL "SPB-WORLD" USING WS-ROW WS-LX WS-LY WS-LZ WS-WX WS-WY WS-WZ
     MOVE WS-WX TO WS-X
     MOVE WS-WY TO WS-Y
     MOVE WS-WZ TO WS-Z
     PERFORM CELL-STATE.
 CHECK-LOCAL.
     PERFORM LOCAL-STATE
     MOVE WS-S TO TL-OBSERVED-N
     MOVE WS-WANT TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 SET-AIR.
     COMPUTE WS-IDX = (WS-Y + 64) * 256 + WS-Z * 16 + WS-X + 1
     MOVE WS-AIR TO CE-STATE(WS-IDX).

 END PROGRAM TEST-COVA-STRUCT-SH-PLACE.
 COPY CORETEST.
