*> Test of the loader of docs/protocol/37-nether-5...md (T-phase 23): LOAD-37-5 USING root (PIC X(1100): the folder that
*> holds data/), status out (CT-OK, or CT-BAD-DATA with every error on standard error and nothing of the part left
*> loaded) loads the Nether features and decoration (placed features, ore features). Fixture tree
*> content/tests/fixtures/load-37-5 (accept cases: one file per documented file shape); each reject case writes one bad
*> file into a fresh copy of it. Case names start 'acceptance US12 load 37-5 '.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOAD-37-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CTSHAPE.
 COPY CTWORLDGEN.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-REG                 PIC X(48).
 01 WS-KEY                 PIC X(112).
 01 WS-WANT-TYPE           PIC X(48).
 01 WS-ROW                 BINARY-LONG.
 01 WS-COMMAND             PIC X(1100).
 01 WS-PATH                PIC X(130).
 01 WS-BODY                PIC X(700).
 01 WS-T                   PIC X(70).
 01 WS-I                   BINARY-LONG.
 01 WS-CASES.
    05 FILLER PIC X(60) VALUE "a placed feature without feature".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-5/t/data/minecraft/worldgen/placed_feature/bad.json".
    05 FILLER PIC X(115) VALUE '{"placement":[{"type":"minecraft:count","count":{"type":"minecraft:uniform","min_inclusive":0,"max_inclusive":5}},{'.
    05 FILLER PIC X(115) VALUE '"type":"minecraft:in_square"},{"type":"minecraft:height_range","height":{"type":"minecraft:uniform","min_inclusive"'.
    05 FILLER PIC X(115) VALUE ':{"above_bottom":4},"max_inclusive":{"below_top":4}}},{"type":"minecraft:biome"}]}                                 '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a placed feature without placement".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-5/t/data/minecraft/worldgen/placed_feature/bad.json".
    05 FILLER PIC X(115) VALUE '{"feature":"minecraft:patch_fire"}                                                                                 '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a feature that is a number".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-5/t/data/minecraft/worldgen/placed_feature/bad.json".
    05 FILLER PIC X(115) VALUE '{"feature":1,"placement":[{"type":"minecraft:count","count":{"type":"minecraft:uniform","min_inclusive":0,"max_incl'.
    05 FILLER PIC X(115) VALUE 'usive":5}},{"type":"minecraft:in_square"},{"type":"minecraft:height_range","height":{"type":"minecraft:uniform","mi'.
    05 FILLER PIC X(115) VALUE 'n_inclusive":{"above_bottom":4},"max_inclusive":{"below_top":4}}},{"type":"minecraft:biome"}]}                     '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a feature id that is invalid".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-5/t/data/minecraft/worldgen/placed_feature/bad.json".
    05 FILLER PIC X(115) VALUE '{"feature":"Not Valid","placement":[{"type":"minecraft:count","count":{"type":"minecraft:uniform","min_inclusive":0'.
    05 FILLER PIC X(115) VALUE ',"max_inclusive":5}},{"type":"minecraft:in_square"},{"type":"minecraft:height_range","height":{"type":"minecraft:un'.
    05 FILLER PIC X(115) VALUE 'iform","min_inclusive":{"above_bottom":4},"max_inclusive":{"below_top":4}}},{"type":"minecraft:biome"}]}           '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "an inline feature without type".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-5/t/data/minecraft/worldgen/placed_feature/bad.json".
    05 FILLER PIC X(115) VALUE '{"feature":{},"placement":[{"type":"minecraft:count","count":{"type":"minecraft:uniform","min_inclusive":0,"max_inc'.
    05 FILLER PIC X(115) VALUE 'lusive":5}},{"type":"minecraft:in_square"},{"type":"minecraft:height_range","height":{"type":"minecraft:uniform","m'.
    05 FILLER PIC X(115) VALUE 'in_inclusive":{"above_bottom":4},"max_inclusive":{"below_top":4}}},{"type":"minecraft:biome"}]}                    '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a placement that is an object".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-5/t/data/minecraft/worldgen/placed_feature/bad.json".
    05 FILLER PIC X(115) VALUE '{"feature":"minecraft:patch_fire","placement":{}}                                                                  '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a placement modifier that is a number".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-5/t/data/minecraft/worldgen/placed_feature/bad.json".
    05 FILLER PIC X(115) VALUE '{"feature":"minecraft:patch_fire","placement":[1]}                                                                 '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a placement modifier without type".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-5/t/data/minecraft/worldgen/placed_feature/bad.json".
    05 FILLER PIC X(115) VALUE '{"feature":"minecraft:patch_fire","placement":[{"count":1}]}                                                       '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a placed feature that is no object".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-5/t/data/minecraft/worldgen/placed_feature/bad.json".
    05 FILLER PIC X(115) VALUE '[]                                                                                                                 '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "an ore feature without config".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-5/t/data/minecraft/worldgen/feature/bad.json".
    05 FILLER PIC X(115) VALUE '{"type":"minecraft:ore"}                                                                                           '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "an ore feature without size".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-5/t/data/minecraft/worldgen/feature/bad.json".
    05 FILLER PIC X(115) VALUE '{"type":"minecraft:ore","config":{"discard_chance_on_air_exposure":0.0,"targets":[]}}                              '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE OCCURS 11 TIMES.
       10 WS-CASE-LABEL    PIC X(60).
       10 WS-CASE-PATH     PIC X(130).
       10 WS-CASE-BODY     PIC X(700).
 PROCEDURE DIVISION.
     CALL "WORLDGEN-FREE"
     CALL "SHAPE-FREE"
     MOVE "content/tests/fixtures/load-37-5" TO WS-DIR
     CALL "LOAD-37-5" USING WS-DIR WS-STATUS
     MOVE "acceptance US12 load 37-5 the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US12 load 37-5 2 shape elements" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US12 load 37-5 2 function rows" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WG-COUNT(WGK-FUNCTION) TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "worldgen/placed_feature" TO WS-REG
     MOVE "minecraft:patch_fire" TO WS-KEY
     MOVE "-" TO WS-WANT-TYPE
     PERFORM FIND-CHECK
     MOVE "worldgen/placed_feature" TO WS-REG
     MOVE "minecraft:nether_sprouts" TO WS-KEY
     MOVE "-" TO WS-WANT-TYPE
     PERFORM FIND-CHECK
     CALL "WORLDGEN-FREE"
     CALL "SHAPE-FREE"

     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 11
         MOVE WS-CASE-LABEL(WS-I) TO WS-T
         MOVE WS-CASE-PATH(WS-I) TO WS-PATH
         MOVE WS-CASE-BODY(WS-I) TO WS-BODY
         PERFORM BAD-CASE
     END-PERFORM
     STOP RUN.

 FIND-CHECK.
     CALL "SHAPE-FIND" USING WS-REG WS-KEY WS-ROW
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 37-5 " FUNCTION TRIM(WS-KEY) " is loaded" DELIMITED BY SIZE INTO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-ROW > 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-OBSERVED
     IF WS-ROW > 0
         MOVE SH-T-NAME(SH-E-TYPE(WS-ROW)) TO TL-OBSERVED
     END-IF
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 37-5 " FUNCTION TRIM(WS-KEY) " has its type row" DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-WANT-TYPE TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 BAD-CASE.
     MOVE SPACES TO WS-COMMAND
     STRING "chmod -R u+rwx build/content-test/load-37-5 2>/dev/null; rm -rf build/content-test/load-37-5; "
         "mkdir -p build/content-test/load-37-5 && cp -R content/tests/fixtures/load-37-5 build/content-test/load-37-5/t"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE SPACES TO WS-COMMAND
     STRING "mkdir -p $(dirname " FUNCTION TRIM(WS-PATH) ") && printf '%s' '" FUNCTION TRIM(WS-BODY) "' > "
         FUNCTION TRIM(WS-PATH) DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "build/content-test/load-37-5/t" TO WS-DIR
     CALL "LOAD-37-5" USING WS-DIR WS-STATUS
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 37-5 " FUNCTION TRIM(WS-T) " is CT-BAD-DATA" DELIMITED BY SIZE INTO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 37-5 after " FUNCTION TRIM(WS-T) " nothing stays" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = SH-ELEMENT-COUNT + WG-COUNT(WGK-FUNCTION) + WG-COUNT(WGK-NODE)
     PERFORM ASSERT-NUM
     CALL "WORLDGEN-FREE"
     CALL "SHAPE-FREE".

 ASSERT-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
