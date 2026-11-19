*> Implementation test (lane 002-lane-p49s, T38501 to T38515; docs/protocol/44-residual-mob-questions-6-nether.md sections 2.11, 5.7 and 5.8, 44-3 section 2.19 B): the piglin's weapons: the
*> main-hand kind, LandRandomPos.getPosAway, the spawn weapon, the spear cycle (approach, charge, retreat, state erased), BackUpIfTooClose, the crossbow walk target and CrossbowAttack, through
*> PGW-STEP and through MOB-STEP.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-6-GEAR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 COPY PGBRAIN.
 COPY CITEMS.
 COPY XORO.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ARROW-TYPE          BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-GX                  FLOAT-LONG.
 01 WS-GY                  FLOAT-LONG.
 01 WS-GZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-CASE                PIC X(100).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 60.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-STONE-KIND          BINARY-LONG VALUE 1.
 01 WS-STONE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 01 WS-YES                 BINARY-LONG VALUE 1.
 01 WS-MAIN                BINARY-LONG.
 01 WS-CROSS               BINARY-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-ACTS                BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-RX                  FLOAT-LONG.
 01 WS-RZ                  FLOAT-LONG.
 01 WS-MINR                FLOAT-LONG.
 01 WS-MAXR                FLOAT-LONG.
 01 WS-V                   BINARY-LONG VALUE 7.
 01 WS-DOT                 FLOAT-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-BABIES              BINARY-LONG.
 01 WS-CROSSBOWS           BINARY-LONG.
 01 WS-SPEARS              BINARY-LONG.
 01 WS-SWORDS              BINARY-LONG.
 01 WS-WALK                FLOAT-LONG.
 01 WS-ARROWS              BINARY-LONG.
 01 WS-START-X             FLOAT-LONG.
 01 WS-FAR                 FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-FX = FUNCTION INTEGER(WS-X) - 30
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) - 30
*>   A floor of nine layers (the upper call clears the air over each lower one), so that there is solid ground under every cell the piglin could walk to.
     PERFORM VARYING WS-I FROM 9 BY -1 UNTIL WS-I < 1
         COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) - WS-I
         CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-STONE-KIND
     END-PERFORM
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE "minecraft:piglin" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "STDMOB-INDEX" USING WS-TYPE WS-M
     CALL "ARROW-TYPE" USING WS-ARROW-TYPE
     MOVE 2 TO BW-DIFFICULTY
*>   Clear the air over the floor so that nothing blocks sight or the sweep: a column of 60 x 5 x 60 is already air (three layers); the player stands on the floor.
     COMPUTE WS-GX = FUNCTION INTEGER(WS-X) + 0.5
     MOVE WS-Y TO WS-GY
     COMPUTE WS-GZ = FUNCTION INTEGER(WS-Z) + 0.5
     COMPUTE WS-WALK = SM-WALK-MILLI(WS-M) / 1000

*>   The main-hand kind (5.8, 2.11): a crossbow, a spear (golden by code, iron by item id), a sword and an empty hand.
     PERFORM SPAWN-PIGLIN
     MOVE 13 TO EN-HAND(WS-ROW)
     CALL "PGW-HAND-KIND" USING WS-ROW WS-MAIN WS-CROSS
     MOVE "acceptance US15 44-6 5.8: a crossbow in the main hand is kind 1" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-MAIN TO WS-OBS
     PERFORM CHK
     MOVE "acceptance US15 44-6 5.7: a crossbow in the main hand counts for BackUpIfTooClose" TO WS-CASE
     MOVE WS-CROSS TO WS-OBS
     PERFORM CHK
     MOVE 12 TO EN-HAND(WS-ROW)
     CALL "PGW-HAND-KIND" USING WS-ROW WS-MAIN WS-CROSS
     MOVE "acceptance US15 44-6 2.11: a golden spear is kind 2" TO WS-CASE
     MOVE 2 TO WS-EXP
     MOVE WS-MAIN TO WS-OBS
     PERFORM CHK
     MOVE "acceptance US15 44-6 5.7: a spear is no crossbow" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-CROSS TO WS-OBS
     PERFORM CHK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IT-COUNT
         IF IT-KEY(WS-I) = "minecraft:iron_spear" OR IT-KEY(WS-I) = "iron_spear"
             COMPUTE EN-HAND(WS-ROW) = 1000 + WS-I - 1
         END-IF
     END-PERFORM
     CALL "PGW-HAND-KIND" USING WS-ROW WS-MAIN WS-CROSS
     MOVE "acceptance US15 44-6 2.11: an iron spear held by item id is kind 2" TO WS-CASE
     MOVE 2 TO WS-EXP
     MOVE WS-MAIN TO WS-OBS
     PERFORM CHK
     MOVE 11 TO EN-HAND(WS-ROW)
     CALL "PGW-HAND-KIND" USING WS-ROW WS-MAIN WS-CROSS
     MOVE "acceptance US15 44-6 2.11: a golden sword is no spear nor crossbow" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-MAIN TO WS-OBS
     PERFORM CHK
     MOVE 0 TO EN-HAND(WS-ROW)
     CALL "PGW-HAND-KIND" USING WS-ROW WS-MAIN WS-CROSS
     MOVE "acceptance US15 44-6 2.11: an empty hand is kind 0" TO WS-CASE
     MOVE WS-MAIN TO WS-OBS
     PERFORM CHK
     CALL "PGB-SLOT" USING EN-ID(WS-ROW) WS-YES WS-SLOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IT-COUNT
         IF IT-KEY(WS-I) = "minecraft:crossbow" OR IT-KEY(WS-I) = "crossbow"
             MOVE WS-I TO PG-OFFHAND(WS-SLOT)
         END-IF
     END-PERFORM
     CALL "PGW-HAND-KIND" USING WS-ROW WS-MAIN WS-CROSS
     MOVE "acceptance US15 44-6 5.7: a crossbow in the off hand counts for BackUpIfTooClose" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-CROSS TO WS-OBS
     PERFORM CHK
     MOVE 0 TO PG-OFFHAND(WS-SLOT)
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   getPosAway (44-3 2.19 B): ranges 4 to 6 away from a point 3 east: found, within the box of the maximum range, away from the point; no range gives none; a zero vector still finds one.
     PERFORM SPAWN-PIGLIN
     MOVE 4 TO WS-MINR
     MOVE 6 TO WS-MAXR
     COMPUTE WS-RX = WS-GX + 3
     MOVE WS-GZ TO WS-RZ
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10 OR WS-FOUND = 1
         CALL "PGW-POS-AWAY" USING WS-ROW WS-MINR WS-MAXR WS-V WS-RX WS-RZ WS-FOUND WS-HX WS-HZ
     END-PERFORM
     MOVE "acceptance US15 44-6 2.19B: getPosAway finds a position on the floor" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-FOUND TO WS-OBS
     PERFORM CHK
     MOVE "acceptance US15 44-6 2.19B: the position is within the maximum range on each axis (+ the cell)" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF FUNCTION ABS(WS-HX - WS-GX) <= WS-MAXR + 1 AND FUNCTION ABS(WS-HZ - WS-GZ) <= WS-MAXR + 1
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM CHK
     COMPUTE WS-DOT = (WS-HX - WS-GX) * (WS-GX - WS-RX) + (WS-HZ - WS-GZ) * (WS-GZ - WS-RZ)
     MOVE "acceptance US15 44-6 2.19B: the position is not toward the avoided point" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-DOT > -3
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM CHK
     MOVE "acceptance US15 44-6 2.19B: the position is the bottom centre of a cell" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION MOD(WS-HX * 2, 2)
     PERFORM CHK
     MOVE -1 TO WS-MAXR
     CALL "PGW-POS-AWAY" USING WS-ROW WS-MINR WS-MAXR WS-V WS-RX WS-RZ WS-FOUND WS-HX WS-HZ
     MOVE "acceptance US15 44-6 2.19B: a negative maximum range rejects every candidate" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-FOUND TO WS-OBS
     PERFORM CHK
     MOVE 6 TO WS-MAXR
     MOVE EN-X(WS-ROW) TO WS-RX
     MOVE EN-Z(WS-ROW) TO WS-RZ
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10 OR WS-FOUND = 1
         CALL "PGW-POS-AWAY" USING WS-ROW WS-MINR WS-MAXR WS-V WS-RX WS-RZ WS-FOUND WS-HX WS-HZ
     END-PERFORM
     MOVE "acceptance US15 44-6 2.19B: from the mob's own position a random direction is used" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-FOUND TO WS-OBS
     PERFORM CHK
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   Hanging 40 blocks over the floor nothing is stable ground within 7 blocks.
     COMPUTE WS-GY = WS-Y + 40
     PERFORM SPAWN-PIGLIN
     COMPUTE WS-RX = WS-GX + 3
     CALL "PGW-POS-AWAY" USING WS-ROW WS-MINR WS-MAXR WS-V WS-RX WS-RZ WS-FOUND WS-HX WS-HZ
     MOVE "acceptance US15 44-6 2.19B: no stable ground within the vertical range gives none" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-FOUND TO WS-OBS
     PERFORM CHK
     CALL "ENTITY-REMOVE" USING WS-ROW
     MOVE WS-Y TO WS-GY

*>   The spawn weapon (5.8 (a)): over 500 finalized piglins a fifth are babies; of the adults half hold a crossbow, a twentieth a golden spear, the rest a golden sword.
     PERFORM SPAWN-PIGLIN
     MOVE 0 TO WS-BABIES WS-CROSSBOWS WS-SPEARS WS-SWORDS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 500
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         MOVE 0 TO EN-HAND(WS-ROW) EN-MOBAGE(WS-ROW)
         CALL "STDMOB-FINALIZE" USING XR-STATE WS-ROW
         EVALUATE TRUE
             WHEN EN-MOBAGE(WS-ROW) < 0
                 ADD 1 TO WS-BABIES
             WHEN EN-HAND(WS-ROW) = 13
                 ADD 1 TO WS-CROSSBOWS
             WHEN EN-HAND(WS-ROW) = 12
                 ADD 1 TO WS-SPEARS
             WHEN EN-HAND(WS-ROW) = 11
                 ADD 1 TO WS-SWORDS
         END-EVALUATE
     END-PERFORM
     MOVE "acceptance US15 44-6 5.8: every finalized piglin is a baby or holds one of the three weapons" TO WS-CASE
     MOVE 500 TO WS-EXP
     COMPUTE WS-OBS = WS-BABIES + WS-CROSSBOWS + WS-SPEARS + WS-SWORDS
     PERFORM CHK
     MOVE "acceptance US15 44-6 5.8: about a fifth are babies (70 to 130 of 500)" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-BABIES >= 70 AND WS-BABIES <= 130
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM CHK
     MOVE "acceptance US15 44-6 5.8: about half of the adults hold a crossbow" TO WS-CASE
     MOVE 0 TO WS-OBS
     COMPUTE WS-FAR = WS-CROSSBOWS * 100 / (500 - WS-BABIES)
     IF WS-FAR >= 40 AND WS-FAR <= 60
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM CHK
     MOVE "acceptance US15 44-6 5.8: a tenth of the rest hold a golden spear" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-SPEARS >= 5 AND WS-SPEARS <= 45
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM CHK
     MOVE "acceptance US15 44-6 5.8: the others hold a golden sword" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-SWORDS >= 120 AND WS-SWORDS <= 230
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM CHK
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   The spear cycle (2.11). A golden spear, the player 15 blocks east: SpearApproach starts and walks to the player.
     PERFORM SPAWN-PIGLIN
     MOVE 12 TO EN-HAND(WS-ROW)
     PERFORM TARGET-AT-15
     CALL "PGB-SLOT" USING EN-ID(WS-ROW) WS-YES WS-SLOT
     CALL "PGW-STEP" USING WS-ROW WS-HX WS-HZ WS-ACTS
     MOVE "acceptance US15 44-6 2.11: a spear piglin acts (acts 1)" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-ACTS TO WS-OBS
     PERFORM CHK
     MOVE "acceptance US15 44-6 2.11: SpearApproach sets SPEAR_STATUS APPROACH" TO WS-CASE
     MOVE PG-SP-STATUS(WS-SLOT) TO WS-OBS
     PERFORM CHK
     MOVE "acceptance US15 44-6 2.11: SpearApproach walks to the target at the walk speed" TO WS-CASE
     COMPUTE WS-EXP = FUNCTION INTEGER(WS-WALK * 10000 + 0.5)
     COMPUTE WS-OBS = FUNCTION INTEGER(WS-HX * 10000 + 0.5)
     PERFORM CHK
*>   At 8 blocks (within 10) the approach ends: CHARGING.
     PERFORM TARGET-AT-8
     CALL "PGW-STEP" USING WS-ROW WS-HX WS-HZ WS-ACTS
     MOVE "acceptance US15 44-6 2.11: within 10 blocks SpearApproach stops and SPEAR_STATUS is CHARGING" TO WS-CASE
     MOVE 2 TO WS-EXP
     MOVE PG-SP-STATUS(WS-SLOT) TO WS-OBS
     PERFORM CHK
*>   The next tick starts SpearAttack: using the item, engage time delay + damage max ticks (golden spear 14 + 275).
     CALL "PGW-STEP" USING WS-ROW WS-HX WS-HZ WS-ACTS
     MOVE "acceptance US15 44-6 2.11: SpearAttack starts using the item" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE PG-USING(WS-SLOT) TO WS-OBS
     PERFORM CHK
     MOVE "acceptance US15 44-6 2.11: SPEAR_ENGAGE_TIME is delay_ticks + the damage max ticks (289 less this tick)" TO WS-CASE
     MOVE 288 TO WS-EXP
     MOVE PG-SP-ENGAGE(WS-SLOT) TO WS-OBS
     PERFORM CHK
*>   Closer than 2 blocks: a reposition point 4.5 to 5.5-ish away is picked.
     COMPUTE WS-X = EN-X(WS-ROW) + 1.5
     MOVE WS-X TO PL-X(WS-PLAYER)
     MOVE 0 TO PG-SP-CSET(WS-SLOT)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10 OR PG-SP-CSET(WS-SLOT) = 1
         CALL "PGW-STEP" USING WS-ROW WS-HX WS-HZ WS-ACTS
     END-PERFORM
     MOVE "acceptance US15 44-6 2.11: closer than 2 blocks SpearAttack sets SPEAR_CHARGE_POSITION" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE PG-SP-CSET(WS-SLOT) TO WS-OBS
     PERFORM CHK
     MOVE "acceptance US15 44-6 2.11: the charge position is away from the target" TO WS-CASE
     MOVE 0 TO WS-OBS
     COMPUTE WS-DOT = (PG-SP-CX(WS-SLOT) - EN-X(WS-ROW)) * (EN-X(WS-ROW) - PL-X(WS-PLAYER))
         + (PG-SP-CZ(WS-SLOT) - EN-Z(WS-ROW)) * (EN-Z(WS-ROW) - PL-Z(WS-PLAYER))
     IF WS-DOT > -3
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM CHK
*>   With a charge position the next tick walks to it.
     CALL "PGW-STEP" USING WS-ROW WS-HX WS-HZ WS-ACTS
     MOVE "acceptance US15 44-6 2.11: SpearAttack walks to the charge position" TO WS-CASE
     COMPUTE WS-DOT = WS-HX * (PG-SP-CX(WS-SLOT) - EN-X(WS-ROW)) + WS-HZ * (PG-SP-CZ(WS-SLOT) - EN-Z(WS-ROW))
     MOVE 0 TO WS-OBS
     IF WS-DOT > 0
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM CHK
*>   The engagement ends: not using, SPEAR_STATUS RETREAT.
     MOVE 1 TO PG-SP-ENGAGE(WS-SLOT)
     CALL "PGW-STEP" USING WS-ROW WS-HX WS-HZ WS-ACTS
     CALL "PGW-STEP" USING WS-ROW WS-HX WS-HZ WS-ACTS
     MOVE "acceptance US15 44-6 2.11: the engagement ends with SPEAR_STATUS RETREAT" TO WS-CASE
     MOVE 3 TO WS-EXP
     MOVE PG-SP-STATUS(WS-SLOT) TO WS-OBS
     PERFORM CHK
     MOVE "acceptance US15 44-6 2.11: the engagement ends with the item put down" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE PG-USING(WS-SLOT) TO WS-OBS
     PERFORM CHK
*>   SpearRetreat starts at the next tick with a fleeing position and runs; at 100 ticks of fleeing it erases everything.
     PERFORM TARGET-AT-8
     PERFORM RETREAT-START
     MOVE "acceptance US15 44-6 2.11: SpearRetreat has a fleeing position" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE PG-SP-FSET(WS-SLOT) TO WS-OBS
     PERFORM CHK
     MOVE "acceptance US15 44-6 2.11: SpearRetreat is the running behaviour" TO WS-CASE
     MOVE 3 TO WS-EXP
     MOVE PG-SP-RUN(WS-SLOT) TO WS-OBS
     PERFORM CHK
     MOVE 99 TO PG-SP-FTIME(WS-SLOT)
     CALL "PGW-STEP" USING WS-ROW WS-HX WS-HZ WS-ACTS
     CALL "PGW-STEP" USING WS-ROW WS-HX WS-HZ WS-ACTS
     MOVE "acceptance US15 44-6 2.11: after 100 ticks of fleeing SPEAR_STATUS is erased" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE PG-SP-STATUS(WS-SLOT) TO WS-OBS
     PERFORM CHK
     MOVE "acceptance US15 44-6 2.11: after the retreat no spear behaviour runs" TO WS-CASE
     MOVE PG-SP-RUN(WS-SLOT) TO WS-OBS
     PERFORM CHK
*>   A spear piglin that loses its target stops its running behaviour with its stop effects (attack: RETREAT).
     PERFORM TARGET-AT-15
     CALL "PGW-STEP" USING WS-ROW WS-HX WS-HZ WS-ACTS
     MOVE 0 TO EN-TARGET(WS-ROW) EN-TARGET-ID(WS-ROW)
     CALL "PGW-STEP" USING WS-ROW WS-HX WS-HZ WS-ACTS
     MOVE "acceptance US15 44-6 2.11: without a target SpearApproach stops with CHARGING" TO WS-CASE
     MOVE 2 TO WS-EXP
     MOVE PG-SP-STATUS(WS-SLOT) TO WS-OBS
     PERFORM CHK
     MOVE "acceptance US15 44-6 2.11: without a target nothing acts" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-ACTS TO WS-OBS
     PERFORM CHK
     PERFORM TARGET-AT-8
     CALL "PGW-STEP" USING WS-ROW WS-HX WS-HZ WS-ACTS
     MOVE 0 TO EN-TARGET(WS-ROW) EN-TARGET-ID(WS-ROW)
     CALL "PGW-STEP" USING WS-ROW WS-HX WS-HZ WS-ACTS
     MOVE "acceptance US15 44-6 2.11: without a target SpearAttack stops with RETREAT and the item down" TO WS-CASE
     MOVE 3 TO WS-EXP
     COMPUTE WS-OBS = PG-SP-STATUS(WS-SLOT) + PG-USING(WS-SLOT) * 10
     PERFORM CHK
     PERFORM TARGET-AT-8
     PERFORM RETREAT-START
     MOVE 0 TO EN-TARGET(WS-ROW) EN-TARGET-ID(WS-ROW)
     CALL "PGW-STEP" USING WS-ROW WS-HX WS-HZ WS-ACTS
     MOVE "acceptance US15 44-6 2.11: without a target SpearRetreat erases the state" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE PG-SP-STATUS(WS-SLOT) TO WS-OBS
     PERFORM CHK
*>   Putting the spear away erases the memory.
     PERFORM TARGET-AT-15
     CALL "PGW-STEP" USING WS-ROW WS-HX WS-HZ WS-ACTS
     MOVE 11 TO EN-HAND(WS-ROW)
     CALL "PGW-STEP" USING WS-ROW WS-HX WS-HZ WS-ACTS
     MOVE "acceptance US15 44-6 2.11: a sword in hand clears the spear state and nothing acts" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS = PG-SP-STATUS(WS-SLOT) + WS-ACTS
     PERFORM CHK
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   BackUpIfTooClose (5.7) and the walk target of a crossbow user: 3 blocks backs up at 0.75, 6 blocks stands still, 12 blocks is left to the chase.
     PERFORM SPAWN-PIGLIN
     MOVE 13 TO EN-HAND(WS-ROW)
     CALL "PGB-SLOT" USING EN-ID(WS-ROW) WS-YES WS-SLOT
     MOVE WS-ROW TO WS-J
     PERFORM TARGET-AT-3
     CALL "PGW-STEP" USING WS-ROW WS-HX WS-HZ WS-ACTS
     MOVE "acceptance US15 44-6 5.7: a crossbow user within 5 blocks backs up (acts 1)" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-ACTS TO WS-OBS
     PERFORM CHK
     MOVE "acceptance US15 44-6 5.7: BackUpIfTooClose walks away at 0.75 of the speed" TO WS-CASE
     COMPUTE WS-EXP ROUNDED = 0 - WS-WALK * 0.75 * 10000
     COMPUTE WS-OBS ROUNDED = WS-HX * 10000
     PERFORM CHK
     PERFORM TARGET-AT-6
     CALL "PGW-STEP" USING WS-ROW WS-HX WS-HZ WS-ACTS
     MOVE "acceptance US15 44-6 5.8: a crossbow user within 8 blocks of a target it sees acts" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-ACTS TO WS-OBS
     PERFORM CHK
     MOVE "acceptance US15 44-6 5.8: it stands still there" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(FUNCTION ABS(WS-HX) * 10000) + FUNCTION INTEGER(FUNCTION ABS(WS-HZ) * 10000)
     PERFORM CHK
     PERFORM TARGET-AT-12
     CALL "PGW-STEP" USING WS-ROW WS-HX WS-HZ WS-ACTS
     MOVE "acceptance US15 44-6 5.8: farther than 8 blocks the chase applies (acts 0)" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-ACTS TO WS-OBS
     PERFORM CHK
*>   A wall between them: the target is not seen, so it does not stand and it does not shoot.
     PERFORM TARGET-AT-6
     COMPUTE WS-FX = FUNCTION INTEGER(WS-GX) + 3
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 3
         COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) + WS-I
         COMPUTE WS-FZ = FUNCTION INTEGER(WS-GZ)
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-STONE
     END-PERFORM
     CALL "PGW-STEP" USING WS-ROW WS-HX WS-HZ WS-ACTS
     MOVE "acceptance US15 44-6 5.8: behind a wall the target is not seen (acts 0)" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-ACTS TO WS-OBS
     PERFORM CHK
     MOVE "acceptance US15 44-6 5.8: behind a wall CrossbowAttack does not start" TO WS-CASE
     MOVE PG-XB-RUN(WS-SLOT) TO WS-OBS
     PERFORM CHK
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 3
         COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) + WS-I
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-AIR
     END-PERFORM

*>   CrossbowAttack: draw 25 ticks, wait 20 to 39, then one arrow; no arrow before the 47th tick.
     PERFORM TARGET-AT-6
     MOVE 0 TO PG-XB-STATE(WS-SLOT) PG-XB-RUN(WS-SLOT) PG-USING(WS-SLOT)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 46
         CALL "PGW-STEP" USING WS-ROW WS-HX WS-HZ WS-ACTS
     END-PERFORM
     PERFORM COUNT-ARROWS
     MOVE "acceptance US15 44-6 5.8: no arrow within 46 ticks (charge 25 + delay 20 at the least)" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-ARROWS TO WS-OBS
     PERFORM CHK
     MOVE "acceptance US15 44-6 5.8: a crossbow is loaded after the charge" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS = PG-XB-LOADED(WS-SLOT)
     PERFORM CHK
     PERFORM VARYING WS-I FROM 47 BY 1 UNTIL WS-I > 70
         CALL "PGW-STEP" USING WS-ROW WS-HX WS-HZ WS-ACTS
     END-PERFORM
     PERFORM COUNT-ARROWS
     MOVE "acceptance US15 44-6 5.8: one arrow is shot by the 70th tick" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-ARROWS TO WS-OBS
     PERFORM CHK
     MOVE "acceptance US15 44-6 5.8: after the shot the crossbow is empty and UNCHARGED or drawing again" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE PG-XB-LOADED(WS-SLOT) TO WS-OBS
     PERFORM CHK
*>   Losing the target stops the crossbow (nothing loaded, not using).
     MOVE 1 TO PG-XB-LOADED(WS-SLOT)
     MOVE 0 TO EN-TARGET(WS-ROW) EN-TARGET-ID(WS-ROW)
     CALL "PGW-STEP" USING WS-ROW WS-HX WS-HZ WS-ACTS
     MOVE "acceptance US15 44-6 5.8: without a target the crossbow stops, its charged projectile is gone" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS = PG-XB-LOADED(WS-SLOT) + PG-XB-RUN(WS-SLOT) + PG-USING(WS-SLOT)
     PERFORM CHK
*>   The run times out after 1200 ticks.
     PERFORM TARGET-AT-6
     CALL "PGW-STEP" USING WS-ROW WS-HX WS-HZ WS-ACTS
     MOVE 1200 TO PG-XB-AGE(WS-SLOT)
     CALL "PGW-STEP" USING WS-ROW WS-HX WS-HZ WS-ACTS
     MOVE "acceptance US15 44-6 5.8: CrossbowAttack times out after 1200 ticks" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE PG-XB-RUN(WS-SLOT) TO WS-OBS
     PERFORM CHK
*>   CHARGING with the item no longer in use goes back to UNCHARGED.
     PERFORM TARGET-AT-6
     MOVE 0 TO PG-XB-RUN(WS-SLOT)
     MOVE 1 TO PG-XB-STATE(WS-SLOT)
     MOVE 0 TO PG-USING(WS-SLOT) PG-XB-USED(WS-SLOT)
     CALL "PGW-STEP" USING WS-ROW WS-HX WS-HZ WS-ACTS
     MOVE "acceptance US15 44-6 5.8: CHARGING without the item in use falls back to UNCHARGED" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE PG-XB-STATE(WS-SLOT) TO WS-OBS
     PERFORM CHK
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   Through MOB-STEP: a crossbow piglin stands where it is while the player is within 8 blocks, a sword piglin walks up to the player. The piglin sees a player 6 blocks away without gold.
     PERFORM SPAWN-PIGLIN
     MOVE 13 TO EN-HAND(WS-ROW)
     MOVE 0 TO PL-MODE(WS-PLAYER)
     COMPUTE WS-X = WS-GX + 6
     MOVE WS-X TO PL-X(WS-PLAYER)
     MOVE WS-GZ TO PL-Z(WS-PLAYER)
     MOVE EN-X(WS-ROW) TO WS-START-X
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30
         CALL "MOB-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 44-6 5.8: a crossbow piglin keeps its place while the player stands 6 blocks away" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF FUNCTION ABS(EN-X(WS-ROW) - WS-START-X) < 0.5
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM CHK
     PERFORM VARYING WS-I FROM 31 BY 1 UNTIL WS-I > 110
         CALL "MOB-STEP" USING WS-ROW
     END-PERFORM
     PERFORM COUNT-ARROWS
     MOVE "acceptance US15 44-6 5.8: MOB-STEP lets the crossbow piglin shoot" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-ARROWS >= 1
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM CHK
     CALL "ENTITY-REMOVE" USING WS-ROW
     STOP RUN.
 SPAWN-PIGLIN.
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-GX WS-GY WS-GZ WS-YAW WS-ROW
     MOVE 0 TO EN-HAND(WS-ROW).
 PLACE-PLAYER.
*>   WS-FAR blocks east of the piglin, target set.
     COMPUTE WS-X = EN-X(WS-ROW) + WS-FAR
     MOVE WS-X TO PL-X(WS-PLAYER)
     MOVE EN-Z(WS-ROW) TO PL-Z(WS-PLAYER)
     MOVE EN-Y(WS-ROW) TO PL-Y(WS-PLAYER)
     MOVE WS-PLAYER TO EN-TARGET(WS-ROW)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-ROW).
 TARGET-AT-15.
     MOVE 15 TO WS-FAR
     PERFORM PLACE-PLAYER.
 TARGET-AT-12.
     MOVE 12 TO WS-FAR
     PERFORM PLACE-PLAYER.
 TARGET-AT-8.
     MOVE 8 TO WS-FAR
     PERFORM PLACE-PLAYER.
 TARGET-AT-6.
     MOVE 6 TO WS-FAR
     PERFORM PLACE-PLAYER.
 TARGET-AT-3.
     MOVE 3 TO WS-FAR
     PERFORM PLACE-PLAYER.
 COUNT-ARROWS.
     MOVE 0 TO WS-ARROWS
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > EN-COUNT
         IF EN-USED(WS-J) = 1 AND EN-TYPE(WS-J) = WS-ARROW-TYPE
             ADD 1 TO WS-ARROWS
         END-IF
     END-PERFORM.
 RETREAT-START.
*>   Steps until SpearRetreat runs (getPosAway may find nothing in an attempt).
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10 OR PG-SP-RUN(WS-SLOT) = 3
         CALL "PGW-STEP" USING WS-ROW WS-HX WS-HZ WS-ACTS
     END-PERFORM.
 CHK.
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS.
 END PROGRAM TEST-Q44-44-6-GEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 LINKAGE SECTION.
 01 L-CASE                 PIC X(100).
 01 L-EXPECTED             BINARY-LONG.
 01 L-OBSERVED             BINARY-LONG.
 PROCEDURE DIVISION USING L-CASE L-EXPECTED L-OBSERVED.
     MOVE "N" TO TL-MODE
     MOVE L-CASE TO TL-CASE
     MOVE L-EXPECTED TO TL-EXPECTED-N
     MOVE L-OBSERVED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-CHK.
 COPY CORETEST.
 COPY MOBSPTEST.
