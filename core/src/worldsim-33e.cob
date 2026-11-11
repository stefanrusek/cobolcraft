*> The level random and the raw brightness lookup that the rules of 29b read. LEVEL-RANDOM-* are java.util.Random (setSeed scrambles with 0x5DEECE66D; next(bits), nextInt(bound), nextFloat as
*> the JDK specifies; the seed of the level's random is taken from the world seed on first use, which is a choice of this core: the artifact does not say how the level random is seeded).
*> LIGHT-RAW reads the sky and block light the light policy of the chunk (light.cob, the stand-in engine of 001; the engine of 32 is not built) keeps per cell.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LEVEL-RANDOM-SEED.
*> USING seed (BINARY-DOUBLE): Random.setSeed: (seed XOR 0x5DEECE66D) AND (2^48 - 1), held as two 24-bit halves.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY WSIM3.
 01 WS-S                   BINARY-DOUBLE.
 01 WS-M                   BINARY-DOUBLE VALUE 25214903917.
 01 WS-P48                 BINARY-DOUBLE VALUE 281474976710656.
 01 WS-P24                 BINARY-DOUBLE VALUE 16777216.
 01 WS-BIT                 BINARY-DOUBLE.
 01 WS-A                   BINARY-DOUBLE.
 01 WS-B                   BINARY-DOUBLE.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-DOUBLE.
 01 WS-Y                   BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-SEED.
     COMPUTE WS-X = FUNCTION MOD(L-SEED, WS-P48)
     MOVE WS-M TO WS-Y
     MOVE 0 TO WS-R
     MOVE 1 TO WS-BIT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 48
         COMPUTE WS-A = FUNCTION MOD(WS-X, 2)
         COMPUTE WS-B = FUNCTION MOD(WS-Y, 2)
         IF WS-A NOT = WS-B
             ADD WS-BIT TO WS-R
         END-IF
         COMPUTE WS-X = (WS-X - WS-A) / 2
         COMPUTE WS-Y = (WS-Y - WS-B) / 2
         COMPUTE WS-BIT = WS-BIT * 2
     END-PERFORM
     COMPUTE LR-HI = (WS-R - FUNCTION MOD(WS-R, WS-P24)) / WS-P24
     COMPUTE LR-LO = FUNCTION MOD(WS-R, WS-P24)
     MOVE 1 TO LR-READY
     GOBACK.
 END PROGRAM LEVEL-RANDOM-SEED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LEVEL-RANDOM-NEXT.
*> USING bits (1 to 32), value out (BINARY-DOUBLE, unsigned): Random.next(bits): the seed becomes (seed * 0x5DEECE66D + 0xB) mod 2^48 and the value is its top `bits` bits. Seeds the generator from the world
*> seed when it was never seeded.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY WSIM3.
 COPY CORESTATE.
 01 WS-AL                  BINARY-DOUBLE VALUE 15525485.
 01 WS-AH                  BINARY-DOUBLE VALUE 1502.
 01 WS-P24                 BINARY-DOUBLE VALUE 16777216.
 01 WS-OLD-LO              BINARY-DOUBLE.
 01 WS-LOW                 BINARY-DOUBLE.
 01 WS-CARRY               BINARY-DOUBLE.
 01 WS-MID                 BINARY-DOUBLE.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-ALL                 BINARY-DOUBLE.
 01 WS-DIV                 BINARY-DOUBLE.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-BITS                 BINARY-LONG.
 01 L-VALUE                BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-BITS L-VALUE.
     IF LR-READY = 0
         COMPUTE WS-SEED = CW-SEED * 3 + 1013904223
         CALL "LEVEL-RANDOM-SEED" USING WS-SEED
     END-IF
     MOVE LR-LO TO WS-OLD-LO
     COMPUTE WS-LOW = WS-OLD-LO * WS-AL + 11
     COMPUTE WS-CARRY = (WS-LOW - FUNCTION MOD(WS-LOW, WS-P24)) / WS-P24
     COMPUTE LR-LO = FUNCTION MOD(WS-LOW, WS-P24)
     COMPUTE WS-MID = LR-HI * WS-AL + WS-OLD-LO * WS-AH + WS-CARRY
     COMPUTE LR-HI = FUNCTION MOD(WS-MID, WS-P24)
     COMPUTE WS-ALL = LR-HI * WS-P24 + LR-LO
     MOVE 1 TO WS-DIV
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 48 - L-BITS
         COMPUTE WS-DIV = WS-DIV * 2
     END-PERFORM
     COMPUTE L-VALUE = (WS-ALL - FUNCTION MOD(WS-ALL, WS-DIV)) / WS-DIV
     GOBACK.
 END PROGRAM LEVEL-RANDOM-NEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LEVEL-RANDOM-INT.
*> USING bound (BINARY-LONG, above 0), result out (BINARY-LONG): Random.nextInt(bound): a power of two scales next(31) (bound * r >> 31); otherwise r = next(31) mod bound, drawing again while
*> u - r + (bound - 1) would overflow an int.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-U                   BINARY-DOUBLE.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-T                   BINARY-LONG.
 01 WS-BITS                BINARY-LONG VALUE 31.
 01 WS-LIMIT               BINARY-DOUBLE VALUE 2147483648.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-BOUND                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-BOUND L-RESULT.
     MOVE L-BOUND TO WS-T
     PERFORM UNTIL FUNCTION MOD(WS-T, 2) NOT = 0 OR WS-T = 0
         COMPUTE WS-T = WS-T / 2
     END-PERFORM
     CALL "LEVEL-RANDOM-NEXT" USING WS-BITS WS-U
     IF WS-T = 1
         COMPUTE WS-R = L-BOUND * WS-U
         COMPUTE L-RESULT = (WS-R - FUNCTION MOD(WS-R, WS-LIMIT)) / WS-LIMIT
     ELSE
         MOVE 0 TO WS-DONE
         PERFORM UNTIL WS-DONE = 1
             COMPUTE WS-R = FUNCTION MOD(WS-U, L-BOUND)
             IF WS-U - WS-R + L-BOUND - 1 < WS-LIMIT
                 MOVE 1 TO WS-DONE
             ELSE
                 CALL "LEVEL-RANDOM-NEXT" USING WS-BITS WS-U
             END-IF
         END-PERFORM
         MOVE WS-R TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM LEVEL-RANDOM-INT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LEVEL-RANDOM-FLOAT.
*> USING value out (FLOAT-LONG): Random.nextFloat: next(24) / 2^24.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BITS                BINARY-LONG VALUE 24.
 01 WS-U                   BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-VALUE.
     CALL "LEVEL-RANDOM-NEXT" USING WS-BITS WS-U
     COMPUTE L-VALUE = WS-U / 16777216
     GOBACK.
 END PROGRAM LEVEL-RANDOM-FLOAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIGHT-RAW.
*> USING dimension row, x, y, z (BINARY-LONG), sky out, block out, raw out (BINARY-LONG): the light of the cell as the chunk keeps it (4 bits per cell; light section i is the section below the cell's plus one)
*> and the raw brightness max(block light, sky light) of 32 section 1.2 with a sky darkening of 0 (rawBrightness(pos, 0)); a cell outside the dimension's height or in a chunk that cannot be loaded reads 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY CELLS.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-OFFSET              BINARY-LONG.
 01 WS-SECTION             BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-UP                  BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-OPEN                BINARY-LONG.
 COPY CBLOCKS.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-SKY                  BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 01 L-RAW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-SKY L-BLOCK L-RAW.
     MOVE 0 TO L-SKY L-BLOCK L-RAW
     COMPUTE WS-OFFSET = L-Y - DM-MIN-Y(L-DIM)
     IF WS-OFFSET < 0 OR WS-OFFSET >= DM-HEIGHT(L-DIM)
         GOBACK
     END-IF
     COMPUTE WS-CX = (L-X - FUNCTION MOD(L-X, 16)) / 16
     COMPUTE WS-CZ = (L-Z - FUNCTION MOD(L-Z, 16)) / 16
     CALL "WORLD-CHUNK-LOAD" USING L-DIM WS-CX WS-CZ WS-ROW
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     COMPUTE WS-SECTION = (WS-OFFSET - FUNCTION MOD(WS-OFFSET, 16)) / 16
     COMPUTE WS-CELL = FUNCTION MOD(WS-OFFSET, 16) * 256 + FUNCTION MOD(L-Z, 16) * 16 + FUNCTION MOD(L-X, 16)
     COMPUTE WS-BYTE = (WS-SECTION + 1) * 2048 + (WS-CELL - FUNCTION MOD(WS-CELL, 2)) / 2 + 1
     MOVE CE-SKY(WS-BYTE) TO WS-V
     IF FUNCTION MOD(WS-CELL, 2) = 0
         COMPUTE L-SKY = FUNCTION MOD(WS-V, 16)
     ELSE
         COMPUTE L-SKY = (WS-V - FUNCTION MOD(WS-V, 16)) / 16
     END-IF
*>   The stand-in policy treats the topmost non-void block of a column as at or below the sky line even when it lets light through (a plant, a layer of snow): a cell with no opaque block above it, whose own
*>   block is not opaque, is lit by the sky at 15 here (vertical light only, as that policy has no sideways spreading).
     IF L-SKY = 0 AND DM-SKYLIGHT(L-DIM) = 1
         COMPUTE WS-TOP = DM-MIN-Y(L-DIM) + DM-HEIGHT(L-DIM) - 1
         MOVE 1 TO WS-OPEN
         CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
         IF WS-STATE NOT = 0
             IF CB-OPAQUE(CB-S-BLOCK(WS-STATE + 1) + 1) = 1
                 MOVE 0 TO WS-OPEN
             END-IF
         END-IF
         COMPUTE WS-UP = L-Y + 1
         PERFORM UNTIL WS-UP > WS-TOP OR WS-OPEN = 0
             CALL "WORLD-GET-BLOCK" USING L-DIM L-X WS-UP L-Z WS-STATE
             IF WS-STATE NOT = 0
                 IF CB-OPAQUE(CB-S-BLOCK(WS-STATE + 1) + 1) = 1
                     MOVE 0 TO WS-OPEN
                 END-IF
             END-IF
             ADD 1 TO WS-UP
         END-PERFORM
         IF WS-OPEN = 1
             MOVE 15 TO L-SKY
         END-IF
     END-IF
     MOVE CE-BLOCK-LIGHT(WS-BYTE) TO WS-V
     IF FUNCTION MOD(WS-CELL, 2) = 0
         COMPUTE L-BLOCK = FUNCTION MOD(WS-V, 16)
     ELSE
         COMPUTE L-BLOCK = (WS-V - FUNCTION MOD(WS-V, 16)) / 16
     END-IF
     COMPUTE L-RAW = FUNCTION MAX(L-SKY, L-BLOCK)
     GOBACK.
 END PROGRAM LIGHT-RAW.
