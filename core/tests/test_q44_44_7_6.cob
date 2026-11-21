*> Acceptance test (US15, FR-036; docs/protocol/44-residual-mob-questions-7-aquatic.md section 6, lane 002-lane-p49j-a): squid, glow squid and dolphin experience (1 + nextInt(3)
*> for a player kill, none otherwise), the group baby chances (6.3, rule 2.1) and the dolphin feeding outcome (6.4). The real kills use STDMOB-XP through HEALTH-MOB-DAMAGE.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-7-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 01 WS-NAME                PIC X(240).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ORB-TYPE            BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-MOB                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-AMOUNT              BINARY-LONG VALUE 100.
 01 WS-CAUSE               BINARY-LONG VALUE 1.
 01 WS-NO-PLAYER           BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-SUM                 BINARY-LONG.
 01 WS-SEEN1               BINARY-LONG.
 01 WS-SEEN2               BINARY-LONG.
 01 WS-SEEN3               BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-NAMES.
    05 FILLER              PIC X(32) VALUE "minecraft:squid".
    05 FILLER              PIC X(32) VALUE "minecraft:glow_squid".
    05 FILLER              PIC X(32) VALUE "minecraft:dolphin".
 01 WS-NAMES-R REDEFINES WS-NAMES.
    05 WS-MOBNAME          PIC X(32) OCCURS 3 TIMES.
 01 WS-BABY                BINARY-LONG.
 01 WS-LOCKED              BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:experience_orb" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ORB-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = PL-X(WS-PLAYER) + 3
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
         MOVE WS-MOBNAME(WS-K) TO WS-KEY
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
         MOVE 0 TO WS-SEEN1 WS-SEEN2 WS-SEEN3 WS-BAD
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
             CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-MOB
             CALL "HEALTH-MOB-DAMAGE" USING WS-MOB WS-AMOUNT WS-CAUSE WS-PLAYER
             PERFORM ORB-SUM
             EVALUATE WS-SUM
                 WHEN 1 MOVE 1 TO WS-SEEN1
                 WHEN 2 MOVE 1 TO WS-SEEN2
                 WHEN 3 MOVE 1 TO WS-SEEN3
                 WHEN OTHER ADD 1 TO WS-BAD
             END-EVALUATE
             PERFORM CLEAR-ORBS
             ADD 1 TO CW-TIME
         END-PERFORM
         MOVE SPACES TO WS-NAME
         STRING "acceptance US15 44-7§6.1 " DELIMITED BY SIZE WS-MOBNAME(WS-K) DELIMITED BY SPACE
             " gives 1, 2 or 3 points on 60 player kills (none outside)" DELIMITED BY SIZE INTO WS-NAME
         MOVE 0 TO WS-EXP
         MOVE WS-BAD TO WS-OBS
         PERFORM EXPECT
         MOVE SPACES TO WS-NAME
         STRING "acceptance US15 44-7§6.1 " DELIMITED BY SIZE WS-MOBNAME(WS-K) DELIMITED BY SPACE
             " each of 1, 2 and 3 is seen (equal weights)" DELIMITED BY SIZE INTO WS-NAME
         MOVE 3 TO WS-EXP
         COMPUTE WS-OBS = WS-SEEN1 + WS-SEEN2 + WS-SEEN3
         PERFORM EXPECT
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-MOB
         CALL "HEALTH-MOB-DAMAGE" USING WS-MOB WS-AMOUNT WS-CAUSE WS-NO-PLAYER
         PERFORM ORB-SUM
         MOVE SPACES TO WS-NAME
         STRING "acceptance US15 44-7§6.1 " DELIMITED BY SIZE WS-MOBNAME(WS-K) DELIMITED BY SPACE
             " not killed by a player gives no experience" DELIMITED BY SIZE INTO WS-NAME
         MOVE 0 TO WS-EXP
         MOVE WS-SUM TO WS-OBS
         PERFORM EXPECT
     END-PERFORM
*>   13.4: draws 0, 1, 2 give 1, 2, 3.
     MOVE 2 TO WS-I
     CALL "Q7-XP-WATER" USING WS-I WS-OBS
     MOVE "acceptance US15 44-7§6.1 13.4 draw 2 gives 3 points" TO WS-NAME
     MOVE 3 TO WS-EXP
     PERFORM EXPECT
     MOVE 0 TO WS-I
     CALL "Q7-XP-WATER" USING WS-I WS-OBS
     MOVE "acceptance US15 44-7§6.1 13.4 draw 0 gives 1 point" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
*>   6.4 feeding.
     MOVE 1 TO WS-BABY
     MOVE 0 TO WS-LOCKED
     CALL "Q7-DOLPHIN-FEED" USING WS-BABY WS-LOCKED WS-OBS
     MOVE "acceptance US15 44-7§6.4 a fish given to an unlocked baby dolphin ages it up" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     MOVE 1 TO WS-LOCKED
     CALL "Q7-DOLPHIN-FEED" USING WS-BABY WS-LOCKED WS-OBS
     MOVE "acceptance US15 44-7§6.4 an age-locked baby only sets gotFish" TO WS-NAME
     MOVE 2 TO WS-EXP
     PERFORM EXPECT
     MOVE 0 TO WS-BABY
     MOVE 0 TO WS-LOCKED
     CALL "Q7-DOLPHIN-FEED" USING WS-BABY WS-LOCKED WS-OBS
     MOVE "acceptance US15 44-7§6.4 an adult only sets gotFish" TO WS-NAME
     PERFORM EXPECT
     STOP RUN.
 ORB-SUM.
     MOVE 0 TO WS-SUM
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > EN-COUNT
         IF EN-USED(WS-J) = 1 AND EN-TYPE(WS-J) = WS-ORB-TYPE
             COMPUTE WS-SUM = WS-SUM + EN-ITEM(WS-J) * EN-ITEM-COUNT(WS-J)
         END-IF
     END-PERFORM.
 CLEAR-ORBS.
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > EN-COUNT
         IF EN-USED(WS-J) = 1 AND EN-TYPE(WS-J) = WS-ORB-TYPE
             CALL "ENTITY-REMOVE" USING WS-J
         END-IF
     END-PERFORM.
 EXPECT.
     MOVE WS-NAME TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED-N
     MOVE WS-OBS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-7-6.
 COPY CORETEST.
 COPY MOBSPTEST.
