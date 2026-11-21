*> A piglin or brute hit by a player (docs/protocol/44-residual-mob-questions-6-nether.md sections 2.3 step 5, 2.4 steps 2 to 5, 2.5 broadcastUniversalAnger; lane 002-lane-p49l):
*> the retaliation distance rule against players, the end of a retreat, universal_anger (the nearest attackable player, told to every adult piglin near).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-6-2P.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY PGBRAIN.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-K24                 PIC X(24).
 01 WS-NAME                PIC X(16) VALUE "Bob".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 3.
 01 WS-CONN2               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-RNAME               PIC X(40) VALUE "universal_anger".
 01 WS-RINDEX              BINARY-LONG.
 01 WS-RVALUE              BINARY-DOUBLE.
 01 WS-AVOIDING            BINARY-LONG.
 01 WS-HANDLED             BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-X0
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z0
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X0) - 20
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y) - 1
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z0) - 20
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-BX WS-BZ 40 WS-BY 1
     MOVE 1000 TO CW-TICKS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN2
     MOVE CN-PLAYER(WS-CONN2) TO WS-BOB
     MOVE 0 TO PL-MODE(WS-BOB)
*>   Section 2.4 step 3: the attacker Bob at 10 blocks against the current target Alice at 6: the target stays; at 7 the piglin retaliates against Bob.
     CALL "T-CLEAR"
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 6
     MOVE WS-Y TO PL-Y(WS-PLAYER)
     MOVE WS-Z0 TO PL-Z(WS-PLAYER)
     COMPUTE PL-X(WS-BOB) = WS-X0 - 10
     MOVE WS-Y TO PL-Y(WS-BOB)
     MOVE WS-Z0 TO PL-Z(WS-BOB)
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     MOVE WS-PLAYER TO EN-TARGET(WS-A)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-A)
     CALL "NETHER-HURT" USING WS-A WS-BOB
     MOVE "acceptance US15 44-6§2.4 attacker at 10 vs target at 6: the target stays" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE PL-X(WS-BOB) = WS-X0 - 7
     CALL "NETHER-HURT" USING WS-A WS-BOB
     MOVE "acceptance US15 44-6§2.4 attacker at 7 vs target at 6: retaliates" TO TL-CASE
     MOVE WS-BOB TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Section 2.3 step 5 and 2.4: a retreat ends with a hit of another kind (a player), which is then retaliated against; the brute retaliates too.
     CALL "T-CLEAR"
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     COMPUTE WS-X = WS-X0 + 3
     MOVE "hoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-B
     CALL "PGAI-RETREAT" USING WS-A WS-B
     CALL "NETHER-HURT" USING WS-A WS-PLAYER
     CALL "PGB-AVOIDING" USING WS-A WS-AVOIDING
     MOVE "acceptance US15 44-6§2.3 step 5 a hit by a player ends the retreat from a hoglin" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE WS-AVOIDING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-6§2.4 and the player is the target" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-X = WS-X0 - 3
     MOVE "piglin_brute" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-C
     CALL "NETHER-HURT" USING WS-C WS-PLAYER
     MOVE "acceptance US15 44-6§2.7 a brute hit by a player retaliates" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-C) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Section 2.4 step 4 and 2.5: universal_anger takes the nearest attackable player and tells every adult piglin near, each its own nearest player.
     CALL "T-CLEAR"
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 10
     COMPUTE PL-X(WS-BOB) = WS-X0 + 2
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     COMPUTE WS-X = WS-X0 + 8
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-B
     COMPUTE WS-X = WS-X0 + 9
     MOVE "piglin_brute" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-C
     CALL "BR-RULE-FIND" USING WS-RNAME WS-RINDEX
     MOVE 1 TO WS-RVALUE
     CALL "BR-RULE-SET" USING WS-RINDEX WS-RVALUE
     CALL "NETHER-HURT" USING WS-A WS-PLAYER
     MOVE "acceptance US15 44-6§2.4 step 4 universal_anger: the hit piglin takes the nearest player" TO TL-CASE
     MOVE WS-BOB TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-6§2.5 broadcastUniversalAnger: the piglin near the attacker takes its nearest player" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-B) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-6§2.5 the brute near the attacker too" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-C) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-RVALUE
     CALL "BR-RULE-SET" USING WS-RINDEX WS-RVALUE
     MOVE 0 TO EN-TARGET(WS-A) EN-TARGET-ID(WS-A) EN-TARGET(WS-B) EN-TARGET-ID(WS-B)
     CALL "NETHER-HURT" USING WS-A WS-PLAYER
     MOVE "acceptance US15 44-6§2.4 step 5 without the rule: the attacker is the target" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   PGAI-HURT-BY-PLAYER only acts for a piglin or a brute; a piglin with a mob foe ignores a player attacker that is much further than the foe.
     CALL "T-CLEAR"
     MOVE "hoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     CALL "PGAI-HURT-BY-PLAYER" USING WS-A WS-PLAYER WS-HANDLED
     MOVE "acceptance US15 44-6§2.4 PGAI-HURT-BY-PLAYER leaves a hoglin to its own rules" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE WS-HANDLED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-B
     COMPUTE WS-X = WS-X0 + 6
     MOVE "hoglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-C
     MOVE WS-C TO EN-FOE(WS-B)
     MOVE EN-ID(WS-C) TO EN-FOE-ID(WS-B)
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 10
     CALL "PGAI-HURT-BY-PLAYER" USING WS-B WS-PLAYER WS-HANDLED
     MOVE "acceptance US15 44-6§2.4 a player at 10 vs a foe at 6: ignored" TO TL-CASE
     MOVE WS-ONE TO TL-EXPECTED-N
     MOVE WS-HANDLED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-Q44-44-6-2P.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. T-CLEAR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0
             CALL "ENTITY-REMOVE" USING WS-I
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM T-CLEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. T-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-KEY                  PIC X(24).
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-KEY L-X L-Y L-Z L-ROW.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE L-KEY DELIMITED BY SPACE INTO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING L-DIM WS-TYPE L-X L-Y L-Z WS-YAW L-ROW
     GOBACK.
 END PROGRAM T-SPAWN.

 COPY CORETEST.
 COPY MOBSPTEST.
