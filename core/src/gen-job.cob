*> Resumable chunk generation (research R12, the decision on time-sliced generation; GENJOB.cpy, GENSTEPS.cpy): the standard
*> overworld's TERRAIN pipeline of docs/protocol/10 section 11.1 as a list of bounded steps over a per-chunk work state (a
*> job). The queue (gen-queue.cob) advances one job under a per-tick budget; run back to back (GEN-JOB-RUN-ALL) the same steps
*> are the atomic reference and give the same bytes. The pipeline runs only when the content library holds the overworld
*> terrain data (GEN-DATA-READY); a world without it keeps the void placeholder (worldgen-standard.cob).
*>
*> Entry points:
*>   GEN-DATA-READY USING flag out (BINARY-LONG): 1 when the density function minecraft:overworld/final_density is loaded.
*>   GEN-WORLD-SETUP: seeds the density evaluator from the open world's seed text once per world (GEN-QUEUE-RESET clears it).
*>   GEN-BLOCK-STATE USING key (PIC X(48)), state out: the default state of that block of the core's block table, 0 when absent.
*>   GEN-JOB-START USING job, dimension row, chunk x, chunk z: allocates the chunk memory and the work state.
*>   GEN-JOB-STEP USING job: runs one step; the job is complete (GJ-ACTIVE 2) after the last.
*>   GEN-JOB-INSTALL USING job, chunk memory, marker-y out: copies the finished chunk out.
*>   GEN-JOB-FREE USING job: gives the chunk memory back; the job is idle (GJ-ACTIVE 0).
*>   GEN-JOB-RUN-ALL USING dimension row, chunk x, chunk z, chunk memory, marker-y out: the atomic reference.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-DATA-READY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:overworld/final_density".
 01 WS-ROOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-FLAG.
     CALL "WG-FIND" USING WS-KIND WS-KEY WS-ROOT
     MOVE 0 TO L-FLAG
     IF WS-ROOT > 0
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM GEN-DATA-READY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-WORLD-SETUP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY COREAPI.
 COPY GENQUEUE.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-RANDOM              BINARY-LONG.
 01 WS-UNSIGNED            BINARY-DOUBLE UNSIGNED.
 PROCEDURE DIVISION.
     IF GQ-SETUP-DONE = 1
         GOBACK
     END-IF
     MOVE CW-SETTINGS TO CORE-SETTINGS
     MOVE CW-SEED TO WS-SEED
     IF WS-SEED < 0
         COMPUTE WS-UNSIGNED = WS-SEED + 18446744073709551616
     ELSE
         MOVE WS-SEED TO WS-UNSIGNED
     END-IF
     CALL "DENSITY-SETUP" USING WS-UNSIGNED
     CALL "SURFACE-SETUP" USING WS-UNSIGNED
     CALL "CARVER-SETUP" USING WS-UNSIGNED
     MOVE 1 TO GQ-SETUP-DONE
     GOBACK.
 END PROGRAM GEN-WORLD-SETUP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-BLOCK-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-I                   BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-STATE.
     MOVE 0 TO L-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT
         MOVE CB-KEY-LENGTH(WS-I) TO WS-LEN
         IF WS-LEN > 0 AND WS-LEN <= 48
             IF CB-KEY(WS-I)(1:WS-LEN) = L-KEY(1:WS-LEN)
                 IF WS-LEN = 48
                     MOVE CB-DEFAULT-STATE(WS-I) TO L-STATE
                     GOBACK
                 END-IF
                 COMPUTE WS-NEXT = WS-LEN + 1
                 IF L-KEY(WS-NEXT:1) = SPACE
                     MOVE CB-DEFAULT-STATE(WS-I) TO L-STATE
                     GOBACK
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GEN-BLOCK-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-FIND-INTERP RECURSIVE.
*> USING node (BINARY-LONG), job: adds to the job's grids (J-G-NODE) every interpolated node reachable from the node (through
*> references and operands; not into splines, find_top_surface, or the input of an interpolated node), once each.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTWORLDGEN.
 01 WS-KIND                BINARY-LONG VALUE 1.
 LOCAL-STORAGE SECTION.
 01 LS-I                   BINARY-LONG.
 01 LS-ROOT                BINARY-LONG.
 01 LS-KEY                 PIC X(112).
 LINKAGE SECTION.
 01 L-NODE                 BINARY-LONG.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 PROCEDURE DIVISION USING L-NODE L-JOB.
     IF L-NODE = 0
         GOBACK
     END-IF
     EVALUATE WGN-TYPE(L-NODE)
         WHEN 0
             MOVE WGN-TEXT-1(L-NODE)(1:112) TO LS-KEY
             CALL "WG-FIND" USING WS-KIND LS-KEY LS-ROOT
             CALL "GEN-FIND-INTERP" USING LS-ROOT L-JOB
         WHEN 29
             CONTINUE
         WHEN 31
             CONTINUE
         WHEN 32
             PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > J-G-COUNT
                 IF J-G-NODE(LS-I) = L-NODE
                     GOBACK
                 END-IF
             END-PERFORM
             IF J-G-COUNT < 16
                 ADD 1 TO J-G-COUNT
                 MOVE L-NODE TO J-G-NODE(J-G-COUNT)
             END-IF
         WHEN OTHER
             PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > 16
                 IF WGN-CHILD(L-NODE, LS-I) > 0
                     CALL "GEN-FIND-INTERP" USING WGN-CHILD(L-NODE, LS-I) L-JOB
                 END-IF
             END-PERFORM
     END-EVALUATE
     GOBACK.
 END PROGRAM GEN-FIND-INTERP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-JOB-START.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY GENSTEPS.
 01 WS-BYTES               BINARY-LONG VALUE 304640.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:overworld/final_density".
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-JOB L-DIM L-CX L-CZ.
     CALL "GEN-WORLD-SETUP"
     MOVE 1 TO J-ACTIVE
     MOVE L-DIM TO J-DIM
     MOVE L-CX TO J-CX
     MOVE L-CZ TO J-CZ
     MOVE 1 TO J-STAGE
     MOVE 0 TO J-SUB
     MOVE 0 TO J-STEPS
     MOVE 0 TO J-G-COUNT
     MOVE 0 TO J-AQ-READY
     MOVE LOW-VALUES TO J-CV
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         MOVE -65 TO J-HM-SURFACE(WS-I)
         MOVE -65 TO J-HM-OCEAN(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3456
         MOVE 0 TO J-SF-RING(WS-I)
     END-PERFORM
     ALLOCATE WS-BYTES CHARACTERS INITIALIZED RETURNING J-ADDR
     CALL "WG-FIND" USING WS-KIND WS-KEY J-FINAL-ROOT
     CALL "GEN-FIND-INTERP" USING J-FINAL-ROOT L-JOB
     GOBACK.
 END PROGRAM GEN-JOB-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-JOB-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY GENSTEPS.
 01 WS-LIMIT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 PROCEDURE DIVISION USING L-JOB.
     IF J-ACTIVE NOT = 1
         GOBACK
     END-IF
     EVALUATE J-STAGE
         WHEN GJ-STAGE-BIOMES
             CALL "GEN-STAGE-BIOMES" USING L-JOB
             MOVE GJ-STEPS-BIOMES TO WS-LIMIT
         WHEN GJ-STAGE-DENSITY
             CALL "GEN-STAGE-DENSITY" USING L-JOB
             MOVE GJ-STEPS-DENSITY TO WS-LIMIT
         WHEN GJ-STAGE-AQUIFER
             CALL "AQUIFER-PREP" USING L-JOB
             MOVE GJ-STEPS-AQUIFER TO WS-LIMIT
         WHEN GJ-STAGE-FILL
             CALL "GEN-STAGE-FILL" USING L-JOB
             MOVE GJ-STEPS-FILL TO WS-LIMIT
         WHEN GJ-STAGE-SURFACE
             CALL "GEN-STAGE-SURFACE" USING L-JOB
             MOVE GJ-STEPS-SURFACE TO WS-LIMIT
         WHEN GJ-STAGE-CARVERS
             CALL "GEN-STAGE-CARVERS" USING L-JOB
             MOVE GJ-STEPS-CARVERS TO WS-LIMIT
         WHEN GJ-STAGE-ORES
             CALL "GEN-STAGE-ORES" USING L-JOB
             MOVE GJ-STEPS-ORES TO WS-LIMIT
         WHEN OTHER
             MOVE GJ-STEPS-FINISH TO WS-LIMIT
     END-EVALUATE
     ADD 1 TO J-STEPS
     ADD 1 TO J-SUB
     IF J-SUB >= WS-LIMIT
         ADD 1 TO J-STAGE
         MOVE 0 TO J-SUB
     END-IF
     IF J-STAGE > GJ-STAGE-COUNT
         MOVE 2 TO J-ACTIVE
     END-IF
     GOBACK.
 END PROGRAM GEN-JOB-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-JOB-INSTALL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SRC                 PIC X(304640) BASED.
 01 WS-DST                 PIC X(304640) BASED.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 01 L-CHUNK                PIC X.
 01 L-MARKER-Y             BINARY-LONG.
 PROCEDURE DIVISION USING L-JOB L-CHUNK L-MARKER-Y.
     SET ADDRESS OF WS-SRC TO J-ADDR
     SET ADDRESS OF WS-DST TO ADDRESS OF L-CHUNK
     MOVE WS-SRC TO WS-DST
     MOVE -1 TO L-MARKER-Y
     GOBACK.
 END PROGRAM GEN-JOB-INSTALL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-JOB-FREE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 PROCEDURE DIVISION USING L-JOB.
     IF J-ADDR NOT = NULL
         FREE J-ADDR
         SET J-ADDR TO NULL
     END-IF
     MOVE 0 TO J-ACTIVE
     GOBACK.
 END PROGRAM GEN-JOB-FREE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-JOB-RUN-ALL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==W-==.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-CHUNK                PIC X.
 01 L-MARKER-Y             BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ L-CHUNK L-MARKER-Y.
     CALL "GEN-JOB-START" USING WS-JOB L-DIM L-CX L-CZ
     PERFORM UNTIL W-ACTIVE NOT = 1
         CALL "GEN-JOB-STEP" USING WS-JOB
     END-PERFORM
     CALL "GEN-JOB-INSTALL" USING WS-JOB L-CHUNK L-MARKER-Y
     CALL "GEN-JOB-FREE" USING WS-JOB
     GOBACK.
 END PROGRAM GEN-JOB-RUN-ALL.
