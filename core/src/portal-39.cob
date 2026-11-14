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

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-LIMIT.
*> USING dimension row, x, y, z, step dx, dy, dz, maximum, reference state, count out (BINARY-LONG): BlockUtil limit (39 section 4.3): how many
*> consecutive cells from (x, y, z) + step * 1, at most the maximum, hold exactly the reference state.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-REF                  BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-DX L-DY L-DZ L-MAX L-REF L-COUNT.
     MOVE 0 TO L-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-MAX
         COMPUTE WS-X = L-X + L-DX * WS-I
         COMPUTE WS-Y = L-Y + L-DY * WS-I
         COMPUTE WS-Z = L-Z + L-DZ * WS-I
         CALL "WORLD-GET-BLOCK" USING L-DIM WS-X WS-Y WS-Z WS-STATE
         IF WS-STATE NOT = L-REF
             GOBACK
         END-IF
         ADD 1 TO L-COUNT
     END-PERFORM
     GOBACK.
 END PROGRAM PORTAL-LIMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-LARGEST-RECT.
*> USING dimension row, x, y, z, axis (0 X, 1 Z), PORTAL-RECT out: BlockUtil.getLargestRectangleAround (39 section 4.3) with axis1 the portal's
*> axis (limit 21), axis2 Y (limit 21) and the predicate "exactly the state at (x, y, z)": one column per offset along the axis with the
*> extents down and up from the row of (x, y, z) that never grow outward, then for each bottom row from the centre column's lowest row down to 0
*> the largest rectangle under the column heights (a rectangle replaces the best only when strictly larger; a rectangle closes at the column past its
*> right end and taller closes first, so the first of equal areas stays).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-AX                  BINARY-LONG.
 01 WS-AZ                  BINARY-LONG.
 01 WS-NAX                 BINARY-LONG.
 01 WS-NAZ                 BINARY-LONG.
 01 WS-REF                 BINARY-LONG.
 01 WS-NEG                 BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-C0                  BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-COLUMNS.
    05 WS-DOWN             BINARY-LONG OCCURS 44 TIMES.
    05 WS-UP               BINARY-LONG OCCURS 44 TIMES.
    05 WS-HT               BINARY-LONG OCCURS 44 TIMES.
    05 WS-S-START          BINARY-LONG OCCURS 46 TIMES.
    05 WS-S-H              BINARY-LONG OCCURS 46 TIMES.
 01 WS-OFFSET              BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-DOWN0               BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SP                  BINARY-LONG.
 01 WS-CUR                 BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-MORE                BINARY-LONG.
 01 WS-AREA                BINARY-LONG.
 01 WS-RBEST               BINARY-LONG.
 01 WS-RLO                 BINARY-LONG.
 01 WS-RHI                 BINARY-LONG.
 01 WS-RH                  BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 01 WS-BLO                 BINARY-LONG.
 01 WS-BW                  BINARY-LONG.
 01 WS-BH                  BINARY-LONG.
 01 WS-BV                  BINARY-LONG.
 01 WS-LIMIT-MAX           BINARY-LONG VALUE 21.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-MINUS               BINARY-LONG VALUE -1.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-AXIS                 BINARY-LONG.
 COPY PORTALRECT.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-AXIS PORTAL-RECT.
     MOVE 1 TO WS-AX
     MOVE 0 TO WS-AZ
     IF L-AXIS = 1
         MOVE 0 TO WS-AX
         MOVE 1 TO WS-AZ
     END-IF
     COMPUTE WS-NAX = 0 - WS-AX
     COMPUTE WS-NAZ = 0 - WS-AZ
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-REF
     CALL "PORTAL-LIMIT" USING L-DIM L-X L-Y L-Z WS-NAX WS-ZERO WS-NAZ WS-LIMIT-MAX WS-REF WS-NEG
     CALL "PORTAL-LIMIT" USING L-DIM L-X L-Y L-Z WS-AX WS-ZERO WS-AZ WS-LIMIT-MAX WS-REF WS-POS
     COMPUTE WS-N = WS-NEG + WS-POS + 1
     MOVE WS-NEG TO WS-C0
     COMPUTE WS-C = WS-C0 + 1
     CALL "PORTAL-LIMIT" USING L-DIM L-X L-Y L-Z WS-ZERO WS-MINUS WS-ZERO WS-LIMIT-MAX WS-REF WS-DOWN(WS-C)
     CALL "PORTAL-LIMIT" USING L-DIM L-X L-Y L-Z WS-ZERO WS-ONE WS-ZERO WS-LIMIT-MAX WS-REF WS-UP(WS-C)
*>   Outward from the centre: first the negative side, then the positive one.
     PERFORM VARYING WS-C FROM WS-C0 BY -1 UNTIL WS-C < 1
         COMPUTE WS-OFFSET = WS-C - 1 - WS-C0
         COMPUTE WS-CX = L-X + WS-AX * WS-OFFSET
         COMPUTE WS-CZ = L-Z + WS-AZ * WS-OFFSET
         MOVE WS-DOWN(WS-C + 1) TO WS-MAX
         CALL "PORTAL-LIMIT" USING L-DIM WS-CX L-Y WS-CZ WS-ZERO WS-MINUS WS-ZERO WS-MAX WS-REF WS-DOWN(WS-C)
         MOVE WS-UP(WS-C + 1) TO WS-MAX
         CALL "PORTAL-LIMIT" USING L-DIM WS-CX L-Y WS-CZ WS-ZERO WS-ONE WS-ZERO WS-MAX WS-REF WS-UP(WS-C)
     END-PERFORM
     PERFORM VARYING WS-C FROM WS-C0 BY 1 UNTIL WS-C >= WS-N - 1
         COMPUTE WS-OFFSET = WS-C + 1 - WS-C0
         COMPUTE WS-CX = L-X + WS-AX * WS-OFFSET
         COMPUTE WS-CZ = L-Z + WS-AZ * WS-OFFSET
         MOVE WS-DOWN(WS-C + 1) TO WS-MAX
         CALL "PORTAL-LIMIT" USING L-DIM WS-CX L-Y WS-CZ WS-ZERO WS-MINUS WS-ZERO WS-MAX WS-REF WS-DOWN(WS-C + 2)
         MOVE WS-UP(WS-C + 1) TO WS-MAX
         CALL "PORTAL-LIMIT" USING L-DIM WS-CX L-Y WS-CZ WS-ZERO WS-ONE WS-ZERO WS-MAX WS-REF WS-UP(WS-C + 2)
     END-PERFORM
     MOVE WS-DOWN(WS-C0 + 1) TO WS-DOWN0
     MOVE 0 TO WS-BEST WS-BLO WS-BW WS-BH WS-BV
     PERFORM VARYING WS-V FROM WS-DOWN0 BY -1 UNTIL WS-V < 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
             MOVE 0 TO WS-HT(WS-I)
             COMPUTE WS-AREA = WS-DOWN0 - WS-DOWN(WS-I)
             COMPUTE WS-CUR = WS-DOWN0 + WS-UP(WS-I)
             IF WS-AREA <= WS-V AND WS-V <= WS-CUR
                 COMPUTE WS-HT(WS-I) = WS-CUR + 1 - WS-V
             END-IF
         END-PERFORM
         MOVE 0 TO WS-SP WS-RBEST WS-RLO WS-RHI WS-RH
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > WS-N
             MOVE 0 TO WS-CUR
             IF WS-I < WS-N
                 MOVE WS-HT(WS-I + 1) TO WS-CUR
             END-IF
             MOVE WS-I TO WS-START
             MOVE 1 TO WS-MORE
             PERFORM UNTIL WS-MORE = 0
                 IF WS-SP = 0
                     MOVE 0 TO WS-MORE
                 ELSE
                     IF WS-S-H(WS-SP) <= WS-CUR
                         MOVE 0 TO WS-MORE
                     ELSE
                         COMPUTE WS-AREA = WS-S-H(WS-SP) * (WS-I - WS-S-START(WS-SP))
                         IF WS-AREA > WS-RBEST
                             MOVE WS-AREA TO WS-RBEST
                             MOVE WS-S-START(WS-SP) TO WS-RLO
                             COMPUTE WS-RHI = WS-I - 1
                             MOVE WS-S-H(WS-SP) TO WS-RH
                         END-IF
                         MOVE WS-S-START(WS-SP) TO WS-START
                         SUBTRACT 1 FROM WS-SP
                     END-IF
                 END-IF
             END-PERFORM
             IF WS-CUR > 0
                 MOVE 1 TO WS-MORE
                 IF WS-SP > 0
                     IF WS-S-H(WS-SP) >= WS-CUR
                         MOVE 0 TO WS-MORE
                     END-IF
                 END-IF
                 IF WS-MORE = 1
                     ADD 1 TO WS-SP
                     MOVE WS-START TO WS-S-START(WS-SP)
                     MOVE WS-CUR TO WS-S-H(WS-SP)
                 END-IF
             END-IF
         END-PERFORM
         IF WS-RBEST > WS-BEST
             MOVE WS-RBEST TO WS-BEST
             MOVE WS-RLO TO WS-BLO
             COMPUTE WS-BW = WS-RHI - WS-RLO + 1
             MOVE WS-RH TO WS-BH
             MOVE WS-V TO WS-BV
         END-IF
     END-PERFORM
     COMPUTE WS-OFFSET = WS-BLO - WS-C0
     COMPUTE PR-X = L-X + WS-AX * WS-OFFSET
     COMPUTE PR-Y = L-Y + WS-BV - WS-DOWN0
     COMPUTE PR-Z = L-Z + WS-AZ * WS-OFFSET
     MOVE WS-BW TO PR-W
     MOVE WS-BH TO PR-H
     MOVE L-AXIS TO PR-AXIS
     GOBACK.
 END PROGRAM PORTAL-LARGEST-RECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-BORDER.
*> USING dimension row, minimum x, maximum x, minimum z, maximum z out (FLOAT-LONG): the extent of that level's world border (33 section 7.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY WSIM2.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-MIN-X                FLOAT-LONG.
 01 L-MAX-X                FLOAT-LONG.
 01 L-MIN-Z                FLOAT-LONG.
 01 L-MAX-Z                FLOAT-LONG.
 PROCEDURE DIVISION USING L-DIM L-MIN-X L-MAX-X L-MIN-Z L-MAX-Z.
     CALL "WORLDSIM-ENSURE2"
     CALL "WB-EXTENT" USING W2-B-CX(L-DIM) W2-B-SIZE(L-DIM) W2-B-ABSOLUTE(L-DIM) L-MIN-X L-MAX-X
     CALL "WB-EXTENT" USING W2-B-CZ(L-DIM) W2-B-SIZE(L-DIM) W2-B-ABSOLUTE(L-DIM) L-MIN-Z L-MAX-Z
     GOBACK.
 END PROGRAM PORTAL-BORDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-IN-BORDER.
*> USING dimension row, block x, block z, inside out (BINARY-LONG): the block position test of the world border (the minimum edge inclusive,
*> the maximum exclusive; 33 section 7.4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MIN-X               FLOAT-LONG.
 01 WS-MAX-X               FLOAT-LONG.
 01 WS-MIN-Z               FLOAT-LONG.
 01 WS-MAX-Z               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-INSIDE               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Z L-INSIDE.
     CALL "PORTAL-BORDER" USING L-DIM WS-MIN-X WS-MAX-X WS-MIN-Z WS-MAX-Z
     MOVE 0 TO L-INSIDE
     IF L-X >= WS-MIN-X AND L-X < WS-MAX-X AND L-Z >= WS-MIN-Z AND L-Z < WS-MAX-Z
         MOVE 1 TO L-INSIDE
     END-IF
     GOBACK.
 END PROGRAM PORTAL-IN-BORDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-SCALE.
*> USING source dimension row, destination dimension row, scale out (FLOAT-LONG): DimensionType.getTeleportationScale (39 section 4.1): the
*> source's coordinate_scale over the destination's (the nether 8.0, every other dimension 1.0; 37-1 section 2.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY DIMENSIONS.
 01 WS-FROM                FLOAT-LONG.
 01 WS-TO                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-FROM                 BINARY-LONG.
 01 L-TO                   BINARY-LONG.
 01 L-SCALE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-FROM L-TO L-SCALE.
     MOVE 1.0 TO WS-FROM WS-TO
     IF DM-KEY(L-FROM) = "minecraft:the_nether"
         MOVE 8.0 TO WS-FROM
     END-IF
     IF DM-KEY(L-TO) = "minecraft:the_nether"
         MOVE 8.0 TO WS-TO
     END-IF
     COMPUTE L-SCALE = WS-FROM / WS-TO
     GOBACK.
 END PROGRAM PORTAL-SCALE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-ORIGIN.
*> USING source dimension row, destination dimension row, entity x, y, z (FLOAT-LONG), origin x, y, z out (BINARY-LONG): 39 section 4.1 step 3:
*> the entity position with x and z scaled, clamped into the destination border (the maximum edge less 9.999999747378752E-6), and the block
*> containing it; y is not scaled.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SCALE               FLOAT-LONG.
 01 WS-MIN-X               FLOAT-LONG.
 01 WS-MAX-X               FLOAT-LONG.
 01 WS-MIN-Z               FLOAT-LONG.
 01 WS-MAX-Z               FLOAT-LONG.
 01 WS-SX                  FLOAT-LONG.
 01 WS-SZ                  FLOAT-LONG.
 01 WS-EPS                 FLOAT-LONG VALUE 0.000009999999747378752.
 01 WS-MARGIN              FLOAT-LONG VALUE 0.
 01 WS-WITHIN              BINARY-LONG.
 01 WS-DISTANCE            FLOAT-LONG.
 01 WS-CX                  FLOAT-LONG.
 01 WS-CZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-FROM                 BINARY-LONG.
 01 L-TO                   BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-FROM L-TO L-X L-Y L-Z L-OX L-OY L-OZ.
     CALL "PORTAL-SCALE" USING L-FROM L-TO WS-SCALE
     CALL "PORTAL-BORDER" USING L-TO WS-MIN-X WS-MAX-X WS-MIN-Z WS-MAX-Z
     COMPUTE WS-SX = L-X * WS-SCALE
     COMPUTE WS-SZ = L-Z * WS-SCALE
     CALL "WB-GEOMETRY" USING WS-SX WS-SZ WS-MARGIN WS-MIN-X WS-MAX-X WS-MIN-Z WS-MAX-Z WS-WITHIN WS-DISTANCE WS-CX WS-CZ
     COMPUTE L-OX = FUNCTION INTEGER(WS-CX)
     COMPUTE L-OY = FUNCTION INTEGER(L-Y)
     COMPUTE L-OZ = FUNCTION INTEGER(WS-CZ)
     GOBACK.
 END PROGRAM PORTAL-ORIGIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-FIND-EXISTING.
*> USING destination dimension row, origin x, y, z, destination is the nether (BINARY-LONG), found out, x, y, z out: PortalForcer
*> .findClosestPortalPosition (39 section 5.1): the portal points of interest within 16 (nether destination) or 128 blocks in x and z of the
*> origin, inside the destination border and still portal blocks, the nearest by 3D squared distance, the lower y on a tie.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PORTAL.
 01 WS-R                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-INSIDE              BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-D                   BINARY-DOUBLE.
 01 WS-BEST                BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 01 L-NETHER               BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-OX L-OY L-OZ L-NETHER L-FOUND L-X L-Y L-Z.
     MOVE 0 TO L-FOUND
     MOVE PQ-RADIUS-OVERWORLD TO WS-R
     IF L-NETHER = 1
         MOVE PQ-RADIUS-NETHER TO WS-R
     END-IF
     MOVE 0 TO WS-BEST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PQ-POI-COUNT
         COMPUTE WS-DX = PQ-P-X(WS-I) - L-OX
         COMPUTE WS-DZ = PQ-P-Z(WS-I) - L-OZ
         IF PQ-P-DIM(WS-I) = L-DIM AND FUNCTION ABS(WS-DX) <= WS-R AND FUNCTION ABS(WS-DZ) <= WS-R
             CALL "PORTAL-IN-BORDER" USING L-DIM PQ-P-X(WS-I) PQ-P-Z(WS-I) WS-INSIDE
             MOVE 0 TO WS-KIND
             IF WS-INSIDE = 1
                 CALL "PORTAL-CELL-KIND" USING L-DIM PQ-P-X(WS-I) PQ-P-Y(WS-I) PQ-P-Z(WS-I) WS-KIND
             END-IF
             IF WS-KIND = 2
                 COMPUTE WS-DY = PQ-P-Y(WS-I) - L-OY
                 COMPUTE WS-D = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
                 IF L-FOUND = 0 OR WS-D < WS-BEST OR (WS-D = WS-BEST AND PQ-P-Y(WS-I) < L-Y)
                     MOVE 1 TO L-FOUND
                     MOVE WS-D TO WS-BEST
                     MOVE PQ-P-X(WS-I) TO L-X
                     MOVE PQ-P-Y(WS-I) TO L-Y
                     MOVE PQ-P-Z(WS-I) TO L-Z
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PORTAL-FIND-EXISTING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-REPLACEABLE.
*> USING dimension row, x, y, z, replaceable out (BINARY-LONG): the cell can be replaced by a portal frame: air, fire or a block without
*> collision that is no fluid and no portal (an approximation of canBeReplaced with an empty fluid state: the core has no replaceable flag).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY PORTAL.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-FLAG.
     MOVE 0 TO L-FLAG
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     CALL "PORTAL-STATE-KIND" USING WS-STATE WS-KIND
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
     IF WS-KIND = 3
         MOVE 1 TO L-FLAG
         GOBACK
     END-IF
     IF WS-KIND = 0 AND CB-SOLID(WS-BLOCK + 1) = 0 AND WS-BLOCK NOT = PI-WATER AND WS-BLOCK NOT = PI-LAVA
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM PORTAL-REPLACEABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-HOST.
*> USING dimension row, x, y, z of a candidate, shift k (BINARY-LONG), dir x, dir z, cw x, cw z, ok out: host(k) of 39 section 5.2: the frame slab
*> shifted by k along the clockwise direction can be built: for i from -1 to 2 along dir the cell below (j = -1) is solid and the four above
*> (j 0 to 3) are replaceable.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-K                    BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-CWX                  BINARY-LONG.
 01 L-CWZ                  BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-K L-DX L-DZ L-CWX L-CWZ L-OK.
     MOVE 1 TO L-OK
     PERFORM VARYING WS-I FROM -1 BY 1 UNTIL WS-I > 2
         COMPUTE WS-X = L-X + L-K * L-CWX + WS-I * L-DX
         COMPUTE WS-Z = L-Z + L-K * L-CWZ + WS-I * L-DZ
         PERFORM VARYING WS-J FROM -1 BY 1 UNTIL WS-J > 3
             COMPUTE WS-Y = L-Y + WS-J
             IF WS-J = -1
                 CALL "WORLD-GET-BLOCK" USING L-DIM WS-X WS-Y WS-Z WS-STATE
                 IF CB-SOLID(CB-S-BLOCK(WS-STATE + 1) + 1) NOT = 1
                     MOVE 0 TO L-OK
                 END-IF
             ELSE
                 CALL "PORTAL-REPLACEABLE" USING L-DIM WS-X WS-Y WS-Z WS-FLAG
                 IF WS-FLAG = 0
                     MOVE 0 TO L-OK
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM PORTAL-HOST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-TOP.
*> USING dimension row, top out: min(maxY, minY + logical_height - 1) (39 section 5.2; the nether's logical height is 128, every other
*> dimension's is its height).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY DIMENSIONS.
 01 WS-LOGICAL             BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-TOP.
     MOVE DM-HEIGHT(L-DIM) TO WS-LOGICAL
     IF DM-KEY(L-DIM) = "minecraft:the_nether"
         MOVE 128 TO WS-LOGICAL
     END-IF
     COMPUTE L-TOP = DM-MIN-Y(L-DIM) + WS-LOGICAL - 1
     IF L-TOP > DM-MIN-Y(L-DIM) + DM-HEIGHT(L-DIM) - 1
         COMPUTE L-TOP = DM-MIN-Y(L-DIM) + DM-HEIGHT(L-DIM) - 1
     END-IF
     GOBACK.
 END PROGRAM PORTAL-TOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-SURFACE.
*> USING dimension row, x, z, height out: the first y above the highest block that blocks motion (a solid block or a fluid): the
*> MOTION_BLOCKING height of 06, found by scanning down from the top of the dimension.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY DIMENSIONS.
 COPY PORTAL.
 01 WS-Y                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Z L-HEIGHT.
     MOVE DM-MIN-Y(L-DIM) TO L-HEIGHT
     COMPUTE WS-Y = DM-MIN-Y(L-DIM) + DM-HEIGHT(L-DIM) - 1
     PERFORM UNTIL WS-Y < DM-MIN-Y(L-DIM)
         CALL "WORLD-GET-BLOCK" USING L-DIM L-X WS-Y L-Z WS-STATE
         MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
         IF CB-SOLID(WS-BLOCK + 1) = 1 OR WS-BLOCK = PI-WATER OR WS-BLOCK = PI-LAVA
             COMPUTE L-HEIGHT = WS-Y + 1
             GOBACK
         END-IF
         SUBTRACT 1 FROM WS-Y
     END-PERFORM
     GOBACK.
 END PROGRAM PORTAL-SURFACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-CREATE.
*> USING destination dimension row, origin x, y, z, axis (0 X, 1 Z), PORTAL-RECT out, ok out (BINARY-LONG): PortalForcer.createPortal
*> (39 section 5.2). Phase A scans the 1089 columns of the square spiral of radius 16 round the origin (east first, then south) for the
*> replaceable runs that can host the frame, keeping the nearest candidate that also hosts the slabs in front and behind (full) or else the
*> nearest that hosts its own (fallback); phase B builds an obsidian platform when there is none; phase C builds the 4 x 5 obsidian frame
*> and the 2 x 3 portal interior (flags 18). The rectangle is the interior; ok 0 when nothing could be made.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY PORTAL.
 01 WS-SPIRAL.
    05 WS-SPX              BINARY-LONG OCCURS 1089 TIMES.
    05 WS-SPZ              BINARY-LONG OCCURS 1089 TIMES.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-CWX                 BINARY-LONG.
 01 WS-CWZ                 BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-MIN-Y               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-LEG                 BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-YB                  BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-HEIGHT              BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-INSIDE              BINARY-LONG.
 01 WS-INSIDE2             BINARY-LONG.
 01 WS-NEXT-X              BINARY-LONG.
 01 WS-HOST                BINARY-LONG.
 01 WS-HOST-M              BINARY-LONG.
 01 WS-HOST-P              BINARY-LONG.
 01 WS-K0                  BINARY-LONG VALUE 0.
 01 WS-KM                  BINARY-LONG VALUE -1.
 01 WS-KP                  BINARY-LONG VALUE 1.
 01 WS-D                   BINARY-DOUBLE.
 01 WS-DY                  BINARY-LONG.
 01 WS-FULL                BINARY-LONG.
 01 WS-FULL-D              BINARY-DOUBLE.
 01 WS-FULL-X              BINARY-LONG.
 01 WS-FULL-Y              BINARY-LONG.
 01 WS-FULL-Z              BINARY-LONG.
 01 WS-FALL                BINARY-LONG.
 01 WS-FALL-D              BINARY-DOUBLE.
 01 WS-FALL-X              BINARY-LONG.
 01 WS-FALL-Y              BINARY-LONG.
 01 WS-FALL-Z              BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-CHOSEN              BINARY-LONG.
 01 WS-LOWER               BINARY-LONG.
 01 WS-UPPER               BINARY-LONG.
 01 WS-MIN-BX              FLOAT-LONG.
 01 WS-MAX-BX              FLOAT-LONG.
 01 WS-MIN-BZ              FLOAT-LONG.
 01 WS-MAX-BZ              FLOAT-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-MARGIN              FLOAT-LONG VALUE 0.
 01 WS-WITHIN              BINARY-LONG.
 01 WS-DISTANCE            FLOAT-LONG.
 01 WS-CLX                 FLOAT-LONG.
 01 WS-CLZ                 FLOAT-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-OBSIDIAN            BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 18.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 01 L-AXIS                 BINARY-LONG.
 COPY PORTALRECT.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-OX L-OY L-OZ L-AXIS PORTAL-RECT L-OK.
     CALL "PORTAL-IDS-ENSURE"
     MOVE 0 TO L-OK
     MOVE 1 TO WS-DX
     MOVE 0 TO WS-DZ
     MOVE 0 TO WS-CWX
     MOVE 1 TO WS-CWZ
     IF L-AXIS = 1
         MOVE 0 TO WS-DX
         MOVE 1 TO WS-DZ
         MOVE -1 TO WS-CWX
         MOVE 0 TO WS-CWZ
     END-IF
     CALL "PORTAL-TOP" USING L-DIM WS-TOP
     MOVE DM-MIN-Y(L-DIM) TO WS-MIN-Y
*>   The square spiral of 1089 offsets: (0, 0), then legs east 1, south 1, west 2, north 2, east 3, ...
     MOVE 1 TO WS-N
     MOVE 0 TO WS-SPX(1) WS-SPZ(1) WS-SX WS-SZ
     PERFORM VARYING WS-LEG FROM 1 BY 1 UNTIL WS-N >= 1089
         COMPUTE WS-LEN = (WS-LEG + 1) / 2
         COMPUTE WS-DIR = FUNCTION MOD(WS-LEG - 1, 4)
         PERFORM VARYING WS-STEP FROM 1 BY 1 UNTIL WS-STEP > WS-LEN OR WS-N >= 1089
             EVALUATE WS-DIR
                 WHEN 0
                     ADD 1 TO WS-SX
                 WHEN 1
                     ADD 1 TO WS-SZ
                 WHEN 2
                     SUBTRACT 1 FROM WS-SX
                 WHEN OTHER
                     SUBTRACT 1 FROM WS-SZ
             END-EVALUATE
             ADD 1 TO WS-N
             MOVE WS-SX TO WS-SPX(WS-N)
             MOVE WS-SZ TO WS-SPZ(WS-N)
         END-PERFORM
     END-PERFORM
     MOVE 0 TO WS-FULL WS-FALL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1089
         COMPUTE WS-X = L-OX + WS-SPX(WS-I)
         COMPUTE WS-Z = L-OZ + WS-SPZ(WS-I)
         COMPUTE WS-NEXT-X = WS-X + WS-DX
         CALL "PORTAL-IN-BORDER" USING L-DIM WS-X WS-Z WS-INSIDE
         COMPUTE WS-A = WS-Z + WS-DZ
         CALL "PORTAL-IN-BORDER" USING L-DIM WS-NEXT-X WS-A WS-INSIDE2
         IF WS-INSIDE = 1 AND WS-INSIDE2 = 1
             CALL "PORTAL-SURFACE" USING L-DIM WS-X WS-Z WS-HEIGHT
             MOVE WS-HEIGHT TO WS-START
             IF WS-START > WS-TOP
                 MOVE WS-TOP TO WS-START
             END-IF
             MOVE WS-START TO WS-Y
             PERFORM UNTIL WS-Y < WS-MIN-Y
                 CALL "PORTAL-REPLACEABLE" USING L-DIM WS-X WS-Y WS-Z WS-FLAG
                 IF WS-FLAG = 0
                     SUBTRACT 1 FROM WS-Y
                 ELSE
                     MOVE WS-Y TO WS-YB
                     MOVE 1 TO WS-FLAG
                     PERFORM UNTIL WS-FLAG = 0
                         IF WS-YB <= WS-MIN-Y
                             MOVE 0 TO WS-FLAG
                         ELSE
                             COMPUTE WS-B = WS-YB - 1
                             CALL "PORTAL-REPLACEABLE" USING L-DIM WS-X WS-B WS-Z WS-FLAG
                             IF WS-FLAG = 1
                                 MOVE WS-B TO WS-YB
                             END-IF
                         END-IF
                     END-PERFORM
                     COMPUTE WS-C = WS-Y - WS-YB
                     IF WS-YB + 4 <= WS-TOP AND (WS-C = 0 OR WS-C >= 3)
                         CALL "PORTAL-HOST" USING L-DIM WS-X WS-YB WS-Z WS-K0 WS-DX WS-DZ WS-CWX WS-CWZ WS-HOST
                         IF WS-HOST = 1
                             COMPUTE WS-DY = WS-YB - L-OY
                             COMPUTE WS-D = WS-SPX(WS-I) * WS-SPX(WS-I) + WS-DY * WS-DY + WS-SPZ(WS-I) * WS-SPZ(WS-I)
                             CALL "PORTAL-HOST" USING L-DIM WS-X WS-YB WS-Z WS-KM WS-DX WS-DZ WS-CWX WS-CWZ WS-HOST-M
                             CALL "PORTAL-HOST" USING L-DIM WS-X WS-YB WS-Z WS-KP WS-DX WS-DZ WS-CWX WS-CWZ WS-HOST-P
                             IF WS-HOST-M = 1 AND WS-HOST-P = 1
                                 IF WS-FULL = 0 OR WS-D < WS-FULL-D
                                     MOVE 1 TO WS-FULL
                                     MOVE WS-D TO WS-FULL-D
                                     MOVE WS-X TO WS-FULL-X
                                     MOVE WS-YB TO WS-FULL-Y
                                     MOVE WS-Z TO WS-FULL-Z
                                 END-IF
                             END-IF
                             IF WS-FULL = 0 AND (WS-FALL = 0 OR WS-D < WS-FALL-D)
                                 MOVE 1 TO WS-FALL
                                 MOVE WS-D TO WS-FALL-D
                                 MOVE WS-X TO WS-FALL-X
                                 MOVE WS-YB TO WS-FALL-Y
                                 MOVE WS-Z TO WS-FALL-Z
                             END-IF
                         END-IF
                     END-IF
                     COMPUTE WS-Y = WS-YB - 1
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     MOVE 0 TO WS-CHOSEN
     IF WS-FULL = 1
         MOVE 1 TO WS-CHOSEN
         MOVE WS-FULL-X TO WS-PX
         MOVE WS-FULL-Y TO WS-PY
         MOVE WS-FULL-Z TO WS-PZ
     ELSE
         IF WS-FALL = 1
             MOVE 1 TO WS-CHOSEN
             MOVE WS-FALL-X TO WS-PX
             MOVE WS-FALL-Y TO WS-PY
             MOVE WS-FALL-Z TO WS-PZ
         END-IF
     END-IF
*>   Phase B: no position at all, a platform of obsidian at the origin's height clamped to the creation range.
     IF WS-CHOSEN = 0
         COMPUTE WS-LOWER = WS-MIN-Y + 1
         IF WS-LOWER < 70
             MOVE 70 TO WS-LOWER
         END-IF
         COMPUTE WS-UPPER = WS-TOP - 9
         IF WS-UPPER < WS-LOWER
             GOBACK
         END-IF
         MOVE L-OY TO WS-PY
         IF WS-PY < WS-LOWER
             MOVE WS-LOWER TO WS-PY
         END-IF
         IF WS-PY > WS-UPPER
             MOVE WS-UPPER TO WS-PY
         END-IF
         COMPUTE WS-FX = L-OX - WS-DX
         COMPUTE WS-FZ = L-OZ - WS-DZ
         CALL "PORTAL-BORDER" USING L-DIM WS-MIN-BX WS-MAX-BX WS-MIN-BZ WS-MAX-BZ
         CALL "WB-GEOMETRY" USING WS-FX WS-FZ WS-MARGIN WS-MIN-BX WS-MAX-BX WS-MIN-BZ WS-MAX-BZ WS-WITHIN WS-DISTANCE
             WS-CLX WS-CLZ
         COMPUTE WS-PX = FUNCTION INTEGER(WS-CLX)
         COMPUTE WS-PZ = FUNCTION INTEGER(WS-CLZ)
         MOVE PI-OBSIDIAN TO WS-A
         MOVE CB-DEFAULT-STATE(WS-A + 1) TO WS-OBSIDIAN
         PERFORM VARYING WS-A FROM -1 BY 1 UNTIL WS-A > 1
             PERFORM VARYING WS-B FROM 0 BY 1 UNTIL WS-B > 1
                 PERFORM VARYING WS-J FROM -1 BY 1 UNTIL WS-J > 2
                     COMPUTE WS-X = WS-PX + WS-A * WS-CWX + WS-B * WS-DX
                     COMPUTE WS-Y = WS-PY + WS-J
                     COMPUTE WS-Z = WS-PZ + WS-A * WS-CWZ + WS-B * WS-DZ
                     IF WS-J = -1
                         CALL "BLOCK-CHANGE" USING L-DIM WS-X WS-Y WS-Z WS-OBSIDIAN
                     ELSE
                         CALL "BLOCK-CHANGE" USING L-DIM WS-X WS-Y WS-Z WS-AIR
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-IF
*>   Phase C: the frame (14 cells) and the interior.
     MOVE PI-OBSIDIAN TO WS-A
     MOVE CB-DEFAULT-STATE(WS-A + 1) TO WS-OBSIDIAN
     PERFORM VARYING WS-A FROM -1 BY 1 UNTIL WS-A > 2
         PERFORM VARYING WS-J FROM -1 BY 1 UNTIL WS-J > 3
             IF WS-A = -1 OR WS-A = 2 OR WS-J = -1 OR WS-J = 3
                 COMPUTE WS-X = WS-PX + WS-A * WS-DX
                 COMPUTE WS-Y = WS-PY + WS-J
                 COMPUTE WS-Z = WS-PZ + WS-A * WS-DZ
                 CALL "BLOCK-CHANGE" USING L-DIM WS-X WS-Y WS-Z WS-OBSIDIAN
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE PI-PORTAL-X TO WS-STATE
     IF L-AXIS = 1
         MOVE PI-PORTAL-Z TO WS-STATE
     END-IF
     PERFORM VARYING WS-A FROM 0 BY 1 UNTIL WS-A > 1
         PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 2
             COMPUTE WS-X = WS-PX + WS-A * WS-DX
             COMPUTE WS-Y = WS-PY + WS-J
             COMPUTE WS-Z = WS-PZ + WS-A * WS-DZ
             CALL "LEVEL-SET-BLOCK" USING L-DIM WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-BUDGET WS-RESULT
         END-PERFORM
     END-PERFORM
     MOVE WS-PX TO PR-X
     MOVE WS-PY TO PR-Y
     MOVE WS-PZ TO PR-Z
     MOVE 2 TO PR-W
     MOVE 3 TO PR-H
     MOVE L-AXIS TO PR-AXIS
     MOVE 1 TO L-OK
     GOBACK.
 END PROGRAM PORTAL-CREATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-RELATIVE.
*> USING PORTAL-RECT of the entry portal, entity x, y, z (FLOAT-LONG), entity width, height (FLOAT-LONG), rx, ry, rz out (FLOAT-LONG):
*> PortalShape.getRelativePosition (39 section 4.4): rx the position along the axis between the rectangle's ends (0.5 when the entity fills
*> the width), ry the position along the height (0 when it fills it), rz the offset from the portal plane, unclamped.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SLACK-W             FLOAT-LONG.
 01 WS-SLACK-H             FLOAT-LONG.
 01 WS-ALONG               FLOAT-LONG.
 01 WS-MIN-ALONG           FLOAT-LONG.
 01 WS-OTHER               FLOAT-LONG.
 01 WS-MIN-OTHER           FLOAT-LONG.
 LINKAGE SECTION.
 COPY PORTALRECT.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-EW                   FLOAT-LONG.
 01 L-EH                   FLOAT-LONG.
 01 L-RX                   FLOAT-LONG.
 01 L-RY                   FLOAT-LONG.
 01 L-RZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING PORTAL-RECT L-X L-Y L-Z L-EW L-EH L-RX L-RY L-RZ.
     IF PR-AXIS = 0
         MOVE L-X TO WS-ALONG
         MOVE PR-X TO WS-MIN-ALONG
         MOVE L-Z TO WS-OTHER
         MOVE PR-Z TO WS-MIN-OTHER
     ELSE
         MOVE L-Z TO WS-ALONG
         MOVE PR-Z TO WS-MIN-ALONG
         MOVE L-X TO WS-OTHER
         MOVE PR-X TO WS-MIN-OTHER
     END-IF
     COMPUTE WS-SLACK-W = PR-W - L-EW
     COMPUTE WS-SLACK-H = PR-H - L-EH
     MOVE 0.5 TO L-RX
     IF WS-SLACK-W > 0
         COMPUTE L-RX = (WS-ALONG - (WS-MIN-ALONG + L-EW / 2)) / WS-SLACK-W
         IF L-RX < 0
             MOVE 0 TO L-RX
         END-IF
         IF L-RX > 1
             MOVE 1 TO L-RX
         END-IF
     END-IF
     MOVE 0 TO L-RY
     IF WS-SLACK-H > 0
         COMPUTE L-RY = (L-Y - PR-Y) / WS-SLACK-H
         IF L-RY < 0
             MOVE 0 TO L-RY
         END-IF
         IF L-RY > 1
             MOVE 1 TO L-RY
         END-IF
     END-IF
     COMPUTE L-RZ = WS-OTHER - (WS-MIN-OTHER + 0.5)
     GOBACK.
 END PROGRAM PORTAL-RELATIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-EXIT-POS.
*> USING PORTAL-RECT of the exit portal, rx, ry, rz, entity width, height (FLOAT-LONG), x, y, z out (FLOAT-LONG): the exit position of 39 section
*> 4.4: px = ew / 2 + (W - ew) rx, py = (H - eh) ry, pz = 0.5 + rz; along the axis X the position is (minX + px, minY + py, minZ + pz), along Z
*> (minX + pz, minY + py, minZ + px).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 LINKAGE SECTION.
 COPY PORTALRECT.
 01 L-RX                   FLOAT-LONG.
 01 L-RY                   FLOAT-LONG.
 01 L-RZ                   FLOAT-LONG.
 01 L-EW                   FLOAT-LONG.
 01 L-EH                   FLOAT-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING PORTAL-RECT L-RX L-RY L-RZ L-EW L-EH L-X L-Y L-Z.
     COMPUTE WS-PX = L-EW / 2 + (PR-W - L-EW) * L-RX
     COMPUTE WS-PY = (PR-H - L-EH) * L-RY
     COMPUTE WS-PZ = 0.5 + L-RZ
     COMPUTE L-Y = PR-Y + WS-PY
     IF PR-AXIS = 0
         COMPUTE L-X = PR-X + WS-PX
         COMPUTE L-Z = PR-Z + WS-PZ
     ELSE
         COMPUTE L-X = PR-X + WS-PZ
         COMPUTE L-Z = PR-Z + WS-PX
     END-IF
     GOBACK.
 END PROGRAM PORTAL-EXIT-POS.
