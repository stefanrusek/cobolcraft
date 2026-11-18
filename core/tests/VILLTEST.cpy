*> Helpers of the villager brain tests (lane 002-lane-p49p; COPY after the test program and after MOBSPTEST, touch the test after changing it).
*>   VT-FLAT USING player row, floor y out: a stone floor of 64 x 64 blocks round the player at the y below its feet, three layers of air above (the villagers' ground).
*>   VT-PLACE USING dim, x, y, z, block key (PIC X(112)), state pairs (PIC X(160)): set one block.
*>   VT-SPAWN USING dim, x, y, z (BINARY-LONG feet block), row out, slot out: a villager standing in the middle of that block.
*>   VT-MOB USING key (PIC X(112)), dim, x, y, z (BINARY-LONG feet block), row out: any mob standing in the middle of that block.
*>   VT-SCAN USING dim, x, z (BINARY-LONG block): the POI index of the chunk of that column (24 sections).
*>   VT-DAY USING time of day: set the world clock (CW-TIME) and keep CW-TICKS.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. VT-FLAT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-X0                   BINARY-LONG.
 01 WS-Z0                   BINARY-LONG.
 01 WS-SIZE                 BINARY-LONG VALUE 64.
 01 WS-KIND                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-PLAYER                BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-Y.
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(L-PLAYER)) - 32
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(L-PLAYER)) - 32
     COMPUTE L-Y = FUNCTION INTEGER(PL-Y(L-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING PL-DIM(L-PLAYER) WS-X0 WS-Z0 WS-SIZE L-Y WS-KIND
     GOBACK.
 END PROGRAM VT-FLAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VT-PLACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STATE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                   BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 01 L-KEY                   PIC X(112).
 01 L-PAIRS                 PIC X(160).
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-KEY L-PAIRS.
     CALL "BLOCKS-STATE-OF" USING L-KEY L-PAIRS WS-STATE
     CALL "WORLD-SET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     GOBACK.
 END PROGRAM VT-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VT-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                  PIC X(112).
 01 WS-ENTITY-ROW           PIC X(66).
 01 WS-STATUS               BINARY-LONG.
 01 WS-TYPE                 BINARY-LONG.
 01 WS-FX                   FLOAT-LONG.
 01 WS-FY                   FLOAT-LONG.
 01 WS-FZ                   FLOAT-LONG.
 01 WS-YAW                  FLOAT-SHORT VALUE 0.
 01 WS-NO                   BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                   BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 01 L-ROW                   BINARY-LONG.
 01 L-SLOT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-ROW L-SLOT.
     MOVE "minecraft:villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-FX = L-X + 0.5
     MOVE L-Y TO WS-FY
     COMPUTE WS-FZ = L-Z + 0.5
     CALL "MOB-SPAWN" USING L-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW L-ROW
     CALL "VL-FIND" USING EN-ID(L-ROW) WS-NO L-SLOT
     GOBACK.
 END PROGRAM VT-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VT-SCAN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILPOIX.
 01 WS-CX                   BINARY-LONG.
 01 WS-CZ                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                   BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Z.
     COMPUTE WS-CX = FUNCTION INTEGER(L-X / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(L-Z / 16)
     MOVE 0 TO PX-DONE-N
     PERFORM 24 TIMES
         CALL "PXI-SCAN" USING L-DIM WS-CX WS-CZ
     END-PERFORM
     GOBACK.
 END PROGRAM VT-SCAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VT-DAY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-TIME                  BINARY-LONG.
 PROCEDURE DIVISION USING L-TIME.
     MOVE L-TIME TO CW-TIME
     GOBACK.
 END PROGRAM VT-DAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VT-MOB.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ENTITY-ROW           PIC X(66).
 01 WS-STATUS               BINARY-LONG.
 01 WS-TYPE                 BINARY-LONG.
 01 WS-FX                   FLOAT-LONG.
 01 WS-FY                   FLOAT-LONG.
 01 WS-FZ                   FLOAT-LONG.
 01 WS-YAW                  FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 01 L-KEY                   PIC X(112).
 01 L-DIM                   BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 01 L-ROW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-DIM L-X L-Y L-Z L-ROW.
     CALL "CONTENT-ENTITY-BY-KEY" USING L-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-FX = L-X + 0.5
     MOVE L-Y TO WS-FY
     COMPUTE WS-FZ = L-Z + 0.5
     CALL "MOB-SPAWN" USING L-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW L-ROW
     GOBACK.
 END PROGRAM VT-MOB.
