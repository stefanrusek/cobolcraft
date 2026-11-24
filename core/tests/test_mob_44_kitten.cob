*> Implementation test (002-lane-mobsa4; 19 section 5.1 "Offspring"): a kitten takes the variant of either parent (50/50), and is tame with the same owner and the mixed collar when its mother (the first
*> parent) is tame; a wild mother makes a wild kitten.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-44-KITTEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 COPY RULES.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-N3                  BINARY-LONG.
 01 WS-N7                  BINARY-LONG.
 01 WS-OTHER               BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG VALUE 40.
 01 WS-SIZE                BINARY-LONG VALUE 48.
 01 WS-STONE               BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-TAME-OK             BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 24
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 24
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FLOOR WS-STONE
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 2.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-Z0 + 2.5
     MOVE "N" TO TL-MODE
     MOVE 2 TO BW-DIFFICULTY
     MOVE 6000 TO CW-TIME
     MOVE "minecraft:cat" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = WS-X0 + 24.5
     COMPUTE WS-Z = WS-Z0 + 24.5
     COMPUTE WS-Y = WS-FLOOR + 1
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-A
     COMPUTE WS-X = WS-X0 + 25.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-B
     MOVE 3 TO EN-WOOL(WS-A)
     MOVE 7 TO EN-WOOL(WS-B)
     MOVE 1 TO EN-TAMED(WS-A)
     MOVE PL-UUID(WS-PLAYER) TO EN-OWNER-UUID(WS-A)
     MOVE 3 TO EN-COLLAR(WS-A)
     MOVE 0 TO WS-N3 WS-N7 WS-OTHER
     MOVE 1 TO WS-TAME-OK
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 16
         ADD 1 TO CW-TICKS
         ADD 1 TO CW-TIME
         MOVE EN-COUNT TO WS-BEFORE
         CALL "MOB-BREED" USING WS-A WS-B
         MOVE 0 TO WS-BABY
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
             IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-TYPE AND WS-I NOT = WS-A AND WS-I NOT = WS-B AND EN-MOBAGE(WS-I) < 0
                 MOVE WS-I TO WS-BABY
             END-IF
         END-PERFORM
         IF WS-BABY > 0
             EVALUATE EN-WOOL(WS-BABY)
                 WHEN 3 ADD 1 TO WS-N3
                 WHEN 7 ADD 1 TO WS-N7
                 WHEN OTHER ADD 1 TO WS-OTHER
             END-EVALUATE
             IF EN-TAMED(WS-BABY) NOT = 1 OR EN-OWNER-UUID(WS-BABY) NOT = PL-UUID(WS-PLAYER) OR EN-COLLAR(WS-BABY) = 0
                 MOVE 0 TO WS-TAME-OK
             END-IF
             CALL "ENTITY-REMOVE" USING WS-BABY
         END-IF
     END-PERFORM
     MOVE "acceptance US15 19§5.1 Cat: the kitten's variant is always one of its parents' (never another)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OTHER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§5.1 Cat: over 16 litters both parents' variants occur (50/50)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-N3 > 0 AND WS-N7 > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§5.1 Cat: a tame mother's kitten is tame with her owner and has a collar" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-TAME-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A wild mother: a wild kitten.
     MOVE 0 TO EN-TAMED(WS-A)
     CALL "MOB-BREED" USING WS-A WS-B
     MOVE 0 TO WS-BABY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-TYPE AND WS-I NOT = WS-A AND WS-I NOT = WS-B AND EN-MOBAGE(WS-I) < 0
             MOVE WS-I TO WS-BABY
         END-IF
     END-PERFORM
     MOVE "acceptance US15 19§5.1 Cat: a wild mother's kitten is wild" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TAMED(WS-BABY) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-44-KITTEN.
 COPY CORETEST.
 COPY MOBSPTEST.
