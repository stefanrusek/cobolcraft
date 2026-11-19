*> Placing, breaking and toggling blocks (US4; standin-content §1.1 to §1.3, §2; data-model §3;
*> docs/protocol/09-cobolcraft-profile.md §3.2 rows 0x04, 0x05, 0x08, 0x29, 0x42, 0x56; 05a, 05b,
*> 05c).
*>
*> Every change goes through BLOCK-CHANGE: Block Update to every player in the dimension whose view
*> square (Chebyshev distance <= the configured view distance from its chunk cache center) holds the
*> block's chunk, the acting player included, then the block is set and the changed light is sent
*> (LIGHT-SET-BLOCK, core/src/light.cob). Changes are applied in arrival order, so two changes to one
*> block leave every viewer with the last one (US4 edge case).
*>
*> Use Item On (BLOCK-USE-ON): on a goto_pad, with either hand, nothing is placed whatever is held
*> and, after the Block Changed Ack, travel starts (DIM-USE-PAD, core/src/dimensions.cob); on a crafting bench
*> block, with either hand, nothing is placed whatever is held and, after the Ack, the bench menu opens
*> (MENU-BENCH-OPEN, core/src/menu-bench.cob); otherwise
*> the main hand only (the off hand does nothing): with a held block item (ITEMS.cpy IT-PLACES-STATE) the
*> block is placed in the position next to the clicked face (face 0 down, 1 up, 2 north, 3 south,
*> 4 west, 5 east) in its default state, a cardstack with the axis of the face (up/down y,
*> north/south z, west/east x; punched false); otherwise a glowtube toggles lit, and anything else
*> does nothing. A placement is refused, with Block Update of the target's real state to the player
*> when the target is in the height range, when the target is neither void nor replaceable (tag minecraft:replaceable), lies outside the dimension's
*> height range or its state's collision shape would overlap the box of a player or a mob (standin §3, the movement.cob rule:
*> positive volume, 1e-7 tolerance; a block with no collision shape, such as a torch, never does: 29 section 9.6). In survival a placed block uses up one item of the held stack (Container Set
*> Slot echo, the state id raised); creative uses nothing up (FR-007).
*>
*> Player Action, the break progress (BLOCK-ACTION, BLOCKS-TICK, BLOCK-BREAK-END) and the stage broadcast are
*> in core/src/breaking.cob (13 section 2).
*>
*> Entry points:
*>   BLOCK-USE-ON USING connection id, PLAY-SERVERBOUND        Use Item On
*>   BLOCK-CHANGE USING dim, x, y, z, state                    set a block, tell the viewers
*>   VIEWERS-SEND USING dim, chunk x, chunk z, except player row (0 none), PB-BUFFER
*> Builders (append id + body to the caller's PB-BUFFER):
*>   BLOCK-UPDATE-BUILD USING x, y, z, state, PB-BUFFER
*>   BLOCK-ACK-BUILD USING sequence, PB-BUFFER
*>   BLOCK-DESTRUCTION-BUILD USING entity id, x, y, z, stage, PB-BUFFER
*>   SECTION-BLOCKS-UPDATE-BUILD USING section x, y, z, count, entries, PB-BUFFER

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCK-UPDATE-BUILD.
*> USING x, y, z, state (BINARY-LONG), PB-BUFFER: Block Update 0x08 (05a: Position, VarInt state).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 8.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-STATE PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-POSITION" USING PB-BUFFER L-X L-Y L-Z
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-STATE
     GOBACK.
 END PROGRAM BLOCK-UPDATE-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCK-ACK-BUILD.
*> USING sequence (BINARY-LONG), PB-BUFFER: Block Changed Ack 0x04 (05a: VarInt sequence).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 4.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-SEQUENCE             BINARY-LONG.
 PROCEDURE DIVISION USING L-SEQUENCE PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-SEQUENCE
     GOBACK.
 END PROGRAM BLOCK-ACK-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCK-DESTRUCTION-BUILD.
*> USING breaker entity id, x, y, z, stage (BINARY-LONG), PB-BUFFER: Block Destruction 0x05 (05a:
*> VarInt breaker id, Position, UByte progress).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 5.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ENTITY-ID            BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STAGE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY-ID L-X L-Y L-Z L-STAGE PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ENTITY-ID
     CALL "PB-PUT-POSITION" USING PB-BUFFER L-X L-Y L-Z
     CALL "PB-PUT-UBYTE" USING PB-BUFFER L-STAGE
     GOBACK.
 END PROGRAM BLOCK-DESTRUCTION-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VIEWERS-SEND.
*> USING dimension row, chunk x, chunk z, except player row (0 = none), PB-BUFFER (BINARY-LONG
*> each): sends the packet to every player whose join has been sent, in that dimension, whose view
*> square holds the chunk, except the given player.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-PLAYER              BINARY-LONG.
 LINKAGE SECTION.
 COPY COREAPI.
 COPY PROTO.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-EXCEPT               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ L-EXCEPT PB-BUFFER.
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
     PERFORM VARYING WS-PLAYER FROM 1 BY 1 UNTIL WS-PLAYER > CORE-MAX-PLAYERS
         IF PL-USED(WS-PLAYER) = 1 AND PL-ENTITY-ROW(WS-PLAYER) > 0
                 AND PL-DIM(WS-PLAYER) = L-DIM AND WS-PLAYER NOT = L-EXCEPT
                 AND FUNCTION ABS(L-CX - PL-CENTER-X(WS-PLAYER)) <= CS-VIEW-DISTANCE
                 AND FUNCTION ABS(L-CZ - PL-CENTER-Z(WS-PLAYER)) <= CS-VIEW-DISTANCE
             CALL "CORE-SEND" USING PL-CONN(WS-PLAYER) PB-BUFFER
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM VIEWERS-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCK-CHANGE.
*> USING dimension row, x, y, z, state (BINARY-LONG): Level.setBlock with flags 3 (LEVEL-SET-BLOCK, 29 section 2): the block is written, its light
*> changes are sent at once (LIGHT-SET-BLOCK), the neighbours are told, and the position joins the tick's change set (BC-MARK, flag 2). The Block
*> Update (or the Section Blocks Update of several changes in one section) reaches the viewers when the tick broadcasts its changes (BC-BROADCAST,
*> 29 section 7.2; WORLDSIM-TICK and WORLDSIM-FLUSH), not here.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE.
     CALL "WORLDSIM-ENSURE"
     CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z L-STATE WS-FLAGS WS-BUDGET WS-RESULT
     GOBACK.
 END PROGRAM BLOCK-CHANGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCK-ACK-QUEUE.
*> USING connection id, sequence (BINARY-LONG): ackBlockChangesUpTo (29 section 7.3): the highest sequence of the tick is kept (BC-ACK-SET); the
*> Block Changed Ack is sent at the start of the connection's next tick (BC-ACK-TICK, WORLDSIM-ACKS).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ACCEPTED            BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-SEQUENCE             BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-SEQUENCE.
     CALL "BC-ACK-SET" USING L-ID L-SEQUENCE WS-ACCEPTED
     GOBACK.
 END PROGRAM BLOCK-ACK-QUEUE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCK-TELL.
*> USING connection id, x, y, z (BINARY-LONG): Block Update of the real state of that block of the
*> player's dimension to that connection only (a refused change).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-X L-Y L-Z.
     CALL "WORLD-GET-BLOCK" USING PL-DIM(CN-PLAYER(L-ID)) L-X L-Y L-Z WS-STATE
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "BLOCK-UPDATE-BUILD" USING L-X L-Y L-Z WS-STATE PB-BUFFER
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM BLOCK-TELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCK-ACK.
*> USING connection id, sequence (BINARY-LONG): Block Changed Ack to that connection.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 16.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-SEQUENCE             BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-SEQUENCE.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "BLOCK-ACK-BUILD" USING L-SEQUENCE PB-BUFFER
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM BLOCK-ACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCK-OVERLAPS-BODY.
*> USING dimension row, x, y, z (BINARY-LONG block position), state (BINARY-LONG, the block state that would be placed there), hit out (BINARY-LONG 1 or 0): 1 when the
*> collision shape of the state, moved to the cell, overlaps with positive volume the box of a blocking entity in that dimension (29 section 9.6, Level.isUnobstructed:
*> the shape is empty = nothing obstructs; the entities are the players that are not spectators, and the mobs, stand-in and standard, all living entities; item entities
*> and the like never block; standin §3 sizes; faces within 1e-7 of each other only touch). The shape is the state's collision shape (BSH-COLL, 51-block-shapes; a full cube
*> or the void in the cobolcraft stand-in set, as MOVE-COLLIDES-BOX reads it), so a torch, sign, ladder, button, lever, flower or rail never obstructs and a full block, slab,
*> stair, fence or carpet obstructs when its boxes meet the entity's.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY CBLOCKS.
 COPY CONTENT.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-STD                 BINARY-LONG.
 01 WS-BLK                 BINARY-LONG.
 01 WS-SHAPE               BINARY-LONG.
 01 WS-ONE                 BINARY-LONG.
 01 WS-HALF                FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-BOX.
    05 WS-B                FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-HIT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-HIT.
     MOVE 0 TO L-HIT
*>   The collision shape of the state (the cobolcraft stand-in set has no shapes: its blocks are full cubes or empty by CB-SOLID, as in movement.cob).
     IF CT-SET-TYPE = CT-TYPE-COBOLCRAFT
         MOVE CB-S-BLOCK(L-STATE + 1) TO WS-BLK
         MOVE CB-SOLID(WS-BLK + 1) TO WS-SHAPE
         IF WS-SHAPE = 1
             CALL "BSH-ENSURE-CUBE"
         END-IF
     ELSE
         CALL "BSH-COLL-ID" USING L-STATE WS-SHAPE
     END-IF
     IF WS-SHAPE = 0
         GOBACK
     END-IF
     COMPUTE WS-HALF = ET-WIDTH-MILLI(CR-OPERATOR + 1) / 2000
     COMPUTE WS-HEIGHT = ET-HEIGHT-MILLI(CR-OPERATOR + 1) / 1000
     PERFORM VARYING WS-PLAYER FROM 1 BY 1 UNTIL WS-PLAYER > CORE-MAX-PLAYERS
         IF PL-USED(WS-PLAYER) = 1 AND PL-DIM(WS-PLAYER) = L-DIM AND PL-MODE(WS-PLAYER) NOT = 3
             COMPUTE WS-B(1) = PL-X(WS-PLAYER) - WS-HALF
             MOVE PL-Y(WS-PLAYER) TO WS-B(2)
             COMPUTE WS-B(3) = PL-Z(WS-PLAYER) - WS-HALF
             COMPUTE WS-B(4) = PL-X(WS-PLAYER) + WS-HALF
             COMPUTE WS-B(5) = PL-Y(WS-PLAYER) + WS-HEIGHT
             COMPUTE WS-B(6) = PL-Z(WS-PLAYER) + WS-HALF
             CALL "BSH-OVERLAPS" USING WS-SHAPE L-X L-Y L-Z WS-BOX WS-ONE
             IF WS-ONE = 1
                 MOVE 1 TO L-HIT
             END-IF
         END-IF
     END-PERFORM
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         MOVE 0 TO WS-M
         MOVE 0 TO WS-STD
         IF EN-USED(WS-E) = 1
             CALL "MOB-INDEX" USING EN-TYPE(WS-E) WS-M
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-E) WS-STD
         END-IF
         IF (WS-M > 0 OR WS-STD > 0) AND EN-DIM(WS-E) = L-DIM
             COMPUTE WS-HALF = ET-WIDTH-MILLI(EN-TYPE(WS-E) + 1) / 2000
             COMPUTE WS-HEIGHT = ET-HEIGHT-MILLI(EN-TYPE(WS-E) + 1) / 1000
             COMPUTE WS-B(1) = EN-X(WS-E) - WS-HALF
             MOVE EN-Y(WS-E) TO WS-B(2)
             COMPUTE WS-B(3) = EN-Z(WS-E) - WS-HALF
             COMPUTE WS-B(4) = EN-X(WS-E) + WS-HALF
             COMPUTE WS-B(5) = EN-Y(WS-E) + WS-HEIGHT
             COMPUTE WS-B(6) = EN-Z(WS-E) + WS-HALF
             CALL "BSH-OVERLAPS" USING WS-SHAPE L-X L-Y L-Z WS-BOX WS-ONE
             IF WS-ONE = 1
                 MOVE 1 TO L-HIT
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BLOCK-OVERLAPS-BODY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCK-PLACE.
*> USING connection id, PLAY-SERVERBOUND (Use Item On), placed state (BINARY-LONG, the held item's
*> IT-PLACES-STATE), placed out (BINARY-LONG 1 when the block was placed): the placement rules above.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY DIMENSIONS.
 COPY PLACECTX.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-REGISTRY            PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:replaceable".
 01 WS-BLOCK               BINARY-LONG.
 01 WS-REPLACEABLE         BINARY-LONG.
 01 WS-FITS                BINARY-LONG.
 01 WS-FOUND-STATE         BINARY-LONG.
 01 WS-OLD-FLUID           BINARY-LONG.
 01 WS-OLD-KIND            BINARY-LONG.
 01 WS-OLD-AMOUNT          BINARY-LONG.
 01 WS-OLD-FALLING         BINARY-LONG.
 01 WS-WL-NAME             PIC X(24) VALUE "waterlogged".
 01 WS-WL-TEXT             PIC X(32).
 01 WS-WL-MODE             BINARY-LONG VALUE 2.
 01 WS-STACKED             BINARY-LONG.
 01 WS-MERGES              BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 01 L-PLACED-STATE         BINARY-LONG.
 01 L-PLACED               BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND L-PLACED-STATE L-PLACED.
     MOVE 0 TO L-PLACED
     MOVE PL-DIM(CN-PLAYER(L-ID)) TO WS-DIM
*>   A segmented block (petals, wildflowers, leaf litter) clicked with its own item gains a segment instead (segment-place.cob).
     CALL "SEG-STACK" USING L-ID PLAY-SERVERBOUND L-PLACED-STATE WS-STACKED
     IF WS-STACKED = 1
         MOVE 1 TO L-PLACED
         GOBACK
     END-IF
     MOVE L-PLACED-STATE TO WS-STATE
     IF CB-S-BLOCK(WS-STATE + 1) = CR-CARDSTACK
         EVALUATE PSB-FACE
             WHEN 0 THRU 1
                 MOVE CR-CARDSTACK-Y TO WS-STATE
             WHEN 2 THRU 3
                 MOVE CR-CARDSTACK-Z TO WS-STATE
             WHEN OTHER
                 MOVE CR-CARDSTACK-X TO WS-STATE
         END-EVALUATE
     END-IF
     CALL "SEG-FACING" USING L-ID WS-STATE
*>   The placement context: the cell the block goes to (the clicked cell when the item replaces the clicked block, else the cell on the clicked face), the click and the player's view (place-state.cob).
     CALL "PLACE-CONTEXT-BUILD" USING L-ID PLAY-SERVERBOUND WS-STATE PLACE-CONTEXT
     MOVE PC-X TO WS-X
     MOVE PC-Y TO WS-Y
     MOVE PC-Z TO WS-Z
     IF WS-Y < DM-MIN-Y(WS-DIM) OR WS-Y >= DM-MIN-Y(WS-DIM) + DM-HEIGHT(WS-DIM)
         GOBACK
     END-IF
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-OLD
     MOVE 1 TO WS-HIT
*>   A target in the block tag minecraft:replaceable (water, lava, grass, snow; 29 section 9.5) is replaced like the void.
     MOVE 0 TO WS-REPLACEABLE
     IF WS-OLD > 0
         MOVE CB-S-BLOCK(WS-OLD + 1) TO WS-BLOCK
         CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG WS-BLOCK WS-REPLACEABLE
     END-IF
     IF WS-OLD = 0 OR WS-REPLACEABLE = 1
         MOVE 0 TO WS-HIT
     END-IF
*>   A slab onto a slab that is not double and a multiface block onto one with a free face add to the block that is there.
     CALL "PS-MERGES" USING PLACE-CONTEXT WS-OLD WS-MERGES
     IF WS-MERGES = 1
         MOVE 0 TO WS-HIT
     END-IF
     IF WS-HIT = 1
         CALL "BLOCK-TELL" USING L-ID WS-X WS-Y WS-Z
         GOBACK
     END-IF
*>   The state the block takes from the click and the player's view (place-state.cob: standing-and-wall items, attached blocks, pillars, slabs, stairs, doors and the facing blocks); nothing fits: nothing is placed.
     CALL "PLACE-STATE" USING PLACE-CONTEXT
     IF PC-FITS = 0
         CALL "BLOCK-TELL" USING L-ID WS-X WS-Y WS-Z
         GOBACK
     END-IF
     MOVE PC-STATE TO WS-STATE
*>   A door or tall plant needs its upper half's cell (empty or replaceable) too, and places both halves.
     CALL "DOUBLE-PLACE-FITS" USING WS-DIM WS-X WS-Y WS-Z WS-STATE WS-FITS
*>   BlockItem.canPlace: the block must survive where it is placed (a plant on its ground, kelp and seagrass in a water source only; support-29.cob).
     IF WS-FITS = 1
         CALL "SUP-PLACE-OK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE WS-FITS
     END-IF
     IF WS-FITS = 0
         CALL "BLOCK-TELL" USING L-ID WS-X WS-Y WS-Z
         GOBACK
     END-IF
*>   BlockItem.canPlace, second half: the state's collision shape must not meet a blocking entity (29 section 9.6, isUnobstructed with the placement context): a torch, sign,
*>   ladder, button, lever, flower or rail goes into the cell the player's body is in, a full block, slab, stair, fence or carpet does not.
     CALL "BLOCK-OVERLAPS-BODY" USING WS-DIM WS-X WS-Y WS-Z WS-STATE WS-HIT
     IF WS-HIT = 1
         CALL "BLOCK-TELL" USING L-ID WS-X WS-Y WS-Z
         GOBACK
     END-IF
*>   A block with the waterlogged property placed into a water source is waterlogged, and in anything else it is not (29a 5.1: FluidState.is(WATER), a source only).
     MOVE 0 TO WS-OLD-KIND
     IF WS-OLD > 0
         CALL "FLUID-OF-STATE" USING WS-OLD WS-OLD-FLUID WS-OLD-KIND WS-OLD-AMOUNT WS-OLD-FALLING
     END-IF
     MOVE "false" TO WS-WL-TEXT
     IF WS-OLD-KIND = 2
         MOVE "true" TO WS-WL-TEXT
     END-IF
     CALL "BLOCK-STATE-PROP" USING WS-WL-MODE WS-STATE WS-WL-NAME WS-WL-TEXT WS-FOUND-STATE
     MOVE WS-FOUND-STATE TO WS-STATE
     CALL "BE-PLACE-STATE" USING L-ID PLAY-SERVERBOUND WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "DOUBLE-PLACE-UPPER" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "GOLEM-BUILD" USING WS-DIM WS-X WS-Y WS-Z
     CALL "WITHER-BUILD" USING WS-DIM WS-X WS-Y WS-Z
     MOVE 1 TO L-PLACED
     GOBACK.
 END PROGRAM BLOCK-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCK-USE-ON.
*> USING connection id, PLAY-SERVERBOUND (a decoded Use Item On): the use rules above, then Block
*> Changed Ack, then (survival placement) the used-up held slot.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY CITEMS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-PLACES              BINARY-LONG.
 01 WS-PLACED              BINARY-LONG.
 01 WS-TRAVEL              BINARY-LONG.
 01 WS-BENCH               BINARY-LONG.
 01 WS-STATION             BINARY-LONG.
 01 WS-BED                 BINARY-LONG.
 01 WS-BONE                BINARY-LONG.
 01 WS-BONE-USED           BINARY-LONG.
 01 WS-EYE                 BINARY-LONG.
 01 WS-DECOR               BINARY-LONG.
 01 WS-CONT                BINARY-LONG.
 01 WS-SHELF               BINARY-LONG.
 01 WS-OPENED              BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TOOL                BINARY-LONG.
 01 WS-SWITCH              BINARY-LONG.
 01 WS-KNOT                BINARY-LONG.
 01 WS-NOTE                BINARY-LONG.
 01 WS-ROCKET              BINARY-LONG.
 01 WS-BELL                BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND.
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-DIM
     MOVE 0 TO WS-PLACED
     MOVE PL-HELD(WS-ROW) TO WS-HELD
     MOVE 0 TO WS-ITEM
     IF PL-SLOT-COUNT(WS-ROW, WS-HELD + 1) > 0
         MOVE PL-SLOT-ITEM(WS-ROW, WS-HELD + 1) TO WS-ITEM
     END-IF
     MOVE IT-PLACES-STATE(WS-ITEM + 1) TO WS-PLACES
     CALL "WORLD-GET-BLOCK" USING WS-DIM PSB-BX PSB-BY PSB-BZ WS-STATE
     MOVE 0 TO WS-TRAVEL
     CALL "MENU-IS-BENCH" USING WS-STATE WS-BENCH
     CALL "WORLDSIM-BED-KEY" USING WS-STATE WS-BED
*>   An axe, shovel or hoe changes the block it is used on (17 section 3.1; tools-wire.cob).
     MOVE 0 TO WS-TOOL
     IF WS-ITEM > 0 AND WS-BENCH = 0 AND WS-BED = 0
         CALL "TOOLUSE-ON" USING L-ID PLAY-SERVERBOUND WS-TOOL
     END-IF
     CALL "GB-HELD-BONEMEAL" USING WS-ITEM WS-BONE
     MOVE 0 TO WS-BONE-USED
     CALL "MENU-IS-CONT" USING WS-STATE WS-CONT
     CALL "MENU-STATION-KIND" USING WS-STATE WS-STATION
     CALL "END-EYE-USE" USING L-ID WS-STATE WS-ITEM PSB-BX PSB-BY PSB-BZ WS-EYE
     CALL "DECOR-ITEM-USE" USING L-ID PLAY-SERVERBOUND WS-ITEM WS-DECOR
     MOVE 0 TO WS-SHELF
*>   A sneaking player holding an item uses the item on the block (places it) instead of using the block (31-1 section 10.2).
     IF PL-SNEAKING(WS-ROW) = 1 AND WS-ITEM > 0
         MOVE 0 TO WS-CONT WS-STATION
     ELSE
         CALL "BE2-SHELF-USE" USING L-ID PLAY-SERVERBOUND WS-STATE WS-SHELF
     END-IF
*>   A lever, button, door, trapdoor or fence gate takes the click (core/src/use-switch.cob).
     CALL "SW-USE" USING L-ID PLAY-SERVERBOUND WS-SWITCH
*>   A fence takes the lead of the player's mobs (a leash knot, 24 section 6.3).
     CALL "MOB-FENCE-USE" USING WS-ROW WS-STATE PSB-BX PSB-BY PSB-BZ WS-KNOT
*>   A note block is tuned by a right click (M44-NOTE-USE).
     MOVE 0 TO WS-NOTE
     IF NOT (PL-SNEAKING(WS-ROW) = 1 AND WS-ITEM > 0)
         CALL "M44-NOTE-USE" USING WS-ROW WS-STATE PSB-BX PSB-BY PSB-BZ PSB-FACE WS-NOTE
     END-IF
*>   A bell rings when it is hit as 31-4 section 4.5 says (core/src/bell-use.cob).
     CALL "BELL-USE" USING WS-ROW WS-STATE PSB-BX PSB-BY PSB-BZ PSB-FACE PSB-CURSOR-Y WS-BELL
     EVALUATE TRUE
         WHEN WS-KNOT = 1
             CONTINUE
         WHEN WS-NOTE = 1
             CONTINUE
         WHEN WS-BELL = 1
             CONTINUE
         WHEN WS-TOOL = 1
             CONTINUE
         WHEN WS-SWITCH = 1
             CONTINUE
         WHEN WS-EYE = 1
             CONTINUE
         WHEN WS-DECOR = 1
             CONTINUE
         WHEN CB-S-BLOCK(WS-STATE + 1) = CR-GOTO-PAD
             MOVE 1 TO WS-TRAVEL
         WHEN WS-BENCH = 1
             CONTINUE
         WHEN WS-STATION > 0
             CONTINUE
         WHEN WS-BED = 1
             CONTINUE
         WHEN WS-CONT > 0
             CONTINUE
         WHEN WS-SHELF = 1
             CONTINUE
         WHEN PSB-HAND NOT = 0
             CONTINUE
         WHEN WS-ITEM > 0 AND IT-KEY(WS-ITEM + 1) = "firework_rocket"
             CALL "RANGED-ROCKET-ON" USING L-ID PLAY-SERVERBOUND WS-ROCKET
         WHEN WS-BONE = 1
             CALL "GB-BONEMEAL-USE" USING L-ID PSB-BX PSB-BY PSB-BZ WS-BONE-USED
         WHEN WS-PLACES >= 0
             CALL "BLOCK-PLACE" USING L-ID PLAY-SERVERBOUND WS-PLACES WS-PLACED
         WHEN CB-S-BLOCK(WS-STATE + 1) = CR-GLOWTUBE
             COMPUTE WS-STATE = CR-GLOWTUBE-LIT + CR-GLOWTUBE-UNLIT - WS-STATE
             CALL "BLOCK-CHANGE" USING WS-DIM PSB-BX PSB-BY PSB-BZ WS-STATE
     END-EVALUATE
     CALL "BLOCK-ACK-QUEUE" USING L-ID PSB-SEQUENCE
     IF WS-TRAVEL = 1
         CALL "DIM-USE-PAD" USING L-ID PSB-BX PSB-BY PSB-BZ
     END-IF
     IF WS-BENCH = 1
         CALL "MENU-BENCH-OPEN" USING L-ID PSB-BX PSB-BY PSB-BZ
     END-IF
     IF WS-STATION > 0
         CALL "MENU-STATION-OPEN" USING L-ID PSB-BX PSB-BY PSB-BZ WS-STATION
     END-IF
     IF WS-BED = 1 AND PSB-HAND = 0
         CALL "WORLDSIM-SLEEP-USE" USING L-ID PSB-BX PSB-BY PSB-BZ
     END-IF
     IF WS-CONT > 0
         CALL "MENU-CONT-OPEN" USING L-ID PSB-BX PSB-BY PSB-BZ WS-OPENED
     END-IF
     IF WS-PLACED = 1 AND PL-MODE(WS-ROW) = 0
         CALL "INV-REMOVE" USING WS-ROW WS-HELD WS-ONE
         COMPUTE PL-STATE-ID(WS-ROW) = FUNCTION MOD(PL-STATE-ID(WS-ROW) + 1, 32768)
         CALL "INV-SLOT-SEND" USING L-ID WS-HELD
     END-IF
     GOBACK.
 END PROGRAM BLOCK-USE-ON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SECTION-BLOCKS-UPDATE-BUILD.
*> USING section x, section y, section z, count (BINARY-LONG), entries (a caller table of count
*> entries of four BINARY-LONG: local x, local y, local z 0 to 15 and the block state), PB-BUFFER:
*> Section Blocks Update 0x56 (05b): SectionPos Long (x in bits 42 to 63, z in bits 20 to 41, y in
*> bits 0 to 19), VarInt count, one VarLong (state << 12 | x << 8 | z << 4 | y) per entry.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 86.
 01 WS-TWO-42              BINARY-DOUBLE VALUE 4398046511104.
 01 WS-TWO-22              BINARY-DOUBLE VALUE 4194304.
 01 WS-TWO-20              BINARY-DOUBLE VALUE 1048576.
 01 WS-POS                 BINARY-DOUBLE.
 01 WS-ENTRY               BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 01 B-ENTRIES BASED.
    05 B-ENTRY OCCURS 4096 TIMES.
       10 B-X              BINARY-LONG.
       10 B-Y              BINARY-LONG.
       10 B-Z              BINARY-LONG.
       10 B-STATE          BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-SX                   BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-ENTRIES              PIC X.
 PROCEDURE DIVISION USING L-SX L-SY L-SZ L-COUNT L-ENTRIES PB-BUFFER.
     SET ADDRESS OF B-ENTRIES TO ADDRESS OF L-ENTRIES
     COMPUTE WS-POS = L-SX * WS-TWO-42 + FUNCTION MOD(L-SZ, WS-TWO-22) * WS-TWO-20
         + FUNCTION MOD(L-SY, WS-TWO-20)
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-LONG" USING PB-BUFFER WS-POS
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
         COMPUTE WS-ENTRY = B-STATE(WS-I) * 4096 + B-X(WS-I) * 256 + B-Z(WS-I) * 16 + B-Y(WS-I)
         CALL "PB-PUT-VARLONG" USING PB-BUFFER WS-ENTRY
     END-PERFORM
     GOBACK.
 END PROGRAM SECTION-BLOCKS-UPDATE-BUILD.
