*> Block entities in the live world (docs/protocol/31-block-entities-1-shared-model-and-containers.md sections 2.3, 5.3, 6, 9, 10, 11 and
*> 29 section 12; US12): the wiring of core/src/be-31-1.cob (the model) into the paths that set blocks, save and load chunks and send
*> them. CORE-BE (BESTATE.cpy) holds the live entities of every loaded chunk; an entity of a dimension row 0 is detached (the ender
*> chest of a player, CORE-ENDER).
*>
*> Hooks (one CALL each in existing code): WORLD-SET-BLOCK calls BE-BLOCK-SET after every change of a cell, BLOCK-PLACE calls BE-PLACE-STATE
*> before the block is set, CHUNK-NBT-WRITE and CHUNK-NBT-READ call BE-CHUNK-WRITE and BE-CHUNK-READ for block_entities, CHUNK-PACKET-BUILD
*> calls BE-CHUNK-PACKET, WORLD-CHUNK-RELEASE calls BE-CHUNK-DROP, WORLD-RESET calls BE-RESET, SP-SWEEP calls BE-MARK-PATCHES and the
*> player files call PNBT-ENDER-WRITE and PNBT-ENDER-READ.
*>
*> Entry points:
*>   BE-RESET                                                    forgets every entity (a world was opened)
*>   BE-BLOCK-KEY USING block id, key out (X(48), "minecraft:" + path when the table key has no namespace), length out
*>   BE-BLOCK-TYPE USING block id, block entity type out (-1 none)    the type whose valid blocks hold the block (cached)
*>   BE-BLOCK-FAMILY USING block id, family out                    0 none, 1 chest or trapped chest, 2 ender chest, 3 barrel, 4 shulker box,
*>        5 hopper, 6 dispenser or dropper (their menus count no openers), 7 chiseled bookshelf, 8 furnace, smoker, blast furnace
*>   BE-STATE-FIELDS USING state, family out, direction out, chest type out, flag out
*>        direction 0 north, 1 east, 2 south, 3 west, 4 up, 5 down; chest type 0 single, 1 left, 2 right; flag waterlogged (chest family,
*>        ender chest) or open (barrel). The state index splits from the last property: a bool lists true first (24 part 1 section 3).
*>   BE-STATE-MAKE USING block id, direction, chest type, flag, state out
*>   BE-FIND USING dim, x, y, z, index out                         the live entity at a position (0 none)
*>   BE-MARK-CHUNK USING index                                     setChanged: the entity and its chunk are unsaved
*>   BE-DROP-CONTENTS USING index                                  Containers.dropContents: every stack becomes a ground item
*>   BE-PARTNER-SET USING dim, x, y, z, state                      the neighbour update of a double chest half (no recursion into BE-BLOCK-SET)
*>   BE-BLOCK-SET USING dim, x, y, z, old state, new state         creates and removes the entity with the block
*>   BE-PLACE-STATE USING connection id, PLAY-SERVERBOUND, dim, x, y, z, state in and out    the placed state of the chest family
*>   BE-CHUNK-WRITE / BE-CHUNK-READ / BE-CHUNK-DROP / BE-CHUNK-PACKET                       chunk storage and streaming (section 5.3, 6)
*>   BE-ENDER-GET USING uuid, create flag, index out               the ender chest storage of a player
*>   PNBT-ENDER-WRITE / PNBT-ENDER-READ                           EnderItems of the player file (45-3 section 5)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-RESET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 PROCEDURE DIVISION.
     INITIALIZE CORE-BE CORE-ENDER
     GOBACK.
 END PROGRAM BE-RESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-BLOCK-KEY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-COLONS              BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-BLOCK                BINARY-LONG.
 01 L-KEY                  PIC X(48).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCK L-KEY L-LENGTH.
     MOVE SPACES TO L-KEY
     MOVE 0 TO L-LENGTH
     IF L-BLOCK < 0 OR L-BLOCK >= CB-BLOCK-COUNT
         GOBACK
     END-IF
     MOVE CB-KEY-LENGTH(L-BLOCK + 1) TO WS-LENGTH
     MOVE 0 TO WS-COLONS
     INSPECT CB-KEY(L-BLOCK + 1)(1:WS-LENGTH) TALLYING WS-COLONS FOR ALL ":"
     IF WS-COLONS = 0
         STRING "minecraft:" CB-KEY(L-BLOCK + 1)(1:WS-LENGTH) DELIMITED BY SIZE INTO L-KEY
         COMPUTE L-LENGTH = WS-LENGTH + 10
     ELSE
         MOVE CB-KEY(L-BLOCK + 1) TO L-KEY
         MOVE WS-LENGTH TO L-LENGTH
     END-IF
     GOBACK.
 END PROGRAM BE-BLOCK-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-BLOCK-TYPE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-EPOCH               BINARY-LONG VALUE -1.
 01 WS-CACHE.
    05 WS-CACHED           BINARY-LONG OCCURS 1400 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-BLOCK                BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCK L-TYPE.
     MOVE -1 TO L-TYPE
     IF L-BLOCK < 0 OR L-BLOCK >= CB-BLOCK-COUNT
         GOBACK
     END-IF
     IF WS-EPOCH NOT = CB-EPOCH
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1400
             MOVE -2 TO WS-CACHED(WS-I)
         END-PERFORM
         MOVE CB-EPOCH TO WS-EPOCH
     END-IF
     IF WS-CACHED(L-BLOCK + 1) = -2
         MOVE -1 TO WS-CACHED(L-BLOCK + 1)
         CALL "BE-BLOCK-KEY" USING L-BLOCK WS-KEY WS-LENGTH
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 48
             CALL "BE-VALID-BLOCK" USING WS-I WS-KEY WS-LENGTH WS-OK
             IF WS-OK = 1 AND WS-CACHED(L-BLOCK + 1) = -1
                 MOVE WS-I TO WS-CACHED(L-BLOCK + 1)
             END-IF
         END-PERFORM
     END-IF
     MOVE WS-CACHED(L-BLOCK + 1) TO L-TYPE
     GOBACK.
 END PROGRAM BE-BLOCK-TYPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-BLOCK-FAMILY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-START               BINARY-LONG.
 LINKAGE SECTION.
 01 L-BLOCK                BINARY-LONG.
 01 L-FAMILY               BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCK L-FAMILY.
     MOVE 0 TO L-FAMILY
     CALL "BE-BLOCK-KEY" USING L-BLOCK WS-KEY WS-LENGTH
     EVALUATE TRUE
         WHEN WS-KEY = "minecraft:chest" OR WS-KEY = "minecraft:trapped_chest"
             MOVE 1 TO L-FAMILY
         WHEN WS-KEY = "minecraft:ender_chest"
             MOVE 2 TO L-FAMILY
         WHEN WS-KEY = "minecraft:barrel"
             MOVE 3 TO L-FAMILY
         WHEN WS-KEY = "minecraft:chiseled_bookshelf"
             MOVE 7 TO L-FAMILY
         WHEN WS-KEY = "minecraft:furnace" OR WS-KEY = "minecraft:smoker" OR WS-KEY = "minecraft:blast_furnace"
             MOVE 8 TO L-FAMILY
         WHEN WS-KEY = "minecraft:hopper"
             MOVE 5 TO L-FAMILY
         WHEN WS-KEY = "minecraft:dispenser" OR WS-KEY = "minecraft:dropper"
             MOVE 6 TO L-FAMILY
         WHEN WS-LENGTH >= 21
             COMPUTE WS-START = WS-LENGTH - 10
             IF WS-KEY(WS-START:11) = "shulker_box"
                 MOVE 4 TO L-FAMILY
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM BE-BLOCK-FAMILY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-STATE-FIELDS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-FACE                BINARY-LONG.
 01 WS-PICK                BINARY-LONG.
 01 WS-FROM-PROP.
    05 FILLER              PIC X(4) VALUE "0231".
 01 FILLER REDEFINES WS-FROM-PROP.
    05 WS-DIRECTION        PIC 9 OCCURS 4 TIMES.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-FAMILY               BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FAMILY L-DIR L-TYPE L-FLAG.
     MOVE 0 TO L-FAMILY L-DIR L-TYPE L-FLAG
     IF L-STATE < 0 OR L-STATE >= CB-STATE-COUNT
         GOBACK
     END-IF
     MOVE CB-S-BLOCK(L-STATE + 1) TO WS-BLOCK
     CALL "BE-BLOCK-FAMILY" USING WS-BLOCK L-FAMILY
     COMPUTE WS-INDEX = L-STATE - CB-FIRST-STATE(WS-BLOCK + 1)
     COMPUTE WS-PICK = FUNCTION MOD(WS-INDEX, 2)
     EVALUATE L-FAMILY
         WHEN 1
             COMPUTE L-FLAG = 1 - WS-PICK
             COMPUTE WS-INDEX = WS-INDEX / 2
             COMPUTE L-TYPE = FUNCTION MOD(WS-INDEX, 3)
             COMPUTE WS-FACE = WS-INDEX / 3
             MOVE WS-DIRECTION(WS-FACE + 1) TO L-DIR
         WHEN 2
             COMPUTE L-FLAG = 1 - WS-PICK
             COMPUTE WS-FACE = WS-INDEX / 2
             MOVE WS-DIRECTION(WS-FACE + 1) TO L-DIR
         WHEN 3
             COMPUTE L-FLAG = 1 - WS-PICK
             COMPUTE L-DIR = WS-INDEX / 2
         WHEN 4
             MOVE WS-INDEX TO L-DIR
*>       The furnaces: facing[north/south/west/east] lit (true first); the flag is lit.
         WHEN 8
             COMPUTE L-FLAG = 1 - WS-PICK
             COMPUTE WS-FACE = WS-INDEX / 2
             MOVE WS-DIRECTION(WS-FACE + 1) TO L-DIR
*>       The chiseled bookshelf: facing[north/south/west/east] then slot_0_occupied .. slot_5_occupied (true first); the type out is the
*>       occupancy mask (bit i set when slot i is occupied).
         WHEN 7
             COMPUTE WS-FACE = WS-INDEX / 64
             MOVE WS-DIRECTION(WS-FACE + 1) TO L-DIR
             COMPUTE WS-PICK = FUNCTION MOD(WS-INDEX, 64)
             PERFORM VARYING WS-FACE FROM 0 BY 1 UNTIL WS-FACE > 5
                 COMPUTE WS-INDEX = WS-PICK / (2 ** (5 - WS-FACE))
                 IF FUNCTION MOD(WS-INDEX, 2) = 0
                     COMPUTE L-TYPE = L-TYPE + 2 ** WS-FACE
                 END-IF
             END-PERFORM
     END-EVALUATE
     GOBACK.
 END PROGRAM BE-STATE-FIELDS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-STATE-MAKE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-FAMILY              BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-FACE                BINARY-LONG.
 01 WS-BITS                BINARY-LONG.
 01 WS-TO-PROP.
    05 FILLER              PIC X(4) VALUE "0312".
 01 FILLER REDEFINES WS-TO-PROP.
    05 WS-PROP             PIC 9 OCCURS 4 TIMES.
 LINKAGE SECTION.
 01 L-BLOCK                BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCK L-DIR L-TYPE L-FLAG L-STATE.
     CALL "BE-BLOCK-FAMILY" USING L-BLOCK WS-FAMILY
     MOVE CB-DEFAULT-STATE(L-BLOCK + 1) TO L-STATE
     COMPUTE WS-INDEX = L-STATE - CB-FIRST-STATE(L-BLOCK + 1)
     EVALUATE WS-FAMILY
         WHEN 1
             MOVE WS-PROP(L-DIR + 1) TO WS-FACE
             COMPUTE WS-INDEX = (WS-FACE * 3 + L-TYPE) * 2 + 1 - L-FLAG
         WHEN 2
             MOVE WS-PROP(L-DIR + 1) TO WS-FACE
             COMPUTE WS-INDEX = WS-FACE * 2 + 1 - L-FLAG
         WHEN 3
             COMPUTE WS-INDEX = L-DIR * 2 + 1 - L-FLAG
         WHEN 4
             MOVE L-DIR TO WS-INDEX
         WHEN 8
             MOVE WS-PROP(L-DIR + 1) TO WS-FACE
             COMPUTE WS-INDEX = WS-FACE * 2 + 1 - L-FLAG
         WHEN 7
             MOVE WS-PROP(L-DIR + 1) TO WS-FACE
             COMPUTE WS-INDEX = WS-FACE * 64 + 63
             PERFORM VARYING WS-FACE FROM 0 BY 1 UNTIL WS-FACE > 5
                 COMPUTE WS-BITS = L-TYPE / (2 ** WS-FACE)
                 IF FUNCTION MOD(WS-BITS, 2) = 1
                     COMPUTE WS-INDEX = WS-INDEX - 2 ** (5 - WS-FACE)
                 END-IF
             END-PERFORM
     END-EVALUATE
     COMPUTE L-STATE = CB-FIRST-STATE(L-BLOCK + 1) + WS-INDEX
     GOBACK.
 END PROGRAM BE-STATE-MAKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-FIND.
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
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BE-MAX OR L-INDEX > 0
         IF BE-USED(WS-I) = 1 AND BE-DIM(WS-I) = L-DIM AND BE-X(WS-I) = L-X AND BE-Y(WS-I) = L-Y AND BE-Z(WS-I) = L-Z
             MOVE WS-I TO L-INDEX
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BE-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-MARK-CHUNK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BESTATE.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-NO-NEIGHBOURS       BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX.
     CALL "BE-SET-CHANGED" USING L-INDEX WS-AIR WS-NO-NEIGHBOURS
     IF BE-DIM(L-INDEX) > 0
         COMPUTE WS-OX = FUNCTION MOD(BE-X(L-INDEX), 16)
         COMPUTE WS-OZ = FUNCTION MOD(BE-Z(L-INDEX), 16)
         COMPUTE WS-CX = (BE-X(L-INDEX) - WS-OX) / 16
         COMPUTE WS-CZ = (BE-Z(L-INDEX) - WS-OZ) / 16
         CALL "WORLD-FIND" USING BE-DIM(L-INDEX) WS-CX WS-CZ WS-ROW
         IF WS-ROW > 0
             MOVE 1 TO CK-CHANGED(WS-ROW)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BE-MARK-CHUNK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-DROP-STACK.
*> Containers.dropItemStack (31-2 section 2 item 7): USING dim, x, y, z (block position), item, count, patch handle. The position inside the block
*> box (w = 0.25, the item entity's width): x = floor(x) + d1 * 0.75 + 0.125, y = floor(y) + d2 * 0.75, z = floor(z) + d3 * 0.75 + 0.125 with the three
*> nextDouble draws made first; then, while the stack lasts, one draw gives the stack size 10 + nextInt(21) and the item is spawned (pickup delay 10)
*> with the velocity triangle(0, 0.11485), triangle(0.2, 0.11485), triangle(0, 0.11485) in the order x, y, z. The random source is the level's
*> (IP-LEVEL-DOUBLE); nextInt(21) is floor(nextDouble * 21).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D                   FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-SPAN                FLOAT-LONG VALUE 0.75.
 01 WS-SPREAD              FLOAT-LONG VALUE 0.11485.
 01 WS-DELAY               BINARY-LONG VALUE 10.
 01 WS-LEFT                BINARY-LONG.
 01 WS-CHUNK               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-ITEM L-COUNT L-VAR.
     CALL "IP-LEVEL-DOUBLE" USING WS-D
     COMPUTE WS-FX = L-X + WS-D * WS-SPAN + 0.125
     CALL "IP-LEVEL-DOUBLE" USING WS-D
     COMPUTE WS-FY = L-Y + WS-D * WS-SPAN
     CALL "IP-LEVEL-DOUBLE" USING WS-D
     COMPUTE WS-FZ = L-Z + WS-D * WS-SPAN + 0.125
     MOVE L-COUNT TO WS-LEFT
     PERFORM UNTIL WS-LEFT <= 0
         CALL "IP-LEVEL-DOUBLE" USING WS-D
         COMPUTE WS-CHUNK = 10 + FUNCTION INTEGER(WS-D * 21)
         IF WS-CHUNK > WS-LEFT
             MOVE WS-LEFT TO WS-CHUNK
         END-IF
         CALL "IP-LEVEL-DOUBLE" USING WS-D
         CALL "IP-LEVEL-DOUBLE" USING WS-D2
         COMPUTE WS-VX = WS-SPREAD * (WS-D - WS-D2)
         CALL "IP-LEVEL-DOUBLE" USING WS-D
         CALL "IP-LEVEL-DOUBLE" USING WS-D2
         COMPUTE WS-VY = 0.2 + WS-SPREAD * (WS-D - WS-D2)
         CALL "IP-LEVEL-DOUBLE" USING WS-D
         CALL "IP-LEVEL-DOUBLE" USING WS-D2
         COMPUTE WS-VZ = WS-SPREAD * (WS-D - WS-D2)
         CALL "GI-SPAWN-X" USING L-DIM WS-FX WS-FY WS-FZ WS-VX WS-VY WS-VZ L-ITEM WS-CHUNK WS-DELAY WS-ROW L-VAR
         SUBTRACT WS-CHUNK FROM WS-LEFT
     END-PERFORM
     GOBACK.
 END PROGRAM BE-DROP-STACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-DROP-CONTENTS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-S                   BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX.
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 27
         IF BE-SLOT-COUNT(L-INDEX, WS-S) > 0
             MOVE BE-SLOT-ITEM(L-INDEX, WS-S) TO WS-ITEM
             MOVE BE-SLOT-COUNT(L-INDEX, WS-S) TO WS-COUNT
             MOVE BE-SLOT-VAR(L-INDEX, WS-S) TO WS-VAR
             MOVE 0 TO BE-SLOT-ITEM(L-INDEX, WS-S) BE-SLOT-COUNT(L-INDEX, WS-S) BE-SLOT-VAR(L-INDEX, WS-S)
             CALL "BE-DROP-STACK" USING BE-DIM(L-INDEX) BE-X(L-INDEX) BE-Y(L-INDEX) BE-Z(L-INDEX) WS-ITEM WS-COUNT WS-VAR
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BE-DROP-CONTENTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-PARTNER-SET.
*> A cell rewritten without the hooks of WORLD-SET-BLOCK (that program is active when this one runs): the cell, its chunk's changed flag
*> and a Block Update to the viewers. The light does not depend on the state of a chest.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY CELLS.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
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
     CALL "WORLD-FIND" USING L-DIM WS-CX WS-CZ WS-ROW
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     MOVE L-STATE TO CE-STATE((L-Y - DM-MIN-Y(L-DIM)) * 256 + (L-Z - WS-CZ * 16) * 16 + L-X - WS-CX * 16 + 1)
     MOVE 1 TO CK-CHANGED(WS-ROW)
     CALL "PB-RESET" USING PB-BUFFER
     CALL "BLOCK-UPDATE-BUILD" USING L-X L-Y L-Z L-STATE PB-BUFFER
     CALL "VIEWERS-SEND" USING L-DIM WS-CX WS-CZ WS-NONE PB-BUFFER
     GOBACK.
 END PROGRAM BE-PARTNER-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-BLOCK-SET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY BESTATE.
 01 WS-OLD-BLOCK           BINARY-LONG.
 01 WS-NEW-BLOCK           BINARY-LONG.
 01 WS-OLD-TYPE            BINARY-LONG.
 01 WS-NEW-TYPE            BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FAMILY              BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-PSTATE              BINARY-LONG.
 01 WS-PFAMILY             BINARY-LONG.
 01 WS-PDIR                BINARY-LONG.
 01 WS-PTYPE               BINARY-LONG.
 01 WS-PFLAG               BINARY-LONG.
 01 WS-SINGLE              BINARY-LONG VALUE 0.
 01 WS-HANDLED             BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OLD                  BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-OLD L-NEW.
     MOVE CB-S-BLOCK(L-OLD + 1) TO WS-OLD-BLOCK
     MOVE CB-S-BLOCK(L-NEW + 1) TO WS-NEW-BLOCK
     IF WS-OLD-BLOCK = WS-NEW-BLOCK
         GOBACK
     END-IF
     CALL "BE-BLOCK-TYPE" USING WS-OLD-BLOCK WS-OLD-TYPE
     CALL "BE-BLOCK-TYPE" USING WS-NEW-BLOCK WS-NEW-TYPE
     IF WS-OLD-TYPE >= 0
         CALL "BE-FIND" USING L-DIM L-X L-Y L-Z WS-INDEX
         IF WS-INDEX > 0
             MOVE 0 TO WS-HANDLED
             IF WS-OLD-TYPE = 24
                 CALL "BE-SHULKER-DROP" USING WS-INDEX WS-OLD-BLOCK WS-HANDLED
             END-IF
             IF WS-HANDLED = 0
                 CALL "BE-DROP-CONTENTS" USING WS-INDEX
             END-IF
             MOVE 1 TO WS-FLAG
             CALL "BE-SET-REMOVED" USING WS-INDEX WS-FLAG
             MOVE 0 TO BE-USED(WS-INDEX)
         END-IF
*>       A half of a double chest that goes leaves its partner a single chest.
         CALL "BE-STATE-FIELDS" USING L-OLD WS-FAMILY WS-DIR WS-TYPE WS-FLAG
         IF WS-FAMILY = 1 AND WS-TYPE NOT = 0
             CALL "BE-CHEST-CONNECTED" USING WS-DIR WS-TYPE WS-DX WS-DZ
             COMPUTE WS-PX = L-X + WS-DX
             COMPUTE WS-PZ = L-Z + WS-DZ
             CALL "WORLD-GET-BLOCK" USING L-DIM WS-PX L-Y WS-PZ WS-PSTATE
             CALL "BE-STATE-FIELDS" USING WS-PSTATE WS-PFAMILY WS-PDIR WS-PTYPE WS-PFLAG
             IF CB-S-BLOCK(WS-PSTATE + 1) = WS-OLD-BLOCK AND WS-PTYPE NOT = 0
                 CALL "BE-STATE-MAKE" USING WS-OLD-BLOCK WS-PDIR WS-SINGLE WS-PFLAG WS-PSTATE
                 CALL "BE-PARTNER-SET" USING L-DIM WS-PX L-Y WS-PZ WS-PSTATE
             END-IF
         END-IF
     END-IF
     IF WS-NEW-TYPE >= 0
         CALL "BE-BLOCK-KEY" USING WS-NEW-BLOCK WS-KEY WS-LENGTH
         CALL "BE-CREATE" USING L-DIM L-X L-Y L-Z WS-NEW-TYPE WS-KEY WS-LENGTH WS-INDEX
         IF WS-NEW-TYPE = 24 AND WS-INDEX > 0
             CALL "BE-SHULKER-RESTORE" USING L-DIM L-X L-Y L-Z WS-INDEX
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BE-BLOCK-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-PLACE-STATE.
*> The placed state of the chest family (31-1 section 10.2 and the block rows of 24): a chest or trapped chest faces the player (the
*> opposite of the horizontal look direction) and becomes the left half when a single chest of the same block and facing stands on the
*> side clockwise from its facing (that chest becomes the right half), else the right half when one stands counter-clockwise. The
*> sneaking placement against a clicked side follows the clicked chest (PL-SNEAKING). An ender chest faces the player, a barrel
*> faces opposite to the look direction (up or down when the pitch is steeper than 45 degrees), a shulker box faces the clicked face.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY BESTATE.
 01 WS-DELTA-X.
    05 FILLER              PIC X(4) VALUE "1210".
 01 FILLER REDEFINES WS-DELTA-X.
    05 WS-DXC              PIC 9 OCCURS 4 TIMES.
 01 WS-DELTA-Z.
    05 FILLER              PIC X(4) VALUE "0121".
 01 FILLER REDEFINES WS-DELTA-Z.
    05 WS-DZC              PIC 9 OCCURS 4 TIMES.
 01 WS-LOOK.
    05 FILLER              PIC X(4) VALUE "2301".
 01 FILLER REDEFINES WS-LOOK.
    05 WS-LOOK-DIR         PIC 9 OCCURS 4 TIMES.
 01 WS-FACE-DIR.
    05 FILLER              PIC X(6) VALUE "540231".
 01 FILLER REDEFINES WS-FACE-DIR.
    05 WS-FACE-TO-DIR      PIC 9 OCCURS 6 TIMES.
 01 WS-ROW                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-FAMILY              BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-LOOKED              BINARY-LONG.
 01 WS-SIDE                BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-PSTATE              BINARY-LONG.
 01 WS-PFAMILY             BINARY-LONG.
 01 WS-PDIR                BINARY-LONG.
 01 WS-PTYPE               BINARY-LONG.
 01 WS-PFLAG               BINARY-LONG.
 01 WS-PARTNER-TYPE        BINARY-LONG.
 01 WS-CLICKED             BINARY-LONG.
 01 WS-OPPOSITE            BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND L-DIM L-X L-Y L-Z L-STATE.
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     MOVE CB-S-BLOCK(L-STATE + 1) TO WS-BLOCK
     CALL "BE-STATE-FIELDS" USING L-STATE WS-FAMILY WS-DIR WS-TYPE WS-FLAG
     IF WS-FAMILY = 0
         GOBACK
     END-IF
     COMPUTE WS-LOOKED = FUNCTION MOD(FUNCTION INTEGER(PL-YAW(WS-ROW) / 90 + 0.5), 4)
     MOVE WS-LOOK-DIR(WS-LOOKED + 1) TO WS-LOOKED
     COMPUTE WS-DIR = FUNCTION MOD(WS-LOOKED + 2, 4)
     MOVE 0 TO WS-TYPE
     EVALUATE WS-FAMILY
         WHEN 1
*>           Sneaking against the side of a chest: the single chest of the same block clicked (a horizontal face) gives its facing when its axis
*>           is not the clicked one; the new chest is the right half when that facing's counter-clockwise side is the side clicked.
             IF PL-SNEAKING(WS-ROW) = 1 AND PSB-FACE >= 2 AND PSB-FACE <= 5
                 MOVE WS-FACE-TO-DIR(PSB-FACE + 1) TO WS-CLICKED
                 COMPUTE WS-OPPOSITE = FUNCTION MOD(WS-CLICKED + 2, 4)
                 CALL "WORLD-GET-BLOCK" USING L-DIM PSB-BX PSB-BY PSB-BZ WS-PSTATE
                 CALL "BE-STATE-FIELDS" USING WS-PSTATE WS-PFAMILY WS-PDIR WS-PTYPE WS-PFLAG
                 IF CB-S-BLOCK(WS-PSTATE + 1) = WS-BLOCK AND WS-PTYPE = 0
                         AND FUNCTION MOD(WS-PDIR, 2) NOT = FUNCTION MOD(WS-CLICKED, 2)
                     MOVE WS-PDIR TO WS-DIR
                     MOVE 1 TO WS-TYPE
                     MOVE 2 TO WS-PARTNER-TYPE
                     IF FUNCTION MOD(WS-PDIR + 3, 4) = WS-OPPOSITE
                         MOVE 2 TO WS-TYPE
                         MOVE 1 TO WS-PARTNER-TYPE
                     END-IF
                     MOVE PSB-BX TO WS-PX
                     MOVE PSB-BZ TO WS-PZ
                     CALL "BE-STATE-MAKE" USING WS-BLOCK WS-PDIR WS-PARTNER-TYPE WS-PFLAG WS-PSTATE
                     CALL "BE-PARTNER-SET" USING L-DIM WS-PX L-Y WS-PZ WS-PSTATE
                 END-IF
             END-IF
             PERFORM VARYING WS-STEP FROM 1 BY 2 UNTIL WS-STEP > 3 OR WS-TYPE NOT = 0 OR PL-SNEAKING(WS-ROW) = 1
                 COMPUTE WS-SIDE = FUNCTION MOD(WS-DIR + WS-STEP, 4)
                 COMPUTE WS-PX = L-X + WS-DXC(WS-SIDE + 1) - 1
                 COMPUTE WS-PZ = L-Z + WS-DZC(WS-SIDE + 1) - 1
                 CALL "WORLD-GET-BLOCK" USING L-DIM WS-PX L-Y WS-PZ WS-PSTATE
                 CALL "BE-STATE-FIELDS" USING WS-PSTATE WS-PFAMILY WS-PDIR WS-PTYPE WS-PFLAG
                 IF CB-S-BLOCK(WS-PSTATE + 1) = WS-BLOCK AND WS-PTYPE = 0 AND WS-PDIR = WS-DIR
                     IF WS-STEP = 1
                         MOVE 1 TO WS-TYPE
                         MOVE 2 TO WS-PARTNER-TYPE
                     ELSE
                         MOVE 2 TO WS-TYPE
                         MOVE 1 TO WS-PARTNER-TYPE
                     END-IF
                     CALL "BE-STATE-MAKE" USING WS-BLOCK WS-PDIR WS-PARTNER-TYPE WS-PFLAG WS-PSTATE
                     CALL "BE-PARTNER-SET" USING L-DIM WS-PX L-Y WS-PZ WS-PSTATE
                 END-IF
             END-PERFORM
         WHEN 3
             IF PL-PITCH(WS-ROW) > 45
                 MOVE 4 TO WS-DIR
             END-IF
             IF PL-PITCH(WS-ROW) < -45
                 MOVE 5 TO WS-DIR
             END-IF
         WHEN 4
             MOVE WS-FACE-TO-DIR(PSB-FACE + 1) TO WS-DIR
     END-EVALUATE
     CALL "BE-STATE-MAKE" USING WS-BLOCK WS-DIR WS-TYPE WS-FLAG L-STATE
     IF WS-FAMILY = 4
         MOVE 1 TO BP-SET
         MOVE L-DIM TO BP-DIM
         MOVE L-X TO BP-X
         MOVE L-Y TO BP-Y
         MOVE L-Z TO BP-Z
         MOVE PL-SLOT-VAR(WS-ROW, PL-HELD(WS-ROW) + 1) TO BP-VAR
     END-IF
     GOBACK.
 END PROGRAM BE-PLACE-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-UNKNOWN-SCAN.
*> USING old PB-BUFFER (a chunk payload at its root payload; its position is restored), slices (a table of 256 start and end
*> byte offsets), count out (BINARY-LONG): the compounds of its block_entities list whose id names no block entity type of the
*> core (31-1 section 3.1; such an entry is dropped when the chunk loads). The bytes START + 1 to END of each are its
*> compound payload; more than 256 are not kept (07 section 10.7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 32.
 01 WS-TYPE                BINARY-LONG.
 01 WS-INNER-TYPE          BINARY-LONG.
 01 WS-ELEMENT-TYPE        BINARY-LONG.
 01 WS-LIST-COUNT          BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-HOME                BINARY-LONG.
 01 WS-ID                  PIC X(64).
 01 WS-ID-CAPACITY         BINARY-LONG VALUE 64.
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-BE-TYPE             BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-SLICES.
    05 L-SLICE OCCURS 256 TIMES.
       10 L-SLICE-START    BINARY-LONG.
       10 L-SLICE-END      BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-SLICES L-COUNT.
     MOVE 0 TO L-COUNT
     MOVE PB-POS TO WS-HOME
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         IF WN = "block_entities" AND WS-TYPE = 9
             CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-LIST-COUNT
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-LIST-COUNT OR PB-ERROR = 1
                 MOVE PB-POS TO WS-START
                 MOVE -1 TO WS-BE-TYPE
                 PERFORM UNTIL PB-ERROR = 1
                     MOVE SPACES TO WN
                     CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-INNER-TYPE WN WS-CAPACITY WL
                     IF WS-INNER-TYPE = 0
                         EXIT PERFORM
                     END-IF
                     IF WN = "id" AND WS-INNER-TYPE = 8
                         MOVE SPACES TO WS-ID
                         CALL "NBT-READ-STRING" USING PB-BUFFER WS-ID WS-ID-CAPACITY WS-ID-LENGTH
                         MOVE SPACES TO WS-KEY
                         MOVE WS-ID-LENGTH TO WS-KEY-LENGTH
                         IF WS-ID(1:10) = "minecraft:"
                             SUBTRACT 10 FROM WS-KEY-LENGTH
                             MOVE WS-ID(11:14) TO WS-KEY
                         ELSE
                             MOVE WS-ID(1:24) TO WS-KEY
                         END-IF
                         IF WS-KEY-LENGTH <= 24
                             CALL "BE-TYPE-ID" USING WS-KEY WS-KEY-LENGTH WS-BE-TYPE
                         END-IF
                     ELSE
                         CALL "NBT-READ-SKIP" USING PB-BUFFER WS-INNER-TYPE
                     END-IF
                 END-PERFORM
                 IF PB-ERROR = 0 AND WS-BE-TYPE < 0 AND L-COUNT < 256
                     ADD 1 TO L-COUNT
                     MOVE WS-START TO L-SLICE-START(L-COUNT)
                     MOVE PB-POS TO L-SLICE-END(L-COUNT)
                 END-IF
             END-PERFORM
         ELSE
             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-IF
     END-PERFORM
     MOVE WS-HOME TO PB-POS
     MOVE 0 TO PB-ERROR
     GOBACK.
 END PROGRAM BE-UNKNOWN-SCAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-CHUNK-WRITE-MERGE.
*> USING dim, chunk x, chunk z, PB-BUFFER, old PB-BUFFER (the chunk as the file holds it, at its root payload; its position is kept),
*> found (BINARY-LONG, 1 when the old chunk is given): the block_entities list of a saved chunk (31-1 section 6 step 1): one compound
*> per live entity of the chunk, its full form with keepPacked false, then the old chunk's compounds of types the core does not
*> know as they were (BE-UNKNOWN-SCAN, 07 section 10.7); an empty list of no type when there are none.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WN                     PIC X(16).
 01 WL                     BINARY-LONG.
 01 WS-ELEMENT             BINARY-LONG VALUE -1.
 01 WS-T-NONE              BINARY-LONG VALUE 0.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-UNKNOWN-COUNT       BINARY-LONG.
 01 WS-SLICES.
    05 WS-SLICE OCCURS 256 TIMES.
       10 WS-SLICE-START   BINARY-LONG.
       10 WS-SLICE-END     BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-POINTER             USAGE POINTER.
 01 B-SLICE                PIC X BASED.
 LINKAGE SECTION.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WK-==.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ PB-BUFFER WK-BUFFER L-FOUND.
     MOVE 0 TO WS-UNKNOWN-COUNT
     IF L-FOUND = 1
         CALL "BE-UNKNOWN-SCAN" USING WK-BUFFER WS-SLICES WS-UNKNOWN-COUNT
     END-IF
     MOVE "block_entities" TO WN
     MOVE 14 TO WL
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BE-MAX
         CALL "BE-IN-CHUNK" USING WS-I L-DIM L-CX L-CZ WS-IN
         ADD WS-IN TO WS-N
     END-PERFORM
     ADD WS-UNKNOWN-COUNT TO WS-N
     IF WS-N = 0
         CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-NONE WS-ZERO
         GOBACK
     END-IF
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-COMPOUND WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BE-MAX
         CALL "BE-IN-CHUNK" USING WS-I L-DIM L-CX L-CZ WS-IN
         IF WS-IN = 1
             CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WS-ELEMENT
             CALL "BE-SAVE-CHUNK" USING WS-I PB-BUFFER
             CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-UNKNOWN-COUNT
         COMPUTE WS-SIZE = WS-SLICE-END(WS-I) - WS-SLICE-START(WS-I)
         SET WS-POINTER TO WK-ADDR
         SET WS-POINTER UP BY WS-SLICE-START(WS-I)
         SET ADDRESS OF B-SLICE TO WS-POINTER
         CALL "PB-APPEND-BYTES" USING PB-BUFFER B-SLICE WS-SIZE
     END-PERFORM
     CALL "NBT-WRITE-LIST-END" USING PB-BUFFER
     GOBACK.
 END PROGRAM BE-CHUNK-WRITE-MERGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-IN-CHUNK.
*> USING index, dim, chunk x, chunk z, result out: 1 when the entity is live and stands in that chunk of that dimension.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-OX                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-DIM L-CX L-CZ L-RESULT.
     MOVE 0 TO L-RESULT
     IF BE-USED(L-INDEX) = 1 AND BE-DIM(L-INDEX) = L-DIM
         COMPUTE WS-OX = FUNCTION MOD(BE-X(L-INDEX), 16)
         COMPUTE WS-OZ = FUNCTION MOD(BE-Z(L-INDEX), 16)
         COMPUTE WS-CX = (BE-X(L-INDEX) - WS-OX) / 16
         COMPUTE WS-CZ = (BE-Z(L-INDEX) - WS-OZ) / 16
         IF WS-CX = L-CX AND WS-CZ = L-CZ
             MOVE 1 TO L-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BE-IN-CHUNK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-CHUNK-READ.
*> USING PB-BUFFER (at the first element of the block_entities list payload), element count, cache row: reads the entities of a loaded chunk
*> (31-1 section 6 step 2). The entry's position is read first (an entry may list x, y, z in any order) to find the block at it in the
*> chunk's cells; a refused or unknown entry is dropped (BE-LOAD-CHUNK-ENTRY results 2 and 3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY CELLS.
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 32.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-RX                  BINARY-LONG.
 01 WS-RY                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-MOVED               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-COUNT                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-COUNT L-ROW.
     MOVE CK-DIM(L-ROW) TO WS-DIM
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(L-ROW)
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > L-COUNT OR PB-ERROR = 1
         MOVE PB-POS TO WS-START
         MOVE 0 TO WS-X WS-Y WS-Z
         PERFORM UNTIL PB-ERROR = 1
             MOVE SPACES TO WN
             CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-NAME-CAPACITY WL
             IF WS-TYPE = 0
                 EXIT PERFORM
             END-IF
             EVALUATE TRUE
                 WHEN WN = "x" AND WS-TYPE = 3
                     CALL "PB-GET-INT" USING PB-BUFFER WS-X
                 WHEN WN = "y" AND WS-TYPE = 3
                     CALL "PB-GET-INT" USING PB-BUFFER WS-Y
                 WHEN WN = "z" AND WS-TYPE = 3
                     CALL "PB-GET-INT" USING PB-BUFFER WS-Z
                 WHEN OTHER
                     CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
             END-EVALUATE
         END-PERFORM
         MOVE WS-START TO PB-POS
         CALL "BE-POS-FROM-TAG" USING CK-X(L-ROW) CK-Z(L-ROW) WS-X WS-Y WS-Z WS-RX WS-RY WS-RZ WS-MOVED
         MOVE 0 TO WS-STATE
         IF WS-RY >= DM-MIN-Y(WS-DIM) AND WS-RY < DM-MIN-Y(WS-DIM) + DM-HEIGHT(WS-DIM)
             MOVE CE-STATE((WS-RY - DM-MIN-Y(WS-DIM)) * 256 + (WS-RZ - CK-Z(L-ROW) * 16) * 16 + WS-RX - CK-X(L-ROW) * 16 + 1)
                 TO WS-STATE
         END-IF
         MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
         CALL "BE-BLOCK-KEY" USING WS-BLOCK WS-KEY WS-LENGTH
         CALL "BE-LOAD-CHUNK-ENTRY" USING PB-BUFFER WS-DIM CK-X(L-ROW) CK-Z(L-ROW) WS-KEY WS-LENGTH WS-RESULT WS-INDEX
     END-PERFORM
     GOBACK.
 END PROGRAM BE-CHUNK-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-CHUNK-DROP.
*> USING dim, chunk x, chunk z: the chunk leaves the cache (it was written first when changed): its entities leave with it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BE-MAX
         CALL "BE-IN-CHUNK" USING WS-I L-DIM L-CX L-CZ WS-IN
         IF WS-IN = 1
             MOVE 0 TO BE-USED(WS-I)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BE-CHUNK-DROP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-CHUNK-PACKET.
*> USING dim, chunk x, chunk z, count out, heads out (5 BINARY-LONG per entry: local x, y, local z, type, data length), data out (the data
*> bytes of all entries back to back): the block entities of the Level Chunk packet (06 section 3.2, 31-1 section 5.3). An entity whose
*> update tag is empty has data length 0 (an absent tag). At most 64 entries; the data area holds 1024 bytes of tag for each.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-ROOT                BINARY-LONG VALUE -2.
 01 WS-BYTES               PIC X(4096) BASED.
 01 WN                     PIC X.
 01 WS-I                   BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-HEAD                BINARY-LONG.
 01 WS-OFFSET              BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-PACKED              BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-PRESENT             BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-HEADS.
    05 L-HEAD              BINARY-LONG OCCURS 320 TIMES.
 01 L-DATA                 PIC X(65536).
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ L-COUNT L-HEADS L-DATA.
     MOVE 0 TO L-COUNT WS-OFFSET
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BE-MAX
         CALL "BE-IN-CHUNK" USING WS-I L-DIM L-CX L-CZ WS-IN
         IF WS-IN = 1 AND L-COUNT < 64
             CALL "BE-CHUNK-ENTRY" USING WS-I WS-PACKED WS-Y WS-TYPE WS-PRESENT
             MOVE 0 TO WS-LENGTH
             IF WS-PRESENT = 1
                 CALL "PB-INIT" USING WK-BUFFER WS-CAPACITY
                 CALL "NBT-WRITE-COMPOUND-BEGIN" USING WK-BUFFER WN WS-ROOT
                 CALL "BE-TAG-ENTRIES" USING WS-I WK-BUFFER
                 CALL "NBT-WRITE-COMPOUND-END" USING WK-BUFFER
                 SET ADDRESS OF WS-BYTES TO WK-ADDR
                 MOVE WK-LENGTH TO WS-LENGTH
                 MOVE WS-BYTES(1:WS-LENGTH) TO L-DATA(WS-OFFSET + 1:WS-LENGTH)
                 CALL "PB-FREE" USING WK-BUFFER
                 ADD WS-LENGTH TO WS-OFFSET
             END-IF
             COMPUTE WS-HEAD = L-COUNT * 5
             COMPUTE L-HEAD(WS-HEAD + 1) = FUNCTION MOD(BE-X(WS-I), 16)
             MOVE WS-Y TO L-HEAD(WS-HEAD + 2)
             COMPUTE L-HEAD(WS-HEAD + 3) = FUNCTION MOD(BE-Z(WS-I), 16)
             MOVE WS-TYPE TO L-HEAD(WS-HEAD + 4)
             MOVE WS-LENGTH TO L-HEAD(WS-HEAD + 5)
             ADD 1 TO L-COUNT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BE-CHUNK-PACKET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-MARK-PATCHES.
*> USING marks (512 BINARY-LONG): marks the pool entries the slots of every live entity refer to (SP-SWEEP).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-MARKS.
    05 L-MARK              BINARY-LONG OCCURS 512 TIMES.
 PROCEDURE DIVISION USING L-MARKS.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BE-MAX
         IF BE-USED(WS-I) = 1
             PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 27
                 CALL "SP-MARK" USING L-MARKS BE-SLOT-VAR(WS-I, WS-S)
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BE-MARK-PATCHES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-ENDER-GET.
*> USING uuid (X(16)), create flag, index out: the ender chest entity of that player (0 when none exists and create is 0, or the table is full).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(48) VALUE "minecraft:ender_chest".
 01 WS-LENGTH              BINARY-LONG VALUE 21.
 01 WS-DIM                 BINARY-LONG VALUE 0.
 01 WS-TYPE                BINARY-LONG VALUE 3.
 01 WS-X                   BINARY-LONG VALUE 0.
 01 WS-Y                   BINARY-LONG VALUE 0.
 01 WS-Z                   BINARY-LONG VALUE 0.
 01 WS-FREE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-UUID                 PIC X(16).
 01 L-CREATE               BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-UUID L-CREATE L-INDEX.
     MOVE 0 TO L-INDEX WS-FREE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > ENDER-MAX
         IF ENDER-USED(WS-I) = 1 AND ENDER-UUID(WS-I) = L-UUID
             MOVE ENDER-BE(WS-I) TO L-INDEX
         END-IF
         IF ENDER-USED(WS-I) = 0 AND WS-FREE = 0
             MOVE WS-I TO WS-FREE
         END-IF
     END-PERFORM
     IF L-INDEX = 0 AND L-CREATE = 1 AND WS-FREE > 0
         CALL "BE-CREATE" USING WS-DIM WS-X WS-Y WS-Z WS-TYPE WS-KEY WS-LENGTH L-INDEX
         IF L-INDEX > 0
             MOVE 1 TO ENDER-USED(WS-FREE)
             MOVE L-UUID TO ENDER-UUID(WS-FREE)
             MOVE L-INDEX TO ENDER-BE(WS-FREE)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BE-ENDER-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PNBT-ENDER-WRITE.
*> USING PB-BUFFER, uuid (X(16)): the EnderItems list of the player file (one {Slot, id, count[, components]} per non-empty slot, in slot
*> order), written only when the player has an ender chest with items.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WN                     PIC X(16).
 01 WL                     BINARY-LONG.
 01 WS-ELEMENT             BINARY-LONG VALUE -1.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-INDEX               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-KP                  BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-UUID                 PIC X(16).
 PROCEDURE DIVISION USING PB-BUFFER L-UUID.
     CALL "BE-ENDER-GET" USING L-UUID WS-NO WS-INDEX
     IF WS-INDEX = 0
         GOBACK
     END-IF
     MOVE 0 TO WS-N
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 27
         IF BE-SLOT-COUNT(WS-INDEX, WS-S) > 0
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     IF WS-N = 0
         GOBACK
     END-IF
     MOVE "EnderItems" TO WN
     MOVE 10 TO WL
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-COMPOUND WS-N
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 27
         IF BE-SLOT-COUNT(WS-INDEX, WS-S) > 0
             CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WS-ELEMENT
             MOVE "Slot" TO WN
             MOVE 4 TO WL
             COMPUTE WS-SLOT = WS-S - 1
             CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-SLOT
             CALL "KX-PATCH-KEEP" USING BE-SLOT-VAR(WS-INDEX, WS-S) WS-KP
             CALL "PNBT-STACK-WRITE" USING PB-BUFFER BE-SLOT-ITEM(WS-INDEX, WS-S) BE-SLOT-COUNT(WS-INDEX, WS-S) WS-KP
             CALL "KX-PATCH-FREE" USING WS-KP
             CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
         END-IF
     END-PERFORM
     CALL "NBT-WRITE-LIST-END" USING PB-BUFFER
     GOBACK.
 END PROGRAM PNBT-ENDER-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PNBT-ENDER-READ.
*> USING PB-BUFFER (at the EnderItems list payload), uuid (X(16)): fills the player's ender chest; a slot outside 0 to 26 is skipped.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-YES                 BINARY-LONG VALUE 1.
 01 WS-INDEX               BINARY-LONG.
 01 WS-ET                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-ICOUNT              BINARY-LONG.
 01 WS-KP                  BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-UUID                 PIC X(16).
 PROCEDURE DIVISION USING PB-BUFFER L-UUID.
     CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ET WS-COUNT
     CALL "BE-ENDER-GET" USING L-UUID WS-YES WS-INDEX
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > WS-COUNT OR PB-ERROR = 1
         CALL "PNBT-STACK-READ" USING PB-BUFFER WS-SLOT WS-ITEM WS-ICOUNT WS-KP
         CALL "KX-PATCH-TAKE" USING WS-KP WS-HANDLE
         CALL "KX-PATCH-FREE" USING WS-KP
         IF WS-INDEX > 0 AND WS-SLOT >= 0 AND WS-SLOT <= 26 AND WS-ITEM > 0 AND WS-ICOUNT > 0
             MOVE WS-ITEM TO BE-SLOT-ITEM(WS-INDEX, WS-SLOT + 1)
             MOVE WS-ICOUNT TO BE-SLOT-COUNT(WS-INDEX, WS-SLOT + 1)
             MOVE WS-HANDLE TO BE-SLOT-VAR(WS-INDEX, WS-SLOT + 1)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PNBT-ENDER-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-SOUND-SEND.
*> USING dim, x, y, z, sound (1 open, 2 close), block entity type: the open or close sound of a container (BEFX FX-SOUND, 31-1 section 8.2) as
*> Sound 0x77 (05b) to the viewers of the chunk: the registry id of block.<chest, ender_chest, barrel or shulker_box>.<open or close>, source
*> blocks (4), the centre of the block in eighths, volume 0.5, pitch 0.95 (vanilla draws it from 0.9 to 1.0), seed 0. Every name asked for is in
*> the vanilla table of 46 (the sound_event registry is the same in both world types).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET-ID           BINARY-LONG VALUE 119.
 01 WS-REGISTRY            PIC X(48) VALUE "minecraft:sound_event".
 01 WS-KEY                 PIC X(112).
 01 WS-BASE                PIC X(16).
 01 WS-BASE-LENGTH         BINARY-LONG.
 01 WS-SIDE                PIC X(6).
 01 WS-SIDE-LENGTH         BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-HOLDER              BINARY-LONG.
 01 WS-SOURCE              BINARY-LONG VALUE 4.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-VOLUME              FLOAT-SHORT VALUE 0.5.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.95.
 01 WS-SEED                BINARY-DOUBLE VALUE 0.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-SOUND L-TYPE.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     EVALUATE L-TYPE
         WHEN 3
             MOVE "ender_chest" TO WS-BASE
             MOVE 11 TO WS-BASE-LENGTH
         WHEN 26
             MOVE "barrel" TO WS-BASE
             MOVE 6 TO WS-BASE-LENGTH
         WHEN 24
             MOVE "shulker_box" TO WS-BASE
             MOVE 11 TO WS-BASE-LENGTH
         WHEN OTHER
             MOVE "chest" TO WS-BASE
             MOVE 5 TO WS-BASE-LENGTH
     END-EVALUATE
     MOVE ".open" TO WS-SIDE
     MOVE 5 TO WS-SIDE-LENGTH
     IF L-SOUND = 2
         MOVE ".close" TO WS-SIDE
         MOVE 6 TO WS-SIDE-LENGTH
     END-IF
     MOVE SPACES TO WS-KEY
     STRING "minecraft:block." WS-BASE(1:WS-BASE-LENGTH) WS-SIDE(1:WS-SIDE-LENGTH) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-STATIC-ID" USING WS-REGISTRY WS-KEY WS-ID WS-STATUS
     COMPUTE WS-HOLDER = WS-ID + 1
     COMPUTE WS-FX = L-X * 8 + 4
     COMPUTE WS-FY = L-Y * 8 + 4
     COMPUTE WS-FZ = L-Z * 8 + 4
     COMPUTE WS-CX = (L-X - FUNCTION MOD(L-X, 16)) / 16
     COMPUTE WS-CZ = (L-Z - FUNCTION MOD(L-Z, 16)) / 16
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-HOLDER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-SOURCE
     CALL "PB-PUT-INT" USING PB-BUFFER WS-FX
     CALL "PB-PUT-INT" USING PB-BUFFER WS-FY
     CALL "PB-PUT-INT" USING PB-BUFFER WS-FZ
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-VOLUME
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-PITCH
     CALL "PB-PUT-LONG" USING PB-BUFFER WS-SEED
     CALL "VIEWERS-SEND" USING L-DIM WS-CX WS-CZ WS-NONE PB-BUFFER
     GOBACK.
 END PROGRAM BE-SOUND-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-CONTAINER-COMPONENT.
*> USING id out: the registry id of the data component type minecraft:container (the vanilla table of 46).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REGISTRY            PIC X(48) VALUE "minecraft:data_component_type".
 01 WS-KEY                 PIC X(112) VALUE "minecraft:container".
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID.
     CALL "CONTENT-STATIC-ID" USING WS-REGISTRY WS-KEY L-ID WS-STATUS
     GOBACK.
 END PROGRAM BE-CONTAINER-COMPONENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-SHULKER-DROP.
*> USING index, block id, handled out (31-1 section 13.4): a shulker box that holds items drops as one item entity of the box at the block centre (pickup
*> delay 10) whose patch carries the container component (ItemContainerContents: a VarInt 27 then the 27 slots as wire stacks, an empty slot
*> one 0 byte), so the contents travel in the item; handled is 1 then. An empty box drops nothing with contents (handled 1); contents that do
*> not fit the 2048 bytes of a component value leave handled 0 (the caller scatters them).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 COPY CITEMS.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 8192.
 01 WS-BYTES               PIC X(8192) BASED.
 01 WS-VALUE               PIC X(2048).
 01 WS-KEY                 PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-SLOTS               BINARY-LONG VALUE 27.
 01 WS-S                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-Z1                  FLOAT-LONG VALUE 0.
 01 WS-Z2                  FLOAT-LONG VALUE 0.
 01 WS-Z3                  FLOAT-LONG VALUE 0.
 01 WS-DELAY               BINARY-LONG VALUE 10.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SHORT               PIC X(48).
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-BLOCK L-HANDLED.
     MOVE 1 TO L-HANDLED
     MOVE 0 TO WS-N
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 27
         IF BE-SLOT-COUNT(L-INDEX, WS-S) > 0
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     IF WS-N = 0
         GOBACK
     END-IF
     CALL "PB-INIT" USING WK-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING WK-BUFFER WS-SLOTS
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 27
         CALL "SP-EXPORT" USING BE-SLOT-ITEM(L-INDEX, WS-S) BE-SLOT-COUNT(L-INDEX, WS-S) BE-SLOT-VAR(L-INDEX, WS-S)
             WK-ITEMSTACK-X
         CALL "PB-PUT-ITEM-STACK" USING WK-BUFFER WK-ITEMSTACK-X
     END-PERFORM
     MOVE WK-LENGTH TO WS-LENGTH
     IF WS-LENGTH > 2048
         CALL "PB-FREE" USING WK-BUFFER
         MOVE 0 TO L-HANDLED
         GOBACK
     END-IF
     SET ADDRESS OF WS-BYTES TO WK-ADDR
     MOVE SPACES TO WS-VALUE
     MOVE WS-BYTES(1:WS-LENGTH) TO WS-VALUE(1:WS-LENGTH)
     CALL "PB-FREE" USING WK-BUFFER
     CALL "BE-CONTAINER-COMPONENT" USING WS-TYPE
     MOVE 0 TO WS-HANDLE
     CALL "SP-SET-COMPONENT-X" USING WS-HANDLE WS-TYPE WS-VALUE WS-LENGTH
*>   The item of the box: the item whose key is the block's key (with or without the namespace).
     CALL "BE-BLOCK-KEY" USING L-BLOCK WS-KEY WS-S
     MOVE SPACES TO WS-SHORT
     COMPUTE WS-N = WS-S - 10
     MOVE 0 TO WS-ITEM
     IF WS-N > 0
         MOVE WS-KEY(11:WS-N) TO WS-SHORT
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IT-COUNT
         IF IT-KEY(WS-I) = WS-KEY OR IT-KEY(WS-I) = WS-SHORT
             COMPUTE WS-ITEM = WS-I - 1
         END-IF
     END-PERFORM
     COMPUTE WS-FX = BE-X(L-INDEX) + 0.5
     COMPUTE WS-FY = BE-Y(L-INDEX) + 0.5
     COMPUTE WS-FZ = BE-Z(L-INDEX) + 0.5
     CALL "GI-SPAWN-X" USING BE-DIM(L-INDEX) WS-FX WS-FY WS-FZ WS-Z1 WS-Z2 WS-Z3 WS-ITEM WS-ONE WS-DELAY WS-ROW WS-HANDLE
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 27
         MOVE 0 TO BE-SLOT-ITEM(L-INDEX, WS-S) BE-SLOT-COUNT(L-INDEX, WS-S) BE-SLOT-VAR(L-INDEX, WS-S)
     END-PERFORM
     GOBACK.
 END PROGRAM BE-SHULKER-DROP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-SHULKER-RESTORE.
*> USING dim, x, y, z, index: the placed shulker box takes the container component of the stack BE-PLACE-STATE noted for this position (loadFromTag of the
*> item placement path, 31-1 section 13.1): each of the 27 wire stacks becomes a slot (a stack that cannot be read ends the list).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 8192.
 01 WS-VALUE               PIC X(2048).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-INDEX.
     IF BP-SET = 0 OR BP-DIM NOT = L-DIM OR BP-X NOT = L-X OR BP-Y NOT = L-Y OR BP-Z NOT = L-Z
         GOBACK
     END-IF
     MOVE 0 TO BP-SET
     CALL "BE-CONTAINER-COMPONENT" USING WS-TYPE
     CALL "SP-GET-COMPONENT-X" USING BP-VAR WS-TYPE WS-VALUE WS-LENGTH WS-FOUND
     IF WS-FOUND = 0
         GOBACK
     END-IF
     CALL "PB-INIT" USING WK-BUFFER WS-CAPACITY
     CALL "PB-APPEND-BYTES" USING WK-BUFFER WS-VALUE WS-LENGTH
     CALL "PB-GET-VARINT" USING WK-BUFFER WS-N
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > WS-N OR WS-S > 27 OR WK-ERROR = 1
         CALL "PB-GET-ITEM-STACK" USING WK-BUFFER WK-ITEMSTACK-X
         IF WK-ISX-COUNT > 0 AND WK-ERROR = 0
             CALL "SP-INTERN" USING WK-ITEMSTACK-X WS-HANDLE
             MOVE WK-ISX-ITEM TO BE-SLOT-ITEM(L-INDEX, WS-S)
             MOVE WK-ISX-COUNT TO BE-SLOT-COUNT(L-INDEX, WS-S)
             MOVE WS-HANDLE TO BE-SLOT-VAR(L-INDEX, WS-S)
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING WK-BUFFER
     CALL "BE-MARK-CHUNK" USING L-INDEX
     GOBACK.
 END PROGRAM BE-SHULKER-RESTORE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOVE-SNEAK.
*> USING connection id, PLAY-SERVERBOUND (a decoded Player Input, 05c 0x2B): PL-SNEAKING is the shift flag (0x20) of the key bits.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SHIFT               BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND.
     COMPUTE WS-SHIFT = PSB-FLAGS / 32
     MOVE 0 TO PL-SNEAKING(CN-PLAYER(L-ID))
     IF FUNCTION MOD(WS-SHIFT, 2) = 1
         MOVE 1 TO PL-SNEAKING(CN-PLAYER(L-ID))
     END-IF
     GOBACK.
 END PROGRAM MOVE-SNEAK.
