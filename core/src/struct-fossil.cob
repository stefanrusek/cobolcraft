*> The nether fossil (docs/protocol/36-structures-4-scattered-and-small.md section 9; 37-nether-5 section 6; 37-nether-6 sections 3.4 and 7): NetherFossilStructure.findGenerationPoint over the
*> Nether's base column, the piece (NetherFossilPiece: rotation, one of fossil_1 to fossil_14, mirror none, the ignore processor STRUCTURE_AND_AIR) and its post-process (the write box takes in
*> the whole template box, the template is placed, then the dried ghast).
*> Not wired into the Nether's chunk pipeline here: the stage that calls the structure starts of a Nether chunk (36-8 sections 2 and 13) belongs to another lane (002-lane-p45b,
*> NETHER-GEN-STRUCTURES); it takes the entry of this file (NFOS-FIND-POINT for the candidate chunks of the set nether_fossils, then NFOS-POST for every pass) as one more structure.
*> Deviations: the write box that the piece takes in (9.2 step 1) is the chunk window of the generation job, which cannot hold more than one chunk column: the cells of the template outside the
*> window are written by the pass of the chunk that holds them (each pass rebuilds the piece), and the dried ghast cell is written by the pass whose window holds it; the doc's "the chunk box already
*> includes the whole template box" is the same result over the union of the passes. The base column is the squeezed density of the chunk's corners (37-2: netherrack above 0, lava below y 32, else
*> air), without the surface pass or the carver: that is what a noise chunk generator's base column holds.
*>
*> Entry points:
*>   NFOS-BASE-COLUMN USING world seed (BINARY-DOUBLE), chunk x, chunk z, local x, local z, column out (PIC X(128): "A" air, "N" netherrack, "L" lava, one letter per y 0 to 127)
*>   NFOS-SCAN USING column, y (in: the sampled y, out: the y of the support block), sea level: 9.1 step 4 (an air cell over soul sand "S" or a sturdy block "N"; lava is not sturdy)
*>   NFOS-FIND-POINT USING world seed, chunk x, chunk z, x out, y out, z out, valid out (1 when there is a start), rotation out (0 to 3), template out (1 to 14): 9.1 with the start random
*>     (setLargeFeatureSeed), the piece added to the builder (SPB-RESET first) when there is a start
*>   NFOS-POST USING piece row: postProcess of the piece (9.2) in the window of MSP-OPEN
*>   NFOS-GHAST USING piece row: placeDriedGhast (9.3)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NFOS-BASE-COLUMN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NETHER.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-GT                  BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-LX                   BINARY-LONG.
 01 L-LZ                   BINARY-LONG.
 01 L-COLUMN               PIC X(128).
 PROCEDURE DIVISION USING L-SEED L-CX L-CZ L-LX L-LZ L-COLUMN.
     CALL "NETHER-SETUP" USING L-SEED
     CALL "NETHER-STATES"
     CALL "NETHER-CORNERS" USING L-CX L-CZ
     CALL "NETHER-COLUMN" USING L-LX L-LZ
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 127
         COMPUTE WS-I = WS-Y + 1
         CALL "FCMP-GT" USING NH-COL(WS-I) WS-ZERO WS-GT
         EVALUATE TRUE
             WHEN WS-GT = 1
                 MOVE "N" TO L-COLUMN(WS-I:1)
             WHEN WS-Y < 32
                 MOVE "L" TO L-COLUMN(WS-I:1)
             WHEN OTHER
                 MOVE "A" TO L-COLUMN(WS-I:1)
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM NFOS-BASE-COLUMN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NFOS-SCAN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   PIC X.
 01 WS-B                   PIC X.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-COLUMN               PIC X(128).
 01 L-Y                    BINARY-LONG.
 01 L-SEA                  BINARY-LONG.
 PROCEDURE DIVISION USING L-COLUMN L-Y L-SEA.
     MOVE 0 TO WS-DONE
     PERFORM UNTIL L-Y <= L-SEA OR WS-DONE = 1
         MOVE L-COLUMN(L-Y + 1:1) TO WS-A
         SUBTRACT 1 FROM L-Y
         MOVE L-COLUMN(L-Y + 1:1) TO WS-B
         IF WS-A = "A" AND (WS-B = "S" OR WS-B = "N")
             MOVE 1 TO WS-DONE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM NFOS-SCAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NFOS-FIND-POINT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 COPY STRUCTTPL.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-COLUMN              PIC X(128).
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-SEA                 BINARY-LONG VALUE 32.
 01 WS-PROC-KEY            PIC X(80) VALUE "cobolcraft:inline/ignore_structure_and_air".
 01 WS-PROC                BINARY-LONG.
 01 WS-ID                  PIC X(96).
 01 WS-NUM                 PIC 99.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 0.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-ZERO3               BINARY-LONG VALUE 0.
 01 WS-ZERO4               BINARY-LONG VALUE 0.
 01 WS-ZERO5               BINARY-LONG VALUE 0.
 01 WS-ZERO6               BINARY-LONG VALUE 0.
 01 WS-PIECE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 01 L-TEMPLATE             BINARY-LONG.
 PROCEDURE DIVISION USING L-SEED L-CX L-CZ L-X L-Y L-Z L-VALID L-ROT L-TEMPLATE.
     MOVE 0 TO L-VALID L-ROT L-TEMPLATE
     CALL "SPB-RESET"
     COMPUTE WS-USEED = FUNCTION MOD(L-SEED + WS-M64, WS-M64)
     CALL "JRAND-LARGE-FEATURE-SEED" USING SP-RNG WS-USEED L-CX L-CZ
*>   9.1 step 1: x then z
     COMPUTE WS-X0 = L-CX * 16
     COMPUTE WS-Z0 = L-CZ * 16
     MOVE 16 TO WS-BOUND
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-DRAW
     COMPUTE L-X = WS-X0 + WS-DRAW
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-DRAW
     COMPUTE L-Z = WS-Z0 + WS-DRAW
*>   step 2: the uniform height provider from absolute 32 to below_top 2 = 0 + 128 - 1 - 2 = 125 (23 section 7.3): nextInt(125 - 32 + 1) + 32
     MOVE 94 TO WS-BOUND
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-DRAW
     COMPUTE L-Y = WS-DRAW + 32
*>   step 3 and 4: the base column and the scan
     COMPUTE WS-LX = L-X - WS-X0
     COMPUTE WS-LZ = L-Z - WS-Z0
     CALL "NFOS-BASE-COLUMN" USING L-SEED L-CX L-CZ WS-LX WS-LZ WS-COLUMN
     CALL "NFOS-SCAN" USING WS-COLUMN L-Y WS-SEA
     IF L-Y <= WS-SEA
         GOBACK
     END-IF
*>   step 5: the rotation, then the template, then the piece
     MOVE 4 TO WS-BOUND
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND L-ROT
     MOVE 14 TO WS-BOUND
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-DRAW
     COMPUTE L-TEMPLATE = WS-DRAW + 1
     MOVE L-TEMPLATE TO WS-NUM
     MOVE SPACES TO WS-ID
     IF L-TEMPLATE < 10
         STRING "minecraft:nether_fossils/fossil_" WS-NUM(2:1) DELIMITED BY SIZE INTO WS-ID
     ELSE
         STRING "minecraft:nether_fossils/fossil_" WS-NUM DELIMITED BY SIZE INTO WS-ID
     END-IF
     CALL "STRUCT-TPL-LOAD" USING SD-DIR WS-ID WS-ROW
     CALL "STRUCT-PROC-LOAD" USING WS-PROC-KEY WS-PROC
     CALL "STRUCT-TPL-PIECE-ADD" USING WS-KIND WS-ROW L-X L-Y L-Z L-ROT WS-ZERO WS-ZERO2 WS-ZERO3 WS-ZERO4 WS-PROC WS-ZERO5 WS-ZERO6 WS-PIECE
     IF WS-PIECE > 0
         MOVE 1 TO L-VALID
     END-IF
     GOBACK.
 END PROGRAM NFOS-FIND-POINT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NFOS-POST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY STRUCTTPL.
 COPY STRUCTPLACE.
 COPY STRUCTSET.
 01 WS-ROW                 BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-RESULT              BINARY-LONG.
 01 WS-TX                  BINARY-LONG.
 01 WS-TY                  BINARY-LONG.
 01 WS-TZ                  BINARY-LONG.
 01 WS-AX                  BINARY-LONG.
 01 WS-AY                  BINARY-LONG.
 01 WS-AZ                  BINARY-LONG.
 01 WS-SAVE.
    05 WS-SV               BINARY-LONG OCCURS 6 TIMES.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE SP-T-ROW(L-ROW) TO WS-ROW
     INITIALIZE STRUCT-SETTINGS
     MOVE SP-T-MIR(L-ROW) TO PS-MIRROR
     MOVE SP-T-ROT(L-ROW) TO PS-ROTATION
     MOVE SP-T-PIV-X(L-ROW) TO PS-PIVOT-X
     MOVE SP-T-PIV-Z(L-ROW) TO PS-PIVOT-Z
     MOVE SP-T-LIQ(L-ROW) TO PS-LIQUID
     MOVE SP-T-PROC(L-ROW) TO PS-PROCESSORS
     MOVE SP-SEED TO PS-SEED
*>   9.2 step 1: the box of the template at its position, taken into the write box
     CALL "STRUCT-TX-BOX" USING TP-SX(WS-ROW) TP-SY(WS-ROW) TP-SZ(WS-ROW) PS-MIRROR PS-ROTATION PS-PIVOT-X PS-PIVOT-Z
         SP-T-X(L-ROW) SP-T-Y(L-ROW) SP-T-Z(L-ROW) WS-BOX
     MOVE B-X0 TO SP-X0(L-ROW)
     MOVE B-Y0 TO SP-Y0(L-ROW)
     MOVE B-Z0 TO SP-Z0(L-ROW)
     MOVE B-X1 TO SP-X1(L-ROW)
     MOVE B-Y1 TO SP-Y1(L-ROW)
     MOVE B-Z1 TO SP-Z1(L-ROW)
     MOVE SW-X0 TO WS-SV(1)
     MOVE SW-Y0 TO WS-SV(2)
     MOVE SW-Z0 TO WS-SV(3)
     MOVE SW-X1 TO WS-SV(4)
     MOVE SW-Y1 TO WS-SV(5)
     MOVE SW-Z1 TO WS-SV(6)
     MOVE FUNCTION MIN(SW-X0, B-X0) TO SW-X0
     MOVE FUNCTION MIN(SW-Y0, B-Y0) TO SW-Y0
     MOVE FUNCTION MIN(SW-Z0, B-Z0) TO SW-Z0
     MOVE FUNCTION MAX(SW-X1, B-X1) TO SW-X1
     MOVE FUNCTION MAX(SW-Y1, B-Y1) TO SW-Y1
     MOVE FUNCTION MAX(SW-Z1, B-Z1) TO SW-Z1
     MOVE 1 TO PS-BOX-SET
     MOVE SW-X0 TO PS-BOX(1)
     MOVE SW-Y0 TO PS-BOX(2)
     MOVE SW-Z0 TO PS-BOX(3)
     MOVE SW-X1 TO PS-BOX(4)
     MOVE SW-Y1 TO PS-BOX(5)
     MOVE SW-Z1 TO PS-BOX(6)
*>   step 2: the template, with its position as the anchor (36-6 2.3)
     MOVE SP-T-X(L-ROW) TO WS-TX WS-AX
     MOVE SP-T-Y(L-ROW) TO WS-TY WS-AY
     MOVE SP-T-Z(L-ROW) TO WS-TZ WS-AZ
     CALL "STRUCT-PLACE" USING WS-ROW WS-TX WS-TY WS-TZ WS-AX WS-AY WS-AZ STRUCT-SETTINGS WS-FLAGS WS-RESULT
*>   the window as it was, then step 3
     MOVE WS-SV(1) TO SW-X0
     MOVE WS-SV(2) TO SW-Y0
     MOVE WS-SV(3) TO SW-Z0
     MOVE WS-SV(4) TO SW-X1
     MOVE WS-SV(5) TO SW-Y1
     MOVE WS-SV(6) TO SW-Z1
     CALL "NFOS-GHAST" USING L-ROW
     GOBACK.
 END PROGRAM NFOS-POST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NFOS-GHAST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY FEATLEVEL.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-STATE               BINARY-DOUBLE UNSIGNED.
 01 WS-FACTORY             BINARY-DOUBLE UNSIGNED.
 01 WS-POSSEED             BINARY-DOUBLE UNSIGNED.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-ROT                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-KEY                 PIC X(112) VALUE "dried_ghast".
 01 WS-PROPS               PIC X(600).
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
*>   9.3: the stream of the world seed's positional factory at the centre of the template's box
     MOVE SP-X0(L-ROW) TO B-X0
     MOVE SP-Y0(L-ROW) TO B-Y0
     MOVE SP-Z0(L-ROW) TO B-Z0
     MOVE SP-X1(L-ROW) TO B-X1
     MOVE SP-Y1(L-ROW) TO B-Y1
     MOVE SP-Z1(L-ROW) TO B-Z1
     CALL "SPB-BOX-CENTER" USING WS-BOX WS-CX WS-CY WS-CZ
     COMPUTE WS-USEED = FUNCTION MOD(SP-SEED + WS-M64, WS-M64)
     CALL "JRAND-SET-SEED" USING WS-STATE WS-USEED
     CALL "JRAND-NEXT-LONG" USING WS-STATE WS-FACTORY
     CALL "XORO-GET-SEED" USING WS-CX WS-CY WS-CZ WS-SEED
     COMPUTE WS-POSSEED = FUNCTION MOD(WS-SEED + WS-M64, WS-M64)
     CALL "CBL_XOR" USING WS-FACTORY WS-POSSEED BY VALUE 8
     CALL "JRAND-SET-SEED" USING WS-STATE WS-POSSEED
*>   the 50 percent gate
     CALL "JRAND-NEXT-FLOAT" USING WS-STATE WS-U
     IF WS-U >= 0.5
         GOBACK
     END-IF
     COMPUTE WS-BOUND = B-X1 - B-X0 + 1
     CALL "JRAND-NEXT-INT-BOUND" USING WS-STATE WS-BOUND WS-DRAW
     COMPUTE WS-X = B-X0 + WS-DRAW
     MOVE B-Y0 TO WS-Y
     COMPUTE WS-BOUND = B-Z1 - B-Z0 + 1
     CALL "JRAND-NEXT-INT-BOUND" USING WS-STATE WS-BOUND WS-DRAW
     COMPUTE WS-Z = B-Z0 + WS-DRAW
*>   an air cell inside the window; the rotation is drawn as the block is set
     IF WS-X < SW-X0 OR WS-X > SW-X1 OR WS-Y < SW-Y0 OR WS-Y > SW-Y1 OR WS-Z < SW-Z0 OR WS-Z > SW-Z1
         GOBACK
     END-IF
     CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-CELL
     IF WS-CELL NOT = FL-S-AIR
         GOBACK
     END-IF
     MOVE 4 TO WS-BOUND
     CALL "JRAND-NEXT-INT-BOUND" USING WS-STATE WS-BOUND WS-ROT
*>   Rotation.getRandom picks none, clockwise_90, clockwise_180, counterclockwise_90: the default state faces north
     EVALUATE WS-ROT
         WHEN 0
             MOVE "facing=north" TO WS-PROPS
         WHEN 1
             MOVE "facing=east" TO WS-PROPS
         WHEN 2
             MOVE "facing=south" TO WS-PROPS
         WHEN OTHER
             MOVE "facing=west" TO WS-PROPS
     END-EVALUATE
     CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PROPS WS-CELL
     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-CELL WS-FLAGS WS-OK
     GOBACK.
 END PROGRAM NFOS-GHAST.
