*> The block shape tables (docs/protocol/51-block-shapes.md), built by BSH-BUILD (content/src/block-shapes.cob) from the open
*> content set and read by the client (physics, targeting) and the core (movement checks). EXTERNAL, so every program that
*> COPYs this book shares the one record.
*>   BSH-READY      1 once BSH-BUILD has run with a set open; 0 otherwise (then every state is a full cube, 0 the void).
*>   BSH-TYPE       the set type (CT-SET-TYPE + 1) the tables were built for, 0 when none: BSH-BUILD skips a set it has built.
*>   BSH-COLL, BSH-OUT   the collision shape id and the outline (targeting) shape id of block state s, at index s + 1.
*>   BSH-CLIMB      1 for a state of the tag minecraft:climbable (ladder, vines, scaffolding; 24 part 1 section 12): the climbing rules of 13 section 1.3.
*>   BSH-SHAPE      shape id i at index i + 1: BSH-N boxes, each (x1, y1, z1, x2, y2, z2) in thousandths of a pixel (1/16 block,
*>                  so 16000 is one block); shape id 0 is empty and 1 is the full cube. Equal shapes share an id.
*>   BSC-SHAPE      the candidate shape the builder assembles (same layout as one BSH-SHAPE).
*>   BSH-HASH       the open-addressing table that finds an equal shape (shape id + 1, 0 = free slot).
 78 BSH-MAX-SHAPES        VALUE 2000.
 78 BSH-MAX-BOXES         VALUE 12.
 78 BSH-MAX-STATES        VALUE 40000.
 78 BSH-HASH-SIZE         VALUE 8191.
 01 BSH-STORE EXTERNAL.
    05 BSH-READY          BINARY-LONG.
    05 BSH-COUNT          BINARY-LONG.
    05 BSH-TYPE           BINARY-LONG.
    05 BSH-COLL           BINARY-SHORT UNSIGNED OCCURS 40000 TIMES.
    05 BSH-OUT            BINARY-SHORT UNSIGNED OCCURS 40000 TIMES.
    05 BSH-CLIMB          BINARY-CHAR UNSIGNED OCCURS 40000 TIMES.
    05 BSH-SHAPE OCCURS 2000 TIMES.
       10 BSH-N           BINARY-LONG.
       10 BSH-BOX OCCURS 12 TIMES.
          15 BSH-V        BINARY-LONG OCCURS 6 TIMES.
    05 BSH-HASH           BINARY-LONG OCCURS 8191 TIMES.
 01 BSH-CAND EXTERNAL.
    05 BSC-SHAPE.
       10 BSC-N           BINARY-LONG.
       10 BSC-BOX OCCURS 12 TIMES.
          15 BSC-V        BINARY-LONG OCCURS 6 TIMES.
