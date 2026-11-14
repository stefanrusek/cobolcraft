*> Test of the advancement progress rules (docs/protocol/27 section 5.4 and 5.9; core/src/recipes-27.cob): the
*> requirements are groups that must each have a done criterion (no groups is never satisfied), the percent of satisfied
*> groups, and award (changes only an existing, not yet done criterion; reports when the advancement becomes done), with
*> the recipe advancement pattern of one group holding every criterion (an OR).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-RECIPES-27-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-GROUPS              BINARY-LONG.
 01 WS-NCRIT               BINARY-LONG.
 01 WS-MEMBERS.
    05 WS-M                PIC 9 OCCURS 32 TIMES.
 01 WS-DONE.
    05 WS-D                PIC 9 OCCURS 8 TIMES.
 01 WS-SATISFIED           BINARY-LONG.
 01 WS-IS-DONE             BINARY-LONG.
 01 WS-PERCENT             BINARY-LONG.
 01 WS-CRIT                BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-COMPLETED           BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-TEXT                PIC X(1024).
 PROCEDURE DIVISION.
     MOVE "acceptance US9 27§5 Advancements a requirement list with no groups is never satisfied" TO TL-CASE
     PERFORM CLEAR-ALL
     MOVE 2 TO WS-NCRIT
     MOVE 0 TO WS-GROUPS
     MOVE 1 TO WS-D(1) WS-D(2)
     CALL "ADV-SATISFIED" USING WS-GROUPS WS-MEMBERS WS-DONE WS-SATISFIED WS-IS-DONE
     MOVE SPACES TO WS-TEXT
     PERFORM SHOW-STATE
     CALL "ADV-PERCENT" USING WS-NCRIT WS-GROUPS WS-SATISFIED WS-PERCENT
     MOVE WS-PERCENT TO WS-EDIT
     STRING FUNCTION TRIM(WS-TEXT) " percent " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "satisfied 0 done 0 percent 0" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US9 27§5 Advancements two groups need one done criterion each: after one group 1 of 2 "
         & "satisfied (50 percent), after both done" TO TL-CASE
     PERFORM CLEAR-ALL
     MOVE 2 TO WS-GROUPS
     MOVE 3 TO WS-NCRIT
     MOVE 1 TO WS-M(1) WS-M(2) WS-M(9 + 2)
     MOVE 1 TO WS-M(8 + 3)
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-D(2)
     PERFORM SHOW-STATE
     CALL "ADV-PERCENT" USING WS-NCRIT WS-GROUPS WS-SATISFIED WS-PERCENT
     MOVE WS-PERCENT TO WS-EDIT
     STRING FUNCTION TRIM(WS-TEXT) " percent " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
     MOVE 1 TO WS-D(3)
     PERFORM SHOW-STATE
     MOVE "satisfied 1 done 0 percent 50 satisfied 2 done 1" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US9 27§5 Advancements no criteria gives percent 0" TO TL-CASE
     MOVE 0 TO WS-NCRIT WS-SATISFIED
     MOVE 2 TO WS-GROUPS
     CALL "ADV-PERCENT" USING WS-NCRIT WS-GROUPS WS-SATISFIED WS-PERCENT
     MOVE WS-PERCENT TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US9 27§5 Advancements the recipe pattern: one group of every criterion; the first done "
         & "criterion completes it, a second award changes nothing, an unknown criterion changes nothing" TO TL-CASE
     PERFORM CLEAR-ALL
     MOVE 1 TO WS-GROUPS
     MOVE 2 TO WS-NCRIT
     MOVE 1 TO WS-M(1) WS-M(2)
     MOVE SPACES TO WS-TEXT
     MOVE 2 TO WS-CRIT
     PERFORM AWARD
     PERFORM AWARD
     MOVE 1 TO WS-CRIT
     PERFORM AWARD
     MOVE 5 TO WS-CRIT
     PERFORM AWARD
     MOVE "changed 1 completed 1 changed 0 completed 0 changed 1 completed 0 changed 0 completed 0"
         TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 CLEAR-ALL.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 32
         MOVE 0 TO WS-M(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         MOVE 0 TO WS-D(WS-I)
     END-PERFORM.

 SHOW-STATE.
     CALL "ADV-SATISFIED" USING WS-GROUPS WS-MEMBERS WS-DONE WS-SATISFIED WS-IS-DONE
     MOVE WS-SATISFIED TO WS-EDIT
     MOVE WS-IS-DONE TO WS-EDIT2
     STRING FUNCTION TRIM(WS-TEXT) " satisfied " FUNCTION TRIM(WS-EDIT) " done " FUNCTION TRIM(WS-EDIT2)
         DELIMITED BY SIZE INTO WS-TEXT.

 AWARD.
     CALL "ADV-AWARD" USING WS-CRIT WS-NCRIT WS-GROUPS WS-MEMBERS WS-DONE WS-CHANGED WS-COMPLETED
     MOVE WS-CHANGED TO WS-EDIT
     MOVE WS-COMPLETED TO WS-EDIT2
     STRING FUNCTION TRIM(WS-TEXT) " changed " FUNCTION TRIM(WS-EDIT) " completed " FUNCTION TRIM(WS-EDIT2)
         DELIMITED BY SIZE INTO WS-TEXT.
 END PROGRAM TEST-RECIPES-27-5.

 COPY CORETEST.
