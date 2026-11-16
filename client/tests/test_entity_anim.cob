*> Implementation test of the mob animation drivers of the replica (T7900 to T7903; docs/protocol/54 sections 1 and 2): the walk animation state of every
*> living entity, fed from the position change of a client tick (smoothing 0.4, positionScale 3 for a baby; per-type factors of the camel, frog and
*> creaking, the omnidirectional bee), the damage event's speed 1.5, the local player's own walk state, the swing of the Swing Animation packet
*> (start rule, tick, duration modifiers), the mob flags byte (slot 15, bit 4 aggressive) and their effect on the drawn models.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY CLMODELS.
 COPY TESTLIB.
 01 WS-KEY                 PIC X(112).
 01 WS-ROW-AREA            PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-POS                 FLOAT-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-STARTED             BINARY-LONG.
 01 WS-HASTE               BINARY-LONG.
 01 WS-FATIGUE             BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-OUT                 BINARY-LONG.
 01 WS-HAND                BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-DUR                 BINARY-LONG.
 01 WS-SUM-REST            BINARY-DOUBLE.
 01 WS-SUM-NOW             BINARY-DOUBLE.
 01 WS-INDEX               BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-SER                 BINARY-LONG.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE 0 TO PK-COUNT
     CALL "ENTITY-ATLAS-BUILD" USING CLIENT-STATE
     MOVE 256 TO PL-HEIGHT
     MOVE 0 TO SK-U PL-YAW
     MOVE 10 TO WS-EYE(1) WS-EYE(3)
     MOVE 64 TO WS-EYE(2)
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     MOVE "N" TO TL-MODE
     MOVE 10.5 TO WS-X
     MOVE 64 TO WS-Y
     MOVE 12.5 TO WS-Z
*>   Rows 1 to 6: zombie, creaking, frog, camel, bee, cow.
     MOVE 1 TO WS-ID
     MOVE "zombie" TO WS-KEY
     CALL "EAN-SPAWN" USING CLIENT-STATE WS-ID WS-KEY WS-X WS-Y WS-Z
     MOVE 2 TO WS-ID
     MOVE "creaking" TO WS-KEY
     CALL "EAN-SPAWN" USING CLIENT-STATE WS-ID WS-KEY WS-X WS-Y WS-Z
     MOVE 3 TO WS-ID
     MOVE "frog" TO WS-KEY
     CALL "EAN-SPAWN" USING CLIENT-STATE WS-ID WS-KEY WS-X WS-Y WS-Z
     MOVE 4 TO WS-ID
     MOVE "camel" TO WS-KEY
     CALL "EAN-SPAWN" USING CLIENT-STATE WS-ID WS-KEY WS-X WS-Y WS-Z
     MOVE 5 TO WS-ID
     MOVE "bee" TO WS-KEY
     CALL "EAN-SPAWN" USING CLIENT-STATE WS-ID WS-KEY WS-X WS-Y WS-Z
     MOVE 6 TO WS-ID
     MOVE "cow" TO WS-KEY
     CALL "EAN-SPAWN" USING CLIENT-STATE WS-ID WS-KEY WS-X WS-Y WS-Z
     MOVE "entity anim a spawned zombie starts with no walk speed" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-WALK-SPEED(1) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   54 1.5 example 1: a default adult moving 0.2 a tick from rest: speeds 0.32, 0.512, 0.6272, position 1.4592.
     MOVE 3 TO WS-I
     PERFORM WS-I TIMES
         ADD 0.2 TO EN-X(1)
         CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     END-PERFORM
     MOVE "entity anim zombie speed after three ticks at 0.2 a tick is 0.6272" TO TL-CASE
     MOVE 6272 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-WALK-SPEED(1) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "entity anim zombie position after three ticks is 1.4592" TO TL-CASE
     MOVE 14592 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-WALK-POS(1) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-ROW
     CALL "ENTITY-WALK-VALUES" USING CLIENT-STATE WS-ROW WS-POS WS-SPEED
     MOVE "entity anim an adult's rendered position is 1.4592" TO TL-CASE
     MOVE 14592 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-POS * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "entity anim the rendered speed is 0.6272" TO TL-CASE
     MOVE 6272 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-SPEED * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A baby (Set Entity Data slot 16, BOOLEAN) has the position scale 3: 4.3776.
     MOVE 1 TO WS-ID
     MOVE 16 TO WS-INDEX
     MOVE 1 TO WS-VALUE
     MOVE "B" TO WS-KEY
     CALL "EAN-DATA" USING CLIENT-STATE WS-ID WS-INDEX WS-VALUE WS-KEY
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     MOVE "entity anim the baby flag is kept" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-BABY(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "entity anim a baby's position scale is 3" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE EN-WALK-SCALE(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-VALUE
     CALL "EAN-DATA" USING CLIENT-STATE WS-ID WS-INDEX WS-VALUE WS-KEY
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     MOVE "entity anim the baby flag is cleared again and the scale is 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-WALK-SCALE(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Standing still: the speed decays by 0.6 a tick (the tick above already did one: 0.6272 -> 0.3763 -> 0.2258).
     MOVE "entity anim a standing zombie's speed decays by a factor 0.6 a tick (two ticks: 0.2258)" TO TL-CASE
     MOVE 2258 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-WALK-SPEED(1) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Per-type factors. Creaking: min(d x 25, 3) and the smoothing 0.4: 0.2 a tick gives 3, speed 1.2.
     ADD 0.2 TO EN-X(2)
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     MOVE "entity anim a creaking's target speed is capped at 3 (speed 1.2 after a tick)" TO TL-CASE
     MOVE 12000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-WALK-SPEED(2) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Frog: d x 25 (0.02 a tick: target 0.5, speed 0.2); a frog while its jump runs would have 0, which the replica cannot see.
     ADD 0.02 TO EN-X(3)
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     MOVE "entity anim a frog's target speed is d x 25 (0.2 after a tick)" TO TL-CASE
     MOVE 2000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-WALK-SPEED(3) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Camel: d x 6 while standing, smoothing 0.2: 0.1 a tick gives 0.6 x 0.2 = 0.12; a camel in another pose gives 0.
     ADD 0.1 TO EN-X(4)
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     MOVE "entity anim a standing camel's speed is 0.12 after a tick (d x 6, smoothing 0.2)" TO TL-CASE
     MOVE 1200 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-WALK-SPEED(4) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO EN-POSE(4)
     MOVE 0 TO EN-WALK-SPEED(4)
     ADD 0.1 TO EN-X(4)
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     MOVE "entity anim a camel that is not standing has the target 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-WALK-SPEED(4) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Bee: omnidirectional, the vertical change counts (0.1 up: d 0.1, speed 0.16); a cow's vertical change does not.
     ADD 0.1 TO EN-Y(5)
     ADD 0.1 TO EN-Y(6)
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     MOVE "entity anim a bee's vertical movement counts (speed 0.16)" TO TL-CASE
     MOVE 1600 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-WALK-SPEED(5) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "entity anim a cow's vertical movement does not count (speed 0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-WALK-SPEED(6) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Damage event: speed 1.5 (rendered speed clamped to 1).
     MOVE 6 TO WS-ID
     CALL "ENTITY-HURT" USING CLIENT-STATE WS-ID
     MOVE "entity anim the damage event sets the walk speed to 1.5" TO TL-CASE
     MOVE 15000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-WALK-SPEED(6) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6 TO WS-ROW
     CALL "ENTITY-WALK-VALUES" USING CLIENT-STATE WS-ROW WS-POS WS-SPEED
     MOVE "entity anim the rendered speed of a hurt entity is clamped to 1" TO TL-CASE
     MOVE 10000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-SPEED * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 99 TO WS-ID
     CALL "ENTITY-HURT" USING CLIENT-STATE WS-ID
     MOVE "entity anim a damage event of an unknown entity is ignored" TO TL-CASE
     MOVE 15000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-WALK-SPEED(6) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The local player's own walk state (the first tick only records the position).
     MOVE 0 TO PL-ANIM-INIT PL-ANIM-SPEED PL-ANIM-POS
     MOVE 5 TO PL-X
     MOVE 70 TO PL-Y
     MOVE 5 TO PL-Z
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     MOVE 3 TO WS-I
     PERFORM WS-I TIMES
         ADD 0.2 TO PL-X
         CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     END-PERFORM
     MOVE "entity anim the local player's walk speed after three ticks at 0.2 is 0.6272" TO TL-CASE
     MOVE 6272 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PL-ANIM-SPEED * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "entity anim the local player's walk position is 1.4592" TO TL-CASE
     MOVE 14592 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PL-ANIM-POS * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Swing duration: Haste a: d - (1 + a); else Mining Fatigue a: d + (1 + a) x 2 (amplifier -1 = no effect).
     MOVE 6 TO WS-BASE
     MOVE -1 TO WS-HASTE WS-FATIGUE
     CALL "ENTITY-SWING-DURATION" USING WS-BASE WS-HASTE WS-FATIGUE WS-OUT
     MOVE "entity anim a swing without effects lasts 6 ticks" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-HASTE
     CALL "ENTITY-SWING-DURATION" USING WS-BASE WS-HASTE WS-FATIGUE WS-OUT
     MOVE "entity anim Haste III shortens a 6 tick swing to 3" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-FATIGUE
     CALL "ENTITY-SWING-DURATION" USING WS-BASE WS-HASTE WS-FATIGUE WS-OUT
     MOVE "entity anim Haste takes precedence over Mining Fatigue" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -1 TO WS-HASTE
     CALL "ENTITY-SWING-DURATION" USING WS-BASE WS-HASTE WS-FATIGUE WS-OUT
     MOVE "entity anim Mining Fatigue II lengthens a 6 tick swing to 10" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-BASE
     MOVE 5 TO WS-HASTE
     MOVE -1 TO WS-FATIGUE
     CALL "ENTITY-SWING-DURATION" USING WS-BASE WS-HASTE WS-FATIGUE WS-OUT
     MOVE "entity anim a swing is never shorter than 1 tick" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Swing Animation (0x7B) on the zombie (id 1, row 1): whack, 6 ticks, main hand.
     MOVE 1 TO WS-ID
     MOVE 0 TO WS-HAND
     MOVE 1 TO WS-TYPE
     MOVE 6 TO WS-DUR
     CALL "EAN-SWING" USING CLIENT-STATE WS-ID WS-HAND WS-TYPE WS-DUR
     MOVE "entity anim the swing packet starts a swing" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-SW-ACTIVE(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "entity anim the swing keeps its duration 6 and its type whack" TO TL-CASE
     MOVE 61 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-SW-DUR(1) * 10 + EN-SW-TYPE(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     MOVE "entity anim the swing value after three ticks is 2/6 and ticks is 3" TO TL-CASE
     MOVE 3333 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-SW-ANIM(1) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO TL-EXPECTED-N
     MOVE EN-SW-TICKS(1) TO TL-OBSERVED-N
     MOVE "entity anim the swing has ticked three times" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Start rule: not yet more than half over (3 > 3 is false): the new swing is refused.
     CALL "EAN-SWING" USING CLIENT-STATE WS-ID WS-HAND WS-TYPE WS-DUR
     MOVE "entity anim a swing in the first half of a running one is refused (ticks stay 3)" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE EN-SW-TICKS(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     CALL "EAN-SWING" USING CLIENT-STATE WS-ID WS-HAND WS-TYPE WS-DUR
     MOVE "entity anim a swing more than half over is replaced (ticks back to 0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-SW-TICKS(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "entity anim the same triple keeps the animation value (3/6 at the tick before)" TO TL-CASE
     MOVE 5000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-SW-ANIM(1) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   ticks <= 0: a swing just started can be replaced at once; a different triple resets the animation value to 0.
     MOVE 8 TO WS-DUR
     CALL "EAN-SWING" USING CLIENT-STATE WS-ID WS-HAND WS-TYPE WS-DUR
     MOVE "entity anim a swing with ticks 0 is replaced by a new one of 8 ticks" TO TL-CASE
     MOVE 8 TO TL-EXPECTED-N
     MOVE EN-SW-DUR(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "entity anim a different triple resets the animation value" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-SW-ANIM(1) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The swing ends once its ticks exceed the duration, the value is 0 again.
     PERFORM 9 TIMES
         CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     END-PERFORM
     MOVE "entity anim the swing has ended after more than its duration" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-SW-ACTIVE(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "entity anim an ended swing has the value 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-SW-ANIM(1) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   No swing running: a new one starts; the off hand (1) and the stab type (2) are kept; a swing of an unknown entity is ignored.
     MOVE 1 TO WS-HAND
     MOVE 2 TO WS-TYPE
     CALL "EAN-SWING" USING CLIENT-STATE WS-ID WS-HAND WS-TYPE WS-DUR
     MOVE "entity anim a swing starts when none runs (off hand, stab)" TO TL-CASE
     MOVE 112 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-SW-ACTIVE(1) * 100 + EN-SW-HAND(1) * 10 + EN-SW-TYPE(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 99 TO WS-ID
     CALL "EAN-SWING" USING CLIENT-STATE WS-ID WS-HAND WS-TYPE WS-DUR
     MOVE "entity anim a swing of an unknown entity changes nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-SW-TICKS(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A swing of type none is accepted (no arm motion).
     MOVE 1 TO WS-ID
     MOVE 0 TO WS-TYPE WS-HAND
     PERFORM 10 TIMES
         CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     END-PERFORM
     CALL "EAN-SWING" USING CLIENT-STATE WS-ID WS-HAND WS-TYPE WS-DUR
     MOVE "entity anim a swing of type none is kept as type 0" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-SW-ACTIVE(1) + EN-SW-TYPE(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Mob flags (Set Entity Data slot 15, BYTE): bit 4 aggressive, bit 2 left-handed; other types of entry 15 are ignored.
     MOVE 15 TO WS-INDEX
     MOVE 4 TO WS-VALUE
     MOVE "Y" TO WS-KEY
     CALL "EAN-DATA" USING CLIENT-STATE WS-ID WS-INDEX WS-VALUE WS-KEY
     MOVE "entity anim the mob flags byte is kept (aggressive 4)" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE EN-MOB-FLAGS(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-VALUE
     MOVE "B" TO WS-KEY
     CALL "EAN-DATA" USING CLIENT-STATE WS-ID WS-INDEX WS-VALUE WS-KEY
     MOVE "entity anim an entry 15 that is not a byte is not the mob flags" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE EN-MOB-FLAGS(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Effect on the drawn models. Checksum: the sum of y and z of the entity's vertices in thousandths (the zombie moves along x only).
     MOVE 0 TO EN-MOB-FLAGS(1) EN-WALK-SPEED(1) EN-WALK-POS(1) EN-SW-ACTIVE(1) EN-SW-ANIM(1)
     MOVE 1 TO WS-ROW
     CALL "EAN-SUM" USING CLIENT-STATE WS-ROW WS-EYE-TABLE WS-SUM-REST
     MOVE 0.6 TO EN-WALK-SPEED(1)
     MOVE 2.5 TO EN-WALK-POS(1)
     CALL "EAN-SUM" USING CLIENT-STATE WS-ROW WS-EYE-TABLE WS-SUM-NOW
     MOVE "entity anim a walking zombie's limbs are posed (differs from rest)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SUM-NOW NOT = WS-SUM-REST
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-WALK-SPEED(1) EN-WALK-POS(1)
     MOVE 4 TO EN-MOB-FLAGS(1)
     CALL "EAN-SUM" USING CLIENT-STATE WS-ROW WS-EYE-TABLE WS-SUM-NOW
     MOVE "entity anim an aggressive zombie raises its arms higher (differs from rest)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SUM-NOW NOT = WS-SUM-REST
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-MOB-FLAGS(1)
     MOVE 1 TO EN-SW-ACTIVE(1) EN-SW-TYPE(1)
     MOVE 0 TO EN-SW-HAND(1)
     MOVE 6 TO EN-SW-DUR(1)
     MOVE 0.5 TO EN-SW-ANIM(1)
     CALL "EAN-SUM" USING CLIENT-STATE WS-ROW WS-EYE-TABLE WS-SUM-NOW
     MOVE "entity anim a zombie in mid swing moves its arms (differs from rest)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SUM-NOW NOT = WS-SUM-REST
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Quadruped (cow, row 6) and creeper walk.
     MOVE 0 TO EN-SW-ACTIVE(1)
     MOVE 6 TO WS-ROW
     MOVE 0 TO EN-WALK-SPEED(6) EN-WALK-POS(6)
     CALL "EAN-SUM" USING CLIENT-STATE WS-ROW WS-EYE-TABLE WS-SUM-REST
     MOVE 0.8 TO EN-WALK-SPEED(6)
     MOVE 1.7 TO EN-WALK-POS(6)
     CALL "EAN-SUM" USING CLIENT-STATE WS-ROW WS-EYE-TABLE WS-SUM-NOW
     MOVE "entity anim a walking cow's legs are posed (differs from rest)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SUM-NOW NOT = WS-SUM-REST
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-ID
     MOVE "creeper" TO WS-KEY
     CALL "EAN-SPAWN" USING CLIENT-STATE WS-ID WS-KEY WS-X WS-Y WS-Z
     MOVE 8 TO WS-ID
     MOVE "skeleton" TO WS-KEY
     CALL "EAN-SPAWN" USING CLIENT-STATE WS-ID WS-KEY WS-X WS-Y WS-Z
     MOVE 7 TO WS-ROW
     CALL "EAN-SUM" USING CLIENT-STATE WS-ROW WS-EYE-TABLE WS-SUM-REST
     MOVE 0.8 TO EN-WALK-SPEED(7)
     MOVE 1.7 TO EN-WALK-POS(7)
     CALL "EAN-SUM" USING CLIENT-STATE WS-ROW WS-EYE-TABLE WS-SUM-NOW
     MOVE "entity anim a walking creeper's legs are posed (differs from rest)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SUM-NOW NOT = WS-SUM-REST
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 8 TO WS-ROW
     CALL "EAN-SUM" USING CLIENT-STATE WS-ROW WS-EYE-TABLE WS-SUM-REST
     MOVE 4 TO EN-MOB-FLAGS(8)
     CALL "EAN-SUM" USING CLIENT-STATE WS-ROW WS-EYE-TABLE WS-SUM-NOW
     MOVE "entity anim an aggressive skeleton differs from a calm one" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SUM-NOW NOT = WS-SUM-REST
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A left-handed zombie (flags 2) swings with both arms alike, so the pose of the zombie family does not tell the hands apart (4.3 animates both arms); the
*>   base swing of a player does: the main hand (0) and the off hand (1) swing different arms.
     MOVE 2 TO EN-MOB-FLAGS(1)
     MOVE 9 TO WS-ID
     MOVE "player" TO WS-KEY
     CALL "EAN-SPAWN" USING CLIENT-STATE WS-ID WS-KEY WS-X WS-Y WS-Z
     MOVE 9 TO WS-ROW
     MOVE 1 TO EN-SW-ACTIVE(9) EN-SW-TYPE(9)
     MOVE 6 TO EN-SW-DUR(9)
     MOVE 0.5 TO EN-SW-ANIM(9)
     MOVE 0 TO EN-SW-HAND(9)
     CALL "EAN-SUM" USING CLIENT-STATE WS-ROW WS-EYE-TABLE WS-SUM-REST
     MOVE 1 TO EN-SW-HAND(9)
     CALL "EAN-SUM" USING CLIENT-STATE WS-ROW WS-EYE-TABLE WS-SUM-NOW
     MOVE "entity anim the off hand swings the other arm of a player" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SUM-NOW NOT = WS-SUM-REST
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-USED(9)

*>   Age in ticks (54 section 1 / 34-2: ageInTicks drives the arm bob and sway of the humanoids): one a tick, kept for the row and for the local figure.
     MOVE 0 TO EN-AGE(1) PL-ANIM-AGE
     PERFORM 5 TIMES
         CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     END-PERFORM
     MOVE "entity anim the age of a replica row counts client ticks" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE EN-AGE(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "entity anim the age of the local figure counts client ticks" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE PL-ANIM-AGE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-ROW
     MOVE 0 TO EN-AGE(1)
     CALL "EAN-SUM" USING CLIENT-STATE WS-ROW WS-EYE-TABLE WS-SUM-REST
     MOVE 40 TO EN-AGE(1)
     CALL "EAN-SUM" USING CLIENT-STATE WS-ROW WS-EYE-TABLE WS-SUM-NOW
     MOVE "entity anim a zombie's arms sway with its age (age 40 differs from age 0)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SUM-NOW NOT = WS-SUM-REST
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Models of the codes -: spider, cave spider, wolf and chicken walk (rows 9 to 12: the player's row 9 is free again), and the spider's eyes layer is posed like its body.
     MOVE 9 TO WS-ID
     MOVE "spider" TO WS-KEY
     CALL "EAN-SPAWN" USING CLIENT-STATE WS-ID WS-KEY WS-X WS-Y WS-Z
     MOVE 10 TO WS-ID
     MOVE "cave_spider" TO WS-KEY
     CALL "EAN-SPAWN" USING CLIENT-STATE WS-ID WS-KEY WS-X WS-Y WS-Z
     MOVE 11 TO WS-ID
     MOVE "wolf" TO WS-KEY
     CALL "EAN-SPAWN" USING CLIENT-STATE WS-ID WS-KEY WS-X WS-Y WS-Z
     MOVE 12 TO WS-ID
     MOVE "chicken" TO WS-KEY
     CALL "EAN-SPAWN" USING CLIENT-STATE WS-ID WS-KEY WS-X WS-Y WS-Z
     PERFORM VARYING WS-ROW FROM 9 BY 1 UNTIL WS-ROW > 12
         MOVE 0 TO EN-WALK-SPEED(WS-ROW) EN-WALK-POS(WS-ROW)
         CALL "EAN-SUM" USING CLIENT-STATE WS-ROW WS-EYE-TABLE WS-SUM-REST
         MOVE 0.8 TO EN-WALK-SPEED(WS-ROW)
         MOVE 1.7 TO EN-WALK-POS(WS-ROW)
         CALL "EAN-SUM" USING CLIENT-STATE WS-ROW WS-EYE-TABLE WS-SUM-NOW
         MOVE "entity anim a walking spider, cave spider, wolf or chicken is posed (differs from rest)" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         IF WS-SUM-NOW NOT = WS-SUM-REST
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   A key of the table with no animation is left alone: the blaze does not read the walk state (an unknown row stays equal).
     MOVE "blaze" TO WS-KEY
     MOVE 13 TO WS-ID
     CALL "EAN-SPAWN" USING CLIENT-STATE WS-ID WS-KEY WS-X WS-Y WS-Z
     MOVE 13 TO WS-ROW
     CALL "EAN-SUM" USING CLIENT-STATE WS-ROW WS-EYE-TABLE WS-SUM-REST
     MOVE 0.8 TO EN-WALK-SPEED(13)
     MOVE 1.7 TO EN-WALK-POS(13)
     CALL "EAN-SUM" USING CLIENT-STATE WS-ROW WS-EYE-TABLE WS-SUM-NOW
     MOVE "entity anim a blaze does not change with the walk state (it reads the age only)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SUM-NOW = WS-SUM-REST
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The blaze's rods turn with its age; the enderman walks (the eyes layers are extra layers of their base rows, not entity rows).
     MOVE 40 TO EN-AGE(13)
     CALL "EAN-SUM" USING CLIENT-STATE WS-ROW WS-EYE-TABLE WS-SUM-NOW
     MOVE 0 TO EN-AGE(13)
     CALL "EAN-SUM" USING CLIENT-STATE WS-ROW WS-EYE-TABLE WS-SUM-REST
     MOVE "entity anim a blaze's rods turn with its age (age 40 differs from age 0)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SUM-NOW NOT = WS-SUM-REST
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 14 TO WS-ID
     MOVE "enderman" TO WS-KEY
     CALL "EAN-SPAWN" USING CLIENT-STATE WS-ID WS-KEY WS-X WS-Y WS-Z
     PERFORM VARYING WS-ROW FROM 14 BY 1 UNTIL WS-ROW > 14
         MOVE 0 TO EN-WALK-SPEED(WS-ROW) EN-WALK-POS(WS-ROW)
         CALL "EAN-SUM" USING CLIENT-STATE WS-ROW WS-EYE-TABLE WS-SUM-REST
         MOVE 0.8 TO EN-WALK-SPEED(WS-ROW)
         MOVE 1.7 TO EN-WALK-POS(WS-ROW)
         CALL "EAN-SUM" USING CLIENT-STATE WS-ROW WS-EYE-TABLE WS-SUM-NOW
         MOVE "entity anim a walking enderman is posed (differs from rest)" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         IF WS-SUM-NOW NOT = WS-SUM-REST
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     PERFORM VARYING WS-I FROM 9 BY 1 UNTIL WS-I > 16
         MOVE 0 TO EN-USED(WS-I)
     END-PERFORM

*>   The local player's figure in the third-person view walks with the state of the player.
     MOVE 1 TO CL-CAMERA
     MOVE 0 TO PL-ANIM-SPEED PL-ANIM-POS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE 0 TO EN-USED(WS-I)
     END-PERFORM
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE 0 TO WS-SUM-REST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-EN-COUNT
         COMPUTE WS-SUM-REST = WS-SUM-REST + FUNCTION INTEGER(RL-EN-Y(WS-I) * 1000 + 0.5)
             + FUNCTION INTEGER(RL-EN-Z(WS-I) * 1000 + 0.5)
     END-PERFORM
     MOVE 0.7 TO PL-ANIM-SPEED
     MOVE 3.1 TO PL-ANIM-POS
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE 0 TO WS-SUM-NOW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-EN-COUNT
         COMPUTE WS-SUM-NOW = WS-SUM-NOW + FUNCTION INTEGER(RL-EN-Y(WS-I) * 1000 + 0.5)
             + FUNCTION INTEGER(RL-EN-Z(WS-I) * 1000 + 0.5)
     END-PERFORM
     MOVE "entity anim the local player's figure is drawn with its walk state" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF RL-EN-COUNT > 0 AND WS-SUM-NOW NOT = WS-SUM-REST
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A guardian's entry 16 is its moving flag (BOOLEAN), not a baby flag (T9404): EN-X1 takes it, EN-BABY stays 0.
     MOVE 30 TO WS-ID
     MOVE "guardian" TO WS-KEY
     CALL "EAN-SPAWN" USING CLIENT-STATE WS-ID WS-KEY WS-X WS-Y WS-Z
     CALL "ENTITY-FIND" USING CLIENT-STATE WS-ID WS-ROW
     MOVE 16 TO WS-INDEX
     MOVE 1 TO WS-VALUE
     MOVE "B" TO WS-KEY
     CALL "EAN-DATA" USING CLIENT-STATE WS-ID WS-INDEX WS-VALUE WS-KEY
     MOVE "entity anim a guardian's entry 16 is not a baby flag" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-BABY(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "entity anim a guardian's entry 16 is its moving flag" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-X1(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The baby flag is entry 16 only for the ageable mobs: a witch's entry 16 is celebrating, a piglin's baby flag is entry 17 and its entry 16 is immunity (21 App A).
     MOVE 31 TO WS-ID
     MOVE "witch" TO WS-KEY
     CALL "EAN-SPAWN" USING CLIENT-STATE WS-ID WS-KEY WS-X WS-Y WS-Z
     CALL "ENTITY-FIND" USING CLIENT-STATE WS-ID WS-ROW
     MOVE 16 TO WS-INDEX
     MOVE 1 TO WS-VALUE
     MOVE "B" TO WS-KEY
     CALL "EAN-DATA" USING CLIENT-STATE WS-ID WS-INDEX WS-VALUE WS-KEY
     MOVE "entity anim a witch's entry 16 is not a baby flag" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-BABY(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 32 TO WS-ID
     MOVE "piglin" TO WS-KEY
     CALL "EAN-SPAWN" USING CLIENT-STATE WS-ID WS-KEY WS-X WS-Y WS-Z
     CALL "ENTITY-FIND" USING CLIENT-STATE WS-ID WS-ROW
     MOVE "B" TO WS-KEY
     CALL "EAN-DATA" USING CLIENT-STATE WS-ID WS-INDEX WS-VALUE WS-KEY
     MOVE "entity anim a piglin's entry 16 is not a baby flag" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-BABY(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 17 TO WS-INDEX
     CALL "EAN-DATA" USING CLIENT-STATE WS-ID WS-INDEX WS-VALUE WS-KEY
     MOVE "entity anim a piglin's entry 17 is its baby flag" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-BABY(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 33 TO WS-ID
     MOVE "cod" TO WS-KEY
     CALL "EAN-SPAWN" USING CLIENT-STATE WS-ID WS-KEY WS-X WS-Y WS-Z
     CALL "ENTITY-FIND" USING CLIENT-STATE WS-ID WS-ROW
     MOVE 16 TO WS-INDEX
     MOVE "B" TO WS-KEY
     CALL "EAN-DATA" USING CLIENT-STATE WS-ID WS-INDEX WS-VALUE WS-KEY
     MOVE "entity anim a fish's entry 16 is from_bucket, not a baby flag" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-BABY(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-ENTITY-ANIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EAN-SPAWN.
*> USING CLIENT-STATE, entity id, type key (PIC X(112) as CONTENT-ENTITY-BY-KEY takes it), x y z: Add Entity at rest.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-ADD                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROW-AREA            PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-UUID                PIC X(16) VALUE LOW-VALUES.
 01 WS-V0                  FLOAT-LONG VALUE 0.
 01 WS-V1                  FLOAT-LONG VALUE 0.
 01 WS-V2                  FLOAT-LONG VALUE 0.
 01 WS-A0                  FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   BINARY-LONG.
 01 L-KEY                  PIC X(112).
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-KEY L-X L-Y L-Z.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "CONTENT-ENTITY-BY-KEY" USING L-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ID
     CALL "PB-PUT-UUID" USING PB-BUFFER WS-UUID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-TYPE
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-X
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Y
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Z
     CALL "PB-PUT-LPVEC3" USING PB-BUFFER WS-V0 WS-V1 WS-V2
     CALL "PB-PUT-ANGLE" USING PB-BUFFER WS-A0
     CALL "PB-PUT-ANGLE" USING PB-BUFFER WS-A0
     CALL "PB-PUT-ANGLE" USING PB-BUFFER WS-A0
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     MOVE 0 TO PB-POS
     CALL "ENTITY-PACKET" USING CLIENT-STATE PB-BUFFER WS-ADD
     GOBACK.
 END PROGRAM EAN-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EAN-DATA.
*> USING CLIENT-STATE, entity id, entry index, value, kind ("Y" BYTE, "B" BOOLEAN): Set Entity Data with one entry.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MD-==.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-DATA                BINARY-LONG VALUE 101.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 01 L-KIND                 PIC X(112).
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-INDEX L-VALUE L-KIND.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ID
     INITIALIZE MD-METADATA-ENTRY
     MOVE L-INDEX TO MD-MD-INDEX
     IF L-KIND(1:1) = "Y"
         MOVE MD-MDS-BYTE TO MD-MD-SERIALIZER
     ELSE
         MOVE MD-MDS-BOOLEAN TO MD-MD-SERIALIZER
     END-IF
     MOVE L-VALUE TO MD-MD-INT
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     MOVE MD-MD-END TO MD-MD-INDEX
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     MOVE 0 TO PB-POS
     CALL "ENTITY-PACKET" USING CLIENT-STATE PB-BUFFER WS-DATA
     GOBACK.
 END PROGRAM EAN-DATA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EAN-SWING.
*> USING CLIENT-STATE, entity id, hand, animation type, duration: Swing Animation (0x7B, 123).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-PACKET              BINARY-LONG VALUE 123.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   BINARY-LONG.
 01 L-HAND                 BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-DUR                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-HAND L-TYPE L-DUR.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-HAND
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-TYPE
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-DUR
     MOVE 0 TO PB-POS
     CALL "ENTITY-PACKET" USING CLIENT-STATE PB-BUFFER WS-PACKET
     GOBACK.
 END PROGRAM EAN-SWING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EAN-SUM.
*> USING CLIENT-STATE, row, eye (3 FLOAT-LONG), sum out (BINARY-DOUBLE): the sum of y and z of the row's vertices in thousandths
*> plus x times y (a left- and a right-handed pose mirror in x: the sums of y and z alone cannot tell them apart; every other row hidden for the call).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-USED-TABLE.
    05 WS-USED             PIC 9 OCCURS 16 TIMES.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 01 L-SUM                  BINARY-DOUBLE.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-EYE-TABLE L-SUM.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE EN-USED(WS-I) TO WS-USED(WS-I)
         IF WS-I NOT = L-ROW
             MOVE 0 TO EN-USED(WS-I)
         END-IF
     END-PERFORM
     CALL "ENTITIES-MESH" USING CLIENT-STATE L-EYE-TABLE
     MOVE 0 TO L-SUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-EN-COUNT
         COMPUTE L-SUM = L-SUM + FUNCTION INTEGER(RL-EN-Y(WS-I) * 1000 + 0.5)
             + FUNCTION INTEGER(RL-EN-Z(WS-I) * 1000 + 0.5) + FUNCTION INTEGER(RL-EN-X(WS-I) * RL-EN-Y(WS-I) * 1000 + 0.5)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE WS-USED(WS-I) TO EN-USED(WS-I)
     END-PERFORM
     GOBACK.
 END PROGRAM EAN-SUM.
