*> Implementation test of the extra-dimension generator (core/src/worldgen.cob; standin-content §15.2)
*> and of the generator selection by dimension (DIMENSIONS.cpy DM-GENERATOR, DM-BIOME): floor height
*> of sample columns of cobolcraft:subroutine (expected values computed with IEEE 754 double sin/cos
*> and rounding halves away from zero), the extremes 27 and 37, the layers of a column (baseplate,
*> greystone, slag, void), the marker glowtube of chunks whose chunk x and z are multiples of 3
*> (negative ones included), the ash_flats biome everywhere, and cobolcraft:main still getting the
*> §5.2 generator. A column is rendered as runs "<state>x<count>" from y 0 upward to the top of the
*> dimension (127; the chunk memory above it stays void).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-WORLDGEN-EXTRA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY DIMENSIONS.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-MARKER              BINARY-LONG.
 01 WS-PREV                BINARY-LONG.
 01 WS-RUN                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-NUM                 BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-ROW                 PIC X(1024).
 01 WS-PTR                 BINARY-LONG.
 01 WS-AREA                PIC X(196608).
 01 WS-AREA-TABLE REDEFINES WS-AREA.
    05 WS-CELL             BINARY-SHORT UNSIGNED OCCURS 98304 TIMES.
 01 WS-BIOMES.
    05 WS-BIOME            BINARY-LONG OCCURS 16 TIMES.
 01 WS-SAMPLES.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 8.
    05 FILLER BINARY-LONG VALUE 8.
    05 FILLER BINARY-LONG VALUE 17.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -17.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 5.
    05 FILLER BINARY-LONG VALUE -40.
    05 FILLER BINARY-LONG VALUE 100.
    05 FILLER BINARY-LONG VALUE 200.
    05 FILLER BINARY-LONG VALUE -33.
    05 FILLER BINARY-LONG VALUE -26.
    05 FILLER BINARY-LONG VALUE 1000.
    05 FILLER BINARY-LONG VALUE -777.
    05 FILLER BINARY-LONG VALUE 52.
    05 FILLER BINARY-LONG VALUE 13.
    05 FILLER BINARY-LONG VALUE -48.
    05 FILLER BINARY-LONG VALUE 8.
 01 WS-SAMPLE-TABLE REDEFINES WS-SAMPLES.
    05 WS-SAMPLE OCCURS 10 TIMES.
       10 WS-SAMPLE-X      BINARY-LONG.
       10 WS-SAMPLE-Z      BINARY-LONG.
 01 WS-OPEN-TYPE          BINARY-LONG VALUE 1.
 01 WS-OPEN-DIR           PIC X(1100) VALUE SPACES.
 01 WS-OPEN-STATUS        BINARY-LONG.
 PROCEDURE DIVISION.
*>   The generators read the ids of their blocks from the open content set (BLOCKS-OPEN roles).
     CALL "CONTENT-OPEN" USING WS-OPEN-TYPE WS-OPEN-DIR WS-OPEN-STATUS
     CALL "BLOCKS-OPEN"
     MOVE "test worldgen extra subroutine floor height of sample columns" TO TL-CASE
     PERFORM START-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         CALL "WORLDGEN-SUB-HEIGHT" USING WS-SAMPLE-X(WS-I) WS-SAMPLE-Z(WS-I) WS-H
         MOVE WS-H TO WS-NUM
         PERFORM ADD-NUM
     END-PERFORM
     MOVE "32 35 37 27 30 30 32 31 29 36" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test worldgen extra subroutine floor height extremes are 27 and 37" TO TL-CASE
     MOVE 999 TO WS-MIN
     MOVE -999 TO WS-MAX
     PERFORM VARYING WS-X FROM -100 BY 1 UNTIL WS-X > 100
         PERFORM VARYING WS-Z FROM -26 BY 13 UNTIL WS-Z > 26
             CALL "WORLDGEN-SUB-HEIGHT" USING WS-X WS-Z WS-H
             IF WS-H < WS-MIN
                 MOVE WS-H TO WS-MIN
             END-IF
             IF WS-H > WS-MAX
                 MOVE WS-H TO WS-MAX
             END-IF
         END-PERFORM
     END-PERFORM
     PERFORM START-ROW
     MOVE WS-MIN TO WS-NUM
     PERFORM ADD-NUM
     MOVE WS-MAX TO WS-NUM
     PERFORM ADD-NUM
     MOVE "27 37" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE DIM-SUBROUTINE TO WS-DIM
     MOVE "test worldgen extra subroutine marker glowtube at chunk (0, 0) local (8, 8), h 35"
         TO TL-CASE
     MOVE 0 TO WS-CX WS-CZ
     MOVE 8 TO WS-LX WS-LZ
     PERFORM CHUNK-COLUMN
     MOVE "1x1 2x32 17x3 13x1 0x91 36" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test worldgen extra subroutine chunk (-3, 3) is a marker chunk (negative multiple of 3)"
         TO TL-CASE
     MOVE -3 TO WS-CX
     MOVE 3 TO WS-CZ
     PERFORM CHUNK-COLUMN
     MOVE "1x1 2x28 17x3 13x1 0x95 32" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test worldgen extra subroutine column (17, 0) of chunk (1, 0): no marker, h 37" TO TL-CASE
     MOVE 1 TO WS-CX
     MOVE 0 TO WS-CZ
     MOVE 1 TO WS-LX
     MOVE 0 TO WS-LZ
     PERFORM CHUNK-COLUMN
     MOVE "1x1 2x34 17x3 0x90 -1" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test worldgen extra subroutine chunk (-1, 0) has no marker (-1 mod 3 = 2)" TO TL-CASE
     MOVE -1 TO WS-CX
     MOVE 0 TO WS-CZ
     MOVE 8 TO WS-LX WS-LZ
     PERFORM CHUNK-COLUMN
     MOVE "1x1 2x26 17x3 0x98 -1" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test worldgen extra subroutine lowest column (-91, -2), h 27" TO TL-CASE
     MOVE -6 TO WS-CX
     MOVE -1 TO WS-CZ
     MOVE 5 TO WS-LX
     MOVE 14 TO WS-LZ
     PERFORM CHUNK-COLUMN
     MOVE "1x1 2x24 17x3 0x100 -1" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test worldgen extra subroutine biome is ash_flats (2) in every cell" TO TL-CASE
     MOVE 5 TO WS-CX
     MOVE -7 TO WS-CZ
     PERFORM BIOME-ROW
     MOVE "2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE DIM-MAIN TO WS-DIM
     MOVE "test worldgen extra cobolcraft:main keeps the surface generator (marker pillar of (0, 0))"
         TO TL-CASE
     MOVE 0 TO WS-CX WS-CZ
     MOVE 8 TO WS-LX WS-LZ
     CALL "WORLDGEN-DIM-CHUNK" USING WS-DIM WS-CX WS-CZ WS-AREA WS-MARKER
     MOVE 255 TO WS-TOP
     PERFORM COLUMN-RUNS
     MOVE WS-MARKER TO WS-NUM
     PERFORM ADD-NUM
     MOVE "1x1 2x50 3x3 4x1 9x2 8x1 12x1 13x1 0x196 59" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test worldgen extra cobolcraft:main keeps the surface biomes of chunk (0, 0)" TO TL-CASE
     MOVE 0 TO WS-CX WS-CZ
     PERFORM BIOME-ROW
     MOVE "0 0 0 1 0 0 0 1 0 0 0 1 0 0 0 1" TO TL-EXPECTED
     PERFORM ASSERT-ROW
     STOP RUN.

 CHUNK-COLUMN.
     MOVE ALL X"FF" TO WS-AREA
     CALL "WORLDGEN-DIM-CHUNK" USING WS-DIM WS-CX WS-CZ WS-AREA WS-MARKER
     MOVE 127 TO WS-TOP
     PERFORM COLUMN-RUNS
     MOVE WS-MARKER TO WS-NUM
     PERFORM ADD-NUM
*>   The memory above the dimension's top is void too.
     PERFORM VARYING WS-Y FROM 128 BY 1 UNTIL WS-Y > 255
         IF WS-CELL(WS-Y * 256 + WS-LZ * 16 + WS-LX + 1) NOT = 0
             MOVE "above-top-not-void" TO WS-ROW
         END-IF
     END-PERFORM.

 BIOME-ROW.
     CALL "WORLDGEN-DIM-BIOMES" USING WS-DIM WS-CX WS-CZ WS-BIOMES
     PERFORM START-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE WS-BIOME(WS-I) TO WS-NUM
         PERFORM ADD-NUM
     END-PERFORM.

 COLUMN-RUNS.
     PERFORM START-ROW
     MOVE -1 TO WS-PREV
     MOVE 0 TO WS-RUN
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > WS-TOP
         MOVE WS-CELL(WS-Y * 256 + WS-LZ * 16 + WS-LX + 1) TO WS-STATE
         IF WS-STATE NOT = WS-PREV AND WS-RUN > 0
             PERFORM ADD-RUN
             MOVE 0 TO WS-RUN
         END-IF
         MOVE WS-STATE TO WS-PREV
         ADD 1 TO WS-RUN
     END-PERFORM
     PERFORM ADD-RUN.

 ADD-RUN.
     MOVE WS-PREV TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) "x" DELIMITED BY SIZE INTO WS-ROW POINTER WS-PTR
     MOVE WS-RUN TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO WS-ROW POINTER WS-PTR.

 START-ROW.
     MOVE SPACES TO WS-ROW
     MOVE 1 TO WS-PTR.

 ADD-NUM.
     MOVE WS-NUM TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO WS-ROW POINTER WS-PTR.

 ASSERT-ROW.
     MOVE "T" TO TL-MODE
     MOVE WS-ROW TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-WORLDGEN-EXTRA.
