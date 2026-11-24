*> The noise spawn finder (docs/protocol/36-structures-1-model-placement-starts.md section 4.9, 33 section 6.3): the dimension origin of the noise generator, which is
*> the centre of the initial world spawn search (33 section 6.2). A probe's fitness is the smallest, over the spawn_target points of the overworld noise settings, sum of
*> the squared distances of the five climate values (continents, erosion, temperature, vegetation, ridges, quantised with a float multiply by 10000 and truncated) to
*> the point's intervals, times 2048 squared, plus x squared and z squared; the search probes a ring around the best position so far (pass 1 radius 512 to 2048 in
*> steps of 512, pass 2 radius 32 to 512 in steps of 32; the angle and the radius are 32-bit floats) and keeps a strictly lower fitness. No random source is used.
*>
*> Entry points:
*>   SPAWN-ALIGN USING x, aligned out (BINARY-LONG): the column rounded down to a multiple of 4 (QuartPos.toBlock(fromBlock(x)))
*>   SPAWN-RING-POINT USING cx, cz (BINARY-LONG), angle, radius (FLOAT-LONG holding a float32), x out, z out (BINARY-LONG): the probe of the ring
*>   SPAWN-RING-NEXT USING angle, radius, step (FLOAT-LONG; angle and radius in/out): angle += step / radius; a new ring after 2 pi
*>   SPAWN-FITNESS-OF USING boxes (BINARY-LONG: first spawn_target box, CTWORLDGEN.cpy domain 12), x, z (BINARY-LONG), values (5 BINARY-DOUBLE quantised: continents,
*>     erosion, temperature, vegetation, ridges), fitness out (BINARY-DOUBLE)
*>   SPAWN-FITNESS-AT USING boxes, x, z, fitness out: the values are the density functions of the overworld at the aligned column (y 0), then SPAWN-FITNESS-OF
*>   SPAWN-SEARCH USING boxes, x out, z out (BINARY-LONG): the two passes
*>   SPAWN-ORIGIN USING chunk x out, chunk z out: the chunk of the result of SPAWN-SEARCH for the overworld noise settings; (0, 0) when the content holds no
*>     spawn_target list or no overworld climate functions (a generator without spawn targets, 36-1 4.9)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPAWN-ALIGN.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-ALIGNED              BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-ALIGNED.
     COMPUTE L-ALIGNED = FUNCTION INTEGER(L-X / 4) * 4
     GOBACK.
 END PROGRAM SPAWN-ALIGN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPAWN-RING-POINT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 01 WS-O                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-ANGLE                FLOAT-LONG.
 01 L-RADIUS               FLOAT-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ L-ANGLE L-RADIUS L-X L-Z.
     CALL STATIC "cc_f64_sin" USING BY REFERENCE L-ANGLE WS-R
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-R L-RADIUS WS-P
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-P WS-O
     COMPUTE L-X = L-CX + WS-O
     CALL STATIC "cc_f64_cos" USING BY REFERENCE L-ANGLE WS-R
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-R L-RADIUS WS-P
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-P WS-O
     COMPUTE L-Z = L-CZ + WS-O
     GOBACK.
 END PROGRAM SPAWN-RING-POINT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPAWN-RING-NEXT.
*> The comparison with 2 pi is made on the exact difference: a FLOAT-LONG comparison is fuzzy (relative 1e-7) and the float32 nearest 2 pi is closer than that.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TWO-PI              FLOAT-LONG VALUE 6.283185307179586.
 01 WS-Q                   FLOAT-LONG.
 01 WS-Q2                  FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-DIFF                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ANGLE                FLOAT-LONG.
 01 L-RADIUS               FLOAT-LONG.
 01 L-STEP                 FLOAT-LONG.
 PROCEDURE DIVISION USING L-ANGLE L-RADIUS L-STEP.
     CALL STATIC "cc_f64_div" USING BY REFERENCE L-STEP L-RADIUS WS-Q
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-Q WS-Q2
     CALL STATIC "cc_f64_add" USING BY REFERENCE L-ANGLE WS-Q2 WS-S
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-S L-ANGLE
     CALL STATIC "cc_f64_sub" USING BY REFERENCE L-ANGLE WS-TWO-PI WS-DIFF
     IF WS-DIFF > 0
         MOVE 0 TO L-ANGLE
         CALL STATIC "cc_f64_add" USING BY REFERENCE L-RADIUS L-STEP WS-S
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-S L-RADIUS
     END-IF
     GOBACK.
 END PROGRAM SPAWN-RING-NEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPAWN-FITNESS-OF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTWORLDGEN.
 01 WS-BOX                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-LO                  BINARY-DOUBLE.
 01 WS-HI                  BINARY-DOUBLE.
 01 WS-D                   BINARY-DOUBLE.
 01 WS-S                   BINARY-DOUBLE.
 01 WS-M                   BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-BOXES                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-VALUES.
    05 L-V                 BINARY-DOUBLE OCCURS 5 TIMES.
 01 L-FITNESS              BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-BOXES L-X L-Z L-VALUES L-FITNESS.
     MOVE 9223372036854775807 TO WS-M
     MOVE L-BOXES TO WS-BOX
     PERFORM UNTIL WS-BOX = 0
         MOVE 0 TO WS-S
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
             COMPUTE WS-J = WS-I * 2 - 1
             CALL "CLIMATE-F32-QUANTIZE" USING WGN-NUM(WS-BOX, WS-J) WS-LO
             ADD 1 TO WS-J
             CALL "CLIMATE-F32-QUANTIZE" USING WGN-NUM(WS-BOX, WS-J) WS-HI
             COMPUTE WS-D = L-V(WS-I) - WS-HI
             IF WS-D <= 0
                 COMPUTE WS-D = WS-LO - L-V(WS-I)
                 IF WS-D < 0
                     MOVE 0 TO WS-D
                 END-IF
             END-IF
             COMPUTE WS-S = WS-S + WS-D * WS-D
         END-PERFORM
         IF WS-S < WS-M
             MOVE WS-S TO WS-M
         END-IF
         MOVE WGN-NEXT(WS-BOX) TO WS-BOX
     END-PERFORM
     COMPUTE L-FITNESS = WS-M * 4194304 + L-X * L-X + L-Z * L-Z
     GOBACK.
 END PROGRAM SPAWN-FITNESS-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPAWN-FITNESS-AT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEYS.
    05 FILLER PIC X(112) VALUE "minecraft:overworld/continents".
    05 FILLER PIC X(112) VALUE "minecraft:overworld/erosion".
    05 FILLER PIC X(112) VALUE "minecraft:overworld/temperature".
    05 FILLER PIC X(112) VALUE "minecraft:overworld/vegetation".
    05 FILLER PIC X(112) VALUE "minecraft:overworld/ridges".
 01 WS-KEY-TABLE REDEFINES WS-KEYS.
    05 WS-KEY              PIC X(112) OCCURS 5 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-Y                   BINARY-LONG VALUE 0.
 01 WS-F                   FLOAT-LONG.
 01 WS-VALUES.
    05 WS-V                BINARY-DOUBLE OCCURS 5 TIMES.
 LINKAGE SECTION.
 01 L-BOXES                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FITNESS              BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-BOXES L-X L-Z L-FITNESS.
     CALL "SPAWN-ALIGN" USING L-X WS-QX
     CALL "SPAWN-ALIGN" USING L-Z WS-QZ
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         CALL "DENSITY-EVAL" USING WS-KEY(WS-I) WS-QX WS-Y WS-QZ WS-F
         CALL "CLIMATE-F32-QUANTIZE" USING WS-F WS-V(WS-I)
     END-PERFORM
     CALL "SPAWN-FITNESS-OF" USING L-BOXES L-X L-Z WS-VALUES L-FITNESS
     GOBACK.
 END PROGRAM SPAWN-FITNESS-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPAWN-SEARCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PASS                BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-BEST                BINARY-DOUBLE.
 01 WS-FIT                 BINARY-DOUBLE.
 01 WS-ANGLE               FLOAT-LONG.
 01 WS-RADIUS              FLOAT-LONG.
 01 WS-STEP                FLOAT-LONG.
 01 WS-MAX                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-BOXES                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-BOXES L-X L-Z.
     MOVE 0 TO L-X L-Z
     CALL "SPAWN-FITNESS-AT" USING L-BOXES L-X L-Z WS-BEST
     PERFORM VARYING WS-PASS FROM 1 BY 1 UNTIL WS-PASS > 2
         MOVE L-X TO WS-CX
         MOVE L-Z TO WS-CZ
         IF WS-PASS = 1
             MOVE 2048 TO WS-MAX
             MOVE 512 TO WS-STEP
         ELSE
             MOVE 512 TO WS-MAX
             MOVE 32 TO WS-STEP
         END-IF
         MOVE 0 TO WS-ANGLE
         MOVE WS-STEP TO WS-RADIUS
         PERFORM UNTIL WS-RADIUS > WS-MAX
             CALL "SPAWN-RING-POINT" USING WS-CX WS-CZ WS-ANGLE WS-RADIUS WS-X WS-Z
             CALL "SPAWN-FITNESS-AT" USING L-BOXES WS-X WS-Z WS-FIT
             IF WS-FIT < WS-BEST
                 MOVE WS-FIT TO WS-BEST
                 MOVE WS-X TO L-X
                 MOVE WS-Z TO L-Z
             END-IF
             CALL "SPAWN-RING-NEXT" USING WS-ANGLE WS-RADIUS WS-STEP
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM SPAWN-SEARCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPAWN-ORIGIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTWORLDGEN.
 01 WS-KIND-SETTINGS       BINARY-LONG VALUE 6.
 01 WS-KIND-FUNCTION       BINARY-LONG VALUE 1.
 01 WS-KEY-SETTINGS        PIC X(112) VALUE "minecraft:overworld".
 01 WS-KEY-CONTINENTS      PIC X(112) VALUE "minecraft:overworld/continents".
 01 WS-ROOT                BINARY-LONG.
 01 WS-FN                  BINARY-LONG.
 01 WS-BOXES               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ.
     MOVE 0 TO L-CX L-CZ WS-BOXES
     CALL "WG-FIND" USING WS-KIND-SETTINGS WS-KEY-SETTINGS WS-ROOT
     IF WS-ROOT > 0
         MOVE WGN-CHILD(WS-ROOT, 16) TO WS-BOXES
     END-IF
     CALL "WG-FIND" USING WS-KIND-FUNCTION WS-KEY-CONTINENTS WS-FN
     IF WS-BOXES > 0 AND WS-FN > 0
         CALL "GEN-WORLD-SETUP"
         CALL "SPAWN-SEARCH" USING WS-BOXES WS-X WS-Z
         COMPUTE L-CX = FUNCTION INTEGER(WS-X / 16)
         COMPUTE L-CZ = FUNCTION INTEGER(WS-Z / 16)
     END-IF
     GOBACK.
 END PROGRAM SPAWN-ORIGIN.
