*> Implementation test (lane covB; docs/protocol/20 sections 13.3 and 13.4): the evoker's less common states: the spell times of an unknown spell, the casting flag, a warm-up that ends
*> without a target, the vex summon at the end of its warm-up, the fang line along the axes and from above, a spell with no performance, a spell chosen from idle (vexes or fangs), the
*> fang biting a mob, rows that are no vex, wololo with mob griefing off and the full spell table.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVB-EVOKER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY EVKSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ETYPE               BINARY-LONG.
 01 WS-COW-T               BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-COW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-CAST                BINARY-LONG.
 01 WS-INTERVAL            BINARY-LONG.
 01 WS-WARM                BINARY-LONG.
 01 WS-SPELL               BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-FX0                 BINARY-LONG.
 01 WS-FZ0                 BINARY-LONG.
 01 WS-FYI                 BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 45.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-SEEN1               BINARY-LONG.
 01 WS-SEEN2               BINARY-LONG.
 01 WS-HEALTH0             BINARY-LONG.
 01 WS-SHEEP               BINARY-LONG VALUE 7.
 01 WS-RULE-NAME           PIC X(40) VALUE "mob_griefing".
 01 WS-RULE-INDEX          BINARY-LONG.
 01 WS-RULE-VALUE          BINARY-DOUBLE.
 01 WS-RULE-OLD            BINARY-DOUBLE.
 01 WS-SX                  FLOAT-LONG.
 01 WS-CREATE              BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:evoker" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ETYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COW-T WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-FX0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 22
     COMPUTE WS-FZ0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 22
     COMPUTE WS-FYI = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX0 WS-FZ0 WS-FSIZE WS-FYI WS-FKIND
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     ADD 10 TO WS-X
     CALL "MOB-SPAWN" USING WS-DIM WS-ETYPE WS-X WS-Y WS-Z WS-YAW WS-E
     COMPUTE WS-X = PL-X(WS-PLAYER) - 10
     CALL "MOB-SPAWN" USING WS-DIM WS-COW-T WS-X WS-Y WS-Z WS-YAW WS-COW
     MOVE WS-PLAYER TO EN-TARGET(WS-E)
     MOVE 9 TO WS-SPELL
     CALL "EVK-SPELL-TIMES" USING WS-SPELL WS-CAST WS-INTERVAL WS-WARM
     MOVE "covB 20 13.3 an unknown spell has no times" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-CAST + WS-INTERVAL + WS-WARM
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Casting flag: only while a spell runs.
     CALL "EVK-IS-CASTING" USING WS-E WS-FLAG
     MOVE "covB 20 13.3 an evoker with no spell is not casting" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-SPELL
     CALL "EVK-BEGIN" USING WS-E WS-SPELL
     CALL "EVK-IS-CASTING" USING WS-E WS-FLAG
     MOVE "covB 20 13.3 an evoker in a spell is casting" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "EVK-FIND" USING EN-ID(WS-E) WS-N WS-SLOT
*>   The warm-up ends at once when the target is gone.
     MOVE 0 TO EN-TARGET(WS-E)
     CALL "EVK-STEP" USING WS-E
     MOVE "covB 20 13.3 a spell whose target is gone loses its warm-up" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EV-WARM(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-PLAYER TO EN-TARGET(WS-E)
*>   Summon: after the 20 tick warm-up three vexes appear.
     MOVE 0 TO EV-SPELL(WS-SLOT) EV-CAST(WS-SLOT)
     MOVE 1 TO WS-SPELL
     CALL "EVK-BEGIN" USING WS-E WS-SPELL
     PERFORM 20 TIMES
         CALL "EVK-STEP" USING WS-E
     END-PERFORM
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > VX-MAX
         IF VX-ID(WS-I) > 0 AND VX-OWNER(WS-I) = EN-ID(WS-E)
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "covB 20 13.3 the summon spell makes three vexes at the end of its warm-up" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Fangs from an evoker straight south and north of the target (no x difference), and from above it.
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 3
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > FG-MAX
             MOVE 0 TO FG-USED(WS-I)
         END-PERFORM
         MOVE PL-X(WS-PLAYER) TO EN-X(WS-E)
         MOVE PL-Y(WS-PLAYER) TO EN-Y(WS-E)
         EVALUATE WS-J
             WHEN 1
                 COMPUTE EN-Z(WS-E) = PL-Z(WS-PLAYER) - 8
             WHEN 2
                 COMPUTE EN-Z(WS-E) = PL-Z(WS-PLAYER) + 8
             WHEN OTHER
                 COMPUTE EN-Z(WS-E) = PL-Z(WS-PLAYER) + 8
                 COMPUTE EN-Y(WS-E) = PL-Y(WS-PLAYER) + 3
         END-EVALUATE
         MOVE 0 TO EV-SPELL(WS-SLOT) EV-CAST(WS-SLOT)
         MOVE 2 TO WS-SPELL
         CALL "EVK-BEGIN" USING WS-E WS-SPELL
         PERFORM 20 TIMES
             CALL "EVK-STEP" USING WS-E
         END-PERFORM
         MOVE 0 TO WS-N
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > FG-MAX
             ADD FG-USED(WS-I) TO WS-N
         END-PERFORM
         MOVE "covB 20 13.3 the fang line is made along the axis of the target" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         IF WS-N > 0
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   A spell that has nothing to perform (disappear, 4): the warm-up ends and the spell goes on without effect.
     MOVE PL-X(WS-PLAYER) TO WS-SX
     COMPUTE EN-X(WS-E) = WS-SX + 10
     MOVE PL-Y(WS-PLAYER) TO EN-Y(WS-E)
     MOVE PL-Z(WS-PLAYER) TO EN-Z(WS-E)
     MOVE 4 TO EV-SPELL(WS-SLOT)
     MOVE 1 TO EV-WARM(WS-SLOT)
     MOVE 5 TO EV-CAST(WS-SLOT)
     CALL "EVK-STEP" USING WS-E
     MOVE "covB 20 13.3 a spell with no evoker performance ends its warm-up and counts its casting down" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EV-WARM(WS-SLOT) * 10 + EV-CAST(WS-SLOT)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Idle with a target and the interval over: a summon when few vexes are about, else fangs; both appear over the draws.
     MOVE 0 TO WS-SEEN1 WS-SEEN2
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 80 OR (WS-SEEN1 > 0 AND WS-SEEN2 > 0)
         MOVE 0 TO EV-SPELL(WS-SLOT) EV-CAST(WS-SLOT) EV-WARM(WS-SLOT) EV-NEXT(WS-SLOT)
         CALL "EVK-STEP" USING WS-E
         IF EV-SPELL(WS-SLOT) = 1
             ADD 1 TO WS-SEEN1
         END-IF
         IF EV-SPELL(WS-SLOT) = 2
             ADD 1 TO WS-SEEN2
         END-IF
     END-PERFORM
     MOVE "covB 20 13.3 an idle evoker with a target begins a summon when few vexes are about" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SEEN1 > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "covB 20 13.3 and begins the fangs when the draw holds the summon back" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SEEN2 > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A fang bites a mob standing in it after 8 ticks.
     MOVE EN-HEALTH(WS-COW) TO WS-HEALTH0
     MOVE EN-X(WS-COW) TO WS-X
     MOVE EN-Y(WS-COW) TO WS-Y
     MOVE EN-Z(WS-COW) TO WS-Z
     MOVE 0 TO WS-WARM
     CALL "EVK-FANG-ADD" USING WS-DIM WS-X WS-Y WS-Z WS-WARM EN-ID(WS-E)
     PERFORM 9 TIMES
         CALL "EVK-FANG-TICK"
     END-PERFORM
     MOVE "covB 20 13.3 a fang bites a mob in its box" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-HEALTH(WS-COW) < WS-HEALTH0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Rows without a vex record do not step or touch.
     MOVE EN-HEALTH(WS-COW) TO WS-HEALTH0
     CALL "VEX-STEP" USING WS-COW
     CALL "VEX-CONTACT" USING WS-COW
     MOVE "covB 20 13.4 vex steps ignore a row that is no vex" TO TL-CASE
     MOVE WS-HEALTH0 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-COW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Wololo with mob griefing off picks no sheep.
     CALL "BR-RULE-FIND" USING WS-RULE-NAME WS-RULE-INDEX
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE-OLD
     MOVE 0 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     CALL "EVK-WOLOLO-PICK" USING WS-E WS-SHEEP
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-OLD
     MOVE "covB 20 13.3 with mob griefing off wololo picks no sheep" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SHEEP TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The illusioner's warm-up ends at once when its target is gone.
     MOVE 4 TO EV-SPELL(WS-SLOT)
     MOVE 5 TO EV-WARM(WS-SLOT)
     MOVE 5 TO EV-CAST(WS-SLOT)
     MOVE 0 TO EN-TARGET(WS-E)
     CALL "ILLUSIONER-STEP" USING WS-E
     MOVE "covB 20 13.4 an illusioner spell whose target is gone loses its warm-up" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EV-WARM(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A full spell table: the steps of an evoker without a slot do nothing.
     MOVE 1 TO WS-N
     MOVE 0 TO WS-I
     PERFORM UNTIL WS-N = 0
         ADD 1 TO WS-I
         COMPUTE WS-J = 800000 + WS-I
         CALL "EVK-FIND" USING WS-J WS-CREATE WS-N
     END-PERFORM
     MOVE EN-HEALTH(WS-COW) TO WS-HEALTH0
     CALL "EVK-STEP" USING WS-COW
     CALL "ILLUSIONER-STEP" USING WS-COW
     MOVE "covB 20 13.3 with the spell table full a new evoker is not stepped" TO TL-CASE
     MOVE WS-HEALTH0 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-COW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-COVB-EVOKER.
 COPY CORETEST.
 COPY MOBSPTEST.
