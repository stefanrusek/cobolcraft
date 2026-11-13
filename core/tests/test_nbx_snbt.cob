*> Implementation test of the NBT value tree (core/copy/NBXTREE.cpy, core/src/nbx-tree.cob) and of the SNBT builder and printer (core/src/nbx-snbt.cob): SNBT text is parsed into the
*> tree (docs/protocol/15-commands-framework.md §9.4) and printed back. The print form is not in the docs (case names tell which rule each case fixes): compound `{key:value,...}` with bare
*> keys of [A-Za-z0-9._+-] and quoted others, strings in double quotes with \ and " escaped, byte `1b`, short `1s`, int `1`, long `1L`, float `1.5f`, double `1.5d`, arrays `[B;1B]` `[I;1]`
*> `[L;1L]`, no spaces.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NBX-SNBT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY NBXTREE.
 01 WS-IN                  PIC X(256).
 01 WS-OUT                 PIC X(256).
 01 WS-CASE                PIC X(240).
 01 WS-NODE                BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-PRINT               PIC X(4096).
 01 WS-POS                 BINARY-LONG.
 01 WS-START               BINARY-LONG VALUE 0.
 01 WS-END                 BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-PARTIAL             BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-KEY                 PIC X(64).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-OBSERVED-N          BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "snbt: compound with byte, int list and string" TO WS-CASE
     MOVE '{a:1b,b:[1,2,3],c:"x y"}' TO WS-IN
     MOVE '{a:1b,b:[1,2,3],c:"x y"}' TO WS-OUT
     CALL "TS-ROUND" USING WS-CASE WS-IN WS-OUT
     MOVE "snbt: every number type, hex, binary, underscores, unsigned, exponent" TO WS-CASE
     MOVE '[1b,2s,3,4L,1.5f,2.5d,0x1F,0b101,-7,1_000,255ub,1e3,1f,2D,+4,0x7fL,-0.5]' TO WS-IN
     MOVE '[1b,2s,3,4L,1.5f,2.5d,31,5,-7,1000,-1b,1000.0d,1.0f,2.0d,4,127L,-0.5d]' TO WS-OUT
     CALL "TS-ROUND" USING WS-CASE WS-IN WS-OUT
     MOVE "snbt: typed arrays print with their suffixes" TO WS-CASE
     MOVE '[B;1b,2b,-3B]' TO WS-IN
     MOVE '[B;1B,2B,-3B]' TO WS-OUT
     CALL "TS-ROUND" USING WS-CASE WS-IN WS-OUT
     MOVE "snbt: int and long arrays" TO WS-CASE
     MOVE '[I; 1, 2 ,300]' TO WS-IN
     MOVE '[I;1,2,300]' TO WS-OUT
     CALL "TS-ROUND" USING WS-CASE WS-IN WS-OUT
     MOVE "snbt: long array elements are longs" TO WS-CASE
     MOVE '[L;1L,2]' TO WS-IN
     MOVE '[L;1L,2L]' TO WS-OUT
     CALL "TS-ROUND" USING WS-CASE WS-IN WS-OUT
     MOVE "snbt: strings in both quotes, escapes, a space escape" TO WS-CASE
     MOVE '["a\"b",''c\\d'',"e''f","\s"]' TO WS-IN
     MOVE '["a\"b","c\\d","e''f"," "]' TO WS-OUT
     CALL "TS-ROUND" USING WS-CASE WS-IN WS-OUT
     MOVE "snbt: quoted keys and keys with a dash, dot and plus" TO WS-CASE
     MOVE '{"a b":1,"":2,x-y.z+w:3,"é":4}' TO WS-IN
     MOVE '{"a b":1,"":2,x-y.z+w:3,"é":4}' TO WS-OUT
     CALL "TS-ROUND" USING WS-CASE WS-IN WS-OUT
     MOVE "snbt: unquoted string value, true, false, bool, empty compound and list" TO WS-CASE
     MOVE '{k:abc,t:true,f:false,b:bool(5),z:bool(0),e:{},l:[]}' TO WS-IN
     MOVE '{k:"abc",t:1b,f:0b,b:1b,z:0b,e:{},l:[]}' TO WS-OUT
     CALL "TS-ROUND" USING WS-CASE WS-IN WS-OUT
     MOVE "snbt: uuid() builds an int array" TO WS-CASE
     MOVE 'uuid("00000001-0002-0003-0004-000000000005")' TO WS-IN
     MOVE '[I;1,131075,262144,5]' TO WS-OUT
     CALL "TS-ROUND" USING WS-CASE WS-IN WS-OUT
     MOVE "snbt: nested compounds and lists, a later duplicate key wins" TO WS-CASE
     MOVE '{a:{b:{c:[{d:1},{d:2}]}},a:5}' TO WS-IN
     MOVE '{a:5}' TO WS-OUT
     CALL "TS-ROUND" USING WS-CASE WS-IN WS-OUT
     MOVE "snbt: a float and a double keep their shortest digits" TO WS-CASE
     MOVE '[0.1f,0.1d,1.0E10d,3.5e-5d,123456.789d]' TO WS-IN
     MOVE '[0.1f,0.1d,1.0E10d,3.5E-5d,123456.789d]' TO WS-OUT
     CALL "TS-ROUND" USING WS-CASE WS-IN WS-OUT

*> merge, equality and clone of parsed trees
     MOVE '{a:{b:1,c:2},d:1}' TO WS-IN
     CALL "TS-PARSE" USING WS-IN WS-A
     MOVE '{a:{b:3},e:[1]}' TO WS-IN
     CALL "TS-PARSE" USING WS-IN WS-B
     CALL "NBX-MERGE" USING WS-A WS-B WS-CHANGED
     MOVE "merge: nested compounds merge, other values replace, new keys append" TO WS-CASE
     MOVE '{a:{b:3,c:2},d:1,e:[1]}' TO WS-OUT
     CALL "TS-SHOW" USING WS-CASE WS-A WS-OUT
     MOVE "merge: reports a change" TO WS-CASE
     MOVE 1 TO WS-EXPECTED-N
     MOVE WS-CHANGED TO WS-OBSERVED-N
     CALL "TEST-EXPECT-NUMBER" USING WS-CASE WS-EXPECTED-N WS-OBSERVED-N
     CALL "NBX-MERGE" USING WS-A WS-B WS-CHANGED
     MOVE "merge: the same merge again changes nothing" TO WS-CASE
     MOVE 0 TO WS-EXPECTED-N
     MOVE WS-CHANGED TO WS-OBSERVED-N
     CALL "TEST-EXPECT-NUMBER" USING WS-CASE WS-EXPECTED-N WS-OBSERVED-N
     CALL "NBX-CLONE" USING WS-A WS-C
     CALL "NBX-FREE" USING WS-A
     CALL "NBX-FREE" USING WS-B
     MOVE "clone: a copy survives freeing the original" TO WS-CASE
     MOVE '{a:{b:3,c:2},d:1,e:[1]}' TO WS-OUT
     CALL "TS-SHOW" USING WS-CASE WS-C WS-OUT
     MOVE '{a:{b:3}}' TO WS-IN
     CALL "TS-PARSE" USING WS-IN WS-A
     MOVE 1 TO WS-PARTIAL
     CALL "NBX-EQUAL" USING WS-A WS-C WS-PARTIAL WS-RESULT
     MOVE "equal: a partial compound matches a bigger one" TO WS-CASE
     MOVE 1 TO WS-EXPECTED-N
     MOVE WS-RESULT TO WS-OBSERVED-N
     CALL "TEST-EXPECT-NUMBER" USING WS-CASE WS-EXPECTED-N WS-OBSERVED-N
     MOVE 0 TO WS-PARTIAL
     CALL "NBX-EQUAL" USING WS-A WS-C WS-PARTIAL WS-RESULT
     MOVE "equal: the same compound is not equal to a bigger one without partial" TO WS-CASE
     MOVE 0 TO WS-EXPECTED-N
     MOVE WS-RESULT TO WS-OBSERVED-N
     CALL "TEST-EXPECT-NUMBER" USING WS-CASE WS-EXPECTED-N WS-OBSERVED-N
     CALL "NBX-FREE" USING WS-A
     CALL "NBX-FREE" USING WS-C
     MOVE "equal: partial list element matching" TO WS-CASE
     MOVE '[{x:1}]' TO WS-IN
     MOVE '[{x:1,y:2},{z:3}]' TO WS-OUT
     MOVE 1 TO WS-PARTIAL
     MOVE 1 TO WS-EXPECTED-N
     CALL "TS-EQUAL" USING WS-CASE WS-IN WS-OUT WS-PARTIAL WS-EXPECTED-N
     MOVE "equal: partial list with an element that is nowhere" TO WS-CASE
     MOVE '[{x:2}]' TO WS-IN
     MOVE 0 TO WS-EXPECTED-N
     CALL "TS-EQUAL" USING WS-CASE WS-IN WS-OUT WS-PARTIAL WS-EXPECTED-N
     MOVE "equal: lists compare in order without partial" TO WS-CASE
     MOVE '[1,2]' TO WS-IN
     MOVE '[2,1]' TO WS-OUT
     MOVE 0 TO WS-PARTIAL
     MOVE 0 TO WS-EXPECTED-N
     CALL "TS-EQUAL" USING WS-CASE WS-IN WS-OUT WS-PARTIAL WS-EXPECTED-N
     MOVE "equal: lists of different length differ" TO WS-CASE
     MOVE '[1]' TO WS-IN
     MOVE '[1,2]' TO WS-OUT
     CALL "TS-EQUAL" USING WS-CASE WS-IN WS-OUT WS-PARTIAL WS-EXPECTED-N
     MOVE "equal: equal lists" TO WS-CASE
     MOVE '[1,2]' TO WS-IN
     MOVE '[1,2]' TO WS-OUT
     MOVE 1 TO WS-EXPECTED-N
     CALL "TS-EQUAL" USING WS-CASE WS-IN WS-OUT WS-PARTIAL WS-EXPECTED-N
     MOVE "equal: an int is not a byte" TO WS-CASE
     MOVE '1' TO WS-IN
     MOVE '1b' TO WS-OUT
     MOVE 0 TO WS-EXPECTED-N
     CALL "TS-EQUAL" USING WS-CASE WS-IN WS-OUT WS-PARTIAL WS-EXPECTED-N
     MOVE "equal: equal strings" TO WS-CASE
     MOVE '"ab"' TO WS-IN
     MOVE 'ab' TO WS-OUT
     MOVE 1 TO WS-EXPECTED-N
     CALL "TS-EQUAL" USING WS-CASE WS-IN WS-OUT WS-PARTIAL WS-EXPECTED-N
     MOVE "equal: different strings" TO WS-CASE
     MOVE '"ab"' TO WS-IN
     MOVE 'abc' TO WS-OUT
     MOVE 0 TO WS-EXPECTED-N
     CALL "TS-EQUAL" USING WS-CASE WS-IN WS-OUT WS-PARTIAL WS-EXPECTED-N
     MOVE "equal: equal doubles" TO WS-CASE
     MOVE '2.5d' TO WS-IN
     MOVE '2.5d' TO WS-OUT
     MOVE 1 TO WS-EXPECTED-N
     CALL "TS-EQUAL" USING WS-CASE WS-IN WS-OUT WS-PARTIAL WS-EXPECTED-N
     MOVE "equal: different longs" TO WS-CASE
     MOVE '2L' TO WS-IN
     MOVE '3L' TO WS-OUT
     MOVE 0 TO WS-EXPECTED-N
     CALL "TS-EQUAL" USING WS-CASE WS-IN WS-OUT WS-PARTIAL WS-EXPECTED-N
     MOVE "equal: compounds with different keys" TO WS-CASE
     MOVE '{a:1}' TO WS-IN
     MOVE '{b:1}' TO WS-OUT
     CALL "TS-EQUAL" USING WS-CASE WS-IN WS-OUT WS-PARTIAL WS-EXPECTED-N
     MOVE "equal: same size compounds with the same values are equal without partial" TO WS-CASE
     MOVE '{a:1,b:[2]}' TO WS-IN
     MOVE '{b:[2],a:1}' TO WS-OUT
     MOVE 1 TO WS-EXPECTED-N
     CALL "TS-EQUAL" USING WS-CASE WS-IN WS-OUT WS-PARTIAL WS-EXPECTED-N

*> find, set, subst, unlink
     MOVE '{a:1,b:2,c:3}' TO WS-IN
     CALL "TS-PARSE" USING WS-IN WS-A
     MOVE "b" TO WS-KEY
     MOVE 1 TO WS-KEY-LENGTH
     CALL "NBX-FIND" USING WS-A WS-KEY WS-KEY-LENGTH WS-B
     MOVE "find: a key present is a node" TO WS-CASE
     MOVE 2 TO WS-EXPECTED-N
     MOVE NX-INT(WS-B) TO WS-OBSERVED-N
     CALL "TEST-EXPECT-NUMBER" USING WS-CASE WS-EXPECTED-N WS-OBSERVED-N
     MOVE "z" TO WS-KEY
     CALL "NBX-FIND" USING WS-A WS-KEY WS-KEY-LENGTH WS-B
     MOVE "find: a key missing is node 0" TO WS-CASE
     MOVE 0 TO WS-EXPECTED-N
     MOVE WS-B TO WS-OBSERVED-N
     CALL "TEST-EXPECT-NUMBER" USING WS-CASE WS-EXPECTED-N WS-OBSERVED-N
     MOVE 5 TO WS-TYPE
     CALL "NBX-NEW" USING WS-TYPE WS-C
     MOVE 9.5 TO NX-DBL(WS-C)
     MOVE "b" TO WS-KEY
     CALL "NBX-SET" USING WS-A WS-KEY WS-KEY-LENGTH WS-C
     MOVE "set: an existing key is replaced in place" TO WS-CASE
     MOVE '{a:1,b:9.5f,c:3}' TO WS-OUT
     CALL "TS-SHOW" USING WS-CASE WS-A WS-OUT
     MOVE 3 TO WS-TYPE
     CALL "NBX-NEW" USING WS-TYPE WS-C
     MOVE 7 TO NX-INT(WS-C)
     MOVE "n" TO WS-KEY
     CALL "NBX-SET" USING WS-A WS-KEY WS-KEY-LENGTH WS-C
     MOVE "set: a new key is appended" TO WS-CASE
     MOVE '{a:1,b:9.5f,c:3,n:7}' TO WS-OUT
     CALL "TS-SHOW" USING WS-CASE WS-A WS-OUT
     MOVE "c" TO WS-KEY
     CALL "NBX-FIND" USING WS-A WS-KEY WS-KEY-LENGTH WS-B
     CALL "NBX-UNLINK" USING WS-B
     CALL "NBX-FREE" USING WS-B
     MOVE "unlink: the middle entry leaves, the others stay in order" TO WS-CASE
     MOVE '{a:1,b:9.5f,n:7}' TO WS-OUT
     CALL "TS-SHOW" USING WS-CASE WS-A WS-OUT
     MOVE "a" TO WS-KEY
     CALL "NBX-FIND" USING WS-A WS-KEY WS-KEY-LENGTH WS-B
     CALL "NBX-UNLINK" USING WS-B
     CALL "NBX-FREE" USING WS-B
     MOVE "n" TO WS-KEY
     CALL "NBX-FIND" USING WS-A WS-KEY WS-KEY-LENGTH WS-B
     CALL "NBX-UNLINK" USING WS-B
     CALL "NBX-FREE" USING WS-B
     MOVE "unlink: first and last entries" TO WS-CASE
     MOVE '{b:9.5f}' TO WS-OUT
     CALL "TS-SHOW" USING WS-CASE WS-A WS-OUT
     CALL "NBX-FREE" USING WS-A

*> the pool: full gives the sink node and sets NX-FULL; freed nodes are reused
     INITIALIZE NBX-POOL
     MOVE 3 TO WS-TYPE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > NX-MAX
         CALL "NBX-NEW" USING WS-TYPE WS-NODE
     END-PERFORM
     MOVE "pool: not full at the last node" TO WS-CASE
     MOVE 0 TO WS-EXPECTED-N
     MOVE NX-FULL TO WS-OBSERVED-N
     CALL "TEST-EXPECT-NUMBER" USING WS-CASE WS-EXPECTED-N WS-OBSERVED-N
     CALL "NBX-NEW" USING WS-TYPE WS-A
     MOVE "pool: a node beyond the last is the sink and sets the full flag" TO WS-CASE
     COMPUTE WS-EXPECTED-N = NX-SINK * 10 + 1
     COMPUTE WS-OBSERVED-N = WS-A * 10 + NX-FULL
     CALL "TEST-EXPECT-NUMBER" USING WS-CASE WS-EXPECTED-N WS-OBSERVED-N
     MOVE 9 TO WS-TYPE
     CALL "NBX-NEW" USING WS-TYPE WS-B
     CALL "NBX-ADD" USING WS-B WS-A
     MOVE 0 TO WS-I
     CALL "NBX-INSERT" USING WS-B WS-A WS-I
     MOVE "pool: adding or inserting the sink to a parent leaves the parent empty" TO WS-CASE
     MOVE 0 TO WS-EXPECTED-N
     MOVE NX-COUNT(WS-B) TO WS-OBSERVED-N
     CALL "TEST-EXPECT-NUMBER" USING WS-CASE WS-EXPECTED-N WS-OBSERVED-N
     CALL "NBX-FREE" USING WS-A
     MOVE 1 TO WS-NODE
     CALL "NBX-FREE" USING WS-NODE
     MOVE 3 TO WS-TYPE
     CALL "NBX-NEW" USING WS-TYPE WS-A
     MOVE "pool: a freed node is the next one handed out" TO WS-CASE
     MOVE 1 TO WS-EXPECTED-N
     MOVE WS-A TO WS-OBSERVED-N
     CALL "TEST-EXPECT-NUMBER" USING WS-CASE WS-EXPECTED-N WS-OBSERVED-N
     INITIALIZE NBX-POOL
     GOBACK.
 END PROGRAM TEST-NBX-SNBT.

*> TS-ROUND USING case, SNBT text, expected print: parse, print, free.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TS-ROUND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NODE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-CASE                 PIC X(240).
 01 L-IN                   PIC X(256).
 01 L-OUT                  PIC X(256).
 PROCEDURE DIVISION USING L-CASE L-IN L-OUT.
     CALL "TS-PARSE" USING L-IN WS-NODE
     CALL "TS-SHOW" USING L-CASE WS-NODE L-OUT
     CALL "NBX-FREE" USING WS-NODE
     GOBACK.
 END PROGRAM TS-ROUND.

*> TS-EQUAL USING case, text a, text b, partial, expected result: NBX-EQUAL on two parsed texts.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TS-EQUAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-OBSERVED            BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-CASE                 PIC X(240).
 01 L-A                    PIC X(256).
 01 L-B                    PIC X(256).
 01 L-PARTIAL              BINARY-LONG.
 01 L-EXPECTED             BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-CASE L-A L-B L-PARTIAL L-EXPECTED.
     CALL "TS-PARSE" USING L-A WS-A
     CALL "TS-PARSE" USING L-B WS-B
     CALL "NBX-EQUAL" USING WS-A WS-B L-PARTIAL WS-RESULT
     MOVE WS-RESULT TO WS-OBSERVED
     CALL "TEST-EXPECT-NUMBER" USING L-CASE L-EXPECTED WS-OBSERVED
     CALL "NBX-FREE" USING WS-A
     CALL "NBX-FREE" USING WS-B
     GOBACK.
 END PROGRAM TS-EQUAL.

 COPY CORETEST.
 COPY CMDTEST.
 COPY NBXTEST.
