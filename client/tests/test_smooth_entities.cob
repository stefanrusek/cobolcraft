*> Implementation test of lane bugsmooth (T60706-T60709; docs/protocol/34-1 section 4 "position x, y, z (interpolated: lerp(partial, old, current) per axis)", head yaw
*> and body yaw by rotLerp, 34-1 section 4.1 pitch): a replica entity is drawn at lerp(partial, the state at the previous client tick, the state now), not at the position
*> of its last packet, so mobs, players, ground items and every other figure move every frame and not 20 times a second (smooth.cob SMOOTH-ENTITIES, render-list.cob).
*> SMOOTH-ENTITIES 1 puts the lerped position, yaw, pitch and head yaw into the used rows for the frame's meshes and 0 puts the tick's own back; at partial 1 or with
*> interpolation off it changes nothing; the figures the render list builds at partial 0.5 are the figures of the entity standing half way.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SMOOTH-ENTITIES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-PATH                PIC X(256).
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-MODE                BINARY-LONG.
 01 WS-MS                  BINARY-LONG.
 01 WS-EVENT               PIC X(24).
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-MAX                 FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-REF-COUNT           BINARY-LONG.
 01 WS-REF.
    05 WS-REF-V            OCCURS 400 TIMES.
       10 WS-REF-X         FLOAT-LONG.
       10 WS-REF-Y         FLOAT-LONG.
       10 WS-REF-Z         FLOAT-LONG.
 01 WS-EDIT                PIC -(4)9.9(4).
 PROCEDURE DIVISION.
*>   The rows themselves.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE 3 TO EN-COUNT
     MOVE 1 TO EN-USED(1) EN-USED(3)
     MOVE 0 TO EN-USED(2)
     MOVE 4.0 TO EN-X(1)
     MOVE 10.0 TO EN-Y(1)
     MOVE -2.0 TO EN-Z(1)
     MOVE 350 TO EN-OYAW(1)
     MOVE 10 TO EN-YAW(1)
     MOVE 20 TO EN-OPITCH(1)
     MOVE -20 TO EN-PITCH(1)
     MOVE 90 TO EN-OHEAD(1)
     MOVE 100 TO EN-HEAD-YAW(1)
     MOVE 3.0 TO EN-OX(1)
     MOVE 8.0 TO EN-OY(1)
     MOVE 2.0 TO EN-OZ(1)
     MOVE 7.5 TO EN-X(2)
     MOVE 1.0 TO EN-OX(2)
     MOVE 1 TO CL-INTERP
     MOVE 0.5 TO CL-PARTIAL
     MOVE 1 TO WS-MODE
     CALL "SMOOTH-ENTITIES" USING CLIENT-STATE WS-MODE
     MOVE "smooth entities: at partial 0.5 a used row is half way between its position at the previous tick and now" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "3.5000/9.0000/0.0000" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     COMPUTE WS-EDIT ROUNDED = EN-X(1)
     STRING FUNCTION TRIM(WS-EDIT) "/" DELIMITED BY SIZE INTO TL-OBSERVED
     COMPUTE WS-EDIT ROUNDED = EN-Y(1)
     STRING FUNCTION TRIM(TL-OBSERVED) FUNCTION TRIM(WS-EDIT) "/" DELIMITED BY SIZE INTO TL-OBSERVED
     COMPUTE WS-EDIT ROUNDED = EN-Z(1)
     STRING FUNCTION TRIM(TL-OBSERVED) FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "smooth entities: the yaw takes the short way round (350 to 10 degrees is 0, not 180), the head yaw (90 to 100) is 95, the pitch (20 to -20) is 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 95 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-HEAD-YAW(1) + EN-PITCH(1) + FUNCTION MOD(EN-YAW(1) + 360, 360)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "smooth entities: a row not in use is not touched" TO TL-CASE
     MOVE 75000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-X(2) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-MODE
     CALL "SMOOTH-ENTITIES" USING CLIENT-STATE WS-MODE
     MOVE "smooth entities: leaving puts the tick's own position (4.0, 10, -2) back" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 4010002 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-X(1) * 1000000 + EN-Y(1) * 1000 - EN-Z(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "smooth entities: ... and the yaw (10), pitch (-20) and head yaw (100)" TO TL-CASE
     MOVE 90 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-YAW(1) + EN-PITCH(1) + EN-HEAD-YAW(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO CL-PARTIAL
     MOVE 1 TO WS-MODE
     CALL "SMOOTH-ENTITIES" USING CLIENT-STATE WS-MODE
     MOVE "smooth entities: at partial 1 nothing changes (the tick's own state is what is drawn)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 40000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-X(1) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO CL-INTERP
     MOVE 0.25 TO CL-PARTIAL
     CALL "SMOOTH-ENTITIES" USING CLIENT-STATE WS-MODE
     MOVE "smooth entities: with interpolation off nothing changes at any partial" TO TL-CASE
     MOVE 40000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-X(1) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The figures of the render list: an operator (the stand-in boxes) at x 4.25 standing, and the same entity at 4.5 that was at 4.0 a tick ago, drawn half way through a tick.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE 1 TO RL-CULL-DISABLE
     MOVE "contract/fixtures/wire/play-s2c-01-add-entity-operator.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE 4.25 TO EN-X(1)
     MOVE 10.0 TO EN-Y(1)
     MOVE 3.5 TO EN-Z(1)
     MOVE 4.25 TO EN-OX(1)
     MOVE 10.0 TO EN-OY(1)
     MOVE 3.5 TO EN-OZ(1)
     CALL "TEST-TICKS" USING CLIENT-STATE WS-ONE
     MOVE 25 TO WS-MS
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENT WS-ZERO WS-MS
     PERFORM SAVE-VERTICES
     MOVE "smooth entities: the standing operator is drawn (reference figure)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-REF-COUNT >= 36
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO CL-INTERP
     MOVE 4.5 TO EN-X(1)
     MOVE 4.0 TO EN-OX(1)
     MOVE 10.0 TO EN-OY(1)
     MOVE 3.5 TO EN-OZ(1)
     MOVE 0 TO WS-MS
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENT WS-ZERO WS-MS
     PERFORM COMPARE-VERTICES
     MOVE "smooth entities: the operator drawn half way through the tick has the vertices of the figure standing at the half way point (largest difference below 0.001)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-N = WS-REF-COUNT AND WS-MAX < 0.001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "smooth entities: after the frame the row holds the tick's own position again (4.5)" TO TL-CASE
     MOVE 45000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-X(1) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.

*> The frame's entity vertices (eye-relative) into WS-REF.
 SAVE-VERTICES.
     MOVE RL-EN-COUNT TO WS-REF-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-REF-COUNT OR WS-I > 400
         MOVE RL-EN-X(WS-I) TO WS-REF-X(WS-I)
         MOVE RL-EN-Y(WS-I) TO WS-REF-Y(WS-I)
         MOVE RL-EN-Z(WS-I) TO WS-REF-Z(WS-I)
     END-PERFORM.

*> The vertex count (WS-N) and the largest difference (WS-MAX) of the frame's entity vertices to the saved ones.
 COMPARE-VERTICES.
     MOVE RL-EN-COUNT TO WS-N
     MOVE 0 TO WS-MAX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N OR WS-I > 400
         COMPUTE WS-D = FUNCTION ABS(RL-EN-X(WS-I) - WS-REF-X(WS-I))
         IF WS-D > WS-MAX
             MOVE WS-D TO WS-MAX
         END-IF
         COMPUTE WS-D = FUNCTION ABS(RL-EN-Y(WS-I) - WS-REF-Y(WS-I))
         IF WS-D > WS-MAX
             MOVE WS-D TO WS-MAX
         END-IF
         COMPUTE WS-D = FUNCTION ABS(RL-EN-Z(WS-I) - WS-REF-Z(WS-I))
         IF WS-D > WS-MAX
             MOVE WS-D TO WS-MAX
         END-IF
     END-PERFORM.
 END PROGRAM TEST-SMOOTH-ENTITIES.
 COPY CLTEST.
