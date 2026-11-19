*> Acceptance test, baby villagers (docs/protocol/44 part 3 sections 2.15, 4.4 and 4.5; lane 002-lane-p49q, T37006): the sensors visible_villager_babies (every 20 ticks: the baby villagers of
*> nearest_visible_living_entities, here within 16 blocks, no adults, none farther) and nearest_bed (a baby only: the home bed within 48 blocks that a path reaches), and PlayTagWithOtherKids in the play
*> activity: one baby chases another (interaction_target = the chased one, walk_target at speed 0.6 = 1.2 s, closeness 1) and a baby that is chased flees to a village position (speed 0.6) when there is one.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-VILLAGER-KIDS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 COPY VLMEM.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-LONG.
 01 WS-O                   BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-K1                  BINARY-LONG.
 01 WS-S1                  BINARY-LONG.
 01 WS-K2                  BINARY-LONG.
 01 WS-S2                  BINARY-LONG.
 01 WS-K3                  BINARY-LONG.
 01 WS-S3                  BINARY-LONG.
 01 WS-AD                  BINARY-LONG.
 01 WS-SAD                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-I                   BINARY-LONG.
 01 WS-PRESENT             BINARY-LONG.
 01 WS-QD                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-N1                  BINARY-LONG.
 01 WS-N2                  BINARY-LONG.
 01 WS-CHASED              BINARY-LONG.
 01 WS-SPEED-OK            BINARY-LONG.
 01 WS-BABY                BINARY-LONG VALUE 1.
 01 WS-ACT                 BINARY-LONG.
 01 WS-HOME                BINARY-LONG VALUE 2.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     CALL "VT-FLAT" USING WS-PLAYER WS-FY
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 6
     COMPUTE WS-Y = WS-FY + 1
     COMPUTE WS-X = WS-X0 + 6
     COMPUTE WS-Z = WS-Z0 + 4
     MOVE "minecraft:red_bed" TO WS-KEY
     MOVE "facing=north,occupied=false,part=head" TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-Z WS-KEY WS-PAIRS
     CALL "VT-SCAN" USING WS-DIM WS-X0 WS-Z0
     CALL "VT-SPAWN" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-K1 WS-S1
     COMPUTE WS-X = WS-X0 + 3
     CALL "VT-SPAWN" USING WS-DIM WS-X WS-Y WS-Z0 WS-K2 WS-S2
     COMPUTE WS-X = WS-X0 - 3
     CALL "VT-SPAWN" USING WS-DIM WS-X WS-Y WS-Z0 WS-AD WS-SAD
     COMPUTE WS-Z = WS-Z0 + 27
     CALL "VT-SPAWN" USING WS-DIM WS-X0 WS-Y WS-Z WS-K3 WS-S3
     MOVE -24000 TO EN-MOBAGE(WS-K1) EN-MOBAGE(WS-K2) EN-MOBAGE(WS-K3)
     MOVE 5000 TO CW-TIME
     MOVE 1000 TO CW-TICKS
     MOVE 0 TO WS-CHASED
     PERFORM 100 TIMES
         ADD 1 TO CW-TICKS
         CALL "STDMOB-STEP" USING WS-K1
         CALL "STDMOB-STEP" USING WS-K2
         CALL "STDMOB-STEP" USING WS-AD
         CALL "STDMOB-STEP" USING WS-K3
         CALL "VM-HAS" USING WS-S1 MT-INTERACTION-TARGET WS-PRESENT
         IF WS-PRESENT = 1
             MOVE 1 TO WS-CHASED
         END-IF
         CALL "VM-HAS" USING WS-S2 MT-INTERACTION-TARGET WS-PRESENT
         IF WS-PRESENT = 1
             MOVE 1 TO WS-CHASED
         END-IF
     END-PERFORM
*>   visible_villager_babies: one baby in sight of K1 (K2; not the adult, not K3 27 blocks away).
     CALL "VM-GET" USING WS-S1 MT-VISIBLE-BABIES WS-PRESENT WS-QD WS-QX WS-QY WS-QZ WS-N1 WS-N2
     MOVE "acceptance US15 44-3§4.4 a baby sees the other baby villager in the list: present" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-PRESENT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 44-3§4.4 the list holds one baby (not the adult, not the one 27 blocks away)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-N1 TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "VM-HAS" USING WS-SAD MT-VISIBLE-BABIES WS-PRESENT
     MOVE "acceptance US15 44-3§4.4 (the sensor runs for babies only here: an adult has no list)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-PRESENT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   nearest_bed: the bed 6 blocks away that a path reaches is the baby's nearest bed; an adult has none.
     CALL "VM-GET" USING WS-S1 MT-NEAREST-BED WS-PRESENT WS-QD WS-QX WS-QY WS-QZ WS-N1 WS-N2
     MOVE "acceptance US15 44-3§4.5 the baby's nearest_bed is the bed" TO WS-CASE
     COMPUTE WS-E = WS-X0 + 6
     MOVE WS-QX TO WS-O
     IF WS-PRESENT = 0
         MOVE -1 TO WS-O
     END-IF
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "VM-HAS" USING WS-SAD MT-NEAREST-BED WS-PRESENT
     MOVE "acceptance US15 44-3§4.5 an adult has no nearest_bed (the sensor acts for a baby only)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-PRESENT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   PlayTagWithOtherKids: within 100 ticks of play one baby has chased the other.
     MOVE "acceptance US15 44-3§2.15 a baby chases another (interaction_target set)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-CHASED TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   A chasing baby: walk to the chased one at 1.2 s, closeness 1.
     MOVE 5000 TO CW-TIME
     CALL "VL-WALK-STOP" USING WS-K1 WS-S1
     CALL "VL-WALK-STOP" USING WS-K2 WS-S2
     CALL "VM-ERASE" USING WS-S1 MT-INTERACTION-TARGET
     CALL "VM-ERASE" USING WS-S2 MT-INTERACTION-TARGET
     MOVE 0 TO WS-SPEED-OK
     MOVE 4 TO WS-ACT
     PERFORM 200 TIMES
         ADD 1 TO CW-TICKS
         CALL "VL-KIDS-TICK" USING WS-K1 WS-S1 WS-BABY WS-ACT
         CALL "VM-GET" USING WS-S1 MT-WALK-TARGET WS-PRESENT WS-QD WS-QX WS-QY WS-QZ WS-N1 WS-N2
         IF WS-PRESENT = 1 AND WS-N1 = 1200 AND WS-N2 = 1
             MOVE 1 TO WS-SPEED-OK
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-3§2.15 the chaser walks at 0.6 (1.2 s) with closeness 1" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-SPEED-OK TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   A baby that is chased flees to a position of a village (a claimed bed makes the sections round it a village): walk_target at 0.6 (1.2 s), closeness 0.
     CALL "VL-WALK-STOP" USING WS-K1 WS-S1
     CALL "VL-WALK-STOP" USING WS-K2 WS-S2
     CALL "VM-ERASE" USING WS-S2 MT-INTERACTION-TARGET
     COMPUTE WS-X = WS-X0 + 6
     COMPUTE WS-Z = WS-Z0 + 4
     CALL "VPX-CLAIM" USING EN-ID(WS-AD) WS-HOME WS-DIM WS-X WS-Y WS-Z
     CALL "VM-NOTE" USING WS-S1 MT-INTERACTION-TARGET EN-ID(WS-K2)
     MOVE 0 TO WS-SPEED-OK
     PERFORM 200 TIMES
         ADD 1 TO CW-TICKS
         CALL "VL-KIDS-TICK" USING WS-K2 WS-S2 WS-BABY WS-ACT
         CALL "VM-GET" USING WS-S2 MT-WALK-TARGET WS-PRESENT WS-QD WS-QX WS-QY WS-QZ WS-N1 WS-N2
         IF WS-PRESENT = 1 AND WS-N1 = 1200 AND WS-N2 = 0
             MOVE 1 TO WS-SPEED-OK
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-3§2.15 a chased baby flees at 0.6 (1.2 s) with closeness 0" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-SPEED-OK TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "VM-HAS" USING WS-S2 MT-INTERACTION-TARGET WS-PRESENT
     MOVE "acceptance US15 44-3§2.15 the fleeing baby does not chase (interaction_target stays absent)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-PRESENT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM ACC-US15-VILLAGER-KIDS.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY Q3TEST.
 COPY VILLTEST.
