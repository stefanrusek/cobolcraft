*> The ender dragon fight controller (docs/protocol/21 section 6.4.5; lane 002-lane-mobsb8, T9704).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. FIGHT-KILLED.
*> USING dim: the dragon of the fight died.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM.
     GOBACK.
 END PROGRAM FIGHT-KILLED.
