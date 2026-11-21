*> The Nether's surface pass (docs/protocol/37-nether-4 sections 2 to 5; T1675 to T1682): the column procedure of 10 section 10.1 over the filled
*> chunk, the surface depth from the legacy surface noise (4, item 6), the bedrock gradients with the legacy factories (5.2) and the complete
*> minecraft:nether material rule tree (5): bedrock floor and roof, the netherrack cap at y >= 122, then the basalt_deltas, soul_sand_valley, on-floor
*> (lava below y 32, the forests' nylium and wart blocks) and nether_wastes rules, and netherrack as the fallthrough. Biomes of a block come from
*> the zoomed lookup (nether-37-3.cob); noise values are cached per column.
*>
*> Entry points (state in NETHER.cpy):
*>   NETHER-COLNOISE USING which (1 to 7, NETHER-NOISE-DEF), x, z (BINARY-LONG), value out (FLOAT-LONG): N.get(x, 0, z), cached for the column.
*>   NETHER-NOISE-GE USING which, x, z, threshold kind (1: -0.012, 2: 0.0, 3: 0.54, 4: 1.17), result out (1 when min <= value).
*>   NETHER-GRADIENT-AT USING which (1 floor, 2 roof), x, y, z, result out (1 when the vertical gradient condition is true).
*>   NETHER-SURFACE-DEPTH USING x, z, depth out: (int)(surface.get(x, 0, z) * 2.75 + 3.0 + R.nextDouble() * 0.25), R = P.at(x, 0, z).
*>   NETHER-RULE USING x, y, z, stone depth above, stone depth below, surface depth (BINARY-LONG), state out: the rule tree at one block.
*>   NETHER-SURFACE USING chunk memory, chunk x, chunk z: the surface pass of the chunk (needs NETHER-STATES, the filled chunk and the biome ring).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-COLNOISE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NETHER.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG VALUE 0.
 01 WS-Z                   FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-WHICH                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-WHICH L-X L-Z L-VALUE.
     IF L-X NOT = NH-CC-X OR L-Z NOT = NH-CC-Z
         MOVE L-X TO NH-CC-X
         MOVE L-Z TO NH-CC-Z
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
             MOVE 0 TO NH-CC-HAVE(WS-I)
         END-PERFORM
     END-IF
     IF NH-CC-HAVE(L-WHICH) = 0
         MOVE L-X TO WS-X
         MOVE L-Z TO WS-Z
         CALL "NOISE-GET" USING NH-H-NOISE(L-WHICH) WS-X WS-Y WS-Z NH-CC-VAL(L-WHICH)
         MOVE 1 TO NH-CC-HAVE(L-WHICH)
     END-IF
     MOVE NH-CC-VAL(L-WHICH) TO L-VALUE
     GOBACK.
 END PROGRAM NETHER-COLNOISE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-NOISE-GE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-TEXT-A              PIC X(16) VALUE Z"-0.012".
 01 WS-TEXT-B              PIC X(16) VALUE Z"0.54".
 01 WS-TEXT-C              PIC X(16) VALUE Z"1.17".
 01 WS-MIN                 FLOAT-LONG OCCURS 4 TIMES.
 01 WS-V                   FLOAT-LONG.
 01 WS-GT                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-WHICH                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-WHICH L-X L-Z L-KIND L-RESULT.
     IF WS-READY = 0
         CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-TEXT-A WS-MIN(1)
         MOVE 0 TO WS-MIN(2)
         CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-TEXT-B WS-MIN(3)
         CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-TEXT-C WS-MIN(4)
         MOVE 1 TO WS-READY
     END-IF
     CALL "NETHER-COLNOISE" USING L-WHICH L-X L-Z WS-V
*>   min <= value, both sides doubles (the float noise value widened)
     CALL "FCMP-GT" USING WS-MIN(L-KIND) WS-V WS-GT
     COMPUTE L-RESULT = 1 - WS-GT
     GOBACK.
 END PROGRAM NETHER-NOISE-GE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-GRADIENT-AT.
*> The vertical_gradient condition (10 section 10.4, 37-4 section 5.2): true at and below the true anchor, false at and above the false anchor,
*> else true when F.at(x, y, z).nextFloat() < t, t = map(y, trueAt, falseAt, 1.0, 0.0), F the legacy factory of the named gradient.
*> The floor runs from y 0 (true) to y 5 (false), the roof from y 122 (true) to y 127 (false).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NETHER.
 01 WS-TRUE-AT             BINARY-LONG.
 01 WS-FALSE-AT            BINARY-LONG.
 01 WS-FS                  BINARY-DOUBLE UNSIGNED.
 01 WS-R                   BINARY-DOUBLE UNSIGNED.
 01 WS-F                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-D                   BINARY-LONG.
 01 WS-GT                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-WHICH                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-WHICH L-X L-Y L-Z L-RESULT.
     IF L-WHICH = 1
         MOVE 0 TO WS-TRUE-AT
         MOVE 5 TO WS-FALSE-AT
         MOVE NH-FLOOR-FS TO WS-FS
     ELSE
         MOVE 122 TO WS-TRUE-AT
         MOVE 127 TO WS-FALSE-AT
         MOVE NH-ROOF-FS TO WS-FS
     END-IF
     EVALUATE TRUE
         WHEN L-Y <= WS-TRUE-AT
             MOVE 1 TO L-RESULT
         WHEN L-Y >= WS-FALSE-AT
             MOVE 0 TO L-RESULT
         WHEN OTHER
             COMPUTE WS-D = L-Y - WS-TRUE-AT
             MOVE WS-D TO WS-A
             COMPUTE WS-D = WS-FALSE-AT - WS-TRUE-AT
             MOVE WS-D TO WS-B
             CALL STATIC "cc_f64_div" USING BY REFERENCE WS-A WS-B WS-T
             CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-ONE WS-T WS-A
             CALL "NETHER-AT" USING WS-FS L-X L-Y L-Z WS-R
             CALL "JRAND-NEXT-FLOAT" USING WS-R WS-F
             CALL "FCMP-GT" USING WS-A WS-F WS-GT
             MOVE WS-GT TO L-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM NETHER-GRADIENT-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-SURFACE-DEPTH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NETHER.
 01 WS-K275                FLOAT-LONG VALUE 2.75.
 01 WS-K3                  FLOAT-LONG VALUE 3.
 01 WS-K025                FLOAT-LONG VALUE 0.25.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE-L               BINARY-LONG VALUE 1.
 01 WS-S                   FLOAT-LONG.
 01 WS-R                   BINARY-DOUBLE UNSIGNED.
 01 WS-D                   FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DEPTH                BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Z L-DEPTH.
     CALL "NETHER-COLNOISE" USING WS-ONE-L L-X L-Z WS-S
     CALL "NETHER-AT" USING NH-FS L-X WS-ZERO L-Z WS-R
     CALL "NETHER-RAND-DOUBLE" USING WS-R WS-D
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-S WS-K275 WS-A
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-A WS-K3 WS-B
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-D WS-K025 WS-A
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-B WS-A WS-D
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-D L-DEPTH
     GOBACK.
 END PROGRAM NETHER-SURFACE-DEPTH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-RULE.
*> The tree of 5 at one block with y between 0 and 127: rules 1 and 2 (bedrock gradients), 3 (netherrack from y 122), 4 to 7 by biome, 8 netherrack.
*> Conditions: under_floor sda <= 1 + sd, on_floor sda <= 1, under_ceiling sdb <= 1 + sd, hole sd <= 0, y_above(n, add_stone_depth) y (+ sda) >= n.
*> When none of the three stone-depth conditions holds every rule from 4 to 7 fails, so the biome is not looked up (the result is netherrack).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NETHER.
 01 WS-G                   BINARY-LONG.
 01 WS-UF                  BINARY-LONG.
 01 WS-OF                  BINARY-LONG.
 01 WS-UC                  BINARY-LONG.
 01 WS-HOLE                BINARY-LONG.
 01 WS-LIM                 BINARY-LONG.
 01 WS-YS                  BINARY-LONG.
 01 WS-BIOME               BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-PATCH               BINARY-LONG.
 01 WS-SEL                 BINARY-LONG.
 01 WS-BAND                BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-K-PATCH             BINARY-LONG VALUE 7.
 01 WS-K-SEL               BINARY-LONG VALUE 2.
 01 WS-K-NR                BINARY-LONG VALUE 3.
 01 WS-K-WART              BINARY-LONG VALUE 4.
 01 WS-K-SOUL              BINARY-LONG VALUE 5.
 01 WS-K-GRAVEL            BINARY-LONG VALUE 6.
 01 WS-T-A                 BINARY-LONG VALUE 1.
 01 WS-T-B                 BINARY-LONG VALUE 2.
 01 WS-T-C                 BINARY-LONG VALUE 3.
 01 WS-T-D                 BINARY-LONG VALUE 4.
 01 WS-FLOOR               BINARY-LONG VALUE 1.
 01 WS-ROOF                BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-SDA                  BINARY-LONG.
 01 L-SDB                  BINARY-LONG.
 01 L-SD                   BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-SDA L-SDB L-SD L-STATE.
     MOVE NH-S-NETHERRACK TO L-STATE
     MOVE 0 TO WS-DONE
*>   1: the floor bedrock
     IF L-Y <= 0
         MOVE NH-S-BEDROCK TO L-STATE
         GOBACK
     END-IF
     IF L-Y < 5
         CALL "NETHER-GRADIENT-AT" USING WS-FLOOR L-X L-Y L-Z WS-G
         IF WS-G = 1
             MOVE NH-S-BEDROCK TO L-STATE
             GOBACK
         END-IF
     END-IF
*>   2: the roof bedrock, where the gradient is false
     IF L-Y >= 123
         CALL "NETHER-GRADIENT-AT" USING WS-ROOF L-X L-Y L-Z WS-G
         IF WS-G = 0
             MOVE NH-S-BEDROCK TO L-STATE
             GOBACK
         END-IF
     END-IF
*>   3: the netherrack cap
     IF L-Y >= 122
         GOBACK
     END-IF
     COMPUTE WS-LIM = 1 + L-SD
     MOVE 0 TO WS-UF WS-OF WS-UC WS-HOLE
     IF L-SDA <= WS-LIM
         MOVE 1 TO WS-UF
     END-IF
     IF L-SDA <= 1
         MOVE 1 TO WS-OF
     END-IF
     IF L-SDB <= WS-LIM
         MOVE 1 TO WS-UC
     END-IF
     IF L-SD <= 0
         MOVE 1 TO WS-HOLE
     END-IF
     IF WS-UF = 0 AND WS-OF = 0 AND WS-UC = 0
         GOBACK
     END-IF
     CALL "NETHER-ZOOM" USING L-X L-Y L-Z WS-BIOME
     COMPUTE WS-YS = L-Y + L-SDA
*>   the gravel band 30 <= y + sda < 35 (y_above 30 and not y_above 35, add_stone_depth true)
     MOVE 0 TO WS-BAND
     IF WS-YS >= 30 AND WS-YS < 35
         MOVE 1 TO WS-BAND
     END-IF
*>   4 and 5: basalt_deltas and soul_sand_valley
     IF WS-BIOME = 5 OR WS-BIOME = 2
         IF WS-UC = 1
             IF WS-BIOME = 5
                 MOVE NH-S-BASALT TO L-STATE
             ELSE
                 CALL "NETHER-NOISE-GE" USING WS-K-SEL L-X L-Z WS-T-B WS-SEL
                 IF WS-SEL = 1
                     MOVE NH-S-SOUL-SAND TO L-STATE
                 ELSE
                     MOVE NH-S-SOUL-SOIL TO L-STATE
                 END-IF
             END-IF
             GOBACK
         END-IF
         IF WS-UF = 1
             IF WS-BAND = 1
                 CALL "NETHER-NOISE-GE" USING WS-K-PATCH L-X L-Z WS-T-A WS-PATCH
                 IF WS-PATCH = 1
                     MOVE NH-S-GRAVEL TO L-STATE
                     GOBACK
                 END-IF
             END-IF
             CALL "NETHER-NOISE-GE" USING WS-K-SEL L-X L-Z WS-T-B WS-SEL
             IF WS-BIOME = 5
                 IF WS-SEL = 1
                     MOVE NH-S-BASALT TO L-STATE
                 ELSE
                     MOVE NH-S-BLACKSTONE TO L-STATE
                 END-IF
             ELSE
                 IF WS-SEL = 1
                     MOVE NH-S-SOUL-SAND TO L-STATE
                 ELSE
                     MOVE NH-S-SOUL-SOIL TO L-STATE
                 END-IF
             END-IF
             GOBACK
         END-IF
     END-IF
*>   6: on_floor
     IF WS-OF = 1
         IF L-Y < 32 AND WS-HOLE = 1
             MOVE NH-S-LAVA TO L-STATE
             GOBACK
         END-IF
         IF (WS-BIOME = 4 OR WS-BIOME = 3) AND L-Y >= 31
             CALL "NETHER-NOISE-GE" USING WS-K-NR L-X L-Z WS-T-C WS-B
             IF WS-B = 0
                 CALL "NETHER-NOISE-GE" USING WS-K-WART L-X L-Z WS-T-D WS-B
                 IF WS-BIOME = 4
                     IF WS-B = 1
                         MOVE NH-S-WARPED-WART TO L-STATE
                     ELSE
                         MOVE NH-S-WARPED-NYL TO L-STATE
                     END-IF
                 ELSE
                     IF WS-B = 1
                         MOVE NH-S-WART-BLOCK TO L-STATE
                     ELSE
                         MOVE NH-S-CRIMSON-NYL TO L-STATE
                     END-IF
                 END-IF
                 GOBACK
             END-IF
         END-IF
     END-IF
*>   7: nether_wastes
     IF WS-BIOME = 1
         IF WS-UF = 1
             CALL "NETHER-NOISE-GE" USING WS-K-SOUL L-X L-Z WS-T-A WS-B
             IF WS-B = 1
                 IF WS-HOLE = 0 AND WS-BAND = 1
                     MOVE NH-S-SOUL-SAND TO L-STATE
                 END-IF
                 GOBACK
             END-IF
         END-IF
         IF WS-OF = 1 AND L-Y >= 31 AND WS-YS < 35
             CALL "NETHER-NOISE-GE" USING WS-K-GRAVEL L-X L-Z WS-T-A WS-B
             IF WS-B = 1
                 IF L-Y >= 32 OR WS-HOLE = 0
                     MOVE NH-S-GRAVEL TO L-STATE
                 END-IF
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM NETHER-RULE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-SURFACE.
*> The column procedure of 10 section 10.1 for every column of the chunk (x outer, z inner): from the highest non-air block (lava counts) down to
*> y 0, stoneDepthAbove counts the solid blocks since the last air block (lava is a fluid: it is neither air nor stone, so it does not reset the
*> count), stoneDepthBelow is y - lowerStone + 1 where lowerStone is one above the first air or fluid block below the run (0 at the world floor),
*> and the rule gives the block. Needs NETHER-BIOME-GRID of the chunk.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CELLS.
 COPY NETHER.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Y2                  BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-SD                  BINARY-LONG.
 01 WS-SDA                 BINARY-LONG.
 01 WS-SDB                 BINARY-LONG.
 01 WS-LOWER               BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-CELL2               BINARY-LONG.
 01 WS-ST                  BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 LINKAGE SECTION.
 01 L-CHUNK                PIC X.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CHUNK L-CX L-CZ.
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF L-CHUNK
     PERFORM VARYING WS-LX FROM 0 BY 1 UNTIL WS-LX > 15
         PERFORM VARYING WS-LZ FROM 0 BY 1 UNTIL WS-LZ > 15
             COMPUTE WS-X = L-CX * 16 + WS-LX
             COMPUTE WS-Z = L-CZ * 16 + WS-LZ
             MOVE -1 TO WS-TOP
             PERFORM VARYING WS-Y FROM 127 BY -1 UNTIL WS-Y < 0 OR WS-TOP >= 0
                 COMPUTE WS-CELL = WS-Y * 256 + WS-LZ * 16 + WS-LX + 1
                 IF CE-STATE(WS-CELL) NOT = 0
                     MOVE WS-Y TO WS-TOP
                 END-IF
             END-PERFORM
             IF WS-TOP >= 0
                 CALL "NETHER-SURFACE-DEPTH" USING WS-X WS-Z WS-SD
                 MOVE 0 TO WS-SDA
                 MOVE 1000 TO WS-LOWER
                 PERFORM VARYING WS-Y FROM WS-TOP BY -1 UNTIL WS-Y < 0
                     COMPUTE WS-CELL = WS-Y * 256 + WS-LZ * 16 + WS-LX + 1
                     MOVE CE-STATE(WS-CELL) TO WS-ST
                     EVALUATE TRUE
                         WHEN WS-ST = 0
                             MOVE 0 TO WS-SDA
                         WHEN WS-ST = NH-S-LAVA
                             CONTINUE
                         WHEN OTHER
                             ADD 1 TO WS-SDA
                             IF WS-LOWER >= WS-Y
                                 MOVE 0 TO WS-STOP
                                 COMPUTE WS-Y2 = WS-Y - 1
                                 PERFORM UNTIL WS-Y2 < 0 OR WS-STOP = 1
                                     COMPUTE WS-CELL2 = WS-Y2 * 256 + WS-LZ * 16 + WS-LX + 1
                                     IF CE-STATE(WS-CELL2) = 0 OR CE-STATE(WS-CELL2) = NH-S-LAVA
                                         MOVE 1 TO WS-STOP
                                     ELSE
                                         SUBTRACT 1 FROM WS-Y2
                                     END-IF
                                 END-PERFORM
                                 COMPUTE WS-LOWER = WS-Y2 + 1
                             END-IF
                             COMPUTE WS-SDB = WS-Y - WS-LOWER + 1
                             CALL "NETHER-RULE" USING WS-X WS-Y WS-Z WS-SDA WS-SDB WS-SD WS-NEW
                             MOVE WS-NEW TO CE-STATE(WS-CELL)
                     END-EVALUATE
                 END-PERFORM
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM NETHER-SURFACE.
