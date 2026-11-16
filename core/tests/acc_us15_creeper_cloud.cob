 *> Acceptance test, the creeper (docs/protocol/20 section 6.1; lane 002-lane-mobsb7, T9515): a creeper with active mob effects leaves a lingering area effect cloud when it explodes (radius 2.5, radius
*> on use -0.5, wait 10, duration 300, duration scale 0.25, radius per tick -radius / duration, copies of the effects); one without effects leaves none; a charged creeper (hit by lightning) explodes
*> with the double power.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-CREEPER-CLOUD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY PROJSTATE.
 COPY STDMOBS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-CTYPE               BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-EFFECT              BINARY-LONG VALUE 1.
 01 WS-AMP                 BINARY-LONG VALUE 1.
 01 WS-DUR                 BINARY-LONG VALUE 600.
 01 WS-FLAGS               BINARY-LONG VALUE 6.
 01 WS-STOP                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 2 TO BW-DIFFICULTY
     MOVE "minecraft:creeper" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-CTYPE WS-ENTITY-ROW WS-STATUS
     CALL "STDMOB-INDEX" USING WS-CTYPE WS-M
     COMPUTE WS-X = PL-X(WS-PLAYER) + 30
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-CTYPE WS-X WS-Y WS-Z WS-YAW WS-C
*>   No effects: no cloud.
     CALL "CREEPER-CLOUD" USING WS-C
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         IF PJ-ENT(WS-I) > 0 AND PJ-KIND(WS-I) = 3
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§6.1 a creeper without effects leaves no cloud" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   With Speed II for 600 ticks: a cloud with that effect.
     CALL "MEF-ADD" USING EN-ID(WS-C) WS-EFFECT WS-AMP WS-DUR WS-FLAGS
     CALL "CREEPER-CLOUD" USING WS-C
     MOVE 0 TO WS-COUNT WS-SLOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         IF PJ-ENT(WS-I) > 0 AND PJ-KIND(WS-I) = 3
             ADD 1 TO WS-COUNT
             MOVE WS-I TO WS-SLOT
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§6.1 a creeper with an active effect leaves one cloud" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§6.1 radius 2.5, duration 300, wait 10 (thousandths of the radius)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 2500 * 1000000 + 300 * 1000 + 10
     COMPUTE TL-OBSERVED-N ROUNDED = PJ-RADIUS(WS-SLOT) * 1000 * 1000000 + PJ-DUR(WS-SLOT) * 1000 + PJ-WAIT(WS-SLOT)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§6.1 radius on use -0.5 and per tick -2.5 / 300 (millionths), scale 0.25" TO TL-CASE
     COMPUTE TL-EXPECTED-N = -500000 * 1000 - 8333 + 250
     COMPUTE TL-OBSERVED-N ROUNDED = PJ-ROU(WS-SLOT) * 1000000 * 1000 + PJ-RPT(WS-SLOT) * 1000000 + PJ-SCALE(WS-SLOT)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§6.1 the cloud carries a copy of the effect" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1000 + 1 * 100 + 1
     COMPUTE TL-OBSERVED-N = PJ-FX-ID(WS-SLOT, 1) * 1000 + PJ-FX-AMP(WS-SLOT, 1) * 100 + PJ-FXN(WS-SLOT)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The explosion makes it too: a creeper at full swell with an effect.
     MOVE 0 TO PJ-ENT(WS-SLOT)
     MOVE SM-FUSE(WS-M) TO EN-SWELL(WS-C)
     MOVE 1 TO EN-IGNITED(WS-C)
     CALL "STDMOB-SWELL" USING WS-C WS-M WS-STOP
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         IF PJ-ENT(WS-I) > 0 AND PJ-KIND(WS-I) = 3
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§6.1 the explosion of a creeper with an effect leaves the cloud" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US15-CREEPER-CLOUD.

 COPY CORETEST.
 COPY MOBSPTEST.
