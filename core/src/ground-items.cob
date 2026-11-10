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
 COPY CITEMS.
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
*> row out (BINARY-LONG): GI-SPAWN-X of a stack without a patch (core/src/itemphys-41.cob).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NONE                BINARY-LONG VALUE 0.
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
     CALL "GI-SPAWN-X" USING L-DIM L-X L-Y L-Z L-VX L-VY L-VZ L-ITEM L-COUNT L-DELAY L-ROW WS-NONE
     GOBACK.
 END PROGRAM GI-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GI-BLOCK-YIELD.
*> USING dimension row, x, y, z (block position), block id (BINARY-LONG) of a block just broken in
*> survival: one item of the block's yield (RULES.cpy RULE-YIELD-ITEM, standin §1.3) through
*> Block.popResource (41 section 2.1: GI-POP-RESOURCE). Only breakable blocks reach here (BLOCK-ACTION
*> refuses void and the baseplate), and every breakable block has a yield.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY RULES.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-BLOCK.
     CALL "GI-POP-RESOURCE" USING L-DIM L-X L-Y L-Z RULE-YIELD-ITEM(L-BLOCK + 1) WS-ONE WS-NONE WS-ROW
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
 01 WS-VAR                 BINARY-LONG.
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
     MOVE PL-SLOT-VAR(WS-ROW, WS-SLOT + 1) TO WS-VAR
     CALL "INV-REMOVE" USING WS-ROW WS-SLOT WS-COUNT
     COMPUTE PL-STATE-ID(WS-ROW) = FUNCTION MOD(PL-STATE-ID(WS-ROW) + 1, 32768)
     CALL "INV-SLOT-SEND" USING L-ID WS-SLOT
     CALL "GI-THROW-STACK-X" USING WS-ROW WS-ITEM WS-COUNT WS-VAR
     GOBACK.
 END PROGRAM GI-THROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GI-THROW-STACK.
*> USING player row, item, count (BINARY-LONG): GI-THROW-STACK-X of a stack without a patch (41 section 2.3). The
*> caller has already taken the stack from the inventory or the cursor.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NONE                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ITEM L-COUNT.
     CALL "GI-THROW-STACK-X" USING L-ROW L-ITEM L-COUNT WS-NONE
     GOBACK.
 END PROGRAM GI-THROW-STACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GI-IN-REACH.
*> USING player row, tracker row (BINARY-LONG), in out (BINARY-LONG 1 or 0): 1 when the player may touch the item now (41 section
*> 4.1): alive, in the item's dimension, and the item box meets the player's box inflated by 1.0 horizontally and 0.5 vertically
*> (strict comparisons: boxes that only share a face do not intersect).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-REACH-XZ            FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-ITEM-HEIGHT         FLOAT-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-IN                   BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ROW L-IN.
     MOVE 0 TO L-IN
     COMPUTE WS-REACH-XZ = ET-WIDTH-MILLI(CR-OPERATOR + 1) / 2000 + 1 + ET-WIDTH-MILLI(CR-LOOSE-ITEM + 1) / 2000
     COMPUTE WS-HEIGHT = ET-HEIGHT-MILLI(CR-OPERATOR + 1) / 1000
     COMPUTE WS-ITEM-HEIGHT = ET-HEIGHT-MILLI(CR-LOOSE-ITEM + 1) / 1000
     IF PL-USED(L-PLAYER) = 1 AND PL-ENTITY-ROW(L-PLAYER) > 0 AND PL-STATE(L-PLAYER) = PS-ALIVE
             AND PL-DIM(L-PLAYER) = EN-DIM(L-ROW)
             AND FUNCTION ABS(EN-X(L-ROW) - PL-X(L-PLAYER)) < WS-REACH-XZ
             AND FUNCTION ABS(EN-Z(L-ROW) - PL-Z(L-PLAYER)) < WS-REACH-XZ
             AND EN-Y(L-ROW) + WS-ITEM-HEIGHT > PL-Y(L-PLAYER) - 0.5
             AND EN-Y(L-ROW) < PL-Y(L-PLAYER) + WS-HEIGHT + 0.5
         MOVE 1 TO L-IN
     END-IF
     GOBACK.
 END PROGRAM GI-IN-REACH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GI-PICKUP.
*> USING tracker row (BINARY-LONG) of a ground item whose pickup delay is 0: ItemEntity.playerTouch (41 section 4.2) for the
*> players in reach, in the order they entered the world (PL-ENTERED), while the entity lasts: a player who is not the owner
*> (when there is one) skips it; IP-INV-ADD moves the stack into the inventory (the patch handle with it). When add returns true
*> the viewers get Take Item Entity (collected id, collector id, the full count) before the slot updates, the entity is removed and item_picked_up is
*> awarded; a partial transfer (survival) sends no Take Item Entity, awards nothing and leaves the rest on the entity (its viewers
*> get Set Entity Data). The taker gets Container Set Slot for the slots that changed (state id raised once).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMPHYS.
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
 01 WS-BEFORE-COUNT        BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-CHANGED             PIC 9.
 01 WS-CANDIDATES.
    05 WS-CANDIDATE        BINARY-LONG OCCURS 64 TIMES.
 01 WS-BEFORE.
    05 WS-BEFORE-SLOT OCCURS 36 TIMES.
       10 WS-BEFORE-ITEM   BINARY-LONG.
       10 WS-BEFORE-N      BINARY-LONG.
       10 WS-BEFORE-VAR    BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "IP-ENSURE" USING L-ROW
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
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N OR EN-USED(WS-ROW) = 0
         MOVE WS-CANDIDATE(WS-I) TO WS-PLAYER
         IF IP-I-HAS-OWNER(WS-ROW) = 0 OR IP-I-OWNER(WS-ROW) = PL-UUID(WS-PLAYER)
             PERFORM TOUCH
         END-IF
     END-PERFORM
     GOBACK.

*> playerTouch of WS-PLAYER on the item WS-ROW.
 TOUCH.
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 36
         MOVE PL-SLOT-ITEM(WS-PLAYER, WS-S) TO WS-BEFORE-ITEM(WS-S)
         MOVE PL-SLOT-COUNT(WS-PLAYER, WS-S) TO WS-BEFORE-N(WS-S)
         MOVE PL-SLOT-VAR(WS-PLAYER, WS-S) TO WS-BEFORE-VAR(WS-S)
     END-PERFORM
     MOVE EN-ITEM-COUNT(WS-ROW) TO WS-BEFORE-COUNT
     MOVE WS-BEFORE-COUNT TO WS-LEFT
     CALL "IP-INV-ADD" USING WS-PLAYER EN-ITEM(WS-ROW) WS-LEFT IP-I-VAR(WS-ROW) WS-RESULT
     IF WS-RESULT = 1
         CALL "PB-RESET" USING PB-BUFFER
         CALL "TAKE-ITEM-ENTITY-BUILD" USING EN-ID(WS-ROW) PL-ENTITY-ID(WS-PLAYER) WS-BEFORE-COUNT PB-BUFFER
         CALL "GI-VIEWERS-SEND" USING WS-ROW PB-BUFFER
     END-IF
     MOVE 0 TO WS-CHANGED
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 36
         IF PL-SLOT-ITEM(WS-PLAYER, WS-S) NOT = WS-BEFORE-ITEM(WS-S) OR PL-SLOT-COUNT(WS-PLAYER, WS-S)
                 NOT = WS-BEFORE-N(WS-S) OR PL-SLOT-VAR(WS-PLAYER, WS-S) NOT = WS-BEFORE-VAR(WS-S)
             IF WS-CHANGED = 0
                 COMPUTE PL-STATE-ID(WS-PLAYER) = FUNCTION MOD(PL-STATE-ID(WS-PLAYER) + 1, 32768)
                 MOVE 1 TO WS-CHANGED
             END-IF
             COMPUTE WS-SLOT = WS-S - 1
             CALL "INV-SLOT-SEND" USING PL-CONN(WS-PLAYER) WS-SLOT
         END-IF
     END-PERFORM
     EVALUATE TRUE
         WHEN WS-RESULT = 1
             CALL "IP-STAT-ADD" USING WS-PLAYER IP-STAT-PICKED EN-ITEM(WS-ROW) WS-BEFORE-COUNT
             MOVE 0 TO EN-ITEM-COUNT(WS-ROW)
             CALL "ENTITY-REMOVE" USING WS-ROW
         WHEN WS-LEFT < WS-BEFORE-COUNT
             MOVE WS-LEFT TO EN-ITEM-COUNT(WS-ROW)
             CALL "PB-RESET" USING PB-BUFFER
             CALL "SET-ENTITY-DATA-ITEM-BUILD" USING EN-ID(WS-ROW) EN-ITEM(WS-ROW) EN-ITEM-COUNT(WS-ROW) PB-BUFFER
             CALL "GI-VIEWERS-SEND" USING WS-ROW PB-BUFFER
     END-EVALUATE.
 END PROGRAM GI-PICKUP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GI-SEND-MOVE.
*> USING tracker row, x, y, z (FLOAT-LONG, the position after the tick): when it differs from the position last sent the viewers get
*> Teleport Entity (position, current motion, the entity's angles, on-ground) and visibility follows (ENTITY-TRACK).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 128.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z.
     IF L-X NOT = EN-X(L-ROW) OR L-Y NOT = EN-Y(L-ROW) OR L-Z NOT = EN-Z(L-ROW)
         IF WS-READY = 0
             CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
             MOVE 1 TO WS-READY
         END-IF
         CALL "PB-RESET" USING PB-BUFFER
         CALL "TELEPORT-ENTITY-BUILD" USING EN-ID(L-ROW) L-X L-Y L-Z EN-VX(L-ROW) EN-VY(L-ROW) EN-VZ(L-ROW)
             EN-YAW(L-ROW) EN-PITCH(L-ROW) EN-ON-GROUND(L-ROW) PB-BUFFER
         CALL "GI-VIEWERS-SEND" USING L-ROW PB-BUFFER
         MOVE L-X TO EN-X(L-ROW)
         MOVE L-Y TO EN-Y(L-ROW)
         MOVE L-Z TO EN-Z(L-ROW)
         CALL "ENTITY-TRACK" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM GI-SEND-MOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GI-STEP.
*> USING tracker row (BINARY-LONG) of a ground item: when its chunk is loaded, the pickup attempt of the players (41 section 4) and
*> then ItemEntity.tick (41 section 3, steps 1 to 12).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMPHYS.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CHUNK               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-ALIVE               BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-PERIOD              BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(L-ROW) / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(L-ROW) / 16)
     CALL "WORLD-FIND" USING EN-DIM(L-ROW) WS-CX WS-CZ WS-CHUNK
     IF WS-CHUNK = 0
         GOBACK
     END-IF
     CALL "IP-ENSURE" USING L-ROW
     MOVE EN-ID(L-ROW) TO WS-ID
*>   A player's touch comes first in the tick (the players tick before the item, 4.1 and validation case 8).
     IF EN-DELAY(L-ROW) = 0 AND EN-ITEM-COUNT(L-ROW) > 0
         CALL "GI-PICKUP" USING L-ROW
         IF EN-USED(L-ROW) = 0 OR EN-ID(L-ROW) NOT = WS-ID
             GOBACK
         END-IF
     END-IF
*>   1. An empty stack is discarded.
     IF EN-ITEM-COUNT(L-ROW) = 0
         CALL "ENTITY-REMOVE" USING L-ROW
         GOBACK
     END-IF
*>   2. The base tick: the tick count and the fire rules.
     ADD 1 TO IP-I-TICKS(L-ROW)
     CALL "IP-FIRE-TICK" USING L-ROW WS-ALIVE
     IF WS-ALIVE = 0
         GOBACK
     END-IF
*>   3. The pickup delay.
     IF EN-DELAY(L-ROW) > 0 AND EN-DELAY(L-ROW) NOT = IP-NEVER-PICKUP
         SUBTRACT 1 FROM EN-DELAY(L-ROW)
     END-IF
*>   4 to 8. Forces, the move, friction; the viewers are told the new position.
     CALL "IP-ITEM-MOVE" USING L-ROW WS-CHANGED WS-X WS-Y WS-Z
     CALL "GI-SEND-MOVE" USING L-ROW WS-X WS-Y WS-Z
*>   9. Merging: every 2 ticks after a change of block cell, else every 40.
     MOVE 40 TO WS-PERIOD
     IF WS-CHANGED = 1
         MOVE 2 TO WS-PERIOD
     END-IF
     IF FUNCTION MOD(IP-I-TICKS(L-ROW), WS-PERIOD) = 0
         CALL "IP-MERGEABLE" USING L-ROW WS-OK
         IF WS-OK = 1
             CALL "IP-MERGE" USING L-ROW
         END-IF
         IF EN-USED(L-ROW) = 0 OR EN-ID(L-ROW) NOT = WS-ID
             GOBACK
         END-IF
     END-IF
*>   10. The age.
     IF EN-AGE(L-ROW) NOT = IP-INFINITE-LIFETIME
         ADD 1 TO EN-AGE(L-ROW)
     END-IF
*>   11. The fluids: heights, the water flag, the lava hurt.
     CALL "IP-FLUID-SCAN" USING L-ROW
     CALL "IP-LAVA-EFFECTS" USING L-ROW WS-ALIVE
     IF WS-ALIVE = 0
         GOBACK
     END-IF
*>   12. The lifetime.
     IF EN-AGE(L-ROW) >= IP-LIFETIME
         CALL "ENTITY-REMOVE" USING L-ROW
         GOBACK
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
 COPY CITEMS.
 COPY CITEMPHYS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-SHIFT               PIC 9.
 01 WS-ORDERS.
    05 WS-ORDER            BINARY-LONG OCCURS 1024 TIMES.
 PROCEDURE DIVISION.
*>   The creative drop throttles of the players fall by 1 per tick (41 section 2.3.1).
     PERFORM VARYING WS-PLAYER FROM 1 BY 1 UNTIL WS-PLAYER > CORE-MAX-PLAYERS
         IF IP-P-THROTTLE(WS-PLAYER) > 0
             SUBTRACT 1 FROM IP-P-THROTTLE(WS-PLAYER)
         END-IF
     END-PERFORM
     MOVE 0 TO WS-N
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-TYPE(WS-ROW) = CR-LOOSE-ITEM
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
