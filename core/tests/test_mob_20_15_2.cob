*> Acceptance test (002-lane-p49b; docs/protocol/20 section 15): the warden's anger manager, targeting, melee and sonic boom. Anger: values per player capped at 150, levels
*> CALM below 40, AGITATED 40 to 79, ANGRY 80 and above; a sensed player (increaseAngerAt) also sets the dig cooldown 1200; every 20 ticks each value falls by 1 and a value of 1 or
*> less is dropped. A warden has no target until someone is angry (it takes the angry player with the highest value, in survival). Hurt by a player: anger +100, and with no target
*> and the attacker within 5 blocks the attacker is the target and the sonic boom cooldown 200. Melee: cooldown 18 ticks, the hit sets the sonic boom cooldown to 40. Sonic boom: with a
*> target within 15 blocks horizontally and the cooldown absent, 60 ticks, entity event 62 at the start, the boom on its 34th tick hurts the target for 10 and pushes it away
*> (Set Entity Motion), then the cooldown is 40.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-15-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY STDMOBS.
 COPY WARDENSTATE.
 COPY RULES.
 COPY BRWORLD.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-WARDEN              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 24.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-W                   BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG VALUE 1.
 01 WS-CAUSE               BINARY-LONG VALUE CAUSE-PLAYER.
 01 WS-HEALTH              FLOAT-SHORT.
 01 WS-HITS                BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-SECOND              BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-FIRE                BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-CD-AT-END           BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-HAS-MOTION          BINARY-LONG.
 01 WS-HAS-EVENT           BINARY-LONG.
 01 WS-TALLY               BINARY-LONG.
 01 WS-WARDEN2             BINARY-LONG.
 01 WS-NO-ATTACKER         BINARY-LONG VALUE 0.
 01 WS-STOP                BINARY-LONG.
 01 WS-PADDED              PIC X(1030).
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE "minecraft:warden" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-FX = FUNCTION INTEGER(WS-X) - 12
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) - 12
     COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     COMPUTE WS-X0 = WS-X + 8
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-WARDEN
     CALL "WD-FIND" USING EN-ID(WS-WARDEN) WS-ONE WS-W
     MOVE 500 TO WD-SONIC-CD(WS-W)
     MOVE 12001 TO CW-TIME

*>   Levels and the cap.
     MOVE 35 TO WS-AMOUNT
     CALL "WARDEN-ANGER-ADD" USING WS-WARDEN WS-PLAYER WS-AMOUNT WS-ZERO
     CALL "WARDEN-LEVEL" USING WS-WARDEN WS-LEVEL
     MOVE "acceptance US15 20§15 Warden anger 35 is CALM" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LEVEL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-AMOUNT
     CALL "WARDEN-ANGER-ADD" USING WS-WARDEN WS-PLAYER WS-AMOUNT WS-ZERO
     CALL "WARDEN-LEVEL" USING WS-WARDEN WS-LEVEL
     MOVE "acceptance US15 20§15 Warden anger 40 is AGITATED" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-LEVEL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 40 TO WS-AMOUNT
     CALL "WARDEN-ANGER-ADD" USING WS-WARDEN WS-PLAYER WS-AMOUNT WS-ZERO
     CALL "WARDEN-LEVEL" USING WS-WARDEN WS-LEVEL
     MOVE "acceptance US15 20§15 Warden anger 80 is ANGRY" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-LEVEL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 200 TO WS-AMOUNT
     CALL "WARDEN-ANGER-ADD" USING WS-WARDEN WS-PLAYER WS-AMOUNT WS-ZERO
     MOVE "acceptance US15 20§15 Warden anger is capped at 150" TO TL-CASE
     MOVE 150 TO TL-EXPECTED-N
     MOVE WD-ANGER(WS-W, WS-PLAYER) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WD-DIG-CD(WS-W)
     MOVE 1 TO WS-AMOUNT
     CALL "WARDEN-ANGER-ADD" USING WS-WARDEN WS-PLAYER WS-AMOUNT WS-ONE
     MOVE "acceptance US15 20§15 Warden a sensed player sets the dig cooldown 1200" TO TL-CASE
     MOVE 1200 TO TL-EXPECTED-N
     MOVE WD-DIG-CD(WS-W) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A creative player gains no anger.
     MOVE 0 TO WD-ANGER(WS-W, WS-PLAYER)
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE 50 TO WS-AMOUNT
     CALL "WARDEN-ANGER-ADD" USING WS-WARDEN WS-PLAYER WS-AMOUNT WS-ZERO
     MOVE "acceptance US15 20§15 Warden a creative player gets no anger" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-ANGER(WS-W, WS-PLAYER) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-MODE(WS-PLAYER)

*>   No target without anger; the angry player is the target; a creative player is not.
     MOVE 0 TO WD-ANGER(WS-W, WS-PLAYER)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "acceptance US15 20§15 Warden has no target without anger" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-WARDEN) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 90 TO WD-ANGER(WS-W, WS-PLAYER)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "acceptance US15 20§15 Warden targets the angry player" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-WARDEN) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO PL-MODE(WS-PLAYER)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "acceptance US15 20§15 Warden drops a target that turns creative" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-WARDEN) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-MODE(WS-PLAYER)

*>   Decay on the 20-tick pulse: 3 falls to 2, 2 falls to 1 and is dropped.
     MOVE 3 TO WD-ANGER(WS-W, WS-PLAYER)
     MOVE 12000 TO CW-TIME
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "acceptance US15 20§15 Warden anger 3 falls to 2 on the pulse" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WD-ANGER(WS-W, WS-PLAYER) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 12020 TO CW-TIME
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "acceptance US15 20§15 Warden anger 2 falls to 1 and is dropped" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-ANGER(WS-W, WS-PLAYER) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 12001 TO CW-TIME
     MOVE 5 TO WD-ANGER(WS-W, WS-PLAYER)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "acceptance US15 20§15 Warden anger does not fall off the pulse" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WD-ANGER(WS-W, WS-PLAYER) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Hurt by a player far away: anger +100, no target yet, the cooldown stays.
     MOVE 0 TO WD-ANGER(WS-W, WS-PLAYER)
     MOVE 0 TO EN-TARGET(WS-WARDEN) EN-TARGET-ID(WS-WARDEN)
     CALL "HEALTH-MOB-DAMAGE" USING WS-WARDEN WS-DAMAGE WS-CAUSE WS-PLAYER
     MOVE "acceptance US15 20§15 Warden hurt by a player at 8 blocks: anger 100" TO TL-CASE
     MOVE 100 TO TL-EXPECTED-N
     MOVE WD-ANGER(WS-W, WS-PLAYER) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§15 Warden hurt by a player at 8 blocks: no direct target" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-WARDEN) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Hurt within 5 blocks: the attacker is the target and the sonic boom cooldown is 200.
     MOVE 0 TO WD-ANGER(WS-W, WS-PLAYER)
     MOVE 0 TO WD-SONIC-CD(WS-W)
     COMPUTE EN-X(WS-WARDEN) = WS-X + 3
     CALL "HEALTH-MOB-DAMAGE" USING WS-WARDEN WS-DAMAGE WS-CAUSE WS-PLAYER
     MOVE "acceptance US15 20§15 Warden hurt within 5 blocks takes the attacker as target" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-WARDEN) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§15 Warden hurt within 5 blocks sets the sonic boom cooldown 200" TO TL-CASE
     MOVE 200 TO TL-EXPECTED-N
     MOVE WD-SONIC-CD(WS-W) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Melee: adjacent, angry: hits 18 ticks apart; the hit sets the sonic boom cooldown to 40. On Easy a hit takes 16 of the player's 20 points, so the second one lands too.
     MOVE 1 TO BW-DIFFICULTY
     MOVE 0 TO WD-ANGER(WS-W, WS-PLAYER)
     MOVE 100 TO WD-ANGER(WS-W, WS-PLAYER)
     MOVE 5000 TO WD-SONIC-CD(WS-W)
     COMPUTE EN-X(WS-WARDEN) = WS-X + 1
     MOVE 0 TO EN-COOLDOWN(WS-WARDEN)
     MOVE PL-HEALTH(WS-PLAYER) TO WS-HEALTH
     MOVE 0 TO WS-HITS WS-FIRST WS-SECOND
     MOVE 12001 TO CW-TIME
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60 OR WS-HITS = 2
         IF PL-HURT-COOLDOWN(WS-PLAYER) > 0
             SUBTRACT 1 FROM PL-HURT-COOLDOWN(WS-PLAYER)
         END-IF
         MOVE 100 TO WD-ANGER(WS-W, WS-PLAYER)
         COMPUTE EN-X(WS-WARDEN) = WS-X + 1
         MOVE 0 TO EN-VX(WS-WARDEN) EN-VZ(WS-WARDEN)
         CALL "MOB-STEP" USING WS-WARDEN
         IF PL-HEALTH(WS-PLAYER) < WS-HEALTH
             ADD 1 TO WS-HITS
             MOVE PL-HEALTH(WS-PLAYER) TO WS-HEALTH
             IF WS-HITS = 1
                 MOVE WS-I TO WS-FIRST
                 MOVE WD-SONIC-CD(WS-W) TO WS-CD-AT-END
             ELSE
                 MOVE WS-I TO WS-SECOND
             END-IF
         END-IF
     END-PERFORM
     MOVE 2 TO BW-DIFFICULTY
     MOVE PS-ALIVE TO PL-STATE(WS-PLAYER)
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE "acceptance US15 20§15 Warden melee cooldown 18 ticks" TO TL-CASE
     MOVE 18 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-SECOND - WS-FIRST
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§15 Warden melee sets the sonic boom cooldown 40" TO TL-CASE
     MOVE 40 TO TL-EXPECTED-N
     MOVE WS-CD-AT-END TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Sonic boom: 8 blocks away, angry, the cooldown absent. Behaviour tick 1 is the start; the boom (10 damage) lands on tick 34; at tick 60 the cooldown is 40.
     CALL "TEST-DRAIN-IDS" USING PL-CONN(WS-PLAYER) WS-IDS
     COMPUTE EN-X(WS-WARDEN) = WS-X + 8
     MOVE 0 TO WD-SONIC-CD(WS-W) WD-BOOM(WS-W) EN-COOLDOWN(WS-WARDEN)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     MOVE PL-HEALTH(WS-PLAYER) TO WS-HEALTH
     MOVE 0 TO WS-START WS-FIRE WS-END WS-CD-AT-END
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 80 OR WS-END > 0
         MOVE 100 TO WD-ANGER(WS-W, WS-PLAYER)
         COMPUTE EN-X(WS-WARDEN) = WS-X + 8
         CALL "MOB-STEP" USING WS-WARDEN
         IF WS-START = 0 AND WD-BOOM(WS-W) = 1
             MOVE WS-I TO WS-START
         END-IF
         IF WS-FIRE = 0 AND PL-HEALTH(WS-PLAYER) < WS-HEALTH
             MOVE WS-I TO WS-FIRE
             COMPUTE WS-AMOUNT = WS-HEALTH - PL-HEALTH(WS-PLAYER)
         END-IF
         IF WS-START > 0 AND WD-BOOM(WS-W) = 0
             MOVE WS-I TO WS-END
             MOVE WD-SONIC-CD(WS-W) TO WS-CD-AT-END
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§15 Warden sonic boom lands on the 34th tick of the behaviour" TO TL-CASE
     MOVE 33 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-FIRE - WS-START
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§15 Warden sonic boom damage 10" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE WS-AMOUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§15 Warden sonic boom lasts 60 ticks" TO TL-CASE
     MOVE 59 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-END - WS-START
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§15 Warden cooldown 40 after the boom" TO TL-CASE
     MOVE 40 TO TL-EXPECTED-N
     MOVE WS-CD-AT-END TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-DRAIN-IDS" USING PL-CONN(WS-PLAYER) WS-IDS
     MOVE SPACES TO WS-PADDED
     STRING " " DELIMITED BY SIZE FUNCTION TRIM(WS-IDS) DELIMITED BY SIZE " " DELIMITED BY SIZE INTO WS-PADDED
     MOVE 0 TO WS-HAS-MOTION WS-HAS-EVENT
     INSPECT WS-PADDED TALLYING WS-HAS-MOTION FOR ALL " 103 "
     INSPECT WS-PADDED TALLYING WS-HAS-EVENT FOR ALL " 34 "
     MOVE "acceptance US15 20§15 Warden sonic boom sends Set Entity Motion" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-HAS-MOTION > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§15 Warden sonic boom start sends entity event 62" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-HAS-EVENT > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A hurt with no attacker changes nothing; a target beyond 15 blocks starts no boom.
     MOVE 0 TO WD-ANGER(WS-W, WS-PLAYER) WD-SONIC-CD(WS-W) WD-BOOM(WS-W)
     CALL "WARDEN-HURT" USING WS-WARDEN WS-NO-ATTACKER
     MOVE "acceptance US15 20§15 Warden hurt without an attacker gets no anger" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-ANGER(WS-W, WS-PLAYER) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-PLAYER TO EN-TARGET(WS-WARDEN)
     COMPUTE EN-X(WS-WARDEN) = WS-X + 20
     CALL "WARDEN-SONIC" USING WS-WARDEN WS-STOP
     MOVE "acceptance US15 20§15 Warden starts no sonic boom at 20 blocks" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-BOOM(WS-W) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   With all 8 state slots taken, a ninth warden has no state: it gains no anger, has no level and no boom.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WD-MAX
         IF WD-ID(WS-I) = 0
             COMPUTE WD-ID(WS-I) = 900000 + WS-I
         END-IF
     END-PERFORM
     COMPUTE WS-X0 = WS-X + 6
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-WARDEN2
     MOVE 50 TO WS-AMOUNT
     CALL "WARDEN-ANGER-ADD" USING WS-WARDEN2 WS-PLAYER WS-AMOUNT WS-ZERO
     CALL "WARDEN-LEVEL" USING WS-WARDEN2 WS-LEVEL
     MOVE "acceptance US15 20§15 Warden without a state slot has level CALM" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LEVEL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-TARGET(WS-WARDEN2)
     CALL "MOB-STEP" USING WS-WARDEN2
     MOVE "acceptance US15 20§15 Warden without a state slot takes no target" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-WARDEN2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-20-15-2.
 COPY CORETEST.
 COPY MOBSPTEST.
