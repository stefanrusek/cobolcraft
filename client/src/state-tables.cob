*> The per-state tables of the mesher (plan R-M: built once at load): for state id s, row s + 1,
*> ST-OPAQUE (1 = the state occludes the faces of its neighbours) and ST-BLOCK (its block id, so a
*> non-opaque block can hide its own faces against the same block, as lucite does). With a content
*> set open (CT-OPEN) they come from it through CONTENT-BLOCK-OF-STATE, one row per state of the
*> set (ST-COUNT = CT-STATE-COUNT, at most CL-MAX-STATES); with none they come from the stand-in
*> table CL-BS of CLCONST.cpy (ST-COUNT = CL-STAND-STATES). The rule on a content row: a block is
*> opaque unless its flags say noOcclusion, noCollision, air, liquid or replaceable, or its class
*> is a shape that does not fill the cube (slabs, stairs, fences, walls, doors, panes and the
*> like) or a see-through material (glass, ice, leaves): the client holds no shape for a state, so this is the class-level approximation of the
*> occlusion shape (24 part 1 section 5.2: canOcclude and a full block shape). A state at or above
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
 01 WS-S                   BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-OPAQUE              PIC 9.
 01 WS-ROW                 PIC X(819).
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     CALL "STATE-LIMIT" USING WS-LIMIT
     MOVE FUNCTION MIN(WS-LIMIT, CL-MAX-STATES) TO ST-COUNT
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > CL-MAX-STATES
         MOVE 0 TO ST-OPAQUE(WS-S) ST-BLOCK(WS-S)
     END-PERFORM
     IF CT-OPEN = 1
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > ST-COUNT
             COMPUTE WS-CODE = WS-S - 1
             CALL "CONTENT-BLOCK-OF-STATE" USING WS-CODE WS-BLOCK WS-INDEX WS-ROW WS-STATUS
             MOVE WS-BLOCK TO ST-BLOCK(WS-S)
             CALL "STATE-ROW-OPAQUE" USING WS-ROW WS-OPAQUE
             MOVE WS-OPAQUE TO ST-OPAQUE(WS-S)
         END-PERFORM
     ELSE
*>       The stand-in table: the block id is the hex digit of its row (0 to 9, A, B).
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > ST-COUNT
             COMPUTE WS-CODE = FUNCTION ORD(CL-BS-BLOCK(WS-S)) - 1
             COMPUTE ST-BLOCK(WS-S) = WS-CODE - 48
             IF WS-CODE >= 65
                 COMPUTE ST-BLOCK(WS-S) = WS-CODE - 55
             END-IF
             MOVE CL-BS-OPAQUE(WS-S) TO ST-OPAQUE(WS-S)
         END-PERFORM
     END-IF
     MOVE 1 TO ST-READY
     GOBACK.
 END PROGRAM STATE-TABLES-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STATE-ROW-OPAQUE.
*> USING block row (PIC X(819), CT-BLOCK-ROW), opaque out (PIC 9): the rule of the header.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-HITS                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  PIC X(819).
 01 L-OPAQUE               PIC 9.
 PROCEDURE DIVISION USING L-ROW L-OPAQUE.
     MOVE L-ROW TO CT-BLOCK-ROW
     MOVE 0 TO WS-HITS
     INSPECT CT-BR-FLAGS TALLYING WS-HITS FOR ALL "noOcclusion" ALL "noCollision" ALL "air"
         ALL "liquid" ALL "replaceable"
     INSPECT CT-BR-CLASS TALLYING WS-HITS FOR ALL "Slab" ALL "Stair" ALL "Fence" ALL "Wall"
         ALL "Door" ALL "Pane" ALL "Bars" ALL "Carpet" ALL "SnowLayer" ALL "Chest" ALL "Bed"
         ALL "Anvil" ALL "Cauldron" ALL "Hopper" ALL "Ladder" ALL "Rail" ALL "Button" ALL "Lever"
         ALL "Torch" ALL "Sign" ALL "Banner" ALL "Skull" ALL "Flower" ALL "Sapling" ALL "Cake"
         ALL "Lantern" ALL "Campfire" ALL "Liquid" ALL "Air" ALL "Transparent" ALL "Glass"
         ALL "IceBlock" ALL "Leaves"
     MOVE 1 TO L-OPAQUE
     IF WS-HITS > 0
         MOVE 0 TO L-OPAQUE
     END-IF
     GOBACK.
 END PROGRAM STATE-ROW-OPAQUE.
