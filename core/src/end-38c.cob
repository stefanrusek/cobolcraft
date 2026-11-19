*> The features of the End (docs/protocol/38-end.md section 8, with the engines of 35-worldgen-features-7 sections 8 to 10; T1735, T1736): the spike list
*> and the obsidian pillars with cage and crystal, the platform, the island, the chorus plant, the podium and the gateway, each as a program that writes
*> blocks through one level: mode 0 is the level of the chunk being generated (FL-OPEN of feat-level.cob: a write outside its column is discarded), mode 1
*> is the world of the dimension DIM (WORLD-SET-BLOCK, for the arrival platform, which is built before the player's chunks go out), mode 2 is the same world through BLOCK-CHANGE (the
*> dragon fight: the podium, the gateways and the regenerated pillars are built while players look at the chunks, so the viewers must be sent the changes). Blocks are found by key and property pairs in the
*> open block table (BLOCKS-STATE-OF). The random source of a feature is the WorldgenRandom of ores.cob (WGR-*) the caller seeded (35-1 section 5).
*>
*> Entry points:
*>   END-STATE-ID USING key (PIC X(48), no namespace), pairs (PIC X(160), "name=value" list or spaces), state out: BLOCKS-STATE-OF.
*>   END-PUT USING mode, dim, x, y, z, state / END-GET USING mode, dim, x, y, z, state out.
*>   END-SPIKE-KEY USING world seed (BINARY-DOUBLE), key out: nextLong() and 65535 of the plain Java LCG seeded with the world seed (8.1 item 1).
*>   END-SPIKES USING world seed, SPIKE-LIST (ENDSPIKE.cpy): the ten pillars (8.1 items 2 to 4).
*>   END-SPIKE-PLACE USING mode, dim, origin x, origin z, world seed, random (XORO.cpy), CRYSTAL-LIST: the pillars whose centre is in the chunk of the origin
*>     (8.2); the caller creates the end crystals of the list (entities are not made here).
*>   END-PLATFORM-PLACE USING mode, dim, centre x, y, z, drop (0 or 1), dropped out: createEndPlatform (10.2); with drop 1 DROPPED counts the blocks that were
*>     replaced and were not air (the caller drops their items).
*>   END-ISLAND-LAYER USING mode, dim, x, y, z, radius (FLOAT-LONG), count out: one disc of end_stone (mode -1 only counts); END-ISLAND-DISC USING radius, count out.
*>   END-ISLAND-PLACE USING mode, dim, origin x, y, z, random: the island (10.1).
*>   END-CHORUS-PLACE USING mode, dim, origin x, y, z, random, result out: the chorus plant (9).
*>   END-PODIUM-PLACE USING mode, dim, x, y, z, active, dropped out: the exit portal podium (10.3).
*>   END-GATEWAY-PLACE USING mode, dim, x, y, z: the gateway frame (10.4); the block entity's exit is set by the caller.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-STATE-ID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(112).
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-PAIRS                PIC X(160).
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-PAIRS L-STATE.
     MOVE SPACES TO WS-KEY
     MOVE L-KEY TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY L-PAIRS L-STATE
     GOBACK.
 END PROGRAM END-STATE-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-PUT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-MODE                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-MODE L-DIM L-X L-Y L-Z L-STATE.
     EVALUATE L-MODE
         WHEN 1
             CALL "WORLD-SET-BLOCK" USING L-DIM L-X L-Y L-Z L-STATE
         WHEN 2
             CALL "BLOCK-CHANGE" USING L-DIM L-X L-Y L-Z L-STATE
         WHEN OTHER
             CALL "FL-SET-STATE" USING L-X L-Y L-Z L-STATE WS-FLAGS WS-OK
     END-EVALUATE
     GOBACK.
 END PROGRAM END-PUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-GET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-MODE                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-MODE L-DIM L-X L-Y L-Z L-STATE.
     IF L-MODE = 1 OR L-MODE = 2
         CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z L-STATE
     ELSE
         CALL "FL-GET-STATE" USING L-X L-Y L-Z L-STATE
     END-IF
     GOBACK.
 END PROGRAM END-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-SPIKE-KEY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-U                   BINARY-DOUBLE UNSIGNED.
 01 WS-R                   BINARY-DOUBLE UNSIGNED.
 01 WS-L                   BINARY-DOUBLE UNSIGNED.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-KEY                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SEED L-KEY.
     IF L-SEED < 0
         COMPUTE WS-U = L-SEED + 18446744073709551616
     ELSE
         MOVE L-SEED TO WS-U
     END-IF
     CALL "JRAND-SET-SEED" USING WS-R WS-U
     CALL "JRAND-NEXT-LONG" USING WS-R WS-L
     COMPUTE L-KEY = FUNCTION MOD(WS-L, 65536)
     GOBACK.
 END PROGRAM END-SPIKE-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-SPIKES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PI-TEXT             PIC X(32) VALUE Z"3.141592653589793".
 01 WS-PI10-TEXT           PIC X(32) VALUE Z"0.3141592653589793".
 01 WS-R42-TEXT            PIC X(32) VALUE Z"42.0".
 01 WS-TWO-TEXT            PIC X(32) VALUE Z"2.0".
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-PI                  FLOAT-LONG.
 01 WS-NEG-PI              FLOAT-LONG.
 01 WS-PI10                FLOAT-LONG.
 01 WS-R42                 FLOAT-LONG.
 01 WS-TWO                 FLOAT-LONG.
 01 WS-ID                  FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-SEED1               BINARY-DOUBLE UNSIGNED.
 01 WS-R1                  BINARY-DOUBLE UNSIGNED.
 01 WS-ORDER               BINARY-LONG OCCURS 10 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-SWAP                BINARY-LONG.
 01 WS-DIV                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-SPIKES.
    05 L-SP-ROW             OCCURS 10 TIMES.
       10 L-SP-CX           BINARY-LONG.
       10 L-SP-CZ           BINARY-LONG.
       10 L-SP-R            BINARY-LONG.
       10 L-SP-H            BINARY-LONG.
       10 L-SP-G            BINARY-LONG.
 PROCEDURE DIVISION USING L-SEED L-SPIKES.
     CALL "END-SPIKE-KEY" USING L-SEED WS-KEY
     MOVE WS-KEY TO WS-SEED1
     CALL "JRAND-SET-SEED" USING WS-R1 WS-SEED1
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         COMPUTE WS-ORDER(WS-I) = WS-I - 1
     END-PERFORM
     PERFORM VARYING WS-I FROM 10 BY -1 UNTIL WS-I < 2
         CALL "JRAND-NEXT-INT-BOUND" USING WS-R1 WS-I WS-J
         COMPUTE WS-K = WS-J + 1
         MOVE WS-ORDER(WS-I) TO WS-SWAP
         MOVE WS-ORDER(WS-K) TO WS-ORDER(WS-I)
         MOVE WS-SWAP TO WS-ORDER(WS-K)
     END-PERFORM
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-PI-TEXT WS-PI
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-PI10-TEXT WS-PI10
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-R42-TEXT WS-R42
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-TWO-TEXT WS-TWO
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-ZERO WS-PI WS-NEG-PI
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         COMPUTE WS-K = WS-I - 1
         MOVE WS-K TO WS-ID
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-PI10 WS-ID WS-T
         CALL STATIC "cc_f64_add" USING BY REFERENCE WS-NEG-PI WS-T WS-U
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-TWO WS-U WS-A
         CALL STATIC "cc_f64_cos" USING BY REFERENCE WS-A WS-C
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-R42 WS-C WS-T
         CALL STATIC "cc_f64_floor" USING BY REFERENCE WS-T WS-U
         CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-U L-SP-CX(WS-I)
         CALL STATIC "cc_f64_sin" USING BY REFERENCE WS-A WS-C
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-R42 WS-C WS-T
         CALL STATIC "cc_f64_floor" USING BY REFERENCE WS-T WS-U
         CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-U L-SP-CZ(WS-I)
         MOVE WS-ORDER(WS-I) TO WS-K
         DIVIDE WS-K BY 3 GIVING WS-DIV
         COMPUTE L-SP-R(WS-I) = 2 + WS-DIV
         COMPUTE L-SP-H(WS-I) = 76 + 3 * WS-K
         MOVE 0 TO L-SP-G(WS-I)
         IF WS-K = 1 OR WS-K = 2
             MOVE 1 TO L-SP-G(WS-I)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM END-SPIKES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-SPIKE-PLACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY ENDSPIKE.
 01 WS-ST-OBSIDIAN         BINARY-LONG.
 01 WS-ST-AIR              BINARY-LONG.
 01 WS-ST-BEDROCK          BINARY-LONG.
 01 WS-ST-FIRE             BINARY-LONG.
 01 WS-ST-BARS             BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-PAIRS               PIC X(160).
 01 WS-NONE                PIC X(160) VALUE SPACES.
 01 WS-OCX                 BINARY-LONG.
 01 WS-OCZ                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-DD                  BINARY-LONG.
 01 WS-RR                  BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-EDGE                BINARY-LONG.
 01 WS-N                   PIC X(5).
 01 WS-S                   PIC X(5).
 01 WS-W                   PIC X(5).
 01 WS-E                   PIC X(5).
 01 WS-F                   FLOAT-LONG.
 01 WS-DEG                 FLOAT-LONG VALUE 360.
 01 WS-OP-MUL              BINARY-LONG VALUE 3.
 01 WS-NEGR                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-MODE                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 01 L-SEED                 BINARY-DOUBLE.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-CRYSTALS.
    05 L-EC-COUNT           BINARY-LONG.
    05 L-EC-ROW             OCCURS 10 TIMES.
       10 L-EC-X            BINARY-LONG.
       10 L-EC-Y            BINARY-LONG.
       10 L-EC-Z            BINARY-LONG.
       10 L-EC-YAW          FLOAT-LONG.
 PROCEDURE DIVISION USING L-MODE L-DIM L-OX L-OZ L-SEED L-STATE L-CRYSTALS.
     MOVE SPACES TO WS-NONE
     MOVE "obsidian" TO WS-KEY
     CALL "END-STATE-ID" USING WS-KEY WS-NONE WS-ST-OBSIDIAN
     MOVE "air" TO WS-KEY
     CALL "END-STATE-ID" USING WS-KEY WS-NONE WS-ST-AIR
     MOVE "bedrock" TO WS-KEY
     CALL "END-STATE-ID" USING WS-KEY WS-NONE WS-ST-BEDROCK
     MOVE "fire" TO WS-KEY
     CALL "END-STATE-ID" USING WS-KEY WS-NONE WS-ST-FIRE
     MOVE 0 TO L-EC-COUNT
     CALL "END-SPIKES" USING L-SEED SPIKE-LIST
     COMPUTE WS-OCX = FUNCTION INTEGER(L-OX / 16)
     COMPUTE WS-OCZ = FUNCTION INTEGER(L-OZ / 16)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         IF FUNCTION INTEGER(SP-CX(WS-I) / 16) = WS-OCX AND FUNCTION INTEGER(SP-CZ(WS-I) / 16) = WS-OCZ
             COMPUTE WS-RR = SP-R(WS-I) * SP-R(WS-I) + 1
             COMPUTE WS-NEGR = 0 - SP-R(WS-I)
             COMPUTE WS-TOP = SP-H(WS-I) + 10
*>           the pillar and the cleared air above y 65
             PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > WS-TOP
                 PERFORM VARYING WS-DX FROM WS-NEGR BY 1 UNTIL WS-DX > SP-R(WS-I)
                     PERFORM VARYING WS-DZ FROM WS-NEGR BY 1 UNTIL WS-DZ > SP-R(WS-I)
                         COMPUTE WS-X = SP-CX(WS-I) + WS-DX
                         COMPUTE WS-Z = SP-CZ(WS-I) + WS-DZ
                         COMPUTE WS-DD = WS-DX * WS-DX + WS-DZ * WS-DZ
                         IF WS-DD <= WS-RR AND WS-Y < SP-H(WS-I)
                             CALL "END-PUT" USING L-MODE L-DIM WS-X WS-Y WS-Z WS-ST-OBSIDIAN
                         ELSE
                             IF WS-Y > 65
                                 CALL "END-PUT" USING L-MODE L-DIM WS-X WS-Y WS-Z WS-ST-AIR
                             END-IF
                         END-IF
                     END-PERFORM
                 END-PERFORM
             END-PERFORM
*>           the cage of a guarded pillar: bars along the walls and the roof, connected within the cage only
             IF SP-G(WS-I) = 1
                 MOVE "iron_bars" TO WS-KEY
                 PERFORM VARYING WS-DX FROM -2 BY 1 UNTIL WS-DX > 2
                     PERFORM VARYING WS-DZ FROM -2 BY 1 UNTIL WS-DZ > 2
                         PERFORM VARYING WS-DY FROM 0 BY 1 UNTIL WS-DY > 3
                             MOVE 0 TO WS-EDGE
                             IF WS-DX = -2 OR WS-DX = 2 OR WS-DZ = -2 OR WS-DZ = 2 OR WS-DY = 3
                                 MOVE 1 TO WS-EDGE
                             END-IF
                             IF WS-EDGE = 1
                                 MOVE 0 TO WS-A WS-B
                                 IF WS-DX = -2 OR WS-DX = 2 OR WS-DY = 3
                                     MOVE 1 TO WS-A
                                 END-IF
                                 IF WS-DZ = -2 OR WS-DZ = 2 OR WS-DY = 3
                                     MOVE 1 TO WS-B
                                 END-IF
                                 MOVE "false" TO WS-N WS-S WS-W WS-E
                                 IF WS-A = 1 AND WS-DZ NOT = -2
                                     MOVE "true" TO WS-N
                                 END-IF
                                 IF WS-A = 1 AND WS-DZ NOT = 2
                                     MOVE "true" TO WS-S
                                 END-IF
                                 IF WS-B = 1 AND WS-DX NOT = -2
                                     MOVE "true" TO WS-W
                                 END-IF
                                 IF WS-B = 1 AND WS-DX NOT = 2
                                     MOVE "true" TO WS-E
                                 END-IF
                                 MOVE SPACES TO WS-PAIRS
                                 STRING "east=" FUNCTION TRIM(WS-E) ",north=" FUNCTION TRIM(WS-N) ",south=" FUNCTION TRIM(WS-S)
                                     ",waterlogged=false,west=" FUNCTION TRIM(WS-W) DELIMITED BY SIZE INTO WS-PAIRS
                                 CALL "END-STATE-ID" USING WS-KEY WS-PAIRS WS-ST-BARS
                                 COMPUTE WS-X = SP-CX(WS-I) + WS-DX
                                 COMPUTE WS-Y = SP-H(WS-I) + WS-DY
                                 COMPUTE WS-Z = SP-CZ(WS-I) + WS-DZ
                                 CALL "END-PUT" USING L-MODE L-DIM WS-X WS-Y WS-Z WS-ST-BARS
                             END-IF
                         END-PERFORM
                     END-PERFORM
                 END-PERFORM
             END-IF
*>           the crystal: one float draw, a bedrock cap and the fire on it
             CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
             ADD 1 TO L-EC-COUNT
             MOVE SP-CX(WS-I) TO L-EC-X(L-EC-COUNT)
             COMPUTE L-EC-Y(L-EC-COUNT) = SP-H(WS-I) + 1
             MOVE SP-CZ(WS-I) TO L-EC-Z(L-EC-COUNT)
             CALL "DENSITY-F32" USING WS-OP-MUL WS-F WS-DEG L-EC-YAW(L-EC-COUNT)
             MOVE SP-CX(WS-I) TO WS-X
             MOVE SP-H(WS-I) TO WS-Y
             MOVE SP-CZ(WS-I) TO WS-Z
             CALL "END-PUT" USING L-MODE L-DIM WS-X WS-Y WS-Z WS-ST-BEDROCK
             COMPUTE WS-Y = SP-H(WS-I) + 1
             CALL "END-PUT" USING L-MODE L-DIM WS-X WS-Y WS-Z WS-ST-FIRE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM END-SPIKE-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-PLATFORM-PLACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ST-OBSIDIAN         BINARY-LONG.
 01 WS-ST-AIR              BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-NONE                PIC X(160) VALUE SPACES.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-MODE                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CY                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-DROP                 BINARY-LONG.
 01 L-DROPPED              BINARY-LONG.
 PROCEDURE DIVISION USING L-MODE L-DIM L-CX L-CY L-CZ L-DROP L-DROPPED.
     MOVE "obsidian" TO WS-KEY
     CALL "END-STATE-ID" USING WS-KEY WS-NONE WS-ST-OBSIDIAN
     MOVE "air" TO WS-KEY
     CALL "END-STATE-ID" USING WS-KEY WS-NONE WS-ST-AIR
     MOVE 0 TO L-DROPPED
     PERFORM VARYING WS-DZ FROM -2 BY 1 UNTIL WS-DZ > 2
         PERFORM VARYING WS-DX FROM -2 BY 1 UNTIL WS-DX > 2
             PERFORM VARYING WS-DY FROM -1 BY 1 UNTIL WS-DY > 2
                 COMPUTE WS-X = L-CX + WS-DX
                 COMPUTE WS-Y = L-CY + WS-DY
                 COMPUTE WS-Z = L-CZ + WS-DZ
                 IF WS-DY = -1
                     MOVE WS-ST-OBSIDIAN TO WS-WANT
                 ELSE
                     MOVE WS-ST-AIR TO WS-WANT
                 END-IF
                 CALL "END-GET" USING L-MODE L-DIM WS-X WS-Y WS-Z WS-OLD
                 IF WS-OLD NOT = WS-WANT
                     IF L-DROP = 1 AND WS-OLD NOT = WS-ST-AIR
                         ADD 1 TO L-DROPPED
                     END-IF
                     CALL "END-PUT" USING L-MODE L-DIM WS-X WS-Y WS-Z WS-WANT
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM END-PLATFORM-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-GATEWAY-PLACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ST-GATEWAY          BINARY-LONG.
 01 WS-ST-AIR              BINARY-LONG.
 01 WS-ST-BEDROCK          BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-NONE                PIC X(160) VALUE SPACES.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-MODE                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-GX                   BINARY-LONG.
 01 L-GY                   BINARY-LONG.
 01 L-GZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-MODE L-DIM L-GX L-GY L-GZ.
     MOVE "end_gateway" TO WS-KEY
     CALL "END-STATE-ID" USING WS-KEY WS-NONE WS-ST-GATEWAY
     MOVE "air" TO WS-KEY
     CALL "END-STATE-ID" USING WS-KEY WS-NONE WS-ST-AIR
     MOVE "bedrock" TO WS-KEY
     CALL "END-STATE-ID" USING WS-KEY WS-NONE WS-ST-BEDROCK
     PERFORM VARYING WS-DX FROM -1 BY 1 UNTIL WS-DX > 1
         PERFORM VARYING WS-DY FROM -2 BY 1 UNTIL WS-DY > 2
             PERFORM VARYING WS-DZ FROM -1 BY 1 UNTIL WS-DZ > 1
                 EVALUATE TRUE
                     WHEN WS-DX = 0 AND WS-DY = 0 AND WS-DZ = 0
                         MOVE WS-ST-GATEWAY TO WS-STATE
                     WHEN WS-DY = 0
                         MOVE WS-ST-AIR TO WS-STATE
                     WHEN (WS-DY = 2 OR WS-DY = -2) AND WS-DX = 0 AND WS-DZ = 0
                         MOVE WS-ST-BEDROCK TO WS-STATE
                     WHEN WS-DX = 0 OR WS-DZ = 0
                         IF WS-DY = 2 OR WS-DY = -2
                             MOVE WS-ST-AIR TO WS-STATE
                         ELSE
                             MOVE WS-ST-BEDROCK TO WS-STATE
                         END-IF
                     WHEN OTHER
                         MOVE WS-ST-AIR TO WS-STATE
                 END-EVALUATE
                 COMPUTE WS-X = L-GX + WS-DX
                 COMPUTE WS-Y = L-GY + WS-DY
                 COMPUTE WS-Z = L-GZ + WS-DZ
                 CALL "END-PUT" USING L-MODE L-DIM WS-X WS-Y WS-Z WS-STATE
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM END-GATEWAY-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-ISLAND-LAYER.
*> USING mode (-1 counts only), dim, x, y, z, radius r (FLOAT-LONG), count out: end_stone where (float)(dx * dx + dz * dz) <= (r + 1) * (r + 1) in float for dx, dz
*> from floor(-r) to ceil(r) (10.1 item 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OP-ADD              BINARY-LONG VALUE 1.
 01 WS-OP-MUL              BINARY-LONG VALUE 3.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-KEY                 PIC X(48).
 01 WS-NONE                PIC X(160) VALUE SPACES.
 01 WS-ST-END-STONE        BINARY-LONG.
 01 WS-NEG                 FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-RP1                 FLOAT-LONG.
 01 WS-RP2                 FLOAT-LONG.
 01 WS-RP3                 FLOAT-LONG.
 01 WS-LIMIT               FLOAT-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-SQ                  BINARY-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-GT                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-MODE                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-R                    FLOAT-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-MODE L-DIM L-X L-Y L-Z L-R L-COUNT.
     MOVE "end_stone" TO WS-KEY
     CALL "END-STATE-ID" USING WS-KEY WS-NONE WS-ST-END-STONE
     MOVE 0 TO L-COUNT
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-ZERO L-R WS-NEG
     CALL STATIC "cc_f64_floor" USING BY REFERENCE WS-NEG WS-T
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-T WS-LO
     CALL STATIC "cc_f64_ceil" USING BY REFERENCE L-R WS-T
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-T WS-HI
     CALL "DENSITY-F32" USING WS-OP-ADD L-R WS-ONE WS-RP1
     MOVE WS-RP1 TO WS-RP3
     CALL "DENSITY-F32" USING WS-OP-MUL WS-RP1 WS-RP3 WS-LIMIT
     PERFORM VARYING WS-DX FROM WS-LO BY 1 UNTIL WS-DX > WS-HI
         PERFORM VARYING WS-DZ FROM WS-LO BY 1 UNTIL WS-DZ > WS-HI
             COMPUTE WS-SQ = WS-DX * WS-DX + WS-DZ * WS-DZ
             MOVE WS-SQ TO WS-V
             CALL "FCMP-GT" USING WS-V WS-LIMIT WS-GT
             IF WS-GT = 0
                 ADD 1 TO L-COUNT
                 IF L-MODE NOT = -1
                     COMPUTE WS-X = L-X + WS-DX
                     COMPUTE WS-Z = L-Z + WS-DZ
                     CALL "END-PUT" USING L-MODE L-DIM WS-X L-Y WS-Z WS-ST-END-STONE
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM END-ISLAND-LAYER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-ISLAND-DISC.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MODE                BINARY-LONG VALUE -1.
 01 WS-DIM                 BINARY-LONG VALUE 0.
 01 WS-X                   BINARY-LONG VALUE 0.
 01 WS-Y                   BINARY-LONG VALUE 0.
 01 WS-Z                   BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-R                    FLOAT-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-R L-COUNT.
     CALL "END-ISLAND-LAYER" USING WS-MODE WS-DIM WS-X WS-Y WS-Z L-R L-COUNT
     GOBACK.
 END PROGRAM END-ISLAND-DISC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-ISLAND-PLACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OP-ADD              BINARY-LONG VALUE 1.
 01 WS-OP-SUB              BINARY-LONG VALUE 2.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-FOUR                FLOAT-LONG VALUE 4.
 01 WS-HALF                FLOAT-LONG VALUE 0.5.
 01 WS-D                   BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-GT                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-MODE                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 PROCEDURE DIVISION USING L-MODE L-DIM L-X L-Y L-Z L-STATE.
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-THREE WS-D
     MOVE WS-D TO WS-F
     CALL "DENSITY-F32" USING WS-OP-ADD WS-F WS-FOUR WS-R
     MOVE 0 TO WS-DY
     CALL "FCMP-GT" USING WS-R WS-HALF WS-GT
     PERFORM UNTIL WS-GT = 0
         COMPUTE WS-Y = L-Y + WS-DY
         CALL "END-ISLAND-LAYER" USING L-MODE L-DIM L-X WS-Y L-Z WS-R WS-COUNT
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-TWO WS-D
         MOVE WS-D TO WS-F
         CALL "DENSITY-F32" USING WS-OP-ADD WS-F WS-HALF WS-T
         CALL "DENSITY-F32" USING WS-OP-SUB WS-R WS-T WS-F
         MOVE WS-F TO WS-R
         SUBTRACT 1 FROM WS-DY
         CALL "FCMP-GT" USING WS-R WS-HALF WS-GT
     END-PERFORM
     GOBACK.
 END PROGRAM END-ISLAND-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-IS-CHORUS.
*> USING state, result out: 1 for a chorus plant or a chorus flower state, else 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-KEY                 PIC X(112).
 01 WS-PLANT               BINARY-LONG.
 01 WS-FLOWER              BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-STATE > 0
         MOVE "chorus_plant" TO WS-KEY
         CALL "BLOCKS-ID-OF" USING WS-KEY WS-PLANT
         MOVE "chorus_flower" TO WS-KEY
         CALL "BLOCKS-ID-OF" USING WS-KEY WS-FLOWER
         MOVE CB-S-BLOCK(L-STATE + 1) TO WS-BLOCK
         IF WS-BLOCK = WS-PLANT OR WS-BLOCK = WS-FLOWER
             MOVE 1 TO L-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM END-IS-CHORUS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-CHORUS-STATE.
*> USING mode, dim, x, y, z, state out: the chorus_plant state with the connection flags of the neighbours of that moment (9: down for a chorus block or end
*> stone below, up and the four sides for a chorus block).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(48).
 01 WS-NONE                PIC X(160) VALUE SPACES.
 01 WS-PAIRS               PIC X(160).
 01 WS-ST-END-STONE        BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-F-DOWN              PIC X(5).
 01 WS-F-UP                PIC X(5).
 01 WS-F-N                 PIC X(5).
 01 WS-F-E                 PIC X(5).
 01 WS-F-S                 PIC X(5).
 01 WS-F-W                 PIC X(5).
 LINKAGE SECTION.
 01 L-MODE                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-MODE L-DIM L-X L-Y L-Z L-STATE.
     MOVE "end_stone" TO WS-KEY
     CALL "END-STATE-ID" USING WS-KEY WS-NONE WS-ST-END-STONE
     MOVE "false" TO WS-F-DOWN WS-F-UP WS-F-N WS-F-E WS-F-S WS-F-W
     COMPUTE WS-Y = L-Y - 1
     CALL "END-GET" USING L-MODE L-DIM L-X WS-Y L-Z WS-S
     CALL "END-IS-CHORUS" USING WS-S WS-R
     IF WS-R = 1 OR WS-S = WS-ST-END-STONE
         MOVE "true" TO WS-F-DOWN
     END-IF
     COMPUTE WS-Y = L-Y + 1
     CALL "END-GET" USING L-MODE L-DIM L-X WS-Y L-Z WS-S
     CALL "END-IS-CHORUS" USING WS-S WS-R
     IF WS-R = 1
         MOVE "true" TO WS-F-UP
     END-IF
     COMPUTE WS-Z = L-Z - 1
     CALL "END-GET" USING L-MODE L-DIM L-X L-Y WS-Z WS-S
     CALL "END-IS-CHORUS" USING WS-S WS-R
     IF WS-R = 1
         MOVE "true" TO WS-F-N
     END-IF
     COMPUTE WS-Z = L-Z + 1
     CALL "END-GET" USING L-MODE L-DIM L-X L-Y WS-Z WS-S
     CALL "END-IS-CHORUS" USING WS-S WS-R
     IF WS-R = 1
         MOVE "true" TO WS-F-S
     END-IF
     COMPUTE WS-X = L-X + 1
     CALL "END-GET" USING L-MODE L-DIM WS-X L-Y L-Z WS-S
     CALL "END-IS-CHORUS" USING WS-S WS-R
     IF WS-R = 1
         MOVE "true" TO WS-F-E
     END-IF
     COMPUTE WS-X = L-X - 1
     CALL "END-GET" USING L-MODE L-DIM WS-X L-Y L-Z WS-S
     CALL "END-IS-CHORUS" USING WS-S WS-R
     IF WS-R = 1
         MOVE "true" TO WS-F-W
     END-IF
     MOVE SPACES TO WS-PAIRS
     STRING "down=" FUNCTION TRIM(WS-F-DOWN) ",east=" FUNCTION TRIM(WS-F-E) ",north=" FUNCTION TRIM(WS-F-N) ",south="
         FUNCTION TRIM(WS-F-S) ",up=" FUNCTION TRIM(WS-F-UP) ",west=" FUNCTION TRIM(WS-F-W) DELIMITED BY SIZE INTO WS-PAIRS
     MOVE "chorus_plant" TO WS-KEY
     CALL "END-STATE-ID" USING WS-KEY WS-PAIRS L-STATE
     GOBACK.
 END PROGRAM END-CHORUS-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-CHORUS-SET.
*> USING mode, dim, x, y, z: places the chorus plant state of END-CHORUS-STATE at the position.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-MODE                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-MODE L-DIM L-X L-Y L-Z.
     CALL "END-CHORUS-STATE" USING L-MODE L-DIM L-X L-Y L-Z WS-STATE
     CALL "END-PUT" USING L-MODE L-DIM L-X L-Y L-Z WS-STATE
     GOBACK.
 END PROGRAM END-CHORUS-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-CHORUS-EMPTY.
*> USING mode, dim, x, y, z, except direction (0 to 3 north east south west, -1 none), result out: 1 when the four horizontal neighbours other than the
*> excepted one are air (9, allNeighborsEmpty).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG OCCURS 4 TIMES.
 01 WS-DZ                  BINARY-LONG OCCURS 4 TIMES.
 01 WS-INIT                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-MODE                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-EXCEPT               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-MODE L-DIM L-X L-Y L-Z L-EXCEPT L-RESULT.
     IF WS-INIT = 0
         MOVE 1 TO WS-INIT
         MOVE 0 TO WS-DX(1) MOVE -1 TO WS-DZ(1)
         MOVE 1 TO WS-DX(2) MOVE 0 TO WS-DZ(2)
         MOVE 0 TO WS-DX(3) MOVE 1 TO WS-DZ(3)
         MOVE -1 TO WS-DX(4) MOVE 0 TO WS-DZ(4)
     END-IF
     MOVE 1 TO L-RESULT
     PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 3
         IF WS-D NOT = L-EXCEPT
             COMPUTE WS-X = L-X + WS-DX(WS-D + 1)
             COMPUTE WS-Z = L-Z + WS-DZ(WS-D + 1)
             CALL "END-GET" USING L-MODE L-DIM WS-X L-Y WS-Z WS-S
             IF WS-S NOT = 0
                 MOVE 0 TO L-RESULT
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM END-CHORUS-EMPTY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-CHORUS-GROW IS RECURSIVE.
*> USING mode, dim, base x, y, z, origin x, origin z, max distance, depth, random: growTreeRecursive of 9 (draw order: the height, the branch count, per
*> attempt the direction, a recursion's draws before the next attempt's).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-INIT                BINARY-LONG VALUE 0.
 01 WS-DX                  BINARY-LONG OCCURS 4 TIMES.
 01 WS-DZ                  BINARY-LONG OCCURS 4 TIMES.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-KEY                 PIC X(48).
 01 WS-PAIRS               PIC X(160).
 LOCAL-STORAGE SECTION.
 01 LS-H                   BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-N                   BINARY-LONG.
 01 LS-K                   BINARY-LONG.
 01 LS-DIR                 BINARY-LONG.
 01 LS-OPP                 BINARY-LONG.
 01 LS-GREW                BINARY-LONG.
 01 LS-EMPTY               BINARY-LONG.
 01 LS-X                   BINARY-LONG.
 01 LS-Y                   BINARY-LONG.
 01 LS-Z                   BINARY-LONG.
 01 LS-QX                  BINARY-LONG.
 01 LS-QZ                  BINARY-LONG.
 01 LS-S                   BINARY-LONG.
 01 LS-OK                  BINARY-LONG.
 01 LS-D                   BINARY-LONG.
 01 LS-DEPTH1              BINARY-LONG.
 01 LS-NEG                 BINARY-LONG VALUE -1.
 01 LS-ST-FLOWER           BINARY-LONG.
 LINKAGE SECTION.
 01 L-MODE                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-BX                   BINARY-LONG.
 01 L-BY                   BINARY-LONG.
 01 L-BZ                   BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-DEPTH                BINARY-LONG.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 PROCEDURE DIVISION USING L-MODE L-DIM L-BX L-BY L-BZ L-OX L-OZ L-MAX L-DEPTH L-STATE.
     IF WS-INIT = 0
         MOVE 1 TO WS-INIT
         MOVE 0 TO WS-DX(1) MOVE -1 TO WS-DZ(1)
         MOVE 1 TO WS-DX(2) MOVE 0 TO WS-DZ(2)
         MOVE 0 TO WS-DX(3) MOVE 1 TO WS-DZ(3)
         MOVE -1 TO WS-DX(4) MOVE 0 TO WS-DZ(4)
     END-IF
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-FOUR LS-H
     ADD 1 TO LS-H
     IF L-DEPTH = 0
         ADD 1 TO LS-H
     END-IF
     PERFORM VARYING LS-I FROM 0 BY 1 UNTIL LS-I >= LS-H
         COMPUTE LS-Y = L-BY + LS-I + 1
         CALL "END-CHORUS-EMPTY" USING L-MODE L-DIM L-BX LS-Y L-BZ LS-NEG LS-OK
         IF LS-OK = 0
             GOBACK
         END-IF
         CALL "END-CHORUS-SET" USING L-MODE L-DIM L-BX LS-Y L-BZ
         COMPUTE LS-Y = L-BY + LS-I
         CALL "END-CHORUS-SET" USING L-MODE L-DIM L-BX LS-Y L-BZ
     END-PERFORM
     MOVE 0 TO LS-GREW
     IF L-DEPTH < 4
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-FOUR LS-N
         IF L-DEPTH = 0
             ADD 1 TO LS-N
         END-IF
         PERFORM LS-N TIMES
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-FOUR LS-DIR
             COMPUTE LS-QX = L-BX + WS-DX(LS-DIR + 1)
             COMPUTE LS-QZ = L-BZ + WS-DZ(LS-DIR + 1)
             COMPUTE LS-Y = L-BY + LS-H
             MOVE 0 TO LS-OK
             IF FUNCTION ABS(LS-QX - L-OX) < L-MAX AND FUNCTION ABS(LS-QZ - L-OZ) < L-MAX
                 CALL "END-GET" USING L-MODE L-DIM LS-QX LS-Y LS-QZ LS-S
                 COMPUTE LS-D = LS-Y - 1
                 IF LS-S = 0
                     CALL "END-GET" USING L-MODE L-DIM LS-QX LS-D LS-QZ LS-S
                     IF LS-S = 0
                         COMPUTE LS-OPP = FUNCTION MOD(LS-DIR + 2, 4)
                         CALL "END-CHORUS-EMPTY" USING L-MODE L-DIM LS-QX LS-Y LS-QZ LS-OPP LS-EMPTY
                         IF LS-EMPTY = 1
                             MOVE 1 TO LS-OK
                         END-IF
                     END-IF
                 END-IF
             END-IF
             IF LS-OK = 1
                 MOVE 1 TO LS-GREW
                 CALL "END-CHORUS-SET" USING L-MODE L-DIM LS-QX LS-Y LS-QZ
                 CALL "END-CHORUS-SET" USING L-MODE L-DIM L-BX LS-Y L-BZ
                 COMPUTE LS-DEPTH1 = L-DEPTH + 1
                 CALL "END-CHORUS-GROW" USING L-MODE L-DIM LS-QX LS-Y LS-QZ L-OX L-OZ L-MAX LS-DEPTH1 L-STATE
             END-IF
         END-PERFORM
     END-IF
     IF LS-GREW = 0
         MOVE "chorus_flower" TO WS-KEY
         MOVE "age=5" TO WS-PAIRS
         CALL "END-STATE-ID" USING WS-KEY WS-PAIRS LS-ST-FLOWER
         COMPUTE LS-Y = L-BY + LS-H
         CALL "END-PUT" USING L-MODE L-DIM L-BX LS-Y L-BZ LS-ST-FLOWER
     END-IF
     GOBACK.
 END PROGRAM END-CHORUS-GROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-CHORUS-PLACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(48).
 01 WS-NONE                PIC X(160) VALUE SPACES.
 01 WS-ST-END-STONE        BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-MAX                 BINARY-LONG VALUE 8.
 01 WS-DEPTH               BINARY-LONG VALUE 0.
 01 WS-OX                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-MODE                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-MODE L-DIM L-X L-Y L-Z L-STATE L-RESULT.
     MOVE 0 TO L-RESULT
     MOVE "end_stone" TO WS-KEY
     CALL "END-STATE-ID" USING WS-KEY WS-NONE WS-ST-END-STONE
     CALL "END-GET" USING L-MODE L-DIM L-X L-Y L-Z WS-S
     COMPUTE WS-Y = L-Y - 1
     IF WS-S = 0
         CALL "END-GET" USING L-MODE L-DIM L-X WS-Y L-Z WS-S
         IF WS-S = WS-ST-END-STONE
             MOVE 1 TO L-RESULT
         END-IF
     END-IF
     IF L-RESULT = 1
         CALL "END-CHORUS-SET" USING L-MODE L-DIM L-X L-Y L-Z
         MOVE L-X TO WS-OX
         MOVE L-Z TO WS-OZ
         CALL "END-CHORUS-GROW" USING L-MODE L-DIM L-X L-Y L-Z WS-OX WS-OZ WS-MAX WS-DEPTH L-STATE
     END-IF
     GOBACK.
 END PROGRAM END-CHORUS-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-PODIUM-PLACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(48).
 01 WS-NONE                PIC X(160) VALUE SPACES.
 01 WS-PAIRS               PIC X(160).
 01 WS-ST-BEDROCK          BINARY-LONG.
 01 WS-ST-END-STONE        BINARY-LONG.
 01 WS-ST-AIR              BINARY-LONG.
 01 WS-ST-PORTAL           BINARY-LONG.
 01 WS-ST-TORCH            BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-INNER               BINARY-LONG.
 01 WS-OUTER               BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-TDX                 BINARY-LONG OCCURS 4 TIMES.
 01 WS-TDZ                 BINARY-LONG OCCURS 4 TIMES.
 01 WS-TNAME               PIC X(5) OCCURS 4 TIMES.
 01 WS-INIT                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-MODE                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ACTIVE               BINARY-LONG.
 01 L-DROPPED              BINARY-LONG.
 PROCEDURE DIVISION USING L-MODE L-DIM L-X L-Y L-Z L-ACTIVE L-DROPPED.
     IF WS-INIT = 0
         MOVE 1 TO WS-INIT
         MOVE 0 TO WS-TDX(1) MOVE -1 TO WS-TDZ(1) MOVE "north" TO WS-TNAME(1)
         MOVE 1 TO WS-TDX(2) MOVE 0 TO WS-TDZ(2) MOVE "east" TO WS-TNAME(2)
         MOVE 0 TO WS-TDX(3) MOVE 1 TO WS-TDZ(3) MOVE "south" TO WS-TNAME(3)
         MOVE -1 TO WS-TDX(4) MOVE 0 TO WS-TDZ(4) MOVE "west" TO WS-TNAME(4)
     END-IF
     MOVE "bedrock" TO WS-KEY
     CALL "END-STATE-ID" USING WS-KEY WS-NONE WS-ST-BEDROCK
     MOVE "end_stone" TO WS-KEY
     CALL "END-STATE-ID" USING WS-KEY WS-NONE WS-ST-END-STONE
     MOVE "air" TO WS-KEY
     CALL "END-STATE-ID" USING WS-KEY WS-NONE WS-ST-AIR
     MOVE "end_portal" TO WS-KEY
     CALL "END-STATE-ID" USING WS-KEY WS-NONE WS-ST-PORTAL
     MOVE 0 TO L-DROPPED
     PERFORM VARYING WS-DX FROM -4 BY 1 UNTIL WS-DX > 4
         PERFORM VARYING WS-DY FROM -1 BY 1 UNTIL WS-DY > 32
             PERFORM VARYING WS-DZ FROM -4 BY 1 UNTIL WS-DZ > 4
                 COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
                 MOVE 0 TO WS-INNER WS-OUTER
                 IF WS-D2 <= 6
                     MOVE 1 TO WS-INNER
                 END-IF
                 IF WS-D2 <= 12
                     MOVE 1 TO WS-OUTER
                 END-IF
                 IF WS-INNER = 1 OR WS-OUTER = 1
                     COMPUTE WS-X = L-X + WS-DX
                     COMPUTE WS-Y = L-Y + WS-DY
                     COMPUTE WS-Z = L-Z + WS-DZ
                     EVALUATE TRUE
                         WHEN WS-DY < 0 AND WS-INNER = 1
                             MOVE WS-ST-BEDROCK TO WS-WANT
                         WHEN WS-DY < 0
                             MOVE WS-ST-END-STONE TO WS-WANT
                         WHEN WS-DY = 0 AND WS-INNER = 1 AND L-ACTIVE = 1
                             MOVE WS-ST-PORTAL TO WS-WANT
                         WHEN WS-DY = 0 AND WS-INNER = 1
                             MOVE WS-ST-AIR TO WS-WANT
                         WHEN WS-DY = 0
                             MOVE WS-ST-BEDROCK TO WS-WANT
                         WHEN OTHER
                             MOVE WS-ST-AIR TO WS-WANT
                     END-EVALUATE
                     IF L-ACTIVE = 1 AND WS-WANT NOT = WS-ST-BEDROCK
                         CALL "END-GET" USING L-MODE L-DIM WS-X WS-Y WS-Z WS-OLD
                         IF WS-OLD NOT = WS-WANT AND WS-OLD NOT = WS-ST-AIR
                             ADD 1 TO L-DROPPED
                         END-IF
                     END-IF
                     CALL "END-PUT" USING L-MODE L-DIM WS-X WS-Y WS-Z WS-WANT
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-DY FROM 0 BY 1 UNTIL WS-DY > 3
         COMPUTE WS-Y = L-Y + WS-DY
         CALL "END-PUT" USING L-MODE L-DIM L-X WS-Y L-Z WS-ST-BEDROCK
     END-PERFORM
     MOVE "wall_torch" TO WS-KEY
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 4
         MOVE SPACES TO WS-PAIRS
         STRING "facing=" FUNCTION TRIM(WS-TNAME(WS-D)) DELIMITED BY SIZE INTO WS-PAIRS
         CALL "END-STATE-ID" USING WS-KEY WS-PAIRS WS-ST-TORCH
         COMPUTE WS-X = L-X + WS-TDX(WS-D)
         COMPUTE WS-Y = L-Y + 2
         COMPUTE WS-Z = L-Z + WS-TDZ(WS-D)
         CALL "END-PUT" USING L-MODE L-DIM WS-X WS-Y WS-Z WS-ST-TORCH
     END-PERFORM
     GOBACK.
 END PROGRAM END-PODIUM-PLACE.
