*> The landing GAME-EVENT-FALL notes for FARM-LANDED (core/src/farm-trample.cob; docs/protocol/29b part 2 section 9.3): the entity row that landed on the ground in the movement
*> pass in progress and the fall distance (Entity.fallDistance, blocks) it had. FT-LAND-ROW is 0 when nothing is noted; every movement pass clears it first.
 01 FARM-LANDING EXTERNAL.
    05 FT-LAND-ROW           BINARY-LONG.
    05 FT-LAND-D             FLOAT-LONG.
