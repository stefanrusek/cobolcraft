*> The desert pyramid's lists of one placement pass (docs/protocol/36-structures-4 sections 3.4 and 3.5; core/src/struct-scatter-desert.cob). EXTERNAL, core-private, memory of one generation job only.
*> SCD-ROOF-SET 1 once a pyramid was post-processed in the pass (STRUCT-PLACE-START resets it before the pieces); SCD-ROOF-X, SCD-ROOF-Y, SCD-ROOF-Z the world position randomCollapsedRoofPos;
*> SCD-CAND the world positions of the potential suspicious sand blocks (potentialSuspiciousSandWorldPositions: 75 of the cellar's box and 8 of its arms), SCD-COUNT of them.
 01 SCP-DESERT-STATE EXTERNAL.
    05 SCD-COUNT           BINARY-LONG.
    05 SCD-ROOF-SET        BINARY-LONG.
    05 SCD-ROOF-X          BINARY-LONG.
    05 SCD-ROOF-Y          BINARY-LONG.
    05 SCD-ROOF-Z          BINARY-LONG.
    05 SCD-CAND OCCURS 100 TIMES.
       10 SCD-CX           BINARY-LONG.
       10 SCD-CY           BINARY-LONG.
       10 SCD-CZ           BINARY-LONG.
