*> The ocean ruins (docs/protocol/36-structures-6 section 3, OceanRuinStructure and OceanRuinPieces): the start (rotation, the large draw, the template choice, the three pieces of a cold ruin,
*> the cluster of small ruins around a large one), the code-defined processor lists (rot, block_ignore, the capped archaeology rule), the adapted height of a piece and the two data markers.
*> The pieces are template pieces of kind 3 (struct-tpl-piece.cob: SP-T-AUX is isLarge); the structure is built by STRUCT-TPL-FIND-POINT (struct-tpl-gen.cob).
*>
*> Deviations: (1) the height of a piece (3.5 steps 1 to 3) is computed from STRUCT-BASE-HEIGHT (OCEAN_FLOOR_WG, the noise terrain alone) instead of the live heightmap and live blocks,
*> so that it is the same in every chunk pass of the start: a column is solid up to its top (the first free y minus one) and everything above it is taken as air or water (ice, which
*> the document's loop also steps through, is placed after the surface structures; a cave or a carver under the anchor is not seen). (2) The drowned of the marker is not made (no entity
*> channel); the block it leaves (air above the sea level, else water) is. (3) 3.6 step 6 "if the candidate list is empty do nothing" cannot happen (at most eight draws of the count for
*> eight candidates) and is not coded.
*>
*> Entry points:
*>   STRUCT-RUIN-LIST-JSON USING key (PIC X(80)), text out (PIC X(65536)), status out (0 the JSON of the list, 1 not a ruin list): the key is cobolcraft:inline/ruin/<w or c>/<tenths of
*>     the integrity>: block_rot(integrity), block_ignore(air, structure_block), capped(5, rule: sand -> suspicious_sand for warm, gravel -> suspicious_gravel for cold, append_loot of
*>     archaeology/ocean_ruin_warm or _cold)
*>   STRUCT-RUIN-HEIGHT USING x, z (the template position), rotation, size x, size z, y out: the template position's y after steps 1 to 3 (remembered by footprint for one world)
*>   STRUCT-RUIN-PIECES USING structure row, x0, z0 (the chunk's minimum corner), rotation: addPieces (3.3), after the start's rotation draw
*>   STRUCT-RUIN-PRE USING row: the height before each placement (STRUCT-TPL-PRE); STRUCT-RUIN-MARKER USING row, metadata, x, y, z: handleDataMarker (3.5)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-RUIN-LIST-JSON.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-INPUT               PIC X(8).
 01 WS-OUTPUT              PIC X(8).
 01 WS-TEMP                PIC X(4).
 LINKAGE SECTION.
 01 L-KEY                  PIC X(80).
 01 L-TEXT                 PIC X(65536).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-TEXT L-STATUS.
     MOVE 1 TO L-STATUS
     IF L-KEY(1:23) NOT = "cobolcraft:inline/ruin/" OR L-KEY(25:1) NOT = "/" OR L-KEY(26:1) NOT NUMERIC OR L-KEY(27:54) NOT = SPACES
         GOBACK
     END-IF
     EVALUATE L-KEY(24:1)
         WHEN "w"
             MOVE "sand" TO WS-INPUT
             MOVE "sand" TO WS-OUTPUT
             MOVE "warm" TO WS-TEMP
         WHEN "c"
             MOVE "gravel" TO WS-INPUT
             MOVE "gravel" TO WS-OUTPUT
             MOVE "cold" TO WS-TEMP
         WHEN OTHER
             GOBACK
     END-EVALUATE
     MOVE SPACES TO L-TEXT
     STRING '{"processors":[{"processor_type":"minecraft:block_rot","integrity":0.' L-KEY(26:1) '},'
         '{"processor_type":"minecraft:block_ignore","blocks":["minecraft:air","minecraft:structure_block"]},'
         '{"processor_type":"minecraft:capped","limit":5,"delegate":{"processor_type":"minecraft:rule","rules":['
         '{"input_predicate":{"predicate_type":"minecraft:block_match","block":"minecraft:' FUNCTION TRIM(WS-INPUT) '"},'
         '"location_predicate":{"predicate_type":"minecraft:always_true"},'
         '"output_state":"minecraft:suspicious_' FUNCTION TRIM(WS-OUTPUT) '",'
         '"block_entity_modifier":{"type":"minecraft:append_loot","loot_table":"minecraft:archaeology/ocean_ruin_' FUNCTION TRIM(WS-TEMP) '"}}]}}]}'
         DELIMITED BY SIZE INTO L-TEXT
     MOVE 0 TO L-STATUS
     GOBACK.
 END PROGRAM STRUCT-RUIN-LIST-JSON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-RUIN-ROT.
*> USING x, z, rotation, x out, z out: transform((x, 0, z), NONE, rotation, (0, 0, 0)) of 2.2 (the block position transform with the pivot at zero).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Y                   BINARY-LONG VALUE 0.
 01 WS-MIRROR              BINARY-LONG VALUE 0.
 01 WS-PX                  BINARY-LONG VALUE 0.
 01 WS-PZ                  BINARY-LONG VALUE 0.
 01 WS-OY                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Z L-ROT L-OX L-OZ.
     CALL "STRUCT-TX-POS" USING L-X WS-Y L-Z WS-MIRROR L-ROT WS-PX WS-PZ L-OX WS-OY L-OZ
     GOBACK.
 END PROGRAM STRUCT-RUIN-ROT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-RUIN-HEIGHT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTWORLDGEN.
 COPY NOISE.
 01 WS-STAMP               BINARY-LONG VALUE -1.
 01 WS-STAMP-NOW           BINARY-LONG.
 01 WS-MEMO-NEXT           BINARY-LONG VALUE 0.
 01 WS-MEMO.
    05 WS-MEMO-ENTRY OCCURS 64 TIMES.
       10 WS-M-USED        BINARY-LONG VALUE 0.
       10 WS-M-X           BINARY-LONG.
       10 WS-M-Z           BINARY-LONG.
       10 WS-M-ROT         BINARY-LONG.
       10 WS-M-SX          BINARY-LONG.
       10 WS-M-SZ          BINARY-LONG.
       10 WS-M-Y           BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-SXM                 BINARY-LONG.
 01 WS-SZM                 BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-LOWEST              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-XX                  BINARY-LONG.
 01 WS-ZZ                  BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 01 L-SX                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Z L-ROT L-SX L-SZ L-Y.
*>   the remembered heights belong to one world (the content and noise generation of STRUCT-BASE-HEIGHT)
     COMPUTE WS-STAMP-NOW = WG-LOAD-GEN + NZ-GEN
     IF WS-STAMP-NOW NOT = WS-STAMP
         MOVE WS-STAMP-NOW TO WS-STAMP
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64
             MOVE 0 TO WS-M-USED(WS-I)
         END-PERFORM
     END-IF
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64 OR WS-FOUND = 1
         IF WS-M-USED(WS-I) = 1 AND WS-M-X(WS-I) = L-X AND WS-M-Z(WS-I) = L-Z AND WS-M-ROT(WS-I) = L-ROT
            AND WS-M-SX(WS-I) = L-SX AND WS-M-SZ(WS-I) = L-SZ
             MOVE 1 TO WS-FOUND
             MOVE WS-M-Y(WS-I) TO L-Y
         END-IF
     END-PERFORM
     IF WS-FOUND = 1
         GOBACK
     END-IF
*>   step 1: the heightmap value of the anchor column; step 2: the far corner of the rotated footprint (2.2, pivot 0 0)
     CALL "STRUCT-BASE-HEIGHT" USING L-X L-Z WS-ONE WS-H
     COMPUTE WS-SXM = L-SX - 1
     COMPUTE WS-SZM = L-SZ - 1
     CALL "STRUCT-RUIN-ROT" USING WS-SXM WS-SZM L-ROT WS-OX WS-OZ
     COMPUTE WS-X0 = FUNCTION MIN(L-X, L-X + WS-OX)
     COMPUTE WS-X1 = FUNCTION MAX(L-X, L-X + WS-OX)
     COMPUTE WS-Z0 = FUNCTION MIN(L-Z, L-Z + WS-OZ)
     COMPUTE WS-Z1 = FUNCTION MAX(L-Z, L-Z + WS-OZ)
*>   step 3: getHeight over the rectangle (3.5): the first solid block under the anchor's floor, at least one above the world's bottom + 1
     COMPUTE WS-BASE = WS-H - 1
     MOVE 512 TO WS-LOWEST
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-ZZ FROM WS-Z0 BY 1 UNTIL WS-ZZ > WS-Z1
         PERFORM VARYING WS-XX FROM WS-X0 BY 1 UNTIL WS-XX > WS-X1
             CALL "STRUCT-BASE-HEIGHT" USING WS-XX WS-ZZ WS-ONE WS-Y
             COMPUTE WS-Y = FUNCTION MAX(FUNCTION MIN(WS-BASE, WS-Y - 1), -63)
             MOVE FUNCTION MIN(WS-LOWEST, WS-Y) TO WS-LOWEST
             IF WS-Y < WS-BASE - 2
                 ADD 1 TO WS-COUNT
             END-IF
         END-PERFORM
     END-PERFORM
     COMPUTE WS-DX = WS-X1 - WS-X0
     MOVE WS-H TO L-Y
     IF WS-BASE - WS-LOWEST > 2 AND WS-COUNT > WS-DX - 2
         COMPUTE L-Y = WS-LOWEST + 1
     END-IF
     COMPUTE WS-I = FUNCTION MOD(WS-MEMO-NEXT, 64) + 1
     ADD 1 TO WS-MEMO-NEXT
     MOVE 1 TO WS-M-USED(WS-I)
     MOVE L-X TO WS-M-X(WS-I)
     MOVE L-Z TO WS-M-Z(WS-I)
     MOVE L-ROT TO WS-M-ROT(WS-I)
     MOVE L-SX TO WS-M-SX(WS-I)
     MOVE L-SZ TO WS-M-SZ(WS-I)
     MOVE L-Y TO WS-M-Y(WS-I)
     GOBACK.
 END PROGRAM STRUCT-RUIN-HEIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-RUIN-PRE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY STRUCTTPL.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "STRUCT-RUIN-HEIGHT" USING SP-T-X(L-ROW) SP-T-Z(L-ROW) SP-T-ROT(L-ROW) TP-SX(SP-T-ROW(L-ROW)) TP-SZ(SP-T-ROW(L-ROW)) SP-T-Y(L-ROW)
     GOBACK.
 END PROGRAM STRUCT-RUIN-PRE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-RUIN-ADD.
*> USING x, z (the anchor), rotation, large (0 or 1), integrity (tenths), warm (1 or 0), template index (0-based, the draw): one piece of the ruin (3.4), or the three of a cold ruin: the
*> template of the list (warm, brick, cracked, mossy; small or big) at (x, 90, z) with the processor list of its integrity.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 01 WS-NUMBERS             PIC X(4) VALUE "1238".
 01 WS-KIND-NAMES.
    05 FILLER              PIC X(8) VALUE "brick".
    05 FILLER              PIC X(8) VALUE "cracked".
    05 FILLER              PIC X(8) VALUE "mossy".
 01 WS-KIND-TABLE REDEFINES WS-KIND-NAMES.
    05 WS-KIND-NAME        PIC X(8) OCCURS 3 TIMES.
 01 WS-STEP                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-NUMBER              PIC 9.
 01 WS-NAME                PIC X(8).
 01 WS-INT                 PIC 9.
 01 WS-TEMP                PIC X.
 01 WS-ID                  PIC X(96).
 01 WS-KEY                 PIC X(80).
 01 WS-ROW                 BINARY-LONG.
 01 WS-LIST                BINARY-LONG.
 01 WS-PIECE               BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 3.
 01 WS-Y                   BINARY-LONG VALUE 90.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-Z3                  BINARY-LONG VALUE 0.
 01 WS-Z4                  BINARY-LONG VALUE 0.
 01 WS-Z5                  BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 01 L-LARGE                BINARY-LONG.
 01 L-INTEGRITY            BINARY-LONG.
 01 L-WARM                 BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Z L-ROT L-LARGE L-INTEGRITY L-WARM L-INDEX.
     IF L-WARM = 1
         MOVE "w" TO WS-TEMP
         MOVE 1 TO WS-N
     ELSE
         MOVE "c" TO WS-TEMP
         MOVE 3 TO WS-N
     END-IF
*>   the number of the template: 1 to 8 of a small list, the big lists hold 4 to 7 (warm) or 1, 2, 3, 8 (cold)
     COMPUTE WS-NUMBER = L-INDEX + 1
     IF L-LARGE = 1 AND L-WARM = 1
         COMPUTE WS-NUMBER = L-INDEX + 4
     END-IF
     IF L-LARGE = 1 AND L-WARM = 0
         MOVE WS-NUMBERS(L-INDEX + 1:1) TO WS-NUMBER
     END-IF
     PERFORM VARYING WS-STEP FROM 0 BY 1 UNTIL WS-STEP >= WS-N
         EVALUATE WS-STEP
             WHEN 0
                 MOVE L-INTEGRITY TO WS-INT
             WHEN 1
                 MOVE 7 TO WS-INT
             WHEN OTHER
                 MOVE 5 TO WS-INT
         END-EVALUATE
         MOVE "warm" TO WS-NAME
         IF L-WARM = 0
             MOVE WS-KIND-NAME(WS-STEP + 1) TO WS-NAME
         END-IF
         MOVE SPACES TO WS-ID
         IF L-LARGE = 1
             STRING "minecraft:underwater_ruin/big_" FUNCTION TRIM(WS-NAME) "_" WS-NUMBER DELIMITED BY SIZE INTO WS-ID
         ELSE
             STRING "minecraft:underwater_ruin/" FUNCTION TRIM(WS-NAME) "_" WS-NUMBER DELIMITED BY SIZE INTO WS-ID
         END-IF
         MOVE SPACES TO WS-KEY
         STRING "cobolcraft:inline/ruin/" WS-TEMP "/" WS-INT DELIMITED BY SIZE INTO WS-KEY
         CALL "STRUCT-PROC-LOAD" USING WS-KEY WS-LIST
         CALL "STRUCT-TPL-LOAD" USING SD-DIR WS-ID WS-ROW
         CALL "STRUCT-TPL-PIECE-ADD" USING WS-KIND WS-ROW L-X WS-Y L-Z L-ROT WS-ZERO WS-Z2 WS-Z3 WS-Z4 WS-LIST WS-Z5 L-LARGE WS-PIECE
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-RUIN-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-RUIN-DRAW.
*> USING lo, hi, value out: Mth.nextInt(r, lo, hi) of the start random (2.1) for lo < hi: nextInt(hi - lo + 1) + lo.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-BOUND               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 LINKAGE SECTION.
 01 L-LO                   BINARY-LONG.
 01 L-HI                   BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-LO L-HI L-VALUE.
     COMPUTE WS-BOUND = L-HI - L-LO + 1
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-DRAW
     COMPUTE L-VALUE = WS-DRAW + L-LO
     GOBACK.
 END PROGRAM STRUCT-RUIN-DRAW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-RUIN-CLUSTER.
*> USING warm, x, z (the main ruin's anchor), rotation: addClusterRuins (3.6): eight candidate anchors around the main ruin's lowest corner (all sixteen offsets drawn in the order of the table),
*> then nextInt(4, 8) repetitions, each taking a random candidate and a random rotation and adding a small ruin (integrity 0.8) unless its box meets the main ruin's.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
*> the offsets of the candidates: x offset, its draw range, z offset, its draw range
 01 WS-OFFSETS.
    05 FILLER              PIC X(24) VALUE "-16+01+08+16+01+07      ".
    05 FILLER              PIC X(24) VALUE "-16+01+08+00+01+07      ".
    05 FILLER              PIC X(24) VALUE "-16+01+08-16+04+08      ".
    05 FILLER              PIC X(24) VALUE "+00+01+07+16+01+07      ".
    05 FILLER              PIC X(24) VALUE "+00+01+07-16+04+06      ".
    05 FILLER              PIC X(24) VALUE "+16+01+07+16+03+08      ".
    05 FILLER              PIC X(24) VALUE "+16+01+07+00+01+07      ".
    05 FILLER              PIC X(24) VALUE "+16+01+07-16+04+08      ".
 01 WS-OFFSET-TABLE REDEFINES WS-OFFSETS.
    05 WS-OFF OCCURS 8 TIMES.
       10 WS-OX            PIC S99 SIGN LEADING SEPARATE.
       10 WS-OX-LO         PIC S99 SIGN LEADING SEPARATE.
       10 WS-OX-HI         PIC S99 SIGN LEADING SEPARATE.
       10 WS-OZ            PIC S99 SIGN LEADING SEPARATE.
       10 WS-OZ-LO         PIC S99 SIGN LEADING SEPARATE.
       10 WS-OZ-HI         PIC S99 SIGN LEADING SEPARATE.
       10 FILLER           PIC X(6).
 01 WS-CAND.
    05 WS-C OCCURS 8 TIMES.
       10 WS-CX            BINARY-LONG.
       10 WS-CZ            BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-ROT                 BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-A                   BINARY-LONG VALUE 15.
 01 WS-A2                  BINARY-LONG VALUE 15.
 01 WS-B                   BINARY-LONG VALUE 6.
 01 WS-FIVE                BINARY-LONG VALUE 5.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-MX0                 BINARY-LONG.
 01 WS-MZ0                 BINARY-LONG.
 01 WS-MX1                 BINARY-LONG.
 01 WS-MZ1                 BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-LARGE               BINARY-LONG VALUE 0.
 01 WS-INTEGRITY           BINARY-LONG VALUE 8.
 LINKAGE SECTION.
 01 L-WARM                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-WARM L-X L-Z L-ROT.
     CALL "STRUCT-RUIN-ROT" USING WS-A WS-A2 L-ROT WS-DX WS-DZ
     COMPUTE WS-MX0 = FUNCTION MIN(L-X, L-X + WS-DX)
     COMPUTE WS-MZ0 = FUNCTION MIN(L-Z, L-Z + WS-DZ)
     COMPUTE WS-MX1 = FUNCTION MAX(L-X, L-X + WS-DX)
     COMPUTE WS-MZ1 = FUNCTION MAX(L-Z, L-Z + WS-DZ)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         MOVE WS-OX-LO(WS-I) TO WS-LO
         MOVE WS-OX-HI(WS-I) TO WS-HI
         CALL "STRUCT-RUIN-DRAW" USING WS-LO WS-HI WS-DRAW
         COMPUTE WS-CX(WS-I) = WS-MX0 + WS-OX(WS-I) + WS-DRAW
         MOVE WS-OZ-LO(WS-I) TO WS-LO
         MOVE WS-OZ-HI(WS-I) TO WS-HI
         CALL "STRUCT-RUIN-DRAW" USING WS-LO WS-HI WS-DRAW
         COMPUTE WS-CZ(WS-I) = WS-MZ0 + WS-OZ(WS-I) + WS-DRAW
     END-PERFORM
     MOVE 4 TO WS-LO
     MOVE 8 TO WS-HI
     CALL "STRUCT-RUIN-DRAW" USING WS-LO WS-HI WS-N
     MOVE 8 TO WS-LEFT
     PERFORM WS-N TIMES
         CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-LEFT WS-DRAW
         COMPUTE WS-K = WS-DRAW + 1
         MOVE WS-CX(WS-K) TO WS-BX
         MOVE WS-CZ(WS-K) TO WS-BZ
         PERFORM VARYING WS-I FROM WS-K BY 1 UNTIL WS-I >= WS-LEFT
             MOVE WS-C(WS-I + 1) TO WS-C(WS-I)
         END-PERFORM
         SUBTRACT 1 FROM WS-LEFT
         MOVE 4 TO WS-BOUND
         CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-ROT
         CALL "STRUCT-RUIN-ROT" USING WS-FIVE WS-B WS-ROT WS-DX WS-DZ
*>       the box of the candidate meets the main ruin's (both are one layer at y 90): the repetition ends
         IF FUNCTION MIN(WS-BX, WS-BX + WS-DX) <= WS-MX1 AND FUNCTION MAX(WS-BX, WS-BX + WS-DX) >= WS-MX0
            AND FUNCTION MIN(WS-BZ, WS-BZ + WS-DZ) <= WS-MZ1 AND FUNCTION MAX(WS-BZ, WS-BZ + WS-DZ) >= WS-MZ0
             CONTINUE
         ELSE
             MOVE 8 TO WS-BOUND
             CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-DRAW
             CALL "STRUCT-RUIN-ADD" USING WS-BX WS-BZ WS-ROT WS-LARGE WS-INTEGRITY L-WARM WS-DRAW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-RUIN-CLUSTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-RUIN-PIECES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 01 WS-U                   FLOAT-LONG.
 01 WS-LARGE               BINARY-LONG.
 01 WS-INTEGRITY           BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 LINKAGE SECTION.
 01 L-STRUCT               BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-STRUCT L-X0 L-Z0 L-ROT.
*>   3.3: isLarge = nextFloat() <= large_probability (note less than or equal), integrity 0.9 or 0.8
     CALL "JRAND-NEXT-FLOAT" USING SP-RNG WS-U
     MOVE 0 TO WS-LARGE
     MOVE 8 TO WS-INTEGRITY
     IF WS-U <= SDT-LARGE(L-STRUCT)
         MOVE 1 TO WS-LARGE
         MOVE 9 TO WS-INTEGRITY
     END-IF
*>   3.4: the template index is drawn from the list of 4 (big) or 8 (small) entries
     MOVE 8 TO WS-BOUND
     IF WS-LARGE = 1
         MOVE 4 TO WS-BOUND
     END-IF
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-DRAW
     CALL "STRUCT-RUIN-ADD" USING L-X0 L-Z0 L-ROT WS-LARGE WS-INTEGRITY SDT-VARIANT(L-STRUCT) WS-DRAW
     IF WS-LARGE = 1
         CALL "JRAND-NEXT-FLOAT" USING SP-RNG WS-U
         IF WS-U <= SDT-CLUSTER(L-STRUCT)
             CALL "STRUCT-RUIN-CLUSTER" USING SDT-VARIANT(L-STRUCT) L-X0 L-Z0 L-ROT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM STRUCT-RUIN-PIECES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-RUIN-MARKER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY FEATLEVEL.
 01 WS-CHEST-KEY           PIC X(48) VALUE "minecraft:chest".
 01 WS-WATER-KEY           PIC X(48) VALUE "minecraft:water".
 01 WS-PROP                PIC X(24) VALUE "waterlogged".
 01 WS-TRUE                PIC X(32) VALUE "true".
 01 WS-MODE                BINARY-LONG VALUE 2.
 01 WS-OLD                 BINARY-LONG.
 01 WS-FLUID               BINARY-LONG.
 01 WS-SOURCE              BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-OK                  BINARY-LONG.
 01 WS-LOOT                PIC X(48).
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-NOTHING             PIC X(32) VALUE SPACES.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-META                 PIC X(96).
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-META L-X L-Y L-Z.
     EVALUATE L-META
         WHEN "chest"
*>           a default chest, waterlogged where the fluid there is water, with the table of the size and one nextLong of the piece random
             CALL "GEN-BLOCK-STATE" USING WS-CHEST-KEY WS-STATE
             CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-OLD
             CALL "STRUCT-FLUID-OF" USING WS-OLD WS-FLUID WS-SOURCE
             IF WS-FLUID = 2
                 CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-PROP WS-TRUE WS-NEW
                 MOVE WS-NEW TO WS-STATE
             END-IF
             CALL "FL-SET-STATE" USING L-X L-Y L-Z WS-STATE WS-FLAGS WS-OK
             MOVE "minecraft:chests/underwater_ruin_small" TO WS-LOOT
             IF SP-T-AUX(L-ROW) = 1
                 MOVE "minecraft:chests/underwater_ruin_big" TO WS-LOOT
             END-IF
             CALL "MSP-RNG-LONG" USING WS-SEED
             CALL "GBE-ADD" USING L-X L-Y L-Z WS-KIND WS-LOOT WS-SEED WS-NOTHING
         WHEN "drowned"
*>           the drowned is not made (no entity channel); the block is air above the sea level, else water
             MOVE 0 TO WS-STATE
             IF L-Y <= FL-SEA
                 CALL "GEN-BLOCK-STATE" USING WS-WATER-KEY WS-STATE
             END-IF
             CALL "FL-SET-STATE" USING L-X L-Y L-Z WS-STATE WS-FLAGS WS-OK
     END-EVALUATE
     GOBACK.
 END PROGRAM STRUCT-RUIN-MARKER.
