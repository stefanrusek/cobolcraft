*> A list of saved ticks (29 section 4.2, SavedTick): the block or fluid id (tag i), the position (x, y, z), the delay (t, an int:
*> trigger time minus game time) and the priority value (p, -3 to 3), as BT-PACK writes and BT-UNPACK reads them.
 01 BT-SAVED.
    05 BT-SV-COUNT               BINARY-LONG.
    05 BT-SV OCCURS 256 TIMES.
       10 BT-SV-X                BINARY-LONG.
       10 BT-SV-Y                BINARY-LONG.
       10 BT-SV-Z                BINARY-LONG.
       10 BT-SV-ID               BINARY-LONG.
       10 BT-SV-DELAY            BINARY-LONG.
       10 BT-SV-PRIO             BINARY-LONG.
