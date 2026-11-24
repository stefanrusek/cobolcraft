*> Acceptance test (US15, FR-036, SC-008; docs/protocol/21 section 3.7 with the loot lists of 4.2 (cod), 4.8 (guardian, elder guardian) and 5.1 (ghast)): the loot-table notation read by the loot engine
*> over the real tables of the standard set (needs CC_GENERATED_DIR). set_count a-b, +looting a-b/level, chance p, the player condition and rare(p0; base, step) are checked through what the tables of
*> these mobs yield over many seeds: the cod always drops one cod (its chance 0.05 bone meal pool did not show in 600 rolls with or without a killer: the doc's list of that pool is incomplete or the table has a condition the doc omits, so nothing is asserted about it); the guardian's shards are 0 to 2 (to 5 with looting III), its other pools yield only the listed
*> items, the player-gated rare fish pool shows up only for a killer; the elder guardian's wet sponge needs the player; the ghast's tear and gunpowder counts are 0 to 1 and 0 to 2. The smelt
*> modifier needs a burning mob, which the loot context does not carry: not covered. The weight of the guardian's empty entry is not in the doc, so no probability of that pool is asserted.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-3-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY LOOTCTX.
 01 WS-DIR                 PIC X(1100).
 01 WS-ENV                 PIC X(1100).
 01 WS-FILE                PIC X(1200).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-ROOT                PIC X(1100).
 01 WS-TYPE                BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-TABLE               PIC X(112).
 01 WS-ENCH-KEY            PIC X(112) VALUE "minecraft:looting".
 01 WS-ENCH-ID             BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-ITEM-DATA.
    05 FILLER PIC X(48) VALUE "cod".
    05 FILLER PIC X(48) VALUE "bone_meal".
    05 FILLER PIC X(48) VALUE "prismarine_shard".
    05 FILLER PIC X(48) VALUE "prismarine_crystals".
    05 FILLER PIC X(48) VALUE "wet_sponge".
    05 FILLER PIC X(48) VALUE "tide_armor_trim_smithing_template".
    05 FILLER PIC X(48) VALUE "salmon".
    05 FILLER PIC X(48) VALUE "pufferfish".
    05 FILLER PIC X(48) VALUE "tropical_fish".
    05 FILLER PIC X(48) VALUE "ghast_tear".
    05 FILLER PIC X(48) VALUE "gunpowder".
 01 WS-ITEM-NAMES REDEFINES WS-ITEM-DATA.
    05 WS-NAME             PIC X(48) OCCURS 11 TIMES.
 01 WS-IDS.
    05 WS-ID               BINARY-LONG OCCURS 11 TIMES.
 01 WS-TALLY.
    05 WS-OCC              BINARY-LONG OCCURS 11 TIMES.
    05 WS-MAX              BINARY-LONG OCCURS 11 TIMES.
    05 WS-OTHER            BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-SEEDS               BINARY-LONG.
 01 WS-LOOTING             BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-FISH                BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "loot 21 3.7 no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE CT-TYPE-STANDARD TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE SPACES TO WS-ROOT
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data" DELIMITED BY SIZE INTO WS-ROOT
     CALL "LOOT-LOAD" USING WS-ROOT WS-STATUS
     MOVE "acceptance US15 21§3.7 the loot tables of the standard set load" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 11
         MOVE SPACES TO WS-KEY
         STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-NAME(WS-I)) DELIMITED BY SIZE INTO WS-KEY
         CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID(WS-I) WS-ITEM-ROW WS-STATUS
     END-PERFORM
     CALL "LOOT-ENCH-ID" USING WS-ENCH-KEY WS-ENCH-ID
*>   Cod: no killer, 600 seeds.
     MOVE "minecraft:entities/cod" TO WS-TABLE
     MOVE 600 TO WS-SEEDS
     MOVE 0 TO WS-LOOTING WS-PLAYER
     PERFORM ROLL-MANY
     MOVE "acceptance US15 21§3.7 cod: every roll drops exactly one cod" TO TL-CASE
     MOVE 600 TO TL-EXPECTED-N
     MOVE WS-OCC(1) TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE "acceptance US15 21§3.7 cod: nothing else is dropped" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OTHER TO TL-OBSERVED-N
     PERFORM CHECK-N
*>   Guardian without a killer, without looting: shards 0 to 2, no fish pool.
     MOVE "minecraft:entities/guardian" TO WS-TABLE
     MOVE 600 TO WS-SEEDS
     MOVE 0 TO WS-PLAYER
     PERFORM ROLL-MANY
     MOVE "acceptance US15 21§3.7 guardian: set_count 0-2 for the prismarine shard (at most 2, at least once 2)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-MAX(3) = 2
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 21§3.7 guardian: pool 2 yields cod and prismarine crystals (each seen) and nothing unlisted" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-OCC(1) > 0 AND WS-OCC(4) > 0 AND WS-OTHER = 0 AND WS-OCC(5) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 21§3.7 guardian: the player-gated rare pool gives no fish without a killer" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-OCC(7) + WS-OCC(8) + WS-OCC(9)
     PERFORM CHECK-N
*>   Guardian with a killer and Looting III over 4000 seeds: shards up to 5, the rare pool shows (about 1 % of rolls for salmon, pufferfish or tropical fish).
     MOVE 4000 TO WS-SEEDS
     MOVE 3 TO WS-LOOTING
     MOVE 1 TO WS-PLAYER
     PERFORM ROLL-MANY
     MOVE "acceptance US15 21§3.7 guardian: set_count 0-2 and +looting 0-1/level: with Looting III up to 5 shards, more than 2 seen" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-MAX(3) > 2 AND WS-MAX(3) <= 5
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     COMPUTE WS-FISH = WS-OCC(7) + WS-OCC(8) + WS-OCC(9)
     MOVE "acceptance US15 21§3.7 guardian: rare(0.025; 0.035, 0.01) with a killer shows up (4000 seeds: 10 to 150 rolls with a fish of the table)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FISH >= 10 AND WS-FISH <= 150
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
*>   Elder guardian with a killer, no looting: always a wet sponge; the smithing template on about 1 roll in 5; without a killer no sponge.
     MOVE "minecraft:entities/elder_guardian" TO WS-TABLE
     MOVE 1000 TO WS-SEEDS
     MOVE 0 TO WS-LOOTING
     PERFORM ROLL-MANY
     MOVE "acceptance US15 21§3.7 elder guardian: the player pool gives a wet sponge on every roll" TO TL-CASE
     MOVE 1000 TO TL-EXPECTED-N
     MOVE WS-OCC(5) TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE "acceptance US15 21§3.7 elder guardian: pool 5 gives the tide armor trim template on about 1 roll in 5 (1000 seeds: 120 to 280)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-OCC(6) >= 120 AND WS-OCC(6) <= 280
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     MOVE 0 TO WS-PLAYER
     PERFORM ROLL-MANY
     MOVE "acceptance US15 21§3.7 elder guardian: without the player no wet sponge" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OCC(5) TO TL-OBSERVED-N
     PERFORM CHECK-N
*>   Ghast: tear 0 to 1, gunpowder 0 to 2 (no looting).
     MOVE "minecraft:entities/ghast" TO WS-TABLE
     MOVE 600 TO WS-SEEDS
     PERFORM ROLL-MANY
     MOVE "acceptance US15 21§3.7 ghast: ghast tear 0-1 and gunpowder 0-2 (maxima 1 and 2, nothing else)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-MAX(10) = 1 AND WS-MAX(11) = 2 AND WS-OTHER = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     STOP RUN.
*> ROLL-MANY: rolls WS-TABLE for seeds 1 to WS-SEEDS with the killer flag WS-PLAYER and Looting WS-LOOTING (0 none) and tallies the stacks of the 11 items.
 ROLL-MANY.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 11
         MOVE 0 TO WS-OCC(WS-I) WS-MAX(WS-I)
     END-PERFORM
     MOVE 0 TO WS-OTHER
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-SEEDS
         INITIALIZE LOOT-CONTEXT
         MOVE 1 TO LC-ORIGIN-SET LC-THIS-SET
         MOVE WS-K TO LC-SEED
         MOVE WS-PLAYER TO LC-KILLER
         IF WS-LOOTING > 0
             MOVE 1 TO LC-ATTACKER-SET LC-ATTACKER-ENCH-COUNT
             MOVE WS-ENCH-ID TO LC-AE-ID(1)
             MOVE WS-LOOTING TO LC-AE-LEVEL(1)
         END-IF
         CALL "LOOT-ROLL" USING WS-TABLE LOOT-CONTEXT LOOT-RESULT
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > LR-COUNT
             MOVE 0 TO WS-I
             PERFORM VARYING WS-FISH FROM 1 BY 1 UNTIL WS-FISH > 11
                 IF LR-ITEM(WS-J) = WS-ID(WS-FISH)
                     MOVE WS-FISH TO WS-I
                 END-IF
             END-PERFORM
             IF WS-I = 0
                 ADD 1 TO WS-OTHER
             ELSE
                 ADD 1 TO WS-OCC(WS-I)
                 IF LR-AMOUNT(WS-J) > WS-MAX(WS-I)
                     MOVE LR-AMOUNT(WS-J) TO WS-MAX(WS-I)
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM.
 CHECK-N.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-21-3-7.
