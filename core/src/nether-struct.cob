*> The structures of the Nether's chunk (docs/protocol/36-structures-8-nether-and-end.md sections 2 and 5, 37-nether-6 sections 2 and 3, 36-1 sections 5 and 8): after the terrain and the placed
*> features of a Nether chunk, the fortress starts of the 17 by 17 chunks around it (the structure set nether_complexes of NETHER-STRUCTURE-CANDIDATE and NETHER-STRUCTURE-PICK) are rebuilt from
*> the level seed and placed into the chunk (NETHER-GEN-STRUCTURES), and the chest and spawner requests and the spawn boxes the pieces made are published for the install (NETHER-BE-PUBLISH).
*> Deviations: the start's biome is read at the candidate chunk's first quart, not at the stub (the centre of the start piece); the structures are placed after all the placed features, not at
*> their own decoration step between them. The bastion remnant is the generic jigsaw start of STRUCT-FIND-POINT (36-3).
*> Entry points: NETHER-GEN-STRUCTURES USING chunk x, chunk z, chunk memory; NETHER-BE-PUBLISH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-STRUCT-BIOME-AT.
*> USING quart x, quart z, index out (the biome id), biome out (PIC X(40)): the Nether's biome of a quart column (the biome source ignores y): the 4 by 4 quarts of its chunk (NETHER-DIM-BIOMES),
*> named from the five Nether biomes.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BIOMES.
    05 WS-BIOME            BINARY-LONG OCCURS 16 TIMES.
 01 WS-NAMES.
    05 FILLER              PIC X(40) VALUE "minecraft:nether_wastes".
    05 FILLER              PIC X(40) VALUE "minecraft:soul_sand_valley".
    05 FILLER              PIC X(40) VALUE "minecraft:crimson_forest".
    05 FILLER              PIC X(40) VALUE "minecraft:warped_forest".
    05 FILLER              PIC X(40) VALUE "minecraft:basalt_deltas".
 01 WS-NAME-TAB REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(40) OCCURS 5 TIMES.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-QX                   BINARY-LONG.
 01 L-QZ                   BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-BIOME                PIC X(40).
 PROCEDURE DIVISION USING L-QX L-QZ L-INDEX L-BIOME.
     COMPUTE WS-CX = FUNCTION INTEGER(L-QX / 4)
     COMPUTE WS-CZ = FUNCTION INTEGER(L-QZ / 4)
     COMPUTE WS-LX = L-QX - WS-CX * 4
     COMPUTE WS-LZ = L-QZ - WS-CZ * 4
     CALL "NETHER-DIM-BIOMES" USING WS-CX WS-CZ WS-BIOMES
     MOVE WS-BIOME(WS-LZ * 4 + WS-LX + 1) TO L-INDEX
     MOVE SPACES TO L-BIOME
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 5
         CALL "SURFACE-BIOME-ID" USING WS-NAME(WS-J) WS-ID
         IF WS-ID = L-INDEX
             MOVE WS-NAME(WS-J) TO L-BIOME
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM NETHER-STRUCT-BIOME-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-DIM-OPEN.
*> USING structure key (PIC X(80)), chunk x, chunk z, chunk memory, min y, height, sea level, row out: the preparation of the structure part of decoration (36-1 8) in a dimension whose chunk
*> generator is not the standard job pipeline: the row of the structure in the table (0, and nothing prepared, when it is not gated on or not loaded), the level view of the chunk (FL-OPEN) and
*> the write box, the decoration random seeded by setDecorationSeed and setFeatureSeed(decorationSeed, index among the structures of the step, step) as STRUCT-DECORATE does, in SP-XR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 COPY FEATLEVEL.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-XR== LEADING ==XR-== BY ==WX-==.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-ON                  BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-R2                  BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-PTR                 USAGE POINTER.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-DECOR               BINARY-DOUBLE UNSIGNED.
 01 WS-FSEED               BINARY-DOUBLE UNSIGNED.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(80).
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-CHUNK                PIC X.
 01 L-MIN-Y                BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-SEA                  BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-CX L-CZ L-CHUNK L-MIN-Y L-HEIGHT L-SEA L-ROW.
     MOVE 0 TO L-ROW
     CALL "STRUCT-GATE" USING L-KEY WS-ON
     IF WS-ON = 0
         GOBACK
     END-IF
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > SD-ST-COUNT
         IF SDT-KEY(WS-R) = L-KEY
             MOVE WS-R TO L-ROW
         END-IF
     END-PERFORM
     IF L-ROW = 0
         GOBACK
     END-IF
     MOVE SDT-STEP(L-ROW) TO WS-STEP
     MOVE 0 TO WS-K
     PERFORM VARYING WS-R2 FROM 1 BY 1 UNTIL WS-R2 > SD-ST-COUNT
         IF SDT-STEP(WS-R2) = WS-STEP AND SDT-KEY(WS-R2) < L-KEY
             ADD 1 TO WS-K
         END-IF
     END-PERFORM
     COMPUTE WS-USEED = FUNCTION MOD(CW-SEED + WS-M64, WS-M64)
     MOVE CW-SEED TO SP-SEED
     SET WS-PTR TO ADDRESS OF L-CHUNK
     CALL "FL-OPEN" USING WS-PTR L-CX L-CZ L-MIN-Y L-HEIGHT L-SEA
     CALL "MSP-OPEN"
     COMPUTE WS-BX = L-CX * 16
     COMPUTE WS-BZ = L-CZ * 16
     CALL "ORE-DECOR-SEED" USING WS-USEED WS-BX WS-BZ WS-XR WS-DECOR
     CALL "ORE-FEATURE-SEED" USING WS-DECOR WS-K WS-STEP WS-FSEED
     CALL "WGR-SET-SEED" USING WS-XR WS-FSEED
     MOVE WX-LO TO SP-XR-LO
     MOVE WX-HI TO SP-XR-HI
     GOBACK.
 END PROGRAM STRUCT-DIM-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-GEN-STRUCTURES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STRUCTPIECE.
 COPY STRUCTDIM.
 01 WS-KEYS.
    05 FILLER              PIC X(80) VALUE "minecraft:fortress".
    05 FILLER              PIC X(80) VALUE "minecraft:bastion_remnant".
 01 WS-KEY-TAB REDEFINES WS-KEYS.
    05 WS-KEY              PIC X(80) OCCURS 2 TIMES.
 01 WS-MIN-Y               BINARY-LONG VALUE 0.
 01 WS-HEIGHT              BINARY-LONG VALUE 256.
 01 WS-SEA                 BINARY-LONG VALUE 32.
 01 WS-SET                 BINARY-LONG VALUE 1.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-IX                  BINARY-LONG.
 01 WS-IZ                  BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-CAND-X              BINARY-LONG.
 01 WS-CAND-Z              BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-VALID.
    05 WS-V1               PIC 9.
    05 WS-V2               PIC 9.
    05 FILLER              PIC X(5) VALUE SPACES.
 01 WS-BIOME-NAMES.
    05 FILLER              PIC X(40) VALUE "minecraft:nether_wastes".
    05 FILLER              PIC X(40) VALUE "minecraft:soul_sand_valley".
    05 FILLER              PIC X(40) VALUE "minecraft:crimson_forest".
    05 FILLER              PIC X(40) VALUE "minecraft:warped_forest".
    05 FILLER              PIC X(40) VALUE "minecraft:basalt_deltas".
 01 WS-BIOME-TAB REDEFINES WS-BIOME-NAMES.
    05 WS-BIOME-NAME       PIC X(40) OCCURS 5 TIMES.
 01 WS-NUM                 BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-ALLOWED             BINARY-LONG.
 01 WS-STRUCT-BASTION      BINARY-LONG VALUE 2.
 01 WS-PICKED              BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 WS-CHUNK               BINARY-LONG.
 01 WS-BIOMES.
    05 WS-BIOME            BINARY-LONG OCCURS 16 TIMES.
 01 WS-N                   BINARY-LONG VALUE 0.
 01 WS-STARTS.
    05 WS-START OCCURS 16 TIMES.
       10 WS-ST-X          BINARY-LONG.
       10 WS-ST-Z          BINARY-LONG.
       10 WS-ST-KIND       BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-CHUNK                PIC X.
 PROCEDURE DIVISION USING L-CX L-CZ L-CHUNK.
*>   the starts of the 17 by 17 chunks around: the set's candidate, the weighted pick of 37-6 section 2 (fortress, else the bastion); the biome of the chunk's first quart stands for
*>   the stub's: the fortress is valid in every Nether biome, the bastion in all but the basalt deltas
     MOVE 0 TO WS-N
     PERFORM VARYING WS-IX FROM 0 BY 1 UNTIL WS-IX > 16
         COMPUTE WS-SX = L-CX - 8 + WS-IX
         PERFORM VARYING WS-IZ FROM 0 BY 1 UNTIL WS-IZ > 16
             COMPUTE WS-SZ = L-CZ - 8 + WS-IZ
             CALL "NETHER-STRUCTURE-CANDIDATE" USING CW-SEED WS-SET WS-SX WS-SZ WS-CAND-X WS-CAND-Z WS-FLAG
             IF WS-FLAG = 1
                 CALL "NETHER-DIM-BIOMES" USING WS-SX WS-SZ WS-BIOMES
                 MOVE 1 TO WS-V1
                 MOVE 0 TO WS-NUM
                 PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 5
                     CALL "SURFACE-BIOME-ID" USING WS-BIOME-NAME(WS-J) WS-ID
                     IF WS-ID = WS-BIOME(1)
                         MOVE WS-J TO WS-NUM
                     END-IF
                 END-PERFORM
                 CALL "NETHER-STRUCTURE-BIOME" USING WS-STRUCT-BASTION WS-NUM WS-ALLOWED
                 MOVE WS-ALLOWED TO WS-V2
                 CALL "NETHER-STRUCTURE-PICK" USING CW-SEED WS-SET WS-SX WS-SZ WS-VALID WS-PICKED
                 IF WS-PICKED > 0 AND WS-N < 16
                     ADD 1 TO WS-N
                     MOVE WS-SX TO WS-ST-X(WS-N)
                     MOVE WS-SZ TO WS-ST-Z(WS-N)
                     MOVE WS-PICKED TO WS-ST-KIND(WS-N)
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
*>   each structure with a start is placed with its own decoration random, the biome source of the structure code being the Nether's
     MOVE 1 TO SDM-KIND
     PERFORM VARYING WS-KIND FROM 1 BY 1 UNTIL WS-KIND > 2
         MOVE 0 TO WS-ROW
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
             IF WS-ST-KIND(WS-I) = WS-KIND AND WS-ROW = 0
                 CALL "STRUCT-DIM-OPEN" USING WS-KEY(WS-KIND) L-CX L-CZ L-CHUNK WS-MIN-Y WS-HEIGHT WS-SEA WS-ROW
             END-IF
             IF WS-ST-KIND(WS-I) = WS-KIND AND WS-ROW > 0
                 MOVE WS-ST-X(WS-I) TO WS-SX
                 MOVE WS-ST-Z(WS-I) TO WS-SZ
                 CALL "STRUCT-FIND-POINT" USING WS-ROW CW-SEED WS-SX WS-SZ WS-X WS-Y WS-Z WS-OK
                 CALL "SPB-UNION-ALL" USING WS-BOX
                 CALL "SPB-BOX-INTERSECTS-XZ" USING WS-BOX SP-WBOX WS-CHUNK
                 IF WS-CHUNK = 1
                     CALL "STRUCT-PLACE-START"
                     CALL "STRUCT-OVR-NOTE" USING WS-KEY(WS-KIND) L-CX L-CZ WS-BOX
                 END-IF
             END-IF
         END-PERFORM
         IF WS-ROW > 0
             CALL "FL-CLOSE"
         END-IF
     END-PERFORM
*>   the nether fossils: the last structure of the underground_decoration step (index 2 after the ancient city and the fortress, 36-1 section 8)
     CALL "NETHER-GEN-FOSSIL" USING L-CX L-CZ L-CHUNK
     MOVE 0 TO SDM-KIND
     GOBACK.
 END PROGRAM NETHER-GEN-STRUCTURES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-GEN-FOSSIL.
*> USING chunk x, chunk z, chunk memory: the nether fossil of a Nether chunk (37-nether-6 sections 3.4 and 7, 36-4 section 9). The start of the chunk's own 3 by 3 chunks (a fossil box reaches at most 6 blocks
*> beyond its start's chunk, so no start farther away touches the chunk) is found as the structure stage finds one (NETHER-FOSSIL-START: the candidate of the set nether_fossils, the biome of the chunk's
*> first quart, NFOS-FIND-POINT, which leaves the piece in the builder) and, when the piece's box reaches the chunk's columns, placed by STRUCT-PLACE-START (the piece's post-process is NFOS-POST: the whole
*> template box is taken into the write box, the template written with the ignore processor, then the dried ghast). The structure is placed only while the gate of "minecraft:nether_fossil" is on.
*> Deviation: as for the fortress, the biome of the chunk's first quart stands for the stub's, and the structure is placed after all the placed features and the fortress and bastion of the chunk.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STRUCTPIECE.
 01 WS-KEY                 PIC X(80) VALUE "minecraft:nether_fossil".
 01 WS-MIN-Y               BINARY-LONG VALUE 0.
 01 WS-HEIGHT              BINARY-LONG VALUE 256.
 01 WS-SEA                 BINARY-LONG VALUE 32.
 01 WS-ON                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-IX                  BINARY-LONG.
 01 WS-IZ                  BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-REACH               BINARY-LONG.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 WS-COLUMNS.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==C-==.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-CHUNK                PIC X.
 PROCEDURE DIVISION USING L-CX L-CZ L-CHUNK.
     CALL "STRUCT-GATE" USING WS-KEY WS-ON
     IF WS-ON = 0
         GOBACK
     END-IF
     COMPUTE C-X0 = L-CX * 16
     COMPUTE C-X1 = C-X0 + 15
     COMPUTE C-Z0 = L-CZ * 16
     COMPUTE C-Z1 = C-Z0 + 15
     MOVE WS-MIN-Y TO C-Y0
     COMPUTE C-Y1 = WS-MIN-Y + WS-HEIGHT - 1
     MOVE 0 TO WS-ROW
     PERFORM VARYING WS-IX FROM 0 BY 1 UNTIL WS-IX > 2
         COMPUTE WS-SX = L-CX - 1 + WS-IX
         PERFORM VARYING WS-IZ FROM 0 BY 1 UNTIL WS-IZ > 2
             COMPUTE WS-SZ = L-CZ - 1 + WS-IZ
             CALL "NETHER-FOSSIL-START" USING CW-SEED WS-SX WS-SZ WS-VALID
             IF WS-VALID = 1
                 CALL "SPB-UNION-ALL" USING WS-BOX
                 CALL "SPB-BOX-INTERSECTS-XZ" USING WS-BOX WS-COLUMNS WS-REACH
                 IF WS-REACH = 1
*>                   the level view of the chunk and the window are opened by the first start that reaches it (they leave the builder's piece alone)
                     IF WS-ROW = 0
                         CALL "STRUCT-DIM-OPEN" USING WS-KEY L-CX L-CZ L-CHUNK WS-MIN-Y WS-HEIGHT WS-SEA WS-ROW
                     END-IF
                     IF WS-ROW > 0
                         CALL "STRUCT-PLACE-START"
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     IF WS-ROW > 0
         CALL "FL-CLOSE"
     END-IF
     GOBACK.
 END PROGRAM NETHER-GEN-FOSSIL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-BE-PUBLISH.
*> No parameters: the level's block entity and entity requests (GENBE.cpy, GENENT.cpy) become the published lists the install reads (GEN-BE, GEN-ENT), and the level's are emptied.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY GENBE.
 COPY GENENT.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE GBL-COUNT TO GB-COUNT
     MOVE GBL-LOST TO GB-LOST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GBL-COUNT
         MOVE GBL-ENTRY(WS-I) TO GB-ENTRY(WS-I)
     END-PERFORM
     MOVE GEL-COUNT TO GE-COUNT
     MOVE GEL-LOST TO GE-LOST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GEL-COUNT
         MOVE GEL-ENTRY(WS-I) TO GE-ENTRY(WS-I)
     END-PERFORM
     MOVE GEL-BOX-COUNT TO GE-BOX-COUNT
     MOVE GEL-BOX-LOST TO GE-BOX-LOST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GEL-BOX-COUNT
         MOVE GEL-BOX(WS-I) TO GE-BOX(WS-I)
     END-PERFORM
     MOVE 0 TO GBL-COUNT GBL-LOST GEL-COUNT GEL-LOST GEL-BOX-COUNT GEL-BOX-LOST
     GOBACK.
 END PROGRAM NETHER-BE-PUBLISH.
