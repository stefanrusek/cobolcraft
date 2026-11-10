*> The step programs of the resumable chunk generation (gen-job.cob; GENJOB.cpy, GENSTEPS.cpy), one per stage of the TERRAIN
*> pipeline of docs/protocol/10 section 11.1. Each is called with the job and does the work of step GJ-SUB of its stage,
*> which is a bounded piece: GEN-STAGE-BIOMES one layer of 4 x 4 quart cells, GEN-STAGE-DENSITY one column of cell corners,
*> GEN-STAGE-FILL one slab of four block rows. Each increments its counter of GENSTAGE.cpy.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-STAGE-BIOMES.
*> Quart layer GJ-SUB (0 to 95, quart y -16 + GJ-SUB) of the chunk's biome cells (06 section 5.4 order: (y mod 16 div 4) * 16 + (z div 4) * 4 + (x div 4)): the
*> biome of the multi-noise source at each quart cell (10 sections 7.1 to 7.3, 7.6; the quart cell's own position).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY CELLS.
 COPY CLIMATE.
 COPY GENSTAGE.
 01 WS-LY                  BINARY-LONG.
 01 WS-SECTION             BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-BIOME               PIC X(40).
 01 WS-LAST                PIC X(40) VALUE SPACES.
 01 WS-ID                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 PROCEDURE DIVISION USING L-JOB.
     ADD 1 TO GS-CLIMATE
     IF CL-COUNT = 0
         CALL "OVB-BUILD"
     END-IF
     SET ADDRESS OF CE-CHUNK TO J-ADDR
     MOVE SPACES TO WS-LAST
     MOVE 0 TO WS-ID
     DIVIDE J-SUB BY 4 GIVING WS-SECTION REMAINDER WS-LY
     COMPUTE WS-QY = -16 + J-SUB
         PERFORM VARYING WS-LZ FROM 0 BY 1 UNTIL WS-LZ > 3
             PERFORM VARYING WS-LX FROM 0 BY 1 UNTIL WS-LX > 3
                 COMPUTE WS-QX = J-CX * 4 + WS-LX
                 COMPUTE WS-QZ = J-CZ * 4 + WS-LZ
                 CALL "CLIMATE-BIOME-AT" USING WS-QX WS-QY WS-QZ WS-INDEX WS-BIOME
                 IF WS-BIOME NOT = WS-LAST
                     MOVE WS-BIOME TO WS-LAST
                     MOVE 0 TO WS-ID
                     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CBI-COUNT
                         MOVE CBI-KEY-LENGTH(WS-I) TO WS-LEN
                         IF WS-LEN > 0 AND WS-LEN <= 40
                             COMPUTE WS-NEXT = WS-LEN + 1
                             IF CBI-KEY(WS-I)(1:WS-LEN) = WS-BIOME(1:WS-LEN) AND WS-BIOME(WS-NEXT:1) = SPACE
                                 COMPUTE WS-ID = WS-I - 1
                             END-IF
                         END-IF
                     END-PERFORM
                 END-IF
                 COMPUTE WS-CELL = WS-SECTION * 64 + WS-LY * 16 + WS-LZ * 4 + WS-LX + 1
                 MOVE WS-ID TO CE-BIOME(WS-CELL)
             END-PERFORM
         END-PERFORM
     GOBACK.
 END PROGRAM GEN-STAGE-BIOMES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-STAGE-DENSITY.
*> Column GJ-SUB (0 to 24, index i * 5 + j for corner x i, corner z j) of the interpolation grids: for every interpolated
*> node of the final density, the value of its input at the 49 corner heights (y -64 to 320 step 8) of that column of corners.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTWORLDGEN.
 COPY GENSTAGE.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-V                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 PROCEDURE DIVISION USING L-JOB.
     ADD 1 TO GS-DENSITY
     ADD 1 TO GS-NOISE
     DIVIDE J-SUB BY 5 GIVING WS-I REMAINDER WS-J
     COMPUTE WS-X = J-CX * 16 + 4 * WS-I
     COMPUTE WS-Z = J-CZ * 16 + 4 * WS-J
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > J-G-COUNT
         PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 48
             COMPUTE WS-Y = -64 + 8 * WS-K
             CALL "DENSITY-NODE" USING WGN-CHILD(J-G-NODE(WS-N), 1) WS-X WS-Y WS-Z WS-V
             MOVE WS-V TO J-G-VAL((WS-N - 1) * 1225 + (WS-I * 5 + WS-J) * 49 + WS-K + 1)
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM GEN-STAGE-DENSITY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-STAGE-FILL.
*> Slab GJ-SUB (0 to 95) of the terrain fill: TERRAIN-FILL-SLAB (terrain.cob).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 PROCEDURE DIVISION USING L-JOB.
     CALL "TERRAIN-FILL-SLAB" USING L-JOB
     GOBACK.
 END PROGRAM GEN-STAGE-FILL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-STAGE-CARVERS.
*> Placeholder until the carvers of document 11 section 5 (carvers.cob): counts the step.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY GENSTAGE.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 PROCEDURE DIVISION USING L-JOB.
     ADD 1 TO GS-CARVER
     GOBACK.
 END PROGRAM GEN-STAGE-CARVERS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-STAGE-ORES.
*> Placeholder until the ores of document 11 sections 7 and 8 (ores.cob): counts the step.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY GENSTAGE.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 PROCEDURE DIVISION USING L-JOB.
     ADD 1 TO GS-ORE
     GOBACK.
 END PROGRAM GEN-STAGE-ORES.
