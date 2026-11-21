*> Johnny, the vindicator (docs/protocol/20 section 13.1, 45-6 section 2; 002-lane-p49n).
*>   JOHNNY-IS USING tracker row, johnny out: 1 for a vindicator whose Johnny flag is set (the Byte key Johnny, kept in slot 2 of its EK-SPX slots by SPXTAB.cpy) or whose custom name
*>     (EK-NAME of ENKEEP.cpy: a String tag, the u16 length 6 and the text) is "Johnny"; 0 for any other row. The foe rule is in MOBVS-TICK (mob-vs-villager.cob).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JOHNNY-IS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY ENKEEP.
 01 WS-M                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-JOHNNY               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-JOHNNY.
     MOVE 0 TO L-JOHNNY
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF WS-M > 0
         IF SM-KEY(WS-M) = "vindicator"
             IF EK-SPX-SET(L-ROW, 2) = 1 AND EK-SPX-NUM(L-ROW, 2) NOT = 0
                 MOVE 1 TO L-JOHNNY
             END-IF
             IF EK-NAME-TYPE(L-ROW) = 8 AND EK-NAME-LEN(L-ROW) = 8 AND EK-NAME-RAW(L-ROW)(3:6) = "Johnny"
                 MOVE 1 TO L-JOHNNY
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM JOHNNY-IS.
