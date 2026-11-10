*> Entity models part 8 section 1 (family overview): the entity type table (1.1), the texture file rules (1.2), hitbox, eye height, name tag height and the baby rule (1.3).
*> Entry points for the integrator (inputs; strings are X(24) lower case entity type, boats are "boat" and "raft", texture paths are relative to textures/entity/):
*>   EF8-ENTITY entity OUT(64 FLOAT-LONG: 1 found, 2 base shadow radius (-1 for the pufferfish, computed from its puff state), 3 model layers); EF8-ENTITY-LAYER entity index(BINARY-LONG) name(X(32), out; spaces past the end);
*>   EF8-HITBOX entity OUT(width, height, eye height, name tag height = the box height); EF8-TEXTURE entity kind(BINARY-LONG 1 adult or first, 2 baby or second) path(X(60), out); EF8-AXOLOTL-TEXTURE IN(variant 1 lucy 2 wild 3 gold 4 cyan 5 blue, baby) path(X(60), out);
*>   EF8-BOAT-TEXTURE wood(X(24)) chest(BINARY-LONG) path(X(60), out); EF8-BABY-SHADOW IN(base radius, scale, ageScale, baby) OUT(radius): the age scale reaches only the shadow.


 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-ENTITY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ENTITY               PIC X(24).
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-ENTITY L-OUT.
     MOVE 0 TO L-O(1) L-O(2) L-O(3)
     EVALUATE L-ENTITY
         WHEN "squid"
             MOVE 1 TO L-O(1)
             MOVE 0.7 TO L-O(2)
             MOVE 2 TO L-O(3)
         WHEN "glow_squid"
             MOVE 1 TO L-O(1)
             MOVE 0.7 TO L-O(2)
             MOVE 2 TO L-O(3)
         WHEN "dolphin"
             MOVE 1 TO L-O(1)
             MOVE 0.7 TO L-O(2)
             MOVE 3 TO L-O(3)
         WHEN "axolotl"
             MOVE 1 TO L-O(1)
             MOVE 0.5 TO L-O(2)
             MOVE 2 TO L-O(3)
         WHEN "cod"
             MOVE 1 TO L-O(1)
             MOVE 0.3 TO L-O(2)
             MOVE 1 TO L-O(3)
         WHEN "salmon"
             MOVE 1 TO L-O(1)
             MOVE 0.4 TO L-O(2)
             MOVE 3 TO L-O(3)
         WHEN "pufferfish"
             MOVE 1 TO L-O(1)
             MOVE -1 TO L-O(2)
             MOVE 3 TO L-O(3)
         WHEN "tropical_fish"
             MOVE 1 TO L-O(1)
             MOVE 0.15 TO L-O(2)
             MOVE 4 TO L-O(3)
         WHEN "nautilus"
             MOVE 1 TO L-O(1)
             MOVE 0.7 TO L-O(2)
             MOVE 4 TO L-O(3)
         WHEN "zombie_nautilus"
             MOVE 1 TO L-O(1)
             MOVE 0.7 TO L-O(2)
             MOVE 4 TO L-O(3)
         WHEN "boat"
             MOVE 1 TO L-O(1)
             MOVE 0.8 TO L-O(2)
             MOVE 3 TO L-O(3)
         WHEN "raft"
             MOVE 1 TO L-O(1)
             MOVE 0.8 TO L-O(2)
             MOVE 2 TO L-O(3)
     END-EVALUATE
     GOBACK.
 END PROGRAM EF8-ENTITY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-ENTITY-LAYER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ENTITY               PIC X(24).
 01 L-INDEX                BINARY-LONG.
 01 L-NAME                 PIC X(32).
 PROCEDURE DIVISION USING L-ENTITY L-INDEX L-NAME.
     MOVE SPACES TO L-NAME
     EVALUATE L-ENTITY
         WHEN "squid"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "squid" TO L-NAME
                 WHEN 2
                     MOVE "squid_baby" TO L-NAME
             END-EVALUATE
         WHEN "glow_squid"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "glow_squid" TO L-NAME
                 WHEN 2
                     MOVE "glow_squid_baby" TO L-NAME
             END-EVALUATE
         WHEN "dolphin"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "dolphin" TO L-NAME
                 WHEN 2
                     MOVE "dolphin_baby" TO L-NAME
                 WHEN 3
                     MOVE "DolphinCarryingItemLayer" TO L-NAME
             END-EVALUATE
         WHEN "axolotl"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "axolotl" TO L-NAME
                 WHEN 2
                     MOVE "axolotl_baby" TO L-NAME
             END-EVALUATE
         WHEN "cod"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "cod" TO L-NAME
             END-EVALUATE
         WHEN "salmon"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "salmon_small" TO L-NAME
                 WHEN 2
                     MOVE "salmon" TO L-NAME
                 WHEN 3
                     MOVE "salmon_large" TO L-NAME
             END-EVALUATE
         WHEN "pufferfish"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "pufferfish_small" TO L-NAME
                 WHEN 2
                     MOVE "pufferfish_medium" TO L-NAME
                 WHEN 3
                     MOVE "pufferfish_big" TO L-NAME
             END-EVALUATE
         WHEN "tropical_fish"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "tropical_fish_small" TO L-NAME
                 WHEN 2
                     MOVE "tropical_fish_large" TO L-NAME
                 WHEN 3
                     MOVE "tropical_fish_small_pattern" TO L-NAME
                 WHEN 4
                     MOVE "tropical_fish_large_pattern" TO L-NAME
             END-EVALUATE
         WHEN "nautilus"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "nautilus" TO L-NAME
                 WHEN 2
                     MOVE "nautilus_baby" TO L-NAME
                 WHEN 3
                     MOVE "nautilus_armor" TO L-NAME
                 WHEN 4
                     MOVE "nautilus_saddle" TO L-NAME
             END-EVALUATE
         WHEN "zombie_nautilus"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "zombie_nautilus" TO L-NAME
                 WHEN 2
                     MOVE "zombie_nautilus_coral" TO L-NAME
                 WHEN 3
                     MOVE "nautilus_armor" TO L-NAME
                 WHEN 4
                     MOVE "nautilus_saddle" TO L-NAME
             END-EVALUATE
         WHEN "boat"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "boat" TO L-NAME
                 WHEN 2
                     MOVE "chest_boat" TO L-NAME
                 WHEN 3
                     MOVE "boat#water_patch" TO L-NAME
             END-EVALUATE
         WHEN "raft"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "boat/bamboo" TO L-NAME
                 WHEN 2
                     MOVE "chest_boat/bamboo" TO L-NAME
             END-EVALUATE
     END-EVALUATE
     GOBACK.
 END PROGRAM EF8-ENTITY-LAYER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-HITBOX.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ENTITY               PIC X(24).
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-ENTITY L-OUT.
     MOVE 0 TO L-O(1) L-O(2) L-O(3) L-O(4)
     EVALUATE L-ENTITY
         WHEN "squid"
             MOVE 0.8 TO L-O(1)
             MOVE 0.8 TO L-O(2)
             MOVE 0.4 TO L-O(3)
             MOVE 0.8 TO L-O(4)
         WHEN "glow_squid"
             MOVE 0.8 TO L-O(1)
             MOVE 0.8 TO L-O(2)
             MOVE 0.4 TO L-O(3)
             MOVE 0.8 TO L-O(4)
         WHEN "dolphin"
             MOVE 0.9 TO L-O(1)
             MOVE 0.6 TO L-O(2)
             MOVE 0.3 TO L-O(3)
             MOVE 0.6 TO L-O(4)
         WHEN "axolotl"
             MOVE 0.75 TO L-O(1)
             MOVE 0.42 TO L-O(2)
             MOVE 0.2751 TO L-O(3)
             MOVE 0.42 TO L-O(4)
         WHEN "cod"
             MOVE 0.5 TO L-O(1)
             MOVE 0.3 TO L-O(2)
             MOVE 0.195 TO L-O(3)
             MOVE 0.3 TO L-O(4)
         WHEN "salmon"
             MOVE 0.7 TO L-O(1)
             MOVE 0.4 TO L-O(2)
             MOVE 0.26 TO L-O(3)
             MOVE 0.4 TO L-O(4)
         WHEN "pufferfish"
             MOVE 0.7 TO L-O(1)
             MOVE 0.7 TO L-O(2)
             MOVE 0.455 TO L-O(3)
             MOVE 0.7 TO L-O(4)
         WHEN "tropical_fish"
             MOVE 0.5 TO L-O(1)
             MOVE 0.4 TO L-O(2)
             MOVE 0.26 TO L-O(3)
             MOVE 0.4 TO L-O(4)
         WHEN "nautilus"
             MOVE 0.875 TO L-O(1)
             MOVE 0.95 TO L-O(2)
             MOVE 0.2751 TO L-O(3)
             MOVE 0.95 TO L-O(4)
         WHEN "zombie_nautilus"
             MOVE 0.875 TO L-O(1)
             MOVE 0.95 TO L-O(2)
             MOVE 0.2751 TO L-O(3)
             MOVE 0.95 TO L-O(4)
         WHEN "boat"
             MOVE 1.375 TO L-O(1)
             MOVE 0.5625 TO L-O(2)
             MOVE 0.5625 TO L-O(3)
             MOVE 0.5625 TO L-O(4)
         WHEN "raft"
             MOVE 1.375 TO L-O(1)
             MOVE 0.5625 TO L-O(2)
             MOVE 0.5625 TO L-O(3)
             MOVE 0.5625 TO L-O(4)
     END-EVALUATE
     GOBACK.
 END PROGRAM EF8-HITBOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ENTITY               PIC X(24).
 01 L-KIND                 BINARY-LONG.
 01 L-PATH                 PIC X(60).
 PROCEDURE DIVISION USING L-ENTITY L-KIND L-PATH.
     MOVE SPACES TO L-PATH
     EVALUATE L-ENTITY
         WHEN "squid"
             EVALUATE L-KIND
                 WHEN 1
                     MOVE "squid/squid.png" TO L-PATH
                 WHEN 2
                     MOVE "squid/squid_baby.png" TO L-PATH
             END-EVALUATE
         WHEN "glow_squid"
             EVALUATE L-KIND
                 WHEN 1
                     MOVE "squid/glow_squid.png" TO L-PATH
                 WHEN 2
                     MOVE "squid/glow_squid_baby.png" TO L-PATH
             END-EVALUATE
         WHEN "dolphin"
             EVALUATE L-KIND
                 WHEN 1
                     MOVE "dolphin/dolphin.png" TO L-PATH
                 WHEN 2
                     MOVE "dolphin/dolphin_baby.png" TO L-PATH
             END-EVALUATE
         WHEN "cod"
             EVALUATE L-KIND
                 WHEN 1
                     MOVE "fish/cod.png" TO L-PATH
             END-EVALUATE
         WHEN "salmon"
             EVALUATE L-KIND
                 WHEN 1
                     MOVE "fish/salmon.png" TO L-PATH
             END-EVALUATE
         WHEN "pufferfish"
             EVALUATE L-KIND
                 WHEN 1
                     MOVE "fish/pufferfish.png" TO L-PATH
             END-EVALUATE
         WHEN "tropical_fish"
             EVALUATE L-KIND
                 WHEN 1
                     MOVE "fish/tropical_a.png" TO L-PATH
                 WHEN 2
                     MOVE "fish/tropical_b.png" TO L-PATH
             END-EVALUATE
         WHEN "nautilus"
             EVALUATE L-KIND
                 WHEN 1
                     MOVE "nautilus/nautilus.png" TO L-PATH
                 WHEN 2
                     MOVE "nautilus/nautilus_baby.png" TO L-PATH
             END-EVALUATE
     END-EVALUATE
     GOBACK.
 END PROGRAM EF8-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-AXOLOTL-TEXTURE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-V                   PIC X(8).
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(60).
 PROCEDURE DIVISION USING L-IN L-PATH.
     MOVE SPACES TO L-PATH WS-V
     EVALUATE L-I(1)
         WHEN 1
             MOVE "lucy" TO WS-V
         WHEN 2
             MOVE "wild" TO WS-V
         WHEN 3
             MOVE "gold" TO WS-V
         WHEN 4
             MOVE "cyan" TO WS-V
         WHEN 5
             MOVE "blue" TO WS-V
         WHEN OTHER
             MOVE "lucy" TO WS-V
     END-EVALUATE
     IF L-I(2) NOT = 0
         STRING "axolotl/axolotl_" FUNCTION TRIM(WS-V) "_baby.png" DELIMITED BY SIZE INTO L-PATH
     ELSE
         STRING "axolotl/axolotl_" FUNCTION TRIM(WS-V) ".png" DELIMITED BY SIZE INTO L-PATH
     END-IF
     GOBACK.
 END PROGRAM EF8-AXOLOTL-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-BOAT-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WOOD                 PIC X(24).
 01 L-CHEST                BINARY-LONG.
 01 L-PATH                 PIC X(60).
 PROCEDURE DIVISION USING L-WOOD L-CHEST L-PATH.
     MOVE SPACES TO L-PATH
     IF L-CHEST NOT = 0
         STRING "chest_boat/" FUNCTION TRIM(L-WOOD) ".png" DELIMITED BY SIZE INTO L-PATH
     ELSE
         STRING "boat/" FUNCTION TRIM(L-WOOD) ".png" DELIMITED BY SIZE INTO L-PATH
     END-IF
     GOBACK.
 END PROGRAM EF8-BOAT-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-BABY-SHADOW.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = L-I(1) * L-I(2)
     IF L-I(4) NOT = 0
         COMPUTE L-O(1) = L-O(1) * L-I(3)
     END-IF
     GOBACK.
 END PROGRAM EF8-BABY-SHADOW.

