*> Item tint sources (docs/protocol/43-tint-sources.md section 7). TINT-ITEM is the question to
*> TINT-ITEM-COLOR: the source (TI-TYPE 1 constant, 2 dye, 3 grass, 4 firework, 5 potion, 6 team,
*> 7 custom_model_data; TI-VALUE the constant, TI-DEFAULT the default colour, TI-TEMP and TI-DOWN
*> the grass climate) and what the stack and the holder say: the dyed_color component, the
*> firework explosion colours, the potion contents (custom colour, -1 when none; effects with
*> amplifier and visibility), the holder's team colour id (-1 none) and the custom_model_data
*> colours. The answer is TI-COLOUR (ARGB).
 01 TINT-ITEM.
    05 TI-TYPE              BINARY-LONG.
    05 TI-VALUE             BINARY-DOUBLE.
    05 TI-DEFAULT           BINARY-DOUBLE.
    05 TI-TEMP              COMP-2.
    05 TI-DOWN              COMP-2.
    05 TI-HAS-DYE           BINARY-LONG.
    05 TI-DYE-RGB           BINARY-LONG.
    05 TI-FW-COUNT          BINARY-LONG.
    05 TI-FW-RGB            BINARY-LONG OCCURS 16 TIMES.
    05 TI-HAS-POTION        BINARY-LONG.
    05 TI-CUSTOM            BINARY-DOUBLE.
    05 TI-EFF-COUNT         BINARY-LONG.
    05 TI-EFF-ID            BINARY-LONG OCCURS 16 TIMES.
    05 TI-EFF-AMP           BINARY-LONG OCCURS 16 TIMES.
    05 TI-EFF-VISIBLE       BINARY-LONG OCCURS 16 TIMES.
    05 TI-TEAM-ID           BINARY-LONG.
    05 TI-CMD-COUNT         BINARY-LONG.
    05 TI-CMD-COLOUR        BINARY-DOUBLE OCCURS 16 TIMES.
    05 TI-INDEX             BINARY-LONG.
    05 TI-COLOUR            BINARY-DOUBLE.
*> Leather dye mixing (7.4): the stack's dyed colour (when TM-HAS-DYED is 1) and up to 16 dye ids.
 01 TINT-MIX.
    05 TM-HAS-DYED          BINARY-LONG.
    05 TM-DYED              BINARY-LONG.
    05 TM-COUNT             BINARY-LONG.
    05 TM-DYE               BINARY-LONG OCCURS 16 TIMES.
    05 TM-RESULT            BINARY-LONG.
