*> The riding table of the ride command (docs/protocol/16-commands-catalog.md §5.6; core/src/cmds-entities.cob): EXTERNAL, one entry per rider, found by
*> the network entity id of the rider (a player's PL-ENTITY-ID, any other entity's EN-ID). RD-RIDER 0 is a free entry; RD-VEHICLE is the entity id of the
*> vehicle. An entity rides at most one vehicle and a vehicle carries at most one passenger. Riding is not saved and moves nothing: a rider does not follow its vehicle.
 78 RD-MAX                 VALUE 1100.
 01 CORE-RIDING EXTERNAL.
    05 RD-ENTRY OCCURS 1100 TIMES.
       10 RD-RIDER           BINARY-LONG.
       10 RD-VEHICLE         BINARY-LONG.
