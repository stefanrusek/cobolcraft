*> The generation state of the stronghold being assembled (docs/protocol/36-structures-5-mineshaft-stronghold.md section 3; core/src/struct-stronghold.cob). EXTERNAL, core-private, one start at a time.
*> SH-TAB is the table of 11 piece weights in table order (1 Straight, 2 PrisonHall, 3 LeftTurn, 4 RightTurn, 5 RoomCrossing, 6 StraightStairsDown, 7 StairsDown, 8 FiveCrossing,
*> 9 ChestCorridor, 10 Library, 11 PortalRoom): SH-W weight, SH-MAX maxPlaceCount (0 unlimited), SH-CNT placeCount, SH-IN 1 while the entry is in currentPieces. SH-IMPOSED and SH-PREV are
*> table indexes (0 none), SH-START the row of the start piece, SH-PORTAL the row of the portal room (0 none), SH-PEND the rows waiting for expansion.
*> SH-EYE (1 to 12) are the eye flags of the portal room being placed, SH-EYE-IDX counts its frames (struct-sh-place.cob).
 78 SH-PEND-MAX           VALUE 1024.
 01 STRUCT-STRONGHOLD EXTERNAL.
    05 SH-IMPOSED          BINARY-LONG.
    05 SH-PREV             BINARY-LONG.
    05 SH-TOTAL            BINARY-LONG.
    05 SH-START            BINARY-LONG.
    05 SH-PORTAL           BINARY-LONG.
    05 SH-PEND-N           BINARY-LONG.
    05 SH-ATTEMPTS         BINARY-LONG.
    05 SH-EYE-IDX          BINARY-LONG.
    05 SH-EYE              BINARY-LONG OCCURS 12 TIMES.
    05 SH-TAB OCCURS 11 TIMES.
       10 SH-W             BINARY-LONG.
       10 SH-MAX           BINARY-LONG.
       10 SH-CNT           BINARY-LONG.
       10 SH-IN            BINARY-LONG.
    05 SH-PEND             BINARY-LONG OCCURS 1024 TIMES.
