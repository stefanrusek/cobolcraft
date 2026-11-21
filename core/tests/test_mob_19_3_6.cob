*> Implementation test (lane p49v; docs/protocol/19-mobs-land-friendly-and-neutral.md sections 3.2 and 3.6): the spawn genes by class. Donkey and mule randomise only the health (15 + nextInt(8) + nextInt(9)),
*> their jump strength stays the chested base 0.5; a horse draws its health the same way; the zombie horse's jump strength is 0.5 + (r1 + r2 + r3) / 15 and its speed (9 + r1 + r2 + r3) / 42.16 (a formula
*> only: the core has no zombie horse or skeleton horse row).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-19-3-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-HIGH                BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-R1                  FLOAT-LONG.
 01 WS-R2                  FLOAT-LONG.
 01 WS-R3                  FLOAT-LONG.
 01 WS-JUMP                FLOAT-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-MILLI               BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-SPECIES.
    05 FILLER              PIC X(24) VALUE "minecraft:horse".
    05 FILLER              PIC X(24) VALUE "minecraft:donkey".
    05 FILLER              PIC X(24) VALUE "minecraft:mule".
 01 WS-SPECIES-TABLE REDEFINES WS-SPECIES.
    05 WS-SPECIES-KEY      PIC X(24) OCCURS 3 TIMES.
 PROCEDURE DIVISION.
     MOVE 0 TO WS-R1 WS-R2 WS-R3
     CALL "M19-ZOMBIE-HORSE-GENES" USING WS-R1 WS-R2 WS-R3 WS-JUMP WS-SPEED
     COMPUTE WS-MILLI ROUNDED = WS-JUMP * 1000
     MOVE "acceptance US15 19§3.6 Zombie horse: draws 0, 0, 0 give jump strength 0.5" TO WS-CASE
     MOVE 500 TO WS-E
     MOVE WS-MILLI TO WS-O
     PERFORM CHECK-N
     COMPUTE WS-MILLI ROUNDED = WS-SPEED * 10000
     MOVE "acceptance US15 19§3.6 Zombie horse: draws 0, 0, 0 give speed 9 / 42.16 = 0.2135" TO WS-CASE
     MOVE 2135 TO WS-E
     MOVE WS-MILLI TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-R1 WS-R2 WS-R3
     CALL "M19-ZOMBIE-HORSE-GENES" USING WS-R1 WS-R2 WS-R3 WS-JUMP WS-SPEED
     COMPUTE WS-MILLI ROUNDED = WS-JUMP * 1000
     MOVE "acceptance US15 19§3.6 Zombie horse: draws 1, 1, 1 give jump strength 0.7" TO WS-CASE
     MOVE 700 TO WS-E
     MOVE WS-MILLI TO WS-O
     PERFORM CHECK-N
     COMPUTE WS-MILLI ROUNDED = WS-SPEED * 10000
     MOVE "acceptance US15 19§3.6 Zombie horse: draws 1, 1, 1 give speed 12 / 42.16 = 0.2846" TO WS-CASE
     MOVE 2846 TO WS-E
     MOVE WS-MILLI TO WS-O
     PERFORM CHECK-N

     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-FX
     MOVE PL-Y(WS-PLAYER) TO WS-FY
     MOVE PL-Z(WS-PLAYER) TO WS-FZ
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         MOVE WS-SPECIES-KEY(WS-I) TO WS-KEY
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
         MOVE 99 TO WS-LOW
         MOVE 0 TO WS-HIGH WS-BAD
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 60
             CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW
             IF EN-HEALTH(WS-ROW) < WS-LOW
                 MOVE EN-HEALTH(WS-ROW) TO WS-LOW
             END-IF
             IF EN-HEALTH(WS-ROW) > WS-HIGH
                 MOVE EN-HEALTH(WS-ROW) TO WS-HIGH
             END-IF
             IF WS-I > 1
                 COMPUTE WS-MILLI ROUNDED = EN-HORSE-JUMP(WS-ROW) * 1000
                 IF WS-MILLI NOT = 500
                     ADD 1 TO WS-BAD
                 END-IF
             ELSE
                 COMPUTE WS-MILLI ROUNDED = EN-HORSE-JUMP(WS-ROW) * 1000
                 IF WS-MILLI < 400 OR WS-MILLI > 1000
                     ADD 1 TO WS-BAD
                 END-IF
             END-IF
             CALL "ENTITY-REMOVE" USING WS-ROW
         END-PERFORM
         MOVE "acceptance US15 19§3.2 Stat genes: the health of 60 spawns lies in 15 to 30 and varies (low under 20, high over 24)" TO WS-CASE
         MOVE 1 TO WS-E
         MOVE 0 TO WS-O
         IF WS-LOW >= 15 AND WS-LOW < 20 AND WS-HIGH <= 30 AND WS-HIGH > 24
             MOVE 1 TO WS-O
         END-IF
         PERFORM CHECK-N
         MOVE "acceptance US15 19§3.6 Donkey, mule: the jump strength stays 0.5 (a horse draws 0.4 to 1.0)" TO WS-CASE
         MOVE 0 TO WS-E
         MOVE WS-BAD TO WS-O
         PERFORM CHECK-N
     END-PERFORM
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-19-3-6.
 COPY CORETEST.
 COPY MOBSPTEST.
