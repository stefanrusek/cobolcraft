*> Entity state of lane 002-lane-p49m that the rows of CORE-ENTITIES do not hold (docs/protocol/45-entity-nbt-1 to 45-9; fields in ENKFIELDS.cpy), one
*> EK-ENTRY per tracker row (the same row number as EN-ENTRY). ENTITY-ALLOC clears the entry (INITIALIZE) when it hands a row out. It is a separate EXTERNAL
*> record so that a new field does not rebuild every core program (the CORESTATE.cpy fields are used by all of them).
 01 CORE-ENTITY-KEEP EXTERNAL.
    05 EK-ENTRY OCCURS 1024 TIMES.
       COPY ENKFIELDS.
