*> The Nether's dimension rules as pure tables and functions (docs/protocol/37-nether-1; T1621 to T1634): the scalar fields and the attribute map of the dimension type
*> minecraft:the_nether (section 2), the rules the attributes drive (section 3: water evaporation, fast lava, brightness, bed and respawn anchor rules, piglin zombification,
*> raids, snow golems), the tags (4), the sky, clock, fog and weather facts (5) and the other dimension rules (6: portal scaling, maps, storage folder, noise settings).
*> No state; the dimension plumbing (DIMENSIONS.cpy) and the engines call these.
*>
*> Entry points:
*>   NETHER-DIM-SCALAR USING code, value out (BINARY-LONG): 1 coordinate scale x1000 (8000), 2 has_skylight, 3 has_ceiling, 4 has_fixed_time, 5 has_ender_dragon_fight, 6 min_y,
*>     7 height, 8 logical_height, 9 ambient_light x1000 (100), 10 monster_spawn_light_level (constant), 11 monster_spawn_block_light_limit, 12 fog start distance,
*>     13 fog end distance, 14 sky light level, 15 sky darken ((int)(15 - level)), 16 sea level, 17 noise height, 18 noise min_y, 19 ambient light colour (RGB int),
*>     20 sky light colour (RGB int), 21 sky light factor x10 (0), 22 attribute count (15), 23 legacy random source (1); any other code gives -1
*>   NETHER-DIM-FLAG USING code, value out (1 or 0): 1 can_start_raid, 2 fast_lava, 3 piglins_zombify, 4 respawn_anchor_works, 5 snow_golem_melts, 6 water_evaporates,
*>     7 nether_portal_spawns_piglin, 8 increased_fire_burnout, 9 bed can_set_spawn, 10 bed can_sleep, 11 bed destroy_on_use (the bed rule: never set spawn, never sleep, explode),
*>     12 can have weather (has_skylight and not has_ceiling); any other code gives -1
*>   NETHER-DIM-TEXT USING code, text out (PIC X(40)), length out: 1 dimension type key, 2 infiniburn tag, 3 skybox, 4 cardinal light, 5 timelines tag, 6 default fluid,
*>     7 default block, 8 dripstone particle, 9 storage folder name (dimensions/minecraft/the_nether)
*>   NETHER-INFINIBURN USING block key (PIC X(40), with namespace), result out: 1 for netherrack and magma_block (the tag infiniburn_nether, 4.1)
*>   NETHER-LAVA-FLOW USING fast lava (1/0), tick delay, slope-find distance, drop-off out (BINARY-LONG)
*>   NETHER-LAVA-CURRENT USING fast lava (1/0), strength out (FLOAT-LONG: 0.007, or 0.007 / 3)
*>   NETHER-BRIGHTNESS USING light level 0 to 15, ambient light (FLOAT-LONG), brightness out (FLOAT-LONG): f + ambient x (1 - f), f = r / (4 - 3 r), r = level / 15
*>   NETHER-FACE-SHADE USING face (0 down, 1 up, 2 north, 3 south, 4 west, 5 east), shade x10 out: the cardinal light of the Nether (9, 9, 8, 8, 6, 6)
*>   NETHER-PORTAL-SCALE USING from dimension, to dimension (0 overworld, 1 the nether, 2 the end), x, z (FLOAT-LONG, entry position), x out, z out, ok out (1 for overworld <-> nether)
*>   NETHER-SNOW-CELLS USING golem x, y, z (FLOAT-LONG), i (0 to 3), cell x, y, z out (BINARY-LONG): the four cells of 3.9
*>   NETHER-MAP-HALF USING map scale (0 to 4), has ceiling (1/0), half extent out: 128 / (1 << scale), halved again with a ceiling
*>   NETHER-MAP-PIXEL USING loop x, loop z (BINARY-LONG), kind out (1 dirt weight 10, 2 stone weight 100), weight out: the ceiling hash of 6.4

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-DIM-SCALAR.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CODE                 BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-CODE L-VALUE.
     EVALUATE L-CODE
         WHEN 1
             MOVE 8000 TO L-VALUE
         WHEN 2
             MOVE 0 TO L-VALUE
         WHEN 3
             MOVE 1 TO L-VALUE
         WHEN 4
             MOVE 1 TO L-VALUE
         WHEN 5
             MOVE 0 TO L-VALUE
         WHEN 6
             MOVE 0 TO L-VALUE
         WHEN 7
             MOVE 256 TO L-VALUE
         WHEN 8
             MOVE 128 TO L-VALUE
         WHEN 9
             MOVE 100 TO L-VALUE
         WHEN 10
             MOVE 7 TO L-VALUE
         WHEN 11
             MOVE 15 TO L-VALUE
         WHEN 12
             MOVE 10 TO L-VALUE
         WHEN 13
             MOVE 96 TO L-VALUE
         WHEN 14
             MOVE 4 TO L-VALUE
         WHEN 15
             MOVE 11 TO L-VALUE
         WHEN 16
             MOVE 32 TO L-VALUE
         WHEN 17
             MOVE 128 TO L-VALUE
         WHEN 18
             MOVE 0 TO L-VALUE
         WHEN 19
             MOVE 3156001 TO L-VALUE
         WHEN 20
             MOVE 8026879 TO L-VALUE
         WHEN 21
             MOVE 0 TO L-VALUE
         WHEN 22
             MOVE 15 TO L-VALUE
         WHEN 23
             MOVE 1 TO L-VALUE
         WHEN OTHER
             MOVE -1 TO L-VALUE
     END-EVALUATE
     GOBACK.
 END PROGRAM NETHER-DIM-SCALAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-DIM-FLAG.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CODE                BINARY-LONG.
 01 WS-SKYLIGHT            BINARY-LONG.
 01 WS-CEILING             BINARY-LONG.
 LINKAGE SECTION.
 01 L-CODE                 BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-CODE L-VALUE.
     EVALUATE L-CODE
         WHEN 2
         WHEN 4
         WHEN 5
         WHEN 6
         WHEN 11
             MOVE 1 TO L-VALUE
         WHEN 1
         WHEN 3
         WHEN 7
         WHEN 8
         WHEN 9
         WHEN 10
             MOVE 0 TO L-VALUE
         WHEN 12
             MOVE 2 TO WS-CODE
             CALL "NETHER-DIM-SCALAR" USING WS-CODE WS-SKYLIGHT
             MOVE 3 TO WS-CODE
             CALL "NETHER-DIM-SCALAR" USING WS-CODE WS-CEILING
             COMPUTE L-VALUE = WS-SKYLIGHT * (1 - WS-CEILING)
         WHEN OTHER
             MOVE -1 TO L-VALUE
     END-EVALUATE
     GOBACK.
 END PROGRAM NETHER-DIM-FLAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-DIM-TEXT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CODE                 BINARY-LONG.
 01 L-TEXT                 PIC X(40).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-CODE L-TEXT L-LENGTH.
     MOVE SPACES TO L-TEXT
     EVALUATE L-CODE
         WHEN 1
             MOVE "minecraft:the_nether" TO L-TEXT
         WHEN 2
             MOVE "#minecraft:infiniburn_nether" TO L-TEXT
         WHEN 3
             MOVE "none" TO L-TEXT
         WHEN 4
             MOVE "nether" TO L-TEXT
         WHEN 5
             MOVE "#minecraft:in_nether" TO L-TEXT
         WHEN 6
             MOVE "minecraft:lava" TO L-TEXT
         WHEN 7
             MOVE "minecraft:netherrack" TO L-TEXT
         WHEN 8
             MOVE "minecraft:dripping_dripstone_lava" TO L-TEXT
         WHEN 9
             MOVE "dimensions/minecraft/the_nether" TO L-TEXT
         WHEN OTHER
             CONTINUE
     END-EVALUATE
     MOVE FUNCTION LENGTH(FUNCTION TRIM(L-TEXT TRAILING)) TO L-LENGTH
     IF L-TEXT = SPACES
         MOVE 0 TO L-LENGTH
     END-IF
     GOBACK.
 END PROGRAM NETHER-DIM-TEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-INFINIBURN.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(40).
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-KEY = "minecraft:netherrack" OR L-KEY = "minecraft:magma_block"
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM NETHER-INFINIBURN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-LAVA-FLOW.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FAST                 BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-SLOPE                BINARY-LONG.
 01 L-DROP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-FAST L-DELAY L-SLOPE L-DROP.
     IF L-FAST = 1
         MOVE 10 TO L-DELAY
         MOVE 4 TO L-SLOPE
         MOVE 1 TO L-DROP
     ELSE
         MOVE 30 TO L-DELAY
         MOVE 2 TO L-SLOPE
         MOVE 2 TO L-DROP
     END-IF
     GOBACK.
 END PROGRAM NETHER-LAVA-FLOW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-LAVA-CURRENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FAST-STRENGTH       FLOAT-LONG VALUE 0.007.
 01 WS-THREE               FLOAT-LONG VALUE 3.
 LINKAGE SECTION.
 01 L-FAST                 BINARY-LONG.
 01 L-STRENGTH             FLOAT-LONG.
 PROCEDURE DIVISION USING L-FAST L-STRENGTH.
     IF L-FAST = 1
         MOVE WS-FAST-STRENGTH TO L-STRENGTH
     ELSE
         COMPUTE L-STRENGTH = WS-FAST-STRENGTH / WS-THREE
     END-IF
     GOBACK.
 END PROGRAM NETHER-LAVA-CURRENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-BRIGHTNESS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-LEVEL                BINARY-LONG.
 01 L-AMBIENT              FLOAT-LONG.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-LEVEL L-AMBIENT L-RESULT.
     COMPUTE WS-R = L-LEVEL / 15
     COMPUTE WS-F = WS-R / (4 - 3 * WS-R)
     COMPUTE L-RESULT = WS-F + L-AMBIENT * (1 - WS-F)
     GOBACK.
 END PROGRAM NETHER-BRIGHTNESS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-FACE-SHADE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FACE                 BINARY-LONG.
 01 L-SHADE                BINARY-LONG.
 PROCEDURE DIVISION USING L-FACE L-SHADE.
     EVALUATE L-FACE
         WHEN 0
         WHEN 1
             MOVE 9 TO L-SHADE
         WHEN 2
         WHEN 3
             MOVE 8 TO L-SHADE
         WHEN OTHER
             MOVE 6 TO L-SHADE
     END-EVALUATE
     GOBACK.
 END PROGRAM NETHER-FACE-SHADE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-PORTAL-SCALE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-EIGHTH              FLOAT-LONG VALUE 0.125.
 01 WS-EIGHT               FLOAT-LONG VALUE 8.
 LINKAGE SECTION.
 01 L-FROM                 BINARY-LONG.
 01 L-TO                   BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-XOUT                 FLOAT-LONG.
 01 L-ZOUT                 FLOAT-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-FROM L-TO L-X L-Z L-XOUT L-ZOUT L-OK.
     MOVE L-X TO L-XOUT
     MOVE L-Z TO L-ZOUT
     MOVE 0 TO L-OK
     IF L-FROM = 0 AND L-TO = 1
         COMPUTE L-XOUT = L-X * WS-EIGHTH
         COMPUTE L-ZOUT = L-Z * WS-EIGHTH
         MOVE 1 TO L-OK
     END-IF
     IF L-FROM = 1 AND L-TO = 0
         COMPUTE L-XOUT = L-X * WS-EIGHT
         COMPUTE L-ZOUT = L-Z * WS-EIGHT
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM NETHER-PORTAL-SCALE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-SNOW-CELLS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OFFSET              FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-I                    BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CY                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-I L-CX L-CY L-CZ.
     MOVE -0.25 TO WS-OFFSET
     IF FUNCTION MOD(L-I, 2) = 1
         MOVE 0.25 TO WS-OFFSET
     END-IF
     COMPUTE WS-T = L-X + WS-OFFSET
     COMPUTE L-CX = FUNCTION INTEGER(WS-T)
     COMPUTE L-CY = FUNCTION INTEGER(L-Y)
     MOVE -0.25 TO WS-OFFSET
     IF L-I >= 2
         MOVE 0.25 TO WS-OFFSET
     END-IF
     COMPUTE WS-T = L-Z + WS-OFFSET
     COMPUTE L-CZ = FUNCTION INTEGER(WS-T)
     GOBACK.
 END PROGRAM NETHER-SNOW-CELLS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-MAP-HALF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIV                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-SCALE                BINARY-LONG.
 01 L-CEILING              BINARY-LONG.
 01 L-HALF                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SCALE L-CEILING L-HALF.
     COMPUTE WS-DIV = 2 ** L-SCALE
     DIVIDE 128 BY WS-DIV GIVING L-HALF
     IF L-CEILING = 1
         DIVIDE L-HALF BY 2 GIVING L-HALF
     END-IF
     GOBACK.
 END PROGRAM NETHER-MAP-HALF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-MAP-PIXEL.
*> h = x + z * 231871, then h = h * h * 31287121 + h * 11, both as 32-bit wrap; bit 20 clear: dirt (weight 10), set: stone (weight 100).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-M32                 BINARY-DOUBLE UNSIGNED VALUE 4294967296.
 01 WS-H                   BINARY-DOUBLE UNSIGNED.
 01 WS-H2                  BINARY-DOUBLE UNSIGNED.
 01 WS-Q                   BINARY-DOUBLE UNSIGNED.
 01 WS-BIT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-WEIGHT               BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Z L-KIND L-WEIGHT.
     COMPUTE WS-H = FUNCTION MOD(L-X + L-Z * 231871, WS-M32)
     COMPUTE WS-H2 = FUNCTION MOD(WS-H * WS-H, WS-M32)
     COMPUTE WS-H = FUNCTION MOD(WS-H2 * 31287121 + WS-H * 11, WS-M32)
     DIVIDE WS-H BY 1048576 GIVING WS-Q
     COMPUTE WS-BIT = FUNCTION MOD(WS-Q, 2)
     IF WS-BIT = 0
         MOVE 1 TO L-KIND
         MOVE 10 TO L-WEIGHT
     ELSE
         MOVE 2 TO L-KIND
         MOVE 100 TO L-WEIGHT
     END-IF
     GOBACK.
 END PROGRAM NETHER-MAP-PIXEL.
