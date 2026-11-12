*> Implementation test of WORLD-GEN-DATA-OPEN (core/src/api.cob): a standard world loads the terrain data of the generated data folder
*> (<directory>/vanilla-data: here the terrain fixture) so GEN-DATA-READY is 1; the cobolcraft and debug types load nothing. Before this
*> nothing in the core loaded the density functions, GEN-DATA-READY stayed 0 and a standard world was the void placeholder.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GEN-DATA-OPEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-TYPE                PIC X(10).
 01 WS-DIR                 PIC X(1024) VALUE "build/gen-data-open".
 01 WS-COMMAND             PIC X(300).
 01 WS-READY               BINARY-LONG.
 01 WS-E1                  PIC -(5)9.
 01 WS-E2                  PIC -(5)9.
 01 WS-E3                  PIC -(5)9.
 PROCEDURE DIVISION.
     MOVE "rm -rf build/gen-data-open && mkdir -p build/gen-data-open && cp -R core/tests/fixtures/terrain build/gen-data-open/vanilla-data"
         TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "WORLDGEN-FREE"
     CALL "GEN-DATA-READY" USING WS-READY
     MOVE WS-READY TO WS-E1
     MOVE "cobolcraft" TO WS-TYPE
     CALL "WORLD-GEN-DATA-OPEN" USING WS-TYPE WS-DIR
     CALL "GEN-DATA-READY" USING WS-READY
     MOVE WS-READY TO WS-E2
     MOVE "standard" TO WS-TYPE
     CALL "WORLD-GEN-DATA-OPEN" USING WS-TYPE WS-DIR
     CALL "GEN-DATA-READY" USING WS-READY
     MOVE WS-READY TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "T" TO TL-MODE
     MOVE "gen data open nothing loaded at first, none for a cobolcraft world, the density functions for a standard world" TO TL-CASE
     MOVE "0 0 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-GEN-DATA-OPEN.
