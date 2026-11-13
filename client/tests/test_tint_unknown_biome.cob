*> Implementation test of TINT-BIOME-AT (tint-43.cob) for a biome id the client holds no colours for: a standard world's
*> generated chunks name biomes (ids 15, 60) that the registry sync did not describe, and their water and grass would tint
*> black (colours 0). The biome of such a cell is the plains biome, as for a cell of an unloaded chunk.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TINT-UNKNOWN-BIOME.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CELLS.
 COPY CLTINT.
 COPY TESTLIB.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ID                  BINARY-LONG.
 01 WS-T                   COMP-2 VALUE 0.8.
 01 WS-D                   COMP-2 VALUE 0.4.
 01 WS-WATER               BINARY-DOUBLE VALUE 4282349284.
 01 WS-NONE                BINARY-DOUBLE VALUE -1.
 01 WS-NONE2               BINARY-DOUBLE VALUE -1.
 01 WS-NONE3               BINARY-DOUBLE VALUE -1.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-MOD                 PIC X(16) VALUE "none".
 01 WS-X                   BINARY-LONG VALUE 0.
 01 WS-Y                   BINARY-LONG VALUE 70.
 01 WS-X4                  BINARY-LONG VALUE 4.
 01 WS-Z                   BINARY-LONG VALUE 0.
 01 WS-BIOME               BINARY-LONG.
 01 WS-BIOME-E             PIC 999.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE 384 TO PL-HEIGHT
     MOVE -64 TO PL-MIN-Y
     MOVE 0 TO WS-ID
     CALL "TINT-BIOME-SET" USING WS-ID WS-T WS-D WS-WATER WS-NONE WS-NONE2 WS-NONE3 WS-MOD
     MOVE 0 TO TT-PLAINS
     CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-ZERO WS-ZERO2 WS-ROW
     SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW)
*>   Block (0, 70, 0) is in 4 x 4 x 4 cell 1 + (134 / 4) * 16: set the cell of x 0 and the one of x 4.
     MOVE 60 TO CE-BIOME(33 * 16 + 1)
     MOVE 0 TO CE-BIOME(33 * 16 + 2)
     MOVE "T" TO TL-MODE
     MOVE "tint-biome-at given a cell whose biome id has no colours when asked then it is the plains biome 000"
         TO TL-CASE
     MOVE "000" TO TL-EXPECTED
     CALL "TINT-BIOME-AT" USING CLIENT-STATE WS-X WS-Y WS-Z WS-BIOME
     MOVE WS-BIOME TO WS-BIOME-E
     MOVE WS-BIOME-E TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO TT-PLAINS
     MOVE 5 TO TT-BIOMES
     MOVE 3 TO CE-BIOME(33 * 16 + 1)
     MOVE "tint-biome-at given a cell whose biome id has colours when asked then it is that biome 003" TO TL-CASE
     MOVE "003" TO TL-EXPECTED
     CALL "TINT-BIOME-AT" USING CLIENT-STATE WS-X WS-Y WS-Z WS-BIOME
     MOVE WS-BIOME TO WS-BIOME-E
     MOVE WS-BIOME-E TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 9 TO CE-BIOME(33 * 16 + 1)
     MOVE "tint-biome-at given the plains biome elsewhere than id 0 and a cell above the table when asked then it is plains 001"
         TO TL-CASE
     MOVE "001" TO TL-EXPECTED
     CALL "TINT-BIOME-AT" USING CLIENT-STATE WS-X WS-Y WS-Z WS-BIOME
     MOVE WS-BIOME TO WS-BIOME-E
     MOVE WS-BIOME-E TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-TINT-UNKNOWN-BIOME.
