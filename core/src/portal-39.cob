*> The portal rules of docs/protocol/39-portals.md (lane nether). Sections 2 (entity-side state machine), 3 (the nether portal frame), 4 and 5
*> (travel and the PortalForcer) and 6 (the transition model) are one program each; the wiring into the tick, the block hooks and the
*> player's dimension change is core/src/portals.cob. Frame cells are classified by PORTAL-CELL-KIND: 0 other, 1 frame block (obsidian,
*> the tag nether_portal_frame), 2 nether_portal, 3 air or fire (the empty cells of 3.1 are kinds 2 and 3).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-IDS-ENSURE.
*> No parameters: resolves the block ids and the nether_portal states of PORTAL-IDS from the open set by key (once per CB-EPOCH).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY PORTAL.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 PROCEDURE DIVISION.
     IF PI-EPOCH = CB-EPOCH
         GOBACK
     END-IF
     MOVE CB-EPOCH TO PI-EPOCH
     MOVE -1 TO PI-OBSIDIAN PI-PORTAL PI-FIRE PI-SOUL-FIRE PI-AIR PI-CAVE-AIR PI-VOID-AIR PI-WATER PI-LAVA
     MOVE 0 TO PI-PORTAL-X PI-PORTAL-Z
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT
         EVALUATE CB-KEY(WS-I)
             WHEN "obsidian"
                 COMPUTE PI-OBSIDIAN = WS-I - 1
             WHEN "nether_portal"
                 COMPUTE PI-PORTAL = WS-I - 1
             WHEN "fire"
                 COMPUTE PI-FIRE = WS-I - 1
             WHEN "soul_fire"
                 COMPUTE PI-SOUL-FIRE = WS-I - 1
             WHEN "air"
                 COMPUTE PI-AIR = WS-I - 1
             WHEN "cave_air"
                 COMPUTE PI-CAVE-AIR = WS-I - 1
             WHEN "void_air"
                 COMPUTE PI-VOID-AIR = WS-I - 1
             WHEN "water"
                 COMPUTE PI-WATER = WS-I - 1
             WHEN "lava"
                 COMPUTE PI-LAVA = WS-I - 1
         END-EVALUATE
     END-PERFORM
     IF PI-PORTAL >= 0
         MOVE SPACES TO WS-KEY
         MOVE "nether_portal" TO WS-KEY
         MOVE "axis=x" TO WS-PAIRS
         CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS PI-PORTAL-X
         MOVE "axis=z" TO WS-PAIRS
         CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS PI-PORTAL-Z
     END-IF
     GOBACK.
 END PROGRAM PORTAL-IDS-ENSURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-STATE-KIND.
*> USING state, kind out (BINARY-LONG): the class of a block state (see the top of this file).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY PORTAL.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-KIND.
     CALL "PORTAL-IDS-ENSURE"
     MOVE CB-S-BLOCK(L-STATE + 1) TO WS-BLOCK
     EVALUATE TRUE
         WHEN WS-BLOCK = PI-OBSIDIAN
             MOVE 1 TO L-KIND
         WHEN WS-BLOCK = PI-PORTAL
             MOVE 2 TO L-KIND
         WHEN WS-BLOCK = PI-AIR OR WS-BLOCK = PI-CAVE-AIR OR WS-BLOCK = PI-VOID-AIR
                 OR WS-BLOCK = PI-FIRE OR WS-BLOCK = PI-SOUL-FIRE
             MOVE 3 TO L-KIND
         WHEN OTHER
             MOVE 0 TO L-KIND
     END-EVALUATE
     GOBACK.
 END PROGRAM PORTAL-STATE-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-CELL-KIND.
*> USING dimension row, x, y, z, kind out: PORTAL-STATE-KIND of the block there.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-KIND.
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     CALL "PORTAL-STATE-KIND" USING WS-STATE L-KIND
     GOBACK.
 END PROGRAM PORTAL-CELL-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-EDGE-DIST.
*> USING dimension row, x, y, z of the start cell, step x, step z (BINARY-LONG, the horizontal direction), distance out: 39 section 3.2
*> getDistanceUntilEdgeAboveFrame: for i from 0 to 21 the cell start + step * i: not empty gives i when it is a frame block, else 0; an
*> empty cell needs a frame block directly below it, else 0; no end within 21 gives 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-SX                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-DIST                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-SX L-SZ L-DIST.
     MOVE 0 TO L-DIST
     COMPUTE WS-BELOW = L-Y - 1
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 21
         COMPUTE WS-X = L-X + L-SX * WS-I
         COMPUTE WS-Z = L-Z + L-SZ * WS-I
         CALL "PORTAL-CELL-KIND" USING L-DIM WS-X L-Y WS-Z WS-KIND
         IF WS-KIND < 2
             IF WS-KIND = 1
                 MOVE WS-I TO L-DIST
             END-IF
             GOBACK
         END-IF
         CALL "PORTAL-CELL-KIND" USING L-DIM WS-X WS-BELOW WS-Z WS-KIND
         IF WS-KIND NOT = 1
             GOBACK
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PORTAL-EDGE-DIST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-FIND-SHAPE.
*> USING dimension row, x, y, z, axis (0 X, 1 Z), PORTAL-SHAPE out: PortalShape.findAnyShape (39 section 3.2): the bottom-left cell by
*> walking down at most 21 cells over empty cells and left along frame-backed empty cells, the width from there to the right, the height
*> as the first row whose posts are not both frame blocks or whose interior is not empty, counting nether_portal blocks, and a top row
*> of frame blocks. No shape leaves PQ-VALID and every count 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY DIMENSIONS.
 01 WS-RX                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-DIST                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-WIDTH               BINARY-LONG.
 01 WS-HEIGHT              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-TOP-OK              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-AXIS                 BINARY-LONG.
 COPY PORTALSHAPE.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-AXIS PORTAL-SHAPE.
     INITIALIZE PORTAL-SHAPE
     MOVE L-AXIS TO PQ-AXIS
     MOVE -1 TO WS-RX
     MOVE 0 TO WS-RZ
     IF L-AXIS = 1
         MOVE 0 TO WS-RX
         MOVE 1 TO WS-RZ
     END-IF
     COMPUTE WS-LX = 0 - WS-RX
     COMPUTE WS-LZ = 0 - WS-RZ
     COMPUTE WS-LIMIT = L-Y - 21
     IF WS-LIMIT < DM-MIN-Y(L-DIM)
         MOVE DM-MIN-Y(L-DIM) TO WS-LIMIT
     END-IF
     MOVE L-Y TO WS-Y0
     MOVE 0 TO WS-DONE
     PERFORM UNTIL WS-Y0 <= WS-LIMIT OR WS-DONE = 1
         COMPUTE WS-BELOW = WS-Y0 - 1
         CALL "PORTAL-CELL-KIND" USING L-DIM L-X WS-BELOW L-Z WS-KIND
         IF WS-KIND >= 2
             MOVE WS-BELOW TO WS-Y0
         ELSE
             MOVE 1 TO WS-DONE
         END-IF
     END-PERFORM
     CALL "PORTAL-EDGE-DIST" USING L-DIM L-X WS-Y0 L-Z WS-LX WS-LZ WS-DIST
     COMPUTE WS-N = WS-DIST - 1
     IF WS-N < 0
         GOBACK
     END-IF
     COMPUTE WS-BX = L-X + WS-LX * WS-N
     COMPUTE WS-BZ = L-Z + WS-LZ * WS-N
     CALL "PORTAL-EDGE-DIST" USING L-DIM WS-BX WS-Y0 WS-BZ WS-RX WS-RZ WS-WIDTH
     IF WS-WIDTH < 2 OR WS-WIDTH > 21
         GOBACK
     END-IF
     MOVE 0 TO WS-COUNT
     MOVE 21 TO WS-HEIGHT
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 20 OR WS-DONE = 1
         COMPUTE WS-Y = WS-Y0 + WS-J
         COMPUTE WS-X = WS-BX - WS-RX
         COMPUTE WS-Z = WS-BZ - WS-RZ
         CALL "PORTAL-CELL-KIND" USING L-DIM WS-X WS-Y WS-Z WS-KIND
         IF WS-KIND NOT = 1
             MOVE WS-J TO WS-HEIGHT
             MOVE 1 TO WS-DONE
         END-IF
         IF WS-DONE = 0
             COMPUTE WS-X = WS-BX + WS-RX * WS-WIDTH
             COMPUTE WS-Z = WS-BZ + WS-RZ * WS-WIDTH
             CALL "PORTAL-CELL-KIND" USING L-DIM WS-X WS-Y WS-Z WS-KIND
             IF WS-KIND NOT = 1
                 MOVE WS-J TO WS-HEIGHT
                 MOVE 1 TO WS-DONE
             END-IF
         END-IF
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-WIDTH OR WS-DONE = 1
             COMPUTE WS-X = WS-BX + WS-RX * WS-I
             COMPUTE WS-Z = WS-BZ + WS-RZ * WS-I
             CALL "PORTAL-CELL-KIND" USING L-DIM WS-X WS-Y WS-Z WS-KIND
             IF WS-KIND < 2
                 MOVE WS-J TO WS-HEIGHT
                 MOVE 1 TO WS-DONE
             END-IF
             IF WS-DONE = 0 AND WS-KIND = 2
                 ADD 1 TO WS-COUNT
             END-IF
         END-PERFORM
     END-PERFORM
     IF WS-HEIGHT < 3 OR WS-HEIGHT > 21
         GOBACK
     END-IF
     COMPUTE WS-Y = WS-Y0 + WS-HEIGHT
     MOVE 1 TO WS-TOP-OK
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-WIDTH
         COMPUTE WS-X = WS-BX + WS-RX * WS-I
         COMPUTE WS-Z = WS-BZ + WS-RZ * WS-I
         CALL "PORTAL-CELL-KIND" USING L-DIM WS-X WS-Y WS-Z WS-KIND
         IF WS-KIND NOT = 1
             MOVE 0 TO WS-TOP-OK
         END-IF
     END-PERFORM
     IF WS-TOP-OK = 0
         GOBACK
     END-IF
     MOVE 1 TO PQ-VALID
     MOVE WS-WIDTH TO PQ-W
     MOVE WS-HEIGHT TO PQ-H
     MOVE WS-COUNT TO PQ-COUNT
     MOVE WS-BX TO PQ-BX
     MOVE WS-Y0 TO PQ-BY
     MOVE WS-BZ TO PQ-BZ
     GOBACK.
 END PROGRAM PORTAL-FIND-SHAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-EMPTY-SHAPE.
*> USING dimension row, x, y, z, PORTAL-SHAPE out: findEmptyPortalShape (39 section 3.3, over findPortalShape): the shape for axis X when
*> it is valid and holds no portal block, else the one for axis Z under the same test; PQ-VALID 0 when neither.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-AXIS                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 COPY PORTALSHAPE.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z PORTAL-SHAPE.
     PERFORM VARYING WS-AXIS FROM 0 BY 1 UNTIL WS-AXIS > 1
         CALL "PORTAL-FIND-SHAPE" USING L-DIM L-X L-Y L-Z WS-AXIS PORTAL-SHAPE
         IF PQ-VALID = 1 AND PQ-COUNT = 0
             GOBACK
         END-IF
     END-PERFORM
     INITIALIZE PORTAL-SHAPE
     GOBACK.
 END PROGRAM PORTAL-EMPTY-SHAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-CREATE-BLOCKS RECURSIVE.
*> USING dimension row, PORTAL-SHAPE: NetherPortalBlock createPortalBlocks (39 section 3.3): every interior cell becomes nether_portal of the
*> shape's axis with flags 18 (client update, no shape update).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PORTAL.
 LOCAL-STORAGE SECTION.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-FLAGS               BINARY-LONG VALUE 18.
 01 WS-RESULT              BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-RX                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 COPY PORTALSHAPE.
 PROCEDURE DIVISION USING L-DIM PORTAL-SHAPE.
     CALL "PORTAL-IDS-ENSURE"
     MOVE PI-PORTAL-X TO WS-STATE
     MOVE -1 TO WS-RX
     MOVE 0 TO WS-RZ
     IF PQ-AXIS = 1
         MOVE PI-PORTAL-Z TO WS-STATE
         MOVE 0 TO WS-RX
         MOVE 1 TO WS-RZ
     END-IF
     PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J >= PQ-H
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= PQ-W
             COMPUTE WS-X = PQ-BX + WS-RX * WS-I
             COMPUTE WS-Y = PQ-BY + WS-J
             COMPUTE WS-Z = PQ-BZ + WS-RZ * WS-I
             CALL "LEVEL-SET-BLOCK" USING L-DIM WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-BUDGET WS-RESULT
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM PORTAL-CREATE-BLOCKS.


 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-LIGHT RECURSIVE.
*> USING dimension row, x, y, z of a placed fire block, lit out (BINARY-LONG): BaseFireBlock.onPlace (39 section 3.3): in the overworld and the
*> nether, an empty valid shape around the fire (axis X, else Z) is filled with portal blocks (lit 1); in any other dimension the portal
*> engine is not consulted.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY DIMENSIONS.
 LOCAL-STORAGE SECTION.
 COPY PORTALSHAPE.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-LIT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-LIT.
     MOVE 0 TO L-LIT
     IF DM-KEY(L-DIM) NOT = "minecraft:overworld" AND DM-KEY(L-DIM) NOT = "minecraft:the_nether"
         GOBACK
     END-IF
     CALL "PORTAL-EMPTY-SHAPE" USING L-DIM L-X L-Y L-Z PORTAL-SHAPE
     IF PQ-VALID = 1
         CALL "PORTAL-CREATE-BLOCKS" USING L-DIM PORTAL-SHAPE
         MOVE 1 TO L-LIT
     END-IF
     GOBACK.
 END PROGRAM PORTAL-LIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-UPDATE-SHAPE.
*> USING dimension row, x, y, z of a portal block, its state, direction towards the changed neighbour (Direction ordinal: 0 down, 1 up, 2 north,
*> 3 south, 4 west, 5 east), the neighbour's new state, state out: NetherPortalBlock.updateShape (39 section 3.4). The block is kept when the
*> change is across its plane (a horizontal side other than its own axis), when the neighbour is a portal block, or when its shape is
*> complete; otherwise it becomes air (0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PORTAL.
 COPY PORTALSHAPE.
 01 WS-OWN                 BINARY-LONG.
 01 WS-SIDE                BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-AREA                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-NEIGHBOUR            BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-DIR L-NEIGHBOUR L-OUT.
     CALL "PORTAL-IDS-ENSURE"
     MOVE L-STATE TO L-OUT
     MOVE 0 TO WS-OWN
     IF L-STATE = PI-PORTAL-Z
         MOVE 1 TO WS-OWN
     END-IF
*>   The axis of the changed side: 0 for X (west, east), 1 for Z (north, south), 2 for Y.
     EVALUATE L-DIR
         WHEN 4 WHEN 5
             MOVE 0 TO WS-SIDE
         WHEN 2 WHEN 3
             MOVE 1 TO WS-SIDE
         WHEN OTHER
             MOVE 2 TO WS-SIDE
     END-EVALUATE
     IF WS-SIDE NOT = WS-OWN AND WS-SIDE < 2
         GOBACK
     END-IF
     CALL "PORTAL-STATE-KIND" USING L-NEIGHBOUR WS-KIND
     IF WS-KIND = 2
         GOBACK
     END-IF
     CALL "PORTAL-FIND-SHAPE" USING L-DIM L-X L-Y L-Z WS-OWN PORTAL-SHAPE
     COMPUTE WS-AREA = PQ-W * PQ-H
     IF PQ-VALID = 1 AND PQ-COUNT = WS-AREA
         GOBACK
     END-IF
     MOVE 0 TO L-OUT
     GOBACK.
 END PROGRAM PORTAL-UPDATE-SHAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-HOOK RECURSIVE.
*> USING kind, dimension row, x, y, z, state, a, b, out state (BINARY-LONG): the portal blocks' part of BU-HOOK (29 section 3 hook kinds):
*> kind 1 onPlace of fire or soul fire lights a frame (PORTAL-LIGHT; the portal then replaces the fire), of a portal block records its
*> point of interest; kind 2 removal of a portal block drops its point of interest; kind 4 updateShape of a portal block (PORTAL-UPDATE-SHAPE).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY PORTAL.
 LOCAL-STORAGE SECTION.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-LIT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-DIM L-X L-Y L-Z L-STATE L-A L-B L-OUT.
     IF L-KIND NOT = 1 AND L-KIND NOT = 2 AND L-KIND NOT = 4
         GOBACK
     END-IF
     CALL "PORTAL-IDS-ENSURE"
     MOVE CB-S-BLOCK(L-STATE + 1) TO WS-BLOCK
     EVALUATE TRUE
         WHEN L-KIND = 1 AND (WS-BLOCK = PI-FIRE OR WS-BLOCK = PI-SOUL-FIRE)
             CALL "PORTAL-LIGHT" USING L-DIM L-X L-Y L-Z WS-LIT
         WHEN L-KIND = 1 AND WS-BLOCK = PI-PORTAL
             CALL "PORTAL-POI-ADD" USING L-DIM L-X L-Y L-Z
         WHEN L-KIND = 2 AND WS-BLOCK = PI-PORTAL
             CALL "PORTAL-POI-REMOVE" USING L-DIM L-X L-Y L-Z
         WHEN L-KIND = 4 AND WS-BLOCK = PI-PORTAL
             CALL "PORTAL-UPDATE-SHAPE" USING L-DIM L-X L-Y L-Z L-STATE L-A L-B L-OUT
     END-EVALUATE
     GOBACK.
 END PROGRAM PORTAL-HOOK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-POI-ADD.
*> USING dimension row, x, y, z: records a nether_portal point of interest (39 section 5.1: one for every portal block); a position already
*> recorded is not added again; a full table drops the point.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PORTAL.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PQ-POI-COUNT
         IF PQ-P-DIM(WS-I) = L-DIM AND PQ-P-X(WS-I) = L-X AND PQ-P-Y(WS-I) = L-Y AND PQ-P-Z(WS-I) = L-Z
             GOBACK
         END-IF
     END-PERFORM
     IF PQ-POI-COUNT >= PQ-POI-MAX
         GOBACK
     END-IF
     ADD 1 TO PQ-POI-COUNT
     MOVE L-DIM TO PQ-P-DIM(PQ-POI-COUNT)
     MOVE L-X TO PQ-P-X(PQ-POI-COUNT)
     MOVE L-Y TO PQ-P-Y(PQ-POI-COUNT)
     MOVE L-Z TO PQ-P-Z(PQ-POI-COUNT)
     GOBACK.
 END PROGRAM PORTAL-POI-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-POI-REMOVE.
*> USING dimension row, x, y, z: drops that point of interest (the last record takes its place).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PORTAL.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PQ-POI-COUNT
         IF PQ-P-DIM(WS-I) = L-DIM AND PQ-P-X(WS-I) = L-X AND PQ-P-Y(WS-I) = L-Y AND PQ-P-Z(WS-I) = L-Z
             MOVE PQ-POI(PQ-POI-COUNT) TO PQ-POI(WS-I)
             SUBTRACT 1 FROM PQ-POI-COUNT
             GOBACK
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PORTAL-POI-REMOVE.
