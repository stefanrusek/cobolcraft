*> What a saved mob compound said about the LivingEntity and NeutralMob layers (docs/protocol/45-entity-nbt-2 sections 2 and 7), collected by
*> LIVING-NBT-KEY and applied by LIVING-NBT-APPLY. A field the compound does not hold stays 0 or spaces.
 01 LV-DATA.
    05 LV-FX-SPEED         BINARY-LONG.
    05 LV-FX-STRENGTH      BINARY-LONG.
    05 LV-FX-REGEN         BINARY-LONG.
    05 LV-FX-INVIS         BINARY-LONG.
    05 LV-FX-FIRE          BINARY-LONG.
    05 LV-FX-WATER         BINARY-LONG.
    05 LV-KILLER           PIC X(16).
    05 LV-KILLER-AGE       BINARY-LONG.
    05 LV-ANGER-SET        BINARY-LONG.
    05 LV-ANGER-END        BINARY-DOUBLE.
    05 LV-ANGRY-AT         PIC X(16).
