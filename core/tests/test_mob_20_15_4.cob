*> Acceptance test (lane p49r; docs/protocol/20 section 15.2): the Darkness pulse of the warden. The pulse is on the warden's own tick count (`tickCount`, 1 at its first tick; EN-WAKE): (id + tickCount)
*> mod 120 = 0, so the first pulse of a warden of id N is at tick t = (-N) mod 120 (120 when that is 0). It reaches survival and adventure players within 20 blocks (squared distance below 400, strict), not
*> creative or spectator players, and a player whose Darkness has more than 199 ticks left is not touched (the effect is renewed to 260 only when at most 199 are left).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-15-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY STDMOBS.
 COPY EFFECTS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-WARDEN              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-SLOT                BINARY-LONG VALUE 33.
 01 WS-T                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 16.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-DARKNESS            BINARY-LONG VALUE 32.
 01 WS-AMPLIFIER           BINARY-LONG VALUE 0.
 01 WS-LEFT                BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 4.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE "minecraft:warden" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-FX = FUNCTION INTEGER(WS-X) - 4
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) - 8
     COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     COMPUTE WS-X0 = WS-X + 10
     MOVE 2 TO PL-MODE(WS-PLAYER)
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-WARDEN
*>   1. The first pulse of a fresh warden is at tick t = (-id) mod 120.
     COMPUTE WS-T = FUNCTION MOD(120 - FUNCTION MOD(EN-ID(WS-WARDEN), 120), 120)
     IF WS-T = 0
         MOVE 120 TO WS-T
     END-IF
     MOVE 0 TO EN-WAKE(WS-WARDEN) EF-ON(WS-PLAYER, WS-SLOT)
     MOVE 0 TO WS-FIRST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 120 OR WS-FIRST > 0
         CALL "MOB-STEP" USING WS-WARDEN
         IF EF-ON(WS-PLAYER, WS-SLOT) = 1
             MOVE WS-I TO WS-FIRST
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§15.2 the first Darkness pulse of a new warden is at tick (-id) mod 120 of its own ticks" TO TL-CASE
     MOVE WS-T TO TL-EXPECTED-N
     MOVE WS-FIRST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§15.2 the warden counts its own ticks (EN-WAKE) from 1" TO TL-CASE
     MOVE WS-FIRST TO TL-EXPECTED-N
     MOVE EN-WAKE(WS-WARDEN) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   2. Game modes: survival and adventure receive it, creative and spectator never. The count is set to the tick before the pulse each time.
     PERFORM VARYING WS-LEVEL FROM 0 BY 1 UNTIL WS-LEVEL > 3
         MOVE WS-LEVEL TO PL-MODE(WS-PLAYER)
         MOVE 0 TO EF-ON(WS-PLAYER, WS-SLOT)
         COMPUTE EN-WAKE(WS-WARDEN) = WS-T - 1
         CALL "MOB-STEP" USING WS-WARDEN
         MOVE SPACES TO TL-CASE
         EVALUATE WS-LEVEL
             WHEN 0
                 MOVE "acceptance US15 20§15.2 a survival player in range gets Darkness" TO TL-CASE
                 MOVE 1 TO TL-EXPECTED-N
             WHEN 1
                 MOVE "acceptance US15 20§15.2 a creative player in range gets none" TO TL-CASE
                 MOVE 0 TO TL-EXPECTED-N
             WHEN 2
                 MOVE "acceptance US15 20§15.2 an adventure player in range gets Darkness" TO TL-CASE
                 MOVE 1 TO TL-EXPECTED-N
             WHEN OTHER
                 MOVE "acceptance US15 20§15.2 a spectator in range gets none" TO TL-CASE
                 MOVE 0 TO TL-EXPECTED-N
         END-EVALUATE
         MOVE EF-ON(WS-PLAYER, WS-SLOT) TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   3. The radius: 20.0 along x exactly is out (squared distance 400 is not below 400), 19.9 is in.
     MOVE 2 TO PL-MODE(WS-PLAYER)
     MOVE 0 TO EF-ON(WS-PLAYER, WS-SLOT)
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 20
     MOVE WS-Y TO PL-Y(WS-PLAYER)
     MOVE WS-Z TO PL-Z(WS-PLAYER)
     COMPUTE EN-WAKE(WS-WARDEN) = WS-T - 1
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "acceptance US15 20§15.2 a player exactly 20 blocks away is out (strict)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EF-ON(WS-PLAYER, WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 19.9
     COMPUTE EN-WAKE(WS-WARDEN) = WS-T - 1
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "acceptance US15 20§15.2 a player 19.9 blocks away is in" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EF-ON(WS-PLAYER, WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   4. Renewal: with 250 ticks of Darkness left the pulse leaves it alone (250), with 199 left it renews to 260.
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 5
     CALL "EFFECT-REMOVE" USING WS-PLAYER WS-DARKNESS
     MOVE 250 TO WS-LEFT
     CALL "EFFECT-ADD" USING WS-PLAYER WS-DARKNESS WS-AMPLIFIER WS-LEFT WS-FLAGS
     COMPUTE EN-WAKE(WS-WARDEN) = WS-T - 1
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "acceptance US15 20§15.2 a Darkness with 250 ticks left is not renewed" TO TL-CASE
     MOVE 250 TO TL-EXPECTED-N
     MOVE EF-DURATION(WS-PLAYER, WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "EFFECT-REMOVE" USING WS-PLAYER WS-DARKNESS
     MOVE 199 TO WS-LEFT
     CALL "EFFECT-ADD" USING WS-PLAYER WS-DARKNESS WS-AMPLIFIER WS-LEFT WS-FLAGS
     COMPUTE EN-WAKE(WS-WARDEN) = WS-T - 1
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "acceptance US15 20§15.2 a Darkness with 199 ticks left is renewed to 260" TO TL-CASE
     MOVE 260 TO TL-EXPECTED-N
     MOVE EF-DURATION(WS-PLAYER, WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-20-15-4.
 COPY CORETEST.
 COPY MOBSPTEST.
