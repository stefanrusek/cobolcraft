*> What a saved mob compound said about its gameplay state (docs/protocol/45-entity-nbt-2 sections 4 and 5, 45-4, 45-5 section 4.1), collected
*> by MOB-NBT-KEY while ENTITY-NBT-ONE reads the compound and applied by MOB-NBT-APPLY once the species is known.
*> A field that the compound does not hold keeps the value ENTITY-NBT-ONE gave it: 0 (flags and counters), spaces (texts, UUIDs), -1 where 0 is
*> a real value (MQ-VARIANT-INT, MQ-SIZE, MQ-EGG).
 01 MQ-DATA.
    05 MQ-AGE              BINARY-LONG.
    05 MQ-FORCED           BINARY-LONG.
    05 MQ-LOCKED           BINARY-LONG.
    05 MQ-LOVE             BINARY-LONG.
    05 MQ-OWNER            PIC X(16).
    05 MQ-SIT              BINARY-LONG.
    05 MQ-TAME             BINARY-LONG.
    05 MQ-TRUST            BINARY-LONG.
    05 MQ-COLLAR           BINARY-LONG.
    05 MQ-SHEARED          BINARY-LONG.
    05 MQ-COLOR            BINARY-LONG.
    05 MQ-TYPE-NAME        PIC X(48).
    05 MQ-VARIANT-NAME     PIC X(48).
    05 MQ-VARIANT-INT      BINARY-LONG.
    05 MQ-STRENGTH         BINARY-LONG.
    05 MQ-TEMPER           BINARY-LONG.
    05 MQ-EGG              BINARY-LONG.
    05 MQ-GENE-MAIN        PIC X(48).
    05 MQ-GENE-HIDDEN      PIC X(48).
    05 MQ-SADDLE           BINARY-LONG.
    05 MQ-BODY             BINARY-LONG.
    05 MQ-BODY-DMG         BINARY-LONG.
    05 MQ-BABY             BINARY-LONG.
    05 MQ-POWERED          BINARY-LONG.
    05 MQ-SIZE             BINARY-LONG.
    05 MQ-LEASH            PIC X(16).
    05 MQ-PERSIST          BINARY-LONG.
    05 MQ-NOAI             BINARY-LONG.
    05 MQ-LEFTY            BINARY-LONG.
    05 MQ-PROF             PIC X(16).
    05 MQ-VLEVEL           BINARY-LONG.
