*> StructureStart records with pieces, references and the StructureManager queries (docs/protocol/36-structures-1-model-placement-starts.md sections 5.6, 7.1, 7.4 and 7.5; STRUCTSTART.cpy).
*> Chunk coordinates of a block are the floor of the coordinate / 16. A start list is a group of up to 64 BINARY-LONG start rows (SST-LIST-MAX).
*>
*> Entry points:
*>   STRUCT-STORE-RESET: empties the store; STRUCT-STORE-SYNC: empties it when the world seed or the structure data epoch changed (the capture and the chunk NBT reader call it)
*>   STRUCT-START-FIND USING structure row, chunk x, chunk z, start row out (0 none): the start of that structure held by the chunk
*>   STRUCT-START-PUT USING structure row, chunk x, chunk z, references, start row out: finds or creates the start and drops its pieces (a full store is emptied first); only the start put last takes pieces
*>   STRUCT-START-PIECE-ADD USING start row, type, orientation, depth, jigsaw kind (0, 1 rigid, 2 terrain_matching), ground level delta, x0, y0, z0, x1, y1, z1, piece row out (0 when it cannot be added)
*>   STRUCT-START-JUNCTION-ADD USING piece row, source x, ground y, source z: a junction of the piece added last
*>   STRUCT-START-BOX USING start row, x0, y0, z0, x1, y1, z1 out, valid out: getBoundingBox (5.6: the union of the piece boxes, inflated by 12 for a terrain-adapting structure) and isValid
*>   STRUCT-START-CAN-REF USING start row, flag out: references < 1; STRUCT-START-ADD-REF USING start row: references + 1
*>   STRUCT-REF-ADD USING chunk x, chunk z, structure row, source chunk x, source chunk z: one reference of the chunk (a set: an entry is kept once)
*>   STRUCT-REFS-CREATE USING chunk x, chunk z: createReferences (7.4)
*>   STRUCT-STARTS-FOR USING chunk x, chunk z, filter (a structure row, 0 every structure, -1 the structures that adapt the terrain), count out, list out: startsForStructure (7.5)
*>   STRUCT-STRUCTURE-AT USING x, y, z, structure row (0 any), start row out: getStructureAt (the first start whose bounding box contains the block)
*>   STRUCT-HAS-PIECE-AT USING start row, x, y, z, flag out: structureHasPieceAt
*>   STRUCT-WITH-PIECE-AT USING x, y, z, structure row (0 any), start row out: getStructureWithPieceAt
*>   STRUCT-ALL-AT USING x, z, count out, structures out, source x out, source z out (three tables of 64 BINARY-LONG): getAllStructuresAt, the references of the chunk of the column, no box test

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-STORE-RESET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTSTART.
 PROCEDURE DIVISION.
     MOVE 0 TO SST-COUNT SST-PIECE-COUNT SST-JUNC-COUNT SST-REF-COUNT SST-LOST
     GOBACK.
 END PROGRAM STRUCT-STORE-RESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-STORE-SYNC.
*> empties the store when the world seed or the structure data epoch is not the one it was filled under (the starts are a function of both), then stamps it with the current ones
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTSTART.
 COPY STRUCTDATA.
 COPY CARVER.
 PROCEDURE DIVISION.
     IF SST-SEED NOT = CV-SEED OR SST-EPOCH NOT = SD-EPOCH
         CALL "STRUCT-STORE-RESET"
         MOVE CV-SEED TO SST-SEED
         MOVE SD-EPOCH TO SST-EPOCH
     END-IF
     GOBACK.
 END PROGRAM STRUCT-STORE-SYNC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-START-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTSTART.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-STRUCT               BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-STRUCT L-CX L-CZ L-ROW.
     MOVE 0 TO L-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SST-COUNT OR L-ROW > 0
         IF SST-STRUCT(WS-I) = L-STRUCT AND SST-CX(WS-I) = L-CX AND SST-CZ(WS-I) = L-CZ
             MOVE WS-I TO L-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-START-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-START-PUT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTSTART.
 01 WS-LIMIT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-STRUCT               BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-REFS                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-STRUCT L-CX L-CZ L-REFS L-ROW.
     CALL "STRUCT-START-FIND" USING L-STRUCT L-CX L-CZ L-ROW
     COMPUTE WS-LIMIT = SST-MAX-PIECES - 1024
     IF L-ROW = 0 AND (SST-COUNT >= SST-MAX-STARTS OR SST-PIECE-COUNT > WS-LIMIT)
         CALL "STRUCT-STORE-RESET"
     END-IF
     IF L-ROW > 0 AND SST-PIECE-COUNT > WS-LIMIT
         CALL "STRUCT-STORE-RESET"
         MOVE 0 TO L-ROW
     END-IF
     IF L-ROW = 0
         ADD 1 TO SST-COUNT
         MOVE SST-COUNT TO L-ROW
     END-IF
     MOVE L-STRUCT TO SST-STRUCT(L-ROW)
     MOVE L-CX TO SST-CX(L-ROW)
     MOVE L-CZ TO SST-CZ(L-ROW)
     MOVE L-REFS TO SST-REFS(L-ROW)
     COMPUTE SST-FIRST(L-ROW) = SST-PIECE-COUNT + 1
     MOVE 0 TO SST-N(L-ROW)
     GOBACK.
 END PROGRAM STRUCT-START-PUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-START-PIECE-ADD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTSTART.
 01 WS-END                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-START                BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-ORIENT               BINARY-LONG.
 01 L-DEPTH                BINARY-LONG.
 01 L-JIG                  BINARY-LONG.
 01 L-GROUND               BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-START L-TYPE L-ORIENT L-DEPTH L-JIG L-GROUND L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1 L-ROW.
     MOVE 0 TO L-ROW
     COMPUTE WS-END = SST-FIRST(L-START) + SST-N(L-START)
     IF WS-END NOT = SST-PIECE-COUNT + 1 OR SST-PIECE-COUNT >= SST-MAX-PIECES
         ADD 1 TO SST-LOST
         GOBACK
     END-IF
     ADD 1 TO SST-PIECE-COUNT
     ADD 1 TO SST-N(L-START)
     MOVE SST-PIECE-COUNT TO L-ROW
     MOVE L-TYPE TO SPC-TYPE(L-ROW)
     MOVE L-ORIENT TO SPC-ORIENT(L-ROW)
     MOVE L-DEPTH TO SPC-DEPTH(L-ROW)
     MOVE L-JIG TO SPC-JIG(L-ROW)
     MOVE L-GROUND TO SPC-GROUND(L-ROW)
     COMPUTE SPC-J-FIRST(L-ROW) = SST-JUNC-COUNT + 1
     MOVE 0 TO SPC-J-N(L-ROW)
     MOVE L-X0 TO SPC-X0(L-ROW)
     MOVE L-Y0 TO SPC-Y0(L-ROW)
     MOVE L-Z0 TO SPC-Z0(L-ROW)
     MOVE L-X1 TO SPC-X1(L-ROW)
     MOVE L-Y1 TO SPC-Y1(L-ROW)
     MOVE L-Z1 TO SPC-Z1(L-ROW)
     GOBACK.
 END PROGRAM STRUCT-START-PIECE-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-START-JUNCTION-ADD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTSTART.
 01 WS-END                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z.
     COMPUTE WS-END = SPC-J-FIRST(L-ROW) + SPC-J-N(L-ROW)
     IF L-ROW NOT = SST-PIECE-COUNT OR WS-END NOT = SST-JUNC-COUNT + 1 OR SST-JUNC-COUNT >= SST-MAX-JUNC
         ADD 1 TO SST-LOST
         GOBACK
     END-IF
     ADD 1 TO SST-JUNC-COUNT
     ADD 1 TO SPC-J-N(L-ROW)
     MOVE L-X TO SJ-X(SST-JUNC-COUNT)
     MOVE L-Y TO SJ-Y(SST-JUNC-COUNT)
     MOVE L-Z TO SJ-Z(SST-JUNC-COUNT)
     GOBACK.
 END PROGRAM STRUCT-START-JUNCTION-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-START-BOX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTSTART.
 COPY STRUCTDATA.
 01 WS-I                   BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1 L-VALID.
     MOVE 0 TO L-VALID L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1
     IF SST-N(L-ROW) = 0
         GOBACK
     END-IF
     MOVE 1 TO L-VALID
     MOVE SPC-X0(SST-FIRST(L-ROW)) TO L-X0
     MOVE SPC-Y0(SST-FIRST(L-ROW)) TO L-Y0
     MOVE SPC-Z0(SST-FIRST(L-ROW)) TO L-Z0
     MOVE SPC-X1(SST-FIRST(L-ROW)) TO L-X1
     MOVE SPC-Y1(SST-FIRST(L-ROW)) TO L-Y1
     MOVE SPC-Z1(SST-FIRST(L-ROW)) TO L-Z1
     COMPUTE WS-LAST = SST-FIRST(L-ROW) + SST-N(L-ROW) - 1
     PERFORM VARYING WS-I FROM SST-FIRST(L-ROW) BY 1 UNTIL WS-I > WS-LAST
         MOVE FUNCTION MIN(L-X0, SPC-X0(WS-I)) TO L-X0
         MOVE FUNCTION MIN(L-Y0, SPC-Y0(WS-I)) TO L-Y0
         MOVE FUNCTION MIN(L-Z0, SPC-Z0(WS-I)) TO L-Z0
         MOVE FUNCTION MAX(L-X1, SPC-X1(WS-I)) TO L-X1
         MOVE FUNCTION MAX(L-Y1, SPC-Y1(WS-I)) TO L-Y1
         MOVE FUNCTION MAX(L-Z1, SPC-Z1(WS-I)) TO L-Z1
     END-PERFORM
     CALL "STRUCT-ADJUST-BOX" USING SDT-ADAPT(SST-STRUCT(L-ROW)) L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1
     GOBACK.
 END PROGRAM STRUCT-START-BOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-START-CAN-REF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTSTART.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-FLAG.
     MOVE 0 TO L-FLAG
     IF SST-REFS(L-ROW) < 1
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM STRUCT-START-CAN-REF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-START-ADD-REF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTSTART.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     ADD 1 TO SST-REFS(L-ROW)
     GOBACK.
 END PROGRAM STRUCT-START-ADD-REF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-REF-ADD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTSTART.
 01 WS-I                   BINARY-LONG.
 01 WS-SAME                BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-STRUCT               BINARY-LONG.
 01 L-SX                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ L-STRUCT L-SX L-SZ.
     MOVE 0 TO WS-SAME
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SST-REF-COUNT
         IF SSR-CX(WS-I) = L-CX AND SSR-CZ(WS-I) = L-CZ AND SSR-STRUCT(WS-I) = L-STRUCT
                 AND SSR-SX(WS-I) = L-SX AND SSR-SZ(WS-I) = L-SZ
             MOVE 1 TO WS-SAME
         END-IF
     END-PERFORM
     IF WS-SAME = 1
         GOBACK
     END-IF
     IF SST-REF-COUNT >= SST-MAX-REFS
         ADD 1 TO SST-LOST
         GOBACK
     END-IF
     ADD 1 TO SST-REF-COUNT
     MOVE L-CX TO SSR-CX(SST-REF-COUNT)
     MOVE L-CZ TO SSR-CZ(SST-REF-COUNT)
     MOVE L-STRUCT TO SSR-STRUCT(SST-REF-COUNT)
     MOVE L-SX TO SSR-SX(SST-REF-COUNT)
     MOVE L-SZ TO SSR-SZ(SST-REF-COUNT)
     GOBACK.
 END PROGRAM STRUCT-REF-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-REFS-CREATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTSTART.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-XLO                 BINARY-LONG.
 01 WS-XHI                 BINARY-LONG.
 01 WS-ZLO                 BINARY-LONG.
 01 WS-ZHI                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-MINX                BINARY-LONG.
 01 WS-MINZ                BINARY-LONG.
 01 WS-MAXX                BINARY-LONG.
 01 WS-MAXZ                BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ.
     COMPUTE WS-XLO = L-CX - 8
     COMPUTE WS-XHI = L-CX + 8
     COMPUTE WS-ZLO = L-CZ - 8
     COMPUTE WS-ZHI = L-CZ + 8
     COMPUTE WS-MINX = L-CX * 16
     COMPUTE WS-MINZ = L-CZ * 16
     COMPUTE WS-MAXX = WS-MINX + 15
     COMPUTE WS-MAXZ = WS-MINZ + 15
     PERFORM VARYING WS-X FROM WS-XLO BY 1 UNTIL WS-X > WS-XHI
         PERFORM VARYING WS-Z FROM WS-ZLO BY 1 UNTIL WS-Z > WS-ZHI
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SST-COUNT
                 IF SST-CX(WS-I) = WS-X AND SST-CZ(WS-I) = WS-Z
                     CALL "STRUCT-START-BOX" USING WS-I WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-VALID
                     IF WS-VALID = 1 AND WS-X1 >= WS-MINX AND WS-X0 <= WS-MAXX
                             AND WS-Z1 >= WS-MINZ AND WS-Z0 <= WS-MAXZ
                         CALL "STRUCT-REF-ADD" USING L-CX L-CZ SST-STRUCT(WS-I) WS-X WS-Z
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-REFS-CREATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-STARTS-FOR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTSTART.
 COPY STRUCTDATA.
 01 WS-I                   BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-FILTER               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-LIST.
    05 L-START             BINARY-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-CX L-CZ L-FILTER L-COUNT L-LIST.
     MOVE 0 TO L-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SST-REF-COUNT
         MOVE 0 TO WS-WANT
         IF SSR-CX(WS-I) = L-CX AND SSR-CZ(WS-I) = L-CZ
             EVALUATE TRUE
                 WHEN L-FILTER = 0
                     MOVE 1 TO WS-WANT
                 WHEN L-FILTER = -1
                     IF SDT-ADAPT(SSR-STRUCT(WS-I)) NOT = 0
                         MOVE 1 TO WS-WANT
                     END-IF
                 WHEN OTHER
                     IF SSR-STRUCT(WS-I) = L-FILTER
                         MOVE 1 TO WS-WANT
                     END-IF
             END-EVALUATE
         END-IF
         IF WS-WANT = 1
             CALL "STRUCT-START-FIND" USING SSR-STRUCT(WS-I) SSR-SX(WS-I) SSR-SZ(WS-I) WS-ROW
             IF WS-ROW > 0 AND L-COUNT < SST-LIST-MAX
                 CALL "STRUCT-START-BOX" USING WS-ROW WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-VALID
                 IF WS-VALID = 1
                     ADD 1 TO L-COUNT
                     MOVE WS-ROW TO L-START(L-COUNT)
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-STARTS-FOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-HAS-PIECE-AT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTSTART.
 01 WS-I                   BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-FLAG.
     MOVE 0 TO L-FLAG
     COMPUTE WS-LAST = SST-FIRST(L-ROW) + SST-N(L-ROW) - 1
     PERFORM VARYING WS-I FROM SST-FIRST(L-ROW) BY 1 UNTIL WS-I > WS-LAST
         IF L-X >= SPC-X0(WS-I) AND L-X <= SPC-X1(WS-I) AND L-Y >= SPC-Y0(WS-I) AND L-Y <= SPC-Y1(WS-I)
                 AND L-Z >= SPC-Z0(WS-I) AND L-Z <= SPC-Z1(WS-I)
             MOVE 1 TO L-FLAG
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-HAS-PIECE-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-STRUCTURE-AT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-LIST.
    05 WS-START            BINARY-LONG OCCURS 64 TIMES.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STRUCT               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-STRUCT L-ROW.
     MOVE 0 TO L-ROW
     COMPUTE WS-CX = FUNCTION INTEGER(L-X / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(L-Z / 16)
     CALL "STRUCT-STARTS-FOR" USING WS-CX WS-CZ L-STRUCT WS-COUNT WS-LIST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR L-ROW > 0
         CALL "STRUCT-START-BOX" USING WS-START(WS-I) WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-VALID
         IF L-X >= WS-X0 AND L-X <= WS-X1 AND L-Y >= WS-Y0 AND L-Y <= WS-Y1 AND L-Z >= WS-Z0 AND L-Z <= WS-Z1
             MOVE WS-START(WS-I) TO L-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-STRUCTURE-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-WITH-PIECE-AT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-LIST.
    05 WS-START            BINARY-LONG OCCURS 64 TIMES.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STRUCT               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-STRUCT L-ROW.
     MOVE 0 TO L-ROW
     COMPUTE WS-CX = FUNCTION INTEGER(L-X / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(L-Z / 16)
     CALL "STRUCT-STARTS-FOR" USING WS-CX WS-CZ L-STRUCT WS-COUNT WS-LIST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR L-ROW > 0
         CALL "STRUCT-HAS-PIECE-AT" USING WS-START(WS-I) L-X L-Y L-Z WS-FLAG
         IF WS-FLAG = 1
             MOVE WS-START(WS-I) TO L-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-WITH-PIECE-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-ALL-AT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTSTART.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-STRUCTS.
    05 L-STRUCT            BINARY-LONG OCCURS 64 TIMES.
 01 L-SXS.
    05 L-SX                BINARY-LONG OCCURS 64 TIMES.
 01 L-SZS.
    05 L-SZ                BINARY-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-X L-Z L-COUNT L-STRUCTS L-SXS L-SZS.
     MOVE 0 TO L-COUNT
     COMPUTE WS-CX = FUNCTION INTEGER(L-X / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(L-Z / 16)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SST-REF-COUNT
         IF SSR-CX(WS-I) = WS-CX AND SSR-CZ(WS-I) = WS-CZ AND L-COUNT < SST-LIST-MAX
             ADD 1 TO L-COUNT
             MOVE SSR-STRUCT(WS-I) TO L-STRUCT(L-COUNT)
             MOVE SSR-SX(WS-I) TO L-SX(L-COUNT)
             MOVE SSR-SZ(WS-I) TO L-SZ(L-COUNT)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-ALL-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-START-CAPTURE.
*> USING structure row, chunk x, chunk z, start row out: stores the start whose pieces are in the builder (STRUCTPIECE.cpy, after STRUCT-FIND-POINT and the placement) as the start of that structure
*> held by the chunk, once: a start already in the store is left as it is (its row is returned). A piece of the jigsaw assembler (builder type 60) is stored with the registry id of the jigsaw piece,
*> its projection (SP-T-AUX: 0 rigid, 1 terrain_matching), ground level delta (SP-F2) and the junctions of STRUCTJIG.cpy that it owns; any other builder type keeps its own number.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTSTART.
 COPY STRUCTPIECE.
 COPY STRUCTJIG.
 01 WS-KIND                BINARY-LONG VALUE 3.
 01 WS-NAME                PIC X(40) VALUE "jigsaw".
 01 WS-JIGSAW              BINARY-LONG.
 01 WS-REFS                BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-JIG                 BINARY-LONG.
 01 WS-GROUND              BINARY-LONG.
 01 WS-PROW                BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-ORIENT              BINARY-LONG.
 01 WS-DEPTH               BINARY-LONG.
 LINKAGE SECTION.
 01 L-STRUCT               BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-STRUCT L-CX L-CZ L-ROW.
     CALL "STRUCT-STORE-SYNC"
     CALL "STRUCT-START-FIND" USING L-STRUCT L-CX L-CZ L-ROW
     IF L-ROW > 0 OR SP-COUNT = 0
         GOBACK
     END-IF
     CALL "STRUCT-ENUM-ID" USING WS-KIND WS-NAME WS-JIGSAW
     CALL "STRUCT-START-PUT" USING L-STRUCT L-CX L-CZ WS-REFS L-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SP-COUNT
         MOVE SP-TYPE(WS-I) TO WS-TYPE
         MOVE 0 TO WS-JIG WS-GROUND
         IF WS-TYPE = 60
             MOVE WS-JIGSAW TO WS-TYPE
             COMPUTE WS-JIG = SP-T-AUX(WS-I) + 1
             MOVE SP-F2(WS-I) TO WS-GROUND
         END-IF
         MOVE SP-ORIENT(WS-I) TO WS-ORIENT
         MOVE SP-DEPTH(WS-I) TO WS-DEPTH
         MOVE SP-X0(WS-I) TO WS-X0
         MOVE SP-Y0(WS-I) TO WS-Y0
         MOVE SP-Z0(WS-I) TO WS-Z0
         MOVE SP-X1(WS-I) TO WS-X1
         MOVE SP-Y1(WS-I) TO WS-Y1
         MOVE SP-Z1(WS-I) TO WS-Z1
         CALL "STRUCT-START-PIECE-ADD" USING L-ROW WS-TYPE WS-ORIENT WS-DEPTH WS-JIG WS-GROUND WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-PROW
         IF WS-JIG > 0 AND WS-PROW > 0
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > JJ-COUNT
                 IF JJ-OWNER(WS-J) = WS-I
                     CALL "STRUCT-START-JUNCTION-ADD" USING WS-PROW JJ-X(WS-J) JJ-Y(WS-J) JJ-Z(WS-J)
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-START-CAPTURE.
