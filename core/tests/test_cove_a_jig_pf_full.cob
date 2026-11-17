*> Coverage of the feature pool element with a full placed-feature table (docs/protocol/36-structures-3 section 5.5; core/src/struct-jig-place.cob JIG-FEATURE): when the table of placed features holds
*> FD-MAX-PF rows, FD-GET-PF finds no row for a feature id it has not seen, and the element places nothing (no row is added, no random is derived).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVE-A-JIG-PF-FULL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY FEATDATA.
 COPY STRUCTPIECE.
 COPY STRUCTJIG.
 01 WS-KEY                 PIC X(80).
 01 WS-I                   BINARY-LONG.
 01 WS-PF                  BINARY-LONG.
 01 WS-EL                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG VALUE 1.
 01 WS-NUM                 PIC 9(4).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 0 TO FD-PF-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > FD-MAX-PF
         MOVE SPACES TO WS-KEY
         MOVE WS-I TO WS-NUM
         STRING "cobolcraft:cove_a_" WS-NUM DELIMITED BY SIZE INTO WS-KEY
         CALL "FD-GET-PF" USING WS-KEY WS-PF
     END-PERFORM
     MOVE "acceptance US12 36-3§5.5 the table of placed features fills to its maximum" TO TL-CASE
     MOVE FD-MAX-PF TO TL-EXPECTED-N
     MOVE FD-PF-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "cobolcraft:cove_a_unseen" TO WS-KEY
     CALL "FD-GET-PF" USING WS-KEY WS-PF
     MOVE "acceptance US12 36-3§5.5 a new feature id finds no row in a full table" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-PF TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     ADD 1 TO JE-COUNT
     MOVE JE-COUNT TO WS-EL
     MOVE 4 TO JE-KIND(WS-EL)
     MOVE "cobolcraft:cove_a_unseen" TO JE-FEATURE(WS-EL)
     CALL "JIG-FEATURE" USING WS-ROW WS-EL
     MOVE "acceptance US12 36-3§5.5 a feature element of an unknown id in a full table adds no row" TO TL-CASE
     MOVE FD-MAX-PF TO TL-EXPECTED-N
     MOVE FD-PF-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-COVE-A-JIG-PF-FULL.
