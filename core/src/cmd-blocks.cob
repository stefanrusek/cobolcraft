*> The block and item argument types of docs/protocol/15-commands-framework.md §9.1 and §9.2: block_state (12), block_predicate
*> (13), item_stack (14) and item_predicate (15). An identifier without a namespace is in the namespace of the open content set
*> (cobolcraft: for the cobolcraft set, else minecraft:, as BLOCKS-ID-OF reads keys). A block id is resolved against the block
*> tables (CBLOCKS.cpy, BLOCKS-ID-OF), its properties against the states of the block (BLOCKS-STATE-PROPS, BLOCKS-STATE-OF); an item
*> id against CORE-ITEMS. Tags (block_predicate, item_predicate) are not looked up (the existence of a tag is the command's
*> check), the type of an item component is not looked up and its SNBT value is not decoded (15 §9.2: checked when the stack
*> is built).
*>
*> The value left in the trail: the integer value is the block state id (block_state, block_predicate; -1 for a tag) or the item
*> id (-1 for a tag or *); BR-V-AUX 1 a tag, 2 trailing NBT (blocks) or components or conditions (items), 4 any item (*).
*>
*> Entry point: BR-ARG-BLOCK USING node, integer out, double out, infinity flag out (as BR-ARG-EXT)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-ARG-BLOCK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY CITEMS.
 01 WS-START               BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-ID-FLAGS            BINARY-LONG VALUE 0.
 01 WS-ID-START            BINARY-LONG.
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-HAS-COLON           BINARY-LONG.
 01 WS-NAME                PIC X(112).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-DEFAULT-COBOL       PIC X(11) VALUE "cobolcraft:".
 01 WS-DEFAULT-MC          PIC X(10) VALUE "minecraft:".
 01 WS-BLOCK-ID            BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-DEFAULT-PROPS       PIC X(64).
 01 WS-STATE-PROPS         PIC X(64).
 01 WS-PROP-COUNT          BINARY-LONG.
 01 WS-PROP                OCCURS 8 TIMES.
    05 WS-P-NAME            PIC X(32).
    05 WS-P-NAME-LENGTH     BINARY-LONG.
    05 WS-P-VALUE           PIC X(32).
    05 WS-P-VALUE-LENGTH    BINARY-LONG.
    05 WS-P-SET             BINARY-LONG.
 01 WS-STR                 PIC X(1024).
 01 WS-STR-LENGTH          BINARY-LONG.
 01 WS-VAL                 PIC X(1024).
 01 WS-VAL-LENGTH          BINARY-LONG.
 01 WS-NAME-START          BINARY-LONG.
 01 WS-VALUE-START         BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-SNBT-KIND           BINARY-LONG.
 01 WS-PAIRS               PIC X(64).
 01 WS-POINTER             BINARY-LONG.
 01 WS-NEEDLE              PIC X(70).
 01 WS-NEEDLE-LENGTH       BINARY-LONG.
 01 WS-HAVE                PIC X(70).
 01 WS-WANT                PIC X(112).
 01 WS-KEY                 PIC X(48).
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG.
 01 WS-L1                  BINARY-LONG.
 01 WS-L2                  BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TAG                 BINARY-LONG.
 01 WS-SEEN-COUNT          BINARY-LONG.
 01 WS-SEEN                OCCURS 32 TIMES.
    05 WS-SEEN-NAME         PIC X(64).
    05 WS-SEEN-LENGTH       BINARY-LONG.
 01 WS-NEGATED             BINARY-LONG.
 01 WS-ANY                 BINARY-LONG.
 01 WS-CH                  PIC X.
 01 WS-ORDER               BINARY-LONG.
 01 WS-PROP-AT             BINARY-LONG.
 01 WS-PROP-TEXT           PIC X(1024).
 01 WS-PROP-TEXT-LENGTH    BINARY-LONG.
 01 WS-COUNT-FOUND         BINARY-LONG.
 01 WS-A3                  PIC X(64).
 01 WS-L3                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-NODE                 BINARY-LONG.
 01 L-INT                  BINARY-DOUBLE.
 01 L-DOUBLE               FLOAT-LONG.
 01 L-INF                  BINARY-LONG.
 PROCEDURE DIVISION USING L-NODE L-INT L-DOUBLE L-INF.
     GO TO MAIN-LINE.

 RAISE-NOW.
     CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC.

 SKIP-SPACES.
     CALL "BR-SNBT-SKIP-SPACES".

*> WS-NAME (WS-NAME-LENGTH): the identifier just read (WS-ID-START, WS-ID-LENGTH) with the namespace of the content set when it has none.
 QUALIFY-ID.
     MOVE SPACES TO WS-NAME
     MOVE 0 TO WS-HAS-COLON
     PERFORM VARYING WS-I FROM WS-ID-START BY 1 UNTIL WS-I >= WS-ID-START + WS-ID-LENGTH
         IF BR-IN-TEXT(WS-I + 1:1) = ":"
             MOVE 1 TO WS-HAS-COLON
         END-IF
     END-PERFORM
     EVALUATE TRUE
         WHEN WS-HAS-COLON = 1
             MOVE BR-IN-TEXT(WS-ID-START + 1:WS-ID-LENGTH) TO WS-NAME
             MOVE WS-ID-LENGTH TO WS-NAME-LENGTH
         WHEN CT-SET-TYPE = CT-TYPE-COBOLCRAFT
             MOVE WS-DEFAULT-COBOL TO WS-NAME(1:11)
             MOVE BR-IN-TEXT(WS-ID-START + 1:WS-ID-LENGTH) TO WS-NAME(12:WS-ID-LENGTH)
             COMPUTE WS-NAME-LENGTH = WS-ID-LENGTH + 11
         WHEN OTHER
             MOVE WS-DEFAULT-MC TO WS-NAME(1:10)
             MOVE BR-IN-TEXT(WS-ID-START + 1:WS-ID-LENGTH) TO WS-NAME(11:WS-ID-LENGTH)
             COMPUTE WS-NAME-LENGTH = WS-ID-LENGTH + 10
     END-EVALUATE.

*> An exception whose first argument is WS-NAME and no other, at WS-RC.
 RAISE-NAME.
     MOVE 1 TO WS-N-ARGS
     MOVE 0 TO WS-L2
     MOVE SPACES TO WS-A1
     MOVE WS-NAME-LENGTH TO WS-L1
     IF WS-L1 > 64
         MOVE 64 TO WS-L1
     END-IF
     MOVE WS-NAME(1:WS-L1) TO WS-A1(1:WS-L1)
     PERFORM RAISE-NOW.

*> An exception with the block (WS-NAME) and the text WS-STR as arguments, in the order WS-ORDER (1 block first).
 RAISE-TWO.
     MOVE 2 TO WS-N-ARGS
     MOVE SPACES TO WS-A1 WS-A2
     IF WS-ORDER = 1
         MOVE WS-NAME-LENGTH TO WS-L1
         IF WS-L1 > 64
             MOVE 64 TO WS-L1
         END-IF
         MOVE WS-NAME(1:WS-L1) TO WS-A1(1:WS-L1)
         MOVE WS-STR-LENGTH TO WS-L2
         IF WS-L2 > 64
             MOVE 64 TO WS-L2
         END-IF
         MOVE WS-STR(1:WS-L2) TO WS-A2(1:WS-L2)
     ELSE
         MOVE WS-STR-LENGTH TO WS-L1
         IF WS-L1 > 64
             MOVE 64 TO WS-L1
         END-IF
         MOVE WS-STR(1:WS-L1) TO WS-A1(1:WS-L1)
         MOVE WS-NAME-LENGTH TO WS-L2
         IF WS-L2 > 64
             MOVE 64 TO WS-L2
         END-IF
         MOVE WS-NAME(1:WS-L2) TO WS-A2(1:WS-L2)
     END-IF
     PERFORM RAISE-NOW.

*> ---- blocks ---------------------------------------------------------------------------------------
 DO-BLOCK.
     MOVE -1 TO L-INT
     MOVE 0 TO WS-TAG BR-V-AUX
     IF BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "#"
         IF BR-N-TYPE(L-NODE) = BR-P-BLOCK-STATE
             MOVE "argument.block.tag.disallowed" TO WS-KEY
             MOVE BR-IN-CURSOR TO WS-RC
             MOVE 0 TO WS-N-ARGS WS-L1 WS-L2
             PERFORM RAISE-NOW
         ELSE
             MOVE 1 TO WS-TAG BR-V-AUX
             ADD 1 TO BR-IN-CURSOR
             CALL "BR-READ-ID" USING WS-ID-FLAGS WS-ID-START WS-ID-LENGTH
             PERFORM QUALIFY-ID
         END-IF
     ELSE
         MOVE BR-IN-CURSOR TO WS-START
         CALL "BR-READ-ID" USING WS-ID-FLAGS WS-ID-START WS-ID-LENGTH
         IF BR-E-KEY = SPACES
             PERFORM QUALIFY-ID
             PERFORM FIND-BLOCK
         END-IF
     END-IF
     IF BR-E-KEY = SPACES
         PERFORM BLOCK-PROPERTIES
     END-IF
     IF BR-E-KEY = SPACES
         PERFORM BLOCK-NBT
     END-IF.

 FIND-BLOCK.
     CALL "BLOCKS-ID-OF" USING WS-NAME WS-BLOCK-ID
     IF WS-BLOCK-ID < 0
         MOVE "argument.block.id.invalid" TO WS-KEY
         MOVE WS-START TO WS-RC
         PERFORM RAISE-NAME
     ELSE
         COMPUTE WS-I = WS-BLOCK-ID + 1
         MOVE CB-DEFAULT-STATE(WS-I) TO WS-STATE
         MOVE WS-STATE TO L-INT
     END-IF.

 BLOCK-NBT.
     IF BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "{"
         CALL "BR-SNBT-VALUE" USING WS-SNBT-KIND
         IF BR-E-KEY = SPACES
             ADD 2 TO BR-V-AUX
         END-IF
     END-IF.

*> [name=value,...]: for a block each name must be a property of it and each value one of its values; for a tag any pair.
 BLOCK-PROPERTIES.
     IF BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "["
         ADD 1 TO BR-IN-CURSOR
         MOVE 0 TO WS-PROP-COUNT
         IF WS-TAG = 0
             PERFORM LOAD-DEFAULT-PROPS
         END-IF
         MOVE 0 TO WS-DONE WS-SEEN-COUNT
         PERFORM SKIP-SPACES
         IF BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "]"
             ADD 1 TO BR-IN-CURSOR
             MOVE 1 TO WS-DONE
         END-IF
         PERFORM UNTIL WS-DONE = 1 OR BR-E-KEY NOT = SPACES
             PERFORM ONE-PROPERTY
         END-PERFORM
         IF BR-E-KEY = SPACES AND WS-TAG = 0
             PERFORM RESOLVE-STATE
         END-IF
     END-IF.

*> The default state's pairs "name=value,..." into WS-PROP (the block's properties in list order).
 LOAD-DEFAULT-PROPS.
     MOVE SPACES TO WS-DEFAULT-PROPS
     CALL "BLOCKS-STATE-PROPS" USING WS-STATE WS-DEFAULT-PROPS
     MOVE 0 TO WS-PROP-COUNT
     MOVE 1 TO WS-POINTER
     PERFORM UNTIL WS-DEFAULT-PROPS(WS-POINTER:1) = SPACE OR WS-POINTER > 64
         ADD 1 TO WS-PROP-COUNT
         MOVE SPACES TO WS-P-NAME(WS-PROP-COUNT) WS-P-VALUE(WS-PROP-COUNT)
         MOVE 0 TO WS-P-NAME-LENGTH(WS-PROP-COUNT) WS-P-VALUE-LENGTH(WS-PROP-COUNT) WS-P-SET(WS-PROP-COUNT)
         PERFORM UNTIL WS-POINTER > 64 OR WS-DEFAULT-PROPS(WS-POINTER:1) = "="
             ADD 1 TO WS-P-NAME-LENGTH(WS-PROP-COUNT)
             MOVE WS-DEFAULT-PROPS(WS-POINTER:1) TO WS-P-NAME(WS-PROP-COUNT)(WS-P-NAME-LENGTH(WS-PROP-COUNT):1)
             ADD 1 TO WS-POINTER
         END-PERFORM
         ADD 1 TO WS-POINTER
         PERFORM UNTIL WS-POINTER > 64 OR WS-DEFAULT-PROPS(WS-POINTER:1) = "," OR WS-DEFAULT-PROPS(WS-POINTER:1) = SPACE
             ADD 1 TO WS-P-VALUE-LENGTH(WS-PROP-COUNT)
             MOVE WS-DEFAULT-PROPS(WS-POINTER:1) TO WS-P-VALUE(WS-PROP-COUNT)(WS-P-VALUE-LENGTH(WS-PROP-COUNT):1)
             ADD 1 TO WS-POINTER
         END-PERFORM
         ADD 1 TO WS-POINTER
     END-PERFORM.

 ONE-PROPERTY.
     PERFORM SKIP-SPACES
     MOVE BR-IN-CURSOR TO WS-NAME-START
     MOVE BR-IN-CURSOR TO WS-C
     CALL "BR-READ-STRING" USING WS-ONE WS-C WS-STR WS-STR-LENGTH
     IF BR-E-KEY = SPACES
         MOVE WS-C TO BR-IN-CURSOR
         PERFORM CHECK-NAME
     END-IF
     IF BR-E-KEY = SPACES
         PERFORM SKIP-SPACES
         IF BR-IN-CURSOR >= BR-IN-LENGTH OR BR-IN-TEXT(BR-IN-CURSOR + 1:1) NOT = "="
             MOVE "argument.block.property.novalue" TO WS-KEY
             MOVE 2 TO WS-ORDER
             MOVE BR-IN-CURSOR TO WS-RC
             PERFORM RAISE-TWO
         ELSE
             ADD 1 TO BR-IN-CURSOR
             PERFORM SKIP-SPACES
             PERFORM PROPERTY-VALUE
         END-IF
     END-IF
     IF BR-E-KEY = SPACES
         PERFORM SKIP-SPACES
         EVALUATE TRUE
             WHEN BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = ","
                 ADD 1 TO BR-IN-CURSOR
             WHEN BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "]"
                 ADD 1 TO BR-IN-CURSOR
                 MOVE 1 TO WS-DONE
             WHEN OTHER
                 MOVE "argument.block.property.unclosed" TO WS-KEY
                 MOVE BR-IN-CURSOR TO WS-RC
                 MOVE 0 TO WS-N-ARGS WS-L1 WS-L2
                 PERFORM RAISE-NOW
         END-EVALUATE
     END-IF.

*> The name WS-STR: a repeat is argument.block.property.duplicate; for a block an unknown one is ...unknown (cursor at the name).
 CHECK-NAME.
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-SEEN-COUNT
         IF WS-SEEN-LENGTH(WS-I) = WS-STR-LENGTH AND WS-SEEN-NAME(WS-I)(1:WS-STR-LENGTH) = WS-STR(1:WS-STR-LENGTH)
             MOVE 1 TO WS-FOUND
         END-IF
     END-PERFORM
     IF WS-FOUND = 1
         MOVE "argument.block.property.duplicate" TO WS-KEY
         MOVE 2 TO WS-ORDER
         MOVE WS-NAME-START TO WS-RC
         PERFORM RAISE-TWO
     ELSE
         IF WS-TAG = 0
             MOVE 0 TO WS-PROP-AT
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-PROP-COUNT
                 IF WS-P-NAME-LENGTH(WS-I) = WS-STR-LENGTH AND WS-P-NAME(WS-I)(1:WS-STR-LENGTH) = WS-STR(1:WS-STR-LENGTH)
                     MOVE WS-I TO WS-PROP-AT
                 END-IF
             END-PERFORM
             IF WS-PROP-AT = 0
                 MOVE "argument.block.property.unknown" TO WS-KEY
                 MOVE 1 TO WS-ORDER
                 MOVE WS-NAME-START TO WS-RC
                 PERFORM RAISE-TWO
             END-IF
         END-IF
     END-IF
     IF BR-E-KEY = SPACES AND WS-SEEN-COUNT < 32
         ADD 1 TO WS-SEEN-COUNT
         MOVE WS-STR(1:64) TO WS-SEEN-NAME(WS-SEEN-COUNT)
         MOVE WS-STR-LENGTH TO WS-SEEN-LENGTH(WS-SEEN-COUNT)
     END-IF
     MOVE WS-STR TO WS-PROP-TEXT
     MOVE WS-STR-LENGTH TO WS-PROP-TEXT-LENGTH.

*> The value: for a block it must be one of the values some state of the block has for the property.
 PROPERTY-VALUE.
     MOVE BR-IN-CURSOR TO WS-VALUE-START
     MOVE BR-IN-CURSOR TO WS-C
     CALL "BR-READ-STRING" USING WS-ONE WS-C WS-VAL WS-VAL-LENGTH
     IF BR-E-KEY = SPACES
         MOVE WS-C TO BR-IN-CURSOR
         IF WS-TAG = 0
             PERFORM CHECK-VALUE
         END-IF
     END-IF.

 CHECK-VALUE.
     MOVE 0 TO WS-FOUND
     MOVE SPACES TO WS-WANT
     STRING WS-PROP-TEXT(1:WS-PROP-TEXT-LENGTH) "=" WS-VAL(1:WS-VAL-LENGTH) DELIMITED BY SIZE INTO WS-WANT
     COMPUTE WS-NEEDLE-LENGTH = WS-PROP-TEXT-LENGTH + 1 + WS-VAL-LENGTH
     COMPUTE WS-LAST = CB-FIRST-STATE(WS-BLOCK-ID + 1) + CB-STATES(WS-BLOCK-ID + 1) - 1
     PERFORM VARYING WS-J FROM CB-FIRST-STATE(WS-BLOCK-ID + 1) BY 1 UNTIL WS-J > WS-LAST OR WS-FOUND = 1
         MOVE SPACES TO WS-STATE-PROPS
         CALL "BLOCKS-STATE-PROPS" USING WS-J WS-STATE-PROPS
         MOVE SPACES TO WS-HAVE
         STRING "," FUNCTION TRIM(WS-STATE-PROPS) "," DELIMITED BY SIZE INTO WS-HAVE
         MOVE SPACES TO WS-NEEDLE
         STRING "," WS-WANT(1:WS-NEEDLE-LENGTH) "," DELIMITED BY SIZE INTO WS-NEEDLE
         MOVE 0 TO WS-COUNT-FOUND
         INSPECT WS-HAVE TALLYING WS-COUNT-FOUND FOR ALL WS-NEEDLE(1:WS-NEEDLE-LENGTH + 2)
         IF WS-COUNT-FOUND > 0
             MOVE 1 TO WS-FOUND
         END-IF
     END-PERFORM
     IF WS-FOUND = 0
         MOVE "argument.block.property.invalid" TO WS-KEY
         MOVE 3 TO WS-N-ARGS
         MOVE SPACES TO WS-A1 WS-A2 WS-A3
         MOVE WS-NAME-LENGTH TO WS-L1
         MOVE WS-NAME(1:WS-L1) TO WS-A1(1:WS-L1)
         MOVE WS-VAL-LENGTH TO WS-L2
         MOVE WS-VAL(1:WS-L2) TO WS-A2(1:WS-L2)
         MOVE WS-PROP-TEXT-LENGTH TO WS-L3
         MOVE WS-PROP-TEXT(1:WS-L3) TO WS-A3(1:WS-L3)
         MOVE WS-VALUE-START TO WS-RC
         PERFORM RAISE-THREE
     ELSE
         MOVE WS-VAL(1:32) TO WS-P-VALUE(WS-PROP-AT)
         MOVE WS-VAL-LENGTH TO WS-P-VALUE-LENGTH(WS-PROP-AT)
         MOVE 1 TO WS-P-SET(WS-PROP-AT)
     END-IF.

 RAISE-THREE.
     CALL "BR-RAISE-3" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-A3 WS-L3 WS-RC.

*> The state whose properties are the default state's with the given values.
 RESOLVE-STATE.
     MOVE SPACES TO WS-PAIRS
     MOVE 1 TO WS-POINTER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-PROP-COUNT
         IF WS-I > 1
             STRING "," DELIMITED BY SIZE INTO WS-PAIRS WITH POINTER WS-POINTER
         END-IF
         STRING WS-P-NAME(WS-I)(1:WS-P-NAME-LENGTH(WS-I)) "=" WS-P-VALUE(WS-I)(1:WS-P-VALUE-LENGTH(WS-I))
             DELIMITED BY SIZE INTO WS-PAIRS WITH POINTER WS-POINTER
     END-PERFORM
     CALL "BLOCKS-STATE-OF" USING WS-NAME WS-PAIRS WS-STATE
     MOVE WS-STATE TO L-INT.

*> ---- items ----------------------------------------------------------------------------------------
 DO-ITEM.
     MOVE -1 TO L-INT
     MOVE 0 TO BR-V-AUX
     MOVE BR-IN-CURSOR TO WS-START
     EVALUATE TRUE
         WHEN BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "#"
             IF BR-N-TYPE(L-NODE) = BR-P-ITEM-STACK
                 MOVE "argument.item.tag.disallowed" TO WS-KEY
                 MOVE BR-IN-CURSOR TO WS-RC
                 MOVE 0 TO WS-N-ARGS WS-L1 WS-L2
                 PERFORM RAISE-NOW
             ELSE
                 MOVE 1 TO BR-V-AUX
                 ADD 1 TO BR-IN-CURSOR
                 CALL "BR-READ-ID" USING WS-ID-FLAGS WS-ID-START WS-ID-LENGTH
             END-IF
         WHEN BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "*"
                 AND BR-N-TYPE(L-NODE) = BR-P-ITEM-PREDICATE
             MOVE 4 TO BR-V-AUX
             ADD 1 TO BR-IN-CURSOR
         WHEN OTHER
             CALL "BR-READ-ID" USING WS-ID-FLAGS WS-ID-START WS-ID-LENGTH
             IF BR-E-KEY = SPACES
                 PERFORM QUALIFY-ID
                 PERFORM FIND-ITEM
             END-IF
     END-EVALUATE
     IF BR-E-KEY = SPACES AND BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "["
         ADD 1 TO BR-IN-CURSOR
         IF BR-N-TYPE(L-NODE) = BR-P-ITEM-STACK
             PERFORM COMPONENT-LIST
         ELSE
             PERFORM CONDITION-LIST
         END-IF
     END-IF.

*> The item whose key is the identifier (the table keeps keys as BLOCKS-ID-OF reads them: without minecraft: unless the
*> cobolcraft set is open).
 FIND-ITEM.
     MOVE 0 TO WS-FOUND
     MOVE WS-NAME-LENGTH TO WS-L1
     MOVE WS-NAME TO WS-WANT
     IF CT-SET-TYPE NOT = CT-TYPE-COBOLCRAFT AND WS-NAME(1:10) = "minecraft:"
         MOVE SPACES TO WS-WANT
         COMPUTE WS-L1 = WS-NAME-LENGTH - 10
         MOVE WS-NAME(11:WS-L1) TO WS-WANT
     END-IF
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > IT-COUNT
         IF IT-KEY-LENGTH(WS-I) = WS-L1 AND IT-KEY(WS-I)(1:WS-L1) = WS-WANT(1:WS-L1)
             COMPUTE L-INT = WS-I - 1
             MOVE 1 TO WS-FOUND
         END-IF
     END-PERFORM
     IF WS-FOUND = 0
         MOVE "argument.item.id.invalid" TO WS-KEY
         MOVE WS-START TO WS-RC
         PERFORM RAISE-NAME
     END-IF.

*> item_stack components: ! type, or type = value; a type may appear once; after a comma another component must follow.
 COMPONENT-LIST.
     MOVE 0 TO WS-DONE WS-SEEN-COUNT
     PERFORM SKIP-SPACES
     IF BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "]"
         ADD 1 TO BR-IN-CURSOR
         MOVE 1 TO WS-DONE
     END-IF
     PERFORM UNTIL WS-DONE = 1 OR BR-E-KEY NOT = SPACES
         PERFORM ONE-COMPONENT
         IF BR-E-KEY = SPACES
             PERFORM SKIP-SPACES
             EVALUATE TRUE
                 WHEN BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = ","
                     ADD 1 TO BR-IN-CURSOR
                     PERFORM SKIP-SPACES
                     IF BR-IN-CURSOR >= BR-IN-LENGTH OR BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "]"
                         MOVE "arguments.item.component.expected" TO WS-KEY
                         MOVE BR-IN-CURSOR TO WS-RC
                         MOVE 0 TO WS-N-ARGS WS-L1 WS-L2
                         PERFORM RAISE-NOW
                     END-IF
                 WHEN BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "]"
                     ADD 1 TO BR-IN-CURSOR
                     MOVE 1 TO WS-DONE
                 WHEN OTHER
                     MOVE "]" TO WS-CH
                     PERFORM RAISE-EXPECTED
             END-EVALUATE
         END-IF
     END-PERFORM
     IF BR-E-KEY = SPACES AND WS-SEEN-COUNT > 0
         MOVE 2 TO BR-V-AUX
     END-IF.

 RAISE-EXPECTED.
     MOVE "parsing.expected" TO WS-KEY
     MOVE 1 TO WS-N-ARGS
     MOVE WS-CH TO WS-A1(1:1)
     MOVE 1 TO WS-L1
     MOVE 0 TO WS-L2
     MOVE BR-IN-CURSOR TO WS-RC
     PERFORM RAISE-NOW.

 ONE-COMPONENT.
     MOVE 0 TO WS-NEGATED
     IF BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "!"
         MOVE 1 TO WS-NEGATED
         ADD 1 TO BR-IN-CURSOR
     END-IF
     CALL "BR-READ-ID" USING WS-ID-FLAGS WS-ID-START WS-ID-LENGTH
     IF BR-E-KEY = SPACES
         PERFORM QUALIFY-ID
         PERFORM CHECK-REPEAT
     END-IF
     IF BR-E-KEY = SPACES AND WS-NEGATED = 0
         PERFORM SKIP-SPACES
         IF BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "="
             ADD 1 TO BR-IN-CURSOR
             PERFORM SKIP-SPACES
             CALL "BR-SNBT-VALUE" USING WS-SNBT-KIND
         ELSE
             MOVE "=" TO WS-CH
             PERFORM RAISE-EXPECTED
         END-IF
     END-IF.

*> A component type given twice (also as a removal) is arguments.item.component.repeated, without an input context.
 CHECK-REPEAT.
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-SEEN-COUNT
         IF WS-SEEN-LENGTH(WS-I) = WS-NAME-LENGTH AND WS-SEEN-NAME(WS-I)(1:WS-NAME-LENGTH) = WS-NAME(1:WS-NAME-LENGTH)
             MOVE 1 TO WS-FOUND
         END-IF
     END-PERFORM
     IF WS-FOUND = 1
         MOVE "arguments.item.component.repeated" TO WS-KEY
         MOVE -1 TO WS-RC
         PERFORM RAISE-NAME
     ELSE
         IF WS-SEEN-COUNT < 32
             ADD 1 TO WS-SEEN-COUNT
             MOVE WS-NAME(1:64) TO WS-SEEN-NAME(WS-SEEN-COUNT)
             MOVE WS-NAME-LENGTH TO WS-SEEN-LENGTH(WS-SEEN-COUNT)
         END-IF
     END-IF.

*> item_predicate conditions: alternatives (|) joined by commas; a term is ! test, id = value, id ~ value or id.
 CONDITION-LIST.
     MOVE 0 TO WS-DONE WS-ANY
     PERFORM SKIP-SPACES
     IF BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "]"
         ADD 1 TO BR-IN-CURSOR
         MOVE 1 TO WS-DONE
     END-IF
     PERFORM UNTIL WS-DONE = 1 OR BR-E-KEY NOT = SPACES
         PERFORM ONE-TERM
         IF BR-E-KEY = SPACES
             MOVE 1 TO WS-ANY
             PERFORM SKIP-SPACES
             EVALUATE TRUE
                 WHEN BR-IN-CURSOR < BR-IN-LENGTH AND (BR-IN-TEXT(BR-IN-CURSOR + 1:1) = ","
                         OR BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "|")
                     ADD 1 TO BR-IN-CURSOR
                     PERFORM SKIP-SPACES
                 WHEN BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "]"
                     ADD 1 TO BR-IN-CURSOR
                     MOVE 1 TO WS-DONE
                 WHEN OTHER
                     MOVE "]" TO WS-CH
                     PERFORM RAISE-EXPECTED
             END-EVALUATE
         END-IF
     END-PERFORM
     IF BR-E-KEY = SPACES AND WS-ANY = 1
         ADD 2 TO BR-V-AUX
     END-IF.

 ONE-TERM.
     IF BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "!"
         ADD 1 TO BR-IN-CURSOR
     END-IF
     CALL "BR-READ-ID" USING WS-ID-FLAGS WS-ID-START WS-ID-LENGTH
     IF BR-E-KEY = SPACES
         PERFORM SKIP-SPACES
         IF BR-IN-CURSOR < BR-IN-LENGTH AND (BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "="
                 OR BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "~")
             ADD 1 TO BR-IN-CURSOR
             PERFORM SKIP-SPACES
             CALL "BR-SNBT-VALUE" USING WS-SNBT-KIND
         END-IF
     END-IF.

 MAIN-LINE.
     MOVE SPACES TO BR-E-KEY
     EVALUATE BR-N-TYPE(L-NODE)
         WHEN BR-P-BLOCK-STATE
         WHEN BR-P-BLOCK-PREDICATE
             PERFORM DO-BLOCK
         WHEN OTHER
             PERFORM DO-ITEM
     END-EVALUATE.
 END PROGRAM BR-ARG-BLOCK.
