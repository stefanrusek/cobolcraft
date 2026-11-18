*> Spawning and structures (docs/protocol/44-residual-mob-questions-2-spawning-structures.md; lane 002-lane-p49g). The live engines of the sections that were only helpers before.
*>
*> Entry points:
*>   SPW-POTENTIAL-PICK USING state (XORO), BE index    section 2.3: after a rolled delay the next spawn data is picked from SpawnPotentials (WeightedList.getRandom, 7.1): nothing
*>     changes and no number is drawn for a list that holds no entries or whose weights add up to 0; otherwise one nextInt(total) chooses the first entry whose cumulative weight
*>     exceeds the roll and its entity id becomes the spawn data (BE-XI 8, 9, BE-XT 1); a picked entry carries no custom spawn rules (the rules of an entry are not kept, 31-7 3.1)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPW-POTENTIAL-PICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-W.
    05 WS-WEIGHT           BINARY-LONG OCCURS 64 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-ENTRY               BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-INDEX.
     MOVE BE-XI(L-INDEX, 15) TO WS-COUNT
     IF WS-COUNT < 1
         GOBACK
     END-IF
     MOVE ZEROES TO WS-W
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         MOVE BE-XI(L-INDEX, 29 + WS-I) TO WS-WEIGHT(WS-I)
     END-PERFORM
     CALL "BE7-WEIGHT-TOTAL" USING WS-W WS-COUNT WS-TOTAL
     IF WS-TOTAL < 1
         GOBACK
     END-IF
     CALL "XORO-NEXT-INT" USING L-STATE WS-TOTAL WS-DRAW
     CALL "BE7-WEIGHT-PICK" USING WS-W WS-COUNT WS-DRAW WS-ENTRY
     MOVE BE-XT(L-INDEX, 1 + WS-ENTRY) TO BE-XT(L-INDEX, 1)
     MOVE BE-XI(L-INDEX, 19 + WS-ENTRY) TO BE-XI(L-INDEX, 9)
     MOVE 1 TO BE-XI(L-INDEX, 8)
     MOVE 0 TO BE-XI(L-INDEX, 10) BE-XI(L-INDEX, 12) BE-XI(L-INDEX, 14)
     MOVE 15 TO BE-XI(L-INDEX, 11) BE-XI(L-INDEX, 13)
     GOBACK.
 END PROGRAM SPW-POTENTIAL-PICK.
