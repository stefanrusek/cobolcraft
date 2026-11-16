*> The contents of a thrown potion (lane itemcomp, T9605; docs/protocol/25 section 9.1, 17 section 3.15): POTION-LOAD hands the effects of the potion_contents of a thrown stack to the generic potion entity.
*>
*>   POTION-LOAD USING tracker row (the entity row of POTION-SPAWN), patch handle of the thrown stack, lingering (0 splash, 1 lingering)
*>     the potion's table effects then the custom effects (SC-POTION-RESOLVE at scale 1.0, so the durations stay as listed) go in with POTION-FX; a lingering potion's duration scale PJ-SCALE is 0.25.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. POTION-LOAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SCALE               BINARY-LONG VALUE 1000.
 01 WS-COUNT               BINARY-LONG.
 01 WS-FX.
    05 WS-FX-E OCCURS 8 TIMES.
       10 WS-FX-ID         BINARY-LONG.
       10 WS-FX-AMP        BINARY-LONG.
       10 WS-FX-DUR        BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HANDLE               BINARY-LONG.
 01 L-LINGERING            BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HANDLE L-LINGERING.
     IF L-LINGERING = 1
         CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
         IF WS-SLOT > 0
             MOVE 250 TO PJ-SCALE(WS-SLOT)
         END-IF
     END-IF
     CALL "SC-POTION-RESOLVE" USING L-HANDLE WS-SCALE WS-COUNT WS-FX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         CALL "POTION-FX" USING L-ROW WS-FX-ID(WS-I) WS-FX-AMP(WS-I) WS-FX-DUR(WS-I)
     END-PERFORM
     GOBACK.
 END PROGRAM POTION-LOAD.
