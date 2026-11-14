*> The structure processor lists (docs/protocol/36-structures-2 sections 7 to 9): the JSON of worldgen/processor_list elements, read from the open content set's registry or from
*> the folder of FD-SET-DIR (FD-FETCH), compiled into the tables of STRUCT-PROC (STRUCTPROC.cpy) on first use and cached by key. A list is `{"processors": [...]}` or a bare array
*> (7.2). A list is unsupported (index 0, cached) when its text is not JSON, a processor or rule test type is unknown, a required field is missing or invalid, a block is unknown, a
*> position test has min_dist >= max_dist (the constructor throws, 8.4.1), a capped limit is not one of the five int providers of STRUCTPROC.cpy, or it holds a jigsaw_replacement or a
*> lava_submerged_block (not built, see STRUCTPROC.cpy). A tag the content set does not have is the empty set; an unknown position test falls back to always_true and an unknown block
*> entity modifier to passthrough (the lenient fields of 8.2).
*>
*> Entry points:
*>   STRUCT-PROC-RESET: empties the cache
*>   STRUCT-PROC-LOAD USING key (PIC X(80), with namespace), index out (BINARY-LONG): the list's number in SP-LIST, 0 when the list is absent or unsupported

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PROC-RESET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPROC.
 PROCEDURE DIVISION.
     MOVE 0 TO SP-LIST-COUNT SP-PROC-COUNT SP-RULE-COUNT SP-TEST-COUNT SP-POOL-COUNT SP-BAD
     GOBACK.
 END PROGRAM STRUCT-PROC-RESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-POOL-ADD.
*> USING value: appends to SP-POOL; SP-BAD when full.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPROC.
 LINKAGE SECTION.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-VALUE.
     IF SP-POOL-COUNT >= SP-MAX-POOL
         MOVE 1 TO SP-BAD
     ELSE
         ADD 1 TO SP-POOL-COUNT
         MOVE L-VALUE TO SP-POOL(SP-POOL-COUNT)
     END-IF
     GOBACK.
 END PROGRAM SP-POOL-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-TAG-ADD.
*> USING text (PIC X(120): "#ns:tag", "ns:tag" or "tag"): adds the block numbers of the tag to the pool; an unknown tag adds nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-REGISTRY            PIC X(48) VALUE "minecraft:block".
 01 WS-IDS.
    05 WS-ID               BINARY-LONG OCCURS 2048 TIMES.
 01 WS-CAP                 BINARY-LONG VALUE 2048.
 01 WS-COUNT               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-TEXT                PIC X(120).
 01 WS-KEY                 PIC X(80).
 01 WS-TAG                 PIC X(112).
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(120).
 PROCEDURE DIVISION USING L-TEXT.
     MOVE L-TEXT TO WS-TEXT
     IF WS-TEXT(1:1) = "#"
         MOVE L-TEXT(2:119) TO WS-TEXT
     END-IF
     CALL "FD-KEY" USING WS-TEXT WS-KEY
     MOVE WS-KEY TO WS-TAG
     CALL "CONTENT-TAG-MEMBERS" USING WS-REGISTRY WS-TAG WS-COUNT WS-IDS WS-CAP WS-STATUS
     IF WS-STATUS = CT-OK
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
             COMPUTE WS-VALUE = WS-ID(WS-I) + 1
             CALL "SP-POOL-ADD" USING WS-VALUE
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM SP-TAG-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-SET-ADD.
*> USING doc, node, first out (pool index of the first entry), count out: a holder set (a block id, a "#tag" or an array of those); an unknown block sets SP-BAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPROC.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-TEXT                PIC X(120).
 01 WS-KEY                 PIC X(80).
 01 WS-KEY48               PIC X(48).
 01 WS-INDEX               BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-FIRST L-COUNT.
     COMPUTE L-FIRST = SP-POOL-COUNT + 1
     MOVE 0 TO L-COUNT
     IF L-NODE = 0
         MOVE 1 TO SP-BAD
         GOBACK
     END-IF
     MOVE 1 TO WS-N
     IF JN-TYPE(L-NODE) = JT-ARRAY
         MOVE JN-COUNT(L-NODE) TO WS-N
     END-IF
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-N
         MOVE L-NODE TO WS-E
         IF JN-TYPE(L-NODE) = JT-ARRAY
             CALL "JSON-ELEMENT" USING JSON-DOC L-NODE WS-I WS-E
         END-IF
         IF JN-TYPE(WS-E) = JT-STRING
             CALL "FD-J-STRING-OF" USING JSON-DOC WS-E WS-TEXT
             MOVE SP-POOL-COUNT TO WS-BEFORE
             IF WS-TEXT(1:1) = "#"
                 CALL "SP-TAG-ADD" USING WS-TEXT
             ELSE
                 CALL "FD-KEY" USING WS-TEXT WS-KEY
                 MOVE WS-KEY TO WS-KEY48
                 CALL "FD-BLOCK-INDEX" USING WS-KEY48 WS-INDEX
                 IF WS-INDEX = 0
                     MOVE 1 TO SP-BAD
                 ELSE
                     CALL "SP-POOL-ADD" USING WS-INDEX
                 END-IF
             END-IF
             COMPUTE L-COUNT = L-COUNT + SP-POOL-COUNT - WS-BEFORE
         ELSE
             MOVE 1 TO SP-BAD
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SP-SET-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-STATE-SET-ADD.
*> USING doc, node (an array of block states, as strings or {"Name": id, "Properties": ...}), first out, count out: the pool entries are the blocks of those states (9.1: only the block is kept).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPROC.
 COPY CBLOCKS.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-FIRST L-COUNT.
     COMPUTE L-FIRST = SP-POOL-COUNT + 1
     MOVE 0 TO L-COUNT
     IF L-NODE = 0
         MOVE 1 TO SP-BAD
         GOBACK
     END-IF
     IF JN-TYPE(L-NODE) NOT = JT-ARRAY
         MOVE 1 TO SP-BAD
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= JN-COUNT(L-NODE)
         CALL "JSON-ELEMENT" USING JSON-DOC L-NODE WS-I WS-E
         CALL "FD-J-STATE" USING JSON-DOC WS-E WS-STATE WS-OK
         IF WS-OK = 1
             COMPUTE WS-VALUE = CB-S-BLOCK(WS-STATE + 1) + 1
             CALL "SP-POOL-ADD" USING WS-VALUE
             ADD 1 TO L-COUNT
         ELSE
             MOVE 1 TO SP-BAD
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SP-STATE-SET-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-COMPILE-TEST RECURSIVE.
*> USING doc, node, kind (1 rule test, 2 position test), index out (the SP-TEST row; 0 for an unknown position test, which is always_true; SP-BAD for any other fault).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPROC.
 01 K-TYPE                 PIC X(40) VALUE "predicate_type".
 01 K-BLOCK                PIC X(40) VALUE "block".
 01 K-STATE                PIC X(40) VALUE "block_state".
 01 K-TAG                  PIC X(40) VALUE "tag".
 01 K-PROBABILITY          PIC X(40) VALUE "probability".
 01 K-MIN-INC              PIC X(40) VALUE "min_inclusive".
 01 K-MAX-INC              PIC X(40) VALUE "max_inclusive".
 01 K-RULES                PIC X(40) VALUE "rules".
 01 K-RULE                 PIC X(40) VALUE "rule".
 01 K-MIN-CHANCE           PIC X(40) VALUE "min_chance".
 01 K-MAX-CHANCE           PIC X(40) VALUE "max_chance".
 01 K-MIN-DIST             PIC X(40) VALUE "min_dist".
 01 K-MAX-DIST             PIC X(40) VALUE "max_dist".
 01 K-AXIS                 PIC X(40) VALUE "axis".
 LOCAL-STORAGE SECTION.
 01 LS-TEXT                PIC X(120).
 01 LS-KEY                 PIC X(80).
 01 LS-KEY48               PIC X(48).
 01 LS-LEN                 BINARY-LONG.
 01 LS-N                   BINARY-LONG.
 01 LS-OK                  BINARY-LONG.
 01 LS-ROW                 BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-E                   BINARY-LONG.
 01 LS-CHILD               BINARY-LONG.
 01 LS-LAST                BINARY-LONG.
 01 LS-VALUE               BINARY-LONG.
 01 LS-FLOAT               FLOAT-LONG.
 01 LS-TYPE                BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-KIND L-INDEX.
     MOVE 0 TO L-INDEX LS-TYPE
     IF L-NODE = 0
         MOVE 1 TO SP-BAD
         GOBACK
     END-IF
     CALL "FD-J-STRING" USING JSON-DOC K-TYPE L-NODE LS-TEXT LS-LEN
     CALL "FD-KEY" USING LS-TEXT LS-KEY
     EVALUATE FUNCTION TRIM(LS-KEY)
         WHEN "minecraft:always_true"
             IF L-KIND = 1
                 MOVE 1 TO LS-TYPE
             ELSE
                 MOVE 21 TO LS-TYPE
             END-IF
         WHEN "minecraft:block_match"
             MOVE 2 TO LS-TYPE
         WHEN "minecraft:blockstate_match"
             MOVE 3 TO LS-TYPE
         WHEN "minecraft:tag_match"
             MOVE 4 TO LS-TYPE
         WHEN "minecraft:random_block_match"
             MOVE 5 TO LS-TYPE
         WHEN "minecraft:random_blockstate_match"
             MOVE 6 TO LS-TYPE
         WHEN "minecraft:height_match"
             MOVE 7 TO LS-TYPE
         WHEN "minecraft:all_of"
             MOVE 8 TO LS-TYPE
         WHEN "minecraft:any_of"
             MOVE 9 TO LS-TYPE
         WHEN "minecraft:not"
             MOVE 10 TO LS-TYPE
         WHEN "minecraft:linear_pos"
             MOVE 22 TO LS-TYPE
         WHEN "minecraft:axis_aligned_linear_pos"
             MOVE 23 TO LS-TYPE
     END-EVALUATE
*>   A position test of the other kind's name, or no name at all: lenient for the position test (always_true), a fault for a rule test.
     IF (L-KIND = 1 AND (LS-TYPE = 0 OR LS-TYPE > 10)) OR (L-KIND = 2 AND LS-TYPE < 21)
         IF L-KIND = 1
             MOVE 1 TO SP-BAD
         END-IF
         GOBACK
     END-IF
     IF SP-TEST-COUNT >= SP-MAX-TESTS
         MOVE 1 TO SP-BAD
         GOBACK
     END-IF
     ADD 1 TO SP-TEST-COUNT
     MOVE SP-TEST-COUNT TO LS-ROW
     INITIALIZE SP-TEST(LS-ROW)
     MOVE LS-TYPE TO SPT-TYPE(LS-ROW)
     MOVE LS-ROW TO L-INDEX
     EVALUATE LS-TYPE
         WHEN 2
         WHEN 5
             CALL "FD-J-STRING" USING JSON-DOC K-BLOCK L-NODE LS-TEXT LS-LEN
             CALL "FD-KEY" USING LS-TEXT LS-KEY
             MOVE LS-KEY TO LS-KEY48
             CALL "FD-BLOCK-INDEX" USING LS-KEY48 SPT-A(LS-ROW)
             IF SPT-A(LS-ROW) = 0
                 MOVE 1 TO SP-BAD
             END-IF
         WHEN 3
         WHEN 6
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE K-STATE LS-N
             CALL "FD-J-STATE" USING JSON-DOC LS-N SPT-A(LS-ROW) LS-OK
             IF LS-OK = 0
                 MOVE 1 TO SP-BAD
             END-IF
         WHEN 4
             CALL "FD-J-STRING" USING JSON-DOC K-TAG L-NODE LS-TEXT LS-LEN
             IF LS-LEN = 0
                 MOVE 1 TO SP-BAD
             END-IF
             MOVE SP-POOL-COUNT TO LS-VALUE
             COMPUTE SPT-POOL(LS-ROW) = SP-POOL-COUNT + 1
             CALL "SP-TAG-ADD" USING LS-TEXT
             COMPUTE SPT-N(LS-ROW) = SP-POOL-COUNT - LS-VALUE
         WHEN 7
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE K-MIN-INC LS-N
             CALL "FD-J-INT" USING JSON-DOC LS-N SPT-B(LS-ROW) LS-OK
             IF LS-OK = 0
                 MOVE 1 TO SP-BAD
             END-IF
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE K-MAX-INC LS-N
             CALL "FD-J-INT" USING JSON-DOC LS-N SPT-C(LS-ROW) LS-OK
             IF LS-OK = 0
                 MOVE 1 TO SP-BAD
             END-IF
         WHEN 8
         WHEN 9
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE K-RULES LS-N
             MOVE 0 TO LS-LAST
             IF LS-N = 0 OR JN-TYPE(LS-N) NOT = JT-ARRAY
                 MOVE 1 TO SP-BAD
             ELSE
                 PERFORM VARYING LS-I FROM 0 BY 1 UNTIL LS-I >= JN-COUNT(LS-N)
                     CALL "JSON-ELEMENT" USING JSON-DOC LS-N LS-I LS-E
                     CALL "SP-COMPILE-TEST" USING JSON-DOC LS-E L-KIND LS-CHILD
                     IF LS-LAST = 0
                         MOVE LS-CHILD TO SPT-CHILD(LS-ROW)
                     ELSE
                         MOVE LS-CHILD TO SPT-NEXT(LS-LAST)
                     END-IF
                     MOVE LS-CHILD TO LS-LAST
                 END-PERFORM
             END-IF
         WHEN 10
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE K-RULE LS-N
             CALL "SP-COMPILE-TEST" USING JSON-DOC LS-N L-KIND SPT-CHILD(LS-ROW)
         WHEN 1
         WHEN 21
             CONTINUE
         WHEN OTHER
*>           The two linear position tests (8.4.1): the constructor needs min_dist < max_dist.
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE K-MIN-CHANCE LS-N
             CALL "FD-J-DOUBLE" USING JSON-DOC LS-N LS-FLOAT LS-OK
             MOVE LS-FLOAT TO SPT-F(LS-ROW)
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE K-MAX-CHANCE LS-N
             CALL "FD-J-DOUBLE" USING JSON-DOC LS-N LS-FLOAT LS-OK
             MOVE LS-FLOAT TO SPT-F2(LS-ROW)
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE K-MIN-DIST LS-N
             CALL "FD-J-INT" USING JSON-DOC LS-N SPT-B(LS-ROW) LS-OK
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE K-MAX-DIST LS-N
             CALL "FD-J-INT" USING JSON-DOC LS-N SPT-C(LS-ROW) LS-OK
             IF SPT-B(LS-ROW) >= SPT-C(LS-ROW)
                 MOVE 1 TO SP-BAD
             END-IF
             MOVE 1 TO SPT-D(LS-ROW)
             IF LS-TYPE = 23
                 CALL "FD-J-STRING" USING JSON-DOC K-AXIS L-NODE LS-TEXT LS-LEN
                 EVALUATE FUNCTION TRIM(LS-TEXT)
                     WHEN "x"
                         MOVE 0 TO SPT-D(LS-ROW)
                     WHEN "z"
                         MOVE 2 TO SPT-D(LS-ROW)
                 END-EVALUATE
             END-IF
     END-EVALUATE
     IF LS-TYPE = 5 OR LS-TYPE = 6
         CALL "FD-J-MEMBER" USING JSON-DOC L-NODE K-PROBABILITY LS-N
         CALL "FD-J-DOUBLE" USING JSON-DOC LS-N LS-FLOAT LS-OK
         MOVE LS-FLOAT TO SPT-F(LS-ROW)
         IF LS-OK = 0
             MOVE 1 TO SP-BAD
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SP-COMPILE-TEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-COMPILE-RULES.
*> USING doc, rules node, first rule row out, count out: the ProcessorRule list of a rule processor (8.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPROC.
 01 K-INPUT                PIC X(40) VALUE "input_predicate".
 01 K-LOCATION             PIC X(40) VALUE "location_predicate".
 01 K-POSITION             PIC X(40) VALUE "position_predicate".
 01 K-OUTPUT               PIC X(40) VALUE "output_state".
 01 K-MODIFIER             PIC X(40) VALUE "block_entity_modifier".
 01 K-TYPE                 PIC X(40) VALUE "type".
 01 WS-I                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-KIND-RULE           BINARY-LONG VALUE 1.
 01 WS-KIND-POS            BINARY-LONG VALUE 2.
 01 WS-TEXT                PIC X(120).
 01 WS-KEY                 PIC X(80).
 01 WS-LEN                 BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-FIRST L-COUNT.
     MOVE 0 TO L-COUNT
     COMPUTE L-FIRST = SP-RULE-COUNT + 1
     IF L-NODE = 0
         MOVE 1 TO SP-BAD
         GOBACK
     END-IF
     IF JN-TYPE(L-NODE) NOT = JT-ARRAY
         MOVE 1 TO SP-BAD
         GOBACK
     END-IF
     IF SP-RULE-COUNT + JN-COUNT(L-NODE) > SP-MAX-RULES
         MOVE 1 TO SP-BAD
         GOBACK
     END-IF
     MOVE JN-COUNT(L-NODE) TO L-COUNT
     ADD L-COUNT TO SP-RULE-COUNT
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= L-COUNT
         COMPUTE WS-ROW = L-FIRST + WS-I
         INITIALIZE SP-RULE(WS-ROW)
         CALL "JSON-ELEMENT" USING JSON-DOC L-NODE WS-I WS-E
         CALL "FD-J-MEMBER" USING JSON-DOC WS-E K-INPUT WS-N
         CALL "SP-COMPILE-TEST" USING JSON-DOC WS-N WS-KIND-RULE SPR-IN(WS-ROW)
         CALL "FD-J-MEMBER" USING JSON-DOC WS-E K-LOCATION WS-N
         CALL "SP-COMPILE-TEST" USING JSON-DOC WS-N WS-KIND-RULE SPR-LOC(WS-ROW)
         CALL "FD-J-MEMBER" USING JSON-DOC WS-E K-POSITION WS-N
         IF WS-N > 0
             CALL "SP-COMPILE-TEST" USING JSON-DOC WS-N WS-KIND-POS SPR-POS(WS-ROW)
         END-IF
         CALL "FD-J-MEMBER" USING JSON-DOC WS-E K-OUTPUT WS-N
         CALL "FD-J-STATE" USING JSON-DOC WS-N SPR-STATE(WS-ROW) WS-OK
         IF WS-OK = 0
             MOVE 1 TO SP-BAD
         END-IF
         CALL "FD-J-MEMBER" USING JSON-DOC WS-E K-MODIFIER WS-N
         IF WS-N > 0
             CALL "FD-J-STRING" USING JSON-DOC K-TYPE WS-N WS-TEXT WS-LEN
             CALL "FD-KEY" USING WS-TEXT WS-KEY
             EVALUATE FUNCTION TRIM(WS-KEY)
                 WHEN "minecraft:clear"
                     MOVE 1 TO SPR-MOD(WS-ROW)
                 WHEN "minecraft:append_static"
                     MOVE 2 TO SPR-MOD(WS-ROW)
                 WHEN "minecraft:append_loot"
                     MOVE 3 TO SPR-MOD(WS-ROW)
             END-EVALUATE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SP-COMPILE-RULES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-COMPILE-PROC RECURSIVE.
*> USING doc, node (a processor object), row (the SP-PROC row to fill).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPROC.
 COPY CBLOCKS.
 01 K-TYPE                 PIC X(40) VALUE "processor_type".
 01 K-RULES                PIC X(40) VALUE "rules".
 01 K-VALUE                PIC X(40) VALUE "value".
 01 K-INTEGRITY            PIC X(40) VALUE "integrity".
 01 K-ROTTABLE             PIC X(40) VALUE "rottable_blocks".
 01 K-DELEGATE             PIC X(40) VALUE "delegate".
 01 K-LIMIT                PIC X(40) VALUE "limit".
 01 K-HEIGHTMAP            PIC X(40) VALUE "heightmap".
 01 K-OFFSET               PIC X(40) VALUE "offset".
 01 K-BLOCKS               PIC X(40) VALUE "blocks".
 01 K-MOSSINESS            PIC X(40) VALUE "mossiness".
 01 WS-TAG-STAIRS          PIC X(120) VALUE "minecraft:stairs".
 01 WS-TAG-SLABS           PIC X(120) VALUE "minecraft:slabs".
 01 WS-TAG-WALLS           PIC X(120) VALUE "minecraft:walls".
 01 WS-TEXT                PIC X(120).
 01 WS-KEY                 PIC X(80).
 01 WS-LEN                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLOAT               FLOAT-LONG.
 01 WS-IP.
    05 WS-IP-V             BINARY-LONG OCCURS 4 TIMES.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ROW-CHILD           BINARY-LONG.
 LOCAL-STORAGE SECTION.
 01 LS-ROW                 BINARY-LONG.
 01 LS-TYPE                BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW.
     MOVE L-ROW TO LS-ROW
     INITIALIZE SP-PROC(LS-ROW)
     IF L-NODE = 0
         MOVE 1 TO SP-BAD
         GOBACK
     END-IF
     CALL "FD-J-STRING" USING JSON-DOC K-TYPE L-NODE WS-TEXT WS-LEN
     CALL "FD-KEY" USING WS-TEXT WS-KEY
     MOVE 0 TO LS-TYPE
     EVALUATE FUNCTION TRIM(WS-KEY)
         WHEN "minecraft:rule"
             MOVE 1 TO LS-TYPE
         WHEN "minecraft:protected_blocks"
             MOVE 2 TO LS-TYPE
         WHEN "minecraft:block_rot"
             MOVE 3 TO LS-TYPE
         WHEN "minecraft:capped"
             MOVE 4 TO LS-TYPE
         WHEN "minecraft:gravity"
             MOVE 5 TO LS-TYPE
         WHEN "minecraft:nop"
             MOVE 8 TO LS-TYPE
         WHEN "minecraft:block_ignore"
             MOVE 9 TO LS-TYPE
         WHEN "minecraft:blackstone_replace"
             MOVE 10 TO LS-TYPE
         WHEN "minecraft:block_age"
             MOVE 11 TO LS-TYPE
     END-EVALUATE
     IF LS-TYPE = 0
         MOVE 1 TO SP-BAD
         GOBACK
     END-IF
     MOVE LS-TYPE TO SPP-TYPE(LS-ROW)
     EVALUATE LS-TYPE
         WHEN 1
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE K-RULES WS-N
             CALL "SP-COMPILE-RULES" USING JSON-DOC WS-N SPP-A(LS-ROW) SPP-N(LS-ROW)
         WHEN 2
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE K-VALUE WS-N
             CALL "SP-SET-ADD" USING JSON-DOC WS-N SPP-POOL(LS-ROW) SPP-N(LS-ROW)
         WHEN 3
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE K-INTEGRITY WS-N
             CALL "FD-J-DOUBLE" USING JSON-DOC WS-N WS-FLOAT WS-OK
             MOVE WS-FLOAT TO SPP-F(LS-ROW)
             IF WS-OK = 0
                 MOVE 1 TO SP-BAD
             END-IF
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE K-ROTTABLE WS-N
             IF WS-N > 0
                 MOVE 1 TO SPP-A(LS-ROW)
                 CALL "SP-SET-ADD" USING JSON-DOC WS-N SPP-POOL(LS-ROW) SPP-N(LS-ROW)
             END-IF
         WHEN 4
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE K-LIMIT WS-N
             CALL "FD-J-IP" USING JSON-DOC WS-N WS-IP WS-OK
             IF WS-OK = 0 OR WS-IP-V(1) > 5
                 MOVE 1 TO SP-BAD
             END-IF
             MOVE WS-IP-V(1) TO SPP-B(LS-ROW)
             MOVE WS-IP-V(2) TO SPP-C(LS-ROW)
             MOVE WS-IP-V(3) TO SPP-D(LS-ROW)
             MOVE WS-IP-V(4) TO SPP-E(LS-ROW)
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE K-DELEGATE WS-N
             IF SP-PROC-COUNT >= SP-MAX-PROCS
                 MOVE 1 TO SP-BAD
             ELSE
                 ADD 1 TO SP-PROC-COUNT
                 MOVE SP-PROC-COUNT TO SPP-A(LS-ROW)
                 CALL "SP-COMPILE-PROC" USING JSON-DOC WS-N SPP-A(LS-ROW)
             END-IF
         WHEN 5
             MOVE 1 TO SPP-A(LS-ROW)
             CALL "FD-J-STRING" USING JSON-DOC K-HEIGHTMAP L-NODE WS-TEXT WS-LEN
             IF WS-LEN = 0
                 MOVE "WORLD_SURFACE_WG" TO WS-TEXT
             END-IF
             EVALUATE FUNCTION TRIM(WS-TEXT)
                 WHEN "WORLD_SURFACE_WG"
                     MOVE 0 TO SPP-A(LS-ROW)
                 WHEN "WORLD_SURFACE"
                     MOVE 1 TO SPP-A(LS-ROW)
                 WHEN "OCEAN_FLOOR_WG"
                     MOVE 2 TO SPP-A(LS-ROW)
                 WHEN "OCEAN_FLOOR"
                     MOVE 3 TO SPP-A(LS-ROW)
                 WHEN "MOTION_BLOCKING"
                     MOVE 4 TO SPP-A(LS-ROW)
                 WHEN "MOTION_BLOCKING_NO_LEAVES"
                     MOVE 5 TO SPP-A(LS-ROW)
                 WHEN OTHER
                     MOVE 1 TO SP-BAD
             END-EVALUATE
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE K-OFFSET WS-N
             CALL "FD-J-INT" USING JSON-DOC WS-N SPP-B(LS-ROW) WS-OK
         WHEN 9
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE K-BLOCKS WS-N
             CALL "SP-STATE-SET-ADD" USING JSON-DOC WS-N SPP-POOL(LS-ROW) SPP-N(LS-ROW)
         WHEN 11
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE K-MOSSINESS WS-N
             CALL "FD-J-DOUBLE" USING JSON-DOC WS-N WS-FLOAT WS-OK
             MOVE WS-FLOAT TO SPP-F(LS-ROW)
             IF WS-OK = 0
                 MOVE 1 TO SP-BAD
             END-IF
             COMPUTE SPP-POOL(LS-ROW) = SP-POOL-COUNT + 1
             MOVE SP-POOL-COUNT TO WS-BEFORE
             CALL "SP-TAG-ADD" USING WS-TAG-STAIRS
             COMPUTE SPP-A(LS-ROW) = SP-POOL-COUNT - WS-BEFORE
             MOVE SP-POOL-COUNT TO WS-BEFORE
             CALL "SP-TAG-ADD" USING WS-TAG-SLABS
             COMPUTE SPP-B(LS-ROW) = SP-POOL-COUNT - WS-BEFORE
             MOVE SP-POOL-COUNT TO WS-BEFORE
             CALL "SP-TAG-ADD" USING WS-TAG-WALLS
             COMPUTE SPP-C(LS-ROW) = SP-POOL-COUNT - WS-BEFORE
     END-EVALUATE
     GOBACK.
 END PROGRAM SP-COMPILE-PROC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PROC-LOAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPROC.
 COPY JSONDOC.
 01 WS-REGISTRY            PIC X(32) VALUE "processor_list".
 01 WS-TEXT                PIC X(65536).
 01 WS-LEN                 BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ARRAY               BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-SAVE-PROC           BINARY-LONG.
 01 WS-SAVE-RULE           BINARY-LONG.
 01 WS-SAVE-TEST           BINARY-LONG.
 01 WS-SAVE-POOL           BINARY-LONG.
 01 K-PROCESSORS           PIC X(40) VALUE "processors".
 LINKAGE SECTION.
 01 L-KEY                  PIC X(80).
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-INDEX.
     MOVE 0 TO L-INDEX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SP-LIST-COUNT
         IF SPL-KEY(WS-I) = L-KEY
             IF SPL-STATUS(WS-I) = 1
                 MOVE WS-I TO L-INDEX
             END-IF
             GOBACK
         END-IF
     END-PERFORM
     IF SP-LIST-COUNT >= SP-MAX-LISTS
         GOBACK
     END-IF
     ADD 1 TO SP-LIST-COUNT
     MOVE SP-LIST-COUNT TO WS-ROW
     MOVE L-KEY TO SPL-KEY(WS-ROW)
     MOVE 2 TO SPL-STATUS(WS-ROW)
     MOVE 0 TO SPL-FIRST(WS-ROW) SPL-N(WS-ROW)
     CALL "FD-FETCH" USING WS-REGISTRY L-KEY WS-TEXT WS-LEN WS-STATUS
     IF WS-STATUS NOT = 0
         GOBACK
     END-IF
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     IF JD-ERROR NOT = 0 OR JD-COUNT = 0
         GOBACK
     END-IF
     MOVE SP-PROC-COUNT TO WS-SAVE-PROC
     MOVE SP-RULE-COUNT TO WS-SAVE-RULE
     MOVE SP-TEST-COUNT TO WS-SAVE-TEST
     MOVE SP-POOL-COUNT TO WS-SAVE-POOL
     MOVE 0 TO SP-BAD
*>   The list is an object with processors, or the bare array.
     MOVE 1 TO WS-ARRAY
     IF JN-TYPE(1) = JT-OBJECT
         CALL "FD-J-MEMBER" USING JSON-DOC 1 K-PROCESSORS WS-ARRAY
     END-IF
     IF WS-ARRAY = 0 OR JN-TYPE(WS-ARRAY) NOT = JT-ARRAY
         MOVE 1 TO SP-BAD
     ELSE
         MOVE JN-COUNT(WS-ARRAY) TO WS-N
         IF SP-PROC-COUNT + WS-N > SP-MAX-PROCS
             MOVE 1 TO SP-BAD
         ELSE
             COMPUTE WS-FIRST = SP-PROC-COUNT + 1
             ADD WS-N TO SP-PROC-COUNT
             PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-N
                 CALL "JSON-ELEMENT" USING JSON-DOC WS-ARRAY WS-I WS-E
                 COMPUTE WS-STATUS = WS-FIRST + WS-I
                 CALL "SP-COMPILE-PROC" USING JSON-DOC WS-E WS-STATUS
             END-PERFORM
         END-IF
     END-IF
     IF SP-BAD = 0
         MOVE 1 TO SPL-STATUS(WS-ROW)
         MOVE WS-FIRST TO SPL-FIRST(WS-ROW)
         MOVE WS-N TO SPL-N(WS-ROW)
         MOVE WS-ROW TO L-INDEX
     ELSE
         MOVE WS-SAVE-PROC TO SP-PROC-COUNT
         MOVE WS-SAVE-RULE TO SP-RULE-COUNT
         MOVE WS-SAVE-TEST TO SP-TEST-COUNT
         MOVE WS-SAVE-POOL TO SP-POOL-COUNT
         MOVE 0 TO SP-BAD
     END-IF
     GOBACK.
 END PROGRAM STRUCT-PROC-LOAD.
