*> Implementation test of swimming on the client (T6220; docs/protocol/53 sections 3, 4, 9; client/src/physics.cob PHYS-SWIM): a player sprinting with the
*> eyes under water gets the swimming flag and the pose 3 (box 0.6 high, camera eye 0.4) a tick later and moves along its look vector: looking up
*> (pitch -45) it rises, looking down (45) it sinks; stopping the sprint ends the flag and the pose; a player wading with the head out of the water
*> cannot start a sprint (shallow water).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SWIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
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
 01 WS-Y0                  FLOAT-LONG.
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
     MOVE "N" TO TL-MODE

*>   A pool: water in the cells y 6 to 9 for x 3 to 12, z -4 to 4 (floor at y 5, surface at about 9.9).
     MOVE "water" TO WS-BLOCK
     MOVE "level=0" TO WS-P1
     PERFORM FIND-STATE
     PERFORM VARYING WS-X FROM 3 BY 1 UNTIL WS-X > 12
         PERFORM VARYING WS-Z FROM -4 BY 1 UNTIL WS-Z > 4
             PERFORM VARYING WS-Y FROM 6 BY 1 UNTIL WS-Y > 9
                 CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 270 TO PL-YAW
     MOVE 0 TO PL-PITCH
     MOVE 3.5 TO PL-X
     MOVE 0.5 TO PL-Z
     MOVE 7.5 TO PL-Y
     MOVE 3 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS

*>   Walking in water with the head under, not sprinting: no swim.
     MOVE "swim a player in water that is not sprinting is not swimming" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-SWIMMING TO TL-OBSERVED-N
     PERFORM ASSERT-N

*>   Sprint (Left Control and W): the flag and the pose follow.
     MOVE CC-KEY-LEFT-CONTROL TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     MOVE CC-KEY-W TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     MOVE 3 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE "swim sprinting with the eyes under water sets the swimming flag" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PL-SWIMMING TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE "swim the pose is swimming (3)" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE PL-POSE TO TL-OBSERVED-N
     PERFORM ASSERT-N

*>   Looking up 45 degrees: the player rises.
     MOVE -45 TO PL-PITCH
     MOVE PL-Y TO WS-Y0
     MOVE 6 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE "swim looking up (pitch -45) the player rises" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-Y > WS-Y0 + 0.3
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-N

*>   Looking down: it sinks.
     MOVE 3.5 TO PL-X
     MOVE 8.0 TO PL-Y
     MOVE 0 TO PL-VY PL-VX PL-VZ
     MOVE 45 TO PL-PITCH
     MOVE PL-Y TO WS-Y0
     MOVE 6 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE "swim looking down (pitch 45) the player sinks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-Y < WS-Y0 - 0.3
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-N

*>   Release forward: the sprint stops (13 stop rule), the flag clears and the pose returns to standing.
     MOVE CC-KEY-W TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP
     MOVE 3 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE "swim the sprint stopped, the flag clears" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-SWIMMING TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE "swim the pose is standing again" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-POSE TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE CC-KEY-LEFT-CONTROL TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP

*>   Shallow water (the head out): a sprint cannot start.
     MOVE 0 TO PL-PITCH
     MOVE 3.5 TO PL-X
     MOVE 8.6 TO PL-Y
     MOVE 0 TO PL-VY PL-VX PL-VZ
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE CC-KEY-LEFT-CONTROL TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     MOVE CC-KEY-W TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     MOVE "swim in shallow water (the head out) a sprint does not start" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-SPRINTING TO TL-OBSERVED-N
     PERFORM ASSERT-N
     STOP RUN.

 FIND-STATE.
     CALL "BSH-TEST-FIND" USING WS-BLOCK WS-P1 WS-P2 WS-P3 WS-STATE.

 ASSERT-N.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-SWIM.

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
