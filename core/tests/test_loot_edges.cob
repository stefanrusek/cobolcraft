*> Test of the loot engine's edges (white box, core/src/loot*.cob; docs/protocol/26-loot-and-predicates.md sections 1, 5.1, 9.1, 10.10): nodes of a kind a
*> program does not take (an array where a provider is expected, a number where a condition or a function is expected), a
*> level based value of an unknown type, the absent node 0 of every reader, an enchantment id without namespace, and the document
*> cache: more documents than slots in one roll are parsed again when needed and still evaluate. The nodes are taken from the
*> fixtures of core/tests/fixtures/loot with LOOT-DOC-GET and LOOT-J-MEMBER.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOOT-EDGES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY LOOTCTX.
 COPY LOOTSTATE.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/loot".
 01 WS-STATUS              BINARY-LONG.
 01 WS-REG-PREDICATE       PIC X(48) VALUE "predicate".
 01 WS-REG-INT             PIC X(48) VALUE "context_int_provider".
 01 WS-KEY                 PIC X(112).
 01 WS-SLOT                BINARY-LONG.
 01 WS-ROOT                BINARY-LONG VALUE 1.
 01 WS-ARRAY               BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-INT                 BINARY-LONG.
 01 WS-FLOAT               FLOAT-LONG.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-RESULT              BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ITEM                BINARY-LONG VALUE 10.
 01 WS-COUNT               BINARY-LONG VALUE 4.
 01 WS-HANDLE              BINARY-LONG VALUE 0.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-SEQUENCE            PIC X(112) VALUE SPACES.
 01 WS-IDS.
    05 WS-ID               BINARY-LONG OCCURS 64 TIMES.
 01 WS-OUT-SLOT            BINARY-LONG.
 01 WS-OUT-NODE            BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "LOOT-LOAD" USING WS-DIR WS-STATUS
     MOVE "test loot edges the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     INITIALIZE LOOT-CONTEXT
     MOVE 3 TO LC-SEED
     MOVE SPACES TO WS-SEQUENCE
     CALL "LOOT-ENTER" USING LOOT-CONTEXT WS-SEQUENCE

     MOVE "test:c_all_of" TO WS-KEY
     CALL "LOOT-DOC-GET" USING WS-REG-PREDICATE WS-KEY WS-SLOT
     MOVE "terms" TO WS-NAME
     CALL "LOOT-J-MEMBER" USING WS-SLOT WS-ROOT WS-NAME WS-ARRAY
     MOVE 0 TO LW-ERR
     MOVE 9 TO WS-INT
     CALL "LOOT-INT-EVAL" USING WS-SLOT WS-ARRAY WS-INT
     MOVE "test loot edges an array is not an int provider: value 0 and the error flag set" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE "0 1" TO TL-EXPECTED
     MOVE WS-INT TO WS-EDIT
     MOVE SPACES TO TL-OBSERVED
     MOVE LW-ERR TO WS-EDIT2
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM CHECK
     MOVE 0 TO LW-ERR
     MOVE 9 TO WS-FLOAT
     CALL "LOOT-FLOAT-EVAL" USING WS-SLOT WS-ARRAY WS-FLOAT
     MOVE "test loot edges an array is not a float provider: value 0 and the error flag set" TO TL-CASE
     MOVE WS-FLOAT TO WS-INT
     MOVE WS-INT TO WS-EDIT
     MOVE SPACES TO TL-OBSERVED
     MOVE LW-ERR TO WS-EDIT2
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM CHECK
     MOVE 0 TO LW-ERR
     MOVE 9 TO WS-FLOAT
     CALL "LOOT-LEVEL-EVAL" USING WS-SLOT WS-ROOT WS-LEVEL WS-FLOAT
     MOVE "test loot edges a condition object is not a level based value: value 0 and the error flag set" TO TL-CASE
     MOVE WS-FLOAT TO WS-INT
     MOVE WS-INT TO WS-EDIT
     MOVE SPACES TO TL-OBSERVED
     MOVE LW-ERR TO WS-EDIT2
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM CHECK

     MOVE "test:i_const" TO WS-KEY
     CALL "LOOT-DOC-GET" USING WS-REG-INT WS-KEY WS-SLOT
     CALL "LOOT-COND-EVAL" USING WS-SLOT WS-ROOT WS-RESULT
     MOVE "test loot edges a number is no condition: false" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     CALL "LOOT-FN-APPLY" USING WS-SLOT WS-ROOT WS-ITEM WS-COUNT WS-HANDLE
     MOVE "test loot edges a number is no function: the stack stays" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     MOVE "test:i_add" TO WS-KEY
     CALL "LOOT-DOC-GET" USING WS-REG-INT WS-KEY WS-SLOT
     CALL "LOOT-COND-EVAL" USING WS-SLOT WS-ROOT WS-RESULT
     MOVE "test loot edges a provider object is no condition: false" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     PERFORM CHECK-NUM

     MOVE 0 TO WS-FLOAT
     CALL "LOOT-RANGE-TEST" USING WS-SLOT WS-ZERO WS-FLOAT WS-KIND WS-RESULT
     MOVE "test loot edges an absent range accepts every value" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     CALL "LOOT-ITEM-IN-SET" USING WS-SLOT WS-ZERO WS-KIND WS-ITEM WS-RESULT
     MOVE "test loot edges an absent item set holds nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     MOVE 9 TO WS-INT
     CALL "LOOT-TAG-ITEMS" USING WS-SLOT WS-ZERO WS-INT WS-IDS
     MOVE "test loot edges an absent items member lists no item" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-INT TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     MOVE 9 TO WS-OUT-NODE
     MOVE 1 TO WS-I
     CALL "LOOT-TABLE-REF" USING WS-SLOT WS-ZERO WS-I WS-OUT-SLOT WS-OUT-NODE WS-KEY
     MOVE "test loot edges an absent table value names no table" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OUT-NODE TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     MOVE "efficiency" TO WS-KEY
     CALL "LOOT-ENCH-ID" USING WS-KEY WS-INT
     MOVE "test loot edges an enchantment id without namespace is minecraft:" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-INT TO TL-OBSERVED-N
     PERFORM CHECK-NUM

     CALL "LOOT-INT-EVAL" USING WS-SLOT WS-ZERO WS-INT
     CALL "LOOT-FLOAT-EVAL" USING WS-SLOT WS-ZERO WS-FLOAT
     CALL "LOOT-LEVEL-EVAL" USING WS-SLOT WS-ZERO WS-LEVEL WS-FLOAT
     CALL "LOOT-COND-EVAL" USING WS-SLOT WS-ZERO WS-RESULT
     MOVE "test loot edges the absent node 0 is no condition: false" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     MOVE 4 TO WS-COUNT
     CALL "LOOT-FN-APPLY" USING WS-SLOT WS-ZERO WS-ITEM WS-COUNT WS-HANDLE
     CALL "LOOT-ITEM-MATCH" USING WS-SLOT WS-ZERO WS-ITEM WS-COUNT WS-HANDLE WS-RESULT
     MOVE "test loot edges an absent item predicate matches every stack" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     MOVE 5 TO WS-OUT-NODE
     MOVE 1 TO WS-OUT-SLOT
     CALL "LOOT-HOLDER" USING WS-REG-INT WS-OUT-SLOT WS-ZERO
     CALL "LOOT-J-MEMBER" USING WS-SLOT WS-ZERO WS-NAME WS-OUT-NODE
     MOVE "test loot edges a member of an absent node is absent" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OUT-NODE TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     MOVE "test:i_add" TO WS-KEY
     CALL "LOOT-DOC-GET" USING WS-REG-INT WS-KEY WS-SLOT
     MOVE 1 TO WS-OUT-NODE
     MOVE "inputs" TO WS-NAME
     CALL "LOOT-J-MEMBER" USING WS-SLOT WS-ROOT WS-NAME WS-OUT-NODE
     CALL "LOOT-HOLDER" USING WS-REG-INT WS-SLOT WS-OUT-NODE
     MOVE "test loot edges a holder of a node that is no string stays as it is" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-OUT-NODE TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     CALL "LOOT-ITEM-MATCH" USING WS-SLOT WS-ZERO WS-ITEM WS-COUNT WS-HANDLE WS-RESULT
*>   More documents than slots in one roll: all are parsed, the earliest again when asked for.
     MOVE "test:c_killed" TO WS-KEY
     CALL "LOOT-DOC-GET" USING WS-REG-PREDICATE WS-KEY WS-SLOT
     CALL "LOOT-ENTER" USING LOOT-CONTEXT WS-SEQUENCE
     MOVE "test:c_killed" TO WS-KEY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30
         MOVE SPACES TO WS-KEY
         MOVE WS-I TO WS-EDIT
         STRING "test:i_bulk_" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-KEY
         CALL "LOOT-DOC-GET" USING WS-REG-INT WS-KEY WS-SLOT
     END-PERFORM
     MOVE 1 TO LC-KILLER
     MOVE "test:c_killed" TO WS-KEY
     CALL "LOOT-PREDICATE" USING WS-KEY LOOT-CONTEXT WS-RESULT WS-STATUS
     MOVE "test loot edges a predicate evaluates after more documents than slots were read" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     GOBACK.

 CHECK.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-LOOT-EDGES.
 COPY CORETEST.
