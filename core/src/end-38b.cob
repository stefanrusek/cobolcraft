*> The End's fixed values of docs/protocol/38-end.md as one lookup (sections 1, 2, 3, 7, 8, 9, 10 and 11; T1722, T1724, T1726, T1736, T1738, T1740,
*> T1742, T1744): END-CONST USING name (PIC X(32), the names of the table below, left justified), value out (BINARY-LONG, -1 for an unknown name).
*> Colours are 0xRRGGBB as integers, fractions are times 100 or 1000 as the name says.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-CONST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(32).
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-VALUE.
     EVALUATE L-NAME
*>       section 1 and 3: stages and noise settings
         WHEN "fill-min-y"
             MOVE 0 TO L-VALUE
         WHEN "fill-max-y"
             MOVE 127 TO L-VALUE
         WHEN "carvers"
             MOVE 0 TO L-VALUE
         WHEN "surface-changes-blocks"
             MOVE 0 TO L-VALUE
         WHEN "noise-min-y"
             MOVE 0 TO L-VALUE
         WHEN "noise-height"
             MOVE 128 TO L-VALUE
         WHEN "sea-level"
             MOVE 0 TO L-VALUE
         WHEN "legacy-random-source"
             MOVE 1 TO L-VALUE
         WHEN "disable-mob-generation"
             MOVE 1 TO L-VALUE
         WHEN "aquifers"
             MOVE 0 TO L-VALUE
         WHEN "spawn-targets"
             MOVE 0 TO L-VALUE
         WHEN "skipped-draws"
             MOVE 17292 TO L-VALUE
*>       section 2: the dimension type
         WHEN "min-y"
             MOVE 0 TO L-VALUE
         WHEN "height"
             MOVE 256 TO L-VALUE
         WHEN "logical-height"
             MOVE 256 TO L-VALUE
         WHEN "has-skylight"
             MOVE 1 TO L-VALUE
         WHEN "has-ceiling"
             MOVE 0 TO L-VALUE
         WHEN "has-fixed-time"
             MOVE 1 TO L-VALUE
         WHEN "has-dragon-fight"
             MOVE 1 TO L-VALUE
         WHEN "ambient-light-x100"
             MOVE 25 TO L-VALUE
         WHEN "monster-light-level"
             MOVE 15 TO L-VALUE
         WHEN "monster-block-light-limit"
             MOVE 0 TO L-VALUE
         WHEN "sky-color"
             MOVE 0 TO L-VALUE
         WHEN "fog-color"
             MOVE 1577752 TO L-VALUE
         WHEN "ambient-light-color"
             MOVE 4147007 TO L-VALUE
         WHEN "sky-light-color"
             MOVE 11296973 TO L-VALUE
         WHEN "sky-light-factor-x100"
             MOVE 0 TO L-VALUE
         WHEN "bed-can-set-spawn"
             MOVE 0 TO L-VALUE
         WHEN "bed-can-sleep"
             MOVE 0 TO L-VALUE
         WHEN "bed-destroy-on-use"
             MOVE 1 TO L-VALUE
         WHEN "respawn-anchor-works"
             MOVE 0 TO L-VALUE
         WHEN "music-delay-min"
             MOVE 6000 TO L-VALUE
         WHEN "music-delay-max"
             MOVE 24000 TO L-VALUE
         WHEN "mood-delay"
             MOVE 6000 TO L-VALUE
         WHEN "mood-extent"
             MOVE 8 TO L-VALUE
*>       section 7: the biome source
         WHEN "disc-radius-chunks"
             MOVE 64 TO L-VALUE
         WHEN "highlands-above-x10000"
             MOVE 2500 TO L-VALUE
         WHEN "midlands-from-x10000"
             MOVE -625 TO L-VALUE
         WHEN "small-islands-below-x10000"
             MOVE -2187 TO L-VALUE
*>       section 8: the placed features
         WHEN "island-rarity"
             MOVE 14 TO L-VALUE
         WHEN "island-min-y"
             MOVE 55 TO L-VALUE
         WHEN "island-max-y"
             MOVE 70 TO L-VALUE
         WHEN "gateway-rarity"
             MOVE 700 TO L-VALUE
         WHEN "gateway-exit-x"
             MOVE 100 TO L-VALUE
         WHEN "gateway-exit-y"
             MOVE 50 TO L-VALUE
         WHEN "gateway-exit-z"
             MOVE 0 TO L-VALUE
         WHEN "chorus-count-max"
             MOVE 4 TO L-VALUE
         WHEN "spike-step"
             MOVE 4 TO L-VALUE
         WHEN "platform-x"
             MOVE 100 TO L-VALUE
         WHEN "platform-y"
             MOVE 49 TO L-VALUE
         WHEN "platform-z"
             MOVE 0 TO L-VALUE
*>       section 9: arrival, return, void
         WHEN "spawn-x"
             MOVE 100 TO L-VALUE
         WHEN "spawn-y"
             MOVE 50 TO L-VALUE
         WHEN "spawn-z"
             MOVE 0 TO L-VALUE
         WHEN "arrival-yaw"
             MOVE 90 TO L-VALUE
         WHEN "platform-floor-y"
             MOVE 48 TO L-VALUE
         WHEN "platform-half"
             MOVE 2 TO L-VALUE
         WHEN "platform-air-layers"
             MOVE 3 TO L-VALUE
         WHEN "void-y"
             MOVE -64 TO L-VALUE
         WHEN "void-damage-x10"
             MOVE 40 TO L-VALUE
         WHEN "build-limit-y"
             MOVE 255 TO L-VALUE
*>       section 10: end cities
         WHEN "city-spacing"
             MOVE 20 TO L-VALUE
         WHEN "city-separation"
             MOVE 11 TO L-VALUE
         WHEN "city-salt"
             MOVE 10387313 TO L-VALUE
*>       section 11: the sky and the flash
         WHEN "flash-window"
             MOVE 600 TO L-VALUE
         WHEN "flash-sound-delay"
             MOVE 30 TO L-VALUE
         WHEN "flash-height"
             MOVE 100 TO L-VALUE
         WHEN "flash-scale"
             MOVE 60 TO L-VALUE
         WHEN "sky-box-half-size"
             MOVE 100 TO L-VALUE
         WHEN "sky-box-quads"
             MOVE 6 TO L-VALUE
         WHEN "sky-box-colour"
             MOVE 2631720 TO L-VALUE
         WHEN OTHER
             MOVE -1 TO L-VALUE
     END-EVALUATE
     GOBACK.
 END PROGRAM END-CONST.
