*> Test helpers of the block entity and container menu wiring tests (COPY after the test program, after CORETEST.cpy).
*> The test world is the cobolcraft world type, whose built-in content has no containers: TEST-ADD-CONTAINERS appends the blocks and
*> items of the standard set that the container tests need to the core's tables (CBLOCKS.cpy, CITEMS.cpy), in the layouts of the
*> generated block rows (24 part 1 section 3: the last property varies fastest, a bool lists true first):
*>   chest and trapped_chest 24 states facing[north/south/west/east] type[single/left/right] waterlogged, default north single dry,
*>   ender_chest 8 states facing waterlogged, barrel 12 states facing[north/east/south/west/up/down] open, shulker_box 6 states facing, and
*>   (keys without a namespace, as the standard table has them) bell 1 state, white_banner 16 states, chiseled_bookshelf 256 states facing[north/south/west/east] slot_0_occupied .. slot_5_occupied (default 63: north,
*>   nothing occupied), and the item minecraft:book (places nothing); hopper 10 states facing[down,north,south,west,east] enabled, dispenser and dropper 12 states
*>   facing[north/east/south/west/up/down] triggered.
*> The tables are only appended once. The items place the default state of their block.
*>   TEST-ADD-CONTAINERS                          appends the blocks and items
*>   TEST-ITEM-ID USING key (X(48)), id out       the item id of a key (0 when none)
*>   TEST-BLOCK-ID USING key (X(48)), id out      the block id of a key (-1 when none)
*>   TEST-CLICK-WIN USING connection id, slot, button, click type   Container Click on the player's open menu (its container id and state id)
*>   TEST-CLOSE-WIN USING connection id          Container Close of the player's open menu
*>   TEST-BE-AT USING dim, x, y, z, index out   the live block entity at a position (0 none)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ADD-CONTAINERS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY CITEMS.
 01 WS-ROWS.
    05 FILLER PIC X(34) VALUE "minecraft:chest             024001".
    05 FILLER PIC X(34) VALUE "minecraft:trapped_chest     024001".
    05 FILLER PIC X(34) VALUE "minecraft:ender_chest       008001".
    05 FILLER PIC X(34) VALUE "minecraft:barrel            012001".
    05 FILLER PIC X(34) VALUE "minecraft:shulker_box       006004".
    05 FILLER PIC X(34) VALUE "minecraft:red_shulker_box   006004".
    05 FILLER PIC X(34) VALUE "bell                        001000".
    05 FILLER PIC X(34) VALUE "white_banner                016000".
    05 FILLER PIC X(34) VALUE "minecraft:hopper            010000".
    05 FILLER PIC X(34) VALUE "minecraft:dispenser         012001".
    05 FILLER PIC X(34) VALUE "minecraft:dropper           012001".
    05 FILLER PIC X(34) VALUE "minecraft:chiseled_bookshelf256063".
 01 FILLER REDEFINES WS-ROWS.
    05 WS-ROW OCCURS 12 TIMES.
       10 WS-KEY             PIC X(28).
       10 WS-STATES          PIC 999.
       10 WS-DEFAULT         PIC 999.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-B FROM 1 BY 1 UNTIL WS-B > CB-BLOCK-COUNT
         IF CB-KEY(WS-B) = "minecraft:chest"
             GOBACK
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         ADD 1 TO CB-BLOCK-COUNT
         MOVE CB-BLOCK-COUNT TO WS-B
         MOVE SPACES TO CB-KEY(WS-B)
         MOVE WS-KEY(WS-I) TO CB-KEY(WS-B)
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-KEY(WS-I))) TO WS-LENGTH
         MOVE WS-LENGTH TO CB-KEY-LENGTH(WS-B)
         MOVE 0 TO CB-SOLID(WS-B) CB-OPAQUE(WS-B) CB-LIGHT(WS-B) CB-CLASS(WS-B) CB-TOOL-REQ(WS-B) CB-NEED-TIER(WS-B)
         MOVE 2500 TO CB-BREAK-MS(WS-B)
         MOVE CB-STATE-COUNT TO WS-FIRST
         MOVE WS-FIRST TO CB-FIRST-STATE(WS-B)
         MOVE WS-STATES(WS-I) TO CB-STATES(WS-B)
         COMPUTE CB-DEFAULT-STATE(WS-B) = WS-FIRST + WS-DEFAULT(WS-I)
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > WS-STATES(WS-I)
             COMPUTE CB-S-BLOCK(WS-FIRST + WS-S) = WS-B - 1
             MOVE 0 TO CB-S-LIGHT(WS-FIRST + WS-S)
         END-PERFORM
         ADD WS-STATES(WS-I) TO CB-STATE-COUNT
         ADD 1 TO IT-COUNT
         MOVE SPACES TO IT-KEY(IT-COUNT)
         MOVE WS-KEY(WS-I) TO IT-KEY(IT-COUNT)
         MOVE WS-LENGTH TO IT-KEY-LENGTH(IT-COUNT)
         MOVE CB-DEFAULT-STATE(WS-B) TO IT-PLACES-STATE(IT-COUNT)
         MOVE 64 TO IT-MAX-STACK(IT-COUNT)
         IF WS-I = 5 OR WS-I = 6
             MOVE 1 TO IT-MAX-STACK(IT-COUNT)
         END-IF
         MOVE 0 TO IT-TOOL-CLASS(IT-COUNT) IT-FOOD(IT-COUNT) IT-TOOL-SPEED(IT-COUNT) IT-TOOL-TIER(IT-COUNT)
         MOVE 1 TO IT-ATTACK(IT-COUNT)
     END-PERFORM
     ADD 1 TO IT-COUNT
     MOVE SPACES TO IT-KEY(IT-COUNT)
     MOVE "minecraft:book" TO IT-KEY(IT-COUNT)
     MOVE 14 TO IT-KEY-LENGTH(IT-COUNT)
     MOVE -1 TO IT-PLACES-STATE(IT-COUNT)
     MOVE 64 TO IT-MAX-STACK(IT-COUNT)
     MOVE 0 TO IT-TOOL-CLASS(IT-COUNT) IT-FOOD(IT-COUNT) IT-TOOL-SPEED(IT-COUNT) IT-TOOL-TIER(IT-COUNT)
     MOVE 1 TO IT-ATTACK(IT-COUNT)
     GOBACK.
 END PROGRAM TEST-ADD-CONTAINERS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ITEM-ID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-ID.
     MOVE 0 TO L-ID
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IT-COUNT
         IF IT-KEY(WS-I) = L-KEY
             COMPUTE L-ID = WS-I - 1
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TEST-ITEM-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BLOCK-ID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-ID.
     MOVE -1 TO L-ID
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT
         IF CB-KEY(WS-I) = L-KEY
             COMPUTE L-ID = WS-I - 1
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TEST-BLOCK-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CLICK-WIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET-ID           BINARY-LONG VALUE 18.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-BUTTON               BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-SLOT L-BUTTON L-TYPE.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER MN-WINDOW(CN-PLAYER(L-ID))
     CALL "PB-PUT-VARINT" USING PB-BUFFER MN-STATE-ID(CN-PLAYER(L-ID))
     CALL "PB-PUT-SHORT" USING PB-BUFFER L-SLOT
     CALL "PB-PUT-BYTE" USING PB-BUFFER L-BUTTON
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-TYPE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
     CALL "TEST-FEED-BUFFER" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM TEST-CLICK-WIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CLOSE-WIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 16.
 01 WS-PACKET-ID           BINARY-LONG VALUE 19.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER MN-WINDOW(CN-PLAYER(L-ID))
     CALL "TEST-FEED-BUFFER" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM TEST-CLOSE-WIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BE-AT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-INDEX.
     MOVE 0 TO L-INDEX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BE-MAX
         IF BE-USED(WS-I) = 1 AND BE-DIM(WS-I) = L-DIM AND BE-X(WS-I) = L-X AND BE-Y(WS-I) = L-Y AND BE-Z(WS-I) = L-Z
             MOVE WS-I TO L-INDEX
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TEST-BE-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-INPUT.
*> USING connection id, flags (BINARY-LONG): feeds Player Input (05c 0x2B) with the key flags (0x20 shift).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 16.
 01 WS-PACKET-ID           BINARY-LONG VALUE 43.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-FLAGS.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-UBYTE" USING PB-BUFFER L-FLAGS
     CALL "TEST-FEED-BUFFER" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM TEST-INPUT.
