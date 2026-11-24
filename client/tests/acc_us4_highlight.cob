*> Acceptance test of US4-1 on the client (client-surface §3; standin-content §3 eye height 1.6,
*> §11.4 block reach 5; 08 §10.8.6 target highlight outline): the block the Player looks at within
*> reach is the target, with the face the look enters through; the render list draws its outline
*> (eye-relative, around the block's cube); nothing is targeted or outlined out of reach or in the
*> open sky.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US4-HIGHLIGHT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-X                   BINARY-LONG VALUE 0.
 01 WS-Y                   BINARY-LONG VALUE 11.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG VALUE 15.
 01 WS-MIN                 FLOAT-LONG OCCURS 3 TIMES.
 01 WS-MAX                 FLOAT-LONG OCCURS 3 TIMES.
 01 WS-E                   PIC -9.99.
 01 WS-TEXT                PIC X(1024).
 01 WS-N                   PIC Z(4)9.
 01 WS-VT-LAYER            PIC XX VALUE "HL".
 01 WS-VT-OK               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
*>   Looking straight down from (0.5, 10, 0.5): the greystone under the feet, (0, 9, 0), top face.
     MOVE 90 TO PL-PITCH
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE 0 TO WS-DRAW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-DRAW-COUNT
         IF RL-D-SLOT(WS-I) = MESH-SLOT-HIGHLIGHT AND RL-D-PIPELINE(WS-I) = CC-PIPE-TRANSLUCENT
             MOVE WS-I TO WS-DRAW
         END-IF
     END-PERFORM
     MOVE "acceptance US4-1 given the Player in the world when they look down at the block under "
         & "their feet then it is the target (0, 9, 0) with its top face (1) and its outline is "
         & "drawn" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     PERFORM TARGET-TEXT
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION CHAR(FUNCTION MIN(WS-DRAW, 1) + 49)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 0/9/0 1 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The outline: 144 eye-relative vertices around the cube (0, 9, 0) to (1, 10, 1).
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         MOVE 1000 TO WS-MIN(WS-I)
         MOVE -1000 TO WS-MAX(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-HL-COUNT
         MOVE FUNCTION MIN(WS-MIN(1), RL-HL-X(WS-I)) TO WS-MIN(1)
         MOVE FUNCTION MIN(WS-MIN(2), RL-HL-Y(WS-I)) TO WS-MIN(2)
         MOVE FUNCTION MIN(WS-MIN(3), RL-HL-Z(WS-I)) TO WS-MIN(3)
         MOVE FUNCTION MAX(WS-MAX(1), RL-HL-X(WS-I)) TO WS-MAX(1)
         MOVE FUNCTION MAX(WS-MAX(2), RL-HL-Y(WS-I)) TO WS-MAX(2)
         MOVE FUNCTION MAX(WS-MAX(3), RL-HL-Z(WS-I)) TO WS-MAX(3)
     END-PERFORM
     MOVE "acceptance US4-1 the highlight is an outline of 144 vertices around the target's cube, "
         & "relative to the eye (0.5, 11.6, 0.5)" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE RL-HL-COUNT TO WS-N
     MOVE FUNCTION TRIM(WS-N) TO TL-OBSERVED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         COMPUTE WS-E ROUNDED = WS-MIN(WS-I)
         STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E) DELIMITED BY SIZE
             INTO TL-OBSERVED
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         COMPUTE WS-E ROUNDED = WS-MAX(WS-I)
         STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E) DELIMITED BY SIZE
             INTO TL-OBSERVED
     END-PERFORM
     MOVE "144 -0.50 -2.60 -0.50 0.50 -1.60 0.50" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-VERTEX-TINTS" USING CLIENT-STATE WS-VT-LAYER WS-VT-OK
     MOVE "tint channel every vertex of the target highlight is untinted white (1, 1, 1) and has no sky term"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-VT-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Looking ahead (+Z) at a ledger_tile wall: 4.5 blocks away it is in reach (north face), 5.5
*>   blocks away it is not.
     MOVE 0 TO PL-PITCH
     MOVE 5 TO WS-Z
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE SPACES TO TL-OBSERVED
     PERFORM TARGET-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE 0 TO WS-STATE
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE 6 TO WS-Z
     MOVE 15 TO WS-STATE
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     CALL "TEST-STEP" USING CLIENT-STATE
     PERFORM TARGET-TEXT
     MOVE RL-HL-COUNT TO WS-N
     STRING FUNCTION TRIM(TL-OBSERVED) " | " FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-N)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US4-1 given a block straight ahead when it is 4.5 blocks from the eye then "
         & "it is the target with its north face (2); at 5.5 blocks it is out of reach: no target, "
         & "no outline" TO TL-CASE
     MOVE "1 0/11/5 2 | 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The open sky above.
     MOVE -90 TO PL-PITCH
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE 0 TO WS-DRAW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-DRAW-COUNT
         IF RL-D-SLOT(WS-I) = MESH-SLOT-HIGHLIGHT
             MOVE WS-I TO WS-DRAW
         END-IF
     END-PERFORM
     MOVE "acceptance US4-1 given the Player looks up into the open sky then nothing is targeted "
         & "or outlined" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = TG-HIT * 10 + FUNCTION MIN(WS-DRAW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 TARGET-TEXT.
     MOVE "0" TO WS-TEXT
     IF TG-HIT = 1
         CALL "TEST-TARGET-TEXT" USING CLIENT-STATE WS-TEXT
     END-IF.
 END PROGRAM ACC-US4-HIGHLIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TARGET-TEXT.
*> USING CLIENT-STATE, text out: "1 <x>/<y>/<z> <face>" of the target.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-E1                  PIC -(5)9.
 01 WS-E2                  PIC -(5)9.
 01 WS-E3                  PIC -(5)9.
 01 WS-E4                  PIC 9.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT.
     MOVE TG-X TO WS-E1
     MOVE TG-Y TO WS-E2
     MOVE TG-Z TO WS-E3
     MOVE TG-FACE TO WS-E4
     MOVE SPACES TO L-TEXT
     STRING "1 " FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2) "/" FUNCTION TRIM(WS-E3) " " WS-E4
         DELIMITED BY SIZE INTO L-TEXT
     GOBACK.
 END PROGRAM TEST-TARGET-TEXT.
 COPY CLTEST.
