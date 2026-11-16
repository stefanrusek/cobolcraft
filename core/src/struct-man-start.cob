*> The woodland mansion as a structure (docs/protocol/36-structures-7-woodland-mansion.md sections 3, 7 and 8): the start (rotation, height test of the 5 by 5 box), the template pieces made from the
*> layout of struct-man-place.cob, the data markers of its pieces (chests with the woodland_mansion loot, the mob markers) and the foundation under the lowest layer.
*> Entry points: MAN-FIND-POINT USING seed, chunk x, chunk z, x out, y out, z out, valid out (builds the pieces in the builder, template kind 5); MAN-PIECES (the layout to pieces);
*> MAN-MARKER USING row, metadata (PIC X(96)), x, y, z (7.1); MAN-AFTER (afterPlace, 8: once per placement pass after the pieces).
*> Deviations: the mobs of the markers (evoker, vindicator, allays) are not made (no entity channel in the generation window): the marker is turned to air as the doc does after the mobs; the
*> start-biome pre-test (couldValidBiomeExistInTerrainColumn) is the stub's biome test of the caller; template pieces keep the pivot (0, 0, 0).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MAN-PIECES.
*> The pieces of the layout MN-ENTRY, in order: each entry's template woodland_mansion/<name> with the ignore_structure_block processor list (7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 COPY STRUCTMAN.
 01 WS-PROC-KEY            PIC X(80) VALUE "cobolcraft:inline/ignore_structure_block".
 01 WS-PROC                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ID                  PIC X(96).
 01 WS-ROW                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 5.
 01 WS-PX                  BINARY-LONG VALUE 0.
 01 WS-PY                  BINARY-LONG VALUE 0.
 01 WS-PZ                  BINARY-LONG VALUE 0.
 01 WS-LIQUID              BINARY-LONG VALUE 0.
 01 WS-AUX                 BINARY-LONG VALUE 0.
 01 WS-PIECE               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "STRUCT-PROC-LOAD" USING WS-PROC-KEY WS-PROC
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > MN-COUNT
         MOVE SPACES TO WS-ID
         STRING "minecraft:woodland_mansion/" FUNCTION TRIM(ME-NAME(WS-I)) DELIMITED BY SIZE INTO WS-ID
         CALL "STRUCT-TPL-LOAD" USING SD-DIR WS-ID WS-ROW
         CALL "STRUCT-TPL-PIECE-ADD" USING WS-KIND WS-ROW ME-X(WS-I) ME-Y(WS-I) ME-Z(WS-I) ME-ROT(WS-I) ME-MIR(WS-I)
             WS-PX WS-PY WS-PZ WS-PROC WS-LIQUID WS-AUX WS-PIECE
     END-PERFORM
     GOBACK.
 END PROGRAM MAN-PIECES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MAN-FIND-POINT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-BOUND               BINARY-LONG VALUE 4.
 01 WS-ROT                 BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 0.
 01 WS-X2                  BINARY-LONG.
 01 WS-Z2                  BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING L-SEED L-CX L-CZ L-X L-Y L-Z L-VALID.
     CALL "SPB-RESET"
     COMPUTE WS-USEED = FUNCTION MOD(L-SEED + WS-M64, WS-M64)
     CALL "JRAND-LARGE-FEATURE-SEED" USING SP-RNG WS-USEED L-CX L-CZ
     COMPUTE L-X = L-CX * 16 + 7
     COMPUTE L-Z = L-CZ * 16 + 7
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-ROT
*>   getLowestYIn5by5Box: the four corners of the box turned by the rotation
     MOVE 5 TO WS-DX WS-DZ
     EVALUATE WS-ROT
         WHEN 1
             MOVE -5 TO WS-DX
         WHEN 2
             MOVE -5 TO WS-DX WS-DZ
         WHEN 3
             MOVE -5 TO WS-DZ
         WHEN OTHER
             CONTINUE
     END-EVALUATE
     CALL "STRUCT-BASE-HEIGHT" USING L-X L-Z WS-KIND WS-H
     COMPUTE WS-MIN = WS-H - 1
     COMPUTE WS-Z2 = L-Z + WS-DZ
     CALL "STRUCT-BASE-HEIGHT" USING L-X WS-Z2 WS-KIND WS-H
     IF WS-H - 1 < WS-MIN
         COMPUTE WS-MIN = WS-H - 1
     END-IF
     COMPUTE WS-X2 = L-X + WS-DX
     CALL "STRUCT-BASE-HEIGHT" USING WS-X2 L-Z WS-KIND WS-H
     IF WS-H - 1 < WS-MIN
         COMPUTE WS-MIN = WS-H - 1
     END-IF
     CALL "STRUCT-BASE-HEIGHT" USING WS-X2 WS-Z2 WS-KIND WS-H
     IF WS-H - 1 < WS-MIN
         COMPUTE WS-MIN = WS-H - 1
     END-IF
     MOVE WS-MIN TO L-Y
     MOVE 1 TO L-VALID
     IF WS-MIN < 60
         MOVE 0 TO L-VALID
         GOBACK
     END-IF
     CALL "MNG-BUILD"
     CALL "MNP-LAYOUT" USING WS-ROT L-X L-Y L-Z
     CALL "MAN-PIECES"
     GOBACK.
 END PROGRAM MAN-FIND-POINT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MAN-MARKER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY CBLOCKS.
 01 WS-CHEST-KEY           PIC X(48) VALUE "minecraft:chest".
 01 WS-STATE               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-PROP                PIC X(24) VALUE "facing".
 01 WS-MODE                BINARY-LONG VALUE 2.
 01 WS-DIR                 BINARY-LONG.
 01 WS-FACING              PIC X(32).
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-OK                  BINARY-LONG.
 01 WS-LOOT                PIC X(48) VALUE "minecraft:chests/woodland_mansion".
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-NOTHING             PIC X(32) VALUE SPACES.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-SET                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-META                 PIC X(96).
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-META L-X L-Y L-Z.
     EVALUATE TRUE
         WHEN L-META(1:5) = "Chest"
             CALL "GEN-BLOCK-STATE" USING WS-CHEST-KEY WS-STATE
             MOVE 9 TO WS-DIR
             EVALUATE L-META
                 WHEN "ChestNorth"
                     MOVE 0 TO WS-DIR
                 WHEN "ChestEast"
                     MOVE 1 TO WS-DIR
                 WHEN "ChestSouth"
                     MOVE 2 TO WS-DIR
                 WHEN "ChestWest"
                     MOVE 3 TO WS-DIR
                 WHEN OTHER
                     CONTINUE
             END-EVALUATE
             IF WS-DIR NOT = 9
                 COMPUTE WS-DIR = FUNCTION MOD(WS-DIR + SP-T-ROT(L-ROW), 4)
                 EVALUATE WS-DIR
                     WHEN 0
                         MOVE "north" TO WS-FACING
                     WHEN 1
                         MOVE "east" TO WS-FACING
                     WHEN 2
                         MOVE "south" TO WS-FACING
                     WHEN OTHER
                         MOVE "west" TO WS-FACING
                 END-EVALUATE
                 CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-PROP WS-FACING WS-NEW
                 MOVE WS-NEW TO WS-STATE
             END-IF
*>           createChest: nothing when the block there already is a chest
             CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-OLD
             MOVE CB-S-BLOCK(WS-OLD + 1) TO WS-BLOCK
             IF CB-KEY(WS-BLOCK + 1) NOT = "chest"
                 CALL "FL-SET-STATE" USING L-X L-Y L-Z WS-STATE WS-FLAGS WS-OK
                 CALL "MSP-RNG-LONG" USING WS-SEED
                 CALL "GBE-ADD" USING L-X L-Y L-Z WS-KIND WS-LOOT WS-SEED WS-NOTHING
             END-IF
         WHEN L-META = "Mage" OR L-META = "Warrior" OR L-META = "Group of Allays"
*>           the mob is not made; the marker position becomes air
             CALL "FL-SET-STATE" USING L-X L-Y L-Z WS-AIR WS-FLAGS WS-OK
         WHEN OTHER
             CONTINUE
     END-EVALUATE
     GOBACK.
 END PROGRAM MAN-MARKER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MAN-AFTER.
*> afterPlace (8): for every column of the write box whose block at the lowest y of the structure is not air and lies in a piece box, the air and liquid below becomes cobblestone down to the first other block.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-ANY                 BINARY-LONG.
 01 WS-STONE-KEY           PIC X(48) VALUE "minecraft:cobblestone".
 01 WS-COBBLE              BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-OK                  BINARY-LONG.
 01 WS-MIN-Y               BINARY-LONG VALUE -64.
 01 WS-STOP                BINARY-LONG.
 PROCEDURE DIVISION.
     IF SP-COUNT = 0
         GOBACK
     END-IF
     IF SP-T-KIND(1) NOT = 5
         GOBACK
     END-IF
     CALL "SPB-UNION-ALL" USING WS-BOX
     MOVE B-Y0 TO WS-Y0
     CALL "GEN-BLOCK-STATE" USING WS-STONE-KEY WS-COBBLE
     PERFORM VARYING WS-X FROM SW-X0 BY 1 UNTIL WS-X > SW-X1
         PERFORM VARYING WS-Z FROM SW-Z0 BY 1 UNTIL WS-Z > SW-Z1
             CALL "FL-GET-STATE" USING WS-X WS-Y0 WS-Z WS-STATE
             CALL "FL-CLASS" USING WS-STATE WS-CLASS
             MOVE 0 TO WS-ANY
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SP-COUNT OR WS-ANY = 1
                 CALL "SPB-BOX-INSIDE" USING SP-BOX(WS-I) WS-X WS-Y0 WS-Z WS-IN
                 MOVE WS-IN TO WS-ANY
             END-PERFORM
             IF WS-CLASS NOT = 1 AND WS-ANY = 1
                 COMPUTE WS-Y = WS-Y0 - 1
                 MOVE 0 TO WS-STOP
                 PERFORM UNTIL WS-Y <= WS-MIN-Y OR WS-STOP = 1
                     CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
                     CALL "FL-CLASS" USING WS-STATE WS-CLASS
                     IF WS-CLASS >= 1 AND WS-CLASS <= 3
                         CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-COBBLE WS-FLAGS WS-OK
                         SUBTRACT 1 FROM WS-Y
                     ELSE
                         MOVE 1 TO WS-STOP
                     END-IF
                 END-PERFORM
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM MAN-AFTER.
