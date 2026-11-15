*> State of the End's travel rules (docs/protocol/38-end.md section 9, 39-portals.md section 7; core/src/end-travel.cob). EXTERNAL (zero at start).
*> ET-EPOCH: the CB-EPOCH the ids were resolved for; ET-S-PORTAL the state of end_portal (-1 when the set has none), ET-ITEM-EYE the item id of ender_eye (-1 none).
*> ET-PL (per player row): the entity id that owns the record (a different one resets it), the portal cooldown in ticks, wonGame and seenCredits (7.5).
 01 END-TRAVEL-STATE EXTERNAL.
    05 ET-EPOCH               BINARY-LONG.
    05 ET-S-PORTAL            BINARY-LONG.
    05 ET-ITEM-EYE            BINARY-LONG.
    05 ET-PL OCCURS 64 TIMES.
       10 ET-OWNER            BINARY-LONG.
       10 ET-COOLDOWN         BINARY-LONG.
       10 ET-WON              BINARY-LONG.
       10 ET-SEEN             BINARY-LONG.
