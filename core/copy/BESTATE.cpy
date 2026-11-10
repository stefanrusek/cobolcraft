*> Block entity state (docs/protocol/31-block-entities-1-shared-model-and-containers.md §2, §8 to §13; core/src/be-31-1.cob);
*> EXTERNAL, one entry per live block entity (BE-USED 1), addressed by its index 1 to BE-MAX. BE-DIM 0 is a detached entity
*> (no level). The slots of the container types (27) hold item id, count and the patch handle of CSTACK.cpy; BE-NAME is a
*> custom name (plain text), BE-LOCK the item key of the lock predicate, BE-LOOT/BE-SEED the loot table and its seed.
*> BE-OPEN-* is the opener counter (section 8.2; the range in thousandths of a block), BE-STATUS/BE-PROGRESS the shulker box
*> animation (section 13), BE-LID/BE-LID-OLD/BE-SHOULD-OPEN the lid controller of the chest and ender chest (section 10.3).
 78 BE-MAX                VALUE 64.
 01 CORE-BE EXTERNAL.
    05 BE-ENTRY OCCURS 64 TIMES.
       10 BE-USED           BINARY-LONG.
       10 BE-DIM            BINARY-LONG.
       10 BE-X              BINARY-LONG.
       10 BE-Y              BINARY-LONG.
       10 BE-Z              BINARY-LONG.
       10 BE-TYPE           BINARY-LONG.
       10 BE-REMOVED        BINARY-LONG.
       10 BE-CHANGED        BINARY-LONG.
       10 BE-NAME-LENGTH    BINARY-LONG.
       10 BE-NAME           PIC X(64).
       10 BE-LOCK-LENGTH    BINARY-LONG.
       10 BE-LOCK           PIC X(48).
       10 BE-LOOT-LENGTH    BINARY-LONG.
       10 BE-LOOT           PIC X(64).
       10 BE-SEED           BINARY-DOUBLE SIGNED.
       10 BE-OPEN-COUNT     BINARY-LONG.
       10 BE-OPEN-RANGE     BINARY-LONG.
       10 BE-STATUS         BINARY-LONG.
       10 BE-PROGRESS       FLOAT-SHORT.
       10 BE-PROGRESS-OLD   FLOAT-SHORT.
       10 BE-LID            FLOAT-SHORT.
       10 BE-LID-OLD        FLOAT-SHORT.
       10 BE-SHOULD-OPEN    BINARY-LONG.
       10 BE-SLOT OCCURS 27 TIMES.
          15 BE-SLOT-ITEM   BINARY-LONG.
          15 BE-SLOT-COUNT  BINARY-LONG.
          15 BE-SLOT-VAR    BINARY-LONG.
