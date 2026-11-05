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
*> Use Item On (BLOCK-USE-ON; main hand only, the off hand does nothing): on a goto_pad nothing is
*> placed whatever is held (travel is US12); with a held block item (ITEMS.cpy IT-PLACES-STATE) the
*> block is placed in the position next to the clicked face (face 0 down, 1 up, 2 north, 3 south,
*> 4 west, 5 east) in its default state, a cardstack with the axis of the face (up/down y,
*> north/south z, west/east x; punched false); otherwise a glowtube toggles lit, and anything else
*> does nothing. A placement is refused, with Block Update of the target's real state to the player
*> when the target is in the height range, when the target is not void, lies outside the dimension's
*> height range or would overlap a player's box (standin §3, the movement.cob rule: positive volume,
*> 1e-7 tolerance). In survival a placed block uses up one item of the held stack (Container Set
*> Slot echo, the state id raised); creative uses nothing up (FR-007).
*>
*> Player Action (BLOCK-ACTION; actions 0, 2, 3; the others belong to later phases and are not
*> answered here). Creative: START breaks at once (no item appears, FR-007). Survival: START records
*> the break (position, start tick, the number of ticks it takes: the §1.1 hand break time, divided
*> by 4 when the held item is the tool of the block's class (§2), at 50 ms per tick rounded down);
*> STOP breaks the block when the same position has been broken for at least that many ticks, and
*> otherwise leaves it (Block Update of the real state to the player); ABORT ends the break. A block
*> without a break time (void, and the baseplate, which nobody may break) is never broken: Block
*> Update of its real state to the player. Each answered action and every Use Item On end with Block
*> Changed Ack of their sequence. A survival break leaves the block's item on the ground
*> (GI-BLOCK-YIELD, core/src/ground-items.cob; standin §1.3) and adds 0.025 exhaustion to the
*> breaker (HUNGER-EXHAUST, standin §11.2); a creative break leaves nothing.
*>
*> Break progress (BLOCKS-TICK, every tick): while a survival break lasts, the other players who see
*> the block get Block Destruction (the breaker's entity id, the position, stage = elapsed ticks x 10
*> / break ticks, at most 9) whenever the stage changes; when the break ends (abort, finish, early
*> stop, a new start) after a stage was sent they get stage 255, outside 0 to 9, which removes the
*> overlay (05a 0x05).
*>
*> Entry points:
*>   BLOCK-USE-ON USING connection id, PLAY-SERVERBOUND        Use Item On
*>   BLOCK-ACTION USING connection id, PLAY-SERVERBOUND        Player Action
*>   BLOCKS-TICK                                               break progress (CORE-TICK)
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
*> USING dimension row, x, y, z, state (BINARY-LONG): Block Update to the viewers of the block's
*> chunk, then the block is set and its light changes are sent (LIGHT-SET-BLOCK).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     COMPUTE WS-CX = (L-X - FUNCTION MOD(L-X, 16)) / 16
     COMPUTE WS-CZ = (L-Z - FUNCTION MOD(L-Z, 16)) / 16
     CALL "PB-RESET" USING PB-BUFFER
     CALL "BLOCK-UPDATE-BUILD" USING L-X L-Y L-Z L-STATE PB-BUFFER
     CALL "VIEWERS-SEND" USING L-DIM WS-CX WS-CZ WS-NONE PB-BUFFER
     CALL "LIGHT-SET-BLOCK" USING L-DIM L-X L-Y L-Z L-STATE
     GOBACK.
 END PROGRAM BLOCK-CHANGE.

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
 PROGRAM-ID. BLOCK-OVERLAPS-PLAYER.
*> USING dimension row, x, y, z (BINARY-LONG block position), hit out (BINARY-LONG 1 or 0): 1 when
*> the cell overlaps the box of a player in that dimension with positive volume (standin §3 player
*> box; faces within 1e-7 of each other only touch).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY ENTITYTYPES.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-HALF                FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-EPSILON             FLOAT-LONG VALUE 0.0000001.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-HIT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-HIT.
     MOVE 0 TO L-HIT
     COMPUTE WS-HALF = ET-WIDTH-MILLI(ET-OPERATOR + 1) / 2000
     COMPUTE WS-HEIGHT = ET-HEIGHT-MILLI(ET-OPERATOR + 1) / 1000
     PERFORM VARYING WS-PLAYER FROM 1 BY 1 UNTIL WS-PLAYER > CORE-MAX-PLAYERS
         IF PL-USED(WS-PLAYER) = 1 AND PL-DIM(WS-PLAYER) = L-DIM
                 AND L-X < PL-X(WS-PLAYER) + WS-HALF - WS-EPSILON
                 AND L-X + 1 > PL-X(WS-PLAYER) - WS-HALF + WS-EPSILON
                 AND L-Y < PL-Y(WS-PLAYER) + WS-HEIGHT - WS-EPSILON
                 AND L-Y + 1 > PL-Y(WS-PLAYER) + WS-EPSILON
                 AND L-Z < PL-Z(WS-PLAYER) + WS-HALF - WS-EPSILON
                 AND L-Z + 1 > PL-Z(WS-PLAYER) - WS-HALF + WS-EPSILON
             MOVE 1 TO L-HIT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BLOCK-OVERLAPS-PLAYER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCK-PLACE.
*> USING connection id, PLAY-SERVERBOUND (Use Item On), placed state (BINARY-LONG, the held item's
*> IT-PLACES-STATE), placed out (BINARY-LONG 1 when the block was placed): the placement rules above.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BLOCKS.
 COPY DIMENSIONS.
 01 WS-OFFSETS.
    05 FILLER PIC X(18) VALUE "101121110112011211".
 01 WS-OFFSET-TABLE REDEFINES WS-OFFSETS.
    05 WS-OFFSET OCCURS 6 TIMES.
       10 WS-OFF-X         PIC 9.
       10 WS-OFF-Y         PIC 9.
       10 WS-OFF-Z         PIC 9.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 01 L-PLACED-STATE         BINARY-LONG.
 01 L-PLACED               BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND L-PLACED-STATE L-PLACED.
     MOVE 0 TO L-PLACED
     MOVE PL-DIM(CN-PLAYER(L-ID)) TO WS-DIM
*>   Face offsets, each digit minus 1: down (0,-1,0), up (0,1,0), north (0,0,-1), south (0,0,1),
*>   west (-1,0,0), east (1,0,0).
     COMPUTE WS-X = PSB-BX + WS-OFF-X(PSB-FACE + 1) - 1
     COMPUTE WS-Y = PSB-BY + WS-OFF-Y(PSB-FACE + 1) - 1
     COMPUTE WS-Z = PSB-BZ + WS-OFF-Z(PSB-FACE + 1) - 1
     MOVE L-PLACED-STATE TO WS-STATE
     IF SB-BLOCK(WS-STATE + 1) = BLK-CARDSTACK
         EVALUATE PSB-FACE
             WHEN 0 THRU 1
                 MOVE ST-CARDSTACK-Y TO WS-STATE
             WHEN 2 THRU 3
                 MOVE ST-CARDSTACK-Z TO WS-STATE
             WHEN OTHER
                 MOVE ST-CARDSTACK-X TO WS-STATE
         END-EVALUATE
     END-IF
     IF WS-Y < DM-MIN-Y(WS-DIM) OR WS-Y >= DM-MIN-Y(WS-DIM) + DM-HEIGHT(WS-DIM)
         GOBACK
     END-IF
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-OLD
     MOVE 1 TO WS-HIT
     IF WS-OLD = ST-VOID
         CALL "BLOCK-OVERLAPS-PLAYER" USING WS-DIM WS-X WS-Y WS-Z WS-HIT
     END-IF
     IF WS-HIT = 1
         CALL "BLOCK-TELL" USING L-ID WS-X WS-Y WS-Z
         GOBACK
     END-IF
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
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
 COPY BLOCKS.
 COPY ITEMS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-PLACES              BINARY-LONG.
 01 WS-PLACED              BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
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
     EVALUATE TRUE
         WHEN PSB-HAND NOT = 0 OR SB-BLOCK(WS-STATE + 1) = BLK-GOTO-PAD
             CONTINUE
         WHEN WS-PLACES >= 0
             CALL "BLOCK-PLACE" USING L-ID PLAY-SERVERBOUND WS-PLACES WS-PLACED
         WHEN SB-BLOCK(WS-STATE + 1) = BLK-GLOWTUBE
             COMPUTE WS-STATE = ST-GLOWTUBE-LIT + ST-GLOWTUBE-UNLIT - WS-STATE
             CALL "BLOCK-CHANGE" USING WS-DIM PSB-BX PSB-BY PSB-BZ WS-STATE
     END-EVALUATE
     CALL "BLOCK-ACK" USING L-ID PSB-SEQUENCE
     IF WS-PLACED = 1 AND PL-MODE(WS-ROW) = 0
         CALL "INV-REMOVE" USING WS-ROW WS-HELD WS-ONE
         COMPUTE PL-STATE-ID(WS-ROW) = FUNCTION MOD(PL-STATE-ID(WS-ROW) + 1, 32768)
         CALL "INV-SLOT-SEND" USING L-ID WS-HELD
     END-IF
     GOBACK.
 END PROGRAM BLOCK-USE-ON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCK-BREAK-END.
*> USING player row (BINARY-LONG): ends the player's survival break, if any; when a stage was sent,
*> the viewers get stage 255 (overlay removed).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-CLEAR               BINARY-LONG VALUE 255.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE L-ROW TO WS-ROW
     IF PL-BREAKING(WS-ROW) = 1 AND PL-BREAK-STAGE(WS-ROW) >= 0
         COMPUTE WS-CX = (PL-BREAK-X(WS-ROW) - FUNCTION MOD(PL-BREAK-X(WS-ROW), 16)) / 16
         COMPUTE WS-CZ = (PL-BREAK-Z(WS-ROW) - FUNCTION MOD(PL-BREAK-Z(WS-ROW), 16)) / 16
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "BLOCK-DESTRUCTION-BUILD" USING PL-ENTITY-ID(WS-ROW) PL-BREAK-X(WS-ROW)
             PL-BREAK-Y(WS-ROW) PL-BREAK-Z(WS-ROW) WS-CLEAR PB-BUFFER
         CALL "VIEWERS-SEND" USING PL-DIM(WS-ROW) WS-CX WS-CZ WS-ROW PB-BUFFER
         CALL "PB-FREE" USING PB-BUFFER
     END-IF
     MOVE 0 TO PL-BREAKING(WS-ROW)
     MOVE -1 TO PL-BREAK-STAGE(WS-ROW)
     GOBACK.
 END PROGRAM BLOCK-BREAK-END.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCK-ACTION.
*> USING connection id, PLAY-SERVERBOUND (a decoded Player Action): the break rules above.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RULES.
 COPY BLOCKS.
 COPY ITEMS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-MS                  BINARY-LONG.
 01 WS-VOID                BINARY-LONG VALUE 0.
 01 WS-EXHAUST             FLOAT-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND.
     IF PSB-ACTION NOT = 0 AND PSB-ACTION NOT = 2 AND PSB-ACTION NOT = 3
         GOBACK
     END-IF
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-DIM
     CALL "WORLD-GET-BLOCK" USING WS-DIM PSB-BX PSB-BY PSB-BZ WS-STATE
     COMPUTE WS-BLOCK = SB-BLOCK(WS-STATE + 1) + 1
     EVALUATE TRUE
         WHEN PSB-ACTION = 2
             CALL "BLOCK-BREAK-END" USING WS-ROW
         WHEN BL-BREAK-MS(WS-BLOCK) <= 0
             CALL "BLOCK-TELL" USING L-ID PSB-BX PSB-BY PSB-BZ
         WHEN PSB-ACTION = 0 AND PL-MODE(WS-ROW) = 1
             CALL "BLOCK-CHANGE" USING WS-DIM PSB-BX PSB-BY PSB-BZ WS-VOID
         WHEN PSB-ACTION = 0
             CALL "BLOCK-BREAK-END" USING WS-ROW
             MOVE BL-BREAK-MS(WS-BLOCK) TO WS-MS
             MOVE 0 TO WS-ITEM
             IF PL-SLOT-COUNT(WS-ROW, PL-HELD(WS-ROW) + 1) > 0
                 MOVE PL-SLOT-ITEM(WS-ROW, PL-HELD(WS-ROW) + 1) TO WS-ITEM
             END-IF
             IF BL-CLASS(WS-BLOCK) NOT = BLOCK-CLASS-NONE
                     AND IT-TOOL-CLASS(WS-ITEM + 1) = BL-CLASS(WS-BLOCK)
                 COMPUTE WS-MS = WS-MS / TOOL-BREAK-DIVISOR
             END-IF
             MOVE 1 TO PL-BREAKING(WS-ROW)
             MOVE PSB-BX TO PL-BREAK-X(WS-ROW)
             MOVE PSB-BY TO PL-BREAK-Y(WS-ROW)
             MOVE PSB-BZ TO PL-BREAK-Z(WS-ROW)
             MOVE CW-TICKS TO PL-BREAK-START(WS-ROW)
             COMPUTE PL-BREAK-TICKS(WS-ROW) = WS-MS / CORE-TICK-MS
             MOVE -1 TO PL-BREAK-STAGE(WS-ROW)
         WHEN PL-MODE(WS-ROW) = 0 AND PL-BREAKING(WS-ROW) = 1 AND PSB-BX = PL-BREAK-X(WS-ROW)
                 AND PSB-BY = PL-BREAK-Y(WS-ROW) AND PSB-BZ = PL-BREAK-Z(WS-ROW)
                 AND CW-TICKS - PL-BREAK-START(WS-ROW) >= PL-BREAK-TICKS(WS-ROW)
             CALL "BLOCK-BREAK-END" USING WS-ROW
             CALL "BLOCK-CHANGE" USING WS-DIM PSB-BX PSB-BY PSB-BZ WS-VOID
             COMPUTE WS-BLOCK = WS-BLOCK - 1
             CALL "GI-BLOCK-YIELD" USING WS-DIM PSB-BX PSB-BY PSB-BZ WS-BLOCK
             COMPUTE WS-EXHAUST = RULE-EXHAUST-BREAK-MILLI / 1000
             CALL "HUNGER-EXHAUST" USING WS-ROW WS-EXHAUST
         WHEN OTHER
             CALL "BLOCK-BREAK-END" USING WS-ROW
             CALL "BLOCK-TELL" USING L-ID PSB-BX PSB-BY PSB-BZ
     END-EVALUATE
     CALL "BLOCK-ACK" USING L-ID PSB-SEQUENCE
     GOBACK.
 END PROGRAM BLOCK-ACTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCKS-TICK.
*> No parameters; called once per tick after CW-TICKS is raised: break progress (above).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-STAGE               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-PLAYER FROM 1 BY 1 UNTIL WS-PLAYER > CORE-MAX-PLAYERS
         IF PL-USED(WS-PLAYER) = 1 AND PL-BREAKING(WS-PLAYER) = 1
                 AND PL-BREAK-TICKS(WS-PLAYER) > 0
             COMPUTE WS-STAGE = FUNCTION MIN(9, (CW-TICKS - PL-BREAK-START(WS-PLAYER)) * 10
                 / PL-BREAK-TICKS(WS-PLAYER))
             IF WS-STAGE NOT = PL-BREAK-STAGE(WS-PLAYER)
                 IF WS-READY = 0
                     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
                     MOVE 1 TO WS-READY
                 END-IF
                 MOVE WS-STAGE TO PL-BREAK-STAGE(WS-PLAYER)
                 COMPUTE WS-CX = (PL-BREAK-X(WS-PLAYER)
                     - FUNCTION MOD(PL-BREAK-X(WS-PLAYER), 16)) / 16
                 COMPUTE WS-CZ = (PL-BREAK-Z(WS-PLAYER)
                     - FUNCTION MOD(PL-BREAK-Z(WS-PLAYER), 16)) / 16
                 CALL "PB-RESET" USING PB-BUFFER
                 CALL "BLOCK-DESTRUCTION-BUILD" USING PL-ENTITY-ID(WS-PLAYER)
                     PL-BREAK-X(WS-PLAYER) PL-BREAK-Y(WS-PLAYER) PL-BREAK-Z(WS-PLAYER)
                     WS-STAGE PB-BUFFER
                 CALL "VIEWERS-SEND" USING PL-DIM(WS-PLAYER) WS-CX WS-CZ WS-PLAYER PB-BUFFER
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BLOCKS-TICK.

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
