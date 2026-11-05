*> Dimension table (standin-content §5.1, §5.2, dimension type §4.6, weather §14.2), transcribed.
*> Tested by core/tests/test_content_tables.cob. Index by row number (DIM-MAIN = 1).
*> The table has DIM-TABLE-ROWS (2) rows, one per dimension the game can enable (CORESTATE's
*> CORE-MAX-DIMS). Row 2 is reserved for the extra dimension of §15 (cobolcraft:subroutine), added by a
*> later phase (T572); until then it holds spaces and zeros and is never enabled.
*> DM-GENERATOR: generator id, DIM-GEN-MAIN (1) = the §5.2 surface generator.
*> DM-LIGHT-POLICY: light policy id, DIM-LIGHT-STANDIN (1) = the §5.2 stand-in light policy (sky light
*>   column drop when DM-SKYLIGHT is 1, block light by taxicab distance through non-opaque cells).
*> DM-SKYLIGHT: dimension type has_skylight (§4.6). DM-WEATHER: 1 when the dimension has weather (§14.2).
 78 DIM-TABLE-ROWS            VALUE 2.
 78 DIM-MAIN                  VALUE 1.
 78 DIM-GEN-MAIN              VALUE 1.
 78 DIM-LIGHT-STANDIN         VALUE 1.
*> World spawn point (§5.2), always in cobolcraft:main: feet (4.5, 54.0, 8.5) in tenths of a block,
*> facing east: yaw -90.0, pitch 0.0 (degrees).
 78 SPAWN-X10                 VALUE 45.
 78 SPAWN-Y10                 VALUE 540.
 78 SPAWN-Z10                 VALUE 85.
 78 SPAWN-YAW                 VALUE -90.
 78 SPAWN-PITCH               VALUE 0.
 01 DIMENSION-DATA.
    05 FILLER.                                  *> row 1: cobolcraft:main
       10 FILLER PIC X(32) VALUE "cobolcraft:main".
       10 FILLER BINARY-LONG VALUE 15.          *> key length
       10 FILLER BINARY-LONG VALUE 0.           *> dimension type id
       10 FILLER PIC X(32) VALUE "cobolcraft:surface".
       10 FILLER BINARY-LONG VALUE 18.          *> dimension type key length
       10 FILLER BINARY-LONG VALUE 0.           *> min y
       10 FILLER BINARY-LONG VALUE 256.         *> height
       10 FILLER BINARY-LONG VALUE 48.          *> sea level
       10 FILLER BINARY-LONG VALUE 1.           *> generator (DIM-GEN-MAIN)
       10 FILLER BINARY-LONG VALUE 1.           *> light policy (DIM-LIGHT-STANDIN)
       10 FILLER BINARY-LONG VALUE 1.           *> has skylight
       10 FILLER BINARY-LONG VALUE 1.           *> has weather
    05 FILLER.                                  *> row 2: reserved (§15, later phase)
       10 FILLER PIC X(32) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER PIC X(32) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
 01 DIMENSION-TABLE REDEFINES DIMENSION-DATA.
    05 DM-ENTRY OCCURS 2 TIMES.
       10 DM-KEY                PIC X(32).
       10 DM-KEY-LENGTH         BINARY-LONG.
       10 DM-TYPE-ID            BINARY-LONG.
       10 DM-TYPE-KEY           PIC X(32).
       10 DM-TYPE-KEY-LENGTH    BINARY-LONG.
       10 DM-MIN-Y              BINARY-LONG.
       10 DM-HEIGHT             BINARY-LONG.
       10 DM-SEA-LEVEL          BINARY-LONG.
       10 DM-GENERATOR          BINARY-LONG.
       10 DM-LIGHT-POLICY       BINARY-LONG.
       10 DM-SKYLIGHT           BINARY-LONG.
       10 DM-WEATHER            BINARY-LONG.
