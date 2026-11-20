*> Structure placement (docs/protocol/36-structures-1 sections 6.5 and 8; STRUCTPIECE.cpy, STRUCTBLK.cpy): the block-writing helpers the piece generators call, the per-type generation
*> hook and the decoration of a chunk by the starts around it. The level is the feature level (FEATLEVEL.cpy): one chunk column of the chunk being generated; SP-WBOX is that chunk's
*> write box (8: from minY + 1), a cell outside it is skipped by every helper (the whole piece is rebuilt by every chunk it touches, each time writing its own part).
*> Deviations: "renders solid" and "face is sturdy" are the content set's solid and opaque flags (the block tables carry no collision shapes); shape-check marks and fluid ticks of placeBlock
*> (6.5) are not made (the chunk window has no post-processing list); blocks written by structures are final states with the mirror and rotation already applied by the caller (SPB-DIR-XFORM).
*>
*> Entry points:
*>   MSP-BLOCKS: resolves STRUCT-BLOCKS for the table epoch;  MSP-OPEN: SP-WBOX from the open level
*>   MSP-GET USING row, local x y z, state out: getBlock (air outside the write box)
*>   MSP-FULL USING state, flag out: 1 for a full cube (solid and opaque)
*>   MSP-CAN-REPLACE USING row, world x y z, flag out: MineShaftPiece.canBeReplaced (36-5 2.9)
*>   MSP-PLACE USING row, local x y z, state: placeBlock (inside the write box and replaceable)
*>   MSP-BOX USING row, x0 y0 z0 x1 y1 z1, edge state, fill state, skip air: generateBox
*>   MSP-MAYBE-BOX USING row, chance (FLOAT-LONG, a single precision value), x0 y0 z0 x1 y1 z1, edge, fill, skip air, require interior: generateMaybeBox
*>   MSP-MAYBE-BLOCK USING row, chance, x y z, state: maybeGenerateBlock
*>   MSP-SPHERE USING row, x0 y0 z0 x1 y1 z1, state, skip air: generateUpperHalfSphere (single precision)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MSP-BLOCKS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY STRUCTBLK.
 01 WS-I                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(600).
 01 WS-FULL                PIC X(48).
 01 WS-LEN                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-NAMES.
    05 FILLER              PIC X(6) VALUE "south ".
    05 FILLER              PIC X(6) VALUE "west  ".
    05 FILLER              PIC X(6) VALUE "north ".
    05 FILLER              PIC X(6) VALUE "east  ".
 01 WS-DIR-NAMES REDEFINES WS-NAMES.
    05 WS-DIR-NAME         PIC X(6) OCCURS 4 TIMES.
 01 WS-WOOD-NAMES.
    05 FILLER              PIC X(10) VALUE "oak       ".
    05 FILLER              PIC X(10) VALUE "dark_oak  ".
 01 WS-WOOD-TAB REDEFINES WS-WOOD-NAMES.
    05 WS-WOOD-NAME        PIC X(10) OCCURS 2 TIMES.
 PROCEDURE DIVISION.
     IF SBK-EPOCH = CB-EPOCH + 1
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1400
         MOVE 0 TO SBK-FLAGS(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT
         CALL "KEY-NAMESPACED" USING CB-KEY(WS-I) WS-FULL
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-FULL)) TO WS-LEN
         EVALUATE TRUE
             WHEN FUNCTION TRIM(WS-FULL) = "minecraft:sand" OR "minecraft:red_sand" OR "minecraft:gravel"
                  OR "minecraft:anvil" OR "minecraft:chipped_anvil" OR "minecraft:damaged_anvil"
                  OR "minecraft:dragon_egg" OR "minecraft:suspicious_sand" OR "minecraft:suspicious_gravel"
                 MOVE 1 TO SBK-FLAGS(WS-I)
             WHEN WS-LEN > 16 AND WS-FULL(WS-LEN - 15:16) = "_concrete_powder"
                 MOVE 1 TO SBK-FLAGS(WS-I)
             WHEN FUNCTION TRIM(WS-FULL) = "minecraft:glow_lichen" OR "minecraft:seagrass" OR "minecraft:tall_seagrass"
                 MOVE 2 TO SBK-FLAGS(WS-I)
         END-EVALUATE
     END-PERFORM
     MOVE SPACES TO WS-PAIRS
     MOVE "minecraft:cave_air" TO WS-KEY
     CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS SBK-S-CAVE-AIR
     MOVE "minecraft:cobweb" TO WS-KEY
     CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS SBK-S-COBWEB
     MOVE "minecraft:spawner" TO WS-KEY
     CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS SBK-S-SPAWNER
     MOVE "minecraft:iron_chain" TO WS-KEY
     CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS SBK-S-CHAIN
     CALL "FL-BLOCK-OF" USING SBK-S-CHAIN SBK-B-CHAIN
     MOVE "minecraft:rail" TO WS-KEY
     MOVE "shape=north_south" TO WS-PAIRS
     CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS SBK-S-RAIL(1)
     MOVE "shape=east_west" TO WS-PAIRS
     CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS SBK-S-RAIL(2)
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 4
         MOVE "minecraft:wall_torch" TO WS-KEY
         MOVE SPACES TO WS-PAIRS
         STRING "facing=" FUNCTION TRIM(WS-DIR-NAME(WS-D)) DELIMITED BY SIZE INTO WS-PAIRS
         CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS SBK-S-TORCH(WS-D)
     END-PERFORM
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 2
         MOVE SPACES TO WS-KEY
         STRING "minecraft:" FUNCTION TRIM(WS-WOOD-NAME(WS-T)) "_planks" DELIMITED BY SIZE INTO WS-KEY
         MOVE SPACES TO WS-PAIRS
         CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS SBK-PLANKS-S(WS-T)
         CALL "FL-BLOCK-OF" USING SBK-PLANKS-S(WS-T) SBK-PLANKS-B(WS-T)
         MOVE SPACES TO WS-KEY
         STRING "minecraft:" FUNCTION TRIM(WS-WOOD-NAME(WS-T)) "_log" DELIMITED BY SIZE INTO WS-KEY
         CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS SBK-LOG-S(WS-T)
         CALL "FL-BLOCK-OF" USING SBK-LOG-S(WS-T) SBK-LOG-B(WS-T)
         MOVE SPACES TO WS-KEY
         STRING "minecraft:" FUNCTION TRIM(WS-WOOD-NAME(WS-T)) "_fence" DELIMITED BY SIZE INTO WS-KEY
         PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 4
             MOVE SPACES TO WS-PAIRS
             STRING FUNCTION TRIM(WS-DIR-NAME(WS-D)) "=true" DELIMITED BY SIZE INTO WS-PAIRS
             CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS SBK-FENCE-S(WS-T, WS-D)
         END-PERFORM
         CALL "FL-BLOCK-OF" USING SBK-FENCE-S(WS-T, 1) SBK-FENCE-B(WS-T)
         MOVE SPACES TO WS-PAIRS
         CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS SBK-FENCE-P(WS-T)
     END-PERFORM
     COMPUTE SBK-EPOCH = CB-EPOCH + 1
     GOBACK.
 END PROGRAM MSP-BLOCKS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MSP-OPEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATLEVEL.
 COPY STRUCTPIECE.
 PROCEDURE DIVISION.
     CALL "MSP-BLOCKS"
     COMPUTE SW-X0 = FL-CX * 16
     COMPUTE SW-Z0 = FL-CZ * 16
     COMPUTE SW-X1 = SW-X0 + 15
     COMPUTE SW-Z1 = SW-Z0 + 15
     COMPUTE SW-Y0 = FL-MIN-Y + 1
     COMPUTE SW-Y1 = FL-MIN-Y + FL-HEIGHT - 1
     GOBACK.
 END PROGRAM MSP-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MSP-GET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATLEVEL.
 COPY STRUCTPIECE.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-STATE.
     CALL "SPB-WORLD" USING L-ROW L-X L-Y L-Z WS-WX WS-WY WS-WZ
     CALL "SPB-BOX-INSIDE" USING SP-WBOX WS-WX WS-WY WS-WZ WS-IN
     MOVE FL-S-AIR TO L-STATE
     IF WS-IN = 1
         CALL "FL-GET-STATE" USING WS-WX WS-WY WS-WZ L-STATE
     END-IF
     GOBACK.
 END PROGRAM MSP-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MSP-FULL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-B                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FLAG.
     MOVE 0 TO L-FLAG
     CALL "FL-BLOCK-OF" USING L-STATE WS-B
     IF WS-B > 0
         IF CB-SOLID(WS-B) = 1 AND CB-OPAQUE(WS-B) = 1
             MOVE 1 TO L-FLAG
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MSP-FULL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MSP-CAN-REPLACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY STRUCTBLK.
 COPY FEATLEVEL.
 01 WS-IN                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-FLAG.
     MOVE 1 TO L-FLAG
     CALL "SPB-BOX-INSIDE" USING SP-WBOX L-X L-Y L-Z WS-IN
     IF WS-IN = 1
         CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
         CALL "FL-BLOCK-OF" USING WS-STATE WS-B
         COMPUTE WS-T = SP-MST(L-ROW) + 1
         IF WS-B > 0
             IF WS-B = SBK-PLANKS-B(WS-T) OR WS-B = SBK-LOG-B(WS-T) OR WS-B = SBK-FENCE-B(WS-T) OR WS-B = SBK-B-CHAIN
                 MOVE 0 TO L-FLAG
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MSP-CAN-REPLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MSP-PLACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-CAN                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-STATE.
     CALL "SPB-WORLD" USING L-ROW L-X L-Y L-Z WS-WX WS-WY WS-WZ
     CALL "SPB-BOX-INSIDE" USING SP-WBOX WS-WX WS-WY WS-WZ WS-IN
     IF WS-IN = 1
         CALL "MSP-CAN-REPLACE" USING L-ROW WS-WX WS-WY WS-WZ WS-CAN
         IF WS-CAN = 1
             CALL "FL-SET-STATE" USING WS-WX WS-WY WS-WZ L-STATE WS-FLAGS WS-OK
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MSP-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MSP-BOX.
*> generateBox with fixed states (6.5): y outermost, then x, then z; an edge cell is on a face of the box; skipAir leaves cells that already hold air.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 01 L-EDGE                 BINARY-LONG.
 01 L-FILL                 BINARY-LONG.
 01 L-SKIP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1 L-EDGE L-FILL L-SKIP.
     PERFORM VARYING WS-Y FROM L-Y0 BY 1 UNTIL WS-Y > L-Y1
         PERFORM VARYING WS-X FROM L-X0 BY 1 UNTIL WS-X > L-X1
             PERFORM VARYING WS-Z FROM L-Z0 BY 1 UNTIL WS-Z > L-Z1
                 MOVE 0 TO WS-CLASS
                 IF L-SKIP = 1
                     CALL "MSP-GET" USING L-ROW WS-X WS-Y WS-Z WS-STATE
                     CALL "FL-CLASS" USING WS-STATE WS-CLASS
                 END-IF
                 IF WS-CLASS NOT = 1
                     IF WS-Y = L-Y0 OR WS-Y = L-Y1 OR WS-X = L-X0 OR WS-X = L-X1 OR WS-Z = L-Z0 OR WS-Z = L-Z1
                         CALL "MSP-PLACE" USING L-ROW WS-X WS-Y WS-Z L-EDGE
                     ELSE
                         CALL "MSP-PLACE" USING L-ROW WS-X WS-Y WS-Z L-FILL
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM MSP-BOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MSP-MAYBE-BOX.
*> generateMaybeBox (6.5): one nextFloat of the decoration random for every cell first, a cell is skipped when the draw is above the chance, then when skipAir and air, then when an
*> interior is required and the cell is not.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-XR== LEADING ==XR-== BY ==WX-==.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-DRAW                FLOAT-LONG.
 01 WS-SKIP                BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-CHANCE               FLOAT-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 01 L-EDGE                 BINARY-LONG.
 01 L-FILL                 BINARY-LONG.
 01 L-SKIPAIR              BINARY-LONG.
 01 L-INTERIOR             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-CHANCE L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1 L-EDGE L-FILL L-SKIPAIR L-INTERIOR.
     PERFORM VARYING WS-Y FROM L-Y0 BY 1 UNTIL WS-Y > L-Y1
         PERFORM VARYING WS-X FROM L-X0 BY 1 UNTIL WS-X > L-X1
             PERFORM VARYING WS-Z FROM L-Z0 BY 1 UNTIL WS-Z > L-Z1
                 MOVE SP-XR-LO TO WX-LO
                 MOVE SP-XR-HI TO WX-HI
                 CALL "WGR-NEXT-FLOAT" USING WS-XR WS-DRAW
                 MOVE WX-LO TO SP-XR-LO
                 MOVE WX-HI TO SP-XR-HI
                 MOVE 0 TO WS-SKIP
                 IF WS-DRAW > L-CHANCE
                     MOVE 1 TO WS-SKIP
                 END-IF
                 IF WS-SKIP = 0 AND L-SKIPAIR = 1
                     CALL "MSP-GET" USING L-ROW WS-X WS-Y WS-Z WS-STATE
                     CALL "FL-CLASS" USING WS-STATE WS-CLASS
                     IF WS-CLASS = 1
                         MOVE 1 TO WS-SKIP
                     END-IF
                 END-IF
                 IF WS-SKIP = 0 AND L-INTERIOR = 1
                     CALL "MSP-INTERIOR" USING L-ROW WS-X WS-Y WS-Z WS-INT
                     IF WS-INT = 0
                         MOVE 1 TO WS-SKIP
                     END-IF
                 END-IF
                 IF WS-SKIP = 0
                     IF WS-Y = L-Y0 OR WS-Y = L-Y1 OR WS-X = L-X0 OR WS-X = L-X1 OR WS-Z = L-Z0 OR WS-Z = L-Z1
                         CALL "MSP-PLACE" USING L-ROW WS-X WS-Y WS-Z L-EDGE
                     ELSE
                         CALL "MSP-PLACE" USING L-ROW WS-X WS-Y WS-Z L-FILL
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM MSP-MAYBE-BOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MSP-MAYBE-BLOCK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-XR== LEADING ==XR-== BY ==WX-==.
 01 WS-DRAW                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-CHANCE               FLOAT-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-CHANCE L-X L-Y L-Z L-STATE.
     MOVE SP-XR-LO TO WX-LO
     MOVE SP-XR-HI TO WX-HI
     CALL "WGR-NEXT-FLOAT" USING WS-XR WS-DRAW
     MOVE WX-LO TO SP-XR-LO
     MOVE WX-HI TO SP-XR-HI
     IF WS-DRAW < L-CHANCE
         CALL "MSP-PLACE" USING L-ROW L-X L-Y L-Z L-STATE
     END-IF
     GOBACK.
 END PROGRAM MSP-MAYBE-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MSP-SPHERE.
*> generateUpperHalfSphere (6.5): centre x0 + sx / 2 and z0 + sz / 2, ny = (y - y0) / sy, nx = (x - cx) / (sx * 0.5), nz likewise, a cell is written when nx^2 + ny^2 + nz^2 <= 1.05, every
*> operation rounded to single precision (a double operation on single values rounded once is the single result).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-SX                  FLOAT-LONG.
 01 WS-SY                  FLOAT-LONG.
 01 WS-SZ                  FLOAT-LONG.
 01 WS-CX                  FLOAT-LONG.
 01 WS-CZ                  FLOAT-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-NX                  FLOAT-LONG.
 01 WS-NY                  FLOAT-LONG.
 01 WS-NZ                  FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-SUM                 FLOAT-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-LIMIT               FLOAT-LONG VALUE 1.0499999523162842.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-SKIP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1 L-STATE L-SKIP.
     COMPUTE WS-SX = L-X1 - L-X0 + 1
     COMPUTE WS-SY = L-Y1 - L-Y0 + 1
     COMPUTE WS-SZ = L-Z1 - L-Z0 + 1
     COMPUTE WS-CX = L-X0 + WS-SX / 2
     COMPUTE WS-CZ = L-Z0 + WS-SZ / 2
     COMPUTE WS-HX = WS-SX * 0.5
     COMPUTE WS-HZ = WS-SZ * 0.5
     PERFORM VARYING WS-Y FROM L-Y0 BY 1 UNTIL WS-Y > L-Y1
         COMPUTE WS-T = (WS-Y - L-Y0) / WS-SY
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-NY
         PERFORM VARYING WS-X FROM L-X0 BY 1 UNTIL WS-X > L-X1
             COMPUTE WS-T = (WS-X - WS-CX) / WS-HX
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-NX
             PERFORM VARYING WS-Z FROM L-Z0 BY 1 UNTIL WS-Z > L-Z1
                 MOVE 0 TO WS-CLASS
                 IF L-SKIP = 1
                     CALL "MSP-GET" USING L-ROW WS-X WS-Y WS-Z WS-STATE
                     CALL "FL-CLASS" USING WS-STATE WS-CLASS
                 END-IF
                 IF WS-CLASS NOT = 1
                     COMPUTE WS-T = (WS-Z - WS-CZ) / WS-HZ
                     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-NZ
                     COMPUTE WS-T = WS-NX * WS-NX
                     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-SUM
                     COMPUTE WS-T = WS-NY * WS-NY
                     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-R
                     COMPUTE WS-T = WS-SUM + WS-R
                     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-SUM
                     COMPUTE WS-T = WS-NZ * WS-NZ
                     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-R
                     COMPUTE WS-T = WS-SUM + WS-R
                     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-SUM
                     IF WS-SUM <= WS-LIMIT
                         CALL "MSP-PLACE" USING L-ROW WS-X WS-Y WS-Z L-STATE
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM MSP-SPHERE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-FIND-POINT.
*> USING structure row, seed (BINARY-DOUBLE), chunk x, chunk z, stub x out, stub y out, stub z out, valid out: findGenerationPoint of the structure's type (36-1 5.3). The mineshaft builds
*> its pieces (MS-FIND-POINT, sea level 63 and min y -64 of the overworld) and leaves them in the builder; the stronghold builds its pieces (SH-FIND-POINT, struct-stronghold.cob); the woodland mansion its template pieces (MAN-FIND-POINT, struct-man-start.cob); the igloo and the shipwreck build template pieces (STRUCT-TPL-FIND-POINT); the swamp hut, the jungle temple and the desert pyramid build scattered pieces (STRUCT-SCATTER-FIND-POINT);
*> any other type has no generator yet: the stub is the chunk's middle column at y 0, valid, with no piece.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-NAME                PIC X(40) VALUE "mineshaft".
 01 WS-JIGSAW-NAME         PIC X(40) VALUE "jigsaw".
 01 WS-JIGSAW-ID           BINARY-LONG.
 01 WS-PORTAL-NAME         PIC X(40) VALUE "ruined_portal".
 01 WS-PORTAL-ID           BINARY-LONG.
 01 WS-STRONG-NAME         PIC X(40) VALUE "stronghold".
 01 WS-STRONG-ID           BINARY-LONG.
 01 WS-MANSION-NAME        PIC X(40) VALUE "woodland_mansion".
 01 WS-MANSION-ID          BINARY-LONG.
 01 WS-FORTRESS-NAME       PIC X(40) VALUE "fortress".
 01 WS-FORTRESS-ID         BINARY-LONG.
 01 WS-ENDCITY-NAME        PIC X(40) VALUE "end_city".
 01 WS-ENDCITY-ID          BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-MIN-Y               BINARY-LONG VALUE -64.
 01 WS-DONE                BINARY-LONG.
 01 WS-FLAT-WORLD          BINARY-LONG.
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
*>   the sea level of a superflat world is -63 (56 section 4.1), not 63
     MOVE 63 TO WS-SEA
     CALL "WORLD-IS-FLAT" USING WS-FLAT-WORLD
     IF WS-FLAT-WORLD = 1
         MOVE -63 TO WS-SEA
     END-IF
     CALL "STRUCT-ENUM-ID" USING WS-KIND WS-NAME WS-ID
     IF SDT-TYPE(L-STRUCT) = WS-ID
         CALL "MS-FIND-POINT" USING L-SEED L-CX L-CZ SDT-VARIANT(L-STRUCT) WS-SEA WS-MIN-Y L-X L-Y L-Z L-VALID
     ELSE
         CALL "STRUCT-ENUM-ID" USING WS-KIND WS-JIGSAW-NAME WS-JIGSAW-ID
         MOVE 0 TO WS-DONE
         IF SDT-TYPE(L-STRUCT) = WS-JIGSAW-ID
             MOVE 1 TO WS-DONE
             CALL "JIG-FIND-POINT" USING L-STRUCT L-SEED L-CX L-CZ L-X L-Y L-Z L-VALID
         END-IF
         CALL "STRUCT-ENUM-ID" USING WS-KIND WS-STRONG-NAME WS-STRONG-ID
         IF SDT-TYPE(L-STRUCT) = WS-STRONG-ID
             MOVE 1 TO WS-DONE
             CALL "SH-FIND-POINT" USING L-SEED L-CX L-CZ WS-SEA WS-MIN-Y L-X L-Y L-Z L-VALID
         END-IF
         CALL "STRUCT-ENUM-ID" USING WS-KIND WS-MANSION-NAME WS-MANSION-ID
         IF SDT-TYPE(L-STRUCT) = WS-MANSION-ID
             MOVE 1 TO WS-DONE
             CALL "MAN-FIND-POINT" USING L-SEED L-CX L-CZ L-X L-Y L-Z L-VALID
         END-IF
         CALL "STRUCT-ENUM-ID" USING WS-KIND WS-FORTRESS-NAME WS-FORTRESS-ID
         IF SDT-TYPE(L-STRUCT) = WS-FORTRESS-ID
             MOVE 1 TO WS-DONE
             CALL "FORT-FIND-POINT" USING L-SEED L-CX L-CZ L-X L-Y L-Z L-VALID
         END-IF
         CALL "STRUCT-ENUM-ID" USING WS-KIND WS-ENDCITY-NAME WS-ENDCITY-ID
         IF SDT-TYPE(L-STRUCT) = WS-ENDCITY-ID
             MOVE 1 TO WS-DONE
             CALL "ENDCITY-FIND-POINT" USING L-SEED L-CX L-CZ L-X L-Y L-Z L-VALID
         END-IF
         CALL "STRUCT-ENUM-ID" USING WS-KIND WS-PORTAL-NAME WS-PORTAL-ID
         IF SDT-TYPE(L-STRUCT) = WS-PORTAL-ID
             MOVE 1 TO WS-DONE
             CALL "STRUCT-PORTAL-FIND-POINT" USING L-STRUCT L-SEED L-CX L-CZ L-X L-Y L-Z L-VALID
         END-IF
         IF WS-DONE = 0
             CALL "STRUCT-TPL-FIND-POINT" USING L-STRUCT L-SEED L-CX L-CZ L-X L-Y L-Z L-VALID WS-DONE
         END-IF
         IF WS-DONE = 0
             CALL "STRUCT-SCATTER-FIND-POINT" USING L-STRUCT L-SEED L-CX L-CZ L-X L-Y L-Z L-VALID WS-DONE
         END-IF
         IF WS-DONE = 0
             COMPUTE L-X = L-CX * 16 + 8
             MOVE 0 TO L-Y
             COMPUTE L-Z = L-CZ * 16 + 8
             MOVE 1 TO L-VALID
         END-IF
     END-IF
     GOBACK.
 END PROGRAM STRUCT-FIND-POINT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-STUB-OK.
*> USING structure row, seed (BINARY-DOUBLE), chunk x, chunk z, valid out: 1 when the structure makes a start in the chunk (the start of 36-1 5.3: a generation point whose stub position has a biome of the structure),
*> asked without building the pieces where the generator allows it (SD-STUB-ONLY: the jigsaw assembly, the scattered pieces' corner heights after the biome, the mansion layout). The answer is that of
*> STRUCT-FIND-POINT followed by STRUCT-VALID-AT (the validity test of STRUCT-CHUNK-STARTS-RAW), which the locate search (cmd-locate.cob) needs for every cell it looks at.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-STRUCT               BINARY-LONG.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING L-STRUCT L-SEED L-CX L-CZ L-VALID.
     MOVE 1 TO SD-STUB-ONLY
     CALL "STRUCT-FIND-POINT" USING L-STRUCT L-SEED L-CX L-CZ WS-X WS-Y WS-Z L-VALID
     MOVE 0 TO SD-STUB-ONLY
     IF L-VALID = 1
         CALL "STRUCT-VALID-AT" USING L-STRUCT WS-X WS-Y WS-Z L-VALID
     END-IF
     GOBACK.
 END PROGRAM STRUCT-STUB-OK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PLACE-START.
*> StructureStart.placeInChunk (36-1 8): every piece of the builder whose box intersects the writable area (the chunk's box from min y + 1) is post-processed in list order; the pivot and
*> afterPlace is only the desert pyramid's (SCP-DESERT-AFTER, after the pieces).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-I                   BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 PROCEDURE DIVISION.
*>   The pivot (36-1 8): the centre x, the min y and the centre z of the first piece's box.
     IF SP-COUNT > 0
         CALL "SPB-BOX-CENTER" USING SP-BOX(1) SP-PIV-X WS-CY SP-PIV-Z
         MOVE SP-Y0(1) TO SP-PIV-Y
     END-IF
     CALL "SCP-RESET"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SP-COUNT
         CALL "SPB-BOX-INTERSECTS" USING SP-BOX(WS-I) SP-WBOX WS-FLAG
         IF WS-FLAG = 1
             EVALUATE TRUE
                 WHEN SP-TYPE(WS-I) = 100
                     CALL "STRUCT-TPL-POST" USING WS-I
                 WHEN SP-TYPE(WS-I) = 60
                     CALL "JIG-POST" USING WS-I
                 WHEN SP-TYPE(WS-I) > 100
                     CALL "SCP-POST" USING WS-I
                 WHEN SP-TYPE(WS-I) >= 19 AND SP-TYPE(WS-I) <= 31
                     CALL "SH-POST" USING WS-I
                 WHEN SP-TYPE(WS-I) >= 4 AND SP-TYPE(WS-I) <= 18
                     CALL "FORT-POST" USING WS-I
                 WHEN OTHER
                     CALL "MS-POST" USING WS-I
             END-EVALUATE
         END-IF
     END-PERFORM
     CALL "SCP-DESERT-AFTER"
     CALL "MAN-AFTER"
     GOBACK.
 END PROGRAM STRUCT-PLACE-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-DECORATE.
*> USING job: the structure part of decoration (36-1 8) for the decoration step GJ-SUB of the chunk: for each structure of the step that is on, in registry listing order (the sorted keys,
*> the index k among the structures of the step), setFeatureSeed(decorationSeed, k, step) once, then every start of that structure in the chunks within 8 of this one, x outer and z
*> inner (7.4: a start whose box reaches the chunk references it), is rebuilt from the seed (the generator is a pure function of seed and chunk) and placed into this chunk. Nothing is
*> done when no structure of the step is on. The requests for block entities the pieces made go to the job (GBE-KEEP).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 COPY CARVER.
 COPY STRUCTPIECE.
 COPY FEATLEVEL.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-XR== LEADING ==XR-== BY ==WX-==.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-M63                 PIC 9(20) VALUE 9223372036854775808.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-STEP                BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-R2                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-ON                  BINARY-LONG.
 01 WS-ANY                 BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-DECOR               BINARY-DOUBLE UNSIGNED.
 01 WS-FSEED               BINARY-DOUBLE UNSIGNED.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 WS-OBOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==O-==.
 01 WS-REACH               BINARY-LONG.
 01 WS-CHUNK               BINARY-LONG.
 01 WS-MIN-Y               BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-FLAT-WORLD          BINARY-LONG.
 01 WS-INFLATE             BINARY-LONG VALUE 12.
 01 WS-COUNT               BINARY-LONG.
 01 WS-IX                  BINARY-LONG.
 01 WS-IZ                  BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-WIN-N               BINARY-LONG.
 01 WS-WIN.
    05 WS-WIN-REC OCCURS 18496 TIMES.
       10 WW-X             BINARY-LONG.
       10 WW-Z             BINARY-LONG.
       10 WW-STRUCT        BINARY-LONG.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 PROCEDURE DIVISION USING L-JOB.
     MOVE J-SUB TO WS-STEP
     MOVE 0 TO WS-ANY
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > SD-ST-COUNT
         MOVE SDT-KEY(WS-R) TO WS-KEY
         CALL "STRUCT-GATE" USING WS-KEY WS-ON
         IF WS-ON = 1 AND SDT-STEP(WS-R) = WS-STEP
             MOVE 1 TO WS-ANY
         END-IF
     END-PERFORM
     IF WS-ANY = 0
         GOBACK
     END-IF
     COMPUTE WS-SEED = FUNCTION MOD(CV-SEED + WS-M63, WS-M64) - WS-M63
     MOVE WS-SEED TO SP-SEED
     MOVE 63 TO WS-SEA
     CALL "WORLD-IS-FLAT" USING WS-FLAT-WORLD
     IF WS-FLAT-WORLD = 1
         MOVE -63 TO WS-SEA
     END-IF
     CALL "FL-OPEN" USING J-ADDR J-CX J-CZ WS-MIN-Y WS-HEIGHT WS-SEA
     CALL "MSP-OPEN"
     COMPUTE WS-BX = J-CX * 16
     COMPUTE WS-BZ = J-CZ * 16
     CALL "ORE-DECOR-SEED" USING CV-SEED WS-BX WS-BZ WS-XR WS-DECOR
*>   the starts of the 17 x 17 chunks around this one, once for every structure of the step: in scan order (x outer, z inner), as (x, z, structure row)
     MOVE 0 TO WS-WIN-N
     PERFORM VARYING WS-IX FROM 0 BY 1 UNTIL WS-IX > 16
         COMPUTE WS-SX = J-CX - 8 + WS-IX
         PERFORM VARYING WS-IZ FROM 0 BY 1 UNTIL WS-IZ > 16
             COMPUTE WS-SZ = J-CZ - 8 + WS-IZ
             CALL "STRUCT-CHUNK-STARTS" USING WS-SEED WS-SX WS-SZ WS-N
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
                 ADD 1 TO WS-WIN-N
                 MOVE WS-SX TO WW-X(WS-WIN-N)
                 MOVE WS-SZ TO WW-Z(WS-WIN-N)
                 MOVE SC-STRUCT(WS-I) TO WW-STRUCT(WS-WIN-N)
             END-PERFORM
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > SD-ST-COUNT
         MOVE SDT-KEY(WS-R) TO WS-KEY
         CALL "STRUCT-GATE" USING WS-KEY WS-ON
         IF WS-ON = 1 AND SDT-STEP(WS-R) = WS-STEP
*>           k: the index of the structure among those of the step in registry (sorted key) order
             MOVE 0 TO WS-K
             PERFORM VARYING WS-R2 FROM 1 BY 1 UNTIL WS-R2 > SD-ST-COUNT
                 IF SDT-STEP(WS-R2) = WS-STEP AND SDT-KEY(WS-R2) < SDT-KEY(WS-R)
                     ADD 1 TO WS-K
                 END-IF
             END-PERFORM
             CALL "ORE-FEATURE-SEED" USING WS-DECOR WS-K WS-STEP WS-FSEED
             CALL "WGR-SET-SEED" USING WS-XR WS-FSEED
             MOVE WX-LO TO SP-XR-LO
             MOVE WX-HI TO SP-XR-HI
             PERFORM VARYING WS-W FROM 1 BY 1 UNTIL WS-W > WS-WIN-N
                 IF WW-STRUCT(WS-W) = WS-R
                     MOVE WW-X(WS-W) TO WS-SX
                     MOVE WW-Z(WS-W) TO WS-SZ
                     CALL "STRUCT-FIND-POINT" USING WS-R WS-SEED WS-SX WS-SZ WS-X WS-Y WS-Z WS-VALID
                     IF SP-COUNT > 0
                         CALL "SPB-UNION-ALL" USING WS-BOX
                         MOVE WS-BOX TO WS-OBOX
                         IF SDT-ADAPT(WS-R) NOT = 0
                             CALL "SPB-BOX-INFLATE" USING WS-BOX WS-INFLATE
                         END-IF
                         CALL "SPB-BOX-INTERSECTS-XZ" USING WS-BOX SP-WBOX WS-CHUNK
                         IF WS-CHUNK = 1
                             CALL "STRUCT-PLACE-START"
*>                           the boxes of a structure that overrides the spawn lists, once the pieces have their final heights (struct-override.cob)
                             CALL "STRUCT-OVR-NOTE-ADAPT" USING SDT-KEY(WS-R) J-CX J-CZ WS-OBOX SDT-ADAPT(WS-R)
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     MOVE 0 TO FL-OV-COUNT FL-OV-LOST
     CALL "FL-CLOSE"
     CALL "GBE-KEEP" USING L-JOB
     CALL "GENT-KEEP" USING L-JOB
     GOBACK.
 END PROGRAM STRUCT-DECORATE.
