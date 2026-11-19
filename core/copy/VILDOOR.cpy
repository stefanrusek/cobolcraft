*> Doors and the walk of the villagers (lane 002-lane-bugvlclaim, T57001; docs/protocol/18 section 5.1 WALKABLE_DOOR and DOOR_IRON_CLOSED, 44 part 3 section 2.15), EXTERNAL.
*> VD-PATH-DOORS is 1 while a path is searched for a mob that opens wooden doors (a villager): STDMOB-CELL then reads a wooden door as passable. The caller sets it round STDMOB-PATH.
*> VD-CLASS is the class of every block (VL-DOOR-CLASS, built per CB-EPOCH: 1 no door, 2 a door a mob opens by hand, 3 an iron door); VD-LAST-STATE is the state GI-SOLID-CELL read last, which
*> ENTITY-BOX-HITS uses to let an open door through (the walk of a mob or an item is not stopped by an open door: the cell is taken as free, the thin panel is not modelled).
 01 VD-STATE EXTERNAL.
    05 VD-PATH-DOORS         BINARY-LONG.
    05 VD-EPOCH              BINARY-LONG.
    05 VD-LAST-STATE         BINARY-LONG.
    05 VD-CLASS              BINARY-CHAR UNSIGNED OCCURS 1400 TIMES.
