*> Unit test of the jigsaw assembly over synthetic fixtures (docs/protocol/36-structures-3 sections 3 to 6, 10; core/tests/fixtures/jigpool and tpl, written by gen_tpl.py): the jigsaw fields of a
*> structure file in all their forms (3.1), the pool reader with its absent, unreadable and unsupported cases and its table limits (6), the box and jigsaws of an element of every kind (5), the
*> direction turns (2.1), a small structure whose jigsaws ask a missing pool, an empty pool and a pool with an empty fallback (10.2 steps 1 to 3) against core/tests/fixtures/gen_jigsaw.py
*> (--synthetic), and the starts that cannot be built. Runs over the standard content set of the generated packs (skipped as a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-JIGSAW-UNIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 COPY STRUCTTPL.
 COPY STRUCTJIG.
 COPY JIGTEST.
 COPY FEATDATA.
 COPY JSONDOC.
 01 WS-GEN-DIR             PIC X(1100).
 01 WS-ENV                 PIC X(1100).
 01 WS-FILE                PIC X(1200).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-TYPE                BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-ID                  PIC X(96).
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROW2                BINARY-LONG.
 01 WS-EL                  BINARY-LONG.
 01 WS-SUB                 BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-TEXT                PIC X(2000).
 01 WS-LEN                 BINARY-LONG.
 01 WS-KIND-TYPE           BINARY-LONG VALUE 1.
 01 WS-NAME                PIC X(40).
 01 WS-JIGSAW-ID           BINARY-LONG.
 01 WS-OTHER-ID            BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-ROT                 BINARY-LONG.
 01 WS-ROT-D               PIC 9.
 01 WS-DIR                 BINARY-LONG.
 01 WS-DIR-D               PIC 9.
 01 WS-OUT                 BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-CYCLE               PIC X(4) VALUE X"02050304".
 01 WS-IDX                 BINARY-LONG.
 01 WS-BOX.
    05 WB                  BINARY-LONG OCCURS 6 TIMES.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-Z3                  BINARY-LONG VALUE 0.
 01 WS-Z4                  BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-SAVE                BINARY-LONG.
 01 WS-SAVE2               BINARY-LONG.
 01 WS-ED1                 PIC -(5)9.
 01 WS-ED2                 PIC -(5)9.
 01 WS-SEED                BINARY-DOUBLE VALUE 12345.
 01 WS-TPL-DIR             PIC X(1100) VALUE "core/tests/fixtures/tpl".
 01 WS-POOL-DIR            PIC X(1100) VALUE "core/tests/fixtures/jigpool".
*> the model's synthetic starts: chunk x, z, then the hub's origin and rotation, the leaf's origin and rotation, the junction source of the parent and of the child (x, ground y, z each)
 01 WS-WANT-DATA.
    05 FILLER PIC X(120) VALUE "+0000+0000 +0000+0069+0000 1 +0003+0069+0000 1 +0001+0070+0001 +0000+0070+0001".
    05 FILLER PIC X(120) VALUE "+0001+0000 +0016+0069+0000 0 +0016+0069-0003 0 +0017+0070-0001 +0017+0070+0000".
    05 FILLER PIC X(120) VALUE "-0002+0003 -0032+0069+0048 1 -0029+0069+0048 1 -0031+0070+0049 -0032+0070+0049".
    05 FILLER PIC X(120) VALUE "+0004+0004 +0064+0069+0064 0 +0064+0069+0061 0 +0065+0070+0063 +0065+0070+0064".
 01 WS-WANT-T REDEFINES WS-WANT-DATA.
    05 WS-W OCCURS 4 TIMES.
       10 WW-CX            PIC S9(4) SIGN LEADING SEPARATE.
       10 WW-CZ            PIC S9(4) SIGN LEADING SEPARATE.
       10 FILLER           PIC X.
       10 WW-HX            PIC S9(4) SIGN LEADING SEPARATE.
       10 WW-HY            PIC S9(4) SIGN LEADING SEPARATE.
       10 WW-HZ            PIC S9(4) SIGN LEADING SEPARATE.
       10 FILLER           PIC X.
       10 WW-HR            PIC 9.
       10 FILLER           PIC X.
       10 WW-LX            PIC S9(4) SIGN LEADING SEPARATE.
       10 WW-LY            PIC S9(4) SIGN LEADING SEPARATE.
       10 WW-LZ            PIC S9(4) SIGN LEADING SEPARATE.
       10 FILLER           PIC X.
       10 WW-LR            PIC 9.
       10 FILLER           PIC X.
       10 WW-PX            PIC S9(4) SIGN LEADING SEPARATE.
       10 WW-PY            PIC S9(4) SIGN LEADING SEPARATE.
       10 WW-PZ            PIC S9(4) SIGN LEADING SEPARATE.
       10 FILLER           PIC X.
       10 WW-QX            PIC S9(4) SIGN LEADING SEPARATE.
       10 WW-QY            PIC S9(4) SIGN LEADING SEPARATE.
       10 WW-QZ            PIC S9(4) SIGN LEADING SEPARATE.
       10 FILLER           PIC X(42).
 01 WS-WANT2-DATA.
    05 FILLER PIC X(60) VALUE "+0007+0007 +0112+0112 0 +0112+0109 0 +0114+0117 2".
    05 FILLER PIC X(60) VALUE "+0008-0006 +0128-0096 3 +0125-0096 3 +0133-0098 1".
    05 FILLER PIC X(60) VALUE "-0009+0005 -0144+0080 2 -0146+0075 0 -0144+0083 2".
 01 WS-WANT2-T REDEFINES WS-WANT2-DATA.
    05 WS-W2 OCCURS 3 TIMES.
       10 W2-CX            PIC S9(4) SIGN LEADING SEPARATE.
       10 W2-CZ            PIC S9(4) SIGN LEADING SEPARATE.
       10 FILLER           PIC X.
       10 W2-HX            PIC S9(4) SIGN LEADING SEPARATE.
       10 W2-HZ            PIC S9(4) SIGN LEADING SEPARATE.
       10 FILLER           PIC X.
       10 W2-HR            PIC 9.
       10 FILLER           PIC X.
       10 W2-AX            PIC S9(4) SIGN LEADING SEPARATE.
       10 W2-AZ            PIC S9(4) SIGN LEADING SEPARATE.
       10 FILLER           PIC X.
       10 W2-AR            PIC 9.
       10 FILLER           PIC X.
       10 W2-BX            PIC S9(4) SIGN LEADING SEPARATE.
       10 W2-BZ            PIC S9(4) SIGN LEADING SEPARATE.
       10 FILLER           PIC X.
       10 W2-BR            PIC 9.
       10 FILLER           PIC X(11).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-GEN-DIR
     ELSE
         MOVE WS-ENV TO WS-GEN-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-GEN-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "test struct jigsaw unit no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE CT-TYPE-STANDARD TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-GEN-DIR WS-STATUS
     CALL "BLOCKS-OPEN"
     CALL "STRUCT-TPL-RESET"
     CALL "JIG-RESET"
     MOVE WS-TPL-DIR TO SD-DIR
     MOVE WS-POOL-DIR TO FD-DIR
     MOVE "jigsaw" TO WS-NAME
     CALL "STRUCT-ENUM-ID" USING WS-KIND-TYPE WS-NAME WS-JIGSAW-ID
     MOVE "shipwreck" TO WS-NAME
     CALL "STRUCT-ENUM-ID" USING WS-KIND-TYPE WS-NAME WS-OTHER-ID
     MOVE 2 TO SD-ST-COUNT
     PERFORM READ-CASES
     PERFORM POOL-CASES
     PERFORM ELEMENT-CASES
     PERFORM SORT-CASES
     PERFORM DIRECTION-CASES
     PERFORM ASSEMBLY-CASES
     PERFORM LIMIT-CASES
     STOP RUN.

 CHECK.
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> 3.1: the fields of a structure file in the object forms, the int forms and the ones the assembler does not read
 READ-CASES.
     MOVE WS-JIGSAW-ID TO SDT-TYPE(1)
     MOVE WS-OTHER-ID TO SDT-TYPE(2)
     MOVE '{"type":"minecraft:jigsaw","start_pool":"test:start","size":4,"start_height":{"absolute":-3},"project_start_to_heightmap":"OCEAN_FLOOR_WG",'
         & '"use_expansion_hack":false,"max_distance_from_center":{"horizontal":50},"dimension_padding":{"bottom":3,"top":4},"liquid_settings":"ignore_waterlogging"}' TO WS-TEXT
     PERFORM PARSE-READ-ONE
     MOVE "test struct jigsaw unit given the object forms when a jigsaw file is read then the fields are the file's (vertical 4064 by default)" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF SDT-JIG-POOL(1) = "test:start" AND SDT-JIG-SIZE(1) = 4 AND SDT-JIG-Y(1) = -3 AND SDT-JIG-PROJ(1) = 1 AND SDT-JIG-HACK(1) = 0
        AND SDT-JIG-HOR(1) = 50 AND SDT-JIG-VER(1) = 4064 AND SDT-JIG-PADB(1) = 3 AND SDT-JIG-PADT(1) = 4 AND SDT-JIG-LIQ(1) = 1 AND SDT-JIG-OK(1) = 1
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE '{"type":"minecraft:jigsaw","start_pool":"minecraft:village/x","size":2,"start_height":{"absolute":5},"use_expansion_hack":true,'
         & '"max_distance_from_center":30,"dimension_padding":5}' TO WS-TEXT
     PERFORM PARSE-READ-ONE
     MOVE "test struct jigsaw unit given the int forms when a jigsaw file is read then the distance is a cube, the padding is both, no heightmap, the hack on" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF SDT-JIG-HOR(1) = 30 AND SDT-JIG-VER(1) = 30 AND SDT-JIG-PADB(1) = 5 AND SDT-JIG-PADT(1) = 5 AND SDT-JIG-PROJ(1) = -1 AND SDT-JIG-HACK(1) = 1
        AND SDT-JIG-LIQ(1) = 0 AND SDT-JIG-OK(1) = 1
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE '{"type":"minecraft:jigsaw","start_pool":"test:start","size":2,"start_height":{"absolute":5},"max_distance_from_center":{"horizontal":40,"vertical":60}}' TO WS-TEXT
     PERFORM PARSE-READ-ONE
     MOVE "test struct jigsaw unit given an object distance with a vertical when a jigsaw file is read then the vertical is read" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF SDT-JIG-HOR(1) = 40 AND SDT-JIG-VER(1) = 60 AND SDT-JIG-PROJ(1) = -1
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE '{"type":"minecraft:jigsaw","start_pool":"test:start","size":2,"start_height":{"absolute":5},"project_start_to_heightmap":"WORLD_SURFACE_WG","max_distance_from_center":9}' TO WS-TEXT
     PERFORM PARSE-READ-ONE
     MOVE "test struct jigsaw unit given the WORLD_SURFACE_WG heightmap when a jigsaw file is read then the heightmap is 0" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF SDT-JIG-PROJ(1) = 0 AND SDT-JIG-OK(1) = 1
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE '{"type":"minecraft:jigsaw","start_pool":"test:start","size":2,"start_height":{"absolute":5},"project_start_to_heightmap":"MOTION_BLOCKING","max_distance_from_center":9}' TO WS-TEXT
     PERFORM PARSE-READ-ONE
     MOVE "test struct jigsaw unit given a heightmap the column query does not know when a jigsaw file is read then it is not ok" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF SDT-JIG-OK(1) = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE '{"type":"minecraft:jigsaw","start_pool":"test:start","size":2,"start_height":{"uniform":{"min_inclusive":{"absolute":1},"max_inclusive":{"absolute":9}}},"max_distance_from_center":9}' TO WS-TEXT
     PERFORM PARSE-READ-ONE
     MOVE "test struct jigsaw unit given a start height that is not absolute when a jigsaw file is read then it is not ok" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF SDT-JIG-OK(1) = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE '{"type":"minecraft:jigsaw","start_pool":"test:start","size":2,"start_height":{"absolute":5},"max_distance_from_center":9,"pool_aliases":[{"type":"minecraft:direct"}]}' TO WS-TEXT
     PERFORM PARSE-READ-ONE
     MOVE "test struct jigsaw unit given a pool alias binding without alias and target when a jigsaw file is read then it is not ok" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF SDT-JIG-OK(1) = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE '{"type":"minecraft:jigsaw","start_pool":"test:start","size":2,"start_height":{"absolute":5},"max_distance_from_center":9,"pool_aliases":[]}' TO WS-TEXT
     PERFORM PARSE-READ-ONE
     MOVE "test struct jigsaw unit given an empty list of pool aliases when a jigsaw file is read then it is ok" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF SDT-JIG-OK(1) = 1
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE '{"type":"minecraft:jigsaw","start_pool":"test:start","start_jigsaw_name":"minecraft:city_anchor","size":2,"start_height":{"absolute":5},"max_distance_from_center":9}' TO WS-TEXT
     PERFORM PARSE-READ-ONE
     MOVE "test struct jigsaw unit given a start_jigsaw_name when a jigsaw file is read then it is ok and the name is kept" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF SDT-JIG-OK(1) = 1 AND SDT-JIG-NAMED(1) = 1 AND SDT-JIG-NAME(1) = "minecraft:city_anchor"
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE '{"type":"minecraft:shipwreck","is_beached":true}' TO WS-TEXT
     MOVE 2 TO WS-ROW
     PERFORM PARSE-READ
     MOVE "test struct jigsaw unit given a structure of another type when its file is read then it is not ok and has no pool" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF SDT-JIG-OK(2) = 0 AND SDT-JIG-POOL(2) = SPACES AND SDT-JIG-PROJ(2) = -1
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK.

 PARSE-READ-ONE.
     MOVE 1 TO WS-ROW
     PERFORM PARSE-READ.

 PARSE-READ.
     COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT TRAILING))
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "STRUCT-JIG-READ" USING JSON-DOC WS-ROW.

*> 3.2, 3.3, 6: pools of the fixtures
 POOL-CASES.
     MOVE 0 TO JE-COUNT
     MOVE "test:start" TO WS-KEY
     CALL "JIG-POOL-FIND" USING WS-KEY WS-ROW
     MOVE JN-ELEM(JP-FIRST(WS-ROW)) TO WS-EL
     MOVE "test struct jigsaw unit given the pool test:start when it is read then it has one legacy rigid element of test:jhub with no list, total 1, fallback minecraft:empty" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF JP-TOTAL(WS-ROW) = 1 AND JE-KIND(WS-EL) = 2 AND JE-PROJ(WS-EL) = 0 AND JE-LOC(WS-EL) = "test:jhub" AND JE-PROC(WS-EL) = SPACES AND JP-FALLBACK(WS-ROW) = 1
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "test:leaf" TO WS-KEY
     CALL "JIG-POOL-FIND" USING WS-KEY WS-ROW
     MOVE WS-ROW TO WS-SAVE
     MOVE JN-ELEM(JP-FIRST(WS-ROW)) TO WS-EL
     MOVE "test struct jigsaw unit given the pool test:leaf when it is read then its element names the list minecraft:empty as processors" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF JE-PROC(WS-EL) = "minecraft:empty"
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "test:zero" TO WS-KEY
     CALL "JIG-POOL-FIND" USING WS-KEY WS-ROW
     MOVE WS-ROW TO WS-SAVE2
     MOVE "test struct jigsaw unit given a pool with no element when it is read then it is loaded with total 0" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-ROW > 1 AND JP-TOTAL(WS-ROW) = 0 AND JP-STATUS(WS-ROW) = 1
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "test:badfb" TO WS-KEY
     CALL "JIG-POOL-FIND" USING WS-KEY WS-ROW
     MOVE "test struct jigsaw unit given a pool whose fallback is a pool with no element when it is read then the fallback is that pool" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF JP-FALLBACK(WS-ROW) = WS-SAVE2
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "test:fb2" TO WS-KEY
     CALL "JIG-POOL-FIND" USING WS-KEY WS-ROW
     MOVE "test struct jigsaw unit given a pool whose fallback is another pool when it is read then the fallback is its row" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF JP-FALLBACK(WS-ROW) = WS-SAVE
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "test:badjson" TO WS-KEY
     CALL "JIG-POOL-FIND" USING WS-KEY WS-ROW
     MOVE "test struct jigsaw unit given a pool file that is not JSON when it is read then there is no pool" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-ROW = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "test:noelements" TO WS-KEY
     CALL "JIG-POOL-FIND" USING WS-KEY WS-ROW
     MOVE "test struct jigsaw unit given a pool file with no elements list when it is read then there is no pool" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-ROW = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "test:mixed" TO WS-KEY
     CALL "JIG-POOL-FIND" USING WS-KEY WS-ROW
     MOVE WS-ROW TO WS-SAVE
     MOVE "test struct jigsaw unit given a pool of an unknown element type, a list, a feature and the empty element when it is read then the weights sum to 7" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF JP-TOTAL(WS-ROW) = 7 AND JP-N(WS-ROW) = 4
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE JN-ELEM(JP-FIRST(WS-SAVE)) TO WS-EL
     MOVE "test struct jigsaw unit given an element of an unknown type when it is read then it is the shared empty element" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-EL = 1 AND JE-KIND(1) = 5
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE JN-ELEM(JP-FIRST(WS-SAVE) + 1) TO WS-EL
     MOVE "test struct jigsaw unit given a list element when it is read then it has two sub-elements and its projection on the first (the empty one is shared and keeps its own)" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF JE-KIND(WS-EL) = 3 AND JE-SUB-N(WS-EL) = 2 AND JE-PROJ(WS-EL) = 1
         MOVE JS-ELEM(JE-SUB-FIRST(WS-EL)) TO WS-SUB
         IF JE-KIND(WS-SUB) = 1 AND JE-PROJ(WS-SUB) = 1 AND JS-ELEM(JE-SUB-FIRST(WS-EL) + 1) = 1
             MOVE 1 TO WS-FLAG
         END-IF
     END-IF
     PERFORM CHECK
     MOVE JN-ELEM(JP-FIRST(WS-SAVE) + 2) TO WS-EL
     MOVE "test struct jigsaw unit given a feature element when it is read then it names the feature with its namespace" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF JE-KIND(WS-EL) = 4 AND JE-FEATURE(WS-EL) = "minecraft:oak"
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "minecraft:empty" TO WS-KEY
     CALL "JIG-POOL-MAXSIZE" USING WS-ONE WS-VALUE
     MOVE "test struct jigsaw unit given the pool minecraft:empty when its max size is asked then it is 0" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-VALUE = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     CALL "JIG-POOL-MAXSIZE" USING WS-SAVE WS-VALUE
     MOVE "test struct jigsaw unit given the mixed pool when its max size is asked then it is the tallest box (2: the list's template is 2 high, a feature 1)" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-VALUE = 2 AND JP-MAXSIZE(WS-SAVE) = 2
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK.

*> 5: the box and the jigsaws of an element of every kind
 ELEMENT-CASES.
     MOVE "test:mixed" TO WS-KEY
     CALL "JIG-POOL-FIND" USING WS-KEY WS-ROW
     MOVE JN-ELEM(JP-FIRST(WS-ROW) + 1) TO WS-EL
     MOVE 10 TO WS-BX
     MOVE 20 TO WS-BY
     MOVE 30 TO WS-BZ
     MOVE 1 TO WS-ROT
     CALL "JIG-EL-BOX" USING WS-EL WS-BX WS-BY WS-BZ WS-ROT WS-BOX
     MOVE "test struct jigsaw unit given a list of a 3 x 2 x 3 template and the empty element when its box is taken at a quarter turn then it is the template's alone" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WB(1) = 8 AND WB(2) = 20 AND WB(3) = 30 AND WB(4) = 10 AND WB(5) = 21 AND WB(6) = 32
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     CALL "JIG-EL-JIGS" USING WS-EL WS-BX WS-BY WS-BZ WS-ZERO
     MOVE "test struct jigsaw unit given a list element when its jigsaws are listed then they are the first sub-element's (one at the rotated position, front south, top up, aligned)" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF JW-COUNT = 1 AND JW-X(1) = 11 AND JW-Y(1) = 20 AND JW-Z(1) = 32 AND JW-FRONT(1) = 3 AND JW-TOP(1) = 1 AND JW-JOINT(1) = 1 AND JW-TAG(1) > 0
        AND JW-PLACE(1) = 0 AND JW-SELECT(1) = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE JN-ELEM(JP-FIRST(WS-ROW) + 2) TO WS-EL
     CALL "JIG-EL-BOX" USING WS-EL WS-BX WS-BY WS-BZ WS-ROT WS-BOX
     MOVE "test struct jigsaw unit given a feature element when its box is taken then it is the block at its position" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WB(1) = 10 AND WB(2) = 20 AND WB(3) = 30 AND WB(4) = 10 AND WB(5) = 20 AND WB(6) = 30
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     CALL "JIG-EL-JIGS" USING WS-EL WS-BX WS-BY WS-BZ WS-ROT
     MOVE "test struct jigsaw unit given a feature element when its jigsaws are listed then there is one synthetic jigsaw (down, top south, rollable, no tag)" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF JW-COUNT = 1 AND JW-X(1) = 10 AND JW-Y(1) = 20 AND JW-Z(1) = 30 AND JW-FRONT(1) = 0 AND JW-TOP(1) = 3 AND JW-JOINT(1) = 2 AND JW-TAG(1) = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     CALL "JIG-EL-JIGS" USING WS-ONE WS-BX WS-BY WS-BZ WS-ROT
     MOVE "test struct jigsaw unit given the empty element when its jigsaws are listed then there are none" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF JW-COUNT = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
*>   an element whose template is not there: a block's box and no jigsaw
     ADD 1 TO JE-COUNT
     MOVE JE-COUNT TO WS-EL
     MOVE 1 TO JE-KIND(WS-EL)
     MOVE 0 TO JE-PROJ(WS-EL)
     MOVE "test:nothing_here" TO JE-LOC(WS-EL)
     CALL "JIG-EL-BOX" USING WS-EL WS-BX WS-BY WS-BZ WS-ROT WS-BOX
     MOVE "test struct jigsaw unit given an element whose template is absent when its box is taken then it is the block at its position" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WB(1) = 10 AND WB(4) = 10 AND WB(5) = 20
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     CALL "JIG-EL-JIGS" USING WS-EL WS-BX WS-BY WS-BZ WS-ROT
     MOVE "test struct jigsaw unit given an element whose template is absent when its jigsaws are listed then there are none" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF JW-COUNT = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK.

*> 4.3: sorted stably by selection priority, highest first, whatever the shuffle gave (test:jigs: one jigsaw has priority 5, the others 0)
 SORT-CASES.
     ADD 1 TO JE-COUNT
     MOVE JE-COUNT TO WS-EL
     MOVE 1 TO JE-KIND(WS-EL)
     MOVE 0 TO JE-PROJ(WS-EL) JE-SUB-FIRST(WS-EL) JE-SUB-N(WS-EL)
     MOVE "test:jigs" TO JE-LOC(WS-EL)
     MOVE 0 TO WS-K
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         MOVE WS-I TO SP-RNG
         CALL "JIG-EL-JIGS" USING WS-EL WS-ZERO WS-Z2 WS-Z3 WS-Z4
         IF JW-COUNT = 3 AND JW-SELECT(1) = 5 AND JW-SELECT(2) = 0 AND JW-SELECT(3) = 0 AND JW-PLACE(1) = 2
             ADD 1 TO WS-K
         END-IF
     END-PERFORM
     MOVE "test struct jigsaw unit given a template with one jigsaw of selection priority 5 when its jigsaws are listed under twelve shuffles then it is always first" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE WS-K TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> 2.1: the horizontal directions turn clockwise, up and down stay
 DIRECTION-CASES.
     PERFORM VARYING WS-DIR FROM 0 BY 1 UNTIL WS-DIR > 5
         PERFORM VARYING WS-ROT FROM 0 BY 1 UNTIL WS-ROT > 3
             CALL "JIG-ROT-DIR" USING WS-DIR WS-ROT WS-OUT
             MOVE WS-DIR TO WS-WANT
             IF WS-DIR >= 2
                 EVALUATE WS-DIR
                     WHEN 2
                         MOVE 0 TO WS-IDX
                     WHEN 5
                         MOVE 1 TO WS-IDX
                     WHEN 3
                         MOVE 2 TO WS-IDX
                     WHEN OTHER
                         MOVE 3 TO WS-IDX
                 END-EVALUATE
                 COMPUTE WS-IDX = FUNCTION MOD(WS-IDX + WS-ROT, 4)
                 COMPUTE WS-WANT = FUNCTION ORD(WS-CYCLE(WS-IDX + 1:1)) - 1
             END-IF
             MOVE WS-DIR TO WS-DIR-D
             MOVE WS-ROT TO WS-ROT-D
             MOVE SPACES TO TL-CASE
             STRING "test struct jigsaw unit given direction " WS-DIR-D " when it is turned by rotation " WS-ROT-D " then it is the table's" DELIMITED BY SIZE INTO TL-CASE
             MOVE 0 TO WS-FLAG
             IF WS-OUT = WS-WANT
                 MOVE 1 TO WS-FLAG
             END-IF
             PERFORM CHECK
         END-PERFORM
     END-PERFORM
     MOVE 2 TO WS-DIR
     MOVE 1 TO WS-ROT
     CALL "JIG-ROT-DIR" USING WS-DIR WS-ROT WS-OUT
     MOVE "test struct jigsaw unit given north when it is turned a quarter clockwise then it is east" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-OUT = 5
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK.

*> 10.2: the hub of four jigsaws against the model: the leaf is attached through the one that fits, the others ask a pool that is absent, empty, or has an empty fallback
 ASSEMBLY-CASES.
     MOVE 1 TO TJ-SURFACE
     MOVE "test:start" TO SDT-JIG-POOL(1)
     MOVE 3 TO SDT-JIG-SIZE(1)
     MOVE 70 TO SDT-JIG-Y(1)
     MOVE -1 TO SDT-JIG-PROJ(1)
     MOVE 0 TO SDT-JIG-HACK(1)
     MOVE 20 TO SDT-JIG-HOR(1)
     MOVE 20 TO SDT-JIG-VER(1)
     MOVE 0 TO SDT-JIG-PADB(1) SDT-JIG-PADT(1) SDT-JIG-LIQ(1)
     MOVE 0 TO SDT-JIG-NAMED(1) SDT-JIG-PADSET(1) SDT-JIG-YKIND(1) SDT-JIG-AL-N(1)
     MOVE 1 TO SDT-JIG-OK(1)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE WW-CX(WS-I) TO WS-CX
         MOVE WW-CZ(WS-I) TO WS-CZ
         CALL "JIG-FIND-POINT" USING WS-ONE WS-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
         MOVE WS-CX TO WS-ED1
         MOVE WS-CZ TO WS-ED2
         MOVE SPACES TO TL-CASE
         STRING "test struct jigsaw unit given the synthetic hub at chunk " FUNCTION TRIM(WS-ED1) "," FUNCTION TRIM(WS-ED2) " when it is built then it is the model's two pieces and two junctions" DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO WS-FLAG
         IF WS-VALID = 1 AND SP-COUNT = 2 AND JJ-COUNT = 2
             MOVE SP-F1(1) TO WS-EL
             MOVE SP-F1(2) TO WS-SUB
             IF JE-LOC(WS-EL) = "test:jhub" AND JE-LOC(WS-SUB) = "test:jleaf"
                AND SP-T-X(1) = WW-HX(WS-I) AND SP-T-Y(1) = WW-HY(WS-I) AND SP-T-Z(1) = WW-HZ(WS-I) AND SP-T-ROT(1) = WW-HR(WS-I)
                AND SP-T-X(2) = WW-LX(WS-I) AND SP-T-Y(2) = WW-LY(WS-I) AND SP-T-Z(2) = WW-LZ(WS-I) AND SP-T-ROT(2) = WW-LR(WS-I)
                AND JJ-OWNER(1) = 1 AND JJ-X(1) = WW-PX(WS-I) AND JJ-Y(1) = WW-PY(WS-I) AND JJ-Z(1) = WW-PZ(WS-I)
                AND JJ-OWNER(2) = 2 AND JJ-X(2) = WW-QX(WS-I) AND JJ-Y(2) = WW-QY(WS-I) AND JJ-Z(2) = WW-QZ(WS-I)
                 MOVE 1 TO WS-FLAG
             END-IF
         END-IF
         PERFORM CHECK
     END-PERFORM
*>   two leaves whose jigsaws have placement priorities 0 and 3: the queue serves the second first (its order does not show in the pieces, which are in creation order)
     MOVE "test:start2" TO SDT-JIG-POOL(1)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         MOVE W2-CX(WS-I) TO WS-CX
         MOVE W2-CZ(WS-I) TO WS-CZ
         CALL "JIG-FIND-POINT" USING WS-ONE WS-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
         MOVE WS-CX TO WS-ED1
         MOVE WS-CZ TO WS-ED2
         MOVE SPACES TO TL-CASE
         STRING "test struct jigsaw unit given the synthetic hub with two priorities at chunk " FUNCTION TRIM(WS-ED1) "," FUNCTION TRIM(WS-ED2) " when it is built then it is the model's three pieces" DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO WS-FLAG
         IF WS-VALID = 1 AND SP-COUNT = 3
             IF SP-T-X(1) = W2-HX(WS-I) AND SP-T-Z(1) = W2-HZ(WS-I) AND SP-T-ROT(1) = W2-HR(WS-I)
                AND SP-T-X(2) = W2-AX(WS-I) AND SP-T-Z(2) = W2-AZ(WS-I) AND SP-T-ROT(2) = W2-AR(WS-I)
                AND SP-T-X(3) = W2-BX(WS-I) AND SP-T-Z(3) = W2-BZ(WS-I) AND SP-T-ROT(3) = W2-BR(WS-I)
                 MOVE 1 TO WS-FLAG
             END-IF
         END-IF
         PERFORM CHECK
     END-PERFORM
     MOVE "test:start" TO SDT-JIG-POOL(1)
*>   the starts that cannot be built
     MOVE 0 TO SDT-JIG-SIZE(1)
     MOVE 9 TO WS-CX
     PERFORM NO-START
     MOVE "test struct jigsaw unit given a size of 0 when the start is built then there is no structure and no piece (9.7 step 1)" TO TL-CASE
     PERFORM CHECK-NONE
     MOVE 3 TO SDT-JIG-SIZE(1)
     MOVE 0 TO SDT-JIG-OK(1)
     PERFORM NO-START
     MOVE "test struct jigsaw unit given a structure that is not ok when the start is built then there is no structure" TO TL-CASE
     PERFORM CHECK-NONE
     MOVE 0 TO SDT-JIG-NAMED(1) SDT-JIG-PADSET(1) SDT-JIG-YKIND(1) SDT-JIG-AL-N(1)
     MOVE 1 TO SDT-JIG-OK(1)
     MOVE "test:missing" TO SDT-JIG-POOL(1)
     PERFORM NO-START
     MOVE "test struct jigsaw unit given a start pool that does not exist when the start is built then there is no structure" TO TL-CASE
     PERFORM CHECK-NONE
     MOVE "test:zero" TO SDT-JIG-POOL(1)
     PERFORM NO-START
     MOVE "test struct jigsaw unit given a start pool with no element when the start is built then there is no structure" TO TL-CASE
     PERFORM CHECK-NONE
     MOVE "test:onlyempty" TO SDT-JIG-POOL(1)
     PERFORM NO-START
     MOVE "test struct jigsaw unit given a start pool whose element is the empty one when the start is built then there is no structure" TO TL-CASE
     PERFORM CHECK-NONE
     MOVE 0 TO TJ-SURFACE.

 NO-START.
     ADD 1 TO WS-CX
     CALL "JIG-FIND-POINT" USING WS-ONE WS-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID.

 CHECK-NONE.
     MOVE 0 TO WS-FLAG
     IF WS-VALID = 0 AND SP-COUNT = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK.

*> the limits of the tables: a full table makes the pool absent, the element empty, or drops a list's sub-elements; the jigsaw records of the templates are emptied when they are getting full
 LIMIT-CASES.
     CALL "JIG-RESET"
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > JP-MAX
         MOVE SPACES TO JP-KEY(WS-I)
     END-PERFORM
     MOVE JP-MAX TO JP-COUNT
     MOVE "test:leaf" TO WS-KEY
     CALL "JIG-POOL-FIND" USING WS-KEY WS-ROW
     MOVE "test struct jigsaw unit given a full pool table when a pool is asked then there is none" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-ROW = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     CALL "JIG-RESET"
     MOVE JN-MAX TO JN-USED
     CALL "JIG-POOL-FIND" USING WS-KEY WS-ROW
     MOVE "test struct jigsaw unit given a full entry table when a pool is asked then there is none" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-ROW = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     CALL "JIG-RESET"
     MOVE JE-MAX TO JE-COUNT
     CALL "JIG-POOL-FIND" USING WS-KEY WS-ROW
     MOVE JN-ELEM(JP-FIRST(WS-ROW)) TO WS-EL
     MOVE "test struct jigsaw unit given a full element table when a pool is asked then its element is the shared empty one" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-EL = 1
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     CALL "JIG-RESET"
     MOVE JS-MAX TO JS-COUNT
     MOVE "test:mixed" TO WS-KEY
     CALL "JIG-POOL-FIND" USING WS-KEY WS-ROW
     MOVE JN-ELEM(JP-FIRST(WS-ROW) + 1) TO WS-EL
     MOVE "test struct jigsaw unit given a full sub-element table when a list is read then it has no sub-element" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF JE-KIND(WS-EL) = 3 AND JE-SUB-N(WS-EL) = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     CALL "JIG-RESET"
     MOVE "test:jhub" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-TPL-DIR WS-ID WS-ROW
     MOVE "test:jleaf" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-TPL-DIR WS-ID WS-ROW2
     CALL "JIG-TPL-JIGS" USING WS-ROW WS-I WS-J
     MOVE WS-J TO WS-SAVE
     CALL "JIG-TPL-JIGS" USING WS-ROW WS-I WS-J
     MOVE "test struct jigsaw unit given a template whose jigsaws were found when they are asked again then they are the same run" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-J = WS-SAVE AND WS-SAVE = 4 AND JX-COUNT = 4
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     COMPUTE JX-COUNT = JX-MAX - 5
     CALL "JIG-TPL-JIGS" USING WS-ROW2 WS-I WS-J
     MOVE "test struct jigsaw unit given a nearly full record table when another template's jigsaws are asked then the table is emptied first and the first template's are forgotten" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF JX-COUNT = 1 AND WS-J = 1 AND JT-KEY(WS-ROW) = SPACES
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK.
 END PROGRAM TEST-STRUCT-JIGSAW-UNIT.

 COPY JIGSEAM.

 COPY CORETEST.
