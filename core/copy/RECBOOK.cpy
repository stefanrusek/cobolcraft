*> The recipe book of each player row (docs/protocol/27-recipes-and-unlocks.md section 4.4; core/src/recipes-27.cob,
*> recipe-unlock.cob): EXTERNAL, one entry per CORE-PLAYERS row. RB-KNOWN(n) = 1 when the recipe of RC-STORE row n is
*> known, RB-HIGHLIGHT(n) = 1 when it is known and not yet seen. RB-OPEN and RB-FILTER hold the settings of the four book
*> types (crafting, furnace, blast furnace, smoker). RB-PENDING(n) = 1 when the recipe became known since the last Recipe Book Add. RB-SENT is 1 once the join has sent the book. RB-INVENTORY is the
*> inventory (PL-INVENTORY) the last unlock check ran over: a different inventory runs the check again.
 01 CORE-RECBOOK EXTERNAL.
    05 RB-PLAYER OCCURS 64 TIMES.
       10 RB-SENT            PIC 9.
       10 RB-INVENTORY       PIC X(288).
       10 RB-OPEN            PIC 9 OCCURS 4 TIMES.
       10 RB-FILTER          PIC 9 OCCURS 4 TIMES.
       10 RB-KNOWN           PIC 9 OCCURS 4096 TIMES.
       10 RB-HIGHLIGHT       PIC 9 OCCURS 4096 TIMES.
       10 RB-PENDING         PIC 9 OCCURS 4096 TIMES.
