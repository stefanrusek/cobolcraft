*> Menu state of the player rows (docs/protocol/40-menus-1-model-and-containers.md §3, §4; 13 §3.5; core/src/menus.cob,
*> menu-inventory.cob, menu-bench.cob); EXTERNAL, one entry per CORE-PLAYERS row (index MN-ENTRY by the player row).
*> The 36 inventory slots stay in PL-SLOT of CORESTATE; the rest of the player's container (armor and off-hand,
*> container slots 36 to 40: boots, leggings, chestplate, helmet, off-hand), the crafting grids and the result slot are
*> here. MN-WINDOW is the container id of the open menu (0 = the inventory menu), MN-TYPE its menu type id of the
*> registry (12 crafting; 0 for the inventory menu), MN-COUNTER the last container id given (1 to 100 cycling),
*> MN-STATE-ID the state id of an open menu other than 0 (the state id of menu 0 is PL-STATE-ID). MN-BENCH-* is the
*> block the bench menu was opened at (its position and dimension row), also the block of an open container menu. A container menu
*> (MN-WINDOW > 0 and MN-CSIZE > 0) has MN-CSIZE own slots, then the 27 main inventory and the 9 hotbar slots (40-1 section 7.2).
 01 CORE-MENUS EXTERNAL.
    05 MN-ENTRY OCCURS 64 TIMES.
       10 MN-EQUIP OCCURS 5 TIMES.
          15 MN-EQUIP-ITEM   BINARY-LONG.
          15 MN-EQUIP-COUNT  BINARY-LONG.
          15 MN-EQUIP-VAR    BINARY-LONG.            *> the patch handle of a stack (CSTACK.cpy), here and in the grids
       10 MN-IGRID OCCURS 4 TIMES.                   *> 2 x 2 grid of the inventory menu, row-major
          15 MN-IGRID-ITEM   BINARY-LONG.
          15 MN-IGRID-COUNT  BINARY-LONG.
          15 MN-IGRID-VAR    BINARY-LONG.
       10 MN-BGRID OCCURS 9 TIMES.                   *> 3 x 3 grid of the crafting bench menu, row-major
          15 MN-BGRID-ITEM   BINARY-LONG.
          15 MN-BGRID-COUNT  BINARY-LONG.
          15 MN-BGRID-VAR    BINARY-LONG.
       10 MN-RESULT-ITEM     BINARY-LONG.
       10 MN-RESULT-COUNT    BINARY-LONG.
       10 MN-RESULT-VAR      BINARY-LONG.
       10 MN-WINDOW          BINARY-LONG.
       10 MN-TYPE            BINARY-LONG.
       10 MN-COUNTER         BINARY-LONG.
       10 MN-STATE-ID        BINARY-LONG.
       10 MN-BENCH-DIM       BINARY-LONG.
       10 MN-BENCH-X         BINARY-LONG.
       10 MN-BENCH-Y         BINARY-LONG.
       10 MN-BENCH-Z         BINARY-LONG.
       10 MN-CSIZE           BINARY-LONG.            *> own slots of an open container menu (0 = none; 27 or 54), core/src/menu-container.cob
       10 MN-CFAMILY         BINARY-LONG.            *> 1 chest, trapped chest, 2 ender chest, 3 barrel, 4 shulker box
       10 MN-CBE1            BINARY-LONG.            *> the block entities the own slots are over (CORE-BE index; the second only for a double chest)
       10 MN-CBE2            BINARY-LONG.
       10 MN-CDATA           BINARY-LONG OCCURS 4 TIMES.   *> the data slots (furnace: lit, lit total, cook, cook total) as last sent
       10 MN-COPEN           BINARY-LONG OCCURS 2 TIMES.   *> the entities that count the openers (an ender chest's own block entity, else the same as MN-CBE1 and 2)
       10 MN-DRAG-ACTIVE     PIC 9.
       10 MN-DRAG-TYPE       BINARY-LONG.
       10 MN-DRAG-COUNT      BINARY-LONG.
       10 MN-DRAG-SLOT       BINARY-LONG OCCURS 90 TIMES.
