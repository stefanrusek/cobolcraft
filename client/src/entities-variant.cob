*> Variant data of the mobs in the render path (docs/protocol 54 section 5 registry id order, 19 section 1.3 and 21 appendix metadata layouts, 34-4 to 34-8 texture rules):
*> ENTITY-VARIANT-SET keeps the Set Entity Data entry that holds a mob's variant in the replica row (EN-VAR, EN-VAR2, EN-VAR3), ENTITY-TEX-CODE turns the row's
*> variant into the texture code of its atlas slot (0 = the image of the model row), ENTITY-TEX-PATH gives the texture path of a model row and code (spaces when the
*> variant has none: the row's own image is used). A variant image that the pack stack lacks falls back to the row's image (ENTITY-ATLAS-BUILD).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-VARIANT-SET.
*> USING CLIENT-STATE, replica row, entry index, serializer, value, second and third value (VILLAGER_DATA).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-WANT                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-SERIALIZER           BINARY-LONG.
 01 L-INT                  BINARY-LONG.
 01 L-INT2                 BINARY-LONG.
 01 L-INT3                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-INDEX L-SERIALIZER L-INT L-INT2 L-INT3.
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
     MOVE SPACES TO WS-BASE WS-TAIL
     UNSTRING CL-MD-KEY(L-MODEL) DELIMITED BY "~" INTO WS-BASE WS-TAIL
*>   An extra layer (the sheep's wool, the slime's outer layer) keeps its own image.
     IF EN-VAR(L-ROW) >= 0 AND WS-BASE = EN-KEY(L-ROW)
         EVALUATE EN-KEY(L-ROW)
             WHEN "pig" WHEN "cow" WHEN "chicken" WHEN "mooshroom" WHEN "rabbit" WHEN "fox" WHEN "frog" WHEN "axolotl"
             WHEN "wolf" WHEN "cat" WHEN "llama" WHEN "trader_llama" WHEN "panda" WHEN "parrot"
                 COMPUTE L-CODE = EN-VAR(L-ROW) + 1
                 IF EN-VAR(L-ROW) = 99
                     MOVE 8 TO L-CODE
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
 01 WS-NAME                PIC X(16).
 01 WS-DIR                 PIC X(10).
 01 WS-PTR                 BINARY-LONG.
 01 WS-BABY                PIC X(5).
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
     IF L-CODE > 0
         EVALUATE WS-BASE
             WHEN "cow" WHEN "pig" WHEN "chicken" WHEN "frog"
                 IF L-CODE <= 3
                     STRING "textures/entity/" FUNCTION TRIM(WS-BASE) "/" FUNCTION TRIM(WS-BASE) "_" FUNCTION TRIM(WS-NM(L-CODE))
                         FUNCTION TRIM(WS-BABY) ".png" DELIMITED BY SIZE INTO L-PATH
                 END-IF
             WHEN "mooshroom"
                 IF L-CODE <= 2
                     IF L-CODE = 1
                         MOVE "red" TO WS-NAME
                     ELSE
                         MOVE "brown" TO WS-NAME
                     END-IF
                     STRING "textures/entity/cow/mooshroom_" FUNCTION TRIM(WS-NAME) FUNCTION TRIM(WS-BABY) ".png"
                         DELIMITED BY SIZE INTO L-PATH
                 END-IF
             WHEN "wolf"
                 IF L-CODE <= 9
                     COMPUTE WS-I = 3 + L-CODE
                     IF WS-NM(WS-I) = "pale"
                         STRING "textures/entity/wolf/wolf" FUNCTION TRIM(WS-BABY) ".png" DELIMITED BY SIZE INTO L-PATH
                     ELSE
                         STRING "textures/entity/wolf/wolf_" FUNCTION TRIM(WS-NM(WS-I)) FUNCTION TRIM(WS-BABY) ".png"
                             DELIMITED BY SIZE INTO L-PATH
                     END-IF
                 END-IF
             WHEN "cat"
                 IF L-CODE <= 11
                     COMPUTE WS-I = 12 + L-CODE
                     STRING "textures/entity/cat/cat_" FUNCTION TRIM(WS-NM(WS-I)) FUNCTION TRIM(WS-BABY) ".png"
                         DELIMITED BY SIZE INTO L-PATH
                 END-IF
             WHEN "horse"
                 IF L-CODE <= 7
                     COMPUTE WS-I = 23 + L-CODE
                     STRING "textures/entity/horse/horse_" FUNCTION TRIM(WS-NM(WS-I)) FUNCTION TRIM(WS-BABY) ".png"
                         DELIMITED BY SIZE INTO L-PATH
                 END-IF
             WHEN "llama" WHEN "trader_llama"
                 IF L-CODE <= 4
                     COMPUTE WS-I = 30 + L-CODE
                     STRING "textures/entity/llama/llama_" FUNCTION TRIM(WS-NM(WS-I)) FUNCTION TRIM(WS-BABY) ".png"
                         DELIMITED BY SIZE INTO L-PATH
                 END-IF
             WHEN "rabbit"
                 IF L-CODE <= 8
                     COMPUTE WS-I = 34 + L-CODE
                     IF L-CODE = 8
                         MOVE 41 TO WS-I
                     END-IF
                     STRING "textures/entity/rabbit/rabbit_" FUNCTION TRIM(WS-NM(WS-I)) FUNCTION TRIM(WS-BABY) ".png"
                         DELIMITED BY SIZE INTO L-PATH
                 END-IF
             WHEN "axolotl"
                 IF L-CODE <= 5
                     COMPUTE WS-I = 41 + L-CODE
                     STRING "textures/entity/axolotl/axolotl_" FUNCTION TRIM(WS-NM(WS-I)) FUNCTION TRIM(WS-BABY) ".png"
                         DELIMITED BY SIZE INTO L-PATH
                 END-IF
             WHEN "parrot"
                 IF L-CODE <= 5
                     COMPUTE WS-I = 46 + L-CODE
                     STRING "textures/entity/parrot/parrot_" FUNCTION TRIM(WS-NM(WS-I)) ".png" DELIMITED BY SIZE INTO L-PATH
                 END-IF
             WHEN "fox"
                 IF L-CODE = 2
                     STRING "textures/entity/fox/fox_snow" FUNCTION TRIM(WS-BABY) ".png" DELIMITED BY SIZE INTO L-PATH
                 END-IF
             WHEN "panda"
                 EVALUATE L-CODE
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
*> diffuse colours of the same table); 1 for everything else.
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
