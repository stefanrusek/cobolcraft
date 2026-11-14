*> Acceptance test (US15, FR-036, SC-008; docs/protocol/18-mob-framework.md section 6.7, with doc 44 part 1 section 4): spawn costs.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-6-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY XORO.
 COPY MOBSPAWN.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-SEED               BINARY-DOUBLE UNSIGNED.
 01 WS-MIRROR.
    05 WS-M-LO            BINARY-DOUBLE UNSIGNED.
    05 WS-M-HI            BINARY-DOUBLE UNSIGNED.
 01 WS-POINTS.
    05 WS-PT                OCCURS 64 TIMES.
       10 WS-PT-X           FLOAT-LONG.
       10 WS-PT-Y           FLOAT-LONG.
       10 WS-PT-Z           FLOAT-LONG.
       10 WS-PT-CHARGE      FLOAT-LONG.
 01 WS-N                 BINARY-LONG VALUE 0.
 01 WS-X                 FLOAT-LONG VALUE 0.
 01 WS-Y                 FLOAT-LONG VALUE 0.
 01 WS-Z                 FLOAT-LONG VALUE 0.
 01 WS-CHARGE            FLOAT-LONG.
 01 WS-RESULT            FLOAT-LONG.
 01 WS-MILLI             BINARY-DOUBLE.
 01 WS-SSV               BINARY-LONG.
 01 WS-WARPED            BINARY-LONG.
 01 WS-PLAINS            BINARY-LONG.
 01 WS-KEY               PIC X(48).
 01 WS-MOB               PIC X(24).
 01 WS-OK                BINARY-LONG.
 01 WS-CX                FLOAT-LONG.
 01 WS-CY                FLOAT-LONG.
 01 WS-CZ                FLOAT-LONG.
 PROCEDURE DIVISION.
     MOVE 0.7 TO WS-CHARGE
     CALL "MS6-ENERGY" USING WS-POINTS WS-N WS-X WS-Y WS-Z WS-CHARGE WS-RESULT
     MOVE 0 TO WS-MILLI
     COMPUTE WS-MILLI ROUNDED = WS-RESULT * 10000
     MOVE "acceptance US15 18§6.7 Spawn costs: with no existing charge the energy change is 0" TO WS-CASE
     COMPUTE WS-E = 0
     COMPUTE WS-O = WS-MILLI
     PERFORM CHECK-N
     MOVE 1 TO WS-N
     MOVE 2.0 TO WS-PT-X(1)
     MOVE 0 TO WS-PT-Y(1) WS-PT-Z(1)
     MOVE 0.7 TO WS-PT-CHARGE(1)
     CALL "MS6-ENERGY" USING WS-POINTS WS-N WS-X WS-Y WS-Z WS-CHARGE WS-RESULT
     COMPUTE WS-MILLI ROUNDED = WS-RESULT * 10000
     MOVE "acceptance US15 18§6.7 Spawn costs: c x (q / sqrt(d2)) = 0.7 x 0.7 / 2 = 0.245" TO WS-CASE
     COMPUTE WS-E = 2450
     COMPUTE WS-O = WS-MILLI
     PERFORM CHECK-N
     MOVE 2 TO WS-N
     MOVE 0 TO WS-PT-X(2) WS-PT-Z(2)
     MOVE 4.0 TO WS-PT-Y(2)
     MOVE 0.3 TO WS-PT-CHARGE(2)
     CALL "MS6-ENERGY" USING WS-POINTS WS-N WS-X WS-Y WS-Z WS-CHARGE WS-RESULT
     COMPUTE WS-MILLI ROUNDED = WS-RESULT * 10000
     MOVE "acceptance US15 18§6.7 Spawn costs: the energies of all charges add (0.245 + 0.7 x 0.3 / 4)" TO WS-CASE
     COMPUTE WS-E = 2975
     COMPUTE WS-O = WS-MILLI
     PERFORM CHECK-N
     MOVE 0 TO WS-CHARGE
     CALL "MS6-ENERGY" USING WS-POINTS WS-N WS-X WS-Y WS-Z WS-CHARGE WS-RESULT
     COMPUTE WS-MILLI ROUNDED = WS-RESULT * 10000
     MOVE "acceptance US15 18§6.7 Spawn costs: a zero charge gives an energy change of 0" TO WS-CASE
     COMPUTE WS-E = 0
     COMPUTE WS-O = WS-MILLI
     PERFORM CHECK-N
     MOVE 0.7 TO WS-CHARGE
     MOVE 1 TO WS-N
     MOVE 0 TO WS-PT-X(1)
     CALL "MS6-ENERGY" USING WS-POINTS WS-N WS-X WS-Y WS-Z WS-CHARGE WS-RESULT
     MOVE 0 TO WS-MILLI
     IF WS-RESULT > 1000000
         MOVE 1 TO WS-MILLI
     END-IF
     MOVE "acceptance US15 18§6.7 Spawn costs: a charge at the same position makes the change infinite" TO WS-CASE
     COMPUTE WS-E = 1
     COMPUTE WS-O = WS-MILLI
     PERFORM CHECK-N
     MOVE "minecraft:soul_sand_valley" TO WS-KEY
     CALL "MS6-BIOME-FIND" USING WS-KEY WS-SSV
     MOVE "minecraft:warped_forest" TO WS-KEY
     CALL "MS6-BIOME-FIND" USING WS-KEY WS-WARPED
     MOVE "minecraft:plains" TO WS-KEY
     CALL "MS6-BIOME-FIND" USING WS-KEY WS-PLAINS
     MOVE 0 TO WS-N
     MOVE "skeleton" TO WS-MOB
     MOVE 5.0 TO WS-CX
     MOVE 0 TO WS-CY WS-CZ
     CALL "MS6-COST-OK" USING WS-SSV WS-MOB WS-POINTS WS-N WS-CX WS-CY WS-CZ WS-OK
     MOVE "acceptance US15 18§6.7 Spawn costs: a costed type passes in an empty field" TO WS-CASE
     COMPUTE WS-E = 1
     COMPUTE WS-O = WS-OK
     PERFORM CHECK-N
     CALL "MS6-COST-ADD" USING WS-SSV WS-MOB WS-POINTS WS-N WS-CX WS-CY WS-CZ
     MOVE "acceptance US15 18§6.7 Spawn costs: afterSpawn adds the new mob's charge as a point" TO WS-CASE
     COMPUTE WS-E = 1
     COMPUTE WS-O = WS-N
     PERFORM CHECK-N
     MOVE 9.0 TO WS-CX
     CALL "MS6-COST-OK" USING WS-SSV WS-MOB WS-POINTS WS-N WS-CX WS-CY WS-CZ WS-OK
     MOVE "acceptance US15 18§6.7 Spawn costs: 4 blocks from a 0.7 charge gives 0.1225, within the budget 0.15" TO WS-CASE
     COMPUTE WS-E = 1
     COMPUTE WS-O = WS-OK
     PERFORM CHECK-N
     MOVE 7.0 TO WS-CX
     CALL "MS6-COST-OK" USING WS-SSV WS-MOB WS-POINTS WS-N WS-CX WS-CY WS-CZ WS-OK
     MOVE "acceptance US15 18§6.7 Spawn costs: 2 blocks from the charge gives 0.245, over the budget 0.15" TO WS-CASE
     COMPUTE WS-E = 0
     COMPUTE WS-O = WS-OK
     PERFORM CHECK-N
     MOVE "zombie" TO WS-MOB
     CALL "MS6-COST-OK" USING WS-SSV WS-MOB WS-POINTS WS-N WS-CX WS-CY WS-CZ WS-OK
     MOVE "acceptance US15 18§6.7 Spawn costs: a type without a cost entry always passes" TO WS-CASE
     COMPUTE WS-E = 1
     COMPUTE WS-O = WS-OK
     PERFORM CHECK-N
     CALL "MS6-COST-ADD" USING WS-SSV WS-MOB WS-POINTS WS-N WS-CX WS-CY WS-CZ
     MOVE "acceptance US15 18§6.7 Spawn costs: a type without a cost adds no charge" TO WS-CASE
     COMPUTE WS-E = 1
     COMPUTE WS-O = WS-N
     PERFORM CHECK-N
     MOVE "skeleton" TO WS-MOB
     CALL "MS6-COST-OK" USING WS-PLAINS WS-MOB WS-POINTS WS-N WS-CX WS-CY WS-CZ WS-OK
     MOVE "acceptance US15 18§6.7 Spawn costs: a biome without costs passes every type" TO WS-CASE
     COMPUTE WS-E = 1
     COMPUTE WS-O = WS-OK
     PERFORM CHECK-N
     MOVE "enderman" TO WS-MOB
     MOVE 0.0 TO WS-CX
     MOVE 3.0 TO WS-PT-X(1)
     MOVE 1.0 TO WS-PT-CHARGE(1)
     CALL "MS6-COST-OK" USING WS-WARPED WS-MOB WS-POINTS WS-N WS-CX WS-CY WS-CZ WS-OK
     MOVE "acceptance US15 18§6.7 Spawn costs: warped forest enderman (charge 1.0, budget 0.12) at 3 blocks from a 1.0 charge: 0.333 is over" TO WS-CASE
     COMPUTE WS-E = 0
     COMPUTE WS-O = WS-OK
     PERFORM CHECK-N

     MOVE 64 TO WS-N
     MOVE "skeleton" TO WS-MOB
     CALL "MS6-COST-ADD" USING WS-SSV WS-MOB WS-POINTS WS-N WS-CX WS-CY WS-CZ
     MOVE "acceptance US15 18§6.7 Spawn costs: at most 64 points are kept" TO WS-CASE
     MOVE 64 TO WS-E
     MOVE WS-N TO WS-O
     PERFORM CHECK-N
     STOP RUN.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-18-6-7.
