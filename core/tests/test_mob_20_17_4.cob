*> Acceptance test (lane p49r; docs/protocol/20 section 17.4, 31 section 6, 44-5 section 8, 44-x2 section 2.4): the creaking heart and its protector. The worked case of 17.4 (Overworld, Normal, time of
*> day 14000, a survival player 20 blocks away): the first state update (the body runs on the second tick of a new heart, then every R + 2 = 22 to 26 ticks) makes the heart AWAKE and spawns a protector
*> on top of a full floor block within 16 blocks horizontally of the heart, bound to it (home, entity event 60); at time of day 23401 the attribute is false and the next body tears the protector down
*> (IS_TEARING_DOWN, removed 45 ticks later) and clears the link; a protector farther than 34 blocks is torn down too; a bound creaking whose heart does not list it dies. No spawn in Peaceful, with
*> only a spectator or a player 40 blocks away, in the day (DORMANT) or with the logs gone (UPROOTED).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-17-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY CREAKSTATE.
 COPY HEARTSTATE.
 COPY BRWORLD.
 COPY GAMEEVENT.
 01 WS-GE0                BINARY-DOUBLE.
 01 WS-GK                 BINARY-DOUBLE.
 01 WS-GLOG               BINARY-LONG.
 01 WS-GPLACES            BINARY-LONG.
 01 WS-GOK                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 70.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-HX                  BINARY-LONG.
 01 WS-HY                  BINARY-LONG.
 01 WS-HZ                  BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-CSLOT               BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-LOGS                BINARY-LONG VALUE 1.
 01 WS-PERSIST             BINARY-LONG VALUE 0.
 01 WS-TIME                BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-CROW                BINARY-LONG.
 01 WS-PROBE               BINARY-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PREV                BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-PADDED              PIC X(1030).
 01 WS-HAS                 BINARY-LONG.
 01 WS-MAXY                BINARY-LONG.
 01 WS-IN-RANGE            BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-LEAVES              BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE "minecraft:creaking" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-FX = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 35
     COMPUTE WS-FZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 35
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     COMPUTE WS-HX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-HY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-HZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     MOVE 0 TO PL-MODE(WS-PLAYER)
     COMPUTE PL-X(WS-PLAYER) = WS-HX + 20.5
     MOVE WS-HY TO PL-Y(WS-PLAYER)
     COMPUTE PL-Z(WS-PLAYER) = WS-HZ + 0.5
     MOVE 14000 TO WS-TIME
     MOVE 2 TO BW-DIFFICULTY
     PERFORM NEW-HEART
*>   The first tick is the countdown, the second the body: AWAKE and a protector.
     CALL "TEST-DRAIN-IDS" USING PL-CONN(WS-PLAYER) WS-IDS
     CALL "HEART-TICK" USING WS-SLOT WS-LOGS WS-TIME WS-PERSIST
     MOVE "the first tick of a new heart is only the countdown: no protector yet" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE HT-LINK(WS-SLOT) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     MOVE GE-COUNT TO WS-GE0
     CALL "HEART-TICK" USING WS-SLOT WS-LOGS WS-TIME WS-PERSIST
     MOVE "the body of the second tick makes the heart AWAKE (2)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE HT-STATE(WS-SLOT) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     MOVE 0 TO WS-CROW
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = WS-TYPE
             MOVE WS-E TO WS-CROW
         END-IF
     END-PERFORM
     MOVE "and a creaking was spawned and linked" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-CROW > 0 AND HT-LINK(WS-SLOT) = EN-ID(WS-CROW)
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-LINE
     IF WS-CROW = 0
         STOP RUN
     END-IF
*>   CreakingHeartBlockEntity.spawnProtector (30-8 14.3.3): entity_place at the creaking's position, the creaking as the source.
     MOVE 0 TO WS-GPLACES WS-GOK
     MOVE WS-GE0 TO WS-GK
     PERFORM UNTIL WS-GK >= GE-COUNT
         ADD 1 TO WS-GK
         COMPUTE WS-GLOG = FUNCTION MOD(WS-GK - 1, 128) + 1
         IF GE-L-NAME(WS-GLOG) = "entity_place"
             ADD 1 TO WS-GPLACES
             IF GE-L-SOURCE(WS-GLOG) = WS-CROW AND GE-L-X(WS-GLOG) = EN-X(WS-CROW) AND GE-L-Y(WS-GLOG) = EN-Y(WS-CROW)
                     AND GE-L-Z(WS-GLOG) = EN-Z(WS-CROW)
                 MOVE 1 TO WS-GOK
             END-IF
         END-IF
     END-PERFORM
     MOVE "the protector's spawn posts one entity_place" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-GPLACES TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     MOVE "at the creaking's position with the creaking as the source (30-8 14.3.3)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-GOK TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     MOVE "the protector stands on top of the floor block (y = floor top + 1)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-FY + 1
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(EN-Y(WS-CROW))
     PERFORM ASSERT-LINE
     MOVE 0 TO WS-IN-RANGE
     IF FUNCTION ABS(EN-X(WS-CROW) - WS-HX - 0.5) <= 16.5 AND FUNCTION ABS(EN-Z(WS-CROW) - WS-HZ - 0.5) <= 16.5
         MOVE 1 TO WS-IN-RANGE
     END-IF
     MOVE "and within 16 blocks of the heart horizontally" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-IN-RANGE TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     CALL "CRK-FIND" USING EN-ID(WS-CROW) WS-ONE WS-CSLOT
     MOVE "the creaking is bound to the heart: home position" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-HX * 1000000 + WS-HY * 1000 + WS-HZ
     COMPUTE TL-OBSERVED-N = CRK-HX(WS-CSLOT) * 1000000 + CRK-HY(WS-CSLOT) * 1000 + CRK-HZ(WS-CSLOT)
     IF CRK-HOME(WS-CSLOT) = 0
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-LINE
*>   Entity event 60 reaches the viewers of the creaking: bind one that stands next to the player.
     COMPUTE WS-X = PL-X(WS-PLAYER) + 2
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PROBE
     CALL "TEST-DRAIN-IDS" USING PL-CONN(WS-PLAYER) WS-IDS
     CALL "CREAKING-BIND" USING WS-PROBE WS-HX WS-HY WS-HZ
     CALL "TEST-DRAIN-IDS" USING PL-CONN(WS-PLAYER) WS-IDS
     MOVE SPACES TO WS-PADDED
     STRING " " DELIMITED BY SIZE FUNCTION TRIM(WS-IDS) DELIMITED BY SIZE " " DELIMITED BY SIZE INTO WS-PADDED
     MOVE 0 TO WS-HAS
     INSPECT WS-PADDED TALLYING WS-HAS FOR ALL " 34"
     MOVE "binding a creaking broadcasts entity event 60 to its viewers" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-HAS > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-LINE
     CALL "ENTITY-REMOVE" USING WS-PROBE
*>   The ticker was reset to 20 + nextInt(5): the next body is R + 2 = 22 to 26 ticks after this one.
     MOVE 0 TO WS-TICKS
     MOVE HT-TICKER(WS-SLOT) TO WS-PREV
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40 OR HT-TICKER(WS-SLOT) > WS-PREV
         MOVE HT-TICKER(WS-SLOT) TO WS-PREV
         CALL "HEART-TICK" USING WS-SLOT WS-LOGS WS-TIME WS-PERSIST
         ADD 1 TO WS-TICKS
     END-PERFORM
     MOVE "the next body runs 22 to 26 ticks after the last" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-TICKS >= 22 AND WS-TICKS <= 26
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-LINE
     MOVE "with the link kept (attribute still true)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF HT-LINK(WS-SLOT) = EN-ID(WS-CROW)
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-LINE
*>   Time of day 23401: the attribute is false, the next body tears the protector down and clears the link; the heart is DORMANT.
     MOVE 23401 TO WS-TIME
     PERFORM 27 TIMES
         CALL "HEART-TICK" USING WS-SLOT WS-LOGS WS-TIME WS-PERSIST
     END-PERFORM
     MOVE "after the attribute turned false the link is cleared within a body period" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE HT-LINK(WS-SLOT) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     MOVE "and the heart is DORMANT (1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE HT-STATE(WS-SLOT) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     MOVE "and the protector is tearing down for 45 ticks" TO TL-CASE
     MOVE 45 TO TL-EXPECTED-N
     MOVE CRK-TEAR(WS-CSLOT) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     PERFORM 44 TIMES
         CALL "MOB-STEP" USING WS-CROW
     END-PERFORM
     MOVE "it is still there after 44 ticks of teardown" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-USED(WS-CROW) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     CALL "MOB-STEP" USING WS-CROW
     MOVE "and removed on the 45th" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-CROW) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
*>   Farther than 34 blocks from the heart: torn down too (attribute true).
     MOVE 14000 TO WS-TIME
     PERFORM NEW-HEART
     PERFORM 2 TIMES
         CALL "HEART-TICK" USING WS-SLOT WS-LOGS WS-TIME WS-PERSIST
     END-PERFORM
     MOVE 0 TO WS-CROW
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = WS-TYPE
             MOVE WS-E TO WS-CROW
         END-IF
     END-PERFORM
     CALL "CRK-FIND" USING EN-ID(WS-CROW) WS-ONE WS-CSLOT
     COMPUTE EN-X(WS-CROW) = WS-HX + 35.5
     MOVE WS-HZ TO EN-Z(WS-CROW)
     MOVE WS-HY TO EN-Y(WS-CROW)
     PERFORM 27 TIMES
         CALL "HEART-TICK" USING WS-SLOT WS-LOGS WS-TIME WS-PERSIST
     END-PERFORM
     MOVE "a protector 35 blocks from the heart is torn down" TO TL-CASE
     MOVE 45 TO TL-EXPECTED-N
     MOVE CRK-TEAR(WS-CSLOT) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     CALL "ENTITY-REMOVE" USING WS-CROW
*>   A persistent protector survives the end of the attribute.
     PERFORM NEW-HEART
     PERFORM 2 TIMES
         CALL "HEART-TICK" USING WS-SLOT WS-LOGS WS-TIME WS-PERSIST
     END-PERFORM
     MOVE 23401 TO WS-TIME
     MOVE 1 TO WS-PERSIST
     PERFORM 27 TIMES
         CALL "HEART-TICK" USING WS-SLOT WS-LOGS WS-TIME WS-PERSIST
     END-PERFORM
     MOVE "a protector that requires persistence keeps its link when the attribute is false" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF HT-LINK(WS-SLOT) > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-LINE
     MOVE 0 TO WS-PERSIST
*>   A bound creaking whose heart does not list it dies.
     MOVE 0 TO WS-CROW
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = WS-TYPE
             MOVE WS-E TO WS-CROW
         END-IF
     END-PERFORM
     MOVE 0 TO HT-LINK(WS-SLOT)
     CALL "MOB-STEP" USING WS-CROW
     MOVE "a bound creaking that its heart no longer lists dies (health 0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-CROW) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     CALL "ENTITY-REMOVE" USING WS-CROW
*>   A link to a creaking that does not exist is cleared once the heart is 30 ticks old.
     MOVE 14000 TO WS-TIME
     PERFORM NEW-HEART
     MOVE 999999 TO HT-LINK(WS-SLOT)
     MOVE 40 TO HT-AGE(WS-SLOT)
     MOVE 0 TO PL-MODE(WS-PLAYER)
     PERFORM 2 TIMES
         CALL "HEART-TICK" USING WS-SLOT WS-LOGS WS-TIME WS-PERSIST
     END-PERFORM
     MOVE "a link to a creaking that is gone is cleared after the 30 tick grace period" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF HT-LINK(WS-SLOT) NOT = 999999
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-LINE
*>   A creaking bound to a heart position that has no heart record dies too.
     COMPUTE WS-X = PL-X(WS-PLAYER) + 2
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-CROW
     CALL "CREAKING-BIND" USING WS-CROW WS-HX WS-HY WS-HZ
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > HT-MAX
         INITIALIZE HT-ENTRY(WS-I)
     END-PERFORM
     CALL "MOB-STEP" USING WS-CROW
     MOVE "a creaking bound to a heart without a record dies" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-CROW) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     CALL "ENTITY-REMOVE" USING WS-CROW
*>   A leaves block is refused as a floor.
     MOVE "minecraft:oak_leaves" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     CALL "CRK-STATE-SOLID" USING WS-STATE WS-SOLID WS-LEAVES
     MOVE "oak leaves are solid and leaves (the strategy refuses them as a floor)" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-SOLID * 10 + WS-LEAVES
     PERFORM ASSERT-LINE
*>   No spawn: Peaceful; only a spectator; a player 40 blocks away; in the day; logs gone.
     MOVE 14000 TO WS-TIME
     MOVE 0 TO BW-DIFFICULTY
     PERFORM NEW-HEART
     PERFORM 30 TIMES
         CALL "HEART-TICK" USING WS-SLOT WS-LOGS WS-TIME WS-PERSIST
     END-PERFORM
     MOVE "no protector in Peaceful" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE HT-LINK(WS-SLOT) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     MOVE 2 TO BW-DIFFICULTY
     MOVE 3 TO PL-MODE(WS-PLAYER)
     PERFORM NEW-HEART
     PERFORM 30 TIMES
         CALL "HEART-TICK" USING WS-SLOT WS-LOGS WS-TIME WS-PERSIST
     END-PERFORM
     MOVE "no protector with only a spectator near" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE HT-LINK(WS-SLOT) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     MOVE 1 TO PL-MODE(WS-PLAYER)
     COMPUTE PL-X(WS-PLAYER) = WS-HX + 40.5
     PERFORM NEW-HEART
     PERFORM 30 TIMES
         CALL "HEART-TICK" USING WS-SLOT WS-LOGS WS-TIME WS-PERSIST
     END-PERFORM
     MOVE "no protector with the only player 40 blocks away" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE HT-LINK(WS-SLOT) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     COMPUTE PL-X(WS-PLAYER) = WS-HX + 20.5
     MOVE 5000 TO WS-TIME
     PERFORM NEW-HEART
     PERFORM 30 TIMES
         CALL "HEART-TICK" USING WS-SLOT WS-LOGS WS-TIME WS-PERSIST
     END-PERFORM
     MOVE "a creative player within 32 blocks counts, but by day the heart is DORMANT: no protector" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = HT-STATE(WS-SLOT) * 10 + HT-LINK(WS-SLOT)
     PERFORM ASSERT-LINE
     MOVE 14000 TO WS-TIME
     MOVE 0 TO WS-LOGS
     PERFORM NEW-HEART
     PERFORM 30 TIMES
         CALL "HEART-TICK" USING WS-SLOT WS-LOGS WS-TIME WS-PERSIST
     END-PERFORM
     MOVE "without its logs a heart with no link is UPROOTED and spawns nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = HT-STATE(WS-SLOT) + HT-LINK(WS-SLOT)
     PERFORM ASSERT-LINE
     STOP RUN.

*> A fresh heart record at the heart position (the creaking records are cleared too).
 NEW-HEART.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > HT-MAX
         INITIALIZE HT-ENTRY(WS-I)
     END-PERFORM
     CALL "HEART-FIND" USING WS-DIM WS-HX WS-HY WS-HZ WS-ONE WS-SLOT
     .

 ASSERT-LINE.
     MOVE SPACES TO WS-ENTITY-ROW
     STRING "acceptance US15 20§17.4 Creaking heart: " DELIMITED BY SIZE FUNCTION TRIM(TL-CASE) DELIMITED BY SIZE INTO WS-ENTITY-ROW
     MOVE WS-ENTITY-ROW TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
 END PROGRAM TEST-MOB-20-17-4.
 COPY CORETEST.
 COPY MOBSPTEST.
