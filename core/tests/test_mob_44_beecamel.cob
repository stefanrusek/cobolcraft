*> Implementation test (US15; docs/protocol/44-residual-mob-questions-4-land-animals.md sections 15 and 2.3): bee pollination timing, camel sitting and dash cooldown.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-44-BEECAMEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==TP-==.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-PLAYER             BINARY-LONG.
 01 WS-DIM                BINARY-LONG.
 01 WS-FX                 FLOAT-LONG.
 01 WS-FY                 FLOAT-LONG.
 01 WS-FZ                 FLOAT-LONG.
 01 WS-YAW                FLOAT-SHORT VALUE 0.
 01 WS-EKEY               PIC X(112).
 01 WS-TYPE               BINARY-LONG.
 01 WS-ENTITY-ROW         PIC X(66).
 01 WS-STATUS             BINARY-LONG.
 01 WS-ROW                BINARY-LONG.
 01 WS-I                  BINARY-LONG.
 01 WS-D2                 FLOAT-LONG.
 01 WS-WALK               BINARY-LONG.
 01 WS-CLEAR              BINARY-LONG.
 01 WS-DX                 FLOAT-LONG.
 01 WS-DY                 FLOAT-LONG.
 01 WS-DZ                 FLOAT-LONG.
 01 WS-STARTED            BINARY-LONG.
 01 WS-ALIVE              BINARY-LONG.
 01 WS-CONT               BINARY-LONG.
 01 WS-J                  BINARY-LONG.
 01 WS-LEN0               BINARY-LONG.
 01 WS-CAPACITY           BINARY-LONG VALUE 256.
 01 WS-BEE                BINARY-LONG.
 01 WS-CAMEL              BINARY-LONG.
 01 WS-FLOWER             BINARY-LONG.
 01 WS-DRAW               BINARY-LONG.
 01 WS-STARTED2           BINARY-LONG.
 01 WS-NOW                BINARY-LONG.
 01 WS-LEASHED            BINARY-LONG.
 01 WS-RIDER              BINARY-LONG.
 01 WS-DONE2              BINARY-LONG.

 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-FX
     MOVE PL-Y(WS-PLAYER) TO WS-FY
     MOVE PL-Z(WS-PLAYER) TO WS-FZ
     MOVE "minecraft:bee" TO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-BEE
     MOVE "minecraft:camel" TO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-CAMEL
     MOVE 1 TO EN-ON-GROUND(WS-CAMEL)
*>   Pollination: no flower, retry cooldown U(20, 60); a flower starts it; 600 ticks end it; more than 400 successful ticks give nectar; the cooldown after is 200.
     MOVE 0 TO WS-FLOWER
     MOVE 0 TO WS-DRAW
     CALL "M44-BEE-POLL-START" USING WS-BEE WS-FLOWER WS-DRAW WS-STARTED2
     MOVE "acceptance US15 44§15 Bee pollination: no flower: not started, the retry cooldown is 20 + draw" TO WS-CASE
     COMPUTE WS-O = WS-STARTED2 * 1000 + EN-BEE-CD(WS-BEE)
     MOVE 20 TO WS-E
     PERFORM CHECK-N
     MOVE 40 TO WS-DRAW
     MOVE 0 TO EN-BEE-CD(WS-BEE)
     CALL "M44-BEE-POLL-START" USING WS-BEE WS-FLOWER WS-DRAW WS-STARTED2
     MOVE "acceptance US15 44§15 Bee pollination: the retry cooldown reaches 60 with the draw 40" TO WS-CASE
     MOVE EN-BEE-CD(WS-BEE) TO WS-O
     MOVE 60 TO WS-E
     PERFORM CHECK-N
     MOVE 1 TO WS-FLOWER
     CALL "M44-BEE-POLL-START" USING WS-BEE WS-FLOWER WS-DRAW WS-STARTED2
     MOVE "acceptance US15 44§15 Bee pollination: with a flower but a running cooldown it does not start" TO WS-CASE
     MOVE WS-STARTED2 TO WS-O
     MOVE 0 TO WS-E
     PERFORM CHECK-N
     MOVE 0 TO EN-BEE-CD(WS-BEE)
     CALL "M44-BEE-POLL-START" USING WS-BEE WS-FLOWER WS-DRAW WS-STARTED2
     MOVE "acceptance US15 44§15 Bee pollination: a flower and no cooldown, no nectar: it starts (1 tick counted)" TO WS-CASE
     COMPUTE WS-O = WS-STARTED2 * 1000 + EN-BEE-POLL(WS-BEE)
     MOVE 1001 TO WS-E
     PERFORM CHECK-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 598
         CALL "M44-BEE-POLL-TICK" USING WS-BEE WS-FLOWER WS-DONE2
     END-PERFORM
     MOVE "acceptance US15 44§15 Bee pollination: after 599 ticks it is still going and carries no nectar" TO WS-CASE
     COMPUTE WS-O = WS-DONE2 * 1000 + EN-BEE-NECTAR(WS-BEE) * 100 + EN-BEE-POLL(WS-BEE) - 599
     MOVE 0 TO WS-E
     PERFORM CHECK-N
     CALL "M44-BEE-POLL-TICK" USING WS-BEE WS-FLOWER WS-DONE2
     MOVE "acceptance US15 44§15 Bee pollination: at 600 it ends: nectar, cooldown 200, counters cleared" TO WS-CASE
     COMPUTE WS-O = WS-DONE2 * 100000 + EN-BEE-NECTAR(WS-BEE) * 10000 + EN-BEE-CD(WS-BEE) * 10 + EN-BEE-POLL(WS-BEE) + EN-BEE-SUCC(WS-BEE)
     MOVE 112000 TO WS-E
     PERFORM CHECK-N
     MOVE 0 TO EN-BEE-NECTAR(WS-BEE) EN-BEE-CD(WS-BEE)
     CALL "M44-BEE-POLL-START" USING WS-BEE WS-FLOWER WS-DRAW WS-STARTED2
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 100
         CALL "M44-BEE-POLL-TICK" USING WS-BEE WS-FLOWER WS-DONE2
     END-PERFORM
     MOVE 0 TO WS-FLOWER
     CALL "M44-BEE-POLL-TICK" USING WS-BEE WS-FLOWER WS-DONE2
     MOVE "acceptance US15 44§15 Bee pollination: the flower lost after 100 ticks stops it without nectar, cooldown 200" TO WS-CASE
     COMPUTE WS-O = WS-DONE2 * 10000 + EN-BEE-NECTAR(WS-BEE) * 1000 + EN-BEE-CD(WS-BEE)
     MOVE 10200 TO WS-E
     PERFORM CHECK-N
     MOVE 1 TO EN-BEE-NECTAR(WS-BEE)
     MOVE 0 TO EN-BEE-CD(WS-BEE)
     MOVE 1 TO WS-FLOWER
     CALL "M44-BEE-POLL-START" USING WS-BEE WS-FLOWER WS-DRAW WS-STARTED2
     MOVE "acceptance US15 44§15 Bee pollination: a bee that carries nectar does not start" TO WS-CASE
     MOVE WS-STARTED2 TO WS-O
     MOVE 0 TO WS-E
     PERFORM CHECK-N
*>   Camel sitting (RandomSitting(20)): pose time at least 400 ticks, on the ground, not leashed, no rider.
     MOVE 1000 TO WS-NOW
     MOVE 601 TO EN-CAMEL-POSE-T(WS-CAMEL)
     MOVE 0 TO WS-LEASHED WS-RIDER
     CALL "M44-CAMEL-SIT" USING WS-CAMEL WS-NOW WS-LEASHED WS-RIDER WS-STARTED2
     MOVE "acceptance US15 44§2.3 Camel sitting: pose time 399 does not change the pose" TO WS-CASE
     COMPUTE WS-O = WS-STARTED2 * 10 + EN-CAMEL-POSE(WS-CAMEL)
     MOVE 0 TO WS-E
     PERFORM CHECK-N
     MOVE 600 TO EN-CAMEL-POSE-T(WS-CAMEL)
     CALL "M44-CAMEL-SIT" USING WS-CAMEL WS-NOW WS-LEASHED WS-RIDER WS-STARTED2
     MOVE "acceptance US15 44§2.3 Camel sitting: pose time 400 sits it down, the pose tick is now" TO WS-CASE
     COMPUTE WS-O = WS-STARTED2 * 100000 + EN-CAMEL-POSE(WS-CAMEL) * 10000 + EN-CAMEL-POSE-T(WS-CAMEL)
     MOVE 111000 TO WS-E
     PERFORM CHECK-N
     MOVE 1 TO WS-LEASHED
     ADD 400 TO WS-NOW
     CALL "M44-CAMEL-SIT" USING WS-CAMEL WS-NOW WS-LEASHED WS-RIDER WS-STARTED2
     MOVE "acceptance US15 44§2.3 Camel sitting: a leashed camel keeps its pose" TO WS-CASE
     COMPUTE WS-O = WS-STARTED2 * 10 + EN-CAMEL-POSE(WS-CAMEL)
     MOVE 1 TO WS-E
     PERFORM CHECK-N
     MOVE 0 TO WS-LEASHED
     MOVE 1 TO WS-RIDER
     CALL "M44-CAMEL-SIT" USING WS-CAMEL WS-NOW WS-LEASHED WS-RIDER WS-STARTED2
     MOVE "acceptance US15 44§2.3 Camel sitting: a camel with a rider keeps its pose" TO WS-CASE
     COMPUTE WS-O = WS-STARTED2 * 10 + EN-CAMEL-POSE(WS-CAMEL)
     MOVE 1 TO WS-E
     PERFORM CHECK-N
     MOVE 0 TO WS-RIDER
     CALL "M44-CAMEL-SIT" USING WS-CAMEL WS-NOW WS-LEASHED WS-RIDER WS-STARTED2
     MOVE "acceptance US15 44§2.3 Camel sitting: the sitting camel stands up after 400 more ticks" TO WS-CASE
     COMPUTE WS-O = WS-STARTED2 * 10 + EN-CAMEL-POSE(WS-CAMEL)
     MOVE 10 TO WS-E
     PERFORM CHECK-N
     MOVE 0 TO EN-ON-GROUND(WS-CAMEL)
     ADD 400 TO WS-NOW
     CALL "M44-CAMEL-SIT" USING WS-CAMEL WS-NOW WS-LEASHED WS-RIDER WS-STARTED2
     MOVE "acceptance US15 44§2.3 Camel sitting: a camel in the air does not change pose" TO WS-CASE
     MOVE WS-STARTED2 TO WS-O
     MOVE 0 TO WS-E
     PERFORM CHECK-N
*>   Dash cooldown 55 ticks.
     MOVE 0 TO EN-CAMEL-DASH(WS-CAMEL)
     CALL "M44-CAMEL-DASH" USING WS-CAMEL WS-STARTED2
     MOVE "acceptance US15 44§2.3 Camel dash: it starts with no cooldown and sets 55" TO WS-CASE
     COMPUTE WS-O = WS-STARTED2 * 1000 + EN-CAMEL-DASH(WS-CAMEL)
     MOVE 1055 TO WS-E
     PERFORM CHECK-N
     CALL "M44-CAMEL-DASH" USING WS-CAMEL WS-STARTED2
     MOVE "acceptance US15 44§2.3 Camel dash: a second dash during the cooldown is refused and the counter runs down" TO WS-CASE
     COMPUTE WS-O = WS-STARTED2 * 1000 + EN-CAMEL-DASH(WS-CAMEL)
     MOVE 54 TO WS-E
     PERFORM CHECK-N
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-44-BEECAMEL.
 COPY CORETEST.
 COPY MOBSPTEST.
