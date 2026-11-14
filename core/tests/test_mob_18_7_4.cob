*> Acceptance test (US15, FR-036, SC-008; docs/protocol/18-mob-framework.md section 7.4 and the knockback numbers of 10.4): the knockback of a fresh hit on a mob.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-7-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY RULES.
 01 WS-CASE               PIC X(240).
 01 WS-E                  FLOAT-LONG.
 01 WS-O                  FLOAT-LONG.
 01 WS-PLAYER             BINARY-LONG.
 01 WS-DIM                BINARY-LONG.
 01 WS-X0                 BINARY-LONG.
 01 WS-Z0                 BINARY-LONG.
 01 WS-FY                 BINARY-LONG.
 01 WS-SIZE               BINARY-LONG VALUE 24.
 01 WS-KIND               BINARY-LONG VALUE 1.
 01 WS-KEY                PIC X(112).
 01 WS-ENTITY-ROW         PIC X(66).
 01 WS-STATUS             BINARY-LONG.
 01 WS-PIG-TYPE           BINARY-LONG.
 01 WS-GOLEM-TYPE         BINARY-LONG.
 01 WS-PIG                BINARY-LONG.
 01 WS-GOLEM              BINARY-LONG.
 01 WS-X                  FLOAT-LONG.
 01 WS-Y                  FLOAT-LONG.
 01 WS-Z                  FLOAT-LONG.
 01 WS-YAW                FLOAT-SHORT VALUE 0.
 01 WS-AMOUNT             BINARY-LONG.
 01 WS-CAUSE              BINARY-LONG.
 01 WS-SPECIES            PIC X(24).
 01 WS-MILLI              BINARY-LONG.
 01 WS-BEFORE             FLOAT-LONG.
 01 WS-SRC-X              FLOAT-LONG.
 01 WS-SRC-Z              FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 20
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 12
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 40
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FY WS-KIND
     MOVE "minecraft:pig" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-PIG-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:iron_golem" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-GOLEM-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = WS-X0 + 12.5
     COMPUTE WS-Y = WS-FY + 1
     COMPUTE WS-Z = WS-Z0 + 12.5
     CALL "MOB-SPAWN" USING WS-DIM WS-PIG-TYPE WS-X WS-Y WS-Z WS-YAW WS-PIG
     MOVE 1 TO EN-ON-GROUND(WS-PIG)
     MOVE 0 TO EN-HURT(WS-PIG)
*>   The numbers of 10.4: the source 2 blocks toward negative z, so the victim goes away from it, up and toward positive z.
     MOVE WS-X TO PL-X(WS-PLAYER)
     COMPUTE PL-Z(WS-PLAYER) = WS-Z - 2
     MOVE 1 TO WS-AMOUNT
     MOVE CAUSE-PLAYER TO WS-CAUSE
     CALL "HEALTH-MOB-DAMAGE" USING WS-PIG WS-AMOUNT WS-CAUSE WS-PLAYER
     MOVE "acceptance US15 18§7.4 Knockback: a fresh hit on a standing victim gives vx 0 (the source is straight toward negative z)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-VX(WS-PIG) TO WS-O
     PERFORM CHECK-F
     MOVE "acceptance US15 18§7.4 Knockback: vy is min(0.4, vy / 2 + 0.4) = 0.4 on the ground" TO WS-CASE
     MOVE 0.4 TO WS-E
     MOVE EN-VY(WS-PIG) TO WS-O
     PERFORM CHECK-F
     MOVE "acceptance US15 18§7.4 Knockback: vz is +0.4, away from the source" TO WS-CASE
     MOVE 0.4 TO WS-E
     MOVE EN-VZ(WS-PIG) TO WS-O
     PERFORM CHECK-F
*>   A hit inside the window that is stronger applies only the difference and is not fresh: no knockback.
     MOVE 0 TO EN-VX(WS-PIG) EN-VY(WS-PIG) EN-VZ(WS-PIG)
     MOVE 2 TO WS-AMOUNT
     CALL "HEALTH-MOB-DAMAGE" USING WS-PIG WS-AMOUNT WS-CAUSE WS-PLAYER
     MOVE "acceptance US15 18§7.3 Hurt window: a stronger hit inside the window is not fresh, so it knocks back nothing" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = FUNCTION ABS(EN-VZ(WS-PIG)) + FUNCTION ABS(EN-VY(WS-PIG)) + FUNCTION ABS(EN-VX(WS-PIG))
     PERFORM CHECK-F
*>   The existing velocity is halved first: x = vx / 2 - delta.x; y = min(0.4, vy / 2 + 0.4).
     MOVE 0 TO EN-HURT(WS-PIG)
     MOVE 0.2 TO EN-VX(WS-PIG)
     MOVE 0.2 TO EN-VY(WS-PIG)
     MOVE 0 TO EN-VZ(WS-PIG)
     MOVE 1 TO EN-ON-GROUND(WS-PIG)
     MOVE 3 TO WS-AMOUNT
     CALL "HEALTH-MOB-DAMAGE" USING WS-PIG WS-AMOUNT WS-CAUSE WS-PLAYER
     MOVE "acceptance US15 18§7.4 Knockback: the old horizontal velocity is halved (0.2 becomes 0.1)" TO WS-CASE
     MOVE 0.1 TO WS-E
     MOVE EN-VX(WS-PIG) TO WS-O
     PERFORM CHECK-F
     MOVE "acceptance US15 18§7.4 Knockback: vy 0.2 gives min(0.4, 0.1 + 0.4) = 0.4" TO WS-CASE
     MOVE 0.4 TO WS-E
     MOVE EN-VY(WS-PIG) TO WS-O
     PERFORM CHECK-F
*>   In the air vy is kept.
     MOVE 0 TO EN-HURT(WS-PIG)
     MOVE 0 TO EN-ON-GROUND(WS-PIG)
     MOVE 0.1 TO EN-VY(WS-PIG)
     MOVE 0 TO EN-VX(WS-PIG) EN-VZ(WS-PIG)
     CALL "HEALTH-MOB-DAMAGE" USING WS-PIG WS-AMOUNT WS-CAUSE WS-PLAYER
     MOVE "acceptance US15 18§7.4 Knockback: a victim in the air keeps its vy (0.1)" TO WS-CASE
     MOVE 0.1 TO WS-E
     MOVE EN-VY(WS-PIG) TO WS-O
     PERFORM CHECK-F
*>   A source exactly above the victim has no direction: a random one is used, the strength is still 0.4 (the horizontal speed).
     MOVE 0 TO EN-HURT(WS-PIG)
     MOVE 1 TO EN-ON-GROUND(WS-PIG)
     MOVE 0 TO EN-VX(WS-PIG) EN-VY(WS-PIG) EN-VZ(WS-PIG)
     MOVE WS-Z TO PL-Z(WS-PLAYER)
     CALL "HEALTH-MOB-DAMAGE" USING WS-PIG WS-AMOUNT WS-CAUSE WS-PLAYER
     MOVE "acceptance US15 18§7.4 Knockback: with no direction a random one is taken and the push is still 0.4 long" TO WS-CASE
     MOVE 0.4 TO WS-E
     COMPUTE WS-O = FUNCTION SQRT(EN-VX(WS-PIG) * EN-VX(WS-PIG) + EN-VZ(WS-PIG) * EN-VZ(WS-PIG))
     PERFORM CHECK-F
*>   The push moves the mob in the tick.
     COMPUTE WS-X = WS-X + 4
     CALL "MOB-SPAWN" USING WS-DIM WS-PIG-TYPE WS-X WS-Y WS-Z WS-YAW WS-PIG
     COMPUTE WS-X = WS-X - 4
     MOVE 1 TO EN-ON-GROUND(WS-PIG)
     MOVE 0 TO EN-VX(WS-PIG) EN-VY(WS-PIG) EN-VZ(WS-PIG)
     MOVE 0 TO EN-HURT(WS-PIG)
     COMPUTE PL-Z(WS-PLAYER) = EN-Z(WS-PIG) - 2
     CALL "HEALTH-MOB-DAMAGE" USING WS-PIG WS-AMOUNT WS-CAUSE WS-PLAYER
     MOVE EN-Z(WS-PIG) TO WS-BEFORE
     CALL "MOB-STEP" USING WS-PIG
     MOVE "acceptance US15 18§7.4 Knockback: the next tick carries the mob away from the source" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-Z(WS-PIG) > WS-BEFORE + 0.15
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-F
*>   Knockback resistance (an attribute): strength x (1 - resistance); at 1 nothing happens.
     CALL "MOB-SPAWN" USING WS-DIM WS-GOLEM-TYPE WS-X WS-Y WS-Z WS-YAW WS-GOLEM
     MOVE 1 TO EN-ON-GROUND(WS-GOLEM)
     MOVE 0 TO EN-HURT(WS-GOLEM)
     MOVE 0 TO EN-VX(WS-GOLEM) EN-VY(WS-GOLEM) EN-VZ(WS-GOLEM)
     COMPUTE PL-Z(WS-PLAYER) = WS-Z - 2
     CALL "HEALTH-MOB-DAMAGE" USING WS-GOLEM WS-AMOUNT WS-CAUSE WS-PLAYER
     MOVE "acceptance US15 18§7.4 Knockback: an iron golem (knockback_resistance 1.0) is not moved" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = FUNCTION ABS(EN-VZ(WS-GOLEM)) + FUNCTION ABS(EN-VY(WS-GOLEM)) + FUNCTION ABS(EN-VX(WS-GOLEM))
     PERFORM CHECK-F
     MOVE "iron_golem" TO WS-SPECIES
     CALL "M187-RESIST" USING WS-SPECIES WS-MILLI
     MOVE "acceptance US15 18§7.4 Knockback: iron_golem resistance is 1000 thousandths" TO WS-CASE
     MOVE 1000 TO WS-E
     MOVE WS-MILLI TO WS-O
     PERFORM CHECK-F
     MOVE "hoglin" TO WS-SPECIES
     CALL "M187-RESIST" USING WS-SPECIES WS-MILLI
     MOVE "acceptance US15 21§5.6 Hoglin: knockback_resistance 0.6" TO WS-CASE
     MOVE 600 TO WS-E
     MOVE WS-MILLI TO WS-O
     PERFORM CHECK-F
     MOVE "zoglin" TO WS-SPECIES
     CALL "M187-RESIST" USING WS-SPECIES WS-MILLI
     MOVE "acceptance US15 21§5.6 Zoglin: knockback_resistance 0.6" TO WS-CASE
     MOVE 600 TO WS-E
     MOVE WS-MILLI TO WS-O
     PERFORM CHECK-F
     MOVE "nautilus" TO WS-SPECIES
     CALL "M187-RESIST" USING WS-SPECIES WS-MILLI
     MOVE "acceptance US15 21§4.10 Nautilus: knockback_resistance 0.3" TO WS-CASE
     MOVE 300 TO WS-E
     MOVE WS-MILLI TO WS-O
     PERFORM CHECK-F
     MOVE "zombie_nautilus" TO WS-SPECIES
     CALL "M187-RESIST" USING WS-SPECIES WS-MILLI
     MOVE "acceptance US15 21§4.10 Zombie nautilus: knockback_resistance 0.3" TO WS-CASE
     MOVE 300 TO WS-E
     MOVE WS-MILLI TO WS-O
     PERFORM CHECK-F
     MOVE "pig" TO WS-SPECIES
     CALL "M187-RESIST" USING WS-SPECIES WS-MILLI
     MOVE "acceptance US15 18§1.3 Attributes: a species with no override has knockback_resistance 0" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-MILLI TO WS-O
     PERFORM CHECK-F
*>   A partial resistance (0.5) halves the strength: the example of 10.4 gives (0, 0.2, 0.2).
     MOVE 500 TO WS-MILLI
     MOVE 0 TO EN-VX(WS-PIG) EN-VY(WS-PIG) EN-VZ(WS-PIG)
     MOVE 1 TO EN-ON-GROUND(WS-PIG)
     MOVE 400 TO WS-AMOUNT
     MOVE EN-X(WS-PIG) TO WS-SRC-X
     MOVE EN-Z(WS-PIG) TO WS-SRC-Z
     CALL "M187-KNOCK" USING WS-PIG WS-SRC-X WS-SRC-Z WS-AMOUNT WS-MILLI
     MOVE "acceptance US15 18§10.4 Knockback: strength 0.4 with resistance 0.5 gives vz 0.2 (source at the victim's z - 0 gives a random direction of length 0.2)" TO WS-CASE
     MOVE 0.2 TO WS-E
     COMPUTE WS-O = FUNCTION SQRT(EN-VX(WS-PIG) * EN-VX(WS-PIG) + EN-VZ(WS-PIG) * EN-VZ(WS-PIG))
     PERFORM CHECK-F
     MOVE "acceptance US15 18§10.4 Knockback: and vy 0.2" TO WS-CASE
     MOVE 0.2 TO WS-E
     MOVE EN-VY(WS-PIG) TO WS-O
     PERFORM CHECK-F
     STOP RUN.
 CHECK-F.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 1000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-18-7-4.
 COPY CORETEST.
 COPY MOBSPTEST.
