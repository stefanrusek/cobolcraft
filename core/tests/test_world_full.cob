*> Implementation test of the full chunk cache (core/src/world.cob WORLD-CHUNK-LOAD): with every row
*> of CORE-CHUNKS in use, loading another chunk is fatal (FR-012: cc_fatal, exit status 1 and the
*> line "FATAL chunk cache: 4096 chunks loaded"; test_world_full.expect).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-WORLD-FULL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-CX                  BINARY-LONG VALUE 0.
 01 WS-CZ                  BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CORE-MAX-CHUNKS TO CK-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-CHUNKS
         MOVE 1 TO CK-USED(WS-I)
     END-PERFORM
     CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ WS-ROW
     DISPLAY "TEST test world full cache FAIL expected=fatal observed=row " WS-ROW
     STOP RUN.
 END PROGRAM TEST-WORLD-FULL.

 COPY CORETEST.
