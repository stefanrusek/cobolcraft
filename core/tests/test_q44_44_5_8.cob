*> Creaking heart block entity (docs/protocol/44-residual-mob-questions-5-overworld-hostile.md section 8, check 12 of section 10; lane 002-lane-p49i, T22560; phase task T2744).
*> Programs Q5-HEART-* and Q5-RESIN-NEIGHBOUR of core/src/q44-44-5.cob.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-5-8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-D                   FLOAT-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-EM                  BINARY-LONG.
 01 WS-P                   FLOAT-LONG.
 01 WS-L1                  BINARY-LONG VALUE 1.
 01 WS-L0                  BINARY-LONG VALUE 0.
 01 WS-L2                  BINARY-LONG VALUE 2.
 01 WS-L3                  BINARY-LONG VALUE 3.
 01 WS-L4                  BINARY-LONG VALUE 4.
 01 WS-L5                  BINARY-LONG VALUE 5.
 PROCEDURE DIVISION.
*>   Comparator output.
     MOVE 0 TO WS-D
     CALL "Q5-HEART-OUTPUT" USING WS-L1 WS-D WS-A
     MOVE "comparator output at distance 0 is 15" TO WS-CASE
     MOVE 15 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 32 TO WS-D
     CALL "Q5-HEART-OUTPUT" USING WS-L1 WS-D WS-A
     MOVE "comparator output at distance 32 is 0" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 100 TO WS-D
     CALL "Q5-HEART-OUTPUT" USING WS-L1 WS-D WS-A
     MOVE "comparator output beyond 32 is 0 (the distance is clamped)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 16 TO WS-D
     CALL "Q5-HEART-OUTPUT" USING WS-L1 WS-D WS-A
     MOVE "comparator output at distance 16 is 15 - floor(7.5) = 8" TO WS-CASE
     MOVE 8 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE -3 TO WS-D
     CALL "Q5-HEART-OUTPUT" USING WS-L1 WS-D WS-A
     MOVE "a negative distance is clamped to 0: output 15" TO WS-CASE
     MOVE 15 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-HEART-OUTPUT" USING WS-L0 WS-D WS-A
     MOVE "comparator output without a protector is 0" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
*>   The ticker: 22 to 26 ticks between two runs of the body.
     MOVE -1 TO WS-A
     MOVE 4 TO WS-B
     CALL "Q5-HEART-TICKER" USING WS-A WS-B WS-C WS-NEW
     MOVE "ticker below 0: the body runs and the ticker is reset to 20 + nextInt(5) (draw 4 gives 24)" TO WS-CASE
     MOVE 124 TO WS-E
     COMPUTE WS-O = WS-C * 100 + WS-NEW
     PERFORM CHECK-N
     MOVE 24 TO WS-A
     MOVE 0 TO WS-C
     MOVE 0 TO WS-O
     MOVE 0 TO WS-B
     PERFORM VARYING WS-B FROM 1 BY 1 UNTIL WS-C = 1
         CALL "Q5-HEART-TICKER" USING WS-A WS-L0 WS-C WS-NEW
         MOVE WS-NEW TO WS-A
         ADD 1 TO WS-O
     END-PERFORM
     MOVE "after a reset to 24 the body runs on the 26th following tick (R + 2)" TO WS-CASE
     MOVE 26 TO WS-E
     PERFORM CHECK-N
     MOVE 20 TO WS-A
     MOVE 0 TO WS-C
     MOVE 0 TO WS-O
     PERFORM VARYING WS-B FROM 1 BY 1 UNTIL WS-C = 1
         CALL "Q5-HEART-TICKER" USING WS-A WS-L0 WS-C WS-NEW
         MOVE WS-NEW TO WS-A
         ADD 1 TO WS-O
     END-PERFORM
     MOVE "after a reset to 20 the body runs on the 22nd following tick (the period is 22 to 26)" TO WS-CASE
     MOVE 22 TO WS-E
     PERFORM CHECK-N
*>   hasRequiredLogs.
     CALL "Q5-HEART-LOGS" USING WS-L1 WS-L1 WS-L1 WS-L1 WS-L1 WS-A
     MOVE "both neighbours pale oak logs along the heart's axis: the required logs are there" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-HEART-LOGS" USING WS-L1 WS-L1 WS-L2 WS-L1 WS-L1 WS-A
     MOVE "a log with another axis does not count" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-HEART-LOGS" USING WS-L1 WS-L1 WS-L1 WS-L0 WS-L1 WS-A
     MOVE "a side that is no pale oak log does not count" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-HEART-LOGS" USING WS-L1 WS-L1 WS-L1 WS-L1 WS-L3 WS-A
     MOVE "the other side with another axis does not count either" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
*>   State: UPROOTED / DORMANT / AWAKE.
     CALL "Q5-HEART-STATE" USING WS-L0 WS-L0 WS-L1 WS-A
     MOVE "no logs and no link: UPROOTED (0)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-HEART-STATE" USING WS-L0 WS-L1 WS-L1 WS-A
     MOVE "no logs but a link: AWAKE while creaking_active holds (2)" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-HEART-STATE" USING WS-L1 WS-L0 WS-L0 WS-A
     MOVE "logs and creaking_active false: DORMANT (1)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
*>   Protector removal.
     MOVE 34 TO WS-D
     CALL "Q5-HEART-PROTECTOR" USING WS-L1 WS-L0 WS-D WS-L0 WS-A
     MOVE "the protector is kept at 34 blocks" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 34.5 TO WS-D
     CALL "Q5-HEART-PROTECTOR" USING WS-L1 WS-L0 WS-D WS-L0 WS-A
     MOVE "the protector is removed beyond 34 blocks" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 5 TO WS-D
     CALL "Q5-HEART-PROTECTOR" USING WS-L0 WS-L0 WS-D WS-L0 WS-A
     MOVE "the protector is removed when the attribute is false and it needs no persistence" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-HEART-PROTECTOR" USING WS-L0 WS-L1 WS-D WS-L0 WS-A
     MOVE "a persistent creaking is kept while the attribute is false" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-HEART-PROTECTOR" USING WS-L1 WS-L0 WS-D WS-L1 WS-A
     MOVE "the protector is removed when a player is stuck in it" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
*>   Spawning needs a non-spectator player within 32, monsters, not Peaceful, AWAKE, no link.
     CALL "Q5-HEART-SPAWN" USING WS-L0 WS-L2 WS-L1 WS-L0 WS-L1 WS-A
     MOVE "an awake heart without a link spawns a protector with a player near" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-HEART-SPAWN" USING WS-L1 WS-L2 WS-L1 WS-L0 WS-L1 WS-A
     MOVE "a linked heart spawns nothing" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-HEART-SPAWN" USING WS-L0 WS-L1 WS-L1 WS-L0 WS-L1 WS-A
     MOVE "a dormant heart spawns nothing" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-HEART-SPAWN" USING WS-L0 WS-L2 WS-L0 WS-L0 WS-L1 WS-A
     MOVE "monsters off: nothing spawns" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-HEART-SPAWN" USING WS-L0 WS-L2 WS-L1 WS-L1 WS-L1 WS-A
     MOVE "Peaceful: nothing spawns" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-HEART-SPAWN" USING WS-L0 WS-L2 WS-L1 WS-L0 WS-L0 WS-A
     MOVE "no player within 32 blocks: nothing spawns" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
*>   Link resolution.
     CALL "Q5-HEART-LINK" USING WS-L1 WS-L0 WS-L0 WS-L0 WS-A
     MOVE "a live reference is used while the entity is not removed" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q5-HEART-LINK" USING WS-L0 WS-L1 WS-L1 WS-L0 WS-A
     MOVE "a UUID found in the level becomes the live link" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 29 TO WS-B
     CALL "Q5-HEART-LINK" USING WS-L0 WS-L1 WS-L0 WS-B WS-A
     MOVE "a UUID not found within 30 ticks of existing is kept (grace period)" TO WS-CASE
     MOVE 3 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 30 TO WS-B
     CALL "Q5-HEART-LINK" USING WS-L0 WS-L1 WS-L0 WS-B WS-A
     MOVE "a UUID not found at ticksExisted 30 is cleared" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
*>   Hurt.
     CALL "Q5-HEART-HURT" USING WS-L1 WS-L0 WS-L0 WS-L1 WS-L3 WS-A WS-B WS-C
     MOVE "hurt of an awake heart: 20 particles, 3 resin spreads (draw 3), emitter 100" TO WS-CASE
     MOVE 203100 TO WS-E
     COMPUTE WS-O = WS-A * 10000 + WS-B * 1000 + WS-C
     PERFORM CHECK-N
     CALL "Q5-HEART-HURT" USING WS-L1 WS-L0 WS-L0 WS-L0 WS-L3 WS-A WS-B WS-C
     MOVE "hurt of a dormant heart: particles and the emitter but no resin" TO WS-CASE
     MOVE 200100 TO WS-E
     COMPUTE WS-O = WS-A * 10000 + WS-B * 1000 + WS-C
     PERFORM CHECK-N
     MOVE 40 TO WS-EM
     CALL "Q5-HEART-HURT" USING WS-L1 WS-L0 WS-EM WS-L1 WS-L2 WS-A WS-B WS-C
     MOVE "hurt while the emitter runs is ignored" TO WS-CASE
     MOVE 40 TO WS-E
     COMPUTE WS-O = WS-A + WS-B + WS-C
     PERFORM CHECK-N
     MOVE 0 TO WS-EM
     CALL "Q5-HEART-HURT" USING WS-L0 WS-L0 WS-EM WS-L1 WS-L2 WS-A WS-B WS-C
     MOVE "hurt without a protector is ignored" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = WS-A + WS-B + WS-C
     PERFORM CHECK-N
     CALL "Q5-HEART-HURT" USING WS-L1 WS-L1 WS-EM WS-L1 WS-L2 WS-A WS-B WS-C
     MOVE "hurt on a client is ignored" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = WS-A + WS-B + WS-C
     PERFORM CHECK-N
*>   The emitter: bursts above 50, the hurt effect every 10 ticks.
     MOVE 100 TO WS-A
     CALL "Q5-HEART-EMIT" USING WS-A WS-B WS-C WS-T WS-P
     MOVE "emitter 100: two particle bursts and the hurt effect with t = 0.2" TO WS-CASE
     MOVE 212 TO WS-E
     COMPUTE WS-O = WS-B * 100 + WS-C * 10 + FUNCTION INTEGER(WS-T * 10 + 0.5)
     PERFORM CHECK-N
     MOVE "emitter 100: the sound pitch is 0.5 + 50 / 100 = 1.0" TO WS-CASE
     MOVE 1000 TO WS-E
     COMPUTE WS-O ROUNDED = WS-P * 1000
     PERFORM CHECK-N
     MOVE 50 TO WS-A
     CALL "Q5-HEART-EMIT" USING WS-A WS-B WS-C WS-T WS-P
     MOVE "emitter 50: no burst (above 50 only), the hurt effect with t = 0.6 and pitch 0.75" TO WS-CASE
     MOVE 1600 TO WS-E
     COMPUTE WS-O = WS-B * 10000 + WS-C * 1000 + FUNCTION INTEGER(WS-T * 1000 + 0.5)
     PERFORM CHECK-N
     MOVE 45 TO WS-A
     CALL "Q5-HEART-EMIT" USING WS-A WS-B WS-C WS-T WS-P
     MOVE "emitter 45: neither a burst nor the hurt effect" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = WS-B + WS-C
     PERFORM CHECK-N
*>   Resin spread: the neighbour rules.
     CALL "Q5-RESIN-NEIGHBOUR" USING WS-L1 WS-L0 WS-L2 WS-A WS-B
     MOVE "resin: air gets a new clump with the face (face 2 = bit 4) and the traversal stops" TO WS-CASE
     MOVE 104 TO WS-E
     COMPUTE WS-O = WS-A * 100 + WS-B
     PERFORM CHECK-N
     CALL "Q5-RESIN-NEIGHBOUR" USING WS-L2 WS-L0 WS-L0 WS-A WS-B
     MOVE "resin: a water source gets a waterlogged clump with the face" TO WS-CASE
     MOVE 201 TO WS-E
     COMPUTE WS-O = WS-A * 100 + WS-B
     PERFORM CHECK-N
     MOVE 1 TO WS-B
     CALL "Q5-RESIN-NEIGHBOUR" USING WS-L3 WS-B WS-L1 WS-A WS-C
     MOVE "resin: a clump without the face gets it (faces 1 + 2 = 3)" TO WS-CASE
     MOVE 303 TO WS-E
     COMPUTE WS-O = WS-A * 100 + WS-C
     PERFORM CHECK-N
     CALL "Q5-RESIN-NEIGHBOUR" USING WS-L3 WS-B WS-L0 WS-A WS-C
     MOVE "resin: a clump that already has the face is skipped" TO WS-CASE
     MOVE 1 TO WS-E
     COMPUTE WS-O = WS-A * 100 + WS-C
     PERFORM CHECK-N
     CALL "Q5-RESIN-NEIGHBOUR" USING WS-L4 WS-B WS-L0 WS-A WS-C
     MOVE "resin: any other block is skipped" TO WS-CASE
     MOVE 1 TO WS-E
     COMPUTE WS-O = WS-A * 100 + WS-C
     PERFORM CHECK-N
     CALL "Q5-RESIN-NEIGHBOUR" USING WS-L3 WS-L0 WS-L5 WS-A WS-C
     MOVE "resin: face 5 is bit 32" TO WS-CASE
     MOVE 332 TO WS-E
     COMPUTE WS-O = WS-A * 100 + WS-C
     PERFORM CHECK-N
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 44-5§8 Creaking heart block entity: " DELIMITED BY SIZE FUNCTION TRIM(WS-CASE) DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-5-8.
