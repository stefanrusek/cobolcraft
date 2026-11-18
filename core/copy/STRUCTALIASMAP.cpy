*> The alias lookup of one start (36-10 section 2.6, core/src/struct-jig-alias.cob): the pools the alias keys resolve to, in binding order (a later binding of the same alias replaces the earlier one).
 78 JA-MAX                VALUE 32.
 01 JIG-ALIAS-MAP.
    05 JA-COUNT             BINARY-LONG.
    05 JA-REC OCCURS 32 TIMES.
       10 JA-KEY            PIC X(80).
       10 JA-TARGET         PIC X(80).
