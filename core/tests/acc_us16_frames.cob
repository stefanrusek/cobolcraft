*> Acceptance test, item frames and paintings (docs/protocol/44 part 9 sections 5.1 to 5.4; lane 002-lane-mobsb6, T9010): frame placement (side faces only, a solid block behind, one frame per cell and
*> direction), putting an item in, rotating (mod 8), the comparator output (rotation + 1), hitting (item first, then the frame, creative drops nothing, a fixed frame is immune), and the painting variant
*> choice (candidates that fit, the largest area, a random pick among equals, its box centre).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US16-FRAMES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 96.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-STICK               BINARY-LONG.
 01 WS-FRAME-ITEM          BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROW2                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-FACE-N              BINARY-LONG VALUE 2.
 01 WS-FACE-UP             BINARY-LONG VALUE 1.
 01 WS-GLOW                BINARY-LONG VALUE 0.
 01 WS-DONE                BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 01 WS-N0                  BINARY-LONG.
 01 WS-N1                  BINARY-LONG.
 01 WS-SIGNAL              BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-YES                 BINARY-LONG VALUE 1.
 01 WS-COUNT               BINARY-LONG.
 01 WS-CAND-W.
    05 WS-W                BINARY-LONG OCCURS 8 TIMES.
 01 WS-CAND-H.
    05 WS-H                BINARY-LONG OCCURS 8 TIMES.
 01 WS-AREA                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Y0 = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) + 30
     COMPUTE WS-FX = WS-X0 - 48
     COMPUTE WS-FZ = WS-Z0 - 48
     COMPUTE WS-GY = WS-Y0 - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-GY WS-FKIND
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE "minecraft:stick" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-STICK WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:item_frame" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-FRAME-ITEM WS-ITEM-ROW WS-STATUS
*>   A wall of stone at z0, x0 - 3 to x0 + 6, y0 to y0 + 3.
     PERFORM VARYING WS-I FROM -3 BY 1 UNTIL WS-I > 6
         PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 3
             COMPUTE WS-CX = WS-X0 + WS-I
             COMPUTE WS-CY = WS-Y0 + WS-J
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-Z0 WS-STONE
         END-PERFORM
     END-PERFORM
     COMPUTE WS-HELD = PL-HELD(WS-PLAYER) + 1
*>   Placement on the north face of the wall block (x0, y0 + 1, z0): the frame is in the cell z0 - 1.
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD)
     MOVE WS-FRAME-ITEM TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD)
     COMPUTE WS-CY = WS-Y0 + 1
     CALL "ITEM-FRAME-PLACE" USING WS-PLAYER WS-X0 WS-CY WS-Z0 WS-FACE-N WS-GLOW WS-ROW
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
     MOVE "acceptance US16 44-9 5.3 a frame on the north face of a wall is made (kind 12, facing north 2)" TO TL-CASE
     MOVE 1202 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ROW > 0
         COMPUTE TL-OBSERVED-N = PJ-KIND(WS-SLOT) * 100 + PJ-I1(WS-SLOT)
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 44-9 5.3 it sits 0.46875 off the cell centre toward the wall (z, thousandths of the offset from the cell)" TO TL-CASE
     MOVE 969 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = (EN-Z(WS-ROW) - (WS-Z0 - 1)) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 44-9 5.3 placing it used up the held frame item (survival)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-HELD) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A second frame in the same cell and direction, one on a vertical face, one without a wall.
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD)
     CALL "ITEM-FRAME-PLACE" USING WS-PLAYER WS-X0 WS-CY WS-Z0 WS-FACE-N WS-GLOW WS-ROW2
     MOVE "acceptance US16 44-9 5.3 a second frame in the same cell and direction is refused" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ROW2 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ITEM-FRAME-PLACE" USING WS-PLAYER WS-X0 WS-CY WS-Z0 WS-FACE-UP WS-GLOW WS-ROW2
     MOVE "acceptance US16 44-9 5.3 the item places no frame on a vertical face" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ROW2 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-CX = WS-X0 + 8
     CALL "ITEM-FRAME-PLACE" USING WS-PLAYER WS-CX WS-CY WS-Z0 WS-FACE-N WS-GLOW WS-ROW2
     MOVE "acceptance US16 44-9 5.3 a frame with no solid block behind it is refused" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ROW2 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ITEM-FRAME-PLACE" USING WS-PLAYER WS-X0 WS-CY WS-Z0 WS-FACE-N WS-YES WS-ROW2
     MOVE "acceptance US16 44-9 5.3 the same cell stays taken for a glow frame" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ROW2 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Interaction: an item goes in, a click rotates, the comparator reads rotation + 1.
     MOVE WS-STICK TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD)
     MOVE 2 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD)
     CALL "ITEM-FRAME-INTERACT" USING WS-ROW WS-PLAYER WS-DONE
     MOVE "acceptance US16 44-9 5.3 a stick goes into the empty frame and the stack loses one" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PJ-I2(WS-SLOT) = WS-STICK AND PL-SLOT-COUNT(WS-PLAYER, WS-HELD) = 1 AND WS-DONE = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ITEM-FRAME-SIGNAL" USING WS-ROW WS-SIGNAL
     MOVE "acceptance US16 44-9 5.3 the comparator reads 1 for rotation 0 with an item" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-SIGNAL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ITEM-FRAME-INTERACT" USING WS-ROW WS-PLAYER WS-DONE
     MOVE "acceptance US16 44-9 5.3 a click on a filled frame rotates it by one" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PJ-I3(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
         CALL "ITEM-FRAME-INTERACT" USING WS-ROW WS-PLAYER WS-DONE
     END-PERFORM
     MOVE "acceptance US16 44-9 5.3 eight rotations bring it back to 0 (mod 8)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PJ-I3(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO PJ-I3(WS-SLOT)
     CALL "ITEM-FRAME-SIGNAL" USING WS-ROW WS-SIGNAL
     MOVE "acceptance US16 44-9 5.3 rotation 3 reads 4" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-SIGNAL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Hits: the item pops first, then the frame breaks and drops itself.
     MOVE 0 TO WS-N0
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-ITEM-COUNT(WS-I) > 0
             ADD 1 TO WS-N0
         END-IF
     END-PERFORM
     CALL "ITEM-FRAME-HURT" USING WS-ROW WS-PLAYER WS-NO WS-DONE
     MOVE "acceptance US16 44-9 5.3 the first hit drops the item and empties the frame (it stays)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PJ-I2(WS-SLOT) = 0 AND EN-USED(WS-ROW) = 1 AND WS-DONE = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ITEM-FRAME-HURT" USING WS-ROW WS-PLAYER WS-NO WS-DONE
     MOVE 0 TO WS-N1
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-ITEM-COUNT(WS-I) > 0
             ADD 1 TO WS-N1
         END-IF
     END-PERFORM
     MOVE "acceptance US16 44-9 5.3 the second hit breaks the frame and drops the frame item (2 items in all)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-N1 - WS-N0
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 44-9 5.3 the frame row is gone" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A creative hit breaks with no drops; a fixed frame is immune to a survival hit.
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD)
     MOVE WS-FRAME-ITEM TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD)
     CALL "ITEM-FRAME-PLACE" USING WS-PLAYER WS-X0 WS-CY WS-Z0 WS-FACE-N WS-GLOW WS-ROW
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
     MOVE 1 TO PJ-I5(WS-SLOT)
     CALL "ITEM-FRAME-HURT" USING WS-ROW WS-PLAYER WS-NO WS-DONE
     MOVE "acceptance US16 44-9 5.3 a fixed frame is not hurt by a survival player" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ITEM-FRAME-INTERACT" USING WS-ROW WS-PLAYER WS-DONE
     MOVE "acceptance US16 44-9 5.3 a fixed frame passes on interaction" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-DONE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PJ-I5(WS-SLOT)
     MOVE 0 TO WS-N0
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-ITEM-COUNT(WS-I) > 0
             ADD 1 TO WS-N0
         END-IF
     END-PERFORM
     MOVE 1 TO PL-MODE(WS-PLAYER)
     CALL "ITEM-FRAME-HURT" USING WS-ROW WS-PLAYER WS-NO WS-DONE
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 0 TO WS-N1
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-ITEM-COUNT(WS-I) > 0
             ADD 1 TO WS-N1
         END-IF
     END-PERFORM
     MOVE "acceptance US16 44-9 5.3 a creative hit breaks the frame with no drops" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-N1 - WS-N0 + EN-USED(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Explosions leave the item in a frame and break the frame.
     CALL "ITEM-FRAME-PLACE" USING WS-PLAYER WS-X0 WS-CY WS-Z0 WS-FACE-N WS-GLOW WS-ROW
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
     MOVE WS-STICK TO PJ-I2(WS-SLOT)
     MOVE 0 TO WS-I
     CALL "ITEM-FRAME-HURT" USING WS-ROW WS-NO WS-YES WS-DONE
     MOVE "acceptance US16 44-9 5.3 an explosion breaks the frame even when it holds an item" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Paintings: the candidates (1,1) (2,1) (1,2): the largest area is 2 and the pick is one of the two.
     MOVE 1 TO WS-W(1)
     MOVE 1 TO WS-H(1)
     MOVE 2 TO WS-W(2)
     MOVE 1 TO WS-H(2)
     MOVE 1 TO WS-W(3)
     MOVE 2 TO WS-H(3)
     MOVE 3 TO WS-COUNT
     COMPUTE WS-CX = WS-X0 + 2
     COMPUTE WS-CY = WS-Y0 + 1
     CALL "PAINTING-PLACE" USING WS-DIM WS-CX WS-CY WS-Z0 WS-FACE-N WS-COUNT WS-CAND-W WS-CAND-H WS-ROW
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
     MOVE "acceptance US16 44-9 5.4 the painting is kind 13 with area 2" TO TL-CASE
     MOVE 1302 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ROW > 0
         COMPUTE TL-OBSERVED-N = PJ-KIND(WS-SLOT) * 100 + PJ-I2(WS-SLOT) * PJ-I3(WS-SLOT)
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A 2 wide painting on a north face is centred half a block toward the counter-clockwise side (west): x = block x.
     MOVE 1 TO WS-COUNT
     MOVE 2 TO WS-W(1)
     MOVE 1 TO WS-H(1)
     COMPUTE WS-CX = WS-X0 - 2
     CALL "PAINTING-PLACE" USING WS-DIM WS-CX WS-CY WS-Z0 WS-FACE-N WS-COUNT WS-CAND-W WS-CAND-H WS-ROW2
     MOVE "acceptance US16 44-9 5.4 a 2 x 1 painting's centre is at the block x, y + 0.5 (millimetres of x - block)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = (EN-X(WS-ROW2) - WS-CX) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Nothing fits: a 3 x 3 painting on a 1 high wall segment, and no wall at all.
     MOVE 3 TO WS-W(1)
     MOVE 3 TO WS-H(1)
     COMPUTE WS-CX = WS-X0 + 5
     COMPUTE WS-CY = WS-Y0 + 3
     CALL "PAINTING-PLACE" USING WS-DIM WS-CX WS-CY WS-Z0 WS-FACE-N WS-COUNT WS-CAND-W WS-CAND-H WS-ROW2
     MOVE "acceptance US16 44-9 5.4 a 3 x 3 painting near the top and the edge of the wall does not fit (row 0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ROW2 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-COUNT
     CALL "PAINTING-PLACE" USING WS-DIM WS-CX WS-CY WS-Z0 WS-FACE-N WS-COUNT WS-CAND-W WS-CAND-H WS-ROW2
     MOVE "acceptance US16 44-9 5.4 with no candidates there is no painting" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ROW2 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Hitting a painting breaks it and drops the painting item unless the attacker is creative.
     MOVE 0 TO WS-N0
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-ITEM-COUNT(WS-I) > 0
             ADD 1 TO WS-N0
         END-IF
     END-PERFORM
     CALL "PAINTING-HURT" USING WS-ROW WS-PLAYER WS-DONE
     MOVE 0 TO WS-N1
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-ITEM-COUNT(WS-I) > 0
             ADD 1 TO WS-N1
         END-IF
     END-PERFORM
     MOVE "acceptance US16 44-9 5.4 a hit removes the painting and drops one painting item" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-N1 - WS-N0 + EN-USED(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US16-FRAMES.
 COPY CORETEST.
 COPY MOBSPTEST.
