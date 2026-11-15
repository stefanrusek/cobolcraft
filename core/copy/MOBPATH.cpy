*> Pathfinding data (docs/protocol/18-mob-framework.md section 5), world agnostic: the caller copies the block path types of
*> the region around a mob into PF-WORLD (the PathNavigationRegion snapshot of 5.2: each cell holds the PathType id of the block
*> at that position, 5.1, local coordinates 0 .. size - 1, cells outside the snapshot count as BLOCKED), then calls the
*> evaluators and PATH-FIND with a PF-SEARCH parameter block. Evaluator kinds: 1 walk, 2 swim, 3 fly, 4 amphibious, 5 wall climber.
*> PathType ids: 0 BLOCKED, 1 OPEN, 2 WALKABLE, 3 WALKABLE_DOOR, 4 TRAPDOOR, 5 POWDER_SNOW, 6 ON_TOP_OF_POWDER_SNOW, 7 FENCE,
*> 8 LAVA, 9 WATER, 10 WATER_BORDER, 11 RAIL, 12 UNPASSABLE_RAIL, 13 FIRE_IN_NEIGHBOR, 14 FIRE, 15 DAMAGING_IN_NEIGHBOR,
*> 16 DAMAGING, 17 DOOR_OPEN, 18 DOOR_WOOD_CLOSED, 19 DOOR_IRON_CLOSED, 20 BREACH, 21 LEAVES, 22 STICKY_HONEY, 23 COCOA,
*> 24 DAMAGE_CAUTIOUS, 25 ON_TOP_OF_TRAPDOOR, 26 BIG_MOBS_CLOSE_TO_DANGER.
 01 PF-MALUS-TABLE.
    05 PF-MALUS-ENTRY OCCURS 27 TIMES.
       10 PF-MALUS-SET      BINARY-LONG.
       10 PF-MALUS-VAL      BINARY-LONG.
    05 PF-SAVED OCCURS 3 TIMES.
       10 PF-SAVED-SET      BINARY-LONG.
       10 PF-SAVED-VAL      BINARY-LONG.
 01 PF-TYPESET.
    05 PT-COUNT             BINARY-LONG.
    05 PT-TYPE              BINARY-LONG OCCURS 27 TIMES.
 01 PF-WORLD.
    05 PW-DX                BINARY-LONG.
    05 PW-DY                BINARY-LONG.
    05 PW-DZ                BINARY-LONG.
    05 PW-CELL              BINARY-LONG OCCURS 4096 TIMES.
 01 PF-SEARCH.
    05 PS-KIND              BINARY-LONG.
    05 PS-SX                BINARY-LONG.
    05 PS-SY                BINARY-LONG.
    05 PS-SZ                BINARY-LONG.
    05 PS-TARGET-COUNT      BINARY-LONG.
    05 PS-TARGET OCCURS 4 TIMES.
       10 PS-TX             BINARY-LONG.
       10 PS-TY             BINARY-LONG.
       10 PS-TZ             BINARY-LONG.
    05 PS-REACH             BINARY-LONG.
    05 PS-MAX-DIST          FLOAT-LONG.
    05 PS-BUDGET            BINARY-LONG.
    05 PS-WIDTH             BINARY-LONG.
    05 PS-HEIGHT            BINARY-LONG.
    05 PS-MAX-FALL          BINARY-LONG.
    05 PS-STEP              BINARY-LONG.
    05 PS-BREACH            BINARY-LONG.
    05 PS-SEA-LEVEL         BINARY-LONG.
    05 PS-SHALLOW           BINARY-LONG.
    05 PS-REACHED           BINARY-LONG.
    05 PS-VISITED           BINARY-LONG.
    05 PS-PATH-COUNT        BINARY-LONG.
    05 PS-PATH OCCURS 600 TIMES.
       10 PS-PX             BINARY-LONG.
       10 PS-PY             BINARY-LONG.
       10 PS-PZ             BINARY-LONG.
       10 PS-PTYPE          BINARY-LONG.
       10 PS-SKY            BINARY-LONG.
 01 PF-NODES.
    05 PN-COUNT             BINARY-LONG.
    05 PN-INDEX             BINARY-LONG OCCURS 4096 TIMES.
    05 PN-NODE OCCURS 600 TIMES.
       10 PN-X              BINARY-LONG.
       10 PN-Y              BINARY-LONG.
       10 PN-Z              BINARY-LONG.
       10 PN-G              FLOAT-LONG.
       10 PN-H              FLOAT-LONG.
       10 PN-WALKED         FLOAT-LONG.
       10 PN-COST           FLOAT-LONG.
       10 PN-STATE          BINARY-LONG.
       10 PN-FROM           BINARY-LONG.
       10 PN-TYPE           BINARY-LONG.
 01 PF-NEIGH.
    05 PNB-COUNT            BINARY-LONG.
    05 PNB-NODE             BINARY-LONG OCCURS 32 TIMES.
*> Path following state (5.5).
 01 PF-NAV.
    05 PV-INDEX             BINARY-LONG.
    05 PV-COUNT             BINARY-LONG.
    05 PV-TICK              BINARY-LONG.
    05 PV-LAST-CHECK        BINARY-LONG.
    05 PV-LAST-X            FLOAT-LONG.
    05 PV-LAST-Y            FLOAT-LONG.
    05 PV-LAST-Z            FLOAT-LONG.
    05 PV-STUCK             BINARY-LONG.
    05 PV-TIMER             FLOAT-LONG.
    05 PV-LIMIT             FLOAT-LONG.
    05 PV-CACHED            BINARY-LONG.
    05 PV-LAST-TIMEOUT      BINARY-LONG.
    05 PV-LAST-RECOMPUTE    BINARY-LONG.
    05 PV-DELAYED           BINARY-LONG.
