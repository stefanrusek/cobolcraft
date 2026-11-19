*> Acceptance test (002-lane-bugtradestop; operator report try16: "villagers never stop moving, they are supposed to stop moving and look at you when you try to trade with them"):
*> a villager with the merchant window of a player open (docs/protocol 44 part 3 section 3.4 LookAndFollowTradingPlayerSink, 44 x2 section 10.3 TradeWithPlayerGoal: start stops the
*> navigation, the goal holds the move flag; LookAtTradingPlayerGoal; 40 section 2.9 stillValid) stands still and faces the trading player (yaw, head yaw, pitch to the player's eyes),
*> also when it was in the middle of a walk, and it walks on when the window is closed (a Container Close, the player walking away or leaving). With two players it stays for the trader.
*> Everything goes through the real Interact packet (0x1A) and Container Close (0x12), the ticks are CORE-TICK.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGTRADESTOP-LOOK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CMENU.
 COPY COREAPI.
 COPY VILSTATE.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-CONN2               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROW2                BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-V1                  BINARY-LONG.
 01 WS-V2                  BINARY-LONG.
 01 WS-TTYPE               BINARY-LONG.
 01 WS-S1                  BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-HAND0               BINARY-LONG VALUE 0.
 01 WS-SNEAK0              BINARY-LONG VALUE 0.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-N                   BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-MX                  BINARY-DOUBLE.
 01 WS-MY                  BINARY-DOUBLE.
 01 WS-MZ                  BINARY-DOUBLE.
 01 WS-E1                  PIC -(11)9.
 01 WS-E2                  PIC -(11)9.
 01 WS-SNAP                PIC X(40).
 01 WS-DEG                 BINARY-DOUBLE.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-WANT                FLOAT-LONG.
 01 WS-GOT                 BINARY-DOUBLE.
 01 WS-WANT10              BINARY-DOUBLE.
 01 WS-DIFF                BINARY-DOUBLE.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 3000 TO CW-TIME
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE "Bobby" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN2
     CALL "TEST-STANDARD-TABLES"
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE CN-PLAYER(WS-CONN2) TO WS-ROW2
     MOVE PL-DIM(WS-ROW) TO WS-DIM
     MOVE "villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-ROW) TO WS-PX
     MOVE PL-Z(WS-ROW) TO WS-PZ
*>   Bobby stands 3 blocks east of Alice; the villager is 1 block east and 1 south of Alice (so the direction to Alice is -X, -Z: yaw 225 = -135).
     COMPUTE PL-X(WS-ROW2) = WS-PX + 3
     MOVE WS-PZ TO PL-Z(WS-ROW2)
     MOVE PL-Y(WS-ROW) TO PL-Y(WS-ROW2)
     COMPUTE WS-X = WS-PX + 1
     MOVE PL-Y(WS-ROW) TO WS-Y
     COMPUTE WS-Z = WS-PZ + 1
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-V1
     CALL "VL-FIND" USING EN-ID(WS-V1) WS-NO WS-S1
*>   A farmer with experience (the brain resets a profession with no job site, no experience and level 1).
     MOVE "farmer" TO VL-PROF(WS-S1)
     MOVE 1 TO VL-XP(WS-S1)
     MOVE "T" TO TL-MODE
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     CALL "TEST-DRAIN-IDS" USING WS-CONN2 WS-IDS
*>   Alice is one block above the floor of the villager (her eyes are 1 block above the villager's).
     COMPUTE PL-Y(WS-ROW) = PL-Y(WS-ROW) + 1
*>   The villager is in the middle of a walk, 20 blocks east; three ticks of it, then Alice right clicks it.
     COMPUTE EN-DEST-X(WS-V1) = EN-X(WS-V1) + 20
     MOVE EN-Z(WS-V1) TO EN-DEST-Z(WS-V1)
     MOVE 200 TO EN-COOLDOWN(WS-V1)
     MOVE 0 TO EN-PATH-TICKS(WS-V1) EN-WAY-X(WS-V1) EN-WAY-Z(WS-V1)
     PERFORM STEP-TICKS-3
     CALL "TEST-INTERACT" USING WS-CONN EN-ID(WS-V1) WS-HAND0 WS-SNEAK0
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "acceptance bugtradestop the window of the farmer is open for Alice" TO TL-CASE
     MOVE "29" TO TL-EXPECTED
     MOVE MN-CFAMILY(WS-ROW) TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     PERFORM CHECK
     PERFORM SNAPSHOT
     MOVE WS-SNAP TO WS-KEY
     PERFORM STEP-TICKS-40
     PERFORM SNAPSHOT
     MOVE "acceptance bugtradestop a villager mid-walk stands still 40 ticks while Alice trades (x z in mm)" TO TL-CASE
     MOVE WS-KEY TO TL-EXPECTED
     MOVE WS-SNAP TO TL-OBSERVED
     PERFORM CHECK
*>   It faces Alice (the walk of the first ticks took it a little east of where it was spawned). The expectations come from the final positions with another formula: Alice is
*>   west and north of the villager (dx < 0, dz < 0), the protocol yaw (0 faces +Z, 90 faces -X, 180 faces -Z) is 90 + atan(|dz| / |dx|) degrees; the pitch to her eyes, 1 block
*>   above the villager's, is -atan(1 / horizontal distance) = -(90 - atan(horizontal distance / 1)) degrees.
     COMPUTE WS-DX = PL-X(WS-ROW) - EN-X(WS-V1)
     COMPUTE WS-DZ = PL-Z(WS-ROW) - EN-Z(WS-V1)
     COMPUTE WS-WANT = 90 + FUNCTION ATAN(FUNCTION ABS(WS-DZ) / FUNCTION ABS(WS-DX)) * 180 / FUNCTION PI
     MOVE "acceptance bugtradestop the body yaw points at Alice (tenths of a degree, within 1)" TO TL-CASE
     COMPUTE WS-GOT ROUNDED = EN-YAW(WS-V1) * 10
     PERFORM CHECK-NEAR
     MOVE "acceptance bugtradestop the yaw the viewers have (the head yaw) is the same" TO TL-CASE
     COMPUTE WS-GOT ROUNDED = EN-SENT-YAW(WS-V1) * 10
     PERFORM CHECK-NEAR
     COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
     COMPUTE WS-WANT = - (90 - FUNCTION ATAN(WS-H) * 180 / FUNCTION PI)
     MOVE "acceptance bugtradestop the pitch looks up at Alice's eyes (tenths of a degree, within 1)" TO TL-CASE
     COMPUTE WS-GOT ROUNDED = EN-PITCH(WS-V1) * 10
     PERFORM CHECK-NEAR
*>   Bobby (nearer to the villager's walk) is not the trader: the villager did not turn to him, and a Bobby right click is refused (already trading).
     MOVE "acceptance bugtradestop two players: Bobby has no window, the villager stays for Alice" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     MOVE MN-WINDOW(WS-ROW2) TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     PERFORM CHECK
*>   Alice closes the window (Container Close): the villager walks on to its walk target.
     CALL "TEST-CLOSE-WIN" USING WS-CONN
     PERFORM SNAPSHOT
     MOVE WS-SNAP TO WS-KEY
     MOVE 6000 TO CW-TIME
     MOVE 40 TO WS-N
     CALL "TEST-TICKS" USING WS-N
     PERFORM SNAPSHOT
     MOVE "acceptance bugtradestop after the window is closed the villager walks on" TO TL-CASE
     MOVE "moved" TO TL-EXPECTED
     MOVE "moved" TO TL-OBSERVED
     IF WS-SNAP = WS-KEY
         MOVE "still" TO TL-OBSERVED
     END-IF
     PERFORM CHECK
*>   Pitch is level again once the trade is over (the next movement or the end of the look resets it).
     MOVE "acceptance bugtradestop the pitch is back to 0 after the trade" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     COMPUTE WS-DEG = FUNCTION INTEGER(EN-PITCH(WS-V1))
     MOVE WS-DEG TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     PERFORM CHECK
*>   Two players. The villager is put back beside them (1 east, 1 south of Alice, Bobby 3 east of her) and sent on a walk again. Alice opens the window first: Bobby's right click is
*>   refused (19 section 22.4: already trading), the villager stands still and faces Alice, not Bobby.
     PERFORM RESET-VILLAGER
     CALL "TEST-INTERACT" USING WS-CONN EN-ID(WS-V1) WS-HAND0 WS-SNEAK0
     CALL "TEST-INTERACT" USING WS-CONN2 EN-ID(WS-V1) WS-HAND0 WS-SNEAK0
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     CALL "TEST-DRAIN-IDS" USING WS-CONN2 WS-IDS
     MOVE "acceptance bugtradestop two players: Bobby's right click on the villager Alice trades with opens nothing" TO TL-CASE
     MOVE "29 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE MN-CFAMILY(WS-ROW) TO WS-E1
     MOVE MN-WINDOW(WS-ROW2) TO WS-E2
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM CHECK
     PERFORM SNAPSHOT
     MOVE WS-SNAP TO WS-KEY
     PERFORM STEP-TICKS-40
     PERFORM SNAPSHOT
     MOVE "acceptance bugtradestop two players: the villager stands still for Alice" TO TL-CASE
     MOVE WS-KEY TO TL-EXPECTED
     MOVE WS-SNAP TO TL-OBSERVED
     PERFORM CHECK
     PERFORM FACE-YAW
     MOVE "acceptance bugtradestop two players: the villager faces Alice, not Bobby (tenths of a degree, within 1)" TO TL-CASE
     COMPUTE WS-GOT ROUNDED = EN-YAW(WS-V1) * 10
     PERFORM CHECK-NEAR
*>   Alice closes; Bobby opens the window and the villager turns to Bobby (he is east of it and north: yaw 180 + atan(dx / |dz|)).
     CALL "TEST-CLOSE-WIN" USING WS-CONN
     CALL "TEST-INTERACT" USING WS-CONN2 EN-ID(WS-V1) WS-HAND0 WS-SNEAK0
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     CALL "TEST-DRAIN-IDS" USING WS-CONN2 WS-IDS
     PERFORM STEP-TICKS-40
     PERFORM SNAPSHOT
     MOVE "acceptance bugtradestop two players: Bobby trades now, the villager has not moved" TO TL-CASE
     MOVE WS-KEY TO TL-EXPECTED
     MOVE WS-SNAP TO TL-OBSERVED
     PERFORM CHECK
     COMPUTE WS-DX = PL-X(WS-ROW2) - EN-X(WS-V1)
     COMPUTE WS-DZ = PL-Z(WS-ROW2) - EN-Z(WS-V1)
     COMPUTE WS-WANT = 180 + FUNCTION ATAN(WS-DX / FUNCTION ABS(WS-DZ)) * 180 / FUNCTION PI
     MOVE "acceptance bugtradestop two players: the villager faces Bobby (tenths of a degree, within 1)" TO TL-CASE
     COMPUTE WS-GOT ROUNDED = EN-YAW(WS-V1) * 10
     PERFORM CHECK-NEAR
*>   Bobby walks 10 blocks away: the next tick closes his window (stillValid, 4 blocks) and the villager walks on.
     COMPUTE PL-X(WS-ROW2) = PL-X(WS-ROW2) + 10
     MOVE 1 TO WS-N
     CALL "TEST-TICKS" USING WS-N
     MOVE "acceptance bugtradestop the window closes when the player is too far" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     MOVE MN-WINDOW(WS-ROW2) TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     PERFORM CHECK
     PERFORM SNAPSHOT
     MOVE WS-SNAP TO WS-KEY
     PERFORM STEP-TICKS-40
     PERFORM SNAPSHOT
     PERFORM CHECK-MOVED
     MOVE "acceptance bugtradestop the villager walks on once the player went away" TO TL-CASE
     PERFORM CHECK
*>   A player who leaves with the window open frees the villager too.
     COMPUTE PL-X(WS-ROW2) = PL-X(WS-ROW2) - 10
     PERFORM RESET-VILLAGER
     CALL "TEST-INTERACT" USING WS-CONN EN-ID(WS-V1) WS-HAND0 WS-SNEAK0
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE 5 TO WS-N
     CALL "TEST-TICKS" USING WS-N
     PERFORM SNAPSHOT
     MOVE WS-SNAP TO WS-KEY
     CALL "PLAYER-LEAVE" USING WS-ROW
     PERFORM STEP-TICKS-40
     PERFORM SNAPSHOT
     PERFORM CHECK-MOVED
     MOVE "acceptance bugtradestop the villager walks on after the trading player left" TO TL-CASE
     PERFORM CHECK
*>   A wandering trader stands still for its trading player as well (Bobby), walks on when the window is closed.
     MOVE "wandering_trader" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TTYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = PL-X(WS-ROW2) + 1
     COMPUTE WS-Z = PL-Z(WS-ROW2) + 1
     CALL "MOB-SPAWN" USING WS-DIM WS-TTYPE WS-X WS-Y WS-Z WS-YAW WS-V2
     COMPUTE EN-DEST-X(WS-V2) = EN-X(WS-V2) + 20
     MOVE EN-Z(WS-V2) TO EN-DEST-Z(WS-V2)
     MOVE 200 TO EN-COOLDOWN(WS-V2)
     MOVE 0 TO EN-PATH-TICKS(WS-V2) EN-WAY-X(WS-V2) EN-WAY-Z(WS-V2)
     CALL "TEST-DRAIN-IDS" USING WS-CONN2 WS-IDS
     CALL "TEST-INTERACT" USING WS-CONN2 EN-ID(WS-V2) WS-HAND0 WS-SNEAK0
     CALL "TEST-DRAIN-IDS" USING WS-CONN2 WS-IDS
     COMPUTE WS-MX = FUNCTION INTEGER(EN-X(WS-V2) * 1000 + 0.5)
     PERFORM STEP-TICKS-40
     COMPUTE WS-MY = FUNCTION INTEGER(EN-X(WS-V2) * 1000 + 0.5)
     MOVE "acceptance bugtradestop a wandering trader with the window open does not move (x within 50 mm)" TO TL-CASE
     MOVE "ok" TO TL-EXPECTED
     MOVE "ok" TO TL-OBSERVED
     IF FUNCTION ABS(WS-MY - WS-MX) > 50
         MOVE WS-MY TO WS-E1
         MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     END-IF
     PERFORM CHECK
     STOP RUN.

 RESET-VILLAGER.
     COMPUTE EN-X(WS-V1) = WS-PX + 1
     COMPUTE EN-Z(WS-V1) = WS-PZ + 1
     MOVE 0 TO EN-VX(WS-V1) EN-VZ(WS-V1)
     COMPUTE EN-DEST-X(WS-V1) = EN-X(WS-V1) + 20
     MOVE EN-Z(WS-V1) TO EN-DEST-Z(WS-V1)
     MOVE 200 TO EN-COOLDOWN(WS-V1)
     MOVE 0 TO EN-PATH-TICKS(WS-V1) EN-WAY-X(WS-V1) EN-WAY-Z(WS-V1)
     MOVE 3000 TO CW-TIME
     MOVE 1 TO WS-N
     CALL "TEST-TICKS" USING WS-N.

 CHECK-MOVED.
     MOVE "moved" TO TL-EXPECTED
     MOVE "moved" TO TL-OBSERVED
     IF WS-SNAP = WS-KEY
         MOVE "still" TO TL-OBSERVED
     END-IF.

 FACE-YAW.
     COMPUTE WS-DX = PL-X(WS-ROW) - EN-X(WS-V1)
     COMPUTE WS-DZ = PL-Z(WS-ROW) - EN-Z(WS-V1)
     COMPUTE WS-WANT = 90 + FUNCTION ATAN(FUNCTION ABS(WS-DZ) / FUNCTION ABS(WS-DX)) * 180 / FUNCTION PI.

 STEP-TICKS-3.
     MOVE 3 TO WS-N
     MOVE 3000 TO CW-TIME
     CALL "TEST-TICKS" USING WS-N.

 STEP-TICKS-40.
     MOVE 3000 TO CW-TIME
     MOVE 40 TO WS-N
     CALL "TEST-TICKS" USING WS-N.

 SNAPSHOT.
     COMPUTE WS-MX = FUNCTION INTEGER(EN-X(WS-V1) * 1000 + 0.5)
     COMPUTE WS-MZ = FUNCTION INTEGER(EN-Z(WS-V1) * 1000 + 0.5)
     MOVE WS-MX TO WS-E1
     MOVE WS-MZ TO WS-E2
     MOVE SPACES TO WS-SNAP
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-SNAP.

 CHECK-NEAR.
     COMPUTE WS-WANT10 ROUNDED = WS-WANT * 10
     MOVE WS-WANT10 TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO TL-EXPECTED
     MOVE WS-GOT TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     COMPUTE WS-DIFF = FUNCTION MOD(WS-GOT - WS-WANT10 + 36000, 3600)
     IF WS-DIFF <= 1 OR WS-DIFF >= 3599
         MOVE TL-EXPECTED TO TL-OBSERVED
     END-IF
     PERFORM CHECK.

 CHECK.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-BUGTRADESTOP-LOOK.
 COPY CORETEST.
 COPY BETEST.
