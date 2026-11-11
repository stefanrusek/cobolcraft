*> A resolved block model (08 §5.1 to §5.5; client/src/models.cob): the elements of the nearest
*> model of the parent chain that has elements, and the texture slots merged along the chain
*> (child entries replace parent entries). MR-MISSING is 1 when a model of the chain names no file:
*> the caller draws the missing model instead (08 §5.2). Coordinates are in sixteenths.
 01 MODEL-RESOLVED.
    05 MR-MISSING            PIC 9.
    05 MR-ELEMENT-COUNT      BINARY-LONG.
    05 MR-ELEMENT OCCURS 8 TIMES.
       10 ME-FROM            FLOAT-SHORT OCCURS 3 TIMES.
       10 ME-TO              FLOAT-SHORT OCCURS 3 TIMES.
       10 ME-ROT-KIND        BINARY-LONG.    *> 0 none, 1 single axis, 2 Euler x, y, z
       10 ME-ROT-AXIS        BINARY-LONG.    *> 1 x, 2 y, 3 z (single axis)
       10 ME-ROT-ANGLE       FLOAT-SHORT OCCURS 3 TIMES.  *> single: (1); Euler: x, y, z
       10 ME-ROT-ORIGIN      FLOAT-SHORT OCCURS 3 TIMES.
       10 ME-RESCALE         PIC 9.
       10 ME-SHADE           BINARY-LONG.    *> shade_direction_override, DIR-NONE when absent
       10 ME-FACE OCCURS 6 TIMES.            *> by DIR-* (down, up, north, south, west, east)
          15 MF-PRESENT      PIC 9.
          15 MF-TEXTURE      PIC X(80).      *> "#slot" or a sprite id
          15 MF-UV-GIVEN     PIC 9.
          15 MF-UV           FLOAT-SHORT OCCURS 4 TIMES.
          15 MF-CULL         BINARY-LONG.    *> DIR-*, DIR-NONE when absent
          15 MF-ROTATION     BINARY-LONG.    *> 0, 90, 180, 270
          15 MF-TINT         BINARY-LONG.    *> tintindex (08 5.5), -1 when absent
    05 MR-SLOT-COUNT         BINARY-LONG.
    05 MR-SLOT OCCURS 16 TIMES.
       10 MS-NAME            PIC X(32).
       10 MS-VALUE           PIC X(80).

*> The models a block state file selects for one state (08 §4: the matching variant, or every
*> multipart case whose condition holds; of a weighted list the first entry), with the Variant
*> rotation in degrees.
 01 STATE-MODELS.
    05 SX-COUNT              BINARY-LONG.
    05 SX-MODEL OCCURS 8 TIMES.
       10 SX-ID              PIC X(80).
       10 SX-X               BINARY-LONG.
       10 SX-Y               BINARY-LONG.
       10 SX-Z               BINARY-LONG.
       10 SX-UVLOCK          PIC 9.
