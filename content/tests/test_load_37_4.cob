*> Test of the loader of docs/protocol/37-nether-4...md (T-phase 23): LOAD-37-4 USING root (PIC X(1100): the folder that
*> holds data/), status out (CT-OK, or CT-BAD-DATA with every error on standard error and nothing of the part left
*> loaded) loads the Nether surface rules and the nether_cave carver. Fixture tree content/tests/fixtures/load-37-4
*> (accept cases: one file per documented file shape); each reject case writes one bad file into a fresh copy of it. Case
*> names start 'acceptance US12 load 37-4 '.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOAD-37-4.
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
    05 FILLER PIC X(60) VALUE "a carver without type".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-4/t/data/minecraft/worldgen/carver/bad.json".
    05 FILLER PIC X(115) VALUE '{"probability":0.2,"y":{"min_inclusive":{"absolute":0},"max_inclusive":{"below_top":1},"type":"minecraft:uniform"},'.
    05 FILLER PIC X(115) VALUE '"count":9,"floor_level":-0.7,"horizontal_radius_multiplier":1.0,"vertical_radius_multiplier":1.0,"room_vertical_rad'.
    05 FILLER PIC X(115) VALUE 'ius_multiplier":0.5,"start_vertical_radius_multiplier":5.0,"thickness":{"type":"minecraft:trapezoid","min":0.0,"max'.
    05 FILLER PIC X(115) VALUE '":6.0,"plateau":2.0}}                                                                                              '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a carver of an unknown type (strict)".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-4/t/data/minecraft/worldgen/carver/bad.json".
    05 FILLER PIC X(115) VALUE '{"type":"minecraft:tunnel","probability":0.2,"y":{"min_inclusive":{"absolute":0},"max_inclusive":{"below_top":1},"t'.
    05 FILLER PIC X(115) VALUE 'ype":"minecraft:uniform"},"count":9,"floor_level":-0.7,"horizontal_radius_multiplier":1.0,"vertical_radius_multipli'.
    05 FILLER PIC X(115) VALUE 'er":1.0,"room_vertical_radius_multiplier":0.5,"start_vertical_radius_multiplier":5.0,"thickness":{"type":"minecraft'.
    05 FILLER PIC X(115) VALUE ':trapezoid","min":0.0,"max":6.0,"plateau":2.0}}                                                                    '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a cave without probability".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-4/t/data/minecraft/worldgen/carver/bad.json".
    05 FILLER PIC X(115) VALUE '{"type":"minecraft:cave","y":{"min_inclusive":{"absolute":0},"max_inclusive":{"below_top":1},"type":"minecraft:unif'.
    05 FILLER PIC X(115) VALUE 'orm"},"count":9,"floor_level":-0.7,"horizontal_radius_multiplier":1.0,"vertical_radius_multiplier":1.0,"room_vertic'.
    05 FILLER PIC X(115) VALUE 'al_radius_multiplier":0.5,"start_vertical_radius_multiplier":5.0,"thickness":{"type":"minecraft:trapezoid","min":0.'.
    05 FILLER PIC X(115) VALUE '0,"max":6.0,"plateau":2.0}}                                                                                        '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a probability above 1".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-4/t/data/minecraft/worldgen/carver/bad.json".
    05 FILLER PIC X(115) VALUE '{"type":"minecraft:cave","probability":1.5,"y":{"min_inclusive":{"absolute":0},"max_inclusive":{"below_top":1},"typ'.
    05 FILLER PIC X(115) VALUE 'e":"minecraft:uniform"},"count":9,"floor_level":-0.7,"horizontal_radius_multiplier":1.0,"vertical_radius_multiplier'.
    05 FILLER PIC X(115) VALUE '":1.0,"room_vertical_radius_multiplier":0.5,"start_vertical_radius_multiplier":5.0,"thickness":{"type":"minecraft:t'.
    05 FILLER PIC X(115) VALUE 'rapezoid","min":0.0,"max":6.0,"plateau":2.0}}                                                                      '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a probability that is a string".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-4/t/data/minecraft/worldgen/carver/bad.json".
    05 FILLER PIC X(115) VALUE '{"type":"minecraft:cave","probability":"0.2","y":{"min_inclusive":{"absolute":0},"max_inclusive":{"below_top":1},"t'.
    05 FILLER PIC X(115) VALUE 'ype":"minecraft:uniform"},"count":9,"floor_level":-0.7,"horizontal_radius_multiplier":1.0,"vertical_radius_multipli'.
    05 FILLER PIC X(115) VALUE 'er":1.0,"room_vertical_radius_multiplier":0.5,"start_vertical_radius_multiplier":5.0,"thickness":{"type":"minecraft'.
    05 FILLER PIC X(115) VALUE ':trapezoid","min":0.0,"max":6.0,"plateau":2.0}}                                                                    '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a cave without y".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-4/t/data/minecraft/worldgen/carver/bad.json".
    05 FILLER PIC X(115) VALUE '{"type":"minecraft:cave","probability":0.2,"count":9,"floor_level":-0.7,"horizontal_radius_multiplier":1.0,"vertica'.
    05 FILLER PIC X(115) VALUE 'l_radius_multiplier":1.0,"room_vertical_radius_multiplier":0.5,"start_vertical_radius_multiplier":5.0,"thickness":{'.
    05 FILLER PIC X(115) VALUE '"type":"minecraft:trapezoid","min":0.0,"max":6.0,"plateau":2.0}}                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a y that is a string".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-4/t/data/minecraft/worldgen/carver/bad.json".
    05 FILLER PIC X(115) VALUE '{"type":"minecraft:cave","probability":0.2,"y":"x","count":9,"floor_level":-0.7,"horizontal_radius_multiplier":1.0,'.
    05 FILLER PIC X(115) VALUE '"vertical_radius_multiplier":1.0,"room_vertical_radius_multiplier":0.5,"start_vertical_radius_multiplier":5.0,"thic'.
    05 FILLER PIC X(115) VALUE 'kness":{"type":"minecraft:trapezoid","min":0.0,"max":6.0,"plateau":2.0}}                                           '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a cave without count".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-4/t/data/minecraft/worldgen/carver/bad.json".
    05 FILLER PIC X(115) VALUE '{"type":"minecraft:cave","probability":0.2,"y":{"min_inclusive":{"absolute":0},"max_inclusive":{"below_top":1},"typ'.
    05 FILLER PIC X(115) VALUE 'e":"minecraft:uniform"},"floor_level":-0.7,"horizontal_radius_multiplier":1.0,"vertical_radius_multiplier":1.0,"roo'.
    05 FILLER PIC X(115) VALUE 'm_vertical_radius_multiplier":0.5,"start_vertical_radius_multiplier":5.0,"thickness":{"type":"minecraft:trapezoid",'.
    05 FILLER PIC X(115) VALUE '"min":0.0,"max":6.0,"plateau":2.0}}                                                                                '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a thickness that is a boolean".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-4/t/data/minecraft/worldgen/carver/bad.json".
    05 FILLER PIC X(115) VALUE '{"type":"minecraft:cave","probability":0.2,"y":{"min_inclusive":{"absolute":0},"max_inclusive":{"below_top":1},"typ'.
    05 FILLER PIC X(115) VALUE 'e":"minecraft:uniform"},"count":9,"floor_level":-0.7,"horizontal_radius_multiplier":1.0,"vertical_radius_multiplier'.
    05 FILLER PIC X(115) VALUE '":1.0,"room_vertical_radius_multiplier":0.5,"start_vertical_radius_multiplier":5.0,"thickness":true}               '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a weird_thickness_bias that is a number".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-4/t/data/minecraft/worldgen/carver/bad.json".
    05 FILLER PIC X(115) VALUE '{"type":"minecraft:cave","probability":0.2,"y":{"min_inclusive":{"absolute":0},"max_inclusive":{"below_top":1},"typ'.
    05 FILLER PIC X(115) VALUE 'e":"minecraft:uniform"},"count":9,"floor_level":-0.7,"horizontal_radius_multiplier":1.0,"vertical_radius_multiplier'.
    05 FILLER PIC X(115) VALUE '":1.0,"room_vertical_radius_multiplier":0.5,"start_vertical_radius_multiplier":5.0,"thickness":{"type":"minecraft:t'.
    05 FILLER PIC X(115) VALUE 'rapezoid","min":0.0,"max":6.0,"plateau":2.0},"weird_thickness_bias":1}                                             '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a float provider of an unknown type (value check)".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-4/t/data/minecraft/worldgen/carver/bad.json".
    05 FILLER PIC X(115) VALUE '{"type":"minecraft:cave","probability":0.2,"y":{"min_inclusive":{"absolute":0},"max_inclusive":{"below_top":1},"typ'.
    05 FILLER PIC X(115) VALUE 'e":"minecraft:uniform"},"count":9,"floor_level":-0.7,"horizontal_radius_multiplier":1.0,"vertical_radius_multiplier'.
    05 FILLER PIC X(115) VALUE '":1.0,"room_vertical_radius_multiplier":0.5,"start_vertical_radius_multiplier":5.0,"thickness":{"type":"minecraft:b'.
    05 FILLER PIC X(115) VALUE 'ogus"}}                                                                                                            '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a canyon without shape".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-4/t/data/minecraft/worldgen/carver/bad.json".
    05 FILLER PIC X(115) VALUE '{"type":"minecraft:canyon","probability":0.01,"y":{"type":"minecraft:biased_to_bottom","min_inclusive":{"absolute":'.
    05 FILLER PIC X(115) VALUE '10},"max_inclusive":{"absolute":67},"inner":3},"vertical_rotation":{"type":"minecraft:uniform","min_inclusive":-0.1'.
    05 FILLER PIC X(115) VALUE '25,"max_exclusive":0.125}}                                                                                         '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a canyon shape without width_smoothness".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-4/t/data/minecraft/worldgen/carver/bad.json".
    05 FILLER PIC X(115) VALUE '{"type":"minecraft:canyon","probability":0.01,"y":{"type":"minecraft:biased_to_bottom","min_inclusive":{"absolute":'.
    05 FILLER PIC X(115) VALUE '10},"max_inclusive":{"absolute":67},"inner":3},"vertical_rotation":{"type":"minecraft:uniform","min_inclusive":-0.1'.
    05 FILLER PIC X(115) VALUE '25,"max_exclusive":0.125},"shape":{"distance_factor":{"type":"minecraft:uniform","min_inclusive":0.75,"max_exclusiv'.
    05 FILLER PIC X(115) VALUE 'e":1.0},"horizontal_radius_factor":{"type":"minecraft:uniform","min_inclusive":0.75,"max_exclusive":1.0},"thickness'.
    05 FILLER PIC X(115) VALUE '":{"type":"minecraft:trapezoid","min":0.0,"max":6.0,"plateau":2.0},"vertical_radius_center_factor":0.0,"vertical_ra'.
    05 FILLER PIC X(115) VALUE 'dius_default_factor":1.0,"y_scale":3.0}}                                                                           '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a width_smoothness that is fractional".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-4/t/data/minecraft/worldgen/carver/bad.json".
    05 FILLER PIC X(115) VALUE '{"type":"minecraft:canyon","probability":0.01,"y":{"type":"minecraft:biased_to_bottom","min_inclusive":{"absolute":'.
    05 FILLER PIC X(115) VALUE '10},"max_inclusive":{"absolute":67},"inner":3},"vertical_rotation":{"type":"minecraft:uniform","min_inclusive":-0.1'.
    05 FILLER PIC X(115) VALUE '25,"max_exclusive":0.125},"shape":{"distance_factor":{"type":"minecraft:uniform","min_inclusive":0.75,"max_exclusiv'.
    05 FILLER PIC X(115) VALUE 'e":1.0},"horizontal_radius_factor":{"type":"minecraft:uniform","min_inclusive":0.75,"max_exclusive":1.0},"thickness'.
    05 FILLER PIC X(115) VALUE '":{"type":"minecraft:trapezoid","min":0.0,"max":6.0,"plateau":2.0},"vertical_radius_center_factor":0.0,"vertical_ra'.
    05 FILLER PIC X(115) VALUE 'dius_default_factor":1.0,"width_smoothness":1.5,"y_scale":3.0}}                                                    '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a canyon without vertical_rotation".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-4/t/data/minecraft/worldgen/carver/bad.json".
    05 FILLER PIC X(115) VALUE '{"type":"minecraft:canyon","probability":0.01,"y":{"type":"minecraft:biased_to_bottom","min_inclusive":{"absolute":'.
    05 FILLER PIC X(115) VALUE '10},"max_inclusive":{"absolute":67},"inner":3},"shape":{"distance_factor":{"type":"minecraft:uniform","min_inclusiv'.
    05 FILLER PIC X(115) VALUE 'e":0.75,"max_exclusive":1.0},"horizontal_radius_factor":{"type":"minecraft:uniform","min_inclusive":0.75,"max_exclu'.
    05 FILLER PIC X(115) VALUE 'sive":1.0},"thickness":{"type":"minecraft:trapezoid","min":0.0,"max":6.0,"plateau":2.0},"vertical_radius_center_fac'.
    05 FILLER PIC X(115) VALUE 'tor":0.0,"vertical_radius_default_factor":1.0,"width_smoothness":3,"y_scale":3.0}}                                 '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a surface rule of an unknown type".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-4/t/data/minecraft/worldgen/material_rule/bad.json".
    05 FILLER PIC X(115) VALUE '{"type":"minecraft:bogus"}                                                                                         '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a surface condition of an unknown type".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-4/t/data/minecraft/worldgen/material_condition/bad.json".
    05 FILLER PIC X(115) VALUE '{"type":"minecraft:bogus"}                                                                                         '.
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
     MOVE "content/tests/fixtures/load-37-4" TO WS-DIR
     CALL "LOAD-37-4" USING WS-DIR WS-STATUS
     MOVE "acceptance US12 load 37-4 the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US12 load 37-4 3 shape elements" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US12 load 37-4 7 function rows" TO TL-CASE
     MOVE 7 TO TL-EXPECTED-N
     MOVE WG-COUNT(WGK-FUNCTION) TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "worldgen/carver" TO WS-REG
     MOVE "minecraft:nether_cave" TO WS-KEY
     MOVE "cave" TO WS-WANT-TYPE
     PERFORM FIND-CHECK
     MOVE "worldgen/carver" TO WS-REG
     MOVE "minecraft:cave" TO WS-KEY
     MOVE "cave" TO WS-WANT-TYPE
     PERFORM FIND-CHECK
     MOVE "worldgen/carver" TO WS-REG
     MOVE "minecraft:canyon" TO WS-KEY
     MOVE "canyon" TO WS-WANT-TYPE
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
     STRING "acceptance US12 load 37-4 " FUNCTION TRIM(WS-KEY) " is loaded" DELIMITED BY SIZE INTO TL-CASE
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
     STRING "acceptance US12 load 37-4 " FUNCTION TRIM(WS-KEY) " has its type row" DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-WANT-TYPE TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 BAD-CASE.
     MOVE SPACES TO WS-COMMAND
     STRING "chmod -R u+rwx build/content-test/load-37-4 2>/dev/null; rm -rf build/content-test/load-37-4; "
         "mkdir -p build/content-test/load-37-4 && cp -R content/tests/fixtures/load-37-4 build/content-test/load-37-4/t"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE SPACES TO WS-COMMAND
     STRING "mkdir -p $(dirname " FUNCTION TRIM(WS-PATH) ") && printf '%s' '" FUNCTION TRIM(WS-BODY) "' > "
         FUNCTION TRIM(WS-PATH) DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "build/content-test/load-37-4/t" TO WS-DIR
     CALL "LOAD-37-4" USING WS-DIR WS-STATUS
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 37-4 " FUNCTION TRIM(WS-T) " is CT-BAD-DATA" DELIMITED BY SIZE INTO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 37-4 after " FUNCTION TRIM(WS-T) " nothing stays" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = SH-ELEMENT-COUNT + WG-COUNT(WGK-FUNCTION) + WG-COUNT(WGK-NODE)
     PERFORM ASSERT-NUM
     CALL "WORLDGEN-FREE"
     CALL "SHAPE-FREE".

 ASSERT-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
