*> Ground items: cobolcraft:loose_item (US5; standin-content §1.3, §3, §9; data-model §5;
*> docs/protocol/09-cobolcraft-profile.md §3.3 ground-item rows, §3.4 rules 6 and 7).
*>
*> A ground item is a row of the entity tracker (CORE-ENTITIES, entity type 1) holding one item
*> stack (EN-ITEM, EN-ITEM-COUNT), its position (EN-X to EN-Z), motion (EN-VX to EN-VZ), pickup delay
*> (EN-DELAY), age (EN-AGE) and resting flag (EN-ON-GROUND). Its entity UUID has the most
*> significant 64 bits 0 and the least significant 64 bits = the entity id (09 §3.3).
*>
*> Sources (§9.1): a survival block break (GI-BLOCK-YIELD: one item of the block's item, §1.3, at
*> (x + 0.5, y + 0.25, z + 0.5), motion 0, pickup delay 6) and a throw (GI-THROW: Player Action 5
*> DROP_ITEM one item, 4 DROP_ALL_ITEMS the whole stack, from the held hotbar slot, any game mode;
*> an empty slot throws nothing; at the feet + (0, 1.3, 0) with the §9.1 thrown motion and pickup
*> delay 30; the held slot is echoed with Container Set Slot; GI-THROW-STACK, shared with the
*> inventory-screen throws of INV-CLICK and INV-CLOSE). A new item enters the tracker: every
*> player who sees it gets Add Entity (movement = its motion) and Set Entity Data with its stack, then
*> Set Entity Motion when its motion is not (0, 0, 0) (09 §3.4 rule 6).
*>
*> Per tick (GROUND-ITEMS-TICK, the last step of CORE-TICK, §9.5): every ground item whose chunk is
*> loaded, in ascending entity id order, runs the §9.2 steps:
*>   1. a pickup delay above 0 decreases by 1;
*>   2. the age increases by 1 when a player of the same dimension (joined, any mode or state) has
*>      feet within 32.0 blocks (3D distance); at 4800 the item despawns (Remove Entities);
*>   3. movement: the item box (x +- 0.15, y to y + 0.3, z +- 0.15) is pushed up out of solid cells;
*>      a resting item with a solid cell below stays put, otherwise it falls: gravity, then moves
*>      along Y, X and Z, each blocked by solid cells (a cell of an unloaded chunk is solid; touching
*>      faces within 1e-7 block do not overlap), landing on a downward Y block, then drag 0.97 (motion
*>      0 at rest). After a tick in which the position changed, the viewers get Teleport Entity
*>      (position, current motion, angles 0, on-ground = resting) and visibility follows;
*>   4. pickup (§9.3): alive players of the dimension whose box expanded by 0.75 in x and z and 0.25
*>      in y overlaps or touches the item box, while the pickup delay is 0, in the order they
*>      entered the world (PL-ENTERED): each takes what fits (INV-ADD) and the next is tried only if
*>      items remain. For each taker the viewers get Take Item Entity and the taker Container Set
*>      Slot of the slots that changed (state id raised once); an emptied item is removed (Remove
*>      Entities), a reduced one is sent Set Entity Data with the rest.
*> Ground items never merge (§9.2, RULES.cpy RULE-GI-MERGES 0): identical items lying side by side
*> stay separate entities.
*>
*> Entry points:
*>   GI-BLOCK-YIELD USING dim, x, y, z, block id (BINARY-LONG)     yield of a survival break
*>   GI-THROW USING connection id, PLAY-SERVERBOUND               Player Action 4 or 5
*>   GI-THROW-STACK USING player row, item, count (BINARY-LONG)   a stack thrown by the player
*>   GI-SPAWN USING dim, x, y, z, vx, vy, vz (FLOAT-LONG), item, count, pickup delay, row out
*>     (BINARY-LONG)                                              a new ground item
*>   GROUND-ITEMS-TICK                                            the per-tick rules (CORE-TICK)
*> Builders (append id + body to the caller's PB-BUFFER):
*>   SET-ENTITY-DATA-ITEM-BUILD USING entity id, item, count, PB-BUFFER
*>   SET-ENTITY-MOTION-BUILD USING entity id, vx, vy, vz (FLOAT-LONG), PB-BUFFER
*>   TAKE-ITEM-ENTITY-BUILD USING collected id, collector id, amount, PB-BUFFER

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SET-ENTITY-DATA-ITEM-BUILD.
*> USING entity id, item, count (BINARY-LONG), PB-BUFFER: Set Entity Data 0x65 (05b; 09 §3.3): the
*> entity id, one metadata entry (index 0, serializer 7 ITEM_STACK, the stack), the 0xFF end.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MD-==.
 01 WS-PACKET-ID           BINARY-LONG VALUE 101.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ENTITY-ID            BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY-ID L-ITEM L-COUNT PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ENTITY-ID
     INITIALIZE MD-METADATA-ENTRY
     MOVE 0 TO MD-MD-INDEX
     MOVE MD-MDS-ITEM-STACK TO MD-MD-SERIALIZER
     MOVE L-COUNT TO MD-MD-IS-COUNT
     MOVE L-ITEM TO MD-MD-IS-ITEM
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     MOVE MD-MD-END TO MD-MD-INDEX
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     GOBACK.
 END PROGRAM SET-ENTITY-DATA-ITEM-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SET-ENTITY-MOTION-BUILD.
*> USING entity id (BINARY-LONG), vx, vy, vz (FLOAT-LONG), PB-BUFFER: Set Entity Motion 0x67 (05b):
*> the entity id and the motion as LpVec3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 103.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ENTITY-ID            BINARY-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-ENTITY-ID L-VX L-VY L-VZ PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ENTITY-ID
     CALL "PB-PUT-LPVEC3" USING PB-BUFFER L-VX L-VY L-VZ
     GOBACK.
 END PROGRAM SET-ENTITY-MOTION-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TAKE-ITEM-ENTITY-BUILD.
*> USING collected entity id, collector entity id, amount (BINARY-LONG), PB-BUFFER: Take Item Entity
*> 0x7F (05b: three VarInts).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 127.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-COLLECTED            BINARY-LONG.
 01 L-COLLECTOR            BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 PROCEDURE DIVISION USING L-COLLECTED L-COLLECTOR L-AMOUNT PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-COLLECTED
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-COLLECTOR
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-AMOUNT
     GOBACK.
 END PROGRAM TAKE-ITEM-ENTITY-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GI-VIEWERS-SEND.
*> USING tracker row (BINARY-LONG), PB-BUFFER: sends the packet to every client that has the entity.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-PLAYER              BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     PERFORM VARYING WS-PLAYER FROM 1 BY 1 UNTIL WS-PLAYER > CORE-MAX-PLAYERS
         IF VW-SEEN(WS-PLAYER)(L-ROW:1) = "1"
             CALL "CORE-SEND" USING PL-CONN(WS-PLAYER) PB-BUFFER
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GI-VIEWERS-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GI-SOLID-CELL.
*> USING dimension row, cell x, y, z (BINARY-LONG), solid out (BINARY-LONG 1 or 0): 1 when the cell's
*> chunk is not loaded or its block is solid (BLOCKS.cpy SB-SOLID; void outside the height range).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLK                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-SOLID                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-SOLID.
     COMPUTE WS-CX = (L-X - FUNCTION MOD(L-X, 16)) / 16
     COMPUTE WS-CZ = (L-Z - FUNCTION MOD(L-Z, 16)) / 16
     CALL "WORLD-FIND" USING L-DIM WS-CX WS-CZ WS-ROW
     MOVE 1 TO L-SOLID
     IF WS-ROW > 0
         CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
         MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLK
         MOVE CB-SOLID(WS-BLK + 1) TO L-SOLID
     END-IF
     GOBACK.
 END PROGRAM GI-SOLID-CELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-BOX-HITS.
*> USING dimension row, entity type (BINARY-LONG), x, y, z (FLOAT-LONG entity position), hit out,
*> top out (BINARY-LONG): hit 1 when the collision box of that entity type (ENTITYTYPES.cpy, standin
*> §3) at that position overlaps a solid cell (GI-SOLID-CELL) with positive volume, faces within
*> 1e-7 block counting as touching; top is then the highest y among those cells. Ground items
*> (GI-MOVE) and mobs (core/src/mobs.cob) move with it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY ENTITYTYPES.
 01 WS-HALF                FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-EPSILON             FLOAT-LONG VALUE 0.0000001.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-HIT                  BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-TYPE L-X L-Y L-Z L-HIT L-TOP.
     MOVE 0 TO L-HIT
     COMPUTE WS-HALF = ET-WIDTH-MILLI(L-TYPE + 1) / 2000
     COMPUTE WS-HEIGHT = ET-HEIGHT-MILLI(L-TYPE + 1) / 1000
*>   First cell floor(low edge + e), last cell ceil(high edge - e) - 1 (as MOVE-COLLIDES).
     COMPUTE WS-X0 = FUNCTION INTEGER(L-X - WS-HALF + WS-EPSILON)
     COMPUTE WS-X1 = - FUNCTION INTEGER(WS-EPSILON - (L-X + WS-HALF)) - 1
     COMPUTE WS-Y0 = FUNCTION INTEGER(L-Y + WS-EPSILON)
     COMPUTE WS-Y1 = - FUNCTION INTEGER(WS-EPSILON - (L-Y + WS-HEIGHT)) - 1
     COMPUTE WS-Z0 = FUNCTION INTEGER(L-Z - WS-HALF + WS-EPSILON)
     COMPUTE WS-Z1 = - FUNCTION INTEGER(WS-EPSILON - (L-Z + WS-HALF)) - 1
     PERFORM VARYING WS-BY FROM WS-Y0 BY 1 UNTIL WS-BY > WS-Y1
         PERFORM VARYING WS-BZ FROM WS-Z0 BY 1 UNTIL WS-BZ > WS-Z1
             PERFORM VARYING WS-BX FROM WS-X0 BY 1 UNTIL WS-BX > WS-X1
                 CALL "GI-SOLID-CELL" USING L-DIM WS-BX WS-BY WS-BZ WS-SOLID
                 IF WS-SOLID = 1
                     MOVE 1 TO L-HIT
                     MOVE WS-BY TO L-TOP
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-BOX-HITS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GI-SPAWN.
*> USING dimension row (BINARY-LONG), x, y, z, vx, vy, vz (FLOAT-LONG), item, count, pickup delay,
*> row out (BINARY-LONG): a new falling ground item of age 0 enters the tracker; its viewers get Add
*> Entity and Set Entity Data, then Set Entity Motion when the motion is not (0, 0, 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY ENTITYTYPES.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-VX L-VY L-VZ L-ITEM L-COUNT L-DELAY L-ROW.
     CALL "ENTITY-ALLOC" USING WS-ROW
     CALL "ENTITY-NEW-ID" USING EN-ID(WS-ROW)
     MOVE ET-LOOSE-ITEM TO EN-TYPE(WS-ROW)
     CALL "ENTITY-SET-UUID" USING WS-ROW
     MOVE L-DIM TO EN-DIM(WS-ROW)
     MOVE L-X TO EN-X(WS-ROW)
     MOVE L-Y TO EN-Y(WS-ROW)
     MOVE L-Z TO EN-Z(WS-ROW)
     MOVE L-VX TO EN-VX(WS-ROW)
     MOVE L-VY TO EN-VY(WS-ROW)
     MOVE L-VZ TO EN-VZ(WS-ROW)
     MOVE L-ITEM TO EN-ITEM(WS-ROW)
     MOVE L-COUNT TO EN-ITEM-COUNT(WS-ROW)
     MOVE L-DELAY TO EN-DELAY(WS-ROW)
     CALL "ENTITY-TRACK" USING WS-ROW
     IF L-VX NOT = 0 OR L-VY NOT = 0 OR L-VZ NOT = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "SET-ENTITY-MOTION-BUILD" USING EN-ID(WS-ROW) L-VX L-VY L-VZ PB-BUFFER
         CALL "GI-VIEWERS-SEND" USING WS-ROW PB-BUFFER
         CALL "PB-FREE" USING PB-BUFFER
     END-IF
     MOVE WS-ROW TO L-ROW
     GOBACK.
 END PROGRAM GI-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GI-BLOCK-YIELD.
*> USING dimension row, x, y, z (block position), block id (BINARY-LONG) of a block just broken in
*> survival: one item of the block's yield (RULES.cpy RULE-YIELD-ITEM, standin §1.3) at (x + 0.5,
*> y + 0.25, z + 0.5), motion 0, pickup delay 6. Only breakable blocks reach here (BLOCK-ACTION
*> refuses void and the baseplate), and every breakable block has a yield.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY RULES.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG VALUE 0.
 01 WS-VY                  FLOAT-LONG VALUE 0.
 01 WS-VZ                  FLOAT-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-DELAY               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-BLOCK.
     MOVE RULE-GI-BREAK-DELAY TO WS-DELAY
     COMPUTE WS-X = L-X + RULE-GI-BREAK-DXZ-MILLI / 1000
     COMPUTE WS-Y = L-Y + RULE-GI-BREAK-DY-MILLI / 1000
     COMPUTE WS-Z = L-Z + RULE-GI-BREAK-DXZ-MILLI / 1000
     CALL "GI-SPAWN" USING L-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ RULE-YIELD-ITEM(L-BLOCK + 1)
         WS-ONE WS-DELAY WS-ROW
     GOBACK.
 END PROGRAM GI-BLOCK-YIELD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GI-THROW.
*> USING connection id, PLAY-SERVERBOUND (a decoded Player Action 4 DROP_ALL_ITEMS or 5 DROP_ITEM):
*> the throw rules above.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND.
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     MOVE PL-HELD(WS-ROW) TO WS-SLOT
     MOVE PL-SLOT-COUNT(WS-ROW, WS-SLOT + 1) TO WS-COUNT
     IF WS-COUNT = 0
         GOBACK
     END-IF
     IF PSB-ACTION = 5
         MOVE 1 TO WS-COUNT
     END-IF
     MOVE PL-SLOT-ITEM(WS-ROW, WS-SLOT + 1) TO WS-ITEM
     CALL "INV-REMOVE" USING WS-ROW WS-SLOT WS-COUNT
     COMPUTE PL-STATE-ID(WS-ROW) = FUNCTION MOD(PL-STATE-ID(WS-ROW) + 1, 32768)
     CALL "INV-SLOT-SEND" USING L-ID WS-SLOT
     CALL "GI-THROW-STACK" USING WS-ROW WS-ITEM WS-COUNT
     GOBACK.
 END PROGRAM GI-THROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GI-THROW-STACK.
*> USING player row, item, count (BINARY-LONG): a ground item of that stack thrown by the player
*> (standin §9.1 Throw: at the feet + (0, 1.3, 0), the thrown motion, pickup delay 30). The
*> caller has already taken the stack from the inventory or the cursor.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RULES.
 01 WS-DELAY               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-PITCH               FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ITEM L-COUNT.
     COMPUTE WS-YAW = PL-YAW(L-ROW) * FUNCTION PI / 180
     COMPUTE WS-PITCH = PL-PITCH(L-ROW) * FUNCTION PI / 180
     COMPUTE WS-VX = - FUNCTION SIN(WS-YAW) * FUNCTION COS(WS-PITCH)
         * RULE-GI-THROW-SPEED-MILLI / 1000
     COMPUTE WS-VY = - FUNCTION SIN(WS-PITCH) * RULE-GI-THROW-SPEED-MILLI / 1000
         + RULE-GI-THROW-LIFT-MILLI / 1000
     COMPUTE WS-VZ = FUNCTION COS(WS-YAW) * FUNCTION COS(WS-PITCH)
         * RULE-GI-THROW-SPEED-MILLI / 1000
     COMPUTE WS-Y = PL-Y(L-ROW) + RULE-GI-THROW-DY-MILLI / 1000
     MOVE RULE-GI-THROW-DELAY TO WS-DELAY
     CALL "GI-SPAWN" USING PL-DIM(L-ROW) PL-X(L-ROW) WS-Y PL-Z(L-ROW) WS-VX WS-VY WS-VZ
         L-ITEM L-COUNT WS-DELAY WS-NEW
     GOBACK.
 END PROGRAM GI-THROW-STACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GI-IN-REACH.
*> USING player row, tracker row (BINARY-LONG), in out (BINARY-LONG 1 or 0): 1 when the player may
*> pick the item up now: alive, in the item's dimension, and the item box overlaps or touches the
*> player's box (standin §3) expanded by 0.75 in x and z and by 0.25 in y (§9.3; 1e-7 tolerance).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY ENTITYTYPES.
 COPY RULES.
 01 WS-REACH-XZ            FLOAT-LONG.
 01 WS-REACH-Y             FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-HALF                FLOAT-LONG.
 01 WS-ITEM-HEIGHT         FLOAT-LONG.
 01 WS-EPSILON             FLOAT-LONG VALUE 0.0000001.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-IN                   BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ROW L-IN.
     MOVE 0 TO L-IN
     COMPUTE WS-REACH-XZ = ET-WIDTH-MILLI(ET-OPERATOR + 1) / 2000
         + RULE-GI-REACH-XZ-MILLI / 1000 + ET-WIDTH-MILLI(ET-LOOSE-ITEM + 1) / 2000
     COMPUTE WS-REACH-Y = RULE-GI-REACH-Y-MILLI / 1000
     COMPUTE WS-HEIGHT = ET-HEIGHT-MILLI(ET-OPERATOR + 1) / 1000
     COMPUTE WS-ITEM-HEIGHT = ET-HEIGHT-MILLI(ET-LOOSE-ITEM + 1) / 1000
     IF PL-USED(L-PLAYER) = 1 AND PL-ENTITY-ROW(L-PLAYER) > 0 AND PL-STATE(L-PLAYER) = PS-ALIVE
             AND PL-DIM(L-PLAYER) = EN-DIM(L-ROW)
             AND FUNCTION ABS(EN-X(L-ROW) - PL-X(L-PLAYER)) <= WS-REACH-XZ + WS-EPSILON
             AND FUNCTION ABS(EN-Z(L-ROW) - PL-Z(L-PLAYER)) <= WS-REACH-XZ + WS-EPSILON
             AND EN-Y(L-ROW) + WS-ITEM-HEIGHT >= PL-Y(L-PLAYER) - WS-REACH-Y - WS-EPSILON
             AND EN-Y(L-ROW) <= PL-Y(L-PLAYER) + WS-HEIGHT + WS-REACH-Y + WS-EPSILON
         MOVE 1 TO L-IN
     END-IF
     GOBACK.
 END PROGRAM GI-IN-REACH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GI-PICKUP.
*> USING tracker row (BINARY-LONG) of a ground item whose pickup delay is 0: the pickup rules above.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-SHIFT               PIC 9.
 01 WS-LEFT                BINARY-LONG.
 01 WS-TAKEN               BINARY-LONG.
 01 WS-ANY                 PIC 9.
 01 WS-CANDIDATES.
    05 WS-CANDIDATE        BINARY-LONG OCCURS 64 TIMES.
 01 WS-BEFORE.
    05 WS-BEFORE-SLOT OCCURS 36 TIMES.
       10 WS-BEFORE-ITEM   BINARY-LONG.
       10 WS-BEFORE-COUNT  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE L-ROW TO WS-ROW
*>   The players in reach, in entering order (insertion by PL-ENTERED).
     MOVE 0 TO WS-N
     PERFORM VARYING WS-PLAYER FROM 1 BY 1 UNTIL WS-PLAYER > CORE-MAX-PLAYERS
         CALL "GI-IN-REACH" USING WS-PLAYER WS-ROW WS-IN
         IF WS-IN = 1
             ADD 1 TO WS-N
             MOVE WS-N TO WS-I
             MOVE 1 TO WS-SHIFT
             PERFORM UNTIL WS-SHIFT = 0
                 MOVE 0 TO WS-SHIFT
                 IF WS-I > 1
                     COMPUTE WS-J = WS-I - 1
                     IF PL-ENTERED(WS-CANDIDATE(WS-J)) > PL-ENTERED(WS-PLAYER)
                         MOVE WS-CANDIDATE(WS-J) TO WS-CANDIDATE(WS-I)
                         MOVE WS-J TO WS-I
                         MOVE 1 TO WS-SHIFT
                     END-IF
                 END-IF
             END-PERFORM
             MOVE WS-PLAYER TO WS-CANDIDATE(WS-I)
         END-IF
     END-PERFORM
     MOVE 0 TO WS-ANY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N OR EN-ITEM-COUNT(WS-ROW) = 0
         MOVE WS-CANDIDATE(WS-I) TO WS-PLAYER
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 36
             MOVE PL-SLOT(WS-PLAYER, WS-S) TO WS-BEFORE-SLOT(WS-S)
         END-PERFORM
         CALL "INV-ADD" USING WS-PLAYER EN-ITEM(WS-ROW) EN-ITEM-COUNT(WS-ROW) WS-LEFT
         COMPUTE WS-TAKEN = EN-ITEM-COUNT(WS-ROW) - WS-LEFT
         IF WS-TAKEN > 0
             MOVE 1 TO WS-ANY
             MOVE WS-LEFT TO EN-ITEM-COUNT(WS-ROW)
             CALL "PB-RESET" USING PB-BUFFER
             CALL "TAKE-ITEM-ENTITY-BUILD" USING EN-ID(WS-ROW) PL-ENTITY-ID(WS-PLAYER) WS-TAKEN
                 PB-BUFFER
             CALL "GI-VIEWERS-SEND" USING WS-ROW PB-BUFFER
             COMPUTE PL-STATE-ID(WS-PLAYER) = FUNCTION MOD(PL-STATE-ID(WS-PLAYER) + 1, 32768)
             PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 36
                 IF PL-SLOT(WS-PLAYER, WS-S) NOT = WS-BEFORE-SLOT(WS-S)
                     COMPUTE WS-SLOT = WS-S - 1
                     CALL "INV-SLOT-SEND" USING PL-CONN(WS-PLAYER) WS-SLOT
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     EVALUATE TRUE
         WHEN EN-ITEM-COUNT(WS-ROW) = 0
             CALL "ENTITY-REMOVE" USING WS-ROW
         WHEN WS-ANY = 1
             CALL "PB-RESET" USING PB-BUFFER
             CALL "SET-ENTITY-DATA-ITEM-BUILD" USING EN-ID(WS-ROW) EN-ITEM(WS-ROW)
                 EN-ITEM-COUNT(WS-ROW) PB-BUFFER
             CALL "GI-VIEWERS-SEND" USING WS-ROW PB-BUFFER
     END-EVALUATE
     GOBACK.
 END PROGRAM GI-PICKUP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GI-MOVE.
*> USING tracker row (BINARY-LONG) of a ground item: §9.2 step 3 (movement) as described above.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY ENTITYTYPES.
 COPY RULES.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 128.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-NEW                 FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-RESTING             BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-TYPE                BINARY-LONG VALUE ET-LOOSE-ITEM.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE L-ROW TO WS-ROW
     MOVE EN-DIM(WS-ROW) TO WS-DIM
     MOVE EN-X(WS-ROW) TO WS-X
     MOVE EN-Y(WS-ROW) TO WS-Y
     MOVE EN-Z(WS-ROW) TO WS-Z
     MOVE EN-VX(WS-ROW) TO WS-VX
     MOVE EN-VY(WS-ROW) TO WS-VY
     MOVE EN-VZ(WS-ROW) TO WS-VZ
     MOVE EN-ON-GROUND(WS-ROW) TO WS-RESTING
*>   3.1 Out of a block placed into the box.
     CALL "ENTITY-BOX-HITS" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-HIT WS-TOP
     IF WS-HIT = 1
         COMPUTE WS-Y = WS-TOP + 1
     END-IF
*>   3.2 A resting item falls again when the cell below is not solid.
     IF WS-RESTING = 1
         COMPUTE WS-BX = FUNCTION INTEGER(WS-X)
         COMPUTE WS-BY = FUNCTION INTEGER(WS-Y) - 1
         COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z)
         CALL "GI-SOLID-CELL" USING WS-DIM WS-BX WS-BY WS-BZ WS-SOLID
         IF WS-SOLID = 0
             MOVE 0 TO WS-RESTING
             MOVE 0 TO WS-VX WS-VY WS-VZ
         END-IF
     END-IF
*>   3.3 to 3.5 Gravity, the moves along Y, X and Z, drag.
     IF WS-RESTING = 0
         COMPUTE WS-VY = WS-VY - RULE-GI-GRAVITY-MILLI / 1000
         COMPUTE WS-NEW = WS-Y + WS-VY
         CALL "ENTITY-BOX-HITS" USING WS-DIM WS-TYPE WS-X WS-NEW WS-Z WS-HIT WS-TOP
         EVALUATE TRUE
             WHEN WS-HIT = 0
                 MOVE WS-NEW TO WS-Y
             WHEN WS-VY < 0
                 COMPUTE WS-Y = WS-TOP + 1
                 MOVE 1 TO WS-RESTING
             WHEN OTHER
                 MOVE 0 TO WS-VY
         END-EVALUATE
         COMPUTE WS-NEW = WS-X + WS-VX
         CALL "ENTITY-BOX-HITS" USING WS-DIM WS-TYPE WS-NEW WS-Y WS-Z WS-HIT WS-TOP
         IF WS-HIT = 0
             MOVE WS-NEW TO WS-X
         ELSE
             MOVE 0 TO WS-VX
         END-IF
         COMPUTE WS-NEW = WS-Z + WS-VZ
         CALL "ENTITY-BOX-HITS" USING WS-DIM WS-TYPE WS-X WS-Y WS-NEW WS-HIT WS-TOP
         IF WS-HIT = 0
             MOVE WS-NEW TO WS-Z
         ELSE
             MOVE 0 TO WS-VZ
         END-IF
         IF WS-RESTING = 1
             MOVE 0 TO WS-VX WS-VY WS-VZ
         ELSE
             COMPUTE WS-VX = WS-VX * RULE-GI-DRAG-MILLI / 1000
             COMPUTE WS-VY = WS-VY * RULE-GI-DRAG-MILLI / 1000
             COMPUTE WS-VZ = WS-VZ * RULE-GI-DRAG-MILLI / 1000
         END-IF
     END-IF
     MOVE WS-VX TO EN-VX(WS-ROW)
     MOVE WS-VY TO EN-VY(WS-ROW)
     MOVE WS-VZ TO EN-VZ(WS-ROW)
     MOVE WS-RESTING TO EN-ON-GROUND(WS-ROW)
     IF WS-X NOT = EN-X(WS-ROW) OR WS-Y NOT = EN-Y(WS-ROW) OR WS-Z NOT = EN-Z(WS-ROW)
         CALL "PB-RESET" USING PB-BUFFER
         CALL "TELEPORT-ENTITY-BUILD" USING EN-ID(WS-ROW) WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ
             WS-YAW WS-PITCH WS-RESTING PB-BUFFER
         CALL "GI-VIEWERS-SEND" USING WS-ROW PB-BUFFER
         MOVE WS-X TO EN-X(WS-ROW)
         MOVE WS-Y TO EN-Y(WS-ROW)
         MOVE WS-Z TO EN-Z(WS-ROW)
         CALL "ENTITY-TRACK" USING WS-ROW
     END-IF
     GOBACK.
 END PROGRAM GI-MOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GI-STEP.
*> USING tracker row (BINARY-LONG) of a ground item: the §9.2 steps for one tick, when its chunk is
*> loaded.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RULES.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CHUNK               BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-NEAR                PIC 9.
 01 WS-LIMIT               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE L-ROW TO WS-ROW
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(WS-ROW) / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(WS-ROW) / 16)
     CALL "WORLD-FIND" USING EN-DIM(WS-ROW) WS-CX WS-CZ WS-CHUNK
     IF WS-CHUNK = 0
         GOBACK
     END-IF
*>   1. Pickup delay.
     IF EN-DELAY(WS-ROW) > 0
         SUBTRACT 1 FROM EN-DELAY(WS-ROW)
     END-IF
*>   2. Age and despawn.
     COMPUTE WS-LIMIT = (RULE-GI-NEAR-MILLI / 1000) ** 2
     MOVE 0 TO WS-NEAR
     PERFORM VARYING WS-PLAYER FROM 1 BY 1 UNTIL WS-PLAYER > CORE-MAX-PLAYERS
         IF PL-USED(WS-PLAYER) = 1 AND PL-ENTITY-ROW(WS-PLAYER) > 0
                 AND PL-DIM(WS-PLAYER) = EN-DIM(WS-ROW)
                 AND (PL-X(WS-PLAYER) - EN-X(WS-ROW)) ** 2 + (PL-Y(WS-PLAYER) - EN-Y(WS-ROW)) ** 2
                     + (PL-Z(WS-PLAYER) - EN-Z(WS-ROW)) ** 2 <= WS-LIMIT
             MOVE 1 TO WS-NEAR
         END-IF
     END-PERFORM
     IF WS-NEAR = 1
         ADD 1 TO EN-AGE(WS-ROW)
     END-IF
     IF EN-AGE(WS-ROW) >= RULE-GI-DESPAWN-AGE
         CALL "ENTITY-REMOVE" USING WS-ROW
         GOBACK
     END-IF
*>   3. Movement; 4. pickup.
     CALL "GI-MOVE" USING WS-ROW
     IF EN-DELAY(WS-ROW) = 0
         CALL "GI-PICKUP" USING WS-ROW
     END-IF
     GOBACK.
 END PROGRAM GI-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GROUND-ITEMS-TICK.
*> No parameters; the last step of CORE-TICK (§9.5): GI-STEP for every ground item in ascending
*> entity id order (insertion by EN-ID into a list of tracker rows).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY ENTITYTYPES.
 01 WS-ROW                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-SHIFT               PIC 9.
 01 WS-ORDERS.
    05 WS-ORDER            BINARY-LONG OCCURS 1024 TIMES.
 PROCEDURE DIVISION.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-TYPE(WS-ROW) = ET-LOOSE-ITEM
             ADD 1 TO WS-N
             MOVE WS-N TO WS-I
             MOVE 1 TO WS-SHIFT
             PERFORM UNTIL WS-SHIFT = 0
                 MOVE 0 TO WS-SHIFT
                 IF WS-I > 1
                     COMPUTE WS-J = WS-I - 1
                     IF EN-ID(WS-ORDER(WS-J)) > EN-ID(WS-ROW)
                         MOVE WS-ORDER(WS-J) TO WS-ORDER(WS-I)
                         MOVE WS-J TO WS-I
                         MOVE 1 TO WS-SHIFT
                     END-IF
                 END-IF
             END-PERFORM
             MOVE WS-ROW TO WS-ORDER(WS-I)
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         CALL "GI-STEP" USING WS-ORDER(WS-I)
     END-PERFORM
     GOBACK.
 END PROGRAM GROUND-ITEMS-TICK.
