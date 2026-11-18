*> T5300 (lane 002-lane-hand): the first-person hand follows 12 section 6.3 and 8.2: the item is posed by the arm transform, the swing and the
*> model's display transform (the defaults of 12 section 8.2 where the model names none), a flat item is extruded (08 section 5.7: front and back
*> quads and one thin quad where an opaque pixel borders a transparent one, each showing one texel, never the whole icon stretched over a thin
*> face), and the equip animation lifts it from below (12 section 6.2). Expected positions are computed by the independent script of the task.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-HAND-MODEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-SUM                 FLOAT-LONG OCCURS 3 TIMES.
 01 WS-MIN                 FLOAT-LONG OCCURS 2 TIMES.
 01 WS-MAX                 FLOAT-LONG OCCURS 2 TIMES.
 01 WS-D                   FLOAT-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-EDGES               BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-SAVED-SW            BINARY-LONG.
 01 WS-M.
    05 FILLER              FLOAT-LONG VALUE 1.
    05 FILLER              FLOAT-LONG VALUE 0.
    05 FILLER              FLOAT-LONG VALUE 0.
    05 FILLER              FLOAT-LONG VALUE 0.
    05 FILLER              FLOAT-LONG VALUE 1.
    05 FILLER              FLOAT-LONG VALUE 0.
    05 FILLER              FLOAT-LONG VALUE 0.
    05 FILLER              FLOAT-LONG VALUE 0.
    05 FILLER              FLOAT-LONG VALUE 1.
    05 FILLER              FLOAT-LONG VALUE 0.
    05 FILLER              FLOAT-LONG VALUE 0.
    05 FILLER              FLOAT-LONG VALUE 0.
 01 WS-ROT.
    05 FILLER              FLOAT-LONG VALUE 1.
    05 FILLER              FLOAT-LONG VALUE 0.
    05 FILLER              FLOAT-LONG VALUE 0.
    05 FILLER              FLOAT-LONG VALUE 0.
    05 FILLER              FLOAT-LONG VALUE 1.
    05 FILLER              FLOAT-LONG VALUE 0.
    05 FILLER              FLOAT-LONG VALUE 0.
    05 FILLER              FLOAT-LONG VALUE 0.
    05 FILLER              FLOAT-LONG VALUE 1.
 01 WS-CORNERS.
    05 WS-CP               FLOAT-LONG OCCURS 12 TIMES VALUE 0.
 01 WS-UV.
    05 WS-UVV              FLOAT-SHORT OCCURS 8 TIMES VALUE 0.
 01 WS-NORMAL.
    05 WS-NV               FLOAT-LONG OCCURS 3 TIMES VALUE 0.
 01 WS-LIGHT               FLOAT-LONG VALUE 1.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "N" TO TL-MODE
*>   These cases are about the poses and the whole mesh, not about which faces face the eye (T32900 tests that): keep the back faces.
     MOVE 1 TO CL-HAND-NOCULL
     MOVE 1 TO PL-SLOT-COUNT(PL-HELD + 1)
     MOVE 0 TO CL-SWING-AT
     MOVE 1000000 TO CL-NOW-MS
*>   The equip animation has run: item 10 (a flat icon) is shown at full height.
     MOVE 10 TO PL-SLOT-ITEM(PL-HELD + 1)
     MOVE 11 TO CL-HAND-ITEM
     MOVE 1 TO CL-HAND-H CL-HAND-OH
     MOVE CL-NOW-MS TO CL-HAND-TICK-MS
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "T5300 a flat item is extruded: more than the front and back quads, whole quads" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF RL-HAND-COUNT > 12 AND FUNCTION MOD(RL-HAND-COUNT, 6) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE RL-HAND-COUNT TO WS-N
     MOVE "T6101 the first mesh of an item is built (not the one already uploaded)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-HAND-SAME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "T6101 the same item, height and light with no swing keeps the mesh already uploaded (same count, flag set)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF RL-HAND-SAME = 1 AND RL-HAND-COUNT = WS-N
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Front and back centre: the generated display transform (rotation 0 -90 25, translation 1.13 3.2 1.13 sixteenths, scale 0.68) on the arm pose.
     MOVE 0 TO WS-SUM(1) WS-SUM(2) WS-SUM(3)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         ADD RL-HAND-X(WS-I) TO WS-SUM(1)
         ADD RL-HAND-Y(WS-I) TO WS-SUM(2)
         ADD RL-HAND-Z(WS-I) TO WS-SUM(3)
     END-PERFORM
     COMPUTE WS-X = WS-SUM(1) / 12
     COMPUTE WS-Y = WS-SUM(2) / 12
     COMPUTE WS-Z = WS-SUM(3) / 12
     MOVE "T5300 at rest the flat item's centre is at (0.6306, -0.32, -0.6494)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(WS-X - 0.6306) < 0.003 AND FUNCTION ABS(WS-Y + 0.32) < 0.003 AND FUNCTION ABS(WS-Z + 0.6494) < 0.003
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The front quad's corners are 0.68 apart (the scale), so a diagonal of 0.9617.
     COMPUTE WS-D = FUNCTION SQRT((RL-HAND-X(1) - RL-HAND-X(3)) ** 2 + (RL-HAND-Y(1) - RL-HAND-Y(3)) ** 2
         + (RL-HAND-Z(1) - RL-HAND-Z(3)) ** 2)
     MOVE "T5300 the flat item is 0.68 blocks across (scale 0.68)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-D > 0.9 AND WS-D < 1.02
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Every edge quad (after the front and back) shows one texel: its vertices differ by less than a texel in u and v.
     MOVE 0 TO WS-BAD
     COMPUTE WS-LIMIT = WS-N / 6
     PERFORM VARYING WS-Q FROM 3 BY 1 UNTIL WS-Q > WS-LIMIT
         MOVE 9 TO WS-MIN(1) WS-MIN(2)
         MOVE -9 TO WS-MAX(1) WS-MAX(2)
         COMPUTE WS-START = (WS-Q - 1) * 6 + 1
         COMPUTE WS-STOP = WS-Q * 6
         PERFORM VARYING WS-I FROM WS-START BY 1 UNTIL WS-I > WS-STOP
             MOVE FUNCTION MIN(WS-MIN(1), RL-HAND-U(WS-I)) TO WS-MIN(1)
             MOVE FUNCTION MAX(WS-MAX(1), RL-HAND-U(WS-I)) TO WS-MAX(1)
             MOVE FUNCTION MIN(WS-MIN(2), RL-HAND-V(WS-I)) TO WS-MIN(2)
             MOVE FUNCTION MAX(WS-MAX(2), RL-HAND-V(WS-I)) TO WS-MAX(2)
         END-PERFORM
         IF (WS-MAX(1) - WS-MIN(1)) * AT-W > 1.01 OR (WS-MAX(2) - WS-MIN(2)) * AT-H > 1.01
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "T5300 no edge quad stretches the icon over a thin face (each shows one texel)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Half way through the swing (p = 0.5) the centre is at (0.2145, -0.5414, -1.0609).
     MOVE 1 TO CL-SWING-AT
     COMPUTE CL-NOW-MS = CL-SWING-AT + 150
     MOVE CL-NOW-MS TO CL-HAND-TICK-MS
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE 0 TO WS-SUM(1) WS-SUM(2) WS-SUM(3)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         ADD RL-HAND-X(WS-I) TO WS-SUM(1)
         ADD RL-HAND-Y(WS-I) TO WS-SUM(2)
         ADD RL-HAND-Z(WS-I) TO WS-SUM(3)
     END-PERFORM
     COMPUTE WS-X = WS-SUM(1) / 12
     COMPUTE WS-Y = WS-SUM(2) / 12
     COMPUTE WS-Z = WS-SUM(3) / 12
     MOVE 1 TO TL-EXPECTED-N
     MOVE "T5300 half way through the swing the flat item's centre is at (0.2145, -0.5414, -1.0609)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(WS-X - 0.2145) < 0.003 AND FUNCTION ABS(WS-Y + 0.5414) < 0.003 AND FUNCTION ABS(WS-Z + 1.0609) < 0.003
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A block item (item 1): the 36 vertices of a cube of 0.4 blocks, centred on the arm pose.
     MOVE 0 TO CL-SWING-AT
     MOVE 2 TO CL-HAND-ITEM
     MOVE 1 TO PL-SLOT-ITEM(PL-HELD + 1)
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "T5300 a block item is a cube of 36 vertices" TO TL-CASE
     MOVE 36 TO TL-EXPECTED-N
     MOVE RL-HAND-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-SUM(1) WS-SUM(2) WS-SUM(3)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         ADD RL-HAND-X(WS-I) TO WS-SUM(1)
         ADD RL-HAND-Y(WS-I) TO WS-SUM(2)
         ADD RL-HAND-Z(WS-I) TO WS-SUM(3)
     END-PERFORM
     COMPUTE WS-X = WS-SUM(1) / 36
     COMPUTE WS-Y = WS-SUM(2) / 36
     COMPUTE WS-Z = WS-SUM(3) / 36
     MOVE 1 TO TL-EXPECTED-N
     MOVE "T5300 at rest the block item is at the arm pose (0.56, -0.52, -0.72)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(WS-X - 0.56) < 0.003 AND FUNCTION ABS(WS-Y + 0.52) < 0.003 AND FUNCTION ABS(WS-Z + 0.72) < 0.003
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Equip: a hand that shows nothing yet lowers the item by 0.6 and lifts it in 4 ticks; a changed stack lowers it again.
     MOVE 0 TO CL-HAND-ITEM CL-HAND-H CL-HAND-OH
     MOVE 0 TO CL-HAND-TICK-MS
     MOVE 2000000 TO CL-NOW-MS
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "T5300 a hand that shows nothing yet draws nothing at the first frame" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-HAND-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     ADD 50 TO CL-NOW-MS
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "T5300 one tick later the hand shows the item, lowered (h = 0 at the bottom of the dip)" TO TL-CASE
     MOVE 36 TO TL-EXPECTED-N
     MOVE RL-HAND-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE CL-NOW-MS = CL-NOW-MS + 250
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE 0 TO WS-SUM(2)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         ADD RL-HAND-Y(WS-I) TO WS-SUM(2)
     END-PERFORM
     COMPUTE WS-Y = WS-SUM(2) / 36
     MOVE 1 TO TL-EXPECTED-N
     MOVE "T5300 five ticks later the item is fully up (y = -0.52)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(WS-Y + 0.52) < 0.003
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 10 TO PL-SLOT-ITEM(PL-HELD + 1)
     ADD 100 TO CL-NOW-MS
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "T5300 after a change of stack the old item is still drawn while it dips (36 vertices of the cube)" TO TL-CASE
     MOVE 36 TO TL-EXPECTED-N
     MOVE RL-HAND-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-SUM(2)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         ADD RL-HAND-Y(WS-I) TO WS-SUM(2)
     END-PERFORM
     COMPUTE WS-Y = WS-SUM(2) / 36
     MOVE 1 TO TL-EXPECTED-N
     MOVE "T5300 the dipping item is lower than at rest" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-Y < -0.6
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A display entry that the item's models name is used instead of the defaults (a stand-in set has none: set by hand); a code-drawn model draws nothing.
     MOVE 0 TO CL-SWING-AT
     MOVE 11 TO CL-HAND-ITEM
     MOVE 1 TO CL-HAND-H CL-HAND-OH
     MOVE CL-NOW-MS TO CL-HAND-TICK-MS
     MOVE 1 TO IS-FP-STATE(11)
     MOVE 0 TO IS-FP-VAL(91) IS-FP-VAL(92) IS-FP-VAL(93) IS-FP-VAL(94) IS-FP-VAL(95) IS-FP-VAL(96)
     MOVE 1 TO IS-FP-VAL(97) IS-FP-VAL(98) IS-FP-VAL(99)
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE 0 TO WS-SUM(1) WS-SUM(2) WS-SUM(3)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         ADD RL-HAND-X(WS-I) TO WS-SUM(1)
         ADD RL-HAND-Y(WS-I) TO WS-SUM(2)
         ADD RL-HAND-Z(WS-I) TO WS-SUM(3)
     END-PERFORM
     COMPUTE WS-X = WS-SUM(1) / 12
     COMPUTE WS-Y = WS-SUM(2) / 12
     COMPUTE WS-Z = WS-SUM(3) / 12
     MOVE "T5300 a model's own display (identity) puts the icon's centre on the arm pose" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(WS-X - 0.56) < 0.003 AND FUNCTION ABS(WS-Y + 0.52) < 0.003 AND FUNCTION ABS(WS-Z + 0.72) < 0.003
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO IS-FP-STATE(11)
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "T5300 a code-drawn model draws no hand" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-HAND-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO IS-FP-STATE(11)
*>   A sprite wider than 32 pixels is read as 32 (the table of opaque pixels).
     MOVE AT-SW(IT-SPRITE(11)) TO WS-SAVED-SW
     MOVE 64 TO AT-SW(IT-SPRITE(11))
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE WS-SAVED-SW TO AT-SW(IT-SPRITE(11))
     MOVE "T5300 a sprite wider than 32 pixels still builds whole quads" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF RL-HAND-COUNT > 12 AND FUNCTION MOD(RL-HAND-COUNT, 6) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A full mesh takes no more quads; a stalled or backwards clock restarts the equip ticks.
     MOVE 2044 TO RL-HAND-COUNT
     CALL "HAND-QUAD" USING CLIENT-STATE WS-M WS-CORNERS WS-UV WS-NORMAL WS-LIGHT WS-ROT
     MOVE "T5300 a mesh of 2044 vertices takes no more quad" TO TL-CASE
     MOVE 2044 TO TL-EXPECTED-N
     MOVE RL-HAND-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A swing in progress builds the mesh again each frame; a changed light does too; so does the frame after the hand showed nothing.
     MOVE 1000000 TO CL-NOW-MS
     MOVE 10 TO PL-SLOT-ITEM(PL-HELD + 1)
     MOVE 11 TO CL-HAND-ITEM
     MOVE 1 TO CL-HAND-H CL-HAND-OH
     MOVE CL-NOW-MS TO CL-HAND-TICK-MS
     MOVE 1000000 TO CL-SWING-AT
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "T6101 a swing in progress builds the mesh again (flag clear)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-HAND-SAME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO CL-SWING-AT
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "T6101 the frame after a swing has no mesh to reuse (flag clear)" TO TL-CASE
     MOVE RL-HAND-SAME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "T6101 a still hand reuses the mesh again after that (flag set)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE RL-HAND-SAME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CL-HAND-KEY-LIGHT TO WS-X
     COMPUTE CL-HAND-KEY-LIGHT = CL-HAND-KEY-LIGHT + 0.5
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "T6101 a different light builds the mesh again (flag clear)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-HAND-SAME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 11 TO CL-HAND-ITEM
     MOVE 1 TO CL-HAND-H CL-HAND-OH
     MOVE 1 TO CL-HAND-TICK-MS
     MOVE 3000000 TO CL-NOW-MS
     CALL "HAND-EQUIP" USING CLIENT-STATE WS-X
     MOVE "T5300 after a gap of over 400 ms the equip clock restarts without ticks (E = 0)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(WS-X) < 0.001 AND CL-HAND-TICK-MS = CL-NOW-MS
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5000000 TO CL-HAND-TICK-MS
     CALL "HAND-EQUIP" USING CLIENT-STATE WS-X
     MOVE "T5300 a clock that ran backwards restarts too" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF CL-HAND-TICK-MS = CL-NOW-MS
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-HAND-MODEL.

 COPY CLTEST.
