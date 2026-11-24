*> Acceptance test of docs/protocol/34-entity-models-4-farm-animals-equines.md section 1 (shared rules specific to these animals): 1.1 layer ids, 1.2 variants (model types, a null variant draws nothing),
*> 1.3 equipment layers (a baby with a null baby model never shows the item) and the layer type ordinals, 1.5 the layer registry table (shadow, models, layers in order), 1.6 ageScale and the baby shadow radius.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-4-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLEMM.
 COPY TESTLIB.
 01 WS-NAME                PIC X(160).
 01 WS-E                   FLOAT-LONG.
 01 WS-O                   FLOAT-LONG.
 01 WS-IN.
    05 WS-IV                FLOAT-LONG OCCURS 32 TIMES.
 01 WS-OUT.
    05 WS-OV                FLOAT-LONG OCCURS 64 TIMES.

 01 WS-X32               PIC X(32).
 01 WS-X32B              PIC X(32).
 01 WS-X120              PIC X(120).
 01 WS-X24               PIC X(24).
 01 WS-X40               PIC X(40).
 01 WS-FL                BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "cow" TO WS-X24
     CALL "EF4-REGISTRY" USING WS-X24 WS-IV(1) WS-X32 WS-X32B WS-FL
     MOVE "1.5 cow shadow radius" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 cow adult model layer" TO WS-NAME
     MOVE "COW" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.5 cow baby model layer" TO WS-NAME
     MOVE "COW_BABY" TO TL-EXPECTED
     MOVE WS-X32B TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.5 cow layers after the body" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "mooshroom" TO WS-X24
     CALL "EF4-REGISTRY" USING WS-X24 WS-IV(1) WS-X32 WS-X32B WS-FL
     MOVE "1.5 mooshroom shadow radius" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 mooshroom adult model layer" TO WS-NAME
     MOVE "MOOSHROOM" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.5 mooshroom baby model layer" TO WS-NAME
     MOVE "MOOSHROOM_BABY" TO TL-EXPECTED
     MOVE WS-X32B TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.5 mooshroom layers after the body" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "pig" TO WS-X24
     CALL "EF4-REGISTRY" USING WS-X24 WS-IV(1) WS-X32 WS-X32B WS-FL
     MOVE "1.5 pig shadow radius" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 pig adult model layer" TO WS-NAME
     MOVE "PIG" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.5 pig baby model layer" TO WS-NAME
     MOVE "PIG_BABY" TO TL-EXPECTED
     MOVE WS-X32B TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.5 pig layers after the body" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "sheep" TO WS-X24
     CALL "EF4-REGISTRY" USING WS-X24 WS-IV(1) WS-X32 WS-X32B WS-FL
     MOVE "1.5 sheep shadow radius" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 sheep adult model layer" TO WS-NAME
     MOVE "SHEEP" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.5 sheep baby model layer" TO WS-NAME
     MOVE "SHEEP_BABY" TO TL-EXPECTED
     MOVE WS-X32B TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.5 sheep layers after the body" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "chicken" TO WS-X24
     CALL "EF4-REGISTRY" USING WS-X24 WS-IV(1) WS-X32 WS-X32B WS-FL
     MOVE "1.5 chicken shadow radius" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 chicken adult model layer" TO WS-NAME
     MOVE "CHICKEN" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.5 chicken baby model layer" TO WS-NAME
     MOVE "CHICKEN_BABY" TO TL-EXPECTED
     MOVE WS-X32B TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.5 chicken layers after the body" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "goat" TO WS-X24
     CALL "EF4-REGISTRY" USING WS-X24 WS-IV(1) WS-X32 WS-X32B WS-FL
     MOVE "1.5 goat shadow radius" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 goat adult model layer" TO WS-NAME
     MOVE "GOAT" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.5 goat baby model layer" TO WS-NAME
     MOVE "GOAT_BABY" TO TL-EXPECTED
     MOVE WS-X32B TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.5 goat layers after the body" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "horse" TO WS-X24
     CALL "EF4-REGISTRY" USING WS-X24 WS-IV(1) WS-X32 WS-X32B WS-FL
     MOVE "1.5 horse shadow radius" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 horse adult model layer" TO WS-NAME
     MOVE "HORSE" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.5 horse baby model layer" TO WS-NAME
     MOVE "HORSE_BABY" TO TL-EXPECTED
     MOVE WS-X32B TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.5 horse layers after the body" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "donkey" TO WS-X24
     CALL "EF4-REGISTRY" USING WS-X24 WS-IV(1) WS-X32 WS-X32B WS-FL
     MOVE "1.5 donkey shadow radius" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 donkey adult model layer" TO WS-NAME
     MOVE "DONKEY" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.5 donkey baby model layer" TO WS-NAME
     MOVE "DONKEY_BABY" TO TL-EXPECTED
     MOVE WS-X32B TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.5 donkey layers after the body" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "mule" TO WS-X24
     CALL "EF4-REGISTRY" USING WS-X24 WS-IV(1) WS-X32 WS-X32B WS-FL
     MOVE "1.5 mule shadow radius" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 mule adult model layer" TO WS-NAME
     MOVE "MULE" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.5 mule baby model layer" TO WS-NAME
     MOVE "MULE_BABY" TO TL-EXPECTED
     MOVE WS-X32B TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.5 mule layers after the body" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "skeleton_horse" TO WS-X24
     CALL "EF4-REGISTRY" USING WS-X24 WS-IV(1) WS-X32 WS-X32B WS-FL
     MOVE "1.5 skeleton_horse shadow radius" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 skeleton_horse adult model layer" TO WS-NAME
     MOVE "SKELETON_HORSE" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.5 skeleton_horse baby model layer" TO WS-NAME
     MOVE "SKELETON_HORSE_BABY" TO TL-EXPECTED
     MOVE WS-X32B TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.5 skeleton_horse layers after the body" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "zombie_horse" TO WS-X24
     CALL "EF4-REGISTRY" USING WS-X24 WS-IV(1) WS-X32 WS-X32B WS-FL
     MOVE "1.5 zombie_horse shadow radius" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 zombie_horse adult model layer" TO WS-NAME
     MOVE "ZOMBIE_HORSE" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.5 zombie_horse baby model layer" TO WS-NAME
     MOVE "ZOMBIE_HORSE_BABY" TO TL-EXPECTED
     MOVE WS-X32B TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.5 zombie_horse layers after the body" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "llama" TO WS-X24
     CALL "EF4-REGISTRY" USING WS-X24 WS-IV(1) WS-X32 WS-X32B WS-FL
     MOVE "1.5 llama shadow radius" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 llama adult model layer" TO WS-NAME
     MOVE "LLAMA" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.5 llama baby model layer" TO WS-NAME
     MOVE "LLAMA_BABY" TO TL-EXPECTED
     MOVE WS-X32B TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.5 llama layers after the body" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "trader_llama" TO WS-X24
     CALL "EF4-REGISTRY" USING WS-X24 WS-IV(1) WS-X32 WS-X32B WS-FL
     MOVE "1.5 trader_llama shadow radius" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 trader_llama adult model layer" TO WS-NAME
     MOVE "TRADER_LLAMA" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.5 trader_llama baby model layer" TO WS-NAME
     MOVE "TRADER_LLAMA_BABY" TO TL-EXPECTED
     MOVE WS-X32B TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.5 trader_llama layers after the body" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "llama_spit" TO WS-X24
     CALL "EF4-REGISTRY" USING WS-X24 WS-IV(1) WS-X32 WS-X32B WS-FL
     MOVE "1.5 llama_spit shadow radius" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 llama_spit adult model layer" TO WS-NAME
     MOVE "LLAMA_SPIT" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.5 llama_spit baby model layer" TO WS-NAME
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-X32B TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.5 llama_spit layers after the body" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "camel" TO WS-X24
     CALL "EF4-REGISTRY" USING WS-X24 WS-IV(1) WS-X32 WS-X32B WS-FL
     MOVE "1.5 camel shadow radius" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 camel adult model layer" TO WS-NAME
     MOVE "CAMEL" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.5 camel baby model layer" TO WS-NAME
     MOVE "CAMEL_BABY" TO TL-EXPECTED
     MOVE WS-X32B TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.5 camel layers after the body" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "camel_husk" TO WS-X24
     CALL "EF4-REGISTRY" USING WS-X24 WS-IV(1) WS-X32 WS-X32B WS-FL
     MOVE "1.5 camel_husk shadow radius" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 camel_husk adult model layer" TO WS-NAME
     MOVE "CAMEL" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.5 camel_husk baby model layer" TO WS-NAME
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-X32B TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.5 camel_husk layers after the body" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "happy_ghast" TO WS-X24
     CALL "EF4-REGISTRY" USING WS-X24 WS-IV(1) WS-X32 WS-X32B WS-FL
     MOVE "1.5 happy_ghast shadow radius" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 happy_ghast adult model layer" TO WS-NAME
     MOVE "HAPPY_GHAST" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.5 happy_ghast baby model layer" TO WS-NAME
     MOVE "HAPPY_GHAST_BABY" TO TL-EXPECTED
     MOVE WS-X32B TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.5 happy_ghast layers after the body" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "rabbit" TO WS-X24
     CALL "EF4-REGISTRY" USING WS-X24 WS-IV(1) WS-X32 WS-X32B WS-FL
     MOVE "1.5 rabbit shadow radius" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 rabbit adult model layer" TO WS-NAME
     MOVE "RABBIT" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.5 rabbit baby model layer" TO WS-NAME
     MOVE "RABBIT_BABY" TO TL-EXPECTED
     MOVE WS-X32B TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.5 rabbit layers after the body" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "goat" TO WS-X24
     MOVE 0 TO WS-FL
     CALL "EF4-AGE-SCALE" USING WS-X24 WS-FL WS-IV(1)
     CALL "EF4-SHADOW" USING WS-X24 WS-FL WS-IV(2)
     MOVE "1.6 goat baby 0 ageScale" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 goat baby 0 shadow radius" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-IV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "goat" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF4-AGE-SCALE" USING WS-X24 WS-FL WS-IV(1)
     CALL "EF4-SHADOW" USING WS-X24 WS-FL WS-IV(2)
     MOVE "1.6 goat baby 1 ageScale" TO WS-NAME
     MOVE 0.55 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 goat baby 1 shadow radius" TO WS-NAME
     MOVE 0.385 TO WS-E
     MOVE WS-IV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "camel" TO WS-X24
     MOVE 0 TO WS-FL
     CALL "EF4-AGE-SCALE" USING WS-X24 WS-FL WS-IV(1)
     CALL "EF4-SHADOW" USING WS-X24 WS-FL WS-IV(2)
     MOVE "1.6 camel baby 0 ageScale" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 camel baby 0 shadow radius" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-IV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "camel" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF4-AGE-SCALE" USING WS-X24 WS-FL WS-IV(1)
     CALL "EF4-SHADOW" USING WS-X24 WS-FL WS-IV(2)
     MOVE "1.6 camel baby 1 ageScale" TO WS-NAME
     MOVE 0.6 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 camel baby 1 shadow radius" TO WS-NAME
     MOVE 0.42 TO WS-E
     MOVE WS-IV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "camel_husk" TO WS-X24
     MOVE 0 TO WS-FL
     CALL "EF4-AGE-SCALE" USING WS-X24 WS-FL WS-IV(1)
     CALL "EF4-SHADOW" USING WS-X24 WS-FL WS-IV(2)
     MOVE "1.6 camel_husk baby 0 ageScale" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 camel_husk baby 0 shadow radius" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-IV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "camel_husk" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF4-AGE-SCALE" USING WS-X24 WS-FL WS-IV(1)
     CALL "EF4-SHADOW" USING WS-X24 WS-FL WS-IV(2)
     MOVE "1.6 camel_husk baby 1 ageScale" TO WS-NAME
     MOVE 0.6 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 camel_husk baby 1 shadow radius" TO WS-NAME
     MOVE 0.42 TO WS-E
     MOVE WS-IV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "happy_ghast" TO WS-X24
     MOVE 0 TO WS-FL
     CALL "EF4-AGE-SCALE" USING WS-X24 WS-FL WS-IV(1)
     CALL "EF4-SHADOW" USING WS-X24 WS-FL WS-IV(2)
     MOVE "1.6 happy_ghast baby 0 ageScale" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 happy_ghast baby 0 shadow radius" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-IV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "happy_ghast" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF4-AGE-SCALE" USING WS-X24 WS-FL WS-IV(1)
     CALL "EF4-SHADOW" USING WS-X24 WS-FL WS-IV(2)
     MOVE "1.6 happy_ghast baby 1 ageScale" TO WS-NAME
     MOVE 0.2375 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 happy_ghast baby 1 shadow radius" TO WS-NAME
     MOVE 0.475 TO WS-E
     MOVE WS-IV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "cow" TO WS-X24
     MOVE 0 TO WS-FL
     CALL "EF4-AGE-SCALE" USING WS-X24 WS-FL WS-IV(1)
     CALL "EF4-SHADOW" USING WS-X24 WS-FL WS-IV(2)
     MOVE "1.6 cow baby 0 ageScale" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 cow baby 0 shadow radius" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-IV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "cow" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF4-AGE-SCALE" USING WS-X24 WS-FL WS-IV(1)
     CALL "EF4-SHADOW" USING WS-X24 WS-FL WS-IV(2)
     MOVE "1.6 cow baby 1 ageScale" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 cow baby 1 shadow radius" TO WS-NAME
     MOVE 0.35 TO WS-E
     MOVE WS-IV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "pig" TO WS-X24
     MOVE 0 TO WS-FL
     CALL "EF4-AGE-SCALE" USING WS-X24 WS-FL WS-IV(1)
     CALL "EF4-SHADOW" USING WS-X24 WS-FL WS-IV(2)
     MOVE "1.6 pig baby 0 ageScale" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 pig baby 0 shadow radius" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-IV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "pig" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF4-AGE-SCALE" USING WS-X24 WS-FL WS-IV(1)
     CALL "EF4-SHADOW" USING WS-X24 WS-FL WS-IV(2)
     MOVE "1.6 pig baby 1 ageScale" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 pig baby 1 shadow radius" TO WS-NAME
     MOVE 0.35 TO WS-E
     MOVE WS-IV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "sheep" TO WS-X24
     MOVE 0 TO WS-FL
     CALL "EF4-AGE-SCALE" USING WS-X24 WS-FL WS-IV(1)
     CALL "EF4-SHADOW" USING WS-X24 WS-FL WS-IV(2)
     MOVE "1.6 sheep baby 0 ageScale" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 sheep baby 0 shadow radius" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-IV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "sheep" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF4-AGE-SCALE" USING WS-X24 WS-FL WS-IV(1)
     CALL "EF4-SHADOW" USING WS-X24 WS-FL WS-IV(2)
     MOVE "1.6 sheep baby 1 ageScale" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 sheep baby 1 shadow radius" TO WS-NAME
     MOVE 0.35 TO WS-E
     MOVE WS-IV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "llama" TO WS-X24
     MOVE 0 TO WS-FL
     CALL "EF4-AGE-SCALE" USING WS-X24 WS-FL WS-IV(1)
     CALL "EF4-SHADOW" USING WS-X24 WS-FL WS-IV(2)
     MOVE "1.6 llama baby 0 ageScale" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 llama baby 0 shadow radius" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-IV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "llama" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF4-AGE-SCALE" USING WS-X24 WS-FL WS-IV(1)
     CALL "EF4-SHADOW" USING WS-X24 WS-FL WS-IV(2)
     MOVE "1.6 llama baby 1 ageScale" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 llama baby 1 shadow radius" TO WS-NAME
     MOVE 0.35 TO WS-E
     MOVE WS-IV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "horse" TO WS-X24
     MOVE 0 TO WS-FL
     CALL "EF4-AGE-SCALE" USING WS-X24 WS-FL WS-IV(1)
     CALL "EF4-SHADOW" USING WS-X24 WS-FL WS-IV(2)
     MOVE "1.6 horse baby 0 ageScale" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 horse baby 0 shadow radius" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-IV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "horse" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF4-AGE-SCALE" USING WS-X24 WS-FL WS-IV(1)
     CALL "EF4-SHADOW" USING WS-X24 WS-FL WS-IV(2)
     MOVE "1.6 horse baby 1 ageScale" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 horse baby 1 shadow radius" TO WS-NAME
     MOVE 0.375 TO WS-E
     MOVE WS-IV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "donkey" TO WS-X24
     MOVE 0 TO WS-FL
     CALL "EF4-AGE-SCALE" USING WS-X24 WS-FL WS-IV(1)
     CALL "EF4-SHADOW" USING WS-X24 WS-FL WS-IV(2)
     MOVE "1.6 donkey baby 0 ageScale" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 donkey baby 0 shadow radius" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-IV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "donkey" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF4-AGE-SCALE" USING WS-X24 WS-FL WS-IV(1)
     CALL "EF4-SHADOW" USING WS-X24 WS-FL WS-IV(2)
     MOVE "1.6 donkey baby 1 ageScale" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 donkey baby 1 shadow radius" TO WS-NAME
     MOVE 0.375 TO WS-E
     MOVE WS-IV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "skeleton_horse" TO WS-X24
     MOVE 0 TO WS-FL
     CALL "EF4-AGE-SCALE" USING WS-X24 WS-FL WS-IV(1)
     CALL "EF4-SHADOW" USING WS-X24 WS-FL WS-IV(2)
     MOVE "1.6 skeleton_horse baby 0 ageScale" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 skeleton_horse baby 0 shadow radius" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-IV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "skeleton_horse" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF4-AGE-SCALE" USING WS-X24 WS-FL WS-IV(1)
     CALL "EF4-SHADOW" USING WS-X24 WS-FL WS-IV(2)
     MOVE "1.6 skeleton_horse baby 1 ageScale" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 skeleton_horse baby 1 shadow radius" TO WS-NAME
     MOVE 0.375 TO WS-E
     MOVE WS-IV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "chicken" TO WS-X24
     MOVE 0 TO WS-FL
     CALL "EF4-AGE-SCALE" USING WS-X24 WS-FL WS-IV(1)
     CALL "EF4-SHADOW" USING WS-X24 WS-FL WS-IV(2)
     MOVE "1.6 chicken baby 0 ageScale" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 chicken baby 0 shadow radius" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-IV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "chicken" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF4-AGE-SCALE" USING WS-X24 WS-FL WS-IV(1)
     CALL "EF4-SHADOW" USING WS-X24 WS-FL WS-IV(2)
     MOVE "1.6 chicken baby 1 ageScale" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 chicken baby 1 shadow radius" TO WS-NAME
     MOVE 0.15 TO WS-E
     MOVE WS-IV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "rabbit" TO WS-X24
     MOVE 0 TO WS-FL
     CALL "EF4-AGE-SCALE" USING WS-X24 WS-FL WS-IV(1)
     CALL "EF4-SHADOW" USING WS-X24 WS-FL WS-IV(2)
     MOVE "1.6 rabbit baby 0 ageScale" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 rabbit baby 0 shadow radius" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-IV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "rabbit" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF4-AGE-SCALE" USING WS-X24 WS-FL WS-IV(1)
     CALL "EF4-SHADOW" USING WS-X24 WS-FL WS-IV(2)
     MOVE "1.6 rabbit baby 1 ageScale" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 rabbit baby 1 shadow radius" TO WS-NAME
     MOVE 0.15 TO WS-E
     MOVE WS-IV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.8 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF4-HEAD-EAT" USING WS-IN WS-OUT
     MOVE "1.6 adult sheep head y += 0.8 x 9 x 1" TO WS-NAME
     MOVE 7.2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.8 TO WS-IV(1)
     MOVE 0.5 TO WS-IV(2)
     CALL "EF4-HEAD-EAT" USING WS-IN WS-OUT
     MOVE "1.6 baby sheep head y += 0.8 x 9 x 0.5" TO WS-NAME
     MOVE 3.6 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.6 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF4-TAIL-OFFSET" USING WS-IN WS-OUT
     MOVE "1.6 adult equine tail y and z offsets for s 0.6 [1]" TO WS-NAME
     MOVE 0.6 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 adult equine tail y and z offsets for s 0.6 [2]" TO WS-NAME
     MOVE 1.2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.6 TO WS-IV(1)
     MOVE 0.5 TO WS-IV(2)
     CALL "EF4-TAIL-OFFSET" USING WS-IN WS-OUT
     MOVE "1.6 baby equine tail y and z offsets for s 0.6 [1]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 baby equine tail y and z offsets for s 0.6 [2]" TO WS-NAME
     MOVE 0.6 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF4-EQUIP-DRAWN" USING WS-IN WS-OUT
     MOVE "1.3 equippable 0 asset 0 baby 0 baby model 0 drawn" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-EQUIP-DRAWN" USING WS-IN WS-OUT
     MOVE "1.3 equippable 0 asset 0 baby 0 baby model 1 drawn" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF4-EQUIP-DRAWN" USING WS-IN WS-OUT
     MOVE "1.3 equippable 0 asset 0 baby 1 baby model 0 drawn" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-EQUIP-DRAWN" USING WS-IN WS-OUT
     MOVE "1.3 equippable 0 asset 0 baby 1 baby model 1 drawn" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF4-EQUIP-DRAWN" USING WS-IN WS-OUT
     MOVE "1.3 equippable 0 asset 1 baby 0 baby model 0 drawn" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-EQUIP-DRAWN" USING WS-IN WS-OUT
     MOVE "1.3 equippable 0 asset 1 baby 0 baby model 1 drawn" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF4-EQUIP-DRAWN" USING WS-IN WS-OUT
     MOVE "1.3 equippable 0 asset 1 baby 1 baby model 0 drawn" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-EQUIP-DRAWN" USING WS-IN WS-OUT
     MOVE "1.3 equippable 0 asset 1 baby 1 baby model 1 drawn" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF4-EQUIP-DRAWN" USING WS-IN WS-OUT
     MOVE "1.3 equippable 1 asset 0 baby 0 baby model 0 drawn" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-EQUIP-DRAWN" USING WS-IN WS-OUT
     MOVE "1.3 equippable 1 asset 0 baby 0 baby model 1 drawn" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF4-EQUIP-DRAWN" USING WS-IN WS-OUT
     MOVE "1.3 equippable 1 asset 0 baby 1 baby model 0 drawn" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-EQUIP-DRAWN" USING WS-IN WS-OUT
     MOVE "1.3 equippable 1 asset 0 baby 1 baby model 1 drawn" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF4-EQUIP-DRAWN" USING WS-IN WS-OUT
     MOVE "1.3 equippable 1 asset 1 baby 0 baby model 0 drawn" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-EQUIP-DRAWN" USING WS-IN WS-OUT
     MOVE "1.3 equippable 1 asset 1 baby 0 baby model 1 drawn" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF4-EQUIP-DRAWN" USING WS-IN WS-OUT
     MOVE "1.3 equippable 1 asset 1 baby 1 baby model 0 drawn" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-EQUIP-DRAWN" USING WS-IN WS-OUT
     MOVE "1.3 equippable 1 asset 1 baby 1 baby model 1 drawn" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "horse_body" TO WS-X40
     CALL "EF4-LAYER-TYPE" USING WS-X40 WS-FL
     MOVE "1.3 layer type horse_body ordinal" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "llama_body" TO WS-X40
     CALL "EF4-LAYER-TYPE" USING WS-X40 WS-FL
     MOVE "1.3 layer type llama_body ordinal" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "pig_saddle" TO WS-X40
     CALL "EF4-LAYER-TYPE" USING WS-X40 WS-FL
     MOVE "1.3 layer type pig_saddle ordinal" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "camel_saddle" TO WS-X40
     CALL "EF4-LAYER-TYPE" USING WS-X40 WS-FL
     MOVE "1.3 layer type camel_saddle ordinal" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "camel_husk_saddle" TO WS-X40
     CALL "EF4-LAYER-TYPE" USING WS-X40 WS-FL
     MOVE "1.3 layer type camel_husk_saddle ordinal" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "horse_saddle" TO WS-X40
     CALL "EF4-LAYER-TYPE" USING WS-X40 WS-FL
     MOVE "1.3 layer type horse_saddle ordinal" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "donkey_saddle" TO WS-X40
     CALL "EF4-LAYER-TYPE" USING WS-X40 WS-FL
     MOVE "1.3 layer type donkey_saddle ordinal" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "mule_saddle" TO WS-X40
     CALL "EF4-LAYER-TYPE" USING WS-X40 WS-FL
     MOVE "1.3 layer type mule_saddle ordinal" TO WS-NAME
     MOVE 13 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "zombie_horse_saddle" TO WS-X40
     CALL "EF4-LAYER-TYPE" USING WS-X40 WS-FL
     MOVE "1.3 layer type zombie_horse_saddle ordinal" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "skeleton_horse_saddle" TO WS-X40
     CALL "EF4-LAYER-TYPE" USING WS-X40 WS-FL
     MOVE "1.3 layer type skeleton_horse_saddle ordinal" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "happy_ghast_body" TO WS-X40
     CALL "EF4-LAYER-TYPE" USING WS-X40 WS-FL
     MOVE "1.3 layer type happy_ghast_body ordinal" TO WS-NAME
     MOVE 16 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "unknown_type" TO WS-X40
     CALL "EF4-LAYER-TYPE" USING WS-X40 WS-FL
     MOVE "1.3 layer type unknown_type ordinal" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "horse" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF4-LAYER-ORDER" USING WS-X24 WS-FL WS-IV(1)
     MOVE "1.3 horse layer kind 1 sub-order" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "horse" TO WS-X24
     MOVE 2 TO WS-FL
     CALL "EF4-LAYER-ORDER" USING WS-X24 WS-FL WS-IV(1)
     MOVE "1.3 horse layer kind 2 sub-order" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "donkey" TO WS-X24
     MOVE 2 TO WS-FL
     CALL "EF4-LAYER-ORDER" USING WS-X24 WS-FL WS-IV(1)
     MOVE "1.3 donkey layer kind 2 sub-order" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "skeleton_horse" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF4-LAYER-ORDER" USING WS-X24 WS-FL WS-IV(1)
     MOVE "1.3 skeleton_horse layer kind 1 sub-order" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "skeleton_horse" TO WS-X24
     MOVE 2 TO WS-FL
     CALL "EF4-LAYER-ORDER" USING WS-X24 WS-FL WS-IV(1)
     MOVE "1.3 skeleton_horse layer kind 2 sub-order" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "zombie_horse" TO WS-X24
     MOVE 2 TO WS-FL
     CALL "EF4-LAYER-ORDER" USING WS-X24 WS-FL WS-IV(1)
     MOVE "1.3 zombie_horse layer kind 2 sub-order" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "camel" TO WS-X24
     MOVE 2 TO WS-FL
     CALL "EF4-LAYER-ORDER" USING WS-X24 WS-FL WS-IV(1)
     MOVE "1.3 camel layer kind 2 sub-order" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "happy_ghast" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF4-LAYER-ORDER" USING WS-X24 WS-FL WS-IV(1)
     MOVE "1.3 happy_ghast layer kind 1 sub-order" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "pig" TO WS-X24
     MOVE 2 TO WS-FL
     CALL "EF4-LAYER-ORDER" USING WS-X24 WS-FL WS-IV(1)
     MOVE "1.3 pig layer kind 2 sub-order" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "cow" TO WS-X24
     MOVE "normal" TO WS-X40
     MOVE 0 TO WS-FL
     CALL "EF4-VARIANT-MODEL" USING WS-X24 WS-X40 WS-FL WS-X32
     MOVE "1.2 cow model type normal baby 0 layer" TO WS-NAME
     MOVE "COW" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "cow" TO WS-X24
     MOVE "normal" TO WS-X40
     MOVE 1 TO WS-FL
     CALL "EF4-VARIANT-MODEL" USING WS-X24 WS-X40 WS-FL WS-X32
     MOVE "1.2 cow model type normal baby 1 layer" TO WS-NAME
     MOVE "COW_BABY" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "cow" TO WS-X24
     MOVE "warm" TO WS-X40
     MOVE 0 TO WS-FL
     CALL "EF4-VARIANT-MODEL" USING WS-X24 WS-X40 WS-FL WS-X32
     MOVE "1.2 cow model type warm baby 0 layer" TO WS-NAME
     MOVE "WARM_COW" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "cow" TO WS-X24
     MOVE "warm" TO WS-X40
     MOVE 1 TO WS-FL
     CALL "EF4-VARIANT-MODEL" USING WS-X24 WS-X40 WS-FL WS-X32
     MOVE "1.2 cow model type warm baby 1 layer" TO WS-NAME
     MOVE "WARM_COW_BABY" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "cow" TO WS-X24
     MOVE "cold" TO WS-X40
     MOVE 0 TO WS-FL
     CALL "EF4-VARIANT-MODEL" USING WS-X24 WS-X40 WS-FL WS-X32
     MOVE "1.2 cow model type cold baby 0 layer" TO WS-NAME
     MOVE "COLD_COW" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "cow" TO WS-X24
     MOVE "cold" TO WS-X40
     MOVE 1 TO WS-FL
     CALL "EF4-VARIANT-MODEL" USING WS-X24 WS-X40 WS-FL WS-X32
     MOVE "1.2 cow model type cold baby 1 layer" TO WS-NAME
     MOVE "COLD_COW_BABY" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "pig" TO WS-X24
     MOVE "normal" TO WS-X40
     MOVE 0 TO WS-FL
     CALL "EF4-VARIANT-MODEL" USING WS-X24 WS-X40 WS-FL WS-X32
     MOVE "1.2 pig model type normal baby 0 layer" TO WS-NAME
     MOVE "PIG" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "pig" TO WS-X24
     MOVE "normal" TO WS-X40
     MOVE 1 TO WS-FL
     CALL "EF4-VARIANT-MODEL" USING WS-X24 WS-X40 WS-FL WS-X32
     MOVE "1.2 pig model type normal baby 1 layer" TO WS-NAME
     MOVE "PIG_BABY" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "pig" TO WS-X24
     MOVE "cold" TO WS-X40
     MOVE 0 TO WS-FL
     CALL "EF4-VARIANT-MODEL" USING WS-X24 WS-X40 WS-FL WS-X32
     MOVE "1.2 pig model type cold baby 0 layer" TO WS-NAME
     MOVE "COLD_PIG" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "pig" TO WS-X24
     MOVE "cold" TO WS-X40
     MOVE 1 TO WS-FL
     CALL "EF4-VARIANT-MODEL" USING WS-X24 WS-X40 WS-FL WS-X32
     MOVE "1.2 pig model type cold baby 1 layer" TO WS-NAME
     MOVE "PIG_BABY" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "chicken" TO WS-X24
     MOVE "normal" TO WS-X40
     MOVE 0 TO WS-FL
     CALL "EF4-VARIANT-MODEL" USING WS-X24 WS-X40 WS-FL WS-X32
     MOVE "1.2 chicken model type normal baby 0 layer" TO WS-NAME
     MOVE "CHICKEN" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "chicken" TO WS-X24
     MOVE "normal" TO WS-X40
     MOVE 1 TO WS-FL
     CALL "EF4-VARIANT-MODEL" USING WS-X24 WS-X40 WS-FL WS-X32
     MOVE "1.2 chicken model type normal baby 1 layer" TO WS-NAME
     MOVE "CHICKEN_BABY" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "chicken" TO WS-X24
     MOVE "cold" TO WS-X40
     MOVE 0 TO WS-FL
     CALL "EF4-VARIANT-MODEL" USING WS-X24 WS-X40 WS-FL WS-X32
     MOVE "1.2 chicken model type cold baby 0 layer" TO WS-NAME
     MOVE "COLD_CHICKEN" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "chicken" TO WS-X24
     MOVE "cold" TO WS-X40
     MOVE 1 TO WS-FL
     CALL "EF4-VARIANT-MODEL" USING WS-X24 WS-X40 WS-FL WS-X32
     MOVE "1.2 chicken model type cold baby 1 layer" TO WS-NAME
     MOVE "CHICKEN_BABY" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 1 TO WS-IV(1)
     CALL "EF4-VARIANT-DRAW" USING WS-IN WS-OUT
     MOVE "1.2 null variant: draws nothing, texture is the missing texture [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 null variant: draws nothing, texture is the missing texture [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF4-VARIANT-DRAW" USING WS-IN WS-OUT
     MOVE "1.2 resolved variant: draws, texture from the variant [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 resolved variant: draws, texture from the variant [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-4§1 Shared rules specific to these animals: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-4§1 Shared rules specific to these animals: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-4-1.
