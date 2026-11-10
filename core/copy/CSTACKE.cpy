*> One stack patch entry (the layout of an element of SP-ENTRY in CSTACK.cpy, levels 10 and 15): COPY it under a level 05
*> item, with REPLACING LEADING ==SP-== for a working copy. A patch is a canonical DataComponentPatch (00 section 12.2): the
*> added components sorted by type id (value bytes as the wire has them, the unused tail of SP-VALUE spaces), the removed
*> component type ids sorted, each without repeats; a damage of 0 is not an entry (17 section 1.1: the prototype value).
          10 SP-LIVE            BINARY-LONG.
          10 SP-ADDED-COUNT     BINARY-LONG.
          10 SP-REMOVED-COUNT   BINARY-LONG.
          10 SP-ADDED OCCURS 8 TIMES.
             15 SP-TYPE          BINARY-LONG.
             15 SP-LENGTH        BINARY-LONG.
             15 SP-VALUE         PIC X(2048).
          10 SP-REMOVED         BINARY-LONG OCCURS 8 TIMES.
