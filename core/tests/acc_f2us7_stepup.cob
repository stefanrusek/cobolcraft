*> Acceptance test, US7-2 core half (docs/protocol/13 §1.2 step height 0.6, §1.3 jump and climbing): the
*> server's position correction does not snap a player back on a legitimate step up or climb, and
*> still refuses the endless climb (on-ground 1 claimed in the air while rising).
*> Alice is a survival player. Greystone floor at y 100 (feet y 101); a one-block step at x 21 (feet y
*> 102) and a second at x 22 (feet y 103). Lucite is made climbable (tag minecraft:climbable, no
*> collision) in a column at x 23, the content set having no ladder.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US7-STEPUP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG VALUE 20.
 01 WS-STATE               BINARY-LONG.
 01 WS-GREY                BINARY-LONG VALUE 2.
 01 WS-MOVE                BINARY-LONG VALUE 30.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG VALUE 20.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-MILLI               BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-TEXT                PIC X(256).
 01 WS-REGISTRY            PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:climbable".
 01 WS-MEMBERS.
    05 WS-MEMBER           BINARY-LONG OCCURS 1 TIMES.
 01 WS-STATUS              BINARY-LONG.
 01 WS-LUCITE              BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
*>   The floor, the two steps, the climbable column.
     MOVE 100 TO WS-BY
     PERFORM VARYING WS-BX FROM 20 BY 1 UNTIL WS-BX > 23
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-GREY
     END-PERFORM
     MOVE 101 TO WS-BY
     MOVE 21 TO WS-BX
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-GREY
     MOVE 22 TO WS-BX
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-GREY
     MOVE 102 TO WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-GREY
     MOVE CR-LUCITE TO WS-MEMBER(1)
     CALL "TAG-PUT" USING WS-REGISTRY WS-TAG 1 WS-MEMBERS WS-STATUS
     MOVE CR-LUCITE TO WS-LUCITE
     MOVE 0 TO CB-SOLID(WS-LUCITE + 1)
     MOVE CB-DEFAULT-STATE(WS-LUCITE + 1) TO WS-STATE
     MOVE 23 TO WS-BX
     PERFORM VARYING WS-BY FROM 101 BY 1 UNTIL WS-BY > 110
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     END-PERFORM
     MOVE 20.5 TO WS-FX
     MOVE 101 TO WS-FY
     MOVE 1 TO WS-FLAGS
     PERFORM MOVE-ALICE
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-IDS

     MOVE "acceptance US7-2 given a one-block step when the player walks up it with on-ground 1 "
         & "then it is not snapped back" TO TL-CASE
     MOVE 21.5 TO WS-FX
     MOVE 102 TO WS-FY
     PERFORM MOVE-ALICE
     MOVE "y 102000 ground 1 ids ." TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US7-2 given a second step when the player walks up it then it is not "
         & "snapped back (stairs: step after step)" TO TL-CASE
     MOVE 22.5 TO WS-FX
     MOVE 103 TO WS-FY
     PERFORM MOVE-ALICE
     MOVE "y 103000 ground 1 ids ." TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US7-2 given a half-block rise on the ground (the step height 0.6) when the "
         & "player moves up 0.5 with on-ground 1 onto a block top then it is not snapped back"
         TO TL-CASE
     MOVE 21.5 TO WS-FX
     MOVE 102 TO WS-FY
     PERFORM MOVE-ALICE
     MOVE 20.5 TO WS-FX
     MOVE 101 TO WS-FY
     PERFORM MOVE-ALICE
     MOVE "y 101000 ground 1 ids ." TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US7-2 given a jump onto a ledge when the player rises with on-ground 0 to "
         & "the jump peak (1.2522 above the floor) and lands on the step with on-ground 1 then "
         & "nothing is snapped back" TO TL-CASE
     MOVE 20.5 TO WS-FX
     MOVE 101.42 TO WS-FY
     MOVE 0 TO WS-FLAGS
     PERFORM MOVE-ALICE
     MOVE 101.7532 TO WS-FY
     PERFORM MOVE-ALICE
     MOVE 102.0013 TO WS-FY
     PERFORM MOVE-ALICE
     MOVE 102.1661 TO WS-FY
     PERFORM MOVE-ALICE
     MOVE 102.2492 TO WS-FY
     PERFORM MOVE-ALICE
     MOVE 20.6 TO WS-FX
     MOVE 102.2522 TO WS-FY
     PERFORM MOVE-ALICE
     MOVE 21.5 TO WS-FX
     MOVE 102.1768 TO WS-FY
     PERFORM MOVE-ALICE
     MOVE 102 TO WS-FY
     MOVE 1 TO WS-FLAGS
     PERFORM MOVE-ALICE
     MOVE "y 102000 ground 1 ids ." TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US7-2 given a climbable column when the player climbs it with on-ground 1 "
         & "claimed on every step then each rise is accepted" TO TL-CASE
     MOVE 23.5 TO WS-FX
     MOVE 102 TO WS-FY
     MOVE 1 TO WS-FLAGS
     PERFORM MOVE-ALICE
     PERFORM VARYING WS-MILLI FROM 1 BY 1 UNTIL WS-MILLI > 6
         COMPUTE WS-FY = 102 + WS-MILLI * 0.5
         PERFORM MOVE-ALICE
     END-PERFORM
     MOVE "y 105000 ground 0 ids ." TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US7-2 given the player leaves the climbable column into open air when it "
         & "keeps rising with on-ground 1 then it is refused" TO TL-CASE
     MOVE 25.5 TO WS-FX
     MOVE 105.5 TO WS-FY
     PERFORM MOVE-ALICE
     MOVE "y 105000 ground 0 ids 73" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 MOVE-ALICE.
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS.

 CHECK.
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-IDS
     COMPUTE WS-MILLI ROUNDED = PL-Y(WS-ROW) * 1000
     MOVE WS-MILLI TO WS-EDIT
     MOVE SPACES TO WS-TEXT
     STRING "y " FUNCTION TRIM(WS-EDIT) " ground " PL-ON-GROUND(WS-ROW) " ids "
         DELIMITED BY SIZE INTO WS-TEXT
     IF WS-IDS = SPACES
         MOVE "." TO WS-IDS
     END-IF
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-IDS) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-F2US7-STEPUP.

 COPY CORETEST.
