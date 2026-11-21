*> The bonus chest (docs/protocol/35-worldgen-features-5-water-and-surface.md section 18; registry id 5, bonus_chest): FD-BONUS-NODE takes a row of FD-WA (WA-I(1) the default state of chest,
*> WA-I(2) of torch; FD-BAD when the table lacks one), FR-BONUS places it: the x values of the chunk of the origin and then its z values are shuffled (Util.shuffle of ints, 15 draws each),
*> and over x (outer) and z (inner) the first column whose MOTION_BLOCKING_NO_LEAVES cell h is air or has an empty collision shape takes a chest at h (flag 2), a loot request of
*> chests/spawn_bonus_chest with the seed nextLong() (the worldgen block entity channel, kind 1) and a torch on each horizontal neighbour (north, east, south, west) whose block below is a
*> full block. False when no column qualifies. Deviations: an empty collision shape is approximated by a block that is not solid (CB-SOLID 0; air and fluids included), a torch survives on an
*> opaque block below (CB-OPAQUE, as the sturdy-face approximations of the other features), and nothing calls it: the world options of this core have no bonus chest choice, so a world
*> creation hook would call FR-PLACE-FT with the spawn position (the placed feature list has no entry in any biome).
*>
*> Entry points: FD-BONUS-NODE USING doc, node, row out; FR-BONUS USING state, feature, x, y, z, result out.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-BONUS-NODE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY CBLOCKS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-NAME                PIC X(48).
 01 WS-BLOCK               BINARY-LONG.
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
     MOVE "minecraft:chest" TO WS-NAME
     CALL "FD-BLOCK-INDEX" USING WS-NAME WS-BLOCK
     IF WS-BLOCK = 0
         MOVE 1 TO FD-BAD
     ELSE
         MOVE CB-DEFAULT-STATE(WS-BLOCK) TO WA-I(WS-ROW, 1)
     END-IF
     MOVE "minecraft:torch" TO WS-NAME
     CALL "FD-BLOCK-INDEX" USING WS-NAME WS-BLOCK
     IF WS-BLOCK = 0
         MOVE 1 TO FD-BAD
     ELSE
         MOVE CB-DEFAULT-STATE(WS-BLOCK) TO WA-I(WS-ROW, 2)
     END-IF
     GOBACK.
 END PROGRAM FD-BONUS-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-BONUS.
*> USING state, feature, x, y, z, result out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY CBLOCKS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-XS.
    05 WS-XV               BINARY-LONG OCCURS 16 TIMES.
 01 WS-ZS.
    05 WS-ZV               BINARY-LONG OCCURS 16 TIMES.
 01 WS-MINX                BINARY-LONG.
 01 WS-MINZ                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-SWAP                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-TX                  BINARY-LONG.
 01 WS-TZ                  BINARY-LONG.
 01 WS-YB                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-FREE                BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-ORD                 BINARY-LONG VALUE 5.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-WRITTEN             BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-LOOT                PIC X(48) VALUE "minecraft:chests/spawn_bonus_chest".
 01 WS-TEXT                PIC X(32) VALUE SPACES.
*> N, E, S, W as dx / dz
 01 WS-DXS.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE -1.
 01 WS-DX-TAB REDEFINES WS-DXS.
    05 WS-DX               BINARY-LONG OCCURS 4 TIMES.
 01 WS-DZS.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
 01 WS-DZ-TAB REDEFINES WS-DZS.
    05 WS-DZ               BINARY-LONG OCCURS 4 TIMES.
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
     COMPUTE WS-MINX = FUNCTION INTEGER(L-X / 16) * 16
     COMPUTE WS-MINZ = FUNCTION INTEGER(L-Z / 16) * 16
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         COMPUTE WS-XV(WS-I) = WS-MINX + WS-I - 1
         COMPUTE WS-ZV(WS-I) = WS-MINZ + WS-I - 1
     END-PERFORM
*>   Util.shuffle: for i = 16 down to 2, j = nextInt(i), swap(i - 1, j), the x values first
     PERFORM VARYING WS-N FROM 16 BY -1 UNTIL WS-N < 2
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-N WS-J
         MOVE WS-XV(WS-N) TO WS-SWAP
         MOVE WS-XV(WS-J + 1) TO WS-XV(WS-N)
         MOVE WS-SWAP TO WS-XV(WS-J + 1)
     END-PERFORM
     PERFORM VARYING WS-N FROM 16 BY -1 UNTIL WS-N < 2
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-N WS-J
         MOVE WS-ZV(WS-N) TO WS-SWAP
         MOVE WS-ZV(WS-J + 1) TO WS-ZV(WS-N)
         MOVE WS-SWAP TO WS-ZV(WS-J + 1)
     END-PERFORM
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16 OR WS-DONE = 1
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 16 OR WS-DONE = 1
             MOVE WS-XV(WS-I) TO WS-X
             MOVE WS-ZV(WS-J) TO WS-Z
             CALL "FL-HEIGHT-OF" USING WS-ORD WS-X WS-Z WS-H
             CALL "FL-GET-STATE" USING WS-X WS-H WS-Z WS-STATE
             CALL "FL-CLASS" USING WS-STATE WS-CLASS
             CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
             MOVE 0 TO WS-FREE
             IF WS-CLASS = 1
                 MOVE 1 TO WS-FREE
             ELSE
                 IF WS-BLOCK > 0
                     IF CB-SOLID(WS-BLOCK) = 0
                         MOVE 1 TO WS-FREE
                     END-IF
                 END-IF
             END-IF
             IF WS-FREE = 1
                 MOVE 1 TO WS-DONE
                 CALL "FL-SET-STATE" USING WS-X WS-H WS-Z WA-I(WS-ROW, 1) WS-FLAGS WS-WRITTEN
                 CALL "F351-NEXT-LONG" USING L-STATE WS-LONG
                 CALL "GBE-ADD" USING WS-X WS-H WS-Z WS-KIND WS-LOOT WS-LONG WS-TEXT
                 COMPUTE WS-YB = WS-H - 1
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                     COMPUTE WS-TX = WS-X + WS-DX(WS-K)
                     COMPUTE WS-TZ = WS-Z + WS-DZ(WS-K)
                     CALL "FL-GET-STATE" USING WS-TX WS-YB WS-TZ WS-STATE
                     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
                     IF WS-BLOCK > 0
                         IF CB-OPAQUE(WS-BLOCK) = 1
                             CALL "FL-SET-STATE" USING WS-TX WS-H WS-TZ WA-I(WS-ROW, 2) WS-FLAGS WS-WRITTEN
                         END-IF
                     END-IF
                 END-PERFORM
             END-IF
         END-PERFORM
     END-PERFORM
     IF WS-DONE = 1
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM FR-BONUS.
