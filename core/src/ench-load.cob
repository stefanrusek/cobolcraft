*> The enchantment definitions read from the loaded enchantment registry rows (docs/protocol/28 sections 3 to 7, 17 section 6.3; US14):
*> the JSON of a row (CONTENT-REGISTRY-ENTRY, registry "enchantment") becomes the prefix expressions of the level-based values (ench-4.cob) and
*> of the value effects (ench-5.cob), and the requirement terms of a conditional effect are evaluated against a context (ENCHCTX.cpy).
*>   ENCH-NUMBER-TEXT USING number (FLOAT-LONG), text out (PIC X(16))
*>   ENCH-LBV-TEXT USING JSON-DOC, node, text (PIC X(200), appended at the pointer), pointer: a level-based value node (a number, linear,
*>     levels_squared, lookup, fraction, clamped, exponent, constant) as its prefix expression
*>   ENCH-EFFECT-TEXT USING JSON-DOC, effect node, text, pointer, status out (0 ok, 3 an effect type the evaluator has no word for: add, multiply,
*>     set, exponential and all_of are known)
*>   ENCH-REQ-EVAL USING JSON-DOC, requirement node (0 = none), ENCH-CTX, result out (1 or 0). Terms: all_of, any_of, inverted,
*>     damage_source_properties (is_direct, tags of the damage type), entity_properties (this: type or "#" tag of the victim). Any other
*>     term or predicate member does not match (documented assumption: a requirement this engine cannot decide does not apply)
*>   ENCH-FOLD USING enchantment registry id, component key ("minecraft:damage", the namespace optional), level, ENCH-CTX, value in
*>     (ten-thousandths), value out, status out (0 ok, 4 no such registry row; the loader keeps strict JSON only): folds the effects of the component in
*>     list order, those whose requirements hold; a component the row does not define leaves the value unchanged

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-NUMBER-TEXT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-EDIT                PIC -(8)9.9(6).
 LINKAGE SECTION.
 01 L-NUMBER               FLOAT-LONG.
 01 L-TEXT                 PIC X(16).
 PROCEDURE DIVISION USING L-NUMBER L-TEXT.
     COMPUTE WS-EDIT = L-NUMBER
     MOVE FUNCTION TRIM(WS-EDIT) TO L-TEXT
     GOBACK.
 END PROGRAM ENCH-NUMBER-TEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-LBV-TEXT RECURSIVE.
 DATA DIVISION.
 LOCAL-STORAGE SECTION.
 01 LS-TMP                 PIC X(112).
 01 LS-KEY                 PIC X(32).
 01 LS-KEY-LENGTH          BINARY-LONG.
 01 LS-MEMBER              BINARY-LONG.
 01 LS-TYPE                PIC X(32).
 01 LS-TYPE-LENGTH         BINARY-LONG.
 01 LS-CAPACITY            BINARY-LONG VALUE 32.
 01 LS-NUM                 PIC X(16).
 01 LS-CHILD               BINARY-LONG.
 01 LS-COUNT               BINARY-LONG.
 01 LS-COUNT-EDIT          PIC Z(8)9.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-TEXT                 PIC X(200).
 01 L-POINTER              BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-TEXT L-POINTER.
     IF L-NODE = 0
         GOBACK
     END-IF
     IF JN-TYPE(L-NODE) = JT-NUMBER
         CALL "ENCH-NUMBER-TEXT" USING JN-NUM(L-NODE) LS-NUM
         STRING FUNCTION TRIM(LS-NUM) " " DELIMITED BY SIZE INTO L-TEXT POINTER L-POINTER
         GOBACK
     END-IF
     IF JN-TYPE(L-NODE) NOT = JT-OBJECT
         GOBACK
     END-IF
     MOVE "type" TO LS-KEY
     MOVE 4 TO LS-KEY-LENGTH
     CALL "JSON-MEMBER" USING JSON-DOC L-NODE LS-KEY LS-KEY-LENGTH LS-MEMBER
     MOVE SPACES TO LS-TYPE
     CALL "JSON-STRING" USING JSON-DOC LS-MEMBER LS-TYPE LS-CAPACITY LS-TYPE-LENGTH
     IF LS-TYPE(1:10) = "minecraft:"
         MOVE LS-TYPE(11:22) TO LS-TMP
         MOVE LS-TMP TO LS-TYPE
     END-IF
     EVALUATE LS-TYPE
         WHEN "linear"
             STRING "linear " DELIMITED BY SIZE INTO L-TEXT POINTER L-POINTER
             MOVE "base" TO LS-KEY
             MOVE 4 TO LS-KEY-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC L-NODE LS-KEY LS-KEY-LENGTH LS-MEMBER
             CALL "ENCH-LBV-TEXT" USING JSON-DOC LS-MEMBER L-TEXT L-POINTER
             MOVE "per_level_above_first" TO LS-KEY
             MOVE 21 TO LS-KEY-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC L-NODE LS-KEY LS-KEY-LENGTH LS-MEMBER
             CALL "ENCH-LBV-TEXT" USING JSON-DOC LS-MEMBER L-TEXT L-POINTER
         WHEN "levels_squared"
             STRING "squared " DELIMITED BY SIZE INTO L-TEXT POINTER L-POINTER
             MOVE "added" TO LS-KEY
             MOVE 5 TO LS-KEY-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC L-NODE LS-KEY LS-KEY-LENGTH LS-MEMBER
             CALL "ENCH-LBV-TEXT" USING JSON-DOC LS-MEMBER L-TEXT L-POINTER
         WHEN "constant"
             MOVE "value" TO LS-KEY
             MOVE 5 TO LS-KEY-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC L-NODE LS-KEY LS-KEY-LENGTH LS-MEMBER
             CALL "ENCH-LBV-TEXT" USING JSON-DOC LS-MEMBER L-TEXT L-POINTER
         WHEN "lookup"
             MOVE "values" TO LS-KEY
             MOVE 6 TO LS-KEY-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC L-NODE LS-KEY LS-KEY-LENGTH LS-MEMBER
             MOVE JN-COUNT(LS-MEMBER) TO LS-COUNT
             MOVE LS-COUNT TO LS-COUNT-EDIT
             STRING "lookup " FUNCTION TRIM(LS-COUNT-EDIT) " " DELIMITED BY SIZE INTO L-TEXT POINTER L-POINTER
             MOVE JN-FIRST(LS-MEMBER) TO LS-CHILD
             PERFORM UNTIL LS-CHILD = 0
                 CALL "ENCH-LBV-TEXT" USING JSON-DOC LS-CHILD L-TEXT L-POINTER
                 MOVE JN-NEXT(LS-CHILD) TO LS-CHILD
             END-PERFORM
             MOVE "fallback" TO LS-KEY
             MOVE 8 TO LS-KEY-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC L-NODE LS-KEY LS-KEY-LENGTH LS-MEMBER
             CALL "ENCH-LBV-TEXT" USING JSON-DOC LS-MEMBER L-TEXT L-POINTER
         WHEN "fraction"
             STRING "fraction " DELIMITED BY SIZE INTO L-TEXT POINTER L-POINTER
             MOVE "numerator" TO LS-KEY
             MOVE 9 TO LS-KEY-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC L-NODE LS-KEY LS-KEY-LENGTH LS-MEMBER
             CALL "ENCH-LBV-TEXT" USING JSON-DOC LS-MEMBER L-TEXT L-POINTER
             MOVE "denominator" TO LS-KEY
             MOVE 11 TO LS-KEY-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC L-NODE LS-KEY LS-KEY-LENGTH LS-MEMBER
             CALL "ENCH-LBV-TEXT" USING JSON-DOC LS-MEMBER L-TEXT L-POINTER
         WHEN "clamped"
             STRING "clamped " DELIMITED BY SIZE INTO L-TEXT POINTER L-POINTER
             MOVE "min" TO LS-KEY
             MOVE 3 TO LS-KEY-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC L-NODE LS-KEY LS-KEY-LENGTH LS-MEMBER
             CALL "ENCH-LBV-TEXT" USING JSON-DOC LS-MEMBER L-TEXT L-POINTER
             MOVE "max" TO LS-KEY
             CALL "JSON-MEMBER" USING JSON-DOC L-NODE LS-KEY LS-KEY-LENGTH LS-MEMBER
             CALL "ENCH-LBV-TEXT" USING JSON-DOC LS-MEMBER L-TEXT L-POINTER
             MOVE "value" TO LS-KEY
             MOVE 5 TO LS-KEY-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC L-NODE LS-KEY LS-KEY-LENGTH LS-MEMBER
             CALL "ENCH-LBV-TEXT" USING JSON-DOC LS-MEMBER L-TEXT L-POINTER
         WHEN "exponent"
             STRING "exponent " DELIMITED BY SIZE INTO L-TEXT POINTER L-POINTER
             MOVE "base" TO LS-KEY
             MOVE 4 TO LS-KEY-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC L-NODE LS-KEY LS-KEY-LENGTH LS-MEMBER
             CALL "ENCH-LBV-TEXT" USING JSON-DOC LS-MEMBER L-TEXT L-POINTER
             MOVE "power" TO LS-KEY
             MOVE 5 TO LS-KEY-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC L-NODE LS-KEY LS-KEY-LENGTH LS-MEMBER
             CALL "ENCH-LBV-TEXT" USING JSON-DOC LS-MEMBER L-TEXT L-POINTER
     END-EVALUATE
     GOBACK.
 END PROGRAM ENCH-LBV-TEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-EFFECT-TEXT RECURSIVE.
 DATA DIVISION.
 LOCAL-STORAGE SECTION.
 01 LS-TMP                 PIC X(112).
 01 LS-KEY                 PIC X(32).
 01 LS-KEY-LENGTH          BINARY-LONG.
 01 LS-MEMBER              BINARY-LONG.
 01 LS-TYPE                PIC X(32).
 01 LS-TYPE-LENGTH         BINARY-LONG.
 01 LS-CAPACITY            BINARY-LONG VALUE 32.
 01 LS-CHILD               BINARY-LONG.
 01 LS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-TEXT                 PIC X(200).
 01 L-POINTER              BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-TEXT L-POINTER L-STATUS.
     MOVE 3 TO L-STATUS
     IF L-NODE = 0
         GOBACK
     END-IF
     MOVE "type" TO LS-KEY
     MOVE 4 TO LS-KEY-LENGTH
     CALL "JSON-MEMBER" USING JSON-DOC L-NODE LS-KEY LS-KEY-LENGTH LS-MEMBER
     MOVE SPACES TO LS-TYPE
     CALL "JSON-STRING" USING JSON-DOC LS-MEMBER LS-TYPE LS-CAPACITY LS-TYPE-LENGTH
     IF LS-TYPE(1:10) = "minecraft:"
         MOVE LS-TYPE(11:22) TO LS-TMP
         MOVE LS-TMP TO LS-TYPE
     END-IF
     EVALUATE LS-TYPE
         WHEN "add" WHEN "multiply" WHEN "set"
             STRING FUNCTION TRIM(LS-TYPE) " " DELIMITED BY SIZE INTO L-TEXT POINTER L-POINTER
             MOVE "value" TO LS-KEY
             MOVE 5 TO LS-KEY-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC L-NODE LS-KEY LS-KEY-LENGTH LS-MEMBER
             CALL "ENCH-LBV-TEXT" USING JSON-DOC LS-MEMBER L-TEXT L-POINTER
             MOVE 0 TO L-STATUS
         WHEN "exponential"
             STRING "exponential " DELIMITED BY SIZE INTO L-TEXT POINTER L-POINTER
             MOVE "base" TO LS-KEY
             MOVE 4 TO LS-KEY-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC L-NODE LS-KEY LS-KEY-LENGTH LS-MEMBER
             CALL "ENCH-LBV-TEXT" USING JSON-DOC LS-MEMBER L-TEXT L-POINTER
             MOVE "power" TO LS-KEY
             MOVE 5 TO LS-KEY-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC L-NODE LS-KEY LS-KEY-LENGTH LS-MEMBER
             CALL "ENCH-LBV-TEXT" USING JSON-DOC LS-MEMBER L-TEXT L-POINTER
             MOVE 0 TO L-STATUS
         WHEN "all_of"
             STRING "all_of " DELIMITED BY SIZE INTO L-TEXT POINTER L-POINTER
             MOVE "effects" TO LS-KEY
             MOVE 7 TO LS-KEY-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC L-NODE LS-KEY LS-KEY-LENGTH LS-MEMBER
             MOVE 0 TO L-STATUS
             IF LS-MEMBER > 0
                 MOVE JN-FIRST(LS-MEMBER) TO LS-CHILD
                 PERFORM UNTIL LS-CHILD = 0 OR L-STATUS NOT = 0
                     CALL "ENCH-EFFECT-TEXT" USING JSON-DOC LS-CHILD L-TEXT L-POINTER LS-STATUS
                     MOVE LS-STATUS TO L-STATUS
                     MOVE JN-NEXT(LS-CHILD) TO LS-CHILD
                 END-PERFORM
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM ENCH-EFFECT-TEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-REQ-EVAL RECURSIVE.
 DATA DIVISION.
 LOCAL-STORAGE SECTION.
 01 LS-TMP                 PIC X(112).
 01 LS-KEY                 PIC X(32).
 01 LS-KEY-LENGTH          BINARY-LONG.
 01 LS-MEMBER              BINARY-LONG.
 01 LS-PRED                BINARY-LONG.
 01 LS-CHILD               BINARY-LONG.
 01 LS-SUB                 BINARY-LONG.
 01 LS-EXPECT              BINARY-LONG.
 01 LS-TEXT                PIC X(112).
 01 LS-TEXT-LENGTH         BINARY-LONG.
 01 LS-CAPACITY            BINARY-LONG VALUE 112.
 01 LS-TAG                 PIC X(32).
 01 LS-TAG-LONG            PIC X(64).
 01 LS-LONG-CAPACITY       BINARY-LONG VALUE 64.
 01 LS-HAS                 BINARY-LONG.
 01 LS-RESULT              BINARY-LONG.
 01 LS-REGISTRY            PIC X(48) VALUE "entity_type".
 01 LS-SHORT-KEY           PIC X(48).
 LINKAGE SECTION.
 COPY JSONDOC.
 COPY ENCHCTX REPLACING LEADING ==EC-== BY ==LC-==.
 01 L-NODE                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE ENCH-CTX L-RESULT.
     MOVE 1 TO L-RESULT
     IF L-NODE = 0
         GOBACK
     END-IF
     MOVE 0 TO L-RESULT
     MOVE "condition" TO LS-KEY
     MOVE 9 TO LS-KEY-LENGTH
     CALL "JSON-MEMBER" USING JSON-DOC L-NODE LS-KEY LS-KEY-LENGTH LS-MEMBER
     MOVE SPACES TO LS-TEXT
     CALL "JSON-STRING" USING JSON-DOC LS-MEMBER LS-TEXT LS-CAPACITY LS-TEXT-LENGTH
     IF LS-TEXT(1:10) = "minecraft:"
         MOVE LS-TEXT(11:102) TO LS-TMP
         MOVE LS-TMP TO LS-TEXT
     END-IF
     EVALUATE TRUE
         WHEN LS-TEXT = "all_of" OR LS-TEXT = "any_of"
             MOVE "terms" TO LS-KEY
             MOVE 5 TO LS-KEY-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC L-NODE LS-KEY LS-KEY-LENGTH LS-PRED
             IF LS-TEXT = "all_of"
                 MOVE 1 TO L-RESULT
             END-IF
             IF LS-PRED > 0
                 MOVE JN-FIRST(LS-PRED) TO LS-CHILD
                 PERFORM UNTIL LS-CHILD = 0
                     CALL "ENCH-REQ-EVAL" USING JSON-DOC LS-CHILD ENCH-CTX LS-RESULT
                     IF LS-TEXT = "all_of" AND LS-RESULT = 0
                         MOVE 0 TO L-RESULT
                     END-IF
                     IF LS-TEXT = "any_of" AND LS-RESULT = 1
                         MOVE 1 TO L-RESULT
                     END-IF
                     MOVE JN-NEXT(LS-CHILD) TO LS-CHILD
                 END-PERFORM
             END-IF
         WHEN LS-TEXT = "inverted"
             MOVE "term" TO LS-KEY
             MOVE 4 TO LS-KEY-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC L-NODE LS-KEY LS-KEY-LENGTH LS-PRED
             CALL "ENCH-REQ-EVAL" USING JSON-DOC LS-PRED ENCH-CTX LS-RESULT
             COMPUTE L-RESULT = 1 - LS-RESULT
         WHEN LS-TEXT = "damage_source_properties"
             MOVE "predicate" TO LS-KEY
             MOVE 9 TO LS-KEY-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC L-NODE LS-KEY LS-KEY-LENGTH LS-PRED
             MOVE 1 TO L-RESULT
             MOVE "is_direct" TO LS-KEY
             MOVE 9 TO LS-KEY-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC LS-PRED LS-KEY LS-KEY-LENGTH LS-MEMBER
             IF LS-MEMBER > 0
                 MOVE 0 TO LS-EXPECT
                 IF JN-TYPE(LS-MEMBER) = JT-TRUE
                     MOVE 1 TO LS-EXPECT
                 END-IF
                 IF LS-EXPECT NOT = LC-DIRECT
                     MOVE 0 TO L-RESULT
                 END-IF
             END-IF
             MOVE "source_entity" TO LS-KEY
             MOVE 13 TO LS-KEY-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC LS-PRED LS-KEY LS-KEY-LENGTH LS-MEMBER
             IF LS-MEMBER > 0
                 MOVE 0 TO L-RESULT
             END-IF
             MOVE "direct_entity" TO LS-KEY
             MOVE 13 TO LS-KEY-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC LS-PRED LS-KEY LS-KEY-LENGTH LS-MEMBER
             IF LS-MEMBER > 0
                 MOVE 0 TO L-RESULT
             END-IF
             MOVE "tags" TO LS-KEY
             MOVE 4 TO LS-KEY-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC LS-PRED LS-KEY LS-KEY-LENGTH LS-MEMBER
             IF LS-MEMBER > 0
                 MOVE JN-FIRST(LS-MEMBER) TO LS-CHILD
                 PERFORM UNTIL LS-CHILD = 0
                     MOVE "id" TO LS-KEY
                     MOVE 2 TO LS-KEY-LENGTH
                     CALL "JSON-MEMBER" USING JSON-DOC LS-CHILD LS-KEY LS-KEY-LENGTH LS-SUB
                     MOVE SPACES TO LS-TAG-LONG LS-TAG
                     CALL "JSON-STRING" USING JSON-DOC LS-SUB LS-TAG-LONG LS-LONG-CAPACITY LS-RESULT
                     IF LS-TAG-LONG(1:10) = "minecraft:"
                         MOVE LS-TAG-LONG(11:32) TO LS-TAG
                     ELSE
                         MOVE LS-TAG-LONG(1:32) TO LS-TAG
                     END-IF
                     MOVE "expected" TO LS-KEY
                     MOVE 8 TO LS-KEY-LENGTH
                     CALL "JSON-MEMBER" USING JSON-DOC LS-CHILD LS-KEY LS-KEY-LENGTH LS-SUB
                     MOVE 0 TO LS-EXPECT
                     IF LS-SUB > 0 AND JN-TYPE(LS-SUB) = JT-TRUE
                         MOVE 1 TO LS-EXPECT
                     END-IF
                     CALL "TOOL-DAMAGE-TAG" USING LC-DAMAGE-KEY LS-TAG LS-HAS
                     IF LS-HAS NOT = LS-EXPECT
                         MOVE 0 TO L-RESULT
                     END-IF
                     MOVE JN-NEXT(LS-CHILD) TO LS-CHILD
                 END-PERFORM
             END-IF
         WHEN LS-TEXT = "entity_properties"
             MOVE "entity" TO LS-KEY
             MOVE 6 TO LS-KEY-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC L-NODE LS-KEY LS-KEY-LENGTH LS-MEMBER
             MOVE SPACES TO LS-TAG
             MOVE 32 TO LS-TEXT-LENGTH
             CALL "JSON-STRING" USING JSON-DOC LS-MEMBER LS-TAG LS-TEXT-LENGTH LS-RESULT
             MOVE "predicate" TO LS-KEY
             MOVE 9 TO LS-KEY-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC L-NODE LS-KEY LS-KEY-LENGTH LS-PRED
             MOVE "type" TO LS-KEY
             MOVE 4 TO LS-KEY-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC LS-PRED LS-KEY LS-KEY-LENGTH LS-MEMBER
             MOVE SPACES TO LS-TEXT
             MOVE 112 TO LS-CAPACITY
             CALL "JSON-STRING" USING JSON-DOC LS-MEMBER LS-TEXT LS-CAPACITY LS-TEXT-LENGTH
             IF LS-TAG = "this" AND LS-TEXT-LENGTH > 0
                 IF LS-TEXT(1:1) = "#"
                     MOVE SPACES TO LS-SHORT-KEY
                     MOVE LS-TEXT(2:111) TO LS-TMP
                     MOVE LS-TMP TO LS-TEXT
                     CALL "CONTENT-TAG-HAS" USING LS-REGISTRY LS-TEXT LC-VICTIM-ID L-RESULT
                 ELSE
                     IF LS-TEXT(1:10) = "minecraft:"
                         MOVE LS-TEXT(11:102) TO LS-TMP
                         MOVE LS-TMP TO LS-TEXT
                     END-IF
                     IF LS-TEXT(1:48) = LC-VICTIM-KEY
                         MOVE 1 TO L-RESULT
                     END-IF
                 END-IF
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM ENCH-REQ-EVAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-FOLD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY JSONDOC.
 01 WS-REGISTRY            PIC X(112) VALUE "enchantment".
 01 WS-TMP                 PIC X(112).
 01 WS-KEY                 PIC X(112).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-AREA                PIC X(16384).
 01 WS-CAPACITY            BINARY-LONG VALUE 16384.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-NAME                PIC X(112).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-EFFECTS             BINARY-LONG.
 01 WS-LIST                BINARY-LONG.
 01 WS-ELEMENT             BINARY-LONG.
 01 WS-REQ                 BINARY-LONG.
 01 WS-EFFECT              BINARY-LONG.
 01 WS-KEYWORD             PIC X(32).
 01 WS-KEYWORD-LENGTH      BINARY-LONG.
 01 WS-APPLIES             BINARY-LONG.
 01 WS-TEXT                PIC X(200).
 01 WS-POINTER             BINARY-LONG.
 01 WS-TEXT-STATUS         BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 01 WS-FOLD-STATUS         BINARY-LONG.
 LINKAGE SECTION.
 COPY ENCHCTX REPLACING LEADING ==EC-== BY ==LC-==.
 01 L-ID                   BINARY-LONG.
 01 L-COMPONENT            PIC X(48).
 01 L-LEVEL                BINARY-LONG.
 01 L-START                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-COMPONENT L-LEVEL ENCH-CTX L-START L-RESULT L-STATUS.
     MOVE L-START TO L-RESULT
     MOVE 0 TO L-STATUS
     CALL "CONTENT-REGISTRY-ENTRY" USING WS-REGISTRY L-ID WS-KEY WS-KEY-LENGTH WS-AREA WS-CAPACITY WS-LENGTH WS-STATUS
     IF WS-STATUS NOT = CT-OK OR WS-LENGTH = 0
         MOVE 4 TO L-STATUS
         GOBACK
     END-IF
     CALL "JSON-PARSE" USING JSON-DOC WS-AREA WS-LENGTH
     MOVE "effects" TO WS-NAME
     MOVE 7 TO WS-NAME-LENGTH
     MOVE 1 TO WS-NODE
     CALL "JSON-MEMBER" USING JSON-DOC WS-NODE WS-NAME WS-NAME-LENGTH WS-EFFECTS
     IF WS-EFFECTS = 0
         GOBACK
     END-IF
*>   The component key as written, then without its namespace.
     MOVE SPACES TO WS-NAME
     MOVE FUNCTION TRIM(L-COMPONENT) TO WS-NAME
     COMPUTE WS-NAME-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(L-COMPONENT))
     CALL "JSON-MEMBER" USING JSON-DOC WS-EFFECTS WS-NAME WS-NAME-LENGTH WS-LIST
     IF WS-LIST = 0 AND WS-NAME(1:10) = "minecraft:"
         MOVE WS-NAME(11:102) TO WS-TMP
         MOVE WS-TMP TO WS-NAME
         SUBTRACT 10 FROM WS-NAME-LENGTH
         CALL "JSON-MEMBER" USING JSON-DOC WS-EFFECTS WS-NAME WS-NAME-LENGTH WS-LIST
     END-IF
     IF WS-LIST = 0 OR JN-TYPE(WS-LIST) NOT = JT-ARRAY
         GOBACK
     END-IF
     MOVE L-START TO WS-VALUE
     MOVE JN-FIRST(WS-LIST) TO WS-ELEMENT
     PERFORM UNTIL WS-ELEMENT = 0
         MOVE "requirements" TO WS-KEYWORD
         MOVE 12 TO WS-KEYWORD-LENGTH
         CALL "JSON-MEMBER" USING JSON-DOC WS-ELEMENT WS-KEYWORD WS-KEYWORD-LENGTH WS-REQ
         CALL "ENCH-REQ-EVAL" USING JSON-DOC WS-REQ ENCH-CTX WS-APPLIES
         IF WS-APPLIES = 1
             MOVE "effect" TO WS-KEYWORD
             MOVE 6 TO WS-KEYWORD-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC WS-ELEMENT WS-KEYWORD WS-KEYWORD-LENGTH WS-EFFECT
             MOVE SPACES TO WS-TEXT
             MOVE 1 TO WS-POINTER
             CALL "ENCH-EFFECT-TEXT" USING JSON-DOC WS-EFFECT WS-TEXT WS-POINTER WS-TEXT-STATUS
             IF WS-TEXT-STATUS = 0
                 CALL "TOOL-VALUE-FOLD" USING WS-TEXT L-LEVEL WS-VALUE WS-NEXT WS-FOLD-STATUS
                 IF WS-FOLD-STATUS = 0
                     MOVE WS-NEXT TO WS-VALUE
                 END-IF
             END-IF
         END-IF
         MOVE JN-NEXT(WS-ELEMENT) TO WS-ELEMENT
     END-PERFORM
     MOVE WS-VALUE TO L-RESULT
     GOBACK.
 END PROGRAM ENCH-FOLD.
