*> The bamboo feature (docs/protocol/35-worldgen-features-4-decorators-and-vegetation.md section 6; registry id 0, compiled as FT-TYPE 1000 because 0 marks an uncompiled feature):
*> FD-BAMBOO-NODE compiles {"type": "minecraft:bamboo", "probability": ..} into a row of FD-TR (TR-PROB the probability, the pool TR-CGT the tag supports_bamboo, the pool TR-MUD the tag
*> beneath_bamboo_podzol_replaceable, TR-SOIL-STATE the podzol), FR-BAMBOO places it: the origin must be air with a block of supports_bamboo below (canSurvive of the stalk, 29b part 4 6.1);
*> n = 5 + nextInt(12) is drawn, then nextFloat() and, when it is below the probability, a podzol disc of radius 1 + nextInt(4) on the surface under the stalk; the stalk is n cells of
*> TRUNK (age 1) going up while the cells are air, and when it is at least three cells high the cell above its end gets FINAL_LARGE and the two below it TOP_LARGE and TOP_SMALL.
*> The 12 states of the stalk are age (0..1) x leaves (none, small, large) x stage (0..1), index age * 6 + leaves * 2 + stage (24 part 6). Writes use flags 2.
*>
*> Entry points: FD-BAMBOO-NODE USING doc, node, row out; FR-BAMBOO USING state, feature, x, y, z, result out.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-BAMBOO-NODE.
*> USING doc, node, row out: compiles a bamboo feature into a row of FD-TR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-K-PROB              PIC X(40) VALUE "probability".
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-TAG-SUPPORT         PIC X(112) VALUE "minecraft:supports_bamboo".
 01 WS-TAG-PODZOL          PIC X(112) VALUE "minecraft:beneath_bamboo_podzol_replaceable".
 01 WS-PODZOL              PIC X(48) VALUE "minecraft:podzol".
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW.
     MOVE 0 TO L-ROW
     IF FD-TR-COUNT >= 256
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     ADD 1 TO FD-TR-COUNT
     MOVE FD-TR-COUNT TO WS-ROW
     INITIALIZE FD-TR(WS-ROW)
     MOVE WS-ROW TO L-ROW
     CALL "FD-TREE-FLOAT" USING JSON-DOC L-NODE WS-K-PROB WS-ZERO TR-PROB(WS-ROW)
     COMPUTE TR-CGT-START(WS-ROW) = FD-POOL-COUNT + 1
     CALL "FD-TAG-BLOCKS" USING WS-TAG-SUPPORT TR-CGT-N(WS-ROW)
     COMPUTE TR-MUD-START(WS-ROW) = FD-POOL-COUNT + 1
     CALL "FD-TAG-BLOCKS" USING WS-TAG-PODZOL TR-MUD-N(WS-ROW)
     CALL "GEN-BLOCK-STATE" USING WS-PODZOL TR-SOIL-STATE(WS-ROW)
     GOBACK.
 END PROGRAM FD-BAMBOO-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-BAMBOO.
*> USING state, feature, x, y, z, result out (1 when the origin passed the test of step 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY CBLOCKS.
 01 WS-KEY                 PIC X(48) VALUE "minecraft:bamboo".
 01 WS-ROW                 BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-SURFACE             BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-TWELVE              BINARY-LONG VALUE 12.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-ORDINAL             BINARY-LONG VALUE 0.
 01 WS-F                   FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-FT                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FT L-X L-Y L-Z L-RESULT.
     MOVE 0 TO L-RESULT
     MOVE FT-A(L-FT) TO WS-ROW
     CALL "FD-BLOCK-INDEX" USING WS-KEY WS-B
     CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
     CALL "FL-CLASS" USING WS-STATE WS-CLASS
     COMPUTE WS-CY = L-Y - 1
     CALL "FL-GET-STATE" USING L-X WS-CY L-Z WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     CALL "FR-POOL-HAS" USING TR-CGT-START(WS-ROW) TR-CGT-N(WS-ROW) WS-BLOCK WS-OK
     IF WS-CLASS = 1 AND WS-OK = 1 AND WS-B > 0
         IF CB-STATES(WS-B) = 12
             MOVE 1 TO L-RESULT
         END-IF
     END-IF
     IF L-RESULT = 1
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-TWELVE WS-DRAW
         COMPUTE WS-N = 5 + WS-DRAW
         CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
         MOVE TR-PROB(WS-ROW) TO WS-P
         CALL "FR-F32" USING WS-P
         IF WS-F < WS-P
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-FOUR WS-DRAW
             COMPUTE WS-R = 1 + WS-DRAW
             COMPUTE WS-LO = 0 - WS-R
             PERFORM VARYING WS-DX FROM WS-LO BY 1 UNTIL WS-DX > WS-R
                 PERFORM VARYING WS-DZ FROM WS-LO BY 1 UNTIL WS-DZ > WS-R
                     IF WS-DX * WS-DX + WS-DZ * WS-DZ <= WS-R * WS-R
                         COMPUTE WS-X = L-X + WS-DX
                         COMPUTE WS-Z = L-Z + WS-DZ
                         CALL "FL-HEIGHT-OF" USING WS-ORDINAL WS-X WS-Z WS-SURFACE
                         COMPUTE WS-Y = WS-SURFACE - 1
                         CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
                         CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
                         CALL "FR-POOL-HAS" USING TR-MUD-START(WS-ROW) TR-MUD-N(WS-ROW) WS-BLOCK WS-OK
                         IF WS-OK = 1
                             CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z TR-SOIL-STATE(WS-ROW) WS-FLAGS WS-OK
                         END-IF
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-IF
         MOVE L-Y TO WS-CY
         MOVE 0 TO WS-STOP
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N OR WS-STOP = 1
             CALL "FL-GET-STATE" USING L-X WS-CY L-Z WS-STATE
             CALL "FL-CLASS" USING WS-STATE WS-CLASS
             IF WS-CLASS = 1
                 COMPUTE WS-STATE = CB-FIRST-STATE(WS-B) + 6
                 CALL "FL-SET-STATE" USING L-X WS-CY L-Z WS-STATE WS-FLAGS WS-OK
                 ADD 1 TO WS-CY
             ELSE
                 MOVE 1 TO WS-STOP
             END-IF
         END-PERFORM
         IF WS-CY - L-Y >= 3
             COMPUTE WS-STATE = CB-FIRST-STATE(WS-B) + 11
             CALL "FL-SET-STATE" USING L-X WS-CY L-Z WS-STATE WS-FLAGS WS-OK
             COMPUTE WS-Y = WS-CY - 1
             COMPUTE WS-STATE = CB-FIRST-STATE(WS-B) + 10
             CALL "FL-SET-STATE" USING L-X WS-Y L-Z WS-STATE WS-FLAGS WS-OK
             COMPUTE WS-Y = WS-CY - 2
             COMPUTE WS-STATE = CB-FIRST-STATE(WS-B) + 8
             CALL "FL-SET-STATE" USING L-X WS-Y L-Z WS-STATE WS-FLAGS WS-OK
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FR-BAMBOO.
