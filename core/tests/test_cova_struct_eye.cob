*> Implementation test (coverage lane A; docs/protocol/36-structures-5 section 3.10; core/src/struct-eye.cob): a locate for a set number outside the loaded sets finds nothing, and the lookup
*> by name also works when the loaded set's key has no namespace.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVA-STRUCT-EYE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTDATA.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/struct".
 01 WS-CLIMATE-DIR         PIC X(1100) VALUE "core/tests/fixtures/density".
 01 WS-STATUS              BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-SET                 BINARY-LONG VALUE 6.
 01 WS-ZERO-SET            BINARY-LONG VALUE 0.
 01 WS-OX                  BINARY-LONG VALUE 0.
 01 WS-OY                  BINARY-LONG VALUE 64.
 01 WS-OZ                  BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-NAME                PIC X(40).
 01 WS-KEY-SAVED           PIC X(80).
 01 WS-FIRST-X             BINARY-LONG.
 01 WS-FIRST-Z             BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "STRUCT-LOAD" USING WS-DIR WS-STATUS
     CALL "WORLDGEN-FREE"
     CALL "NOISES-LOAD" USING WS-CLIMATE-DIR WS-STATUS
     CALL "DENSITY-FUNCTIONS-LOAD" USING WS-CLIMATE-DIR WS-STATUS
     MOVE 0 TO WS-SEED
     MOVE 0 TO WS-USEED
     CALL "DENSITY-SETUP" USING WS-USEED
     CALL "CLIMATE-POINTS-RESET"
     CALL "STRUCT-POSSIBLE-BUILD"
     CALL "STRUCT-NEAREST-RING" USING WS-ZERO-SET WS-SEED WS-OX WS-OY WS-OZ WS-FOUND WS-CX WS-CZ WS-X WS-Y WS-Z
     MOVE "test cova struct eye a set number outside the loaded sets finds nothing" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-FOUND TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     CALL "STRUCT-NEAREST-RING" USING WS-SET WS-SEED WS-OX WS-OY WS-OZ WS-FOUND WS-CX WS-CZ WS-X WS-Y WS-Z
     MOVE WS-CX TO WS-FIRST-X
     MOVE WS-CZ TO WS-FIRST-Z
     MOVE SS-KEY(WS-SET) TO WS-KEY-SAVED
     MOVE SPACES TO WS-NAME
     IF WS-KEY-SAVED(1:10) = "minecraft:"
         MOVE WS-KEY-SAVED(11:40) TO WS-NAME
     ELSE
         MOVE WS-KEY-SAVED(1:40) TO WS-NAME
     END-IF
     MOVE SPACES TO SS-KEY(WS-SET)
     MOVE WS-NAME TO SS-KEY(WS-SET)
     CALL "STRUCT-NEAREST-NAMED" USING WS-NAME WS-SEED WS-OX WS-OY WS-OZ WS-FOUND WS-CX WS-CZ WS-X WS-Y WS-Z
     MOVE WS-KEY-SAVED TO SS-KEY(WS-SET)
     MOVE "test cova struct eye a set whose key has no namespace is found by its name" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-FOUND TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE "test cova struct eye and gives the same nearest chunk as the lookup by number" TO WS-CASE
     COMPUTE WS-E = WS-FIRST-X * 100000 + WS-FIRST-Z
     COMPUTE WS-O = WS-CX * 100000 + WS-CZ
     CALL "CA-N" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-COVA-STRUCT-EYE.
 COPY COVATEST.
