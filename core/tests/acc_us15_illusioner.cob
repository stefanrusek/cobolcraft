*> Acceptance test, the illusioner's spells (docs/protocol/20 section 13.5; lane 002-lane-mobsb5, T8912): mirror (Invisibility 1200 on itself, casting 20, interval 340) when it lacks
*> Invisibility, blindness (Blindness 400 on the target, casting 20, interval 180) on a target it did not blind last, only above Normal difficulty.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-ILLUSIONER.
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
 01 WS-ITYPE               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-CAST                BINARY-LONG.
 01 WS-INTERVAL            BINARY-LONG.
 01 WS-WARM                BINARY-LONG.
 01 WS-SPELL               BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-INVIS               BINARY-LONG VALUE 13.
 01 WS-BLIND               BINARY-LONG VALUE 14.
 01 WS-CAST-FLAG           BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:illusioner" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ITYPE WS-ENTITY-ROW WS-STATUS
     MOVE 4 TO WS-SPELL
     CALL "EVK-SPELL-TIMES" USING WS-SPELL WS-CAST WS-INTERVAL WS-WARM
     MOVE "acceptance US15 20§13.5 mirror casts 20 with interval 340" TO TL-CASE
     MOVE 20340 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-CAST * 1000 + WS-INTERVAL
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-SPELL
     CALL "EVK-SPELL-TIMES" USING WS-SPELL WS-CAST WS-INTERVAL WS-WARM
     MOVE "acceptance US15 20§13.5 blindness casts 20 with interval 180" TO TL-CASE
     MOVE 20180 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-CAST * 1000 + WS-INTERVAL
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     ADD 8 TO WS-X
     MOVE 3 TO BW-DIFFICULTY
     MOVE 100 TO CW-TICKS
     CALL "MOB-SPAWN" USING WS-DIM WS-ITYPE WS-X WS-Y WS-Z WS-YAW WS-I
     MOVE WS-PLAYER TO EN-TARGET(WS-I)
*>   Step 1 picks the mirror (it lacks Invisibility); 20 warm-up ticks later it is invisible.
     CALL "ILLUSIONER-STEP" USING WS-I
     CALL "EVK-FIND" USING EN-ID(WS-I) WS-NO WS-SLOT
     MOVE "acceptance US15 20§13.5 without Invisibility it casts the mirror" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE EV-SPELL(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM 20 TIMES
         CALL "ILLUSIONER-STEP" USING WS-I
     END-PERFORM
     CALL "MEF-LEVEL" USING EN-ID(WS-I) WS-INVIS WS-LEVEL WS-LEFT
     MOVE "acceptance US15 20§13.5 Invisibility 1200 on itself" TO TL-CASE
     MOVE 1200 TO TL-EXPECTED-N
     MOVE WS-LEFT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Invisible: the next spell is blindness once the interval (340) is over; on Hard.
     PERFORM 25 TIMES
         CALL "ILLUSIONER-STEP" USING WS-I
     END-PERFORM
     MOVE "acceptance US15 20§13.5 within the interval nothing new starts" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EV-SPELL(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 440 TO CW-TICKS
     CALL "ILLUSIONER-STEP" USING WS-I
     MOVE "acceptance US15 20§13.5 then blindness is cast on a new target" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE EV-SPELL(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM 20 TIMES
         CALL "ILLUSIONER-STEP" USING WS-I
     END-PERFORM
     CALL "EFFECT-LEVEL" USING WS-PLAYER WS-BLIND WS-LEVEL WS-LEFT
     MOVE "acceptance US15 20§13.5 the player is blind for 400 ticks" TO TL-CASE
     MOVE 400 TO TL-EXPECTED-N
     MOVE WS-LEFT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The same target is not blinded again.
     PERFORM 30 TIMES
         CALL "ILLUSIONER-STEP" USING WS-I
     END-PERFORM
     MOVE 900 TO CW-TICKS
     CALL "ILLUSIONER-STEP" USING WS-I
     MOVE "acceptance US15 20§13.5 the last blinded target is skipped" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EV-SPELL(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   On Normal no blindness: a fresh illusioner that is already invisible casts nothing.
     MOVE 2 TO BW-DIFFICULTY
     MOVE 0 TO EV-LAST(WS-SLOT)
     CALL "ILLUSIONER-STEP" USING WS-I
     MOVE "acceptance US15 20§13.5 Normal difficulty does not exceed 2.0: no blindness" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EV-SPELL(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ILLUSIONER-IS-CASTING" USING WS-I WS-CAST-FLAG
     MOVE "acceptance US15 20§13.5 idle: not casting" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-CAST-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US15-ILLUSIONER.

 COPY CORETEST.
 COPY MOBSPTEST.
