*> Implementation test (coverage lane A; docs/protocol/20 section 11, 17 section 3.15; core/src/mob-20-potion.cob): the effect of every potion, the aim at a zero distance, harming and healing
*> splashes on a player, a duration splash on a player, a potion in flight that meets a player, a throw without a target, a throw at a target that already has every effect, and the
*> witch's ranged goal (timer, no target, out of range, throw).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVA-WITCH-POTION.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY EVKSTATE.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-WTYPE               BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N0                  BINARY-LONG.
 01 WS-N1                  BINARY-LONG.
 01 WS-POTION              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-AMP                 BINARY-LONG.
 01 WS-DUR                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ZERO2               FLOAT-LONG VALUE 0.
 01 WS-ZERO3               FLOAT-LONG VALUE 0.
 01 WS-ZERO4               FLOAT-LONG VALUE 0.
 01 WS-ZERO5               FLOAT-LONG VALUE 0.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-OWNER               BINARY-LONG VALUE 0.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 40.
 01 WS-KIND1               BINARY-LONG VALUE 1.
 01 WS-HP0                 FLOAT-SHORT.
 01 WS-DIGIT               PIC 9.
 01 WS-EXPECTED-IDS        PIC X(18) VALUE "006005009001018017".
 01 WS-EXPECTED-DURS       PIC X(24) VALUE "000000000900180009001800".
 01 WS-SLOW-ID             BINARY-LONG VALUE 1.
 01 WS-POISON-ID           BINARY-LONG VALUE 18.
 01 WS-WEAK-ID             BINARY-LONG VALUE 17.
 01 WS-FLAGS               BINARY-LONG VALUE 6.
 01 WS-LONG                BINARY-LONG VALUE 5000.
 01 WS-ID3                 PIC 999.
 01 WS-DUR4                PIC 9999.
 01 WS-ZERO-L              BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:witch" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-WTYPE WS-ENTITY-ROW WS-STATUS
*>   The effect of each potion (ids from the effect table, durations in ticks, 0 for the instant ones).
     PERFORM VARYING WS-POTION FROM 1 BY 1 UNTIL WS-POTION > 6
         CALL "POTION-EFFECT-OF" USING WS-POTION WS-ID WS-AMP WS-DUR
         MOVE SPACES TO WS-CASE
         MOVE WS-POTION TO WS-DIGIT
         STRING "test cova witch potion " WS-DIGIT " has its effect id and duration" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-ID TO WS-ID3
         MOVE WS-DUR TO WS-DUR4
         COMPUTE WS-E = FUNCTION NUMVAL(WS-EXPECTED-IDS((WS-POTION - 1) * 3 + 1:3)) * 10000
             + FUNCTION NUMVAL(WS-EXPECTED-DURS((WS-POTION - 1) * 4 + 1:4))
         COMPUTE WS-O = WS-ID * 10000 + WS-DUR
         CALL "CA-N" USING WS-CASE WS-E WS-O
     END-PERFORM
*>   Aiming at nothing gives no velocity.
     CALL "POTION-AIM" USING WS-ZERO WS-ZERO2 WS-ZERO3 WS-ZERO4 WS-ZERO5 WS-VX WS-VY WS-VZ
     MOVE "test cova witch potion an aim of length zero is the zero velocity" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O ROUNDED = (FUNCTION ABS(WS-VX) + FUNCTION ABS(WS-VY) + FUNCTION ABS(WS-VZ)) * 1000
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   A floor under the player and a witch 6 blocks east of it.
     MOVE PL-X(WS-PLAYER) TO WS-X0
     MOVE PL-Z(WS-PLAYER) TO WS-Z0
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X0) - 20
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y) - 1
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z0) - 20
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-BX WS-BZ WS-SIZE WS-BY WS-KIND1
     COMPUTE WS-X = WS-X0 + 6
     CALL "MOB-SPAWN" USING WS-DIM WS-WTYPE WS-X WS-Y WS-Z0 WS-YAW WS-W
*>   A harming splash right at the player (intensity 1) hurts by 6 and credits the witch; a healing splash heals by 4.
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 1 TO WS-POTION
     COMPUTE WS-Y = PL-Y(WS-PLAYER) + 0.5
     CALL "WITCH-POTION-SPLASH" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-POTION EN-ID(WS-W)
     MOVE "test cova witch potion a harming splash on the player lowers the health" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF PL-HEALTH(WS-PLAYER) < 20
         MOVE 1 TO WS-O
     END-IF
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE "test cova witch potion the harmed player has a credited killer name" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF PL-CREDIT-LENGTH(WS-PLAYER) > 0
         MOVE 1 TO WS-O
     END-IF
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE 10 TO PL-HEALTH(WS-PLAYER)
     MOVE 2 TO WS-POTION
     CALL "WITCH-POTION-SPLASH" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-POTION WS-OWNER
     MOVE "test cova witch potion a healing splash heals the player by 4" TO WS-CASE
     MOVE 14 TO WS-E
     MOVE PL-HEALTH(WS-PLAYER) TO WS-HP0
     COMPUTE WS-O = FUNCTION INTEGER(WS-HP0)
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE 4 TO WS-POTION
     CALL "WITCH-POTION-SPLASH" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-POTION WS-OWNER
     CALL "EFFECT-LEVEL" USING WS-PLAYER WS-SLOW-ID WS-LEVEL WS-LEFT
     MOVE "test cova witch potion a slowness splash at intensity 1 gives 1800 ticks" TO WS-CASE
     MOVE 1800 TO WS-E
     MOVE WS-LEFT TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     CALL "EFFECT-REMOVE" USING WS-PLAYER WS-SLOW-ID
*>   A potion in flight that is launched inside the player shatters on the entity check of the tick.
     MOVE 0 TO WS-N0
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PZ-MAX
         ADD PZ-USED(WS-I) TO WS-N0
     END-PERFORM
     MOVE 5 TO WS-POTION
     CALL "POTION-LAUNCH" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-ZERO WS-ZERO2 WS-ZERO3 WS-POTION WS-OWNER
     CALL "POTIONS-TICK"
     MOVE 0 TO WS-N1
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PZ-MAX
         ADD PZ-USED(WS-I) TO WS-N1
     END-PERFORM
     MOVE "test cova witch potion a potion that meets the player shatters in its first tick" TO WS-CASE
     MOVE WS-N0 TO WS-E
     MOVE WS-N1 TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     CALL "EFFECT-LEVEL" USING WS-PLAYER WS-POISON-ID WS-LEVEL WS-LEFT
     MOVE "test cova witch potion the player met by the potion is poisoned" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-LEVEL TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     CALL "EFFECT-REMOVE" USING WS-PLAYER WS-POISON-ID
*>   A witch without a target throws nothing and keeps its timer.
     MOVE 0 TO EN-TARGET(WS-W)
     MOVE 0 TO EN-SHOOT-TIME(WS-W)
     CALL "WITCH-THROW" USING WS-W
     MOVE "test cova witch potion a throw without a target leaves the timer at 0" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-SHOOT-TIME(WS-W) TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   A target that is slowed, poisoned and weakened gets the default Harming potion.
     CALL "EFFECT-ADD" USING WS-PLAYER WS-SLOW-ID WS-ZERO-L WS-LONG WS-FLAGS
     CALL "EFFECT-ADD" USING WS-PLAYER WS-POISON-ID WS-ZERO-L WS-LONG WS-FLAGS
     CALL "EFFECT-ADD" USING WS-PLAYER WS-WEAK-ID WS-ZERO-L WS-LONG WS-FLAGS
     MOVE WS-PLAYER TO EN-TARGET(WS-W)
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PZ-MAX
         MOVE 0 TO PZ-USED(WS-I)
     END-PERFORM
     CALL "WITCH-THROW" USING WS-W
     MOVE "test cova witch potion a throw at a slowed, poisoned and weakened target is Harming" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PZ-MAX
         IF PZ-USED(WS-I) = 1
             MOVE PZ-KIND(WS-I) TO WS-O
         END-IF
     END-PERFORM
     CALL "CA-N" USING WS-CASE WS-E WS-O
     CALL "EFFECT-REMOVE" USING WS-PLAYER WS-SLOW-ID
     CALL "EFFECT-REMOVE" USING WS-PLAYER WS-POISON-ID
     CALL "EFFECT-REMOVE" USING WS-PLAYER WS-WEAK-ID
*>   The ranged goal: the timer counts down, then nothing without a target, nothing beyond 10 blocks, a throw within sight.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PZ-MAX
         MOVE 0 TO PZ-USED(WS-I)
     END-PERFORM
     MOVE 5 TO EN-SHOOT-TIME(WS-W)
     CALL "WITCH-THROW-STEP" USING WS-W
     MOVE "test cova witch potion the ranged goal counts the timer down and does not throw" TO WS-CASE
     MOVE 4 TO WS-E
     MOVE EN-SHOOT-TIME(WS-W) TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE 0 TO EN-SHOOT-TIME(WS-W)
     MOVE 0 TO EN-TARGET(WS-W)
     CALL "WITCH-THROW-STEP" USING WS-W
     MOVE "test cova witch potion the ranged goal without a target throws nothing" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-SHOOT-TIME(WS-W) TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE WS-PLAYER TO EN-TARGET(WS-W)
     COMPUTE EN-X(WS-W) = WS-X0 + 15
     CALL "WITCH-THROW-STEP" USING WS-W
     MOVE "test cova witch potion the ranged goal beyond 10 blocks throws nothing" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-SHOOT-TIME(WS-W) TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     COMPUTE EN-X(WS-W) = WS-X0 + 6
     MOVE WS-Z0 TO EN-Z(WS-W)
     MOVE PL-Y(WS-PLAYER) TO EN-Y(WS-W)
     CALL "WITCH-THROW-STEP" USING WS-W
     MOVE "test cova witch potion the ranged goal throws at a target in sight (timer 60)" TO WS-CASE
     MOVE 60 TO WS-E
     MOVE EN-SHOOT-TIME(WS-W) TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-COVA-WITCH-POTION.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY COVATEST.
