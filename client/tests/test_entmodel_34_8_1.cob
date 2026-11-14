*> Acceptance test of docs/protocol/34-entity-models-8-aquatic-nautilus-boats.md section 1 (family overview): 1.1 the entity type table (base shadow radius, the model layers baked), 1.2 the texture paths including the axolotl variants, the tropical fish bases and the 11 boat woods,
*> 1.3 hitbox, eye height and name tag height, and the baby rule (the baby model only; the age scale reaches the shadow).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-8-1.
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
 01 WS-X60               PIC X(60).
 PROCEDURE DIVISION.
     MOVE "squid" TO WS-X24
     CALL "EF8-ENTITY" USING WS-X24 WS-OUT
     MOVE "1.1 squid found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 squid base shadow radius (-1 computed from the puff state)" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 squid model layers" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "squid" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF8-ENTITY-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.1 squid layer 1" TO WS-NAME
     MOVE "squid" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "squid" TO WS-X24
     MOVE 2 TO WS-FL
     CALL "EF8-ENTITY-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.1 squid layer 2" TO WS-NAME
     MOVE "squid_baby" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "squid" TO WS-X24
     CALL "EF8-HITBOX" USING WS-X24 WS-OUT
     MOVE "1.3 squid hitbox width" TO WS-NAME
     MOVE 0.8 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 squid hitbox height" TO WS-NAME
     MOVE 0.8 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 squid eye height" TO WS-NAME
     MOVE 0.4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 squid name tag height (the box height)" TO WS-NAME
     MOVE 0.8 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "glow_squid" TO WS-X24
     CALL "EF8-ENTITY" USING WS-X24 WS-OUT
     MOVE "1.1 glow_squid found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 glow_squid base shadow radius (-1 computed from the puff state)" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 glow_squid model layers" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "glow_squid" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF8-ENTITY-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.1 glow_squid layer 1" TO WS-NAME
     MOVE "glow_squid" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "glow_squid" TO WS-X24
     MOVE 2 TO WS-FL
     CALL "EF8-ENTITY-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.1 glow_squid layer 2" TO WS-NAME
     MOVE "glow_squid_baby" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "glow_squid" TO WS-X24
     CALL "EF8-HITBOX" USING WS-X24 WS-OUT
     MOVE "1.3 glow_squid hitbox width" TO WS-NAME
     MOVE 0.8 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 glow_squid hitbox height" TO WS-NAME
     MOVE 0.8 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 glow_squid eye height" TO WS-NAME
     MOVE 0.4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 glow_squid name tag height (the box height)" TO WS-NAME
     MOVE 0.8 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "dolphin" TO WS-X24
     CALL "EF8-ENTITY" USING WS-X24 WS-OUT
     MOVE "1.1 dolphin found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 dolphin base shadow radius (-1 computed from the puff state)" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 dolphin model layers" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "dolphin" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF8-ENTITY-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.1 dolphin layer 1" TO WS-NAME
     MOVE "dolphin" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "dolphin" TO WS-X24
     MOVE 2 TO WS-FL
     CALL "EF8-ENTITY-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.1 dolphin layer 2" TO WS-NAME
     MOVE "dolphin_baby" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "dolphin" TO WS-X24
     MOVE 3 TO WS-FL
     CALL "EF8-ENTITY-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.1 dolphin layer 3" TO WS-NAME
     MOVE "DolphinCarryingItemLayer" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "dolphin" TO WS-X24
     CALL "EF8-HITBOX" USING WS-X24 WS-OUT
     MOVE "1.3 dolphin hitbox width" TO WS-NAME
     MOVE 0.9 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 dolphin hitbox height" TO WS-NAME
     MOVE 0.6 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 dolphin eye height" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 dolphin name tag height (the box height)" TO WS-NAME
     MOVE 0.6 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "axolotl" TO WS-X24
     CALL "EF8-ENTITY" USING WS-X24 WS-OUT
     MOVE "1.1 axolotl found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 axolotl base shadow radius (-1 computed from the puff state)" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 axolotl model layers" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "axolotl" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF8-ENTITY-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.1 axolotl layer 1" TO WS-NAME
     MOVE "axolotl" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "axolotl" TO WS-X24
     MOVE 2 TO WS-FL
     CALL "EF8-ENTITY-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.1 axolotl layer 2" TO WS-NAME
     MOVE "axolotl_baby" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "axolotl" TO WS-X24
     CALL "EF8-HITBOX" USING WS-X24 WS-OUT
     MOVE "1.3 axolotl hitbox width" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 axolotl hitbox height" TO WS-NAME
     MOVE 0.42 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 axolotl eye height" TO WS-NAME
     MOVE 0.2751 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 axolotl name tag height (the box height)" TO WS-NAME
     MOVE 0.42 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "cod" TO WS-X24
     CALL "EF8-ENTITY" USING WS-X24 WS-OUT
     MOVE "1.1 cod found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 cod base shadow radius (-1 computed from the puff state)" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 cod model layers" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "cod" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF8-ENTITY-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.1 cod layer 1" TO WS-NAME
     MOVE "cod" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "cod" TO WS-X24
     CALL "EF8-HITBOX" USING WS-X24 WS-OUT
     MOVE "1.3 cod hitbox width" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 cod hitbox height" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 cod eye height" TO WS-NAME
     MOVE 0.195 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 cod name tag height (the box height)" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "salmon" TO WS-X24
     CALL "EF8-ENTITY" USING WS-X24 WS-OUT
     MOVE "1.1 salmon found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 salmon base shadow radius (-1 computed from the puff state)" TO WS-NAME
     MOVE 0.4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 salmon model layers" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "salmon" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF8-ENTITY-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.1 salmon layer 1" TO WS-NAME
     MOVE "salmon_small" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "salmon" TO WS-X24
     MOVE 2 TO WS-FL
     CALL "EF8-ENTITY-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.1 salmon layer 2" TO WS-NAME
     MOVE "salmon" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "salmon" TO WS-X24
     MOVE 3 TO WS-FL
     CALL "EF8-ENTITY-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.1 salmon layer 3" TO WS-NAME
     MOVE "salmon_large" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "salmon" TO WS-X24
     CALL "EF8-HITBOX" USING WS-X24 WS-OUT
     MOVE "1.3 salmon hitbox width" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 salmon hitbox height" TO WS-NAME
     MOVE 0.4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 salmon eye height" TO WS-NAME
     MOVE 0.26 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 salmon name tag height (the box height)" TO WS-NAME
     MOVE 0.4 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "pufferfish" TO WS-X24
     CALL "EF8-ENTITY" USING WS-X24 WS-OUT
     MOVE "1.1 pufferfish found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 pufferfish base shadow radius (-1 computed from the puff state)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 pufferfish model layers" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "pufferfish" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF8-ENTITY-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.1 pufferfish layer 1" TO WS-NAME
     MOVE "pufferfish_small" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "pufferfish" TO WS-X24
     MOVE 2 TO WS-FL
     CALL "EF8-ENTITY-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.1 pufferfish layer 2" TO WS-NAME
     MOVE "pufferfish_medium" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "pufferfish" TO WS-X24
     MOVE 3 TO WS-FL
     CALL "EF8-ENTITY-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.1 pufferfish layer 3" TO WS-NAME
     MOVE "pufferfish_big" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "pufferfish" TO WS-X24
     CALL "EF8-HITBOX" USING WS-X24 WS-OUT
     MOVE "1.3 pufferfish hitbox width" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 pufferfish hitbox height" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 pufferfish eye height" TO WS-NAME
     MOVE 0.455 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 pufferfish name tag height (the box height)" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tropical_fish" TO WS-X24
     CALL "EF8-ENTITY" USING WS-X24 WS-OUT
     MOVE "1.1 tropical_fish found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 tropical_fish base shadow radius (-1 computed from the puff state)" TO WS-NAME
     MOVE 0.15 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 tropical_fish model layers" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tropical_fish" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF8-ENTITY-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.1 tropical_fish layer 1" TO WS-NAME
     MOVE "tropical_fish_small" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "tropical_fish" TO WS-X24
     MOVE 2 TO WS-FL
     CALL "EF8-ENTITY-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.1 tropical_fish layer 2" TO WS-NAME
     MOVE "tropical_fish_large" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "tropical_fish" TO WS-X24
     MOVE 3 TO WS-FL
     CALL "EF8-ENTITY-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.1 tropical_fish layer 3" TO WS-NAME
     MOVE "tropical_fish_small_pattern" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "tropical_fish" TO WS-X24
     MOVE 4 TO WS-FL
     CALL "EF8-ENTITY-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.1 tropical_fish layer 4" TO WS-NAME
     MOVE "tropical_fish_large_pattern" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "tropical_fish" TO WS-X24
     CALL "EF8-HITBOX" USING WS-X24 WS-OUT
     MOVE "1.3 tropical_fish hitbox width" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 tropical_fish hitbox height" TO WS-NAME
     MOVE 0.4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 tropical_fish eye height" TO WS-NAME
     MOVE 0.26 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 tropical_fish name tag height (the box height)" TO WS-NAME
     MOVE 0.4 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "nautilus" TO WS-X24
     CALL "EF8-ENTITY" USING WS-X24 WS-OUT
     MOVE "1.1 nautilus found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 nautilus base shadow radius (-1 computed from the puff state)" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 nautilus model layers" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "nautilus" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF8-ENTITY-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.1 nautilus layer 1" TO WS-NAME
     MOVE "nautilus" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "nautilus" TO WS-X24
     MOVE 2 TO WS-FL
     CALL "EF8-ENTITY-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.1 nautilus layer 2" TO WS-NAME
     MOVE "nautilus_baby" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "nautilus" TO WS-X24
     MOVE 3 TO WS-FL
     CALL "EF8-ENTITY-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.1 nautilus layer 3" TO WS-NAME
     MOVE "nautilus_armor" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "nautilus" TO WS-X24
     MOVE 4 TO WS-FL
     CALL "EF8-ENTITY-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.1 nautilus layer 4" TO WS-NAME
     MOVE "nautilus_saddle" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "nautilus" TO WS-X24
     CALL "EF8-HITBOX" USING WS-X24 WS-OUT
     MOVE "1.3 nautilus hitbox width" TO WS-NAME
     MOVE 0.875 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 nautilus hitbox height" TO WS-NAME
     MOVE 0.95 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 nautilus eye height" TO WS-NAME
     MOVE 0.2751 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 nautilus name tag height (the box height)" TO WS-NAME
     MOVE 0.95 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "zombie_nautilus" TO WS-X24
     CALL "EF8-ENTITY" USING WS-X24 WS-OUT
     MOVE "1.1 zombie_nautilus found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 zombie_nautilus base shadow radius (-1 computed from the puff state)" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 zombie_nautilus model layers" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "zombie_nautilus" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF8-ENTITY-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.1 zombie_nautilus layer 1" TO WS-NAME
     MOVE "zombie_nautilus" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "zombie_nautilus" TO WS-X24
     MOVE 2 TO WS-FL
     CALL "EF8-ENTITY-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.1 zombie_nautilus layer 2" TO WS-NAME
     MOVE "zombie_nautilus_coral" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "zombie_nautilus" TO WS-X24
     MOVE 3 TO WS-FL
     CALL "EF8-ENTITY-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.1 zombie_nautilus layer 3" TO WS-NAME
     MOVE "nautilus_armor" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "zombie_nautilus" TO WS-X24
     MOVE 4 TO WS-FL
     CALL "EF8-ENTITY-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.1 zombie_nautilus layer 4" TO WS-NAME
     MOVE "nautilus_saddle" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "zombie_nautilus" TO WS-X24
     CALL "EF8-HITBOX" USING WS-X24 WS-OUT
     MOVE "1.3 zombie_nautilus hitbox width" TO WS-NAME
     MOVE 0.875 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 zombie_nautilus hitbox height" TO WS-NAME
     MOVE 0.95 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 zombie_nautilus eye height" TO WS-NAME
     MOVE 0.2751 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 zombie_nautilus name tag height (the box height)" TO WS-NAME
     MOVE 0.95 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "boat" TO WS-X24
     CALL "EF8-ENTITY" USING WS-X24 WS-OUT
     MOVE "1.1 boat found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 boat base shadow radius (-1 computed from the puff state)" TO WS-NAME
     MOVE 0.8 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 boat model layers" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "boat" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF8-ENTITY-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.1 boat layer 1" TO WS-NAME
     MOVE "boat" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "boat" TO WS-X24
     MOVE 2 TO WS-FL
     CALL "EF8-ENTITY-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.1 boat layer 2" TO WS-NAME
     MOVE "chest_boat" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "boat" TO WS-X24
     MOVE 3 TO WS-FL
     CALL "EF8-ENTITY-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.1 boat layer 3" TO WS-NAME
     MOVE "boat#water_patch" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "boat" TO WS-X24
     CALL "EF8-HITBOX" USING WS-X24 WS-OUT
     MOVE "1.3 boat hitbox width" TO WS-NAME
     MOVE 1.375 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 boat hitbox height" TO WS-NAME
     MOVE 0.5625 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 boat eye height" TO WS-NAME
     MOVE 0.5625 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 boat name tag height (the box height)" TO WS-NAME
     MOVE 0.5625 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "raft" TO WS-X24
     CALL "EF8-ENTITY" USING WS-X24 WS-OUT
     MOVE "1.1 raft found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 raft base shadow radius (-1 computed from the puff state)" TO WS-NAME
     MOVE 0.8 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 raft model layers" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "raft" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF8-ENTITY-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.1 raft layer 1" TO WS-NAME
     MOVE "boat/bamboo" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "raft" TO WS-X24
     MOVE 2 TO WS-FL
     CALL "EF8-ENTITY-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.1 raft layer 2" TO WS-NAME
     MOVE "chest_boat/bamboo" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "raft" TO WS-X24
     CALL "EF8-HITBOX" USING WS-X24 WS-OUT
     MOVE "1.3 raft hitbox width" TO WS-NAME
     MOVE 1.375 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 raft hitbox height" TO WS-NAME
     MOVE 0.5625 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 raft eye height" TO WS-NAME
     MOVE 0.5625 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 raft name tag height (the box height)" TO WS-NAME
     MOVE 0.5625 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "creeper" TO WS-X24
     CALL "EF8-ENTITY" USING WS-X24 WS-OUT
     MOVE "1.1 an entity of another part is not found" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "squid" TO WS-X24
     MOVE 9 TO WS-FL
     MOVE "x" TO WS-X32
     CALL "EF8-ENTITY-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.1 a layer past the end is blank" TO WS-NAME
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "squid" TO WS-X24
     MOVE 1 TO WS-FL
     MOVE SPACES TO WS-X60
     CALL "EF8-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "1.2 squid texture kind 1" TO WS-NAME
     MOVE "squid/squid.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "squid" TO WS-X24
     MOVE 2 TO WS-FL
     MOVE SPACES TO WS-X60
     CALL "EF8-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "1.2 squid texture kind 2" TO WS-NAME
     MOVE "squid/squid_baby.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "glow_squid" TO WS-X24
     MOVE 1 TO WS-FL
     MOVE SPACES TO WS-X60
     CALL "EF8-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "1.2 glow_squid texture kind 1" TO WS-NAME
     MOVE "squid/glow_squid.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "glow_squid" TO WS-X24
     MOVE 2 TO WS-FL
     MOVE SPACES TO WS-X60
     CALL "EF8-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "1.2 glow_squid texture kind 2" TO WS-NAME
     MOVE "squid/glow_squid_baby.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "dolphin" TO WS-X24
     MOVE 1 TO WS-FL
     MOVE SPACES TO WS-X60
     CALL "EF8-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "1.2 dolphin texture kind 1" TO WS-NAME
     MOVE "dolphin/dolphin.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "dolphin" TO WS-X24
     MOVE 2 TO WS-FL
     MOVE SPACES TO WS-X60
     CALL "EF8-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "1.2 dolphin texture kind 2" TO WS-NAME
     MOVE "dolphin/dolphin_baby.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "cod" TO WS-X24
     MOVE 1 TO WS-FL
     MOVE SPACES TO WS-X60
     CALL "EF8-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "1.2 cod texture kind 1" TO WS-NAME
     MOVE "fish/cod.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "salmon" TO WS-X24
     MOVE 1 TO WS-FL
     MOVE SPACES TO WS-X60
     CALL "EF8-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "1.2 salmon texture kind 1" TO WS-NAME
     MOVE "fish/salmon.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "pufferfish" TO WS-X24
     MOVE 1 TO WS-FL
     MOVE SPACES TO WS-X60
     CALL "EF8-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "1.2 pufferfish texture kind 1" TO WS-NAME
     MOVE "fish/pufferfish.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "tropical_fish" TO WS-X24
     MOVE 1 TO WS-FL
     MOVE SPACES TO WS-X60
     CALL "EF8-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "1.2 tropical_fish texture kind 1" TO WS-NAME
     MOVE "fish/tropical_a.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "tropical_fish" TO WS-X24
     MOVE 2 TO WS-FL
     MOVE SPACES TO WS-X60
     CALL "EF8-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "1.2 tropical_fish texture kind 2" TO WS-NAME
     MOVE "fish/tropical_b.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "nautilus" TO WS-X24
     MOVE 1 TO WS-FL
     MOVE SPACES TO WS-X60
     CALL "EF8-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "1.2 nautilus texture kind 1" TO WS-NAME
     MOVE "nautilus/nautilus.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "nautilus" TO WS-X24
     MOVE 2 TO WS-FL
     MOVE SPACES TO WS-X60
     CALL "EF8-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "1.2 nautilus texture kind 2" TO WS-NAME
     MOVE "nautilus/nautilus_baby.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE SPACES TO WS-X60
     CALL "EF8-AXOLOTL-TEXTURE" USING WS-IN WS-X60
     MOVE "1.2 axolotl variant lucy baby 0" TO WS-NAME
     MOVE "axolotl/axolotl_lucy.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE SPACES TO WS-X60
     CALL "EF8-AXOLOTL-TEXTURE" USING WS-IN WS-X60
     MOVE "1.2 axolotl variant lucy baby 1" TO WS-NAME
     MOVE "axolotl/axolotl_lucy_baby.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 2 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE SPACES TO WS-X60
     CALL "EF8-AXOLOTL-TEXTURE" USING WS-IN WS-X60
     MOVE "1.2 axolotl variant wild baby 0" TO WS-NAME
     MOVE "axolotl/axolotl_wild.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 2 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE SPACES TO WS-X60
     CALL "EF8-AXOLOTL-TEXTURE" USING WS-IN WS-X60
     MOVE "1.2 axolotl variant wild baby 1" TO WS-NAME
     MOVE "axolotl/axolotl_wild_baby.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 3 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE SPACES TO WS-X60
     CALL "EF8-AXOLOTL-TEXTURE" USING WS-IN WS-X60
     MOVE "1.2 axolotl variant gold baby 0" TO WS-NAME
     MOVE "axolotl/axolotl_gold.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 3 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE SPACES TO WS-X60
     CALL "EF8-AXOLOTL-TEXTURE" USING WS-IN WS-X60
     MOVE "1.2 axolotl variant gold baby 1" TO WS-NAME
     MOVE "axolotl/axolotl_gold_baby.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 4 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE SPACES TO WS-X60
     CALL "EF8-AXOLOTL-TEXTURE" USING WS-IN WS-X60
     MOVE "1.2 axolotl variant cyan baby 0" TO WS-NAME
     MOVE "axolotl/axolotl_cyan.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 4 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE SPACES TO WS-X60
     CALL "EF8-AXOLOTL-TEXTURE" USING WS-IN WS-X60
     MOVE "1.2 axolotl variant cyan baby 1" TO WS-NAME
     MOVE "axolotl/axolotl_cyan_baby.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 5 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE SPACES TO WS-X60
     CALL "EF8-AXOLOTL-TEXTURE" USING WS-IN WS-X60
     MOVE "1.2 axolotl variant blue baby 0" TO WS-NAME
     MOVE "axolotl/axolotl_blue.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 5 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE SPACES TO WS-X60
     CALL "EF8-AXOLOTL-TEXTURE" USING WS-IN WS-X60
     MOVE "1.2 axolotl variant blue baby 1" TO WS-NAME
     MOVE "axolotl/axolotl_blue_baby.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 9 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE SPACES TO WS-X60
     CALL "EF8-AXOLOTL-TEXTURE" USING WS-IN WS-X60
     MOVE "1.2 axolotl variant lucy baby 0" TO WS-NAME
     MOVE "axolotl/axolotl_lucy.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 9 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE SPACES TO WS-X60
     CALL "EF8-AXOLOTL-TEXTURE" USING WS-IN WS-X60
     MOVE "1.2 axolotl variant lucy baby 1" TO WS-NAME
     MOVE "axolotl/axolotl_lucy_baby.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "oak" TO WS-X24
     MOVE 0 TO WS-FL
     MOVE SPACES TO WS-X60
     CALL "EF8-BOAT-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "1.2 boat oak chest 0" TO WS-NAME
     MOVE "boat/oak.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "oak" TO WS-X24
     MOVE 1 TO WS-FL
     MOVE SPACES TO WS-X60
     CALL "EF8-BOAT-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "1.2 boat oak chest 1" TO WS-NAME
     MOVE "chest_boat/oak.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "spruce" TO WS-X24
     MOVE 0 TO WS-FL
     MOVE SPACES TO WS-X60
     CALL "EF8-BOAT-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "1.2 boat spruce chest 0" TO WS-NAME
     MOVE "boat/spruce.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "spruce" TO WS-X24
     MOVE 1 TO WS-FL
     MOVE SPACES TO WS-X60
     CALL "EF8-BOAT-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "1.2 boat spruce chest 1" TO WS-NAME
     MOVE "chest_boat/spruce.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "birch" TO WS-X24
     MOVE 0 TO WS-FL
     MOVE SPACES TO WS-X60
     CALL "EF8-BOAT-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "1.2 boat birch chest 0" TO WS-NAME
     MOVE "boat/birch.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "birch" TO WS-X24
     MOVE 1 TO WS-FL
     MOVE SPACES TO WS-X60
     CALL "EF8-BOAT-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "1.2 boat birch chest 1" TO WS-NAME
     MOVE "chest_boat/birch.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "jungle" TO WS-X24
     MOVE 0 TO WS-FL
     MOVE SPACES TO WS-X60
     CALL "EF8-BOAT-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "1.2 boat jungle chest 0" TO WS-NAME
     MOVE "boat/jungle.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "jungle" TO WS-X24
     MOVE 1 TO WS-FL
     MOVE SPACES TO WS-X60
     CALL "EF8-BOAT-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "1.2 boat jungle chest 1" TO WS-NAME
     MOVE "chest_boat/jungle.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "acacia" TO WS-X24
     MOVE 0 TO WS-FL
     MOVE SPACES TO WS-X60
     CALL "EF8-BOAT-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "1.2 boat acacia chest 0" TO WS-NAME
     MOVE "boat/acacia.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "acacia" TO WS-X24
     MOVE 1 TO WS-FL
     MOVE SPACES TO WS-X60
     CALL "EF8-BOAT-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "1.2 boat acacia chest 1" TO WS-NAME
     MOVE "chest_boat/acacia.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "cherry" TO WS-X24
     MOVE 0 TO WS-FL
     MOVE SPACES TO WS-X60
     CALL "EF8-BOAT-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "1.2 boat cherry chest 0" TO WS-NAME
     MOVE "boat/cherry.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "cherry" TO WS-X24
     MOVE 1 TO WS-FL
     MOVE SPACES TO WS-X60
     CALL "EF8-BOAT-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "1.2 boat cherry chest 1" TO WS-NAME
     MOVE "chest_boat/cherry.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "dark_oak" TO WS-X24
     MOVE 0 TO WS-FL
     MOVE SPACES TO WS-X60
     CALL "EF8-BOAT-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "1.2 boat dark_oak chest 0" TO WS-NAME
     MOVE "boat/dark_oak.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "dark_oak" TO WS-X24
     MOVE 1 TO WS-FL
     MOVE SPACES TO WS-X60
     CALL "EF8-BOAT-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "1.2 boat dark_oak chest 1" TO WS-NAME
     MOVE "chest_boat/dark_oak.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "pale_oak" TO WS-X24
     MOVE 0 TO WS-FL
     MOVE SPACES TO WS-X60
     CALL "EF8-BOAT-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "1.2 boat pale_oak chest 0" TO WS-NAME
     MOVE "boat/pale_oak.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "pale_oak" TO WS-X24
     MOVE 1 TO WS-FL
     MOVE SPACES TO WS-X60
     CALL "EF8-BOAT-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "1.2 boat pale_oak chest 1" TO WS-NAME
     MOVE "chest_boat/pale_oak.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "mangrove" TO WS-X24
     MOVE 0 TO WS-FL
     MOVE SPACES TO WS-X60
     CALL "EF8-BOAT-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "1.2 boat mangrove chest 0" TO WS-NAME
     MOVE "boat/mangrove.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "mangrove" TO WS-X24
     MOVE 1 TO WS-FL
     MOVE SPACES TO WS-X60
     CALL "EF8-BOAT-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "1.2 boat mangrove chest 1" TO WS-NAME
     MOVE "chest_boat/mangrove.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "poplar" TO WS-X24
     MOVE 0 TO WS-FL
     MOVE SPACES TO WS-X60
     CALL "EF8-BOAT-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "1.2 boat poplar chest 0" TO WS-NAME
     MOVE "boat/poplar.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "poplar" TO WS-X24
     MOVE 1 TO WS-FL
     MOVE SPACES TO WS-X60
     CALL "EF8-BOAT-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "1.2 boat poplar chest 1" TO WS-NAME
     MOVE "chest_boat/poplar.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "bamboo" TO WS-X24
     MOVE 0 TO WS-FL
     MOVE SPACES TO WS-X60
     CALL "EF8-BOAT-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "1.2 boat bamboo chest 0" TO WS-NAME
     MOVE "boat/bamboo.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "bamboo" TO WS-X24
     MOVE 1 TO WS-FL
     MOVE SPACES TO WS-X60
     CALL "EF8-BOAT-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "1.2 boat bamboo chest 1" TO WS-NAME
     MOVE "chest_boat/bamboo.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 0.7 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF8-BABY-SHADOW" USING WS-IN WS-OUT
     MOVE "1.3 shadow radius base 0.7 scale 1 ageScale 1 baby 0 (only the age scale differs)" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.7 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0.5 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF8-BABY-SHADOW" USING WS-IN WS-OUT
     MOVE "1.3 shadow radius base 0.7 scale 1 ageScale 0.5 baby 1 (only the age scale differs)" TO WS-NAME
     MOVE 0.35 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.7 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 0.5 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF8-BABY-SHADOW" USING WS-IN WS-OUT
     MOVE "1.3 shadow radius base 0.7 scale 2 ageScale 0.5 baby 1 (only the age scale differs)" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-8§1 Family overview: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-8§1 Family overview: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-8-1.
