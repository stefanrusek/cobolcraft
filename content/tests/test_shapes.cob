*> Test of the data shape engine (shapes.cob, CTSHAPE.cpy; the engine behind the loaders of docs/protocol/35 to 39).
*> SHAPE-TYPE-ADD USING group (PIC X(24)), type (PIC X(48)), fields (PIC X(600)), status out (0, 1 when the table is
*> full) registers a type row once. SHAPE-BEGIN, SHAPE-LOAD USING root (PIC X(1100)), registry (PIC X(48)), group (PIC
*> X(24)), strict (BINARY-LONG: 1 an unknown type is an error), SHAPE-END USING status out (CT-OK, or CT-BAD-DATA with
*> every error on standard error and the elements of the load taken back), SHAPE-FIND USING registry, key (PIC X(64)),
*> row out, SHAPE-FREE. Every field form of CTSHAPE.cpy has an accept case (fixture tree content/tests/fixtures/shapes)
*> and each of its failures a reject case written into a fresh copy of the tree.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SHAPES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CTSHAPE.
 01 WS-DIR                 PIC X(1100).
 01 WS-REGISTRY            PIC X(48) VALUE "test/shapes".
 01 WS-GROUP               PIC X(24).
 01 WS-TYPE                PIC X(48).
 01 WS-FIELDS              PIC X(600).
 01 WS-STATUS              BINARY-LONG.
 01 WS-STRICT              BINARY-LONG.
 01 WS-KEY                 PIC X(64).
 01 WS-ROW                 BINARY-LONG.
 01 WS-COMMAND             PIC X(600).
 01 WS-BODY                PIC X(300).
 01 WS-T                   PIC X(60).
 01 WS-I                   BINARY-LONG.
 01 WS-N-TEXT              PIC Z(4)9.
 01 WS-ROWS.
    05 FILLER PIC X(24) VALUE "r".
    05 FILLER PIC X(48) VALUE "one".
    05 FILLER PIC X(600) VALUE "S a".
    05 FILLER PIC X(24) VALUE "r".
    05 FILLER PIC X(48) VALUE "minecraft:two".
    05 FILLER PIC X(600) VALUE "I b".
 01 WS-ROW-COUNT           BINARY-LONG VALUE 2.
 01 WS-CASES.
    05 FILLER PIC X(40) VALUE "an array is no object".
    05 FILLER PIC X(300) VALUE '[]'.
    05 FILLER PIC X(40) VALUE "a value without a type".
    05 FILLER PIC X(300) VALUE '{"name":"x"}'.
    05 FILLER PIC X(40) VALUE "an unknown type".
    05 FILLER PIC X(300) VALUE '{"type":"minecraft:nope"}'.
    05 FILLER PIC X(40) VALUE "a required member left out".
    05 FILLER PIC X(300) VALUE '{"type":"minecraft:alpha"}'.
    05 FILLER PIC X(40) VALUE "a string that is a number".
    05 FILLER PIC X(300) VALUE '{"type":"alpha","name":1}'.
    05 FILLER PIC X(40) VALUE "a fractional integer".
    05 FILLER PIC X(300) VALUE '{"type":"alpha","name":"x","count":1.5}'.
    05 FILLER PIC X(40) VALUE "an integer above its range".
    05 FILLER PIC X(300) VALUE '{"type":"alpha","name":"x","count":11}'.
    05 FILLER PIC X(40) VALUE "an integer below its range".
    05 FILLER PIC X(300) VALUE '{"type":"alpha","name":"x","count":-1}'.
    05 FILLER PIC X(40) VALUE "an integer that is a string".
    05 FILLER PIC X(300) VALUE '{"type":"alpha","name":"x","count":"1"}'.
    05 FILLER PIC X(40) VALUE "a number above its range".
    05 FILLER PIC X(300) VALUE '{"type":"alpha","name":"x","ratio":2}'.
    05 FILLER PIC X(40) VALUE "a number below its range".
    05 FILLER PIC X(300) VALUE '{"type":"alpha","name":"x","ratio":-1.6}'.
    05 FILLER PIC X(40) VALUE "a boolean that is a number".
    05 FILLER PIC X(300) VALUE '{"type":"alpha","name":"x","flag":1}'.
    05 FILLER PIC X(40) VALUE "an enum value not listed".
    05 FILLER PIC X(300) VALUE '{"type":"alpha","name":"x","kind":"c"}'.
    05 FILLER PIC X(40) VALUE "an enum that is a number".
    05 FILLER PIC X(300) VALUE '{"type":"alpha","name":"x","kind":1}'.
    05 FILLER PIC X(40) VALUE "an invalid identifier".
    05 FILLER PIC X(300) VALUE '{"type":"alpha","name":"x","ref":"Bad Id"}'.
    05 FILLER PIC X(40) VALUE "an empty identifier".
    05 FILLER PIC X(300) VALUE '{"type":"alpha","name":"x","ref":""}'.
    05 FILLER PIC X(40) VALUE "an identifier with an empty path".
    05 FILLER PIC X(300) VALUE '{"type":"alpha","name":"x","ref":"a:"}'.
    05 FILLER PIC X(40) VALUE "an identifier of a bad namespace".
    05 FILLER PIC X(300) VALUE '{"type":"alpha","name":"x","ref":"A:b"}'.
    05 FILLER PIC X(40) VALUE "an identifier of 65 bytes".
    05 FILLER PIC X(300) VALUE '{"type":"alpha","name":"x","ref":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"}'.
    05 FILLER PIC X(40) VALUE "an object that is an array".
    05 FILLER PIC X(300) VALUE '{"type":"alpha","name":"x","obj":[]}'.
    05 FILLER PIC X(40) VALUE "an array that is an object".
    05 FILLER PIC X(300) VALUE '{"type":"alpha","name":"x","arr":{}}'.
    05 FILLER PIC X(40) VALUE "a typed object that is bad".
    05 FILLER PIC X(300) VALUE '{"type":"alpha","name":"x","inner":{"tag":1}}'.
    05 FILLER PIC X(40) VALUE "a typed object of a bad type".
    05 FILLER PIC X(300) VALUE '{"type":"alpha","name":"x","typed":{"type":"beta"}}'.
    05 FILLER PIC X(40) VALUE "a typed object without a type".
    05 FILLER PIC X(300) VALUE '{"type":"alpha","name":"x","typed":{}}'.
    05 FILLER PIC X(40) VALUE "a reference that is a number".
    05 FILLER PIC X(300) VALUE '{"type":"alpha","name":"x","rr":1}'.
    05 FILLER PIC X(40) VALUE "a reference object that is bad".
    05 FILLER PIC X(300) VALUE '{"type":"alpha","name":"x","rr":{"tag":1}}'.
    05 FILLER PIC X(40) VALUE "a reference id that is bad".
    05 FILLER PIC X(300) VALUE '{"type":"alpha","name":"x","rr":"#a"}'.
    05 FILLER PIC X(40) VALUE "a number or object that is a string".
    05 FILLER PIC X(300) VALUE '{"type":"alpha","name":"x","vv":"x"}'.
    05 FILLER PIC X(40) VALUE "a number or object whose object is bad".
    05 FILLER PIC X(300) VALUE '{"type":"alpha","name":"x","vv":{"tag":1}}'.
    05 FILLER PIC X(40) VALUE "a list that is no array".
    05 FILLER PIC X(300) VALUE '{"type":"alpha","name":"x","ll":{}}'.
    05 FILLER PIC X(40) VALUE "a list element that is bad".
    05 FILLER PIC X(300) VALUE '{"type":"alpha","name":"x","ll":[{"tag":"u"},{"tag":2}]}'.
    05 FILLER PIC X(40) VALUE "an id list that is no array".
    05 FILLER PIC X(300) VALUE '{"type":"alpha","name":"x","kk":1}'.
    05 FILLER PIC X(40) VALUE "an id list element that is bad".
    05 FILLER PIC X(300) VALUE '{"type":"alpha","name":"x","kk":["Bad Id"]}'.
    05 FILLER PIC X(40) VALUE "an id list element with a tag mark".
    05 FILLER PIC X(300) VALUE '{"type":"alpha","name":"x","kk":["#a:b"]}'.
    05 FILLER PIC X(40) VALUE "a holder set that is a number".
    05 FILLER PIC X(300) VALUE '{"type":"alpha","name":"x","hh":1}'.
    05 FILLER PIC X(40) VALUE "a holder set string that is bad".
    05 FILLER PIC X(300) VALUE '{"type":"alpha","name":"x","hh":"#Bad Id"}'.
    05 FILLER PIC X(40) VALUE "a holder set element that is a number".
    05 FILLER PIC X(300) VALUE '{"type":"alpha","name":"x","hh":[1]}'.
    05 FILLER PIC X(40) VALUE "a holder set object that is bad".
    05 FILLER PIC X(300) VALUE '{"type":"alpha","name":"x","hh":{"tag":1}}'.
    05 FILLER PIC X(40) VALUE "a file that is no JSON".
    05 FILLER PIC X(300) VALUE '{"type":"alpha","name":"x",}'.
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE OCCURS 39 TIMES.
       10 WS-CASE-LABEL    PIC X(40).
       10 WS-CASE-BODY     PIC X(300).
 PROCEDURE DIVISION.
     CALL "SHAPE-FREE"
     MOVE "content/tests/fixtures/shapes" TO WS-DIR
     MOVE "no type row before registering" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SH-TYPE-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM

     PERFORM REGISTER-TYPES
     MOVE "four type rows, a second registration adds none" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE SH-TYPE-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM

*>   Accept: the fixture tree, strict off (the mystery type of namespace extra is a type nobody registered).
     MOVE 0 TO WS-STRICT
     CALL "SHAPE-BEGIN"
     CALL "SHAPE-LOAD" USING WS-DIR WS-REGISTRY WS-GROUP WS-STRICT
     CALL "SHAPE-END" USING WS-STATUS
     MOVE "the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "three elements" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "minecraft:test/shapes" TO WS-KEY
     MOVE "minecraft:a" TO WS-KEY
     CALL "SHAPE-FIND" USING WS-REGISTRY WS-KEY WS-ROW
     MOVE "a is found" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-ROW > 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-NUM
     IF WS-ROW = 0
         MOVE 1 TO WS-ROW
     END-IF
     MOVE "a is of type alpha" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "alpha" TO TL-EXPECTED
     MOVE SH-T-NAME(SH-E-TYPE(WS-ROW)) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "a keeps its file text" TO TL-CASE
     MOVE 266 TO TL-EXPECTED-N
     MOVE SH-E-LENGTH(WS-ROW) TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "minecraft:b" TO WS-KEY
     CALL "SHAPE-FIND" USING WS-REGISTRY WS-KEY WS-ROW
     MOVE "b is the second element" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-ROW TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "extra:c" TO WS-KEY
     CALL "SHAPE-FIND" USING WS-REGISTRY WS-KEY WS-ROW
     MOVE "c of an unregistered type has no type row" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SH-E-TYPE(WS-ROW) TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "minecraft:nothing" TO WS-KEY
     CALL "SHAPE-FIND" USING WS-REGISTRY WS-KEY WS-ROW
     MOVE "an element that is not there is row 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ROW TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "minecraft:a" TO WS-KEY
     MOVE "other/registry" TO WS-T
     CALL "SHAPE-FIND" USING WS-T WS-KEY WS-ROW
     MOVE "an element of another registry is row 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ROW TO TL-OBSERVED-N
     PERFORM ASSERT-NUM

*>   Strict: the same tree is refused for the type nobody registered, and nothing stays.
     MOVE 1 TO WS-STRICT
     CALL "SHAPE-BEGIN"
     CALL "SHAPE-LOAD" USING WS-DIR WS-REGISTRY WS-GROUP WS-STRICT
     CALL "SHAPE-END" USING WS-STATUS
     MOVE "strict: an unregistered type is CT-BAD-DATA" TO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "strict: the elements of the earlier load stay" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM

     CALL "SHAPE-FREE"
     MOVE "free: no element" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "free: no type row" TO TL-CASE
     MOVE SH-TYPE-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM

*>   Reject: one bad file in a fresh copy of the tree.
     PERFORM REGISTER-TYPES
     MOVE 1 TO WS-STRICT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 39
         MOVE WS-CASE-LABEL(WS-I) TO WS-T
         MOVE WS-CASE-BODY(WS-I) TO WS-BODY
         PERFORM BAD-CASE
     END-PERFORM

*>   A bad file also takes back the good files of the same load.
     CALL "SYSTEM" USING "rm -rf build/content-test/shapes; mkdir -p build/content-test/shapes && cp -R content/tests/fixtures/shapes build/content-test/shapes/t && rm -rf build/content-test/shapes/t/data/extra"
     MOVE "build/content-test/shapes/t" TO WS-DIR
     MOVE '{"type":"alpha"}' TO WS-BODY
     PERFORM WRITE-BAD
     CALL "SHAPE-BEGIN"
     CALL "SHAPE-LOAD" USING WS-DIR WS-REGISTRY WS-GROUP WS-STRICT
     CALL "SHAPE-END" USING WS-STATUS
     MOVE "a bad file takes back the good ones" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM

*>   A type with no member at all accepts any object.
     MOVE "content/tests/fixtures/shapes" TO WS-DIR
     MOVE "g4" TO WS-GROUP
     MOVE "-" TO WS-TYPE
     MOVE SPACES TO WS-FIELDS
     CALL "SHAPE-TYPE-ADD" USING WS-GROUP WS-TYPE WS-FIELDS WS-STATUS
     MOVE "test/empty" TO WS-T
     CALL "SHAPE-BEGIN"
     CALL "SHAPE-LOAD" USING WS-DIR WS-T WS-GROUP WS-STRICT
     CALL "SHAPE-END" USING WS-STATUS
     MOVE "a type with no member accepts an object" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     CALL "SHAPE-FREE"
     PERFORM REGISTER-TYPES

*>   A path with no end.
     MOVE ALL "a" TO WS-DIR
     CALL "SHAPE-BEGIN"
     CALL "SHAPE-LOAD" USING WS-DIR WS-REGISTRY WS-GROUP WS-STRICT
     CALL "SHAPE-END" USING WS-STATUS
     MOVE "a path of 1100 bytes is CT-BAD-DATA" TO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM

*>   A full element table.
     MOVE "content/tests/fixtures/shapes" TO WS-DIR
     MOVE 4095 TO SH-ELEMENT-COUNT
     CALL "SHAPE-BEGIN"
     CALL "SHAPE-LOAD" USING WS-DIR WS-REGISTRY WS-GROUP WS-STRICT
     MOVE 0 TO WS-STRICT
     CALL "SHAPE-END" USING WS-STATUS
     MOVE "a full element table is CT-BAD-DATA" TO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "a full element table is as it was" TO TL-CASE
     MOVE 4095 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE 0 TO SH-ELEMENT-COUNT

*>   SHAPE-REGISTER USING rows (group PIC X(24), type PIC X(48), fields PIC X(600), repeated), count: SHAPE-TYPE-ADD
*>   for each row; a full table counts an error for SHAPE-END.
     CALL "SHAPE-FREE"
     CALL "SHAPE-BEGIN"
     CALL "SHAPE-REGISTER" USING WS-ROWS WS-ROW-COUNT
     CALL "SHAPE-END" USING WS-STATUS
     MOVE "register: two rows are CT-OK" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "register: two type rows" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE SH-TYPE-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "r" TO WS-GROUP
     MOVE "two" TO WS-TYPE
     CALL "SHAPE-TYPE-FIND" USING WS-GROUP WS-TYPE WS-ROW
     MOVE "register: the prefix of the second is dropped" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-ROW TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "I b" TO WS-FIELDS
     MOVE SH-T-FIELDS(2)(1:3) TO TL-OBSERVED
     MOVE "register: the field list is kept" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "I b" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SHAPE-FREE"
     MOVE SPACES TO SH-T-GROUP(1) SH-T-GROUP(2)
     MOVE 2048 TO SH-TYPE-COUNT
     CALL "SHAPE-BEGIN"
     CALL "SHAPE-REGISTER" USING WS-ROWS WS-ROW-COUNT
     CALL "SHAPE-END" USING WS-STATUS
     MOVE "register: a full table is CT-BAD-DATA" TO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM

*>   A full type table.
     MOVE 2048 TO SH-TYPE-COUNT
     MOVE "g" TO WS-GROUP
     MOVE "omega" TO WS-TYPE
     MOVE "S a" TO WS-FIELDS
     CALL "SHAPE-TYPE-ADD" USING WS-GROUP WS-TYPE WS-FIELDS WS-STATUS
     MOVE "a full type table gives status 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     CALL "SHAPE-FREE"
     STOP RUN.

 REGISTER-TYPES.
     MOVE "g" TO WS-GROUP
     MOVE "alpha" TO WS-TYPE
     MOVE "S name;i count=0..10;n ratio=-1.5..1.5;b flag;e kind=a|b;d ref;o obj;a arr;x any;t inner=g2;r rr=g2;"
         TO WS-FIELDS(1:100)
     MOVE "v vv=g2;l ll=g2;k kk;h hh=g2;t typed=g3" TO WS-FIELDS(101:)
     CALL "SHAPE-TYPE-ADD" USING WS-GROUP WS-TYPE WS-FIELDS WS-STATUS
     CALL "SHAPE-TYPE-ADD" USING WS-GROUP WS-TYPE WS-FIELDS WS-STATUS
     MOVE "g2" TO WS-GROUP
     MOVE "-" TO WS-TYPE
     MOVE "S tag" TO WS-FIELDS
     CALL "SHAPE-TYPE-ADD" USING WS-GROUP WS-TYPE WS-FIELDS WS-STATUS
     MOVE "g3" TO WS-GROUP
     MOVE "beta" TO WS-TYPE
     MOVE "I n" TO WS-FIELDS
     CALL "SHAPE-TYPE-ADD" USING WS-GROUP WS-TYPE WS-FIELDS WS-STATUS
     MOVE "g3" TO WS-GROUP
     MOVE "minecraft:other" TO WS-TYPE
     MOVE "I n" TO WS-FIELDS
     CALL "SHAPE-TYPE-ADD" USING WS-GROUP WS-TYPE WS-FIELDS WS-STATUS
     MOVE "g" TO WS-GROUP.

 FRESH-TREE.
     MOVE "build/content-test/shapes/t" TO WS-DIR
     CALL "SYSTEM" USING "chmod -R u+rwx build/content-test/shapes 2>/dev/null; rm -rf build/content-test/shapes; mkdir -p build/content-test/shapes && cp -R content/tests/fixtures/shapes build/content-test/shapes/t && rm -rf build/content-test/shapes/t/data/minecraft/test/shapes/*.json build/content-test/shapes/t/data/extra".

 WRITE-BAD.
     MOVE SPACES TO WS-COMMAND
     STRING "printf '%s' '" FUNCTION TRIM(WS-BODY) "' > build/content-test/shapes/t/data/minecraft/test/shapes/bad.json"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND.

 BAD-CASE.
     PERFORM FRESH-TREE
     PERFORM WRITE-BAD
     CALL "SHAPE-BEGIN"
     CALL "SHAPE-LOAD" USING WS-DIR WS-REGISTRY WS-GROUP WS-STRICT
     CALL "SHAPE-END" USING WS-STATUS
     MOVE SPACES TO TL-CASE
     STRING "shapes: " FUNCTION TRIM(WS-T) " is CT-BAD-DATA" DELIMITED BY SIZE INTO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "shapes: after " FUNCTION TRIM(WS-T) " nothing stays" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM.

 ASSERT-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
