*> Charged creeper (002-lane-mobsfull-h5; docs/protocol/20 section 6.1). A powered creeper has EN-VARIANT 1 (metadata 17) and explodes with twice its power
*> (STDMOB-SWELL: 6 in place of 3).
*>
*> Entry points:
*>   STDMOB-POWER USING tracker row, powered out   thunderHit: a creeper becomes powered (variant 1, metadata 17 to the viewers); powered out 1, else 0

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-POWER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-POWERED.
     MOVE 0 TO L-POWERED
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF WS-M > 0 AND SM-KEY(WS-M) = "creeper"
         MOVE 1 TO EN-VARIANT(L-ROW)
         MOVE 1 TO L-POWERED
         CALL "STDMOB-VARIANT-SEND" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM STDMOB-POWER.
