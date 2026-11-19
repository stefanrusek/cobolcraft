*> Acceptance test (002-lane-p49b; docs/protocol/20 section 15): the warden's table row and its Darkness pulse. Entity warden: max health 500, attack damage 30,
*> follow range 24, experience 5, no natural spawn rule (sculk shrieker only), a monster. Every 120 ticks offset by the entity id ((id + tickCount) mod 120 = 0) it gives
*> every player within 20 blocks the Darkness effect (amplifier 0, 260 ticks, no particles); a player farther away, or a tick off the pulse, gets none.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-15.
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
 01 WS-INDEX               BINARY-LONG.
 01 WS-WARDEN              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-SLOT                BINARY-LONG VALUE 33.
 01 WS-OFF                 BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 16.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE "minecraft:warden" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "STDMOB-INDEX" USING WS-TYPE WS-INDEX
     MOVE "acceptance US15 minecraft:warden is a standard mob row" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-INDEX > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-INDEX = 0
         STOP RUN
     END-IF
     MOVE "acceptance US15 20§15 Warden health, attack, follow, xp, kind, spawn" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 500 * 100000000 + 30 * 1000000 + 24 * 10000 + 5 * 100 + 10
     COMPUTE TL-OBSERVED-N = SM-HEALTH(WS-INDEX) * 100000000 + SM-ATTACK(WS-INDEX) * 1000000 + SM-FOLLOW(WS-INDEX) * 10000
         + SM-XP(WS-INDEX) * 100 + SM-KIND(WS-INDEX) * 10 + SM-SPAWN(WS-INDEX)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The pulse: a creative player 10 blocks away (no fight), the time chosen so that (id + time) mod 120 = 0.
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-X0 = WS-X + 10
     COMPUTE WS-FX = FUNCTION INTEGER(WS-X) - 4
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) - 8
     COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-WARDEN
     COMPUTE WS-OFF = FUNCTION MOD(EN-ID(WS-WARDEN), 120)
     COMPUTE CW-TIME = 12000 - WS-OFF + 1
     MOVE 0 TO EF-ON(WS-PLAYER, WS-SLOT)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "acceptance US15 20§15 Warden no Darkness off the pulse" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EF-ON(WS-PLAYER, WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE CW-TIME = 12000 - WS-OFF
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "acceptance US15 20§15 Warden Darkness on the pulse (on, amplifier, duration, flags)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1 * 10000000 + 0 * 1000000 + 260 * 10 + 4
     COMPUTE TL-OBSERVED-N = EF-ON(WS-PLAYER, WS-SLOT) * 10000000 + EF-AMPLIFIER(WS-PLAYER, WS-SLOT) * 1000000
         + EF-DURATION(WS-PLAYER, WS-SLOT) * 10 + EF-FLAGS(WS-PLAYER, WS-SLOT)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A player 30 blocks above is not affected.
     MOVE 0 TO EF-ON(WS-PLAYER, WS-SLOT)
     COMPUTE PL-Y(WS-PLAYER) = WS-Y + 30
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "acceptance US15 20§15 Warden no Darkness beyond 20 blocks" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EF-ON(WS-PLAYER, WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-20-15.
 COPY CORETEST.
 COPY MOBSPTEST.
