*> Implementation test of standing in and on water (operator report of try18: "I can stand on water"; docs/protocol 51 section 3.1 R-A3: water and lava have
*> no collision shape at any level; 13 section 1.3 swimming; 18 section 3.2 travelInWater), with the real states of the standard set over a pool (floor at y 5,
*> water in y 6 to 9, surface at 9 + 8/9): every level of water and lava (0 source, 1 to 7 flowing, 8 to 15 falling) is without collision and passed through; a Player
*> put at the surface sinks and one dropped from above ends on the floor, Space lifts it; a sea pickle (R-F44: collision as its outline, 6 pixels high for one pickle,
*> not the full cube it was) lets a Player stand on it at its own height in the water, 6.375, not on the invisible cube top at 7.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PHYSICS-WATER-STAND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY CONTENT.
 COPY CTBSHAPE.
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
 01 WS-SHAPE               BINARY-LONG.
 01 WS-BLOCK               PIC X(40).
 01 WS-P1                  PIC X(80).
 01 WS-P2                  PIC X(80).
 01 WS-P3                  PIC X(80).
 01 WS-Y0                  FLOAT-LONG.
 01 WS-LEVEL               PIC Z9.
 01 WS-SOLID               BINARY-LONG.
 01 WS-ANY                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     MOVE 1 TO CT-OPEN
     CALL "CONTENT-SET-COUNTS"
     MOVE 0 TO ST-READY
     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "N" TO TL-MODE

*>   Every level of water and lava has no collision (the table gives no shape, so the cell is never solid for the Player or the core).
     MOVE 0 TO WS-ANY
     MOVE "water" TO WS-BLOCK
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 15
         PERFORM LEVEL-SOLID
     END-PERFORM
     MOVE "lava" TO WS-BLOCK
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 15
         PERFORM LEVEL-SOLID
     END-PERFORM
     MOVE "water stand: no level of water or lava has a collision shape (32 states)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ANY TO TL-OBSERVED-N
     PERFORM ASSERT-N

*>   The pool.
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
     MOVE 0 TO PL-YAW PL-PITCH
     MOVE 5.5 TO PL-X
     MOVE 0.5 TO PL-Z

*>   Put at the surface (the feet 0.1 under it) with no motion: 20 ticks later the Player is lower.
     MOVE 9.79 TO PL-Y
     MOVE 0 TO PL-VY PL-ON-GROUND
     MOVE 20 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE "water stand: a Player put at the surface sinks, 20 ticks later it is under 9.7" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-Y < 9.7
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-N

*>   Dropped from 3 blocks above the surface: it ends on the pool floor.
     MOVE 13 TO PL-Y
     MOVE 0 TO PL-VY
     MOVE 120 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE "water stand: a Player dropped over the pool is on its floor (y 6) after 120 ticks, on the ground" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-Y < 6.001 AND PL-Y > 5.999 AND PL-ON-GROUND = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-N

*>   Space held on the floor of the pool: the swimmer rises.
     MOVE CC-KEY-SPACE TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     MOVE 10 TO WS-TICKS
     MOVE PL-Y TO WS-Y0
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP
     MOVE "water stand: Space held in deep water rises more than 0.3 in 10 ticks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-Y > WS-Y0 + 0.3
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-N

*>   A sea pickle on the pool floor (one pickle, waterlogged): its collision is its 6 pixel box, so a Player over it stands at 6.375.
     MOVE "sea_pickle" TO WS-BLOCK
     MOVE "pickles=1" TO WS-P1
     MOVE "waterlogged=true" TO WS-P2
     PERFORM FIND-STATE
     MOVE 8 TO WS-X
     MOVE 6 TO WS-Y
     MOVE 0 TO WS-Z
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE 8.5 TO PL-X
     MOVE 0.5 TO PL-Z
     MOVE 9 TO PL-Y
     MOVE 0 TO PL-VY PL-ON-GROUND
*>   Sinking in water is slow (0.025 a tick at the end): from y 9 to the top of the pickle at 6.375 takes about 105 ticks, so 160 ticks are run.
     MOVE 160 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE "water stand: a Player over one sea pickle on the pool floor stands on it at y 6.375 (not on a cube top at 7)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-Y < 6.376 AND PL-Y > 6.374
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-N
     STOP RUN.

*> The state of level WS-Y of block WS-BLOCK has no collision shape; WS-ANY counts the ones that have.
 LEVEL-SOLID.
     MOVE WS-Y TO WS-LEVEL
     MOVE SPACES TO WS-P1 WS-P2
     STRING "level=" FUNCTION TRIM(WS-LEVEL) DELIMITED BY SIZE INTO WS-P1
     PERFORM FIND-STATE
     CALL "BSH-COLL-ID" USING WS-STATE WS-SHAPE
     MOVE 0 TO WS-SOLID
     IF WS-SHAPE NOT = 0 AND BSH-N(WS-SHAPE + 1) > 0
         MOVE 1 TO WS-SOLID
     END-IF
     ADD WS-SOLID TO WS-ANY.

 FIND-STATE.
     CALL "BSH-TEST-FIND" USING WS-BLOCK WS-P1 WS-P2 WS-P3 WS-STATE.

 ASSERT-N.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-PHYSICS-WATER-STAND.

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
