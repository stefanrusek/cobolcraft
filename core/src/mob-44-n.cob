*> The kitten of two cats (002-lane-mobsa4; docs/protocol/19-mobs-land-friendly-and-neutral.md section 5.1 "Offspring").
*> CAT-BRED USING parent a (the mother, the first parent), parent b, baby row, coin (0 or 1): the kitten has the variant (EN-WOOL) of the parent the coin names; when the mother is tame the kitten is
*>   tame with her owner and its collar is the mix of the parents' collars (M19-SHEEP-MIX over the dye ids; the default collar is red, 14), as for the wolf pup.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CAT-BRED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-COLOR-A             BINARY-LONG.
 01 WS-COLOR-B             BINARY-LONG.
 01 WS-MIXED               BINARY-LONG.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-BABY                 BINARY-LONG.
 01 L-COIN                 BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-BABY L-COIN.
     MOVE EN-WOOL(L-A) TO EN-WOOL(L-BABY)
     IF L-COIN = 1
         MOVE EN-WOOL(L-B) TO EN-WOOL(L-BABY)
     END-IF
     IF EN-TAMED(L-A) = 1
         MOVE 14 TO WS-COLOR-A WS-COLOR-B
         IF EN-COLLAR(L-A) > 0
             COMPUTE WS-COLOR-A = EN-COLLAR(L-A) - 1
         END-IF
         IF EN-COLLAR(L-B) > 0
             COMPUTE WS-COLOR-B = EN-COLLAR(L-B) - 1
         END-IF
         CALL "M19-SHEEP-MIX" USING WS-COLOR-A WS-COLOR-B L-COIN WS-MIXED
         COMPUTE EN-COLLAR(L-BABY) = WS-MIXED + 1
         MOVE 1 TO EN-TAMED(L-BABY)
         MOVE 0 TO EN-SIT(L-BABY)
         MOVE EN-OWNER-UUID(L-A) TO EN-OWNER-UUID(L-BABY)
     END-IF
     GOBACK.
 END PROGRAM CAT-BRED.
