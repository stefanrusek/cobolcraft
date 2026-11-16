*> The fossil feature (docs/protocol/35-worldgen-features-6-underground.md section 10.2 and 10.4; registry id 18, fossil): FD-FOSSIL-NODE reads fossil_structures and overlay_structures (equal, non-empty lists of
*> template ids), fossil_processors and overlay_processors (a processor list id or an inline {"processors": [...]}) and max_empty_corners_allowed (0 to 7) into a row of FD-WA (WA-I(1) the number of
*> templates, WA-I(2) the fossil processor list, WA-I(3) the overlay processor list, WA-I(4) the empty corner limit, WA-START(1) and WA-N(1) the slice of the pool that holds, per template, the cache
*> row of the fossil and of its overlay; FD-BAD when a file is absent or unsupported, the lists differ in length or a list does not compile).
*> FR-FOSSIL: rotation = nextInt(4), index = nextInt(count); corner = origin + (-size.x / 2, 0, -size.z / 2) over the rotated size; y = the least OCEAN_FLOOR_WG height over the footprint; one draw
*> nextInt(10) gives base = max(y - 15 - draw, minY + 10); zero = corner at base + getZeroPositionWithTransform; the box is the transformed template box moved by zero; more empty corners (air, water
*> or lava at the 8 corners) than the limit return false; then the fossil and the overlay are placed at zero with the rotation, the 3 x 3 chunk window as bounding box and flags 260 (one palette draw each,
*> as in FR-TEMPLATE). Deviations: the level is the chunk's own column (feat-level.cob), so the footprint columns outside it are not part of the height minimum and a corner outside it is not counted
*> as empty; the processors get no shared random (block_rot draws from a source seeded by the position).
*>
*> Entry points: FD-FOSSIL-NODE USING doc, node, row out; FR-FOSSIL USING state, feature, x, y, z, result out.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-FOSSIL-NODE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FDKEYS.
 COPY STRUCTDATA.
 COPY STRUCTTPL.
 01 WS-ROW                 BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-O                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-TEXT                PIC X(120).
 01 WS-ID                  PIC X(96).
 01 WS-KEY                 PIC X(80).
 01 WS-ROOT                PIC X(1100).
 01 WS-TROW                BINARY-LONG.
 01 WS-LIST                BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-PHASE               BINARY-LONG.
 01 WS-K-FOSSILS           PIC X(40) VALUE "fossil_structures".
 01 WS-K-OVERLAYS          PIC X(40) VALUE "overlay_structures".
 01 WS-K-FPROC             PIC X(40) VALUE "fossil_processors".
 01 WS-K-OPROC             PIC X(40) VALUE "overlay_processors".
 01 WS-K-MAX               PIC X(40) VALUE "max_empty_corners_allowed".
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
     IF SD-DIR = SPACES
         MOVE FD-DIR TO WS-ROOT
     ELSE
         MOVE SD-DIR TO WS-ROOT
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-FOSSILS WS-F
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-OVERLAYS WS-O
     IF WS-F = 0 OR WS-O = 0 OR JN-TYPE(WS-F) NOT = JT-ARRAY OR JN-TYPE(WS-O) NOT = JT-ARRAY
        OR JN-COUNT(WS-F) < 1 OR JN-COUNT(WS-F) NOT = JN-COUNT(WS-O) OR JN-COUNT(WS-F) > 16
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     MOVE JN-COUNT(WS-F) TO WS-N
     MOVE WS-N TO WA-I(WS-ROW, 1)
     COMPUTE WA-START(WS-ROW, 1) = FD-POOL-COUNT + 1
     COMPUTE WA-N(WS-ROW, 1) = WS-N * 2
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-N
         PERFORM VARYING WS-PHASE FROM 1 BY 1 UNTIL WS-PHASE > 2
             IF WS-PHASE = 1
                 CALL "JSON-ELEMENT" USING JSON-DOC WS-F WS-I WS-E
             ELSE
                 CALL "JSON-ELEMENT" USING JSON-DOC WS-O WS-I WS-E
             END-IF
             CALL "FD-J-STRING-OF" USING JSON-DOC WS-E WS-TEXT
             MOVE WS-TEXT TO WS-ID
             MOVE 0 TO WS-TROW
             IF WS-ID NOT = SPACES
                 CALL "STRUCT-TPL-LOAD" USING WS-ROOT WS-ID WS-TROW
             END-IF
             IF WS-TROW < 1
                 MOVE 1 TO FD-BAD
                 MOVE 0 TO WS-TROW
             ELSE
                 IF TP-STATUS(WS-TROW) NOT = 1
                     MOVE 1 TO FD-BAD
                 END-IF
             END-IF
             CALL "FD-POOL-ADD" USING WS-TROW WS-IDX
         END-PERFORM
     END-PERFORM
*>   the two processor lists: an id or an inline list
     PERFORM VARYING WS-PHASE FROM 1 BY 1 UNTIL WS-PHASE > 2
         IF WS-PHASE = 1
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-FPROC WS-E
         ELSE
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-OPROC WS-E
         END-IF
         MOVE 0 TO WS-LIST
         IF WS-E = 0
             MOVE 1 TO FD-BAD
         ELSE
             IF JN-TYPE(WS-E) = JT-STRING
                 CALL "FD-J-STRING-OF" USING JSON-DOC WS-E WS-TEXT
                 MOVE WS-TEXT TO WS-KEY
                 CALL "STRUCT-PROC-LOAD" USING WS-KEY WS-LIST
             ELSE
                 CALL "STRUCT-PROC-INLINE" USING JSON-DOC WS-E WS-LIST
             END-IF
             IF WS-LIST = 0
                 MOVE 1 TO FD-BAD
             END-IF
         END-IF
         IF WS-PHASE = 1
             MOVE WS-LIST TO WA-I(WS-ROW, 2)
         ELSE
             MOVE WS-LIST TO WA-I(WS-ROW, 3)
         END-IF
     END-PERFORM
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-MAX WS-E
     CALL "FD-J-INT" USING JSON-DOC WS-E WS-MAX WS-OK
     IF WS-OK = 0 OR WS-MAX < 0 OR WS-MAX > 7
         MOVE 1 TO FD-BAD
         MOVE 0 TO WS-MAX
     END-IF
     MOVE WS-MAX TO WA-I(WS-ROW, 4)
     GOBACK.
 END PROGRAM FD-FOSSIL-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-FOSSIL.
*> USING state, feature, x, y, z, result out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY STRUCTTPL.
 COPY STRUCTSET.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROT                 BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-FOSSIL              BINARY-LONG.
 01 WS-OVERLAY             BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-TEN                 BINARY-LONG VALUE 10.
 01 WS-SX0                 BINARY-LONG.
 01 WS-SZ0                 BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-CORNER-X            BINARY-LONG.
 01 WS-CORNER-Z            BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-MINH                BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-ZX                  BINARY-LONG.
 01 WS-ZZ                  BINARY-LONG.
 01 WS-BX0                 BINARY-LONG.
 01 WS-BX1                 BINARY-LONG.
 01 WS-BZ0                 BINARY-LONG.
 01 WS-BZ1                 BINARY-LONG.
 01 WS-BY1                 BINARY-LONG.
 01 WS-TX                  BINARY-LONG.
 01 WS-TZ                  BINARY-LONG.
 01 WS-EMPTY               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-PALETTES            BINARY-LONG.
 01 WS-HEIGHT-KIND         BINARY-LONG VALUE 2.
 01 WS-FLAGS               BINARY-LONG VALUE 260.
 01 WS-PASS                BINARY-LONG.
 01 WS-PLACED              BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-AX                  BINARY-LONG.
 01 WS-AY                  BINARY-LONG.
 01 WS-AZ                  BINARY-LONG.
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
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-FOUR WS-ROT
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WA-I(WS-ROW, 1) WS-IDX
     MOVE FD-POOL(WA-START(WS-ROW, 1) + WS-IDX * 2) TO WS-FOSSIL
     MOVE FD-POOL(WA-START(WS-ROW, 1) + WS-IDX * 2 + 1) TO WS-OVERLAY
     MOVE TP-SX(WS-FOSSIL) TO WS-SX0
     MOVE TP-SZ(WS-FOSSIL) TO WS-SZ0
     IF WS-ROT = 1 OR WS-ROT = 3
         MOVE WS-SZ0 TO WS-SX
         MOVE WS-SX0 TO WS-SZ
     ELSE
         MOVE WS-SX0 TO WS-SX
         MOVE WS-SZ0 TO WS-SZ
     END-IF
     COMPUTE WS-CORNER-X = L-X + (0 - WS-SX) / 2
     COMPUTE WS-CORNER-Z = L-Z + (0 - WS-SZ) / 2
*>   the least OCEAN_FLOOR_WG height over the footprint (columns of this chunk only)
     MOVE L-Y TO WS-MINH
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-SX
         PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J >= WS-SZ
             COMPUTE WS-LX = WS-CORNER-X + WS-I - FL-CX * 16
             COMPUTE WS-LZ = WS-CORNER-Z + WS-J - FL-CZ * 16
             IF WS-LX >= 0 AND WS-LX <= 15 AND WS-LZ >= 0 AND WS-LZ <= 15
                 COMPUTE WS-TX = WS-CORNER-X + WS-I
                 COMPUTE WS-TZ = WS-CORNER-Z + WS-J
                 CALL "FL-HEIGHT-OF" USING WS-HEIGHT-KIND WS-TX WS-TZ WS-H
                 IF WS-H < WS-MINH
                     MOVE WS-H TO WS-MINH
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-TEN WS-DRAW
     COMPUTE WS-BASE = WS-MINH - 15 - WS-DRAW
     IF WS-BASE < FL-MIN-Y + 10
         COMPUTE WS-BASE = FL-MIN-Y + 10
     END-IF
*>   getZeroPositionWithTransform and the box of the transformed template (relative to zero, then moved by it)
     EVALUATE WS-ROT
         WHEN 0
             MOVE WS-CORNER-X TO WS-ZX
             MOVE WS-CORNER-Z TO WS-ZZ
             MOVE 0 TO WS-BX0
             COMPUTE WS-BX1 = WS-SX0 - 1
             MOVE 0 TO WS-BZ0
             COMPUTE WS-BZ1 = WS-SZ0 - 1
         WHEN 1
             COMPUTE WS-ZX = WS-CORNER-X + WS-SZ0 - 1
             MOVE WS-CORNER-Z TO WS-ZZ
             COMPUTE WS-BX0 = 0 - (WS-SZ0 - 1)
             MOVE 0 TO WS-BX1
             MOVE 0 TO WS-BZ0
             COMPUTE WS-BZ1 = WS-SX0 - 1
         WHEN 2
             COMPUTE WS-ZX = WS-CORNER-X + WS-SX0 - 1
             COMPUTE WS-ZZ = WS-CORNER-Z + WS-SZ0 - 1
             COMPUTE WS-BX0 = 0 - (WS-SX0 - 1)
             MOVE 0 TO WS-BX1
             COMPUTE WS-BZ0 = 0 - (WS-SZ0 - 1)
             MOVE 0 TO WS-BZ1
         WHEN OTHER
             MOVE WS-CORNER-X TO WS-ZX
             COMPUTE WS-ZZ = WS-CORNER-Z + WS-SX0 - 1
             MOVE 0 TO WS-BX0
             COMPUTE WS-BX1 = WS-SZ0 - 1
             COMPUTE WS-BZ0 = 0 - (WS-SX0 - 1)
             MOVE 0 TO WS-BZ1
     END-EVALUATE
     COMPUTE WS-BY1 = WS-BASE + TP-SY(WS-FOSSIL) - 1
*>   the empty corners: air, water or lava
     MOVE 0 TO WS-EMPTY
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 7
         IF FUNCTION MOD(WS-I, 2) = 0
             COMPUTE WS-CX = WS-ZX + WS-BX0
         ELSE
             COMPUTE WS-CX = WS-ZX + WS-BX1
         END-IF
         COMPUTE WS-K = WS-I / 2
         IF FUNCTION MOD(WS-K, 2) = 0
             COMPUTE WS-CZ = WS-ZZ + WS-BZ0
         ELSE
             COMPUTE WS-CZ = WS-ZZ + WS-BZ1
         END-IF
         IF WS-I < 4
             MOVE WS-BASE TO WS-CY
         ELSE
             MOVE WS-BY1 TO WS-CY
         END-IF
         COMPUTE WS-LX = WS-CX - FL-CX * 16
         COMPUTE WS-LZ = WS-CZ - FL-CZ * 16
         IF WS-LX >= 0 AND WS-LX <= 15 AND WS-LZ >= 0 AND WS-LZ <= 15
             CALL "FL-GET-STATE" USING WS-CX WS-CY WS-CZ WS-STATE
             CALL "FL-CLASS" USING WS-STATE WS-CLASS
             IF WS-CLASS >= 1 AND WS-CLASS <= 3
                 ADD 1 TO WS-EMPTY
             END-IF
         END-IF
     END-PERFORM
     IF WS-EMPTY > WA-I(WS-ROW, 4)
         GOBACK
     END-IF
*>   the fossil, then its overlay at the same origin, rotation and window
     PERFORM VARYING WS-PASS FROM 1 BY 1 UNTIL WS-PASS > 2
         INITIALIZE STRUCT-SETTINGS
         MOVE WS-ROT TO PS-ROTATION
         MOVE 1 TO PS-BOX-SET
         COMPUTE PS-BOX(1) = (FL-CX - 1) * 16
         MOVE FL-MIN-Y TO PS-BOX(2)
         COMPUTE PS-BOX(3) = (FL-CZ - 1) * 16
         COMPUTE PS-BOX(4) = (FL-CX + 2) * 16 - 1
         COMPUTE PS-BOX(5) = FL-MIN-Y + FL-HEIGHT - 1
         COMPUTE PS-BOX(6) = (FL-CZ + 2) * 16 - 1
         IF WS-PASS = 1
             MOVE WS-FOSSIL TO WS-IDX
             MOVE WA-I(WS-ROW, 2) TO PS-PROCESSORS
         ELSE
             MOVE WS-OVERLAY TO WS-IDX
             MOVE WA-I(WS-ROW, 3) TO PS-PROCESSORS
         END-IF
         MOVE TP-PALETTES(WS-IDX) TO WS-PALETTES
         IF WS-PALETTES > 0
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-PALETTES WS-DRAW
         END-IF
         MOVE WS-ZX TO WS-AX
         MOVE WS-BASE TO WS-AY
         MOVE WS-ZZ TO WS-AZ
         CALL "STRUCT-PLACE" USING WS-IDX WS-ZX WS-BASE WS-ZZ WS-AX WS-AY WS-AZ STRUCT-SETTINGS WS-FLAGS WS-PLACED
     END-PERFORM
     MOVE 1 TO L-RESULT
     GOBACK.
 END PROGRAM FR-FOSSIL.
