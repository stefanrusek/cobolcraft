*> The fill layer feature (docs/protocol/35-worldgen-features-5-water-and-surface.md section 11; registry id 17, fill_layer): FD-FILL-NODE takes a row of FD-WA (WA-I(1) the state, WA-I(2) the height);
*> FR-FILL turns every air block of the 16 x 16 layer y = minY + height whose corner is the origin (x, z .. x + 15, z + 15) into the state (flag 2), draws nothing and returns true.
*>
*> Entry points: FD-FILL-NODE USING doc, node, row out; FR-FILL USING feature, x, y, z, result out.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-FILL-NODE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FDKEYS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW.
     MOVE 0 TO L-ROW
     IF FD-WA-COUNT >= FD-MAX-WA
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     ADD 1 TO FD-WA-COUNT
     MOVE FD-WA-COUNT TO WS-ROW
     INITIALIZE FD-WA(WS-ROW)
     MOVE WS-ROW TO L-ROW
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-STATE WS-E
     CALL "FD-J-STATE" USING JSON-DOC WS-E WA-I(WS-ROW, 1) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-HEIGHT WS-E
     CALL "FD-J-INT" USING JSON-DOC WS-E WA-I(WS-ROW, 2) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     GOBACK.
 END PROGRAM FD-FILL-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-FILL.
*> USING feature, x, y, z, result out (always 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATLEVEL.
 01 WS-ROW                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-WRITTEN             BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-FT                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-FT L-X L-Y L-Z L-RESULT.
     MOVE 1 TO L-RESULT
     MOVE FT-A(L-FT) TO WS-ROW
     COMPUTE WS-Y = FL-MIN-Y + WA-I(WS-ROW, 2)
     PERFORM VARYING WS-DX FROM 0 BY 1 UNTIL WS-DX > 15
         PERFORM VARYING WS-DZ FROM 0 BY 1 UNTIL WS-DZ > 15
             COMPUTE WS-X = L-X + WS-DX
             COMPUTE WS-Z = L-Z + WS-DZ
             CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
             CALL "FL-CLASS" USING WS-STATE WS-CLASS
             IF WS-CLASS = 1
                 CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WA-I(WS-ROW, 1) WS-FLAGS WS-WRITTEN
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM FR-FILL.
