*> The shape rules and the property table of the shape builder (content/src/block-shapes.cob; docs/protocol/51-block-shapes.md).
*> BSR-R row r: the block classes it covers ("|A|B|"), its mode (S static, P a property value picks, Y yawed by a property,
*> H height by a number property, A attached face, K coded family), the property and value it consults, and the collision and
*> outline box lists in pixels ("x1 y1 z1 x2 y2 z2,..."; N none, F full cube, = same as the collision).
*> BSP-ENTRY: the properties of the block being built, split from its row, with the value text each holds for the state.
 78 BSR-MAX               VALUE 100.
 01 BSH-RULES EXTERNAL.
    05 BSR-N              BINARY-LONG.
    05 BSR-R OCCURS 100 TIMES.
       10 BSR-CLASSES     PIC X(200).
       10 BSR-MODE        PIC X.
       10 BSR-PROP        PIC X(12).
       10 BSR-VAL         PIC X(14).
       10 BSR-COLL        PIC X(160).
       10 BSR-OUT         PIC X(160).
 01 BSH-PROPS EXTERNAL.
    05 BSP-N              BINARY-LONG.
    05 BSP-ENTRY OCCURS 16 TIMES.
       10 BSP-NAME        PIC X(24).
       10 BSP-KIND        PIC X.
       10 BSP-COUNT       BINARY-LONG.
       10 BSP-LOW         BINARY-LONG.
       10 BSP-ITEM        PIC X(16) OCCURS 16 TIMES.
       10 BSP-VAL         PIC X(16).
