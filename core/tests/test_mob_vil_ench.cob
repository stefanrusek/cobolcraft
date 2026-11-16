*> Unit test, the extra price of enchanted trades (docs/protocol/54-client-gap-closures.md section 4.1 and 4.3; lane 002-lane-mobsb2, T7102): an enchanted book of level L costs
*> E = 2 + nextInt(5 + 10 L) + 3 L extra emeralds (doubled for treasure enchantments); traded equipment enchanted with 5 to 19 levels costs that many more.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-VIL-ENCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY VILSTATE.
 01 WS-SALT                BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-LEVEL               BINARY-LONG.
 01 WS-EXTRA               BINARY-LONG.
 01 WS-MAXL                BINARY-LONG.
 01 WS-DOUBLE              BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-SEEN-DOUBLE         BINARY-LONG.
 01 WS-SEEN-L5             BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-LV                  BINARY-LONG.
 01 WS-N-BOOK              BINARY-LONG.
 01 WS-N-GEAR              BINARY-LONG.
 01 WS-WANT                PIC X(32).
 01 WS-EXT                 PIC X(32).
 01 WS-GIVE                PIC X(32).
 01 WS-WC                  BINARY-LONG.
 01 WS-EC                  BINARY-LONG.
 01 WS-GC                  BINARY-LONG.
 01 WS-MU                  BINARY-LONG.
 01 WS-XPV                 BINARY-LONG.
 01 WS-MULT                BINARY-LONG.
 01 WS-MASK                BINARY-LONG.
 01 WS-MOD                 BINARY-LONG.
 01 WS-PROF                PIC X(16).
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE 0 TO WS-BAD WS-SEEN-DOUBLE WS-SEEN-L5
     PERFORM VARYING WS-SALT FROM 1 BY 1 UNTIL WS-SALT > 400
         CALL "VIL-ENCH-PICK" USING WS-SALT WS-KEY WS-LEVEL WS-EXTRA WS-MAXL WS-DOUBLE
         COMPUTE WS-LO = 5 + 3 * (WS-LEVEL - 1)
         COMPUTE WS-HI = 2 + (5 + 10 * WS-LEVEL - 1) + 3 * WS-LEVEL
         IF WS-LEVEL = 5
             MOVE 1 TO WS-SEEN-L5
         END-IF
         COMPUTE WS-LO = 2 + 3 * WS-LEVEL
         IF WS-DOUBLE = 1
             MOVE 1 TO WS-SEEN-DOUBLE
             COMPUTE WS-LO = WS-LO * 2
             COMPUTE WS-HI = WS-HI * 2
         END-IF
         IF WS-LEVEL < 1 OR WS-LEVEL > WS-MAXL OR WS-EXTRA < WS-LO OR WS-EXTRA > WS-HI
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US15 54§4.1 400 draws: level 1 to max level, E within 2 + 3L to 2 + (4 + 10L) + 3L (doubled for treasure)" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     MOVE WS-BAD TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     PERFORM CHECK
     MOVE "acceptance US15 54§4.1 the draws reach a level 5 book and a doubled treasure book" TO TL-CASE
     MOVE "1 1" TO TL-EXPECTED
     MOVE WS-SEEN-L5 TO WS-E1
     MOVE WS-SEEN-DOUBLE TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM CHECK
*>   Real trade sets: books and traded equipment of the librarian, armorer, weaponsmith, toolsmith, fletcher, cleric.
     MOVE 0 TO WS-N-BOOK WS-N-GEAR WS-BAD
     MOVE 1 TO WS-I
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 397
         CALL "VIL-TRADE-ROW" USING WS-J WS-WANT WS-WC WS-EXT WS-EC WS-GIVE WS-GC WS-MU WS-XPV WS-MULT WS-MASK WS-MOD
         MOVE 0 TO WS-EXTRA
         CALL "VIL-ROW-EXTRA" USING WS-J WS-I WS-EXTRA
         EVALUATE WS-MOD
             WHEN 1
                 ADD 1 TO WS-N-BOOK
                 IF WS-EXTRA < 5 OR WS-EXTRA > 142
                     ADD 1 TO WS-BAD
                 END-IF
             WHEN 2
                 ADD 1 TO WS-N-GEAR
                 IF WS-EXTRA < 5 OR WS-EXTRA > 19
                     ADD 1 TO WS-BAD
                 END-IF
             WHEN OTHER
                 IF WS-EXTRA NOT = 0
                     ADD 1 TO WS-BAD
                 END-IF
         END-EVALUATE
     END-PERFORM
     MOVE "acceptance US15 54§4.3 every book trade costs 5 to 142 extra, every equipment trade 5 to 19, others 0" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     MOVE WS-BAD TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     PERFORM CHECK
     MOVE "acceptance US15 54§4.3 the trade table holds book and equipment trades" TO TL-CASE
     MOVE "1" TO TL-EXPECTED
     MOVE "0" TO TL-OBSERVED
     IF WS-N-BOOK > 0 AND WS-N-GEAR > 0
         MOVE "1" TO TL-OBSERVED
     END-IF
     PERFORM CHECK
     STOP RUN.

 CHECK.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-VIL-ENCH.
 COPY CORETEST.
