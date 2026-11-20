*> The end city as a structure (docs/protocol/36-structures-8-nether-and-end.md sections 8 to 11, 38 section 10): the start with its terrain rules (ENDCITY-FIND-POINT: the biome of the column,
*> the rotation draw, the lowest of four surface heights, none below y 60), the layout of struct-endcity.cob as template pieces of kind 16 (ENDCITY-PIECES: woodland_mansion-like
*> template pieces with the block-ignore processor of 9.1), the data markers (ENDCITY-MARKER, 9.4), and the placement into an End chunk after its terrain and features (END-GEN-STRUCTURES).
*> The `Elytra` marker asks for an item frame through the entity channel (GENT-ADD-FRAME, ENTITY-NBT-ONE reads frames);
*> a `Sentry` makes its shulker with no persistence flag as 9.4 says; the city is placed after all the placed features of the chunk, not at its own decoration step.
*> Entry points: ENDCITY-HEIGHT USING x, z, height out (the first occupied height of the End terrain column, 0 when empty); ENDCITY-FIND-POINT USING seed (signed), chunk x, chunk z, x out, y
*> out, z out, valid out; ENDCITY-MARKER USING row, metadata (PIC X(96)), x, y, z; END-GEN-STRUCTURES USING chunk x, chunk z, chunk memory.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENDCITY-HEIGHT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CELLS.
 01 WS-PTR                 USAGE POINTER.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-LAST-CX             BINARY-LONG VALUE 0.
 01 WS-LAST-CZ             BINARY-LONG VALUE 0.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-MARKER              BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Z L-HEIGHT.
     COMPUTE WS-CX = FUNCTION INTEGER(L-X / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(L-Z / 16)
     COMPUTE WS-LX = L-X - WS-CX * 16
     COMPUTE WS-LZ = L-Z - WS-CZ * 16
     IF WS-READY = 0
         ALLOCATE 304640 CHARACTERS INITIALIZED RETURNING WS-PTR
         MOVE 1 TO WS-READY
         MOVE -999999 TO WS-LAST-CX
     END-IF
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     IF WS-CX NOT = WS-LAST-CX OR WS-CZ NOT = WS-LAST-CZ
         CALL "END-GEN-CHUNK" USING CW-SEED WS-CX WS-CZ CE-CHUNK WS-MARKER
         MOVE WS-CX TO WS-LAST-CX
         MOVE WS-CZ TO WS-LAST-CZ
     END-IF
     MOVE 0 TO L-HEIGHT
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-Y FROM 127 BY -1 UNTIL WS-Y < 0 OR WS-DONE = 1
         COMPUTE WS-IDX = WS-Y * 256 + WS-LZ * 16 + WS-LX + 1
         IF CE-STATE(WS-IDX) NOT = 0
             COMPUTE L-HEIGHT = WS-Y + 1
             MOVE 1 TO WS-DONE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ENDCITY-HEIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENDCITY-PIECES.
*> USING nothing: the layout EC-PIECE as template pieces of kind 16 in the builder (9.1: template end_city/<name>, the structure-block ignoring processor, or the one that also ignores air when
*> overwrite is 0), after the builder's reset.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 COPY STRUCTEC.
 COPY STRUCTPIECE.
 01 WS-PROC-OW-KEY         PIC X(80) VALUE "cobolcraft:inline/ignore_structure_block".
 01 WS-PROC-KEEP-KEY       PIC X(80) VALUE "cobolcraft:inline/ignore_structure_and_air".
 01 WS-PROC-OW             BINARY-LONG.
 01 WS-PROC-KEEP           BINARY-LONG.
 01 WS-PROC                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ID                  PIC X(96).
 01 WS-ROW                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 16.
 01 WS-MIR                 BINARY-LONG VALUE 0.
 01 WS-PX                  BINARY-LONG VALUE 0.
 01 WS-PY                  BINARY-LONG VALUE 0.
 01 WS-PZ                  BINARY-LONG VALUE 0.
 01 WS-LIQUID              BINARY-LONG VALUE 0.
 01 WS-AUX                 BINARY-LONG VALUE 0.
 01 WS-PIECE               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "SPB-RESET"
     CALL "STRUCT-PROC-LOAD" USING WS-PROC-OW-KEY WS-PROC-OW
     CALL "STRUCT-PROC-LOAD" USING WS-PROC-KEEP-KEY WS-PROC-KEEP
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EC-COUNT
         MOVE SPACES TO WS-ID
         STRING "minecraft:end_city/" FUNCTION TRIM(EP-NAME(WS-I)) DELIMITED BY SIZE INTO WS-ID
         CALL "STRUCT-TPL-LOAD" USING SD-DIR WS-ID WS-ROW
         MOVE WS-PROC-KEEP TO WS-PROC
         IF EP-OW(WS-I) = 1
             MOVE WS-PROC-OW TO WS-PROC
         END-IF
         CALL "STRUCT-TPL-PIECE-ADD" USING WS-KIND WS-ROW EP-X(WS-I) EP-Y(WS-I) EP-Z(WS-I) EP-ROT(WS-I) WS-MIR
             WS-PX WS-PY WS-PZ WS-PROC WS-LIQUID WS-AUX WS-PIECE
     END-PERFORM
     GOBACK.
 END PROGRAM ENDCITY-PIECES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENDCITY-FIND-POINT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-RNG                 BINARY-DOUBLE UNSIGNED.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-ROT                 BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-X2                  BINARY-LONG.
 01 WS-Z2                  BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-BIOMES.
    05 WS-BIOME            BINARY-LONG OCCURS 16 TIMES.
 01 WS-HIGH-NAME           PIC X(40) VALUE "minecraft:end_highlands".
 01 WS-MID-NAME            PIC X(40) VALUE "minecraft:end_midlands".
 01 WS-HIGH                BINARY-LONG.
 01 WS-MID                 BINARY-LONG.
 01 WS-QI                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING L-SEED L-CX L-CZ L-X L-Y L-Z L-VALID.
     MOVE 0 TO L-VALID
     CALL "SPB-RESET"
     COMPUTE L-X = L-CX * 16 + 7
     COMPUTE L-Z = L-CZ * 16 + 7
     MOVE 0 TO L-Y
*>   couldValidBiomeExistInTerrainColumn: the End's biome does not depend on y, so the biome of the column's quart is the test (8.2 step 2)
     CALL "END-SETUP" USING L-SEED
     CALL "END-DIM-BIOMES" USING L-CX L-CZ WS-BIOMES
     CALL "SURFACE-BIOME-ID" USING WS-HIGH-NAME WS-HIGH
     CALL "SURFACE-BIOME-ID" USING WS-MID-NAME WS-MID
     COMPUTE WS-LX = L-X - L-CX * 16
     COMPUTE WS-LZ = L-Z - L-CZ * 16
     COMPUTE WS-QI = (WS-LZ / 4) * 4 + WS-LX / 4 + 1
     IF WS-BIOME(WS-QI) NOT = WS-HIGH AND WS-BIOME(WS-QI) NOT = WS-MID
         GOBACK
     END-IF
*>   the rotation is the first draw; the corners of getLowestYIn5by5Box follow from it
     COMPUTE WS-USEED = FUNCTION MOD(L-SEED + WS-M64, WS-M64)
     CALL "JRAND-LARGE-FEATURE-SEED" USING WS-RNG WS-USEED L-CX L-CZ
     CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG WS-FOUR WS-ROT
     CALL "ENDCITY-CORNER" USING WS-ROT WS-SX WS-SZ
     CALL "ENDCITY-HEIGHT" USING L-X L-Z WS-H
     MOVE WS-H TO WS-MIN
     COMPUTE WS-Z2 = L-Z + WS-SZ
     CALL "ENDCITY-HEIGHT" USING L-X WS-Z2 WS-H
     COMPUTE WS-MIN = FUNCTION MIN(WS-MIN, WS-H)
     COMPUTE WS-X2 = L-X + WS-SX
     CALL "ENDCITY-HEIGHT" USING WS-X2 L-Z WS-H
     COMPUTE WS-MIN = FUNCTION MIN(WS-MIN, WS-H)
     CALL "ENDCITY-HEIGHT" USING WS-X2 WS-Z2 WS-H
     COMPUTE WS-MIN = FUNCTION MIN(WS-MIN, WS-H)
     MOVE WS-MIN TO L-Y
     CALL "ENDCITY-START" USING WS-USEED L-CX L-CZ WS-MIN L-VALID
     IF L-VALID = 1
         CALL "ENDCITY-PIECES"
     END-IF
     GOBACK.
 END PROGRAM ENDCITY-FIND-POINT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENDCITY-MARKER.
*> USING row, metadata, x, y, z: EndCityPiece.handleDataMarker (9.4), the prefix tested in this order: Chest (the table chests/end_city_treasure on the chest below), Sentry (a shulker at the
*> centre of the marker cell, not persistent), Elytra (an item frame holding an elytra, GENT-ADD-FRAME).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LOOT                PIC X(48) VALUE "minecraft:chests/end_city_treasure".
 01 WS-SHULKER             PIC X(32) VALUE "minecraft:shulker".
 01 WS-PERSISTENT          BINARY-LONG VALUE 0.
 COPY STRUCTPIECE.
 01 WS-ELYTRA              PIC X(32) VALUE "minecraft:elytra".
 01 WS-FACING              BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-META                 PIC X(96).
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-META L-X L-Y L-Z.
     EVALUATE TRUE
         WHEN L-META(1:5) = "Chest"
             CALL "STRUCT-MARKER-LOOT" USING L-X L-Y L-Z WS-LOOT
         WHEN L-META(1:6) = "Sentry"
             COMPUTE WS-FX = L-X + 0.5
             MOVE L-Y TO WS-FY
             COMPUTE WS-FZ = L-Z + 0.5
             CALL "GENT-ADD-MOB" USING WS-FX WS-FY WS-FZ WS-SHULKER WS-PERSISTENT
         WHEN L-META(1:6) = "Elytra"
*>           an item frame at the marker facing the piece's rotation of south (none south 3, clockwise 90 west 4, clockwise 180 north 2, counterclockwise 90 east 5) holding one elytra
             EVALUATE SP-T-ROT(L-ROW)
                 WHEN 0
                     MOVE 3 TO WS-FACING
                 WHEN 1
                     MOVE 4 TO WS-FACING
                 WHEN 2
                     MOVE 2 TO WS-FACING
                 WHEN OTHER
                     MOVE 5 TO WS-FACING
             END-EVALUATE
             CALL "GENT-ADD-FRAME" USING L-X L-Y L-Z WS-FACING WS-ELYTRA
     END-EVALUATE
     GOBACK.
 END PROGRAM ENDCITY-MARKER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-GEN-STRUCTURES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 01 WS-CITY-KEY            PIC X(80) VALUE "minecraft:end_city".
 01 WS-SET-KEY             PIC X(80) VALUE "minecraft:end_cities".
 01 WS-MIN-Y               BINARY-LONG VALUE 0.
 01 WS-HEIGHT              BINARY-LONG VALUE 128.
 01 WS-SEA                 BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SET                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-IX                  BINARY-LONG.
 01 WS-IZ                  BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 WS-CHUNK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-CHUNK                PIC X.
 PROCEDURE DIVISION USING L-CX L-CZ L-CHUNK.
     CALL "STRUCT-DIM-OPEN" USING WS-CITY-KEY L-CX L-CZ L-CHUNK WS-MIN-Y WS-HEIGHT WS-SEA WS-ROW
     IF WS-ROW = 0
         GOBACK
     END-IF
     MOVE 0 TO WS-SET
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > SD-SET-COUNT
         IF SS-KEY(WS-S) = WS-SET-KEY
             MOVE WS-S TO WS-SET
         END-IF
     END-PERFORM
*>   a table without the set has no starts (the loops below do not run)
     PERFORM VARYING WS-IX FROM 0 BY 1 UNTIL WS-IX > 16 OR WS-SET = 0
         COMPUTE WS-SX = L-CX - 8 + WS-IX
         PERFORM VARYING WS-IZ FROM 0 BY 1 UNTIL WS-IZ > 16
             COMPUTE WS-SZ = L-CZ - 8 + WS-IZ
             CALL "STRUCT-IS-CHUNK" USING WS-SET CW-SEED WS-SX WS-SZ WS-FLAG
             IF WS-FLAG = 1
                 CALL "ENDCITY-FIND-POINT" USING CW-SEED WS-SX WS-SZ WS-X WS-Y WS-Z WS-OK
                 IF WS-OK = 1
                     CALL "SPB-UNION-ALL" USING WS-BOX
                     CALL "SPB-BOX-INTERSECTS-XZ" USING WS-BOX SP-WBOX WS-CHUNK
                     IF WS-CHUNK = 1
                         CALL "STRUCT-PLACE-START"
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     CALL "FL-CLOSE"
     GOBACK.
 END PROGRAM END-GEN-STRUCTURES.
