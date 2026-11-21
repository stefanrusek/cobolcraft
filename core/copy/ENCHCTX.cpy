*> Context of an enchantment effect evaluation (core/src/ench-load.cob ENCH-FOLD; docs/protocol/28 sections 7 and 8).
*> EC-DIRECT 1 when the damage is a direct hit (a melee hit, not a projectile); EC-DAMAGE-KEY the damage type key without namespace
*> ("player_attack"); EC-VICTIM-ID the entity type id of the victim (-1 none) for entity-type tag tests; EC-VICTIM-KEY its key.
 01 ENCH-CTX.
    05 EC-DIRECT           BINARY-LONG.
    05 EC-DAMAGE-KEY       PIC X(48).
    05 EC-VICTIM-ID        BINARY-LONG.
    05 EC-VICTIM-KEY       PIC X(48).
