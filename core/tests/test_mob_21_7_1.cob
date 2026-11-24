*> Wither build pattern and Nether Star (docs/protocol/21 sections 7.1 and 7.4; lane 002-lane-p49e, T18500): the pattern in a row along z with soul soil
*> and the wall skull variant, the clearing of all seven pattern blocks, the wither's spot, and the extended lifetime (age -6000) of the nether star.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-7-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROJSTATE.
 COPY BRWORLD.
 COPY RULES.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 96.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-SOIL                BINARY-LONG.
 01 WS-WALL                BINARY-LONG.
 01 WS-STAR                BINARY-LONG.
 01 WS-WITHER-T            BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SUM                 BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-CAUSE-PLAYER        BINARY-LONG VALUE CAUSE-PLAYER.

 01 WS-SLOT              BINARY-LONG.
 01 WS-AGE                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 14
     COMPUTE WS-Y0 = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FX = WS-X0 - 40
     COMPUTE WS-FZ = WS-Z0 - 40
     COMPUTE WS-GY = WS-Y0 - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-GY WS-FKIND
     MOVE "minecraft:soul_soil" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-SOIL
     MOVE "minecraft:wither_skeleton_wall_skull" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-WALL
     MOVE "minecraft:nether_star" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-STAR WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:wither" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-WITHER-T WS-ENTITY-ROW WS-STATUS
*>   A row along z: wall skulls at y0 + 2, soul soil at y0 + 1 and the base at y0 under the middle.
     PERFORM VARYING WS-I FROM -1 BY 1 UNTIL WS-I > 1
         COMPUTE WS-CZ = WS-Z0 + WS-I
         COMPUTE WS-CY = WS-Y0 + 1
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X0 WS-CY WS-CZ WS-SOIL
         COMPUTE WS-CY = WS-Y0 + 2
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X0 WS-CY WS-CZ WS-WALL
     END-PERFORM
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X0 WS-Y0 WS-Z0 WS-SOIL
     CALL "WITHER-BUILD" USING WS-DIM WS-X0 WS-CY WS-Z0
     MOVE 0 TO WS-COUNT
     MOVE 0 TO WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-WITHER-T
             ADD 1 TO WS-COUNT
             MOVE WS-I TO WS-ROW
         END-IF
     END-PERFORM
     MOVE "acceptance US15 21§7.1 Build pattern minecraft:wither a row along z of wall skulls over soul soil makes one wither" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-SUM
     PERFORM VARYING WS-I FROM -1 BY 1 UNTIL WS-I > 1
         COMPUTE WS-CZ = WS-Z0 + WS-I
         PERFORM VARYING WS-CY FROM WS-Y0 BY 1 UNTIL WS-CY > WS-Y0 + 2
             CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X0 WS-CY WS-CZ WS-STATE
             ADD WS-STATE TO WS-SUM
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US15 21§7.1 Build pattern minecraft:wither all seven pattern blocks are cleared" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SUM TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 21§7.1 Build pattern minecraft:wither the wither stands at the centre of the base column" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-X0 * 1000 + 500
     COMPUTE TL-OBSERVED-N ROUNDED = EN-X(WS-ROW) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 21§7.1 Build pattern minecraft:wither and at the base block's z centre" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-Z0 * 1000 + 500
     COMPUTE TL-OBSERVED-N ROUNDED = EN-Z(WS-ROW) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Dying drops a nether star with the extended lifetime.
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
     MOVE 0 TO PJ-I1(WS-SLOT)
     MOVE 1000 TO WS-DAMAGE
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-DAMAGE WS-CAUSE-PLAYER WS-PLAYER
     MOVE 0 TO WS-COUNT
     MOVE 0 TO WS-AGE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-ITEM(WS-I) = WS-STAR AND EN-ITEM-COUNT(WS-I) = 1
             ADD 1 TO WS-COUNT
             MOVE EN-AGE(WS-I) TO WS-AGE
         END-IF
     END-PERFORM
     MOVE "acceptance US15 21§7.4 Nether Star minecraft:wither one nether star is dropped" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 21§7.4 Nether Star minecraft:wither its age is -6000 (extended lifetime, 12000 ticks)" TO TL-CASE
     MOVE -6000 TO TL-EXPECTED-N
     MOVE WS-AGE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-21-7-1.
 COPY CORETEST.
 COPY MOBSPTEST.
