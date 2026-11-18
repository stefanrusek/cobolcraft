 *> Acceptance test, the raiders' walk to the raid (docs/protocol/20 section 13, Pathfind to raid; lane 002-lane-mobsb7, T9514): a raider with an ongoing raid, no target and no village around it walks
*> toward the raid centre (priority 3), every 20 ticks it recruits raiders within 16 blocks that have no raid into the raid's current wave; with a target, in a village or without a raid it does not.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-RAID-WALK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY RAIDSTATE.
 COPY VILPOIX.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-PTYPE               BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-WALK                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-SLOT                BINARY-LONG VALUE 1.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-MEMBER              BINARY-LONG.
 01 WS-P49-OWNER           BINARY-LONG VALUE 900001.
 01 WS-P49-HOME            BINARY-LONG VALUE 2.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 2 TO BW-DIFFICULTY
     MOVE "minecraft:pillager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-PTYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     MOVE 1 TO RD-USED(1)
     MOVE 9 TO RD-ID(1)
     MOVE 1 TO RD-STATUS(1)
     MOVE WS-DIM TO RD-DIM(1)
     COMPUTE RD-CX(1) = FUNCTION INTEGER(WS-X) + 40
     COMPUTE RD-CY(1) = FUNCTION INTEGER(WS-Y)
     COMPUTE RD-CZ(1) = FUNCTION INTEGER(WS-Z)
     MOVE 1 TO RD-GROUPS(1)
     CALL "MOB-SPAWN" USING WS-DIM WS-PTYPE WS-X WS-Y WS-Z WS-YAW WS-A
     CALL "MOB-SPAWN" USING WS-DIM WS-PTYPE WS-X WS-Y WS-Z WS-YAW WS-B
     CALL "RAID-JOIN" USING WS-SLOT WS-ONE WS-A WS-ZERO
     MOVE 0 TO EN-TARGET(WS-A)
     MOVE 0 TO CW-TICKS
     CALL "RAID-WALK" USING WS-A WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 20§13 a raider of an ongoing raid walks toward the raid centre (east)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-WALK = 1 AND WS-HX > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-MEMBER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RR-MAX
         IF RR-ID(WS-I) = EN-ID(WS-B)
             MOVE 1 TO WS-MEMBER
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§13 on the 20 tick beat it recruits a raider within 16 blocks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-MEMBER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-PLAYER TO EN-TARGET(WS-A)
     CALL "RAID-WALK" USING WS-A WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 20§13 with a target it does not walk to the raid" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-TARGET(WS-A)
     MOVE 1 TO PX-KIND(1)
     MOVE WS-DIM TO PX-DIM(1)
     COMPUTE PX-X(1) = FUNCTION INTEGER(WS-X)
     COMPUTE PX-Y(1) = FUNCTION INTEGER(WS-Y)
     COMPUTE PX-Z(1) = FUNCTION INTEGER(WS-Z)
*>   A village needs a claimed point of interest (44-3 section 1.4): the villager 900001 sleeps in this bed.
     CALL "VPX-CLAIM" USING WS-P49-OWNER WS-P49-HOME WS-DIM PX-X(1) PX-Y(1) PX-Z(1)
     CALL "RAID-WALK" USING WS-A WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 20§13 in a village it does not (the raid is at its goal)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PX-KIND(1)
     MOVE 3 TO RD-STATUS(1)
     CALL "RAID-WALK" USING WS-A WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 20§13 a raid that is over: no walk" TO TL-CASE
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "RAID-WALK" USING WS-B WS-HX WS-HZ WS-WALK
     MOVE 1 TO RD-STATUS(1)
     CALL "ENTITY-REMOVE" USING WS-A
     CALL "RAID-WALK" USING WS-B WS-HX WS-HZ WS-WALK
     STOP RUN.
 END PROGRAM ACC-US15-RAID-WALK.

 COPY CORETEST.
 COPY MOBSPTEST.
