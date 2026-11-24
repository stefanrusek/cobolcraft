*> Implementation test (lane 002-lane-mobsb3, T8102; docs/protocol/20 section 4.2): curing a zombie villager. A golden apple on one with Weakness starts the cure (2401 to 5999 ticks,
*> the apple is used, Weakness leaves, Strength lasts the conversion time); each tick counts the time down; at 0 a villager takes its place with the villager state, Nausea 200 and the
*> cured gossip of the player.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-ZV.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY VILSTATE.
 COPY ZVCURE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-VTYPE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-HELD                PIC X(24).
 01 WS-USED                BINARY-LONG.
 01 WS-WEAK                BINARY-LONG VALUE 17.
 01 WS-STRENGTH            BINARY-LONG VALUE 4.
 01 WS-NAUSEA              BINARY-LONG VALUE 8.
 01 WS-AMP                 BINARY-LONG VALUE 0.
 01 WS-DUR                 BINARY-LONG VALUE 1000.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-REP                 BINARY-LONG.
 01 WS-TIME                BINARY-LONG.
 01 WS-VSLOT               BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-AMT                 BINARY-LONG VALUE 2.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE "minecraft:zombie_villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-VTYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "MOB-SPAWN" USING PL-DIM(WS-PLAYER) WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE EN-ID(WS-ROW) TO WS-ID
     MOVE "golden_apple" TO WS-HELD
*>   No Weakness: nothing happens.
     CALL "ZV-USE" USING WS-PLAYER WS-ROW WS-HELD WS-USED
     MOVE "acceptance US15 20§4.2 a golden apple without Weakness does nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-USED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MEF-ADD" USING WS-ID WS-WEAK WS-AMP WS-DUR WS-FLAGS
     MOVE "bread" TO WS-HELD
     CALL "ZV-USE" USING WS-PLAYER WS-ROW WS-HELD WS-USED
     MOVE "acceptance US15 20§4.2 another item does nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-USED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   With Weakness: the cure starts.
     MOVE "golden_apple" TO WS-HELD
     CALL "ZV-USE" USING WS-PLAYER WS-ROW WS-HELD WS-USED
     MOVE "acceptance US15 20§4.2 a golden apple on a weakened zombie villager starts the cure" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-USED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ZC-FIND" USING WS-ID WS-NO WS-SLOT
     MOVE ZC-TIME(WS-SLOT) TO WS-TIME
     MOVE "acceptance US15 20§4.2 the conversion time is 2401 to 5999" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-TIME >= 2401 AND WS-TIME <= 5999
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MEF-LEVEL" USING WS-ID WS-WEAK WS-LEVEL WS-TICKS
     MOVE "acceptance US15 20§4.2 Weakness is removed" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LEVEL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MEF-LEVEL" USING WS-ID WS-STRENGTH WS-LEVEL WS-TICKS
     MOVE "acceptance US15 20§4.2 Strength I lasts the conversion time" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-LEVEL = 1 AND WS-TICKS = WS-TIME
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A second apple does nothing while converting.
     CALL "MEF-ADD" USING WS-ID WS-WEAK WS-AMP WS-DUR WS-FLAGS
     CALL "ZV-USE" USING WS-PLAYER WS-ROW WS-HELD WS-USED
     MOVE "acceptance US15 20§4.2 a converting zombie villager takes no second apple" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-USED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The villager state of the zombie villager moves to the new villager.
     CALL "VL-SETUP" USING WS-ID WS-ONE WS-TWO WS-VSLOT
     MOVE "librarian" TO VL-PROF(WS-VSLOT)
     MOVE 3 TO VL-LEVEL(WS-VSLOT)
     CALL "VG-ADD" USING WS-ID PL-ENTITY-ID(WS-PLAYER) WS-TWO WS-AMT
*>   The countdown: 1 each tick (and more near iron bars or beds, which are absent here).
     MOVE 3 TO ZC-TIME(WS-SLOT)
     PERFORM 2 TIMES
         CALL "ZV-TICK" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 20§4.2 still converting before the time is up" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ZV-TICK" USING WS-ROW
     MOVE 0 TO WS-N
     MOVE 0 TO WS-NEW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-VTYPE
             ADD 1 TO WS-N
             MOVE WS-I TO WS-NEW
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§4.2 at 0 the zombie villager is gone and a villager stands there" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-USED(WS-ROW) = 0 AND WS-N = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "VL-FIND" USING EN-ID(WS-NEW) WS-NO WS-VSLOT
     MOVE "acceptance US15 20§4.2 the villager keeps its profession" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "librarian" TO TL-EXPECTED
     MOVE VL-PROF(WS-VSLOT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US15 20§4.2 the villager keeps its level" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE VL-LEVEL(WS-VSLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MEF-LEVEL" USING EN-ID(WS-NEW) WS-NAUSEA WS-LEVEL WS-TICKS
     MOVE "acceptance US15 20§4.2 the villager has Nausea for 200 ticks" TO TL-CASE
     MOVE 200 TO TL-EXPECTED-N
     MOVE WS-TICKS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "VG-REP" USING EN-ID(WS-NEW) PL-ENTITY-ID(WS-PLAYER) WS-REP
     MOVE "acceptance US15 20§5 the player is thanked: the reputation is positive" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-REP > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-ZV.
 COPY CORETEST.
 COPY MOBSPTEST.
