*> The per-state tables of the mesher (plan R-M: built once at load): for state id s, row s + 1,
*> ST-OPAQUE (1 = the state occludes the faces of its neighbours) and ST-BLOCK (its block id, so a
*> non-opaque block can hide its own faces against the same block, as lucite does). With a content
*> set open (CT-OPEN) they come from it through CONTENT-BLOCK-OF-STATE, one row per state of the
*> set (ST-COUNT = CT-STATE-COUNT, at most CL-MAX-STATES); with none they come from the stand-in
*> table CL-BS of CLCONST.cpy (ST-COUNT = CL-STAND-STATES). The rule on a content row: a block is
*> opaque unless its flags say noOcclusion, noCollision, air, liquid or replaceable, or its class
*> is open (fences, walls, doors, panes and the
*> like) or a see-through material (glass, ice, leaves): the client holds no shape for a state, so this is the class-level approximation of the
*> occlusion shape (24 part 1 section 5.2: canOcclude and a full block shape). A state that passes the class rule occludes by its outline shape (51; the
*> face classes of state-faces.cob: ST-SHAPED, ST-OWN, ST-NB, ST-COVER): a neighbour hides a face only when its face covers the whole face (a slab hides the
*> side of a full block not at all, the full block hides the whole side of the slab); it is opaque (ST-OPAQUE) only when its outline is the full cube (a double slab is). A state at or above
*> ST-COUNT is not opaque and has block 0. STATE-TABLES-ENSURE builds them when they are not.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STATE-TABLES-ENSURE.
*> USING CLIENT-STATE: STATE-TABLES-BUILD unless the tables are built (ST-READY).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF ST-READY = 0
         CALL "STATE-TABLES-BUILD" USING CLIENT-STATE
     END-IF
     GOBACK.
 END PROGRAM STATE-TABLES-ENSURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STATE-TABLES-BUILD.
*> USING CLIENT-STATE: fills ST-OPAQUE and ST-BLOCK for every state of the set (or the stand-in
*> table) and clears the rows above; ST-READY becomes 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CONTENT.
 COPY CTBSHAPE.
 COPY CLFACES.
 01 WS-S                   BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-OPAQUE              PIC 9.
 01 WS-ROW                 PIC X(819).
 01 WS-FLUID               PIC 9.
 01 WS-HITS                BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-SHAPE               BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-OPP                 BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 01 WS-PROPS.
    05 WS-P-COUNT          BINARY-LONG.
    05 WS-P-ENTRY OCCURS 16 TIMES.
       10 WS-P-NAME        PIC X(24).
       10 WS-P-VALUE       PIC X(32).
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     CALL "STATE-LIMIT" USING WS-LIMIT
     MOVE FUNCTION MIN(WS-LIMIT, CL-MAX-STATES) TO ST-COUNT
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > CL-MAX-STATES
         MOVE 0 TO ST-OPAQUE(WS-S) ST-BLOCK(WS-S) ST-FLUID(WS-S) ST-LEVEL(WS-S) ST-OVERLAY(WS-S) ST-SHAPED(WS-S) ST-LIKE(WS-S)
     END-PERFORM
*>   A state that does not occlude: its faces need the whole neighbour face to hide them (class 1) and hide nothing (class 2).
     PERFORM VARYING WS-AT FROM 1 BY 1 UNTIL WS-AT > 393222
         MOVE 1 TO ST-OWN(WS-AT)
         MOVE 2 TO ST-NB(WS-AT)
     END-PERFORM
     CALL "STATE-FACES-INIT"
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 2048
         MOVE SPACES TO ST-BLOCK-NAME(WS-S)
     END-PERFORM
     IF CT-OPEN = 1 AND CT-STATE-COUNT > 0
*>       The collision and outline shape of every state (51 block shapes): the content library's tables, built once per set type.
         CALL "BSH-BUILD"
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > ST-COUNT
             COMPUTE WS-CODE = WS-S - 1
             CALL "CONTENT-BLOCK-OF-STATE" USING WS-CODE WS-BLOCK WS-INDEX WS-ROW WS-STATUS
             MOVE WS-BLOCK TO ST-BLOCK(WS-S)
             CALL "STATE-ROW-OPAQUE" USING WS-ROW WS-OPAQUE
*>           A state that occludes by its shape (the class rule below: not an open or see-through class; slabs, stairs, carpets, snow layers and trapdoors are in) hides what its faces cover
*>           (the face classes); it is opaque, hiding every face and the light, only when its outline shape is the full cube (id 1).
             IF WS-OPAQUE = 1 AND BSH-READY = 1 AND BSH-OUT(WS-S) NOT = 0
                 MOVE 1 TO ST-SHAPED(WS-S)
                 MOVE BSH-OUT(WS-S) TO WS-SHAPE
                 CALL "STATE-FACES-SHAPE" USING WS-SHAPE
                 PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 6
                     COMPUTE WS-OPP = WS-D + 1 - 2 * FUNCTION MOD(WS-D + 1, 2)
                     COMPUTE WS-AT = WS-CODE * 6 + WS-D
                     MOVE SF-OWN(WS-SHAPE + 1, WS-D) TO ST-OWN(WS-AT)
                     MOVE SF-NB(WS-SHAPE + 1, WS-OPP) TO ST-NB(WS-AT)
                 END-PERFORM
             END-IF
*>           A state that does not occlude but fills the cube (glass, ice, leaves) hides its faces against the same block.
             IF WS-OPAQUE = 0 AND BSH-READY = 1 AND BSH-OUT(WS-S) = 1
                 MOVE 1 TO ST-LIKE(WS-S)
             END-IF
*>           HalfTransparentBlock.skipRendering hides a face against the same block whatever the outline (honey's is smaller than the cube).
             IF WS-OPAQUE = 0 AND BSH-READY = 1
                 MOVE WS-ROW TO CT-BLOCK-ROW
                 MOVE 0 TO WS-HITS
                 INSPECT CT-BR-CLASS TALLYING WS-HITS FOR ALL "HoneyBlock"
                 IF WS-HITS > 0
                     MOVE 1 TO ST-LIKE(WS-S)
                 END-IF
             END-IF
             IF WS-OPAQUE = 1 AND BSH-READY = 1 AND BSH-OUT(WS-S) NOT = 1
                 MOVE 0 TO WS-OPAQUE
             END-IF
             MOVE WS-OPAQUE TO ST-OPAQUE(WS-S)
             MOVE WS-ROW TO CT-BLOCK-ROW
             CALL "STATE-FLUID-OF" USING WS-ROW WS-FLUID
*>           A waterlogged state (a block with the property, set true) holds water and keeps its model (4).
             IF WS-FLUID = 0
                 MOVE 0 TO WS-HITS
                 INSPECT CT-BR-PROPS TALLYING WS-HITS FOR ALL "waterlogged"
                 IF WS-HITS > 0
                     CALL "CONTENT-STATE-PROPS" USING WS-CODE WS-PROPS WS-STATUS
                     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > WS-P-COUNT
                         IF WS-P-NAME(WS-P) = "waterlogged" AND WS-P-VALUE(WS-P) = "true"
                             MOVE 4 TO WS-FLUID
                         END-IF
                     END-PERFORM
                 END-IF
             END-IF
             MOVE WS-FLUID TO ST-FLUID(WS-S)
*>           The classes that take the overlay sprite of the water beside them (29a 10.3).
             MOVE 0 TO WS-HITS
             INSPECT CT-BR-CLASS TALLYING WS-HITS FOR ALL "Transparent" ALL "IceBlock" ALL "SlimeBlock" ALL "HoneyBlock"
                 ALL "Leaves" ALL "StainedGlass" ALL "TintedGlass"
             IF WS-HITS > 0
                 MOVE 1 TO ST-OVERLAY(WS-S)
             END-IF
             IF WS-FLUID > 0 AND WS-FLUID < 3
                 MOVE WS-INDEX TO ST-LEVEL(WS-S)
             END-IF
*>           The block's name as the table holds it, without a namespace (the tint sources key on it).
             IF WS-BLOCK >= 0 AND WS-BLOCK < 2048 AND WS-STATUS = CT-OK
                 IF ST-BLOCK-NAME(WS-BLOCK + 1) = SPACES
                     MOVE WS-ROW TO CT-BLOCK-ROW
                     MOVE CT-BR-KEY TO ST-BLOCK-NAME(WS-BLOCK + 1)
                 END-IF
             END-IF
         END-PERFORM
     ELSE
*>       The stand-in table: the block id is the hex digit of its row (0 to 9, A, B); every state but 0 is a full cube.
         MOVE 0 TO BSH-READY BSH-TYPE
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > ST-COUNT
             COMPUTE WS-CODE = FUNCTION ORD(CL-BS-BLOCK(WS-S)) - 1
             COMPUTE ST-BLOCK(WS-S) = WS-CODE - 48
             IF WS-CODE >= 65
                 COMPUTE ST-BLOCK(WS-S) = WS-CODE - 55
             END-IF
             MOVE CL-BS-OPAQUE(WS-S) TO ST-OPAQUE(WS-S) ST-SHAPED(WS-S)
             COMPUTE ST-LIKE(WS-S) = 1 - CL-BS-OPAQUE(WS-S)
*>           An opaque stand-in state is a whole face for its neighbours.
             IF CL-BS-OPAQUE(WS-S) = 1
                 PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 6
                     COMPUTE WS-AT = (WS-S - 1) * 6 + WS-D
                     MOVE 1 TO ST-NB(WS-AT)
                 END-PERFORM
             END-IF
         END-PERFORM
     END-IF
     CALL "STATE-FACES-MATRIX" USING CLIENT-STATE
     MOVE 1 TO ST-READY
     GOBACK.
 END PROGRAM STATE-TABLES-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STATE-FLUID-OF.
*> USING block row (PIC X(819), CT-BLOCK-ROW), fluid out (PIC 9): the fluid the block's states hold (29a section 1.2): 1 water
*> and 2 lava (the liquid blocks, whose state index is the level; they have no model), 3 water for a block that is always wet and
*> has a model of its own without collision (kelp, seagrass, the bubble column), else 0; STATE-TABLES-BUILD sets 4 for a
*> waterlogged state (water, a model and its collision).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-KEY                 PIC X(35).
 LINKAGE SECTION.
 01 L-ROW                  PIC X(819).
 01 L-FLUID                PIC 9.
 PROCEDURE DIVISION USING L-ROW L-FLUID.
     MOVE L-ROW TO CT-BLOCK-ROW
     MOVE CT-BR-KEY TO WS-KEY
     MOVE 0 TO L-FLUID
     EVALUATE WS-KEY
         WHEN "water"
             MOVE 1 TO L-FLUID
         WHEN "lava"
             MOVE 2 TO L-FLUID
         WHEN "kelp"
         WHEN "kelp_plant"
         WHEN "seagrass"
         WHEN "tall_seagrass"
         WHEN "bubble_column"
             MOVE 3 TO L-FLUID
     END-EVALUATE
     GOBACK.
 END PROGRAM STATE-FLUID-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STATE-ROW-OPAQUE.
*> USING block row (PIC X(819), CT-BLOCK-ROW), opaque out (PIC 9): the rule of the header.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-HITS                BINARY-LONG.
 01 WS-TRAP                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  PIC X(819).
 01 L-OPAQUE               PIC 9.
 PROCEDURE DIVISION USING L-ROW L-OPAQUE.
     MOVE L-ROW TO CT-BLOCK-ROW
     MOVE 0 TO WS-HITS
     INSPECT CT-BR-FLAGS TALLYING WS-HITS FOR ALL "noOcclusion" ALL "noCollision" ALL "air"
         ALL "liquid" ALL "replaceable"
     INSPECT CT-BR-CLASS TALLYING WS-HITS FOR ALL "Fence" ALL "Wall"
         ALL "Door" ALL "Pane" ALL "Bars" ALL "Chest" ALL "Bed"
         ALL "Anvil" ALL "Cauldron" ALL "Hopper" ALL "Ladder" ALL "Rail" ALL "Button" ALL "Lever"
         ALL "Torch" ALL "Sign" ALL "Banner" ALL "Skull" ALL "Flower" ALL "Sapling" ALL "Cake"
         ALL "Lantern" ALL "Campfire" ALL "Liquid" ALL "Air" ALL "Transparent" ALL "Glass"
         ALL "IceBlock" ALL "Leaves"
*>   A trapdoor (class TrapDoorBlock) is no door: it occludes by its shape, as slabs, stairs, carpets and snow layers do.
     MOVE 0 TO WS-TRAP
     INSPECT CT-BR-CLASS TALLYING WS-TRAP FOR ALL "TrapDoor"
*>   HalfTransparentBlock (blue ice, ice, slime, honey, stained glass) is no TransparentBlock: it occludes unless its flags say noOcclusion.
     INSPECT CT-BR-CLASS TALLYING WS-TRAP FOR ALL "HalfTransparent"
     SUBTRACT WS-TRAP FROM WS-HITS
     MOVE 1 TO L-OPAQUE
     IF WS-HITS > 0
         MOVE 0 TO L-OPAQUE
     END-IF
     GOBACK.
 END PROGRAM STATE-ROW-OPAQUE.
