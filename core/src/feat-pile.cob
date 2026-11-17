*> The block pile feature (docs/protocol/35-worldgen-features-5-water-and-surface.md section 12; registry id 3, block_pile): FD-PILE-NODE takes a row of FD-WA (WA-PV(1) the state_provider, FD-BAD when it is
*> missing or a type that is not compiled, as `rotated` of pile_hay; WA-I(1) the block index of dirt_path), FR-PILE places it: false below minY + 5; a = 2 + nextInt(2), b = 2 + nextInt(2); over the box
*> pos + (-a, 0, -b) .. pos + (a, 1, b) (x fastest, z slowest) a cell is tried when the squared horizontal distance d <= t, t = nextFloat() * 10f - nextFloat() * 6f (float32, rounded after each of the three
*> operations), else when a third draw nextFloat() < 0.031; a tried cell takes the provider state (flag 260, no update) when it is air and the block below is a full face (CB-OPAQUE, as has_sturdy_face) or,
*> for dirt_path, nextBoolean(). The result is true once the y check passes.
*>
*> Entry points: FD-PILE-NODE USING doc, node, row out; FR-PILE USING state, feature, x, y, z, result out.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-PILE-NODE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FDKEYS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-NAME                PIC X(48).
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
     MOVE "minecraft:dirt_path" TO WS-NAME
     CALL "FD-BLOCK-INDEX" USING WS-NAME WA-I(WS-ROW, 1)
     GOBACK.
 END PROGRAM FD-PILE-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-PILE.
*> USING state, feature, x, y, z, result out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY CBLOCKS.
 COPY FEATLEVEL.
 01 WS-ROW                 BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-B2                  BINARY-LONG VALUE 2.
 01 WS-BITS24              BINARY-LONG VALUE 24.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-XLO                 BINARY-LONG.
 01 WS-ZLO                 BINARY-LONG.
 01 WS-MINY5               BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-KU                  BINARY-DOUBLE.
 01 WS-KV                  BINARY-DOUBLE.
 01 WS-KW                  BINARY-DOUBLE.
 01 WS-F1                  FLOAT-SHORT.
 01 WS-F2                  FLOAT-SHORT.
 01 WS-FT                  FLOAT-SHORT.
 01 WS-FD                  FLOAT-SHORT.
 01 WS-DL                  FLOAT-LONG.
 01 WS-TL                  FLOAT-LONG.
 01 WS-SCALE               FLOAT-LONG VALUE 16777216.
 01 WS-TRY                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-BOOL                BINARY-LONG.
 01 WS-PLACE               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-WRITTEN             BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 260.
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
     COMPUTE WS-MINY5 = FL-MIN-Y + 5
     IF L-Y < WS-MINY5
         GOBACK
     END-IF
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B2 WS-A
     ADD 2 TO WS-A
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B2 WS-B
     ADD 2 TO WS-B
     COMPUTE WS-XLO = L-X - WS-A
     COMPUTE WS-ZLO = L-Z - WS-B
     PERFORM VARYING WS-Z FROM WS-ZLO BY 1 UNTIL WS-Z > L-Z + WS-B
         PERFORM VARYING WS-Y FROM L-Y BY 1 UNTIL WS-Y > L-Y + 1
             PERFORM VARYING WS-X FROM WS-XLO BY 1 UNTIL WS-X > L-X + WS-A
                 COMPUTE WS-D = (L-X - WS-X) * (L-X - WS-X) + (L-Z - WS-Z) * (L-Z - WS-Z)
                 CALL "WGR-NEXT" USING L-STATE WS-BITS24 WS-KU
                 CALL "WGR-NEXT" USING L-STATE WS-BITS24 WS-KV
*>               t = u * 10f - v * 6f, each operation rounded to float32 (the products of a 24 bit integer by 10 and 6 and the difference are exact in a double)
                 COMPUTE WS-DL = WS-KU * 10
                 COMPUTE WS-TL = WS-DL / WS-SCALE
                 MOVE WS-TL TO WS-F1
                 COMPUTE WS-DL = WS-KV * 6
                 COMPUTE WS-TL = WS-DL / WS-SCALE
                 MOVE WS-TL TO WS-F2
                 COMPUTE WS-TL = WS-F1 - WS-F2
                 MOVE WS-TL TO WS-FT
                 MOVE 0 TO WS-TRY
                 IF WS-D <= WS-FT
                     MOVE 1 TO WS-TRY
                 ELSE
                     CALL "WGR-NEXT" USING L-STATE WS-BITS24 WS-KW
*>                   (double) k / 2^24 < 0.031  <=>  k <= 520093
                     IF WS-KW <= 520093
                         MOVE 1 TO WS-TRY
                     END-IF
                 END-IF
                 IF WS-TRY = 1
                     CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
                     CALL "FL-CLASS" USING WS-STATE WS-CLASS
                     IF WS-CLASS = 1
                         COMPUTE WS-NEW = WS-Y - 1
                         CALL "FL-GET-STATE" USING WS-X WS-NEW WS-Z WS-STATE
                         CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
                         MOVE 0 TO WS-PLACE
                         IF WS-BLOCK > 0 AND WS-BLOCK = WA-I(WS-ROW, 1)
                             CALL "F351-NEXT-BOOLEAN" USING L-STATE WS-PLACE
                         ELSE
                             IF WS-BLOCK > 0
                                 MOVE CB-OPAQUE(WS-BLOCK) TO WS-PLACE
                             END-IF
                         END-IF
                         IF WS-PLACE = 1
                             CALL "FR-PROV-STATE" USING L-STATE WA-PV(WS-ROW, 1) WS-X WS-Y WS-Z WS-NEW WS-OK
                             IF WS-OK = 1
                                 CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-NEW WS-FLAGS WS-WRITTEN
                             END-IF
                         END-IF
                     END-IF
     
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 1 TO L-RESULT
     GOBACK.
 END PROGRAM FR-PILE.
