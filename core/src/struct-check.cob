*> StructureCheck (docs/protocol/36-structures-1-model-placement-starts.md section 7.6; STRUCTCHECK.cpy): answers whether chunk (x, z) holds a start of a structure without loading the chunk, for the locate search.
*> Answers: 0 START_PRESENT, 1 START_NOT_PRESENT, 2 CHUNK_LOAD_NEEDED. Step 2 of the document (the partial scan of the chunk's stored start data, three possible NBT layouts and a data fixer) has no
*> storage to read here: the chunks the core knows are loaded through STRUCT-CHECK-ON-LOAD (7.6 onStructureLoad) from the store of starts, so a chunk not in loadedChunks counts as nothing found in storage
*> (it is added to the without-starts set, which is emptied when it reaches 131072 entries, 7.6 state). The old-world data fixer is out of scope (Open question 9).
*>
*> Entry points:
*>   STRUCT-CHECK-RESET: empties loadedChunks, featureChecks and the without-starts set
*>   STRUCT-CHECK-ON-LOAD USING chunk x, chunk z: onStructureLoad: loadedChunks[chunk] = the valid starts the store holds for the chunk with their references; the chunk leaves the without-starts set, its
*>     memoised featureChecks are dropped
*>   STRUCT-CHECK-INCREMENT USING chunk x, chunk z, structure row: incrementReference (the stored count + 1, the map is created when missing; the chunk leaves the without-starts set)
*>   STRUCT-CHECK-CAN-CREATE USING structure row, seed (BINARY-DOUBLE), chunk x, chunk z, flag out: canCreateStructure: the structure's generator up to the stub and the biome test of the stub (5.3 step 2), memoised
*>   STRUCT-CHECK-START USING chunk x, chunk z, structure row, set row, seed (BINARY-DOUBLE), skip referenced (0 or 1), answer out: checkStart

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-CHECK-RESET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTCHECK.
 PROCEDURE DIVISION.
     MOVE 0 TO SCL-COUNT SCF-COUNT SCW-COUNT
     GOBACK.
 END PROGRAM STRUCT-CHECK-RESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-CHECK-FORGET.
*> USING chunk x, chunk z: the chunk leaves the without-starts set
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTCHECK.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SCW-COUNT
         IF SCW-CX(WS-I) = L-CX AND SCW-CZ(WS-I) = L-CZ
             MOVE SCW-CX(SCW-COUNT) TO SCW-CX(WS-I)
             MOVE SCW-CZ(SCW-COUNT) TO SCW-CZ(WS-I)
             SUBTRACT 1 FROM SCW-COUNT
             EXIT PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-CHECK-FORGET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-CHECK-LOADED-ROW.
*> USING chunk x, chunk z, create (0 find only, 1 make the row), row out (0 none)
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTCHECK.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-CREATE               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ L-CREATE L-ROW.
     MOVE 0 TO L-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SCL-COUNT OR L-ROW > 0
         IF SCL-CX(WS-I) = L-CX AND SCL-CZ(WS-I) = L-CZ
             MOVE WS-I TO L-ROW
         END-IF
     END-PERFORM
     IF L-ROW = 0 AND L-CREATE = 1
         IF SCL-COUNT >= SC-LOADED-MAX
             MOVE 0 TO SCL-COUNT
         END-IF
         ADD 1 TO SCL-COUNT
         MOVE SCL-COUNT TO L-ROW
         MOVE L-CX TO SCL-CX(L-ROW)
         MOVE L-CZ TO SCL-CZ(L-ROW)
         MOVE 0 TO SCL-N(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM STRUCT-CHECK-LOADED-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-CHECK-ON-LOAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTCHECK.
 COPY STRUCTSTART.
 01 WS-CREATE              BINARY-LONG VALUE 1.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ.
     CALL "STRUCT-CHECK-LOADED-ROW" USING L-CX L-CZ WS-CREATE WS-ROW
     MOVE 0 TO SCL-N(WS-ROW)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SST-COUNT
         IF SST-CX(WS-I) = L-CX AND SST-CZ(WS-I) = L-CZ AND SST-N(WS-I) > 0 AND SCL-N(WS-ROW) < 8
             ADD 1 TO SCL-N(WS-ROW)
             MOVE SST-STRUCT(WS-I) TO SCL-STRUCT(WS-ROW, SCL-N(WS-ROW))
             MOVE SST-REFS(WS-I) TO SCL-REFS(WS-ROW, SCL-N(WS-ROW))
         END-IF
     END-PERFORM
     CALL "STRUCT-CHECK-FORGET" USING L-CX L-CZ
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SCF-COUNT
         IF SCF-CX(WS-I) = L-CX AND SCF-CZ(WS-I) = L-CZ
             MOVE -1 TO SCF-VALUE(WS-I)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-CHECK-ON-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-CHECK-INCREMENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTCHECK.
 01 WS-CREATE              BINARY-LONG VALUE 1.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-STRUCT               BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ L-STRUCT.
     CALL "STRUCT-CHECK-LOADED-ROW" USING L-CX L-CZ WS-CREATE WS-ROW
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SCL-N(WS-ROW)
         IF SCL-STRUCT(WS-ROW, WS-I) = L-STRUCT
             MOVE WS-I TO WS-FOUND
         END-IF
     END-PERFORM
     IF WS-FOUND > 0
         IF SCL-REFS(WS-ROW, WS-FOUND) < 0
             MOVE 0 TO SCL-REFS(WS-ROW, WS-FOUND)
         END-IF
         ADD 1 TO SCL-REFS(WS-ROW, WS-FOUND)
     END-IF
     IF WS-FOUND = 0 AND SCL-N(WS-ROW) < 8
         ADD 1 TO SCL-N(WS-ROW)
         MOVE L-STRUCT TO SCL-STRUCT(WS-ROW, SCL-N(WS-ROW))
         MOVE 1 TO SCL-REFS(WS-ROW, SCL-N(WS-ROW))
     END-IF
     CALL "STRUCT-CHECK-FORGET" USING L-CX L-CZ
     GOBACK.
 END PROGRAM STRUCT-CHECK-INCREMENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-CHECK-CAN-CREATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTCHECK.
 01 WS-I                   BINARY-LONG.
 01 WS-MEMO                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-BIOME               BINARY-LONG.
 LINKAGE SECTION.
 01 L-STRUCT               BINARY-LONG.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STRUCT L-SEED L-CX L-CZ L-FLAG.
     MOVE 0 TO WS-MEMO
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SCF-COUNT OR WS-MEMO > 0
         IF SCF-STRUCT(WS-I) = L-STRUCT AND SCF-CX(WS-I) = L-CX AND SCF-CZ(WS-I) = L-CZ AND SCF-VALUE(WS-I) >= 0
             MOVE WS-I TO WS-MEMO
         END-IF
     END-PERFORM
     IF WS-MEMO > 0
         MOVE SCF-VALUE(WS-MEMO) TO L-FLAG
         GOBACK
     END-IF
     CALL "STRUCT-FIND-POINT" USING L-STRUCT L-SEED L-CX L-CZ WS-X WS-Y WS-Z WS-VALID
     MOVE 0 TO L-FLAG
     IF WS-VALID = 1
         CALL "STRUCT-VALID-AT" USING L-STRUCT WS-X WS-Y WS-Z WS-BIOME
         MOVE WS-BIOME TO L-FLAG
     END-IF
     IF SCF-COUNT >= SC-FEATURE-MAX
         MOVE 0 TO SCF-COUNT
     END-IF
     ADD 1 TO SCF-COUNT
     MOVE L-STRUCT TO SCF-STRUCT(SCF-COUNT)
     MOVE L-CX TO SCF-CX(SCF-COUNT)
     MOVE L-CZ TO SCF-CZ(SCF-COUNT)
     MOVE L-FLAG TO SCF-VALUE(SCF-COUNT)
     GOBACK.
 END PROGRAM STRUCT-CHECK-CAN-CREATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-CHECK-START.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTCHECK.
 01 WS-NOCREATE            BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-REFS                BINARY-LONG.
 01 WS-IN-SET              BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-CAN                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-STRUCT               BINARY-LONG.
 01 L-SET                  BINARY-LONG.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-SKIP                 BINARY-LONG.
 01 L-ANSWER               BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ L-STRUCT L-SET L-SEED L-SKIP L-ANSWER.
*>   1: a chunk loadedChunks knows is answered from its map
     CALL "STRUCT-CHECK-LOADED-ROW" USING L-CX L-CZ WS-NOCREATE WS-ROW
     IF WS-ROW = 0
*>       2: nothing in storage for a chunk that is not loaded: remember that (the set is emptied at 131072 entries, then the chunk is added)
         MOVE 0 TO WS-IN-SET
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SCW-COUNT
             IF SCW-CX(WS-I) = L-CX AND SCW-CZ(WS-I) = L-CZ
                 MOVE 1 TO WS-IN-SET
             END-IF
         END-PERFORM
         IF WS-IN-SET = 0
             IF SCW-COUNT >= SC-WITHOUT-MAX
                 MOVE 0 TO SCW-COUNT
             END-IF
             ADD 1 TO SCW-COUNT
             MOVE L-CX TO SCW-CX(SCW-COUNT)
             MOVE L-CZ TO SCW-CZ(SCW-COUNT)
         END-IF
*>       3: the cheap pre-test of the placement
         CALL "STRUCT-FREQ-OK" USING L-SET L-SEED L-CX L-CZ WS-OK
         IF WS-OK = 0
             MOVE 1 TO L-ANSWER
             GOBACK
         END-IF
*>       4 and 5: could the structure be created here at all
         CALL "STRUCT-CHECK-CAN-CREATE" USING L-STRUCT L-SEED L-CX L-CZ WS-CAN
         MOVE 1 TO L-ANSWER
         IF WS-CAN = 1
             MOVE 2 TO L-ANSWER
         END-IF
         GOBACK
     END-IF
*>   6: the structure's value in the map
     MOVE 0 TO WS-FOUND
     MOVE -1 TO WS-REFS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SCL-N(WS-ROW)
         IF SCL-STRUCT(WS-ROW, WS-I) = L-STRUCT
             MOVE SCL-REFS(WS-ROW, WS-I) TO WS-REFS
         END-IF
     END-PERFORM
     MOVE 0 TO L-ANSWER
     IF WS-REFS < 0
         MOVE 1 TO L-ANSWER
     END-IF
     IF WS-REFS > 0 AND L-SKIP = 1
         MOVE 1 TO L-ANSWER
     END-IF
     GOBACK.
 END PROGRAM STRUCT-CHECK-START.
