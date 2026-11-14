*> Test of the loader of docs/protocol/37-nether-2...md (T-phase 23): LOAD-37-2 USING root (PIC X(1100): the folder that
*> holds data/), status out (CT-OK, or CT-BAD-DATA with every error on standard error and nothing of the part left
*> loaded) loads the Nether noise settings, noise definitions and density functions. Fixture tree
*> content/tests/fixtures/load-37-2 (accept cases: one file per documented file shape); each reject case writes one bad
*> file into a fresh copy of it. Case names start 'acceptance US12 load 37-2 '.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOAD-37-2.
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
    05 FILLER PIC X(60) VALUE "noise settings without sea_level".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-2/t/data/minecraft/worldgen/noise_settings/bad.json".
    05 FILLER PIC X(115) VALUE '{"legacy_random_source":true,"disable_mob_generation":false,"noise":{"min_y":0,"height":128},"default_block":{"Name'.
    05 FILLER PIC X(115) VALUE '":"minecraft:netherrack"},"default_fluid":{"id"  :"minecraft:lava","properties":{"level":"0"}},"material_rule":"min'.
    05 FILLER PIC X(115) VALUE 'ecraft:nether","spawn_target":[],"noise_router":{"temperature":0,"vegetation":0,"continents":0,"erosion":0,"depth":'.
    05 FILLER PIC X(115) VALUE '0,"ridges":0,"chunk_surface_level":0,"final_density":"minecraft:nether/base_3d_noise"},"debug_functions":[{"label":'.
    05 FILLER PIC X(115) VALUE '"N","function":"minecraft:nether/base_3d_noise"}]}                                                                 '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a sea_level that is a string".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-2/t/data/minecraft/worldgen/noise_settings/bad.json".
    05 FILLER PIC X(115) VALUE '{"sea_level":"32","legacy_random_source":true,"disable_mob_generation":false,"noise":{"min_y":0,"height":128},"defa'.
    05 FILLER PIC X(115) VALUE 'ult_block":{"id"  :"minecraft:netherrack"},"default_fluid":{"id"  :"minecraft:lava","properties":{"level":"0"}},"ma'.
    05 FILLER PIC X(115) VALUE 'terial_rule":"minecraft:nether","spawn_target":[],"noise_router":{"temperature":0,"vegetation":0,"continents":0,"er'.
    05 FILLER PIC X(115) VALUE 'osion":0,"depth":0,"ridges":0,"chunk_surface_level":0,"final_density":"minecraft:nether/base_3d_noise"},"debug_func'.
    05 FILLER PIC X(115) VALUE 'tions":[{"label":"N","function":"minecraft:nether/base_3d_noise"}]}                                                '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a noise.min_y above 2031".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-2/t/data/minecraft/worldgen/noise_settings/bad.json".
    05 FILLER PIC X(115) VALUE '{"sea_level":32,"legacy_random_source":true,"disable_mob_generation":false,"noise":{"min_y":2032,"height":128},"def'.
    05 FILLER PIC X(115) VALUE 'ault_block":{"id"  :"minecraft:netherrack"},"default_fluid":{"id"  :"minecraft:lava","properties":{"level":"0"}},"m'.
    05 FILLER PIC X(115) VALUE 'aterial_rule":"minecraft:nether","spawn_target":[],"noise_router":{"temperature":0,"vegetation":0,"continents":0,"e'.
    05 FILLER PIC X(115) VALUE 'rosion":0,"depth":0,"ridges":0,"chunk_surface_level":0,"final_density":"minecraft:nether/base_3d_noise"},"debug_fun'.
    05 FILLER PIC X(115) VALUE 'ctions":[{"label":"N","function":"minecraft:nether/base_3d_noise"}]}                                               '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a noise.height above 4064".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-2/t/data/minecraft/worldgen/noise_settings/bad.json".
    05 FILLER PIC X(115) VALUE '{"sea_level":32,"legacy_random_source":true,"disable_mob_generation":false,"noise":{"min_y":0,"height":4080},"defau'.
    05 FILLER PIC X(115) VALUE 'lt_block":{"id"  :"minecraft:netherrack"},"default_fluid":{"id"  :"minecraft:lava","properties":{"level":"0"}},"mat'.
    05 FILLER PIC X(115) VALUE 'erial_rule":"minecraft:nether","spawn_target":[],"noise_router":{"temperature":0,"vegetation":0,"continents":0,"ero'.
    05 FILLER PIC X(115) VALUE 'sion":0,"depth":0,"ridges":0,"chunk_surface_level":0,"final_density":"minecraft:nether/base_3d_noise"},"debug_funct'.
    05 FILLER PIC X(115) VALUE 'ions":[{"label":"N","function":"minecraft:nether/base_3d_noise"}]}                                                 '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a noise.min_y that is no multiple of 16 (value check)".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-2/t/data/minecraft/worldgen/noise_settings/bad.json".
    05 FILLER PIC X(115) VALUE '{"sea_level":32,"legacy_random_source":true,"disable_mob_generation":false,"noise":{"min_y":8,"height":128},"defaul'.
    05 FILLER PIC X(115) VALUE 't_block":{"id"  :"minecraft:netherrack"},"default_fluid":{"id"  :"minecraft:lava","properties":{"level":"0"}},"mate'.
    05 FILLER PIC X(115) VALUE 'rial_rule":"minecraft:nether","spawn_target":[],"noise_router":{"temperature":0,"vegetation":0,"continents":0,"eros'.
    05 FILLER PIC X(115) VALUE 'ion":0,"depth":0,"ridges":0,"chunk_surface_level":0,"final_density":"minecraft:nether/base_3d_noise"},"debug_functi'.
    05 FILLER PIC X(115) VALUE 'ons":[{"label":"N","function":"minecraft:nether/base_3d_noise"}]}                                                  '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "noise settings without noise".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-2/t/data/minecraft/worldgen/noise_settings/bad.json".
    05 FILLER PIC X(115) VALUE '{"sea_level":32,"legacy_random_source":true,"disable_mob_generation":false,"default_block":{"id"  :"minecraft:nethe'.
    05 FILLER PIC X(115) VALUE 'rrack"},"default_fluid":{"id"  :"minecraft:lava","properties":{"level":"0"}},"material_rule":"minecraft:nether","sp'.
    05 FILLER PIC X(115) VALUE 'awn_target":[],"noise_router":{"temperature":0,"vegetation":0,"continents":0,"erosion":0,"depth":0,"ridges":0,"chun'.
    05 FILLER PIC X(115) VALUE 'k_surface_level":0,"final_density":"minecraft:nether/base_3d_noise"},"debug_functions":[{"label":"N","function":"mi'.
    05 FILLER PIC X(115) VALUE 'necraft:nether/base_3d_noise"}]}                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a default_block without Name".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-2/t/data/minecraft/worldgen/noise_settings/bad.json".
    05 FILLER PIC X(115) VALUE '{"sea_level":32,"legacy_random_source":true,"disable_mob_generation":false,"noise":{"min_y":0,"height":128},"defaul'.
    05 FILLER PIC X(115) VALUE 't_block":{"properties":{}},"default_fluid":{"id"  :"minecraft:lava","properties":{"level":"0"}},"material_rule":"mi'.
    05 FILLER PIC X(115) VALUE 'necraft:nether","spawn_target":[],"noise_router":{"temperature":0,"vegetation":0,"continents":0,"erosion":0,"depth"'.
    05 FILLER PIC X(115) VALUE ':0,"ridges":0,"chunk_surface_level":0,"final_density":"minecraft:nether/base_3d_noise"},"debug_functions":[{"label"'.
    05 FILLER PIC X(115) VALUE ':"N","function":"minecraft:nether/base_3d_noise"}]}                                                                '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a router without final_density".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-2/t/data/minecraft/worldgen/noise_settings/bad.json".
    05 FILLER PIC X(115) VALUE '{"sea_level":32,"legacy_random_source":true,"disable_mob_generation":false,"noise":{"min_y":0,"height":128},"defaul'.
    05 FILLER PIC X(115) VALUE 't_block":{"id"  :"minecraft:netherrack"},"default_fluid":{"id"  :"minecraft:lava","properties":{"level":"0"}},"mate'.
    05 FILLER PIC X(115) VALUE 'rial_rule":"minecraft:nether","spawn_target":[],"noise_router":{"temperature":0,"vegetation":0,"continents":0,"eros'.
    05 FILLER PIC X(115) VALUE 'ion":0,"depth":0,"ridges":0,"chunk_surface_level":0},"debug_functions":[{"label":"N","function":"minecraft:nether/b'.
    05 FILLER PIC X(115) VALUE 'ase_3d_noise"}]}                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a spawn_target that is an object".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-2/t/data/minecraft/worldgen/noise_settings/bad.json".
    05 FILLER PIC X(115) VALUE '{"sea_level":32,"legacy_random_source":true,"disable_mob_generation":false,"noise":{"min_y":0,"height":128},"defaul'.
    05 FILLER PIC X(115) VALUE 't_block":{"id"  :"minecraft:netherrack"},"default_fluid":{"id"  :"minecraft:lava","properties":{"level":"0"}},"mate'.
    05 FILLER PIC X(115) VALUE 'rial_rule":"minecraft:nether","spawn_target":{},"noise_router":{"temperature":0,"vegetation":0,"continents":0,"eros'.
    05 FILLER PIC X(115) VALUE 'ion":0,"depth":0,"ridges":0,"chunk_surface_level":0,"final_density":"minecraft:nether/base_3d_noise"},"debug_functi'.
    05 FILLER PIC X(115) VALUE 'ons":[{"label":"N","function":"minecraft:nether/base_3d_noise"}]}                                                  '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a debug_functions member that is an object".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-2/t/data/minecraft/worldgen/noise_settings/bad.json".
    05 FILLER PIC X(115) VALUE '{"sea_level":32,"legacy_random_source":true,"disable_mob_generation":false,"noise":{"min_y":0,"height":128},"defaul'.
    05 FILLER PIC X(115) VALUE 't_block":{"id"  :"minecraft:netherrack"},"default_fluid":{"id"  :"minecraft:lava","properties":{"level":"0"}},"mate'.
    05 FILLER PIC X(115) VALUE 'rial_rule":"minecraft:nether","spawn_target":[],"noise_router":{"temperature":0,"vegetation":0,"continents":0,"eros'.
    05 FILLER PIC X(115) VALUE 'ion":0,"depth":0,"ridges":0,"chunk_surface_level":0,"final_density":"minecraft:nether/base_3d_noise"},"debug_functi'.
    05 FILLER PIC X(115) VALUE 'ons":{}}                                                                                                           '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a legacy_random_source that is a number".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-2/t/data/minecraft/worldgen/noise_settings/bad.json".
    05 FILLER PIC X(115) VALUE '{"sea_level":32,"legacy_random_source":1,"disable_mob_generation":false,"noise":{"min_y":0,"height":128},"default_b'.
    05 FILLER PIC X(115) VALUE 'lock":{"id"  :"minecraft:netherrack"},"default_fluid":{"id"  :"minecraft:lava","properties":{"level":"0"}},"materia'.
    05 FILLER PIC X(115) VALUE 'l_rule":"minecraft:nether","spawn_target":[],"noise_router":{"temperature":0,"vegetation":0,"continents":0,"erosion'.
    05 FILLER PIC X(115) VALUE '":0,"depth":0,"ridges":0,"chunk_surface_level":0,"final_density":"minecraft:nether/base_3d_noise"},"debug_functions'.
    05 FILLER PIC X(115) VALUE '":[{"label":"N","function":"minecraft:nether/base_3d_noise"}]}                                                     '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a noise without base_amplitude".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-2/t/data/minecraft/worldgen/noise/bad.json".
    05 FILLER PIC X(115) VALUE '{"base_octave":-7,"octave_count":2}                                                                                '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a base_amplitude that is a string".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-2/t/data/minecraft/worldgen/noise/bad.json".
    05 FILLER PIC X(115) VALUE '{"base_octave":-7,"octave_count":2,"base_amplitude":"1"}                                                           '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "an octave_count of 0".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-2/t/data/minecraft/worldgen/noise/bad.json".
    05 FILLER PIC X(115) VALUE '{"base_octave":-7,"octave_count":0,"base_amplitude":0.9494731054427981}                                            '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "an octave_count of 33".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-2/t/data/minecraft/worldgen/noise/bad.json".
    05 FILLER PIC X(115) VALUE '{"base_octave":-7,"octave_count":33,"base_amplitude":0.9494731054427981}                                           '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a normalize that is not listed".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-2/t/data/minecraft/worldgen/noise/bad.json".
    05 FILLER PIC X(115) VALUE '{"base_octave":-7,"octave_count":2,"base_amplitude":0.9494731054427981,"normalize":"bogus"}                        '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "one amplitude modifier for two octaves (value check)".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-2/t/data/minecraft/worldgen/noise/bad.json".
    05 FILLER PIC X(115) VALUE '{"base_octave":-7,"octave_count":2,"base_amplitude":0.9494731054427981,"amplitude_modifiers":[1.0]}                '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a density function of an unknown type".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-2/t/data/minecraft/worldgen/density_function/bad.json".
    05 FILLER PIC X(115) VALUE '{"type":"minecraft:bogus"}                                                                                         '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE OCCURS 18 TIMES.
       10 WS-CASE-LABEL    PIC X(60).
       10 WS-CASE-PATH     PIC X(130).
       10 WS-CASE-BODY     PIC X(700).
 PROCEDURE DIVISION.
     CALL "WORLDGEN-FREE"
     CALL "SHAPE-FREE"
     MOVE "content/tests/fixtures/load-37-2" TO WS-DIR
     CALL "LOAD-37-2" USING WS-DIR WS-STATUS
     MOVE "acceptance US12 load 37-2 the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US12 load 37-2 3 shape elements" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US12 load 37-2 4 function rows" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WG-COUNT(WGK-FUNCTION) TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "worldgen/noise_settings" TO WS-REG
     MOVE "minecraft:nether" TO WS-KEY
     MOVE "-" TO WS-WANT-TYPE
     PERFORM FIND-CHECK
     MOVE "worldgen/noise" TO WS-REG
     MOVE "minecraft:nether/temperature" TO WS-KEY
     MOVE "-" TO WS-WANT-TYPE
     PERFORM FIND-CHECK
     MOVE "worldgen/noise" TO WS-REG
     MOVE "minecraft:nether/vegetation" TO WS-KEY
     MOVE "-" TO WS-WANT-TYPE
     PERFORM FIND-CHECK
     CALL "WORLDGEN-FREE"
     CALL "SHAPE-FREE"

     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 18
         MOVE WS-CASE-LABEL(WS-I) TO WS-T
         MOVE WS-CASE-PATH(WS-I) TO WS-PATH
         MOVE WS-CASE-BODY(WS-I) TO WS-BODY
         PERFORM BAD-CASE
     END-PERFORM
     STOP RUN.

 FIND-CHECK.
     CALL "SHAPE-FIND" USING WS-REG WS-KEY WS-ROW
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 37-2 " FUNCTION TRIM(WS-KEY) " is loaded" DELIMITED BY SIZE INTO TL-CASE
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
     STRING "acceptance US12 load 37-2 " FUNCTION TRIM(WS-KEY) " has its type row" DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-WANT-TYPE TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 BAD-CASE.
     MOVE SPACES TO WS-COMMAND
     STRING "chmod -R u+rwx build/content-test/load-37-2 2>/dev/null; rm -rf build/content-test/load-37-2; "
         "mkdir -p build/content-test/load-37-2 && cp -R content/tests/fixtures/load-37-2 build/content-test/load-37-2/t"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE SPACES TO WS-COMMAND
     STRING "mkdir -p $(dirname " FUNCTION TRIM(WS-PATH) ") && printf '%s' '" FUNCTION TRIM(WS-BODY) "' > "
         FUNCTION TRIM(WS-PATH) DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "build/content-test/load-37-2/t" TO WS-DIR
     CALL "LOAD-37-2" USING WS-DIR WS-STATUS
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 37-2 " FUNCTION TRIM(WS-T) " is CT-BAD-DATA" DELIMITED BY SIZE INTO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 37-2 after " FUNCTION TRIM(WS-T) " nothing stays" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = SH-ELEMENT-COUNT + WG-COUNT(WGK-FUNCTION) + WG-COUNT(WGK-NODE)
     PERFORM ASSERT-NUM
     CALL "WORLDGEN-FREE"
     CALL "SHAPE-FREE".

 ASSERT-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
