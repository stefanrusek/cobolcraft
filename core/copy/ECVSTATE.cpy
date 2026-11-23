*> Contents of the entities that hold a container (spec 002-client-polish, wrap C round 5; docs/protocol/44-residual-mob-questions-x2-continuation.md section 5 and 44-8 section 4.6): chest and hopper
*> minecarts today, EXTERNAL, one entry per tracker row, 27 slots of an item id, a count and a patch handle (the same handle as BE-SLOT-VAR). Kept apart from CORESTATE.cpy so that adding a field
*> recompiles only the programs that COPY this book. ECV-ID is the entity id the entry belongs to: an entry whose ECV-ID is not the row's EN-ID is a stale one of an entity that left the row
*> (ECV-ROW-OPEN clears it). The container size of a kind (27 chest, 5 hopper) is ECV-KIND's, not the table's.
 01 ECV-STATE EXTERNAL.
    05 ECV-ROW               OCCURS 1024 TIMES.
       10 ECV-ID             BINARY-LONG.
       10 ECV-SLOT           OCCURS 27 TIMES.
          15 ECV-ITEM        BINARY-LONG.
          15 ECV-COUNT       BINARY-LONG.
          15 ECV-VAR         BINARY-LONG.
