*> The sky light of a cell with the sideways spreading of the sky engine (docs/protocol/32-light-engine.md section 5.2), for the rules that ask whether a cell is dark
*> (the monster spawn light test of 18 section 6.8, the daylight neutrality of the spider of 20 section 7.1).
*> The light the chunk stores (light.cob: the stand-in policy) is 15 in every cell above its column's topmost block and 0 at and below it, with no spreading, so a cell
*> under the eaves of a house, a porch roof or the edge of a canopy reads 0 although the sky shines in from the side (light 13 or 14). The engine spreads a level 15 sideways
*> and down, one level a step, through every cell that lets light through. LIGHT-SKY-SPREAD reproduces that for the cells near open sky: the cell's own light
*> (LIGHT-RAW) or 15 minus the length of the shortest path of face-adjacent cells that are not opaque (CB-OPAQUE: air, plants, glass, leaves, doors) to a cell whose stored sky
*> light is 15, whichever is greater. Deviations: the path costs one level a step whatever the cells (no dampening of leaves or water, no face shapes: a stair or a slab is
*> opaque); the search stops at the depth asked (at most 7) and at 600 cells, and a cell with no sky within it keeps its own light (so the deep dark, where the exact value
*> is 7 or less, reads the stored 0: the rules that need the exact low values are not asked here).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIGHT-SKY-SPREAD.
*> USING dimension row, x, y, z (BINARY-LONG), depth (BINARY-LONG, how many steps to look, 0 to 7), sky out (BINARY-LONG): the sky light of the cell as above.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 78 LS-QUEUE-MAX          VALUE 600.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-RAW                 BINARY-LONG.
 01 WS-SEEN                PIC X(3375).
 01 WS-QUEUE.
    05 WS-Q                OCCURS 600 TIMES.
       10 WS-QX            BINARY-LONG.
       10 WS-QY            BINARY-LONG.
       10 WS-QZ            BINARY-LONG.
       10 WS-QD            BINARY-LONG.
 01 WS-STEPS.
    05 FILLER              PIC S9 VALUE 1.
    05 FILLER              PIC S9 VALUE 0.
    05 FILLER              PIC S9 VALUE 0.
    05 FILLER              PIC S9 VALUE -1.
    05 FILLER              PIC S9 VALUE 0.
    05 FILLER              PIC S9 VALUE 0.
    05 FILLER              PIC S9 VALUE 0.
    05 FILLER              PIC S9 VALUE 1.
    05 FILLER              PIC S9 VALUE 0.
    05 FILLER              PIC S9 VALUE 0.
    05 FILLER              PIC S9 VALUE -1.
    05 FILLER              PIC S9 VALUE 0.
    05 FILLER              PIC S9 VALUE 0.
    05 FILLER              PIC S9 VALUE 0.
    05 FILLER              PIC S9 VALUE 1.
    05 FILLER              PIC S9 VALUE 0.
    05 FILLER              PIC S9 VALUE 0.
    05 FILLER              PIC S9 VALUE -1.
 01 WS-STEP REDEFINES WS-STEPS.
    05 WS-DELTA            OCCURS 6 TIMES.
       10 WS-DX            PIC S9.
       10 WS-DY            PIC S9.
       10 WS-DZ            PIC S9.
 01 WS-HEAD                BINARY-LONG.
 01 WS-TAIL                BINARY-LONG.
 01 WS-DEPTH               BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-ND                  BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-SKY2                BINARY-LONG.
 01 WS-BLOCK2              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DEPTH                BINARY-LONG.
 01 L-SKY                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-DEPTH L-SKY.
     CALL "LIGHT-RAW" USING L-DIM L-X L-Y L-Z L-SKY WS-BLOCK WS-RAW
     MOVE L-DEPTH TO WS-DEPTH
     IF WS-DEPTH > 7
         MOVE 7 TO WS-DEPTH
     END-IF
*>   Open sky (or one step from it) cannot gain: 15 is the most and 14 the best a spread gives.
     IF L-SKY >= 14 OR WS-DEPTH < 1
         GOBACK
     END-IF
     MOVE LOW-VALUES TO WS-SEEN
     MOVE 1 TO WS-HEAD WS-TAIL
     MOVE L-X TO WS-QX(1)
     MOVE L-Y TO WS-QY(1)
     MOVE L-Z TO WS-QZ(1)
     MOVE 0 TO WS-QD(1)
     MOVE 0 TO WS-FOUND
     MOVE "1" TO WS-SEEN(1 + 7 * 225 + 7 * 15 + 7:1)
     PERFORM UNTIL WS-HEAD > WS-TAIL OR WS-FOUND = 1
         IF WS-QD(WS-HEAD) < WS-DEPTH
             COMPUTE WS-ND = WS-QD(WS-HEAD) + 1
             PERFORM VARYING WS-DIR FROM 1 BY 1 UNTIL WS-DIR > 6 OR WS-FOUND = 1
                 COMPUTE WS-NX = WS-QX(WS-HEAD) + WS-DX(WS-DIR)
                 COMPUTE WS-NY = WS-QY(WS-HEAD) + WS-DY(WS-DIR)
                 COMPUTE WS-NZ = WS-QZ(WS-HEAD) + WS-DZ(WS-DIR)
                 COMPUTE WS-INDEX = 1 + (WS-NX - L-X + 7) * 225 + (WS-NY - L-Y + 7) * 15 + WS-NZ - L-Z + 7
                 IF WS-SEEN(WS-INDEX:1) = LOW-VALUE
                     MOVE "1" TO WS-SEEN(WS-INDEX:1)
                     CALL "WORLD-GET-BLOCK" USING L-DIM WS-NX WS-NY WS-NZ WS-STATE
                     IF WS-STATE = 0 OR CB-OPAQUE(CB-S-BLOCK(WS-STATE + 1) + 1) = 0
                         CALL "STDMOB-LIGHTS" USING L-DIM WS-NX WS-NY WS-NZ WS-SKY2 WS-BLOCK2
                         IF WS-SKY2 = 15
                             MOVE 1 TO WS-FOUND
                             IF 15 - WS-ND > L-SKY
                                 COMPUTE L-SKY = 15 - WS-ND
                             END-IF
                         ELSE
                             IF WS-TAIL < LS-QUEUE-MAX
                                 ADD 1 TO WS-TAIL
                                 MOVE WS-NX TO WS-QX(WS-TAIL)
                                 MOVE WS-NY TO WS-QY(WS-TAIL)
                                 MOVE WS-NZ TO WS-QZ(WS-TAIL)
                                 MOVE WS-ND TO WS-QD(WS-TAIL)
                             END-IF
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
         END-IF
         ADD 1 TO WS-HEAD
     END-PERFORM
     GOBACK.
 END PROGRAM LIGHT-SKY-SPREAD.
