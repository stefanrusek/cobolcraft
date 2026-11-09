*> Test of the loader of docs/protocol/37-nether-1...md (T-phase 23): LOAD-37-1 USING root (PIC X(1100): the folder that
*> holds data/), status out (CT-OK, or CT-BAD-DATA with every error on standard error and nothing of the part left
*> loaded) loads the Nether shared model and dimension rules (dimension_type with its attributes map, the world preset
*> wiring). Fixture tree content/tests/fixtures/load-37-1 (accept cases: one file per documented file shape); each reject
*> case writes one bad file into a fresh copy of it. Case names start 'acceptance US12 load 37-1 '.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOAD-37-1.
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
    05 FILLER PIC X(60) VALUE "a dimension type without has_skylight".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-1/t/data/minecraft/dimension_type/bad.json".
    05 FILLER PIC X(115) VALUE '{"has_fixed_time":true,"has_ceiling":true,"has_ender_dragon_fight":false,"coordinate_scale":8.0,"min_y":0,"height":'.
    05 FILLER PIC X(115) VALUE '256,"logical_height":128,"infiniburn":"#minecraft:infiniburn_nether","ambient_light":0.1,"monster_spawn_light_level'.
    05 FILLER PIC X(115) VALUE '":7,"monster_spawn_block_light_limit":15,"skybox":"none","cardinal_light":"nether"}                                '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a has_skylight that is a string".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-1/t/data/minecraft/dimension_type/bad.json".
    05 FILLER PIC X(115) VALUE '{"has_fixed_time":true,"has_skylight":"no","has_ceiling":true,"has_ender_dragon_fight":false,"coordinate_scale":8.0'.
    05 FILLER PIC X(115) VALUE ',"min_y":0,"height":256,"logical_height":128,"infiniburn":"#minecraft:infiniburn_nether","ambient_light":0.1,"monst'.
    05 FILLER PIC X(115) VALUE 'er_spawn_light_level":7,"monster_spawn_block_light_limit":15,"skybox":"none","cardinal_light":"nether"}            '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a min_y above 2031".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-1/t/data/minecraft/dimension_type/bad.json".
    05 FILLER PIC X(115) VALUE '{"has_fixed_time":true,"has_skylight":false,"has_ceiling":true,"has_ender_dragon_fight":false,"coordinate_scale":8.'.
    05 FILLER PIC X(115) VALUE '0,"min_y":2032,"height":256,"logical_height":128,"infiniburn":"#minecraft:infiniburn_nether","ambient_light":0.1,"m'.
    05 FILLER PIC X(115) VALUE 'onster_spawn_light_level":7,"monster_spawn_block_light_limit":15,"skybox":"none","cardinal_light":"nether"}        '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a height below 16".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-1/t/data/minecraft/dimension_type/bad.json".
    05 FILLER PIC X(115) VALUE '{"has_fixed_time":true,"has_skylight":false,"has_ceiling":true,"has_ender_dragon_fight":false,"coordinate_scale":8.'.
    05 FILLER PIC X(115) VALUE '0,"min_y":0,"height":8,"logical_height":128,"infiniburn":"#minecraft:infiniburn_nether","ambient_light":0.1,"monste'.
    05 FILLER PIC X(115) VALUE 'r_spawn_light_level":7,"monster_spawn_block_light_limit":15,"skybox":"none","cardinal_light":"nether"}             '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a fractional height".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-1/t/data/minecraft/dimension_type/bad.json".
    05 FILLER PIC X(115) VALUE '{"has_fixed_time":true,"has_skylight":false,"has_ceiling":true,"has_ender_dragon_fight":false,"coordinate_scale":8.'.
    05 FILLER PIC X(115) VALUE '0,"min_y":0,"height":256.5,"logical_height":128,"infiniburn":"#minecraft:infiniburn_nether","ambient_light":0.1,"mo'.
    05 FILLER PIC X(115) VALUE 'nster_spawn_light_level":7,"monster_spawn_block_light_limit":15,"skybox":"none","cardinal_light":"nether"}         '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a coordinate_scale of 0".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-1/t/data/minecraft/dimension_type/bad.json".
    05 FILLER PIC X(115) VALUE '{"has_fixed_time":true,"has_skylight":false,"has_ceiling":true,"has_ender_dragon_fight":false,"coordinate_scale":0,'.
    05 FILLER PIC X(115) VALUE '"min_y":0,"height":256,"logical_height":128,"infiniburn":"#minecraft:infiniburn_nether","ambient_light":0.1,"monste'.
    05 FILLER PIC X(115) VALUE 'r_spawn_light_level":7,"monster_spawn_block_light_limit":15,"skybox":"none","cardinal_light":"nether"}             '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a skybox that is not listed".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-1/t/data/minecraft/dimension_type/bad.json".
    05 FILLER PIC X(115) VALUE '{"has_fixed_time":true,"has_skylight":false,"has_ceiling":true,"has_ender_dragon_fight":false,"coordinate_scale":8.'.
    05 FILLER PIC X(115) VALUE '0,"min_y":0,"height":256,"logical_height":128,"infiniburn":"#minecraft:infiniburn_nether","ambient_light":0.1,"mons'.
    05 FILLER PIC X(115) VALUE 'ter_spawn_light_level":7,"monster_spawn_block_light_limit":15,"skybox":"dome","cardinal_light":"nether"}           '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a cardinal_light that is not listed".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-1/t/data/minecraft/dimension_type/bad.json".
    05 FILLER PIC X(115) VALUE '{"has_fixed_time":true,"has_skylight":false,"has_ceiling":true,"has_ender_dragon_fight":false,"coordinate_scale":8.'.
    05 FILLER PIC X(115) VALUE '0,"min_y":0,"height":256,"logical_height":128,"infiniburn":"#minecraft:infiniburn_nether","ambient_light":0.1,"mons'.
    05 FILLER PIC X(115) VALUE 'ter_spawn_light_level":7,"monster_spawn_block_light_limit":15,"skybox":"none","cardinal_light":"x"}                '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a block light limit of 16".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-1/t/data/minecraft/dimension_type/bad.json".
    05 FILLER PIC X(115) VALUE '{"has_fixed_time":true,"has_skylight":false,"has_ceiling":true,"has_ender_dragon_fight":false,"coordinate_scale":8.'.
    05 FILLER PIC X(115) VALUE '0,"min_y":0,"height":256,"logical_height":128,"infiniburn":"#minecraft:infiniburn_nether","ambient_light":0.1,"mons'.
    05 FILLER PIC X(115) VALUE 'ter_spawn_light_level":7,"monster_spawn_block_light_limit":16,"skybox":"none","cardinal_light":"nether"}           '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a light level that is a string".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-1/t/data/minecraft/dimension_type/bad.json".
    05 FILLER PIC X(115) VALUE '{"has_fixed_time":true,"has_skylight":false,"has_ceiling":true,"has_ender_dragon_fight":false,"coordinate_scale":8.'.
    05 FILLER PIC X(115) VALUE '0,"min_y":0,"height":256,"logical_height":128,"infiniburn":"#minecraft:infiniburn_nether","ambient_light":0.1,"mons'.
    05 FILLER PIC X(115) VALUE 'ter_spawn_light_level":"seven","monster_spawn_block_light_limit":15,"skybox":"none","cardinal_light":"nether"}     '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "an attributes member that is an array".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-1/t/data/minecraft/dimension_type/bad.json".
    05 FILLER PIC X(115) VALUE '{"has_fixed_time":true,"has_skylight":false,"has_ceiling":true,"has_ender_dragon_fight":false,"coordinate_scale":8.'.
    05 FILLER PIC X(115) VALUE '0,"min_y":0,"height":256,"logical_height":128,"infiniburn":"#minecraft:infiniburn_nether","ambient_light":0.1,"mons'.
    05 FILLER PIC X(115) VALUE 'ter_spawn_light_level":7,"monster_spawn_block_light_limit":15,"skybox":"none","cardinal_light":"nether","attributes'.
    05 FILLER PIC X(115) VALUE '":[]}                                                                                                              '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a default_clock that is no identifier".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-1/t/data/minecraft/dimension_type/bad.json".
    05 FILLER PIC X(115) VALUE '{"has_fixed_time":true,"has_skylight":false,"has_ceiling":true,"has_ender_dragon_fight":false,"coordinate_scale":8.'.
    05 FILLER PIC X(115) VALUE '0,"min_y":0,"height":256,"logical_height":128,"infiniburn":"#minecraft:infiniburn_nether","ambient_light":0.1,"mons'.
    05 FILLER PIC X(115) VALUE 'ter_spawn_light_level":7,"monster_spawn_block_light_limit":15,"skybox":"none","cardinal_light":"nether","default_cl'.
    05 FILLER PIC X(115) VALUE 'ock":"Not Valid"}                                                                                                  '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a logical_height above the height (constructor check)".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-1/t/data/minecraft/dimension_type/bad.json".
    05 FILLER PIC X(115) VALUE '{"has_fixed_time":true,"has_skylight":false,"has_ceiling":true,"has_ender_dragon_fight":false,"coordinate_scale":8.'.
    05 FILLER PIC X(115) VALUE '0,"min_y":0,"height":256,"logical_height":300,"infiniburn":"#minecraft:infiniburn_nether","ambient_light":0.1,"mons'.
    05 FILLER PIC X(115) VALUE 'ter_spawn_light_level":7,"monster_spawn_block_light_limit":15,"skybox":"none","cardinal_light":"nether"}           '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a dimension type that is no object".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-1/t/data/minecraft/dimension_type/bad.json".
    05 FILLER PIC X(115) VALUE '[]                                                                                                                 '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a world preset without dimensions".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-1/t/data/minecraft/worldgen/world_preset/bad.json".
    05 FILLER PIC X(115) VALUE '{}                                                                                                                 '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a world preset whose dimensions are an array".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-1/t/data/minecraft/worldgen/world_preset/bad.json".
    05 FILLER PIC X(115) VALUE '{"dimensions":[]}                                                                                                  '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE OCCURS 16 TIMES.
       10 WS-CASE-LABEL    PIC X(60).
       10 WS-CASE-PATH     PIC X(130).
       10 WS-CASE-BODY     PIC X(700).
 PROCEDURE DIVISION.
     CALL "WORLDGEN-FREE"
     CALL "SHAPE-FREE"
     MOVE "content/tests/fixtures/load-37-1" TO WS-DIR
     CALL "LOAD-37-1" USING WS-DIR WS-STATUS
     MOVE "acceptance US12 load 37-1 the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US12 load 37-1 4 shape elements" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US12 load 37-1 3 function rows" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WG-COUNT(WGK-FUNCTION) TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "dimension_type" TO WS-REG
     MOVE "minecraft:the_nether" TO WS-KEY
     MOVE "-" TO WS-WANT-TYPE
     PERFORM FIND-CHECK
     MOVE "dimension_type" TO WS-REG
     MOVE "minecraft:the_end" TO WS-KEY
     MOVE "-" TO WS-WANT-TYPE
     PERFORM FIND-CHECK
     MOVE "dimension_type" TO WS-REG
     MOVE "minecraft:overworld" TO WS-KEY
     MOVE "-" TO WS-WANT-TYPE
     PERFORM FIND-CHECK
     MOVE "worldgen/world_preset" TO WS-REG
     MOVE "minecraft:normal" TO WS-KEY
     MOVE "-" TO WS-WANT-TYPE
     PERFORM FIND-CHECK
     CALL "WORLDGEN-FREE"
     CALL "SHAPE-FREE"

     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE WS-CASE-LABEL(WS-I) TO WS-T
         MOVE WS-CASE-PATH(WS-I) TO WS-PATH
         MOVE WS-CASE-BODY(WS-I) TO WS-BODY
         PERFORM BAD-CASE
     END-PERFORM
     STOP RUN.

 FIND-CHECK.
     CALL "SHAPE-FIND" USING WS-REG WS-KEY WS-ROW
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 37-1 " FUNCTION TRIM(WS-KEY) " is loaded" DELIMITED BY SIZE INTO TL-CASE
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
     STRING "acceptance US12 load 37-1 " FUNCTION TRIM(WS-KEY) " has its type row" DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-WANT-TYPE TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 BAD-CASE.
     MOVE SPACES TO WS-COMMAND
     STRING "chmod -R u+rwx build/content-test/load-37-1 2>/dev/null; rm -rf build/content-test/load-37-1; "
         "mkdir -p build/content-test/load-37-1 && cp -R content/tests/fixtures/load-37-1 build/content-test/load-37-1/t"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE SPACES TO WS-COMMAND
     STRING "mkdir -p $(dirname " FUNCTION TRIM(WS-PATH) ") && printf '%s' '" FUNCTION TRIM(WS-BODY) "' > "
         FUNCTION TRIM(WS-PATH) DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "build/content-test/load-37-1/t" TO WS-DIR
     CALL "LOAD-37-1" USING WS-DIR WS-STATUS
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 37-1 " FUNCTION TRIM(WS-T) " is CT-BAD-DATA" DELIMITED BY SIZE INTO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 37-1 after " FUNCTION TRIM(WS-T) " nothing stays" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = SH-ELEMENT-COUNT + WG-COUNT(WGK-FUNCTION) + WG-COUNT(WGK-NODE)
     PERFORM ASSERT-NUM
     CALL "WORLDGEN-FREE"
     CALL "SHAPE-FREE".

 ASSERT-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
