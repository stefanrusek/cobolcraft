*> Test of the loader of docs/protocol/37-nether-3...md (T-phase 23): LOAD-37-3 USING root (PIC X(1100): the folder that
*> holds data/), status out (CT-OK, or CT-BAD-DATA with every error on standard error and nothing of the part left
*> loaded) loads the Nether biome source preset and the five biome definitions. Fixture tree
*> content/tests/fixtures/load-37-3 (accept cases: one file per documented file shape); each reject case writes one bad
*> file into a fresh copy of it. Case names start 'acceptance US12 load 37-3 '.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOAD-37-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CTSHAPE.
 COPY CTWORLDGEN.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-REG                 PIC X(48).
 01 WS-KEY                 PIC X(64).
 01 WS-WANT-TYPE           PIC X(48).
 01 WS-ROW                 BINARY-LONG.
 01 WS-COMMAND             PIC X(1100).
 01 WS-PATH                PIC X(130).
 01 WS-BODY                PIC X(700).
 01 WS-T                   PIC X(70).
 01 WS-I                   BINARY-LONG.
 01 WS-CASES.
    05 FILLER PIC X(60) VALUE "a biome without temperature".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-3/t/data/minecraft/worldgen/biome/bad.json".
    05 FILLER PIC X(115) VALUE '{"has_precipitation":false,"downfall":0.0,"effects":{"water_color":4159204},"attributes":{},"carvers":"minecraft:ne'.
    05 FILLER PIC X(115) VALUE 'ther_cave","features":[[],[]]}                                                                                     '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a temperature that is a string".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-3/t/data/minecraft/worldgen/biome/bad.json".
    05 FILLER PIC X(115) VALUE '{"has_precipitation":false,"temperature":"hot","downfall":0.0,"effects":{"water_color":4159204},"attributes":{},"ca'.
    05 FILLER PIC X(115) VALUE 'rvers":"minecraft:nether_cave","features":[[],[]]}                                                                 '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a biome without has_precipitation".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-3/t/data/minecraft/worldgen/biome/bad.json".
    05 FILLER PIC X(115) VALUE '{"temperature":2.0,"downfall":0.0,"effects":{"water_color":4159204},"attributes":{},"carvers":"minecraft:nether_cav'.
    05 FILLER PIC X(115) VALUE 'e","features":[[],[]]}                                                                                             '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a temperature_modifier that is not listed".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-3/t/data/minecraft/worldgen/biome/bad.json".
    05 FILLER PIC X(115) VALUE '{"has_precipitation":false,"temperature":2.0,"downfall":0.0,"effects":{"water_color":4159204},"attributes":{},"carv'.
    05 FILLER PIC X(115) VALUE 'ers":"minecraft:nether_cave","features":[[],[]],"temperature_modifier":"warm"}                                     '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a biome without effects".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-3/t/data/minecraft/worldgen/biome/bad.json".
    05 FILLER PIC X(115) VALUE '{"has_precipitation":false,"temperature":2.0,"downfall":0.0,"attributes":{},"carvers":"minecraft:nether_cave","feat'.
    05 FILLER PIC X(115) VALUE 'ures":[[],[]]}                                                                                                     '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "effects without water_color".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-3/t/data/minecraft/worldgen/biome/bad.json".
    05 FILLER PIC X(115) VALUE '{"has_precipitation":false,"temperature":2.0,"downfall":0.0,"effects":{},"attributes":{},"carvers":"minecraft:nethe'.
    05 FILLER PIC X(115) VALUE 'r_cave","features":[[],[]]}                                                                                        '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a grass_color_modifier that is not listed".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-3/t/data/minecraft/worldgen/biome/bad.json".
    05 FILLER PIC X(115) VALUE '{"has_precipitation":false,"temperature":2.0,"downfall":0.0,"effects":{"water_color":4159204,"grass_color_modifier"'.
    05 FILLER PIC X(115) VALUE ':"red"},"attributes":{},"carvers":"minecraft:nether_cave","features":[[],[]]}                                      '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "attributes that are an array".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-3/t/data/minecraft/worldgen/biome/bad.json".
    05 FILLER PIC X(115) VALUE '{"has_precipitation":false,"temperature":2.0,"downfall":0.0,"effects":{"water_color":4159204},"attributes":[],"carv'.
    05 FILLER PIC X(115) VALUE 'ers":"minecraft:nether_cave","features":[[],[]]}                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a biome without carvers".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-3/t/data/minecraft/worldgen/biome/bad.json".
    05 FILLER PIC X(115) VALUE '{"has_precipitation":false,"temperature":2.0,"downfall":0.0,"effects":{"water_color":4159204},"attributes":{},"feat'.
    05 FILLER PIC X(115) VALUE 'ures":[[],[]]}                                                                                                     '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a carvers value that is a number".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-3/t/data/minecraft/worldgen/biome/bad.json".
    05 FILLER PIC X(115) VALUE '{"has_precipitation":false,"temperature":2.0,"downfall":0.0,"effects":{"water_color":4159204},"attributes":{},"carv'.
    05 FILLER PIC X(115) VALUE 'ers":1,"features":[[],[]]}                                                                                         '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a carver id that is invalid".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-3/t/data/minecraft/worldgen/biome/bad.json".
    05 FILLER PIC X(115) VALUE '{"has_precipitation":false,"temperature":2.0,"downfall":0.0,"effects":{"water_color":4159204},"attributes":{},"carv'.
    05 FILLER PIC X(115) VALUE 'ers":["Not Valid"],"features":[[],[]]}                                                                             '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a biome without features".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-3/t/data/minecraft/worldgen/biome/bad.json".
    05 FILLER PIC X(115) VALUE '{"has_precipitation":false,"temperature":2.0,"downfall":0.0,"effects":{"water_color":4159204},"attributes":{},"carv'.
    05 FILLER PIC X(115) VALUE 'ers":"minecraft:nether_cave"}                                                                                      '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "features that are an object".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-3/t/data/minecraft/worldgen/biome/bad.json".
    05 FILLER PIC X(115) VALUE '{"has_precipitation":false,"temperature":2.0,"downfall":0.0,"effects":{"water_color":4159204},"attributes":{},"carv'.
    05 FILLER PIC X(115) VALUE 'ers":"minecraft:nether_cave","features":{}}                                                                        '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "features whose inner value is no list (value check)".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-3/t/data/minecraft/worldgen/biome/bad.json".
    05 FILLER PIC X(115) VALUE '{"has_precipitation":false,"temperature":2.0,"downfall":0.0,"effects":{"water_color":4159204},"attributes":{},"carv'.
    05 FILLER PIC X(115) VALUE 'ers":"minecraft:nether_cave","features":["minecraft:x"]}                                                           '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a preset that is not listed".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-3/t/data/minecraft/worldgen/multi_noise_biome_source_parameter_list/bad.json".
    05 FILLER PIC X(115) VALUE '{"preset":"minecraft:end"}                                                                                         '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a preset list without preset".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-3/t/data/minecraft/worldgen/multi_noise_biome_source_parameter_list/bad.json".
    05 FILLER PIC X(115) VALUE '{}                                                                                                                 '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a preset that is a number".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-3/t/data/minecraft/worldgen/multi_noise_biome_source_parameter_list/bad.json".
    05 FILLER PIC X(115) VALUE '{"preset":1}                                                                                                       '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE OCCURS 17 TIMES.
       10 WS-CASE-LABEL    PIC X(60).
       10 WS-CASE-PATH     PIC X(130).
       10 WS-CASE-BODY     PIC X(700).
 PROCEDURE DIVISION.
     CALL "WORLDGEN-FREE"
     CALL "SHAPE-FREE"
     MOVE "content/tests/fixtures/load-37-3" TO WS-DIR
     CALL "LOAD-37-3" USING WS-DIR WS-STATUS
     MOVE "acceptance US12 load 37-3 the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US12 load 37-3 5 shape elements" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US12 load 37-3 5 function rows" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WG-COUNT(WGK-FUNCTION) TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "worldgen/biome" TO WS-REG
     MOVE "minecraft:nether_wastes" TO WS-KEY
     MOVE "-" TO WS-WANT-TYPE
     PERFORM FIND-CHECK
     MOVE "worldgen/biome" TO WS-REG
     MOVE "minecraft:plains" TO WS-KEY
     MOVE "-" TO WS-WANT-TYPE
     PERFORM FIND-CHECK
     MOVE "worldgen/biome" TO WS-REG
     MOVE "minecraft:swamp" TO WS-KEY
     MOVE "-" TO WS-WANT-TYPE
     PERFORM FIND-CHECK
     MOVE "worldgen/multi_noise_biome_source_parameter_list" TO WS-REG
     MOVE "minecraft:nether" TO WS-KEY
     MOVE "-" TO WS-WANT-TYPE
     PERFORM FIND-CHECK
     MOVE "worldgen/multi_noise_biome_source_parameter_list" TO WS-REG
     MOVE "minecraft:overworld" TO WS-KEY
     MOVE "-" TO WS-WANT-TYPE
     PERFORM FIND-CHECK
     CALL "WORLDGEN-FREE"
     CALL "SHAPE-FREE"

     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 17
         MOVE WS-CASE-LABEL(WS-I) TO WS-T
         MOVE WS-CASE-PATH(WS-I) TO WS-PATH
         MOVE WS-CASE-BODY(WS-I) TO WS-BODY
         PERFORM BAD-CASE
     END-PERFORM
     STOP RUN.

 FIND-CHECK.
     CALL "SHAPE-FIND" USING WS-REG WS-KEY WS-ROW
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 37-3 " FUNCTION TRIM(WS-KEY) " is loaded" DELIMITED BY SIZE INTO TL-CASE
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
     STRING "acceptance US12 load 37-3 " FUNCTION TRIM(WS-KEY) " has its type row" DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-WANT-TYPE TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 BAD-CASE.
     MOVE SPACES TO WS-COMMAND
     STRING "chmod -R u+rwx build/content-test/load-37-3 2>/dev/null; rm -rf build/content-test/load-37-3; "
         "mkdir -p build/content-test/load-37-3 && cp -R content/tests/fixtures/load-37-3 build/content-test/load-37-3/t"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE SPACES TO WS-COMMAND
     STRING "mkdir -p $(dirname " FUNCTION TRIM(WS-PATH) ") && printf '%s' '" FUNCTION TRIM(WS-BODY) "' > "
         FUNCTION TRIM(WS-PATH) DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "build/content-test/load-37-3/t" TO WS-DIR
     CALL "LOAD-37-3" USING WS-DIR WS-STATUS
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 37-3 " FUNCTION TRIM(WS-T) " is CT-BAD-DATA" DELIMITED BY SIZE INTO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 37-3 after " FUNCTION TRIM(WS-T) " nothing stays" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = SH-ELEMENT-COUNT + WG-COUNT(WGK-FUNCTION) + WG-COUNT(WGK-NODE)
     PERFORM ASSERT-NUM
     CALL "WORLDGEN-FREE"
     CALL "SHAPE-FREE".

 ASSERT-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
