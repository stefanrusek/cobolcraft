*> Schooling fish (docs/protocol/21 section 4.1 and 4.1.1; lane p49t, T39100): FISH-PACK-JOIN makes the first fish of a group the leader and every later fish follow it (schoolSize counts the leader);
*> FISH-SCHOOL-STEP runs FollowFlockLeaderGoal: a lone fish whose start tick ran out searches the box inflated by 8, picks a leader that can be followed (else itself) and the leader adopts
*> N = max - schoolSize of the fish found in list order (the limit is applied before the leader is excluded: the two worked examples, 6 adopted with schoolSize 7 and 7 adopted with schoolSize 8, max 8;
*> salmon max 5); a follower leaves when its leader is more than 11 blocks away (squared 121) and has no leader once the leader is dead; a leader with followers whose box holds no other fish loses its
*> school with probability 1/200 a tick; a follower heads for its leader (AQUA-SWIM sets the destination to the leader's cell).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-P49T-SCHOOL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 01 WS-CASE                PIC X(160).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-COD-T               BINARY-LONG.
 01 WS-SALMON-T            BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-FISH.
    05 WS-F                BINARY-LONG OCCURS 12 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-FOLLOW              BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-LEADER              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-R3                  BINARY-LONG.
 01 WS-CD                  BINARY-LONG.
 01 WS-DESTX               BINARY-LONG.
 01 WS-KEY24               PIC X(24).
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:cod" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COD-T WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:salmon" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-SALMON-T WS-ENTITY-ROW WS-STATUS
     MOVE "cod" TO WS-KEY24
     CALL "FISH-SCHOOL-MAX" USING WS-KEY24 WS-MAX
     MOVE "acceptance US15 21§4.1 a cod school has at most 8 fish" TO WS-CASE
     MOVE 8 TO WS-E
     MOVE WS-MAX TO WS-O
     PERFORM CHECK-N
     MOVE "salmon" TO WS-KEY24
     CALL "FISH-SCHOOL-MAX" USING WS-KEY24 WS-MAX
     MOVE "acceptance US15 21§4.1 a salmon school has at most 5 fish" TO WS-CASE
     MOVE 5 TO WS-E
     MOVE WS-MAX TO WS-O
     PERFORM CHECK-N
     MOVE "tropical_fish" TO WS-KEY24
     CALL "FISH-SCHOOL-MAX" USING WS-KEY24 WS-MAX
     MOVE "acceptance US15 21§4.1 a tropical fish school has at most 8 fish" TO WS-CASE
     MOVE 8 TO WS-E
     MOVE WS-MAX TO WS-O
     PERFORM CHECK-N
     MOVE "pufferfish" TO WS-KEY24
     CALL "FISH-SCHOOL-MAX" USING WS-KEY24 WS-MAX
     MOVE "acceptance US15 21§4.1 a pufferfish does not school" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-MAX TO WS-O
     PERFORM CHECK-N
*>   Five cod spawned as a group: the first is the leader, the other four follow it (schoolSize 5).
     COMPUTE WS-X = PL-X(WS-PLAYER) + 40
     COMPUTE WS-Y = PL-Y(WS-PLAYER) + 40
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         CALL "MOB-SPAWN" USING WS-DIM WS-COD-T WS-X WS-Y WS-Z WS-YAW WS-F(WS-I)
         CALL "FISH-PACK-JOIN" USING WS-F(1) WS-F(WS-I)
     END-PERFORM
     CALL "FISH-SCHOOL-SIZE" USING WS-F(1) WS-SIZE
     MOVE "acceptance US15 21§4.1.1 5 cod spawned in one cluster: the leader's schoolSize is 5" TO WS-CASE
     MOVE 5 TO WS-E
     MOVE WS-SIZE TO WS-O
     PERFORM CHECK-N
     CALL "FISH-LEADER-ROW" USING WS-F(1) WS-LEADER
     MOVE "acceptance US15 21§4.1.1 the first fish of the group has no leader (it is the leader)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-LEADER TO WS-O
     PERFORM CHECK-N
     CALL "FISH-LEADER-ROW" USING WS-F(3) WS-LEADER
     MOVE "acceptance US15 21§4.1.1 the third fish follows the first" TO WS-CASE
     MOVE WS-F(1) TO WS-E
     MOVE WS-LEADER TO WS-O
     PERFORM CHECK-N
*>   A follower in range heads for the leader; the path is recalculated every 5 ticks.
     MOVE 0 TO EN-SCH-PATH(WS-F(3))
     CALL "FISH-SCHOOL-STEP" USING WS-F(3) WS-FOLLOW
     MOVE "acceptance US15 21§4.1.1 a follower within 11 blocks of its leader follows it" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-FOLLOW TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 21§4.1.1 the destination is the leader's cell (x)" TO WS-CASE
     COMPUTE WS-E = FUNCTION INTEGER(EN-X(WS-F(1)))
     MOVE EN-DEST-X(WS-F(3)) TO WS-O
     PERFORM CHECK-N
*>   AQUA-SWIM (the swimming of a fish in water) gives a follower the leader's cell as its destination and no random destination.
     COMPUTE EN-X(WS-F(3)) = EN-X(WS-F(1)) + 5
     MOVE -999 TO EN-DEST-X(WS-F(3))
     MOVE 0 TO EN-COOLDOWN(WS-F(3))
     MOVE 0 TO EN-SCH-PATH(WS-F(3))
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-F(3)) WS-M
     CALL "AQUA-SWIM" USING WS-F(3) WS-M
     MOVE "acceptance US15 21§4.1.1 AQUA-SWIM of a follower heads for the leader's cell (z)" TO WS-CASE
     MOVE EN-Z(WS-F(1)) TO WS-T
     COMPUTE WS-E = FUNCTION INTEGER(WS-T)
     MOVE EN-DEST-Z(WS-F(3)) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 21§4.1.1 and it keeps that destination (the stroll ticks run)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     MOVE EN-X(WS-F(1)) TO WS-T
     COMPUTE WS-DX = FUNCTION INTEGER(WS-T)
     MOVE WS-F(3) TO WS-R3
     MOVE EN-COOLDOWN(WS-R3) TO WS-CD
     MOVE EN-DEST-X(WS-R3) TO WS-DESTX
     IF WS-CD > 0 AND WS-DESTX = WS-DX
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
*>   Out of range (more than 11 blocks): it stops following, the leader's school shrinks.
     COMPUTE EN-X(WS-F(4)) = EN-X(WS-F(1)) + 12
     CALL "FISH-SCHOOL-STEP" USING WS-F(4) WS-FOLLOW
     MOVE "acceptance US15 21§4.1.1 a follower more than 11 blocks from its leader stops following" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-FOLLOW TO WS-O
     PERFORM CHECK-N
     CALL "FISH-SCHOOL-SIZE" USING WS-F(1) WS-SIZE
     MOVE "acceptance US15 21§4.1.1 stopFollowing lowers the leader's schoolSize to 4" TO WS-CASE
     MOVE 4 TO WS-E
     MOVE WS-SIZE TO WS-O
     PERFORM CHECK-N
*>   A leader that died leaves no followers: isFollower needs a living leader.
     MOVE 0 TO EN-HEALTH(WS-F(1))
     CALL "FISH-LEADER-ROW" USING WS-F(3) WS-LEADER
     MOVE "acceptance US15 21§4.1.1 a fish whose leader died is no follower" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-LEADER TO WS-O
     PERFORM CHECK-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         CALL "ENTITY-REMOVE" USING WS-F(WS-I)
     END-PERFORM
*>   The worked examples (max 8): the searching fish L first in the list adopts 6 (schoolSize 7).
     COMPUTE WS-X = PL-X(WS-PLAYER) - 40
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         CALL "MOB-SPAWN" USING WS-DIM WS-COD-T WS-X WS-Y WS-Z WS-YAW WS-F(WS-I)
     END-PERFORM
     MOVE 1 TO EN-SCH-ROLLED(WS-F(1))
     MOVE 0 TO EN-SCH-NEXT(WS-F(1))
     CALL "FISH-SCHOOL-STEP" USING WS-F(1) WS-FOLLOW
     CALL "FISH-SCHOOL-SIZE" USING WS-F(1) WS-SIZE
     MOVE "acceptance US15 21§4.1.1 leader first in the list of 10: N = 7, limit before exclusion: schoolSize 7 (6 adopted)" TO WS-CASE
     MOVE 7 TO WS-E
     MOVE WS-SIZE TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 21§4.1.1 the searching fish that became its own leader is no follower" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-FOLLOW TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > 10
         CALL "FISH-LEADER-ROW" USING WS-F(WS-I) WS-LEADER
         IF WS-LEADER = WS-F(1)
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "acceptance US15 21§4.1.1 exactly 6 of the others follow it, the first six in the list" TO WS-CASE
     MOVE 6 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
     CALL "FISH-LEADER-ROW" USING WS-F(8) WS-LEADER
     MOVE "acceptance US15 21§4.1.1 the seventh other fish of the list is not adopted" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-LEADER TO WS-O
     PERFORM CHECK-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         CALL "ENTITY-REMOVE" USING WS-F(WS-I)
     END-PERFORM
*>   L last in the list: 7 adopted, schoolSize 8.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         CALL "MOB-SPAWN" USING WS-DIM WS-COD-T WS-X WS-Y WS-Z WS-YAW WS-F(WS-I)
     END-PERFORM
     MOVE 1 TO EN-SCH-ROLLED(WS-F(10))
     MOVE 0 TO EN-SCH-NEXT(WS-F(10))
     CALL "FISH-SCHOOL-STEP" USING WS-F(10) WS-FOLLOW
     CALL "FISH-SCHOOL-SIZE" USING WS-F(10) WS-SIZE
     MOVE "acceptance US15 21§4.1.1 leader last in the list of 10: schoolSize 8 (7 adopted)" TO WS-CASE
     MOVE 8 TO WS-E
     MOVE WS-SIZE TO WS-O
     PERFORM CHECK-N
*>   A lone fish whose box is near a school it can join: it takes the school's leader (the first fish with room).
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         CALL "ENTITY-REMOVE" USING WS-F(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         CALL "MOB-SPAWN" USING WS-DIM WS-COD-T WS-X WS-Y WS-Z WS-YAW WS-F(WS-I)
         CALL "FISH-PACK-JOIN" USING WS-F(1) WS-F(WS-I)
     END-PERFORM
     COMPUTE WS-X = WS-X + 6
     CALL "MOB-SPAWN" USING WS-DIM WS-COD-T WS-X WS-Y WS-Z WS-YAW WS-F(4)
     MOVE 1 TO EN-SCH-ROLLED(WS-F(4))
     MOVE 0 TO EN-SCH-NEXT(WS-F(4))
     CALL "FISH-SCHOOL-STEP" USING WS-F(4) WS-FOLLOW
     MOVE "acceptance US15 21§4.1.1 a lone cod 6 blocks from a school joins it (follower)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-FOLLOW TO WS-O
     PERFORM CHECK-N
     CALL "FISH-SCHOOL-SIZE" USING WS-F(1) WS-SIZE
     MOVE "acceptance US15 21§4.1.1 the school grew to 4" TO WS-CASE
     MOVE 4 TO WS-E
     MOVE WS-SIZE TO WS-O
     PERFORM CHECK-N
*>   While the start tick runs the fish does not search: it is decremented.
     CALL "ENTITY-REMOVE" USING WS-F(4)
     COMPUTE WS-X = WS-X + 1
     CALL "MOB-SPAWN" USING WS-DIM WS-COD-T WS-X WS-Y WS-Z WS-YAW WS-F(4)
     MOVE 1 TO EN-SCH-ROLLED(WS-F(4))
     MOVE 100 TO EN-SCH-NEXT(WS-F(4))
     CALL "FISH-SCHOOL-STEP" USING WS-F(4) WS-FOLLOW
     MOVE "acceptance US15 21§4.1.1 with the start tick above 0 it only counts down (100 to 99)" TO WS-CASE
     MOVE 99 TO WS-E
     MOVE EN-SCH-NEXT(WS-F(4)) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 21§4.1.1 and does not follow yet" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-FOLLOW TO WS-O
     PERFORM CHECK-N
*>   Housekeeping: a leader that has followers and finds nothing else in the box dissolves the school with probability 1/200 a tick.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         CALL "ENTITY-REMOVE" USING WS-F(WS-I)
     END-PERFORM
     COMPUTE WS-Y = WS-Y + 20
     CALL "MOB-SPAWN" USING WS-DIM WS-COD-T WS-X WS-Y WS-Z WS-YAW WS-F(1)
     MOVE 3 TO EN-SCH-FOLLOWERS(WS-F(1))
     MOVE 1 TO EN-SCH-ROLLED(WS-F(1))
     MOVE 1 TO EN-SCH-NEXT(WS-F(1))
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 4000
         CALL "FISH-SCHOOL-STEP" USING WS-F(1) WS-FOLLOW
     END-PERFORM
     CALL "FISH-SCHOOL-SIZE" USING WS-F(1) WS-SIZE
     MOVE "acceptance US15 21§4.1.1 an alone leader's school dissolves (schoolSize 1) within 4000 ticks" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-SIZE TO WS-O
     PERFORM CHECK-N
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-P49T-SCHOOL.
 COPY CORETEST.
 COPY MOBSPTEST.
