*> Implementation test (lane 002-lane-p49s, T38560 to T38570; docs/protocol/44-residual-mob-questions-x1-continuation.md sections 8.2 and 11.2): the merge rules of MobEffectInstance.update on a
*> chain of one effect (FX-MERGE), tickDownDuration and downgradeToHiddenEffect (FX-TICK-DOWN), and through the player store (EFFECT-ADD, EFFECTS-TICK) and the mob store (MEF-ADD, MEF-TICK):
*> Speed amplifier 0 for 1200 ticks, then amplifier 1 for 200 ticks: after 200 ticks amplifier 0 with 1000 ticks left takes over.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FX-HIDDEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY EFFECTS.
 COPY MOBEFFECT.
 COPY FXCHAIN.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-DOWN                BINARY-LONG.
 01 WS-ALIVE               BINARY-LONG.
 01 WS-AMP                 BINARY-LONG.
 01 WS-DUR                 BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-SHORT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-SPEED               BINARY-LONG VALUE 0.
 01 WS-ENT                 BINARY-LONG VALUE 777.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
*>   isShorterDurationThan: a is not infinite and (a < b or b is infinite).
     MOVE 100 TO WS-AMP
     MOVE 200 TO WS-DUR
     CALL "FX-SHORTER" USING WS-AMP WS-DUR WS-SHORT
     MOVE "acceptance US15 44-x1§8.2 100 is shorter than 200" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-SHORT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -1 TO WS-DUR
     CALL "FX-SHORTER" USING WS-AMP WS-DUR WS-SHORT
     MOVE "acceptance US15 44-x1§8.2 100 is shorter than infinite" TO TL-CASE
     MOVE WS-SHORT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FX-SHORTER" USING WS-DUR WS-AMP WS-SHORT
     MOVE "acceptance US15 44-x1§8.2 infinite is shorter than nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SHORT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Step 1: a higher and shorter instance keeps the old one hidden: (0, 600) + (1, 200) = (1, 200) over (0, 600).
     MOVE 1 TO FX-N
     MOVE 0 TO FX-AMP(1)
     MOVE 600 TO FX-DUR(1)
     MOVE 6 TO FX-FLAGS(1)
     MOVE 1 TO WS-AMP
     MOVE 200 TO WS-DUR
     MOVE 6 TO WS-FLAGS
     CALL "FX-MERGE" USING FX-CHAIN WS-AMP WS-DUR WS-FLAGS WS-CHANGED
     MOVE "acceptance US15 44-x1§8.2 higher and shorter: the active instance is amplifier 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE FX-AMP(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-x1§8.2 higher and shorter: it lasts 200" TO TL-CASE
     MOVE 200 TO TL-EXPECTED-N
     MOVE FX-DUR(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-x1§8.2 higher and shorter: the old instance is hidden (600)" TO TL-CASE
     MOVE 600 TO TL-EXPECTED-N
     MOVE FX-DUR(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-x1§8.2 higher and shorter: two nodes and changed" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FX-N + WS-CHANGED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Higher and longer: replaces without a hidden instance.
     MOVE 1 TO FX-N
     MOVE 0 TO FX-AMP(1)
     MOVE 100 TO FX-DUR(1)
     MOVE 1 TO WS-AMP
     MOVE 300 TO WS-DUR
     CALL "FX-MERGE" USING FX-CHAIN WS-AMP WS-DUR WS-FLAGS WS-CHANGED
     MOVE "acceptance US15 44-x1§8.2 higher and longer: no hidden instance" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE FX-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-x1§8.2 higher and longer: it lasts 300 at amplifier 1" TO TL-CASE
     MOVE 301 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FX-DUR(1) + FX-AMP(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Step 2: a lower and longer instance becomes hidden: (1, 200) + (0, 600).
     MOVE 1 TO FX-N
     MOVE 1 TO FX-AMP(1)
     MOVE 200 TO FX-DUR(1)
     MOVE 6 TO FX-FLAGS(1)
     MOVE 0 TO WS-AMP
     MOVE 600 TO WS-DUR
     CALL "FX-MERGE" USING FX-CHAIN WS-AMP WS-DUR WS-FLAGS WS-CHANGED
     MOVE "acceptance US15 44-x1§8.2 lower and longer: the active instance is unchanged (1, 200)" TO TL-CASE
     MOVE 201 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FX-DUR(1) + FX-AMP(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-x1§8.2 lower and longer: it becomes the hidden instance (0, 600)" TO TL-CASE
     MOVE 600 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FX-DUR(2) + FX-AMP(2)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-x1§8.2 lower and longer: nothing changed for the active instance" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-CHANGED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The hidden instance is updated recursively: chain (2, 100) over (1, 300), then (0, 500): a third node.
     MOVE 2 TO FX-N
     MOVE 2 TO FX-AMP(1)
     MOVE 100 TO FX-DUR(1)
     MOVE 6 TO FX-FLAGS(1)
     MOVE 1 TO FX-AMP(2)
     MOVE 300 TO FX-DUR(2)
     MOVE 6 TO FX-FLAGS(2)
     MOVE 0 TO WS-AMP
     MOVE 500 TO WS-DUR
     CALL "FX-MERGE" USING FX-CHAIN WS-AMP WS-DUR WS-FLAGS WS-CHANGED
     MOVE "acceptance US15 44-x1§8.2 a lower longer instance goes down the chain: three nodes" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE FX-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-x1§8.2 and it is the last node (0, 500)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FX-DUR(3) + FX-AMP(3)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A longer higher instance of the hidden one (1, 300) above (0, 100)? Chain (3, 50) over (1, 100): other (2, 400) is lower than the active, longer: it updates the hidden (1, 100): higher: replaces it, no push (longer).
     MOVE 2 TO FX-N
     MOVE 3 TO FX-AMP(1)
     MOVE 50 TO FX-DUR(1)
     MOVE 1 TO FX-AMP(2)
     MOVE 100 TO FX-DUR(2)
     MOVE 2 TO WS-AMP
     MOVE 400 TO WS-DUR
     CALL "FX-MERGE" USING FX-CHAIN WS-AMP WS-DUR WS-FLAGS WS-CHANGED
     MOVE "acceptance US15 44-x1§8.2 a hidden instance that is lower is replaced by the higher one (2, 400)" TO TL-CASE
     MOVE 402 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FX-DUR(2) + FX-AMP(2)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Equal amplifier: a longer duration extends, a shorter one does not.
     MOVE 1 TO FX-N
     MOVE 0 TO FX-AMP(1)
     MOVE 100 TO FX-DUR(1)
     MOVE 0 TO WS-AMP
     MOVE 300 TO WS-DUR
     CALL "FX-MERGE" USING FX-CHAIN WS-AMP WS-DUR WS-FLAGS WS-CHANGED
     MOVE "acceptance US15 44-x1§8.2 equal amplifier, longer: the duration becomes 300" TO TL-CASE
     MOVE 300 TO TL-EXPECTED-N
     MOVE FX-DUR(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 50 TO WS-DUR
     CALL "FX-MERGE" USING FX-CHAIN WS-AMP WS-DUR WS-FLAGS WS-CHANGED
     MOVE "acceptance US15 44-x1§8.2 equal amplifier, shorter: the duration stays 300" TO TL-CASE
     MOVE 300 TO TL-EXPECTED-N
     MOVE FX-DUR(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-x1§8.2 and nothing changed" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-CHANGED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   An infinite instance is never shorter: a lower amplifier changes nothing.
     MOVE 1 TO FX-N
     MOVE 1 TO FX-AMP(1)
     MOVE -1 TO FX-DUR(1)
     MOVE 0 TO WS-AMP
     MOVE 500 TO WS-DUR
     CALL "FX-MERGE" USING FX-CHAIN WS-AMP WS-DUR WS-FLAGS WS-CHANGED
     MOVE "acceptance US15 44-x1§8.2 an infinite instance keeps a lower one out" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE FX-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Flags: ambient on this and not on other clears it; visible and icon follow the new instance.
     MOVE 1 TO FX-N
     MOVE 0 TO FX-AMP(1)
     MOVE 100 TO FX-DUR(1)
     MOVE 7 TO FX-FLAGS(1)
     MOVE 0 TO WS-AMP
     MOVE 50 TO WS-DUR
     MOVE 0 TO WS-FLAGS
     CALL "FX-MERGE" USING FX-CHAIN WS-AMP WS-DUR WS-FLAGS WS-CHANGED
     MOVE "acceptance US15 44-x1§8.2 the flags follow the new instance (ambient, visible, icon off)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE FX-FLAGS(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-x1§8.2 and that counts as a change" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-CHANGED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6 TO WS-FLAGS
     CALL "FX-MERGE" USING FX-CHAIN WS-AMP WS-DUR WS-FLAGS WS-CHANGED
     MOVE "acceptance US15 44-x1§8.2 visible and icon are switched on again" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE FX-FLAGS(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   tickDownDuration and the downgrade: the worked example after 200 ticks: active (1, 1) over hidden (0, 1000) gives (0, 999) alone.
     MOVE 2 TO FX-N
     MOVE 1 TO FX-AMP(1)
     MOVE 1 TO FX-DUR(1)
     MOVE 6 TO FX-FLAGS(1)
     MOVE 0 TO FX-AMP(2)
     MOVE 1000 TO FX-DUR(2)
     MOVE 6 TO FX-FLAGS(2)
     CALL "FX-TICK-DOWN" USING FX-CHAIN WS-DOWN WS-ALIVE
     MOVE "acceptance US15 44-x1§11.2 the downgrade copies the hidden instance (0, 999)" TO TL-CASE
     MOVE 999 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FX-DUR(1) + FX-AMP(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-x1§11.2 the chain is one node, downgraded and alive" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FX-N + WS-DOWN + WS-ALIVE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   With no hidden instance the instance ends at 0.
     MOVE 1 TO FX-N
     MOVE 0 TO FX-AMP(1)
     MOVE 1 TO FX-DUR(1)
     CALL "FX-TICK-DOWN" USING FX-CHAIN WS-DOWN WS-ALIVE
     MOVE "acceptance US15 44-x1§11.2 without a hidden instance the effect ends at 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-ALIVE + WS-DOWN
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   An infinite duration never counts down; a chain of three shifts up one level.
     MOVE 1 TO FX-N
     MOVE -1 TO FX-DUR(1)
     CALL "FX-TICK-DOWN" USING FX-CHAIN WS-DOWN WS-ALIVE
     MOVE "acceptance US15 44-x1§11.2 an infinite effect stays infinite and alive" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FX-DUR(1) + WS-ALIVE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO FX-N
     MOVE 2 TO FX-AMP(1)
     MOVE 1 TO FX-DUR(1)
     MOVE 1 TO FX-AMP(2)
     MOVE 50 TO FX-DUR(2)
     MOVE 0 TO FX-AMP(3)
     MOVE 90 TO FX-DUR(3)
     CALL "FX-TICK-DOWN" USING FX-CHAIN WS-DOWN WS-ALIVE
     MOVE "acceptance US15 44-x1§11.2 a chain of three shifts up: active (1, 49), hidden (0, 89)" TO TL-CASE
     MOVE 49 TO TL-EXPECTED-N
     MOVE FX-DUR(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-x1§11.2 the shifted chain has two nodes" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE FX-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-x1§11.2 and the last node is (0, 89)" TO TL-CASE
     MOVE 89 TO TL-EXPECTED-N
     MOVE FX-DUR(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The player store: Speed (effect 0) amplifier 0 for 1200, then amplifier 1 for 200; EFFECTS-TICK 200 times.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE 6 TO WS-FLAGS
     MOVE 0 TO WS-AMP
     MOVE 1200 TO WS-DUR
     CALL "EFFECT-ADD" USING WS-PLAYER WS-SPEED WS-AMP WS-DUR WS-FLAGS
     MOVE 1 TO WS-AMP
     MOVE 200 TO WS-DUR
     CALL "EFFECT-ADD" USING WS-PLAYER WS-SPEED WS-AMP WS-DUR WS-FLAGS
     MOVE "acceptance US15 44-x1§8.2 the player has Speed amplifier 1 for 200 with one hidden instance" TO TL-CASE
     MOVE 1201 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EF-HCOUNT(WS-PLAYER, 1) * 1000 + EF-AMPLIFIER(WS-PLAYER, 1) * 1 + EF-DURATION(WS-PLAYER, 1) / 200 * 200
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM 199 TIMES
         CALL "EFFECTS-TICK"
     END-PERFORM
     CALL "EFFECT-LEVEL" USING WS-PLAYER WS-SPEED WS-LEVEL WS-TICKS
     MOVE "acceptance US15 44-x1§8.2 after 199 ticks amplifier 1 is still active (1 tick left)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-LEVEL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "EFFECTS-TICK"
     CALL "EFFECT-LEVEL" USING WS-PLAYER WS-SPEED WS-LEVEL WS-TICKS
     MOVE "acceptance US15 44-x1§11.2 at 200 ticks amplifier 0 takes over (level 1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-LEVEL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-x1§11.2 with 1000 ticks left (the hidden 1200 less 200 ticks)" TO TL-CASE
     MOVE 1000 TO TL-EXPECTED-N
     MOVE WS-TICKS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-x1§11.2 and no hidden instance is left" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EF-HCOUNT(WS-PLAYER, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   At a duration that is a multiple of 600 the client is told again; the effect ends at 0.
     MOVE 601 TO EF-DURATION(WS-PLAYER, 1)
     CALL "EFFECTS-TICK"
     MOVE "acceptance US15 44-x1§11.2 600 ticks left: the effect goes on" TO TL-CASE
     MOVE 600 TO TL-EXPECTED-N
     MOVE EF-DURATION(WS-PLAYER, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO EF-DURATION(WS-PLAYER, 1)
     CALL "EFFECTS-TICK"
     MOVE "acceptance US15 44-x1§11.2 the last tick ends the effect" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EF-ON(WS-PLAYER, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Adding again after the removal starts fresh (no hidden instances left from the old chain).
     MOVE 0 TO WS-AMP
     MOVE 100 TO WS-DUR
     CALL "EFFECT-ADD" USING WS-PLAYER WS-SPEED WS-AMP WS-DUR WS-FLAGS
     MOVE "acceptance US15 44-x1§11.2 a fresh effect has no hidden instance" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EF-HCOUNT(WS-PLAYER, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "EFFECT-REMOVE" USING WS-PLAYER WS-SPEED

*>   A third instance pushes the chain down: (0, 100), then (1, 50), then (2, 20) leaves two hidden instances; a takeover of the row by another player drops the effects on the next tick.
     MOVE 0 TO WS-AMP
     MOVE 100 TO WS-DUR
     CALL "EFFECT-ADD" USING WS-PLAYER WS-SPEED WS-AMP WS-DUR WS-FLAGS
     MOVE 1 TO WS-AMP
     MOVE 50 TO WS-DUR
     CALL "EFFECT-ADD" USING WS-PLAYER WS-SPEED WS-AMP WS-DUR WS-FLAGS
     MOVE 2 TO WS-AMP
     MOVE 20 TO WS-DUR
     CALL "EFFECT-ADD" USING WS-PLAYER WS-SPEED WS-AMP WS-DUR WS-FLAGS
     MOVE "acceptance US15 44-x1§8.2 a third instance leaves two hidden instances" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE EF-HCOUNT(WS-PLAYER, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE EF-OWNER(WS-PLAYER, 1) = EF-OWNER(WS-PLAYER, 1) + 1
     CALL "EFFECTS-TICK"
     MOVE "acceptance US15 44-x1§11.2 a row taken over by another player loses the old effects" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EF-ON(WS-PLAYER, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The mob store: the same example through MEF-ADD and MEF-TICK on a mob of that entity id.
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     MOVE "minecraft:pig" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE EN-ID(WS-ROW) TO WS-ENT
     MOVE 0 TO WS-AMP
     MOVE 1200 TO WS-DUR
     CALL "MEF-ADD" USING WS-ENT WS-SPEED WS-AMP WS-DUR WS-FLAGS
     MOVE 1 TO WS-AMP
     MOVE 200 TO WS-DUR
     CALL "MEF-ADD" USING WS-ENT WS-SPEED WS-AMP WS-DUR WS-FLAGS
     PERFORM 200 TIMES
         CALL "MEF-TICK" USING WS-ROW
     END-PERFORM
     CALL "MEF-LEVEL" USING WS-ENT WS-SPEED WS-LEVEL WS-TICKS
     MOVE "acceptance US15 44-x1§11.2 the mob: after 200 ticks Speed 0 takes over (level 1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-LEVEL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-x1§11.2 the mob: 1000 ticks left (200 ticks of the tick-down since the add)" TO TL-CASE
     MOVE 1000 TO TL-EXPECTED-N
     MOVE WS-TICKS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-AMP
     MOVE 5000 TO WS-DUR
     CALL "MEF-ADD" USING WS-ENT WS-SPEED WS-AMP WS-DUR WS-FLAGS
     MOVE 1 TO WS-AMP
     MOVE 300 TO WS-DUR
     CALL "MEF-ADD" USING WS-ENT WS-SPEED WS-AMP WS-DUR WS-FLAGS
     MOVE 2 TO WS-AMP
     MOVE 100 TO WS-DUR
     CALL "MEF-ADD" USING WS-ENT WS-SPEED WS-AMP WS-DUR WS-FLAGS
     MOVE 0 TO WS-SLOT
     MOVE 0 TO WS-I
     CALL "MEF-FIND" USING WS-ENT WS-SPEED WS-I WS-SLOT
     MOVE "acceptance US15 44-x1§8.2 the mob: a third instance leaves two hidden instances" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE ME-HCOUNT(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM 100 TIMES
         CALL "MEF-TICK" USING WS-ROW
     END-PERFORM
     CALL "MEF-LEVEL" USING WS-ENT WS-SPEED WS-LEVEL WS-TICKS
     MOVE "acceptance US15 44-x1§11.2 the mob: after 100 ticks amplifier 1 takes over (level 2)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-LEVEL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-FX-HIDDEN.

 COPY CORETEST.
 COPY MOBSPTEST.
