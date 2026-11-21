*> Acceptance test (lane p49a, T14500 series; docs/protocol/18-mob-framework.md section 2.1 Where the tick runs): a mob is ticked only while it is within the
*> ticking range of a player of its dimension (MOB-ACTIVE, MOB-ACTIVE-RANGE 64 blocks, 3D); a dimension with no player ticks its mobs. The document gives no
*> number for the range (recorded in the lane report), so the limit is the implementation's.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-2-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY MOBS.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-PLAYER             BINARY-LONG.
 01 WS-DIM                BINARY-LONG.
 01 WS-KEY                PIC X(112).
 01 WS-COW                BINARY-LONG.
 01 WS-ENTITY-ROW         PIC X(66).
 01 WS-STATUS             BINARY-LONG.
 01 WS-ROW                BINARY-LONG.
 01 WS-ACTIVE             BINARY-LONG.
 01 WS-X                  FLOAT-LONG.
 01 WS-Y                  FLOAT-LONG.
 01 WS-Z                  FLOAT-LONG.
 01 WS-YAW                FLOAT-SHORT VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COW WS-ENTITY-ROW WS-STATUS
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z

*>   63 blocks away along x: inside the range.
     COMPUTE WS-X = PL-X(WS-PLAYER) + 63
     CALL "MOB-SPAWN" USING WS-DIM WS-COW WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "MOB-ACTIVE" USING WS-ROW WS-ACTIVE
     MOVE "acceptance US15 18§2.1 Where the tick runs: a mob 63 blocks from the only player is ticked" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-ACTIVE TO WS-O
     PERFORM CHECK-N
*>   65 blocks away: outside.
     COMPUTE WS-X = PL-X(WS-PLAYER) + 65
     MOVE WS-X TO EN-X(WS-ROW)
     CALL "MOB-ACTIVE" USING WS-ROW WS-ACTIVE
     MOVE "acceptance US15 18§2.1 Where the tick runs: a mob 65 blocks away is not ticked" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-ACTIVE TO WS-O
     PERFORM CHECK-N
*>   The distance is 3D: 40 along x and 60 up is outside, 40 and 40 inside.
     COMPUTE EN-X(WS-ROW) = PL-X(WS-PLAYER) + 40
     COMPUTE EN-Y(WS-ROW) = PL-Y(WS-PLAYER) + 60
     MOVE PL-Z(WS-PLAYER) TO EN-Z(WS-ROW)
     CALL "MOB-ACTIVE" USING WS-ROW WS-ACTIVE
     MOVE "acceptance US15 18§2.1 Where the tick runs: the range is three dimensional (40 and 60 up is out)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-ACTIVE TO WS-O
     PERFORM CHECK-N
     COMPUTE EN-Y(WS-ROW) = PL-Y(WS-PLAYER) + 40
     CALL "MOB-ACTIVE" USING WS-ROW WS-ACTIVE
     MOVE "acceptance US15 18§2.1 Where the tick runs: 40 and 40 up is in" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-ACTIVE TO WS-O
     PERFORM CHECK-N
*>   A player of another dimension does not count.
     COMPUTE EN-X(WS-ROW) = PL-X(WS-PLAYER) + 100
     MOVE PL-Y(WS-PLAYER) TO EN-Y(WS-ROW)
     COMPUTE PL-DIM(WS-PLAYER) = WS-DIM + 1
     CALL "MOB-ACTIVE" USING WS-ROW WS-ACTIVE
     MOVE "acceptance US15 18§2.1 Where the tick runs: with the only player elsewhere the mob is ticked (no player in its dimension)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-ACTIVE TO WS-O
     PERFORM CHECK-N
     MOVE WS-DIM TO PL-DIM(WS-PLAYER)
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-18-2-1.
 COPY CORETEST.
 COPY MOBSPTEST.
