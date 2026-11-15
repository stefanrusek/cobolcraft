*> Structure templates, part 2 (docs/protocol/36-structures-2 sections 1 and 2): reading a template from its gzip NBT file into the cache of STRUCTTPL.cpy.
*>
*> Entry points:
*>   STRUCT-TPL-RESET: forgets every template.
*>   STRUCT-TPL-STATE USING block key (PIC X(112)), properties (PIC X(600): "name=value" pairs separated by commas), state out (BINARY-LONG): section 1.2 readBlockState:
*>     the default state of the block with each property applied by name and value; a name or value that does not exist is skipped; an unknown block is state 0 (air).
*>   STRUCT-TPL-ORDER USING template row, palette number (1-based): sorts the palette's scratch records into the placement order of section 1.3 and appends them to the pool.
*>   STRUCT-TPL-LOAD USING root folder (PIC X(1100): the folder that holds data/), template id (PIC X(96), "path" or "namespace:path"), row out (BINARY-LONG: the cache row, whose
*>     TP-STATUS says loaded, absent or unsupported; 0 when the cache is full): the cache's get (2.3): a template is read once, an absent one stays absent. The file is <root>/data/<namespace>/structure/<path>.nbt (2.1).
*>   STRUCT-TPL-NBT USING PB-BUFFER (at the payload of a record's nbt compound), index out: keeps the kind and the keys of a block entity tag in the table of STRUCTTPL.cpy (1.4, 1.5);
*>     PB-ERROR is set when the table is full (the template is unsupported).
*>   STRUCT-BLOCK-TEXT USING text (PIC X(160)), state out, ok out: the block state text parser of 15 section 9.1 with the NBT switch on ("id[name=value,...]{nbt}"); a syntax
*>     error is ok 0 (an unknown block or property, an invalid or repeated one, a name without a value, an unclosed list, text after the properties). The trailing {nbt} is skipped
*>     up to its matching brace and not kept (the final_state of a jigsaw with block entity data is not kept).
*>   Approximation: "full cube" (1.3) is the content set's solid flag (CB-SOLID), as the block tables carry no collision shapes; it only changes the placement order of slabs,
*>   stairs, fences and the like, which no draw depends on except the loot seed order of chests (not written).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-TPL-RESET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTTPL.
 PROCEDURE DIVISION.
     MOVE 0 TO TP-COUNT
     MOVE 0 TO TP-USED
     MOVE 1 TO TN-USED
     MOVE 0 TO TN-KIND(1) TN-JOINT(1) TN-PRIO-PLACE(1) TN-PRIO-SELECT(1)
     MOVE SPACES TO TN-LOOT(1) TN-NAME(1) TN-POOL(1) TN-TARGET(1) TN-TEXT(1)
     GOBACK.
 END PROGRAM STRUCT-TPL-RESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-TPL-STATE-RAW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BASE                BINARY-LONG.
 01 WS-TRY                 BINARY-LONG.
 01 WS-CUR                 PIC X(160).
 01 WS-HAVE                PIC X(160).
 01 WS-CAND                PIC X(160).
 01 WS-NO-PAIRS            PIC X(160) VALUE SPACES.
 01 WS-WANT                PIC X(600).
 01 WS-POINTER             BINARY-LONG.
 01 WS-PAIR                PIC X(100).
 01 WS-PAIR-LENGTH         BINARY-LONG.
 01 WS-NAME                PIC X(48).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-VALUE               PIC X(48).
 01 WS-VALUE-LENGTH        BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-CPTR                BINARY-LONG.
 01 WS-CPAIR               PIC X(100).
 01 WS-CLEN                BINARY-LONG.
 01 WS-CNAME               PIC X(48).
 01 WS-CNAME-LENGTH        BINARY-LONG.
 01 WS-CVALUE              PIC X(48).
 01 WS-OUT-POINTER         BINARY-LONG.
 01 WS-CUR-TRIM            PIC X(160).
 01 WS-WANT-LENGTH          BINARY-LONG.
 01 WS-CUR-LENGTH           BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(112).
 01 L-PAIRS                PIC X(600).
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-PAIRS L-STATE.
     CALL "BLOCKS-STATE-OF" USING L-KEY WS-NO-PAIRS WS-BASE
     MOVE WS-BASE TO L-STATE
     IF L-PAIRS = SPACES
         GOBACK
     END-IF
     CALL "BLOCKS-STATE-PROPS" USING WS-BASE WS-CUR
     IF WS-CUR = SPACES
         GOBACK
     END-IF
     MOVE FUNCTION TRIM(L-PAIRS) TO WS-WANT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(L-PAIRS)) TO WS-WANT-LENGTH
     MOVE 1 TO WS-POINTER
     PERFORM UNTIL WS-POINTER > WS-WANT-LENGTH
         MOVE SPACES TO WS-PAIR
         MOVE 0 TO WS-PAIR-LENGTH
         UNSTRING WS-WANT(1:WS-WANT-LENGTH) DELIMITED BY "," INTO WS-PAIR COUNT IN WS-PAIR-LENGTH
             WITH POINTER WS-POINTER
         MOVE SPACES TO WS-NAME
         MOVE SPACES TO WS-VALUE
         UNSTRING WS-PAIR(1:WS-PAIR-LENGTH) DELIMITED BY "=" INTO WS-NAME COUNT IN WS-NAME-LENGTH
             WS-VALUE COUNT IN WS-VALUE-LENGTH
*>       Rebuild the current pairs with this one's value, in the block's list order.
         MOVE SPACES TO WS-CAND
         MOVE 1 TO WS-OUT-POINTER
         MOVE 0 TO WS-FOUND
         MOVE FUNCTION TRIM(WS-CUR) TO WS-CUR-TRIM
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-CUR)) TO WS-CUR-LENGTH
         MOVE 1 TO WS-CPTR
         PERFORM UNTIL WS-CPTR > WS-CUR-LENGTH
             MOVE SPACES TO WS-CPAIR
             MOVE 0 TO WS-CLEN
             UNSTRING WS-CUR-TRIM(1:WS-CUR-LENGTH) DELIMITED BY "," INTO WS-CPAIR COUNT IN WS-CLEN WITH POINTER WS-CPTR
             MOVE SPACES TO WS-CNAME
             MOVE SPACES TO WS-CVALUE
             UNSTRING WS-CPAIR(1:WS-CLEN) DELIMITED BY "=" INTO WS-CNAME COUNT IN WS-CNAME-LENGTH WS-CVALUE
             IF WS-OUT-POINTER > 1
                 STRING "," DELIMITED BY SIZE INTO WS-CAND WITH POINTER WS-OUT-POINTER
             END-IF
             IF WS-CNAME = WS-NAME
                 MOVE 1 TO WS-FOUND
                 STRING FUNCTION TRIM(WS-CNAME) "=" WS-VALUE(1:WS-VALUE-LENGTH) DELIMITED BY SIZE
                     INTO WS-CAND WITH POINTER WS-OUT-POINTER
             ELSE
                 STRING FUNCTION TRIM(WS-CNAME) "=" FUNCTION TRIM(WS-CVALUE) DELIMITED BY SIZE
                     INTO WS-CAND WITH POINTER WS-OUT-POINTER
             END-IF
         END-PERFORM
         IF WS-FOUND = 1
             CALL "BLOCKS-STATE-OF" USING L-KEY WS-CAND WS-TRY
             CALL "BLOCKS-STATE-PROPS" USING WS-TRY WS-HAVE
             IF WS-HAVE = WS-CAND
                 MOVE WS-CAND TO WS-CUR
                 MOVE WS-TRY TO L-STATE
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-TPL-STATE-RAW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-TPL-STATE.
*> USING block key, properties, state out: STRUCT-TPL-STATE-RAW remembered. A state is a function of the key, the pairs and the open block tables (CB-EPOCH), and the lookup of the engine
*> scans the block's states once per pair, so the answers are kept in a table of 4096 entries found by a hash of the key and the pairs (an entry made under another CB-EPOCH, or for other
*> text, is replaced; pairs longer than 160 bytes are never kept). Every template of a structure asks the same few hundred states again.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-MEMO.
    05 WS-M OCCURS 4096 TIMES.
       10 WM-EPOCH         BINARY-LONG VALUE -1.
       10 WM-KEY           PIC X(112).
       10 WM-PAIRS         PIC X(160).
       10 WM-STATE         BINARY-LONG.
 01 WS-HASH                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-PAIRS-LENGTH        BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(112).
 01 L-PAIRS                PIC X(600).
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-PAIRS L-STATE.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(L-PAIRS TRAILING)) TO WS-PAIRS-LENGTH
     IF L-PAIRS = SPACES
         MOVE 0 TO WS-PAIRS-LENGTH
     END-IF
     IF WS-PAIRS-LENGTH > 160
         CALL "STRUCT-TPL-STATE-RAW" USING L-KEY L-PAIRS L-STATE
         GOBACK
     END-IF
     MOVE FUNCTION LENGTH(FUNCTION TRIM(L-KEY TRAILING)) TO WS-KEY-LENGTH
     MOVE 7 TO WS-HASH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-KEY-LENGTH
         COMPUTE WS-CODE = FUNCTION ORD(L-KEY(WS-I:1))
         COMPUTE WS-HASH = FUNCTION MOD(WS-HASH * 31 + WS-CODE, 4093)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-PAIRS-LENGTH
         COMPUTE WS-CODE = FUNCTION ORD(L-PAIRS(WS-I:1))
         COMPUTE WS-HASH = FUNCTION MOD(WS-HASH * 31 + WS-CODE, 4093)
     END-PERFORM
     COMPUTE WS-SLOT = WS-HASH + 1
     IF WM-EPOCH(WS-SLOT) = CB-EPOCH AND WM-KEY(WS-SLOT) = L-KEY AND WM-PAIRS(WS-SLOT) = L-PAIRS(1:160)
         MOVE WM-STATE(WS-SLOT) TO L-STATE
         GOBACK
     END-IF
     CALL "STRUCT-TPL-STATE-RAW" USING L-KEY L-PAIRS L-STATE
     MOVE CB-EPOCH TO WM-EPOCH(WS-SLOT)
     MOVE L-KEY TO WM-KEY(WS-SLOT)
     MOVE L-PAIRS(1:160) TO WM-PAIRS(WS-SLOT)
     MOVE L-STATE TO WM-STATE(WS-SLOT)
     GOBACK.
 END PROGRAM STRUCT-TPL-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-TPL-ORDER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTTPL.
 COPY CBLOCKS.
 01 WS-I                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-VOLUME              BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-OUT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-PALETTE              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-PALETTE.
     COMPUTE WS-VOLUME = TP-SX(L-ROW) * TP-SY(L-ROW) * TP-SZ(L-ROW)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-VOLUME
         MOVE 0 TO TW-HEAD(WS-I)
     END-PERFORM
*>   Group of each record (1.3: block entity data, then full cubes, then the rest) and the chains of records per cell, in file order.
     PERFORM VARYING WS-I FROM TW-BLOCK-COUNT BY -1 UNTIL WS-I < 1
         IF TW-IDX(WS-I) >= 0 AND TW-IDX(WS-I) < TW-PAL-STATES(L-PALETTE)
             MOVE TW-PSTATE((L-PALETTE - 1) * TW-MAX-STATES + TW-IDX(WS-I) + 1) TO WS-STATE
         ELSE
             MOVE 0 TO WS-STATE
         END-IF
         EVALUATE TRUE
             WHEN TW-NBT(WS-I) > 0
                 MOVE 3 TO TW-GROUP(WS-I)
             WHEN CB-SOLID(CB-S-BLOCK(WS-STATE + 1) + 1) = 1
                 MOVE 1 TO TW-GROUP(WS-I)
             WHEN OTHER
                 MOVE 2 TO TW-GROUP(WS-I)
         END-EVALUATE
         COMPUTE WS-CELL = (TW-Y(WS-I) * TP-SX(L-ROW) + TW-X(WS-I)) * TP-SZ(L-ROW) + TW-Z(WS-I) + 1
         MOVE TW-HEAD(WS-CELL) TO TW-NEXT(WS-I)
         MOVE WS-I TO TW-HEAD(WS-CELL)
     END-PERFORM
     MOVE TP-USED TO TP-BASE(L-ROW, L-PALETTE)
     MOVE TP-USED TO WS-OUT
     PERFORM VARYING WS-G FROM 1 BY 1 UNTIL WS-G > 3
         MOVE 0 TO WS-CELL
         PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y >= TP-SY(L-ROW)
             PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X >= TP-SX(L-ROW)
                 PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z >= TP-SZ(L-ROW)
                     ADD 1 TO WS-CELL
                     MOVE TW-HEAD(WS-CELL) TO WS-R
                     PERFORM UNTIL WS-R = 0
                         IF TW-GROUP(WS-R) = WS-G
                             ADD 1 TO WS-OUT
                             MOVE TW-X(WS-R) TO TB-X(WS-OUT)
                             MOVE TW-Y(WS-R) TO TB-Y(WS-OUT)
                             MOVE TW-Z(WS-R) TO TB-Z(WS-OUT)
                             MOVE TW-NBT(WS-R) TO TB-NBT(WS-OUT)
                             IF TW-IDX(WS-R) >= 0 AND TW-IDX(WS-R) < TW-PAL-STATES(L-PALETTE)
                                 MOVE TW-PSTATE((L-PALETTE - 1) * TW-MAX-STATES + TW-IDX(WS-R) + 1) TO TB-STATE(WS-OUT)
                             ELSE
                                 MOVE 0 TO TB-STATE(WS-OUT)
                             END-IF
                         END-IF
                         MOVE TW-NEXT(WS-R) TO WS-R
                     END-PERFORM
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE WS-OUT TO TP-USED
     GOBACK.
 END PROGRAM STRUCT-TPL-ORDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-TPL-PALETTE.
*> USING PB-BUFFER (at a tag 9 payload: a list of block-state compounds), palette number (1-based): reads the states into the scratch (TW-PSTATE, TW-PAL-STATES);
*> a state with no id, or with an id the set does not hold, is state 0 (air).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTTPL.
 01 WS-ELEMENT-TYPE        BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-INNER               BINARY-LONG.
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 32.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-ID                  PIC X(112).
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-PAIRS               PIC X(600).
 01 WS-POINTER             BINARY-LONG.
 01 WS-PNAME               PIC X(48).
 01 WS-PNAME-LENGTH        BINARY-LONG.
 01 WS-PVALUE              PIC X(48).
 01 WS-PVALUE-LENGTH       BINARY-LONG.
 01 WS-CAPACITY-ID         BINARY-LONG VALUE 112.
 01 WS-CAPACITY-VALUE      BINARY-LONG VALUE 48.
 01 WS-STATE               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-PALETTE              BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-PALETTE.
     MOVE 0 TO TW-PAL-STATES(L-PALETTE)
     CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-COUNT
     IF PB-ERROR = 1 OR WS-COUNT > TW-MAX-STATES
         MOVE 1 TO PB-ERROR
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1
         MOVE SPACES TO WS-ID
         MOVE SPACES TO WS-PAIRS
         MOVE 1 TO WS-POINTER
         PERFORM UNTIL PB-ERROR = 1
             MOVE SPACES TO WN
             CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-NAME-CAPACITY WL
             IF WS-TYPE = 0
                 EXIT PERFORM
             END-IF
             EVALUATE TRUE
                 WHEN WN = "id" AND WS-TYPE = 8
                     CALL "NBT-READ-STRING" USING PB-BUFFER WS-ID WS-CAPACITY-ID WS-ID-LENGTH
                 WHEN WN = "properties" AND WS-TYPE = 10
                     PERFORM UNTIL PB-ERROR = 1
                         MOVE SPACES TO WN
                         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-INNER WN WS-NAME-CAPACITY WL
                         IF WS-INNER = 0
                             EXIT PERFORM
                         END-IF
                         IF WS-INNER = 8
                             MOVE SPACES TO WS-PVALUE
                             CALL "NBT-READ-STRING" USING PB-BUFFER WS-PVALUE WS-CAPACITY-VALUE WS-PVALUE-LENGTH
                             IF WS-POINTER > 1
                                 STRING "," DELIMITED BY SIZE INTO WS-PAIRS WITH POINTER WS-POINTER
                             END-IF
                             STRING WN(1:WL) "=" WS-PVALUE(1:WS-PVALUE-LENGTH) DELIMITED BY SIZE
                                 INTO WS-PAIRS WITH POINTER WS-POINTER
                         ELSE
                             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-INNER
                         END-IF
                     END-PERFORM
                 WHEN OTHER
                     CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
             END-EVALUATE
         END-PERFORM
         IF WS-ID = SPACES
             MOVE 0 TO WS-STATE
         ELSE
             CALL "STRUCT-TPL-STATE" USING WS-ID WS-PAIRS WS-STATE
         END-IF
         COMPUTE WS-SLOT = (L-PALETTE - 1) * TW-MAX-STATES + WS-I
         MOVE WS-STATE TO TW-PSTATE(WS-SLOT)
     END-PERFORM
     MOVE WS-COUNT TO TW-PAL-STATES(L-PALETTE)
     GOBACK.
 END PROGRAM STRUCT-TPL-PALETTE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-TPL-NBT.
*> USING PB-BUFFER (at a tag 10 payload: the nbt of a block record), index out (BINARY-LONG): the row of the tag in STRUCT-TPL-BE. The keys read: id, LootTable, SpawnData.entity.id,
*> mode, metadata, and of a jigsaw joint, name, pool, target, placement_priority, selection_priority, final_state (1.5); every other key is skipped. A full table is PB-ERROR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTTPL.
 01 WS-TYPE                BINARY-LONG.
 01 WS-INNER               BINARY-LONG.
 01 WS-DEEP                BINARY-LONG.
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 24.
 01 WN                     PIC X(24).
 01 WL                     BINARY-LONG.
 01 WS-CAP48               BINARY-LONG VALUE 48.
 01 WS-CAP96               BINARY-LONG VALUE 96.
 01 WS-CAP16               BINARY-LONG VALUE 16.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-ID                  PIC X(48).
 01 WS-LOOT                PIC X(48).
 01 WS-SPAWN               PIC X(48).
 01 WS-MODE                PIC X(16).
 01 WS-JOINT               PIC X(16).
 01 WS-META                PIC X(96).
 01 WS-FINAL               PIC X(96).
 01 WS-NAME                PIC X(48).
 01 WS-POOL                PIC X(48).
 01 WS-TARGET              PIC X(48).
 01 WS-PLACE               BINARY-LONG.
 01 WS-SELECT              BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-INDEX.
     MOVE SPACES TO WS-ID WS-LOOT WS-SPAWN WS-MODE WS-JOINT WS-META WS-FINAL WS-NAME WS-POOL WS-TARGET
     MOVE 0 TO WS-PLACE WS-SELECT
     MOVE 0 TO L-INDEX
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-NAME-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         EVALUATE TRUE
             WHEN WN = "id" AND WS-TYPE = 8
                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-ID WS-CAP48 WS-LENGTH
             WHEN WN = "LootTable" AND WS-TYPE = 8
                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-LOOT WS-CAP48 WS-LENGTH
             WHEN WN = "mode" AND WS-TYPE = 8
                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-MODE WS-CAP16 WS-LENGTH
             WHEN WN = "joint" AND WS-TYPE = 8
                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-JOINT WS-CAP16 WS-LENGTH
             WHEN WN = "metadata" AND WS-TYPE = 8
                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-META WS-CAP96 WS-LENGTH
             WHEN WN = "final_state" AND WS-TYPE = 8
                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-FINAL WS-CAP96 WS-LENGTH
             WHEN WN = "name" AND WS-TYPE = 8
                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-NAME WS-CAP48 WS-LENGTH
             WHEN WN = "pool" AND WS-TYPE = 8
                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-POOL WS-CAP48 WS-LENGTH
             WHEN WN = "target" AND WS-TYPE = 8
                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-TARGET WS-CAP48 WS-LENGTH
             WHEN WN = "placement_priority" AND WS-TYPE = 3
                 CALL "PB-GET-INT" USING PB-BUFFER WS-PLACE
             WHEN WN = "selection_priority" AND WS-TYPE = 3
                 CALL "PB-GET-INT" USING PB-BUFFER WS-SELECT
             WHEN WN = "SpawnData" AND WS-TYPE = 10
                 PERFORM UNTIL PB-ERROR = 1
                     MOVE SPACES TO WN
                     CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-INNER WN WS-NAME-CAPACITY WL
                     IF WS-INNER = 0
                         EXIT PERFORM
                     END-IF
                     IF WN = "entity" AND WS-INNER = 10
                         PERFORM UNTIL PB-ERROR = 1
                             MOVE SPACES TO WN
                             CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-DEEP WN WS-NAME-CAPACITY WL
                             IF WS-DEEP = 0
                                 EXIT PERFORM
                             END-IF
                             IF WN = "id" AND WS-DEEP = 8
                                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-SPAWN WS-CAP48 WS-LENGTH
                             ELSE
                                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-DEEP
                             END-IF
                         END-PERFORM
                     ELSE
                         CALL "NBT-READ-SKIP" USING PB-BUFFER WS-INNER
                     END-IF
                 END-PERFORM
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     IF TN-USED < 1
         MOVE 1 TO TN-USED
         MOVE 0 TO TN-KIND(1) TN-JOINT(1) TN-PRIO-PLACE(1) TN-PRIO-SELECT(1)
         MOVE SPACES TO TN-LOOT(1) TN-NAME(1) TN-POOL(1) TN-TARGET(1) TN-TEXT(1)
     END-IF
     IF TN-USED >= TN-MAX
         MOVE 1 TO PB-ERROR
         GOBACK
     END-IF
     ADD 1 TO TN-USED
     MOVE TN-USED TO L-INDEX
     MOVE 0 TO TN-KIND(L-INDEX) TN-JOINT(L-INDEX)
     MOVE WS-PLACE TO TN-PRIO-PLACE(L-INDEX)
     MOVE WS-SELECT TO TN-PRIO-SELECT(L-INDEX)
     MOVE WS-LOOT TO TN-LOOT(L-INDEX)
     MOVE SPACES TO TN-TEXT(L-INDEX)
     MOVE "minecraft:empty" TO TN-NAME(L-INDEX) TN-POOL(L-INDEX) TN-TARGET(L-INDEX)
     EVALUATE TRUE
         WHEN WS-ID = "minecraft:jigsaw"
             MOVE 4 TO TN-KIND(L-INDEX)
             IF WS-NAME NOT = SPACES
                 MOVE WS-NAME TO TN-NAME(L-INDEX)
             END-IF
             IF WS-POOL NOT = SPACES
                 MOVE WS-POOL TO TN-POOL(L-INDEX)
             END-IF
             IF WS-TARGET NOT = SPACES
                 MOVE WS-TARGET TO TN-TARGET(L-INDEX)
             END-IF
             EVALUATE WS-JOINT
                 WHEN "aligned"
                     MOVE 1 TO TN-JOINT(L-INDEX)
                 WHEN "rollable"
                     MOVE 2 TO TN-JOINT(L-INDEX)
             END-EVALUATE
             IF WS-FINAL = SPACES
                 MOVE "minecraft:air" TO TN-TEXT(L-INDEX)
             ELSE
                 MOVE WS-FINAL TO TN-TEXT(L-INDEX)
             END-IF
         WHEN WS-ID = "minecraft:structure_block"
             IF WS-MODE = "DATA"
                 MOVE 3 TO TN-KIND(L-INDEX)
                 MOVE WS-META TO TN-TEXT(L-INDEX)
             ELSE
                 MOVE 5 TO TN-KIND(L-INDEX)
             END-IF
         WHEN WS-ID = "minecraft:mob_spawner" OR WS-ID = "minecraft:spawner"
             MOVE 2 TO TN-KIND(L-INDEX)
             MOVE WS-SPAWN TO TN-TEXT(L-INDEX)
         WHEN WS-LOOT NOT = SPACES OR WS-ID = "minecraft:chest" OR WS-ID = "minecraft:trapped_chest" OR WS-ID = "minecraft:barrel"
             OR WS-ID = "minecraft:dispenser" OR WS-ID = "minecraft:dropper" OR WS-ID = "minecraft:hopper" OR WS-ID = "minecraft:shulker_box"
             MOVE 1 TO TN-KIND(L-INDEX)
     END-EVALUATE
     GOBACK.
 END PROGRAM STRUCT-TPL-NBT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-TPL-BLOCKS.
*> USING PB-BUFFER (at a tag 9 payload: the list of block records), entities flag out unused: reads pos (3 ints), state (int) and the presence of nbt of each record into
*> the scratch; more records than TW-MAX-BLOCKS, or a pos that is not a list of ints, is PB-ERROR (the template is unsupported).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTTPL.
 01 WS-ELEMENT-TYPE        BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 16.
 01 WN                     PIC X(16).
 01 WL                     BINARY-LONG.
 01 WS-POS-TYPE            BINARY-LONG.
 01 WS-POS-COUNT           BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-P                   BINARY-LONG OCCURS 3 TIMES.
 01 WS-STATE               BINARY-LONG.
 01 WS-NBT                 BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER.
     MOVE 0 TO TW-BLOCK-COUNT
     CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-COUNT
     IF PB-ERROR = 1 OR WS-COUNT > TW-MAX-BLOCKS
         MOVE 1 TO PB-ERROR
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1
         MOVE 0 TO WS-P(1) WS-P(2) WS-P(3)
         MOVE 0 TO WS-STATE
         MOVE 0 TO WS-NBT
         PERFORM UNTIL PB-ERROR = 1
             MOVE SPACES TO WN
             CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-NAME-CAPACITY WL
             IF WS-TYPE = 0
                 EXIT PERFORM
             END-IF
             EVALUATE TRUE
                 WHEN WN = "pos" AND WS-TYPE = 9
                     CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-POS-TYPE WS-POS-COUNT
                     IF WS-POS-COUNT > 0 AND WS-POS-TYPE NOT = 3
                         MOVE 1 TO PB-ERROR
                     END-IF
                     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-POS-COUNT OR PB-ERROR = 1
                         CALL "PB-GET-INT" USING PB-BUFFER WS-V
                         IF WS-J <= 3
                             MOVE WS-V TO WS-P(WS-J)
                         END-IF
                     END-PERFORM
                 WHEN WN = "state" AND WS-TYPE = 3
                     CALL "PB-GET-INT" USING PB-BUFFER WS-STATE
                 WHEN WN = "nbt" AND WS-TYPE = 10
                     CALL "STRUCT-TPL-NBT" USING PB-BUFFER WS-NBT
                 WHEN OTHER
                     CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
             END-EVALUATE
         END-PERFORM
         IF PB-ERROR = 0
             ADD 1 TO TW-BLOCK-COUNT
             MOVE WS-P(1) TO TW-X(TW-BLOCK-COUNT)
             MOVE WS-P(2) TO TW-Y(TW-BLOCK-COUNT)
             MOVE WS-P(3) TO TW-Z(TW-BLOCK-COUNT)
             MOVE WS-NBT TO TW-NBT(TW-BLOCK-COUNT)
             MOVE WS-STATE TO TW-IDX(TW-BLOCK-COUNT)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-TPL-BLOCKS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-TPL-LOAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTTPL.
 COPY PROTO.
 01 WS-KEY                 PIC X(96).
 01 WS-NS                  PIC X(48).
 01 WS-PATH-PART           PIC X(96).
 01 WS-PATH                PIC X(1300).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-POINTER             BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 16.
 01 WN                     PIC X(16).
 01 WL                     BINARY-LONG.
 01 WS-ELEMENT-TYPE        BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-SIZE                BINARY-LONG OCCURS 3 TIMES.
 01 WS-MULTI               BINARY-LONG.
 01 WS-ENTITIES            BINARY-LONG.
 01 WS-NBT-IN-ENTITY       BINARY-LONG.
 01 WS-INNER               BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-VOLUME              BINARY-LONG.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 LINKAGE SECTION.
 01 L-ROOT                 PIC X(1100).
 01 L-ID                   PIC X(96).
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROOT L-ID L-ROW.
     MOVE SPACES TO WS-KEY
     IF FUNCTION TRIM(L-ID) = SPACES
         MOVE 0 TO L-ROW
         GOBACK
     END-IF
     MOVE 0 TO WS-I
     INSPECT L-ID TALLYING WS-I FOR ALL ":"
     IF WS-I = 0
         STRING "minecraft:" FUNCTION TRIM(L-ID) DELIMITED BY SIZE INTO WS-KEY
     ELSE
         MOVE FUNCTION TRIM(L-ID) TO WS-KEY
     END-IF
     PERFORM VARYING L-ROW FROM 1 BY 1 UNTIL L-ROW > TP-COUNT
         IF TP-KEY(L-ROW) = WS-KEY
             GOBACK
         END-IF
     END-PERFORM
     IF TP-COUNT >= TP-MAX-TEMPLATES
         MOVE 0 TO L-ROW
         GOBACK
     END-IF
     ADD 1 TO TP-COUNT
     MOVE TP-COUNT TO WS-ROW
     MOVE WS-ROW TO L-ROW
     MOVE WS-KEY TO TP-KEY(WS-ROW)
     MOVE 2 TO TP-STATUS(WS-ROW)
     MOVE 0 TO TP-SX(WS-ROW) TP-SY(WS-ROW) TP-SZ(WS-ROW) TP-PALETTES(WS-ROW) TP-BLOCKS(WS-ROW) TP-ENTITIES(WS-ROW)
*>   <root>/data/<namespace>/structure/<path>.nbt (2.1)
     MOVE SPACES TO WS-NS
     MOVE SPACES TO WS-PATH-PART
     UNSTRING WS-KEY DELIMITED BY ":" INTO WS-NS WS-PATH-PART
     MOVE SPACES TO WS-PATH
     MOVE 1 TO WS-POINTER
     STRING FUNCTION TRIM(L-ROOT TRAILING) "/data/" FUNCTION TRIM(WS-NS) "/structure/" FUNCTION TRIM(WS-PATH-PART) ".nbt"
         DELIMITED BY SIZE INTO WS-PATH WITH POINTER WS-POINTER
     COMPUTE WS-PATH-LENGTH = WS-POINTER - 1
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "NBT-FILE-READ" USING WS-PATH WS-PATH-LENGTH PB-BUFFER WS-OUTCOME
     IF WS-OUTCOME NOT = 0
         CALL "PB-FREE" USING PB-BUFFER
         GOBACK
     END-IF
*>   from here a failure is "unsupported"
     MOVE 3 TO TP-STATUS(WS-ROW)
     MOVE 0 TO WS-SIZE(1) WS-SIZE(2) WS-SIZE(3)
     MOVE 0 TO WS-MULTI WS-ENTITIES TW-BLOCK-COUNT TW-PAL-COUNT
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-NAME-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         EVALUATE TRUE
             WHEN WN = "size" AND WS-TYPE = 9
                 CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-COUNT
                 IF WS-COUNT > 0 AND WS-ELEMENT-TYPE NOT = 3
                     MOVE 1 TO PB-ERROR
                 END-IF
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-COUNT OR PB-ERROR = 1
                     CALL "PB-GET-INT" USING PB-BUFFER WS-V
                     IF WS-K <= 3
                         MOVE WS-V TO WS-SIZE(WS-K)
                     END-IF
                 END-PERFORM
             WHEN WN = "blocks" AND WS-TYPE = 9
                 CALL "STRUCT-TPL-BLOCKS" USING PB-BUFFER
             WHEN WN = "palettes" AND WS-TYPE = 9
                 MOVE 1 TO WS-MULTI
                 CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-COUNT
                 IF WS-COUNT > TP-MAX-PALETTES
                     MOVE 1 TO PB-ERROR
                 END-IF
                 MOVE WS-COUNT TO TW-PAL-COUNT
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-COUNT OR PB-ERROR = 1
                     CALL "STRUCT-TPL-PALETTE" USING PB-BUFFER WS-K
                 END-PERFORM
             WHEN WN = "palette" AND WS-TYPE = 9 AND WS-MULTI = 0
                 MOVE 1 TO TW-PAL-COUNT
                 MOVE 1 TO WS-K
                 CALL "STRUCT-TPL-PALETTE" USING PB-BUFFER WS-K
             WHEN WN = "entities" AND WS-TYPE = 9
                 CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-COUNT
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-COUNT OR PB-ERROR = 1
                     MOVE 0 TO WS-NBT-IN-ENTITY
                     PERFORM UNTIL PB-ERROR = 1
                         MOVE SPACES TO WN
                         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-INNER WN WS-NAME-CAPACITY WL
                         IF WS-INNER = 0
                             EXIT PERFORM
                         END-IF
                         IF WN = "nbt" AND WS-INNER = 10
                             MOVE 1 TO WS-NBT-IN-ENTITY
                         END-IF
                         CALL "NBT-READ-SKIP" USING PB-BUFFER WS-INNER
                     END-PERFORM
                     ADD WS-NBT-IN-ENTITY TO WS-ENTITIES
                 END-PERFORM
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     MOVE PB-ERROR TO WS-BAD
     CALL "PB-FREE" USING PB-BUFFER
     IF WS-BAD = 1
         GOBACK
     END-IF
*>   Limits: the grid, the record chains and the pool. Every record must lie inside the size.
     COMPUTE WS-VOLUME = WS-SIZE(1) * WS-SIZE(2) * WS-SIZE(3)
     IF WS-SIZE(1) < 0 OR WS-SIZE(2) < 0 OR WS-SIZE(3) < 0 OR WS-VOLUME > TW-GRID
         GOBACK
     END-IF
     IF TP-USED + TW-PAL-COUNT * TW-BLOCK-COUNT > TP-POOL
         GOBACK
     END-IF
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > TW-BLOCK-COUNT
         IF TW-X(WS-K) < 0 OR TW-X(WS-K) >= WS-SIZE(1) OR TW-Y(WS-K) < 0 OR TW-Y(WS-K) >= WS-SIZE(2)
             OR TW-Z(WS-K) < 0 OR TW-Z(WS-K) >= WS-SIZE(3)
             MOVE 1 TO WS-BAD
         END-IF
     END-PERFORM
     IF WS-BAD = 1
         GOBACK
     END-IF
     MOVE WS-SIZE(1) TO TP-SX(WS-ROW)
     MOVE WS-SIZE(2) TO TP-SY(WS-ROW)
     MOVE WS-SIZE(3) TO TP-SZ(WS-ROW)
     MOVE TW-PAL-COUNT TO TP-PALETTES(WS-ROW)
     MOVE TW-BLOCK-COUNT TO TP-BLOCKS(WS-ROW)
     MOVE WS-ENTITIES TO TP-ENTITIES(WS-ROW)
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > TW-PAL-COUNT
         CALL "STRUCT-TPL-ORDER" USING WS-ROW WS-K
     END-PERFORM
     MOVE 1 TO TP-STATUS(WS-ROW)
     GOBACK.
 END PROGRAM STRUCT-TPL-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-BLOCK-TEXT.
*> USING text (PIC X(160)), state out (BINARY-LONG), ok out (BINARY-LONG): see the header.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-ID-END              BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-DEPTH               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-BLOCK               BINARY-LONG.
 01 WS-INSIDE              PIC X(160).
 01 WS-INSIDE-LENGTH       BINARY-LONG.
 01 WS-POINTER             BINARY-LONG.
 01 WS-PIECE               PIC X(100).
 01 WS-PIECE-LENGTH        BINARY-LONG.
 01 WS-NAME                PIC X(48).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-VALUE               PIC X(48).
 01 WS-VALUE-LENGTH        BINARY-LONG.
 01 WS-SEEN                PIC X(400).
 01 WS-SEEN-POINTER        BINARY-LONG.
 01 WS-NEEDLE              PIC X(60).
 01 WS-NEEDLE-LENGTH       BINARY-LONG.
 01 WS-HITS                BINARY-LONG.
 01 WS-PAIRS               PIC X(600).
 01 WS-PAIRS-POINTER       BINARY-LONG.
 01 WS-PROPS               PIC X(160).
 01 WS-HAVE                PIC X(170).
 01 WS-BAD                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(160).
 01 L-STATE                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-STATE L-OK.
     MOVE 0 TO L-STATE L-OK
     IF L-TEXT = SPACES
         GOBACK
     END-IF
     MOVE FUNCTION LENGTH(FUNCTION TRIM(L-TEXT TRAILING)) TO WS-LENGTH
*>   The identifier runs to the first [ or { (or the end).
     MOVE 1 TO WS-POS
     PERFORM UNTIL WS-POS > WS-LENGTH OR L-TEXT(WS-POS:1) = "[" OR L-TEXT(WS-POS:1) = "{"
         ADD 1 TO WS-POS
     END-PERFORM
     COMPUTE WS-ID-END = WS-POS - 1
     IF WS-ID-END < 1
         GOBACK
     END-IF
     MOVE SPACES TO WS-KEY
     MOVE L-TEXT(1:WS-ID-END) TO WS-KEY
     IF WS-KEY(1:1) = SPACE
         GOBACK
     END-IF
     MOVE 0 TO WS-I
     INSPECT WS-KEY TALLYING WS-I FOR ALL ":"
     IF WS-I = 0
         MOVE SPACES TO WS-KEY
         STRING "minecraft:" L-TEXT(1:WS-ID-END) DELIMITED BY SIZE INTO WS-KEY
     END-IF
     CALL "BLOCKS-ID-OF" USING WS-KEY WS-BLOCK
     IF WS-BLOCK < 0
         GOBACK
     END-IF
*>   The property list.
     MOVE SPACES TO WS-INSIDE
     MOVE 0 TO WS-INSIDE-LENGTH
     IF WS-POS <= WS-LENGTH AND L-TEXT(WS-POS:1) = "["
         MOVE WS-POS TO WS-CLOSE
         PERFORM UNTIL WS-CLOSE > WS-LENGTH OR L-TEXT(WS-CLOSE:1) = "]"
             ADD 1 TO WS-CLOSE
         END-PERFORM
         IF WS-CLOSE > WS-LENGTH
             GOBACK
         END-IF
         COMPUTE WS-INSIDE-LENGTH = WS-CLOSE - WS-POS - 1
         IF WS-INSIDE-LENGTH > 0
             MOVE L-TEXT(WS-POS + 1:WS-INSIDE-LENGTH) TO WS-INSIDE
         END-IF
         COMPUTE WS-POS = WS-CLOSE + 1
     END-IF
*>   The trailing nbt: braces must balance up to the end of the text.
     IF WS-POS <= WS-LENGTH
         IF L-TEXT(WS-POS:1) NOT = "{"
             GOBACK
         END-IF
         MOVE 0 TO WS-DEPTH
         PERFORM VARYING WS-I FROM WS-POS BY 1 UNTIL WS-I > WS-LENGTH
             IF L-TEXT(WS-I:1) = "{"
                 ADD 1 TO WS-DEPTH
             END-IF
             IF L-TEXT(WS-I:1) = "}"
                 SUBTRACT 1 FROM WS-DEPTH
                 IF WS-DEPTH = 0 AND WS-I < WS-LENGTH
                     GOBACK
                 END-IF
             END-IF
         END-PERFORM
         IF WS-DEPTH NOT = 0
             GOBACK
         END-IF
     END-IF
*>   Each pair: name = value, whitespace skipped; a repeated name is an error.
     MOVE SPACES TO WS-PAIRS WS-SEEN
     MOVE 1 TO WS-PAIRS-POINTER WS-SEEN-POINTER
     STRING "," DELIMITED BY SIZE INTO WS-SEEN WITH POINTER WS-SEEN-POINTER
     IF WS-INSIDE NOT = SPACES
         MOVE 1 TO WS-POINTER
         PERFORM UNTIL WS-POINTER > WS-INSIDE-LENGTH
             MOVE SPACES TO WS-PIECE
             MOVE 0 TO WS-PIECE-LENGTH
             UNSTRING WS-INSIDE(1:WS-INSIDE-LENGTH) DELIMITED BY "," INTO WS-PIECE COUNT IN WS-PIECE-LENGTH
                 WITH POINTER WS-POINTER
             MOVE 0 TO WS-I
             INSPECT WS-PIECE TALLYING WS-I FOR ALL "="
             IF WS-I NOT = 1
                 GOBACK
             END-IF
             MOVE SPACES TO WS-NAME WS-VALUE
             UNSTRING WS-PIECE DELIMITED BY "=" INTO WS-NAME WS-VALUE
             MOVE FUNCTION TRIM(WS-NAME) TO WS-NAME
             MOVE FUNCTION TRIM(WS-VALUE) TO WS-VALUE
             IF WS-NAME = SPACES OR WS-VALUE = SPACES
                 GOBACK
             END-IF
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-NAME)) TO WS-NAME-LENGTH
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-VALUE)) TO WS-VALUE-LENGTH
             MOVE SPACES TO WS-NEEDLE
             STRING "," WS-NAME(1:WS-NAME-LENGTH) "," DELIMITED BY SIZE INTO WS-NEEDLE
             COMPUTE WS-NEEDLE-LENGTH = WS-NAME-LENGTH + 2
             MOVE 0 TO WS-HITS
             INSPECT WS-SEEN TALLYING WS-HITS FOR ALL WS-NEEDLE(1:WS-NEEDLE-LENGTH)
             IF WS-HITS > 0
                 GOBACK
             END-IF
             STRING WS-NAME(1:WS-NAME-LENGTH) "," DELIMITED BY SIZE INTO WS-SEEN WITH POINTER WS-SEEN-POINTER
             IF WS-PAIRS-POINTER > 1
                 STRING "," DELIMITED BY SIZE INTO WS-PAIRS WITH POINTER WS-PAIRS-POINTER
             END-IF
             STRING WS-NAME(1:WS-NAME-LENGTH) "=" WS-VALUE(1:WS-VALUE-LENGTH) DELIMITED BY SIZE
                 INTO WS-PAIRS WITH POINTER WS-PAIRS-POINTER
         END-PERFORM
     END-IF
     CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS L-STATE
*>   Every wanted pair must be held by the state (STRUCT-TPL-STATE skips a name or value the block does not have).
     IF WS-PAIRS NOT = SPACES
         CALL "BLOCKS-STATE-PROPS" USING L-STATE WS-PROPS
         MOVE SPACES TO WS-HAVE
         STRING "," FUNCTION TRIM(WS-PROPS) "," DELIMITED BY SIZE INTO WS-HAVE
         MOVE 0 TO WS-BAD
         MOVE 1 TO WS-POINTER
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PAIRS)) TO WS-INSIDE-LENGTH
         PERFORM UNTIL WS-POINTER > WS-INSIDE-LENGTH
             MOVE SPACES TO WS-PIECE
             UNSTRING WS-PAIRS(1:WS-INSIDE-LENGTH) DELIMITED BY "," INTO WS-PIECE COUNT IN WS-PIECE-LENGTH
                 WITH POINTER WS-POINTER
             MOVE SPACES TO WS-NEEDLE
             STRING "," WS-PIECE(1:WS-PIECE-LENGTH) "," DELIMITED BY SIZE INTO WS-NEEDLE
             COMPUTE WS-NEEDLE-LENGTH = WS-PIECE-LENGTH + 2
             MOVE 0 TO WS-HITS
             INSPECT WS-HAVE TALLYING WS-HITS FOR ALL WS-NEEDLE(1:WS-NEEDLE-LENGTH)
             IF WS-HITS = 0
                 MOVE 1 TO WS-BAD
             END-IF
         END-PERFORM
         IF WS-BAD = 1
             MOVE 0 TO L-STATE
             GOBACK
         END-IF
     END-IF
     MOVE 1 TO L-OK
     GOBACK.
 END PROGRAM STRUCT-BLOCK-TEXT.
