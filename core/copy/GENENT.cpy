*> The worldgen entity channel (docs/design/world-types.md "Entities of generated structures"; core/src/gen-ent.cob). A worker cannot spawn an entity (the entity table is the game process's), so a
*> structure that places a villager, a golem, a cat or any mob asks for it here, as the worldgen block-entity channel (GENBE.cpy) asks for chests and spawners: a bounded list of requests carried
*> with the job (GENT-KEEP, GENJOB.cpy GJ-ENT), published by the install in GEN-ENT (GE-DATA, the same layout), returned by a worker after the block-entity requests (GW-ANSWER-BYTES) and applied by
*> WORLD-CHUNK-LOAD to the chunk it generated (GENT-APPLY), on the main thread. A request is the entity's compound as the template stored it (GEL-NBT, GEL-LEN bytes: the payload with its End tag),
*> the world position (GEL-X, GEL-Y, GEL-Z) and the yaw; the compound says whether the mob persists (PersistenceRequired). Only the chunk pass whose write box holds the entity's block makes the
*> request, so an entity is asked for once. The same group carries the boxes of the structures that override the natural spawn lists (STRUCTOVR.cpy, struct-override.cob): GEL-BOX, at most
*> GE-BOX-MAX per chunk, each the kind of the structure and a box that intersects the chunk; the main thread registers them with the chunk (GENT-APPLY). At most GE-MAX requests per chunk (GEL-LOST counts the rest); a compound over GE-NBT-MAX bytes is not kept. Memory of the game process only.
 78 GE-MAX                VALUE 16.
 78 GE-BOX-MAX            VALUE 24.
 78 GE-NBT-MAX            VALUE 1344.
 01 GEN-ENT-LEVEL EXTERNAL.
    05 GEL-COUNT           BINARY-LONG.
    05 GEL-LOST            BINARY-LONG.
    05 GEL-ENTRY OCCURS 16 TIMES.
       10 GEL-X            FLOAT-LONG.
       10 GEL-Y            FLOAT-LONG.
       10 GEL-Z            FLOAT-LONG.
       10 GEL-YAW          FLOAT-SHORT.
       10 GEL-LEN          BINARY-LONG.
       10 GEL-NBT          PIC X(1344).
    05 GEL-BOX-COUNT       BINARY-LONG.
    05 GEL-BOX-LOST        BINARY-LONG.
    05 GEL-BOX OCCURS 24 TIMES.
       10 GEL-B-KIND       BINARY-LONG.
       10 GEL-B-MIN-X      BINARY-LONG.
       10 GEL-B-MIN-Y      BINARY-LONG.
       10 GEL-B-MIN-Z      BINARY-LONG.
       10 GEL-B-MAX-X      BINARY-LONG.
       10 GEL-B-MAX-Y      BINARY-LONG.
       10 GEL-B-MAX-Z      BINARY-LONG.
 01 GEN-ENT EXTERNAL.
    05 GE-DATA.
       10 GE-COUNT         BINARY-LONG.
       10 GE-LOST          BINARY-LONG.
       10 GE-ENTRY OCCURS 16 TIMES.
          15 GE-X          FLOAT-LONG.
          15 GE-Y          FLOAT-LONG.
          15 GE-Z          FLOAT-LONG.
          15 GE-YAW        FLOAT-SHORT.
          15 GE-LEN        BINARY-LONG.
          15 GE-NBT        PIC X(1344).
       10 GE-BOX-COUNT     BINARY-LONG.
       10 GE-BOX-LOST      BINARY-LONG.
       10 GE-BOX OCCURS 24 TIMES.
          15 GE-B-KIND     BINARY-LONG.
          15 GE-B-MIN-X    BINARY-LONG.
          15 GE-B-MIN-Y    BINARY-LONG.
          15 GE-B-MIN-Z    BINARY-LONG.
          15 GE-B-MAX-X    BINARY-LONG.
          15 GE-B-MAX-Y    BINARY-LONG.
          15 GE-B-MAX-Z    BINARY-LONG.
