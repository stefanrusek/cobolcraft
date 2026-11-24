*> The worldgen block-entity channel (docs/design/world-types.md "Block entities of generated structures"; core/src/gen-be.cob). A generated chunk cannot write a block entity (the chunk window has block
*> states only), so a structure that places a chest or a spawner also asks for the entity here: a bounded list of requests, carried like the overflow list (GENOVER.cpy). Kind 1 is a chest
*> with a loot table (GBL-LOOT the key "namespace:path", GBL-SEED the seed drawn at generation, `random.nextLong()` of the placement, 36-1 6.5 createChest; the table is rolled when the
*> chest is first opened, 31-1 9.3), kind 2 a spawner (GBL-TEXT the entity id, e.g. "minecraft:cave_spider"). The structure code appends to GEN-BE-LEVEL (GBE-ADD, at most GB-MAX, GBL-LOST
*> counts the rest); the stage hands them to the job (GBE-KEEP, GENJOB.cpy GJ-BE); the install publishes the job's list in GEN-BE (GB-DATA, the same layout), a worker returns it after the overflow
*> (GW-ANSWER-BYTES), and WORLD-CHUNK-LOAD applies it to the chunk it generated (GBE-APPLY): the entity is made by BE-BLOCK-SET, the path of a block a player places. Memory of the game process only.
 78 GB-MAX                VALUE 64.
 01 GEN-BE-LEVEL EXTERNAL.
    05 GBL-COUNT           BINARY-LONG.
    05 GBL-LOST            BINARY-LONG.
    05 GBL-ENTRY OCCURS 64 TIMES.
       10 GBL-X            BINARY-LONG.
       10 GBL-Y            BINARY-LONG.
       10 GBL-Z            BINARY-LONG.
       10 GBL-KIND         BINARY-LONG.
       10 GBL-SEED         BINARY-DOUBLE.
       10 GBL-LOOT         PIC X(48).
       10 GBL-TEXT         PIC X(32).
 01 GEN-BE EXTERNAL.
    05 GB-DATA.
       10 GB-COUNT         BINARY-LONG.
       10 GB-LOST          BINARY-LONG.
       10 GB-ENTRY OCCURS 64 TIMES.
          15 GB-X          BINARY-LONG.
          15 GB-Y          BINARY-LONG.
          15 GB-Z          BINARY-LONG.
          15 GB-KIND       BINARY-LONG.
          15 GB-SEED       BINARY-DOUBLE.
          15 GB-LOOT       PIC X(48).
          15 GB-TEXT       PIC X(32).
