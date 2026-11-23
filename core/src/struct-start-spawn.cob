*> The structure spawn overrides from the stored starts (docs/protocol/36-structures-1-model-placement-starts.md section 10; SPAWNSEL.cpy, STRUCTSTART.cpy, STRUCTOVR.cpy): ChunkGenerator.getMobsAt takes every structure that
*> references the chunk of the position (getAllStructuresAt, 7.5), in the order of the chunk's reference list (Open question 5: registry order is not recorded, the insertion order of createReferences is used), tests the
*> spawn_overrides entry of each for the mob category and its referencing starts (piece mode: a piece box holds the position; full mode: the start's adjusted box does), and the first structure that qualifies gives its
*> list (STRUCT-SPAWN-SELECT). The override lists are those of 44-2 section 8 (STRUCTOVR.cpy SO-LIST): a structure key names its kind (fortress 1 and swamp hut 4 and trial chambers 6 piece, monument 2 and pillager
*> outpost 3 and ancient city 5 full), a kind has a list for a category when SO-LIST holds a row of that kind for it (category 0 is every category). The fortress's whole-box rule on nether bricks (kind 7, 44-2 8.1
*> step 1) is not part of 36-1 section 10 and stays with SO-LOOKUP's registry.
*>
*> Entry points:
*>   STRUCT-SPAWN-BUILD USING x, z, category (1 to 7), SPAWN-SELECT out, kinds out (a table of 8 BINARY-LONG: the override kind of each row of SPAWN-SELECT): the candidates of the position's chunk
*>   STRUCT-SPAWN-QUERY USING x, y, z, category, list out (a row of SO-LIST, 0 when no start qualifies, the biome's own list is used)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-SPAWN-KIND.
*> USING structure row, kind out (0 none), full out (1 bounding_box full)
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 LINKAGE SECTION.
 01 L-STRUCT               BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-FULL                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STRUCT L-KIND L-FULL.
     MOVE 0 TO L-KIND L-FULL
     EVALUATE SDT-KEY(L-STRUCT)
         WHEN "minecraft:fortress"
             MOVE 1 TO L-KIND
         WHEN "minecraft:monument"
             MOVE 2 TO L-KIND
             MOVE 1 TO L-FULL
         WHEN "minecraft:pillager_outpost"
             MOVE 3 TO L-KIND
             MOVE 1 TO L-FULL
         WHEN "minecraft:swamp_hut"
             MOVE 4 TO L-KIND
         WHEN "minecraft:ancient_city"
             MOVE 5 TO L-KIND
             MOVE 1 TO L-FULL
         WHEN "minecraft:trial_chambers"
             MOVE 6 TO L-KIND
     END-EVALUATE
     GOBACK.
 END PROGRAM STRUCT-SPAWN-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-SPAWN-LIST.
*> USING kind, category, list out (the first row of SO-LIST of that kind that has the category or every category, 0 none)
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTOVR.
 01 WS-L                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-CAT                  BINARY-LONG.
 01 L-LIST                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-CAT L-LIST.
     MOVE 0 TO L-LIST
     PERFORM VARYING WS-L FROM 1 BY 1 UNTIL WS-L > SO-LISTS OR L-LIST > 0
         IF SO-L-KIND(WS-L) = L-KIND AND (SO-L-CAT(WS-L) = L-CAT OR SO-L-CAT(WS-L) = 0)
             MOVE WS-L TO L-LIST
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-SPAWN-LIST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-SPAWN-BUILD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTSTART.
 01 WS-COUNT               BINARY-LONG.
 01 WS-STRUCTS.
    05 WS-STRUCT           BINARY-LONG OCCURS 64 TIMES.
 01 WS-SXS.
    05 WS-SX               BINARY-LONG OCCURS 64 TIMES.
 01 WS-SZS.
    05 WS-SZ               BINARY-LONG OCCURS 64 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-FULL                BINARY-LONG.
 01 WS-LIST                BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-CAT                  BINARY-LONG.
 COPY SPAWNSEL.
 01 L-KINDS.
    05 L-K                 BINARY-LONG OCCURS 8 TIMES.
 PROCEDURE DIVISION USING L-X L-Z L-CAT SPAWN-SELECT L-KINDS.
     MOVE 0 TO SPS-COUNT
     CALL "STRUCT-ALL-AT" USING L-X L-Z WS-COUNT WS-STRUCTS WS-SXS WS-SZS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
*>       one row per structure, at its first reference
         MOVE 0 TO WS-SEEN
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J >= WS-I
             IF WS-STRUCT(WS-J) = WS-STRUCT(WS-I)
                 MOVE 1 TO WS-SEEN
             END-IF
         END-PERFORM
         IF WS-SEEN = 0 AND SPS-COUNT < SPS-MAX-STRUCTS
             CALL "STRUCT-SPAWN-KIND" USING WS-STRUCT(WS-I) WS-KIND WS-FULL
             ADD 1 TO SPS-COUNT
             MOVE SPS-COUNT TO WS-ROW
             MOVE WS-KIND TO L-K(WS-ROW)
             MOVE 0 TO SPS-OVERRIDE(WS-ROW) SPS-MODE(WS-ROW) SPS-STARTS(WS-ROW)
             IF WS-KIND > 0
                 CALL "STRUCT-SPAWN-LIST" USING WS-KIND L-CAT WS-LIST
                 IF WS-LIST > 0
                     MOVE 1 TO SPS-OVERRIDE(WS-ROW)
                 END-IF
                 MOVE WS-FULL TO SPS-MODE(WS-ROW)
             END-IF
             IF SPS-OVERRIDE(WS-ROW) = 1
                 PERFORM VARYING WS-J FROM WS-I BY 1 UNTIL WS-J > WS-COUNT
                     IF WS-STRUCT(WS-J) = WS-STRUCT(WS-I) AND SPS-STARTS(WS-ROW) < SPS-MAX-STARTS
                         CALL "STRUCT-START-FIND" USING WS-STRUCT(WS-J) WS-SX(WS-J) WS-SZ(WS-J) WS-START
                         IF WS-START > 0
                             ADD 1 TO SPS-STARTS(WS-ROW)
                             MOVE SPS-STARTS(WS-ROW) TO WS-T
                             CALL "STRUCT-START-BOX" USING WS-START WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-VALID
                             MOVE WS-VALID TO SPS-VALID(WS-ROW, WS-T)
                             MOVE WS-X0 TO SPS-BX0(WS-ROW, WS-T)
                             MOVE WS-Y0 TO SPS-BY0(WS-ROW, WS-T)
                             MOVE WS-Z0 TO SPS-BZ0(WS-ROW, WS-T)
                             MOVE WS-X1 TO SPS-BX1(WS-ROW, WS-T)
                             MOVE WS-Y1 TO SPS-BY1(WS-ROW, WS-T)
                             MOVE WS-Z1 TO SPS-BZ1(WS-ROW, WS-T)
                             MOVE 0 TO SPS-PIECES(WS-ROW, WS-T)
                             COMPUTE WS-LAST = SST-FIRST(WS-START) + SST-N(WS-START) - 1
                             PERFORM VARYING WS-P FROM SST-FIRST(WS-START) BY 1 UNTIL WS-P > WS-LAST
                                 IF SPS-PIECES(WS-ROW, WS-T) < SPS-MAX-PIECES
                                     ADD 1 TO SPS-PIECES(WS-ROW, WS-T)
                                     MOVE SPC-X0(WS-P) TO SPS-PX0(WS-ROW, WS-T, SPS-PIECES(WS-ROW, WS-T))
                                     MOVE SPC-Y0(WS-P) TO SPS-PY0(WS-ROW, WS-T, SPS-PIECES(WS-ROW, WS-T))
                                     MOVE SPC-Z0(WS-P) TO SPS-PZ0(WS-ROW, WS-T, SPS-PIECES(WS-ROW, WS-T))
                                     MOVE SPC-X1(WS-P) TO SPS-PX1(WS-ROW, WS-T, SPS-PIECES(WS-ROW, WS-T))
                                     MOVE SPC-Y1(WS-P) TO SPS-PY1(WS-ROW, WS-T, SPS-PIECES(WS-ROW, WS-T))
                                     MOVE SPC-Z1(WS-P) TO SPS-PZ1(WS-ROW, WS-T, SPS-PIECES(WS-ROW, WS-T))
                                 END-IF
                             END-PERFORM
                         END-IF
                     END-IF
                 END-PERFORM
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-SPAWN-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-SPAWN-QUERY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SPAWNSEL.
 01 WS-KINDS.
    05 WS-K                BINARY-LONG OCCURS 8 TIMES.
 01 WS-WIN                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-CAT                  BINARY-LONG.
 01 L-LIST                 BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-CAT L-LIST.
     MOVE 0 TO L-LIST
     CALL "STRUCT-SPAWN-BUILD" USING L-X L-Z L-CAT SPAWN-SELECT WS-KINDS
     CALL "STRUCT-SPAWN-SELECT" USING SPAWN-SELECT L-X L-Y L-Z WS-WIN
     IF WS-WIN > 0
         CALL "STRUCT-SPAWN-LIST" USING WS-K(WS-WIN) L-CAT L-LIST
     END-IF
     GOBACK.
 END PROGRAM STRUCT-SPAWN-QUERY.
