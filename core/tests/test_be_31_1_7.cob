*> Test of 31 section 7 (Tickers; T0853): a block ticks only the type it owns (createTickerHelper); chest and ender chest tick on the client
*> only, the trapped chest inherits the chest's ticker, the shulker box ticks on both sides, the barrel has no ticker.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BE-31-1-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BESTATE.
 COPY PROTO.
 01 WS-TEXT                PIC X(8192).
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.
 01 WS-EDIT4               PIC -(9)9.
 01 WS-I                   BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-TYPE10              BINARY-LONG VALUE 10.
 01 WS-R                   BINARY-LONG.
 01 WS-SIDE                BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "acceptance US12 31-1§7 tickers: the ticker helper returns the ticker only when the two types are identical" TO TL-CASE
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE-TICKER-FOR" USING WS-A WS-B WS-R
     MOVE WS-R TO WS-EDIT
     MOVE 2 TO WS-B
     CALL "BE-TICKER-FOR" USING WS-A WS-B WS-R
     MOVE WS-R TO WS-EDIT2
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "1 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 31-1§7 tickers: server side only the shulker box ticks; client side chest, trapped chest, ender chest and shulker box tick, the barrel never" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-SIDE FROM 0 BY 1 UNTIL WS-SIDE > 1
         PERFORM VARYING WS-A FROM 0 BY 1 UNTIL WS-A > 48
             CALL "BE-TICKS-ON" USING WS-A WS-SIDE WS-R
             IF WS-R = 1 AND (WS-A = 1 OR WS-A = 2 OR WS-A = 3 OR WS-A = 24 OR WS-A = 26)
                 MOVE WS-A TO WS-EDIT
                 STRING FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
             END-IF
         END-PERFORM
         STRING "| " DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
     END-PERFORM
     MOVE "24 | 1 2 3 24 |" TO TL-EXPECTED
     PERFORM CHECK
     GOBACK.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-BE-31-1-7.

 COPY CORETEST.
