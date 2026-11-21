*> The gossip of villagers (docs/protocol/19-mobs-land-friendly-and-neutral.md section 22.5; core/src/mob-vil-gossip.cob), EXTERNAL, a side table of one entry per
*> (villager entity id, target entity id) pair (GS-VIL 0 = free). GS-V holds the five gossip values in the order of the types: major_negative, minor_negative,
*> minor_positive, major_positive, trading. Targets are player entity ids (golems and other villagers are not stored yet).
 78 GS-MAX                VALUE 512.
 01 GS-STATE EXTERNAL.
    05 GS-ENTRY              OCCURS 512 TIMES.
       10 GS-VIL             BINARY-LONG.
       10 GS-TARGET          BINARY-LONG.
       10 GS-V               BINARY-LONG OCCURS 5 TIMES.
