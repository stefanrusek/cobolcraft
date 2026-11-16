*> Acceptance test, the ender dragon fight controller (docs/protocol/21 section 6.4.5, 6.4.6; lane 002-lane-mobsb8, T9704, T9705): the boss bar members (every 20 ticks, alive players within 192 of
*> (0, 128, 0)), the progress, the crystal count (pillar boxes, every 100 ticks), a new dragon after 1200 ticks unseen, the kill (portal active, gateway popped, egg only on the first kill, bar hidden),
*> tryRespawn (a crystal in each of four directions at 3 blocks) and the respawn stages (pillars cleared and regenerated with an invulnerable crystal, the dragon created at the end).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US16-DRAGON-FIGHT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROJSTATE.
 COPY DRAGSTATE.
 COPY FIGHTRT.
 COPY ENDFIGHT.
 COPY ENDSPIKE REPLACING ==SPIKE-LIST== BY ==WS-SPIKES== LEADING ==SP-== BY ==WSP-== ==CRYSTAL-LIST== BY ==WS-CRYSTALS== LEADING ==EC-== BY ==WEC-==.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CROW                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-STONE               BINARY-LONG.
 01 WS-PORTAL              BINARY-LONG.
 01 WS-EGG                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-SET                 BINARY-LONG VALUE 4.
 01 WS-GET                 BINARY-LONG VALUE 3.
 01 WS-PI                  FLOAT-LONG.
 01 WS-SEED                BINARY-DOUBLE VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE WS-DIM TO FR-DIM
     MOVE 1 TO FR-SCANNED
     MOVE 0 TO CW-SEED
     MOVE FUNCTION PI TO WS-PI
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE "minecraft:end_portal" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-PORTAL
     MOVE "minecraft:dragon_egg" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-EGG
*>   The podium column: stone at (0, 60, 0), the surface is 61.
     MOVE 0 TO WS-BX WS-BZ
     MOVE 60 TO WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE
*>   Boss bar members: a player 100 blocks up is within 192 of (0, 128, 0): added on the 20 tick sync; a far player is not.
     MOVE 0 TO PL-X(WS-PLAYER)
     MOVE 100 TO PL-Y(WS-PLAYER)
     MOVE 0 TO PL-Z(WS-PLAYER)
     MOVE 19 TO FR-TICKS
     CALL "FIGHT-TICK"
     MOVE "acceptance US16 21 6.4.5 a player within 192 blocks of (0, 128, 0) joins the boss bar on the 20 tick sync" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FR-BAR * 10 + FR-BAR-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 500 TO PL-X(WS-PLAYER)
     MOVE 39 TO FR-TICKS
     CALL "FIGHT-TICK"
     MOVE "acceptance US16 21 6.4.5 a player who went beyond 192 blocks leaves the bar" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE FR-BAR-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-X(WS-PLAYER)
*>   A dragon unseen for 1200 ticks is created at (0, 128, 0).
     INITIALIZE END-FIGHT
     MOVE 0 TO EF-KILLED
     MOVE 20 TO EF-GATEWAY-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         COMPUTE EF-GATEWAY(WS-I) = WS-I - 1
     END-PERFORM
     CALL "END-FIGHT-IO" USING WS-SET END-FIGHT
     MOVE 0 TO DG-ENT
     MOVE 1198 TO FR-SEEN
     MOVE 59 TO FR-TICKS
     CALL "FIGHT-TICK"
     MOVE "acceptance US16 21 6.4.5 before 1200 ticks unseen no dragon is made" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE DG-ENT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FIGHT-TICK"
     MOVE "acceptance US16 21 6.4.5 after 1200 ticks unseen a dragon of the fight exists" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF DG-ENT > 0 AND DG-FIGHT = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "DRAGON-ROW" USING WS-ROW
     MOVE "acceptance US16 21 6.4.5 it is created at (0, 128, 0)" TO TL-CASE
     MOVE 128 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-Y(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Boss bar progress: half health.
     MOVE 100 TO DG-HP
     CALL "FIGHT-TICK"
     MOVE "acceptance US16 21 6.4.5 the bar progress follows health (500 thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE FR-PROG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Crystal count: two crystals on pillar tops, counted every 100 ticks.
     CALL "END-SPIKES" USING CW-SEED WS-SPIKES
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         COMPUTE WS-X = WSP-CX(WS-I) + 0.5
         COMPUTE WS-Y = WSP-H(WS-I) + 1
         COMPUTE WS-Z = WSP-CZ(WS-I) + 0.5
         CALL "CRYSTAL-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-I WS-CROW
     END-PERFORM
     MOVE 99 TO FR-TICKS
     CALL "FIGHT-TICK"
     MOVE "acceptance US16 21 6.4.5 every 100 ticks the crystals in the pillar boxes are counted (2)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE FR-CRYSTALS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The kill: portal active at the surface - 1, egg on the first kill, one gateway popped, bar hidden, flags set.
     CALL "END-FIGHT-IO" USING WS-GET END-FIGHT
     MOVE 0 TO EF-PREVIOUS
     CALL "END-FIGHT-IO" USING WS-SET END-FIGHT
     CALL "FIGHT-KILLED" USING WS-DIM
     CALL "END-FIGHT-IO" USING WS-GET END-FIGHT
     MOVE 1 TO WS-BX
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE "acceptance US16 21 6.4.5 the exit portal is active: the block beside the bedrock column is end_portal" TO TL-CASE
     MOVE WS-PORTAL TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-BX
     MOVE "acceptance US16 21 6.4.5 the kill is recorded (killed 1, previously killed 1)" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EF-KILLED * 10 + EF-PREVIOUS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4.5 the portal location is stored (0, 60, 0)" TO TL-CASE
     MOVE 60 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EF-PORTAL(2) + EF-HAS-PORTAL * 0
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4.5 a new gateway uses up one index (19 left)" TO TL-CASE
     MOVE 19 TO TL-EXPECTED-N
     MOVE EF-GATEWAY-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4.5 the bar is hidden on the kill" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE FR-BAR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The egg: on top of the portal's bedrock column on the first kill; none on the second.
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-J FROM 60 BY 1 UNTIL WS-J > 70
         CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-J WS-BZ WS-STATE
         IF WS-STATE = WS-EGG
             ADD 1 TO WS-COUNT
             MOVE WS-J TO WS-I
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-I WS-BZ WS-STONE
         END-IF
     END-PERFORM
     MOVE "acceptance US16 21 6.4.5 the first kill places the dragon egg above the portal" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FIGHT-KILLED" USING WS-DIM
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-J FROM 60 BY 1 UNTIL WS-J > 75
         CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-J WS-BZ WS-STATE
         IF WS-STATE = WS-EGG
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "acceptance US16 21 6.4.5 later kills place no egg" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   tryRespawn: three crystals are not enough, four (one in each direction at 3 blocks, 1 above the portal) start the sequence.
     MOVE 0 TO FR-RC-N
     MOVE 0 TO EF-STAGE
     MOVE 61 TO WS-Y
     MOVE 3.5 TO WS-X
     MOVE 0.5 TO WS-Z
     CALL "CRYSTAL-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-I WS-CROW
     MOVE -2.5 TO WS-X
     CALL "CRYSTAL-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-I WS-CROW
     MOVE 0.5 TO WS-X
     MOVE 3.5 TO WS-Z
     CALL "CRYSTAL-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-I WS-CROW
     CALL "FIGHT-RESPAWN-TRY" USING WS-DIM
     CALL "END-FIGHT-IO" USING WS-GET END-FIGHT
     MOVE "acceptance US16 21 6.4.5 tryRespawn with a crystal missing in one direction does nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EF-STAGE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -2.5 TO WS-Z
     CALL "CRYSTAL-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-I WS-CROW
     CALL "FIGHT-RESPAWN-TRY" USING WS-DIM
     CALL "END-FIGHT-IO" USING WS-GET END-FIGHT
     MOVE "acceptance US16 21 6.4.5 four crystals start the sequence: stage START and four respawn crystals" TO TL-CASE
     MOVE 14 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EF-STAGE * 10 + FR-RC-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-BX
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 0 TO WS-BX
     MOVE "acceptance US16 21 6.4.5 the portal is rebuilt inactive (the block beside the column is air)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Stages: START -> PREPARING_TO_SUMMON_PILLARS (2) -> after 100 ticks SUMMONING_PILLARS (3).
     CALL "FIGHT-TICK"
     CALL "END-FIGHT-IO" USING WS-GET END-FIGHT
     MOVE "acceptance US16 21 6.4.5 the START stage leads to stage 2" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE EF-STAGE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 100 TO EF-TIME
     CALL "END-FIGHT-IO" USING WS-SET END-FIGHT
     CALL "FIGHT-TICK"
     CALL "END-FIGHT-IO" USING WS-GET END-FIGHT
     MOVE "acceptance US16 21 6.4.5 after 100 ticks stage 3 starts with the time reset" TO TL-CASE
     MOVE 30 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EF-STAGE * 10 + EF-TIME
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Summoning pillars: at tick 39 of the first pillar the cube of half-size 10 is cleared and the pillar is rebuilt with an invulnerable crystal.
     CALL "END-SPIKES" USING CW-SEED WS-SPIKES
     COMPUTE WS-BX = WSP-CX(1) + 8
     MOVE WSP-H(1) TO WS-BY
     MOVE WSP-CZ(1) TO WS-BZ
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE
     MOVE 39 TO EF-TIME
     CALL "END-FIGHT-IO" USING WS-SET END-FIGHT
     CALL "FIGHT-TICK"
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE "acceptance US16 21 6.4.5 the first pillar's surroundings (cube of half-size 10) are cleared" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         IF PJ-ENT(WS-I) > 0 AND PJ-KIND(WS-I) = 16 AND PJ-I2(WS-I) = 1
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "acceptance US16 21 6.4.5 the regenerated pillar carries an invulnerable crystal" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The last stage: after 100 ticks of summoning the dragon is created, the respawn crystals are gone and the spike crystals are vulnerable again.
     CALL "END-FIGHT-IO" USING WS-GET END-FIGHT
     MOVE 4 TO EF-STAGE
     MOVE 100 TO EF-TIME
     CALL "END-FIGHT-IO" USING WS-SET END-FIGHT
     MOVE 0 TO DG-ENT
     CALL "FIGHT-TICK"
     CALL "END-FIGHT-IO" USING WS-GET END-FIGHT
     MOVE "acceptance US16 21 6.4.5 the sequence ends: stage 0, not killed" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EF-STAGE + EF-KILLED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4.5 and a new dragon of the fight exists" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF DG-ENT > 0 AND DG-FIGHT = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         IF PJ-ENT(WS-I) > 0 AND PJ-KIND(WS-I) = 16 AND PJ-I2(WS-I) = 1
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "acceptance US16 21 6.4.5 no crystal is invulnerable any more" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US16-DRAGON-FIGHT.
 COPY CORETEST.
 COPY MOBSPTEST.
