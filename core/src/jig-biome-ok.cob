*> A program of its own (one program per file): a test with a synthetic terrain and no biome source defines a JIG-BIOME-OK in its own source (core/tests/JIGSEAM.cpy).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. JIG-BIOME-OK.
*> USING structure row, x, y, z, flag out: 1 when the biome at the stub of a jigsaw start is one of the structure's (STRUCT-VALID-AT, 36-1 5.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STRUCT               BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STRUCT L-X L-Y L-Z L-FLAG.
     CALL "STRUCT-VALID-AT" USING L-STRUCT L-X L-Y L-Z L-FLAG
     GOBACK.
 END PROGRAM JIG-BIOME-OK.
