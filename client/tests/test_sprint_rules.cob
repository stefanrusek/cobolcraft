*> Implementation test of the sprint rules (T6210; docs/protocol/13 section 1.5, 1.3 jumpFromGround, 53 section 8): a double tap of forward starts
*> sprinting (second press within 350 ms) and it lasts while forward is held; it stops when forward is released, at a wall, when the food level is 6 or
*> less (survival), when shift is held, while an item is being used (eating) and under Blindness (which also stops it from starting); the sprint
*> jump adds 0.2 forward on its tick; the field of view modifier of the camera grows to 1.15 while sprinting and back to 1.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SPRINT-RULES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-TEXT                PIC X(1024).
 01 WS-KEY                 BINARY-LONG.
 01 WS-DOWN                BINARY-LONG VALUE CC-EV-KEY-DOWN.
 01 WS-UP                  BINARY-LONG VALUE CC-EV-KEY-UP.
 01 WS-TICKS               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               PIC X(40).
 01 WS-P1                  PIC X(80).
 01 WS-P2                  PIC X(80).
 01 WS-P3                  PIC X(80).
 01 WS-Z0                  FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE 1 TO PL-ENTITY-ID
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     MOVE 1 TO CT-OPEN
     CALL "CONTENT-SET-COUNTS"
     MOVE 0 TO ST-READY
     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE 1 TO CL-FOV-EFFECT
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "N" TO TL-MODE

*>   A wall of stone at z 6 (y 10 and 11, x -1 to 1).
     MOVE "stone" TO WS-BLOCK
     PERFORM FIND-STATE
     PERFORM VARYING WS-X FROM -1 BY 1 UNTIL WS-X > 1
         PERFORM VARYING WS-Y FROM 10 BY 1 UNTIL WS-Y > 11
             MOVE 6 TO WS-Z
             CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
         END-PERFORM
     END-PERFORM

*>   Double tap: W, release, W again 100 ms later.
     MOVE CC-KEY-W TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP
     MOVE "sprint a single tap of forward does not sprint" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-SPRINTING TO TL-OBSERVED-N
     PERFORM ASSERT-N
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     MOVE "sprint a second tap within the window starts sprinting" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PL-SPRINTING TO TL-OBSERVED-N
     PERFORM ASSERT-N
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "sprint the double tap sends start sprinting once (Player Command 0x2A)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "2a010100" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-TEXT(1:8) TO TL-OBSERVED(1:8)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 2 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE PL-Z TO WS-Z0
     MOVE 5 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE "sprint without Left Control: it goes on while forward is held, 0.28 a tick (1.4 in five ticks)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-SPRINTING = 1 AND PL-Z - WS-Z0 > 1.399 AND PL-Z - WS-Z0 < 1.401
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-N
     MOVE "sprint field of view modifier grows to 1.15 (within 0.01) after seven ticks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-FOV-MOD > 1.13 AND PL-FOV-MOD < 1.151
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-N
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP
     MOVE "sprint releasing forward stops sprinting" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-SPRINTING TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE 20 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE "sprint the field of view modifier returns to 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-FOV-MOD > 0.999 AND PL-FOV-MOD < 1.01
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-N

*>   A sprint with Left Control runs into the wall at z 6 and stops there.
     MOVE CC-KEY-LEFT-CONTROL TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     MOVE CC-KEY-W TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     MOVE 30 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE "sprint hitting a wall stops sprinting" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-SPRINTING TO TL-OBSERVED-N
     PERFORM ASSERT-N
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP
     MOVE CC-KEY-LEFT-CONTROL TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP
     MOVE 0.5 TO PL-Z

*>   Food 6: no sprint, and a sprint stops.
     MOVE CC-KEY-LEFT-CONTROL TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     MOVE CC-KEY-W TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     MOVE "sprint Left Control and forward start sprinting" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PL-SPRINTING TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE 6 TO PL-FOOD
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE "sprint food level 6 stops it and it cannot start again" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-SPRINTING TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE 20 TO PL-FOOD

*>   Eating (an item in use) stops it.
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE "sprint it starts again with food 20 (keys still held)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PL-SPRINTING TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE 1 TO PL-EATING
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE "sprint using an item stops sprinting" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-SPRINTING TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE 0 TO PL-EATING

*>   Blindness (effect 14) stops it and stops a start.
     MOVE 1 TO EF-COUNT
     MOVE 14 TO EF-ID(1)
     MOVE 200 TO EF-DUR(1)
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE "sprint blindness stops sprinting" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-SPRINTING TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE 0 TO EF-COUNT

*>   Shift stops it.
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE CC-KEY-LEFT-SHIFT TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     MOVE "sprint holding shift stops sprinting" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-SPRINTING TO TL-OBSERVED-N
     PERFORM ASSERT-N
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP
     MOVE 2 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE 0.5 TO PL-Z

*>   The sprint jump: 0.2 more forward on the tick of the jump.
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE PL-Z TO WS-Z0
     MOVE CC-KEY-SPACE TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     MOVE "sprint the jump tick goes 0.28 + 0.2 forward" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-Z - WS-Z0 > 0.479 AND PL-Z - WS-Z0 < 0.481
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-N
     STOP RUN.

 FIND-STATE.
     CALL "BSH-TEST-FIND" USING WS-BLOCK WS-P1 WS-P2 WS-P3 WS-STATE.

 ASSERT-N.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-SPRINT-RULES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSH-TEST-FIND.
*> USING block key, three texts of comma separated "name=value" constraints (spaces = none), state out: the first state of the block
*> that holds them all.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
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
