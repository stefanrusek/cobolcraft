*> Acceptance test, villager gossip and the reputation price (docs/protocol/19 sections 22.4, 22.5 and 25.2; lane 002-lane-mobsb2, T7102): the reputation of a player
*> with a villager is the weighted sum of the stored gossip; the special price of every offer is -floor(R x multiplier) when the window opens; a hit by the player stores
*> minor_negative 25, a trade stores trading 2 (cap 25); a day later each value loses its decay per day.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-VILLAGER-GOSSIP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY VILSTATE.
 COPY RULES.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-VROW                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-PICK                BINARY-LONG.
 01 WS-USED                BINARY-LONG.
 01 WS-LIB                 PIC X(16) VALUE "librarian".
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-REP                 BINARY-LONG.
 01 WS-VID                 BINARY-LONG.
 01 WS-PID                 BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-AMT                 BINARY-LONG.
 01 WS-WANT                PIC X(32).
 01 WS-EXTRA               PIC X(32).
 01 WS-GIVE                PIC X(32).
 01 WS-WC                  BINARY-LONG.
 01 WS-EC                  BINARY-LONG.
 01 WS-GC                  BINARY-LONG.
 01 WS-MU                  BINARY-LONG.
 01 WS-XPV                 BINARY-LONG.
 01 WS-MULT                BINARY-LONG.
 01 WS-MASK                BINARY-LONG.
 01 WS-MOD                 BINARY-LONG.
 01 WS-EXPECT              BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-E1                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     CALL "TEST-STANDARD-TABLES"
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE "villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-ROW) TO WS-X
     MOVE PL-Y(WS-ROW) TO WS-Y
     MOVE PL-Z(WS-ROW) TO WS-Z
     CALL "MOB-SPAWN" USING PL-DIM(WS-ROW) WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-VROW
     MOVE EN-ID(WS-VROW) TO WS-VID
     MOVE PL-ENTITY-ID(WS-ROW) TO WS-PID
     CALL "VL-FIND" USING WS-VID WS-ONE WS-SLOT
     MOVE "librarian" TO VL-PROF(WS-SLOT)
     CALL "VIL-TRADE-SET" USING WS-LIB WS-ONE WS-FIRST WS-N WS-PICK
     MOVE 1 TO VL-O-N(WS-SLOT) VL-BUILT(WS-SLOT)
     MOVE WS-FIRST TO VL-O-ROW(WS-SLOT, 1)
     MOVE 0 TO VL-O-USES(WS-SLOT, 1) VL-O-DEMAND(WS-SLOT, 1) VL-O-SPECIAL(WS-SLOT, 1) VL-O-EXTRA(WS-SLOT, 1)
     CALL "VIL-TRADE-ROW" USING VL-O-ROW(WS-SLOT, 1) WS-WANT WS-WC WS-EXTRA WS-EC WS-GIVE WS-GC WS-MU WS-XPV WS-MULT WS-MASK WS-MOD
     MOVE "T" TO TL-MODE
     CALL "VG-REP" USING WS-VID WS-PID WS-REP
     MOVE "acceptance US15 19§22.5 no gossip: reputation 0" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     PERFORM CHECK-REP
*>   Doc 25.2 step 3: trading 20, major_positive 6, minor_negative 4 give R = 46.
     MOVE 5 TO WS-T
     MOVE 20 TO WS-AMT
     CALL "VG-ADD" USING WS-VID WS-PID WS-T WS-AMT
     MOVE 4 TO WS-T
     MOVE 6 TO WS-AMT
     CALL "VG-ADD" USING WS-VID WS-PID WS-T WS-AMT
     MOVE 2 TO WS-T
     MOVE 4 TO WS-AMT
     CALL "VG-ADD" USING WS-VID WS-PID WS-T WS-AMT
     CALL "VG-REP" USING WS-VID WS-PID WS-REP
     MOVE "acceptance US15 19§25.2 trading 20, major_positive 6, minor_negative 4: R = 46" TO TL-CASE
     MOVE "46" TO TL-EXPECTED
     PERFORM CHECK-REP
*>   Opening the window refreshes the special price: -floor(46 x multiplier).
     CALL "MERCHANT-INTERACT" USING WS-ROW WS-VROW WS-USED
     COMPUTE WS-EXPECT = 0 - FUNCTION INTEGER(46 * WS-MULT / 1000)
     MOVE "acceptance US15 19§22.4 the special price of the offer is -floor(R x multiplier) once the window opened" TO TL-CASE
     MOVE WS-EXPECT TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO TL-EXPECTED
     MOVE VL-O-SPECIAL(WS-SLOT, 1) TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     PERFORM CHECK
*>   A hit by the player: minor_negative + 25 (4 -> 29), R = 20 + 30 - 29 = 21.
     CALL "HEALTH-MOB-DAMAGE" USING WS-VROW WS-ONE CAUSE-PLAYER WS-ROW
     CALL "VG-REP" USING WS-VID WS-PID WS-REP
     MOVE "acceptance US15 19§22.5 hurting the villager stores minor_negative 25: R = 21" TO TL-CASE
     MOVE "21" TO TL-EXPECTED
     PERFORM CHECK-REP
*>   A trade: trading + 2 (20 -> 22), R = 23.
     MOVE 2 TO WS-T
     CALL "VG-EVENT" USING WS-VID WS-PID WS-T
     CALL "VG-REP" USING WS-VID WS-PID WS-REP
     MOVE "acceptance US15 19§22.5 a trade stores trading 2: R = 23" TO TL-CASE
     MOVE "23" TO TL-EXPECTED
     PERFORM CHECK-REP
*>   The trading value is capped at 25.
     PERFORM 5 TIMES
         CALL "VG-EVENT" USING WS-VID WS-PID WS-T
     END-PERFORM
     CALL "VG-REP" USING WS-VID WS-PID WS-REP
     MOVE "acceptance US15 19§22.5 trading stays at its cap of 25: R = 26" TO TL-CASE
     MOVE "26" TO TL-EXPECTED
     PERFORM CHECK-REP
*>   Decay a day later: trading 25 -> 23, minor_negative 29 -> 9, major_positive stays: R = 23 + 30 - 9 = 44.
     MOVE 1000 TO CW-TICKS
     CALL "VL-TICK" USING WS-SLOT
     MOVE 25000 TO CW-TICKS
     CALL "VL-TICK" USING WS-SLOT
     CALL "VG-REP" USING WS-VID WS-PID WS-REP
     MOVE "acceptance US15 19§22.5 a day later the values decay: R = 44" TO TL-CASE
     MOVE "44" TO TL-EXPECTED
     PERFORM CHECK-REP
*>   Removing the villager forgets its gossip.
     CALL "VL-REMOVE" USING WS-VID
     CALL "VG-REP" USING WS-VID WS-PID WS-REP
     MOVE "acceptance US15 19§22.5 a removed villager keeps no gossip" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     PERFORM CHECK-REP
     STOP RUN.

 CHECK-REP.
     MOVE WS-REP TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     PERFORM CHECK.

 CHECK.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US15-VILLAGER-GOSSIP.
 COPY CORETEST.
