*> The light engine of docs/protocol/32-light-engine.md fed from the core's block registry (T0697): the per-state inputs of section 2 (emission, dampening,
*> canOcclude, useShapeForLightOcclusion, the six face occlusion shapes) derived from the content rows, CBLOCKS.cpy and the shape tables of 51
*> (CTBSHAPE.cpy) with the rules of 24 part 1 section 5.2 and 32 section 7, and the engine state ids of the registry's block states.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-ENGINE-STATE.
*> USING registry block state id, engine state id (out): 0 for an air state (EN-ISAIR, set by L32-LOAD-REGISTRY), else the state id + 2 (ids 0 and 1 of the
*> engine are the presets of L32-INIT).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-ENGINE               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ENGINE.
     COMPUTE L-ENGINE = L-STATE + 2
     IF L-STATE >= 0 AND L-STATE < 40000
         IF EN-ISAIR(L-STATE + 1) = 1
             MOVE 0 TO L-ENGINE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM L32-ENGINE-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-SHAPE-IS-FULL.
*> USING shape id (CTBSHAPE.cpy), flag (out): 1 when one box of the shape is the full cube (the builder may give equal shapes more than one id, so the boxes are read).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTBSHAPE.
 01 WS-B                   BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-SHAPE                BINARY-LONG.
 01 L-FULL                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SHAPE L-FULL.
     MOVE 0 TO L-FULL
     COMPUTE WS-IDX = L-SHAPE + 1
     PERFORM VARYING WS-B FROM 1 BY 1 UNTIL WS-B > BSH-N(WS-IDX)
         IF BSH-V(WS-IDX, WS-B, 1) = 0 AND BSH-V(WS-IDX, WS-B, 2) = 0 AND BSH-V(WS-IDX, WS-B, 3) = 0
                 AND BSH-V(WS-IDX, WS-B, 4) = 16000 AND BSH-V(WS-IDX, WS-B, 5) = 16000 AND BSH-V(WS-IDX, WS-B, 6) = 16000
             MOVE 1 TO L-FULL
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM L32-SHAPE-IS-FULL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-FACE-MASKS.
*> USING shape id (CTBSHAPE.cpy), six face masks (out, DOWN UP NORTH SOUTH WEST EAST): the quadrant mask (bit qa + 2 qb, the halves of the two axes
*> of the face) of the boxes of the shape that touch the face's plane and cover the quadrant (32 section 2: 0 empty, 15 a full face).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTBSHAPE.
 01 WS-D                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-QA                  BINARY-LONG.
 01 WS-QB                  BINARY-LONG.
 01 WS-TOUCH               BINARY-LONG.
 01 WS-A1                  BINARY-LONG.
 01 WS-A2                  BINARY-LONG.
 01 WS-B1                  BINARY-LONG.
 01 WS-B2                  BINARY-LONG.
 01 WS-LO-A                BINARY-LONG.
 01 WS-LO-B                BINARY-LONG.
 01 WS-MASK                BINARY-LONG.
 01 WS-BIT                 BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-SHAPE                BINARY-LONG.
 01 L-FACES.
    05 L-FACE              BINARY-LONG OCCURS 6 TIMES.
 PROCEDURE DIVISION USING L-SHAPE L-FACES.
     COMPUTE WS-IDX = L-SHAPE + 1
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 6
         MOVE 0 TO WS-MASK
         IF BSH-N(WS-IDX) > 0
             PERFORM VARYING WS-B FROM 1 BY 1 UNTIL WS-B > BSH-N(WS-IDX)
                 MOVE 0 TO WS-TOUCH
                 EVALUATE WS-D
                     WHEN 1
                         IF BSH-V(WS-IDX, WS-B, 2) = 0
                             MOVE 1 TO WS-TOUCH
                         END-IF
                         MOVE BSH-V(WS-IDX, WS-B, 1) TO WS-A1
                         MOVE BSH-V(WS-IDX, WS-B, 4) TO WS-A2
                         MOVE BSH-V(WS-IDX, WS-B, 3) TO WS-B1
                         MOVE BSH-V(WS-IDX, WS-B, 6) TO WS-B2
                     WHEN 2
                         IF BSH-V(WS-IDX, WS-B, 5) = 16000
                             MOVE 1 TO WS-TOUCH
                         END-IF
                         MOVE BSH-V(WS-IDX, WS-B, 1) TO WS-A1
                         MOVE BSH-V(WS-IDX, WS-B, 4) TO WS-A2
                         MOVE BSH-V(WS-IDX, WS-B, 3) TO WS-B1
                         MOVE BSH-V(WS-IDX, WS-B, 6) TO WS-B2
                     WHEN 3
                         IF BSH-V(WS-IDX, WS-B, 3) = 0
                             MOVE 1 TO WS-TOUCH
                         END-IF
                         MOVE BSH-V(WS-IDX, WS-B, 1) TO WS-A1
                         MOVE BSH-V(WS-IDX, WS-B, 4) TO WS-A2
                         MOVE BSH-V(WS-IDX, WS-B, 2) TO WS-B1
                         MOVE BSH-V(WS-IDX, WS-B, 5) TO WS-B2
                     WHEN 4
                         IF BSH-V(WS-IDX, WS-B, 6) = 16000
                             MOVE 1 TO WS-TOUCH
                         END-IF
                         MOVE BSH-V(WS-IDX, WS-B, 1) TO WS-A1
                         MOVE BSH-V(WS-IDX, WS-B, 4) TO WS-A2
                         MOVE BSH-V(WS-IDX, WS-B, 2) TO WS-B1
                         MOVE BSH-V(WS-IDX, WS-B, 5) TO WS-B2
                     WHEN 5
                         IF BSH-V(WS-IDX, WS-B, 1) = 0
                             MOVE 1 TO WS-TOUCH
                         END-IF
                         MOVE BSH-V(WS-IDX, WS-B, 3) TO WS-A1
                         MOVE BSH-V(WS-IDX, WS-B, 6) TO WS-A2
                         MOVE BSH-V(WS-IDX, WS-B, 2) TO WS-B1
                         MOVE BSH-V(WS-IDX, WS-B, 5) TO WS-B2
                     WHEN OTHER
                         IF BSH-V(WS-IDX, WS-B, 4) = 16000
                             MOVE 1 TO WS-TOUCH
                         END-IF
                         MOVE BSH-V(WS-IDX, WS-B, 3) TO WS-A1
                         MOVE BSH-V(WS-IDX, WS-B, 6) TO WS-A2
                         MOVE BSH-V(WS-IDX, WS-B, 2) TO WS-B1
                         MOVE BSH-V(WS-IDX, WS-B, 5) TO WS-B2
                 END-EVALUATE
                 IF WS-TOUCH = 1
                     PERFORM VARYING WS-QB FROM 0 BY 1 UNTIL WS-QB > 1
                         PERFORM VARYING WS-QA FROM 0 BY 1 UNTIL WS-QA > 1
                             COMPUTE WS-LO-A = WS-QA * 8000
                             COMPUTE WS-LO-B = WS-QB * 8000
                             IF WS-A1 <= WS-LO-A AND WS-A2 >= WS-LO-A + 8000 AND WS-B1 <= WS-LO-B AND WS-B2 >= WS-LO-B + 8000
                                 COMPUTE WS-BIT = 2 ** (WS-QA + 2 * WS-QB)
                                 COMPUTE WS-Q = WS-MASK / WS-BIT
                                 IF FUNCTION MOD(WS-Q, 2) = 0
                                     ADD WS-BIT TO WS-MASK
                                 END-IF
                             END-IF
                         END-PERFORM
                     END-PERFORM
                 END-IF
             END-PERFORM
         END-IF
         MOVE WS-MASK TO L-FACE(WS-D)
     END-PERFORM
     GOBACK.
 END PROGRAM L32-FACE-MASKS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-LOAD-REGISTRY.
*> No parameters: defines the engine state (L32-DEFINE-STATE) of every block state of the open content set, id + 2, after L32-INIT. Per state: emission CB-S-LIGHT; canOcclude
*> CB-OPAQUE of the block (24 part 1 section 5.2: false for noOcclusion, noCollision, air); the occlusion shape the outline shape BSH-OUT (a box that is the full cube = solidRender); the fluid is
*> not empty for a waterlogged state, a LiquidBlock and the always-wet plants (24 part 2 section 5.3); propagatesSkylightDown by default the outline is not a full cube and the fluid
*> is empty; then L32-BLOCK-RULES (32 section 7) gives the dampening and useShapeForLightOcclusion; the face masks come from L32-FACE-MASKS. Air states (outline empty, flags
*> air) are marked in EN-ISAIR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY CTBSHAPE.
 COPY L32.
 01 WS-ROW                 PIC X(819).
 01 WS-STATE               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-HITS                BINARY-LONG.
 01 WS-PROPS               PIC X(160).
 01 WS-NAMES               PIC X(300).
 01 WS-CLASS               PIC X(32).
 01 WS-KEY                 PIC X(35).
 01 WS-HAS-PROPS           BINARY-LONG.
 01 WS-FLAGS               PIC X(149).
 01 WS-AIR                 BINARY-LONG.
 01 WS-ALWAYS-WET          BINARY-LONG.
 01 WS-WET                 BINARY-LONG.
 01 WS-DOUBLE              BINARY-LONG.
 01 WS-EXTENDED            BINARY-LONG.
 01 WS-SHAPE               BINARY-LONG.
 01 WS-FULL                BINARY-LONG.
 01 WS-OCC                 BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-FLUID-EMPTY         BINARY-LONG.
 01 WS-PROP-DEFAULT        BINARY-LONG.
 01 WS-DAMP                BINARY-LONG.
 01 WS-PROPAGATES          BINARY-LONG.
 01 WS-USE                 BINARY-LONG.
 01 WS-EMIT                BINARY-LONG.
 01 WS-ENGINE              BINARY-LONG.
 01 WS-FACES.
    05 WS-FACE             BINARY-LONG OCCURS 6 TIMES.
 01 WS-F                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE 0 TO WS-STATE
     MOVE CT-OK TO WS-STATUS
     PERFORM UNTIL WS-STATE >= CT-STATE-COUNT OR WS-STATUS NOT = CT-OK
         CALL "CONTENT-BLOCK-OF-STATE" USING WS-STATE WS-ID WS-INDEX WS-ROW WS-STATUS
         IF WS-STATUS = CT-OK
             MOVE WS-ROW TO CT-BLOCK-ROW
             MOVE CT-BR-CLASS TO WS-CLASS
             MOVE CT-BR-KEY TO WS-KEY
             MOVE SPACES TO WS-NAMES
             STRING " " CT-BR-PROPS " " DELIMITED BY SIZE INTO WS-NAMES
             MOVE 0 TO WS-HAS-PROPS WS-HITS
             INSPECT WS-NAMES TALLYING WS-HITS FOR ALL " waterlogged[" ALL " type[" ALL " extended["
             IF WS-HITS > 0
                 MOVE 1 TO WS-HAS-PROPS
             END-IF
             MOVE SPACES TO WS-FLAGS
             STRING " " CT-BR-FLAGS " " DELIMITED BY SIZE INTO WS-FLAGS
             MOVE 0 TO WS-AIR WS-HITS
             INSPECT WS-FLAGS TALLYING WS-HITS FOR ALL " air "
             IF WS-HITS > 0
                 MOVE 1 TO WS-AIR
             END-IF
             MOVE 0 TO WS-ALWAYS-WET
             IF WS-CLASS = "LiquidBlock"
                 MOVE 1 TO WS-ALWAYS-WET
             END-IF
             IF WS-KEY = "minecraft:seagrass" OR "minecraft:tall_seagrass" OR "minecraft:kelp"
                     OR "minecraft:kelp_plant" OR "minecraft:bubble_column"
                 MOVE 1 TO WS-ALWAYS-WET
             END-IF
             COMPUTE WS-LAST = WS-STATE + CB-STATES(WS-ID + 1) - 1
             PERFORM VARYING WS-S FROM WS-STATE BY 1 UNTIL WS-S > WS-LAST
                 MOVE WS-ALWAYS-WET TO WS-WET
                 MOVE 0 TO WS-DOUBLE WS-EXTENDED
                 IF WS-HAS-PROPS = 1
                     CALL "BLOCKS-STATE-PROPS" USING WS-S WS-PROPS
                     MOVE 0 TO WS-HITS
                     INSPECT WS-PROPS TALLYING WS-HITS FOR ALL "waterlogged=true"
                     IF WS-HITS > 0
                         MOVE 1 TO WS-WET
                     END-IF
                     MOVE 0 TO WS-HITS
                     INSPECT WS-PROPS TALLYING WS-HITS FOR ALL "type=double"
                     IF WS-HITS > 0
                         MOVE 1 TO WS-DOUBLE
                     END-IF
                     MOVE 0 TO WS-HITS
                     INSPECT WS-PROPS TALLYING WS-HITS FOR ALL "extended=true"
                     IF WS-HITS > 0
                         MOVE 1 TO WS-EXTENDED
                     END-IF
                 END-IF
                 MOVE 1 TO WS-FULL
                 MOVE 1 TO WS-SHAPE
                 IF BSH-READY = 1
                     MOVE BSH-OUT(WS-S + 1) TO WS-SHAPE
                     CALL "L32-SHAPE-IS-FULL" USING WS-SHAPE WS-FULL
                 END-IF
                 MOVE CB-OPAQUE(WS-ID + 1) TO WS-OCC
                 MOVE 0 TO WS-SOLID
                 IF WS-OCC = 1 AND WS-FULL = 1
                     MOVE 1 TO WS-SOLID
                 END-IF
                 COMPUTE WS-FLUID-EMPTY = 1 - WS-WET
                 MOVE 0 TO WS-PROP-DEFAULT
                 IF WS-FULL = 0 AND WS-FLUID-EMPTY = 1
                     MOVE 1 TO WS-PROP-DEFAULT
                 END-IF
                 CALL "L32-BLOCK-RULES" USING WS-CLASS WS-SOLID WS-PROP-DEFAULT WS-FLUID-EMPTY WS-WET WS-DOUBLE WS-EXTENDED
                     WS-DAMP WS-PROPAGATES WS-USE
                 MOVE CB-S-LIGHT(WS-S + 1) TO WS-EMIT
                 MOVE LOW-VALUES TO WS-FACES
                 IF WS-OCC = 1 AND BSH-READY = 1
                     CALL "L32-FACE-MASKS" USING WS-SHAPE WS-FACES
                 END-IF
                 IF WS-OCC = 1 AND BSH-READY = 0
                     MOVE 15 TO WS-FACE(1) WS-FACE(2) WS-FACE(3) WS-FACE(4) WS-FACE(5) WS-FACE(6)
                 END-IF
                 COMPUTE WS-ENGINE = WS-S + 2
                 CALL "L32-DEFINE-STATE" USING WS-ENGINE WS-EMIT WS-DAMP WS-OCC WS-USE
                     WS-FACE(1) WS-FACE(2) WS-FACE(3) WS-FACE(4) WS-FACE(5) WS-FACE(6)
                 MOVE 0 TO EN-ISAIR(WS-S + 1)
                 IF WS-AIR = 1
                     MOVE 1 TO EN-ISAIR(WS-S + 1)
                 END-IF
             END-PERFORM
             COMPUTE WS-STATE = WS-LAST + 1
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM L32-LOAD-REGISTRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-DIM-RESET.
*> USING sky engine present, block section count, lowest block section Y: starts a dimension's engine (L32-INIT, L32-SET-DIMENSION) and keeps the state table that
*> L32-LOAD-REGISTRY filled, so the registry is read once.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-KEEP-STATES         PIC X(1600080).
 01 WS-KEEP-AIR            PIC X(40000).
 LINKAGE SECTION.
 01 L-SKY                  BINARY-LONG.
 01 L-NS                   BINARY-LONG.
 01 L-MIN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SKY L-NS L-MIN.
     MOVE EN-STATES TO WS-KEEP-STATES
     MOVE EN-AIRS TO WS-KEEP-AIR
     CALL "L32-INIT" USING L-SKY
     MOVE WS-KEEP-STATES TO EN-STATES
     MOVE WS-KEEP-AIR TO EN-AIRS
     CALL "L32-SET-DIMENSION" USING L-NS L-MIN
     GOBACK.
 END PROGRAM L32-DIM-RESET.
