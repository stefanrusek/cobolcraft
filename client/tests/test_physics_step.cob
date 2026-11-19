*> Test of the collision step of docs/protocol/51-block-shapes.md section 6 and 6.1 (client/src/physics.cob PHYS-HORIZONTAL, PHYS-STEP-UP): the horizontal axes of a move are resolved
*> in the order of Direction.axisStepOrder (Z then X when |dx| < |dz|, else X then Z), and a blocked move on the ground tries the heights at which a collider's boxes start or end
*> (0 < h <= 0.6, ascending) and keeps the first that carries the player further along the ground. The Player's box is the operator's, 0.7 wide: the worked example of 6.1 (a bottom slab
*> ahead, m = (0.2, 0, 0): the result is (0.2, 0.5, 0)) is shifted to the box x 0.25 to 0.95.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PHYSICS-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY CONTENT.
 COPY CTBSHAPE.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-SX                  FLOAT-LONG.
 01 WS-SY                  FLOAT-LONG.
 01 WS-SZ                  FLOAT-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STEPPED             BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-BLOCK               PIC X(40).
 01 WS-P1                  PIC X(80).
 01 WS-P2                  PIC X(80).
 01 WS-P3                  PIC X(80).
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 0 TO ST-READY
     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE 10 TO WS-Y

*>   A stone block at (1, 10, 1) and the Player at (0.5, 10, 0.5) (box x and z 0.15 to 0.85) moving (0.3, 0.5): |dx| < |dz|, so Z goes first (free: the box does not reach the block's
*>   x range), then X is stopped by the block at 0.15: (0.65, 1.0). Moving (0.5, 0.3) goes X first: (1.0, 0.65).
     MOVE "stone" TO WS-BLOCK
     PERFORM FIND-STATE
     MOVE 1 TO WS-X
     MOVE 1 TO WS-Z
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE 0.5 TO PL-X PL-Z
     MOVE 10 TO PL-Y
     MOVE 0.3 TO WS-DX
     MOVE 0.5 TO WS-DZ
     CALL "PHYS-HORIZONTAL" USING CLIENT-STATE WS-DX WS-DZ WS-BX WS-BZ
     MOVE "R4 axis order: |dx| < |dz| moves Z first, then X stops at the block" TO TL-CASE
     MOVE "0.6500/10.0000/1.0000" TO TL-EXPECTED
     PERFORM ASSERT-POSITION
     MOVE "R4 axis order: the X move was blocked, the Z move was not" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-BX * 10 + WS-BZ
     MOVE 10 TO TL-EXPECTED-N
     PERFORM ASSERT-N
     MOVE 0.5 TO PL-X PL-Z
     MOVE 0.5 TO WS-DX
     MOVE 0.3 TO WS-DZ
     CALL "PHYS-HORIZONTAL" USING CLIENT-STATE WS-DX WS-DZ WS-BX WS-BZ
     MOVE "R4 axis order: |dx| >= |dz| moves X first, then Z stops at the block" TO TL-CASE
     MOVE "1.0000/10.0000/0.6500" TO TL-EXPECTED
     PERFORM ASSERT-POSITION
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-AIR

*>   The worked example of 6.1: a bottom slab at (1, 10, 0), the Player standing at (0.6, 10, 0.5) moves (0.2, 0): the plain move stops at x 0.65 (box max 1.0) and the step
*>   search tries the one candidate 0.5 (the slab's top; its bottom 0 is not above 0): (0.8, 10.5, 0.5) in the same tick.
     MOVE "oak_slab" TO WS-BLOCK
     MOVE "type=bottom,waterlogged=false" TO WS-P1
     PERFORM FIND-STATE
     MOVE 1 TO WS-X
     MOVE 0 TO WS-Z
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE 0.6 TO PL-X
     MOVE 0.5 TO PL-Z
     MOVE 10 TO PL-Y
     PERFORM STEP
     MOVE "R4 step-up: the worked example of 51 6.1, a bottom slab ahead: up 0.5 and on" TO TL-CASE
     MOVE "0.8000/10.5000/0.5000" TO TL-EXPECTED
     PERFORM ASSERT-POSITION
     MOVE 1 TO TL-EXPECTED-N
     MOVE "R4 step-up: the step was taken" TO TL-CASE
     MOVE WS-STEPPED TO TL-OBSERVED-N
     PERFORM ASSERT-N
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-AIR

*>   A full block of height 1 is not a step (the only candidate 1.0 is above 0.6); a block with a low ceiling over the ledge gains nothing (the step does not carry further).
     MOVE "stone" TO WS-BLOCK
     MOVE SPACES TO WS-P1
     PERFORM FIND-STATE
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE 0.6 TO PL-X
     MOVE 0.5 TO PL-Z
     MOVE 10 TO PL-Y
     PERFORM STEP
     MOVE "R4 step-up: a full block is not climbed" TO TL-CASE
     MOVE "0.6500/10.0000/0.5000" TO TL-EXPECTED
     PERFORM ASSERT-POSITION
     MOVE 0 TO TL-EXPECTED-N
     MOVE "R4 step-up: no step was taken over a full block" TO TL-CASE
     MOVE WS-STEPPED TO TL-OBSERVED-N
     PERFORM ASSERT-N
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-AIR
*>   A carpet (1 pixel) at x 1 and a bottom slab at x 2, the Player on the carpet (feet 10.0625) moving 0.5: the plain move stops at the slab's face (x 2); the Y coordinates of the
*>   colliders above the feet are only the slab's top (the carpet's own top is the feet, h = 0 is skipped): the one candidate is 0.4375 and the Player ends on the slab, x 1.9.
     MOVE "white_carpet" TO WS-BLOCK
     PERFORM FIND-STATE
     MOVE 1 TO WS-X
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE "oak_slab" TO WS-BLOCK
     MOVE "type=bottom,waterlogged=false" TO WS-P1
     PERFORM FIND-STATE
     MOVE 2 TO WS-X
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE 1.4 TO PL-X
     MOVE 0.5 TO PL-Z
     MOVE 10.0625 TO PL-Y
     MOVE 0.5 TO WS-DX
     MOVE 0 TO WS-DZ
     MOVE PL-X TO WS-SX
     MOVE PL-Y TO WS-SY
     MOVE PL-Z TO WS-SZ
     CALL "PHYS-HORIZONTAL" USING CLIENT-STATE WS-DX WS-DZ WS-BX WS-BZ
     CALL "PHYS-STEP-UP" USING CLIENT-STATE WS-SX WS-SY WS-SZ WS-DX WS-DZ WS-STEPPED
     MOVE "R4 step-up: from a carpet onto a slab: the candidate is the slab's top (h 0.4375), the move goes on" TO TL-CASE
     MOVE "1.9000/10.5000/0.5000" TO TL-EXPECTED
     PERFORM ASSERT-POSITION
     MOVE 1 TO WS-X
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-AIR
     MOVE 2 TO WS-X
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-AIR
*>   Two candidates met in descending order (a bottom slab at x 1: top 0.5, a carpet at x 2: top 0.0625, three snow layers at x 3: top 0.25; the Player moves 2.2): they are tried
*>   ascending: 0.0625 and 0.25 are still stopped by the slab, 0.5 carries the Player over all three (2.8, 10.5).
     MOVE "oak_slab" TO WS-BLOCK
     MOVE "type=bottom,waterlogged=false" TO WS-P1
     PERFORM FIND-STATE
     MOVE 1 TO WS-X
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE "white_carpet" TO WS-BLOCK
     MOVE SPACES TO WS-P1
     PERFORM FIND-STATE
     MOVE 2 TO WS-X
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE "snow" TO WS-BLOCK
     MOVE "layers=3" TO WS-P1
     PERFORM FIND-STATE
     MOVE 3 TO WS-X
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE 0.6 TO PL-X
     MOVE 0.5 TO PL-Z
     MOVE 10 TO PL-Y
     MOVE PL-X TO WS-SX
     MOVE PL-Y TO WS-SY
     MOVE PL-Z TO WS-SZ
     MOVE 2.2 TO WS-DX
     MOVE 0 TO WS-DZ
     CALL "PHYS-HORIZONTAL" USING CLIENT-STATE WS-DX WS-DZ WS-BX WS-BZ
     CALL "PHYS-STEP-UP" USING CLIENT-STATE WS-SX WS-SY WS-SZ WS-DX WS-DZ WS-STEPPED
     MOVE "R4 step-up: candidates 0.5, 0.0625, 0.25 met are tried ascending: only 0.5 clears the slab and goes over all three" TO TL-CASE
     MOVE "2.8000/10.5000/0.5000" TO TL-EXPECTED
     PERFORM ASSERT-POSITION
     MOVE 1 TO WS-X
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-AIR
     MOVE 2 TO WS-X
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-AIR
     MOVE 3 TO WS-X
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-AIR
     GOBACK.

*> The Player at its position moves (0.2, 0): the plain move, then the step search.
 STEP.
     MOVE PL-X TO WS-SX
     MOVE PL-Y TO WS-SY
     MOVE PL-Z TO WS-SZ
     MOVE 0.2 TO WS-DX
     MOVE 0 TO WS-DZ
     CALL "PHYS-HORIZONTAL" USING CLIENT-STATE WS-DX WS-DZ WS-BX WS-BZ
     CALL "PHYS-STEP-UP" USING CLIENT-STATE WS-SX WS-SY WS-SZ WS-DX WS-DZ WS-STEPPED.

 FIND-STATE.
     CALL "BSH-TEST-FIND" USING WS-BLOCK WS-P1 WS-P2 WS-P3 WS-STATE.

 ASSERT-POSITION.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     CALL "TEST-POSITION" USING CLIENT-STATE TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-N.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-PHYSICS-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSH-TEST-FIND.
*> USING block key, three texts of comma separated "name=value" constraints (spaces = none), state out: the first state of the block
*> that holds them all.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CTBSHAPE.
 01 CT-PROPS.
    05 CTP-COUNT            BINARY-LONG.
    05 CTP-ENTRY OCCURS 16 TIMES.
       10 CTP-NAME          PIC X(24).
       10 CTP-VALUE         PIC X(32).
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 PIC X(819).
 01 WS-VIEW REDEFINES WS-ROW.
    05 FILLER              PIC X(359).
    05 WS-R-COUNT          PIC X(4).
    05 WS-R-FIRST          PIC X(5).
    05 FILLER              PIC X(451).
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-STATES              BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-LIST                PIC X(250).
 01 WS-POINTER             BINARY-LONG.
 01 WS-WANT                PIC X(40).
 01 WS-HAVE                PIC X(60).
 LINKAGE SECTION.
 01 L-KEY                  PIC X(40).
 01 L-P1                   PIC X(80).
 01 L-P2                   PIC X(80).
 01 L-P3                   PIC X(80).
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-P1 L-P2 L-P3 L-STATE.
     MOVE L-KEY TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     COMPUTE WS-FIRST = FUNCTION NUMVAL(WS-R-FIRST)
     COMPUTE WS-STATES = FUNCTION NUMVAL(WS-R-COUNT)
     MOVE SPACES TO WS-LIST
     STRING FUNCTION TRIM(L-P1) "," FUNCTION TRIM(L-P2) "," FUNCTION TRIM(L-P3) "," DELIMITED BY SIZE INTO WS-LIST
     MOVE WS-FIRST TO L-STATE
     MOVE 0 TO WS-OK
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-STATES OR WS-OK = 1
         COMPUTE WS-STATE = WS-FIRST + WS-I
         CALL "CONTENT-STATE-PROPS" USING WS-STATE CT-PROPS WS-STATUS
         MOVE 1 TO WS-OK
         MOVE 1 TO WS-POINTER
         PERFORM UNTIL WS-POINTER > 250
             MOVE SPACES TO WS-WANT
             UNSTRING WS-LIST DELIMITED BY "," INTO WS-WANT WITH POINTER WS-POINTER
             IF WS-WANT NOT = SPACES
                 MOVE 0 TO WS-HAS
                 PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > CTP-COUNT
                     MOVE SPACES TO WS-HAVE
                     STRING FUNCTION TRIM(CTP-NAME(WS-J)) "=" FUNCTION TRIM(CTP-VALUE(WS-J)) DELIMITED BY SIZE INTO WS-HAVE
                     IF WS-HAVE = WS-WANT
                         MOVE 1 TO WS-HAS
                     END-IF
                 END-PERFORM
                 IF WS-HAS = 0
                     MOVE 0 TO WS-OK
                 END-IF
             END-IF
         END-PERFORM
         IF WS-OK = 1
             MOVE WS-STATE TO L-STATE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BSH-TEST-FIND.
 COPY CLTEST.
