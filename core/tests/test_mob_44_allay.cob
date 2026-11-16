*> Implementation test (002-lane-mobsa4; 18 section 12 GoToWantedItem, 19 section 15, 44 part 4 section 14): the allay picks up items equal to the one in its hand (range 32, pickup cooldown), gives them
*> to the liked player (survival or creative, within 64, eye distance below 3.0, cooldown 60) or to a liked note block it heard (radius 16, cooldown 600).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-44-ALLAY.
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
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG VALUE 40.
 01 WS-SIZE                BINARY-LONG VALUE 48.
 01 WS-STONE               BINARY-LONG VALUE 1.
 01 WS-STATE               BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG VALUE 0.
 01 WS-VY                  FLOAT-LONG VALUE 0.
 01 WS-VZ                  FLOAT-LONG VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-GROUND              BINARY-LONG VALUE 0.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-EMERALD             BINARY-LONG.
 01 WS-STICK               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DELAY               BINARY-LONG VALUE 0.
 01 WS-HEARD               BINARY-LONG.
 01 WS-STICKROW            BINARY-LONG.
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
     COMPUTE WS-Y = WS-FLOOR + 2
     MOVE 6000 TO CW-TIME
     MOVE 2 TO BW-DIFFICULTY
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE "minecraft:allay" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:emerald" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-EMERALD WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:stick" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-STICK WS-ITEM-ROW WS-STATUS
     MOVE "N" TO TL-MODE

*>   Pickup: an emerald 6 blocks away is collected, a stick is not.
     COMPUTE WS-X = WS-PX - 6
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-A
     MOVE WS-EMERALD TO EN-ALLAY-ITEM(WS-A)
     MOVE PL-UUID(WS-PLAYER) TO EN-ALLAY-LIKED(WS-A)
     MOVE 0 TO PL-MODE(WS-PLAYER)
     COMPUTE PL-X(WS-PLAYER) = WS-PX + 70
     COMPUTE WS-X = WS-PX - 12
     CALL "GI-SPAWN" USING WS-DIM WS-X WS-Y WS-PZ WS-VX WS-VY WS-VZ WS-EMERALD 3 WS-DELAY WS-ROW
     COMPUTE WS-X = WS-PX - 11
     CALL "GI-SPAWN" USING WS-DIM WS-X WS-Y WS-PZ WS-VX WS-VY WS-VZ WS-STICK 2 WS-DELAY WS-STICKROW
     PERFORM 150 TIMES
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 19§15 Allay: it picks up an item equal to the one it holds (3 emeralds)" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE EN-ALLAY-COUNT(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§15 Allay: the picked up item entity is gone" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§15 Allay: an item of another kind is left alone" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-USED(WS-STICKROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-STICKROW

*>   Range 32: an emerald 40 blocks away is not wanted; a cooldown blocks the pickup.
     MOVE 0 TO EN-ALLAY-COUNT(WS-A)
     COMPUTE WS-X = EN-X(WS-A) + 40
     CALL "GI-SPAWN" USING WS-DIM WS-X WS-Y WS-PZ WS-VX WS-VY WS-VZ WS-EMERALD 1 WS-DELAY WS-ROW
     MOVE 0 TO EN-FLY-ON(WS-A)
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 19§15 Allay: an item farther than 32 blocks is not a goal" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 1 TO TL-OBSERVED-N
     IF EN-FLY-X(WS-A) > EN-X(WS-A) + 20
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ROW
     COMPUTE WS-X = EN-X(WS-A) + 0.2
     MOVE EN-Z(WS-A) TO WS-Z
     CALL "GI-SPAWN" USING WS-DIM WS-X EN-Y(WS-A) WS-Z WS-VX WS-VY WS-VZ WS-EMERALD 1 WS-DELAY WS-ROW
     MOVE 2 TO EN-ALLAY-CD(WS-A)
     PERFORM 1 TIMES
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 19§15 Allay: no pickup while the pickup cooldown runs (it counts down)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1 * 10 + 1
     COMPUTE TL-OBSERVED-N = EN-USED(WS-ROW) * 10 + EN-ALLAY-CD(WS-A)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM 1 TIMES
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 19§15 Allay: once the cooldown is over the item beside it is taken" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-ALLAY-COUNT(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-ALLAY-COUNT(WS-A)

*>   A full inventory takes what fits: 63 held, a stack of 3 beside it leaves 2.
     CALL "ENTITY-REMOVE" USING WS-ROW
     MOVE 63 TO EN-ALLAY-COUNT(WS-A)
     MOVE 0 TO EN-ALLAY-CD(WS-A)
     MOVE EN-Z(WS-A) TO WS-Z
     CALL "GI-SPAWN" USING WS-DIM EN-X(WS-A) EN-Y(WS-A) WS-Z WS-VX WS-VY WS-VZ WS-EMERALD 3 WS-DELAY WS-ROW
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 19§15 Allay: with room for one it takes 1 of a stack of 3 (64 held, 2 left)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 64 * 10 + 2
     COMPUTE TL-OBSERVED-N = EN-ALLAY-COUNT(WS-A) * 10 + EN-ITEM-COUNT(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ROW
     MOVE 0 TO EN-ALLAY-COUNT(WS-A)

*>   Delivery to the liked player: within 3 blocks of the eyes, survival, one stack thrown, cooldown 60.
     MOVE WS-PX TO PL-X(WS-PLAYER)
     MOVE 2 TO EN-ALLAY-COUNT(WS-A)
     MOVE WS-PX TO WS-X
     COMPUTE WS-X = WS-PX - 2
     CALL "ENTITY-MOVE" USING WS-A WS-X WS-Y WS-PZ WS-YAW WS-PITCH WS-GROUND
     MOVE 0 TO EN-ALLAY-CD(WS-A)
     MOVE 3 TO PL-MODE(WS-PLAYER)
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 19§15 Allay: a spectator is not a delivery target" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE EN-ALLAY-COUNT(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-MODE(WS-PLAYER)
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-A
     PERFORM COUNT-EMERALDS
     MOVE "acceptance US15 19§15 Allay: it gives the stack to the liked survival player (2 thrown, none held, cooldown 60)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 2 * 1000 + 0 * 100 + 60
     COMPUTE TL-OBSERVED-N = WS-N * 1000 + EN-ALLAY-COUNT(WS-A) * 100 + EN-ALLAY-CD(WS-A)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§15 Allay: the main hand copy and the liked player stay" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-ALLAY-ITEM(WS-A) = WS-EMERALD AND EN-ALLAY-LIKED(WS-A) = PL-UUID(WS-PLAYER)
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The thrown stack is not picked up again at once (the pickup cooldown 60) and a far player gets nothing.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-ITEM(WS-I) = WS-EMERALD AND EN-ITEM-COUNT(WS-I) > 0
             CALL "ENTITY-REMOVE" USING WS-I
         END-IF
     END-PERFORM
     MOVE 2 TO EN-ALLAY-COUNT(WS-A)
     MOVE 0 TO EN-ALLAY-CD(WS-A)
     COMPUTE PL-X(WS-PLAYER) = WS-PX + 66
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 19§15 Allay: a liked player 64 blocks away or farther gets no delivery" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE EN-ALLAY-COUNT(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-PX TO PL-X(WS-PLAYER)
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE 0 TO EN-ALLAY-CD(WS-A)
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 19§15 Allay: a creative player is a delivery target" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-ALLAY-COUNT(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-MODE(WS-PLAYER)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-ITEM(WS-I) = WS-EMERALD AND EN-ITEM-COUNT(WS-I) > 0
             CALL "ENTITY-REMOVE" USING WS-I
         END-IF
     END-PERFORM

*>   The liked note block: heard within 16 blocks, stored with the cooldown 600.
     COMPUTE WS-BX = FUNCTION INTEGER(WS-PX) + 8
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-PZ)
     COMPUTE WS-BY = WS-FLOOR + 2
     MOVE "minecraft:note_block" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 0 TO EN-ALLAY-NB-ON(WS-A)
     MOVE 0 TO EN-ALLAY-NB-CD(WS-A)
     CALL "ALLAY-NOTE-EVENT" USING WS-DIM WS-BX WS-BY WS-BZ WS-N
     MOVE "acceptance US15 44-4§14 Allay: a note block within 16 blocks is stored with the cooldown 600 (one allay heard it)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1 * 10000 + 1 * 1000 + 600
     COMPUTE TL-OBSERVED-N = WS-N * 10000 + EN-ALLAY-NB-ON(WS-A) * 1000 + EN-ALLAY-NB-CD(WS-A)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-4§14 Allay: the stored position is the block's" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-BX * 1000000 + WS-BY * 1000 + WS-BZ
     COMPUTE TL-OBSERVED-N = EN-ALLAY-NB-X(WS-A) * 1000000 + EN-ALLAY-NB-Y(WS-A) * 1000 + EN-ALLAY-NB-Z(WS-A)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Hearing the same block again resets only the cooldown; another block one is not received while the first is within 1024.
     MOVE 100 TO EN-ALLAY-NB-CD(WS-A)
     CALL "ALLAY-NOTE-EVENT" USING WS-DIM WS-BX WS-BY WS-BZ WS-N
     MOVE "acceptance US15 44-4§14 Allay: the same block again resets the cooldown to 600" TO TL-CASE
     MOVE 600 TO TL-EXPECTED-N
     MOVE EN-ALLAY-NB-CD(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-N = WS-BX + 1
     CALL "ALLAY-NOTE-EVENT" USING WS-DIM WS-N WS-BY WS-BZ WS-HEARD
     MOVE "acceptance US15 44-4§14 Allay: with a stored position within 1024 blocks it receives nothing else" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-HEARD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Out of the listener radius 16 nothing is heard.
     MOVE 0 TO EN-ALLAY-NB-ON(WS-A)
     COMPUTE WS-N = WS-BX + 20
     CALL "ALLAY-NOTE-EVENT" USING WS-DIM WS-N WS-BY WS-BZ WS-HEARD
     MOVE "acceptance US15 44-4§14 Allay: a note block 28 blocks away is out of the listener radius" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-ALLAY-NB-ON(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Delivery to the block: the player is far, the allay beside the block.
     CALL "ALLAY-NOTE-EVENT" USING WS-DIM WS-BX WS-BY WS-BZ WS-HEARD
     COMPUTE PL-X(WS-PLAYER) = WS-PX + 60
     MOVE 2 TO EN-ALLAY-COUNT(WS-A)
     MOVE 0 TO EN-ALLAY-CD(WS-A)
     COMPUTE WS-X = WS-BX - 1
     CALL "ENTITY-MOVE" USING WS-A WS-X WS-Y WS-PZ WS-YAW WS-PITCH WS-GROUND
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-A
     PERFORM COUNT-EMERALDS
     MOVE "acceptance US15 44-4§14 Allay: it gives the stack at the liked note block (2 thrown, cooldown 60)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 2 * 1000 + 0 * 100 + 60
     COMPUTE TL-OBSERVED-N = WS-N * 1000 + EN-ALLAY-COUNT(WS-A) * 100 + EN-ALLAY-CD(WS-A)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The cooldown counts down; the position is forgotten when it is over.
     MOVE 1 TO EN-ALLAY-NB-CD(WS-A)
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-A
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 44-4§14 Allay: after the note block cooldown the stored position is erased" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-ALLAY-NB-ON(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A stored position whose block is no longer a note block is erased too.
     CALL "ALLAY-NOTE-EVENT" USING WS-DIM WS-BX WS-BY WS-BZ WS-HEARD
     MOVE 0 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 44-4§14 Allay: a position without a note block is erased" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-ALLAY-NB-ON(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Taking the held item back by an empty hand returns the inventory items to the world too.
     MOVE 3 TO EN-ALLAY-COUNT(WS-A)
     MOVE WS-PX TO PL-X(WS-PLAYER)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, WS-I)
     END-PERFORM
     MOVE 0 TO PL-HELD(WS-PLAYER)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-ITEM(WS-I) = WS-EMERALD AND EN-ITEM-COUNT(WS-I) > 0
             CALL "ENTITY-REMOVE" USING WS-I
         END-IF
     END-PERFORM
     CALL "MOB-ALLAY-USE" USING WS-PLAYER WS-A
     PERFORM COUNT-EMERALDS
     MOVE "acceptance US15 19§15 Allay: the empty hand takes the held item back and the 3 inventory items are thrown out" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 3 * 10 + 0
     COMPUTE TL-OBSERVED-N = WS-N * 10 + EN-ALLAY-COUNT(WS-A)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 COUNT-EMERALDS.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-ITEM(WS-I) = WS-EMERALD AND EN-ITEM-COUNT(WS-I) > 0
             ADD EN-ITEM-COUNT(WS-I) TO WS-N
         END-IF
     END-PERFORM.
 END PROGRAM TEST-MOB-44-ALLAY.
 COPY CORETEST.
 COPY MOBSPTEST.
