*> The disk feature (docs/protocol/35-worldgen-features-5-water-and-surface.md section 5; registry id 10, disk): FD-DISK-NODE compiles the configuration into a row of FD-WA (WA-I(1)
*> half_height, WA-IP(1) the radius int provider, WA-PR(1) the target predicate, WA-PV(1) the state provider: a simple, weighted, random_block, randomized_int or rule_based provider),
*> FR-DISK places it: the radius is drawn once, then every column of the circle (z outermost and x innermost, as betweenClosed over the square) is walked from
*> pos.y + half_height down to pos.y - half_height; a cell the target holds for takes the state of the provider at that cell (a null state writes nothing). The post-processing marks (and the "previous cell wrote"
*> flag that decides them) are not made: the generator has no post-processing list. Writes use flag 2.
*>
*> Entry points: FD-DISK-NODE USING doc, node, row out (FD-BAD set when the feature cannot be placed whole); FR-DISK USING state, feature, x, y, z, result out.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-DISK-NODE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FDKEYS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-P4.
    05 WS-Q                BINARY-LONG OCCURS 4 TIMES.
 01 WS-I                   BINARY-LONG.
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
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-STATE-PROVIDER WS-E
     CALL "FD-PROV-NODE" USING JSON-DOC WS-E WA-PV(WS-ROW, 1)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-DISK-TARGET WS-E
     CALL "FD-PRED-NODE" USING JSON-DOC WS-E WA-PR(WS-ROW, 1)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-RADIUS WS-E
     CALL "FD-J-IP" USING JSON-DOC WS-E WS-P4 WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE WS-Q(WS-I) TO WA-IPV(WS-ROW, 1, WS-I)
     END-PERFORM
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-HALF-HEIGHT WS-E
     CALL "FD-J-INT" USING JSON-DOC WS-E WA-I(WS-ROW, 1) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     GOBACK.
 END PROGRAM FD-DISK-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-DISK.
*> USING state, feature, x, y, z, result out (1 when a block was written).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-ROW                 BINARY-LONG.
 01 WS-P4.
    05 WS-Q                BINARY-LONG OCCURS 4 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-RADIUS              BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-BOTTOM              BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-XLO                 BINARY-LONG.
 01 WS-XHI                 BINARY-LONG.
 01 WS-ZLO                 BINARY-LONG.
 01 WS-ZHI                 BINARY-LONG.
 01 WS-TEST                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-WRITTEN             BINARY-LONG.
 01 WS-PRED                BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
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
     MOVE WA-I(WS-ROW, 1) TO WS-H
     COMPUTE WS-TOP = L-Y + WS-H
     COMPUTE WS-BOTTOM = L-Y - WS-H - 1
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE WA-IPV(WS-ROW, 1, WS-I) TO WS-Q(WS-I)
     END-PERFORM
     CALL "FR-INT-SAMPLE" USING L-STATE WS-P4 WS-RADIUS
     MOVE WA-PR(WS-ROW, 1) TO WS-PRED
     COMPUTE WS-ZLO = L-Z - WS-RADIUS
     COMPUTE WS-ZHI = L-Z + WS-RADIUS
     COMPUTE WS-XLO = L-X - WS-RADIUS
     COMPUTE WS-XHI = L-X + WS-RADIUS
     PERFORM VARYING WS-Z FROM WS-ZLO BY 1 UNTIL WS-Z > WS-ZHI
         PERFORM VARYING WS-X FROM WS-XLO BY 1 UNTIL WS-X > WS-XHI
             COMPUTE WS-DX = L-X - WS-X
             COMPUTE WS-DZ = L-Z - WS-Z
             IF WS-DX * WS-DX + WS-DZ * WS-DZ <= WS-RADIUS * WS-RADIUS
                 PERFORM VARYING WS-Y FROM WS-TOP BY -1 UNTIL WS-Y <= WS-BOTTOM
                     CALL "FR-PRED-TEST" USING WS-PRED WS-X WS-Y WS-Z WS-TEST
                     IF WS-TEST = 1
                         CALL "FR-PROV-STATE" USING L-STATE WA-PV(WS-ROW, 1) WS-X WS-Y WS-Z WS-STATE WS-OK
                         IF WS-OK = 1
                             CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-WRITTEN
                             MOVE 1 TO L-RESULT
                         END-IF
                     END-IF
                 END-PERFORM
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM FR-DISK.
