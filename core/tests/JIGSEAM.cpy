*> Test-owned stand-ins for three production programs that sit in files of their own (core/src/jig-surface.cob, jig-biome-ok.cob, struct-portal-biome.cob): COPY this after the END PROGRAM of
*> a test whose terrain is synthetic (JIGTEST.cpy). The test object defines the program names, so the linker does not take the library's. With TJ-SURFACE 0 each does what the library's does.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. JIG-SURFACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY JIGTEST.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-H                    BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Z L-KIND L-H.
     EVALUATE TJ-SURFACE
         WHEN 1
             COMPUTE L-H = 68 + FUNCTION MOD(FUNCTION INTEGER(L-X / 4) + FUNCTION INTEGER(L-Z / 4), 5)
         WHEN 2
             MOVE -40 TO L-H
         WHEN 3
             MOVE 200 TO L-H
         WHEN OTHER
             CALL "STRUCT-BASE-HEIGHT" USING L-X L-Z L-KIND L-H
     END-EVALUATE
     GOBACK.
 END PROGRAM JIG-SURFACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JIG-BIOME-OK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY JIGTEST.
 LINKAGE SECTION.
 01 L-STRUCT               BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STRUCT L-X L-Y L-Z L-FLAG.
     MOVE 1 TO L-FLAG
     IF TJ-SURFACE NOT = 1
         CALL "STRUCT-VALID-AT" USING L-STRUCT L-X L-Y L-Z L-FLAG
     END-IF
     GOBACK.
 END PROGRAM JIG-BIOME-OK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PORTAL-BIOME.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY JIGTEST.
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
     MOVE SPACES TO L-BIOME
     IF TJ-SURFACE = 0
         CALL "STRUCT-QUART" USING L-X WS-QX
         CALL "STRUCT-QUART" USING L-Y WS-QY
         CALL "STRUCT-QUART" USING L-Z WS-QZ
         CALL "CLIMATE-BIOME-AT" USING WS-QX WS-QY WS-QZ WS-INDEX L-BIOME
     END-IF
     GOBACK.
 END PROGRAM STRUCT-PORTAL-BIOME.
