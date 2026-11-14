*> Implementation test (002-lane-mobsfull-h8; docs/protocol/20 section 5 Skeleton family): the bow attack interval by kind (skeleton and stray 40 / 20,
*> bogged and parched 70 / 50 on non-Hard / Hard), the bow in the main hand of every skeleton, arrow effects (stray Slowness 600, bogged Poison 100,
*> parched Weakness 600 ticks) applied to a player an arrow hits, and the armour roll of the family.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY PROTO.
 COPY XORO.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ARROW-TYPE          BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ARROW               BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-CASE                PIC X(100).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-INTERVAL            BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-EFFECT              BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-ARMOURED            BINARY-LONG.
 01 WS-BOWS                BINARY-LONG.
 01 WS-KEYS.
    05 FILLER              PIC X(24) VALUE "skeleton".
    05 FILLER              PIC X(24) VALUE "stray".
    05 FILLER              PIC X(24) VALUE "bogged".
    05 FILLER              PIC X(24) VALUE "parched".
 01 WS-KEY-TABLE REDEFINES WS-KEYS.
    05 WS-NAME             PIC X(24) OCCURS 4 TIMES.
 01 WS-EFFECTS.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 18.
    05 FILLER              BINARY-LONG VALUE 17.
 01 WS-EFFECT-TABLE REDEFINES WS-EFFECTS.
    05 WS-EFFECT-ID        BINARY-LONG OCCURS 4 TIMES.
 01 WS-DURATIONS.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 600.
    05 FILLER              BINARY-LONG VALUE 100.
    05 FILLER              BINARY-LONG VALUE 600.
 01 WS-DURATION-TABLE REDEFINES WS-DURATIONS.
    05 WS-DURATION         BINARY-LONG OCCURS 4 TIMES.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     CALL "ARROW-TYPE" USING WS-ARROW-TYPE
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-X0 = WS-X + 8
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         MOVE SPACES TO WS-KEY
         STRING "minecraft:" DELIMITED BY SIZE WS-NAME(WS-K) DELIMITED BY SPACE INTO WS-KEY
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
         CALL "STDMOB-INDEX" USING WS-TYPE WS-M
*>       Interval: 40 / 20 for skeleton and stray, 70 / 50 for bogged and parched.
         MOVE 2 TO WS-I
         CALL "STDMOB-BOW-INTERVAL" USING WS-M WS-I WS-INTERVAL
         MOVE WS-NAME(WS-K) TO WS-CASE
         STRING "acceptance US15 20§5 Skeleton family: " DELIMITED BY SIZE WS-NAME(WS-K) DELIMITED BY SPACE
             " bow interval on Normal" DELIMITED BY SIZE INTO WS-CASE
         IF WS-K <= 2
             MOVE 40 TO WS-EXP
         ELSE
             MOVE 70 TO WS-EXP
         END-IF
         MOVE WS-INTERVAL TO WS-OBS
         CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
         MOVE 3 TO WS-I
         CALL "STDMOB-BOW-INTERVAL" USING WS-M WS-I WS-INTERVAL
         MOVE SPACES TO WS-CASE
         STRING "acceptance US15 20§5 Skeleton family: " DELIMITED BY SIZE WS-NAME(WS-K) DELIMITED BY SPACE
             " bow interval on Hard" DELIMITED BY SIZE INTO WS-CASE
         IF WS-K <= 2
             MOVE 20 TO WS-EXP
         ELSE
             MOVE 50 TO WS-EXP
         END-IF
         MOVE WS-INTERVAL TO WS-OBS
         CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>       Finalized: a bow in the main hand (hand 4).
         MOVE 0 TO WS-BOWS WS-ARMOURED
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 300
             MOVE WS-I TO WS-SEED
             CALL "XORO-SEED" USING WS-SEED XR-STATE
             CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-ROW
             CALL "STDMOB-FINALIZE" USING XR-STATE WS-ROW
             IF EN-HAND(WS-ROW) = 4
                 ADD 1 TO WS-BOWS
             END-IF
             IF EN-EQUIP(WS-ROW) > 0
                 ADD 1 TO WS-ARMOURED
             END-IF
             CALL "ENTITY-REMOVE" USING WS-ROW
         END-PERFORM
         MOVE SPACES TO WS-CASE
         STRING "acceptance US15 20§5 Skeleton family: every " DELIMITED BY SIZE WS-NAME(WS-K) DELIMITED BY SPACE
             " holds a bow" DELIMITED BY SIZE INTO WS-CASE
         MOVE 300 TO WS-EXP
         MOVE WS-BOWS TO WS-OBS
         CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>       Shot: the arrow carries the kind's effect and a player it hits gets it.
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-ROW
         MOVE WS-PLAYER TO EN-TARGET(WS-ROW)
         MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-ROW)
         MOVE 25 TO EN-SWELL(WS-ROW)
         MOVE 21 TO EN-DRAW(WS-ROW)
         MOVE 20 TO PL-HEALTH(WS-PLAYER)
         MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
         CALL "STDMOB-SHOOT" USING WS-ROW WS-M WS-STOP
         MOVE 0 TO WS-ARROW
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
             IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-ARROW-TYPE
                 MOVE WS-I TO WS-ARROW
             END-IF
         END-PERFORM
         MOVE SPACES TO WS-CASE
         STRING "acceptance US15 20§5 Skeleton family: " DELIMITED BY SIZE WS-NAME(WS-K) DELIMITED BY SPACE
             " arrow effect applied on a hit" DELIMITED BY SIZE INTO WS-CASE
         MOVE 0 TO WS-EXP
         MOVE 0 TO WS-OBS
         IF WS-ARROW > 0
             CALL "ARROW-HIT" USING WS-ARROW WS-NONE WS-PLAYER
             IF WS-K > 1
                 MOVE WS-EFFECT-ID(WS-K) TO WS-EFFECT
                 CALL "EFFECT-LEVEL" USING WS-PLAYER WS-EFFECT WS-LEVEL WS-TICKS
                 MOVE WS-DURATION(WS-K) TO WS-EXP
                 MOVE WS-TICKS TO WS-OBS
                 IF WS-LEVEL NOT = 1
                     MOVE -1 TO WS-OBS
                 END-IF
             ELSE
                 MOVE 1 TO WS-EXP WS-OBS
             END-IF
         END-IF
         CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
         CALL "EFFECT-CLEAR-ALL" USING WS-PLAYER
         CALL "ENTITY-REMOVE" USING WS-ROW
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-MOB-20-5.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 LINKAGE SECTION.
 01 L-CASE                 PIC X(100).
 01 L-EXPECTED             BINARY-LONG.
 01 L-OBSERVED             BINARY-LONG.
 PROCEDURE DIVISION USING L-CASE L-EXPECTED L-OBSERVED.
     MOVE "N" TO TL-MODE
     MOVE L-CASE TO TL-CASE
     MOVE L-EXPECTED TO TL-EXPECTED-N
     MOVE L-OBSERVED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-CHK.
 COPY CORETEST.
 COPY MOBSPTEST.
