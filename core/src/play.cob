*> Play phase: the join sequence and the serverbound packets of the join (docs/protocol/05a, 05b,
*> 05c; 09 §3.2, §4).
*>
*> Join sequence (PLAY-JOIN, called by config-phase on the client's Finish Configuration). The
*> order is the 09 §3.2 "Join sequence" paragraph:
*>   1. Login (0x32), then Commands (0x10, the tree the player may use, CMD-TREE-SEND,
*>      core/src/commands.cob) and Recipe Book Settings and Add (0x4D, 0x4B, RECBOOK-JOIN, core/src/recipe-unlock.cob)
*>   2. Player Abilities (0x41) of the player's game mode
*>   3. Set Held Slot (0x6B)
*>   4. Container Set Content (0x12) of container 0, the 36 slots (09 §3.2 numbering), the state id
*>      raised by one first (as every send of the container's content does)
*>   5. PLAY-ARRIVE, the part of the sequence a respawn repeats (core/src/health.cob):
*>      Set Health (0x6A, survival players only, 09 §3.3), Set Default Spawn Position (0x63),
*>      Set Time (0x73), the weather pair of the player's dimension (WEATHER-SEND, Game Event
*>      1 or 2, 7, 8; core/src/weather.cob), Game Event 13 LEVEL_CHUNKS_LOAD_START (0x27)
*>      before the first chunk batch,
*>      CHUNKS-INITIAL-BATCH (Set Chunk Cache Center, Chunk Batch Start, the chunks, Chunk Batch
*>      Finished), Player Position (0x49) with the next teleport id of the connection (counting up
*>      from 1)
*>   6. OTHERS-JOIN: Player Info Update for every player in the world, the player's entity for the
*>      others and Add Entity for the other players it sees (09 §3.2, US3-5)
*>   7. A player who left while dead (PL-DEATH-CAUSE > 0) is sent Player Combat Kill again, which
*>      shows the death screen (standin §10.6, HEALTH-DEATH-SCREEN)
*> 09 places Player Position after the chunk batches; the tasks text (T404) lists it before the
*> batch, but 09 is the protocol authority and the client relies only on: Login first, Game Event 13
*> before the first batch, chunks only inside a batch.
*>
*> Serverbound (PLAY-PACKET): Accept Teleportation with the awaited id marks the teleport accepted
*> (another id is ignored, as 05c's server does); Chunk Batch Received acknowledges one batch;
*> Player Loaded makes the player Alive, or Dead when it joined dead (PL-DEATH-CAUSE > 0); Client
*> Tick End needs nothing yet; Client Information
*> stores the view distance; Keep Alive goes to CORE-KEEPALIVE-ANSWER; Move Player 0x1E to 0x21 go
*> to MOVE-PLAYER and Player Abilities to MOVE-ABILITIES (core/src/movement.cob); Player Action 4
*> and 5 (throws) go to GI-THROW (core/src/ground-items.cob), the other actions to BLOCK-ACTION, and
*> Use Item On to BLOCK-USE-ON (core/src/blocks.cob); Set Carried Item, Container
*> Click, Container Close and Set Creative Mode Slot go to INV-HELD, INV-CLICK, INV-CLOSE and
*> INV-CREATIVE-SET (core/src/inventory.cob); Attack goes to HEALTH-ATTACK and Client Command to HEALTH-RESPAWN
*> (core/src/health.cob); Player Command goes to MOVE-SPRINT (core/src/movement.cob), Use Item to
*> HUNGER-USE-ITEM and Player Action 6 RELEASE_USE_ITEM to HUNGER-CANCEL (core/src/hunger.cob) and 7 SWAP_ITEM_WITH_OFFHAND to MENU-OFFHAND-SWAP (core/src/menu-inventory.cob);
*> Place Recipe goes to RECIPE-PLACE (core/src/recipe-unlock.cob); Chat Command goes to CMD-RUN-PACKET and
*> Command Suggestion to CMD-SUGGEST (core/src/commands.cob). After every packet CRAFT-REFRESH-ALL
*> re-sends the recipe book to each player whose inventory the packet changed.
*> A Cookie Response is
*> unsolicited: Disconnect multiplayer.disconnect.unexpected_query_response (09 §4, 02). Resource
*> Pack Response (0x32) is in the 09 §3 inventory but means nothing in play (a pack is offered only
*> during configuration, config-phase.cob), so it is discarded unread; any other packet id this
*> module does not decode, a malformed packet or one with bytes left over closes the connection
*> (09 §4, 01 §5: CORE-BAD-PACKET).
*>
*> Entry points:
*>   PLAY-JOIN USING connection id
*>   PLAY-PACKET USING connection id, packet id, PB-BUFFER (PB-POS after the id)
*>   PLAY-DECODE USING packet id, PB-BUFFER (PB-POS after the id), PLAY-SERVERBOUND
*>     (core/copy/PLAYPKT.cpy), outcome out (0 decoded, 1 malformed or bytes left over, 2 not a
*>     packet this module decodes)
*>   PLAY-ARRIVE USING connection id         the arrival part of the join sequence (step 5)
*> Builders (append id + body to the caller's PB-BUFFER):
*>   PLAY-LOGIN-BUILD USING player row, PB-BUFFER
*>   PLAY-SPAWN-INFO-BUILD USING dimension row, game mode (PIC 9), PB-BUFFER (no packet id)
*>   PLAY-RESPAWN-BUILD USING dimension row, game mode (PIC 9), data to keep, PB-BUFFER
*>   PLAY-ABILITIES-BUILD USING game mode, flying (PIC 9 each), PB-BUFFER
*>   PLAY-HELD-SLOT-BUILD USING slot, PB-BUFFER
*>   PLAY-CONTENT-BUILD USING player row, PB-BUFFER
*>   PLAY-INVENTORY-SLOT-BUILD USING slot, PB-ITEMSTACK, PB-BUFFER
*>   PLAY-SPAWN-POSITION-BUILD USING PB-BUFFER
*>   PLAY-TIME-BUILD USING time (BINARY-DOUBLE), PB-BUFFER
*>   PLAY-GAME-EVENT-BUILD USING event, value (FLOAT-SHORT), PB-BUFFER
*>   PLAY-POSITION-BUILD USING teleport id, x, y, z (FLOAT-LONG), yaw, pitch (FLOAT-SHORT), PB-BUFFER
*>   PLAYER-INFO-UPDATE-BUILD USING player row, PB-BUFFER
*>   PLAYER-INFO-REMOVE-BUILD USING UUID (PIC X(16)), PB-BUFFER
*> Other players (US3-5):
*>   OTHERS-JOIN USING connection id         end of the join sequence
*>   OTHERS-LEAVE USING player row           the player leaves the world (PLAYER-LEAVE)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAY-JOIN.
*> USING connection id of a connection that has just entered play with its player (CN-PLAYER):
*> sends the join sequence above, then queues the console line "<name> joined" (operator-surface
*> §3, US13-3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-ROW                 BINARY-LONG.
 01 WS-LINE                PIC X(32).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID.
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PLAY-LOGIN-BUILD" USING WS-ROW PB-BUFFER
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     CALL "CMD-TREE-SEND" USING WS-ROW
     CALL "RECBOOK-JOIN" USING WS-ROW
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-ABILITIES-BUILD" USING PL-MODE(WS-ROW) PL-FLYING(WS-ROW) PB-BUFFER
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-HELD-SLOT-BUILD" USING PL-HELD(WS-ROW) PB-BUFFER
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     CALL "PB-RESET" USING PB-BUFFER
     COMPUTE PL-STATE-ID(WS-ROW) = FUNCTION MOD(PL-STATE-ID(WS-ROW) + 1, 32768)
     CALL "PLAY-CONTENT-BUILD" USING WS-ROW PB-BUFFER
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PLAY-ARRIVE" USING L-ID
     CALL "OTHERS-JOIN" USING L-ID
     IF PL-DEATH-CAUSE(WS-ROW) > 0
         CALL "HEALTH-DEATH-SCREEN" USING WS-ROW
     END-IF
     MOVE SPACES TO WS-LINE
     STRING PL-NAME(WS-ROW)(1:PL-NAME-LENGTH(WS-ROW)) " joined" DELIMITED BY SIZE INTO WS-LINE
     COMPUTE WS-LENGTH = PL-NAME-LENGTH(WS-ROW) + 7
     CALL "CORE-LOG" USING WS-LINE WS-LENGTH
     GOBACK.
 END PROGRAM PLAY-JOIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAY-ARRIVE.
*> USING connection id of a connection in play with its player: the arrival part of the join
*> sequence (step 5 above), sent on joining and after a respawn.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-ROW                 BINARY-LONG.
 01 WS-EVENT               BINARY-LONG VALUE 13.
 01 WS-VALUE               FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID.
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     IF PL-MODE(WS-ROW) = 0
         CALL "HEALTH-SEND" USING WS-ROW
     END-IF
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PLAY-SPAWN-POSITION-BUILD" USING PB-BUFFER
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-TIME-BUILD" USING CW-TIME PB-BUFFER
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     CALL "WEATHER-SEND" USING WS-ROW
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-GAME-EVENT-BUILD" USING WS-EVENT WS-VALUE PB-BUFFER
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     CALL "CHUNKS-INITIAL-BATCH" USING L-ID
     ADD 1 TO CN-TELEPORT-ID(L-ID)
     MOVE 0 TO CN-TELEPORT-ACKED(L-ID)
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-POSITION-BUILD" USING CN-TELEPORT-ID(L-ID) PL-X(WS-ROW) PL-Y(WS-ROW)
         PL-Z(WS-ROW) PL-YAW(WS-ROW) PL-PITCH(WS-ROW) PB-BUFFER
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM PLAY-ARRIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAY-PACKET.
*> USING connection id, packet id, PB-BUFFER: one serverbound play packet (see above).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PLAYPKT.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-WORN                BINARY-LONG.
*> Serverbound play ids 0 to 68 (05c): "1" where the packet is in the 09 §3 inventory and is
*> discarded unread in play (0x32 Resource Pack Response).
 01 WS-LATER               PIC X(69) VALUE
     "000000000000000000000000000000000000000000000000001000000000000000000".
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ID                   BINARY-LONG.
 01 L-PACKET-ID            BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-PACKET-ID PB-BUFFER.
     IF L-PACKET-ID = 21
         INITIALIZE PK-TEXT
         MOVE PK-TEXT-TRANSLATE TO PK-TX-KIND
         MOVE "multiplayer.disconnect.unexpected_query_response" TO PK-TX-VALUE
         MOVE 48 TO PK-TX-LENGTH
         CALL "CORE-SEND-DISCONNECT" USING L-ID PK-TEXT
         GOBACK
     END-IF
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     CALL "PLAY-DECODE" USING L-PACKET-ID PB-BUFFER PLAY-SERVERBOUND WS-OUTCOME
     EVALUATE TRUE
         WHEN WS-OUTCOME = 1
             CALL "CORE-BAD-PACKET" USING L-ID
         WHEN WS-OUTCOME = 2
             IF L-PACKET-ID < 0 OR L-PACKET-ID > 68
                 CALL "CORE-BAD-PACKET" USING L-ID
             ELSE
                 IF WS-LATER(L-PACKET-ID + 1:1) NOT = "1"
                     CALL "CORE-BAD-PACKET" USING L-ID
                 END-IF
             END-IF
         WHEN L-PACKET-ID = 0
             IF PSB-TELEPORT-ID = CN-TELEPORT-ID(L-ID)
                 MOVE 1 TO CN-TELEPORT-ACKED(L-ID)
             END-IF
         WHEN L-PACKET-ID = 11
             IF PL-BATCH-PENDING(WS-ROW) > 0
                 SUBTRACT 1 FROM PL-BATCH-PENDING(WS-ROW)
             END-IF
         WHEN L-PACKET-ID = 14
             MOVE PSB-VIEW-DISTANCE TO PL-VIEW-DISTANCE(WS-ROW)
         WHEN L-PACKET-ID = 28
             CALL "CORE-KEEPALIVE-ANSWER" USING L-ID PSB-KEEPALIVE
         WHEN L-PACKET-ID = 44
             MOVE PS-ALIVE TO PL-STATE(WS-ROW)
             IF PL-DEATH-CAUSE(WS-ROW) > 0
                 MOVE PS-DEAD TO PL-STATE(WS-ROW)
             END-IF
         WHEN L-PACKET-ID = 40
             CALL "MOVE-ABILITIES" USING L-ID PSB-FLAGS
         WHEN L-PACKET-ID >= 30 AND L-PACKET-ID <= 33
             CALL "MOVE-PLAYER" USING L-ID L-PACKET-ID PLAY-SERVERBOUND
         WHEN L-PACKET-ID = 41 AND (PSB-ACTION = 4 OR PSB-ACTION = 5)
             CALL "GI-THROW" USING L-ID PLAY-SERVERBOUND
         WHEN L-PACKET-ID = 41 AND PSB-ACTION = 6
             CALL "HUNGER-CANCEL" USING WS-ROW
         WHEN L-PACKET-ID = 41 AND PSB-ACTION = 7
             CALL "MENU-OFFHAND-SWAP" USING L-ID
         WHEN L-PACKET-ID = 41
             CALL "BLOCK-ACTION" USING L-ID PLAY-SERVERBOUND
         WHEN L-PACKET-ID = 66
             CALL "BLOCK-USE-ON" USING L-ID PLAY-SERVERBOUND
         WHEN L-PACKET-ID = 54
             CALL "INV-HELD" USING L-ID PSB-SLOT
         WHEN L-PACKET-ID = 18
             CALL "INV-CLICK" USING L-ID PLAY-SERVERBOUND
         WHEN L-PACKET-ID = 19
             CALL "INV-CLOSE" USING L-ID PLAY-SERVERBOUND
         WHEN L-PACKET-ID = 57
             CALL "INV-CREATIVE-SET" USING L-ID PLAY-SERVERBOUND
         WHEN L-PACKET-ID = 9
             CALL "CHAT-MESSAGE" USING L-ID PLAY-SERVERBOUND
         WHEN L-PACKET-ID = 1
             CALL "HEALTH-ATTACK" USING L-ID PLAY-SERVERBOUND
         WHEN L-PACKET-ID = 12
             CALL "HEALTH-RESPAWN" USING L-ID PLAY-SERVERBOUND
         WHEN L-PACKET-ID = 42
             CALL "MOVE-SPRINT" USING L-ID PLAY-SERVERBOUND
         WHEN L-PACKET-ID = 67
             CALL "TOOLUSE-ITEM" USING L-ID WS-WORN
             IF WS-WORN = 0
                 CALL "HUNGER-USE-ITEM" USING L-ID PLAY-SERVERBOUND
             END-IF
         WHEN L-PACKET-ID = 39
             CALL "RECIPE-PLACE" USING L-ID PLAY-SERVERBOUND
         WHEN L-PACKET-ID = 47
             CALL "RECIPE-SETTINGS" USING L-ID PLAY-SERVERBOUND
         WHEN L-PACKET-ID = 48
             CALL "RECIPE-SEEN" USING L-ID PLAY-SERVERBOUND
         WHEN L-PACKET-ID = 15
             CALL "CMD-SUGGEST" USING L-ID PLAY-SERVERBOUND
         WHEN L-PACKET-ID = 7
             CALL "CMD-RUN-PACKET" USING L-ID PLAY-SERVERBOUND
     END-EVALUATE
     CALL "CRAFT-REFRESH-ALL"
     GOBACK.
 END PROGRAM PLAY-PACKET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAY-DECODE.
*> USING packet id, PB-BUFFER (PB-POS after the id), PLAY-SERVERBOUND out, outcome out: decodes the
*> serverbound play packets of the join (05c field tables): Accept Teleportation 0x00 (VarInt, three
*> Doubles, two Floats), Chunk Batch Received 0x0B (Float), Client Tick End 0x0D (no fields),
*> Client Information 0x0E (the 03 layout, through CONFIG-DECODE), Keep Alive 0x1C (Long), Player
*> Loaded 0x2C (no fields); Move Player Pos 0x1E (three Doubles, UByte flags), Pos Rot 0x1F (three
*> Doubles, two Floats, UByte), Rot 0x20 (two Floats, UByte), Status Only 0x21 (UByte), Player
*> Abilities 0x28 (Byte); Player Action 0x29 (VarInt action, Position, UByte face, VarInt sequence);
*> Use Item On 0x42 (VarInt hand, Position, VarInt face, three Floats, two Booleans, VarInt
*> sequence); Set Carried Item 0x36 (Short); Container Click 0x12 (VarInt container, VarInt state id,
*> Short slot, Byte button, VarInt click type, a map of at most 128 Short slots to HashedStacks, the
*> carried HashedStack); Container Close 0x13 (VarInt container); Set Creative Mode Slot 0x39 (Short,
*> ItemStack). A HashedStack is a Boolean
*> present, then VarInt item, VarInt count and the component counts (00 §12.4); CobolCraft items
*> carry no data components (standin §2), so a stack with any is malformed, as for an ItemStack.
*> Chat 0x09 (String of at most 256 code units, Long timestamp, Long salt, Optional MessageSignature
*> of 256 raw bytes, LastSeenMessagesUpdate: VarInt offset, FixedBitSet(20), Byte checksum); the
*> signature and the last seen messages are not checked (09 §1: secure chat is not enforced).
*> Attack 0x01 (VarInt entity id); Client Command 0x0C (VarInt action); Player Command 0x2A (VarInt
*> entity id, VarInt action, VarInt data); Use Item 0x43 (VarInt hand, VarInt sequence, two Floats);
*> Place Recipe 0x27 (VarInt container id, VarInt recipe display id, Boolean use max items).
*> Outcome 1 when a read fails or bytes are left over.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONFIGPKT.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WK-==.
 01 WS-CONFIG-ID           BINARY-LONG VALUE 0.
 01 WS-CONFIG-OUTCOME      BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-MAX-MESSAGE         BINARY-LONG VALUE 256.
 01 WS-MAX-COMMAND         BINARY-LONG VALUE 32767.
 01 WS-MAX-SUGGESTION      BINARY-LONG VALUE 32500.
 01 WS-MESSAGE-CAPACITY    BINARY-LONG VALUE 768.
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-PRESENT             BINARY-LONG.
 01 WS-SIGNATURE-BYTES     BINARY-LONG VALUE 256.
 01 WS-SEEN-BITS           BINARY-LONG VALUE 20.
 01 WS-SEEN                PIC X(3).
 LINKAGE SECTION.
 COPY PROTO.
 COPY PLAYPKT.
 01 L-PACKET-ID            BINARY-LONG.
 01 L-OUTCOME              BINARY-LONG.
 PROCEDURE DIVISION USING L-PACKET-ID PB-BUFFER PLAY-SERVERBOUND L-OUTCOME.
     INITIALIZE PLAY-SERVERBOUND
     MOVE 0 TO L-OUTCOME
     EVALUATE L-PACKET-ID
         WHEN 0
             CALL "PB-GET-VARINT" USING PB-BUFFER PSB-TELEPORT-ID
             CALL "PB-GET-DOUBLE" USING PB-BUFFER PSB-X
             CALL "PB-GET-DOUBLE" USING PB-BUFFER PSB-Y
             CALL "PB-GET-DOUBLE" USING PB-BUFFER PSB-Z
             CALL "PB-GET-FLOAT" USING PB-BUFFER PSB-YAW
             CALL "PB-GET-FLOAT" USING PB-BUFFER PSB-PITCH
         WHEN 11
             CALL "PB-GET-FLOAT" USING PB-BUFFER PSB-CHUNK-RATE
         WHEN 13
             CONTINUE
         WHEN 14
             CALL "CONFIG-DECODE" USING WS-CONFIG-ID PB-BUFFER CONFIG-SERVERBOUND
                 WS-CONFIG-OUTCOME
             MOVE CSB-VIEW-DISTANCE TO PSB-VIEW-DISTANCE
         WHEN 28
             CALL "PB-GET-LONG" USING PB-BUFFER PSB-KEEPALIVE
         WHEN 44
             CONTINUE
         WHEN 30
             CALL "PB-GET-DOUBLE" USING PB-BUFFER PSB-X
             CALL "PB-GET-DOUBLE" USING PB-BUFFER PSB-Y
             CALL "PB-GET-DOUBLE" USING PB-BUFFER PSB-Z
             CALL "PB-GET-UBYTE" USING PB-BUFFER PSB-FLAGS
         WHEN 31
             CALL "PB-GET-DOUBLE" USING PB-BUFFER PSB-X
             CALL "PB-GET-DOUBLE" USING PB-BUFFER PSB-Y
             CALL "PB-GET-DOUBLE" USING PB-BUFFER PSB-Z
             CALL "PB-GET-FLOAT" USING PB-BUFFER PSB-YAW
             CALL "PB-GET-FLOAT" USING PB-BUFFER PSB-PITCH
             CALL "PB-GET-UBYTE" USING PB-BUFFER PSB-FLAGS
         WHEN 32
             CALL "PB-GET-FLOAT" USING PB-BUFFER PSB-YAW
             CALL "PB-GET-FLOAT" USING PB-BUFFER PSB-PITCH
             CALL "PB-GET-UBYTE" USING PB-BUFFER PSB-FLAGS
         WHEN 33
             CALL "PB-GET-UBYTE" USING PB-BUFFER PSB-FLAGS
         WHEN 40
             CALL "PB-GET-BYTE" USING PB-BUFFER PSB-FLAGS
         WHEN 41
             CALL "PB-GET-VARINT" USING PB-BUFFER PSB-ACTION
             CALL "PB-GET-POSITION" USING PB-BUFFER PSB-BX PSB-BY PSB-BZ
             CALL "PB-GET-UBYTE" USING PB-BUFFER PSB-FACE
             CALL "PB-GET-VARINT" USING PB-BUFFER PSB-SEQUENCE
             MOVE FUNCTION MOD(PSB-FACE, 6) TO PSB-FACE
         WHEN 66
             CALL "PB-GET-VARINT" USING PB-BUFFER PSB-HAND
             CALL "PB-GET-POSITION" USING PB-BUFFER PSB-BX PSB-BY PSB-BZ
             CALL "PB-GET-VARINT" USING PB-BUFFER PSB-FACE
             CALL "PB-GET-FLOAT" USING PB-BUFFER PSB-CURSOR-X
             CALL "PB-GET-FLOAT" USING PB-BUFFER PSB-CURSOR-Y
             CALL "PB-GET-FLOAT" USING PB-BUFFER PSB-CURSOR-Z
             CALL "PB-GET-BOOL" USING PB-BUFFER PSB-INSIDE
             CALL "PB-GET-BOOL" USING PB-BUFFER PSB-BORDER
             CALL "PB-GET-VARINT" USING PB-BUFFER PSB-SEQUENCE
             MOVE FUNCTION MOD(PSB-FACE, 6) TO PSB-FACE
         WHEN 54
             CALL "PB-GET-SHORT" USING PB-BUFFER PSB-SLOT
         WHEN 18
             CALL "PB-GET-VARINT" USING PB-BUFFER PSB-CONTAINER
             CALL "PB-GET-VARINT" USING PB-BUFFER PSB-STATE-ID
             CALL "PB-GET-SHORT" USING PB-BUFFER PSB-SLOT
             CALL "PB-GET-BYTE" USING PB-BUFFER PSB-BUTTON
             CALL "PB-GET-VARINT" USING PB-BUFFER PSB-CLICK-TYPE
             IF PSB-CLICK-TYPE < 0 OR PSB-CLICK-TYPE > 6
                 MOVE 0 TO PSB-CLICK-TYPE
             END-IF
             CALL "PB-GET-VARINT" USING PB-BUFFER PSB-CHANGED-COUNT
             IF PSB-CHANGED-COUNT < 0 OR PSB-CHANGED-COUNT > 128
                 MOVE 1 TO PB-ERROR
                 MOVE 0 TO PSB-CHANGED-COUNT
             END-IF
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PSB-CHANGED-COUNT
                 CALL "PB-GET-SHORT" USING PB-BUFFER PSB-CHANGED-SLOT(WS-I)
                 CALL "PLAY-GET-HASHED-STACK" USING PB-BUFFER PSB-CHANGED-ITEM(WS-I)
                     PSB-CHANGED-AMOUNT(WS-I)
             END-PERFORM
             CALL "PLAY-GET-HASHED-STACK" USING PB-BUFFER PSB-CARRIED-ITEM PSB-CARRIED-COUNT
         WHEN 19
             CALL "PB-GET-VARINT" USING PB-BUFFER PSB-CONTAINER
         WHEN 57
             CALL "PB-GET-SHORT" USING PB-BUFFER PSB-SLOT
             CALL "PB-GET-ITEM-STACK" USING PB-BUFFER WK-ITEMSTACK-X
             MOVE WK-ISX-ITEM TO PSB-STACK-ITEM
             MOVE WK-ISX-COUNT TO PSB-STACK-COUNT
             CALL "SP-INTERN" USING WK-ITEMSTACK-X PSB-STACK-VAR
         WHEN 1
             CALL "PB-GET-VARINT" USING PB-BUFFER PSB-TARGET
         WHEN 12
             CALL "PB-GET-VARINT" USING PB-BUFFER PSB-ACTION
         WHEN 42
             CALL "PB-GET-VARINT" USING PB-BUFFER PSB-TARGET
             CALL "PB-GET-VARINT" USING PB-BUFFER PSB-ACTION
             CALL "PB-GET-VARINT" USING PB-BUFFER PSB-DATA
         WHEN 67
             CALL "PB-GET-VARINT" USING PB-BUFFER PSB-HAND
             CALL "PB-GET-VARINT" USING PB-BUFFER PSB-SEQUENCE
             CALL "PB-GET-FLOAT" USING PB-BUFFER PSB-YAW
             CALL "PB-GET-FLOAT" USING PB-BUFFER PSB-PITCH
         WHEN 47
             CALL "PB-GET-RECIPE-BOOK-CHANGE" USING PB-BUFFER PSB-BOOK-TYPE PSB-BOOK-OPEN PSB-BOOK-FILTER
         WHEN 48
             CALL "PB-GET-RECIPE-SEEN" USING PB-BUFFER PSB-RECIPE
         WHEN 39
             CALL "PB-GET-VARINT" USING PB-BUFFER PSB-CONTAINER
             CALL "PB-GET-VARINT" USING PB-BUFFER PSB-RECIPE
             CALL "PB-GET-BOOL" USING PB-BUFFER PSB-USE-MAX
         WHEN 7
             CALL "PB-GET-STRING" USING PB-BUFFER WS-MAX-COMMAND PSB-MESSAGE WS-MESSAGE-CAPACITY
                 PSB-MESSAGE-LENGTH
         WHEN 15
             CALL "PB-GET-VARINT" USING PB-BUFFER PSB-TRANSACTION
             CALL "PB-GET-STRING" USING PB-BUFFER WS-MAX-SUGGESTION PSB-MESSAGE
                 WS-MESSAGE-CAPACITY PSB-MESSAGE-LENGTH
         WHEN 9
             CALL "PB-GET-STRING" USING PB-BUFFER WS-MAX-MESSAGE PSB-MESSAGE WS-MESSAGE-CAPACITY
                 PSB-MESSAGE-LENGTH
             CALL "PB-GET-LONG" USING PB-BUFFER WS-LONG
             CALL "PB-GET-LONG" USING PB-BUFFER WS-LONG
             CALL "PB-GET-BOOL" USING PB-BUFFER WS-PRESENT
             IF WS-PRESENT = 1
                 CALL "PB-SKIP" USING PB-BUFFER WS-SIGNATURE-BYTES
             END-IF
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-I
             CALL "PB-GET-FIXED-BITSET" USING PB-BUFFER WS-SEEN-BITS WS-SEEN
             CALL "PB-GET-BYTE" USING PB-BUFFER WS-I
         WHEN OTHER
             MOVE 2 TO L-OUTCOME
     END-EVALUATE
     IF L-OUTCOME = 0 AND (PB-ERROR = 1 OR PB-POS NOT = PB-LENGTH)
         MOVE 1 TO L-OUTCOME
     END-IF
     GOBACK.
 END PROGRAM PLAY-DECODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAY-GET-HASHED-STACK.
*> USING PB-BUFFER, item out, count out (BINARY-LONG): one HashedStack (00 §12.4; 05c 0x12). Absent
*> is item 0, count 0. A stack with data components sets PB-ERROR (see PLAY-DECODE).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PRESENT             BINARY-LONG.
 01 WS-ADDED               BINARY-LONG.
 01 WS-REMOVED             BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-ITEM L-COUNT.
     MOVE 0 TO L-ITEM L-COUNT
     CALL "PB-GET-BOOL" USING PB-BUFFER WS-PRESENT
     IF WS-PRESENT = 1
         CALL "PB-GET-VARINT" USING PB-BUFFER L-ITEM
         CALL "PB-GET-VARINT" USING PB-BUFFER L-COUNT
         CALL "PB-GET-VARINT" USING PB-BUFFER WS-ADDED
         CALL "PB-GET-VARINT" USING PB-BUFFER WS-REMOVED
         IF WS-ADDED NOT = 0 OR WS-REMOVED NOT = 0
             MOVE 1 TO PB-ERROR
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PLAY-GET-HASHED-STACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAY-LOGIN-BUILD.
*> USING player row, PB-BUFFER: Login 0x32 (05a; 09 §3.2): the player's entity id, hardcore false,
*> dimension names = every enabled dimension (CW-DIM, in order), max players 20, view and
*> simulation distance = the configured view distance, reduced debug info false, show death screen
*> true, limited crafting false, CommonPlayerSpawnInfo of the player's dimension (type id, key,
*> hashed seed 0, game mode, previous game mode absent, not debug, not flat, no last death
*> location, portal cooldown 0, sea level), online mode false, enforces secure chat false.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 01 WS-PACKET-ID           BINARY-LONG VALUE 50.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-MAX-PLAYERS         BINARY-LONG VALUE 20.
 01 WS-DIM                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY COREAPI.
 COPY PROTO.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-INT" USING PB-BUFFER PL-ENTITY-ID(L-ROW)
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-VARINT" USING PB-BUFFER CW-DIM-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CW-DIM-COUNT
         MOVE CW-DIM(WS-I) TO WS-DIM
         CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER DM-KEY(WS-DIM) DM-KEY-LENGTH(WS-DIM)
     END-PERFORM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-MAX-PLAYERS
     CALL "PB-PUT-VARINT" USING PB-BUFFER CS-VIEW-DISTANCE
     CALL "PB-PUT-VARINT" USING PB-BUFFER CS-VIEW-DISTANCE
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ONE
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
     CALL "PLAY-SPAWN-INFO-BUILD" USING PL-DIM(L-ROW) PL-MODE(L-ROW) PB-BUFFER
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
     GOBACK.
 END PROGRAM PLAY-LOGIN-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAY-RESPAWN-BUILD.
*> USING dimension row (BINARY-LONG), game mode (PIC 9), data to keep (BINARY-LONG), PB-BUFFER:
*> Respawn 0x54 (05b; 09 §3.3): CommonPlayerSpawnInfo of the dimension, then the Byte data to keep
*> (0x00 after a death, 0x03 for travel).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 84.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-DIM                  BINARY-LONG.
 01 L-MODE                 PIC 9.
 01 L-KEEP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-MODE L-KEEP PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PLAY-SPAWN-INFO-BUILD" USING L-DIM L-MODE PB-BUFFER
     CALL "PB-PUT-BYTE" USING PB-BUFFER L-KEEP
     GOBACK.
 END PROGRAM PLAY-RESPAWN-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAY-SPAWN-INFO-BUILD.
*> USING dimension row (BINARY-LONG), game mode (PIC 9: 0 survival, 1 creative), PB-BUFFER: the
*> CommonPlayerSpawnInfo of Login and Respawn (05a, 05b; 09 §3.2): dimension type id, dimension key,
*> hashed seed 0, game mode, previous game mode absent, not debug, not flat, no last death location,
*> portal cooldown 0, sea level.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY DIMENSIONS.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-SEED                BINARY-DOUBLE VALUE 0.
 01 WS-MODE                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-DIM                  BINARY-LONG.
 01 L-MODE                 PIC 9.
 PROCEDURE DIVISION USING L-DIM L-MODE PB-BUFFER.
     MOVE L-DIM TO WS-DIM
     CALL "PB-PUT-VARINT" USING PB-BUFFER DM-TYPE-ID(WS-DIM)
     CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER DM-KEY(WS-DIM) DM-KEY-LENGTH(WS-DIM)
     CALL "PB-PUT-LONG" USING PB-BUFFER WS-SEED
     MOVE L-MODE TO WS-MODE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-MODE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-VARINT" USING PB-BUFFER DM-SEA-LEVEL(WS-DIM)
     GOBACK.
 END PROGRAM PLAY-SPAWN-INFO-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAY-ABILITIES-BUILD.
*> USING game mode (PIC 9: 0 survival, 1 creative, 2 adventure, 3 spectator), flying (PIC 9), PB-BUFFER: Player Abilities
*> 0x41 (05a; 09 §3.2; 13 §1.4): creative flags 0x0D (invulnerable, can fly, instant build) plus 0x02 while
*> flying, spectator 0x07 (invulnerable, flying, can fly), survival and adventure 0x00; flying speed 0.05, walking speed 0.1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 65.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-FLY-SPEED           FLOAT-SHORT VALUE 0.05.
 01 WS-WALK-SPEED          FLOAT-SHORT VALUE 0.1.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-MODE                 PIC 9.
 01 L-FLYING               PIC 9.
 PROCEDURE DIVISION USING L-MODE L-FLYING PB-BUFFER.
     MOVE 0 TO WS-FLAGS
     EVALUATE L-MODE
         WHEN 1
             MOVE 13 TO WS-FLAGS
             IF L-FLYING = 1
                 ADD 2 TO WS-FLAGS
             END-IF
         WHEN 3
             MOVE 7 TO WS-FLAGS
     END-EVALUATE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-BYTE" USING PB-BUFFER WS-FLAGS
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-FLY-SPEED
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-WALK-SPEED
     GOBACK.
 END PROGRAM PLAY-ABILITIES-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAY-HELD-SLOT-BUILD.
*> USING hotbar slot 0 to 8, PB-BUFFER: Set Held Slot 0x6B (05b; VarInt slot).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 107.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-SLOT
     GOBACK.
 END PROGRAM PLAY-HELD-SLOT-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAY-CONTENT-BUILD.
*> USING player row, PB-BUFFER: Container Set Content 0x12 (05a; 09 §3.2; 40-1 §4.3): the container id and state id of the
*> player's current menu, its 46 slots in the menu's numbering (menus.cob; count 0 = empty), then the item on the player's
*> cursor (PL-CARRIED-*).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WK-==.
 01 WS-PACKET-ID           BINARY-LONG VALUE 18.
 01 WS-SLOTS               BINARY-LONG VALUE 46.
 01 WS-I                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     IF MN-WINDOW(L-ROW) = 0
         MOVE PL-STATE-ID(L-ROW) TO WS-STATE
     ELSE
         MOVE MN-STATE-ID(L-ROW) TO WS-STATE
     END-IF
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER MN-WINDOW(L-ROW)
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-STATE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-SLOTS
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 45
         CALL "MENU-GET-X" USING L-ROW WS-I WS-ITEM WS-COUNT WS-VAR
         CALL "SP-EXPORT" USING WS-ITEM WS-COUNT WS-VAR WK-ITEMSTACK-X
         CALL "PB-PUT-ITEM-STACK" USING PB-BUFFER WK-ITEMSTACK-X
     END-PERFORM
     CALL "SP-EXPORT" USING PL-CARRIED-ITEM(L-ROW) PL-CARRIED-COUNT(L-ROW) PL-CARRIED-VAR(L-ROW) WK-ITEMSTACK-X
     CALL "PB-PUT-ITEM-STACK" USING PB-BUFFER WK-ITEMSTACK-X
     GOBACK.
 END PROGRAM PLAY-CONTENT-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAY-INVENTORY-SLOT-BUILD.
*> USING slot 0 to 35, PB-ITEMSTACK, PB-BUFFER: Set Player Inventory 0x6E (05b; VarInt slot,
*> ItemStack).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 110.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT PB-ITEMSTACK PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-SLOT
     CALL "PB-PUT-ITEMSTACK" USING PB-BUFFER PB-ITEMSTACK
     GOBACK.
 END PROGRAM PLAY-INVENTORY-SLOT-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAY-SPAWN-POSITION-BUILD.
*> USING PB-BUFFER: Set Default Spawn Position 0x63 (05b RespawnData; 09 §3.2): dimension
*> cobolcraft:main, the block position of the world spawn (floor of each coordinate), its yaw,
*> pitch 0.0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 01 WS-PACKET-ID           BINARY-LONG VALUE 99.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER.
     COMPUTE WS-X = FUNCTION INTEGER(CW-SPAWN-X)
     COMPUTE WS-Y = FUNCTION INTEGER(CW-SPAWN-Y)
     COMPUTE WS-Z = FUNCTION INTEGER(CW-SPAWN-Z)
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER DM-KEY(DIM-MAIN) DM-KEY-LENGTH(DIM-MAIN)
     CALL "PB-PUT-POSITION" USING PB-BUFFER WS-X WS-Y WS-Z
     CALL "PB-PUT-FLOAT" USING PB-BUFFER CW-SPAWN-YAW
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-PITCH
     GOBACK.
 END PROGRAM PLAY-SPAWN-POSITION-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAY-TIME-BUILD.
*> USING time of day (BINARY-DOUBLE), PB-BUFFER: Set Time 0x73 (05b; 09 §3.2): game time = the
*> time, one clock update: world_clock id 0 (cobolcraft:daylight), total ticks = the time, partial
*> tick 0.0, rate 1.0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 115.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-PARTIAL             FLOAT-SHORT VALUE 0.
 01 WS-RATE                FLOAT-SHORT VALUE 1.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-TIME                 BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-TIME PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-LONG" USING PB-BUFFER L-TIME
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ONE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-VARLONG" USING PB-BUFFER L-TIME
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-PARTIAL
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-RATE
     GOBACK.
 END PROGRAM PLAY-TIME-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAY-GAME-EVENT-BUILD.
*> USING event (BINARY-LONG, UByte on the wire), value (FLOAT-SHORT), PB-BUFFER: Game Event 0x27
*> (05a).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 39.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-EVENT                BINARY-LONG.
 01 L-VALUE                FLOAT-SHORT.
 PROCEDURE DIVISION USING L-EVENT L-VALUE PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-UBYTE" USING PB-BUFFER L-EVENT
     CALL "PB-PUT-FLOAT" USING PB-BUFFER L-VALUE
     GOBACK.
 END PROGRAM PLAY-GAME-EVENT-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAY-POSITION-BUILD.
*> USING teleport id, x, y, z (FLOAT-LONG), yaw, pitch (FLOAT-SHORT), PB-BUFFER: Player Position
*> 0x49 (05b; 09 §3.2): the teleport id, the position, velocity (0, 0, 0), yaw, pitch, relative
*> flags 0 (all absolute).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 73.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-STILL               FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-TELEPORT-ID          BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-YAW                  FLOAT-SHORT.
 01 L-PITCH                FLOAT-SHORT.
 PROCEDURE DIVISION USING L-TELEPORT-ID L-X L-Y L-Z L-YAW L-PITCH PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-TELEPORT-ID
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-X
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Y
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Z
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER WS-STILL
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER WS-STILL
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER WS-STILL
     CALL "PB-PUT-FLOAT" USING PB-BUFFER L-YAW
     CALL "PB-PUT-FLOAT" USING PB-BUFFER L-PITCH
     CALL "PB-PUT-INT" USING PB-BUFFER WS-ZERO
     GOBACK.
 END PROGRAM PLAY-POSITION-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAYER-INFO-UPDATE-BUILD.
*> USING player row, PB-BUFFER: Player Info Update 0x47 (05a; 09 §3.2): actions 0x01 (ADD_PLAYER
*> only), one entry: the player's offline UUID, name, 0 properties.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-PACKET-ID           BINARY-LONG VALUE 71.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-MAX                 BINARY-LONG VALUE 16.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-UBYTE" USING PB-BUFFER WS-ONE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ONE
     CALL "PB-PUT-UUID" USING PB-BUFFER PL-UUID(L-ROW)
     CALL "PB-PUT-STRING" USING PB-BUFFER PL-NAME(L-ROW) PL-NAME-LENGTH(L-ROW) WS-MAX
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     GOBACK.
 END PROGRAM PLAYER-INFO-UPDATE-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAYER-INFO-REMOVE-BUILD.
*> USING UUID (PIC X(16)), PB-BUFFER: Player Info Remove 0x46 (05a): one profile id.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 70.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-UUID                 PIC X(16).
 PROCEDURE DIVISION USING L-UUID PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ONE
     CALL "PB-PUT-UUID" USING PB-BUFFER L-UUID
     GOBACK.
 END PROGRAM PLAYER-INFO-REMOVE-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OTHERS-JOIN.
*> USING connection id of a player whose join sequence has just been sent (US3-5; 09 §3.2 Player
*> Info Update and Add Entity rows, "Join sequence"): the player is sent Player Info Update for
*> itself and for every player already in the world, and every player already in the world is sent
*> Player Info Update for the new player. Then the player's entity (cobolcraft:operator, its entity
*> id and offline UUID, position and facing) enters the tracker: the others who see it get Add
*> Entity, and the new player gets Add Entity for every entity it sees. The player's entering order
*> (PL-ENTERED, standin §9.3 pickup order) is the next CW-NEXT-ENTER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 128.
 01 WS-ROW                 BINARY-LONG.
 01 WS-OTHER               BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID.
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PLAYER-INFO-UPDATE-BUILD" USING WS-ROW PB-BUFFER
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     PERFORM VARYING WS-OTHER FROM 1 BY 1 UNTIL WS-OTHER > CORE-MAX-PLAYERS
         IF PL-USED(WS-OTHER) = 1 AND PL-ENTITY-ROW(WS-OTHER) > 0
             CALL "CORE-SEND" USING PL-CONN(WS-OTHER) PB-BUFFER
         END-IF
     END-PERFORM
     PERFORM VARYING WS-OTHER FROM 1 BY 1 UNTIL WS-OTHER > CORE-MAX-PLAYERS
         IF PL-USED(WS-OTHER) = 1 AND PL-ENTITY-ROW(WS-OTHER) > 0
             CALL "PB-RESET" USING PB-BUFFER
             CALL "PLAYER-INFO-UPDATE-BUILD" USING WS-OTHER PB-BUFFER
             CALL "CORE-SEND" USING L-ID PB-BUFFER
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     CALL "ENTITY-ALLOC" USING WS-ENTITY
     MOVE PL-ENTITY-ID(WS-ROW) TO EN-ID(WS-ENTITY)
     MOVE CR-OPERATOR TO EN-TYPE(WS-ENTITY)
     MOVE PL-UUID(WS-ROW) TO EN-UUID(WS-ENTITY)
     MOVE WS-ROW TO EN-PLAYER(WS-ENTITY)
     MOVE PL-DIM(WS-ROW) TO EN-DIM(WS-ENTITY)
     MOVE PL-X(WS-ROW) TO EN-X(WS-ENTITY)
     MOVE PL-Y(WS-ROW) TO EN-Y(WS-ENTITY)
     MOVE PL-Z(WS-ROW) TO EN-Z(WS-ENTITY)
     MOVE PL-YAW(WS-ROW) TO EN-YAW(WS-ENTITY)
     MOVE PL-PITCH(WS-ROW) TO EN-PITCH(WS-ENTITY)
     MOVE PL-ON-GROUND(WS-ROW) TO EN-ON-GROUND(WS-ENTITY)
     MOVE WS-ENTITY TO PL-ENTITY-ROW(WS-ROW)
     ADD 1 TO CW-NEXT-ENTER
     MOVE CW-NEXT-ENTER TO PL-ENTERED(WS-ROW)
     CALL "ENTITY-VIEWER-FORGET" USING WS-ROW
     CALL "ENTITY-TRACK" USING WS-ENTITY
     CALL "ENTITY-VIEWER-REFRESH" USING WS-ROW
     GOBACK.
 END PROGRAM OTHERS-JOIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OTHERS-LEAVE.
*> USING player row of a player leaving the world (US3-5; 09 §3.2 Remove Entities and Player Info
*> Remove rows): when its join was sent, its entity leaves the tracker (Remove Entities to those who
*> had it), its client is marked as having nothing, and every other player in the world is sent
*> Player Info Remove with its UUID; the console line "<name> left" is queued (operator-surface §3,
*> US13-3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-ROW                 BINARY-LONG.
 01 WS-OTHER               BINARY-LONG.
 01 WS-LINE                PIC X(32).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE L-ROW TO WS-ROW
     IF PL-ENTITY-ROW(WS-ROW) = 0
         GOBACK
     END-IF
     CALL "ENTITY-REMOVE" USING PL-ENTITY-ROW(WS-ROW)
     MOVE 0 TO PL-ENTITY-ROW(WS-ROW)
     CALL "ENTITY-VIEWER-FORGET" USING WS-ROW
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PLAYER-INFO-REMOVE-BUILD" USING PL-UUID(WS-ROW) PB-BUFFER
     PERFORM VARYING WS-OTHER FROM 1 BY 1 UNTIL WS-OTHER > CORE-MAX-PLAYERS
         IF PL-USED(WS-OTHER) = 1 AND PL-ENTITY-ROW(WS-OTHER) > 0
             CALL "CORE-SEND" USING PL-CONN(WS-OTHER) PB-BUFFER
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     MOVE SPACES TO WS-LINE
     STRING PL-NAME(WS-ROW)(1:PL-NAME-LENGTH(WS-ROW)) " left" DELIMITED BY SIZE INTO WS-LINE
     COMPUTE WS-LENGTH = PL-NAME-LENGTH(WS-ROW) + 5
     CALL "CORE-LOG" USING WS-LINE WS-LENGTH
     GOBACK.
 END PROGRAM OTHERS-LEAVE.
