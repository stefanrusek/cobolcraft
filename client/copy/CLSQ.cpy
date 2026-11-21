*> The quads of a code-drawn item model (client/src/item-special.cob: the chest family, the shulker boxes, the banners; docs/protocol/52): SQ-COUNT quads, each four corners
*> (x, y, z interleaved) in the unit cell of the model after the item definition's own transformation (the space an item's display transform acts on), clockwise seen from
*> outside (the winding of the terrain: the cross product of the first two edges points into the model), the atlas texture coordinates of the corners (the block atlas), the
*> outward unit normal and the tint (white, or the banner's dye colour).
 01 SQ-TABLE.
    05 SQ-COUNT             BINARY-LONG.
    05 SQ-QUAD OCCURS 48 TIMES.
       10 SQ-C              FLOAT-LONG OCCURS 12 TIMES.
       10 SQ-UV.
          15 SQ-U           FLOAT-SHORT OCCURS 4 TIMES.
          15 SQ-V           FLOAT-SHORT OCCURS 4 TIMES.
       10 SQ-N              FLOAT-LONG OCCURS 3 TIMES.
       10 SQ-T              FLOAT-SHORT OCCURS 3 TIMES.
