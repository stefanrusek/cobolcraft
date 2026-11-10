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

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-ILLAGER-POSE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
*> IN(kind 1 pillager 2 vindicator 3 evoker 4 illusioner 5 other, charging its crossbow, holding a crossbow, aggressive, celebrating, casting) OUT(arm pose ordinal CROSSED 0,
*> ATTACKING 1, SPELLCASTING 2, BOW_AND_ARROW 3, CROSSBOW_HOLD 4, CROSSBOW_CHARGE 5, CELEBRATING 6, NEUTRAL 7): 4.3, first match wins.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     EVALUATE L-I(1)
         WHEN 1
             EVALUATE TRUE
                 WHEN L-I(2) NOT = 0 MOVE 5 TO L-O(1)
                 WHEN L-I(3) NOT = 0 MOVE 4 TO L-O(1)
                 WHEN L-I(4) NOT = 0 MOVE 1 TO L-O(1)
                 WHEN OTHER MOVE 7 TO L-O(1)
             END-EVALUATE
         WHEN 2
             EVALUATE TRUE
                 WHEN L-I(4) NOT = 0 MOVE 1 TO L-O(1)
                 WHEN L-I(5) NOT = 0 MOVE 6 TO L-O(1)
             END-EVALUATE
         WHEN 3
             EVALUATE TRUE
                 WHEN L-I(6) NOT = 0 MOVE 2 TO L-O(1)
                 WHEN L-I(5) NOT = 0 MOVE 6 TO L-O(1)
             END-EVALUATE
         WHEN 4
             EVALUATE TRUE
                 WHEN L-I(6) NOT = 0 MOVE 2 TO L-O(1)
                 WHEN L-I(4) NOT = 0 MOVE 3 TO L-O(1)
             END-EVALUATE
     END-EVALUATE
     GOBACK.
 END PROGRAM EM3-ILLAGER-POSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-ILLAGER-RENDERER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 PIC X(24).
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 01 L-TEXTURE              PIC X(100).
*> USING type(X(24)) OUT(found, shadow radius) texture: the four illager renderers (4.5), base shadow 0.5.
 PROCEDURE DIVISION USING L-TYPE L-OUT L-TEXTURE.
     MOVE 1 TO L-O(1)
     MOVE 0.5 TO L-O(2)
     MOVE SPACES TO L-TEXTURE
     EVALUATE L-TYPE
         WHEN "pillager" MOVE "textures/entity/illager/pillager.png" TO L-TEXTURE
         WHEN "vindicator" MOVE "textures/entity/illager/vindicator.png" TO L-TEXTURE
         WHEN "evoker" MOVE "textures/entity/illager/evoker.png" TO L-TEXTURE
         WHEN "illusioner" MOVE "textures/entity/illager/illusioner.png" TO L-TEXTURE
         WHEN OTHER MOVE 0 TO L-O(1) L-O(2)
     END-EVALUATE
     GOBACK.
 END PROGRAM EM3-ILLAGER-RENDERER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-ILLAGER-ITEM.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
*> IN(kind 1 pillager 2 vindicator 3 evoker 4 illusioner, aggressive, casting a spell) OUT(the ItemInHandLayer draws): 4.5.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     EVALUATE L-I(1)
         WHEN 1
             MOVE 1 TO L-O(1)
         WHEN 2
             MOVE L-I(2) TO L-O(1)
         WHEN 3
             MOVE L-I(3) TO L-O(1)
         WHEN 4
             IF L-I(2) NOT = 0 OR L-I(3) NOT = 0
                 MOVE 1 TO L-O(1)
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM EM3-ILLAGER-ITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-ILLUSION-OFFSET.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
*> IN(offset x y z, index i, age in ticks) OUT(translation x y z of the copy i, drawn when the illusioner is invisible): 4.6.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = L-I(1) + FUNCTION COS(L-I(4) + L-I(5) * 0.5) * 0.025
     COMPUTE L-O(2) = L-I(2) + FUNCTION COS(L-I(4) + L-I(5) * 0.75) * 0.0125
     COMPUTE L-O(3) = L-I(3) + FUNCTION COS(L-I(4) + L-I(5) * 0.7) * 0.025
     GOBACK.
 END PROGRAM EM3-ILLUSION-OFFSET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-ILLUSIONER-CULL.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
*> IN(box min xyz, max xyz) OUT(the same box inflated by (3, 0, 3)): the illusioner's culling box (4.6).
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = L-I(1) - 3
     MOVE L-I(2) TO L-O(2)
     COMPUTE L-O(3) = L-I(3) - 3
     COMPUTE L-O(4) = L-I(4) + 3
     MOVE L-I(5) TO L-O(5)
     COMPUTE L-O(6) = L-I(6) + 3
     GOBACK.
 END PROGRAM EM3-ILLUSIONER-CULL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-SPELL-COLOUR.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
*> IN(spell id 0 NONE, 1 SUMMON_VEX, 2 FANGS, 3 WOLOLO, 4 DISAPPEAR, 5 BLINDNESS) OUT(r g b): the spell colours of 4.7.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1) L-O(2) L-O(3)
     EVALUATE L-I(1)
         WHEN 1
             MOVE 0.7 TO L-O(1) L-O(2)
             MOVE 0.8 TO L-O(3)
         WHEN 2
             MOVE 0.4 TO L-O(1)
             MOVE 0.3 TO L-O(2)
             MOVE 0.35 TO L-O(3)
         WHEN 3
             MOVE 0.7 TO L-O(1)
             MOVE 0.5 TO L-O(2)
             MOVE 0.2 TO L-O(3)
         WHEN 4
             MOVE 0.3 TO L-O(1) L-O(2)
             MOVE 0.8 TO L-O(3)
         WHEN 5
             MOVE 0.1 TO L-O(1) L-O(2)
             MOVE 0.2 TO L-O(3)
     END-EVALUATE
     GOBACK.
 END PROGRAM EM3-SPELL-COLOUR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-SPELL-PARTICLES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PHI                 FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-C-IN.
    05 WS-CI               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-C-OUT.
    05 WS-CO               FLOAT-LONG OCCURS 64 TIMES.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
*> IN(yBodyRot degrees, tickCount, scale, spell id, x, y, z) OUT(first particle xyz, second particle xyz, colour r g b): the two entity_effect particles of 4.7.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE WS-PHI = L-I(1) * 0.017453292 + FUNCTION COS(L-I(2) * 0.6662) * 0.25
     COMPUTE WS-DX = FUNCTION COS(WS-PHI) * 0.6 * L-I(3)
     COMPUTE WS-DZ = FUNCTION SIN(WS-PHI) * 0.6 * L-I(3)
     COMPUTE WS-DY = 1.8 * L-I(3)
     COMPUTE L-O(1) = L-I(5) + WS-DX
     COMPUTE L-O(2) = L-I(6) + WS-DY
     COMPUTE L-O(3) = L-I(7) + WS-DZ
     COMPUTE L-O(4) = L-I(5) - WS-DX
     COMPUTE L-O(5) = L-I(6) + WS-DY
     COMPUTE L-O(6) = L-I(7) - WS-DZ
     MOVE L-I(4) TO WS-CI(1)
     CALL "EM3-SPELL-COLOUR" USING WS-C-IN WS-C-OUT
     MOVE WS-CO(1) TO L-O(7)
     MOVE WS-CO(2) TO L-O(8)
     MOVE WS-CO(3) TO L-O(9)
     GOBACK.
 END PROGRAM EM3-SPELL-PARTICLES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-FANGS-OPS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
*> IN(yRot degrees, bite progress) OUT(draw, operation count, then 4 per operation as EM6-POSE-CHAIN): EvokerFangsRenderer (4.8): not drawn at progress 0; else rotate Y by
*> 90 - yRot, scale (-1, -1, 1), translate (0, -1.501, 0).
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     IF L-I(2) NOT = 0
         MOVE 1 TO L-O(1)
         MOVE 3 TO L-O(2)
         MOVE 3 TO L-O(3)
         COMPUTE L-O(4) = 90 - L-I(1)
         MOVE 0 TO L-O(5) L-O(6)
         MOVE 2 TO L-O(7)
         MOVE -1 TO L-O(8) L-O(9)
         MOVE 1 TO L-O(10)
         MOVE 1 TO L-O(11)
         MOVE 0 TO L-O(12)
         MOVE -1.501 TO L-O(13)
         MOVE 0 TO L-O(14)
     END-IF
     GOBACK.
 END PROGRAM EM3-FANGS-OPS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-FANGS-PROGRESS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
*> IN(attack started, lifeTicks, partial tick) OUT(EvokerFangs.getAnimationProgress): 0 until entity event 4; with t = lifeTicks - 2: 1 when t <= 0, else 1 - (t - partial) / 20 (4.8).
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     IF L-I(1) NOT = 0
         COMPUTE WS-T = L-I(2) - 2
         IF WS-T <= 0
             MOVE 1 TO L-O(1)
         ELSE
             COMPUTE L-O(1) = 1 - (WS-T - L-I(3)) / 20
         END-IF
     END-IF
     GOBACK.
 END PROGRAM EM3-FANGS-PROGRESS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-FANGS-TICK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
*> IN(attack started, lifeTicks) OUT(lifeTicks after the client tick, 1 when the burst of 12 crit particles is spawned this tick (lifeTicks equals 14 after the decrement)): 4.8.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-I(2) TO L-O(1)
     MOVE 0 TO L-O(2)
     IF L-I(1) NOT = 0
         COMPUTE L-O(1) = L-I(2) - 1
         IF L-O(1) = 14
             MOVE 1 TO L-O(2)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM EM3-FANGS-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-FANGS-CRIT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
*> IN(r1..r6 in [0, 1), X, Y, Z, width) OUT(x y z vx vy vz): one crit particle of the fangs burst, the draws in the order of 4.8.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = L-I(7) + (2 * L-I(1) - 1) * L-I(10) * 0.5
     COMPUTE L-O(2) = L-I(8) + 0.05 + L-I(2) + 1
     COMPUTE L-O(3) = L-I(9) + (2 * L-I(3) - 1) * L-I(10) * 0.5
     COMPUTE L-O(4) = (2 * L-I(4) - 1) * 0.3
     COMPUTE L-O(5) = 0.3 + L-I(5) * 0.3
     COMPUTE L-O(6) = (2 * L-I(6) - 1) * 0.3
     GOBACK.
 END PROGRAM EM3-FANGS-CRIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-FANGS-SOUND-PITCH.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
*> IN(r random float in [0, 1)) OUT(pitch of the attack sound, 0.85 + 0.2 r): 4.8.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = 0.85 + 0.2 * L-I(1)
     GOBACK.
 END PROGRAM EM3-FANGS-SOUND-PITCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-FANGS-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PATH                 PIC X(100).
 PROCEDURE DIVISION USING L-PATH.
     MOVE "textures/entity/illager/evoker_fangs.png" TO L-PATH
     GOBACK.
 END PROGRAM EM3-FANGS-TEXTURE.
