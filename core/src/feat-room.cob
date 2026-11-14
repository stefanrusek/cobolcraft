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
 01 WS-DEFAULT             BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-RENDER              BINARY-LONG.
 01 WS-KIND-RENDER         BINARY-LONG VALUE 3.
 01 WS-KIND-BLOCK          BINARY-LONG VALUE 4.
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
*> the turns of step 3: opposite, clockwise, opposite
 01 WS-TURNS.
    05 FILLER              BINARY-LONG VALUE 2.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 2.
 01 WS-TURN-TABLE REDEFINES WS-TURNS.
    05 WS-TURN             BINARY-LONG OCCURS 3 TIMES.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-STATE.
     COMPUTE WS-BLOCK-ID = WA-I(L-ROW, 4) - 1
*>   1. the neighbours in order: a chest keeps the default state; two solid-render ones cancel each other
     MOVE -1 TO WS-CAND
     MOVE 0 TO WS-STOP WS-DEFAULT
     PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 3 OR WS-STOP = 1 OR WS-DEFAULT = 1
         COMPUTE WS-PX = L-X + WS-DX(WS-D + 1)
         COMPUTE WS-PZ = L-Z + WS-DZ(WS-D + 1)
         CALL "ROOM-PROBE" USING WS-PX L-Y WS-PZ WS-KIND-BLOCK WS-BLOCK
         IF WS-BLOCK = WA-I(L-ROW, 4)
             MOVE 1 TO WS-DEFAULT
         ELSE
             CALL "ROOM-PROBE" USING WS-PX L-Y WS-PZ WS-KIND-RENDER WS-RENDER
             IF WS-RENDER = 1 AND WS-CAND < 0
                 MOVE WS-D TO WS-CAND
             ELSE
                 IF WS-RENDER = 1
                     MOVE -1 TO WS-CAND
                     MOVE 1 TO WS-STOP
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     MOVE 0 TO WS-DIR
     IF WS-DEFAULT = 0
         IF WS-CAND >= 0
             COMPUTE WS-DIR = FUNCTION MOD(WS-CAND + 2, 4)
         ELSE
*>           3. the facing of the default (north): away from a solid block in front, then clockwise, then back
             PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 3
                 COMPUTE WS-PX = L-X + WS-DX(WS-DIR + 1)
                 COMPUTE WS-PZ = L-Z + WS-DZ(WS-DIR + 1)
                 CALL "ROOM-PROBE" USING WS-PX L-Y WS-PZ WS-KIND-RENDER WS-RENDER
                 IF WS-RENDER = 1
                     COMPUTE WS-DIR = FUNCTION MOD(WS-DIR + WS-TURN(WS-D), 4)
                 END-IF
             END-PERFORM
         END-IF
     END-IF
     CALL "BE-STATE-MAKE" USING WS-BLOCK-ID WS-DIR WS-TYPE WS-DRY L-STATE
     GOBACK.
 END PROGRAM ROOM-REORIENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-ROOM.
*> USING state (the feature's random), feature, x, y, z, result out (1 when the room was made).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY CBLOCKS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-RX                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-XMIN                BINARY-LONG.
 01 WS-XMAX                BINARY-LONG.
 01 WS-ZMIN                BINARY-LONG.
 01 WS-ZMAX                BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-EMPTY               BINARY-LONG.
 01 WS-EMPTY-UP            BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-FAIL                BINARY-LONG.
 01 WS-WALL                BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CHEST-STATE         BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-SOLIDS              BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-KIND-SOLID          BINARY-LONG VALUE 1.
 01 WS-KIND-EMPTY          BINARY-LONG VALUE 2.
 01 WS-KIND-BLOCK          BINARY-LONG VALUE 4.
 01 WS-BOUND               BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-LOOT                PIC X(48) VALUE "minecraft:chests/simple_dungeon".
 01 WS-NO-LOOT             PIC X(48) VALUE SPACES.
 01 WS-NO-TEXT             PIC X(32) VALUE SPACES.
 01 WS-KIND-CHEST          BINARY-LONG VALUE 1.
 01 WS-KIND-SPAWNER        BINARY-LONG VALUE 2.
 01 WS-ZERO-SEED           BINARY-DOUBLE VALUE 0.
 01 WS-MOB                 PIC X(32).
 01 WS-MOBS.
    05 FILLER              PIC X(32) VALUE "minecraft:skeleton".
    05 FILLER              PIC X(32) VALUE "minecraft:zombie".
    05 FILLER              PIC X(32) VALUE "minecraft:zombie".
    05 FILLER              PIC X(32) VALUE "minecraft:spider".
 01 WS-MOB-TABLE REDEFINES WS-MOBS.
    05 WS-MOB-NAME         PIC X(32) OCCURS 4 TIMES.
 01 WS-DXS.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE -1.
 01 WS-DX-TABLE REDEFINES WS-DXS.
    05 WS-NDX              BINARY-LONG OCCURS 4 TIMES.
 01 WS-DZS.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
 01 WS-DZ-TABLE REDEFINES WS-DZS.
    05 WS-NDZ              BINARY-LONG OCCURS 4 TIMES.
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
*>   1. the size, x drawn first
     MOVE 2 TO WS-BOUND
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-RX
     ADD 2 TO WS-RX
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-RZ
     ADD 2 TO WS-RZ
     COMPUTE WS-XMIN = -WS-RX - 1
     COMPUTE WS-XMAX = WS-RX + 1
     COMPUTE WS-ZMIN = -WS-RZ - 1
     COMPUTE WS-ZMAX = WS-RZ + 1
*>   2. the check pass: solid floor and ceiling, one to five open cells along the walls at y 0
     MOVE 0 TO WS-COUNT WS-FAIL
     PERFORM VARYING WS-DX FROM WS-XMIN BY 1 UNTIL WS-DX > WS-XMAX OR WS-FAIL = 1
         PERFORM VARYING WS-DY FROM -1 BY 1 UNTIL WS-DY > 4 OR WS-FAIL = 1
             PERFORM VARYING WS-DZ FROM WS-ZMIN BY 1 UNTIL WS-DZ > WS-ZMAX OR WS-FAIL = 1
                 COMPUTE WS-PX = L-X + WS-DX
                 COMPUTE WS-PY = L-Y + WS-DY
                 COMPUTE WS-PZ = L-Z + WS-DZ
                 CALL "ROOM-PROBE" USING WS-PX WS-PY WS-PZ WS-KIND-SOLID WS-SOLID
                 IF (WS-DY = -1 OR WS-DY = 4) AND WS-SOLID = 0
                     MOVE 1 TO WS-FAIL
                 END-IF
                 IF WS-FAIL = 0 AND WS-DY = 0
                     IF WS-DX = WS-XMIN OR WS-DX = WS-XMAX OR WS-DZ = WS-ZMIN OR WS-DZ = WS-ZMAX
                         CALL "ROOM-PROBE" USING WS-PX WS-PY WS-PZ WS-KIND-EMPTY WS-EMPTY
                         COMPUTE WS-QX = WS-PY + 1
                         CALL "ROOM-PROBE" USING WS-PX WS-QX WS-PZ WS-KIND-EMPTY WS-EMPTY-UP
                         IF WS-EMPTY = 1 AND WS-EMPTY-UP = 1
                             ADD 1 TO WS-COUNT
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     IF WS-FAIL = 1 OR WS-COUNT < 1 OR WS-COUNT > 5
         GOBACK
     END-IF
*>   3. the carve pass: walls and floor become cobblestone (mossy on the floor three times in four), the inside cave air
     PERFORM VARYING WS-DX FROM WS-XMIN BY 1 UNTIL WS-DX > WS-XMAX
         PERFORM VARYING WS-DY FROM 3 BY -1 UNTIL WS-DY < -1
             PERFORM VARYING WS-DZ FROM WS-ZMIN BY 1 UNTIL WS-DZ > WS-ZMAX
                 COMPUTE WS-PX = L-X + WS-DX
                 COMPUTE WS-PY = L-Y + WS-DY
                 COMPUTE WS-PZ = L-Z + WS-DZ
                 CALL "ROOM-PROBE" USING WS-PX WS-PY WS-PZ WS-KIND-BLOCK WS-BLOCK
                 MOVE 0 TO WS-WALL
                 IF WS-DX = WS-XMIN OR WS-DX = WS-XMAX OR WS-DY = -1 OR WS-DZ = WS-ZMIN OR WS-DZ = WS-ZMAX
                     MOVE 1 TO WS-WALL
                 END-IF
                 IF WS-WALL = 1
                     COMPUTE WS-QX = WS-PY - 1
                     CALL "ROOM-PROBE" USING WS-PX WS-QX WS-PZ WS-KIND-SOLID WS-BELOW
                     IF WS-PY >= FL-MIN-Y AND WS-BELOW = 0
                         MOVE CB-DEFAULT-STATE(WA-I(WS-ROW, 3)) TO WS-STATE
                         CALL "FL-SET-STATE" USING WS-PX WS-PY WS-PZ WS-STATE WS-FLAGS WS-OK
                     ELSE
                         IF CB-SOLID(WS-BLOCK) = 1 AND WS-BLOCK NOT = WA-I(WS-ROW, 4)
                             MOVE CB-DEFAULT-STATE(WA-I(WS-ROW, 1)) TO WS-STATE
                             IF WS-DY = -1
                                 MOVE 4 TO WS-BOUND
                                 CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-DRAW
                                 IF WS-DRAW NOT = 0
                                     MOVE CB-DEFAULT-STATE(WA-I(WS-ROW, 2)) TO WS-STATE
                                 END-IF
                             END-IF
                             CALL "ROOM-SAFE-SET" USING WS-ROW WS-PX WS-PY WS-PZ WS-STATE
                         END-IF
                     END-IF
                 ELSE
                     IF WS-BLOCK NOT = WA-I(WS-ROW, 4) AND WS-BLOCK NOT = WA-I(WS-ROW, 5)
                         MOVE CB-DEFAULT-STATE(WA-I(WS-ROW, 3)) TO WS-STATE
                         CALL "ROOM-SAFE-SET" USING WS-ROW WS-PX WS-PY WS-PZ WS-STATE
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
*>   4. two chests, up to three attempts each: an empty cell with exactly one solid horizontal neighbour
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 2
         MOVE 0 TO WS-DONE
         PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 3 OR WS-DONE = 1
             COMPUTE WS-BOUND = 2 * WS-RX + 1
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-DRAW
             COMPUTE WS-PX = L-X + WS-DRAW - WS-RX
             COMPUTE WS-BOUND = 2 * WS-RZ + 1
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-DRAW
             COMPUTE WS-PZ = L-Z + WS-DRAW - WS-RZ
             MOVE L-Y TO WS-PY
             CALL "ROOM-PROBE" USING WS-PX WS-PY WS-PZ WS-KIND-EMPTY WS-EMPTY
             IF WS-EMPTY = 1
                 MOVE 0 TO WS-SOLIDS
                 PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 4
                     COMPUTE WS-QX = WS-PX + WS-NDX(WS-D)
                     COMPUTE WS-QZ = WS-PZ + WS-NDZ(WS-D)
                     CALL "ROOM-PROBE" USING WS-QX WS-PY WS-QZ WS-KIND-SOLID WS-SOLID
                     ADD WS-SOLID TO WS-SOLIDS
                 END-PERFORM
                 IF WS-SOLIDS = 1
                     CALL "ROOM-REORIENT" USING WS-ROW WS-PX WS-PY WS-PZ WS-CHEST-STATE
                     CALL "ROOM-SAFE-SET" USING WS-ROW WS-PX WS-PY WS-PZ WS-CHEST-STATE
                     CALL "F351-NEXT-LONG" USING L-STATE WS-SEED
                     CALL "ROOM-IN-CHUNK" USING WS-PX WS-PZ WS-OK
                     IF WS-OK = 1
                         CALL "GBE-ADD" USING WS-PX WS-PY WS-PZ WS-KIND-CHEST WS-LOOT WS-SEED WS-NO-TEXT
                     END-IF
                     MOVE 1 TO WS-DONE
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
*>   5. the spawner at the origin, its mob one of skeleton, zombie, zombie, spider
     MOVE CB-DEFAULT-STATE(WA-I(WS-ROW, 5)) TO WS-STATE
     CALL "ROOM-SAFE-SET" USING WS-ROW L-X L-Y L-Z WS-STATE
     CALL "ROOM-PROBE" USING L-X L-Y L-Z WS-KIND-BLOCK WS-BLOCK
     IF WS-BLOCK = WA-I(WS-ROW, 5)
         MOVE 4 TO WS-BOUND
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-DRAW
         MOVE WS-MOB-NAME(WS-DRAW + 1) TO WS-MOB
         CALL "ROOM-IN-CHUNK" USING L-X L-Z WS-OK
         IF WS-OK = 1
             CALL "GBE-ADD" USING L-X L-Y L-Z WS-KIND-SPAWNER WS-NO-LOOT WS-ZERO-SEED WS-MOB
         END-IF
     END-IF
     MOVE 1 TO L-RESULT
     GOBACK.
 END PROGRAM FR-ROOM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ROOM-IN-CHUNK.
*> USING x, z, flag out: 1 when the column is the one the level (the chunk being generated) holds.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATLEVEL.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Z L-FLAG.
     COMPUTE WS-X0 = FL-CX * 16
     COMPUTE WS-Z0 = FL-CZ * 16
     MOVE 0 TO L-FLAG
     IF L-X >= WS-X0 AND L-X < WS-X0 + 16 AND L-Z >= WS-Z0 AND L-Z < WS-Z0 + 16
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM ROOM-IN-CHUNK.
