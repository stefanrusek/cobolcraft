*> Acceptance test of docs/protocol/42-particles-1-shared-model-engine.md section 5 (engine core: groups,
*> limits, culling, order): render types and group classes, creation and the per-type limit (E5), the
*> per-group limit and reservoir (E4), the tick order of 5.5, the F3 counter string, the render order,
*> frustum culling by point, the tracking emitter (E10), the item pickup particle (E8), elder guardian (E9).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PARTICLES-42-1-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLENG.
 COPY TESTLIB.
 01 WS-NAME                PIC X(160).
 01 WS-GROUP               BINARY-LONG.
 01 WS-SHORT               PIC X(2).
 01 WS-CLASS               PIC X(32).
 01 WS-LIMITED             BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-DRAW                FLOAT-LONG.
 01 WS-DREW                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DRAWS.
    05 WS-D                FLOAT-LONG OCCURS 48 TIMES.
 01 WS-TEXT                PIC X(64).
 01 WS-ORDER.
    05 WS-ORD              BINARY-LONG OCCURS 4 TIMES.
 01 WS-N                   BINARY-LONG.
 01 WS-PLANES.
    05 WS-PLANE            OCCURS 6 TIMES.
       10 WS-PC            FLOAT-LONG OCCURS 4 TIMES.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-INSIDE              BINARY-LONG.
 01 WS-ENT.
    05 WS-EX               FLOAT-LONG.
    05 WS-EY               FLOAT-LONG.
    05 WS-EZ               FLOAT-LONG.
    05 WS-EW               FLOAT-LONG.
    05 WS-EH               FLOAT-LONG.
 01 WS-EM.
    05 WS-EM-X             FLOAT-LONG.
    05 WS-EM-Y             FLOAT-LONG.
    05 WS-EM-Z             FLOAT-LONG.
    05 WS-EM-LIFE          BINARY-LONG.
    05 WS-EM-LIFETIME      BINARY-LONG.
    05 WS-EM-REMOVED       BINARY-LONG.
 01 WS-SPAWNS.
    05 WS-SP-COUNT         BINARY-LONG.
    05 WS-SPAWN            OCCURS 16 TIMES.
       10 WS-SP            FLOAT-LONG OCCURS 6 TIMES.
 01 WS-PICK.
    05 WS-PK-LIFE          BINARY-LONG.
    05 WS-PK-REMOVED       BINARY-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-DEG                 FLOAT-LONG.
 01 WS-VAL                 FLOAT-LONG.
 01 WS-SCALE               BINARY-DOUBLE.
 01 WS-LIGHT               BINARY-LONG VALUE 15728880.
 PROCEDURE DIVISION.
*>   5.1 render types: shorthand and group class.
     MOVE 1 TO WS-GROUP
     CALL "PENG-GROUP-NAME" USING WS-GROUP WS-SHORT WS-CLASS
     MOVE "render type 1: SINGLE_QUADS SQ QuadParticleGroup" TO WS-NAME
     MOVE "T" TO TL-MODE
     MOVE "SQ QuadParticleGroup" TO TL-EXPECTED
     STRING WS-SHORT " " WS-CLASS DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 2 TO WS-GROUP
     CALL "PENG-GROUP-NAME" USING WS-GROUP WS-SHORT WS-CLASS
     MOVE "render type 2: ITEM_PICKUP IP ItemPickupParticleGroup" TO WS-NAME
     MOVE "IP ItemPickupParticleGroup" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING WS-SHORT " " WS-CLASS DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 3 TO WS-GROUP
     CALL "PENG-GROUP-NAME" USING WS-GROUP WS-SHORT WS-CLASS
     MOVE "render type 3: ELDER_GUARDIANS EG ElderGuardianParticleGroup" TO WS-NAME
     MOVE "EG ElderGuardianParticleGroup" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING WS-SHORT " " WS-CLASS DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 4 TO WS-GROUP
     CALL "PENG-GROUP-NAME" USING WS-GROUP WS-SHORT WS-CLASS
     MOVE "render type 4: NO_RENDER NR NoRenderParticleGroup" TO WS-NAME
     MOVE "NR NoRenderParticleGroup" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING WS-SHORT " " WS-CLASS DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 9 TO WS-GROUP
     CALL "PENG-GROUP-NAME" USING WS-GROUP WS-SHORT WS-CLASS
     MOVE "unknown render type has no name" TO WS-NAME
     MOVE SPACES TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING WS-SHORT WS-CLASS DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM ASSERT-TEXT
*>   E4 reservoir: size 14336 -> q 0.5, q^2 0.25: draw 0.3 rejects, 0.2 accepts. 16384 always rejects with
*>   no draw; 12287 always accepts with no draw; 16383 band: q = 1/4096.
     MOVE 14336 TO WS-SIZE
     MOVE 0.3 TO WS-DRAW
     CALL "PENG-GROUP-ACCEPT" USING WS-SIZE WS-DRAW WS-OK WS-DREW
     MOVE "E4: size 14336, draw 0.3 is rejected (q squared 0.25), one draw taken" TO WS-NAME
     COMPUTE TL-OBSERVED-N = WS-DREW * 10 + WS-OK
     COMPUTE TL-EXPECTED-N = 10
     PERFORM ASSERT-NUMBER
     MOVE 0.2 TO WS-DRAW
     CALL "PENG-GROUP-ACCEPT" USING WS-SIZE WS-DRAW WS-OK WS-DREW
     MOVE "E4: size 14336, draw 0.2 is accepted" TO WS-NAME
     MOVE 11 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-DREW * 10 + WS-OK
     PERFORM ASSERT-NUMBER
     MOVE 16384 TO WS-SIZE
     MOVE 0.0 TO WS-DRAW
     CALL "PENG-GROUP-ACCEPT" USING WS-SIZE WS-DRAW WS-OK WS-DREW
     MOVE "E4: size 16384 is always rejected, no draw" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-DREW * 10 + WS-OK
     PERFORM ASSERT-NUMBER
     MOVE 12287 TO WS-SIZE
     CALL "PENG-GROUP-ACCEPT" USING WS-SIZE WS-DRAW WS-OK WS-DREW
     MOVE "E4: size 12287 is always accepted, no draw" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-DREW * 10 + WS-OK
     PERFORM ASSERT-NUMBER
     MOVE 12288 TO WS-SIZE
     MOVE 0.99 TO WS-DRAW
     CALL "PENG-GROUP-ACCEPT" USING WS-SIZE WS-DRAW WS-OK WS-DREW
     MOVE "reservoir starts at size 12288: q = 1, q squared 1, draw 0.99 accepted with a draw" TO WS-NAME
     MOVE 11 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-DREW * 10 + WS-OK
     PERFORM ASSERT-NUMBER
     MOVE 16383 TO WS-SIZE
     MOVE 0.001 TO WS-DRAW
     CALL "PENG-GROUP-ACCEPT" USING WS-SIZE WS-DRAW WS-OK WS-DREW
     MOVE "size 16383: q squared is about 6e-8, draw 0.001 rejects" TO WS-NAME
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-DREW * 10 + WS-OK
     PERFORM ASSERT-NUMBER
*>   5.3 / E5: ParticleLimit at call time: the 1001st limited particle is dropped, counter stays 1000.
     CALL "PENG-INIT" USING ENGINE
     MOVE 1 TO WS-GROUP
     MOVE 1 TO WS-LIMITED
     PERFORM VARYING WS-HANDLE FROM 1 BY 1 UNTIL WS-HANDLE > 1000
         CALL "PENG-ADD" USING ENGINE WS-HANDLE WS-GROUP WS-LIMITED WS-OK
     END-PERFORM
     MOVE 1001 TO WS-HANDLE
     CALL "PENG-ADD" USING ENGINE WS-HANDLE WS-GROUP WS-LIMITED WS-OK
     MOVE "E5: the 1001st spore_blossom_air is dropped inside add" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "E5: the counter stays 1000" TO WS-NAME
     MOVE 1000 TO TL-EXPECTED-N
     MOVE EN-LIMIT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "queued particles: 1000 in the add queue" TO WS-NAME
     MOVE 1000 TO TL-EXPECTED-N
     MOVE EN-ADD-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
*>   A particle without a limit is queued regardless of the counter.
     MOVE 0 TO WS-LIMITED
     MOVE 2000 TO WS-HANDLE
     CALL "PENG-ADD" USING ENGINE WS-HANDLE WS-GROUP WS-LIMITED WS-OK
     MOVE "a particle without a limit is always queued" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
*>   5.5 tick order: drain inserts in FIFO order into lazily created groups; first tick next time.
     MOVE 0 TO WS-D(1)
     CALL "PENG-REAP" USING ENGINE WS-DRAWS
     MOVE "5.5 step 3: the queue drains into the group (1001 particles) and empties" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 1001 * 10 + 0
     COMPUTE TL-OBSERVED-N = EN-G-COUNT(1) * 10 + EN-ADD-COUNT
     PERFORM ASSERT-NUMBER
     MOVE "5.5: groups are created lazily: only the quad group exists" TO WS-NAME
     MOVE 1000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-G-EXISTS(1) * 1000 + EN-G-EXISTS(2) + EN-G-EXISTS(3) + EN-G-EXISTS(4)
     PERFORM ASSERT-NUMBER
     MOVE "5.5 step 3: insertion order is FIFO (slot 1 is handle 1, slot 1001 is 2000)" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 1 * 10000 + 2000
     COMPUTE TL-OBSERVED-N = EN-G-HANDLE(1, 1) * 10000 + EN-G-HANDLE(1, 1001)
     PERFORM ASSERT-NUMBER
*>   E5 end: one limited particle dies in tickParticles -> counter 999.
     MOVE 1 TO EN-G-DEAD(1, 5)
     CALL "PENG-REAP" USING ENGINE WS-DRAWS
     MOVE "E5: a limited particle dying in tickParticles makes the counter 999" TO WS-NAME
     MOVE 999 TO TL-EXPECTED-N
     MOVE EN-LIMIT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "5.5 step 1: the dead particle is removed from the group, order kept" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 1000 * 10000 + 6
     COMPUTE TL-OBSERVED-N = EN-G-COUNT(1) * 10000 + EN-G-HANDLE(1, 5)
     PERFORM ASSERT-NUMBER
*>   When a group refuses a particle the limit counter is decremented again.
     CALL "PENG-INIT" USING ENGINE
     MOVE 1 TO WS-LIMITED
     MOVE 77 TO WS-HANDLE
     CALL "PENG-ADD" USING ENGINE WS-HANDLE WS-GROUP WS-LIMITED WS-OK
     MOVE 16384 TO EN-G-COUNT(1)
     MOVE 1 TO EN-G-EXISTS(1)
     CALL "PENG-REAP" USING ENGINE WS-DRAWS
     MOVE "5.4: a full group refuses the particle and the limit counter goes back to 0" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-LIMIT-COUNT + EN-ADD-COUNT
     PERFORM ASSERT-NUMBER
     MOVE "5.4: the refused particle is not in the group" TO WS-NAME
     MOVE 16384 TO TL-EXPECTED-N
     MOVE EN-G-COUNT(1) TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
*>   Reservoir in drain: group of 14336, draw 0.3 refuses, then 0.2 accepts (draws consumed in order).
     CALL "PENG-INIT" USING ENGINE
     MOVE 0 TO WS-LIMITED
     MOVE 1 TO WS-HANDLE
     CALL "PENG-ADD" USING ENGINE WS-HANDLE WS-GROUP WS-LIMITED WS-OK
     MOVE 2 TO WS-HANDLE
     CALL "PENG-ADD" USING ENGINE WS-HANDLE WS-GROUP WS-LIMITED WS-OK
     MOVE 14336 TO EN-G-COUNT(1)
     MOVE 1 TO EN-G-EXISTS(1)
     MOVE 0.3 TO WS-D(1)
     MOVE 0.2 TO WS-D(2)
     CALL "PENG-REAP" USING ENGINE WS-DRAWS
     MOVE "reservoir in drain: draw 0.3 refuses the first, draw 0.2 accepts the second" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 14337 * 10 + 2
     COMPUTE TL-OBSERVED-N = EN-G-COUNT(1) * 10 + EN-G-HANDLE(1, 14337)
     PERFORM ASSERT-NUMBER
*>   NO_RENDER group is created too and counted; F3 string; render order skips NR and empty groups.
     CALL "PENG-INIT" USING ENGINE
     MOVE 1 TO WS-GROUP
     MOVE 0 TO WS-LIMITED
     MOVE 1 TO WS-HANDLE
     CALL "PENG-ADD" USING ENGINE WS-HANDLE WS-GROUP WS-LIMITED WS-OK
     MOVE 2 TO WS-HANDLE
     CALL "PENG-ADD" USING ENGINE WS-HANDLE WS-GROUP WS-LIMITED WS-OK
     MOVE 3 TO WS-HANDLE
     MOVE 4 TO WS-GROUP
     CALL "PENG-ADD" USING ENGINE WS-HANDLE WS-GROUP WS-LIMITED WS-OK
     CALL "PENG-REAP" USING ENGINE WS-DRAWS
     CALL "PENG-COUNTER" USING ENGINE WS-TEXT
     MOVE "F3 counter string: 'SQ 2 NR 1 T3'" TO WS-NAME
     MOVE "T" TO TL-MODE
     MOVE "SQ 2 NR 1 T3" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     CALL "PENG-RENDER-ORDER" USING ENGINE WS-ORDER WS-N
     MOVE "render order: only SQ here, NR is never drawn" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 1 * 10 + 1
     COMPUTE TL-OBSERVED-N = WS-N * 10 + WS-ORD(1)
     PERFORM ASSERT-NUMBER
     MOVE 3 TO WS-HANDLE
     MOVE 3 TO WS-GROUP
     CALL "PENG-ADD" USING ENGINE WS-HANDLE WS-GROUP WS-LIMITED WS-OK
     MOVE 4 TO WS-HANDLE
     MOVE 2 TO WS-GROUP
     CALL "PENG-ADD" USING ENGINE WS-HANDLE WS-GROUP WS-LIMITED WS-OK
     CALL "PENG-REAP" USING ENGINE WS-DRAWS
     CALL "PENG-RENDER-ORDER" USING ENGINE WS-ORDER WS-N
     MOVE "render order: SINGLE_QUADS, ITEM_PICKUP, ELDER_GUARDIANS" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 3 * 1000 + 1 * 100 + 2 * 10 + 3
     COMPUTE TL-OBSERVED-N = WS-N * 1000 + WS-ORD(1) * 100 + WS-ORD(2) * 10 + WS-ORD(3)
     PERFORM ASSERT-NUMBER
*>   Emitters tick after groups; dead ones are removed (5.5 step 2).
     MOVE 1 TO EN-EM-COUNT
     MOVE 9 TO EN-EM-HANDLE(1)
     MOVE 1 TO EN-EM-DEAD(1)
     MOVE 2 TO EN-EM-COUNT
     MOVE 10 TO EN-EM-HANDLE(2)
     MOVE 0 TO EN-EM-DEAD(2)
     CALL "PENG-REAP" USING ENGINE WS-DRAWS
     MOVE "5.5 step 2: the dead emitter is removed, the live one kept in order" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 1 * 100 + 10
     COMPUTE TL-OBSERVED-N = EN-EM-COUNT * 100 + EN-EM-HANDLE(1)
     PERFORM ASSERT-NUMBER
*>   clearParticles via PENG-INIT: everything empties.
     CALL "PENG-INIT" USING ENGINE
     MOVE "setLevel/clearParticles empties groups, queue, emitters and counters" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-G-COUNT(1) + EN-G-EXISTS(1) + EN-ADD-COUNT + EN-EM-COUNT + EN-LIMIT-COUNT
     PERFORM ASSERT-NUMBER
*>   5.6 culling: a point inside six planes (a unit cube around the origin; plane n.p + d >= 0 inside).
     MOVE 0 TO WS-PC(1, 1) WS-PC(1, 2) WS-PC(1, 3) WS-PC(2, 1) WS-PC(2, 2) WS-PC(2, 3)
     MOVE 0 TO WS-PC(3, 1) WS-PC(3, 2) WS-PC(3, 3) WS-PC(4, 1) WS-PC(4, 2) WS-PC(4, 3)
     MOVE 0 TO WS-PC(5, 1) WS-PC(5, 2) WS-PC(5, 3) WS-PC(6, 1) WS-PC(6, 2) WS-PC(6, 3)
     MOVE 1 TO WS-PC(1, 1)
     MOVE -1 TO WS-PC(2, 1)
     MOVE 1 TO WS-PC(3, 2)
     MOVE -1 TO WS-PC(4, 2)
     MOVE 1 TO WS-PC(5, 3)
     MOVE -1 TO WS-PC(6, 3)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE 1 TO WS-PC(WS-I, 4)
     END-PERFORM
     MOVE 0.5 TO WS-PX
     MOVE 0.5 TO WS-PY
     MOVE -0.5 TO WS-PZ
     CALL "PENG-POINT-IN-FRUSTUM" USING WS-PLANES WS-PX WS-PY WS-PZ WS-INSIDE
     MOVE "culling: a point inside all six planes is drawn" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-INSIDE TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 2.0 TO WS-PX
     CALL "PENG-POINT-IN-FRUSTUM" USING WS-PLANES WS-PX WS-PY WS-PZ WS-INSIDE
     MOVE "culling: a point outside one plane is culled" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-INSIDE TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
*>   5.7 / E10 tracking emitter: entity 0.6 x 1.8 at (0,64,0).
     MOVE 0 TO WS-EX WS-EZ
     MOVE 64.0 TO WS-EY
     MOVE 0.6 TO WS-EW
     MOVE 1.8 TO WS-EH
*>   Raw nextFloat draws: attempt 1 = (0.75, 0.5, 0.25) -> (0.5, 0.0, -0.5); attempt 2 = 0.95 x3 -> 0.9 x3
*>   (length squared 2.43, skipped); attempts 3 to 16 = 0.0 x3 -> (-1, -1, -1) (length squared 3, skipped).
     MOVE 0.75 TO WS-D(1)
     MOVE 0.5 TO WS-D(2)
     MOVE 0.25 TO WS-D(3)
     MOVE 0.95 TO WS-D(4) WS-D(5) WS-D(6)
     PERFORM VARYING WS-I FROM 7 BY 1 UNTIL WS-I > 48
         MOVE 0.0 TO WS-D(WS-I)
     END-PERFORM
     MOVE 0 TO WS-EM-LIFE
     MOVE 3 TO WS-EM-LIFETIME
     MOVE 0 TO WS-EM-REMOVED
     CALL "PENG-EMITTER-TICK" USING WS-ENT WS-EM WS-DRAWS WS-SPAWNS
     MOVE 1000 TO WS-SCALE
     MOVE "E10: first spawn x 0.075 (0.6 * 0.5 / 4)" TO WS-NAME
     MOVE WS-SP(1, 1) TO WS-VAL
     MOVE 75 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "E10: first spawn y 64.9 = 64 + 1.8 * (0.5 + 0)" TO WS-NAME
     MOVE WS-SP(1, 2) TO WS-VAL
     MOVE 64900 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "E10: first spawn z -0.075" TO WS-NAME
     MOVE WS-SP(1, 3) TO WS-VAL
     MOVE -75 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "E10: velocity x 0.5" TO WS-NAME
     MOVE WS-SP(1, 4) TO WS-VAL
     MOVE 500 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "E10: velocity y 0.2 (ey + 0.2)" TO WS-NAME
     MOVE WS-SP(1, 5) TO WS-VAL
     MOVE 200 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "E10: velocity z -0.5" TO WS-NAME
     MOVE WS-SP(1, 6) TO WS-VAL
     MOVE -500 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "E10: the (0.9, 0.9, 0.9) attempt (length squared 2.43) and the (-1,-1,-1) attempts are skipped: 1 spawn" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-SP-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "emitter: life 1 of 3, not removed" TO WS-NAME
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-EM-LIFE * 10 + WS-EM-REMOVED
     PERFORM ASSERT-NUMBER
     MOVE 2 TO WS-EM-LIFE
     CALL "PENG-EMITTER-TICK" USING WS-ENT WS-EM WS-DRAWS WS-SPAWNS
     MOVE "emitter: life reaching the lifetime removes it" TO WS-NAME
     MOVE 31 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-EM-LIFE * 10 + WS-EM-REMOVED
     PERFORM ASSERT-NUMBER
*>   Construction position: x, y + 0.5 height, z; one tick happens in the constructor (life 1).
     MOVE 5.0 TO WS-EX
     MOVE 64.0 TO WS-EY
     MOVE 6.0 TO WS-EZ
     CALL "PENG-EMITTER-NEW" USING WS-ENT WS-EM WS-DRAWS WS-SPAWNS
     MOVE "emitter construction: x 5, y 64 + 0.5 * 1.8 = 64.9, z 6" TO WS-NAME
     MOVE 1000 TO WS-SCALE
     MOVE WS-EM-X TO WS-VAL
     MOVE 5000 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE WS-EM-Y TO WS-VAL
     MOVE 64900 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE WS-EM-Z TO WS-VAL
     MOVE 6000 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "emitter construction: default lifetime 3" TO WS-NAME
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-EM-LIFETIME TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "emitter construction: calls tick once so life is 1" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-EM-LIFE TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
*>   E8 pickup: life 1, partial 0.5 -> t 0.25; item x 10, target 12 -> 10.5.
     MOVE 1 TO WS-PK-LIFE
     MOVE 0.5 TO WS-DRAW
     CALL "PENG-PICKUP-T" USING WS-PK-LIFE WS-DRAW WS-T
     MOVE "E8: t = ((1 + 0.5) / 3) squared = 0.25 (thousandths)" TO WS-NAME
     MOVE 1000 TO WS-SCALE
     MOVE WS-T TO WS-VAL
     MOVE 250 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE 10.0 TO WS-PX
     MOVE 12.0 TO WS-PY
     CALL "PENG-PICKUP-POS" USING WS-T WS-PX WS-PY WS-A
     MOVE "E8: drawn x = 10 + 0.25 * (12 - 10) = 10.5" TO WS-NAME
     MOVE WS-A TO WS-VAL
     MOVE 10500 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE 0 TO WS-PK-LIFE
     MOVE 0 TO WS-PK-REMOVED
     CALL "PENG-PICKUP-TICK" USING WS-PICK
     CALL "PENG-PICKUP-TICK" USING WS-PICK
     MOVE "pickup tick: life 2 of 3, alive" TO WS-NAME
     MOVE 20 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-PK-LIFE * 10 + WS-PK-REMOVED
     PERFORM ASSERT-NUMBER
     CALL "PENG-PICKUP-TICK" USING WS-PICK
     MOVE "pickup tick: at life 3 the particle removes itself" TO WS-NAME
     MOVE 31 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-PK-LIFE * 10 + WS-PK-REMOVED
     PERFORM ASSERT-NUMBER
     MOVE 5.0 TO WS-PX
     MOVE 1.0 TO WS-PY
     MOVE 1.6 TO WS-PZ
     CALL "PENG-PICKUP-TARGET" USING WS-PY WS-PZ WS-A
     MOVE "pickup target y: mean of the target y (1.0) and eye y (1.6) = 1.3" TO WS-NAME
     MOVE WS-A TO WS-VAL
     MOVE 1300 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
*>   E9 elder guardian: age 10, partial 0.5, lifetime 30: alpha 0.49549 -> byte 126; X rotation 7.5.
     MOVE 10 TO WS-SIZE
     MOVE 0.5 TO WS-DRAW
     MOVE 30 TO WS-N
     CALL "PENG-ELDER" USING WS-SIZE WS-DRAW WS-N WS-A WS-BYTE WS-DEG
     MOVE "E9: alpha 0.49549 (hundred thousandths)" TO WS-NAME
     MOVE 100000 TO WS-SCALE
     MOVE WS-A TO WS-VAL
     MOVE 49549 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "E9: byte 126" TO WS-NAME
     MOVE 126 TO TL-EXPECTED-N
     MOVE WS-BYTE TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "E9: X rotation 7.5 degrees (tenths)" TO WS-NAME
     MOVE 10 TO WS-SCALE
     MOVE WS-DEG TO WS-VAL
     MOVE 75 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE 15 TO WS-SIZE
     CALL "PENG-ELDER" USING WS-SIZE WS-DRAW WS-N WS-A WS-BYTE WS-DEG
     MOVE "elder guardian at t 0.5: alpha 0.55 (byte 140)" TO WS-NAME
     MOVE 140 TO TL-EXPECTED-N
     MOVE WS-BYTE TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "elder guardian: lifetime 30 and light 15728880" TO WS-NAME
     CALL "PENG-ELDER-CONSTANTS" USING WS-N WS-LIGHT
     COMPUTE TL-EXPECTED-N = 30 + 15728880
     COMPUTE TL-OBSERVED-N = WS-N + WS-LIGHT
     PERFORM ASSERT-NUMBER
*>   The add queue is bounded (4096): the 4097th add is dropped.
     CALL "PENG-INIT" USING ENGINE
     MOVE 1 TO WS-GROUP
     MOVE 0 TO WS-LIMITED
     PERFORM VARYING WS-HANDLE FROM 1 BY 1 UNTIL WS-HANDLE > 4097
         CALL "PENG-ADD" USING ENGINE WS-HANDLE WS-GROUP WS-LIMITED WS-OK
     END-PERFORM
     MOVE "a full add queue drops the particle" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
*>   Past the 48 supplied draws a band group refuses (draw 1.0).
     CALL "PENG-INIT" USING ENGINE
     MOVE 14336 TO EN-G-COUNT(1)
     MOVE 1 TO EN-G-EXISTS(1)
     PERFORM VARYING WS-HANDLE FROM 1 BY 1 UNTIL WS-HANDLE > 50
         CALL "PENG-ADD" USING ENGINE WS-HANDLE WS-GROUP WS-LIMITED WS-OK
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 48
         MOVE 0.0 TO WS-D(WS-I)
     END-PERFORM
     CALL "PENG-REAP" USING ENGINE WS-DRAWS
     MOVE "draws past the table count as 1.0: 48 accepted, 2 refused" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 14336 + 48
     MOVE EN-G-COUNT(1) TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     STOP RUN.

 ASSERT-NUMBER.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-1§5 Engine core: groups, limits, culling, order: " FUNCTION TRIM(WS-NAME)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-1§5 Engine core: groups, limits, culling, order: " FUNCTION TRIM(WS-NAME)
         DELIMITED BY SIZE INTO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-SCALED.
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(WS-VAL * WS-SCALE + 0.5)
     PERFORM ASSERT-NUMBER.
 END PROGRAM TEST-PARTICLES-42-1-5.
