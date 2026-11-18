*> Test of the data layout of the woodland mansion grids (docs/protocol/36-structures-7-woodland-mansion.md section 4; core/src/struct-mansion.cob, core/copy/STRUCTMAN.cpy): the cell values and
*> isHouse (4.1), the 11 by 11 SimpleGrid with the outside value 5 (get outside reads 5, set outside is ignored, the cell (x, y) at index y * 11 + x + 1), set(x0, y0, x1, y1, v) as an inclusive
*> rectangle clipped to the grid, setif, edgesTo with the four orthogonal neighbours (the outside counts as 5), the grids all start at 0 (4.1), and the room code masks (4.2).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-7-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTPIECE.
 COPY STRUCTMAN.
 01 WS-G                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 1.
 01 WS-ID                  BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ORIGIN              BINARY-LONG.
 01 WS-DOOR                BINARY-LONG.
 01 WS-STAIRS              BINARY-LONG.
 01 WS-CORR                BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-CASE                PIC X(200).
 01 WS-ED                  PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
*>   the grids start at 0 (a fresh constructor run leaves the rooms of floor 0 empty outside the rooms)
     CALL "JRAND-SET-SEED" USING SP-RNG WS-SEED
     CALL "MNG-BUILD"
     MOVE 0 TO WS-V
     MOVE 0 TO WS-X
     MOVE 0 TO WS-Y
     MOVE 3 TO WS-G
     CALL "MNG-GET" USING WS-G WS-X WS-Y WS-V
     MOVE "acceptance US12 36-7§4.1 a cell no room covers holds 0 (CLEAR / no room code)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   cell values: isHouse is true for 1 to 4 only; 0, 5 and the outside are not house
     MOVE 1 TO WS-G
     MOVE 5 TO WS-X
     MOVE 5 TO WS-Y
     MOVE 0 TO WS-N
     PERFORM VARYING WS-V FROM 0 BY 1 UNTIL WS-V > 5
         CALL "MNG-SET" USING WS-G WS-X WS-Y WS-V
         CALL "MNG-HOUSE" USING WS-G WS-X WS-Y WS-FLAG
         COMPUTE WS-N = WS-N * 2 + WS-FLAG
     END-PERFORM
     MOVE "acceptance US12 36-7§4.1 isHouse of the values 0 to 5 is 0 1 1 1 1 0 (binary 011110)" TO TL-CASE
     MOVE 30 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -1 TO WS-X
     CALL "MNG-HOUSE" USING WS-G WS-X WS-Y WS-FLAG
     MOVE "acceptance US12 36-7§4.1 a cell outside the grid is not house" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   outside reads 5 on every grid, at the four sides and the corners
     MOVE 0 TO WS-N
     PERFORM VARYING WS-G FROM 1 BY 1 UNTIL WS-G > 5
         MOVE -1 TO WS-X
         MOVE 4 TO WS-Y
         CALL "MNG-GET" USING WS-G WS-X WS-Y WS-V
         ADD WS-V TO WS-N
         MOVE 11 TO WS-X
         CALL "MNG-GET" USING WS-G WS-X WS-Y WS-V
         ADD WS-V TO WS-N
         MOVE 4 TO WS-X
         MOVE -1 TO WS-Y
         CALL "MNG-GET" USING WS-G WS-X WS-Y WS-V
         ADD WS-V TO WS-N
         MOVE 11 TO WS-Y
         CALL "MNG-GET" USING WS-G WS-X WS-Y WS-V
         ADD WS-V TO WS-N
         MOVE 11 TO WS-X
         CALL "MNG-GET" USING WS-G WS-X WS-Y WS-V
         ADD WS-V TO WS-N
     END-PERFORM
     MOVE "acceptance US12 36-7§4.1 get outside 0 to 10 returns the outside value 5, on all five grids (25 reads)" TO TL-CASE
     MOVE 125 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   set outside is ignored; set inside lands at index y * 11 + x + 1
     MOVE 1 TO WS-G
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 121
         MOVE 0 TO MN-CELL(1, WS-I)
     END-PERFORM
     MOVE 7 TO WS-V
     MOVE 11 TO WS-X
     MOVE 5 TO WS-Y
     CALL "MNG-SET" USING WS-G WS-X WS-Y WS-V
     MOVE -1 TO WS-X
     CALL "MNG-SET" USING WS-G WS-X WS-Y WS-V
     MOVE 5 TO WS-X
     MOVE 11 TO WS-Y
     CALL "MNG-SET" USING WS-G WS-X WS-Y WS-V
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 121
         ADD MN-CELL(1, WS-I) TO WS-N
     END-PERFORM
     MOVE "acceptance US12 36-7§4.1 set outside the grid is ignored: no cell changed" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-Y
     MOVE 7 TO WS-X
     MOVE 3 TO WS-V
     CALL "MNG-SET" USING WS-G WS-X WS-Y WS-V
     MOVE "acceptance US12 36-7§4.1 the cell (7, 4) is element 4 * 11 + 7 + 1 = 52 of the grid" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE MN-CELL(1, 52) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   set(x0, y0, x1, y1, v): the inclusive rectangle, clipped (the extent 11 of the entrance shapes reaches outside)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 121
         MOVE 0 TO MN-CELL(1, WS-I)
     END-PERFORM
     MOVE 2 TO WS-X
     MOVE 2 TO WS-Y
     MOVE 4 TO WS-A
     MOVE 3 TO WS-B
     MOVE 7 TO WS-V
     CALL "MNG-FILL" USING WS-G WS-X WS-Y WS-A WS-B WS-V
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 121
         IF MN-CELL(1, WS-I) = 7
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-7§4.1 set(2, 2, 4, 3, 7) fills the inclusive rectangle: 3 by 2 cells" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-X
     MOVE 3 TO WS-Y
     CALL "MNG-GET" USING WS-G WS-X WS-Y WS-V
     MOVE WS-V TO WS-A
     MOVE 5 TO WS-X
     CALL "MNG-GET" USING WS-G WS-X WS-Y WS-V
     MOVE "acceptance US12 36-7§4.1 the far corner (4, 3) of the rectangle is set and (5, 3) is not" TO TL-CASE
     MOVE 70 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-A * 10 + WS-V
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-X
     MOVE 9 TO WS-Y
     MOVE 11 TO WS-A
     MOVE 11 TO WS-B
     MOVE 5 TO WS-V
     CALL "MNG-FILL" USING WS-G WS-X WS-Y WS-A WS-B WS-V
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 121
         IF MN-CELL(1, WS-I) = 5
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-7§4.1 set(0, 9, 11, 11, 5) fills rows 9 and 10 (22 cells) and ignores what lies outside" TO TL-CASE
     MOVE 22 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   setif(x, y, a, b) sets b only when the cell holds a
     MOVE 6 TO WS-X
     MOVE 6 TO WS-Y
     MOVE 0 TO WS-A
     MOVE 2 TO WS-B
     CALL "MNG-SETIF" USING WS-G WS-X WS-Y WS-A WS-B
     MOVE 8 TO WS-A
     MOVE 3 TO WS-B
     CALL "MNG-SETIF" USING WS-G WS-X WS-Y WS-A WS-B
     CALL "MNG-GET" USING WS-G WS-X WS-Y WS-V
     MOVE "acceptance US12 36-7§4.1 setif changes a cell that holds a (0 to 2) and leaves one that does not (8 to 3)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   edgesTo: the four orthogonal neighbours only
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 121
         MOVE 0 TO MN-CELL(1, WS-I)
     END-PERFORM
     MOVE 1 TO WS-V
     MOVE 6 TO WS-X
     MOVE 5 TO WS-Y
     CALL "MNG-SET" USING WS-G WS-X WS-Y WS-V
     MOVE 4 TO WS-A
     MOVE 4 TO WS-B
     CALL "MNG-EDGES-TO" USING WS-G WS-A WS-B WS-V WS-FLAG
     MOVE WS-FLAG TO WS-N
     MOVE 5 TO WS-A
     MOVE 5 TO WS-B
     CALL "MNG-EDGES-TO" USING WS-G WS-A WS-B WS-V WS-FLAG
     COMPUTE WS-N = WS-N * 10 + WS-FLAG
     MOVE 7 TO WS-A
     CALL "MNG-EDGES-TO" USING WS-G WS-A WS-B WS-V WS-FLAG
     COMPUTE WS-N = WS-N * 10 + WS-FLAG
     MOVE 6 TO WS-A
     MOVE 4 TO WS-B
     CALL "MNG-EDGES-TO" USING WS-G WS-A WS-B WS-V WS-FLAG
     COMPUTE WS-N = WS-N * 10 + WS-FLAG
     MOVE 6 TO WS-B
     CALL "MNG-EDGES-TO" USING WS-G WS-A WS-B WS-V WS-FLAG
     COMPUTE WS-N = WS-N * 10 + WS-FLAG
     MOVE "acceptance US12 36-7§4.1 edgesTo(x, y, 1) next to a corridor at (6, 5): diagonal no, west yes, east yes, north yes, south yes" TO TL-CASE
     MOVE 1111 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 5 TO WS-B
     MOVE 5 TO WS-V
     CALL "MNG-EDGES-TO" USING WS-G WS-A WS-B WS-V WS-FLAG
     MOVE "acceptance US12 36-7§4.1 edgesTo counts the outside value 5: the cell (0, 5) edges to 5" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   4.2 the room code fields
     COMPUTE WS-CODE = 1048576 + 2097152 + 131072 + 4660
     CALL "MNG-BITS" USING WS-CODE WS-ID WS-TYPE WS-ORIGIN WS-DOOR WS-STAIRS WS-CORR
     MOVE "acceptance US12 36-7§4.2 code 0x321234 is id 0x1234, 1x2 (2), origin, door, no stairs, no corridor flag" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 4660 * 1000000 + 2 * 100000 + 10000 + 1000
     COMPUTE TL-OBSERVED-N = WS-ID * 1000000 + WS-TYPE * 100000 + WS-ORIGIN * 10000 + WS-DOOR * 1000 + WS-STAIRS * 100 + WS-CORR * 10
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-CODE = 4194304 + 262144 + 65535
     CALL "MNG-BITS" USING WS-CODE WS-ID WS-TYPE WS-ORIGIN WS-DOOR WS-STAIRS WS-CORR
     MOVE "acceptance US12 36-7§4.2 code 0x44FFFF is id 65535 (the id mask), 2x2 (4), the stairs flag only" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 65535 * 1000000 + 4 * 100000 + 100
     COMPUTE TL-OBSERVED-N = WS-ID * 1000000 + WS-TYPE * 100000 + WS-ORIGIN * 10000 + WS-DOOR * 1000 + WS-STAIRS * 100 + WS-CORR * 10
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 8388608 TO WS-CODE
     CALL "MNG-BITS" USING WS-CODE WS-ID WS-TYPE WS-ORIGIN WS-DOOR WS-STAIRS WS-CORR
     MOVE "acceptance US12 36-7§4.2 code 0x800000 (the corridor flag) has no id and no room type" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-ID * 1000000 + WS-TYPE * 100000 + WS-ORIGIN * 10000 + WS-DOOR * 1000 + WS-STAIRS * 100 + WS-CORR * 10
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-CODE = 65536 + 10
     CALL "MNG-BITS" USING WS-CODE WS-ID WS-TYPE WS-ORIGIN WS-DOOR WS-STAIRS WS-CORR
     MOVE "acceptance US12 36-7§4.2 code 0x1000A is room id 10, 1x1 (1), no flags" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 10 * 1000000 + 100000
     COMPUTE TL-OBSERVED-N = WS-ID * 1000000 + WS-TYPE * 100000 + WS-ORIGIN * 10000 + WS-DOOR * 1000 + WS-STAIRS * 100 + WS-CORR * 10
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a built mansion: room ids start at 10 on every floor, the types are 1x1, 1x2 or 2x2 only
     CALL "MNG-BUILD"
     MOVE 0 TO WS-N
     PERFORM VARYING WS-G FROM 3 BY 1 UNTIL WS-G > 5
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 121
             MOVE MN-CELL(WS-G, WS-I) TO WS-CODE
             IF WS-CODE NOT = 0 AND WS-CODE NOT = 8388608
                 CALL "MNG-BITS" USING WS-CODE WS-ID WS-TYPE WS-ORIGIN WS-DOOR WS-STAIRS WS-CORR
                 IF WS-ID < 10 OR (WS-TYPE NOT = 1 AND WS-TYPE NOT = 2 AND WS-TYPE NOT = 4)
                     ADD 1 TO WS-N
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-7§4.2 every room code of a built mansion has id 10 or more and a type of 1, 2 or 4" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-STRUCT-36-7-4.
