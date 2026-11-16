 *> Acceptance test, the raid game rules (docs/protocol/20 sections 14.1 and 14.2, 16 section 13, 33 section 3.4, 37-1 section 3.8; lane 002-lane-mobsb7, T9509): the patrol spawner
*> does nothing while spawn_patrols is false, createOrExtendRaid creates nothing while raids is false or in a dimension where can_start_raid is false (the Nether), and a raid is stopped and
*> removed while raids is false.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-RAID-RULES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY RAIDSTATE.
 COPY PATROL.
 COPY DIMENSIONS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-NAME                PIC X(40).
 01 WS-INDEX               BINARY-LONG.
 01 WS-VALUE               BINARY-DOUBLE.
 01 WS-DIM-SAVED           BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE 2 TO BW-DIFFICULTY
     COMPUTE WS-X = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Y = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-Z = FUNCTION INTEGER(PL-Z(WS-PLAYER))
*>   raids false: no raid is created.
     MOVE "raids" TO WS-NAME
     CALL "BR-RULE-FIND" USING WS-NAME WS-INDEX
     MOVE 0 TO WS-VALUE
     CALL "BR-RULE-SET" USING WS-INDEX WS-VALUE
     CALL "RAID-CREATE-OR-EXTEND" USING WS-PLAYER WS-X WS-Y WS-Z WS-SLOT
     MOVE "acceptance US15 20§14.2 raids false: createOrExtendRaid makes no raid" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SLOT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-VALUE
     CALL "BR-RULE-SET" USING WS-INDEX WS-VALUE
*>   can_start_raid false in the Nether.
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM-SAVED
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 5
         IF DM-KEY(WS-D) = "minecraft:the_nether"
             MOVE WS-D TO PL-DIM(WS-PLAYER)
         END-IF
     END-PERFORM
     CALL "RAID-CREATE-OR-EXTEND" USING WS-PLAYER WS-X WS-Y WS-Z WS-SLOT
     MOVE WS-DIM-SAVED TO PL-DIM(WS-PLAYER)
     MOVE "acceptance US15 37-1§3.8 can_start_raid false in the Nether: no raid" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SLOT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "RAID-CREATE-OR-EXTEND" USING WS-PLAYER WS-X WS-Y WS-Z WS-SLOT
     MOVE "acceptance US15 20§14.2 with the rule on and the attribute true the raid is made" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SLOT > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   raids false: the raid is stopped and removed by the world tick.
     MOVE 0 TO WS-VALUE
     CALL "BR-RULE-SET" USING WS-INDEX WS-VALUE
     MOVE 2 TO RD-STATUS(WS-SLOT)
     MOVE 0 TO RD-CELEB(WS-SLOT)
     CALL "RAID-WORLD-TICK"
     MOVE "acceptance US15 20§14.2 raids false: a raid is stopped and removed" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RD-USED(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-VALUE
     CALL "BR-RULE-SET" USING WS-INDEX WS-VALUE
*>   spawn_patrols false: the spawner counter does not move.
     MOVE "spawn_patrols" TO WS-NAME
     CALL "BR-RULE-FIND" USING WS-NAME WS-INDEX
     MOVE 0 TO WS-VALUE
     CALL "BR-RULE-SET" USING WS-INDEX WS-VALUE
     MOVE 5 TO PT-NEXT
     CALL "PATROL-TICK"
     MOVE "acceptance US15 20§14.1 spawn_patrols false: the counter stays" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE PT-NEXT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-VALUE
     CALL "BR-RULE-SET" USING WS-INDEX WS-VALUE
     CALL "PATROL-TICK"
     MOVE "acceptance US15 20§14.1 spawn_patrols true: the counter counts down" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE PT-NEXT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US15-RAID-RULES.

 COPY CORETEST.
 COPY MOBSPTEST.
