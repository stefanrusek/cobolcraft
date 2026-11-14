*> The world-generation level of the feature stage (docs/protocol/35-worldgen-features-1 section 4; FEATLEVEL.cpy): reads and writes of the block
*> states of the chunk being generated, the heightmaps of section 4.2 over its columns, the biome of a cell, and the block classes the features ask.
*>
*> Entry points:
*>   FL-OPEN USING chunk address (POINTER), chunk x, chunk z, min y, height, sea level (BINARY-LONG)
*>   FL-CLOSE
*>   FL-GET-STATE USING x, y, z (block coordinates), state out (BINARY-LONG): air (FL-S-AIR) outside the chunk's column, void_air outside the build height
*>   FL-SET-STATE USING x, y, z, state, flags, ok out: 1 written (or a y outside the build height, discarded silently as in 4.1 item 3), 0 outside the chunk's column
*>   FL-CLASS USING state, class out: 1 air (air, cave air, void air), 2 water, 3 lava, 4 bedrock, 0 any other block
*>   FL-HEIGHT-OF USING heightmap ordinal (0 to 5, section 4.2), x, z, height out: the first free y over the highest qualifying block, min y for none
*>   FL-BIOME-AT USING x, y, z, biome key out (PIC X(40))
*>   FL-BLOCK-OF USING state, block index out (the number in CORE-BLOCKS)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-OPEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATLEVEL.
 COPY CBLOCKS.
 01 WS-I                   BINARY-LONG.
 01 WS-FULL                PIC X(48).
 LINKAGE SECTION.
 01 L-ADDR                 USAGE POINTER.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-MIN-Y                BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-SEA                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ADDR L-CX L-CZ L-MIN-Y L-HEIGHT L-SEA.
     SET FL-ADDR TO L-ADDR
     MOVE L-CX TO FL-CX
     MOVE L-CZ TO FL-CZ
     MOVE L-MIN-Y TO FL-MIN-Y
     MOVE L-HEIGHT TO FL-HEIGHT
     MOVE L-SEA TO FL-SEA
     MOVE 0 TO FL-DISCARDED FL-WRITES
     IF FL-EPOCH NOT = CB-EPOCH + 1
         MOVE 0 TO FL-B-AIR FL-B-CAVE-AIR FL-B-VOID-AIR FL-B-WATER FL-B-LAVA FL-B-BEDROCK FL-S-AIR FL-S-VOID-AIR
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT
*>           The standard set keeps its keys without the namespace ("air", "water").
             CALL "KEY-NAMESPACED" USING CB-KEY(WS-I) WS-FULL
             EVALUATE FUNCTION TRIM(WS-FULL)
                 WHEN "minecraft:air"
                     MOVE WS-I TO FL-B-AIR
                     MOVE CB-DEFAULT-STATE(WS-I) TO FL-S-AIR
                 WHEN "minecraft:cave_air"
                     MOVE WS-I TO FL-B-CAVE-AIR
                 WHEN "minecraft:void_air"
                     MOVE WS-I TO FL-B-VOID-AIR
                     MOVE CB-DEFAULT-STATE(WS-I) TO FL-S-VOID-AIR
                 WHEN "minecraft:water"
                     MOVE WS-I TO FL-B-WATER
                 WHEN "minecraft:lava"
                     MOVE WS-I TO FL-B-LAVA
                 WHEN "minecraft:bedrock"
                     MOVE WS-I TO FL-B-BEDROCK
             END-EVALUATE
         END-PERFORM
         COMPUTE FL-EPOCH = CB-EPOCH + 1
     END-IF
     MOVE 1 TO FL-OPEN-FLAG
     GOBACK.
 END PROGRAM FL-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-CLOSE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATLEVEL.
 PROCEDURE DIVISION.
     MOVE 0 TO FL-OPEN-FLAG
     SET FL-ADDR TO NULL
     GOBACK.
 END PROGRAM FL-CLOSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-BLOCK-OF.
*> USING state, block out: the 1-based number of the block of a state in CORE-BLOCKS (0 for none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-BLOCK.
     MOVE 0 TO L-BLOCK
     IF L-STATE >= 0 AND L-STATE < CB-STATE-COUNT
         COMPUTE L-BLOCK = CB-S-BLOCK(L-STATE + 1) + 1
     END-IF
     GOBACK.
 END PROGRAM FL-BLOCK-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-CLASS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATLEVEL.
 01 WS-B                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-CLASS                BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-CLASS.
     CALL "FL-BLOCK-OF" USING L-STATE WS-B
     MOVE 0 TO L-CLASS
     EVALUATE TRUE
         WHEN WS-B = 0
             CONTINUE
         WHEN WS-B = FL-B-AIR OR WS-B = FL-B-CAVE-AIR OR WS-B = FL-B-VOID-AIR
             MOVE 1 TO L-CLASS
         WHEN WS-B = FL-B-WATER
             MOVE 2 TO L-CLASS
         WHEN WS-B = FL-B-LAVA
             MOVE 3 TO L-CLASS
         WHEN WS-B = FL-B-BEDROCK
             MOVE 4 TO L-CLASS
     END-EVALUATE
     GOBACK.
 END PROGRAM FL-CLASS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-GET-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATLEVEL.
 COPY CELLS.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-STATE.
     COMPUTE WS-LX = L-X - FL-CX * 16
     COMPUTE WS-LZ = L-Z - FL-CZ * 16
     MOVE FL-S-AIR TO L-STATE
     IF L-Y < FL-MIN-Y OR L-Y > FL-MIN-Y + FL-HEIGHT - 1
         MOVE FL-S-VOID-AIR TO L-STATE
     ELSE
         IF WS-LX >= 0 AND WS-LX <= 15 AND WS-LZ >= 0 AND WS-LZ <= 15
             SET ADDRESS OF CE-CHUNK TO FL-ADDR
             COMPUTE WS-INDEX = (L-Y - FL-MIN-Y) * 256 + WS-LZ * 16 + WS-LX + 1
             MOVE CE-STATE(WS-INDEX) TO L-STATE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FL-GET-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-SET-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATLEVEL.
 COPY CELLS.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-STATE L-FLAGS L-OK.
     COMPUTE WS-LX = L-X - FL-CX * 16
     COMPUTE WS-LZ = L-Z - FL-CZ * 16
     MOVE 0 TO L-OK
     IF WS-LX >= 0 AND WS-LX <= 15 AND WS-LZ >= 0 AND WS-LZ <= 15
         MOVE 1 TO L-OK
         IF L-Y >= FL-MIN-Y AND L-Y <= FL-MIN-Y + FL-HEIGHT - 1
             SET ADDRESS OF CE-CHUNK TO FL-ADDR
             COMPUTE WS-INDEX = (L-Y - FL-MIN-Y) * 256 + WS-LZ * 16 + WS-LX + 1
             MOVE L-STATE TO CE-STATE(WS-INDEX)
             ADD 1 TO FL-WRITES
         END-IF
     ELSE
         ADD 1 TO FL-DISCARDED
     END-IF
     GOBACK.
 END PROGRAM FL-SET-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-HEIGHT-OF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATLEVEL.
 COPY CBLOCKS.
 COPY CELLS.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ORDINAL              BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ORDINAL L-X L-Z L-HEIGHT.
     MOVE FL-MIN-Y TO L-HEIGHT
     COMPUTE WS-LX = L-X - FL-CX * 16
     COMPUTE WS-LZ = L-Z - FL-CZ * 16
     IF WS-LX >= 0 AND WS-LX <= 15 AND WS-LZ >= 0 AND WS-LZ <= 15
         SET ADDRESS OF CE-CHUNK TO FL-ADDR
         MOVE 0 TO WS-PASS
         COMPUTE WS-TOP = FL-MIN-Y + FL-HEIGHT - 1
         PERFORM VARYING WS-Y FROM WS-TOP BY -1 UNTIL WS-Y < FL-MIN-Y OR WS-PASS = 1
             COMPUTE WS-INDEX = (WS-Y - FL-MIN-Y) * 256 + WS-LZ * 16 + WS-LX + 1
             MOVE CE-STATE(WS-INDEX) TO WS-STATE
             CALL "FL-CLASS" USING WS-STATE WS-CLASS
             CALL "FL-BLOCK-OF" USING WS-STATE WS-B
             EVALUATE L-ORDINAL
                 WHEN 0
                 WHEN 1
                     IF WS-CLASS NOT = 1
                         MOVE 1 TO WS-PASS
                     END-IF
                 WHEN 2
                 WHEN 3
                     IF WS-B > 0 AND WS-CLASS NOT = 1 AND CB-SOLID(WS-B) = 1
                         MOVE 1 TO WS-PASS
                     END-IF
                 WHEN 4
                     IF WS-CLASS = 2 OR WS-CLASS = 3 OR (WS-B > 0 AND WS-CLASS NOT = 1 AND CB-SOLID(WS-B) = 1)
                         MOVE 1 TO WS-PASS
                     END-IF
                 WHEN OTHER
                     IF WS-CLASS = 2 OR WS-CLASS = 3
                         MOVE 1 TO WS-PASS
                     END-IF
                     IF WS-PASS = 0 AND WS-B > 0 AND WS-CLASS NOT = 1 AND CB-SOLID(WS-B) = 1
                         MOVE CB-KEY-LENGTH(WS-B) TO WS-LEN
                         IF WS-LEN < 7 OR CB-KEY(WS-B)(WS-LEN - 6:7) NOT = "_leaves"
                             MOVE 1 TO WS-PASS
                         END-IF
                     END-IF
             END-EVALUATE
             IF WS-PASS = 1
                 COMPUTE L-HEIGHT = WS-Y + 1
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM FL-HEIGHT-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-BIOME-AT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATLEVEL.
 COPY CBLOCKS.
 COPY CELLS.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-BIOME                PIC X(40).
 PROCEDURE DIVISION USING L-X L-Y L-Z L-BIOME.
     COMPUTE WS-LX = L-X - FL-CX * 16
     COMPUTE WS-LZ = L-Z - FL-CZ * 16
     IF WS-LX < 0
         MOVE 0 TO WS-LX
     END-IF
     IF WS-LX > 15
         MOVE 15 TO WS-LX
     END-IF
     IF WS-LZ < 0
         MOVE 0 TO WS-LZ
     END-IF
     IF WS-LZ > 15
         MOVE 15 TO WS-LZ
     END-IF
     COMPUTE WS-LY = L-Y - FL-MIN-Y
     IF WS-LY < 0
         MOVE 0 TO WS-LY
     END-IF
     IF WS-LY > FL-HEIGHT - 1
         COMPUTE WS-LY = FL-HEIGHT - 1
     END-IF
     SET ADDRESS OF CE-CHUNK TO FL-ADDR
     COMPUTE WS-INDEX = FUNCTION INTEGER(WS-LY / 16) * 64 + FUNCTION MOD(FUNCTION INTEGER(WS-LY / 4), 4) * 16 + FUNCTION INTEGER(WS-LZ / 4) * 4 + FUNCTION INTEGER(WS-LX / 4) + 1
     MOVE CE-BIOME(WS-INDEX) TO WS-ID
     MOVE SPACES TO L-BIOME
     IF WS-ID < CBI-COUNT
         MOVE CBI-KEY(WS-ID + 1) TO L-BIOME
     END-IF
     GOBACK.
 END PROGRAM FL-BIOME-AT.
