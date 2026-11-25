*> Player poses on the server (docs/protocol/53 sections 1 to 3, 10; T6201).
*>
*> The pose of a player (the Pose enum: 0 standing, 3 swimming or crawling, 5 crouching) and the shared-flags byte of its entity (18 section
*> 1.4: 0x02 shift key down, 0x08 sprinting, 0x10 swimming) are kept in PL-POSE and PL-POSE-FLAGS. POSE-UPDATE runs after Player Input,
*> Player Command and every accepted move: the pose is chosen as 53 section 3.2 says (the swimming box must fit or nothing changes; the desired
*> pose is crouching with the shift key up unless flying, else standing; a pose whose box does not fit becomes crouching, then swimming), and a
*> change of pose, flags or displayed skin parts (PL-MODEL-PARTS, from Client Information, 47 section 5.3) is sent to every player who sees the entity as
*> Set Entity Data (05b 0x65: index 0 Byte flags, index 6 Pose, index 16 Byte skin parts).
*>
*> Entry points:
*>   POSE-DATA-BUILD USING entity id, flags, pose, skin parts, hand, PB-BUFFER
*>   POSE-UPDATE USING player row
*>   POSE-EYE USING player row, eye height out (FLOAT-LONG)
*>   LIVING-DATA-BUILD USING entity id, living flags, PB-BUFFER (CC-0014, docs/protocol/58 section 2.1)
*>   USE-FLAGS-GET USING player row, in use out (1 when an item is in use), living flags out
*>   USE-FLAGS-SYNC USING player row (once a tick)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. POSE-DATA-BUILD.
*> USING entity id, flags (the shared-flags Byte), pose (id), skin parts (the displayed skin parts byte, 47 section 5.3), hand (0 no entry, 1 the left main hand, 2 the right one),
*> PB-BUFFER: Set Entity Data 0x65 with entry 0 (BYTE flags), entry 6 (POSE), entry 15 (HUMANOID_ARM, serializer 42: 0 left, 1 right; DATA_PLAYER_MAIN_HAND, 47 section 5.3) when the
*> hand is 1 or 2, entry 16 (BYTE skin parts: DATA_PLAYER_MODE_CUSTOMISATION), 0xFF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MD-==.
 01 WS-PACKET-ID           BINARY-LONG VALUE 101.
 01 WS-INDEX-HAND          BINARY-LONG VALUE 15.
 01 WS-HUMANOID-ARM        BINARY-LONG VALUE 42.
 01 WS-ARM                 BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ENTITY-ID            BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 01 L-POSE                 BINARY-LONG.
 01 L-PARTS                BINARY-LONG.
 01 L-HAND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY-ID L-FLAGS L-POSE L-PARTS L-HAND PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ENTITY-ID
     INITIALIZE MD-METADATA-ENTRY
     MOVE 0 TO MD-MD-INDEX
     MOVE MD-MDS-BYTE TO MD-MD-SERIALIZER
     MOVE L-FLAGS TO MD-MD-INT
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     INITIALIZE MD-METADATA-ENTRY
     MOVE 6 TO MD-MD-INDEX
     MOVE MD-MDS-POSE TO MD-MD-SERIALIZER
     MOVE L-POSE TO MD-MD-INT
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
*>   Entry 15 by hand (the entries go in index order; PB-PUT-ENTITY-METADATA does not know the serializer, so the entry is written here).
     IF L-HAND > 0
         COMPUTE WS-ARM = L-HAND - 1
         CALL "PB-PUT-UBYTE" USING PB-BUFFER WS-INDEX-HAND
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-HUMANOID-ARM
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ARM
     END-IF
     INITIALIZE MD-METADATA-ENTRY
     MOVE 16 TO MD-MD-INDEX
     MOVE MD-MDS-BYTE TO MD-MD-SERIALIZER
     MOVE L-PARTS TO MD-MD-INT
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     MOVE MD-MD-END TO MD-MD-INDEX
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     GOBACK.
 END PROGRAM POSE-DATA-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. POSE-UPDATE.
*> USING player row: the rules above; sends Set Entity Data when the pose or the flags changed since the last send.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CTOOLS.
 COPY WSIM2.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-STAND               BINARY-LONG VALUE 0.
 01 WS-CROUCH              BINARY-LONG VALUE 5.
 01 WS-SWIM                BINARY-LONG VALUE 3.
 01 WS-HALF                FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-SWIM-FITS           BINARY-LONG.
 01 WS-DESIRED             BINARY-LONG.
 01 WS-FITS                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-TRACKER             BINARY-LONG.
 01 WS-WET                 BINARY-LONG.
 01 WS-EYE                 BINARY-LONG.
 01 WS-HAND                BINARY-LONG.
 01 WS-VIEWER              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
*>   The swimming flag (53 section 4): kept while sprinting in water, set when sprinting with the eye in water; never while flying.
     CALL "FLUID-TOUCHES-WATER" USING PL-DIM(L-ROW) PL-X(L-ROW) PL-Y(L-ROW) PL-Z(L-ROW) WS-WET
     CALL "BREATH-EYE-IN-WATER" USING L-ROW WS-EYE
     IF PL-SWIMMING(L-ROW) = 1
         IF PL-SPRINTING(L-ROW) = 0 OR WS-WET = 0 OR PL-FLYING(L-ROW) = 1
             MOVE 0 TO PL-SWIMMING(L-ROW)
         END-IF
     ELSE
         IF PL-SPRINTING(L-ROW) = 1 AND WS-WET = 1 AND WS-EYE = 1 AND PL-FLYING(L-ROW) = 0
             MOVE 1 TO PL-SWIMMING(L-ROW)
         END-IF
     END-IF
     CALL "MOVE-COLLIDES-POSE" USING PL-DIM(L-ROW) WS-SWIM PL-X(L-ROW) PL-Y(L-ROW) PL-Z(L-ROW) WS-HIT
     IF WS-HIT = 0
         MOVE WS-STAND TO WS-DESIRED
         IF PL-SWIMMING(L-ROW) = 1
             MOVE WS-SWIM TO WS-DESIRED
         END-IF
         IF PL-SNEAKING(L-ROW) = 1 AND PL-FLYING(L-ROW) = 0
             MOVE WS-CROUCH TO WS-DESIRED
         END-IF
         IF PL-MODE(L-ROW) NOT = 3
             CALL "MOVE-COLLIDES-POSE" USING PL-DIM(L-ROW) WS-DESIRED PL-X(L-ROW) PL-Y(L-ROW) PL-Z(L-ROW) WS-FITS
             IF WS-FITS = 1
                 MOVE WS-CROUCH TO WS-DESIRED
                 CALL "MOVE-COLLIDES-POSE" USING PL-DIM(L-ROW) WS-DESIRED PL-X(L-ROW) PL-Y(L-ROW) PL-Z(L-ROW) WS-FITS
                 IF WS-FITS = 1
                     MOVE WS-SWIM TO WS-DESIRED
                 END-IF
             END-IF
         END-IF
         MOVE WS-DESIRED TO PL-POSE(L-ROW)
     END-IF
*>   A sleeping player (core/src/sleep-bed.cob) has the SLEEPING pose (53 section 1, id 2).
     IF L-ROW <= 64
         IF W2-SLEEPING(L-ROW) = 1
             MOVE 2 TO PL-POSE(L-ROW)
         END-IF
     END-IF
     MOVE 0 TO PL-POSE-FLAGS(L-ROW)
*>   Gliding (17 section 3.13): the fall flying pose (1) and the shared flag 7 (0x80, 18 section 1.4).
     IF TS-GLIDE-TICKS(L-ROW) > 0
         MOVE 1 TO PL-POSE(L-ROW)
         ADD 128 TO PL-POSE-FLAGS(L-ROW)
     END-IF
     IF PL-SNEAKING(L-ROW) = 1
         ADD 2 TO PL-POSE-FLAGS(L-ROW)
     END-IF
     IF PL-SPRINTING(L-ROW) = 1
         ADD 8 TO PL-POSE-FLAGS(L-ROW)
     END-IF
     IF PL-SWIMMING(L-ROW) = 1
         ADD 16 TO PL-POSE-FLAGS(L-ROW)
     END-IF
*>   The on-fire flag (entry 0 bit 0, 18 section 1.4) while the tracker row burns (PLAYER-FIRE-TICK).
     IF PL-ENTITY-ROW(L-ROW) > 0 AND EN-BURN(PL-ENTITY-ROW(L-ROW)) > 0
         ADD 1 TO PL-POSE-FLAGS(L-ROW)
     END-IF
     COMPUTE WS-STATE = 1 + PL-POSE(L-ROW) * 256 + PL-POSE-FLAGS(L-ROW)
     MOVE PL-POSE-SENT(L-ROW) TO WS-OLD
     IF WS-OLD = 0
         MOVE 1 TO WS-OLD
     END-IF
     IF (WS-STATE NOT = WS-OLD OR PL-MODEL-PARTS(L-ROW) NOT = PL-PARTS-SENT(L-ROW) OR PL-LEFT-HAND(L-ROW) NOT = PL-HAND-SENT(L-ROW))
         AND PL-ENTITY-ROW(L-ROW) > 0
         IF WS-READY = 0
             CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
             MOVE 1 TO WS-READY
         END-IF
         MOVE WS-STATE TO PL-POSE-SENT(L-ROW)
         MOVE PL-MODEL-PARTS(L-ROW) TO PL-PARTS-SENT(L-ROW)
*>       The main hand: entry 15 while it is the left one, and once more as the right one when it goes back (the viewers keep the last value).
         MOVE 0 TO WS-HAND
         IF PL-LEFT-HAND(L-ROW) = 1
             MOVE 1 TO WS-HAND
         END-IF
         IF PL-LEFT-HAND(L-ROW) = 0 AND PL-HAND-SENT(L-ROW) = 1
             MOVE 2 TO WS-HAND
         END-IF
         MOVE PL-LEFT-HAND(L-ROW) TO PL-HAND-SENT(L-ROW)
         MOVE PL-ENTITY-ROW(L-ROW) TO WS-TRACKER
         CALL "PB-RESET" USING PB-BUFFER
         CALL "POSE-DATA-BUILD" USING EN-ID(WS-TRACKER) PL-POSE-FLAGS(L-ROW) PL-POSE(L-ROW) PL-MODEL-PARTS(L-ROW)
             WS-HAND PB-BUFFER
         PERFORM VARYING WS-VIEWER FROM 1 BY 1 UNTIL WS-VIEWER > CORE-MAX-PLAYERS
             IF VW-SEEN(WS-VIEWER)(WS-TRACKER:1) = "1"
                 CALL "CORE-SEND" USING PL-CONN(WS-VIEWER) PB-BUFFER
             END-IF
         END-PERFORM
*>       Going to bed or getting out of it is also told to the player itself (it does not predict the pose).
         COMPUTE WS-OLD = (WS-OLD - 1) / 256
         IF (WS-OLD = 2 OR PL-POSE(L-ROW) = 2) AND VW-SEEN(L-ROW)(WS-TRACKER:1) NOT = "1"
             CALL "CORE-SEND" USING PL-CONN(L-ROW) PB-BUFFER
         END-IF
     END-IF
     GOBACK.
 END PROGRAM POSE-UPDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. POSE-EYE.
*> USING player row, eye height out (FLOAT-LONG, above the feet): the eye of the player's current pose, the origin of every look ray the server tests
*> a player's interaction from (docs/protocol/53 sections 2.1 and 7: the entity's own eye height, not smoothed, "what the server and the picking ray use";
*> the client's PHYS-EYE gives the same value): standing 1.62 and crouching (5) 1.27 with a standard or debug content set, 1.6 and 1.25 for the
*> cobolcraft stand-in set (RULE-ATTACK-EYE-MILLI, standin-content section 3); swimming or crawling (3) and fall flying (1) 0.4; sleeping (2) 0.2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY RULES.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-EYE                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-EYE.
     COMPUTE L-EYE = RULE-ATTACK-EYE-MILLI / 1000
     EVALUATE PL-POSE(L-ROW)
         WHEN 5
             MOVE 1.25 TO L-EYE
             IF CT-SET-TYPE NOT = CT-TYPE-COBOLCRAFT
                 MOVE 1.27 TO L-EYE
             END-IF
         WHEN 3
             MOVE 0.4 TO L-EYE
         WHEN 1
             MOVE 0.4 TO L-EYE
         WHEN 2
             MOVE 0.2 TO L-EYE
         WHEN OTHER
             IF CT-SET-TYPE NOT = CT-TYPE-COBOLCRAFT
                 MOVE 1.62 TO L-EYE
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM POSE-EYE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIVING-DATA-BUILD.
*> USING entity id, living flags (BINARY-LONG), PB-BUFFER (CC-0014, docs/protocol/58 section 2.1): Set Entity Data 0x65 with the one entry 8 (BYTE: the living entity flags, 1 using an item,
*> 2 the used hand is the off hand, 4 spin attack), 0xFF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MD-==.
 01 WS-PACKET-ID           BINARY-LONG VALUE 101.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ENTITY-ID            BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY-ID L-FLAGS PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ENTITY-ID
     INITIALIZE MD-METADATA-ENTRY
     MOVE 8 TO MD-MD-INDEX
     MOVE MD-MDS-BYTE TO MD-MD-SERIALIZER
     MOVE L-FLAGS TO MD-MD-INT
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     MOVE MD-MD-END TO MD-MD-INDEX
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     GOBACK.
 END PROGRAM LIVING-DATA-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. USE-FLAGS-GET.
*> USING player row, in use out, living flags out (docs/protocol/58 section 2.1): the item a player uses is one of the use states of the tools: a raised shield (TS-BLOCK-START, its hand
*> TS-BLOCK-HAND), a bow, crossbow or trident being drawn (TS-USE-START), eating (PL-EATING-ITEM) and a goat horn (TS-HORN-USE-START, TS-HORN-USE-HAND); all but the shield and the horn
*> use the main hand. The flags byte is 1 + 2 when the used hand is the off hand while an item is in use; with none in use it is the bit 2 of the byte last sent (startUsingItem
*> sets or clears it and stopUsingItem leaves it).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CTOOLS.
 01 WS-OFF                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ACTIVE               BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ACTIVE L-FLAGS.
     CALL "COMBAT-TS-CHECK" USING L-ROW
     MOVE 0 TO L-ACTIVE WS-OFF
     EVALUATE TRUE
         WHEN TS-HORN-USE-START(L-ROW) > 0
             MOVE 1 TO L-ACTIVE
             MOVE TS-HORN-USE-HAND(L-ROW) TO WS-OFF
         WHEN TS-BLOCK-START(L-ROW) > 0
             MOVE 1 TO L-ACTIVE
             MOVE TS-BLOCK-HAND(L-ROW) TO WS-OFF
         WHEN TS-USE-START(L-ROW) > 0 OR PL-EATING-ITEM(L-ROW) > 0
             MOVE 1 TO L-ACTIVE
     END-EVALUATE
     IF L-ACTIVE = 1
         COMPUTE L-FLAGS = 1 + 2 * WS-OFF
     ELSE
         COMPUTE L-FLAGS = 2 * FUNCTION MOD(FUNCTION INTEGER(TS-LIVING-SENT(L-ROW) / 2), 2)
     END-IF
     GOBACK.
 END PROGRAM USE-FLAGS-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. USE-FLAGS-SYNC.
*> USING player row: once a tick the living entity flags of the player (USE-FLAGS-GET) are compared with the byte last sent (TS-LIVING-SENT); a change goes to the players who see the
*> player and to the player as Set Entity Data entry 8 (docs/protocol/58 sections 2.1, 2.2 and 5.8). When an item comes into use (bit 1 rises) the Set Equipment of the used hand
*> (0x68: slot 0 main hand, 1 off hand, the stack with its components, so a horn keeps the instrument of its prototype, 58 section 5.2) goes out first: the viewer's use start needs the stack
*> in the hand when the flags arrive (58 section 2.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CTOOLS.
 COPY CMENU.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 8192.
 01 WS-ACTIVE              BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-OLD-USING           BINARY-LONG.
 01 WS-PACKET-EQUIP        BINARY-LONG VALUE 104.
 01 WS-HAND                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 01 WS-TRACKER             BINARY-LONG.
 01 WS-VIEWER              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "USE-FLAGS-GET" USING L-ROW WS-ACTIVE WS-FLAGS
     IF WS-FLAGS = TS-LIVING-SENT(L-ROW) OR PL-ENTITY-ROW(L-ROW) = 0
         GOBACK
     END-IF
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE PL-ENTITY-ROW(L-ROW) TO WS-TRACKER
     MOVE FUNCTION MOD(TS-LIVING-SENT(L-ROW), 2) TO WS-OLD-USING
     IF WS-ACTIVE = 1 AND WS-OLD-USING = 0
*>       startUsingItem sends the used hand's stack at once (58 section 2.2 step 1).
         COMPUTE WS-HAND = FUNCTION INTEGER(WS-FLAGS / 2)
         IF WS-HAND = 0
             COMPUTE WS-SLOT = PL-HELD(L-ROW) + 1
             MOVE PL-SLOT-ITEM(L-ROW, WS-SLOT) TO WS-ITEM
             MOVE PL-SLOT-COUNT(L-ROW, WS-SLOT) TO WS-COUNT
             MOVE PL-SLOT-VAR(L-ROW, WS-SLOT) TO WS-VAR
         ELSE
             MOVE MN-EQUIP-ITEM(L-ROW, 5) TO WS-ITEM
             MOVE MN-EQUIP-COUNT(L-ROW, 5) TO WS-COUNT
             MOVE MN-EQUIP-VAR(L-ROW, 5) TO WS-VAR
         END-IF
         CALL "SP-EXPORT" USING WS-ITEM WS-COUNT WS-VAR PB-ITEMSTACK-X
         CALL "PB-RESET" USING PB-BUFFER
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-EQUIP
         CALL "PB-PUT-VARINT" USING PB-BUFFER EN-ID(WS-TRACKER)
         CALL "PB-PUT-UBYTE" USING PB-BUFFER WS-HAND
         CALL "PB-PUT-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
         PERFORM VARYING WS-VIEWER FROM 1 BY 1 UNTIL WS-VIEWER > CORE-MAX-PLAYERS
             IF VW-SEEN(WS-VIEWER)(WS-TRACKER:1) = "1"
                 CALL "CORE-SEND" USING PL-CONN(WS-VIEWER) PB-BUFFER
             END-IF
         END-PERFORM
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "LIVING-DATA-BUILD" USING EN-ID(WS-TRACKER) WS-FLAGS PB-BUFFER
     PERFORM VARYING WS-VIEWER FROM 1 BY 1 UNTIL WS-VIEWER > CORE-MAX-PLAYERS
         IF VW-SEEN(WS-VIEWER)(WS-TRACKER:1) = "1" AND WS-VIEWER NOT = L-ROW
             CALL "CORE-SEND" USING PL-CONN(WS-VIEWER) PB-BUFFER
         END-IF
     END-PERFORM
*>   The player itself gets its own flags too (the tracker pass sends dirty data to the trackers and to the player, 18 section 9.2; its client predicts a use and ends it on the clear flag, 58 section 2.4).
     CALL "CORE-SEND" USING PL-CONN(L-ROW) PB-BUFFER
     MOVE WS-FLAGS TO TS-LIVING-SENT(L-ROW)
     GOBACK.
 END PROGRAM USE-FLAGS-SYNC.
