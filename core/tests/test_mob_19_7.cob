*> Implementation test (002-lane-mobsfull-h21; docs/protocol/19-mobs-land-friendly-and-neutral.md section 7, 44-residual-mob-questions-4-land-animals.md section 4): the fox. The held item of a new adult
*> (chance 0.2, then r: < 0.05 emerald, < 0.2 egg, < 0.4 rabbit hide or foot, < 0.6 wheat, < 0.8 leather, else feather); the baby that two foxes breed has an empty hand and trusts the players that fed them;
*> the held item is dropped when it dies; an untrusted non-sneaking player in survival within 16 blocks makes it flee (speed 1.6, 1.4 within 7 blocks), a trusted, sneaking or creative player does not;
*> metadata 18 (type), 20 and 21 (trusted players).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-19-7.
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
 01 WS-C                   BINARY-LONG.
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
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-WALK                BINARY-LONG.
 01 WS-R1                  BINARY-LONG.
 01 WS-R2                  BINARY-LONG.
 01 WS-BOOL                BINARY-LONG.
 01 WS-HELD                PIC X(24).
 01 WS-TEXT                PIC X(160).
 01 WS-POS                 BINARY-LONG.
 01 WS-EMERALD             BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-WOOL                BINARY-LONG.
 01 WS-NEEDED              BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-TRUSTS              BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
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
     MOVE "minecraft:fox" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:emerald" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-EMERALD WS-ITEM-ROW WS-STATUS
     MOVE "N" TO TL-MODE
     MOVE 0 TO PL-SPRINTING(WS-PLAYER) PL-SNEAKING(WS-PLAYER)

*>   The held item of a new adult: draws 0 to 9999 stand for nextFloat.
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-POS
     MOVE 2000 TO WS-R1
     MOVE 0 TO WS-R2 WS-BOOL
     CALL "FOX-HELD-ITEM" USING WS-R1 WS-R2 WS-BOOL WS-HELD
     MOVE "acceptance US15 19§7 Fox: no item when the first roll is 0.2 or more" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-HELD TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1999 TO WS-R1
     MOVE 499 TO WS-R2
     CALL "FOX-HELD-ITEM" USING WS-R1 WS-R2 WS-BOOL WS-HELD
     STRING WS-HELD DELIMITED BY SPACE "|" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     MOVE 500 TO WS-R2
     CALL "FOX-HELD-ITEM" USING WS-R1 WS-R2 WS-BOOL WS-HELD
     STRING WS-HELD DELIMITED BY SPACE "|" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     MOVE 1999 TO WS-R2
     CALL "FOX-HELD-ITEM" USING WS-R1 WS-R2 WS-BOOL WS-HELD
     STRING WS-HELD DELIMITED BY SPACE "|" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     MOVE 2000 TO WS-R2
     MOVE 1 TO WS-BOOL
     CALL "FOX-HELD-ITEM" USING WS-R1 WS-R2 WS-BOOL WS-HELD
     STRING WS-HELD DELIMITED BY SPACE "|" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     MOVE 3999 TO WS-R2
     MOVE 0 TO WS-BOOL
     CALL "FOX-HELD-ITEM" USING WS-R1 WS-R2 WS-BOOL WS-HELD
     STRING WS-HELD DELIMITED BY SPACE "|" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     MOVE 4000 TO WS-R2
     CALL "FOX-HELD-ITEM" USING WS-R1 WS-R2 WS-BOOL WS-HELD
     STRING WS-HELD DELIMITED BY SPACE "|" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     MOVE 6000 TO WS-R2
     CALL "FOX-HELD-ITEM" USING WS-R1 WS-R2 WS-BOOL WS-HELD
     STRING WS-HELD DELIMITED BY SPACE "|" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     MOVE 8000 TO WS-R2
     CALL "FOX-HELD-ITEM" USING WS-R1 WS-R2 WS-BOOL WS-HELD
     STRING WS-HELD DELIMITED BY SPACE INTO WS-TEXT WITH POINTER WS-POS
     MOVE "acceptance US15 19§7 Fox: the held item table emerald, egg, rabbit hide or foot, wheat, leather, feather" TO TL-CASE
     MOVE "emerald|egg|egg|rabbit_hide|rabbit_foot|wheat|leather|feather" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
*>   A new fox holds an item about one time in five.
     MOVE 0 TO WS-N
     PERFORM 40 TIMES
         COMPUTE WS-X = WS-PX + 5
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-A
         IF EN-FOX-HELD(WS-A) > 0
             ADD 1 TO WS-N
         END-IF
         CALL "ENTITY-REMOVE" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 minecraft:fox of 40 new foxes about one in five holds an item (1 to 20)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-N >= 1 AND WS-N <= 20
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Breeding: the baby trusts the players that fed its parents and holds nothing.
     COMPUTE WS-X = WS-PX + 5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-A
     COMPUTE WS-X = WS-PX + 6
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-B
     CALL "MOB-DATA-VALUES" USING WS-A WS-BABY WS-WOOL WS-NEEDED
     MOVE "acceptance US15 19§7 Fox: a new red fox that trusts nobody sends no extra entity data" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-NEEDED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-EMERALD TO EN-FOX-HELD(WS-A) EN-FOX-HELD(WS-B)
     MOVE WS-PLAYER TO EN-LOVE-CAUSE(WS-A) EN-LOVE-CAUSE(WS-B)
     CALL "MOB-BREED" USING WS-A WS-B
     MOVE 0 TO WS-C
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-TYPE AND WS-I NOT = WS-A AND WS-I NOT = WS-B
             MOVE WS-I TO WS-C
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-4§4 the baby of two foxes trusts the player that fed them and has an empty hand" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-C > 0
         IF EN-FOX-TRUST-A(WS-C) = PL-UUID(WS-PLAYER) AND EN-FOX-HELD(WS-C) = 0
             MOVE 1 TO TL-OBSERVED-N
         END-IF
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FOX-TRUSTS" USING WS-C WS-PLAYER WS-TRUSTS
     MOVE "acceptance US15 44-4§4 trusts(player) is membership in the trusted list" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-TRUSTS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FOX-TRUSTS" USING WS-A WS-PLAYER WS-TRUSTS
     MOVE "acceptance US15 44-4§4 a fox that was not bred does not trust" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-TRUSTS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MOB-DATA-VALUES" USING WS-C WS-BABY WS-WOOL WS-NEEDED
     CALL "MOB-DATA-SEND" USING WS-C
     MOVE "acceptance US15 19§7 Fox: the trusted players are entity data (20, 21)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-NEEDED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-WOOL(WS-A)
     MOVE 1 TO EN-WOOL(WS-B)
     MOVE 1 TO WS-I
     CALL "FOX-BRED" USING WS-A WS-B WS-C WS-I
     MOVE EN-WOOL(WS-C) TO WS-N
     MOVE 0 TO WS-I
     CALL "FOX-BRED" USING WS-A WS-B WS-C WS-I
     MOVE "acceptance US15 19§7 Fox: the baby takes the type of the parent that the coin names" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-N * 10 + EN-WOOL(WS-C)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-C
     MOVE 1 TO EN-WOOL(WS-B)
     CALL "MOB-DATA-VALUES" USING WS-B WS-BABY WS-WOOL WS-NEEDED
     CALL "MOB-DATA-SEND" USING WS-B
     MOVE "acceptance US15 19§7 Fox: the snow type is entity data (18)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-NEEDED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-B

*>   The held item is dropped on death.
     MOVE 0 TO EN-HURT(WS-A)
     MOVE 100 TO WS-AMOUNT
     MOVE CAUSE-PLAYER TO WS-CAUSE
     CALL "HEALTH-MOB-DAMAGE" USING WS-A WS-AMOUNT WS-CAUSE WS-PLAYER
     MOVE 0 TO WS-N
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > EN-COUNT
         IF EN-USED(WS-J) = 1 AND EN-ITEM(WS-J) = WS-EMERALD AND EN-ITEM-COUNT(WS-J) > 0
             ADD EN-ITEM-COUNT(WS-J) TO WS-N
         END-IF
     END-PERFORM
     MOVE "acceptance US15 19§7 Fox: the held item is dropped when it dies" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-A

*>   Avoiding players: the fox is 10 blocks east of the player.
     COMPUTE WS-X = WS-PX + 10
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-A
     CALL "FOX-TICK" USING WS-A WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44-4§4 an untrusted player 10 blocks away: the fox flees east at 0.5 a tick (1.6)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-WALK = 1 AND WS-HX > 0.49 AND WS-HX < 0.52 AND WS-HZ > -0.001 AND WS-HZ < 0.001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE EN-X(WS-A) = WS-PX + 5
     CALL "FOX-TICK" USING WS-A WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44-4§4 within 7 blocks the speed is 1.4 (0.39 a tick)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-WALK = 1 AND WS-HX > 0.38 AND WS-HX < 0.40
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE EN-X(WS-A) = WS-PX + 17
     CALL "FOX-TICK" USING WS-A WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44-4§4 a player 17 blocks away is not avoided" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE EN-X(WS-A) = WS-PX + 10
     MOVE 1 TO PL-SNEAKING(WS-PLAYER)
     CALL "FOX-TICK" USING WS-A WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44-4§4 a sneaking player is not avoided" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-SNEAKING(WS-PLAYER)
     MOVE 1 TO PL-MODE(WS-PLAYER)
     CALL "FOX-TICK" USING WS-A WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44-4§4 a creative player is not avoided" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE PL-UUID(WS-PLAYER) TO EN-FOX-TRUST-B(WS-A)
     CALL "FOX-TICK" USING WS-A WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44-4§4 a trusted player is not avoided" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Through the step: the untrusted fox moves away from the player.
     MOVE SPACES TO EN-FOX-TRUST-B(WS-A)
     COMPUTE EN-X(WS-A) = WS-PX + 10
     PERFORM 4 TIMES
         CALL "MOB-STEP" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 minecraft:fox in the step the fox runs away from an untrusted player" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-X(WS-A) > WS-PX + 11.5
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-19-7.
 COPY CORETEST.
 COPY MOBSPTEST.
