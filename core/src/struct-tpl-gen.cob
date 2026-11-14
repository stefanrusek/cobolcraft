*> findGenerationPoint of the template structures (docs/protocol/36-structures-4 section 6 igloo, 36-structures-6 section 4 shipwreck and section 3 ocean ruins, whose pieces are in struct-ruin.cob) and the hooks of their pieces: the start
*> random (the Java LCG seeded by setLargeFeatureSeed, SP-RNG), the stub position on top of the chunk centre (the base height of STRUCT-BASE-HEIGHT, 36-4 2.2 item 2: the stub y is
*> the first occupied height, y of the top block) and the template pieces of the structure (STRUCT-TPL-PIECE-ADD, kinds 1 igloo and 2 shipwreck). The biome check of 36-4 2.2 item 1 is
*> STRUCT-VALID-AT at the stub (the "could exist on top of the chunk centre" test before it holds whenever the check at the stub passes, so it is not made on its own).
*>
*> Heights: the doc's `level.getHeight` of the generation region is the live heightmap of whichever chunk holds the column, which would make a piece's position depend on which chunk's
*> pass reaches it first. Here every height a piece needs is the base height of the column (STRUCT-BASE-HEIGHT: the noise terrain alone, deterministic, the same in every pass and
*> process), and the shipwreck's one-time adjustment (36-6 4.3 step 2, done at the first pass in vanilla and then saved) is made when the start is built, with the beached draw taken
*> from the start random (the structure's own dead branch of 36-6 4.2 step 3 does the same), so each chunk's pass places the piece at the same height.
*>
*> Entry points:
*>   STRUCT-TPL-FIND-POINT USING structure row, seed (BINARY-DOUBLE), chunk x, chunk z, x out, y out, z out, valid out, done out (1 when the structure's type is one of these, else nothing is
*>     touched): builds the pieces in the builder (SPB-RESET first)
*>   STRUCT-IGLOO-PIECES USING x0, z0, rotation; STRUCT-SHIPWRECK-PIECE USING structure row, heightmap kind, x0, z0, rotation, valid: the pieces of one start, called by STRUCT-TPL-FIND-POINT
*>   STRUCT-TPL-AFTER USING row, result: the end of postProcess of a template piece with a hook (the igloo's snow block, and the restore of its position); STRUCT-TPL-PRE is in struct-tpl-piece.cob


 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-TPL-FIND-POINT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 01 WS-KIND-TYPE           BINARY-LONG VALUE 1.
 01 WS-NAME                PIC X(40).
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-HEIGHTMAP           BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-ROT                 BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-STRUCT               BINARY-LONG.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STRUCT L-SEED L-CX L-CZ L-X L-Y L-Z L-VALID L-DONE.
     CALL "STRUCT-ENUM-NAME" USING WS-KIND-TYPE SDT-TYPE(L-STRUCT) WS-NAME
     MOVE 1 TO L-DONE
     EVALUATE WS-NAME
         WHEN "igloo"
             MOVE 0 TO WS-HEIGHTMAP
         WHEN "shipwreck"
             COMPUTE WS-HEIGHTMAP = 1 - SDT-VARIANT(L-STRUCT)
         WHEN "ocean_ruin"
             MOVE 1 TO WS-HEIGHTMAP
         WHEN OTHER
             MOVE 0 TO L-DONE
             GOBACK
     END-EVALUATE
     CALL "SPB-RESET"
     COMPUTE WS-USEED = FUNCTION MOD(L-SEED + WS-M64, WS-M64)
     CALL "JRAND-LARGE-FEATURE-SEED" USING SP-RNG WS-USEED L-CX L-CZ
*>   onTopOfChunkCenter: the stub is the top block of the chunk centre's column
     COMPUTE L-X = L-CX * 16 + 8
     COMPUTE L-Z = L-CZ * 16 + 8
     CALL "STRUCT-BASE-HEIGHT" USING L-X L-Z WS-HEIGHTMAP WS-H
     COMPUTE L-Y = WS-H - 1
     MOVE 1 TO L-VALID
     COMPUTE WS-X0 = L-CX * 16
     COMPUTE WS-Z0 = L-CZ * 16
     MOVE 4 TO WS-BOUND
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-ROT
     EVALUATE WS-NAME
         WHEN "igloo"
             CALL "STRUCT-IGLOO-PIECES" USING WS-X0 WS-Z0 WS-ROT
         WHEN "ocean_ruin"
*>           36-6 3.2: the piece generator (struct-ruin.cob); a start whose templates are absent has no piece and is invalid
             CALL "STRUCT-RUIN-PIECES" USING L-STRUCT WS-X0 WS-Z0 WS-ROT
             IF SP-COUNT = 0
                 MOVE 0 TO L-VALID
             END-IF
         WHEN OTHER
             CALL "STRUCT-SHIPWRECK-PIECE" USING L-STRUCT WS-HEIGHTMAP WS-X0 WS-Z0 WS-ROT L-VALID
     END-EVALUATE
     GOBACK.
 END PROGRAM STRUCT-TPL-FIND-POINT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-IGLOO-PIECES.
*> IglooPieces.addPieces (36-4 6.1) after the rotation draw: a basement (the laboratory, n - 1 ladders) when nextDouble() < 0.5, n = nextInt(8) + 4, then the top; per piece the template of
*> 6.2 (position offsets are world-axis offsets, not rotated; the rotation pivot is the table's) and the code-defined processor list of the igloo.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY STRUCTDATA.
 01 WS-PROC-KEY            PIC X(80) VALUE "cobolcraft:inline/ignore_structure_block".
 01 WS-PROC                BINARY-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-DEPTH               BINARY-LONG.
 LINKAGE SECTION.
 01 L-X0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-X0 L-Z0 L-ROT.
     CALL "STRUCT-PROC-LOAD" USING WS-PROC-KEY WS-PROC
     CALL "STRUCT-NEXT-DOUBLE" USING SP-RNG WS-R
     IF WS-R < 0.5
         MOVE 8 TO WS-BOUND
         CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-DRAW
         COMPUTE WS-N = WS-DRAW + 4
         COMPUTE WS-DEPTH = WS-N * 3
         MOVE 3 TO WS-KIND
         CALL "STRUCT-IGLOO-ADD" USING L-X0 L-Z0 L-ROT WS-KIND WS-DEPTH WS-PROC
         COMPUTE WS-DRAW = WS-N - 2
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > WS-DRAW
             COMPUTE WS-DEPTH = WS-I * 3
             MOVE 2 TO WS-KIND
             CALL "STRUCT-IGLOO-ADD" USING L-X0 L-Z0 L-ROT WS-KIND WS-DEPTH WS-PROC
         END-PERFORM
     END-IF
     MOVE 0 TO WS-DEPTH
     MOVE 1 TO WS-KIND
     CALL "STRUCT-IGLOO-ADD" USING L-X0 L-Z0 L-ROT WS-KIND WS-DEPTH WS-PROC
     GOBACK.
 END PROGRAM STRUCT-IGLOO-PIECES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-IGLOO-ADD.
*> USING x0, z0, rotation, template kind (1 top, 2 middle, 3 bottom), depth offset, processor list: one igloo piece at (x0, 90, z0) plus the offset of 36-4 6.2, minus the depth.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 COPY STRUCTTPL.
 01 WS-ID                  PIC X(96).
 01 WS-ROW                 BINARY-LONG.
 01 WS-GX                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-GZ                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-PIECE               BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-LIQUID              BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-X0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-DEPTH                BINARY-LONG.
 01 L-PROC                 BINARY-LONG.
 PROCEDURE DIVISION USING L-X0 L-Z0 L-ROT L-KIND L-DEPTH L-PROC.
     EVALUATE L-KIND
         WHEN 1
             MOVE "minecraft:igloo/top" TO WS-ID
             MOVE L-X0 TO WS-GX
             MOVE 90 TO WS-GY
             MOVE L-Z0 TO WS-GZ
             MOVE 3 TO WS-PX
             MOVE 5 TO WS-PY
             MOVE 5 TO WS-PZ
         WHEN 2
             MOVE "minecraft:igloo/middle" TO WS-ID
             COMPUTE WS-GX = L-X0 + 2
             COMPUTE WS-GY = 90 - 3 - L-DEPTH
             COMPUTE WS-GZ = L-Z0 + 4
             MOVE 1 TO WS-PX
             MOVE 3 TO WS-PY
             MOVE 1 TO WS-PZ
         WHEN OTHER
             MOVE "minecraft:igloo/bottom" TO WS-ID
             MOVE L-X0 TO WS-GX
             COMPUTE WS-GY = 90 - 3 - L-DEPTH
             COMPUTE WS-GZ = L-Z0 - 2
             MOVE 3 TO WS-PX
             MOVE 6 TO WS-PY
             MOVE 7 TO WS-PZ
     END-EVALUATE
     CALL "STRUCT-TPL-LOAD" USING SD-DIR WS-ID WS-ROW
     CALL "STRUCT-TPL-PIECE-ADD" USING WS-ONE WS-ROW WS-GX WS-GY WS-GZ L-ROT WS-ZERO WS-PX WS-PY WS-PZ L-PROC WS-LIQUID L-KIND WS-PIECE
     GOBACK.
 END PROGRAM STRUCT-IGLOO-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-SHIPWRECK-PIECE.
*> USING structure row, heightmap kind (0 WORLD_SURFACE_WG for a beached wreck, 1 OCEAN_FLOOR_WG), x0, z0, rotation, valid out: ShipwreckStructure (36-6 4.2, 4.3) after the rotation draw: a template of the
*> list (11 beached, 20 ocean) at (minX, adjusted y, minZ), the height of the one-time adjustment from the base heights of the unrotated footprint. The sum and the lowest height of a footprint
*> are remembered by position, template and heightmap (a start is rebuilt for every chunk near it), for one world.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 COPY STRUCTTPL.
 COPY CTWORLDGEN.
 COPY NOISE.
 01 WS-STAMP               BINARY-LONG VALUE -1.
 01 WS-STAMP-NOW           BINARY-LONG.
 01 WS-PROC-KEY            PIC X(80) VALUE "cobolcraft:inline/ignore_structure_and_air".
 01 WS-PROC                BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-ID                  PIC X(96).
 01 WS-ROW                 BINARY-LONG.
 01 WS-PIECE               BINARY-LONG.
 01 WS-SUM                 BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-AREA                BINARY-LONG.
 01 WS-GX                  BINARY-LONG.
 01 WS-GZ                  BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-PX                  BINARY-LONG VALUE 4.
 01 WS-PY                  BINARY-LONG VALUE 0.
 01 WS-PZ                  BINARY-LONG VALUE 15.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-LIQUID              BINARY-LONG VALUE 0.
 01 WS-AUX                 BINARY-LONG VALUE 0.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-FOUND               BINARY-LONG.
 01 WS-MEMO-NEXT           BINARY-LONG VALUE 0.
 01 WS-MEMO.
    05 WS-MEMO-ENTRY OCCURS 16 TIMES.
       10 WS-M-USED        BINARY-LONG VALUE 0.
       10 WS-M-X           BINARY-LONG.
       10 WS-M-Z           BINARY-LONG.
       10 WS-M-ROW         BINARY-LONG.
       10 WS-M-MAP         BINARY-LONG.
       10 WS-M-SUM         BINARY-LONG.
       10 WS-M-LOW         BINARY-LONG.
*> the shipwreck lists (36-6 4.1)
 01 WS-OCEAN-NAMES.
    05 FILLER              PIC X(32) VALUE "with_mast".
    05 FILLER              PIC X(32) VALUE "upsidedown_full".
    05 FILLER              PIC X(32) VALUE "upsidedown_fronthalf".
    05 FILLER              PIC X(32) VALUE "upsidedown_backhalf".
    05 FILLER              PIC X(32) VALUE "sideways_full".
    05 FILLER              PIC X(32) VALUE "sideways_fronthalf".
    05 FILLER              PIC X(32) VALUE "sideways_backhalf".
    05 FILLER              PIC X(32) VALUE "rightsideup_full".
    05 FILLER              PIC X(32) VALUE "rightsideup_fronthalf".
    05 FILLER              PIC X(32) VALUE "rightsideup_backhalf".
    05 FILLER              PIC X(32) VALUE "with_mast_degraded".
    05 FILLER              PIC X(32) VALUE "upsidedown_full_degraded".
    05 FILLER              PIC X(32) VALUE "upsidedown_fronthalf_degraded".
    05 FILLER              PIC X(32) VALUE "upsidedown_backhalf_degraded".
    05 FILLER              PIC X(32) VALUE "sideways_full_degraded".
    05 FILLER              PIC X(32) VALUE "sideways_fronthalf_degraded".
    05 FILLER              PIC X(32) VALUE "sideways_backhalf_degraded".
    05 FILLER              PIC X(32) VALUE "rightsideup_full_degraded".
    05 FILLER              PIC X(32) VALUE "rightsideup_fronthalf_degraded".
    05 FILLER              PIC X(32) VALUE "rightsideup_backhalf_degraded".
 01 WS-OCEAN-TABLE REDEFINES WS-OCEAN-NAMES.
    05 WS-OCEAN            PIC X(32) OCCURS 20 TIMES.
 01 WS-BEACHED-NAMES.
    05 FILLER              PIC X(32) VALUE "with_mast".
    05 FILLER              PIC X(32) VALUE "sideways_full".
    05 FILLER              PIC X(32) VALUE "sideways_fronthalf".
    05 FILLER              PIC X(32) VALUE "sideways_backhalf".
    05 FILLER              PIC X(32) VALUE "rightsideup_full".
    05 FILLER              PIC X(32) VALUE "rightsideup_fronthalf".
    05 FILLER              PIC X(32) VALUE "rightsideup_backhalf".
    05 FILLER              PIC X(32) VALUE "with_mast_degraded".
    05 FILLER              PIC X(32) VALUE "rightsideup_full_degraded".
    05 FILLER              PIC X(32) VALUE "rightsideup_fronthalf_degraded".
    05 FILLER              PIC X(32) VALUE "rightsideup_backhalf_degraded".
 01 WS-BEACHED-TABLE REDEFINES WS-BEACHED-NAMES.
    05 WS-BEACH            PIC X(32) OCCURS 11 TIMES.
 LINKAGE SECTION.
 01 L-STRUCT               BINARY-LONG.
 01 L-MAP                  BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING L-STRUCT L-MAP L-X0 L-Z0 L-ROT L-VALID.
     CALL "STRUCT-PROC-LOAD" USING WS-PROC-KEY WS-PROC
*>   the remembered heights belong to one world (the content and noise generation of STRUCT-BASE-HEIGHT)
     COMPUTE WS-STAMP-NOW = WG-LOAD-GEN + NZ-GEN
     IF WS-STAMP-NOW NOT = WS-STAMP
         MOVE WS-STAMP-NOW TO WS-STAMP
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
             MOVE 0 TO WS-M-USED(WS-I)
         END-PERFORM
     END-IF
     IF SDT-VARIANT(L-STRUCT) = 1
         MOVE 11 TO WS-BOUND
     ELSE
         MOVE 20 TO WS-BOUND
     END-IF
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-DRAW
     MOVE SPACES TO WS-ID
     IF SDT-VARIANT(L-STRUCT) = 1
         STRING "minecraft:shipwreck/" FUNCTION TRIM(WS-BEACH(WS-DRAW + 1)) DELIMITED BY SIZE INTO WS-ID
     ELSE
         STRING "minecraft:shipwreck/" FUNCTION TRIM(WS-OCEAN(WS-DRAW + 1)) DELIMITED BY SIZE INTO WS-ID
     END-IF
     CALL "STRUCT-TPL-LOAD" USING SD-DIR WS-ID WS-ROW
     IF TP-STATUS(WS-ROW) NOT = 1
         MOVE 0 TO L-VALID
         GOBACK
     END-IF
     COMPUTE WS-AREA = TP-SX(WS-ROW) * TP-SZ(WS-ROW)
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16 OR WS-FOUND = 1
         IF WS-M-USED(WS-I) = 1 AND WS-M-X(WS-I) = L-X0 AND WS-M-Z(WS-I) = L-Z0 AND WS-M-ROW(WS-I) = WS-ROW AND WS-M-MAP(WS-I) = L-MAP
             MOVE WS-I TO WS-FOUND
             MOVE WS-M-SUM(WS-I) TO WS-SUM
             MOVE WS-M-LOW(WS-I) TO WS-LOW
         END-IF
     END-PERFORM
     IF WS-FOUND = 0
         MOVE 0 TO WS-SUM
         MOVE 1000 TO WS-LOW
         PERFORM VARYING WS-GZ FROM L-Z0 BY 1 UNTIL WS-GZ >= L-Z0 + TP-SZ(WS-ROW)
             PERFORM VARYING WS-GX FROM L-X0 BY 1 UNTIL WS-GX >= L-X0 + TP-SX(WS-ROW)
                 CALL "STRUCT-BASE-HEIGHT" USING WS-GX WS-GZ L-MAP WS-H
                 ADD WS-H TO WS-SUM
                 IF WS-H < WS-LOW
                     MOVE WS-H TO WS-LOW
                 END-IF
             END-PERFORM
         END-PERFORM
         COMPUTE WS-I = FUNCTION MOD(WS-MEMO-NEXT, 16) + 1
         ADD 1 TO WS-MEMO-NEXT
         MOVE 1 TO WS-M-USED(WS-I)
         MOVE L-X0 TO WS-M-X(WS-I)
         MOVE L-Z0 TO WS-M-Z(WS-I)
         MOVE WS-ROW TO WS-M-ROW(WS-I)
         MOVE L-MAP TO WS-M-MAP(WS-I)
         MOVE WS-SUM TO WS-M-SUM(WS-I)
         MOVE WS-LOW TO WS-M-LOW(WS-I)
     END-IF
     IF SDT-VARIANT(L-STRUCT) = 1
         MOVE 3 TO WS-BOUND
         CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-DRAW
         COMPUTE WS-N = TP-SY(WS-ROW) / 2
         COMPUTE WS-Y = WS-LOW - WS-N - WS-DRAW
     ELSE
         COMPUTE WS-Y = WS-SUM / WS-AREA
     END-IF
     CALL "STRUCT-TPL-PIECE-ADD" USING WS-TWO WS-ROW L-X0 WS-Y L-Z0 L-ROT WS-ZERO WS-PX WS-PY WS-PZ WS-PROC WS-LIQUID WS-AUX WS-PIECE
     GOBACK.
 END PROGRAM STRUCT-SHIPWRECK-PIECE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-TPL-AFTER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY CBLOCKS.
 01 WS-KEY                 PIC X(48) VALUE "minecraft:snow_block".
 01 WS-SNOW                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-LADDER              BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-FIVE                BINARY-LONG VALUE 5.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-RESULT.
     IF SP-T-KIND(L-ROW) = 1
*>       36-4 6.3 step 5: the top piece puts snow where the block under its door cell is neither air nor a ladder
         IF L-RESULT = 1 AND SP-T-AUX(L-ROW) = 1
             CALL "STRUCT-TX-POS" USING WS-THREE WS-ZERO WS-FIVE SP-T-MIR(L-ROW) SP-T-ROT(L-ROW) SP-T-PIV-X(L-ROW) SP-T-PIV-Z(L-ROW) WS-OX WS-OY WS-OZ
             COMPUTE WS-X = SP-T-X(L-ROW) + WS-OX
             COMPUTE WS-Y = SP-T-Y(L-ROW) + WS-OY
             COMPUTE WS-Z = SP-T-Z(L-ROW) + WS-OZ
             COMPUTE WS-BELOW = WS-Y - 1
             CALL "FL-GET-STATE" USING WS-X WS-BELOW WS-Z WS-STATE
             CALL "FL-CLASS" USING WS-STATE WS-CLASS
             CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
             MOVE 0 TO WS-LADDER
             IF WS-BLOCK > 0
                 IF CB-KEY(WS-BLOCK) = "ladder"
                     MOVE 1 TO WS-LADDER
                 END-IF
             END-IF
             IF WS-CLASS NOT = 1 AND WS-LADDER = 0
                 CALL "GEN-BLOCK-STATE" USING WS-KEY WS-SNOW
                 CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-SNOW WS-FLAGS WS-OK
             END-IF
         END-IF
*>       step 6: the saved position is back
         MOVE SP-F1(L-ROW) TO SP-T-Y(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM STRUCT-TPL-AFTER.
