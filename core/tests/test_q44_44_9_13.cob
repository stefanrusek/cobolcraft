*> Acceptance test (US15, FR-036; docs/protocol/44-residual-mob-questions-9-end-bosses-decorations.md section 13 and 5.2, lane 002-lane-p49j-a): the item pickup and throw delays: the constants of 41 (10 spawned, 40 thrown, 0 dispenser) and the drops of frames and armor stands, which use the 10-tick default (DECOR-DROP on a real world).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-9-13.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CITEMPHYS.
 01 WS-KEY                 PIC X(112).
 01 WS-ROWBUF              PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-NAME                PIC X(240).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WA                     BINARY-LONG.
 01 WB                     BINARY-LONG.
 01 WC                     BINARY-LONG.
 01 WD                     BINARY-LONG.
 01 WE                     BINARY-LONG.
 01 WF1                    FLOAT-LONG.
 01 WF2                    FLOAT-LONG.
 01 WF3                    FLOAT-LONG.
 01 WF4                    FLOAT-LONG.
 01 WF5                    FLOAT-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE "acceptance US15 44-9§13 and 5.2 13 the default pickup delay is 10" TO WS-NAME
     MOVE 10 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = IP-DELAY-DEFAULT
     PERFORM EXPECT
     MOVE "acceptance US15 44-9§13 and 5.2 13 a player throw uses 40" TO WS-NAME
     MOVE 40 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = IP-DELAY-THROWN
     PERFORM EXPECT
     MOVE "acceptance US15 44-9§13 and 5.2 13 a dispenser drop uses 0" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = IP-DELAY-DISPENSER
     PERFORM EXPECT
     MOVE 0 TO WD
     CALL "MS-TEST-OPEN" USING WA
     MOVE PL-DIM(WA) TO WB
     MOVE PL-X(WA) TO WF1
     COMPUTE WF2 = PL-Y(WA) + 20
     MOVE PL-Z(WA) TO WF3
     MOVE "minecraft:stone" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WC WS-ROWBUF WS-STATUS
     CALL "DECOR-DROP" USING WB WF1 WF2 WF3 WC
     PERFORM FIND-DROP
     MOVE "acceptance US15 44-9§13 and 5.2 13 a decoration drop (frame, painting, armor stand pop) is an item with delay 10" TO WS-NAME
     MOVE 10 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     STOP RUN.
 FIND-DROP.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-ITEM(WS-I) = WC AND EN-ITEM-COUNT(WS-I) > 0
             MOVE EN-DELAY(WS-I) TO WD
         END-IF
     END-PERFORM.
 EXPECT.
     MOVE WS-NAME TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED-N
     MOVE WS-OBS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-9-13.
 COPY CORETEST.
 COPY MOBSPTEST.
