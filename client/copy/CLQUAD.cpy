*> One baked quad (client/src/models.cob), laid out as BM-QUAD of CLSTATE.cpy so it can be moved
*> there whole: cull and shade directions (DIR-*), sprite, and four corners top-left, top-right,
*> bottom-right, bottom-left (block units 0 to 1, sprite units 0 to 16).
 01 QUAD.
    05 QD-CULL               BINARY-LONG.
    05 QD-SHADE              BINARY-LONG.
    05 QD-SPRITE             BINARY-LONG.
    05 QD-CORNER OCCURS 4 TIMES.
       10 QD-X               FLOAT-SHORT.
       10 QD-Y               FLOAT-SHORT.
       10 QD-Z               FLOAT-SHORT.
       10 QD-U               FLOAT-SHORT.
       10 QD-V               FLOAT-SHORT.
