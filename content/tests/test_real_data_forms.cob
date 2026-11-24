*> Test of the value forms of the real data in the world generation and loot loaders (docs/protocol/48-real-data-shapes.md
*> sections 2.1, 2.5, 2.7 and 3.17 to 3.21): a block state that is a block id or {id, properties}, the surface rule member
*> sequence whose elements are ids or objects, if_true and then_run as ids, an ore feature with no config wrapper whose targets
*> hold a block id as state and rule tests with the members rules and rule, the spawn_target boxes keyed by density function ids
*> (the spellings of overworld and overworld_large_biomes, only ridges required), and context provider files that are a bare
*> number. Invented minimal files: content/tests/fixtures/real-forms. The old forms (a config member, Name and Properties, rules
*> of a sequence, predicates of a rule test) are rejected.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-REAL-DATA-FORMS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CTSHAPE.
 COPY CTWORLDGEN.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-KIND                BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-BOX                 BINARY-LONG.
 01 WS-GOT-N               BINARY-LONG.
 01 WS-T                   PIC X(70).
 01 WS-DIR-NAME            PIC X(60).
 01 WS-BODY                PIC X(700).
 01 WS-COMMAND             PIC X(1000).
 01 WS-I                   BINARY-LONG.
 01 WS-CASES.
    05 FILLER PIC X(60) VALUE "a state with the key Name".
    05 FILLER PIC X(20) VALUE "noise_settings".
    05 FILLER PIC X(700) VALUE '{"sea_level":1,"noise":{"min_y":0,"height":128},"default_block":{"Name":"a:b"},"default_fluid":"a:b","material_rule":"a:b","debug_functions":[],"disable_mob_generation":false,"legacy_random_source":false,"noise_router":{"temperature":0,"vegetation":0,"continents":0,"erosion":0,"depth":0,"ridges":0,"chunk_surface_level":0,"final_density":0},"spawn_target":[]}'.
    05 FILLER PIC X(60) VALUE "a spawn box without ridges".
    05 FILLER PIC X(20) VALUE "noise_settings".
    05 FILLER PIC X(700) VALUE '{"sea_level":1,"noise":{"min_y":0,"height":128},"default_block":"a:b","default_fluid":"a:b","material_rule":"a:b","debug_functions":[],"disable_mob_generation":false,"legacy_random_source":false,"noise_router":{"temperature":0,"vegetation":0,"continents":0,"erosion":0,"depth":0,"ridges":0,"chunk_surface_level":0,"final_density":0},"spawn_target":[{"minecraft:overworld/continents":[0,1]}]}'.
    05 FILLER PIC X(60) VALUE "a sequence rule with the member rules".
    05 FILLER PIC X(20) VALUE "material_rule".
    05 FILLER PIC X(700) VALUE '{"type":"minecraft:sequence","rules":["a:b"]}'.
    05 FILLER PIC X(60) VALUE "a block rule whose result_state has Name".
    05 FILLER PIC X(20) VALUE "material_rule".
    05 FILLER PIC X(700) VALUE '{"type":"minecraft:block","result_state":{"Name":"a:b"}}'.
    05 FILLER PIC X(60) VALUE "an ore feature with a config member".
    05 FILLER PIC X(20) VALUE "feature".
    05 FILLER PIC X(700) VALUE '{"type":"minecraft:ore","config":{"size":3,"discard_chance_on_air_exposure":0.0,"targets":[]}}'.
    05 FILLER PIC X(60) VALUE "an ore rule test with the member predicates".
    05 FILLER PIC X(20) VALUE "feature".
    05 FILLER PIC X(700) VALUE '{"type":"minecraft:ore","size":3,"discard_chance_on_air_exposure":0.0,"targets":[{"state":"a:b","target":{"predicate_type":"minecraft:all_of","predicates":[]}}]}'.
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE OCCURS 6 TIMES.
       10 WS-CASE-LABEL    PIC X(60).
       10 WS-CASE-DIR      PIC X(20).
       10 WS-CASE-BODY     PIC X(700).
 PROCEDURE DIVISION.
     MOVE "content/tests/fixtures/real-forms" TO WS-DIR
     CALL "WORLDGEN-FREE"
     CALL "NOISE-SETTINGS-LOAD" USING WS-DIR WS-STATUS
     MOVE "real forms: the noise settings load" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE 6 TO WS-KIND
     MOVE "minecraft:large" TO WS-KEY
     CALL "WG-FIND" USING WS-KIND WS-KEY WS-NODE
     IF WS-NODE = 0
         MOVE 1 TO WS-NODE
     END-IF
     MOVE "real forms: default_block as a block id" TO TL-CASE
     MOVE "minecraft:stone" TO TL-EXPECTED
     MOVE WGN-TEXT-1(WS-NODE) TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "real forms: default_fluid as {id, properties}" TO TL-CASE
     MOVE "minecraft:water level=0" TO TL-EXPECTED
     MOVE WGN-TEXT-2(WS-NODE) TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE WGN-CHILD(WS-NODE, 16) TO WS-BOX
     MOVE "real forms: first box, large biomes erosion maximum" TO TL-CASE
     COMPUTE WS-GOT-N = WGN-NUM(WS-BOX, 4) * 10
     MOVE 10 TO TL-EXPECTED-N
     MOVE WS-GOT-N TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "real forms: first box, ridges minimum" TO TL-CASE
     COMPUTE WS-GOT-N = WGN-NUM(WS-BOX, 9) * 10
     MOVE -10 TO TL-EXPECTED-N
     MOVE WS-GOT-N TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE WGN-NEXT(WS-BOX) TO WS-BOX
     MOVE "real forms: second box, continents maximum" TO TL-CASE
     COMPUTE WS-GOT-N = WGN-NUM(WS-BOX, 2) * 10
     MOVE 5 TO TL-EXPECTED-N
     MOVE WS-GOT-N TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "real forms: second box leaves erosion out" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WGN-NUM(WS-BOX, 3) * 10
     PERFORM ASSERT-NUM

     CALL "MATERIAL-RULES-LOAD" USING WS-DIR WS-STATUS
     MOVE "real forms: the surface rules load" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     CALL "ORE-FEATURES-LOAD" USING WS-DIR WS-STATUS
     MOVE "real forms: the ore feature loads" TO TL-CASE
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "real forms: five files (settings, 2 rules, a condition, an ore)" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WG-COUNT(WGK-FUNCTION) TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE 5 TO WS-KIND
     MOVE "minecraft:ore_forms" TO WS-KEY
     CALL "WG-FIND" USING WS-KIND WS-KEY WS-NODE
     IF WS-NODE = 0
         MOVE 1 TO WS-NODE
     END-IF
     MOVE "real forms: ore size at the top level" TO TL-CASE
     MOVE 17 TO TL-EXPECTED-N
     MOVE WGN-INT(WS-NODE, 1) TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE WGN-CHILD(WS-NODE, 1) TO WS-NODE
     MOVE "real forms: ore target state as a block id" TO TL-CASE
     MOVE "minecraft:coal_ore" TO TL-EXPECTED
     MOVE WGN-TEXT-1(WS-NODE) TO TL-OBSERVED
     PERFORM ASSERT-TEXT

     CALL "SHAPE-FREE"
     CALL "LOOT-LOAD" USING WS-DIR WS-STATUS
     MOVE "real forms: context providers (a bare integer, a bare decimal, a typed one) load" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "real forms: three context provider elements" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     CALL "SHAPE-FREE"

*>   The forms that do not occur are rejected.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE WS-CASE-LABEL(WS-I) TO WS-T
         MOVE WS-CASE-DIR(WS-I) TO WS-DIR-NAME
         MOVE WS-CASE-BODY(WS-I) TO WS-BODY
         PERFORM BAD-CASE
     END-PERFORM
     STOP RUN.

 BAD-CASE.
     CALL "WORLDGEN-FREE"
     CALL "SYSTEM" USING "rm -rf build/content-test/real-forms; mkdir -p build/content-test/real-forms"
     MOVE SPACES TO WS-COMMAND
     STRING "mkdir -p build/content-test/real-forms/t/data/minecraft/worldgen/" FUNCTION TRIM(WS-DIR-NAME) " && printf '%s' '"
         FUNCTION TRIM(WS-BODY) "' > build/content-test/real-forms/t/data/minecraft/worldgen/" FUNCTION TRIM(WS-DIR-NAME)
         "/bad.json" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "build/content-test/real-forms/t" TO WS-DIR
     EVALUATE WS-DIR-NAME
         WHEN "noise_settings"
             CALL "NOISE-SETTINGS-LOAD" USING WS-DIR WS-STATUS
         WHEN "material_rule"
             CALL "MATERIAL-RULES-LOAD" USING WS-DIR WS-STATUS
         WHEN OTHER
             CALL "ORE-FEATURES-LOAD" USING WS-DIR WS-STATUS
     END-EVALUATE
     MOVE SPACES TO TL-CASE
     STRING "real forms: reject " FUNCTION TRIM(WS-T) DELIMITED BY SIZE INTO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "real forms: after " FUNCTION TRIM(WS-T) " nothing stays" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WG-COUNT(WGK-FUNCTION) TO TL-OBSERVED-N
     PERFORM ASSERT-NUM.

 ASSERT-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-TEXT.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
