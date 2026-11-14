*> Implementation test (T1751; docs/protocol/39-portals.md section 4 and 1.3): nether portal travel. The destination dimension (the overworld from
*> the nether, otherwise the nether, so the end leads to the nether), the scale 1/8 and 8, the origin with the destination border clamp
*> (E3, V12), the largest rectangle of identical portal blocks (4.3, E9 and the tie rule of its worked example), the relative position of
*> an entity in the entry rectangle and the exit position (4.4, E4). Needs the generated packs (a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PORTAL-39-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY PORTALRECT.
 01 WS-SKIP                BINARY-LONG.
 01 WS-SRC                 BINARY-LONG.
 01 WS-DEST                BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-EW                  FLOAT-LONG VALUE 0.6.
 01 WS-EH                  FLOAT-LONG VALUE 1.8.
 01 WS-RX                  FLOAT-LONG.
 01 WS-RY                  FLOAT-LONG.
 01 WS-RZ                  FLOAT-LONG.
 01 WS-SCALE               FLOAT-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-FIRST               PIC X(40).
 01 WS-STATE-X             BINARY-LONG.
 01 WS-KEY-PORTAL          PIC X(48) VALUE "nether_portal".
 01 WS-PAIRS-X             PIC X(160) VALUE "axis=x".
 01 WS-A                   PIC -(9)9.
 01 WS-B                   PIC -(9)9.
 01 WS-C                   PIC -(9)9.
 01 WS-D                   PIC -(9)9.
 01 WS-E                   PIC -(9)9.
 01 WS-F                   PIC -(5)9.999.
 01 WS-G                   PIC -(5)9.999.
 01 WS-H                   PIC -(5)9.999.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance US12 39§4 Nether portal travel: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "PT-STATE" USING WS-KEY-PORTAL WS-PAIRS-X WS-STATE-X

     MOVE "acceptance US12 39§4 Nether portal travel: 4.1 the destination is the nether from the overworld and the end, "
         & "the overworld from the nether" TO TL-CASE
     CALL "PORTAL-DESTINATION" USING DIM-STANDARD-OVERWORLD WS-DEST
     MOVE WS-DEST TO WS-A
     CALL "PORTAL-DESTINATION" USING DIM-STANDARD-NETHER WS-DEST
     MOVE WS-DEST TO WS-B
     CALL "PORTAL-DESTINATION" USING DIM-STANDARD-END WS-DEST
     MOVE WS-DEST TO WS-C
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "4 3 4" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 39§4 Nether portal travel: 4.1 the scale is 0.125 into the nether, 8 out of it and 0.125 from the end" TO TL-CASE
     CALL "PORTAL-SCALE" USING DIM-STANDARD-OVERWORLD DIM-STANDARD-NETHER WS-SCALE
     COMPUTE WS-F = WS-SCALE
     CALL "PORTAL-SCALE" USING DIM-STANDARD-NETHER DIM-STANDARD-OVERWORLD WS-SCALE
     COMPUTE WS-G = WS-SCALE
     CALL "PORTAL-SCALE" USING DIM-STANDARD-END DIM-STANDARD-NETHER WS-SCALE
     COMPUTE WS-H = WS-SCALE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-F) " " FUNCTION TRIM(WS-G) " " FUNCTION TRIM(WS-H) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0.125 8.000 0.125" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 39§4 Nether portal travel: E3 the origins (-38, 70, 125) and (100, 70, -26)" TO TL-CASE
     MOVE -300.5 TO WS-FX
     MOVE 70.0 TO WS-FY
     MOVE 1000.2 TO WS-FZ
     CALL "PORTAL-ORIGIN" USING DIM-STANDARD-OVERWORLD DIM-STANDARD-NETHER WS-FX WS-FY WS-FZ WS-OX WS-OY WS-OZ
     MOVE WS-OX TO WS-A
     MOVE WS-OY TO WS-B
     MOVE WS-OZ TO WS-C
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE 12.5 TO WS-FX
     MOVE -3.2 TO WS-FZ
     CALL "PORTAL-ORIGIN" USING DIM-STANDARD-NETHER DIM-STANDARD-OVERWORLD WS-FX WS-FY WS-FZ WS-OX WS-OY WS-OZ
     MOVE WS-OX TO WS-A
     MOVE WS-OY TO WS-B
     MOVE WS-OZ TO WS-C
     STRING FUNCTION TRIM(TL-OBSERVED) " / " FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "-38 70 125 / 100 70 -26" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 39§4 Nether portal travel: the origin is clamped into the destination's world border "
         & "(x 400000000 / 8 and x 5000000 x 8 end at 29999983, x -400000000 / 8 at -29999984)" TO TL-CASE
     MOVE 400000000.5 TO WS-FX
     MOVE 5.5 TO WS-FZ
     CALL "PORTAL-ORIGIN" USING DIM-STANDARD-OVERWORLD DIM-STANDARD-NETHER WS-FX WS-FY WS-FZ WS-OX WS-OY WS-OZ
     MOVE WS-OX TO WS-A
     MOVE 5000000.5 TO WS-FX
     CALL "PORTAL-ORIGIN" USING DIM-STANDARD-NETHER DIM-STANDARD-OVERWORLD WS-FX WS-FY WS-FZ WS-OX WS-OY WS-OZ
     MOVE WS-OX TO WS-B
     MOVE -400000000.5 TO WS-FX
     CALL "PORTAL-ORIGIN" USING DIM-STANDARD-OVERWORLD DIM-STANDARD-NETHER WS-FX WS-FY WS-FZ WS-OX WS-OY WS-OZ
     MOVE WS-OX TO WS-C
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "29999983 29999983 -29999984" TO TL-EXPECTED
     PERFORM CHECK

*>   E9: portal blocks x 10..11, y 65..67 (axis X) and a stray at (12, 65): pos (11, 66) gives (10, 65) 2 x 3 either way.
     MOVE DIM-STANDARD-NETHER TO WS-DEST
     MOVE 0 TO WS-Z
     PERFORM VARYING WS-X FROM 10 BY 1 UNTIL WS-X > 11
         PERFORM VARYING WS-Y FROM 65 BY 1 UNTIL WS-Y > 67
             CALL "WORLD-SET-BLOCK" USING WS-DEST WS-X WS-Y WS-Z WS-STATE-X
         END-PERFORM
     END-PERFORM
     MOVE 11 TO WS-X MOVE 66 TO WS-Y
     MOVE 0 TO WS-AXIS
     CALL "PORTAL-LARGEST-RECT" USING WS-DEST WS-X WS-Y WS-Z WS-AXIS PORTAL-RECT
     PERFORM RECT-TEXT
     MOVE TL-OBSERVED TO WS-FIRST
     MOVE 12 TO WS-X MOVE 65 TO WS-Y
     CALL "WORLD-SET-BLOCK" USING WS-DEST WS-X WS-Y WS-Z WS-STATE-X
     MOVE 11 TO WS-X MOVE 66 TO WS-Y
     CALL "PORTAL-LARGEST-RECT" USING WS-DEST WS-X WS-Y WS-Z WS-AXIS PORTAL-RECT
     PERFORM RECT-TEXT
     MOVE "acceptance US12 39§4 Nether portal travel: E9 the largest rectangle around (11, 66) is minCorner (10, 65, 0), "
         & "2 x 3, with and without a stray portal block at (12, 65)" TO TL-CASE
     MOVE "10 65 0 2 3" TO TL-EXPECTED
     IF WS-FIRST NOT = TL-OBSERVED(1:40)
         MOVE "differs with the stray block" TO TL-OBSERVED
     END-IF
     PERFORM CHECK

*>   The tie rule: columns of height 2, 3, 3 on the row of pos: height 3 on columns 1..2 beats height 2 on columns 0..2 (both area 6).
     MOVE 0 TO WS-Z
     PERFORM VARYING WS-X FROM 30 BY 1 UNTIL WS-X > 32
         MOVE 2 TO WS-J
         IF WS-X > 30
             MOVE 3 TO WS-J
         END-IF
         PERFORM VARYING WS-Y FROM 65 BY 1 UNTIL WS-Y > 64 + WS-J
             CALL "WORLD-SET-BLOCK" USING WS-DEST WS-X WS-Y WS-Z WS-STATE-X
         END-PERFORM
     END-PERFORM
     MOVE 31 TO WS-X MOVE 66 TO WS-Y
     CALL "PORTAL-LARGEST-RECT" USING WS-DEST WS-X WS-Y WS-Z WS-AXIS PORTAL-RECT
     PERFORM RECT-TEXT
     MOVE "acceptance US12 39§4 Nether portal travel: 4.3 equal areas keep the first closed candidate: heights 2, 3, 3 give "
         & "columns 1..2 at height 3 (minCorner (31, 65, 0), 2 x 3)" TO TL-CASE
     MOVE "31 65 0 2 3" TO TL-EXPECTED
     PERFORM CHECK

*>   E4: an entity at (10.9, 64.5, 20.3) in a rectangle of axis X at (10, 64, 20), 2 x 3; exit rectangle of axis Z at (100, 70, -5).
     MOVE 10 TO PR-X MOVE 64 TO PR-Y MOVE 20 TO PR-Z
     MOVE 2 TO PR-W MOVE 3 TO PR-H MOVE 0 TO PR-AXIS
     MOVE 10.9 TO WS-FX
     MOVE 64.5 TO WS-FY
     MOVE 20.3 TO WS-FZ
     CALL "PORTAL-RELATIVE" USING PORTAL-RECT WS-FX WS-FY WS-FZ WS-EW WS-EH WS-RX WS-RY WS-RZ
     COMPUTE WS-F ROUNDED = WS-RX
     COMPUTE WS-G ROUNDED = WS-RY
     COMPUTE WS-H ROUNDED = WS-RZ
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-F) " " FUNCTION TRIM(WS-G) " " FUNCTION TRIM(WS-H) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 39§4 Nether portal travel: E4 the relative position is (0.429, 0.417, -0.200)" TO TL-CASE
     MOVE "0.429 0.417 -0.200" TO TL-EXPECTED
     PERFORM CHECK

     MOVE 100 TO PR-X MOVE 70 TO PR-Y MOVE -5 TO PR-Z
     MOVE 1 TO PR-AXIS
     CALL "PORTAL-EXIT-POS" USING PORTAL-RECT WS-RX WS-RY WS-RZ WS-EW WS-EH WS-FX WS-FY WS-FZ
     COMPUTE WS-F ROUNDED = WS-FX
     COMPUTE WS-G ROUNDED = WS-FY
     COMPUTE WS-H ROUNDED = WS-FZ
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-F) " " FUNCTION TRIM(WS-G) " " FUNCTION TRIM(WS-H) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 39§4 Nether portal travel: E4 the exit position in an axis Z rectangle is (100.300, 70.500, -4.100)" TO TL-CASE
     MOVE "100.300 70.500 -4.100" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 39§4 Nether portal travel: an entity as wide as the portal stands in its middle (rx 0.5) and one on its floor has ry 0" TO TL-CASE
     MOVE 2 TO PR-W MOVE 3 TO PR-H MOVE 0 TO PR-AXIS MOVE 10 TO PR-X MOVE 64 TO PR-Y MOVE 20 TO PR-Z
     MOVE 2.0 TO WS-EW
     MOVE 3.0 TO WS-EH
     MOVE 10.5 TO WS-FX MOVE 64.0 TO WS-FY MOVE 20.5 TO WS-FZ
     CALL "PORTAL-RELATIVE" USING PORTAL-RECT WS-FX WS-FY WS-FZ WS-EW WS-EH WS-RX WS-RY WS-RZ
     COMPUTE WS-F ROUNDED = WS-RX
     COMPUTE WS-G ROUNDED = WS-RY
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-F) " " FUNCTION TRIM(WS-G) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0.500 0.000" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 RECT-TEXT.
     MOVE PR-X TO WS-A
     MOVE PR-Y TO WS-B
     MOVE PR-Z TO WS-C
     MOVE PR-W TO WS-D
     MOVE PR-H TO WS-E
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) " " FUNCTION TRIM(WS-D) " "
         FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO TL-OBSERVED.

 CHECK.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-PORTAL-39-4.

 COPY CORETEST.
 COPY PORTALTEST.
