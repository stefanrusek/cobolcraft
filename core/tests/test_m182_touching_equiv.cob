*> Equivalence test (002-lane-bugvlag): M182-TOUCHING (the cramming count of the environment tick: the walk to the highest used row, the box test before the species lookup, the sign test for
*> the absolute differences) counts what the loop it replaced counted (every row of 1024, STDMOB-INDEX first, FUNCTION ABS). 56 mobs of seven species are put in a 2.5 x 2.5 block area at the
*> player at drawn positions, so that many boxes overlap; six are dead (health 0), four are in another dimension, and the player is one of the rows. For every used row the two counts must be equal.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-M182-TOUCHING-EQUIV.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEYS.
    05 WS-KEY              PIC X(24) OCCURS 7 TIMES.
 01 WS-SEED                BINARY-DOUBLE VALUE 20261121.
 01 WS-PICK                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-NEW-ROW             BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-GOT                 BINARY-LONG.
 01 WS-REF                 BINARY-LONG.
 01 WS-DIFFER              BINARY-LONG VALUE 0.
 01 WS-ROWS                BINARY-LONG VALUE 0.
 01 WS-SUM                 BINARY-LONG VALUE 0.
 01 WS-OTHER               BINARY-LONG.
 01 WS-EKEY                PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-LIVING              BINARY-LONG.
 01 WS-OTHER-M             BINARY-LONG.
 01 WS-HALF                FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "pig" TO WS-KEY(1)
     MOVE "cow" TO WS-KEY(2)
     MOVE "zombie" TO WS-KEY(3)
     MOVE "villager" TO WS-KEY(4)
     MOVE "iron_golem" TO WS-KEY(5)
     MOVE "slime" TO WS-KEY(6)
     MOVE "sheep" TO WS-KEY(7)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 56
         PERFORM DRAW
         COMPUTE WS-X = PL-X(WS-PLAYER) - 1.25 + WS-PICK / 13107
         PERFORM DRAW
         COMPUTE WS-Z = PL-Z(WS-PLAYER) - 1.25 + WS-PICK / 13107
         PERFORM DRAW
         COMPUTE WS-Y = PL-Y(WS-PLAYER) + WS-PICK / 16384
         PERFORM DRAW
         COMPUTE WS-PICK = FUNCTION MOD(WS-PICK, 7) + 1
         MOVE SPACES TO WS-EKEY
         STRING "minecraft:" DELIMITED BY SIZE WS-KEY(WS-PICK) DELIMITED BY SPACE INTO WS-EKEY
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-NEW-ROW
         IF WS-I <= 6
             MOVE 0 TO EN-HEALTH(WS-NEW-ROW)
         END-IF
         IF WS-I > 6 AND WS-I <= 10
             MOVE 7 TO EN-DIM(WS-NEW-ROW)
         END-IF
     END-PERFORM
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1
             COMPUTE WS-HEIGHT = ET-HEIGHT-MILLI(EN-TYPE(WS-ROW) + 1) / 1000
             CALL "M182-TOUCHING" USING WS-ROW WS-HEIGHT WS-GOT
             PERFORM REFERENCE-COUNT
             ADD 1 TO WS-ROWS
             ADD WS-REF TO WS-SUM
             IF WS-GOT NOT = WS-REF
                 ADD 1 TO WS-DIFFER
             END-IF
         END-IF
     END-PERFORM
     MOVE "bugvlag the cramming count equals the count of the replaced loop for every row" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-DIFFER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "bugvlag the rows overlap (the reference counts over 100 touching pairs, so the case is not vacuous) and many rows ran" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SUM > 100 AND WS-ROWS > 40
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> The loop that M182-ENV-TICK had, for row WS-ROW and height WS-HEIGHT: count in WS-REF.
 REFERENCE-COUNT.
     MOVE 0 TO WS-REF
     PERFORM VARYING WS-OTHER FROM 1 BY 1 UNTIL WS-OTHER > 1024
         IF WS-OTHER NOT = WS-ROW AND EN-USED(WS-OTHER) = 1 AND EN-DIM(WS-OTHER) = EN-DIM(WS-ROW)
             MOVE 0 TO WS-LIVING
             IF EN-PLAYER(WS-OTHER) > 0
                 MOVE 1 TO WS-LIVING
             ELSE
                 CALL "STDMOB-INDEX" USING EN-TYPE(WS-OTHER) WS-OTHER-M
                 IF WS-OTHER-M > 0 AND EN-HEALTH(WS-OTHER) > 0
                     MOVE 1 TO WS-LIVING
                 END-IF
             END-IF
             IF WS-LIVING = 1
                 COMPUTE WS-HALF = (ET-WIDTH-MILLI(EN-TYPE(WS-ROW) + 1) + ET-WIDTH-MILLI(EN-TYPE(WS-OTHER) + 1)) / 2000
                 COMPUTE WS-DX = FUNCTION ABS(EN-X(WS-OTHER) - EN-X(WS-ROW))
                 COMPUTE WS-DZ = FUNCTION ABS(EN-Z(WS-OTHER) - EN-Z(WS-ROW))
                 COMPUTE WS-DY = EN-Y(WS-OTHER) - EN-Y(WS-ROW)
                 IF WS-DX < WS-HALF AND WS-DZ < WS-HALF AND WS-DY < WS-HEIGHT AND WS-DY > - ET-HEIGHT-MILLI(EN-TYPE(WS-OTHER) + 1) / 1000
                     ADD 1 TO WS-REF
                 END-IF
             END-IF
         END-IF
     END-PERFORM.

 DRAW.
     COMPUTE WS-SEED = FUNCTION MOD(WS-SEED * 1103515245 + 12345, 2147483648)
     COMPUTE WS-PICK = FUNCTION MOD(WS-SEED / 65536, 32768).
 END PROGRAM TEST-M182-TOUCHING-EQUIV.
 COPY CORETEST.
 COPY MOBSPTEST.
