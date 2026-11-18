*> The light engine of docs/protocol/32-light-engine.md, sections 1 to 3 (T0680, T0682, T0684): constants, dimension rules and the
*> brightness queries, the block-state inputs, the queue entry format. Program names start L32-. The engine state is the EXTERNAL
*> record L32-ENGINE of core/copy/L32.cpy (a window of 4 x 4 chunks, 4 block sections of 16 cells: light sections -1 to 4).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-LIGHT-SECTIONS.
*> USING block section count, minimum section Y; gives light section count, minimum light section Y, maximum (exclusive) (1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BLOCKS               BINARY-LONG.
 01 L-MIN                  BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-LOW                  BINARY-LONG.
 01 L-HIGH                 BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCKS L-MIN L-COUNT L-LOW L-HIGH.
     COMPUTE L-COUNT = L-BLOCKS + 2
     COMPUTE L-LOW = L-MIN - 1
     COMPUTE L-HIGH = L-LOW + L-COUNT
     GOBACK.
 END PROGRAM L32-LIGHT-SECTIONS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-NIBBLE-INDEX.
*> USING local x, y, z; gives the cell index (y << 8) | (z << 4) | x, its byte (index >> 1) and 1 when it is the low nibble (1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-BYTE                 BINARY-LONG.
 01 L-LOW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-INDEX L-BYTE L-LOW.
     COMPUTE L-INDEX = L-Y * 256 + L-Z * 16 + L-X
     DIVIDE L-INDEX BY 2 GIVING L-BYTE REMAINDER L-LOW
     COMPUTE L-LOW = 1 - L-LOW
     GOBACK.
 END PROGRAM L32-NIBBLE-INDEX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-NIBBLE-GET.
*> USING a 2048-byte layer, cell index 0 to 4095; gives the level 0 to 15 (the low nibble of byte index >> 1 for an even index).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Q                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-AREA.
    05 L-B                 BINARY-CHAR UNSIGNED OCCURS 2048 TIMES.
 01 L-INDEX                BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 PROCEDURE DIVISION USING L-AREA L-INDEX L-LEVEL.
     DIVIDE L-INDEX BY 2 GIVING WS-Q REMAINDER WS-R
     IF WS-R = 0
         COMPUTE L-LEVEL = FUNCTION MOD(L-B(WS-Q + 1), 16)
     ELSE
         COMPUTE L-LEVEL = L-B(WS-Q + 1) / 16
     END-IF
     GOBACK.
 END PROGRAM L32-NIBBLE-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-NIBBLE-SET.
*> USING a 2048-byte layer, cell index, level 0 to 15; stores the level and keeps the other nibble of the byte.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Q                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-AREA.
    05 L-B                 BINARY-CHAR UNSIGNED OCCURS 2048 TIMES.
 01 L-INDEX                BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 PROCEDURE DIVISION USING L-AREA L-INDEX L-LEVEL.
     DIVIDE L-INDEX BY 2 GIVING WS-Q REMAINDER WS-R
     ADD 1 TO WS-Q
     MOVE L-B(WS-Q) TO WS-V
     IF WS-R = 0
         COMPUTE WS-HI = WS-V / 16
         COMPUTE L-B(WS-Q) = WS-HI * 16 + L-LEVEL
     ELSE
         COMPUTE L-B(WS-Q) = L-LEVEL * 16 + FUNCTION MOD(WS-V, 16)
     END-IF
     GOBACK.
 END PROGRAM L32-NIBBLE-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-CONSTANT.
*> USING which; gives the constant of the table of 1: 1 maximum level, 2 minimum opacity, 3 light section padding, 4 section bytes, 5 nibbles.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WHICH                BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-WHICH L-VALUE.
     EVALUATE L-WHICH
         WHEN 1
             MOVE 15 TO L-VALUE
         WHEN 2
             MOVE 1 TO L-VALUE
         WHEN 3
             MOVE 1 TO L-VALUE
         WHEN 4
             MOVE 2048 TO L-VALUE
         WHEN 5
             MOVE 4096 TO L-VALUE
     END-EVALUATE
     GOBACK.
 END PROGRAM L32-CONSTANT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-DIRECTION.
*> USING ordinal 0 to 5 (DOWN, UP, NORTH, SOUTH, WEST, EAST); gives dx, dy, dz and the opposite ordinal (the low bit flipped) (1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TABLE.
    05 WS-D                OCCURS 6 TIMES.
       10 WS-DX            BINARY-LONG.
       10 WS-DY            BINARY-LONG.
       10 WS-DZ            BINARY-LONG.
 01 WS-INIT                PIC 9 VALUE 0.
 01 WS-Q                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ORD                  BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-OPP                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ORD L-DX L-DY L-DZ L-OPP.
     IF WS-INIT = 0
         MOVE 1 TO WS-INIT
         MOVE 0 TO WS-DX(1) WS-DY(1) WS-DZ(1) WS-DX(2) WS-DY(2) WS-DZ(2)
         MOVE -1 TO WS-DY(1)
         MOVE 1 TO WS-DY(2)
         MOVE 0 TO WS-DX(3) WS-DY(3) WS-DZ(3) WS-DX(4) WS-DY(4) WS-DZ(4)
         MOVE -1 TO WS-DZ(3)
         MOVE 1 TO WS-DZ(4)
         MOVE 0 TO WS-DX(5) WS-DY(5) WS-DZ(5) WS-DX(6) WS-DY(6) WS-DZ(6)
         MOVE -1 TO WS-DX(5)
         MOVE 1 TO WS-DX(6)
     END-IF
     MOVE WS-DX(L-ORD + 1) TO L-DX
     MOVE WS-DY(L-ORD + 1) TO L-DY
     MOVE WS-DZ(L-ORD + 1) TO L-DZ
     DIVIDE L-ORD BY 2 GIVING WS-Q REMAINDER WS-R
     COMPUTE L-OPP = WS-Q * 2 + 1 - WS-R
     GOBACK.
 END PROGRAM L32-DIRECTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-DIM-RULES.
*> USING dimension 1 overworld, 2 overworld_caves, 3 the_nether, 4 the_end (1.1); gives has_skylight, has_ceiling, ambient_light x 100,
*> monster_spawn_block_light_limit, monster_spawn_light_level kind (1 uniform 0 to value inclusive, 2 constant) and its value.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-SKY                  BINARY-LONG.
 01 L-CEIL                 BINARY-LONG.
 01 L-AMBIENT              BINARY-LONG.
 01 L-LIMIT                BINARY-LONG.
 01 L-LKIND                BINARY-LONG.
 01 L-LVALUE               BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-SKY L-CEIL L-AMBIENT L-LIMIT L-LKIND L-LVALUE.
     EVALUATE L-KIND
         WHEN 1
             MOVE 1 TO L-SKY
             MOVE 0 TO L-CEIL
             MOVE 0 TO L-AMBIENT
             MOVE 0 TO L-LIMIT
             MOVE 1 TO L-LKIND
             MOVE 7 TO L-LVALUE
         WHEN 2
             MOVE 1 TO L-SKY
             MOVE 1 TO L-CEIL
             MOVE 0 TO L-AMBIENT
             MOVE 0 TO L-LIMIT
             MOVE 1 TO L-LKIND
             MOVE 7 TO L-LVALUE
         WHEN 3
             MOVE 0 TO L-SKY
             MOVE 1 TO L-CEIL
             MOVE 10 TO L-AMBIENT
             MOVE 15 TO L-LIMIT
             MOVE 2 TO L-LKIND
             MOVE 7 TO L-LVALUE
         WHEN 4
             MOVE 1 TO L-SKY
             MOVE 0 TO L-CEIL
             MOVE 25 TO L-AMBIENT
             MOVE 0 TO L-LIMIT
             MOVE 2 TO L-LKIND
             MOVE 15 TO L-LVALUE
     END-EVALUATE
     GOBACK.
 END PROGRAM L32-DIM-RULES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-CAN-HAVE-WEATHER.
*> USING has_skylight, has_ceiling, dimension is the End; gives 1 for Level.canHaveWeather (1.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SKY                  BINARY-LONG.
 01 L-CEIL                 BINARY-LONG.
 01 L-END                  BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SKY L-CEIL L-END L-CAN.
     MOVE 0 TO L-CAN
     IF L-SKY = 1 AND L-CEIL = 0 AND L-END = 0
         MOVE 1 TO L-CAN
     END-IF
     GOBACK.
 END PROGRAM L32-CAN-HAVE-WEATHER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-WEATHER-STATE.
*> USING canHaveWeather, thunder level, rain level; gives isThundering (thunder > 0.9) and isRaining (rain > 0.2), each needing canHaveWeather (1.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CAN                  BINARY-LONG.
 01 L-THUNDER              FLOAT-LONG.
 01 L-RAIN                 FLOAT-LONG.
 01 L-THUNDERING           BINARY-LONG.
 01 L-RAINING              BINARY-LONG.
 PROCEDURE DIVISION USING L-CAN L-THUNDER L-RAIN L-THUNDERING L-RAINING.
     MOVE 0 TO L-THUNDERING L-RAINING
     IF L-CAN = 1 AND L-THUNDER > 0.9
         MOVE 1 TO L-THUNDERING
     END-IF
     IF L-CAN = 1 AND L-RAIN > 0.2
         MOVE 1 TO L-RAINING
     END-IF
     GOBACK.
 END PROGRAM L32-WEATHER-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-RAW-BRIGHT.
*> USING block level, sky level, darken, sky engine present; gives max(block, sky - darken), the sky term 0 when the engine is missing (1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SKY                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-BLOCK                BINARY-LONG.
 01 L-SKY                  BINARY-LONG.
 01 L-DARKEN               BINARY-LONG.
 01 L-PRESENT              BINARY-LONG.
 01 L-RAW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCK L-SKY L-DARKEN L-PRESENT L-RAW.
     MOVE 0 TO WS-SKY
     IF L-PRESENT = 1
         COMPUTE WS-SKY = L-SKY - L-DARKEN
     END-IF
     MOVE L-BLOCK TO L-RAW
     IF WS-SKY > L-RAW
         MOVE WS-SKY TO L-RAW
     END-IF
     GOBACK.
 END PROGRAM L32-RAW-BRIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-MAX-LOCAL.
*> USING x, z, block level, sky level, darken, sky engine present; gives getMaxLocalRawBrightness: 15 outside +-30 000 000 (1.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 01 L-SKY                  BINARY-LONG.
 01 L-DARKEN               BINARY-LONG.
 01 L-PRESENT              BINARY-LONG.
 01 L-RAW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Z L-BLOCK L-SKY L-DARKEN L-PRESENT L-RAW.
     IF L-X < -30000000 OR L-Z < -30000000 OR L-X >= 30000000 OR L-Z >= 30000000
         MOVE 15 TO L-RAW
     ELSE
         CALL "L32-RAW-BRIGHT" USING L-BLOCK L-SKY L-DARKEN L-PRESENT L-RAW
     END-IF
     GOBACK.
 END PROGRAM L32-MAX-LOCAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-EFFECTIVE-SKY.
*> USING sky level, skyDarken; gives max(0, sky - skyDarken) (1.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SKY                  BINARY-LONG.
 01 L-DARKEN               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-SKY L-DARKEN L-RESULT.
     COMPUTE L-RESULT = L-SKY - L-DARKEN
     COMPUTE L-RESULT = FUNCTION MAX(0, L-RESULT)
     GOBACK.
 END PROGRAM L32-EFFECTIVE-SKY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-CAN-SEE-SKY.
*> USING sky level; gives 1 when sky >= 15 (1.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SKY                  BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-SKY L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-SKY >= 15
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM L32-CAN-SEE-SKY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-BRIGHTNESS-CURVE.
*> USING integer level L, ambient_light (FLOAT-LONG); gives r = L / 15, f = r / (4 - 3r), f + ambient (1 - f) (1.1, 1.2: the light-level dependent magic
*> value and Lightmap.getBrightness).
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
 END PROGRAM L32-BRIGHTNESS-CURVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-PATH-COST.
*> USING integer level, ambient_light; gives getPathfindingCostFromLightLevels: the brightness curve minus 0.5 (1.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LEVEL                BINARY-LONG.
 01 L-AMBIENT              FLOAT-LONG.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-LEVEL L-AMBIENT L-RESULT.
     CALL "L32-BRIGHTNESS-CURVE" USING L-LEVEL L-AMBIENT L-RESULT
     COMPUTE L-RESULT = L-RESULT - 0.5
     GOBACK.
 END PROGRAM L32-PATH-COST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-DAYLIGHT.
*> USING sky level s (getEffectiveSkyBrightness), inverted, sun_angle in degrees; gives the power 0 to 15 (1.2): inverted 15 - s; else for
*> s > 0 round(s cos(a)) with a moved 20 percent of the way to 0 (a < pi) or to 2 pi; clamped to 0..15.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PI                  FLOAT-LONG VALUE 3.141592653589793.
 01 WS-A                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-V                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-S                    BINARY-LONG.
 01 L-INVERTED             BINARY-LONG.
 01 L-DEGREES              FLOAT-LONG.
 01 L-POWER                BINARY-LONG.
 PROCEDURE DIVISION USING L-S L-INVERTED L-DEGREES L-POWER.
     MOVE 0 TO WS-V
     IF L-INVERTED = 1
         COMPUTE WS-V = 15 - L-S
     ELSE
         IF L-S > 0
             COMPUTE WS-A = L-DEGREES * 0.017453292
             MOVE 0 TO WS-T
             IF WS-A >= WS-PI
                 COMPUTE WS-T = 2 * WS-PI
             END-IF
             COMPUTE WS-A = WS-A + (WS-T - WS-A) * 0.2
             COMPUTE WS-T = L-S * FUNCTION COS(WS-A) + 0.5
             COMPUTE WS-V = FUNCTION INTEGER(WS-T)
         END-IF
     END-IF
     COMPUTE L-POWER = FUNCTION MAX(0, FUNCTION MIN(15, WS-V))
     GOBACK.
 END PROGRAM L32-DAYLIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-MONSTER-DARK.
*> USING sky level at the position, nextInt(32) draw, monster_spawn_block_light_limit, block level, thundering, raw brightness with
*> darken 10, raw brightness with the default darken, one sample of monster_spawn_light_level; gives 1 for Monster.isDarkEnoughToSpawn (1.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-M                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-SKY                  BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-LIMIT                BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 01 L-THUNDER              BINARY-LONG.
 01 L-M10                  BINARY-LONG.
 01 L-MDEFAULT             BINARY-LONG.
 01 L-SAMPLE               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-SKY L-DRAW L-LIMIT L-BLOCK L-THUNDER L-M10 L-MDEFAULT L-SAMPLE L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-SKY > L-DRAW
         GOBACK
     END-IF
     IF L-LIMIT < 15 AND L-BLOCK > L-LIMIT
         GOBACK
     END-IF
     MOVE L-MDEFAULT TO WS-M
     IF L-THUNDER = 1
         MOVE L-M10 TO WS-M
     END-IF
     IF WS-M <= L-SAMPLE
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM L32-MONSTER-DARK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-LIGHT-GATES.
*> USING max local raw brightness, nextInt(4) draw, nextInt(8) draw, raw brightness (darken 0), crop age, maximum age; gives the Bat light
*> test (brightness <= draw), the Slime light test, Animal.isBrightEnoughToSpawn (raw > 8), crop growth (raw >= 9 and age below maximum) and
*> crop survival light (raw >= 8) (1.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LOCAL                BINARY-LONG.
 01 L-DRAW4                BINARY-LONG.
 01 L-DRAW8                BINARY-LONG.
 01 L-RAW                  BINARY-LONG.
 01 L-AGE                  BINARY-LONG.
 01 L-MAX-AGE              BINARY-LONG.
 01 L-BAT                  BINARY-LONG.
 01 L-SLIME                BINARY-LONG.
 01 L-ANIMAL               BINARY-LONG.
 01 L-GROW                 BINARY-LONG.
 01 L-SURVIVE              BINARY-LONG.
 PROCEDURE DIVISION USING L-LOCAL L-DRAW4 L-DRAW8 L-RAW L-AGE L-MAX-AGE L-BAT L-SLIME L-ANIMAL L-GROW L-SURVIVE.
     MOVE 0 TO L-BAT L-SLIME L-ANIMAL L-GROW L-SURVIVE
     IF L-LOCAL <= L-DRAW4
         MOVE 1 TO L-BAT
     END-IF
     IF L-LOCAL <= L-DRAW8
         MOVE 1 TO L-SLIME
     END-IF
     IF L-RAW > 8
         MOVE 1 TO L-ANIMAL
     END-IF
     IF L-RAW >= 9 AND L-AGE < L-MAX-AGE
         MOVE 1 TO L-GROW
     END-IF
     IF L-RAW >= 8
         MOVE 1 TO L-SURVIVE
     END-IF
     GOBACK.
 END PROGRAM L32-LIGHT-GATES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-SKY-BELOW-WATER.
*> USING 16 BINARY-LONG: y, sea level, canSeeSky(pos), canSeeSky(x, sea level, z), then (dampening, liquid) pairs of the cells sea level - 1
*> down to y + 1; gives LevelReader.canSeeSkyFromBelowWater (1.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-L                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-Y                 BINARY-LONG.
    05 L-SEA               BINARY-LONG.
    05 L-POS-SEES          BINARY-LONG.
    05 L-SEA-SEES          BINARY-LONG.
    05 L-CELL              OCCURS 6 TIMES.
       10 L-DAMPENING      BINARY-LONG.
       10 L-LIQUID         BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-IN L-RESULT.
     MOVE L-POS-SEES TO L-RESULT
     IF L-Y < L-SEA
         MOVE L-SEA-SEES TO L-RESULT
         COMPUTE WS-N = L-SEA - 1 - L-Y
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
             MOVE L-DAMPENING(WS-I) TO WS-D
             MOVE L-LIQUID(WS-I) TO WS-L
             IF WS-D NOT = 0 AND WS-L = 0
                 MOVE 0 TO L-RESULT
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM L32-SKY-BELOW-WATER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-MONSTER-RULES.
*> USING rule 1 checkMonsterSpawnRules, 2 checkSurfaceMonstersSpawnRules, 3 checkAnyLightMonsterSpawnRules; spawn reason (1 SPAWNER, 2
*> TRIAL_SPAWNER, 3 other), isDarkEnoughToSpawn, canSeeSky, checkMobSpawnRules; gives the rule's result (1.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CHECK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-RULE                 BINARY-LONG.
 01 L-REASON               BINARY-LONG.
 01 L-DARK                 BINARY-LONG.
 01 L-SEES                 BINARY-LONG.
 01 L-MOB                  BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-RULE L-REASON L-DARK L-SEES L-MOB L-RESULT.
     MOVE 0 TO WS-CHECK
     IF (L-REASON = 2 OR L-DARK = 1) AND L-MOB = 1
         MOVE 1 TO WS-CHECK
     END-IF
     EVALUATE L-RULE
         WHEN 1
             MOVE WS-CHECK TO L-RESULT
         WHEN 2
             MOVE 0 TO L-RESULT
             IF WS-CHECK = 1 AND (L-REASON = 1 OR L-REASON = 2 OR L-SEES = 1)
                 MOVE 1 TO L-RESULT
             END-IF
         WHEN 3
             MOVE L-MOB TO L-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM L32-MONSTER-RULES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-INIT.
*> USING sky engine present (1.1): resets the whole engine (nothing stores light, no chunk is available; 4 block sections from section Y 0; the window
*> is chunks -1 to 2), defines the preset states 0
*> (air: no emission, dampening 0, no occlusion) and 1 (bedrock: dampening 15, full faces, the state of an unloaded cell, 2.2), and
*> starts the sky storage's lowest light section at Integer.MAX_VALUE (6.8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-F                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-SKY                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SKY.
     MOVE LOW-VALUES TO L32-ENGINE
     MOVE L-SKY TO EN-SKY-ON
     MOVE 2147483647 TO LY-LOWEST(2)
     MOVE 1 TO QU-INC-HEAD(1) QU-INC-HEAD(2) QU-DEC-HEAD(1) QU-DEC-HEAD(2)
     MOVE 15 TO EN-DAMP(2)
     MOVE 1 TO EN-OCC(2)
     MOVE 4 TO EN-NS
     MOVE 6 TO EN-NL
     MOVE -1 TO EN-LOWL
     PERFORM VARYING WS-R FROM 0 BY 1 UNTIL WS-R > 3
         PERFORM VARYING WS-C FROM 0 BY 1 UNTIL WS-C > 3
             COMPUTE EN-OWN-Z(WS-R * 4 + WS-C + 1) = WS-R - 1
             COMPUTE EN-OWN-X(WS-R * 4 + WS-C + 1) = WS-C - 1
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 6
         MOVE 15 TO EN-FACE(2, WS-F)
     END-PERFORM
     GOBACK.
 END PROGRAM L32-INIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-SET-DIMENSION.
*> USING block section count (1 to 24), minimum block section Y: sizes the columns for a dimension (EN-NS, EN-MINSEC; light sections one below the lowest block
*> section to one above the highest, 1). Call it right after L32-INIT, before any chunk is made available.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 LINKAGE SECTION.
 01 L-NS                   BINARY-LONG.
 01 L-MIN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-NS L-MIN.
     MOVE L-NS TO EN-NS
     MOVE L-MIN TO EN-MINSEC
     COMPUTE EN-NL = L-NS + 2
     COMPUTE EN-LOWL = L-MIN - 1
     COMPUTE EN-MINY = L-MIN * 16
     GOBACK.
 END PROGRAM L32-SET-DIMENSION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-CLAIM-CHUNK.
*> USING chunk x, chunk z, previous owner changed (out, 1 when the slot was another chunk's): gives the chunk the slot (z + 1 mod 4) * 4 + (x + 1 mod 4) + 1 of the
*> sliding window. A slot owned by another chunk is cleared first: its blocks, availability, sky sources, section counts and every light storage of
*> both layers, so the caller saves what it needs of the old chunk and has run the queued updates beforehand.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-COL                 BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SID                 BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ L-CHANGED.
     MOVE 0 TO L-CHANGED
     COMPUTE WS-COL = FUNCTION MOD(L-CZ + 1, 4) * 4 + FUNCTION MOD(L-CX + 1, 4) + 1
     IF EN-OWN-X(WS-COL) NOT = L-CX OR EN-OWN-Z(WS-COL) NOT = L-CZ
         MOVE 1 TO L-CHANGED
         MOVE L-CX TO EN-OWN-X(WS-COL)
         MOVE L-CZ TO EN-OWN-Z(WS-COL)
         MOVE 0 TO EN-AVAIL(WS-COL) EN-PAST-INIT(WS-COL) EN-LIGHT-CORRECT(WS-COL)
         COMPUTE WS-FIRST = (WS-COL - 1) * EN-NL + 1
         COMPUTE WS-LAST = WS-COL * EN-NL
         PERFORM VARYING WS-SID FROM WS-FIRST BY 1 UNTIL WS-SID > WS-LAST
             MOVE 0 TO EN-EMPTYNOTE(WS-SID) EN-DIRTY(WS-SID)
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 2
                 MOVE 0 TO LY-STATE(WS-K, WS-SID) LY-WP(WS-K, WS-SID) LY-VP(WS-K, WS-SID) LY-QP(WS-K, WS-SID)
                 MOVE 0 TO LY-PR(WS-K, WS-SID) LY-CH(WS-K, WS-SID) LY-AF(WS-K, WS-SID) LY-NOTIFY(WS-K, WS-SID)
                 MOVE LOW-VALUES TO LY-WD(WS-K, WS-SID) LY-VD(WS-K, WS-SID) LY-QD(WS-K, WS-SID)
             END-PERFORM
         END-PERFORM
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 2
             MOVE 0 TO LY-ON(WS-K, WS-COL) LY-RETAIN(WS-K, WS-COL) LY-TOP(WS-K, WS-COL) LY-TOPSET(WS-K, WS-COL)
             MOVE 0 TO LY-VTOP(WS-K, WS-COL) LY-VTOPSET(WS-K, WS-COL)
         END-PERFORM
         COMPUTE WS-FIRST = (WS-COL - 1) * EN-NS + 1
         COMPUTE WS-LAST = WS-COL * EN-NS
         PERFORM VARYING WS-SID FROM WS-FIRST BY 1 UNTIL WS-SID > WS-LAST
             MOVE 0 TO EN-NONAIR(WS-SID)
         END-PERFORM
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
             MOVE 0 TO EN-LS(WS-COL, WS-I)
         END-PERFORM
         COMPUTE WS-BASE = (WS-COL - 1) * EN-NS * 4096
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-NS * 4096
             MOVE 0 TO EN-BLK(WS-BASE + WS-I)
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM L32-CLAIM-CHUNK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-DEFINE-STATE.
*> USING state id 0 to 39999, emission, dampening, canOcclude, useShapeForLightOcclusion, then the six face occlusion shapes (DOWN, UP, NORTH,
*> SOUTH, WEST, EAST) as quadrant masks 0 to 15 (0 empty, 15 a full face; the block registry's shapes are in 24, 2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-EMIT                 BINARY-LONG.
 01 L-DAMP                 BINARY-LONG.
 01 L-OCC                  BINARY-LONG.
 01 L-USE                  BINARY-LONG.
 01 L-F1                   BINARY-LONG.
 01 L-F2                   BINARY-LONG.
 01 L-F3                   BINARY-LONG.
 01 L-F4                   BINARY-LONG.
 01 L-F5                   BINARY-LONG.
 01 L-F6                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-EMIT L-DAMP L-OCC L-USE L-F1 L-F2 L-F3 L-F4 L-F5 L-F6.
     MOVE L-EMIT TO EN-EMIT(L-ID + 1)
     MOVE L-DAMP TO EN-DAMP(L-ID + 1)
     MOVE L-OCC TO EN-OCC(L-ID + 1)
     MOVE L-USE TO EN-USE(L-ID + 1)
     MOVE L-F1 TO EN-FACE(L-ID + 1, 1)
     MOVE L-F2 TO EN-FACE(L-ID + 1, 2)
     MOVE L-F3 TO EN-FACE(L-ID + 1, 3)
     MOVE L-F4 TO EN-FACE(L-ID + 1, 4)
     MOVE L-F5 TO EN-FACE(L-ID + 1, 5)
     MOVE L-F6 TO EN-FACE(L-ID + 1, 6)
     GOBACK.
 END PROGRAM L32-DEFINE-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-OPACITY.
*> USING state id; gives getOpacity: max(1, getLightDampening) (2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-OPACITY              BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-OPACITY.
     MOVE EN-DAMP(L-ID + 1) TO L-OPACITY
     IF L-OPACITY < 1
         MOVE 1 TO L-OPACITY
     END-IF
     GOBACK.
 END PROGRAM L32-OPACITY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-IS-EMPTY-SHAPE.
*> USING state id; gives 1 when canOcclude is false or useShapeForLightOcclusion is false (2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-EMPTY.
     MOVE 0 TO L-EMPTY
     IF EN-OCC(L-ID + 1) = 0 OR EN-USE(L-ID + 1) = 0
         MOVE 1 TO L-EMPTY
     END-IF
     GOBACK.
 END PROGRAM L32-IS-EMPTY-SHAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-DIFF-PROPS.
*> USING state ids a, b; gives hasDifferentLightProperties: false for the same state, true when the dampening or the emission differs or either
*> uses its shape for light occlusion, else false (2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-DIFF                 BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-DIFF.
     MOVE 0 TO L-DIFF
     IF L-A NOT = L-B
         IF EN-DAMP(L-A + 1) NOT = EN-DAMP(L-B + 1) OR EN-EMIT(L-A + 1) NOT = EN-EMIT(L-B + 1)
                 OR EN-USE(L-A + 1) = 1 OR EN-USE(L-B + 1) = 1
             MOVE 1 TO L-DIFF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM L32-DIFF-PROPS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-FACE-OCCLUDES.
*> USING face shapes a, b (quadrant masks); gives Shapes.faceShapeOccludes: never for two empty faces, else when together they cover the face (2.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BIT                 BINARY-LONG.
 01 WS-QA                  BINARY-LONG.
 01 WS-QB                  BINARY-LONG.
 01 WS-COVER               BINARY-LONG.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-RESULT.
     MOVE 0 TO L-RESULT
     MOVE L-A TO WS-QA
     MOVE L-B TO WS-QB
     MOVE 1 TO WS-COVER
     PERFORM 4 TIMES
         IF FUNCTION MOD(WS-QA, 2) = 0 AND FUNCTION MOD(WS-QB, 2) = 0
             MOVE 0 TO WS-COVER
         END-IF
         COMPUTE WS-QA = WS-QA / 2
         COMPUTE WS-QB = WS-QB / 2
     END-PERFORM
     COMPUTE WS-BIT = L-A + L-B
     IF WS-BIT > 0
         MOVE WS-COVER TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM L32-FACE-OCCLUDES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-OCCLUDES.
*> USING source state, neighbour state, direction ordinal; gives shapeOccludes: the face of S in the direction and of N toward S (each empty
*> when isEmptyShape) must together cover the face (2.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-EMPTY               BINARY-LONG.
 01 WS-FACE-S              BINARY-LONG.
 01 WS-FACE-N              BINARY-LONG.
 01 WS-OPP                 BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-S                    BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-S L-N L-DIR L-RESULT.
     CALL "L32-DIRECTION" USING L-DIR WS-DX WS-DY WS-DZ WS-OPP
     MOVE 0 TO WS-FACE-S WS-FACE-N
     CALL "L32-IS-EMPTY-SHAPE" USING L-S WS-EMPTY
     IF WS-EMPTY = 0
         MOVE EN-FACE(L-S + 1, L-DIR + 1) TO WS-FACE-S
     END-IF
     CALL "L32-IS-EMPTY-SHAPE" USING L-N WS-EMPTY
     IF WS-EMPTY = 0
         MOVE EN-FACE(L-N + 1, WS-OPP + 1) TO WS-FACE-N
     END-IF
     CALL "L32-FACE-OCCLUDES" USING WS-FACE-S WS-FACE-N L-RESULT
     GOBACK.
 END PROGRAM L32-OCCLUDES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-DAMPING-INTO.
*> USING from state, to state, direction, default; gives LightEngine.getLightDampeningInto (2.1, informational): the default when both
*> occlusion shapes are empty, 16 when the facing shapes occlude, else the default.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-EMPTY-A             BINARY-LONG.
 01 WS-EMPTY-B             BINARY-LONG.
 01 WS-OCCLUDES            BINARY-LONG.
 LINKAGE SECTION.
 01 L-FROM                 BINARY-LONG.
 01 L-TO                   BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-DEFAULT              BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-FROM L-TO L-DIR L-DEFAULT L-RESULT.
     MOVE L-DEFAULT TO L-RESULT
     CALL "L32-IS-EMPTY-SHAPE" USING L-FROM WS-EMPTY-A
     CALL "L32-IS-EMPTY-SHAPE" USING L-TO WS-EMPTY-B
     IF WS-EMPTY-A = 0 OR WS-EMPTY-B = 0
         CALL "L32-OCCLUDES" USING L-FROM L-TO L-DIR WS-OCCLUDES
         IF WS-OCCLUDES = 1
             MOVE 16 TO L-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM L32-DAMPING-INTO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-LOCATE.
*> USING world x, y, z; gives the column 1 to 16 (0 when the chunk does not own its slot of the window), the section id (0 outside the light
*> sections EN-LOWL to EN-LOWL + EN-NL - 1) and the nibble index of the cell in its section (1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-COL                  BINARY-LONG.
 01 L-SID                  BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-COL L-SID L-INDEX.
     MOVE 0 TO L-COL L-SID L-INDEX
     COMPUTE WS-LX = FUNCTION MOD(L-X, 16)
     COMPUTE WS-LY = FUNCTION MOD(L-Y, 16)
     COMPUTE WS-LZ = FUNCTION MOD(L-Z, 16)
     COMPUTE WS-CX = (L-X - WS-LX) / 16
     COMPUTE WS-CZ = (L-Z - WS-LZ) / 16
     COMPUTE WS-SY = (L-Y - WS-LY) / 16
     COMPUTE WS-SLOT = FUNCTION MOD(WS-CZ + 1, 4) * 4 + FUNCTION MOD(WS-CX + 1, 4) + 1
     IF EN-OWN-X(WS-SLOT) = WS-CX AND EN-OWN-Z(WS-SLOT) = WS-CZ
         MOVE WS-SLOT TO L-COL
         IF WS-SY >= EN-LOWL AND WS-SY < EN-LOWL + EN-NL
             COMPUTE L-SID = (L-COL - 1) * EN-NL + WS-SY - EN-LOWL + 1
             COMPUTE L-INDEX = WS-LY * 256 + WS-LZ * 16 + WS-LX
         END-IF
     END-IF
     GOBACK.
 END PROGRAM L32-LOCATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-AVAIL-CHUNK.
*> USING chunk x, chunk z (a chunk that owns its slot), flag: makes the chunk available to the engine's chunk getter (1) or not (0), with its sky-source table
*> filled from the chunk's cells when it becomes available (5.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-COL                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-MINV                BINARY-LONG VALUE -2147483648.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ L-FLAG.
     COMPUTE WS-COL = FUNCTION MOD(L-CZ + 1, 4) * 4 + FUNCTION MOD(L-CX + 1, 4) + 1
     MOVE L-FLAG TO EN-AVAIL(WS-COL)
     IF L-FLAG = 1
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
             MOVE WS-MINV TO EN-LS(WS-COL, WS-I)
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM L32-AVAIL-CHUNK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-SET-CELL.
*> USING x, y, z (y inside the build height), state id: stores a block state in an available chunk without any light work (the plain store of a chunk
*> that is being built), keeping the count of non-air cells of its block section.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-COL                 BINARY-LONG.
 01 WS-SID                 BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-SEC                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-STATE.
     CALL "L32-LOCATE" USING L-X L-Y L-Z WS-COL WS-SID WS-INDEX
     COMPUTE WS-CELL = (WS-COL - 1) * EN-NS * 4096 + (L-Y - EN-MINY) * 256 + FUNCTION MOD(L-Z, 16) * 16 + FUNCTION MOD(L-X, 16) + 1
     COMPUTE WS-SEC = (WS-COL - 1) * EN-NS + (L-Y - EN-MINY) / 16 + 1
     IF EN-BLK(WS-CELL) NOT = 0
         SUBTRACT 1 FROM EN-NONAIR(WS-SEC)
     END-IF
     IF L-STATE NOT = 0
         ADD 1 TO EN-NONAIR(WS-SEC)
     END-IF
     MOVE L-STATE TO EN-BLK(WS-CELL)
     GOBACK.
 END PROGRAM L32-SET-CELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-STATE-AT.
*> USING x, y, z; gives the state id at the cell (getState, 2.2): bedrock for a chunk that is not available (or outside the window), air for a
*> Y outside the block sections of an available chunk, else the stored state.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-COL                 BINARY-LONG.
 01 WS-SID                 BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-STATE.
     MOVE 1 TO L-STATE
     CALL "L32-LOCATE" USING L-X L-Y L-Z WS-COL WS-SID WS-INDEX
     IF WS-COL > 0
         IF EN-AVAIL(WS-COL) = 1
             MOVE 0 TO L-STATE
             IF L-Y >= EN-MINY AND L-Y < EN-MINY + EN-NS * 16
                 MOVE EN-BLK((WS-COL - 1) * EN-NS * 4096 + (L-Y - EN-MINY) * 256 + FUNCTION MOD(L-Z, 16) * 16 + FUNCTION MOD(L-X, 16) + 1) TO L-STATE
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM L32-STATE-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-ENTRY.
*> USING kind, level, from-empty-shape, direction; gives the queue entry (3): kind 1 decreaseAllDirections(l), 2 decreaseSkipOneDirection(l, d),
*> 3 increaseLightFromEmission(l, emptyShape), 4 increaseSkipOneDirection(l, emptyShape, d), 5 increaseOnlyOneDirection(l, emptyShape, d).
*> Bits 0-3 level, bit 4 + ordinal one direction, 1024 from empty shape, 2048 increase from emission.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BIT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-ENTRY                BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-LEVEL L-EMPTY L-DIR L-ENTRY.
     COMPUTE WS-BIT = 16 * 2 ** L-DIR
     EVALUATE L-KIND
         WHEN 1
             COMPUTE L-ENTRY = L-LEVEL + 1008
         WHEN 2
             COMPUTE L-ENTRY = L-LEVEL + 1008 - WS-BIT
         WHEN 3
             COMPUTE L-ENTRY = L-LEVEL + 1008 + 2048
         WHEN 4
             COMPUTE L-ENTRY = L-LEVEL + 1008 - WS-BIT
         WHEN 5
             COMPUTE L-ENTRY = L-LEVEL + WS-BIT
     END-EVALUATE
     IF L-EMPTY = 1 AND L-KIND >= 3
         ADD 1024 TO L-ENTRY
     END-IF
     GOBACK.
 END PROGRAM L32-ENTRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-ENTRY-SKY.
*> USING down, north, south, west, east (0 or 1); gives increaseSkySourceInDirections: level 15 and a bit per true direction, never UP (3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DOWN                 BINARY-LONG.
 01 L-NORTH                BINARY-LONG.
 01 L-SOUTH                BINARY-LONG.
 01 L-WEST                 BINARY-LONG.
 01 L-EAST                 BINARY-LONG.
 01 L-ENTRY                BINARY-LONG.
 PROCEDURE DIVISION USING L-DOWN L-NORTH L-SOUTH L-WEST L-EAST L-ENTRY.
     COMPUTE L-ENTRY = 15 + L-DOWN * 16 + L-NORTH * 64 + L-SOUTH * 128 + L-WEST * 256 + L-EAST * 512
     GOBACK.
 END PROGRAM L32-ENTRY-SKY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-ENTRY-DECODE.
*> USING entry; gives the from level, the direction bits (0 to 63, bit = ordinal), the from-empty-shape flag and the from-emission flag (3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REST                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ENTRY                BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-BITS                 BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-EMISSION             BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTRY L-LEVEL L-BITS L-EMPTY L-EMISSION.
     COMPUTE L-LEVEL = FUNCTION MOD(L-ENTRY, 16)
     COMPUTE WS-REST = L-ENTRY / 16
     COMPUTE L-BITS = FUNCTION MOD(WS-REST, 64)
     COMPUTE WS-REST = L-ENTRY / 1024
     COMPUTE L-EMPTY = FUNCTION MOD(WS-REST, 2)
     COMPUTE WS-REST = L-ENTRY / 2048
     COMPUTE L-EMISSION = FUNCTION MOD(WS-REST, 2)
     GOBACK.
 END PROGRAM L32-ENTRY-DECODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-ENTRY-CONST.
*> USING which; gives PULL_LIGHT_IN_ENTRY (1), REMOVE_TOP_SKY_SOURCE_ENTRY (2), REMOVE_SKY_SOURCE_ENTRY (3), ADD_SKY_SOURCE_ENTRY (4) (3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ALL                 BINARY-LONG VALUE 1.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-UP                  BINARY-LONG VALUE 1.
 01 WS-KIND                BINARY-LONG.
 LINKAGE SECTION.
 01 L-WHICH                BINARY-LONG.
 01 L-ENTRY                BINARY-LONG.
 PROCEDURE DIVISION USING L-WHICH L-ENTRY.
     MOVE 15 TO WS-LEVEL
     EVALUATE L-WHICH
         WHEN 1
             MOVE 1 TO WS-LEVEL
             MOVE 1 TO WS-KIND
         WHEN 2
             MOVE 1 TO WS-KIND
         WHEN 3
             MOVE 2 TO WS-KIND
         WHEN 4
             MOVE 4 TO WS-KIND
     END-EVALUATE
     CALL "L32-ENTRY" USING WS-KIND WS-LEVEL WS-NONE WS-UP L-ENTRY
     GOBACK.
 END PROGRAM L32-ENTRY-CONST.
