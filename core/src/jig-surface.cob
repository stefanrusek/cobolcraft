*> A program of its own (one program per file): a test that needs a synthetic terrain defines a JIG-SURFACE in its own source (core/tests/JIGSEAM.cpy) and the linker takes that one.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. JIG-SURFACE.
*> USING x, z, kind (0 WORLD_SURFACE_WG, 1 OCEAN_FLOOR_WG), height out: getFirstFreeHeight of the column, the base height of the noise terrain (STRUCT-BASE-HEIGHT, no beardifier).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-H                    BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Z L-KIND L-H.
     CALL "STRUCT-BASE-HEIGHT" USING L-X L-Z L-KIND L-H
     GOBACK.
 END PROGRAM JIG-SURFACE.
