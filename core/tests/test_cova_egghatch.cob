*> Implementation test (coverage lane A; core/src/thrown-44b.cob EGG-HATCH): when no content set is open the chicken entity type is unknown (0) and a hatching egg spawns nothing.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVA-EGGHATCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-DIM                 BINARY-LONG VALUE 0.
 01 WS-X                   FLOAT-LONG VALUE 0.
 01 WS-Y                   FLOAT-LONG VALUE 64.
 01 WS-Z                   FLOAT-LONG VALUE 0.
 01 WS-R8                  BINARY-LONG VALUE 0.
 01 WS-R32                 BINARY-LONG VALUE 0.
 01 WS-BEFORE              BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE EN-COUNT TO WS-BEFORE
     CALL "EGG-HATCH" USING WS-DIM WS-X WS-Y WS-Z WS-R8 WS-R32
     MOVE "test cova egghatch a hatching egg without a content set spawns no chick" TO WS-CASE
     MOVE WS-BEFORE TO WS-E
     MOVE EN-COUNT TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-COVA-EGGHATCH.
 COPY COVATEST.
