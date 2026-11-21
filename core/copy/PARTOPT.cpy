*> The option of a Level Particles particle (docs/protocol/57-client-closures-3 section 4), the argument of
*> PARTICLE-OPTION-BUILD, PARTICLE-BUILD-OPT and PARTICLE-SEND-OPT. Which fields a type reads:
*>   block family (1, 2, 36, 121, 125): PO-VARINT the block state id
*>   geyser, geyser_plume (7, 10): PO-COLOR-1 the water blocks (an Int); geyser_base, geyser_poof (8, 9): PO-COLOR-1 and PO-FLOAT
*>   dragon_breath (15) and sculk_charge (48): PO-FLOAT; shriek (115): PO-VARINT the delay
*>   dust (21): PO-COLOR-1 (the 32-bit word, 0 to 4294967295) and PO-FLOAT the scale, clamped to 0.01 .. 4.0
*>   dust_color_transition (22): PO-COLOR-1, PO-COLOR-2, PO-FLOAT the scale (clamped the same way)
*>   effect, instant_effect (23, 56): PO-COLOR-1 and PO-FLOAT the power
*>   entity_effect, tinted_leaves, flash (28, 46, 52): PO-COLOR-1 (ARGB)
*>   item (57): PO-VARINT the item id and PO-COUNT (1 or more), an empty component patch
*>   vibration (58): PO-SOURCE 0 block (PO-BX, PO-BY, PO-BZ) or 1 entity (PO-ENTITY, PO-FLOAT the y offset), then PO-VARINT the arrival ticks
*>   trail (59): PO-TX, PO-TY, PO-TZ the target, PO-COLOR-1 the colour, PO-VARINT the duration
 01 PARTICLE-OPTION.
    05 PO-VARINT             BINARY-LONG.
    05 PO-COUNT              BINARY-LONG.
    05 PO-COLOR-1            BINARY-DOUBLE.
    05 PO-COLOR-2            BINARY-DOUBLE.
    05 PO-FLOAT              FLOAT-SHORT.
    05 PO-SOURCE             BINARY-LONG.
    05 PO-ENTITY             BINARY-LONG.
    05 PO-BX                 BINARY-LONG.
    05 PO-BY                 BINARY-LONG.
    05 PO-BZ                 BINARY-LONG.
    05 PO-TX                 FLOAT-LONG.
    05 PO-TY                 FLOAT-LONG.
    05 PO-TZ                 FLOAT-LONG.
