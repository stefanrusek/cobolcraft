*> Entity state of lane 002-lane-p49m that rows of CORE-ENTITIES do not hold (docs/protocol/45-entity-nbt-1 to 45-9), one EK-ENTRY per tracker row (the same
*> row number as EN-ENTRY). ENTITIES' row creation clears the entry (INITIALIZE). It is a separate EXTERNAL record so that a new field does not rebuild every
*> core program (the CORESTATE.cpy fields are used by all of them).
*>   EK-NAME-*: CustomName, the tag payload as the compound holds it (any form of the text component: String, Compound or List; 45-1 section 5), kept when it
*>     fits EK-NAME-RAW (a longer one is not kept). EK-NAME-LEN 0 = no name.
*>   EK-TAG-*: Tags, a set of strings (45-1 section 5): the u16 length and the bytes of each distinct tag one after the other, at most 1024 of them and what
*>     fits EK-TAG-RAW.
*>   EK-DATA-*: data, the custom data compound payload (End tag included); an empty compound is none (EK-DATA-LEN 0).
 01 CORE-ENTITY-KEEP EXTERNAL.
    05 EK-ENTRY OCCURS 1024 TIMES.
       10 EK-NAME-LEN        BINARY-LONG.
       10 EK-NAME-TYPE       BINARY-LONG.
       10 EK-NAME-RAW        PIC X(256).
       10 EK-TAG-COUNT       BINARY-LONG.
       10 EK-TAG-LEN         BINARY-LONG.
       10 EK-TAG-RAW         PIC X(1024).
       10 EK-DATA-LEN        BINARY-LONG.
       10 EK-DATA-RAW        PIC X(1024).
