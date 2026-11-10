*> Test of 29 section 8, Interaction results (core/src/blockupd-29.cob; T0469): the six InteractionResult values with whether
*> each consumes the action, whether it swings the arm, whether the acting player's own client is told of the swing (false only
*> for a PREDICTED Success), the kind (Success, Fail, Pass, TryEmptyHandInteraction), the item context of a Success (default: an
*> item interaction; the NONE context is not) and withoutItem(). Expected values come from the table of 29 section 8.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BLOCKUPD-29-8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY INTERACT.
 01 WS-CODE                BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-CONSUMES            BINARY-LONG.
 01 WS-SWINGS              BINARY-LONG.
 01 WS-SELF                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-OUT                 BINARY-LONG.
 01 WS-OUT-TEXT            PIC X(64).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 29§8 Interaction results: the values are 1 to 6 in table order" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-OBSERVED-N = IR-SUCCESS * 100000 + IR-SUCCESS-SERVER * 10000 + IR-CONSUME * 1000 + IR-FAIL * 100
         + IR-PASS * 10 + IR-TRY-WITH-EMPTY-HAND
     MOVE 123456 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE IR-SUCCESS TO WS-CODE
     PERFORM SHOW
     MOVE "acceptance US12 29§8 Interaction results: SUCCESS consumes, swings, and its own client is not told (predicted)"
         TO TL-CASE
     MOVE "success consumes 1 swings 1 self 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE IR-SUCCESS-SERVER TO WS-CODE
     PERFORM SHOW
     MOVE "acceptance US12 29§8 Interaction results: SUCCESS_SERVER consumes, swings and tells the acting player's client too"
         TO TL-CASE
     MOVE "success consumes 1 swings 1 self 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE IR-CONSUME TO WS-CODE
     PERFORM SHOW
     MOVE "acceptance US12 29§8 Interaction results: CONSUME consumes and does not swing" TO TL-CASE
     MOVE "success consumes 1 swings 0 self 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE IR-FAIL TO WS-CODE
     PERFORM SHOW
     MOVE "acceptance US12 29§8 Interaction results: FAIL is a Fail, consumes nothing, no swing" TO TL-CASE
     MOVE "fail consumes 0 swings 0 self 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE IR-PASS TO WS-CODE
     PERFORM SHOW
     MOVE "acceptance US12 29§8 Interaction results: PASS is a Pass, consumes nothing, no swing" TO TL-CASE
     MOVE "pass consumes 0 swings 0 self 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE IR-TRY-WITH-EMPTY-HAND TO WS-CODE
     PERFORM SHOW
     MOVE "acceptance US12 29§8 Interaction results: TRY_WITH_EMPTY_HAND consumes nothing, no swing" TO TL-CASE
     MOVE "try consumes 0 swings 0 self 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 29§8 Interaction results: a Success is an item interaction by default and withoutItem() gives the "
         & "NONE context; CONSUME's context is already NONE; other kinds have none" TO TL-CASE
     MOVE IR-SUCCESS TO WS-CODE
     CALL "IR-ITEM-CONTEXT" USING WS-CODE WS-ITEM
     MOVE WS-ITEM TO WS-E1
     CALL "IR-WITHOUT-ITEM" USING WS-CODE WS-ITEM
     MOVE WS-ITEM TO WS-E2
     MOVE IR-CONSUME TO WS-CODE
     CALL "IR-ITEM-CONTEXT" USING WS-CODE WS-ITEM
     MOVE WS-ITEM TO WS-E3
     MOVE IR-FAIL TO WS-CODE
     CALL "IR-ITEM-CONTEXT" USING WS-CODE WS-ITEM
     MOVE WS-ITEM TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 SHOW.
     CALL "IR-PROPERTIES" USING WS-CODE WS-KIND WS-CONSUMES WS-SWINGS WS-SELF
     MOVE WS-CONSUMES TO WS-E1
     MOVE WS-SWINGS TO WS-E2
     MOVE WS-SELF TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     EVALUATE WS-KIND
         WHEN 1
             STRING "success" DELIMITED BY SIZE INTO TL-OBSERVED
         WHEN 2
             STRING "fail" DELIMITED BY SIZE INTO TL-OBSERVED
         WHEN 3
             STRING "pass" DELIMITED BY SIZE INTO TL-OBSERVED
         WHEN OTHER
             STRING "try" DELIMITED BY SIZE INTO TL-OBSERVED
     END-EVALUATE
     MOVE SPACES TO WS-OUT-TEXT
     STRING FUNCTION TRIM(TL-OBSERVED) " consumes " FUNCTION TRIM(WS-E1) " swings " FUNCTION TRIM(WS-E2)
         " self " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-OUT-TEXT
     MOVE WS-OUT-TEXT TO TL-OBSERVED
     .
 END PROGRAM TEST-BLOCKUPD-29-8.
