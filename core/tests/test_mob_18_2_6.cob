*> Acceptance test (lane p49a; docs/protocol/18-mob-framework.md section 2.6 LivingEntity.aiStep, steps 4 and 11): a velocity component of a mob below 0.003 in
*> absolute value is set to 0 (so a creeping 0.002 upward speed does not lift it), and freezing: ticksFrozen +1 a tick in powder snow and -2 (never below 0)
*> otherwise, fully frozen at 140 takes 1.0 freeze damage on every 40th tick (5.0 for blaze, strider and magma cube); polar bear, stray, snow golem and wither cannot freeze.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-2-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY RULES.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-PLAYER             BINARY-LONG.
 01 WS-DIM                BINARY-LONG.
 01 WS-KEY                PIC X(112).
 01 WS-COW                BINARY-LONG.
 01 WS-BLAZE              BINARY-LONG.
 01 WS-BEAR               BINARY-LONG.
 01 WS-ENTITY-ROW         PIC X(66).
 01 WS-STATUS             BINARY-LONG.
 01 WS-ROW                BINARY-LONG.
 01 WS-BLAZE-ROW          BINARY-LONG.
 01 WS-BEAR-ROW           BINARY-LONG.
 01 WS-STILL              BINARY-LONG.
 01 WS-BX                 BINARY-LONG.
 01 WS-BY                 BINARY-LONG.
 01 WS-BZ                 BINARY-LONG.
 01 WS-FX                 BINARY-LONG.
 01 WS-FZ                 BINARY-LONG.
 01 WS-FY                 BINARY-LONG.
 01 WS-SIZE               BINARY-LONG VALUE 9.
 01 WS-KIND               BINARY-LONG VALUE 1.
 01 WS-STATE              BINARY-LONG.
 01 WS-X                  FLOAT-LONG.
 01 WS-Y                  FLOAT-LONG.
 01 WS-Z                  FLOAT-LONG.
 01 WS-YAW                FLOAT-SHORT VALUE 0.
 01 WS-TICK               BINARY-LONG.
 01 WS-HX                 FLOAT-LONG VALUE 0.
 01 WS-HZ                 FLOAT-LONG VALUE 0.
 01 WS-DY                 FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COW WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:blaze" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-BLAZE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:polar_bear" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-BEAR WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FX = WS-BX - 4
     COMPUTE WS-FZ = WS-BZ - 4
     COMPUTE WS-FY = WS-BY - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-KIND
     MOVE 6000 TO CW-TIME
     MOVE "N" TO TL-MODE

*>   Velocity clean-up: a mob hanging in the air with vy 0.002 and one with 0.004; the first has its vy cleared to 0 before gravity, the second keeps rising.
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE WS-Y = WS-BY + 3
     COMPUTE WS-Z = WS-BZ + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-COW WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 0.002 TO EN-VY(WS-ROW)
     CALL "MOB-PHYSICS" USING WS-ROW WS-HX WS-HZ WS-YAW
     MOVE "acceptance US15 18§2.6 LivingEntity.aiStep: vy 0.002 is cleared (the mob does not rise)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-Y(WS-ROW) = WS-Y
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
     CALL "MOB-SPAWN" USING WS-DIM WS-COW WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 0.004 TO EN-VY(WS-ROW)
     CALL "MOB-PHYSICS" USING WS-ROW WS-HX WS-HZ WS-YAW
     MOVE "acceptance US15 18§2.6 LivingEntity.aiStep: vy 0.004 is kept (the mob rises)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-Y(WS-ROW) > WS-Y
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   Freezing: a cow in powder snow.
     COMPUTE WS-Y = WS-BY
     MOVE "minecraft:powder_snow" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     CALL "MOB-SPAWN" USING WS-DIM WS-COW WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "MOB-SPAWN" USING WS-DIM WS-BLAZE WS-X WS-Y WS-Z WS-YAW WS-BLAZE-ROW
     CALL "MOB-SPAWN" USING WS-DIM WS-BEAR WS-X WS-Y WS-Z WS-YAW WS-BEAR-ROW
     MOVE 100 TO EN-HEALTH(WS-ROW) EN-HEALTH(WS-BLAZE-ROW) EN-HEALTH(WS-BEAR-ROW)
     PERFORM VARYING WS-TICK FROM 1 BY 1 UNTIL WS-TICK > 139
         COMPUTE CW-TICKS = WS-TICK
         PERFORM TICK-ALL
     END-PERFORM
     MOVE "acceptance US15 18§2.6 LivingEntity.aiStep: 139 ticks in powder snow count 139 ticks frozen" TO WS-CASE
     MOVE 139 TO WS-E
     MOVE EN-FROZEN(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 18§2.6 LivingEntity.aiStep: and no freeze damage yet" TO WS-CASE
     MOVE 100 TO WS-E
     MOVE EN-HEALTH(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 18§2.6 LivingEntity.aiStep: a polar bear cannot freeze" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-FROZEN(WS-BEAR-ROW) TO WS-O
     PERFORM CHECK-N
*>   Tick 140 is a multiple of 40? 140 mod 40 = 20: no damage; tick 160 does.
     COMPUTE CW-TICKS = 140
     PERFORM TICK-ALL
     MOVE "acceptance US15 18§2.6 LivingEntity.aiStep: fully frozen at 140 but tick 140 is not a 40th tick: no damage" TO WS-CASE
     MOVE 100 TO WS-E
     MOVE EN-HEALTH(WS-ROW) TO WS-O
     PERFORM CHECK-N
     PERFORM VARYING WS-TICK FROM 141 BY 1 UNTIL WS-TICK > 160
         COMPUTE CW-TICKS = WS-TICK
         PERFORM TICK-ALL
     END-PERFORM
     MOVE "acceptance US15 18§2.6 LivingEntity.aiStep: on tick 160 a frozen cow takes 1.0 freeze damage" TO WS-CASE
     MOVE 99 TO WS-E
     MOVE EN-HEALTH(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 18§2.6 LivingEntity.aiStep: a frozen blaze takes 5.0 (freeze_hurts_extra_types)" TO WS-CASE
     MOVE 95 TO WS-E
     MOVE EN-HEALTH(WS-BLAZE-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 18§2.6 LivingEntity.aiStep: the polar bear takes none" TO WS-CASE
     MOVE 100 TO WS-E
     MOVE EN-HEALTH(WS-BEAR-ROW) TO WS-O
     PERFORM CHECK-N
*>   Out of the snow the count falls by 2 a tick.
     MOVE 0 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     COMPUTE CW-TICKS = 161
     PERFORM TICK-ALL
     MOVE "acceptance US15 18§2.6 LivingEntity.aiStep: out of powder snow the count falls by 2 a tick" TO WS-CASE
     MOVE 158 TO WS-E
     MOVE EN-FROZEN(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO EN-FROZEN(WS-ROW)
     PERFORM TICK-ALL
     MOVE "acceptance US15 18§2.6 LivingEntity.aiStep: and never goes below 0" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-FROZEN(WS-ROW) TO WS-O
     PERFORM CHECK-N
*>   A frozen mob of 1 health dies of the freeze damage on a 40th tick.
     MOVE "minecraft:powder_snow" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 200 TO EN-FROZEN(WS-ROW)
     MOVE 1 TO EN-HEALTH(WS-ROW)
     COMPUTE CW-TICKS = 200
     PERFORM TICK-ALL
     MOVE "acceptance US15 18§2.6 LivingEntity.aiStep: the freeze damage can kill (a mob of 1 health)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-HEALTH(WS-ROW) TO WS-O
     PERFORM CHECK-N
     STOP RUN.

 TICK-ALL.
     MOVE 0 TO EN-HURT(WS-ROW) EN-HURT(WS-BLAZE-ROW) EN-HURT(WS-BEAR-ROW)
     CALL "M183-TICK" USING WS-ROW
     CALL "M183-TICK" USING WS-BLAZE-ROW
     CALL "M183-TICK" USING WS-BEAR-ROW.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-18-2-6.
 COPY CORETEST.
 COPY MOBSPTEST.
