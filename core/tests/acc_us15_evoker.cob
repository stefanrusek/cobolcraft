*> Acceptance test, evoker spells (docs/protocol/20 section 13.3; lane 002-lane-mobsb5, T8900): the fang layouts, the spell times, the vex limit, the summon of 3 vexes with owner and
*> limited life, the casting state machine of the evoker, and the bite of a fang (6 damage after its warm-up).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-EVOKER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY EVKSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ETYPE               BINARY-LONG.
 01 WS-VTYPE               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-YAW-RAD             FLOAT-LONG VALUE 0.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-CAST                BINARY-LONG.
 01 WS-INTERVAL            BINARY-LONG.
 01 WS-WARM                BINARY-LONG.
 01 WS-SPELL               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-YES                 BINARY-LONG.
 01 WS-BLUE                BINARY-LONG.
 01 WS-H0                  FLOAT-SHORT.
 01 WS-DIFF                FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:evoker" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ETYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:vex" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-VTYPE WS-ENTITY-ROW WS-STATUS
*>   Fang layout: a target within 3 blocks gets a ring of 5 (radius 1.5, warm-up 0) and a ring of 8 (radius 2.5, warm-up 3).
     MOVE 4 TO WS-D2
     CALL "EVK-FANGS-PLAN" USING WS-D2 WS-YAW-RAD
     MOVE "acceptance US15 20§13.3 a close target gets 13 fangs" TO TL-CASE
     MOVE 13 TO TL-EXPECTED-N
     MOVE EV-PLAN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§13.3 the first fang of the inner ring is 1.5 ahead" TO TL-CASE
     COMPUTE TL-EXPECTED-N ROUNDED = 1.5 * 1000
     COMPUTE TL-OBSERVED-N ROUNDED = EV-PLAN-DX(1) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§13.3 the inner ring has warm-up 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EV-PLAN-WARM(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§13.3 the outer ring has warm-up 3" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE EV-PLAN-WARM(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§13.3 the first outer fang is at radius 2.5 and 72 degrees" TO TL-CASE
     COMPUTE TL-EXPECTED-N ROUNDED = (2.5 * FUNCTION COS(1.2566371)) * 1000
     COMPUTE TL-OBSERVED-N ROUNDED = EV-PLAN-DX(6) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A far target: a line of 16, 1.25 apart, warm-up i.
     MOVE 100 TO WS-D2
     CALL "EVK-FANGS-PLAN" USING WS-D2 WS-YAW-RAD
     MOVE "acceptance US15 20§13.3 a far target gets a line of 16" TO TL-CASE
     MOVE 16 TO TL-EXPECTED-N
     MOVE EV-PLAN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§13.3 the last fang is 20 blocks out" TO TL-CASE
     COMPUTE TL-EXPECTED-N ROUNDED = 20 * 1000
     COMPUTE TL-OBSERVED-N ROUNDED = EV-PLAN-DX(16) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§13.3 the last fang has warm-up 15" TO TL-CASE
     MOVE 15 TO TL-EXPECTED-N
     MOVE EV-PLAN-WARM(16) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Spell times.
     MOVE 2 TO WS-SPELL
     CALL "EVK-SPELL-TIMES" USING WS-SPELL WS-CAST WS-INTERVAL WS-WARM
     MOVE "acceptance US15 20§13.3 fangs cast 40 interval 100 warm-up 20" TO TL-CASE
     MOVE 40100020 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-CAST * 1000000 + WS-INTERVAL * 1000 + WS-WARM
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-SPELL
     CALL "EVK-SPELL-TIMES" USING WS-SPELL WS-CAST WS-INTERVAL WS-WARM
     MOVE "acceptance US15 20§13.3 summon vex casts 100 interval 340" TO TL-CASE
     MOVE 100340020 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-CAST * 1000000 + WS-INTERVAL * 1000 + WS-WARM
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-SPELL
     CALL "EVK-SPELL-TIMES" USING WS-SPELL WS-CAST WS-INTERVAL WS-WARM
     MOVE "acceptance US15 20§13.3 wololo casts 60 interval 140 warm-up 40" TO TL-CASE
     MOVE 60140040 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-CAST * 1000000 + WS-INTERVAL * 1000 + WS-WARM
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Vex limit: allowed while the count is below 1 + the draw.
     MOVE 2 TO WS-COUNT
     MOVE 1 TO WS-DRAW
     CALL "EVK-VEX-ALLOWED" USING WS-COUNT WS-DRAW WS-YES
     MOVE "acceptance US15 20§13.3 2 vexes with draw 1 is not below 2" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-YES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-DRAW
     CALL "EVK-VEX-ALLOWED" USING WS-COUNT WS-DRAW WS-YES
     MOVE "acceptance US15 20§13.3 2 vexes with draw 2 is below 3" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-YES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Live: an evoker with the player as target, 10 blocks away.
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     ADD 10 TO WS-X
     CALL "MOB-SPAWN" USING WS-DIM WS-ETYPE WS-X WS-Y WS-Z WS-YAW WS-E
     MOVE WS-PLAYER TO EN-TARGET(WS-E)
     MOVE 3 TO WS-SPELL
     CALL "EVK-BEGIN" USING WS-E WS-SPELL
     CALL "EVK-FIND" USING EN-ID(WS-E) WS-N WS-SLOT
     MOVE "acceptance US15 20§13.3 beginning wololo sets the casting counter 60" TO TL-CASE
     MOVE 60 TO TL-EXPECTED-N
     MOVE EV-CAST(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§13.3 the next spell is CW-TICKS + 140" TO TL-CASE
     COMPUTE TL-EXPECTED-N = CW-TICKS + 140
     MOVE EV-NEXT(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Fangs: begin the spell and step 20 ticks; the fangs exist, 16 in a line.
     MOVE 2 TO WS-SPELL
     MOVE 0 TO EV-SPELL(WS-SLOT) EV-CAST(WS-SLOT)
     CALL "EVK-BEGIN" USING WS-E WS-SPELL
     PERFORM 19 TIMES
         CALL "EVK-STEP" USING WS-E
     END-PERFORM
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EF-MAX
         ADD EF-USED(WS-I) TO WS-N
     END-PERFORM
     MOVE "acceptance US15 20§13.3 no fang before the warm-up ends" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "EVK-STEP" USING WS-E
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EF-MAX
         ADD EF-USED(WS-I) TO WS-N
     END-PERFORM
     MOVE "acceptance US15 20§13.3 at warm-up 0 the 16 fangs of the line are made" TO TL-CASE
     MOVE 16 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Summon: three vexes with owner and life.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EF-MAX
         MOVE 0 TO EF-USED(WS-I)
     END-PERFORM
     CALL "EVK-SUMMON" USING WS-E
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > VX-MAX
         IF VX-ID(WS-I) > 0 AND VX-OWNER(WS-I) = EN-ID(WS-E) AND VX-LIFE(WS-I) >= 600 AND VX-LIFE(WS-I) < 2600
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§13.3 three vexes owned by the evoker with 600 to 2599 life ticks" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "EVK-VEX-COUNT" USING WS-E WS-COUNT
     MOVE "acceptance US15 20§13.3 the evoker counts its vexes within 16 blocks" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Vex life: at 0 it starves 1 point every 20 ticks.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > VX-MAX
         IF VX-ID(WS-I) > 0
             MOVE 1 TO VX-LIFE(WS-I)
         END-IF
     END-PERFORM
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT OR WS-N > 0
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-VTYPE
             MOVE WS-I TO WS-N
         END-IF
     END-PERFORM
     MOVE EN-HEALTH(WS-N) TO WS-H0
     CALL "VEX-STEP" USING WS-N
     MOVE "acceptance US15 20§13.4 the last life tick only counts down" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-H0 - EN-HEALTH(WS-N)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM 20 TIMES
         CALL "VEX-STEP" USING WS-N
     END-PERFORM
     MOVE "acceptance US15 20§13.4 after the life ends the vex starves 1 point" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-H0 - EN-HEALTH(WS-N)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A fang bites after its warm-up of 0 plus 8 ticks: 6 damage to a player standing in it.
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO WS-WARM
     CALL "EVK-FANG-ADD" USING WS-DIM WS-X WS-Y WS-Z WS-WARM EN-ID(WS-E)
     PERFORM 7 TIMES
         CALL "EVK-FANG-TICK"
     END-PERFORM
     MOVE "acceptance US15 20§13.3 no bite before the 8th tick past the warm-up" TO TL-CASE
     COMPUTE TL-EXPECTED-N ROUNDED = 20 * 1000
     COMPUTE TL-OBSERVED-N ROUNDED = PL-HEALTH(WS-PLAYER) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "EVK-FANG-TICK"
     MOVE "acceptance US15 20§13.3 the bite does 6 damage on Normal" TO TL-CASE
     COMPUTE TL-EXPECTED-N ROUNDED = 14 * 1000
     COMPUTE TL-OBSERVED-N ROUNDED = PL-HEALTH(WS-PLAYER) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US15-EVOKER.

 COPY CORETEST.
 COPY MOBSPTEST.
