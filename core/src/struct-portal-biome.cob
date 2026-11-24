*> A program of its own (one program per file): a test with a synthetic terrain and no biome source defines a STRUCT-PORTAL-BIOME in its own source (core/tests/JIGSEAM.cpy).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PORTAL-BIOME.
*> USING x, y, z (block position), biome out (PIC X(40)): the biome of the multi-noise source at the quart cell of the position.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-BIOME                PIC X(40).
 PROCEDURE DIVISION USING L-X L-Y L-Z L-BIOME.
     CALL "STRUCT-QUART" USING L-X WS-QX
     CALL "STRUCT-QUART" USING L-Y WS-QY
     CALL "STRUCT-QUART" USING L-Z WS-QZ
     CALL "STRUCT-BIOME-AT" USING WS-QX WS-QY WS-QZ WS-INDEX L-BIOME
     GOBACK.
 END PROGRAM STRUCT-PORTAL-BIOME.
