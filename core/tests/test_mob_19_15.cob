*> Implementation test (002-lane-mobsfull-h21; docs/protocol/19-mobs-land-friendly-and-neutral.md section 15): the allay. Right click with an item and an empty allay: it takes a copy of one (the stack of a
*> survival player shrinks) and likes the player; right click with an empty hand on an allay that holds an item: the item goes back to the player and the liked player is forgotten; an item in both hands
*> does nothing. An amethyst shard on a dancing allay that can duplicate makes a second allay, both get a duplication cooldown of 6000 ticks (the shard is used up); the cooldown counts down by 1 a tick
*> and canDuplicate (metadata 17) is true at 0. It heals 1 HP every 10 ticks. The liked player cannot hurt it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-19-15.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 COPY RULES.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG VALUE 40.
 01 WS-SIZE                BINARY-LONG VALUE 48.
 01 WS-STONE               BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-EMERALD             BINARY-LONG.
 01 WS-STICK               BINARY-LONG.
 01 WS-SHARD               BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-WOOL                BINARY-LONG.
 01 WS-NEEDED              BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-HAND                BINARY-LONG VALUE 0.
 01 WS-BEFORE              BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 24
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 24
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FLOOR WS-STONE
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 24.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-Z0 + 24.5
     MOVE PL-X(WS-PLAYER) TO WS-PX
     MOVE PL-Z(WS-PLAYER) TO WS-PZ
     COMPUTE WS-Y = WS-FLOOR + 1
     MOVE 6000 TO CW-TIME
     MOVE 2 TO BW-DIFFICULTY
     MOVE "minecraft:allay" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:emerald" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-EMERALD WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:stick" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-STICK WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:amethyst_shard" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-SHARD WS-ITEM-ROW WS-STATUS
     MOVE "N" TO TL-MODE
     MOVE 0 TO PL-HELD(WS-PLAYER) PL-MODE(WS-PLAYER)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, WS-I)
     END-PERFORM
     COMPUTE WS-X = WS-PX + 1
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-A

*>   Giving: a copy of one is taken and the player is liked.
     MOVE WS-EMERALD TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 3 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     CALL "MOB-ALLAY-USE" USING WS-PLAYER WS-A
     MOVE "acceptance US15 19§15 Allay: it takes one item of the stack (the stack shrinks to 2)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-EMERALD * 10 + 2
     COMPUTE TL-OBSERVED-N = EN-ALLAY-ITEM(WS-A) * 10 + PL-SLOT-COUNT(WS-PLAYER, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§15 Allay: the giver is the liked player" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-ALLAY-LIKED(WS-A) = PL-UUID(WS-PLAYER)
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   An item in both hands does nothing.
     MOVE WS-STICK TO PL-SLOT-ITEM(WS-PLAYER, 1)
     CALL "MOB-ALLAY-USE" USING WS-PLAYER WS-A
     MOVE "acceptance US15 19§15 Allay: an item in both hands does nothing" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-EMERALD * 10 + 2
     COMPUTE TL-OBSERVED-N = EN-ALLAY-ITEM(WS-A) * 10 + PL-SLOT-COUNT(WS-PLAYER, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The empty hand takes the item back.
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     CALL "MOB-ALLAY-USE" USING WS-PLAYER WS-A
     PERFORM COUNT-EMERALDS
     MOVE "acceptance US15 19§15 Allay: the empty hand gets the item back and the allay forgets the player" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-N = 1 AND EN-ALLAY-ITEM(WS-A) = 0 AND EN-ALLAY-LIKED(WS-A) = SPACES
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   An empty hand on an empty allay does nothing.
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     CALL "MOB-ALLAY-USE" USING WS-PLAYER WS-A
     MOVE "acceptance US15 19§15 Allay: an empty hand on an empty allay does nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-ALLAY-ITEM(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A creative player keeps the stack.
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE WS-EMERALD TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 3 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     CALL "MOB-ALLAY-USE" USING WS-PLAYER WS-A
     MOVE "acceptance US15 19§15 Allay: a creative player's stack keeps its size" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 0 TO EN-ALLAY-ITEM(WS-A)
     MOVE SPACES TO EN-ALLAY-LIKED(WS-A)

*>   Duplication: an amethyst shard on a dancing allay that can duplicate.
     MOVE WS-SHARD TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 2 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     CALL "MOB-ALLAY-USE" USING WS-PLAYER WS-A
     MOVE "acceptance US15 19§15 Allay: a shard on an allay that does not dance is taken as an item to hold" TO TL-CASE
     MOVE WS-SHARD TO TL-EXPECTED-N
     MOVE EN-ALLAY-ITEM(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-ALLAY-ITEM(WS-A)
     MOVE 2 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 1 TO EN-ALLAY-DANCE(WS-A)
     PERFORM COUNT-ALLAYS
     MOVE WS-N TO WS-BEFORE
     CALL "MOB-ALLAY-USE" USING WS-PLAYER WS-A
     PERFORM COUNT-ALLAYS
     MOVE "acceptance US15 19§15 Allay: a second allay appears, the shard is used up" TO TL-CASE
     COMPUTE TL-EXPECTED-N = (WS-BEFORE + 1) * 10 + 1
     COMPUTE TL-OBSERVED-N = WS-N * 10 + PL-SLOT-COUNT(WS-PLAYER, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-B
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-TYPE AND WS-I NOT = WS-A
             MOVE WS-I TO WS-B
         END-IF
     END-PERFORM
     MOVE "acceptance US15 19§15 Allay: both have a duplication cooldown of 6000 ticks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-B > 0
         IF EN-ALLAY-DUP(WS-A) = 6000 AND EN-ALLAY-DUP(WS-B) = 6000
             MOVE 1 TO TL-OBSERVED-N
         END-IF
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MOB-DATA-VALUES" USING WS-A WS-BABY WS-WOOL WS-NEEDED
     CALL "MOB-DATA-SEND" USING WS-A
     MOVE "acceptance US15 19§15 Allay: dancing and the cooldown are entity data (16, 17)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-NEEDED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   While the cooldown runs a second shard is not used for it.
     MOVE 0 TO EN-ALLAY-ITEM(WS-A)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     CALL "MOB-ALLAY-USE" USING WS-PLAYER WS-A
     PERFORM COUNT-ALLAYS
     MOVE "acceptance US15 19§15 Allay: no duplication while the cooldown runs" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-B

*>   Cooldown and healing run in the step.
     MOVE 0 TO EN-ALLAY-ITEM(WS-A)
     MOVE 5 TO EN-HEALTH(WS-A)
     MOVE 3 TO EN-ALLAY-DUP(WS-A)
     MOVE 0 TO EN-ALLAY-T(WS-A)
     PERFORM 9 TIMES
         CALL "MOB-STEP" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 19§15 Allay: nothing is healed before 10 ticks" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 19§15 Allay: it heals 1 HP every 10 ticks" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§15 Allay: the duplication cooldown counts down and stops at 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-ALLAY-DUP(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 20 TO EN-HEALTH(WS-A)
     PERFORM 10 TIMES
         CALL "MOB-STEP" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 19§15 Allay: a healthy allay is not healed beyond 20" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The liked player cannot hurt it; others can.
     MOVE PL-UUID(WS-PLAYER) TO EN-ALLAY-LIKED(WS-A)
     MOVE 1 TO WS-AMOUNT
     MOVE CAUSE-PLAYER TO WS-CAUSE
     MOVE 0 TO EN-HURT(WS-A)
     CALL "HEALTH-MOB-DAMAGE" USING WS-A WS-AMOUNT WS-CAUSE WS-PLAYER
     MOVE "acceptance US15 19§15 Allay: the liked player cannot hurt it" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO EN-ALLAY-LIKED(WS-A)
     CALL "HEALTH-MOB-DAMAGE" USING WS-A WS-AMOUNT WS-CAUSE WS-PLAYER
     MOVE "acceptance US15 19§15 Allay: another player can" TO TL-CASE
     MOVE 19 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A right click through the packet.
     MOVE WS-EMERALD TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     CALL "TEST-INTERACT" USING PL-CONN(WS-PLAYER) EN-ID(WS-A) WS-HAND WS-HAND
     MOVE "acceptance US15 minecraft:allay a right click with an item gives it to the allay" TO TL-CASE
     MOVE WS-EMERALD TO TL-EXPECTED-N
     MOVE EN-ALLAY-ITEM(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 COUNT-EMERALDS.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 36
         IF PL-SLOT-COUNT(WS-PLAYER, WS-J) > 0 AND PL-SLOT-ITEM(WS-PLAYER, WS-J) = WS-EMERALD
             ADD PL-SLOT-COUNT(WS-PLAYER, WS-J) TO WS-N
         END-IF
     END-PERFORM.

 COUNT-ALLAYS.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > EN-COUNT
         IF EN-USED(WS-J) = 1 AND EN-TYPE(WS-J) = WS-TYPE
             ADD 1 TO WS-N
         END-IF
     END-PERFORM.
 END PROGRAM TEST-MOB-19-15.
 COPY CORETEST.
 COPY MOBSPTEST.
