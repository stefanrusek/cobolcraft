*> Acceptance test (002-lane-p49b; docs/protocol/20 section 20.1 and validation item 1): creeper blast damage to a player. The worked cases of the section for a
*> normal creeper (power 3, 2R = 6) at 0, 1, 2, 3, 5 and 6 blocks, and a charged creeper (power 6) at 2 and 6 blocks, exposure 1, on Normal; beyond 2R nothing;
*> the difficulty scaling of 3.1 (Easy, Hard and Peaceful) of the 2-block case. Damage in thousandths of a point, within 2 thousandths of the document's figure.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-20-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY CONTENT.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-CX                  FLOAT-LONG.
 01 WS-CY                  FLOAT-LONG.
 01 WS-CZ                  FLOAT-LONG.
 01 WS-POWER               FLOAT-LONG.
 01 WS-KEEP                BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-CREEPER             BINARY-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-LOST                BINARY-LONG.
 01 WS-DIFF                BINARY-LONG.
 01 WS-DATA.
*>   power, distance (blocks), difficulty (1 easy, 2 normal, 3 hard), expected damage in thousandths
    05 FILLER              PIC X(20) VALUE "3 0 2 043000".
    05 FILLER              PIC X(20) VALUE "3 1 2 033083".
    05 FILLER              PIC X(20) VALUE "3 2 2 024333".
    05 FILLER              PIC X(20) VALUE "3 3 2 016750".
    05 FILLER              PIC X(20) VALUE "3 5 2 005083".
    05 FILLER              PIC X(20) VALUE "3 6 2 001000".
    05 FILLER              PIC X(20) VALUE "6 2 2 065167".
    05 FILLER              PIC X(20) VALUE "6 6 2 032500".
    05 FILLER              PIC X(20) VALUE "3 2 1 013167".
    05 FILLER              PIC X(20) VALUE "3 2 3 036500".
    05 FILLER              PIC X(20) VALUE "3 7 2 000000".
    05 FILLER              PIC X(20) VALUE "3 2 0 000000".
 01 WS-TABLE REDEFINES WS-DATA.
    05 WS-LINE OCCURS 12 TIMES.
       10 WS-L-POWER       PIC 9.
       10 FILLER           PIC X.
       10 WS-L-DIST        PIC 9.
       10 FILLER           PIC X.
       10 WS-L-DIFF        PIC 9.
       10 FILLER           PIC X.
       10 WS-L-DAMAGE      PIC 9(6).
       10 FILLER           PIC X(8).
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 16
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 40
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-CX = WS-BX + 0.5
     MOVE WS-BY TO WS-CY
     COMPUTE WS-CZ = WS-BZ + 0.5
     MOVE "minecraft:creeper" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-CX WS-CY WS-CZ WS-YAW WS-CREEPER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         MOVE WS-L-POWER(WS-I) TO WS-POWER
         MOVE WS-L-DIFF(WS-I) TO BW-DIFFICULTY
         COMPUTE PL-X(WS-PLAYER) = WS-CX + WS-L-DIST(WS-I)
         MOVE WS-BY TO PL-Y(WS-PLAYER)
         MOVE WS-CZ TO PL-Z(WS-PLAYER)
         MOVE 100 TO PL-HEALTH(WS-PLAYER)
         MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
         CALL "EXPLODE-RUN" USING WS-DIM WS-CX WS-CY WS-CZ WS-POWER WS-KEEP WS-CREEPER
         COMPUTE WS-LOST = FUNCTION INTEGER(100000 - PL-HEALTH(WS-PLAYER) * 1000 + 0.5)
         IF WS-LOST > 100000
             MOVE 100000 TO WS-LOST
         END-IF
         MOVE SPACES TO TL-CASE
         STRING "acceptance US15 20§20.1 power " WS-L-POWER(WS-I) " at " WS-L-DIST(WS-I) " blocks difficulty " WS-L-DIFF(WS-I)
             DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-L-DAMAGE(WS-I) TO TL-EXPECTED-N
         MOVE WS-LOST TO TL-OBSERVED-N
         IF FUNCTION ABS(WS-LOST - WS-L-DAMAGE(WS-I)) <= 2
             MOVE WS-L-DAMAGE(WS-I) TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-MOB-20-20-1.
 COPY CORETEST.
 COPY MOBSPTEST.
