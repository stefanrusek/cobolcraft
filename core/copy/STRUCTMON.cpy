*> The ocean monument being generated (docs/protocol/36-structures-6-ocean.md section 5; core/src/struct-monument.cob). EXTERNAL, core-private, one start at a time.
*> MO-DEF holds the 49 room definitions of 5.2 and 5.3 by slot: slot i + 1 is the grid room of index i (0 to 74, MD-INDEX 0 to 74 when the cell has a room, else -1), slot 76 the left wing (index 1001), 77 the right wing
*> (1002), 78 the penthouse (1003). A direction is the 3-D data value 0 down, 1 up, 2 north, 3 south, 4 west, 5 east (subscript = value + 1); MD-CONN is the slot of the connected definition or 0, MD-OPEN the hasOpening flag.
*> MO-ORDER is the room list of 5.3 step 7 (46 shuffled grid slots, then the penthouse, left and right wing slots). MO-CORE is the slot of the core room.
*> MO-CHILD is the child piece list of 5.4 in order (kind 1 entry, 2 core, 3 simple, 4 simple top, 5 double X, 6 double Y, 7 double Z, 8 double XY, 9 double YZ, 10 wing, 11 penthouse; the definition index, the main
*> design (simple rooms and wings, else 0) and the box). The building direction MO-DIR is 0 north, 1 east, 2 south, 3 west; the building box is MO-B*.
 78 MO-SLOTS             VALUE 78.
 78 MO-CHILD-MAX         VALUE 64.
 01 STRUCT-MONUMENT EXTERNAL.
    05 MO-DEF OCCURS 78 TIMES.
       10 MD-INDEX         BINARY-LONG.
       10 MD-CONN          BINARY-LONG OCCURS 6 TIMES.
       10 MD-OPEN          BINARY-LONG OCCURS 6 TIMES.
       10 MD-CLAIMED       BINARY-LONG.
       10 MD-SOURCE        BINARY-LONG.
       10 MD-SCAN          BINARY-LONG.
    05 MO-ORDER            BINARY-LONG OCCURS 49 TIMES.
    05 MO-CORE             BINARY-LONG.
    05 MO-DIR              BINARY-LONG.
    05 MO-WING-SEED        BINARY-LONG.
    05 MO-VX               BINARY-LONG.
    05 MO-VZ               BINARY-LONG.
    05 MO-BX0              BINARY-LONG.
    05 MO-BY0              BINARY-LONG.
    05 MO-BZ0              BINARY-LONG.
    05 MO-BX1              BINARY-LONG.
    05 MO-BY1              BINARY-LONG.
    05 MO-BZ1              BINARY-LONG.
    05 MO-COUNT            BINARY-LONG.
    05 MO-CHILD OCCURS 64 TIMES.
       10 MC-KIND          BINARY-LONG.
       10 MC-INDEX         BINARY-LONG.
       10 MC-DESIGN        BINARY-LONG.
       10 MC-X0            BINARY-LONG.
       10 MC-Y0            BINARY-LONG.
       10 MC-Z0            BINARY-LONG.
       10 MC-X1            BINARY-LONG.
       10 MC-Y1            BINARY-LONG.
       10 MC-Z1            BINARY-LONG.
