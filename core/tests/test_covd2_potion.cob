*> Splash of a potion with a duration on a mob in range (docs/protocol/20 section 11, 17 section 3.15): the duration is mapped (DUR x intensity + 500) / 1000 and the
*> effect is added to the mob only when that is above 20 ticks.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVD2-POTION.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-VTYPE               BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-POTION              BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-OWNER               BINARY-LONG VALUE 0.
 01 WS-SPEED-ID            BINARY-LONG VALUE 9.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-VTYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-X = PL-X(WS-PLAYER) + 40
     CALL "MOB-SPAWN" USING WS-DIM WS-VTYPE WS-X WS-Y WS-Z WS-YAW WS-V
     MOVE 3 TO WS-POTION
*>   Impact on the mob: intensity 1, the full 900 ticks.
     MOVE EN-X(WS-V) TO WS-X
     CALL "WITCH-POTION-SPLASH" USING WS-DIM WS-X WS-Y WS-Z WS-POTION WS-OWNER
     CALL "MEF-LEVEL" USING EN-ID(WS-V) WS-SPEED-ID WS-LEVEL WS-LEFT
     MOVE "acceptance US15 17§3.15 a duration potion at intensity 1 gives 900 ticks" TO TL-CASE
     MOVE 900 TO TL-EXPECTED-N
     MOVE WS-LEFT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MEF-REMOVE" USING EN-ID(WS-V) WS-SPEED-ID
*>   Impact 3.95 blocks from the box: intensity 0.0125, 900 x 0.012 = 11 ticks, not above 20: nothing is added.
     COMPUTE WS-X = EN-X(WS-V) - 4.25
     CALL "WITCH-POTION-SPLASH" USING WS-DIM WS-X WS-Y WS-Z WS-POTION WS-OWNER
     CALL "MEF-LEVEL" USING EN-ID(WS-V) WS-SPEED-ID WS-LEVEL WS-LEFT
     MOVE "acceptance US15 17§3.15 a mapped duration of 20 ticks or less adds nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LEVEL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-COVD2-POTION.

 COPY CORETEST.
 COPY MOBSPTEST.
