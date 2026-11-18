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

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPW-CUSTOM-OK.
*> USING dim, x, y, z (BINARY-LONG feet cell), species row (STDMOBS.cpy), custom rules (5 BINARY-LONG: set, block light min, max, sky light min, max), ok out: SpawnData.custom_spawn_rules
*> isValidPosition of 44 part 2 section 3 together with the Peaceful test of 18 section 6.12 step 3: a type that is not friendly (a monster, SM-KIND 1) is refused on Peaceful, the block
*> light of the cell and the effective sky brightness (the sky light less the night's darkening, or 10 in a thunderstorm; ServerLevel.getEffectiveSkyBrightness) must lie in the
*> inclusive ranges.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STDMOBS.
 COPY BRWORLD.
 COPY CORESTATE.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-RAW                 BINARY-LONG.
 01 WS-DARKEN              BINARY-LONG.
 01 WS-THUNDER             BINARY-LONG.
 01 WS-EFF                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-RULES.
    05 L-RULE-SET          BINARY-LONG.
    05 L-RULE-BMIN         BINARY-LONG.
    05 L-RULE-BMAX         BINARY-LONG.
    05 L-RULE-SMIN         BINARY-LONG.
    05 L-RULE-SMAX         BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-ROW L-RULES L-OK.
     CALL "LIGHT-RAW" USING L-DIM L-X L-Y L-Z WS-SKY WS-BLOCK WS-RAW
     CALL "STDMOB-DARKEN" USING CW-TIME WS-DARKEN
     CALL "WEATHER-THUNDERING" USING L-DIM WS-THUNDER
     IF WS-THUNDER = 1
         MOVE 10 TO WS-DARKEN
     END-IF
     COMPUTE WS-EFF = FUNCTION MAX(WS-SKY - WS-DARKEN, 0)
     MOVE 1 TO L-OK
     IF SM-KIND(L-ROW) = 1 AND BW-DIFFICULTY = 0
         MOVE 0 TO L-OK
     END-IF
     IF WS-BLOCK < L-RULE-BMIN OR WS-BLOCK > L-RULE-BMAX OR WS-EFF < L-RULE-SMIN OR WS-EFF > L-RULE-SMAX
         MOVE 0 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM SPW-CUSTOM-OK.
