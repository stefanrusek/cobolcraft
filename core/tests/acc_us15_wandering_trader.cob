*> Acceptance test, the wandering trader (docs/protocol/19 section 23; lane 002-lane-mobsb4, T8802): the wandering_trader and trader_llama rows, the trader's nine offers, the spawner (every 1200
*> ticks the delay drops by 1200, at 0 it resets to 24000 and the chance rises by 25 to at most 75; a roll at or below the chance and a 1 in 10 gate try a spawn), the placement of the trader
*> with two trader llamas, and the despawn after 48000 ticks.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-WANDERING-TRADER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY VILSTATE.
 COPY TRADERSP.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TTYPE               BINARY-LONG.
 01 WS-LTYPE               BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 96.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-GATE                BINARY-LONG.
 01 WS-TRADERS             BINARY-LONG.
 01 WS-LLAMAS              BINARY-LONG.
 01 WS-NEAR                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Y0 = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FX = WS-X0 - 48
     COMPUTE WS-FZ = WS-Z0 - 48
     COMPUTE WS-GY = WS-Y0 - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-GY WS-KIND
     MOVE "minecraft:wandering_trader" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:trader_llama" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-LTYPE WS-ENTITY-ROW WS-STATUS
*>   The rows.
     CALL "STDMOB-INDEX" USING WS-TTYPE WS-IDX
     MOVE "acceptance US15 19§23 the wandering_trader has a standard mob row" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-IDX > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "STDMOB-INDEX" USING WS-LTYPE WS-IDX
     MOVE "acceptance US15 19§3.7 the trader_llama has a standard mob row" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-IDX > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-TTYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "VL-FIND" USING EN-ID(WS-ROW) WS-NO WS-SLOT
     MOVE "acceptance US15 19§23 a spawned trader has the trader state (kind 2) and nine offers" TO TL-CASE
     MOVE 29 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SLOT > 0
         COMPUTE TL-OBSERVED-N = 20 + VL-KIND(WS-SLOT) * 0 + VL-O-N(WS-SLOT)
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The spawner clock.
     MOVE 0 TO TS-INIT
     MOVE 1200 TO CW-TICKS
     CALL "TRADER-TICK"
     MOVE "acceptance US15 19§23 the first call sets delay 24000 and chance 25, then the tick 1200 takes 1200" TO TL-CASE
     MOVE 22800 TO TL-EXPECTED-N
     MOVE TS-DELAY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1300 TO CW-TICKS
     CALL "TRADER-TICK"
     MOVE "acceptance US15 19§23 off the 1200 beat the delay does not move" TO TL-CASE
     MOVE 22800 TO TL-EXPECTED-N
     MOVE TS-DELAY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO TS-DELAY
     MOVE 40 TO TS-CHANCE
     MOVE 2400 TO CW-TICKS
     CALL "TRADER-TICK"
     MOVE "acceptance US15 19§23 at delay 0 or less the delay resets to 24000" TO TL-CASE
     MOVE 24000 TO TL-EXPECTED-N
     MOVE TS-DELAY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§23 the chance 40 + 25 = 65 stays (failed or no try) or resets to 25 (spawned)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF TS-CHANCE = 65 OR TS-CHANCE = 25
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 70 TO TS-CHANCE
     MOVE 1 TO TS-DELAY
     MOVE 3600 TO CW-TICKS
     CALL "TRADER-TICK"
     MOVE "acceptance US15 19§23 the chance is clamped to 75" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF TS-CHANCE = 75 OR TS-CHANCE = 25
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Many beats: some roll passes the chance, some do not (a delay of 1 each time).
     MOVE 0 TO WS-OK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200
         MOVE 1 TO TS-DELAY
         MOVE 75 TO TS-CHANCE
         COMPUTE CW-TICKS = 1200 * (WS-I + 10)
         CALL "TRADER-TICK"
         IF TS-CHANCE = 25
             MOVE 1 TO WS-OK
         END-IF
     END-PERFORM
     MOVE "acceptance US15 19§23 within 200 beats at chance 75 a trader spawns and the chance resets to 25" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Placement.
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND (EN-TYPE(WS-E) = WS-TTYPE OR EN-TYPE(WS-E) = WS-LTYPE) AND WS-E NOT = WS-ROW
             CALL "ENTITY-REMOVE" USING WS-E
         END-IF
     END-PERFORM
     MOVE 1 TO WS-GATE
     CALL "TRADER-SPAWN" USING WS-GATE WS-OK
     MOVE "acceptance US15 19§23 the 9 in 10 gate (draw not 0) aborts the attempt" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-GATE
     CALL "TRADER-SPAWN" USING WS-GATE WS-OK
     MOVE "acceptance US15 19§23 a spawn attempt that passes the gate succeeds on open ground" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-TRADERS WS-LLAMAS
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = WS-TTYPE AND WS-E NOT = WS-ROW
             ADD 1 TO WS-TRADERS
             MOVE WS-E TO WS-I
         END-IF
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = WS-LTYPE
             ADD 1 TO WS-LLAMAS
         END-IF
     END-PERFORM
     MOVE "acceptance US15 19§23 one new trader exists" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-TRADERS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§23 two trader llamas came with it" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-LLAMAS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-I TO WS-ROW
     CALL "VL-FIND" USING EN-ID(WS-ROW) WS-NO WS-SLOT
     MOVE "acceptance US15 19§23 the new trader has despawn delay 48000" TO TL-CASE
     MOVE 48000 TO TL-EXPECTED-N
     MOVE VL-DESPAWN(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-NEAR
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = WS-LTYPE
             IF FUNCTION ABS(EN-X(WS-E) - EN-X(WS-ROW)) <= 4.5 AND FUNCTION ABS(EN-Z(WS-E) - EN-Z(WS-ROW)) <= 4.5
                 ADD 1 TO WS-NEAR
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US15 19§23 both llamas stand within 4 blocks of the trader" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-NEAR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Despawn: the delay counts down and at 0 the trader and its llamas are gone.
     MOVE 2 TO VL-DESPAWN(WS-SLOT)
     CALL "TRADER-STEP" USING WS-ROW
     MOVE "acceptance US15 19§23 the despawn delay counts down by 1 per tick" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE VL-DESPAWN(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TRADER-STEP" USING WS-ROW
     MOVE 0 TO WS-LLAMAS
     MOVE 0 TO WS-TRADERS
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = WS-LTYPE
             ADD 1 TO WS-LLAMAS
         END-IF
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = WS-TTYPE AND WS-E NOT = 0
             ADD 1 TO WS-TRADERS
         END-IF
     END-PERFORM
     MOVE "acceptance US15 19§23 at 0 the trader's llamas are gone" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LLAMAS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§23 at 0 only the first trader (the test's own) is left" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-TRADERS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US15-WANDERING-TRADER.
 COPY CORETEST.
 COPY MOBSPTEST.
