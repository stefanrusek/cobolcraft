*> The quads of one fluid cell (MESH-FLUID, 29a section 10): up to six (top, bottom, north, south, west, east), each four
*> corners in the order that makes corners 1 and 3 opposite; positions relative to the section's lowest corner. FO-TRANSLUCENT 1
*> sends the quad to the translucent mesh. FO-BRIGHT and FO-SKY are the vertex brightness and sky terms of the mesher;
*> FO-R, FO-G and FO-B the tint.
 01 FLUID-OUT.
    05 FO-COUNT             BINARY-LONG.
    05 FO-QUAD OCCURS 6 TIMES.
       10 FO-TRANSLUCENT    BINARY-LONG.
       10 FO-BRIGHT         FLOAT-SHORT.
       10 FO-SKY            FLOAT-SHORT.
       10 FO-R              FLOAT-SHORT.
       10 FO-G              FLOAT-SHORT.
       10 FO-B              FLOAT-SHORT.
       10 FO-CORNER OCCURS 4 TIMES.
          15 FO-X           FLOAT-SHORT.
          15 FO-Y           FLOAT-SHORT.
          15 FO-Z           FLOAT-SHORT.
          15 FO-U           FLOAT-SHORT.
          15 FO-V           FLOAT-SHORT.
