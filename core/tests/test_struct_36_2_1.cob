*> Acceptance test of docs/protocol/36-structures-2 sections 1 and 2 (the structure template and its loading): the file schema read from hand-built gzip NBT
*> (core/tests/fixtures/gen_tpl.py), the block states of a palette (defaults, properties applied by name and value, unknown ids), the placement order of 1.3 (full
*> cubes, others, records with block entity data; each group by y, x, z), the palettes forms, entity records with nbt counted, the path of 2.1 and the cache of 2.3.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-2-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY STRUCTTPL.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/tpl".
 01 WS-MISSING             PIC X(1100) VALUE "core/tests/fixtures/no-such-folder".
 01 WS-CONTENT-DIR         PIC X(1100) VALUE SPACES.
 01 WS-TYPE                BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-ID                  PIC X(96).
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROW2                BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(600).
 01 WS-STATE               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-A                   PIC -(5)9.
 01 WS-B                   PIC -(5)9.
 01 WS-C                   PIC -(5)9.
 01 WS-D                   PIC -(5)9.
 01 WS-PTR                 BINARY-LONG.
 01 WS-SAVED               BINARY-LONG.
 01 WS-ID-G                PIC -(5)9.
 PROCEDURE DIVISION.
     MOVE CT-TYPE-COBOLCRAFT TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-CONTENT-DIR WS-STATUS
     CALL "BLOCKS-OPEN"
     CALL "STRUCT-TPL-RESET"

     MOVE "T" TO TL-MODE
     MOVE "tiny" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-DIR WS-ID WS-ROW
     MOVE "acceptance US12 36-2§1 The structure template: tiny loads with size (3,2,2), 1 palette, 6 blocks, 1 entity with nbt (the record without nbt is dropped)" TO TL-CASE
     PERFORM SHOW-HEAD
     MOVE "1 3 2 2 1 6 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-2§1 The structure template: placement order is full cubes (solid, lucite included), others (air), then block entity records, each by y, x, z (example 11.3)" TO TL-CASE
     MOVE 1 TO WS-P
     PERFORM SHOW-ORDER
     MOVE "0,0,0 1,0,0 0,1,0 1,1,1 0,0,1 2,0,1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-2§1 The structure template: the state of a record is the palette's state; an index with no mapping is air (state 0); properties set by name" TO TL-CASE
     MOVE 1 TO WS-P
     PERFORM SHOW-STATES
     MOVE SPACES TO TL-EXPECTED
     MOVE 1 TO WS-PTR
     MOVE "cobolcraft:greystone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     MOVE WS-STATE TO WS-A
     MOVE "cobolcraft:cardstack" TO WS-KEY
     MOVE "axis=z,punched=true" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     MOVE WS-STATE TO WS-B
     MOVE "cobolcraft:lucite" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     MOVE WS-STATE TO WS-C
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) " " FUNCTION TRIM(WS-A) " 0 " FUNCTION TRIM(WS-A)
         DELIMITED BY SIZE INTO TL-EXPECTED WITH POINTER WS-PTR
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-2§1 The structure template: the nbt tag row (2: row 1 is the empty tag) marks only the record with nbt" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE TB-NBT(TP-BASE(WS-ROW, 1) + WS-I) TO WS-A
         STRING FUNCTION TRIM(WS-A) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-PERFORM
     MOVE "000002" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "multi" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-DIR WS-ID WS-ROW
     MOVE "acceptance US12 36-2§1 Palettes and block order: palettes present means palette is ignored; two palettes, each its own list" TO TL-CASE
     PERFORM SHOW-HEAD
     MOVE "1 2 1 1 2 2 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-2§1 Palettes and block order: palette 1 holds greystone, cardstack-block-index mapped by state index (greystone, lucite)" TO TL-CASE
     MOVE 1 TO WS-P
     PERFORM SHOW-STATES
     MOVE "cobolcraft:greystone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     MOVE WS-STATE TO WS-A
     MOVE "cobolcraft:lucite" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     MOVE WS-STATE TO WS-B
     MOVE SPACES TO TL-EXPECTED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-2§1 Palettes and block order: palette 2 maps the same records to the other states" TO TL-CASE
     MOVE 2 TO WS-P
     PERFORM SHOW-STATES
     MOVE SPACES TO TL-EXPECTED
     STRING FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-A) DELIMITED BY SIZE INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "props" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-DIR WS-ID WS-ROW
     MOVE "acceptance US12 36-2§1 The structure template: properties by name: partial set keeps defaults, bad name or value and a property on a propertyless block skipped, odd tags ignored, no id or unknown id is air" TO TL-CASE
     MOVE 1 TO WS-P
     PERFORM SHOW-STATES
     MOVE "cobolcraft:cardstack" TO WS-KEY
     MOVE "axis=y,punched=true" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     MOVE WS-STATE TO WS-A
     MOVE "axis=x,punched=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     MOVE WS-STATE TO WS-B
     MOVE "axis=y,punched=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     MOVE WS-STATE TO WS-C
     MOVE SPACES TO TL-EXPECTED
     MOVE "axis=x,punched=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     MOVE WS-STATE TO WS-D
     MOVE "cobolcraft:greystone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     MOVE WS-STATE TO WS-ID-G
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) " " FUNCTION TRIM(WS-ID-G) " " FUNCTION TRIM(WS-D) " 0 0"
         DELIMITED BY SIZE INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 36-2§2 Finding, loading, saving: the path is data/<namespace>/structure/<path>.nbt, a path may hold folders" TO TL-CASE
     MOVE "sub/deep" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-DIR WS-ID WS-ROW
     PERFORM SHOW-HEAD
     MOVE "1 1 1 1 1 1 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-2§2 Finding, loading, saving: another namespace is read from its own folder; an empty block list is a template with no blocks" TO TL-CASE
     MOVE "cobolcraft:other" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-DIR WS-ID WS-ROW
     PERFORM SHOW-HEAD
     MOVE "1 1 1 1 1 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-2§1 The structure template: a size list with a missing element reads 0 for it" TO TL-CASE
     MOVE "short" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-DIR WS-ID WS-ROW
     PERFORM SHOW-HEAD
     MOVE "1 2 3 0 1 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 36-2§2 Finding, loading, saving: a missing id is absent (status 2) and a second get finds the same cache row" TO TL-CASE
     MOVE "nothing/here" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-DIR WS-ID WS-ROW
     CALL "STRUCT-TPL-LOAD" USING WS-DIR WS-ID WS-ROW2
     MOVE SPACES TO TL-OBSERVED
     MOVE TP-STATUS(WS-ROW) TO WS-A
     IF WS-ROW = WS-ROW2
         STRING FUNCTION TRIM(WS-A) " same" DELIMITED BY SIZE INTO TL-OBSERVED
     ELSE
         STRING FUNCTION TRIM(WS-A) " different" DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     MOVE "2 same" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-2§2 Finding, loading, saving: a loaded template found again by its id with and without minecraft:" TO TL-CASE
     MOVE "tiny" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-DIR WS-ID WS-ROW
     MOVE "minecraft:tiny" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-DIR WS-ID WS-ROW2
     MOVE "N" TO TL-MODE
     COMPUTE TL-OBSERVED-N = WS-ROW - WS-ROW2
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 36-2§2 Finding, loading, saving: a file that is not NBT is absent (an unreadable source is skipped)" TO TL-CASE
     MOVE "notnbt" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-DIR WS-ID WS-ROW
     MOVE TP-STATUS(WS-ROW) TO WS-A
     MOVE FUNCTION TRIM(WS-A) TO TL-OBSERVED
     MOVE "2" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-2§2 Finding, loading, saving: a folder with no data is empty, every id is absent" TO TL-CASE
     MOVE "tiny" TO WS-ID
     CALL "STRUCT-TPL-RESET"
     CALL "STRUCT-TPL-LOAD" USING WS-MISSING WS-ID WS-ROW
     MOVE TP-STATUS(WS-ROW) TO WS-A
     MOVE FUNCTION TRIM(WS-A) TO TL-OBSERVED
     MOVE "2" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-2§2 Finding, loading, saving: an empty id gives no row" TO TL-CASE
     MOVE SPACES TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-DIR WS-ID WS-ROW
     MOVE WS-ROW TO WS-A
     MOVE FUNCTION TRIM(WS-A) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Unsupported: limits of this implementation (status 3).
     CALL "STRUCT-TPL-RESET"
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         EVALUATE WS-I
             WHEN 1 MOVE "outside" TO WS-ID
             WHEN 2 MOVE "negative" TO WS-ID
             WHEN 3 MOVE "huge" TO WS-ID
             WHEN 4 MOVE "negsize" TO WS-ID
             WHEN 5 MOVE "sizestr" TO WS-ID
             WHEN 6 MOVE "posstr" TO WS-ID
             WHEN 7 MOVE "manypal" TO WS-ID
             WHEN 8 MOVE "manyblocks" TO WS-ID
             WHEN OTHER MOVE "bigpal" TO WS-ID
         END-EVALUATE
         CALL "STRUCT-TPL-LOAD" USING WS-DIR WS-ID WS-ROW
         MOVE TP-STATUS(WS-ROW) TO WS-A
         STRING FUNCTION TRIM(WS-A) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-PERFORM
     MOVE "acceptance US12 36-2§1 The structure template: a record outside the size, a size over the grid limit or negative, a size or pos that is not a list of ints, too many palettes, states or records are unsupported (status 3)" TO TL-CASE
     MOVE "333333333" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-2§1 The structure template: a file with no blocks and no palette still loads (status 1, no palettes)" TO TL-CASE
     MOVE "empty" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-DIR WS-ID WS-ROW
     PERFORM SHOW-HEAD
     MOVE "1 1 1 1 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 36-2§2 Finding, loading, saving: when the record pool cannot hold the template it is unsupported" TO TL-CASE
     CALL "STRUCT-TPL-RESET"
     MOVE TP-POOL TO TP-USED
     MOVE "tiny" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-DIR WS-ID WS-ROW
     MOVE TP-STATUS(WS-ROW) TO WS-A
     MOVE FUNCTION TRIM(WS-A) TO TL-OBSERVED
     MOVE "3" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-2§2 Finding, loading, saving: a full cache gives no row for a new id" TO TL-CASE
     CALL "STRUCT-TPL-RESET"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TP-MAX-TEMPLATES
         MOVE SPACES TO WS-ID
         MOVE WS-I TO WS-A
         STRING "fill/" FUNCTION TRIM(WS-A) DELIMITED BY SIZE INTO WS-ID
         CALL "STRUCT-TPL-LOAD" USING WS-DIR WS-ID WS-ROW
     END-PERFORM
     MOVE "tiny" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-DIR WS-ID WS-ROW
     MOVE WS-ROW TO WS-A
     MOVE FUNCTION TRIM(WS-A) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "STRUCT-TPL-RESET"
     GOBACK.

 SHOW-HEAD.
     MOVE TP-STATUS(WS-ROW) TO WS-A
     MOVE TP-SX(WS-ROW) TO WS-B
     MOVE TP-SY(WS-ROW) TO WS-C
     MOVE TP-SZ(WS-ROW) TO WS-D
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) " " FUNCTION TRIM(WS-D) " " DELIMITED BY SIZE
         INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE TP-PALETTES(WS-ROW) TO WS-A
     MOVE TP-BLOCKS(WS-ROW) TO WS-B
     MOVE TP-ENTITIES(WS-ROW) TO WS-C
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) DELIMITED BY SIZE
         INTO TL-OBSERVED WITH POINTER WS-PTR.

 SHOW-ORDER.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TP-BLOCKS(WS-ROW)
         MOVE TB-X(TP-BASE(WS-ROW, WS-P) + WS-I) TO WS-A
         MOVE TB-Y(TP-BASE(WS-ROW, WS-P) + WS-I) TO WS-B
         MOVE TB-Z(TP-BASE(WS-ROW, WS-P) + WS-I) TO WS-C
         IF WS-I > 1
             STRING " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
         STRING FUNCTION TRIM(WS-A) "," FUNCTION TRIM(WS-B) "," FUNCTION TRIM(WS-C) DELIMITED BY SIZE
             INTO TL-OBSERVED WITH POINTER WS-PTR
     END-PERFORM.

 SHOW-STATES.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TP-BLOCKS(WS-ROW)
         MOVE TB-STATE(TP-BASE(WS-ROW, WS-P) + WS-I) TO WS-A
         IF WS-I > 1
             STRING " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
         STRING FUNCTION TRIM(WS-A) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-PERFORM.
