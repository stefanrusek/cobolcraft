*> spike (throwaway, plan 003): what the client of today (client/src/physics.cob) does per tick on a flat floor, to
*> check the Plan-Phase Handoff of spec.md: walk on ordinary ground, cross onto ice (the floor's friction is changed
*> under the walking player), release the key; then release on ordinary ground. Prints the horizontal distance of
*> every tick in blocks. Linked with the client library and the CLTEST harness (see spike_move_current.out.txt).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPIKE-MOVE-CURRENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY CTBSHAPE.
 01 WS-SERVER              BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-DOWN                BINARY-LONG VALUE CC-EV-KEY-DOWN.
 01 WS-UP                  BINARY-LONG VALUE CC-EV-KEY-UP.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-LABEL               PIC X(24).
 01 WS-ED                  PIC -(4)9.9(6).
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE CC-KEY-W TO WS-KEY
     MOVE 0 TO PL-YAW
     MOVE "ground, W held" TO WS-LABEL
     MOVE PL-Z TO WS-Z0
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     PERFORM DO-PRINT
     PERFORM 5 TIMES
         PERFORM DO-TICK
     END-PERFORM
     MOVE 980 TO BSH-SLIP(3)
     MOVE "ice, W held" TO WS-LABEL
     PERFORM 12 TIMES
         PERFORM DO-TICK
     END-PERFORM
     MOVE "ice, W released" TO WS-LABEL
     MOVE PL-Z TO WS-Z0
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP
     PERFORM DO-PRINT
     PERFORM 5 TIMES
         PERFORM DO-TICK
     END-PERFORM
     MOVE 0 TO BSH-SLIP(3)
     PERFORM 60 TIMES
         CALL "TEST-TICKS" USING CLIENT-STATE WS-ONE
     END-PERFORM
     MOVE "ground, W held" TO WS-LABEL
     MOVE PL-Z TO WS-Z0
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     PERFORM DO-PRINT
     PERFORM 3 TIMES
         PERFORM DO-TICK
     END-PERFORM
     MOVE "ground, W released" TO WS-LABEL
     MOVE PL-Z TO WS-Z0
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP
     PERFORM DO-PRINT
     PERFORM 3 TIMES
         PERFORM DO-TICK
     END-PERFORM
     STOP RUN.

 DO-TICK.
     MOVE PL-Z TO WS-Z0
     CALL "TEST-TICKS" USING CLIENT-STATE WS-ONE
     PERFORM DO-PRINT.

 DO-PRINT.
     COMPUTE WS-ED ROUNDED = PL-Z - WS-Z0
     DISPLAY FUNCTION TRIM(WS-LABEL) ": " FUNCTION TRIM(WS-ED).
 END PROGRAM SPIKE-MOVE-CURRENT.
 COPY CLTEST.
