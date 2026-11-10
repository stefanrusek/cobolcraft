*> The stages of a resumable chunk generation (core/src/gen-job.cob) and the number of steps of each. One step is a
*> bounded piece of work (a section of biomes, a column of cell corners, a slab of four block rows, ...), so a tick can
*> stop between two steps. The standard overworld's TERRAIN pipeline of docs/protocol/10 section 11.1 in order.
 78 GJ-STAGE-BIOMES        VALUE 1.
 78 GJ-STAGE-DENSITY       VALUE 2.
 78 GJ-STAGE-AQUIFER        VALUE 3.
 78 GJ-STAGE-FILL          VALUE 4.
 78 GJ-STAGE-SURFACE       VALUE 5.
 78 GJ-STAGE-CARVERS       VALUE 6.
 78 GJ-STAGE-ORES          VALUE 7.
 78 GJ-STAGE-FINISH        VALUE 8.
 78 GJ-STAGE-COUNT         VALUE 8.
 78 GJ-STEPS-BIOMES        VALUE 96.
 78 GJ-STEPS-DENSITY       VALUE 25.
 78 GJ-STEPS-AQUIFER       VALUE 121.
 78 GJ-STEPS-FILL          VALUE 96.
 78 GJ-STEPS-SURFACE       VALUE 164.
 78 GJ-STEPS-CARVERS       VALUE 305.
 78 GJ-STEPS-ORES          VALUE 270.
 78 GJ-STEPS-FINISH        VALUE 1.
 78 GJ-STEPS-TOTAL         VALUE 1078.
