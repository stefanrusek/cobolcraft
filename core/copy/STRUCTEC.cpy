*> The end city being generated (docs/protocol/36-structures-8-nether-and-end.md sections 8 to 12; core/src/struct-endcity.cob). EXTERNAL, core-private, one city at a time.
*> EC-PIECE is the piece list in order (9.1): the template short name, the template position, the rotation (0 none, 1 clockwise 90, 2 clockwise 180, 3 counterclockwise 90), overwrite (1 = template air is
*> written), the generation depth field (the group id of 10.1, or -1 on a bridge's first piece and end) and the box. EC-SHIP is the shipCreated flag of the bridge generator.
 78 EC-MAX               VALUE 2000.
 01 STRUCT-ENDCITY EXTERNAL.
    05 EC-COUNT            BINARY-LONG.
    05 EC-LOST             BINARY-LONG.
    05 EC-SHIP             BINARY-LONG.
    05 EC-PIECE OCCURS 2000 TIMES.
       10 EP-NAME          PIC X(24).
       10 EP-X             BINARY-LONG.
       10 EP-Y             BINARY-LONG.
       10 EP-Z             BINARY-LONG.
       10 EP-ROT           BINARY-LONG.
       10 EP-OW            BINARY-LONG.
       10 EP-GD            BINARY-LONG.
       10 EP-X0            BINARY-LONG.
       10 EP-Y0            BINARY-LONG.
       10 EP-Z0            BINARY-LONG.
       10 EP-X1            BINARY-LONG.
       10 EP-Y1            BINARY-LONG.
       10 EP-Z1            BINARY-LONG.
