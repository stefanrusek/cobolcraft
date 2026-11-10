*> The stack patch pool (T3650 and following; docs/protocol/00 section 12.2, 17 section 1.1; core/src/stack-patch.cob): EXTERNAL.
*> A stack of the core is an item id, a count and a patch handle: 0 is the empty patch (no data component differs from the
*> item's prototype), 1 to 512 names an entry of this pool. Two stacks merge only when item and handle are equal (17 section
*> 1.1, the isSameItemSameComponents rule), which holds because an entry is interned: equal patches share one handle. The
*> slots keep the handle beside the item (PL-SLOT-VAR, PL-CARRIED-VAR of CORESTATE.cpy, MN-*-VAR of CMENU.cpy).
*> Capacity: SP-MAX-ENTRIES added components of at most SP-VALUE-MAX value bytes and as many removed type ids per patch;
*> what exceeds that is dropped when the patch is interned. SP-SWEEP frees the entries no slot of a player in the world
*> refers to when the pool is full, so a handle must be stored in a slot before the next patch is interned.
 01 CORE-STACK-PATCHES EXTERNAL.
    05 SP-ENTRY OCCURS 512 TIMES.
       COPY CSTACKE.
