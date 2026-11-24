*> Implementation test (integration batch 15): a thrown arrow flying along -x only faces yaw -90 (ARROW-SPAWN-AS); the spectral arrow kind 4 gives a player Glowing for 200 ticks
*> (STDMOB-ARROW-APPLY, 17 section 3.9); a hoglin whose stored foe is gone drops the foe and does nothing else (MOBVS-TICK, 44-6 section 6).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-B15-COVER-MORE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ARROW               BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG VALUE 0.
 01 WS-VZ                  FLOAT-LONG VALUE 0.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-WALK                BINARY-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-FAMILY              BINARY-LONG VALUE 1.
 01 WS-BASE                BINARY-LONG VALUE 2000.
 01 WS-OWNER               BINARY-LONG VALUE 0.
 01 WS-KIND                BINARY-LONG VALUE 4.
 01 WS-GLOWING             BINARY-LONG VALUE 23.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE PL-X(WS-PLAYER) TO WS-X
     COMPUTE WS-Y = PL-Y(WS-PLAYER) + 5
     MOVE PL-Z(WS-PLAYER) TO WS-Z

*>   An arrow along -x with no z component faces -90 degrees.
     MOVE -1 TO WS-VX
     CALL "ARROW-SPAWN-AS" USING WS-FAMILY WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-BASE WS-OWNER WS-ARROW
     MOVE "test b15 ARROW-SPAWN-AS: an arrow along -x only has yaw -90" TO TL-CASE
     MOVE -90 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-YAW(WS-ARROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ARROW

*>   A spectral arrow's kind (4) lights up the player it hits for 200 ticks.
     CALL "STDMOB-ARROW-APPLY" USING WS-PLAYER WS-KIND
     CALL "EFFECT-LEVEL" USING WS-PLAYER WS-GLOWING WS-LEVEL WS-TICKS
     MOVE "test b15 STDMOB-ARROW-APPLY: a spectral arrow gives Glowing level 1 for 200 ticks" TO TL-CASE
     MOVE 1200 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-LEVEL * 1000 + WS-TICKS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A hoglin whose foe has gone: the foe is dropped and the tick ends.
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:hoglin" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "STDMOB-INDEX" USING WS-TYPE WS-M
     COMPUTE WS-X = PL-X(WS-PLAYER) + 3
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE WS-PLAYER TO EN-FOE(WS-ROW)
     MOVE -5 TO EN-FOE-ID(WS-ROW)
     CALL "MOBVS-TICK" USING WS-ROW WS-M WS-HX WS-HZ WS-WALK
     MOVE "test b15 MOBVS-TICK: a hoglin with a stale foe drops it and does not walk" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-FOE(WS-ROW) * 10 + WS-WALK
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-B15-COVER-MORE.
 COPY CORETEST.
 COPY MOBSPTEST.
