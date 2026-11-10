*> The feature stage of the chunk generation (docs/protocol/35-worldgen-features-1 section 6; core/src/gen-job.cob stage GJ-STAGE-FEATURES): step GJ-SUB (0 to 10) is the
*> decoration step of that number for the chunk being generated: the placed features of the biomes present in the chunk, in the order of the feature index of the step, each
*> seeded with decorationSeed + index + 10000 * step (5.1) and placed at the chunk's origin (16 cx, min y, 16 cz) through the level of feat-level.cob.
*> Deviations (the lane's notes): only the origins of this chunk are decorated and only blocks inside it are written (the 3 x 3 window of 4.1 is the chunk); the feature index
*> of a placed feature in a step is its position in the list of the step over the loaded biomes in table order, without repeats (the global sort of 11 section 6.2 is not tabulated:
*> open question 14 of 35-1). A world without loaded biomes with feature lists runs no feature.
*>
*> Entry points: GEN-STAGE-FEATURES USING job; FR-INDEX-BUILD (builds the index lists of the steps from the loaded biomes).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-INDEX-BUILD.
*> USING step lists out are in FEAT-INDEX (EXTERNAL, FEATINDEX.cpy): per step the placed feature ids in index order, built from the biome rows of the worldgen store in table order.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTWORLDGEN.
 COPY FEATINDEX.
 01 WS-I                   BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 PROCEDURE DIVISION.
     PERFORM VARYING WS-STEP FROM 1 BY 1 UNTIL WS-STEP > 11
         MOVE 0 TO FI-COUNT(WS-STEP)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WG-COUNT(4)
         IF WGF-KIND(WS-I) = 7
             MOVE WGN-CHILD(WGF-ROOT(WS-I), 1) TO WS-NODE
             PERFORM UNTIL WS-NODE = 0
                 COMPUTE WS-STEP = WGN-INT(WS-NODE, 1) + 1
                 MOVE WGN-TEXT-1(WS-NODE)(1:80) TO WS-KEY
                 IF WS-STEP >= 1 AND WS-STEP <= 11
                     MOVE 0 TO WS-FOUND
                     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > FI-COUNT(WS-STEP) OR WS-FOUND = 1
                         IF FI-KEY(WS-STEP, WS-J) = WS-KEY
                             MOVE 1 TO WS-FOUND
                         END-IF
                     END-PERFORM
                     IF WS-FOUND = 0 AND FI-COUNT(WS-STEP) < 1024
                         ADD 1 TO FI-COUNT(WS-STEP)
                         MOVE WS-KEY TO FI-KEY(WS-STEP, FI-COUNT(WS-STEP))
                     END-IF
                 END-IF
                 MOVE WGN-NEXT(WS-NODE) TO WS-NODE
             END-PERFORM
         END-IF
     END-PERFORM
     COMPUTE FI-STAMP = WG-LOAD-GEN + 1
     GOBACK.
 END PROGRAM FR-INDEX-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-STAGE-FEATURES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTWORLDGEN.
 COPY CELLS.
 COPY CBLOCKS.
 COPY CARVER.
 COPY GENSTAGE.
 COPY FEATINDEX.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-XR== LEADING ==XR-== BY ==WX-==.
 01 WS-STAMP-WG            BINARY-LONG VALUE -1.
 01 WS-STAMP-CB            BINARY-LONG VALUE -1.
 01 WS-STEP                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-SEEN.
    05 WS-SEEN-FLAG        BINARY-LONG OCCURS 256 TIMES.
 01 WS-WANT.
    05 WS-WANT-FLAG        BINARY-LONG OCCURS 1024 TIMES.
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-BIOME112            PIC X(112).
 01 WS-KEY                 PIC X(80).
 01 WS-DECOR               BINARY-DOUBLE UNSIGNED.
 01 WS-FSEED               BINARY-DOUBLE UNSIGNED.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-PF                  BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-INDEX0              BINARY-LONG.
 01 WS-HAVE                BINARY-LONG.
 01 WS-MIN-Y               BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 PROCEDURE DIVISION USING L-JOB.
     ADD 1 TO GS-FEATURE
     IF CV-READY NOT = 1 OR J-SUB > 10
         GOBACK
     END-IF
     IF WS-STAMP-WG NOT = WG-LOAD-GEN OR WS-STAMP-CB NOT = CB-EPOCH
         CALL "FD-RESET"
         MOVE WG-LOAD-GEN TO WS-STAMP-WG
         MOVE CB-EPOCH TO WS-STAMP-CB
     END-IF
     IF FI-STAMP NOT = WG-LOAD-GEN + 1
         CALL "FR-INDEX-BUILD"
     END-IF
     MOVE J-SUB TO WS-STEP
     COMPUTE WS-K = WS-STEP + 1
     IF FI-COUNT(WS-K) = 0
         GOBACK
     END-IF
     SET ADDRESS OF CE-CHUNK TO J-ADDR
*>   the biomes present in the chunk, and the placed features of the step they list
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         MOVE 0 TO WS-SEEN-FLAG(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1536
         COMPUTE WS-ID = CE-BIOME(WS-I) + 1
         MOVE 1 TO WS-SEEN-FLAG(WS-ID)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > FI-COUNT(WS-K)
         MOVE 0 TO WS-WANT-FLAG(WS-I)
     END-PERFORM
     MOVE 0 TO WS-HAVE
     PERFORM VARYING WS-ID FROM 1 BY 1 UNTIL WS-ID > CBI-COUNT
         IF WS-SEEN-FLAG(WS-ID) = 1
             MOVE CBI-KEY(WS-ID) TO WS-BIOME112
             MOVE 0 TO WS-ROW
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WG-COUNT(4) OR WS-ROW > 0
                 IF WGF-KIND(WS-I) = 7 AND WGF-KEY(WS-I) = WS-BIOME112
                     MOVE WS-I TO WS-ROW
                 END-IF
             END-PERFORM
             IF WS-ROW > 0
                 MOVE WGN-CHILD(WGF-ROOT(WS-ROW), 1) TO WS-NODE
                 PERFORM UNTIL WS-NODE = 0
                     IF WGN-INT(WS-NODE, 1) = WS-STEP
                         MOVE WGN-TEXT-1(WS-NODE)(1:80) TO WS-KEY
                         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > FI-COUNT(WS-K)
                             IF FI-KEY(WS-K, WS-J) = WS-KEY
                                 MOVE 1 TO WS-WANT-FLAG(WS-J)
                                 MOVE 1 TO WS-HAVE
                             END-IF
                         END-PERFORM
                     END-IF
                     MOVE WGN-NEXT(WS-NODE) TO WS-NODE
                 END-PERFORM
             END-IF
         END-IF
     END-PERFORM
     IF WS-HAVE = 0
         GOBACK
     END-IF
     COMPUTE WS-BX = J-CX * 16
     COMPUTE WS-BZ = J-CZ * 16
     CALL "FL-OPEN" USING J-ADDR J-CX J-CZ WS-MIN-Y WS-HEIGHT WS-SEA
     CALL "ORE-DECOR-SEED" USING CV-SEED WS-BX WS-BZ WS-XR WS-DECOR
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > FI-COUNT(WS-K)
         IF WS-WANT-FLAG(WS-J) = 1
             COMPUTE WS-INDEX0 = WS-J - 1
             CALL "ORE-FEATURE-SEED" USING WS-DECOR WS-INDEX0 WS-STEP WS-FSEED
             CALL "WGR-SET-SEED" USING WS-XR WS-FSEED
             CALL "FD-GET-PF" USING FI-KEY(WS-K, WS-J) WS-PF
             IF WS-PF > 0
                 MOVE WS-PF TO WS-TOP
                 CALL "FR-PLACE-PF" USING WS-XR WS-PF WS-TOP WS-BX WS-MIN-Y WS-BZ WS-RESULT
             END-IF
         END-IF
     END-PERFORM
     CALL "FL-CLOSE"
     GOBACK.
 END PROGRAM GEN-STAGE-FEATURES.
