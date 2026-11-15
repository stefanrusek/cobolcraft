*> Placeholder generators of the standard world's nether and end (work plan A; docs/protocol/37-nether-1 section 6.9, 38 section 2). The
*> generator lane replaces both through the one dispatch point WORLDGEN-DIM-CHUNK (worldgen.cob); the constants are in DIMENSIONS.cpy
*> (GEN-NETHER-*, GEN-END-*). Cells are (y - min y) * 256 + z * 16 + x + 1 and both dimensions have min y 0.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDGEN-NETHER-CHUNK.
*> USING chunk x, chunk z (BINARY-LONG), chunk memory (CELLS.cpy), marker-y out (-1): y 0 bedrock; netherrack from y 1 to
*> GEN-NETHER-HIGH (even cx + cz) or GEN-NETHER-LOW (odd); lava from there up to GEN-NETHER-LAVA-TOP; air; netherrack from
*> GEN-NETHER-CEILING to GEN-NETHER-ROOF - 1; bedrock at GEN-NETHER-ROOF; air above it up to y 255.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY DIMENSIONS.
 COPY CELLS.
 01 WS-KEY-BEDROCK         PIC X(48) VALUE "minecraft:bedrock".
 01 WS-KEY-NETHERRACK      PIC X(48) VALUE "minecraft:netherrack".
 01 WS-KEY-LAVA            PIC X(48) VALUE "minecraft:lava".
 01 WS-BEDROCK             BINARY-LONG.
 01 WS-NETHERRACK          BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-CHUNK                PIC X.
 01 L-MARKER-Y             BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ L-CHUNK L-MARKER-Y.
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF L-CHUNK
     MOVE LOW-VALUES TO CE-STATES
     MOVE -1 TO L-MARKER-Y
     CALL "GEN-BLOCK-STATE" USING WS-KEY-BEDROCK WS-BEDROCK
     CALL "GEN-BLOCK-STATE" USING WS-KEY-NETHERRACK WS-NETHERRACK
     CALL "GEN-BLOCK-STATE" USING WS-KEY-LAVA WS-LAVA
     MOVE GEN-NETHER-HIGH TO WS-FLOOR
     IF FUNCTION MOD(L-CX + L-CZ, 2) = 1
         MOVE GEN-NETHER-LOW TO WS-FLOOR
     END-IF
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > GEN-NETHER-ROOF
         EVALUATE TRUE
             WHEN WS-Y = 0 OR WS-Y = GEN-NETHER-ROOF
                 MOVE WS-BEDROCK TO WS-STATE
             WHEN WS-Y <= WS-FLOOR OR WS-Y >= GEN-NETHER-CEILING
                 MOVE WS-NETHERRACK TO WS-STATE
             WHEN WS-Y <= GEN-NETHER-LAVA-TOP
                 MOVE WS-LAVA TO WS-STATE
             WHEN OTHER
                 MOVE 0 TO WS-STATE
         END-EVALUATE
         IF WS-STATE NOT = 0
             PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 256
                 COMPUTE WS-CELL = WS-Y * 256 + WS-C
                 MOVE WS-STATE TO CE-STATE(WS-CELL)
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM WORLDGEN-NETHER-CHUNK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDGEN-END-CHUNK.
*> USING chunk x, chunk z (BINARY-LONG), chunk memory (CELLS.cpy), marker-y out (-1): end_stone from GEN-END-BOTTOM to GEN-END-TOP in
*> every column whose block x squared plus z squared is below GEN-END-RADIUS squared; void elsewhere.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY DIMENSIONS.
 COPY CELLS.
 01 WS-KEY-END-STONE       PIC X(48) VALUE "minecraft:end_stone".
 01 WS-END-STONE           BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-CHUNK                PIC X.
 01 L-MARKER-Y             BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ L-CHUNK L-MARKER-Y.
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF L-CHUNK
     MOVE LOW-VALUES TO CE-STATES
     MOVE -1 TO L-MARKER-Y
     CALL "GEN-BLOCK-STATE" USING WS-KEY-END-STONE WS-END-STONE
     COMPUTE WS-LIMIT = GEN-END-RADIUS * GEN-END-RADIUS
     PERFORM VARYING WS-LZ FROM 0 BY 1 UNTIL WS-LZ > 15
         PERFORM VARYING WS-LX FROM 0 BY 1 UNTIL WS-LX > 15
             COMPUTE WS-X = L-CX * 16 + WS-LX
             COMPUTE WS-Z = L-CZ * 16 + WS-LZ
             IF WS-X * WS-X + WS-Z * WS-Z < WS-LIMIT
                 PERFORM VARYING WS-Y FROM GEN-END-BOTTOM BY 1 UNTIL WS-Y > GEN-END-TOP
                     COMPUTE WS-CELL = WS-Y * 256 + WS-LZ * 16 + WS-LX + 1
                     MOVE WS-END-STONE TO CE-STATE(WS-CELL)
                 END-PERFORM
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM WORLDGEN-END-CHUNK.
