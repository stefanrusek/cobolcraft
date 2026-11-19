*> What a saved entity compound said about the Entity base (docs/protocol/45-entity-nbt-1 section 5), collected by ENTITY-BASE-KEY while
*> ENTITY-NBT-ONE reads the compound and applied by ENTITY-BASE-APPLY: a key the compound does not hold stays 0 (its default).
 01 EB-DATA.
    05 EB-FALL             FLOAT-LONG.
    05 EB-INVULN           BINARY-LONG.
    05 EB-PORTAL           BINARY-LONG.
    05 EB-INVTIME          BINARY-LONG.
    05 EB-NAME-VIS         BINARY-LONG.
    05 EB-SILENT           BINARY-LONG.
    05 EB-NOGRAV           BINARY-LONG.
    05 EB-GLOW             BINARY-LONG.
    05 EB-FROZEN           BINARY-LONG.
    05 EB-VISFIRE          BINARY-LONG.
    05 EB-NAME-LEN         BINARY-LONG.
    05 EB-NAME-TYPE        BINARY-LONG.
    05 EB-NAME-RAW         PIC X(256).
    05 EB-TAG-COUNT        BINARY-LONG.
    05 EB-TAG-LEN          BINARY-LONG.
    05 EB-TAG-RAW          PIC X(1024).
    05 EB-DATA-LEN         BINARY-LONG.
    05 EB-DATA-RAW         PIC X(1024).
