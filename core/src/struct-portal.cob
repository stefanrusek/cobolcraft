*> The ruined portal and its processors (docs/protocol/36-structures-4 section 8, 36-structures-2 section 9.7).
*>
*> Entry points:
*>   STRUCT-PROC-LAVA USING STRUCT-CUR: LavaSubmergedBlockProcessor.processBlock (36-2 9.7): where the world holds lava (the lava block, any level) at the record's position and the
*>     template's state is not a full block, the record's state becomes the default state of lava (the tag is kept). Deviation: "full block" (isShapeFullBlock of the collision shape) is
*>     the content set's solid and opaque flags (CB-SOLID and CB-OPAQUE; the block tables carry no collision shapes), so a stair, a slab, a fence, glass and a chest are not full blocks.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PROC-LAVA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-LAVA-KEY            PIC X(48) VALUE "minecraft:lava".
 01 WS-WORLD               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 LINKAGE SECTION.
 COPY STRUCTCUR.
 PROCEDURE DIVISION USING STRUCT-CUR.
     CALL "FL-GET-STATE" USING CU-X CU-Y CU-Z WS-WORLD
     CALL "FL-CLASS" USING WS-WORLD WS-CLASS
     IF WS-CLASS = 3
         MOVE CB-S-BLOCK(CU-STATE + 1) TO WS-BLOCK
         IF CB-SOLID(WS-BLOCK + 1) = 0 OR CB-OPAQUE(WS-BLOCK + 1) = 0
             CALL "GEN-BLOCK-STATE" USING WS-LAVA-KEY WS-LAVA
             MOVE WS-LAVA TO CU-STATE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM STRUCT-PROC-LAVA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PORTAL-READ.
*> USING JSON-DOC (the structure's file), structure row: the setups of 8.1 into STRUCT-PORTAL-DATA (SDT-RP-FIRST, SDT-RP-N): placement, air_pocket_probability, mossiness (in tenths: the data
*> has one decimal), overgrown, vines, can_be_cold, replace_with_blackstone and weight. A structure that is not a ruined_portal has no setup.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 COPY STRUCTPORTAL.
 01 WS-KIND-TYPE           BINARY-LONG VALUE 1.
 01 WS-NAME                PIC X(40).
 01 WS-ARRAY               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-MEMBER              BINARY-LONG.
 01 WS-TEXT                PIC X(120).
 01 WS-LEN                 BINARY-LONG.
 01 WS-DBL                 FLOAT-LONG.
 01 WS-F32                 FLOAT-SHORT.
 01 WS-OK                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 K-SETUPS               PIC X(40) VALUE "setups".
 01 K-PLACEMENT            PIC X(40) VALUE "placement".
 01 K-AIR                  PIC X(40) VALUE "air_pocket_probability".
 01 K-MOSS                 PIC X(40) VALUE "mossiness".
 01 K-OVERGROWN            PIC X(40) VALUE "overgrown".
 01 K-VINES                PIC X(40) VALUE "vines".
 01 K-COLD                 PIC X(40) VALUE "can_be_cold".
 01 K-BLACK                PIC X(40) VALUE "replace_with_blackstone".
 01 K-WEIGHT               PIC X(40) VALUE "weight".
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-ROW.
     MOVE 0 TO SDT-RP-FIRST(L-ROW) SDT-RP-N(L-ROW)
     CALL "STRUCT-ENUM-NAME" USING WS-KIND-TYPE SDT-TYPE(L-ROW) WS-NAME
     IF WS-NAME NOT = "ruined_portal"
         GOBACK
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC 1 K-SETUPS WS-ARRAY
     IF WS-ARRAY = 0
         GOBACK
     END-IF
     COMPUTE SDT-RP-FIRST(L-ROW) = RP-COUNT + 1
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= JN-COUNT(WS-ARRAY) OR RP-COUNT >= RP-MAX
         CALL "JSON-ELEMENT" USING JSON-DOC WS-ARRAY WS-I WS-NODE
         ADD 1 TO RP-COUNT
         MOVE RP-COUNT TO WS-ROW
         ADD 1 TO SDT-RP-N(L-ROW)
         CALL "FD-J-STRING" USING JSON-DOC K-PLACEMENT WS-NODE WS-TEXT WS-LEN
         EVALUATE FUNCTION TRIM(WS-TEXT)
             WHEN "on_land_surface"
                 MOVE 0 TO RP-PLACEMENT(WS-ROW)
             WHEN "partly_buried"
                 MOVE 1 TO RP-PLACEMENT(WS-ROW)
             WHEN "on_ocean_floor"
                 MOVE 2 TO RP-PLACEMENT(WS-ROW)
             WHEN "in_mountain"
                 MOVE 3 TO RP-PLACEMENT(WS-ROW)
             WHEN "underground"
                 MOVE 4 TO RP-PLACEMENT(WS-ROW)
             WHEN OTHER
                 MOVE 5 TO RP-PLACEMENT(WS-ROW)
         END-EVALUATE
         CALL "FD-J-MEMBER" USING JSON-DOC WS-NODE K-AIR WS-MEMBER
         CALL "FD-J-DOUBLE" USING JSON-DOC WS-MEMBER WS-DBL WS-OK
         MOVE WS-DBL TO WS-F32
         MOVE WS-F32 TO RP-AIR(WS-ROW)
         CALL "FD-J-MEMBER" USING JSON-DOC WS-NODE K-WEIGHT WS-MEMBER
         CALL "FD-J-DOUBLE" USING JSON-DOC WS-MEMBER WS-DBL WS-OK
         MOVE WS-DBL TO WS-F32
         MOVE WS-F32 TO RP-WEIGHT(WS-ROW)
         CALL "FD-J-MEMBER" USING JSON-DOC WS-NODE K-MOSS WS-MEMBER
         CALL "FD-J-DOUBLE" USING JSON-DOC WS-MEMBER WS-DBL WS-OK
         COMPUTE RP-MOSS(WS-ROW) = FUNCTION INTEGER(WS-DBL * 10 + 0.5)
         CALL "FD-J-MEMBER" USING JSON-DOC WS-NODE K-OVERGROWN WS-MEMBER
         MOVE 0 TO WS-OK
         IF WS-MEMBER > 0
             IF JN-TYPE(WS-MEMBER) = JT-TRUE
                 MOVE 1 TO WS-OK
             END-IF
         END-IF
         MOVE WS-OK TO RP-OVERGROWN(WS-ROW)
         CALL "FD-J-MEMBER" USING JSON-DOC WS-NODE K-VINES WS-MEMBER
         MOVE 0 TO WS-OK
         IF WS-MEMBER > 0
             IF JN-TYPE(WS-MEMBER) = JT-TRUE
                 MOVE 1 TO WS-OK
             END-IF
         END-IF
         MOVE WS-OK TO RP-VINES(WS-ROW)
         CALL "FD-J-MEMBER" USING JSON-DOC WS-NODE K-COLD WS-MEMBER
         MOVE 0 TO WS-OK
         IF WS-MEMBER > 0
             IF JN-TYPE(WS-MEMBER) = JT-TRUE
                 MOVE 1 TO WS-OK
             END-IF
         END-IF
         MOVE WS-OK TO RP-COLD(WS-ROW)
         CALL "FD-J-MEMBER" USING JSON-DOC WS-NODE K-BLACK WS-MEMBER
         MOVE 0 TO WS-OK
         IF WS-MEMBER > 0
             IF JN-TYPE(WS-MEMBER) = JT-TRUE
                 MOVE 1 TO WS-OK
             END-IF
         END-IF
         MOVE WS-OK TO RP-BLACK(WS-ROW)
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-PORTAL-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PORTAL-LIST-JSON.
*> USING key (PIC X(80)), text out (PIC X(65536)), status out (0 the JSON of the list, 1 not a portal list): the processors of a ruined portal piece (8.4) for the key
*> cobolcraft:inline/portal/<air pocket><ocean floor><cold><blackstone, each 0 or 1>/<tenths of the mossiness>: block_ignore (structure_block when there is an air pocket, else air too),
*> the rule processor (gold_block to air at 0.3; lava to magma_block always on the ocean floor, else to netherrack always when cold, else at 0.2; netherrack to magma_block at 0.07
*> unless cold), block_age, protected_blocks (#features_cannot_replace), lava_submerged_block and, with blackstone, blackstone_replace.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-IGNORE              PIC X(80).
 01 WS-LAVA                PIC X(240).
 01 WS-MAGMA               PIC X(240).
 01 WS-BLACK               PIC X(60).
 LINKAGE SECTION.
 01 L-KEY                  PIC X(80).
 01 L-TEXT                 PIC X(65536).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-TEXT L-STATUS.
     MOVE 1 TO L-STATUS
     IF L-KEY(1:25) NOT = "cobolcraft:inline/portal/" OR L-KEY(26:4) NOT NUMERIC OR L-KEY(30:1) NOT = "/" OR L-KEY(31:1) NOT NUMERIC OR L-KEY(32:49) NOT = SPACES
         GOBACK
     END-IF
     MOVE '"minecraft:air","minecraft:structure_block"' TO WS-IGNORE
     IF L-KEY(26:1) = "1"
         MOVE '"minecraft:structure_block"' TO WS-IGNORE
     END-IF
     MOVE '{"input_predicate":{"predicate_type":"minecraft:random_block_match","block":"minecraft:lava","probability":0.2},"location_predicate":{"predicate_type":"minecraft:always_true"},"output_state":"minecraft:magma_block"}' TO WS-LAVA
     IF L-KEY(28:1) = "1"
         MOVE '{"input_predicate":{"predicate_type":"minecraft:block_match","block":"minecraft:lava"},"location_predicate":{"predicate_type":"minecraft:always_true"},"output_state":"minecraft:netherrack"}' TO WS-LAVA
     END-IF
     IF L-KEY(27:1) = "1"
         MOVE '{"input_predicate":{"predicate_type":"minecraft:block_match","block":"minecraft:lava"},"location_predicate":{"predicate_type":"minecraft:always_true"},"output_state":"minecraft:magma_block"}' TO WS-LAVA
     END-IF
     MOVE SPACES TO WS-MAGMA
     IF L-KEY(28:1) = "0"
         MOVE ',{"input_predicate":{"predicate_type":"minecraft:random_block_match","block":"minecraft:netherrack","probability":0.07},"location_predicate":{"predicate_type":"minecraft:always_true"},"output_state":"minecraft:magma_block"}' TO WS-MAGMA
     END-IF
     MOVE SPACES TO WS-BLACK
     IF L-KEY(29:1) = "1"
         MOVE ',{"processor_type":"minecraft:blackstone_replace"}' TO WS-BLACK
     END-IF
     MOVE SPACES TO L-TEXT
     STRING '{"processors":[{"processor_type":"minecraft:block_ignore","blocks":[' FUNCTION TRIM(WS-IGNORE) ']},'
         '{"processor_type":"minecraft:rule","rules":['
         '{"input_predicate":{"predicate_type":"minecraft:random_block_match","block":"minecraft:gold_block","probability":0.3},'
         '"location_predicate":{"predicate_type":"minecraft:always_true"},"output_state":"minecraft:air"},'
         FUNCTION TRIM(WS-LAVA) FUNCTION TRIM(WS-MAGMA) ']},'
         '{"processor_type":"minecraft:block_age","mossiness":0.' L-KEY(31:1) '},'
         '{"processor_type":"minecraft:protected_blocks","value":"#minecraft:features_cannot_replace"},'
         '{"processor_type":"minecraft:lava_submerged_block"}' FUNCTION TRIM(WS-BLACK) ']}'
         DELIMITED BY SIZE INTO L-TEXT
     MOVE 0 TO L-STATUS
     GOBACK.
 END PROGRAM STRUCT-PORTAL-LIST-JSON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PORTAL-RBI.
*> USING lo, hi, value out: Mth.nextInt(r, lo, hi) of the start random (inclusive; lo when lo >= hi, without a draw).
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
     MOVE L-LO TO L-VALUE
     IF L-LO < L-HI
         COMPUTE WS-BOUND = L-HI - L-LO + 1
         CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-DRAW
         COMPUTE L-VALUE = WS-DRAW + L-LO
     END-IF
     GOBACK.
 END PROGRAM STRUCT-PORTAL-RBI.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PORTAL-COLD.
*> USING x, y, z (the stub), flag out: Biome.coldEnoughToSnow(pos, sea level 63) of the biome at the stub (33 section 4.5; 36-4 8.2 step 9): 1 when the temperature of the biome of the registry at the
*> position is below 0.15, the temperature being FR-TEMPERATURE of feat-freeze.cob (the base temperature, the frozen modifier of the frozen biomes, the noise term above sea level + 17). The biome comes
*> from STRUCT-PORTAL-BIOME (struct-portal-biome.cob, a program of its own) and is looked up by its key in the registry table CORE-BIOMES; a biome the table has not is not cold.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-BIOME               PIC X(40).
 01 WS-T                   FLOAT-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-LIMIT               FLOAT-LONG VALUE 0.15.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-FLAG.
     MOVE 0 TO L-FLAG
     CALL "STRUCT-PORTAL-BIOME" USING L-X L-Y L-Z WS-BIOME
     MOVE -1 TO WS-ID
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CBI-COUNT
         MOVE CBI-KEY-LENGTH(WS-I) TO WS-LEN
         IF WS-LEN > 0 AND WS-LEN <= 40
             COMPUTE WS-NEXT = WS-LEN + 1
             IF CBI-KEY(WS-I)(1:WS-LEN) = WS-BIOME(1:WS-LEN) AND WS-BIOME(WS-NEXT:1) = SPACE
                 COMPUTE WS-ID = WS-I - 1
             END-IF
         END-IF
     END-PERFORM
     IF WS-ID >= 0
         CALL "FR-TEMPERATURE" USING WS-ID L-X L-Y L-Z WS-SEA WS-T
         IF WS-T < WS-LIMIT
             MOVE 1 TO L-FLAG
         END-IF
     END-IF
     GOBACK.
 END PROGRAM STRUCT-PORTAL-COLD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PORTAL-FIND-POINT.
*> USING structure row, seed (BINARY-DOUBLE), chunk x, chunk z, stub x out, stub y out, stub z out, valid out: findGenerationPoint (8.2, 8.3): the start random (setLargeFeatureSeed), the
*> setup (one draw when there are several), the air pocket (no draw at probability 0 or 1), the template (a float, then an index), the rotation, the mirror, the pivot, the box and the column
*> of its centre (JIG-SURFACE: the base height, kind 1 for the ocean floor) and the suitable y with its lowering loop over the four corners (a column's block at y passes when y is under
*> its first free height; the base terrain has no caves here). The piece is a template piece of kind 4 at (chunk corner, y), its AUX the properties: air pocket 1, overgrown 2, vines 4,
*> cold 8, blackstone 16 and 32 times the placement; the stub is the piece's position.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 COPY STRUCTTPL.
 COPY STRUCTPORTAL.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-U                   FLOAT-LONG.
 01 WS-F32                 FLOAT-SHORT.
 01 WS-TOTAL               FLOAT-LONG.
 01 WS-HALF                FLOAT-LONG VALUE 0.5.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG.
 01 WS-ID                  PIC X(96).
 01 WS-TROW                BINARY-LONG.
 01 WS-DIGITS              PIC Z9.
 01 WS-ROT                 BINARY-LONG.
 01 WS-MIRROR              BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG VALUE 0.
 01 WS-PZ                  BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG VALUE 0.
 01 WS-OZ                  BINARY-LONG.
 01 WS-BOX.
    05 WB                  BINARY-LONG OCCURS 6 TIMES.
 01 WS-SBOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==SBX-==.
 01 WS-CCX                 BINARY-LONG.
 01 WS-CCY                 BINARY-LONG.
 01 WS-CCZ                 BINARY-LONG.
 01 WS-PLACEMENT           BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-SURF                BINARY-LONG.
 01 WS-SPAN                BINARY-LONG.
 01 WS-MIN-Y               BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-CORNER-X            BINARY-LONG.
 01 WS-CORNER-Z            BINARY-LONG.
 01 WS-COLD                BINARY-LONG.
 01 WS-AUX                 BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-LIST                BINARY-LONG.
 01 WS-DIGIT               PIC 9.
 01 WS-AIRD                PIC 9.
 01 WS-OCEAND              PIC 9.
 01 WS-COLDD               PIC 9.
 01 WS-BLACKD              PIC 9.
 01 WS-PIECE               BINARY-LONG.
 01 WS-LIQUID              BINARY-LONG VALUE 0.
 01 WS-KIND-PIECE          BINARY-LONG VALUE 4.
 LINKAGE SECTION.
 01 L-STRUCT               BINARY-LONG.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING L-STRUCT L-SEED L-CX L-CZ L-X L-Y L-Z L-VALID.
     MOVE 0 TO L-VALID
     CALL "SPB-RESET"
     COMPUTE L-X = L-CX * 16
     MOVE 0 TO L-Y
     COMPUTE L-Z = L-CZ * 16
     IF SDT-RP-N(L-STRUCT) = 0
         GOBACK
     END-IF
     COMPUTE WS-USEED = FUNCTION MOD(L-SEED + WS-M64, WS-M64)
     CALL "JRAND-LARGE-FEATURE-SEED" USING SP-RNG WS-USEED L-CX L-CZ
*>   8.2 step 1: the setup, by weight
     MOVE SDT-RP-FIRST(L-STRUCT) TO WS-ROW
     IF SDT-RP-N(L-STRUCT) > 1
         MOVE 0 TO WS-TOTAL
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= SDT-RP-N(L-STRUCT)
             COMPUTE WS-ROW = SDT-RP-FIRST(L-STRUCT) + WS-I
             COMPUTE WS-TOTAL = WS-TOTAL + RP-WEIGHT(WS-ROW)
             MOVE WS-TOTAL TO WS-F32
             MOVE WS-F32 TO WS-TOTAL
         END-PERFORM
         CALL "JRAND-NEXT-FLOAT" USING SP-RNG WS-U
         MOVE 0 TO WS-N
         MOVE SDT-RP-FIRST(L-STRUCT) TO WS-I
         COMPUTE WS-ROW = SDT-RP-FIRST(L-STRUCT) + SDT-RP-N(L-STRUCT) - 1
         PERFORM VARYING WS-I FROM SDT-RP-FIRST(L-STRUCT) BY 1 UNTIL WS-I >= SDT-RP-FIRST(L-STRUCT) + SDT-RP-N(L-STRUCT) OR WS-N = 1
             COMPUTE WS-U = WS-U - RP-WEIGHT(WS-I) / WS-TOTAL
             MOVE WS-U TO WS-F32
             MOVE WS-F32 TO WS-U
             IF WS-U < 0
                 MOVE WS-I TO WS-ROW
                 MOVE 1 TO WS-N
             END-IF
         END-PERFORM
     END-IF
     MOVE RP-PLACEMENT(WS-ROW) TO WS-PLACEMENT
*>   step 3: the air pocket (sample: none at probability 0 or 1)
     MOVE 0 TO WS-AIR
     IF RP-AIR(WS-ROW) >= 1
         MOVE 1 TO WS-AIR
     END-IF
     IF RP-AIR(WS-ROW) > 0 AND RP-AIR(WS-ROW) < 1
         CALL "JRAND-NEXT-FLOAT" USING SP-RNG WS-U
         IF WS-U < RP-AIR(WS-ROW)
             MOVE 1 TO WS-AIR
         END-IF
     END-IF
*>   step 4: the template, a giant one at 0.05
     MOVE 0.05 TO WS-F32
     MOVE WS-F32 TO WS-TOTAL
     CALL "JRAND-NEXT-FLOAT" USING SP-RNG WS-U
     MOVE SPACES TO WS-ID
     IF WS-U < WS-TOTAL
         MOVE 3 TO WS-BOUND
         CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-DRAW
         COMPUTE WS-N = WS-DRAW + 1
         MOVE WS-N TO WS-DIGITS
         STRING "minecraft:ruined_portal/giant_portal_" FUNCTION TRIM(WS-DIGITS) DELIMITED BY SIZE INTO WS-ID
     ELSE
         MOVE 10 TO WS-BOUND
         CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-DRAW
         COMPUTE WS-N = WS-DRAW + 1
         MOVE WS-N TO WS-DIGITS
         STRING "minecraft:ruined_portal/portal_" FUNCTION TRIM(WS-DIGITS) DELIMITED BY SIZE INTO WS-ID
     END-IF
*>   step 5: the rotation, then the mirror (none or front_back)
     MOVE 4 TO WS-BOUND
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-ROT
     CALL "JRAND-NEXT-FLOAT" USING SP-RNG WS-U
     MOVE 0 TO WS-MIRROR
     IF WS-U >= WS-HALF
         MOVE 2 TO WS-MIRROR
     END-IF
     CALL "STRUCT-TPL-LOAD" USING SD-DIR WS-ID WS-TROW
     IF WS-TROW < 1
         GOBACK
     END-IF
     IF TP-STATUS(WS-TROW) NOT = 1
         GOBACK
     END-IF
*>   steps 6 and 7: the pivot, the box at the chunk's corner and the column of its centre
     COMPUTE WS-PX = TP-SX(WS-TROW) / 2
     COMPUTE WS-PZ = TP-SZ(WS-TROW) / 2
     MOVE L-X TO WS-OX
     MOVE L-Z TO WS-OZ
     CALL "STRUCT-TX-BOX" USING TP-SX(WS-TROW) TP-SY(WS-TROW) TP-SZ(WS-TROW) WS-MIRROR WS-ROT WS-PX WS-PZ WS-OX WS-OY WS-OZ WS-BOX
     MOVE WB(1) TO SBX-X0
     MOVE WB(2) TO SBX-Y0
     MOVE WB(3) TO SBX-Z0
     MOVE WB(4) TO SBX-X1
     MOVE WB(5) TO SBX-Y1
     MOVE WB(6) TO SBX-Z1
     CALL "SPB-BOX-CENTER" USING WS-SBOX WS-CCX WS-CCY WS-CCZ
     MOVE 0 TO WS-KIND
     IF WS-PLACEMENT = 2
         MOVE 1 TO WS-KIND
     END-IF
     CALL "JIG-SURFACE" USING WS-CCX WS-CCZ WS-KIND WS-SURF
     SUBTRACT 1 FROM WS-SURF
     MOVE TP-SY(WS-TROW) TO WS-SPAN
     MOVE -64 TO WS-MIN-Y
     IF WS-PLACEMENT = 5
         MOVE 0 TO WS-MIN-Y
     END-IF
     COMPUTE WS-LIMIT = WS-MIN-Y + 15
*>   8.3: the candidate y of the placement
     EVALUATE WS-PLACEMENT
         WHEN 5
             IF WS-AIR = 1
                 MOVE 32 TO WS-LO
                 MOVE 100 TO WS-HI
                 CALL "STRUCT-PORTAL-RBI" USING WS-LO WS-HI WS-Y
             ELSE
                 CALL "JRAND-NEXT-FLOAT" USING SP-RNG WS-U
                 IF WS-U < WS-HALF
                     MOVE 27 TO WS-LO
                     MOVE 29 TO WS-HI
                 ELSE
                     MOVE 29 TO WS-LO
                     MOVE 100 TO WS-HI
                 END-IF
                 CALL "STRUCT-PORTAL-RBI" USING WS-LO WS-HI WS-Y
             END-IF
         WHEN 3
             COMPUTE WS-V = WS-SURF - WS-SPAN
             MOVE 70 TO WS-LO
             CALL "STRUCT-PORTAL-RBI" USING WS-LO WS-V WS-Y
             IF WS-V <= 70
                 MOVE WS-V TO WS-Y
             END-IF
         WHEN 4
             COMPUTE WS-V = WS-SURF - WS-SPAN
             CALL "STRUCT-PORTAL-RBI" USING WS-LIMIT WS-V WS-Y
             IF WS-V <= WS-LIMIT
                 MOVE WS-V TO WS-Y
             END-IF
         WHEN 1
             MOVE 2 TO WS-LO
             MOVE 8 TO WS-HI
             CALL "STRUCT-PORTAL-RBI" USING WS-LO WS-HI WS-V
             COMPUTE WS-Y = WS-SURF - WS-SPAN + WS-V
         WHEN OTHER
             MOVE WS-SURF TO WS-Y
     END-EVALUATE
*>   the lowering loop: down while the block of three of the four corner columns is not there
     MOVE 0 TO WS-COUNT
     PERFORM UNTIL WS-Y <= WS-LIMIT OR WS-COUNT >= 3
         MOVE 0 TO WS-COUNT
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 3
             IF WS-I = 0 OR WS-I = 2
                 MOVE WB(1) TO WS-CORNER-X
             ELSE
                 MOVE WB(4) TO WS-CORNER-X
             END-IF
             IF WS-I < 2
                 MOVE WB(3) TO WS-CORNER-Z
             ELSE
                 MOVE WB(6) TO WS-CORNER-Z
             END-IF
             CALL "JIG-SURFACE" USING WS-CORNER-X WS-CORNER-Z WS-KIND WS-H
             IF WS-Y < WS-H
                 ADD 1 TO WS-COUNT
             END-IF
         END-PERFORM
         IF WS-COUNT < 3
             SUBTRACT 1 FROM WS-Y
         END-IF
     END-PERFORM
     MOVE L-X TO WS-OX
     MOVE WS-Y TO L-Y
     MOVE WS-Y TO WS-OY
*>   step 9: cold only for a setup that can be, in a cold biome at the stub
     MOVE 0 TO WS-COLD
     IF RP-COLD(WS-ROW) = 1
         CALL "STRUCT-PORTAL-COLD" USING L-X L-Y L-Z WS-COLD
     END-IF
     COMPUTE WS-AUX = WS-AIR + RP-OVERGROWN(WS-ROW) * 2 + RP-VINES(WS-ROW) * 4 + WS-COLD * 8 + RP-BLACK(WS-ROW) * 16 + WS-PLACEMENT * 32
     MOVE WS-AIR TO WS-AIRD
     MOVE 0 TO WS-OCEAND
     IF WS-PLACEMENT = 2
         MOVE 1 TO WS-OCEAND
     END-IF
     MOVE WS-COLD TO WS-COLDD
     MOVE RP-BLACK(WS-ROW) TO WS-BLACKD
     MOVE RP-MOSS(WS-ROW) TO WS-DIGIT
     MOVE SPACES TO WS-KEY
     STRING "cobolcraft:inline/portal/" WS-AIRD WS-OCEAND WS-COLDD WS-BLACKD "/" WS-DIGIT DELIMITED BY SIZE INTO WS-KEY
     CALL "STRUCT-PROC-LOAD" USING WS-KEY WS-LIST
     CALL "STRUCT-TPL-PIECE-ADD" USING WS-KIND-PIECE WS-TROW L-X WS-Y L-Z WS-ROT WS-MIRROR WS-PX WS-PY WS-PZ WS-LIST WS-LIQUID WS-AUX WS-PIECE
     IF WS-PIECE > 0
         MOVE 1 TO L-VALID
     END-IF
     GOBACK.
 END PROGRAM STRUCT-PORTAL-FIND-POINT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PORTAL-BEGIN.
*> USING piece row, go out: the start of postProcess of a ruined portal piece (8.4 steps 1 and 2): go 0 when the write box does not contain the centre of the piece's box (the whole
*> portal is made only in the pass whose chunk holds it); else the write box SW-* of STRUCTPIECE.cpy is enlarged to the portal's box for this call (STRUCT-PORTAL-AFTER puts it back).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY STRUCTTPL.
 COPY STRUCTPORTAL-WORK.
 01 WS-BOX.
    05 WB                  BINARY-LONG OCCURS 6 TIMES.
 01 WS-SBOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==SBX-==.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-TROW                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-GO                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-GO.
     MOVE 0 TO L-GO
     MOVE SP-T-ROW(L-ROW) TO WS-TROW
     CALL "STRUCT-TX-BOX" USING TP-SX(WS-TROW) TP-SY(WS-TROW) TP-SZ(WS-TROW) SP-T-MIR(L-ROW) SP-T-ROT(L-ROW) SP-T-PIV-X(L-ROW) SP-T-PIV-Z(L-ROW)
         SP-T-X(L-ROW) SP-T-Y(L-ROW) SP-T-Z(L-ROW) WS-BOX
     MOVE WB(1) TO SBX-X0
     MOVE WB(2) TO SBX-Y0
     MOVE WB(3) TO SBX-Z0
     MOVE WB(4) TO SBX-X1
     MOVE WB(5) TO SBX-Y1
     MOVE WB(6) TO SBX-Z1
     CALL "SPB-BOX-CENTER" USING WS-SBOX WS-CX WS-CY WS-CZ
     IF WS-CX >= SW-X0 AND WS-CX <= SW-X1 AND WS-CY >= SW-Y0 AND WS-CY <= SW-Y1 AND WS-CZ >= SW-Z0 AND WS-CZ <= SW-Z1
         MOVE 1 TO L-GO
         MOVE SW-X0 TO PORT-SAVE(1)
         MOVE SW-Y0 TO PORT-SAVE(2)
         MOVE SW-Z0 TO PORT-SAVE(3)
         MOVE SW-X1 TO PORT-SAVE(4)
         MOVE SW-Y1 TO PORT-SAVE(5)
         MOVE SW-Z1 TO PORT-SAVE(6)
         MOVE FUNCTION MIN(SW-X0, WB(1)) TO SW-X0
         MOVE FUNCTION MIN(SW-Y0, WB(2)) TO SW-Y0
         MOVE FUNCTION MIN(SW-Z0, WB(3)) TO SW-Z0
         MOVE FUNCTION MAX(SW-X1, WB(4)) TO SW-X1
         MOVE FUNCTION MAX(SW-Y1, WB(5)) TO SW-Y1
         MOVE FUNCTION MAX(SW-Z1, WB(6)) TO SW-Z1
     END-IF
     GOBACK.
 END PROGRAM STRUCT-PORTAL-BEGIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PORTAL-XF.
*> USING value out (FLOAT-LONG): nextFloat() of the decoration random SP-XR of the placement.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-XR== LEADING ==XR-== BY ==WX-==.
 LINKAGE SECTION.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-VALUE.
     MOVE SP-XR-LO TO WX-LO
     MOVE SP-XR-HI TO WX-HI
     CALL "WGR-NEXT-FLOAT" USING WS-XR L-VALUE
     MOVE WX-LO TO SP-XR-LO
     MOVE WX-HI TO SP-XR-HI
     GOBACK.
 END PROGRAM STRUCT-PORTAL-XF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PORTAL-XD.
*> USING value out (FLOAT-LONG): nextDouble() of the decoration random SP-XR of the placement.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-XR== LEADING ==XR-== BY ==WX-==.
 LINKAGE SECTION.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-VALUE.
     MOVE SP-XR-LO TO WX-LO
     MOVE SP-XR-HI TO WX-HI
     CALL "WGR-NEXT-DOUBLE" USING WS-XR L-VALUE
     MOVE WX-LO TO SP-XR-LO
     MOVE WX-HI TO SP-XR-HI
     GOBACK.
 END PROGRAM STRUCT-PORTAL-XD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PORTAL-KEY.
*> USING x, y, z, key out (PIC X(48)): the block key (without the namespace) of the state of the window at the position; spaces for a state that is not a block of the table.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-KEY                  PIC X(48).
 PROCEDURE DIVISION USING L-X L-Y L-Z L-KEY.
     CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
     MOVE CB-KEY(WS-BLOCK + 1) TO L-KEY
     GOBACK.
 END PROGRAM STRUCT-PORTAL-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PORTAL-CAN.
*> USING x, y, z, nether (1 for the in_nether placement), flag out: canBlockBeReplacedByNetherrackOrMagma (8.5): not air (the block air only), not obsidian, not a block of the tag
*> features_cannot_replace and, unless nether, not lava.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPROC.
 01 WS-KEY                 PIC X(48).
 01 WS-LIST-KEY            PIC X(80) VALUE "cobolcraft:inline/features_cannot_replace".
 01 WS-LIST                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-NETHER               BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-NETHER L-FLAG.
     MOVE 1 TO L-FLAG
     CALL "STRUCT-PORTAL-KEY" USING L-X L-Y L-Z WS-KEY
     IF WS-KEY = "air" OR WS-KEY = "obsidian" OR (WS-KEY = "lava" AND L-NETHER = 0)
         MOVE 0 TO L-FLAG
         GOBACK
     END-IF
     CALL "STRUCT-PROC-LOAD" USING WS-LIST-KEY WS-LIST
     IF WS-LIST > 0
         CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
         CALL "SP-IN-SET" USING SPP-POOL(SPL-FIRST(WS-LIST)) SPP-N(SPL-FIRST(WS-LIST)) WS-STATE WS-IN
         IF WS-IN = 1
             MOVE 0 TO L-FLAG
         END-IF
     END-IF
     GOBACK.
 END PROGRAM STRUCT-PORTAL-CAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PORTAL-PLACE.
*> USING x, y, z, cold, nether: placeNetherrackOrMagma (8.5, 8.6): where the block may be replaced, magma_block when the piece is not cold and nextFloat() < 0.07 (the draw is made only then),
*> else netherrack (setBlockAndUpdate: flags 3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NETHERRACK          PIC X(48) VALUE "minecraft:netherrack".
 01 WS-MAGMA               PIC X(48) VALUE "minecraft:magma_block".
 01 WS-CAN                 BINARY-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-CHANCE              FLOAT-LONG.
 01 WS-F32                 FLOAT-SHORT VALUE 0.07.
 01 WS-STATE               BINARY-LONG.
 01 WS-STATE-KEY           PIC X(48).
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-COLD                 BINARY-LONG.
 01 L-NETHER               BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-COLD L-NETHER.
     CALL "STRUCT-PORTAL-CAN" USING L-X L-Y L-Z L-NETHER WS-CAN
     IF WS-CAN = 1
         MOVE WS-F32 TO WS-CHANCE
         MOVE WS-NETHERRACK TO WS-STATE-KEY
         IF L-COLD = 0
             CALL "STRUCT-PORTAL-XF" USING WS-U
             IF WS-U < WS-CHANCE
                 MOVE WS-MAGMA TO WS-STATE-KEY
             END-IF
         END-IF
         CALL "GEN-BLOCK-STATE" USING WS-STATE-KEY WS-STATE
         CALL "FL-SET-STATE" USING L-X L-Y L-Z WS-STATE WS-FLAGS WS-OK
     END-IF
     GOBACK.
 END PROGRAM STRUCT-PORTAL-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PORTAL-DRIP.
*> USING x, y, z, cold, nether: addNetherrackDripColumn (8.6): the cell, then while fewer than eight were added below it and nextFloat() < 0.5, the cell under (at most nine cells).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-U                   FLOAT-LONG.
 01 WS-HALF                FLOAT-LONG VALUE 0.5.
 01 WS-N                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-COLD                BINARY-LONG.
 01 WS-NETHER              BINARY-LONG.
 01 WS-GO                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-COLD                 BINARY-LONG.
 01 L-NETHER               BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-COLD L-NETHER.
     MOVE L-X TO WS-X
     MOVE L-Y TO WS-Y
     MOVE L-Z TO WS-Z
     MOVE L-COLD TO WS-COLD
     MOVE L-NETHER TO WS-NETHER
     CALL "STRUCT-PORTAL-PLACE" USING WS-X WS-Y WS-Z WS-COLD WS-NETHER
     MOVE 8 TO WS-N
     MOVE 1 TO WS-GO
     PERFORM UNTIL WS-GO = 0
         MOVE 0 TO WS-GO
         IF WS-N > 0
             CALL "STRUCT-PORTAL-XF" USING WS-U
             IF WS-U < WS-HALF
                 MOVE 1 TO WS-GO
             END-IF
         END-IF
         IF WS-GO = 1
             SUBTRACT 1 FROM WS-Y
             SUBTRACT 1 FROM WS-N
             CALL "STRUCT-PORTAL-PLACE" USING WS-X WS-Y WS-Z WS-COLD WS-NETHER
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-PORTAL-DRIP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PORTAL-LEAVES.
*> USING x, y, z: maybeAddLeavesAbove (8.6): nextFloat() < 0.5 (the first action), the block at the position is netherrack and the one above is air: jungle_leaves[persistent=true] above.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-U                   FLOAT-LONG.
 01 WS-HALF                FLOAT-LONG VALUE 0.5.
 01 WS-KEY                 PIC X(48).
 01 WS-LEAVES              PIC X(48) VALUE "minecraft:jungle_leaves".
 01 WS-PROP                PIC X(24) VALUE "persistent".
 01 WS-TRUE                PIC X(32) VALUE "true".
 01 WS-MODE                BINARY-LONG VALUE 2.
 01 WS-STATE               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z.
     CALL "STRUCT-PORTAL-XF" USING WS-U
     IF WS-U < WS-HALF
         CALL "STRUCT-PORTAL-KEY" USING L-X L-Y L-Z WS-KEY
         COMPUTE WS-ABOVE = L-Y + 1
         IF WS-KEY = "netherrack"
             CALL "STRUCT-PORTAL-KEY" USING L-X WS-ABOVE L-Z WS-KEY
             IF WS-KEY = "air"
                 CALL "GEN-BLOCK-STATE" USING WS-LEAVES WS-STATE
                 CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-PROP WS-TRUE WS-NEW
                 CALL "FL-SET-STATE" USING L-X WS-ABOVE L-Z WS-NEW WS-FLAGS WS-OK
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM STRUCT-PORTAL-LEAVES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PORTAL-VINES.
*> USING x, y, z: maybeAddVines (8.6): a block that is not air or vine draws a horizontal direction (nextInt(4) over north, east, south, west); where the cell in that direction is air and the
*> block there is a full one (approximated by the solid and opaque flags: no collision shapes), a vine with the opposite face set is put in the neighbour.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-KEY                 PIC X(48).
 01 WS-DIR                 BINARY-LONG.
 01 WS-BOUND               BINARY-LONG VALUE 4.
 01 WS-QX                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-VINE                PIC X(48) VALUE "minecraft:vine".
 01 WS-FACES               PIC X(24) VALUE "south west  north east  ".
 01 WS-FACE                PIC X(24).
 01 WS-TRUE                PIC X(32) VALUE "true".
 01 WS-MODE                BINARY-LONG VALUE 2.
 01 WS-VINE-STATE          BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z.
     CALL "STRUCT-PORTAL-KEY" USING L-X L-Y L-Z WS-KEY
     IF WS-KEY = "air" OR WS-KEY = "vine"
         GOBACK
     END-IF
     CALL "MSP-RNG-INT" USING WS-BOUND WS-DIR
     MOVE L-X TO WS-QX
     MOVE L-Z TO WS-QZ
     EVALUATE WS-DIR
         WHEN 0
             SUBTRACT 1 FROM WS-QZ
         WHEN 1
             ADD 1 TO WS-QX
         WHEN 2
             ADD 1 TO WS-QZ
         WHEN OTHER
             SUBTRACT 1 FROM WS-QX
     END-EVALUATE
     CALL "STRUCT-PORTAL-KEY" USING WS-QX L-Y WS-QZ WS-KEY
     IF WS-KEY NOT = "air"
         GOBACK
     END-IF
     CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
     IF CB-SOLID(WS-BLOCK + 1) = 0 OR CB-OPAQUE(WS-BLOCK + 1) = 0
         GOBACK
     END-IF
*>   the vine's face is the opposite of the direction: south for north, west for east, north for south, east for west
     MOVE SPACES TO WS-FACE
     MOVE WS-FACES(WS-DIR * 6 + 1:6) TO WS-FACE
     CALL "GEN-BLOCK-STATE" USING WS-VINE WS-VINE-STATE
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-VINE-STATE WS-FACE WS-TRUE WS-NEW
     CALL "FL-SET-STATE" USING WS-QX L-Y WS-QZ WS-NEW WS-FLAGS WS-OK
     GOBACK.
 END PROGRAM STRUCT-PORTAL-VINES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PORTAL-AUX.
*> USING aux, placement out, air out, overgrown out, vines out, cold out, nether out: the properties packed in a ruined portal piece's AUX (STRUCT-PORTAL-FIND-POINT).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REST                BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-AUX                  BINARY-LONG.
 01 L-PLACEMENT            BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 01 L-OVERGROWN            BINARY-LONG.
 01 L-VINES                BINARY-LONG.
 01 L-COLD                 BINARY-LONG.
 01 L-NETHER               BINARY-LONG.
 PROCEDURE DIVISION USING L-AUX L-PLACEMENT L-AIR L-OVERGROWN L-VINES L-COLD L-NETHER.
     DIVIDE L-AUX BY 32 GIVING L-PLACEMENT REMAINDER WS-REST
     DIVIDE WS-REST BY 2 GIVING WS-Q REMAINDER L-AIR
     DIVIDE WS-Q BY 2 GIVING WS-REST REMAINDER L-OVERGROWN
     DIVIDE WS-REST BY 2 GIVING WS-Q REMAINDER L-VINES
     DIVIDE WS-Q BY 2 GIVING WS-REST REMAINDER L-COLD
     MOVE 0 TO L-NETHER
     IF L-PLACEMENT = 5
         MOVE 1 TO L-NETHER
     END-IF
     GOBACK.
 END PROGRAM STRUCT-PORTAL-AUX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PORTAL-SPREAD.
*> USING piece row: spreadNetherrack (8.5) then addNetherrackDripColumnsBelowPortal (8.6) for the piece in the window of one chunk. The piece's box is SP-X0.. of the row, its properties the AUX
*> (air 1, overgrown 2, vines 4, cold 8, blackstone 16, 32 times the placement). The heights are the live heightmap of the window (FL-HEIGHT-OF: WORLD_SURFACE_WG, OCEAN_FLOOR_WG for
*> the ocean floor); a column of another chunk reads as air there, so the cells outside the chunk of the pass are skipped (they cannot be replaced) as are their draws after the test.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-AUX                 BINARY-LONG.
 01 WS-PLACEMENT           BINARY-LONG.
 01 WS-AIR                 BINARY-LONG.
 01 WS-VINES               BINARY-LONG.
 01 WS-OVERGROWN           BINARY-LONG.
 01 WS-COLD                BINARY-LONG.
 01 WS-NETHER              BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-HEIGHTMAP           BINARY-LONG.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-AVG                 BINARY-LONG.
 01 WS-HALF-AVG            BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-OFFSET              BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 01 WS-P-09                FLOAT-SHORT VALUE 0.9.
 01 WS-P-08                FLOAT-SHORT VALUE 0.8.
 01 WS-P-07                FLOAT-SHORT VALUE 0.7.
 01 WS-P-06                FLOAT-SHORT VALUE 0.6.
 01 WS-P-04                FLOAT-SHORT VALUE 0.4.
 01 WS-P-02                FLOAT-SHORT VALUE 0.2.
 01 WS-CAN                 BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE SP-T-AUX(L-ROW) TO WS-AUX
     CALL "STRUCT-PORTAL-AUX" USING WS-AUX WS-PLACEMENT WS-AIR WS-OVERGROWN WS-VINES WS-COLD WS-NETHER
     MOVE 0 TO WS-FLAG
     IF WS-PLACEMENT = 0 OR WS-PLACEMENT = 2
         MOVE 1 TO WS-FLAG
     END-IF
     MOVE 0 TO WS-HEIGHTMAP
     IF WS-PLACEMENT = 2
         MOVE 2 TO WS-HEIGHTMAP
     END-IF
     MOVE SP-X0(L-ROW) TO B-X0
     MOVE SP-Y0(L-ROW) TO B-Y0
     MOVE SP-Z0(L-ROW) TO B-Z0
     MOVE SP-X1(L-ROW) TO B-X1
     MOVE SP-Y1(L-ROW) TO B-Y1
     MOVE SP-Z1(L-ROW) TO B-Z1
     CALL "SPB-BOX-CENTER" USING WS-BOX WS-CX WS-CY WS-CZ
*>   8.5 step 1: the offset draws one int below max(1, 8 - avg / 2)
     COMPUTE WS-AVG = ((B-X1 - B-X0 + 1) + (B-Z1 - B-Z0 + 1)) / 2
     COMPUTE WS-HALF-AVG = WS-AVG / 2
     COMPUTE WS-BOUND = FUNCTION MAX(1, 8 - WS-HALF-AVG)
     CALL "MSP-RNG-INT" USING WS-BOUND WS-OFFSET
*>   step 2: the columns around the centre, x outer, z inner
     COMPUTE WS-X0 = WS-CX - 14
     COMPUTE WS-X1 = WS-CX + 14
     COMPUTE WS-Z0 = WS-CZ - 14
     COMPUTE WS-Z1 = WS-CZ + 14
     PERFORM VARYING WS-X FROM WS-X0 BY 1 UNTIL WS-X > WS-X1
         PERFORM VARYING WS-Z FROM WS-Z0 BY 1 UNTIL WS-Z > WS-Z1
             COMPUTE WS-D = FUNCTION ABS(WS-X - WS-CX) + FUNCTION ABS(WS-Z - WS-CZ)
             COMPUTE WS-K = FUNCTION MAX(0, WS-D + WS-OFFSET)
             IF WS-K < 14
                 EVALUATE TRUE
                     WHEN WS-K < 7
                         MOVE 1 TO WS-P
                     WHEN WS-K < 9
                         MOVE WS-P-09 TO WS-P
                     WHEN WS-K = 9
                         MOVE WS-P-08 TO WS-P
                     WHEN WS-K = 10
                         MOVE WS-P-07 TO WS-P
                     WHEN WS-K = 11
                         MOVE WS-P-06 TO WS-P
                     WHEN WS-K = 12
                         MOVE WS-P-04 TO WS-P
                     WHEN OTHER
                         MOVE WS-P-02 TO WS-P
                 END-EVALUATE
                 CALL "STRUCT-PORTAL-XD" USING WS-U
                 IF WS-U < WS-P
                     CALL "FL-HEIGHT-OF" USING WS-HEIGHTMAP WS-X WS-Z WS-H
                     COMPUTE WS-SY = WS-H - 1
                     IF WS-FLAG = 1
                         MOVE WS-SY TO WS-Y
                     ELSE
                         MOVE FUNCTION MIN(B-Y0, WS-SY) TO WS-Y
                     END-IF
                     COMPUTE WS-DY = FUNCTION ABS(WS-Y - B-Y0)
                     IF WS-DY <= 3
                         CALL "STRUCT-PORTAL-CAN" USING WS-X WS-Y WS-Z WS-NETHER WS-CAN
                         IF WS-CAN = 1
                             CALL "STRUCT-PORTAL-PLACE" USING WS-X WS-Y WS-Z WS-COLD WS-NETHER
                             IF WS-OVERGROWN = 1
                                 CALL "STRUCT-PORTAL-LEAVES" USING WS-X WS-Y WS-Z
                             END-IF
                             COMPUTE WS-BELOW = WS-Y - 1
                             CALL "STRUCT-PORTAL-DRIP" USING WS-X WS-BELOW WS-Z WS-COLD WS-NETHER
                         END-IF
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-PORTAL-SPREAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PORTAL-AFTER.
*> USING piece row: the rest of postProcess of a ruined portal piece (8.4 steps 4 to 6), after the template piece's post-processing (the write box is the portal's: STRUCT-PORTAL-BEGIN):
*> the spread of netherrack, the drip columns below the portal, then for every position of the box (x fastest, then y, then z) the vines and the leaves; the write box of the chunk is put back.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY STRUCTPORTAL-WORK.
 01 WS-AUX                 BINARY-LONG.
 01 WS-PLACEMENT           BINARY-LONG.
 01 WS-AIR                 BINARY-LONG.
 01 WS-VINES               BINARY-LONG.
 01 WS-OVERGROWN           BINARY-LONG.
 01 WS-COLD                BINARY-LONG.
 01 WS-NETHER              BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "STRUCT-PORTAL-SPREAD" USING L-ROW
     MOVE SP-T-AUX(L-ROW) TO WS-AUX
     CALL "STRUCT-PORTAL-AUX" USING WS-AUX WS-PLACEMENT WS-AIR WS-OVERGROWN WS-VINES WS-COLD WS-NETHER
*>   8.6: the drip columns below the portal: the cells of its bottom layer that are netherrack drip down
     COMPUTE WS-X0 = SP-X0(L-ROW) + 1
     COMPUTE WS-Z0 = SP-Z0(L-ROW) + 1
     PERFORM VARYING WS-X FROM WS-X0 BY 1 UNTIL WS-X >= SP-X1(L-ROW)
         PERFORM VARYING WS-Z FROM WS-Z0 BY 1 UNTIL WS-Z >= SP-Z1(L-ROW)
             CALL "STRUCT-PORTAL-KEY" USING WS-X SP-Y0(L-ROW) WS-Z WS-KEY
             IF WS-KEY = "netherrack"
                 COMPUTE WS-BELOW = SP-Y0(L-ROW) - 1
                 CALL "STRUCT-PORTAL-DRIP" USING WS-X WS-BELOW WS-Z WS-COLD WS-NETHER
             END-IF
         END-PERFORM
     END-PERFORM
*>   step 6: vines and leaves over the whole box
     IF WS-VINES = 1 OR WS-OVERGROWN = 1
         PERFORM VARYING WS-Z FROM SP-Z0(L-ROW) BY 1 UNTIL WS-Z > SP-Z1(L-ROW)
             PERFORM VARYING WS-Y FROM SP-Y0(L-ROW) BY 1 UNTIL WS-Y > SP-Y1(L-ROW)
                 PERFORM VARYING WS-X FROM SP-X0(L-ROW) BY 1 UNTIL WS-X > SP-X1(L-ROW)
                     IF WS-VINES = 1
                         CALL "STRUCT-PORTAL-VINES" USING WS-X WS-Y WS-Z
                     END-IF
                     IF WS-OVERGROWN = 1
                         CALL "STRUCT-PORTAL-LEAVES" USING WS-X WS-Y WS-Z
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-IF
     MOVE PORT-SAVE(1) TO SW-X0
     MOVE PORT-SAVE(2) TO SW-Y0
     MOVE PORT-SAVE(3) TO SW-Z0
     MOVE PORT-SAVE(4) TO SW-X1
     MOVE PORT-SAVE(5) TO SW-Y1
     MOVE PORT-SAVE(6) TO SW-Z1
     GOBACK.
 END PROGRAM STRUCT-PORTAL-AFTER.
