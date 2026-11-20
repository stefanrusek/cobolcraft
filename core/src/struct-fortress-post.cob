*> The nether fortress as a structure (docs/protocol/36-structures-8-nether-and-end.md sections 2 and 5 to 6): the start (FORT-FIND-POINT: setLargeFeatureSeed, the pieces of struct-fortress.cob,
*> a stub at the chunk's minimum corner at y 64 with no biome pre-check, 2.1) and the blocks of each piece (FORT-POST: the generated lists of struct-fortress-gen.cob run by SCP-RUN, the
*> bridge end filler's private random, the throne's blaze spawner, the turn pieces' chest). The random of the placement is the decoration random SP-XR.
*> Deviations: the lava well's extra fluid tick (5.7 last row) is not scheduled (worldgen has no tick queue); shape-check marks of the fences are not made; the spawner's setEntityId draws
*> nothing (31 section 7 is not built).
*> Entry points: FORT-FIND-POINT USING seed (BINARY-DOUBLE), chunk x, chunk z, x out, y out, z out, valid out; FORT-POST USING row.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORT-FIND-POINT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING L-SEED L-CX L-CZ L-X L-Y L-Z L-VALID.
     COMPUTE WS-USEED = FUNCTION MOD(L-SEED + WS-M64, WS-M64)
     CALL "FORT-START" USING WS-USEED L-CX L-CZ
     COMPUTE L-X = L-CX * 16
     MOVE 64 TO L-Y
     COMPUTE L-Z = L-CZ * 16
     MOVE 1 TO L-VALID
     GOBACK.
 END PROGRAM FORT-FIND-POINT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORT-STRIP.
*> USING row, x, y, n: fill (x, y, 0) to (x, y, n) with nether bricks.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SPEC                PIC X(60) VALUE "nether_bricks".
 01 WS-STATE               BINARY-LONG.
 01 WS-FILL                BINARY-LONG.
 01 WS-SKIP                BINARY-LONG VALUE 0.
 01 WS-Z0                  BINARY-LONG VALUE 0.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-N.
     CALL "SCP-STATE" USING L-ROW WS-SPEC WS-STATE
     MOVE WS-STATE TO WS-FILL
     MOVE L-X TO WS-X1
     MOVE L-Y TO WS-Y1
     CALL "SCP-BOX" USING L-ROW L-X L-Y WS-Z0 WS-X1 WS-Y1 L-N WS-STATE WS-FILL WS-SKIP
     GOBACK.
 END PROGRAM FORT-STRIP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORT-FILLER.
*> USING row: BridgeEndFiller.postProcess (5.3): 27 draws of a private Java random seeded by the stored Seed, each a strip of nether bricks along z from the piece's edge.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-SEEDU               BINARY-DOUBLE UNSIGNED.
 01 WS-RNG                 BINARY-DOUBLE UNSIGNED.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-0                   BINARY-LONG VALUE 0.
 01 WS-4                   BINARY-LONG VALUE 4.
 01 WS-5                   BINARY-LONG VALUE 5.
 01 WS-8                   BINARY-LONG VALUE 8.
 01 WS-3                   BINARY-LONG VALUE 3.
 01 WS-Y5                  BINARY-LONG VALUE 5.
 01 WS-Y2                  BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     COMPUTE WS-SEEDU = FUNCTION MOD(SP-F1(L-ROW) + WS-M64, WS-M64)
     CALL "JRAND-SET-SEED" USING WS-RNG WS-SEEDU
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 4
         PERFORM VARYING WS-Y FROM 3 BY 1 UNTIL WS-Y > 4
             CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG WS-8 WS-N
             CALL "FORT-STRIP" USING L-ROW WS-X WS-Y WS-N
         END-PERFORM
     END-PERFORM
     CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG WS-8 WS-N
     CALL "FORT-STRIP" USING L-ROW WS-0 WS-Y5 WS-N
     CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG WS-8 WS-N
     CALL "FORT-STRIP" USING L-ROW WS-4 WS-Y5 WS-N
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 4
         CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG WS-5 WS-N
         CALL "FORT-STRIP" USING L-ROW WS-X WS-Y2 WS-N
     END-PERFORM
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 4
         PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 1
             CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG WS-3 WS-N
             CALL "FORT-STRIP" USING L-ROW WS-X WS-Y WS-N
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM FORT-FILLER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORT-CHEST.
*> USING row, local x y z: the turn piece's chest (6.1): when pending and the cell is in the write box, the flag is cleared and the chest with the chests/nether_bridge table is made.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-NOSPEC              PIC X(60) VALUE SPACES.
 01 WS-WANT                PIC X(48) VALUE "chest".
 01 WS-LOOT                PIC X(48) VALUE "minecraft:chests/nether_bridge".
 01 WS-PLACED              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z.
     IF SP-F2(L-ROW) = 1
         CALL "SCP-CONTAINER" USING L-ROW L-X L-Y L-Z WS-NOSPEC WS-WANT WS-LOOT WS-PLACED
         IF WS-PLACED = 1
             MOVE 0 TO SP-F2(L-ROW)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FORT-CHEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORT-SPAWNER.
*> USING row: the throne's blaze spawner (5.6): once (the Mob flag) when local (3, 5, 5) is inside the write box.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY STRUCTBLK.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG VALUE 3.
 01 WS-LY                  BINARY-LONG VALUE 5.
 01 WS-LZ                  BINARY-LONG VALUE 5.
 01 WS-KIND                BINARY-LONG VALUE 2.
 01 WS-NOLOOT              PIC X(48) VALUE SPACES.
 01 WS-BLAZE               PIC X(32) VALUE "minecraft:blaze".
 01 WS-SEED                BINARY-DOUBLE VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF SP-F1(L-ROW) = 0
         CALL "SPB-WORLD" USING L-ROW WS-LX WS-LY WS-LZ WS-WX WS-WY WS-WZ
         CALL "SPB-BOX-INSIDE" USING SP-WBOX WS-WX WS-WY WS-WZ WS-IN
         IF WS-IN = 1
             MOVE 1 TO SP-F1(L-ROW)
             CALL "MSP-PLACE-RAW" USING WS-WX WS-WY WS-WZ SBK-S-SPAWNER
             CALL "GBE-ADD" USING WS-WX WS-WY WS-WZ WS-KIND WS-NOLOOT WS-SEED WS-BLAZE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FORT-SPAWNER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORT-POST.
*> USING row: postProcess of a fortress piece (5): the piece's lists in order with the chest, the spawner and the filler where the document puts them.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-X3                  BINARY-LONG VALUE 3.
 01 WS-X1                  BINARY-LONG VALUE 1.
 01 WS-Y2                  BINARY-LONG VALUE 2.
 01 WS-Z3                  BINARY-LONG VALUE 3.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     EVALUATE SP-TYPE(L-ROW)
         WHEN 4
             CALL "FORT-GEO-04" USING L-ROW
         WHEN 18
             CALL "FORT-GEO-04" USING L-ROW
         WHEN 5
             CALL "FORT-FILLER" USING L-ROW
         WHEN 6
             CALL "FORT-GEO-06" USING L-ROW
         WHEN 7
             CALL "FORT-GEO-07" USING L-ROW
         WHEN 8
             CALL "FORT-GEO-08" USING L-ROW
         WHEN 9
             CALL "FORT-GEO-09-A" USING L-ROW
         WHEN 10
             CALL "FORT-GEO-10" USING L-ROW
         WHEN 11
             CALL "FORT-GEO-11-A" USING L-ROW
             CALL "FORT-CHEST" USING L-ROW WS-X3 WS-Y2 WS-Z3
             CALL "FORT-GEO-11-B" USING L-ROW
         WHEN 12
             CALL "FORT-GEO-12" USING L-ROW
         WHEN 13
             CALL "FORT-GEO-13-A" USING L-ROW
             CALL "FORT-CHEST" USING L-ROW WS-X1 WS-Y2 WS-Z3
             CALL "FORT-GEO-13-B" USING L-ROW
         WHEN 14
             CALL "FORT-GEO-14" USING L-ROW
         WHEN 15
             CALL "FORT-GEO-15-A" USING L-ROW
             CALL "FORT-SPAWNER" USING L-ROW
             CALL "FORT-GEO-15-B" USING L-ROW
         WHEN 16
             CALL "FORT-GEO-16" USING L-ROW
         WHEN OTHER
             CALL "FORT-GEO-17" USING L-ROW
     END-EVALUATE
     GOBACK.
 END PROGRAM FORT-POST.
