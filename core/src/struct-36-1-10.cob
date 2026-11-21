*> The spawn overrides of structures (docs/protocol/36-structures-1-model-placement-starts.md section 10, and adjustBoundingBox of 5.4). The query ChunkGenerator.getMobsAt takes the structures that reference
*> the chunk of the position (the caller collects them, in its iteration order, into SPAWNSEL.cpy together with their referencing starts' piece boxes and bounding boxes) and answers the first structure that has
*> a spawn_overrides entry for the mob category and a valid start that covers the position: for bounding_box piece some piece box contains it, for full the start's bounding box does (boxes are inclusive on
*> every axis). No such structure: the answer is 0 and the caller uses the biome's own list for the category (an override replaces that list only where it covers).
*> Entry points:
*>   STRUCT-SPAWN-SELECT USING SPAWN-SELECT, x, y, z, structure out (the row number in SPS-STRUCT, 0 for none)
*>   STRUCT-ADJUST-BOX USING terrain adaptation (0 none, 1 bury, 2 beard_thin, 3 beard_box, 4 encapsulate), minX, minY, minZ, maxX, maxY, maxZ (in and out): the box itself for none, else inflated by 12 in every direction

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-SPAWN-SELECT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-S                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 LINKAGE SECTION.
 COPY SPAWNSEL.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-WIN                  BINARY-LONG.
 PROCEDURE DIVISION USING SPAWN-SELECT L-X L-Y L-Z L-WIN.
     MOVE 0 TO L-WIN
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > SPS-COUNT OR L-WIN > 0
         IF SPS-OVERRIDE(WS-S) = 1
             MOVE 0 TO WS-HIT
             PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > SPS-STARTS(WS-S)
                 IF SPS-VALID(WS-S, WS-T) = 1
                     IF SPS-MODE(WS-S) = 1
                         IF L-X >= SPS-BX0(WS-S, WS-T) AND L-X <= SPS-BX1(WS-S, WS-T)
                             AND L-Y >= SPS-BY0(WS-S, WS-T) AND L-Y <= SPS-BY1(WS-S, WS-T)
                             AND L-Z >= SPS-BZ0(WS-S, WS-T) AND L-Z <= SPS-BZ1(WS-S, WS-T)
                             MOVE 1 TO WS-HIT
                         END-IF
                     ELSE
                         PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > SPS-PIECES(WS-S, WS-T)
                             IF L-X >= SPS-PX0(WS-S, WS-T, WS-P) AND L-X <= SPS-PX1(WS-S, WS-T, WS-P)
                                 AND L-Y >= SPS-PY0(WS-S, WS-T, WS-P) AND L-Y <= SPS-PY1(WS-S, WS-T, WS-P)
                                 AND L-Z >= SPS-PZ0(WS-S, WS-T, WS-P) AND L-Z <= SPS-PZ1(WS-S, WS-T, WS-P)
                                 MOVE 1 TO WS-HIT
                             END-IF
                         END-PERFORM
                     END-IF
                 END-IF
             END-PERFORM
             IF WS-HIT = 1
                 MOVE WS-S TO L-WIN
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-SPAWN-SELECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-ADJUST-BOX.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MODE                 BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 PROCEDURE DIVISION USING L-MODE L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1.
     IF L-MODE NOT = 0
         SUBTRACT 12 FROM L-X0 L-Y0 L-Z0
         ADD 12 TO L-X1 L-Y1 L-Z1
     END-IF
     GOBACK.
 END PROGRAM STRUCT-ADJUST-BOX.
