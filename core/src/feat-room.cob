*> The monster room (docs/protocol/35-worldgen-features-6-underground.md section 9 and 9.1; registry id 27, monster_room, no fields): FD-ROOM-NODE compiles it (a row of FD-WA:
*> WA-I(1) cobblestone, (2) mossy_cobblestone, (3) cave_air, (4) chest, (5) spawner as block indices, pool 1 the tag features_cannot_replace of the safeSetBlock filter; a block the table lacks
*> makes the feature unsupported), FR-ROOM places it. The draws are the document's: rx then rz, the carve pass draws nextInt(4) at the floor cells only, each of the two chests up to three attempts
*> of x then z, the chest seed is nextLong (two draws), and the spawner picks its mob with nextInt(4) when a spawner stands at the origin. The chest and the spawner ask for their block
*> entity through the worldgen channel (GBE-ADD: the table minecraft:chests/simple_dungeon with the seed, and the entity id of skeleton, zombie, zombie, spider), which the job keeps
*> (GBE-KEEP).
*> Deviations: solid is the content set's CB-SOLID flag (no collision or air are not solid) and isSolidRender its CB-OPAQUE; the level of the stage holds the chunk's own column, so a cell outside
*> it reads as air (a room that reaches the border of the chunk fails its floor or ceiling check) and a block written outside it goes to the overflow list; the block entity request of a
*> chest or spawner outside the chunk's column is not made (the chest stays empty), because the channel applies requests to the chunk the job installs.
*>
*> Entry points: FD-ROOM-NODE USING doc, node, row out (FD-BAD set when a block is unknown); FR-ROOM USING state, feature, x, y, z, result out.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-ROOM-NODE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEY48               PIC X(48).
 01 WS-TAG                 PIC X(112) VALUE "minecraft:features_cannot_replace".
 01 WS-K                   BINARY-LONG.
 01 WS-KEYS.
    05 FILLER              PIC X(48) VALUE "minecraft:cobblestone".
    05 FILLER              PIC X(48) VALUE "minecraft:mossy_cobblestone".
    05 FILLER              PIC X(48) VALUE "minecraft:cave_air".
    05 FILLER              PIC X(48) VALUE "minecraft:chest".
    05 FILLER              PIC X(48) VALUE "minecraft:spawner".
 01 WS-KEY-TABLE REDEFINES WS-KEYS.
    05 WS-KEY              PIC X(48) OCCURS 5 TIMES.
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
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 5
         MOVE WS-KEY(WS-K) TO WS-KEY48
         CALL "FD-BLOCK-INDEX" USING WS-KEY48 WA-I(WS-ROW, WS-K)
         IF WA-I(WS-ROW, WS-K) = 0
             MOVE 1 TO FD-BAD
         END-IF
     END-PERFORM
     COMPUTE WA-START(WS-ROW, 1) = FD-POOL-COUNT + 1
     CALL "FD-TAG-BLOCKS" USING WS-TAG WA-N(WS-ROW, 1)
     GOBACK.
 END PROGRAM FD-ROOM-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ROOM-PROBE.
*> USING x, y, z, kind, answer out: kind 1 solid (CB-SOLID of the block at the cell), 2 empty (air of any kind), 3 solid render (CB-OPAQUE), 4 the block index.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-ANSWER               BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-KIND L-ANSWER.
     MOVE 0 TO L-ANSWER
     CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     EVALUATE L-KIND
         WHEN 1
             MOVE CB-SOLID(WS-BLOCK) TO L-ANSWER
         WHEN 2
             CALL "FL-CLASS" USING WS-STATE WS-CLASS
             IF WS-CLASS = 1
                 MOVE 1 TO L-ANSWER
             END-IF
         WHEN 3
             MOVE CB-OPAQUE(WS-BLOCK) TO L-ANSWER
         WHEN OTHER
             MOVE WS-BLOCK TO L-ANSWER
     END-EVALUATE
     GOBACK.
 END PROGRAM ROOM-PROBE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ROOM-SAFE-SET.
*> USING row, x, y, z, state: safeSetBlock: written (flags 2) when the block there is not in the pool of the row (features_cannot_replace).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-STATE.
     CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     CALL "FR-POOL-HAS" USING WA-START(L-ROW, 1) WA-N(L-ROW, 1) WS-BLOCK WS-IN
     IF WS-IN = 0
         CALL "FL-SET-STATE" USING L-X L-Y L-Z L-STATE WS-FLAGS WS-OK
     END-IF
     GOBACK.
 END PROGRAM ROOM-SAFE-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ROOM-REORIENT.
*> USING row, x, y, z, state out: StructurePiece.reorient of the default chest (9.1): directions 0 north, 1 east, 2 south, 3 west.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-D                   BINARY-LONG.
 01 WS-CAND                BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-RETURN-DEFAULT      BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-RENDER              BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-BLOCK-ID            BINARY-LONG.
 01 WS-TYPE                BINARY-LONG VALUE 0.
 01 WS-DRY                 BINARY-LONG VALUE 0.
 01 WS-DXS.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE -1.
 01 WS-DX-TABLE REDEFINES WS-DXS.
    05 WS-DX               BINARY-LONG OCCURS 4 TIMES.
 01 WS-DZS.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
 01 WS-DZ-TABLE REDEFINES WS-DZS.
    05 WS-DZ               BINARY-LONG OCCURS 4 TIMES.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-STATE.
     MOVE 0 TO WS-DIR
     COMPUTE WS-BLOCK-ID = WA-I(L-ROW, 4) - 1
*>   1. the neighbours: a chest keeps the default; two solid-render ones cancel each other
     MOVE -1 TO WS-CAND
     MOVE 0 TO WS-STOP WS-RETURN-DEFAULT
     PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 3 OR WS-STOP = 1 OR WS-RETURN-DEFAULT = 1
         COMPUTE WS-PX = L-X + WS-DX(WS-D + 1)
         COMPUTE WS-PZ = L-Z + WS-DZ(WS-D + 1)
         MOVE WS-STEP TO WS-STEP
         CALL "ROOM-PROBE" USING WS-PX L-Y WS-PZ WS-STEP WS-BLOCK
         MOVE 4 TO WS-STEP
         CALL "ROOM-PROBE" USING WS-PX L-Y WS-PZ WS-STEP WS-BLOCK
         IF WS-BLOCK = WA-I(L-ROW, 4)
             MOVE 1 TO WS-RETURN-DEFAULT
         ELSE
             MOVE 3 TO WS-STEP
             CALL "ROOM-PROBE" USING WS-PX L-Y WS-PZ WS-STEP WS-RENDER
             IF WS-RENDER = 1
                 IF WS-CAND < 0
                     MOVE WS-D TO WS-CAND
                 ELSE
                     MOVE -1 TO WS-CAND
                     MOVE 1 TO WS-STOP
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     EVALUATE TRUE
         WHEN WS-RETURN-DEFAULT = 1
             MOVE 0 TO WS-DIR
         WHEN WS-CAND >= 0
             COMPUTE WS-DIR = FUNCTION MOD(WS-CAND + 2, 4)
         WHEN OTHER
*>           3. the default facing north: away from a solid block in front, then clockwise, then back
             MOVE 0 TO WS-DIR
             PERFORM 3 TIMES
                 COMPUTE WS-PX = L-X + WS-DX(WS-DIR + 1)
                 COMPUTE WS-PZ = L-Z + WS-DZ(WS-DIR + 1)
                 MOVE 3 TO WS-STEP
                 CALL "ROOM-PROBE" USING WS-PX L-Y WS-PZ WS-STEP WS-RENDER
                 IF WS-RENDER = 1
                     ADD 1 TO WS-D
                 END-IF
             END-PERFORM
     END-EVALUATE
     CALL "BE-STATE-MAKE" USING WS-BLOCK-ID WS-DIR WS-TYPE WS-DRY L-STATE
     GOBACK.
 END PROGRAM ROOM-REORIENT.
