*> Variant data of the mobs in the render path (docs/protocol 54 section 5 registry id order, 19 section 1.3 and 21 appendix metadata layouts, 34-4 to 34-8 texture rules):
*> ENTITY-VARIANT-SET keeps the Set Entity Data entry that holds a mob's variant in the replica row (EN-VAR, EN-VAR2, EN-VAR3), ENTITY-TEX-CODE turns the row's
*> variant into the texture code of its atlas slot (0 = the image of the model row), ENTITY-TEX-PATH gives the texture path of a model row and code (spaces when the
*> variant has none: the row's own image is used). A variant image that the pack stack lacks falls back to the row's image (ENTITY-ATLAS-BUILD).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-VARIANT-SET.
*> USING CLIENT-STATE, replica row, entry index, serializer, value, second and third value (VILLAGER_DATA), long value (the wolf's anger end time).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLMODELS.
 01 WS-WANT                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-SERIALIZER           BINARY-LONG.
 01 L-INT                  BINARY-LONG.
 01 L-INT2                 BINARY-LONG.
 01 L-INT3                 BINARY-LONG.
 01 L-LONG                 BINARY-DOUBLE.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-INDEX L-SERIALIZER L-INT L-INT2 L-INT3 L-LONG.
     MOVE -1 TO WS-WANT
     EVALUATE EN-KEY(L-ROW)
         WHEN "pig"
         WHEN "horse"
         WHEN "villager"
             MOVE 19 TO WS-WANT
         WHEN "cow"
         WHEN "chicken"
         WHEN "mooshroom"
         WHEN "rabbit"
         WHEN "fox"
         WHEN "frog"
         WHEN "axolotl"
         WHEN "sheep"
         WHEN "slime"
         WHEN "magma_cube"
             MOVE 18 TO WS-WANT
         WHEN "zombie_nautilus"
             MOVE 21 TO WS-WANT
         WHEN "wolf"
             MOVE 23 TO WS-WANT
         WHEN "cat"
         WHEN "parrot"
         WHEN "zombie_villager"
             MOVE 20 TO WS-WANT
         WHEN "llama"
         WHEN "trader_llama"
         WHEN "panda"
             MOVE 21 TO WS-WANT
         WHEN "tropical_fish"
         WHEN "salmon"
         WHEN "pufferfish"
             MOVE 17 TO WS-WANT
         WHEN OTHER
             MOVE -1 TO WS-WANT
     END-EVALUATE
     IF L-INDEX = WS-WANT AND L-SERIALIZER NOT = 3
         MOVE L-INT TO EN-VAR(L-ROW)
         MOVE L-INT2 TO EN-VAR2(L-ROW)
         MOVE L-INT3 TO EN-VAR3(L-ROW)
     END-IF
*>   The tamable flags (wolf and cat entry 18, bit 4 tame), the collar colour (wolf 21, cat 23), the wolf's anger end time (22, a LONG) and the fox's flags (19,
*>   bit 32 sleeping), the panda's hidden gene (22): the metadata of the overlay layers and of the wolf and fox textures (34-5 2.5, 3, 4; 19 section 1.3).
     EVALUATE TRUE
         WHEN (EN-KEY(L-ROW) = "wolf" OR "cat") AND L-INDEX = 18 AND L-SERIALIZER = 0
             MOVE L-INT TO EN-X1(L-ROW)
         WHEN EN-KEY(L-ROW) = "wolf" AND L-INDEX = 21 AND L-SERIALIZER = 1
             MOVE L-INT TO EN-X2(L-ROW)
         WHEN EN-KEY(L-ROW) = "cat" AND L-INDEX = 23 AND L-SERIALIZER = 1
             MOVE L-INT TO EN-X2(L-ROW)
         WHEN EN-KEY(L-ROW) = "wolf" AND L-INDEX = 22 AND L-SERIALIZER = 2
             MOVE L-LONG TO EN-X3(L-ROW)
         WHEN EN-KEY(L-ROW) = "fox" AND L-INDEX = 19 AND L-SERIALIZER = 0
             MOVE L-INT TO EN-X1(L-ROW)
*>   A boat's paddle states (21 appendix: entries 11 left and 12 right, BOOLEAN): the paddle is held (EN-X1 left, EN-X2 right).
         WHEN L-INDEX = 11 AND L-SERIALIZER = 8 AND EN-MODEL(L-ROW) > 0 AND CL-MD-ANIM(EN-MODEL(L-ROW)) = "B"
             MOVE L-INT TO EN-X1(L-ROW)
         WHEN L-INDEX = 12 AND L-SERIALIZER = 8 AND EN-MODEL(L-ROW) > 0 AND CL-MD-ANIM(EN-MODEL(L-ROW)) = "B"
             MOVE L-INT TO EN-X2(L-ROW)
         WHEN EN-KEY(L-ROW) = "panda" AND L-INDEX = 22 AND L-SERIALIZER = 0
             MOVE L-INT TO EN-X1(L-ROW)
*>   An enderman's carried block (entry 16, OPTIONAL_BLOCK_STATE: the raw VarInt, 0 none) and creepy flag (entry 17, BOOLEAN).
         WHEN EN-KEY(L-ROW) = "enderman" AND L-INDEX = 16 AND L-SERIALIZER = 15
             MOVE L-INT TO EN-CARRY(L-ROW)
         WHEN EN-KEY(L-ROW) = "enderman" AND L-INDEX = 17 AND L-SERIALIZER = 8
             MOVE L-INT TO EN-CREEPY(L-ROW)
*>   A guardian's moving flag (entry 16, BOOLEAN) in EN-X1 and its active attack target (entry 17, VarInt): a new target restarts the attack time (EN-RS).
         WHEN (EN-KEY(L-ROW) = "guardian" OR "elder_guardian") AND L-INDEX = 16 AND L-SERIALIZER = 8
             MOVE L-INT TO EN-X1(L-ROW)
         WHEN (EN-KEY(L-ROW) = "guardian" OR "elder_guardian") AND L-INDEX = 17 AND L-SERIALIZER = 1
             IF L-INT NOT = EN-TGT(L-ROW)
                 MOVE 0 TO EN-RS(L-ROW)
             END-IF
             MOVE L-INT TO EN-TGT(L-ROW)
         WHEN OTHER
             CONTINUE
     END-EVALUATE
     GOBACK.
 END PROGRAM ENTITY-VARIANT-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-TEX-CODE.
*> USING CLIENT-STATE, replica row, model row drawn (CL-MODELS: the baby row or an extra layer's row), code out (BINARY-LONG): 0 when the row's own image is drawn (no variant known, or a type whose variant is not a texture), else the
*> variant id plus 1 (the horse: the colour plus 1; the panda: the gene plus 1; the rabbit: killer bunny 99 is 8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLMODELS.
 01 WS-BASE                PIC X(20).
 01 WS-TAIL                PIC X(2).
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-MODEL                BINARY-LONG.
 01 L-CODE                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-MODEL L-CODE.
     MOVE 0 TO L-CODE
*>   An overlay layer being drawn (ENTITY-OVERLAY) has the code of the layer.
     IF EN-OVL(L-ROW) > 0
         MOVE EN-OVL(L-ROW) TO L-CODE
         GOBACK
     END-IF
     MOVE SPACES TO WS-BASE WS-TAIL
     UNSTRING CL-MD-KEY(L-MODEL) DELIMITED BY "~" INTO WS-BASE WS-TAIL
*>   An extra layer (the sheep's wool, the slime's outer layer) keeps its own image.
*>   The pattern layer of a tropical fish: the pattern index of the packed variant plus 1.
     IF EN-VAR(L-ROW) >= 0 AND WS-BASE = "tropical_pattern"
         COMPUTE L-CODE = FUNCTION MOD(FUNCTION INTEGER(EN-VAR(L-ROW) / 256), 256) + 1
     END-IF
     IF EN-VAR(L-ROW) >= 0 AND WS-BASE = EN-KEY(L-ROW)
         EVALUATE EN-KEY(L-ROW)
             WHEN "pig" WHEN "cow" WHEN "chicken" WHEN "mooshroom" WHEN "rabbit" WHEN "fox" WHEN "frog" WHEN "axolotl"
             WHEN "wolf" WHEN "cat" WHEN "llama" WHEN "trader_llama" WHEN "panda" WHEN "parrot"
                 COMPUTE L-CODE = EN-VAR(L-ROW) + 1
                 IF EN-VAR(L-ROW) = 99
                     MOVE 8 TO L-CODE
                 END-IF
*>               A wolf's texture by state (34-5 2.5: tame wins over angry): +100 tame, +200 angry (anger end time above the clock); a sleeping fox (flags bit 32): +100.
                 IF EN-KEY(L-ROW) = "wolf"
                     EVALUATE TRUE
                         WHEN FUNCTION MOD(FUNCTION INTEGER(EN-X1(L-ROW) / 4), 2) = 1
                             ADD 100 TO L-CODE
                         WHEN EN-X3(L-ROW) > PL-GAME-TIME
                             ADD 200 TO L-CODE
                         WHEN OTHER
                             CONTINUE
                     END-EVALUATE
                 END-IF
*>               A panda shows a recessive main gene (brown 4, weak 5) only when its hidden gene (EN-X1) is the same, else it is a normal panda (19 section 8).
                 IF EN-KEY(L-ROW) = "panda" AND (EN-VAR(L-ROW) = 4 OR 5) AND EN-X1(L-ROW) NOT = EN-VAR(L-ROW)
                     MOVE 1 TO L-CODE
                 END-IF
                 IF EN-KEY(L-ROW) = "fox" AND FUNCTION MOD(FUNCTION INTEGER(EN-X1(L-ROW) / 32), 2) = 1
                     ADD 100 TO L-CODE
                 END-IF
             WHEN "horse"
                 COMPUTE L-CODE = FUNCTION MOD(EN-VAR(L-ROW), 256) + 1
             WHEN OTHER
                 CONTINUE
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM ENTITY-TEX-CODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-TEX-PATH.
*> USING row key (X(20), the key of the model row: a baby row ends in ~b), code (ENTITY-TEX-CODE), path out (X(64), relative to assets/minecraft/, spaces for none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BASE                PIC X(20).
 01 WS-TAIL                PIC X(2).
 01 WS-NAME                PIC X(20).
 01 WS-DIR                 PIC X(10).
 01 WS-PTR                 BINARY-LONG.
 01 WS-BABY                PIC X(5).
 01 WS-DIGIT               PIC 9.
 01 WS-I                   BINARY-LONG.
 01 WS-NAMES-DATA.
    05 FILLER PIC X(54) VALUE "cold              temperate         warm              ".
    05 FILLER PIC X(162) VALUE "ashen             black             chestnut          pale              rusty             snowy             spotted           striped           woods             ".
    05 FILLER PIC X(198) VALUE "all_black         black             british_shorthair calico            jellie            persian           ragdoll           red               siamese           tabby             white             ".
    05 FILLER PIC X(126) VALUE "white             creamy            chestnut          brown             black             gray              darkbrown         ".
    05 FILLER PIC X(72) VALUE "creamy            white             brown             gray              ".
    05 FILLER PIC X(126) VALUE "brown             white             black             white_splotched   gold              salt              caerbannog        ".
    05 FILLER PIC X(90) VALUE "lucy              wild              gold              cyan              blue              ".
    05 FILLER PIC X(90) VALUE "red_blue          blue              green             yellow_blue       grey              ".
 01 WS-NAMES REDEFINES WS-NAMES-DATA.
    05 WS-NM                PIC X(18) OCCURS 51 TIMES.
*> The overlay layers (ENTITY-OVERLAY): villager types 1 to 7, professions 8 to 21, levels 22 to 26, markings 27 to 30, armor assets 31 to 39 (the last of them the wolf's armadillo scute), llama carpets 40 to 55 by dye, the trader llama's 56 and 57 (baby).
 01 WS-OVL-DATA.
    05 FILLER PIC X(126) VALUE "desert            jungle            plains            savanna           snow              swamp             taiga             ".
    05 FILLER PIC X(252) VALUE "armorer           butcher           cartographer      cleric            farmer            fisherman         fletcher          leatherworker     librarian         mason             nitwit            shepherd          toolsmith         weaponsmith       ".
    05 FILLER PIC X(90) VALUE "stone             iron              gold              emerald           diamond           ".
    05 FILLER PIC X(72) VALUE "white             whitefield        whitedots         blackdots         ".
    05 FILLER PIC X(162) VALUE "leather           copper            chainmail         iron              gold              diamond           turtle_scute      netherite         armadillo_scute   ".
    05 FILLER PIC X(288) VALUE "white             orange            magenta           light_blue        yellow            lime              pink              gray              light_gray        cyan              purple            blue              brown             green             red               black             ".
    05 FILLER PIC X(36) VALUE "trader_llama      trader_llama_baby ".
 01 WS-OVL REDEFINES WS-OVL-DATA.
    05 WS-OV                PIC X(18) OCCURS 57 TIMES.
 01 WS-CD                  BINARY-LONG.
 01 WS-DIRNAME             PIC X(24).
 01 WS-STATE               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-TRIM                PIC X(10).
 LINKAGE SECTION.
 01 L-KEY                  PIC X(20).
 01 L-CODE                 BINARY-LONG.
 01 L-PATH                 PIC X(64).
 PROCEDURE DIVISION USING L-KEY L-CODE L-PATH.
     MOVE SPACES TO L-PATH WS-BASE WS-TAIL WS-NAME WS-BABY
     MOVE 1 TO WS-PTR
     UNSTRING L-KEY DELIMITED BY "~" INTO WS-BASE WS-TAIL
     IF WS-TAIL = "b"
         MOVE "_baby" TO WS-BABY
     END-IF
*>   The no-hat rows stand in for the type layer of the villagers: their textures are those of the villager and the zombie villager.
     IF WS-BASE = "villager_nohat"
         MOVE "villager" TO WS-BASE
     END-IF
     IF WS-BASE = "zvillager_nohat"
         MOVE "zombie_villager" TO WS-BASE
     END-IF
*>   The zombie villager's armor rows take the textures of the humanoid armor rows.
     EVALUATE WS-BASE
         WHEN "zvil_armor_head" MOVE "armor_head" TO WS-BASE
         WHEN "zvil_armor_chest" MOVE "armor_chest" TO WS-BASE
         WHEN "zvil_armor_legs" MOVE "armor_legs" TO WS-BASE
         WHEN "zvil_armor_feet" MOVE "armor_feet" TO WS-BASE
         WHEN "piglin_armor_head" MOVE "armor_head" TO WS-BASE
         WHEN "piglin_armor_chest" MOVE "armor_chest" TO WS-BASE
         WHEN "piglin_armor_legs" MOVE "armor_legs" TO WS-BASE
         WHEN "piglin_armor_feet" MOVE "armor_feet" TO WS-BASE
     END-EVALUATE
     COMPUTE WS-KIND = FUNCTION INTEGER(L-CODE / 1000)
     COMPUTE WS-CD = FUNCTION MOD(L-CODE, 100)
     COMPUTE WS-STATE = FUNCTION MOD(FUNCTION INTEGER(L-CODE / 100), 10)
     IF WS-KIND > 0
*>       The overlay layers of ENTITY-OVERLAY (kind 1 villager type, 2 profession, 3 level, 4 horse markings, 5 collar; WS-CD is the value).
         COMPUTE WS-CD = FUNCTION MOD(L-CODE, 1000)
         EVALUATE TRUE
*>           An armor trim (code 100000 + palette * 100 + pattern, ENTITY-OVERLAY): the pattern texture of the piece's layer type (54 section 18.4 rule 3).
             WHEN L-CODE >= 100000 AND FUNCTION MOD(L-CODE, 100) >= 1 AND FUNCTION MOD(L-CODE, 100) <= 18
                     AND (WS-BASE = "armor_head" OR "armor_chest" OR "armor_legs" OR "armor_feet")
                 MOVE "humanoid" TO WS-NAME
                 IF WS-BASE = "armor_legs"
                     MOVE "humanoid_leggings" TO WS-NAME
                 END-IF
                 COMPUTE WS-I = FUNCTION MOD(L-CODE, 100)
                 CALL "TRIM-PATTERN-NAME" USING WS-I WS-TRIM
                 STRING "textures/trims/entity/" FUNCTION TRIM(WS-NAME) "/" FUNCTION TRIM(WS-TRIM) ".png"
                     DELIMITED BY SIZE INTO L-PATH
             WHEN WS-KIND = 1 AND WS-CD >= 1 AND WS-CD <= 7 AND (WS-BASE = "villager" OR "zombie_villager")
                 MOVE "type" TO WS-NAME
                 IF WS-BABY NOT = SPACES
                     MOVE "baby" TO WS-NAME
                 END-IF
                 STRING "textures/entity/" FUNCTION TRIM(WS-BASE) "/" FUNCTION TRIM(WS-NAME) "/" FUNCTION TRIM(WS-OV(WS-CD)) ".png"
                     DELIMITED BY SIZE INTO L-PATH
             WHEN WS-KIND = 2 AND WS-CD >= 1 AND WS-CD <= 14 AND (WS-BASE = "villager" OR "zombie_villager")
                 COMPUTE WS-I = 7 + WS-CD
                 STRING "textures/entity/" FUNCTION TRIM(WS-BASE) "/profession/" FUNCTION TRIM(WS-OV(WS-I)) ".png"
                     DELIMITED BY SIZE INTO L-PATH
             WHEN WS-KIND = 3 AND WS-CD >= 1 AND WS-CD <= 5 AND (WS-BASE = "villager" OR "zombie_villager")
                 COMPUTE WS-I = 21 + WS-CD
                 STRING "textures/entity/" FUNCTION TRIM(WS-BASE) "/profession_level/" FUNCTION TRIM(WS-OV(WS-I)) ".png"
                     DELIMITED BY SIZE INTO L-PATH
             WHEN WS-KIND = 4 AND WS-CD >= 1 AND WS-CD <= 4 AND WS-BASE = "horse"
                 COMPUTE WS-I = 26 + WS-CD
                 STRING "textures/entity/horse/horse_markings_" FUNCTION TRIM(WS-OV(WS-I)) FUNCTION TRIM(WS-BABY) ".png"
                     DELIMITED BY SIZE INTO L-PATH
             WHEN WS-KIND = 6 AND WS-CD >= 1 AND WS-CD <= 8 AND (WS-BASE = "armor_head" OR "armor_chest" OR "armor_legs" OR "armor_feet")
                 MOVE "humanoid" TO WS-NAME
                 IF WS-BASE = "armor_legs"
                     MOVE "humanoid_leggings" TO WS-NAME
                 END-IF
*>               A baby's pieces are all of the layer type humanoid_baby (34-2 section 1.5 step 2).
                 IF WS-BABY NOT = SPACES
                     MOVE "humanoid_baby" TO WS-NAME
                 END-IF
                 COMPUTE WS-I = 30 + WS-CD
                 STRING "textures/entity/equipment/" FUNCTION TRIM(WS-NAME) "/" FUNCTION TRIM(WS-OV(WS-I)) ".png"
                     DELIMITED BY SIZE INTO L-PATH
             WHEN WS-KIND = 7 AND WS-CD >= 1 AND WS-CD <= 27
                 AND (WS-BASE = "horse_armor" OR "undead_horse_armor" OR "wolf_armor" OR "llama_decor" OR "nautilus_armor")
*>               Body armor: the equipment layer type directory (horse_body, wolf_body, llama_body) and the asset.
                 MOVE "horse_body" TO WS-NAME
                 IF WS-BASE = "wolf_armor"
                     MOVE "wolf_body" TO WS-NAME
                 END-IF
                 IF WS-BASE = "llama_decor"
                     MOVE "llama_body" TO WS-NAME
                 END-IF
                 IF WS-BASE = "nautilus_armor"
                     MOVE "nautilus_body" TO WS-NAME
                 END-IF
                 COMPUTE WS-I = 30 + WS-CD
                 STRING "textures/entity/equipment/" FUNCTION TRIM(WS-NAME) "/" FUNCTION TRIM(WS-OV(WS-I)) ".png"
                     DELIMITED BY SIZE INTO L-PATH
             WHEN WS-KIND = 9 AND WS-BASE = "banner" AND WS-CD >= 1 AND WS-CD <= 43
*>               A banner pattern sprite (54 section 22.3): the pattern's id under entity/banner.
                 CALL "BANNER-PATTERN-NAME" USING WS-CD WS-DIRNAME
                 STRING "textures/entity/banner/" FUNCTION TRIM(WS-DIRNAME) ".png" DELIMITED BY SIZE INTO L-PATH
             WHEN WS-KIND = 8 AND WS-CD = 1
*>               A saddle: the row key is the layer type (horse_saddle, pig_saddle, strider_saddle, ...).
                 MOVE WS-BASE TO WS-DIRNAME
                 IF WS-BASE = "skhorse_saddle"
                     MOVE "skeleton_horse_saddle" TO WS-DIRNAME
                 END-IF
                 STRING "textures/entity/equipment/" FUNCTION TRIM(WS-DIRNAME) "/saddle.png" DELIMITED BY SIZE INTO L-PATH
             WHEN WS-KIND = 5 AND (WS-BASE = "wolf" OR "cat")
                 STRING "textures/entity/" FUNCTION TRIM(WS-BASE) "/" FUNCTION TRIM(WS-BASE) "_collar" FUNCTION TRIM(WS-BABY) ".png"
                     DELIMITED BY SIZE INTO L-PATH
             WHEN OTHER
                 CONTINUE
         END-EVALUATE
     END-IF
     IF L-CODE > 0 AND WS-KIND = 0
         EVALUATE WS-BASE
             WHEN "cow" WHEN "pig" WHEN "chicken" WHEN "frog"
                 IF WS-CD <= 3
                     STRING "textures/entity/" FUNCTION TRIM(WS-BASE) "/" FUNCTION TRIM(WS-BASE) "_" FUNCTION TRIM(WS-NM(WS-CD))
                         FUNCTION TRIM(WS-BABY) ".png" DELIMITED BY SIZE INTO L-PATH
                 END-IF
             WHEN "mooshroom"
                 IF WS-CD <= 2
                     IF WS-CD = 1
                         MOVE "red" TO WS-NAME
                     ELSE
                         MOVE "brown" TO WS-NAME
                     END-IF
                     STRING "textures/entity/cow/mooshroom_" FUNCTION TRIM(WS-NAME) FUNCTION TRIM(WS-BABY) ".png"
                         DELIMITED BY SIZE INTO L-PATH
                 END-IF
             WHEN "wolf"
*>               State 1 tame, 2 angry (34-5 2.5): wolf_<variant>_<state>[_baby], the pale variant has no variant part.
                 IF WS-CD >= 1 AND WS-CD <= 9
                     COMPUTE WS-I = 3 + WS-CD
                     MOVE SPACES TO WS-NAME
                     IF WS-STATE = 1
                         MOVE "_tame" TO WS-NAME
                     END-IF
                     IF WS-STATE = 2
                         MOVE "_angry" TO WS-NAME
                     END-IF
                     IF WS-NM(WS-I) = "pale"
                         STRING "textures/entity/wolf/wolf" FUNCTION TRIM(WS-NAME) FUNCTION TRIM(WS-BABY) ".png"
                             DELIMITED BY SIZE INTO L-PATH
                     ELSE
                         STRING "textures/entity/wolf/wolf_" FUNCTION TRIM(WS-NM(WS-I)) FUNCTION TRIM(WS-NAME) FUNCTION TRIM(WS-BABY)
                             ".png" DELIMITED BY SIZE INTO L-PATH
                     END-IF
                 END-IF
             WHEN "cat"
                 IF WS-CD <= 11
                     COMPUTE WS-I = 12 + WS-CD
                     STRING "textures/entity/cat/cat_" FUNCTION TRIM(WS-NM(WS-I)) FUNCTION TRIM(WS-BABY) ".png"
                         DELIMITED BY SIZE INTO L-PATH
                 END-IF
             WHEN "horse"
                 IF WS-CD <= 7
                     COMPUTE WS-I = 23 + WS-CD
                     STRING "textures/entity/horse/horse_" FUNCTION TRIM(WS-NM(WS-I)) FUNCTION TRIM(WS-BABY) ".png"
                         DELIMITED BY SIZE INTO L-PATH
                 END-IF
             WHEN "llama" WHEN "trader_llama"
                 IF WS-CD <= 4
                     COMPUTE WS-I = 30 + WS-CD
                     STRING "textures/entity/llama/llama_" FUNCTION TRIM(WS-NM(WS-I)) FUNCTION TRIM(WS-BABY) ".png"
                         DELIMITED BY SIZE INTO L-PATH
                 END-IF
             WHEN "rabbit"
                 IF WS-CD <= 8
                     COMPUTE WS-I = 34 + WS-CD
                     IF WS-CD = 8
                         MOVE 41 TO WS-I
                     END-IF
                     STRING "textures/entity/rabbit/rabbit_" FUNCTION TRIM(WS-NM(WS-I)) FUNCTION TRIM(WS-BABY) ".png"
                         DELIMITED BY SIZE INTO L-PATH
                 END-IF
             WHEN "axolotl"
                 IF WS-CD <= 5
                     COMPUTE WS-I = 41 + WS-CD
                     STRING "textures/entity/axolotl/axolotl_" FUNCTION TRIM(WS-NM(WS-I)) FUNCTION TRIM(WS-BABY) ".png"
                         DELIMITED BY SIZE INTO L-PATH
                 END-IF
             WHEN "parrot"
                 IF WS-CD <= 5
                     COMPUTE WS-I = 46 + WS-CD
                     STRING "textures/entity/parrot/parrot_" FUNCTION TRIM(WS-NM(WS-I)) ".png" DELIMITED BY SIZE INTO L-PATH
                 END-IF
             WHEN "tropical_pattern"
                 IF WS-CD <= 6
                     MOVE WS-CD TO WS-DIGIT
                     MOVE "a" TO WS-NAME
                     IF WS-TAIL = "l"
                         MOVE "b" TO WS-NAME
                     END-IF
                     STRING "textures/entity/fish/tropical_" FUNCTION TRIM(WS-NAME) "_pattern_" WS-DIGIT ".png"
                         DELIMITED BY SIZE INTO L-PATH
                 END-IF
             WHEN "fox"
*>               Sleeping (state 1): fox_sleep and fox_snow_sleep, a baby fox_sleep_baby.
                 IF WS-CD = 2 AND WS-STATE = 0
                     STRING "textures/entity/fox/fox_snow" FUNCTION TRIM(WS-BABY) ".png" DELIMITED BY SIZE INTO L-PATH
                 END-IF
                 IF WS-CD = 1 AND WS-STATE = 1
                     STRING "textures/entity/fox/fox_sleep" FUNCTION TRIM(WS-BABY) ".png" DELIMITED BY SIZE INTO L-PATH
                 END-IF
                 IF WS-CD = 2 AND WS-STATE = 1
                     STRING "textures/entity/fox/fox_snow_sleep" FUNCTION TRIM(WS-BABY) ".png" DELIMITED BY SIZE INTO L-PATH
                 END-IF
             WHEN "panda"
                 EVALUATE WS-CD
                     WHEN 2 MOVE "lazy" TO WS-NAME
                     WHEN 3 MOVE "worried" TO WS-NAME
                     WHEN 4 MOVE "playful" TO WS-NAME
                     WHEN 5 MOVE "brown" TO WS-NAME
                     WHEN 6 MOVE "weak" TO WS-NAME
                     WHEN 7 MOVE "aggressive" TO WS-NAME
                     WHEN OTHER MOVE SPACES TO WS-NAME
                 END-EVALUATE
                 IF WS-NAME NOT = SPACES AND WS-BABY = SPACES
                     STRING "textures/entity/panda/panda_" FUNCTION TRIM(WS-NAME) ".png" DELIMITED BY SIZE INTO L-PATH
                 END-IF
                 IF WS-NAME NOT = SPACES AND WS-BABY NOT = SPACES
                     STRING "textures/entity/panda/" FUNCTION TRIM(WS-NAME) "_panda_baby.png" DELIMITED BY SIZE INTO L-PATH
                 END-IF
             WHEN OTHER
                 CONTINUE
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM ENTITY-TEX-PATH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-TINT.
*> USING CLIENT-STATE, replica row, model row drawn, red, green, blue out (FLOAT-LONG 0 to 1, the colour the model's texture is multiplied by): the wool of a sheep in
*> the colour of its dye (34-4 section 5: white 0xE6E6E6, else each channel of the dye's diffuse colour x 0.75 rounded down), the base layer of a tropical fish in its
*> base colour and the pattern layer in its pattern colour (34-8 section 5.4: the packed variant EN-VAR, base colour bits 16 to 23, pattern colour bits 24 to 31, dye
*> diffuse colours of the same table), the collar layer of a wolf or cat in its dye (the diffuse colour); 1 for everything else.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLMODELS.
 01 WS-DIFFUSE-DATA.
    05 FILLER PIC 9(8) VALUE 16383998.
    05 FILLER PIC 9(8) VALUE 16351261.
    05 FILLER PIC 9(8) VALUE 13061821.
    05 FILLER PIC 9(8) VALUE 3847130.
    05 FILLER PIC 9(8) VALUE 16701501.
    05 FILLER PIC 9(8) VALUE 8439583.
    05 FILLER PIC 9(8) VALUE 15961002.
    05 FILLER PIC 9(8) VALUE 4673362.
    05 FILLER PIC 9(8) VALUE 10329495.
    05 FILLER PIC 9(8) VALUE 1481884.
    05 FILLER PIC 9(8) VALUE 8991416.
    05 FILLER PIC 9(8) VALUE 3949738.
    05 FILLER PIC 9(8) VALUE 8606770.
    05 FILLER PIC 9(8) VALUE 6192150.
    05 FILLER PIC 9(8) VALUE 11546150.
    05 FILLER PIC 9(8) VALUE 1908001.
 01 WS-DIFFUSE REDEFINES WS-DIFFUSE-DATA.
    05 WS-DF                PIC 9(8) OCCURS 16 TIMES.
 01 WS-BASE                PIC X(20).
 01 WS-TAIL                PIC X(2).
 01 WS-DYE                 BINARY-LONG.
 01 WS-RGB                 BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-MODEL                BINARY-LONG.
 01 L-RED                  FLOAT-LONG.
 01 L-GREEN                FLOAT-LONG.
 01 L-BLUE                 FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-MODEL L-RED L-GREEN L-BLUE.
     MOVE 1 TO L-RED L-GREEN L-BLUE
     MOVE SPACES TO WS-BASE WS-TAIL
     UNSTRING CL-MD-KEY(L-MODEL) DELIMITED BY "~" INTO WS-BASE WS-TAIL
     MOVE 0 TO WS-MODE
     MOVE 0 TO WS-DYE
     EVALUATE WS-BASE
         WHEN "sheep_wool"
             MOVE 1 TO WS-MODE
             IF EN-VAR(L-ROW) >= 0
                 COMPUTE WS-DYE = FUNCTION MOD(EN-VAR(L-ROW), 16)
             END-IF
         WHEN "tropical_fish"
             MOVE 2 TO WS-MODE
             IF EN-VAR(L-ROW) >= 0
                 COMPUTE WS-DYE = FUNCTION MOD(FUNCTION INTEGER(EN-VAR(L-ROW) / 65536), 16)
             END-IF
         WHEN "tropical_pattern"
             MOVE 2 TO WS-MODE
             IF EN-VAR(L-ROW) >= 0
                 COMPUTE WS-DYE = FUNCTION MOD(FUNCTION INTEGER(EN-VAR(L-ROW) / 16777216), 16)
             END-IF
         WHEN OTHER
             CONTINUE
     END-EVALUATE
*>   The collar layer of a wolf or cat (code 5000 + n of ENTITY-OVERLAY): the dye's diffuse colour of EN-X2 (34-5 1.4).
     IF EN-OVL(L-ROW) >= 5000 AND EN-OVL(L-ROW) < 6000
         MOVE 2 TO WS-MODE
         COMPUTE WS-DYE = FUNCTION MOD(EN-X2(L-ROW), 16)
     END-IF
     IF WS-MODE > 0
         MOVE WS-DF(WS-DYE + 1) TO WS-RGB
         COMPUTE WS-R = FUNCTION INTEGER(WS-RGB / 65536)
         COMPUTE WS-G = FUNCTION MOD(FUNCTION INTEGER(WS-RGB / 256), 256)
         COMPUTE WS-B = FUNCTION MOD(WS-RGB, 256)
         IF WS-MODE = 1
             IF WS-DYE = 0
                 MOVE 230 TO WS-R WS-G WS-B
             ELSE
                 COMPUTE WS-R = FUNCTION INTEGER(WS-R * 0.75)
                 COMPUTE WS-G = FUNCTION INTEGER(WS-G * 0.75)
                 COMPUTE WS-B = FUNCTION INTEGER(WS-B * 0.75)
             END-IF
         END-IF
         COMPUTE L-RED = WS-R / 255
         COMPUTE L-GREEN = WS-G / 255
         COMPUTE L-BLUE = WS-B / 255
     END-IF
     GOBACK.
 END PROGRAM ENTITY-TINT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-MODEL-ROW.
*> USING CLIENT-STATE, replica row, model row out (BINARY-LONG): the row of CL-MODELS that draws the entity now: its type's row, the baby row for a baby (CL-MD-BABY),
*> and for the fish the row of their variant (34-8 section 5: the tropical fish of pattern base LARGE, the pufferfish of puff state 1 and 2, the salmon of type 0 and 2,
*> rows keyed tropical_fish~l, pufferfish~1, pufferfish~2, salmon~s, salmon~l).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLMODELS.
 01 WS-KEY                 PIC X(24).
 01 WS-FIND                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-MODEL                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-MODEL.
     MOVE EN-MODEL(L-ROW) TO L-MODEL
     IF L-MODEL > 0 AND EN-BABY(L-ROW) = 1 AND CL-MD-BABY(L-MODEL) > 0
         MOVE CL-MD-BABY(L-MODEL) TO L-MODEL
     END-IF
     MOVE SPACES TO WS-KEY
     IF L-MODEL > 0 AND EN-VAR(L-ROW) >= 0
         EVALUATE EN-KEY(L-ROW)
             WHEN "tropical_fish"
                 IF FUNCTION MOD(EN-VAR(L-ROW), 256) = 1
                     MOVE "tropical_fish~l" TO WS-KEY
                 END-IF
             WHEN "pufferfish"
                 IF EN-VAR(L-ROW) = 1
                     MOVE "pufferfish~1" TO WS-KEY
                 END-IF
                 IF EN-VAR(L-ROW) >= 2
                     MOVE "pufferfish~2" TO WS-KEY
                 END-IF
             WHEN "salmon"
                 IF EN-VAR(L-ROW) = 0
                     MOVE "salmon~s" TO WS-KEY
                 END-IF
                 IF EN-VAR(L-ROW) >= 2
                     MOVE "salmon~l" TO WS-KEY
                 END-IF
             WHEN "zombie_nautilus"
                 IF EN-VAR(L-ROW) = 1
                     MOVE "zombie_nautilus~w" TO WS-KEY
                 END-IF
             WHEN OTHER
                 CONTINUE
         END-EVALUATE
     END-IF
     IF WS-KEY NOT = SPACES
         CALL "ENTITY-MODEL-FIND" USING WS-KEY WS-FIND
         IF WS-FIND > 0
             MOVE WS-FIND TO L-MODEL
         END-IF
     END-IF
     GOBACK.
 END PROGRAM ENTITY-MODEL-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-BABY-INDEX.
*> USING entity type key (X(24)), index out (BINARY-LONG): the Set Entity Data entry that holds the baby flag (BOOLEAN) of the type (21 Appendix A): 16 for the ageable mobs and the
*> zombies, 17 for the piglin, 0 (none) for the types whose entry 16 is something else (allay dancing, bogged sheared, the fish's from_bucket, creaking, guardians moving, the
*> illagers and the witch celebrating, ghast charging, the piglin brute's immunity, the skeleton's conversion, the tadpole's from_bucket).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(24).
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-INDEX.
     EVALUATE L-KEY
         WHEN "piglin"
             MOVE 17 TO L-INDEX
         WHEN "allay" WHEN "bogged" WHEN "cod" WHEN "salmon" WHEN "tropical_fish" WHEN "pufferfish" WHEN "tadpole"
         WHEN "creaking" WHEN "guardian" WHEN "elder_guardian" WHEN "evoker" WHEN "illusioner" WHEN "pillager"
         WHEN "vindicator" WHEN "ravager" WHEN "witch" WHEN "ghast" WHEN "piglin_brute" WHEN "skeleton"
             MOVE 0 TO L-INDEX
         WHEN OTHER
             MOVE 16 TO L-INDEX
     END-EVALUATE
     GOBACK.
 END PROGRAM ENTITY-BABY-INDEX.
