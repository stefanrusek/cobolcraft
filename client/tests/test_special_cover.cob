*> Lane bugbeitems (T42440 and on): the edges of the code-drawn item models. SPECIAL-SORT orders by ascending key and keeps equal keys in their order; SPECIAL-ITEM-KIND names the
*> undyed and dyed shulker boxes, the ender and copper chests and answers 0 for an item with an ordinary model, an unknown id and no item; SPECIAL-ITEM-QUADS has no quads for such an item
*> and takes the missing texture (sprite 1) when the pack lacks the sprite; ATLAS-RESOURCE-ID names a `single` source with and without a namespace; a stack of 2 to 48 and over
*> drops as 2 to 5 copies (the chest thick, with offsets; the banner flat, stacked along z); a ground mesh that does not fit the vertex buffer adds nothing; a page of 36 chests in
*> slots has all its models in the icon layer (the 1536 vertices of before held 32), and a chest that finds the icon layer full is left to its flat icon. The generated vanilla pack is read
*> from CC_GENERATED_DIR.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SPECIAL-COVER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY TESTLIB.
 COPY CLSQ.
 01 WS-GEN                 PIC X(256).
 01 WS-ROOT                PIC X(256).
 01 WS-KEY                 PIC X(112).
 01 WS-ROW-AREA            PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-CHEST               BINARY-LONG.
 01 WS-BANNER              BINARY-LONG.
 01 WS-DIRT                BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ID1                 PIC X(80).
 01 WS-LEN1                BINARY-LONG.
 01 WS-ID2                 PIC X(80).
 01 WS-LEN2                BINARY-LONG.
 01 WS-DYE                 BINARY-LONG.
 01 WS-NAMES-DATA.
    05 FILLER PIC X(24) VALUE "shulker_box             ".
    05 FILLER PIC X(24) VALUE "red_shulker_box         ".
    05 FILLER PIC X(24) VALUE "ender_chest             ".
    05 FILLER PIC X(24) VALUE "copper_chest            ".
    05 FILLER PIC X(24) VALUE "waxed_oxidized_copper_ch".
    05 FILLER PIC X(24) VALUE "dirt                    ".
 01 WS-NAMES REDEFINES WS-NAMES-DATA.
    05 WS-NAME             PIC X(24) OCCURS 6 TIMES.
 01 WS-WANT-DATA           PIC X(24) VALUE "216 214 100 100 100 000 ".
 01 WS-WANT REDEFINES WS-WANT-DATA.
    05 WS-WANT-ROW         OCCURS 6 TIMES.
       10 WS-WANT-KIND     PIC 9.
       10 WS-WANT-DYE      PIC 99.
       10 FILLER           PIC X.
 01 WS-IDS-DATA.
    05 FILLER PIC X(48) VALUE "minecraft:entity/shulker/shulker                ".
    05 FILLER PIC X(48) VALUE "minecraft:entity/shulker/shulker_red            ".
    05 FILLER PIC X(48) VALUE "minecraft:entity/chest/ender                    ".
    05 FILLER PIC X(48) VALUE "minecraft:entity/chest/copper                   ".
    05 FILLER PIC X(48) VALUE "minecraft:entity/chest/copper_oxidized          ".
    05 FILLER PIC X(48) VALUE "                                                ".
 01 WS-IDS REDEFINES WS-IDS-DATA.
    05 WS-IDX              PIC X(48) OCCURS 6 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-KEYS.
    05 WS-KEYV             FLOAT-LONG OCCURS 48 TIMES.
 01 WS-ORDERS.
    05 WS-ORDER            BINARY-LONG OCCURS 48 TIMES.
 01 WS-COUNT               BINARY-LONG.
 01 WS-LINE                PIC X(40).
 01 WS-DIGIT               PIC 9.
 01 WS-RES                 PIC X(128).
 01 WS-RLEN                BINARY-LONG.
 01 WS-RID                 PIC X(80).
 01 WS-RIDLEN              BINARY-LONG.
 01 WS-RPATH               PIC X(256).
 01 WS-RPATHLEN            BINARY-LONG.
 01 WS-KEEP                BINARY-LONG.
 01 WS-ENT-ID              BINARY-LONG.
 01 WS-ENT-TYPE            BINARY-LONG.
 01 WS-EX                  FLOAT-LONG.
 01 WS-EY                  FLOAT-LONG.
 01 WS-EZ                  FLOAT-LONG.
 01 WS-ENT-YAW             FLOAT-SHORT.
 01 WS-EYE-POINT.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-STACKS-DATA         PIC X(10) VALUE "0102173349".
 01 WS-STACKS REDEFINES WS-STACKS-DATA.
    05 WS-STACK            PIC 99 OCCURS 5 TIMES.
 01 WS-PER                 BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-MORE                BINARY-LONG.
 01 WS-DRAWN               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-SLOTS               BINARY-LONG.
 01 WS-HAVE                BINARY-LONG.
 01 WS-HD                  PIC 9.
 01 WS-KINDV               BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-GEN
     ACCEPT WS-GEN FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-GEN = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-GEN
     END-IF
     MOVE SPACES TO WS-ROOT
     STRING FUNCTION TRIM(WS-GEN) "/vanilla-resources" DELIMITED BY SIZE INTO WS-ROOT
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     ADD 1 TO PK-COUNT
     INITIALIZE PK-PACK(PK-COUNT)
     MOVE 1 TO PK-KIND(PK-COUNT)
     MOVE 3 TO PK-LEVEL(PK-COUNT)
     MOVE "generated/vanilla" TO PK-ID(PK-COUNT)
     MOVE 17 TO PK-ID-LENGTH(PK-COUNT)
     MOVE WS-ROOT TO PK-ROOT(PK-COUNT)
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-ROOT)) TO PK-ROOT-LENGTH(PK-COUNT)
     CALL "PACK-STACK-OPEN" USING CLIENT-STATE
     CALL "PACK-SOURCE-FILES" USING CLIENT-STATE PK-COUNT
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     MOVE 256 TO PL-HEIGHT
     MOVE 0 TO SK-U
     MOVE 1 TO CL-GUI-SCALE
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 1 TO CT-OPEN
     MOVE "N" TO TL-MODE
*>   SPECIAL-SORT: the keys 3 1 2 1 and an ordered 1 2 3.
     MOVE 3 TO WS-KEYV(1)
     MOVE 1 TO WS-KEYV(2) WS-KEYV(4)
     MOVE 2 TO WS-KEYV(3)
     MOVE 4 TO WS-COUNT
     CALL "SPECIAL-SORT" USING WS-COUNT WS-KEYS WS-ORDERS
     MOVE SPACES TO WS-LINE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE WS-ORDER(WS-I) TO WS-DIGIT
         MOVE WS-DIGIT TO WS-LINE(WS-I:1)
     END-PERFORM
     MOVE "T" TO TL-MODE
     MOVE "bugbeitems sort: keys 3 1 2 1 give the order 2 4 3 1 (equal keys keep their order)" TO TL-CASE
     MOVE "2431" TO TL-EXPECTED
     MOVE WS-LINE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-KEYV(1)
     MOVE 2 TO WS-KEYV(2)
     MOVE 3 TO WS-KEYV(3)
     MOVE 3 TO WS-COUNT
     CALL "SPECIAL-SORT" USING WS-COUNT WS-KEYS WS-ORDERS
     MOVE SPACES TO WS-LINE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         MOVE WS-ORDER(WS-I) TO WS-DIGIT
         MOVE WS-DIGIT TO WS-LINE(WS-I:1)
     END-PERFORM
     MOVE "bugbeitems sort: ordered keys stay in their order" TO TL-CASE
     MOVE "123" TO TL-EXPECTED
     MOVE WS-LINE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   ATLAS-RESOURCE-ID.
     MOVE SPACES TO WS-RES
     MOVE "entity/bell/bell_body" TO WS-RES
     MOVE 21 TO WS-RLEN
     CALL "ATLAS-RESOURCE-ID" USING WS-RES WS-RLEN WS-RID WS-RIDLEN WS-RPATH WS-RPATHLEN
     MOVE "bugbeitems atlas single: a resource without a namespace is minecraft's (id)" TO TL-CASE
     MOVE "minecraft:entity/bell/bell_body" TO TL-EXPECTED
     MOVE WS-RID(1:WS-RIDLEN) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "bugbeitems atlas single: a resource without a namespace (file)" TO TL-CASE
     MOVE "assets/minecraft/textures/entity/bell/bell_body.png" TO TL-EXPECTED
     MOVE WS-RPATH(1:WS-RPATHLEN) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-RES
     MOVE "other:entity/thing" TO WS-RES
     MOVE 18 TO WS-RLEN
     CALL "ATLAS-RESOURCE-ID" USING WS-RES WS-RLEN WS-RID WS-RIDLEN WS-RPATH WS-RPATHLEN
     MOVE "bugbeitems atlas single: a resource of another namespace (id)" TO TL-CASE
     MOVE "other:entity/thing" TO TL-EXPECTED
     MOVE WS-RID(1:WS-RIDLEN) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "bugbeitems atlas single: a resource of another namespace (file)" TO TL-CASE
     MOVE "assets/other/textures/entity/thing.png" TO TL-EXPECTED
     MOVE WS-RPATH(1:WS-RPATHLEN) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   SPECIAL-ITEM-KIND.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE SPACES TO WS-KEY
         MOVE WS-NAME(WS-I) TO WS-KEY
         IF WS-I = 5
             MOVE "waxed_oxidized_copper_chest" TO WS-KEY
         END-IF
         CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
         CALL "SPECIAL-ITEM-KIND" USING CLIENT-STATE WS-ITEM WS-KIND WS-ID1 WS-LEN1 WS-ID2 WS-LEN2 WS-DYE
         MOVE "N" TO TL-MODE
         MOVE SPACES TO TL-CASE
         STRING "bugbeitems kind of " FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-WANT-KIND(WS-I) TO TL-EXPECTED-N
         MOVE WS-KIND TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         IF WS-KIND = 2
             MOVE SPACES TO TL-CASE
             STRING "bugbeitems dye of " FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE INTO TL-CASE
             MOVE WS-WANT-DYE(WS-I) TO TL-EXPECTED-N
             MOVE WS-DYE TO TL-OBSERVED-N
             CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         END-IF
         IF WS-KIND > 0
             MOVE SPACES TO TL-CASE
             STRING "bugbeitems sprite of " FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE INTO TL-CASE
             MOVE "T" TO TL-MODE
             MOVE FUNCTION TRIM(WS-IDX(WS-I)) TO TL-EXPECTED
             MOVE WS-ID1(1:WS-LEN1) TO TL-OBSERVED
             CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         END-IF
     END-PERFORM
     MOVE "N" TO TL-MODE
     MOVE -1 TO WS-ITEM
     CALL "SPECIAL-ITEM-KIND" USING CLIENT-STATE WS-ITEM WS-KIND WS-ID1 WS-LEN1 WS-ID2 WS-LEN2 WS-DYE
     MOVE "bugbeitems kind of no item is 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-KIND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 99999 TO WS-ITEM
     CALL "SPECIAL-ITEM-KIND" USING CLIENT-STATE WS-ITEM WS-KIND WS-ID1 WS-LEN1 WS-ID2 WS-LEN2 WS-DYE
     MOVE "bugbeitems kind of an unknown item id is 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-KIND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   SPECIAL-ITEM-QUADS: none for dirt; the missing texture when the pack has no sprite.
     MOVE SPACES TO WS-KEY
     MOVE "dirt" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-DIRT WS-ITEM-ROW WS-STATUS
     CALL "SPECIAL-ITEM-QUADS" USING CLIENT-STATE WS-DIRT SQ-TABLE
     MOVE "bugbeitems dirt has no model quads" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SQ-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-KEY
     MOVE "chest" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-CHEST WS-ITEM-ROW WS-STATUS
     MOVE SPACES TO WS-KEY
     MOVE "red_banner" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-BANNER WS-ITEM-ROW WS-STATUS
     MOVE AT-SPRITE-COUNT TO WS-KEEP
     MOVE 1 TO AT-SPRITE-COUNT
     CALL "SPECIAL-ITEM-QUADS" USING CLIENT-STATE WS-BANNER SQ-TABLE
     MOVE WS-KEEP TO AT-SPRITE-COUNT
     MOVE "bugbeitems a banner with no sprites in the pack still has its 24 quads (the missing texture)" TO TL-CASE
     MOVE 24 TO TL-EXPECTED-N
     MOVE SQ-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The ground: a dropped chest and banner by stack size.
     MOVE SPACES TO WS-KEY
     MOVE "item" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ENT-TYPE WS-ROW-AREA WS-STATUS
     MOVE 64 TO WS-ENT-ID
     MOVE 10.5 TO WS-EX WS-EZ
     MOVE 64 TO WS-EY
     MOVE 0 TO WS-ENT-YAW
     CALL "GIF-SPAWN" USING CLIENT-STATE WS-ENT-ID WS-ENT-TYPE WS-EX WS-EY WS-EZ WS-ENT-YAW
     MOVE 0 TO CL-NOW-MS
     MOVE 10.5 TO WS-EYE(1)
     MOVE 66 TO WS-EYE(2)
     MOVE 8.5 TO WS-EYE(3)
     PERFORM VARYING WS-HAVE FROM 1 BY 1 UNTIL WS-HAVE > 2
         IF WS-HAVE = 1
             MOVE WS-CHEST TO EN-STACK-ITEM(1)
         ELSE
             MOVE WS-BANNER TO EN-STACK-ITEM(1)
         END-IF
         MOVE 0 TO WS-LAST
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
             MOVE WS-STACK(WS-I) TO EN-STACK-COUNT(1)
             MOVE 0 TO RL-GI-COUNT
             CALL "VANILLA-ITEMS-MESH" USING CLIENT-STATE WS-EYE-POINT
             MOVE SPACES TO TL-CASE
             MOVE WS-HAVE TO WS-HD
             STRING "bugbeitems dropped model " WS-HD " stack of " WS-STACK(WS-I) ": more vertices than the stack before it"
                 DELIMITED BY SIZE INTO TL-CASE
             MOVE "N" TO TL-MODE
             MOVE 1 TO TL-EXPECTED-N
             MOVE 0 TO TL-OBSERVED-N
             IF WS-I = 1 OR RL-GI-COUNT > WS-LAST
                 MOVE 1 TO TL-OBSERVED-N
             END-IF
             CALL "TEST-ASSERT" USING TESTLIB-ASSERT
             MOVE RL-GI-COUNT TO WS-LAST
         END-PERFORM
     END-PERFORM
*>   A buffer with no room: nothing is added.
     MOVE WS-CHEST TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     COMPUTE RL-GI-COUNT = CL-MAX-GI-VERTICES - 10
     CALL "VANILLA-ITEMS-MESH" USING CLIENT-STATE WS-EYE-POINT
     MOVE "bugbeitems a ground mesh with no room for the model adds nothing" TO TL-CASE
     COMPUTE TL-EXPECTED-N = CL-MAX-GI-VERTICES - 10
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A page of 36 chests in the slots: every model is in the icon layer.
     MOVE 36 TO WS-SLOTS
     MOVE WS-SLOTS TO SM-WIDGET-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-SLOTS
         MOVE WK-SLOT TO SM-W-KIND(WS-I)
         COMPUTE SM-W-ARG(WS-I) = WS-I - 1
         MOVE 0 TO SM-W-STATE(WS-I)
         COMPUTE SM-W-X(WS-I) = 10 + FUNCTION MOD(WS-I - 1, 9) * 20
         COMPUTE SM-W-Y(WS-I) = 10 + FUNCTION INTEGER((WS-I - 1) / 9) * 20
         MOVE 18 TO SM-W-W(WS-I) SM-W-H(WS-I)
         MOVE 1 TO PL-SLOT-COUNT(WS-I)
         MOVE WS-CHEST TO PL-SLOT-ITEM(WS-I)
     END-PERFORM
     MOVE 2 TO CL-GUI-SCALE
     CALL "UI-RENDER" USING CLIENT-STATE
     MOVE "bugbeitems a page of 36 chests: 8 quads each (1728 vertices) are all in the icon layer" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 36 * 8 * 6
     MOVE RL-IC-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The icon layer without room for a model: SPECIAL-GUI-ICON adds nothing and says so; the slot then draws its flat icon.
     MOVE 1 TO SM-WIDGET-COUNT
     COMPUTE RL-IC-COUNT = CL-MAX-ICON-VERTICES - 30
     MOVE 1 TO WS-X WS-Y
     CALL "SPECIAL-GUI-ICON" USING CLIENT-STATE WS-KINDV WS-CHEST WS-X WS-Y WS-DRAWN
     MOVE "bugbeitems icon layer with room for 5 quads: the model of 8 is refused" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-DRAWN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "bugbeitems icon layer with room for 5 quads: nothing was added" TO TL-CASE
     COMPUTE TL-EXPECTED-N = CL-MAX-ICON-VERTICES - 30
     MOVE RL-IC-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-X
     CALL "UI-SLOT" USING CLIENT-STATE WS-X
     MOVE "bugbeitems icon layer with room for 5 quads: the slot of the chest takes the flat icon (6 vertices)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = CL-MAX-ICON-VERTICES - 30 + 6
     MOVE RL-IC-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-SPECIAL-COVER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GIF-SPAWN.
*> USING CLIENT-STATE, entity id, type (registry id), x y z (FLOAT-LONG), yaw (FLOAT-SHORT, also the head yaw): Add Entity.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-ADD                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-UUID                PIC X(16) VALUE LOW-VALUES.
 01 WS-V0                  FLOAT-LONG VALUE 0.
 01 WS-V1                  FLOAT-LONG VALUE 0.
 01 WS-V2                  FLOAT-LONG VALUE 0.
 01 WS-A0                  FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-YAW                  FLOAT-SHORT.
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-TYPE L-X L-Y L-Z L-YAW.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ID
     CALL "PB-PUT-UUID" USING PB-BUFFER WS-UUID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-TYPE
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-X
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Y
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Z
     CALL "PB-PUT-LPVEC3" USING PB-BUFFER WS-V0 WS-V1 WS-V2
     CALL "PB-PUT-ANGLE" USING PB-BUFFER WS-A0
     CALL "PB-PUT-ANGLE" USING PB-BUFFER L-YAW
     CALL "PB-PUT-ANGLE" USING PB-BUFFER L-YAW
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     MOVE 0 TO PB-POS
     CALL "ENTITY-PACKET" USING CLIENT-STATE PB-BUFFER WS-ADD
     GOBACK.
 END PROGRAM GIF-SPAWN.


 COPY CLTEST.
