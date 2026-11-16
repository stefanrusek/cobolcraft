*> Acceptance test, villager breeding (docs/protocol/19 section 22.6; lane 002-lane-mobsb4, T8800): willingness (food plus inventory food at least 12, awake, an adult), the partner within
*> 8 blocks, love mode with the birth 275 to 324 ticks later, the baby needs a vacant bed (none: no child), the baby's age -24000 and the parents' 6000, food digested, food predicates.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-VILLAGER-BREED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY VILSTATE.
 COPY VILPOIX.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-PAIRS               PIC X(160) VALUE SPACES.
 01 WS-KEY                 PIC X(112).
 01 WS-KEY24               PIC X(24).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-QD                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-HOME                BINARY-LONG VALUE 2.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-SA                  BINARY-LONG.
 01 WS-SB                  BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-YES                 BINARY-LONG.
 01 WS-WANTS               BINARY-LONG.
 01 WS-EXCESS              BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-INV                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-AT                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-A
     COMPUTE WS-X = WS-X + 2
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-B
     COMPUTE WS-X = WS-X + 20
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-C
     CALL "VL-FIND" USING EN-ID(WS-A) WS-NO WS-SA
     CALL "VL-FIND" USING EN-ID(WS-B) WS-NO WS-SB
     MOVE 1000 TO CW-TICKS
*>   Food predicates.
     MOVE 11 TO WS-INV
     CALL "VL-FOOD-FLAGS" USING WS-INV WS-WANTS WS-EXCESS
     MOVE "acceptance US15 19§22.6 inventory food 11 wants more food" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-WANTS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§22.6 inventory food 11 is no excess" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-EXCESS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 24 TO WS-INV
     CALL "VL-FOOD-FLAGS" USING WS-INV WS-WANTS WS-EXCESS
     MOVE "acceptance US15 19§22.6 inventory food 24 is an excess and wants no more" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = 10 * WS-WANTS + WS-EXCESS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Willingness.
     MOVE 5 TO VL-FOOD(WS-SA)
     MOVE 6 TO VL-INV(WS-SA)
     CALL "VL-CAN-BREED-ROW" USING WS-A WS-YES
     MOVE "acceptance US15 19§22.6 food 5 and inventory 6 are 11: not willing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-YES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO VL-INV(WS-SA)
     CALL "VL-CAN-BREED-ROW" USING WS-A WS-YES
     MOVE "acceptance US15 19§22.6 food 5 and inventory 7 are 12: willing" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-YES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO VL-SLEEP(WS-SA)
     CALL "VL-CAN-BREED-ROW" USING WS-A WS-YES
     MOVE "acceptance US15 19§22.6 a sleeping villager is not willing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-YES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO VL-SLEEP(WS-SA)
     MOVE 6000 TO EN-MOBAGE(WS-A)
     CALL "VL-CAN-BREED-ROW" USING WS-A WS-YES
     MOVE "acceptance US15 19§22.6 a villager in its breeding cooldown (age 6000) is not willing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-YES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-MOBAGE(WS-A)
     MOVE 12 TO VL-FOOD(WS-SB)
*>   The partner: B is 2 blocks away and willing, C is 22 away.
     CALL "VL-LOVE-PICK" USING WS-A WS-E
     MOVE "acceptance US15 19§22.6 the partner is the villager within 8 blocks" TO TL-CASE
     MOVE WS-B TO TL-EXPECTED-N
     MOVE WS-E TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -24000 TO EN-MOBAGE(WS-B)
     CALL "VL-LOVE-PICK" USING WS-A WS-E
     MOVE "acceptance US15 19§22.6 a baby is not a partner" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-E TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-MOBAGE(WS-B)
*>   Love mode.
     CALL "VL-LOVE-START" USING WS-A WS-B
     MOVE "acceptance US15 19§22.6 the partners are set both ways" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF VL-LOVE(WS-SA) = EN-ID(WS-B) AND VL-LOVE(WS-SB) = EN-ID(WS-A)
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-AT = VL-LOVE-AT(WS-SA) - 1000
     MOVE "acceptance US15 19§22.6 the birth is 275 to 324 ticks away" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-AT >= 275 AND WS-AT <= 324
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   No bed: the parents get no child.
     MOVE EN-COUNT TO WS-N
     COMPUTE CW-TICKS = VL-LOVE-AT(WS-SA)
     CALL "VL-LOVE-TICK" USING WS-A
     MOVE "acceptance US15 19§22.6 with no vacant bed no child is born (entity count)" TO TL-CASE
     MOVE WS-N TO TL-EXPECTED-N
     MOVE EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§22.6 with no vacant bed love ends for both" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = VL-LOVE(WS-SA) + VL-LOVE(WS-SB)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§22.6 with no vacant bed the parents' age stays 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-MOBAGE(WS-A) + EN-MOBAGE(WS-B)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A vacant bed within 48 blocks.
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 4
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     MOVE "minecraft:red_bed" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     COMPUTE WS-CX = FUNCTION INTEGER(PL-X(WS-PLAYER) / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(PL-Z(WS-PLAYER) / 16)
     MOVE 0 TO PX-DONE-N
     PERFORM 24 TIMES
         CALL "PXI-SCAN" USING WS-DIM WS-CX WS-CZ
     END-PERFORM
     MOVE 5 TO VL-FOOD(WS-SA)
     MOVE 7 TO VL-INV(WS-SA)
     MOVE 12 TO VL-FOOD(WS-SB)
     CALL "VL-LOVE-START" USING WS-A WS-B
     MOVE VL-LOVE-AT(WS-SA) TO WS-AT
*>   Love mode before the birth time: the happy particles roll (1 in 35) runs on a few hundred ticks.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 300
         COMPUTE CW-TICKS = WS-AT - 400 + WS-I
         CALL "VL-LOVE-TICK" USING WS-A
     END-PERFORM
     MOVE EN-COUNT TO WS-N
     COMPUTE CW-TICKS = VL-LOVE-AT(WS-SA) - 1
     CALL "VL-LOVE-TICK" USING WS-A
     MOVE "acceptance US15 19§22.6 before the birth time nothing is born" TO TL-CASE
     MOVE WS-N TO TL-EXPECTED-N
     MOVE EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     ADD 1 TO CW-TICKS
     CALL "VL-LOVE-TICK" USING WS-A
     MOVE 0 TO WS-BABY
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-MOBAGE(WS-E) = -24000 AND EN-TYPE(WS-E) = WS-TYPE
             MOVE WS-E TO WS-BABY
         END-IF
     END-PERFORM
     MOVE "acceptance US15 19§22.6 at the birth time a baby villager exists with age -24000" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-BABY > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§22.6 the baby has the baby flag" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-VARIANT(WS-BABY) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§22.6 both parents get age 6000" TO TL-CASE
     MOVE 12000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-MOBAGE(WS-A) + EN-MOBAGE(WS-B)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "VPX-OF" USING EN-ID(WS-BABY) WS-HOME WS-QD WS-QX WS-QY WS-QZ WS-FOUND
     MOVE "acceptance US15 19§22.6 the bed is given to the baby as its home" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§22.6 the parents eat and digest: food 5 + 7 eaten - 12 = 0, 12 - 12 = 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = VL-FOOD(WS-SA) + VL-FOOD(WS-SB) + VL-INV(WS-SA)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§22.6 love ends for both after the birth" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = VL-LOVE(WS-SA) + VL-LOVE(WS-SB)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "VL-FIND" USING EN-ID(WS-BABY) WS-NO WS-SA
     MOVE "acceptance US15 19§22.6 the baby's type is one of the seven" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SA > 0 AND VL-TYPE(WS-SA) >= 0 AND VL-TYPE(WS-SA) <= 6
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A partner that vanished ends love.
     CALL "VL-FIND" USING EN-ID(WS-A) WS-NO WS-SA
     CALL "VL-FIND" USING EN-ID(WS-B) WS-NO WS-SB
     MOVE EN-ID(WS-B) TO VL-LOVE(WS-SA)
     MOVE 99999 TO VL-LOVE-AT(WS-SA)
     CALL "ENTITY-REMOVE" USING WS-B
     CALL "VL-LOVE-TICK" USING WS-A
     MOVE "acceptance US15 19§22.6 a vanished partner ends love" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE VL-LOVE(WS-SA) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   VL-BREED-STEP: an idle willing pair starts love mode within a while (idle: day tick 11500).
     MOVE 0 TO EN-MOBAGE(WS-A)
     MOVE 12 TO VL-FOOD(WS-SA)
     MOVE "minecraft:villager" TO WS-KEY
     MOVE PL-X(WS-PLAYER) TO WS-X
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-B
     CALL "VL-FIND" USING EN-ID(WS-B) WS-NO WS-SB
     MOVE 12 TO VL-FOOD(WS-SB)
     COMPUTE EN-X(WS-B) = EN-X(WS-B) + 6
     MOVE 11500 TO CW-TIME
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3000 OR VL-LOVE(WS-SA) > 0
         ADD 1 TO CW-TICKS
         CALL "VL-BREED-STEP" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 19§22.3 an idle willing pair starts love mode" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF VL-LOVE(WS-SA) > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§22.3 the pair walks toward each other (destination set)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     MOVE 0 TO EN-COOLDOWN(WS-A)
     CALL "VL-BREED-STEP" USING WS-A
     IF EN-COOLDOWN(WS-A) > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3000 TO CW-TIME
     MOVE 0 TO VL-LOVE(WS-SA) VL-LOVE(WS-SB)
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400
         ADD 1 TO CW-TICKS
         CALL "VL-BREED-STEP" USING WS-A
         ADD VL-LOVE(WS-SA) TO WS-N
     END-PERFORM
     MOVE "acceptance US15 19§22.3 at work time (not idle) no love mode starts" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US15-VILLAGER-BREED.
 COPY CORETEST.
 COPY MOBSPTEST.
