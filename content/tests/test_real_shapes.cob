*> Test of the value forms the real data needs of the shape engine (docs/protocol/48-real-data-shapes.md sections 2.2, 2.7 and 3.15
*> to 3.17; shapes.cob, CTSHAPE.cpy): the block state slot Q (a block id, or {id, properties?}; the keys Name and Properties
*> do not occur), the object of strings W, the block state provider slot G (a provider id, an untyped state object, or a typed
*> provider), a group that names its type in another member (the row "@": element_type, predicate_type), and a bare number as
*> the whole file of a group (the row "~", a context provider file). Every case writes invented minimal files into a fresh
*> tree and loads them (SHAPE-LOAD); an accept case expects CT-OK, a reject case CT-BAD-DATA with nothing kept.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-REAL-SHAPES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CTSHAPE.
 01 WS-DIR                 PIC X(1100).
 01 WS-REGISTRY            PIC X(48).
 01 WS-GROUP               PIC X(24).
 01 WS-STATUS              BINARY-LONG.
 01 WS-STRICT              BINARY-LONG.
 01 WS-COMMAND             PIC X(600).
 01 WS-I                   BINARY-LONG.
 01 WS-T                   PIC X(60).
 01 WS-BODY                PIC X(300).
 01 WS-EXPECT              BINARY-LONG.
 01 WS-ROWS.
    05 FILLER PIC X(24) VALUE "rs".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "Q st;q st2;W props;G pv=pvg;I n".
    05 FILLER PIC X(24) VALUE "el".
    05 FILLER PIC X(48) VALUE "@".
    05 FILLER PIC X(600) VALUE "element_type".
    05 FILLER PIC X(24) VALUE "el".
    05 FILLER PIC X(48) VALUE "single".
    05 FILLER PIC X(600) VALUE "D location;E projection=rigid|terrain_matching".
    05 FILLER PIC X(24) VALUE "el".
    05 FILLER PIC X(48) VALUE "empty".
    05 FILLER PIC X(600) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "pvg".
    05 FILLER PIC X(48) VALUE "weighted".
    05 FILLER PIC X(600) VALUE "A entries".
    05 FILLER PIC X(24) VALUE "num".
    05 FILLER PIC X(48) VALUE "~".
    05 FILLER PIC X(600) VALUE "I".
    05 FILLER PIC X(24) VALUE "num".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "x type".
 01 WS-ROW-COUNT           BINARY-LONG VALUE 8.
*> Cases: the group, the registry directory, 0 accept or 1 reject, the label and the file body.
 01 WS-CASES.
    05 FILLER PIC X(24) VALUE "rs".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(60) VALUE "a state that is a block id".
    05 FILLER PIC X(300) VALUE '{"st":"minecraft:stone","props":{},"pv":"minecraft:p","n":1}'.
    05 FILLER PIC X(24) VALUE "rs".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(60) VALUE "a state that is {id, properties} with string values".
    05 FILLER PIC X(300) VALUE '{"st":{"id":"minecraft:oak_log","properties":{"axis":"y"}},"props":{"a":"b"},"pv":"a:b","n":1}'.
    05 FILLER PIC X(24) VALUE "rs".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(60) VALUE "a state that is {id} without properties".
    05 FILLER PIC X(300) VALUE '{"st":{"id":"minecraft:dirt"},"props":{},"pv":{"id":"minecraft:dirt"},"n":1}'.
    05 FILLER PIC X(24) VALUE "rs".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(60) VALUE "a provider that is a typed object".
    05 FILLER PIC X(300) VALUE '{"st":"a:b","props":{},"pv":{"type":"minecraft:weighted","entries":[]},"n":1,"st2":"a:c"}'.
    05 FILLER PIC X(24) VALUE "rs".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(60) VALUE "a state with the key Name".
    05 FILLER PIC X(300) VALUE '{"st":{"Name":"minecraft:stone"},"props":{},"pv":"a:b","n":1}'.
    05 FILLER PIC X(24) VALUE "rs".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(60) VALUE "a state that is a number".
    05 FILLER PIC X(300) VALUE '{"st":3,"props":{},"pv":"a:b","n":1}'.
    05 FILLER PIC X(24) VALUE "rs".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(60) VALUE "a state whose id is a number".
    05 FILLER PIC X(300) VALUE '{"st":{"id":3},"props":{},"pv":"a:b","n":1}'.
    05 FILLER PIC X(24) VALUE "rs".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(60) VALUE "a state whose properties hold a number".
    05 FILLER PIC X(300) VALUE '{"st":{"id":"a:b","properties":{"x":1}},"props":{},"pv":"a:b","n":1}'.
    05 FILLER PIC X(24) VALUE "rs".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(60) VALUE "an object of strings that holds a number".
    05 FILLER PIC X(300) VALUE '{"st":"a:b","props":{"x":1},"pv":"a:b","n":1}'.
    05 FILLER PIC X(24) VALUE "rs".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(60) VALUE "an object of strings that is an array".
    05 FILLER PIC X(300) VALUE '{"st":"a:b","props":[],"pv":"a:b","n":1}'.
    05 FILLER PIC X(24) VALUE "rs".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(60) VALUE "a provider that is a number".
    05 FILLER PIC X(300) VALUE '{"st":"a:b","props":{},"pv":5,"n":1}'.
    05 FILLER PIC X(24) VALUE "rs".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(60) VALUE "an untyped provider object without id".
    05 FILLER PIC X(300) VALUE '{"st":"a:b","props":{},"pv":{"properties":{}},"n":1}'.
    05 FILLER PIC X(24) VALUE "el".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(60) VALUE "an element named by element_type".
    05 FILLER PIC X(300) VALUE '{"element_type":"minecraft:single","location":"a:b","projection":"rigid"}'.
    05 FILLER PIC X(24) VALUE "el".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(60) VALUE "an element of a type with no member".
    05 FILLER PIC X(300) VALUE '{"element_type":"minecraft:empty"}'.
    05 FILLER PIC X(24) VALUE "el".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(60) VALUE "an element without element_type".
    05 FILLER PIC X(300) VALUE '{"location":"a:b","projection":"rigid"}'.
    05 FILLER PIC X(24) VALUE "el".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(60) VALUE "an element of an unregistered type (strict)".
    05 FILLER PIC X(300) VALUE '{"element_type":"minecraft:other"}'.
    05 FILLER PIC X(24) VALUE "el".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(60) VALUE "an element missing a member of its type".
    05 FILLER PIC X(300) VALUE '{"element_type":"minecraft:single","projection":"rigid"}'.
    05 FILLER PIC X(24) VALUE "num".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(60) VALUE "a file that is a bare integer".
    05 FILLER PIC X(300) VALUE '20'.
    05 FILLER PIC X(24) VALUE "num".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(60) VALUE "a file that is an object of the group".
    05 FILLER PIC X(300) VALUE '{"type":"minecraft:x"}'.
    05 FILLER PIC X(24) VALUE "num".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(60) VALUE "a file that is a bare decimal where an integer is due".
    05 FILLER PIC X(300) VALUE '1.5'.
    05 FILLER PIC X(24) VALUE "num".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(60) VALUE "a file that is a string".
    05 FILLER PIC X(300) VALUE '"x"'.
    05 FILLER PIC X(24) VALUE "rs".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(60) VALUE "a bare number where the group has no ~ row".
    05 FILLER PIC X(300) VALUE '20'.
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE OCCURS 22 TIMES.
       10 WS-CASE-GROUP    PIC X(24).
       10 WS-CASE-EXPECT   PIC X(1).
       10 WS-CASE-LABEL    PIC X(60).
       10 WS-CASE-BODY     PIC X(300).
 PROCEDURE DIVISION.
     CALL "SHAPE-FREE"
     CALL "SHAPE-BEGIN"
     CALL "SHAPE-REGISTER" USING WS-ROWS WS-ROW-COUNT
     MOVE "real shapes: eight type rows" TO TL-CASE
     MOVE 8 TO TL-EXPECTED-N
     MOVE SH-TYPE-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE 1 TO WS-STRICT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 22
         MOVE WS-CASE-GROUP(WS-I) TO WS-GROUP
         MOVE WS-CASE-LABEL(WS-I) TO WS-T
         MOVE WS-CASE-BODY(WS-I) TO WS-BODY
         IF WS-CASE-EXPECT(WS-I) = "0"
             MOVE CT-OK TO WS-EXPECT
         ELSE
             MOVE CT-BAD-DATA TO WS-EXPECT
         END-IF
         PERFORM ONE-CASE
     END-PERFORM
     CALL "SHAPE-FREE"
     STOP RUN.

 ONE-CASE.
     CALL "SYSTEM" USING "rm -rf build/content-test/real-shapes; mkdir -p build/content-test/real-shapes/t/data/minecraft/test"
     MOVE SPACES TO WS-COMMAND
     STRING "mkdir -p build/content-test/real-shapes/t/data/minecraft/test/real && printf '%s' '" FUNCTION TRIM(WS-BODY)
         "' > build/content-test/real-shapes/t/data/minecraft/test/real/x.json" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "build/content-test/real-shapes/t" TO WS-DIR
     MOVE "test/real" TO WS-REGISTRY
     CALL "SHAPE-BEGIN"
     CALL "SHAPE-LOAD" USING WS-DIR WS-REGISTRY WS-GROUP WS-STRICT
     CALL "SHAPE-END" USING WS-STATUS
     MOVE SPACES TO TL-CASE
     STRING "real shapes: " FUNCTION TRIM(WS-T) DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     IF WS-EXPECT = CT-OK
         MOVE 1 TO TL-EXPECTED-N
     ELSE
         MOVE 0 TO TL-EXPECTED-N
     END-IF
     MOVE SPACES TO TL-CASE
     STRING "real shapes: " FUNCTION TRIM(WS-T) ": elements kept" DELIMITED BY SIZE INTO TL-CASE
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     CALL "SHAPE-FREE"
     CALL "SHAPE-BEGIN"
     CALL "SHAPE-REGISTER" USING WS-ROWS WS-ROW-COUNT.

 ASSERT-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
