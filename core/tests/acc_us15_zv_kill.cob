*> Acceptance test, a villager killed by a zombie (docs/protocol/20 sections 4 and 4.2; lane 002-lane-mobsb4, T8803): Normal difficulty converts on a coin, Hard always, Easy never; the
*> zombie villager takes the position, the villager state and the baby flag, and no drop; the converting flag (metadata 19) is sent while curing; curing drops the zombie villager's
*> equipment; a converting zombie villager does not despawn for distance.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-ZV-KILL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY VILSTATE.
 COPY BRWORLD.
 COPY ZVCURE.
 COPY CITEMS.
 COPY PROTO.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-KEY24               PIC X(24).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-VTYPE               BINARY-LONG.
 01 WS-ZTYPE               BINARY-LONG.
 01 WS-CTYPE               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-YES                 BINARY-LONG.
 01 WS-DIFF                BINARY-LONG.
 01 WS-COIN                BINARY-LONG.
 01 WS-CONVERTED           BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-E                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-N0                  BINARY-LONG.
 01 WS-ZV                  BINARY-LONG.
 01 WS-VID                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-HELD                PIC X(24).
 01 WS-USED                BINARY-LONG.
 01 WS-WEAK                BINARY-LONG VALUE 17.
 01 WS-AMP                 BINARY-LONG VALUE 0.
 01 WS-DUR                 BINARY-LONG VALUE 1000.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-PID                 BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 WS-VIEW.
    05 WS-BYTE             PIC X OCCURS 64 TIMES.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-VTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:zombie_villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-CTYPE WS-ENTITY-ROW WS-STATUS
*>   The rule.
     MOVE "zombie" TO WS-KEY24
     MOVE 1 TO WS-DIFF
     MOVE 1 TO WS-COIN
     CALL "ZV-KILL-RULE" USING WS-DIFF WS-COIN WS-KEY24 WS-YES
     MOVE "acceptance US15 20§4 on Easy the villager dies normally" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-YES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-DIFF
     CALL "ZV-KILL-RULE" USING WS-DIFF WS-COIN WS-KEY24 WS-YES
     MOVE "acceptance US15 20§4 on Normal a true coin converts" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-YES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-COIN
     CALL "ZV-KILL-RULE" USING WS-DIFF WS-COIN WS-KEY24 WS-YES
     MOVE "acceptance US15 20§4 on Normal a false coin does not" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-YES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-DIFF
     CALL "ZV-KILL-RULE" USING WS-DIFF WS-COIN WS-KEY24 WS-YES
     MOVE "acceptance US15 20§4 on Hard it always converts" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-YES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "creeper" TO WS-KEY24
     CALL "ZV-KILL-RULE" USING WS-DIFF WS-COIN WS-KEY24 WS-YES
     MOVE "acceptance US15 20§4 only zombies convert (not a creeper)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-YES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         EVALUATE WS-I
             WHEN 1 MOVE "husk" TO WS-KEY24
             WHEN 2 MOVE "drowned" TO WS-KEY24
             WHEN 3 MOVE "zombie_villager" TO WS-KEY24
             WHEN 4 MOVE "zombie" TO WS-KEY24
         END-EVALUATE
         CALL "ZV-KILL-RULE" USING WS-DIFF WS-COIN WS-KEY24 WS-YES
         MOVE "acceptance US15 20§4 the zombie family converts" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE WS-YES TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   Live: a librarian villager with xp 7 killed by a zombie on Hard.
     MOVE 3 TO BW-DIFFICULTY
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z0
     CALL "MOB-SPAWN" USING WS-DIM WS-VTYPE WS-X WS-Y WS-Z0 WS-YAW WS-V
     CALL "MOB-SPAWN" USING WS-DIM WS-CTYPE WS-X WS-Y WS-Z0 WS-YAW WS-C
     MOVE EN-ID(WS-V) TO WS-VID
     CALL "VL-FIND" USING WS-VID WS-NO WS-SLOT
     MOVE "librarian" TO VL-PROF(WS-SLOT)
     MOVE 7 TO VL-XP(WS-SLOT)
     MOVE -10000 TO EN-MOBAGE(WS-V)
     MOVE 1 TO EN-VARIANT(WS-V)
     MOVE 0 TO WS-N0
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = CR-LOOSE-ITEM
             ADD 1 TO WS-N0
         END-IF
     END-PERFORM
     CALL "ZV-KILLED" USING WS-V WS-C WS-CONVERTED
     MOVE "acceptance US15 20§4 Hard: the kill converts" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-CONVERTED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§4 the villager is gone" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-USED(WS-V) * (1 - FUNCTION MIN(1, FUNCTION ABS(EN-ID(WS-V) - WS-VID) * 1))
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-ZV
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = WS-ZTYPE
             MOVE WS-E TO WS-ZV
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§4 a zombie villager stands there" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ZV > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "VL-FIND" USING EN-ID(WS-ZV) WS-NO WS-SLOT
     MOVE "T" TO TL-MODE
     MOVE "acceptance US15 20§4 the villager state moved to the zombie villager (librarian)" TO TL-CASE
     MOVE "librarian" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF WS-SLOT > 0
         MOVE VL-PROF(WS-SLOT) TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US15 20§4 a baby villager makes a baby zombie villager" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-VARIANT(WS-ZV) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-N
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = CR-LOOSE-ITEM
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§4 the villager does not drop" TO TL-CASE
     MOVE WS-N0 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Metadata 19 while curing.
     MOVE 0 TO EN-VARIANT(WS-ZV)
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "STDMOB-VARIANT-BUILD" USING WS-ZV PB-BUFFER
     MOVE "acceptance US15 20§4.2 not converting: no variant packet" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PB-LENGTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MEF-ADD" USING EN-ID(WS-ZV) WS-WEAK WS-AMP WS-DUR WS-FLAGS
     MOVE "golden_apple" TO WS-HELD
     CALL "ZV-USE" USING WS-PLAYER WS-ZV WS-HELD WS-USED
     CALL "PB-RESET" USING PB-BUFFER
     CALL "STDMOB-VARIANT-BUILD" USING WS-ZV PB-BUFFER
     SET ADDRESS OF WS-VIEW TO PB-ADDR
     MOVE "T" TO TL-MODE
     MOVE "acceptance US15 20§4.2 converting: Set Entity Data with index 19 boolean true" TO TL-CASE
     MOVE "yes" TO TL-EXPECTED
     MOVE "no" TO TL-OBSERVED
     IF PB-LENGTH >= 6 AND WS-BYTE(1) = X"65" AND WS-BYTE(3) = X"13" AND WS-BYTE(5) = X"01"
         MOVE "yes" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PB-FREE" USING PB-BUFFER
     MOVE "N" TO TL-MODE
*>   Despawn immunity: far from every player a plain zombie villager is removed at once, a converting one stays.
     COMPUTE WS-X = PL-X(WS-PLAYER) + 300
     CALL "MOB-SPAWN" USING WS-DIM WS-ZTYPE WS-X WS-Y WS-Z0 WS-YAW WS-E
     MOVE WS-E TO WS-N
     CALL "MS6-DESPAWN-TICK" USING WS-N
     MOVE "acceptance US15 20§4.2 a zombie villager 300 blocks away despawns" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-N) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MOB-SPAWN" USING WS-DIM WS-ZTYPE WS-X WS-Y WS-Z0 WS-YAW WS-E
     MOVE WS-E TO WS-N
     MOVE 1 TO WS-I
     CALL "ZC-FIND" USING EN-ID(WS-N) WS-I WS-SLOT
     MOVE 100 TO ZC-TIME(WS-SLOT)
     CALL "MS6-DESPAWN-TICK" USING WS-N
     MOVE "acceptance US15 20§4.2 a converting zombie villager 300 blocks away stays" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-USED(WS-N) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Equipment drop at the cure: an iron helmet and chestplate and an iron sword.
     MOVE 52 TO EN-EQUIP(WS-N)
     MOVE 1 TO EN-HAND(WS-N)
     MOVE 0 TO WS-N0
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = CR-LOOSE-ITEM
             ADD 1 TO WS-N0
         END-IF
     END-PERFORM
     CALL "ZV-CONVERT" USING WS-N WS-PID
     MOVE 0 TO WS-C
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = CR-LOOSE-ITEM
             ADD 1 TO WS-C
         END-IF
     END-PERFORM
     COMPUTE WS-C = WS-C - WS-N0
     MOVE "acceptance US15 20§4.2 curing drops the three equipment items" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-C TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US15-ZV-KILL.
 COPY CORETEST.
 COPY MOBSPTEST.
