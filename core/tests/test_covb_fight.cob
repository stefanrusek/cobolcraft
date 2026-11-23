*> Implementation test (lane covB; docs/protocol/21 section 6.4.5): the dragon fight controller's less common paths: a boss bar member leaving ahead of another one, the exit portal's
*> height above a bedrock column, tryRespawn without a known portal, an aborted respawn sequence, the timed stages (2 effects, last pillar, summoning), the first scan of the saved state
*> (known active portal, no portal, an adopted dragon) and a killed dragon's idle tick.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVB-FIGHT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROJSTATE.
 COPY DRAGSTATE.
 COPY FIGHTRT.
 COPY ENDFIGHT.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-STONE               BINARY-LONG.
 01 WS-PORTAL              BINARY-LONG.
 01 WS-BEDROCK             BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-SET                 BINARY-LONG VALUE 4.
 01 WS-GET                 BINARY-LONG VALUE 3.
 01 WS-ROW                 BINARY-LONG.
 01 WS-INACTIVE            BINARY-LONG VALUE 0.
 01 WS-YES                 BINARY-LONG VALUE 1.
 01 WS-CX                  FLOAT-LONG.
 01 WS-CY                  FLOAT-LONG.
 01 WS-CZ                  FLOAT-LONG.
 01 WS-RCID                BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE WS-DIM TO FR-DIM
     MOVE 1 TO FR-SCANNED
     MOVE 0 TO CW-SEED
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE "minecraft:end_portal" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-PORTAL
     MOVE "minecraft:bedrock" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-BEDROCK
*>   Two members on the bar, the first far away: it is removed and the second moves up.
     MOVE 500 TO PL-X(WS-PLAYER)
     MOVE 100 TO PL-Y(WS-PLAYER)
     MOVE 0 TO PL-Z(WS-PLAYER)
     MOVE 2 TO FR-BAR-N
     MOVE PL-UUID(WS-PLAYER) TO FR-BAR-PLAYER(1)
     MOVE "BBBBBBBBBBBBBBBB" TO FR-BAR-PLAYER(2)
     CALL "FIGHT-BAR-SYNC" USING WS-DIM
     MOVE "covB 21 6.4.5 a member that left the area is removed and the next one moves up" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF FR-BAR-N = 1 AND FR-BAR-PLAYER(1) = "BBBBBBBBBBBBBBBB"
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO FR-BAR-N
     MOVE 0 TO PL-X(WS-PLAYER)
*>   The portal's height: the surface of the podium column minus one, lowered through bedrock above 63 (here 64 to 66, stopping at 63).
     MOVE 0 TO WS-BX WS-BZ
     PERFORM VARYING WS-BY FROM 64 BY 1 UNTIL WS-BY > 66
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-BEDROCK
     END-PERFORM
     INITIALIZE END-FIGHT
     CALL "END-FIGHT-IO" USING WS-SET END-FIGHT
     CALL "FIGHT-PORTAL" USING WS-DIM WS-INACTIVE
     CALL "END-FIGHT-IO" USING WS-GET END-FIGHT
     MOVE "covB 21 6.4.5 the exit portal is placed below the bedrock column (y 63)" TO TL-CASE
     MOVE 163 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EF-HAS-PORTAL * 100 + EF-PORTAL(2)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-BY FROM 64 BY 1 UNTIL WS-BY > 66
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     END-PERFORM
*>   tryRespawn of a killed dragon with no known portal first makes the portal, then finds no crystals.
     INITIALIZE END-FIGHT
     MOVE 1 TO EF-KILLED
     CALL "END-FIGHT-IO" USING WS-SET END-FIGHT
     CALL "FIGHT-RESPAWN-TRY" USING WS-DIM
     CALL "END-FIGHT-IO" USING WS-GET END-FIGHT
     MOVE "covB 21 6.4.5 tryRespawn with no known portal places it and starts nothing" TO TL-CASE
     MOVE 100 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EF-HAS-PORTAL * 100 + EF-STAGE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   An aborted sequence: a respawn crystal that does not exist any more.
     MOVE 1 TO EF-STAGE
     CALL "END-FIGHT-IO" USING WS-SET END-FIGHT
     MOVE 1 TO FR-RC-N
     MOVE 999999 TO FR-RC(1)
     CALL "FIGHT-RESPAWN-TICK" USING WS-DIM
     CALL "END-FIGHT-IO" USING WS-GET END-FIGHT
     MOVE "covB 21 6.4.5 a vanished respawn crystal ends the sequence (stage 0, none left)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EF-STAGE + FR-RC-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Stage 2 plays the sound event at tick 0 and counts up.
     MOVE 2 TO EF-STAGE
     MOVE 0 TO EF-TIME
     CALL "END-FIGHT-IO" USING WS-SET END-FIGHT
     CALL "FIGHT-RESPAWN-TICK" USING WS-DIM
     CALL "END-FIGHT-IO" USING WS-GET END-FIGHT
     MOVE "covB 21 6.4.5 stage 2 counts its ticks" TO TL-CASE
     MOVE 21 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EF-STAGE * 10 + EF-TIME
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Stage 3 at tick 399 builds the last pillar and goes on to stage 4; stage 4 counts.
     MOVE 3 TO EF-STAGE
     MOVE 399 TO EF-TIME
     CALL "END-FIGHT-IO" USING WS-SET END-FIGHT
     CALL "FIGHT-RESPAWN-TICK" USING WS-DIM
     CALL "END-FIGHT-IO" USING WS-GET END-FIGHT
     MOVE "covB 21 6.4.5 after 400 ticks of summoning stage 4 starts" TO TL-CASE
     MOVE 40 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EF-STAGE * 10 + EF-TIME
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO EF-TIME
     CALL "END-FIGHT-IO" USING WS-SET END-FIGHT
     CALL "FIGHT-RESPAWN-TICK" USING WS-DIM
     CALL "END-FIGHT-IO" USING WS-GET END-FIGHT
     MOVE "covB 21 6.4.5 stage 4 counts its ticks" TO TL-CASE
     MOVE 46 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EF-STAGE * 10 + EF-TIME
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Stage 4 at tick 100 discards the respawn crystals with an explosion (power 6, no fire) each, and the sequence ends (stage 0).
     COMPUTE WS-CX = WS-BX + 0.5
     MOVE 120 TO WS-CY
     COMPUTE WS-CZ = WS-BZ + 0.5
     CALL "CRYSTAL-SPAWN" USING WS-DIM WS-CX WS-CY WS-CZ WS-YES WS-ROW
     MOVE 1 TO FR-RC-N
     MOVE EN-ID(WS-ROW) TO WS-RCID
     MOVE WS-RCID TO FR-RC(1)
     MOVE 4 TO EF-STAGE
     MOVE 100 TO EF-TIME
     CALL "END-FIGHT-IO" USING WS-SET END-FIGHT
     CALL "FIGHT-RESPAWN-TICK" USING WS-DIM
     CALL "END-FIGHT-IO" USING WS-GET END-FIGHT
     MOVE "covB 21 6.4.5 stage 4 ends the sequence at tick 100 (stage 0, no respawn crystal left)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EF-STAGE + FR-RC-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-LEFT
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > EN-COUNT
         IF EN-USED(WS-J) = 1 AND EN-ID(WS-J) = WS-RCID
             ADD 1 TO WS-LEFT
         END-IF
     END-PERFORM
     MOVE "covB 21 6.4.5 and the respawn crystal's entity is gone (its row may be the new dragon's)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LEFT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The first scan (FR-SCANNED 0), with a known portal block that is active: the dragon was killed before.
     MOVE 0 TO FR-SCANNED
     INITIALIZE END-FIGHT
     MOVE 1 TO EF-HAS-PORTAL
     MOVE 0 TO EF-PORTAL(1) EF-PORTAL(3)
     MOVE 70 TO EF-PORTAL(2)
     CALL "END-FIGHT-IO" USING WS-SET END-FIGHT
     MOVE 70 TO WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-PORTAL
     MOVE 1 TO FR-BAR-N
     MOVE PL-UUID(WS-PLAYER) TO FR-BAR-PLAYER(1)
     MOVE 5 TO FR-SEEN
     MOVE 0 TO DG-ENT
     MOVE 1 TO FR-TICKS
     CALL "FIGHT-TICK"
     CALL "END-FIGHT-IO" USING WS-GET END-FIGHT
     MOVE "covB 21 6.4.5 the first tick scans the state: an active portal means killed before" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FR-SCANNED * 10 + EF-PREVIOUS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A killed dragon (flag set) leaves the tick before the dragon upkeep: the unseen counter stands.
     MOVE 1 TO EF-KILLED
     CALL "END-FIGHT-IO" USING WS-SET END-FIGHT
     MOVE 5 TO FR-SEEN
     CALL "FIGHT-TICK"
     MOVE "covB 21 6.4.5 and nothing else of the dragon's upkeep runs while it is killed" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE FR-SEEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 70 TO WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
*>   A known portal location without a portal block builds the inactive portal; an existing dragon is adopted.
     MOVE 0 TO DG-FIGHT
     CALL "FIGHT-NEW-DRAGON" USING WS-DIM
     MOVE 0 TO DG-FIGHT
     MOVE 0 TO EF-PREVIOUS
     CALL "END-FIGHT-IO" USING WS-SET END-FIGHT
     CALL "FIGHT-SCAN" USING WS-DIM
     CALL "END-FIGHT-IO" USING WS-GET END-FIGHT
     MOVE "covB 21 6.4.5 without an active portal the scan keeps previous 0 and adopts the dragon" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EF-PREVIOUS = 0 AND DG-FIGHT = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE "covB 21 6.4.5 and the inactive portal's bedrock column stands at the stored place" TO TL-CASE
     MOVE WS-BEDROCK TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-COVB-FIGHT.
 COPY CORETEST.
 COPY MOBSPTEST.
