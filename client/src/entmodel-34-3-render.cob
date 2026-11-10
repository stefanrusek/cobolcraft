*> Entity models part 3 (docs/protocol/34-entity-models-3-villagers-illagers-golems-misc.md): renderer constants, textures and layer rules of the entities of this
*> document (shadow radii, texture paths, held-item transforms, overlay choices).
*> Entry points for the integrator (inputs; the table programs take IN of 16 and OUT of 64 FLOAT-LONG):
*>   EM3-VILLAGER-SHADOW IN(is baby, scale) OUT(radius): 1.4 (0.5 x scale x ageScale, times 0.5 more for a baby). EM3-VILLAGER-TEXTURE baby(BINARY-LONG) path(X(100), out).
*>   EM3-TRADER-TEXTURE path(out). EM3-HEAD-TRANSFORM name(X(24): villager, else the default set) OUT(y offset, skull y offset, horizontal scale, vertical scale).
*>   EM3-CROSSED-ARMS-OPS OUT(operation count, then 4 per operation as EM6-POSE-CHAIN: kind 1 translate, 2 scale, 5 rotate about X in degrees, then three values), applied
*>     after translateToArms (1.4).
*>   EM3-PROF-TEXTURE path-name(X(24)) folder(X(24): type, profession, profession_level) key(X(40), "ns:name", spaces when it cannot be resolved) level(BINARY-LONG)
*>     baby(BINARY-LONG) texture(X(100), out): 1.5. EM3-HAT-VALUE text(X(24)) value(BINARY-LONG, out 0 none, 1 partial, 2 full).
*>   EM3-ZV-SHAKING IN(fully frozen, converting, age in ticks, body rotation) OUT(shaking, body rotation with the jitter): 2.
*>   EM3-WITCH-RENDERER OUT(shadow radius, has a custom head layer); EM3-WITCH-TEXTURE path(out); EM3-WITCH-ITEM-OPS IN(held item is a potion) OUT(ops as EM3-CROSSED-ARMS-OPS; for a
*>     potion the five operations after the head and nose chain: translate, rotate Z 180, X 140, Z 10, X 180 degrees): 3.3.
*>   EM3-PROF-MODEL IN(type hat value, profession hat value) OUT(1 for the parent (full) model, 0 for the no-hat model): the model of the type overlay (1.5 step 3).
*>   EM3-PROF-OVERLAYS IN(invisible, has villager data, baby, profession is none, profession is nitwit) OUT(type overlay, profession overlay, level overlay): which of
*>     the three overlays are drawn (1.5 steps 1 to 5).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-VILLAGER-SHADOW.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = 0.5 * L-I(2)
     IF L-I(1) NOT = 0
         COMPUTE L-O(1) = L-O(1) * 0.5 * 0.5
     END-IF
     GOBACK.
 END PROGRAM EM3-VILLAGER-SHADOW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-VILLAGER-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BABY                 BINARY-LONG.
 01 L-PATH                 PIC X(100).
 PROCEDURE DIVISION USING L-BABY L-PATH.
     MOVE "textures/entity/villager/villager.png" TO L-PATH
     IF L-BABY NOT = 0
         MOVE "textures/entity/villager/villager_baby.png" TO L-PATH
     END-IF
     GOBACK.
 END PROGRAM EM3-VILLAGER-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-TRADER-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PATH                 PIC X(100).
 PROCEDURE DIVISION USING L-PATH.
     MOVE "textures/entity/wandering_trader/wandering_trader.png" TO L-PATH
     GOBACK.
 END PROGRAM EM3-TRADER-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-HEAD-TRANSFORM.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(24).
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-NAME L-OUT.
     MOVE 0 TO L-O(1) L-O(2)
     IF L-NAME = "villager"
         MOVE -0.1171875 TO L-O(1)
         MOVE -0.07421875 TO L-O(2)
     END-IF
     MOVE 1 TO L-O(3) L-O(4)
     GOBACK.
 END PROGRAM EM3-HEAD-TRANSFORM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-CROSSED-ARMS-OPS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-OUT.
     MOVE 4 TO L-O(1)
     MOVE 5 TO L-O(2)
     COMPUTE L-O(3) = 0.75 * 180 / 3.1415927
     MOVE 0 TO L-O(4) L-O(5)
     MOVE 2 TO L-O(6)
     MOVE 1.07 TO L-O(7) L-O(8) L-O(9)
     MOVE 1 TO L-O(10)
     MOVE 0 TO L-O(11)
     MOVE 0.13 TO L-O(12)
     MOVE -0.34 TO L-O(13)
     MOVE 5 TO L-O(14)
     MOVE 180 TO L-O(15)
     MOVE 0 TO L-O(16) L-O(17)
     GOBACK.
 END PROGRAM EM3-CROSSED-ARMS-OPS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-PROF-TEXTURE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NS                  PIC X(24).
 01 WS-NAME                PIC X(40).
 01 WS-FOLDER              PIC X(24).
 01 WS-LV                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-PATH                 PIC X(24).
 01 L-FOLDER               PIC X(24).
 01 L-KEY                  PIC X(40).
 01 L-LEVEL                BINARY-LONG.
 01 L-BABY                 BINARY-LONG.
 01 L-TEXTURE              PIC X(100).
 PROCEDURE DIVISION USING L-PATH L-FOLDER L-KEY L-LEVEL L-BABY L-TEXTURE.
     MOVE SPACES TO L-TEXTURE
     IF L-KEY = SPACES
         MOVE "minecraft:missingno" TO L-TEXTURE
         GOBACK
     END-IF
     MOVE SPACES TO WS-NS WS-NAME
     UNSTRING L-KEY DELIMITED BY ":" INTO WS-NS WS-NAME
     MOVE L-FOLDER TO WS-FOLDER
     IF L-FOLDER = "type" AND L-BABY NOT = 0
         MOVE "baby" TO WS-FOLDER
     END-IF
     IF L-FOLDER = "profession_level"
         COMPUTE WS-LV = L-LEVEL
         IF WS-LV < 1
             MOVE 1 TO WS-LV
         END-IF
         IF WS-LV > 5
             MOVE 5 TO WS-LV
         END-IF
         EVALUATE WS-LV
             WHEN 1 MOVE "stone" TO WS-NAME
             WHEN 2 MOVE "iron" TO WS-NAME
             WHEN 3 MOVE "gold" TO WS-NAME
             WHEN 4 MOVE "emerald" TO WS-NAME
             WHEN OTHER MOVE "diamond" TO WS-NAME
         END-EVALUATE
     END-IF
     STRING FUNCTION TRIM(WS-NS) ":textures/entity/" FUNCTION TRIM(L-PATH) "/" FUNCTION TRIM(WS-FOLDER) "/" FUNCTION TRIM(WS-NAME) ".png"
         DELIMITED BY SIZE INTO L-TEXTURE
     GOBACK.
 END PROGRAM EM3-PROF-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-HAT-VALUE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(24).
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-VALUE.
     MOVE 0 TO L-VALUE
     EVALUATE L-TEXT
         WHEN "partial" MOVE 1 TO L-VALUE
         WHEN "full" MOVE 2 TO L-VALUE
     END-EVALUATE
     GOBACK.
 END PROGRAM EM3-HAT-VALUE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-PROF-MODEL.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     IF L-I(2) = 0 OR (L-I(2) = 1 AND L-I(1) NOT = 2)
         MOVE 1 TO L-O(1)
     END-IF
     GOBACK.
 END PROGRAM EM3-PROF-MODEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-PROF-OVERLAYS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1) L-O(2) L-O(3)
     IF L-I(1) = 0 AND L-I(2) NOT = 0
         MOVE 1 TO L-O(1)
         IF L-I(4) = 0 AND L-I(3) = 0
             MOVE 1 TO L-O(2)
             IF L-I(5) = 0
                 MOVE 1 TO L-O(3)
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM EM3-PROF-OVERLAYS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-ZV-SHAKING.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
*> IN(fully frozen, converting, age in ticks, body rotation degrees) OUT(shaking, body rotation after the jitter): 2 (the entity shakes when frozen or converting; the jitter is
*> cos(floor(ageInTicks) * 3.25) * pi * 0.4 added to the body rotation).
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     MOVE L-I(4) TO L-O(2)
     IF L-I(1) NOT = 0 OR L-I(2) NOT = 0
         MOVE 1 TO L-O(1)
         COMPUTE L-O(2) = L-I(4) + FUNCTION COS(FUNCTION INTEGER-PART(L-I(3)) * 3.25) * 3.1415927 * 0.4
     END-IF
     GOBACK.
 END PROGRAM EM3-ZV-SHAKING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-WITCH-RENDERER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-OUT.
     MOVE 0.5 TO L-O(1)
     MOVE 0 TO L-O(2)
     GOBACK.
 END PROGRAM EM3-WITCH-RENDERER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-WITCH-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PATH                 PIC X(100).
 PROCEDURE DIVISION USING L-PATH.
     MOVE "textures/entity/witch/witch.png" TO L-PATH
     GOBACK.
 END PROGRAM EM3-WITCH-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-WITCH-ITEM-OPS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     IF L-I(1) = 0
         CALL "EM3-CROSSED-ARMS-OPS" USING L-OUT
     ELSE
         MOVE 5 TO L-O(1)
         MOVE 1 TO L-O(2)
         MOVE 0.0625 TO L-O(3)
         MOVE 0.25 TO L-O(4)
         MOVE 0 TO L-O(5)
         MOVE 4 TO L-O(6)
         MOVE 180 TO L-O(7)
         MOVE 0 TO L-O(8) L-O(9)
         MOVE 5 TO L-O(10)
         MOVE 140 TO L-O(11)
         MOVE 0 TO L-O(12) L-O(13)
         MOVE 4 TO L-O(14)
         MOVE 10 TO L-O(15)
         MOVE 0 TO L-O(16) L-O(17)
         MOVE 5 TO L-O(18)
         MOVE 180 TO L-O(19)
         MOVE 0 TO L-O(20) L-O(21)
     END-IF
     GOBACK.
 END PROGRAM EM3-WITCH-ITEM-OPS.
