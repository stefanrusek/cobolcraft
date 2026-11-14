*> Dimension table (standin-content §5.1, §5.2, §15.1 to §15.5, dimension type §4.6, weather §14.2),
*> transcribed. Tested by core/tests/test_content_tables.cob. Index by row number (DIM-MAIN = 1,
*> DIM-SUBROUTINE = 2; the row number minus 1 is the §12.4 dimension index). The table has
*> DIM-TABLE-ROWS (2) rows, one per dimension the game can enable (CORESTATE's CORE-MAX-DIMS), in
*> Login order.
*> DM-GENERATOR: generator id, DIM-GEN-MAIN (1) = the §5.2 surface generator, DIM-GEN-SUBROUTINE (2)
*>   = the §15.2 floor generator (GEN-SUB-* constants).
*> DM-LIGHT-POLICY: light policy id, DIM-LIGHT-STANDIN (1) = the §5.2 stand-in light policy (sky light
*>   column drop, block light by taxicab distance through non-opaque cells); DIM-LIGHT-BLOCK-ONLY (2)
*>   = §15.3: no sky light at all, block light as §5.2.
*> DM-SKYLIGHT: dimension type has_skylight (§4.6). DM-WEATHER: 1 when the dimension has weather (§14.2).
*> DM-BIOME: the biome of every cell (§15.1), -1 when the generator chooses (§5.2).
*> DM-EXTRA: 1 when the dimension is enabled only while the extra-dimensions setting is on (§15.1).
*> DM-EXTRA 2: a row of the standard world type only (never enabled for a cobolcraft world).
*> DM-BLOCK-BITS, DM-BIOME-BITS: the global palette bits of the chunk packet (06 §5.5; 5 and 2 for the cobolcraft
*>   type, 16 and 7 for the standard type).
*> DM-TRAVEL-TO: the row a goto_pad in this dimension leads to (§15.5 destination).
 78 DIM-TABLE-ROWS            VALUE 3.
 78 DIM-STANDARD-OVERWORLD    VALUE 3.
 78 DIM-MAIN                  VALUE 1.
 78 DIM-SUBROUTINE            VALUE 2.
 78 DIM-GEN-MAIN              VALUE 1.
 78 DIM-GEN-SUBROUTINE        VALUE 2.
 78 DIM-GEN-STANDARD          VALUE 3.
 78 DIM-LIGHT-STANDIN         VALUE 1.
 78 DIM-LIGHT-BLOCK-ONLY      VALUE 2.
*> The §15.2 generator: floor height h = GEN-SUB-BASE + round(GEN-SUB-AMPLITUDE x sin(x /
*> GEN-SUB-X-DIVISOR) x cos(z / GEN-SUB-Z-DIVISOR)); y 0 baseplate, 1 to h - 3 greystone, h - 2 to h
*> slag, above void; a lit glowtube at local (8, h + 1, 8) of chunks whose chunk x and z are both
*> multiples of GEN-SUB-MARKER-MOD.
 78 GEN-SUB-BASE              VALUE 32.
 78 GEN-SUB-AMPLITUDE         VALUE 5.
 78 GEN-SUB-X-DIVISOR         VALUE 11.
 78 GEN-SUB-Z-DIVISOR         VALUE 13.
 78 GEN-SUB-MARKER-MOD        VALUE 3.
*> Travel (§15.5): Use Item On a block of id TRAVEL-BLOCK (goto_pad) starts it; the arrival goto_pad
*> placed when needed has state TRAVEL-PAD-STATE; a player who travelled within the last
*> TRAVEL-COOLDOWN ticks is ignored; Respawn carries data to keep TRAVEL-KEEP (0x03).
 78 TRAVEL-BLOCK              VALUE 10.
 78 TRAVEL-PAD-STATE          VALUE 16.
 78 TRAVEL-COOLDOWN           VALUE 20.
 78 TRAVEL-KEEP               VALUE 3.
*> World spawn point (§5.2), always in cobolcraft:main: feet (4.5, 54.0, 8.5) in tenths of a block,
*> facing east: yaw -90.0, pitch 0.0 (degrees).
 78 SPAWN-X10                 VALUE 45.
 78 SPAWN-Y10                 VALUE 540.
 78 SPAWN-Z10                 VALUE 85.
 78 SPAWN-YAW                 VALUE -90.
 78 SPAWN-PITCH               VALUE 0.
 01 DIMENSION-DATA.
    05 FILLER.                                  *> row 1: cobolcraft:main (§5.1)
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
       10 FILLER BINARY-LONG VALUE -1.          *> biome: from the generator
       10 FILLER BINARY-LONG VALUE 0.           *> always enabled
       10 FILLER BINARY-LONG VALUE 2.           *> travel leads to cobolcraft:subroutine
       10 FILLER BINARY-LONG VALUE 5.           *> block palette bits (global)
       10 FILLER BINARY-LONG VALUE 2.           *> biome palette bits (global)
    05 FILLER.                                  *> row 2: cobolcraft:subroutine (§15.1)
       10 FILLER PIC X(32) VALUE "cobolcraft:subroutine".
       10 FILLER BINARY-LONG VALUE 21.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER PIC X(32) VALUE "cobolcraft:sunless".
       10 FILLER BINARY-LONG VALUE 18.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 128.
       10 FILLER BINARY-LONG VALUE 32.
       10 FILLER BINARY-LONG VALUE 2.           *> generator (DIM-GEN-SUBROUTINE)
       10 FILLER BINARY-LONG VALUE 2.           *> light policy (DIM-LIGHT-BLOCK-ONLY)
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 2.           *> biome: cobolcraft:ash_flats
       10 FILLER BINARY-LONG VALUE 1.           *> enabled by extra-dimensions
       10 FILLER BINARY-LONG VALUE 1.           *> travel leads to cobolcraft:main
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER BINARY-LONG VALUE 2.
    05 FILLER.                                  *> row 3: minecraft:overworld (standard world type; 04 §6, 06)
       10 FILLER PIC X(32) VALUE "minecraft:overworld".
       10 FILLER BINARY-LONG VALUE 19.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER PIC X(32) VALUE "minecraft:overworld".
       10 FILLER BINARY-LONG VALUE 19.
       10 FILLER BINARY-LONG VALUE -64.
       10 FILLER BINARY-LONG VALUE 384.
       10 FILLER BINARY-LONG VALUE 63.
       10 FILLER BINARY-LONG VALUE 3.           *> generator (DIM-GEN-STANDARD: void until the worldgen phase)
       10 FILLER BINARY-LONG VALUE 1.           *> light policy (DIM-LIGHT-STANDIN until the light engine of 32)
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE -1.          *> biome: from the generator
       10 FILLER BINARY-LONG VALUE 2.           *> enabled only by the standard world type
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 16.
       10 FILLER BINARY-LONG VALUE 7.
 01 DIMENSION-TABLE REDEFINES DIMENSION-DATA.
    05 DM-ENTRY OCCURS 3 TIMES.
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
       10 DM-BIOME              BINARY-LONG.
       10 DM-EXTRA              BINARY-LONG.
       10 DM-TRAVEL-TO          BINARY-LONG.
       10 DM-BLOCK-BITS         BINARY-LONG.
       10 DM-BIOME-BITS         BINARY-LONG.
