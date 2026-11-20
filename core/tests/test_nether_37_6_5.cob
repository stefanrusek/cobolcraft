*> Test of the bastion remnant's variants (core/src/nether-37-6d.cob; T1709; docs/protocol/37-nether-6 section 5): the four variants with their closures counted on the generated data
*> (CC_GENERATED_DIR, skipped as a pass without it): the start pool, the pools and templates reached from each start template by following every jigsaw block's pool and every pool's elements, the
*> shared pools and the totals, against the doc's table; the degradation rules of bastion_generic_degradation read through the processor loader against the doc's example.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NETHER-37-6-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY STRUCTDATA.
 COPY STRUCTTPL.
 COPY STRUCTJIG.
 COPY STRUCTPROC.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-V                   BINARY-LONG.
 01 WS-EXPECT              BINARY-LONG.
 01 WS-CASE                PIC X(200).
 01 WS-VARIANT             BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-NAME                PIC X(48).
 01 WS-LEN                 BINARY-LONG.
 01 WS-OUT                 PIC X(48).
 01 WS-PROB                BINARY-LONG.
 01 WS-REACHED             BINARY-LONG.
 01 WS-SHARED              BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-ROW                 BINARY-LONG.
 01 WS-EL                  BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-TAG                 BINARY-LONG.
 01 WS-POOL-N              BINARY-LONG.
 01 WS-TPL-N               BINARY-LONG.
 01 WS-HEAD                BINARY-LONG.
 01 WS-TPL-ROW             BINARY-LONG.
 01 WS-NEW                 PIC X(96).
 01 WS-FOUND               BINARY-LONG.
 01 WS-POOLS.
    05 WS-POOL             PIC X(80) OCCURS 64 TIMES.
 01 WS-TPLS.
    05 WS-TPL              PIC X(96) OCCURS 128 TIMES.
 01 WS-SHARED-KEYS.
    05 FILLER              PIC X(80) VALUE "minecraft:bastion/blocks/gold".
    05 FILLER              PIC X(80) VALUE "minecraft:bastion/mobs/piglin".
    05 FILLER              PIC X(80) VALUE "minecraft:bastion/mobs/piglin_melee".
    05 FILLER              PIC X(80) VALUE "minecraft:bastion/mobs/hoglin".
 01 WS-SHARED-T REDEFINES WS-SHARED-KEYS.
    05 WS-SHARED-KEY       PIC X(80) OCCURS 4 TIMES.
 01 WS-TJ                 BINARY-LONG.
 01 WS-TK                 BINARY-LONG.
 01 WS-PK                 BINARY-LONG.
 01 WS-QJ                 BINARY-LONG.
 01 WS-QK                 BINARY-LONG.
 01 WS-AK                 BINARY-LONG.
 01 WS-TEST                BINARY-LONG.
 01 WS-BLK                 BINARY-LONG.
 01 WS-ST                  BINARY-LONG.
 01 WS-SJ                 BINARY-LONG.
 01 WS-SK                 BINARY-LONG.
 01 WS-SUBEL              BINARY-LONG.
 01 WS-FULL               PIC X(96).
 01 WS-DV                 PIC 9.
 01 WS-DC                 PIC 9.
 01 WS-DI                 PIC 99.
 01 WS-DJ                 PIC 99.
 01 WS-DOC-IN             PIC X(40).
 01 WS-DOC-OUT            PIC X(40).
 01 WS-INT                 BINARY-LONG.
 01 WS-SCALED              BINARY-LONG.
 01 WS-FL                  FLOAT-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     PERFORM TABLE-CASES
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "acceptance US12 37-6§5 The bastion remnant: four variants as pool graphs: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "GEN-WORLD-SETUP"
     PERFORM START-POOL-CASES
     PERFORM CLOSURE-CASES
     PERFORM PROCESSOR-CASES
     STOP RUN.

 CHECK-V.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 37-6§5 The bastion remnant: four variants as pool graphs: " FUNCTION TRIM(WS-CASE) DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 37-6§5 The bastion remnant: four variants as pool graphs: " FUNCTION TRIM(WS-CASE) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE.

*> the doc's tables: pools, templates and own-family pools per variant (own plus the shared pools it reaches is the closure's pool count), the start templates, the shared-pool matrix, the totals
 TABLE-CASES.
     PERFORM VARYING WS-VARIANT FROM 1 BY 1 UNTIL WS-VARIANT > 4
         MOVE 1 TO WS-CODE
         CALL "NETHER-BASTION-VARIANT" USING WS-VARIANT WS-CODE WS-V
         EVALUATE WS-VARIANT
             WHEN 1 MOVE 18 TO WS-EXPECT
             WHEN 2 MOVE 17 TO WS-EXPECT
             WHEN 3 MOVE 22 TO WS-EXPECT
             WHEN 4 MOVE 10 TO WS-EXPECT
         END-EVALUATE
         MOVE SPACES TO WS-CASE
         MOVE WS-VARIANT TO WS-DV
         STRING "variant " WS-DV " pools in the closure" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-V
         MOVE 2 TO WS-CODE
         CALL "NETHER-BASTION-VARIANT" USING WS-VARIANT WS-CODE WS-V
         EVALUATE WS-VARIANT
             WHEN 1 MOVE 38 TO WS-EXPECT
             WHEN 2 MOVE 62 TO WS-EXPECT
             WHEN 3 MOVE 66 TO WS-EXPECT
             WHEN 4 MOVE 19 TO WS-EXPECT
         END-EVALUATE
         MOVE SPACES TO WS-CASE
         MOVE WS-VARIANT TO WS-DV
         STRING "variant " WS-DV " templates in the closure" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-V
         MOVE 3 TO WS-CODE
         CALL "NETHER-BASTION-VARIANT" USING WS-VARIANT WS-CODE WS-V
         EVALUATE WS-VARIANT
             WHEN 1 MOVE 15 TO WS-EXPECT
             WHEN 2 MOVE 13 TO WS-EXPECT
             WHEN 3 MOVE 20 TO WS-EXPECT
             WHEN 4 MOVE 7 TO WS-EXPECT
         END-EVALUATE
         MOVE SPACES TO WS-CASE
         MOVE WS-VARIANT TO WS-DV
         STRING "variant " WS-DV " pools of its own family" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-V
*>       own pools plus the shared pools it reaches are the pools of the closure
         MOVE 0 TO WS-N
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
             CALL "NETHER-BASTION-SHARED" USING WS-I WS-VARIANT WS-REACHED
             ADD WS-REACHED TO WS-N
         END-PERFORM
         MOVE 1 TO WS-CODE
         CALL "NETHER-BASTION-VARIANT" USING WS-VARIANT WS-CODE WS-V
         COMPUTE WS-V = WS-V - WS-N
         MOVE 3 TO WS-CODE
         CALL "NETHER-BASTION-VARIANT" USING WS-VARIANT WS-CODE WS-EXPECT
         MOVE SPACES TO WS-CASE
         MOVE WS-VARIANT TO WS-DV
         STRING "variant " WS-DV " closure pools less its shared pools are its own family" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-V
     END-PERFORM
     MOVE 1 TO WS-VARIANT
     MOVE 1 TO WS-I
     CALL "NETHER-BASTION-SHARED" USING WS-I WS-VARIANT WS-V
     MOVE 1 TO WS-EXPECT
     MOVE "blocks/gold is reached by the housing units" TO WS-CASE
     PERFORM CHECK-V
     MOVE 2 TO WS-VARIANT
     CALL "NETHER-BASTION-SHARED" USING WS-I WS-VARIANT WS-V
     MOVE "blocks/gold is reached by the hoglin stable" TO WS-CASE
     PERFORM CHECK-V
     MOVE 3 TO WS-VARIANT
     CALL "NETHER-BASTION-SHARED" USING WS-I WS-VARIANT WS-V
     MOVE 0 TO WS-EXPECT
     MOVE "blocks/gold is not reached by the treasure room" TO WS-CASE
     PERFORM CHECK-V
     MOVE 4 TO WS-VARIANT
     CALL "NETHER-BASTION-SHARED" USING WS-I WS-VARIANT WS-V
     MOVE "blocks/gold is not reached by the bridge" TO WS-CASE
     PERFORM CHECK-V
     MOVE 2 TO WS-I
     PERFORM VARYING WS-VARIANT FROM 1 BY 1 UNTIL WS-VARIANT > 4
         CALL "NETHER-BASTION-SHARED" USING WS-I WS-VARIANT WS-V
         MOVE 1 TO WS-EXPECT
         MOVE "mobs/piglin is reached by all four variants" TO WS-CASE
         PERFORM CHECK-V
     END-PERFORM
     MOVE 3 TO WS-I
     PERFORM VARYING WS-VARIANT FROM 1 BY 1 UNTIL WS-VARIANT > 4
         CALL "NETHER-BASTION-SHARED" USING WS-I WS-VARIANT WS-V
         MOVE "mobs/piglin_melee is reached by all four variants" TO WS-CASE
         PERFORM CHECK-V
     END-PERFORM
     MOVE 4 TO WS-I
     MOVE 1 TO WS-VARIANT
     CALL "NETHER-BASTION-SHARED" USING WS-I WS-VARIANT WS-V
     MOVE 0 TO WS-EXPECT
     MOVE "mobs/hoglin is not reached by the housing units" TO WS-CASE
     PERFORM CHECK-V
     MOVE 2 TO WS-VARIANT
     CALL "NETHER-BASTION-SHARED" USING WS-I WS-VARIANT WS-V
     MOVE 1 TO WS-EXPECT
     MOVE "mobs/hoglin is reached by the hoglin stable" TO WS-CASE
     PERFORM CHECK-V
     MOVE 3 TO WS-VARIANT
     CALL "NETHER-BASTION-SHARED" USING WS-I WS-VARIANT WS-V
     MOVE 0 TO WS-EXPECT
     MOVE "mobs/hoglin is not reached by the treasure room" TO WS-CASE
     PERFORM CHECK-V
     MOVE 4 TO WS-VARIANT
     CALL "NETHER-BASTION-SHARED" USING WS-I WS-VARIANT WS-V
     MOVE 1 TO WS-EXPECT
     MOVE "mobs/hoglin is reached by the bridge" TO WS-CASE
     PERFORM CHECK-V
     MOVE 1 TO WS-VARIANT
     MOVE 9 TO WS-I
     CALL "NETHER-BASTION-SHARED" USING WS-I WS-VARIANT WS-V
     MOVE 0 TO WS-EXPECT
     MOVE "an unknown shared pool is reached by none" TO WS-CASE
     PERFORM CHECK-V
     MOVE 9 TO WS-VARIANT
     MOVE 1 TO WS-CODE
     CALL "NETHER-BASTION-VARIANT" USING WS-VARIANT WS-CODE WS-V
     MOVE -1 TO WS-EXPECT
     MOVE "an unknown variant has no counts (-1)" TO WS-CASE
     PERFORM CHECK-V
     MOVE 1 TO WS-VARIANT
     MOVE 9 TO WS-CODE
     CALL "NETHER-BASTION-VARIANT" USING WS-VARIANT WS-CODE WS-V
     MOVE "an unknown count code gives -1" TO WS-CASE
     PERFORM CHECK-V
     PERFORM VARYING WS-VARIANT FROM 1 BY 1 UNTIL WS-VARIANT > 4
         CALL "NETHER-BASTION-START-TEMPLATE" USING WS-VARIANT WS-NAME WS-LEN
         MOVE SPACES TO TL-OBSERVED TL-EXPECTED
         MOVE WS-NAME(1:WS-LEN) TO TL-OBSERVED
         EVALUATE WS-VARIANT
             WHEN 1 MOVE "bastion/units/air_base" TO TL-EXPECTED
             WHEN 2 MOVE "bastion/hoglin_stable/air_base" TO TL-EXPECTED
             WHEN 3 MOVE "bastion/treasure/big_air_full" TO TL-EXPECTED
             WHEN 4 MOVE "bastion/bridge/starting_pieces/entrance_base" TO TL-EXPECTED
         END-EVALUATE
         MOVE WS-VARIANT TO WS-DV
         MOVE SPACES TO WS-CASE
         STRING "variant " WS-DV " start template" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-TEXT
     END-PERFORM
     MOVE 5 TO WS-VARIANT
     CALL "NETHER-BASTION-START-TEMPLATE" USING WS-VARIANT WS-NAME WS-LEN
     MOVE WS-LEN TO WS-V
     MOVE 0 TO WS-EXPECT
     MOVE "an unknown variant has no start template (length 0)" TO WS-CASE
     PERFORM CHECK-V
     PERFORM VARYING WS-CODE FROM 1 BY 1 UNTIL WS-CODE > 7
         CALL "NETHER-BASTION-TOTAL" USING WS-CODE WS-V
         EVALUATE WS-CODE
             WHEN 1 MOVE 4 TO WS-EXPECT
             WHEN 2 MOVE 1 TO WS-EXPECT
             WHEN 3 MOVE 60 TO WS-EXPECT
             WHEN 4 MOVE 167 TO WS-EXPECT
             WHEN 5 MOVE 11 TO WS-EXPECT
             WHEN 6 MOVE 4 TO WS-EXPECT
             WHEN 7 MOVE -1 TO WS-EXPECT
         END-EVALUATE
         MOVE SPACES TO WS-CASE
         MOVE WS-CODE TO WS-DC
         STRING "total " WS-DC " (start pool elements, their weight, template pool files, structure NBT files, processor lists, chest loot tables)" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-V
     END-PERFORM.

*> the start pool of the generated data: four single elements of weight 1 with the generic degradation list and rigid projection
 START-POOL-CASES.
     CALL "JIG-RESET"
     MOVE "minecraft:bastion/starts" TO WS-KEY
     CALL "JIG-POOL-FIND" USING WS-KEY WS-ROW
     MOVE JP-N(WS-ROW) TO WS-V
     MOVE 4 TO WS-EXPECT
     MOVE "the pool bastion/starts has four elements" TO WS-CASE
     PERFORM CHECK-V
     MOVE JP-TOTAL(WS-ROW) TO WS-V
     MOVE "its expanded list holds four entries: the weights are 1 each, so the draw is uniform" TO WS-CASE
     PERFORM CHECK-V
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > JP-N(WS-ROW)
         COMPUTE WS-J = JP-FIRST(WS-ROW) + WS-I - 1
         MOVE JN-ELEM(WS-J) TO WS-EL
         IF JN-WEIGHT(WS-J) = 1 AND JE-KIND(WS-EL) = 1 AND JE-PROJ(WS-EL) = 0 AND JE-PROC(WS-EL) = "minecraft:bastion_generic_degradation"
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE WS-N TO WS-V
     MOVE "every element is a single_pool_element of weight 1, rigid, with bastion_generic_degradation" TO WS-CASE
     PERFORM CHECK-V
*>   the four start templates are the doc's
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         CALL "NETHER-BASTION-START-TEMPLATE" USING WS-I WS-NAME WS-LEN
         MOVE SPACES TO WS-FULL
         STRING "minecraft:" WS-NAME(1:WS-LEN) DELIMITED BY SIZE INTO WS-FULL
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > JP-N(WS-ROW)
             COMPUTE WS-K = JP-FIRST(WS-ROW) + WS-J - 1
             MOVE JN-ELEM(WS-K) TO WS-EL
             IF JE-LOC(WS-EL) = WS-FULL
                 ADD 1 TO WS-N
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE WS-N TO WS-V
     MOVE "the elements are the four start templates of the doc, one each" TO WS-CASE
     PERFORM CHECK-V.

*> closure of each variant from its start template: the templates, and the pools named by their jigsaw blocks and the elements of those pools
 CLOSURE-CASES.
     PERFORM VARYING WS-VARIANT FROM 1 BY 1 UNTIL WS-VARIANT > 4
         CALL "JIG-RESET"
         CALL "STRUCT-TPL-RESET"
         CALL "NETHER-BASTION-START-TEMPLATE" USING WS-VARIANT WS-NAME WS-LEN
         MOVE 1 TO WS-TPL-N
         MOVE SPACES TO WS-TPL(1)
         STRING "minecraft:" WS-NAME(1:WS-LEN) DELIMITED BY SIZE INTO WS-TPL(1)
         MOVE 0 TO WS-POOL-N
         MOVE 1 TO WS-HEAD
         MOVE 1 TO WS-I
         PERFORM UNTIL WS-HEAD > WS-TPL-N AND WS-I > WS-POOL-N
             PERFORM UNTIL WS-HEAD > WS-TPL-N
                 MOVE WS-TPL(WS-HEAD) TO WS-NEW
                 PERFORM TEMPLATE-POOLS
                 ADD 1 TO WS-HEAD
             END-PERFORM
             PERFORM UNTIL WS-I > WS-POOL-N
                 PERFORM POOL-TEMPLATES
                 ADD 1 TO WS-I
             END-PERFORM
         END-PERFORM
         MOVE WS-POOL-N TO WS-V
         MOVE 1 TO WS-CODE
         CALL "NETHER-BASTION-VARIANT" USING WS-VARIANT WS-CODE WS-EXPECT
         MOVE SPACES TO WS-CASE
         MOVE WS-VARIANT TO WS-DV
         STRING "variant " WS-DV " the pools reached on the data equal the doc's count" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-V
         MOVE WS-TPL-N TO WS-V
         MOVE 2 TO WS-CODE
         CALL "NETHER-BASTION-VARIANT" USING WS-VARIANT WS-CODE WS-EXPECT
         MOVE SPACES TO WS-CASE
         MOVE WS-VARIANT TO WS-DV
         STRING "variant " WS-DV " the templates reached on the data equal the doc's count" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-V
*>       the shared pools reached are the doc's matrix
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 4
             MOVE 0 TO WS-V
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-POOL-N
                 IF WS-POOL(WS-K) = WS-SHARED-KEY(WS-J)
                     MOVE 1 TO WS-V
                 END-IF
             END-PERFORM
             CALL "NETHER-BASTION-SHARED" USING WS-J WS-VARIANT WS-EXPECT
             MOVE SPACES TO WS-CASE
             MOVE WS-VARIANT TO WS-DV
             MOVE WS-J TO WS-DJ
             STRING "variant " WS-DV " shared pool " WS-DJ " reached on the data as in the doc's matrix" DELIMITED BY SIZE INTO WS-CASE
             PERFORM CHECK-V
         END-PERFORM
     END-PERFORM.

 TEMPLATE-POOLS.
     CALL "STRUCT-TPL-LOAD" USING SD-DIR WS-NEW WS-TPL-ROW
     IF WS-TPL-ROW > 0
         CALL "JIG-TPL-JIGS" USING WS-TPL-ROW WS-FIRST WS-COUNT
         PERFORM VARYING WS-TJ FROM 1 BY 1 UNTIL WS-TJ > WS-COUNT
             COMPUTE WS-TK = WS-FIRST + WS-TJ - 1
             MOVE JX-TAG(WS-TK) TO WS-TAG
             MOVE SPACES TO WS-KEY
             MOVE TN-POOL(WS-TAG) TO WS-KEY
             IF WS-KEY(1:10) NOT = "minecraft:"
                 MOVE SPACES TO WS-KEY
                 STRING "minecraft:" FUNCTION TRIM(TN-POOL(WS-TAG)) DELIMITED BY SIZE INTO WS-KEY
             END-IF
             PERFORM POOL-ADD
         END-PERFORM
     END-IF.

 POOL-ADD.
     IF WS-KEY NOT = "minecraft:empty"
         MOVE 0 TO WS-FOUND
         PERFORM VARYING WS-PK FROM 1 BY 1 UNTIL WS-PK > WS-POOL-N
             IF WS-POOL(WS-PK) = WS-KEY
                 MOVE 1 TO WS-FOUND
             END-IF
         END-PERFORM
         IF WS-FOUND = 0
             ADD 1 TO WS-POOL-N
             MOVE WS-KEY TO WS-POOL(WS-POOL-N)
         END-IF
     END-IF.

 POOL-TEMPLATES.
     MOVE WS-POOL(WS-I) TO WS-KEY
     CALL "JIG-POOL-FIND" USING WS-KEY WS-ROW
     IF WS-ROW > 1
         PERFORM VARYING WS-QJ FROM 1 BY 1 UNTIL WS-QJ > JP-N(WS-ROW)
             COMPUTE WS-QK = JP-FIRST(WS-ROW) + WS-QJ - 1
             MOVE JN-ELEM(WS-QK) TO WS-EL
             IF JE-KIND(WS-EL) = 1 OR JE-KIND(WS-EL) = 2
                 MOVE JE-LOC(WS-EL) TO WS-NEW
                 PERFORM TPL-ADD
             END-IF
             IF JE-KIND(WS-EL) = 3
                 PERFORM VARYING WS-SJ FROM 1 BY 1 UNTIL WS-SJ > JE-SUB-N(WS-EL)
                     COMPUTE WS-SK = JE-SUB-FIRST(WS-EL) + WS-SJ - 1
                     MOVE JS-ELEM(WS-SK) TO WS-SUBEL
                     IF JE-KIND(WS-SUBEL) = 1 OR JE-KIND(WS-SUBEL) = 2
                         MOVE JE-LOC(WS-SUBEL) TO WS-NEW
                         PERFORM TPL-ADD
                     END-IF
                 END-PERFORM
             END-IF
         END-PERFORM
     END-IF.

 TPL-ADD.
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-AK FROM 1 BY 1 UNTIL WS-AK > WS-TPL-N
         IF WS-TPL(WS-AK) = WS-NEW
             MOVE 1 TO WS-FOUND
         END-IF
     END-PERFORM
     IF WS-FOUND = 0
         ADD 1 TO WS-TPL-N
         MOVE WS-NEW TO WS-TPL(WS-TPL-N)
     END-IF.

*> bastion_generic_degradation through the loader: one rule processor of five random_block_match rules, the doc's example
 PROCESSOR-CASES.
     MOVE "minecraft:bastion_generic_degradation" TO WS-KEY
     CALL "STRUCT-PROC-LOAD" USING WS-KEY WS-ROW
     MOVE SPL-N(WS-ROW) TO WS-V
     MOVE 1 TO WS-EXPECT
     MOVE "bastion_generic_degradation holds one processor" TO WS-CASE
     PERFORM CHECK-V
     MOVE SPP-TYPE(SPL-FIRST(WS-ROW)) TO WS-V
     MOVE "it is a rule processor" TO WS-CASE
     PERFORM CHECK-V
     MOVE SPP-N(SPL-FIRST(WS-ROW)) TO WS-V
     MOVE 5 TO WS-EXPECT
     MOVE "it has five rules" TO WS-CASE
     PERFORM CHECK-V
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         COMPUTE WS-J = SPP-A(SPL-FIRST(WS-ROW)) + WS-I - 1
         MOVE SPT-TYPE(SPR-IN(WS-J)) TO WS-V
         MOVE 5 TO WS-EXPECT
         MOVE SPACES TO WS-CASE
         MOVE WS-I TO WS-DI
         STRING "rule " WS-DI " input is a random_block_match" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-V
         MOVE SPT-TYPE(SPR-LOC(WS-J)) TO WS-V
         MOVE 1 TO WS-EXPECT
         MOVE SPACES TO WS-CASE
         MOVE WS-I TO WS-DI
         STRING "rule " WS-DI " location test is always_true" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-V
         MOVE SPACES TO WS-NAME WS-OUT
         MOVE SPR-IN(WS-J) TO WS-TEST
         MOVE SPT-A(WS-TEST) TO WS-BLK
         MOVE CB-KEY(WS-BLK) TO WS-NAME
         MOVE SPR-STATE(WS-J) TO WS-ST
         IF WS-ST = 0
             MOVE "air" TO WS-OUT
         ELSE
             COMPUTE WS-BLK = CB-S-BLOCK(WS-ST + 1) + 1
             MOVE CB-KEY(WS-BLK) TO WS-OUT
         END-IF
         COMPUTE WS-FL = SPT-F(WS-TEST) * 1000000 + 0.5
         COMPUTE WS-SCALED = FUNCTION INTEGER(WS-FL)
         MOVE WS-I TO WS-INT
         CALL "NETHER-BASTION-DEGRADE" USING WS-INT WS-DOC-IN WS-DOC-OUT WS-PROB
         MOVE SPACES TO TL-EXPECTED TL-OBSERVED
         MOVE WS-DOC-IN TO TL-EXPECTED
         MOVE WS-NAME TO TL-OBSERVED
         MOVE SPACES TO WS-CASE
         MOVE WS-I TO WS-DI
         STRING "rule " WS-DI " replaces the block of the doc's example" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-TEXT
         MOVE SPACES TO TL-EXPECTED TL-OBSERVED
         MOVE WS-DOC-OUT TO TL-EXPECTED
         MOVE WS-OUT TO TL-OBSERVED
         MOVE SPACES TO WS-CASE
         MOVE WS-I TO WS-DI
         STRING "rule " WS-DI " gives the block of the doc's example" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-TEXT
         MOVE WS-PROB TO WS-EXPECT
         MOVE WS-SCALED TO WS-V
         MOVE SPACES TO WS-CASE
         MOVE WS-I TO WS-DI
         STRING "rule " WS-DI " probability in millionths" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-V
     END-PERFORM
     MOVE 9 TO WS-INT
     CALL "NETHER-BASTION-DEGRADE" USING WS-INT WS-DOC-IN WS-DOC-OUT WS-PROB
     MOVE WS-PROB TO WS-V
     MOVE -1 TO WS-EXPECT
     MOVE "a rule index beyond the five has no probability (-1)" TO WS-CASE
     PERFORM CHECK-V.
 END PROGRAM TEST-NETHER-37-6-5.
 COPY NOSPAWN.
 COPY CORETEST.
