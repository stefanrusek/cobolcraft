*> Overlay layers of the mobs: a layer is the model of the mob drawn once more with a texture of its own, slightly larger so that it lies over the body
*> (the opaque entity mesh has no depth test that would let a coplanar layer through, see ENTITY-MODEL-EMIT). Their texture codes (ENTITY-TEX-CODE, ENTITY-TEX-PATH):
*> 1000 + n the type texture of a villager or zombie villager (34-3 1.5, n = type id + 1 in the registry order of 54 section 5; a baby takes the baby folder), 2000 + n its
*> profession texture, 3000 + n its level texture (n = level 1 to 5), 4000 + n the horse's markings (34-4 8.5), 5000 + n the collar of a wolf or cat (34-5 2 and 3,
*> tinted by ENTITY-TINT with the dye of EN-X2).
*> Gap (docs hold no data): the hat value of the villager textures' .mcmeta decides whether the type layer draws the head (34-3 1.5); the replica does not read it
*> and the type layer always draws the whole model.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-OVERLAY.
*> USING CLIENT-STATE, replica row, layer number 1 to 12, code out (BINARY-LONG, 0 when the row has no such layer), red, green, blue out (FLOAT-LONG: the tint of the layer),
*> model row out (0: the row's own model; the armor pieces of layers 5 to 8 have their own).
*> Villager and zombie villager: 1 type (known data only), 2 profession (not for a baby, id 1 to 14), 3 level (not for a baby, a nitwit or no profession; clamped to 1 to 5).
*> Zombie, husk, drowned, skeletons, piglins (adults): 5 chest, 6 legs, 7 feet, 8 head armor piece (code 6000 + asset of ENTITY-ARMOR-ASSET) with the model row armor_<slot>.
*> Horse: 1 markings (entry 19 value / 256 of 1 to 4). Wolf and cat: 1 collar when tame (flags bit 4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLMODELS.
 01 WS-NOW                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-MARK                BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ASSET               BINARY-LONG.
 01 WS-FK                  PIC X(24).
 01 WS-FK2                 PIC X(20).
 01 WS-VPATH               PIC X(64).
 01 WS-N                   BINARY-LONG.
 01 WS-HAT                 BINARY-LONG.
 01 WS-PROF-HAT            BINARY-LONG.
 01 WS-TYPE-HAT            BINARY-LONG.
 01 WS-DYE                 BINARY-LONG.
 01 WS-LAYER               BINARY-LONG.
 01 WS-PALETTE             BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-CODE                 BINARY-LONG.
 01 L-RED                  FLOAT-LONG.
 01 L-GREEN                FLOAT-LONG.
 01 L-BLUE                 FLOAT-LONG.
 01 L-MODEL                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-N L-CODE L-RED L-GREEN L-BLUE L-MODEL.
     MOVE 0 TO L-CODE L-MODEL
     EVALUATE EN-KEY(L-ROW)
         WHEN "villager"
         WHEN "zombie_villager"
             IF EN-VAR(L-ROW) >= 0
                 EVALUATE L-N
                     WHEN 1
                         IF EN-VAR(L-ROW) <= 6
                             COMPUTE L-CODE = 1001 + EN-VAR(L-ROW)
                             PERFORM HAT-MODEL
                         END-IF
                     WHEN 2
                         IF EN-BABY(L-ROW) = 0 AND EN-VAR2(L-ROW) >= 1 AND EN-VAR2(L-ROW) <= 14
                             COMPUTE L-CODE = 2000 + EN-VAR2(L-ROW)
                         END-IF
                     WHEN 3
                         IF EN-BABY(L-ROW) = 0 AND EN-VAR2(L-ROW) >= 1 AND EN-VAR2(L-ROW) <= 14 AND EN-VAR2(L-ROW) NOT = 11
                             COMPUTE WS-LEVEL = FUNCTION MIN(FUNCTION MAX(EN-VAR3(L-ROW), 1), 5)
                             COMPUTE L-CODE = 3000 + WS-LEVEL
                         END-IF
                     WHEN OTHER
                         CONTINUE
                 END-EVALUATE
             END-IF
         WHEN "horse"
             IF L-N = 1 AND EN-VAR(L-ROW) >= 0
                 COMPUTE WS-MARK = FUNCTION INTEGER(EN-VAR(L-ROW) / 256)
                 IF WS-MARK >= 1 AND WS-MARK <= 4
                     COMPUTE L-CODE = 4000 + WS-MARK
                 END-IF
             END-IF
         WHEN "wolf"
         WHEN "cat"
             IF L-N = 1 AND FUNCTION MOD(FUNCTION INTEGER(EN-X1(L-ROW) / 4), 2) = 1
                 MOVE 5001 TO L-CODE
             END-IF
         WHEN "zombie" WHEN "husk" WHEN "drowned" WHEN "skeleton" WHEN "stray" WHEN "bogged" WHEN "parched" WHEN "wither_skeleton"
         WHEN "zombified_piglin" WHEN "piglin" WHEN "piglin_brute"
*>           The armor pieces of an adult (34-2 1.5), in the order chest, legs, feet, head: layers 5 to 8, each with the model row of its slot.
             IF L-N >= 5 AND L-N <= 12 AND EN-BABY(L-ROW) = 0
*>               Layers 9 to 12 are the trims of the pieces of layers 5 to 8 (54 section 18).
                 COMPUTE WS-LAYER = L-N
                 IF L-N > 8
                     SUBTRACT 4 FROM WS-LAYER
                 END-IF
                 EVALUATE WS-LAYER
                     WHEN 5 MOVE 2 TO WS-WANT
                     WHEN 6 MOVE 3 TO WS-WANT
                     WHEN 7 MOVE 4 TO WS-WANT
                     WHEN OTHER MOVE 1 TO WS-WANT
                 END-EVALUATE
*>               Equipment slot ordinal 2 feet, 3 legs, 4 chest, 5 head: EN-EQ index ordinal + 1; the item's own slot must be the slot drawn.
                 COMPUTE WS-ITEM = EN-EQ(L-ROW, 7 - WS-WANT)
                 IF WS-ITEM > 0
                     CALL "ENTITY-ARMOR-ASSET" USING CLIENT-STATE WS-ITEM WS-SLOT WS-ASSET
                     IF WS-SLOT = WS-WANT AND L-N > 8
*>                       The trim: the palette of the material (darker for the armor's own material) and the pattern, code 100000 + palette * 100 + pattern.
                         IF EN-EQ-TRIM-MAT(L-ROW, 7 - WS-WANT) >= 1 AND EN-EQ-TRIM-MAT(L-ROW, 7 - WS-WANT) <= 11
                                 AND EN-EQ-TRIM-PAT(L-ROW, 7 - WS-WANT) >= 1 AND EN-EQ-TRIM-PAT(L-ROW, 7 - WS-WANT) <= 18
                             CALL "TRIM-PALETTE-FOR" USING WS-ASSET EN-EQ-TRIM-MAT(L-ROW, 7 - WS-WANT) WS-PALETTE
                             COMPUTE L-CODE = 100000 + WS-PALETTE * 100 + EN-EQ-TRIM-PAT(L-ROW, 7 - WS-WANT)
                             PERFORM ARMOR-MODEL-ROW
                         END-IF
                     END-IF
                     IF WS-SLOT = WS-WANT AND L-N <= 8
                         COMPUTE L-CODE = 6000 + WS-ASSET
                         PERFORM ARMOR-MODEL-ROW
                     END-IF
                 END-IF
             END-IF
         WHEN OTHER
             CONTINUE
     END-EVALUATE
*>   Body armor (layer 5) and the saddle (layer 6) of the animals (34-4 8 and 9.3, 34-5 2.6): the item's piece, the model row of the piece (WS-FK), the carpet of a
*>   trader llama when no carpet is worn (a baby wears that one only, with the baby row).
     IF L-CODE = 0 AND (L-N = 5 OR L-N = 6)
         MOVE 0 TO WS-KIND
         MOVE 0 TO WS-ASSET
         MOVE SPACES TO WS-FK
         IF L-N = 5
             MOVE EN-EQ(L-ROW, 7) TO WS-ITEM
         ELSE
             MOVE EN-EQ(L-ROW, 8) TO WS-ITEM
         END-IF
         IF WS-ITEM > 0
             CALL "ENTITY-BODY-ASSET" USING CLIENT-STATE WS-ITEM WS-KIND WS-ASSET
         END-IF
         EVALUATE TRUE
             WHEN L-N = 5 AND WS-KIND = 1 AND EN-BABY(L-ROW) = 0 AND EN-KEY(L-ROW) = "horse"
                 MOVE "horse_armor" TO WS-FK
             WHEN L-N = 5 AND WS-KIND = 1 AND EN-BABY(L-ROW) = 0 AND (EN-KEY(L-ROW) = "zombie_horse" OR "skeleton_horse")
                 MOVE "undead_horse_armor" TO WS-FK
             WHEN L-N = 5 AND WS-KIND = 2 AND EN-BABY(L-ROW) = 0 AND EN-KEY(L-ROW) = "wolf"
                 MOVE "wolf_armor" TO WS-FK
             WHEN L-N = 5 AND WS-KIND = 3 AND EN-BABY(L-ROW) = 0 AND (EN-KEY(L-ROW) = "llama" OR "trader_llama")
                 MOVE "llama_decor" TO WS-FK
             WHEN L-N = 5 AND WS-KIND = 5 AND EN-BABY(L-ROW) = 0 AND (EN-KEY(L-ROW) = "nautilus" OR "zombie_nautilus")
                 MOVE "nautilus_armor" TO WS-FK
             WHEN L-N = 6 AND WS-KIND = 4 AND EN-BABY(L-ROW) = 0 AND EN-KEY(L-ROW) = "zombie_nautilus"
                 MOVE "nautilus_saddle" TO WS-FK
             WHEN L-N = 6 AND WS-KIND = 4 AND EN-BABY(L-ROW) = 0
                 STRING FUNCTION TRIM(EN-KEY(L-ROW)) "_saddle" DELIMITED BY SIZE INTO WS-FK
*>               The row key of the skeleton horse's saddle is shortened to the 20 characters of a key.
                 IF EN-KEY(L-ROW) = "skeleton_horse"
                     MOVE "skhorse_saddle" TO WS-FK
                 END-IF
             WHEN OTHER
                 CONTINUE
         END-EVALUATE
         IF WS-FK NOT = SPACES
             IF L-N = 5
                 COMPUTE L-CODE = 7000 + WS-ASSET
             ELSE
                 MOVE 8001 TO L-CODE
             END-IF
         END-IF
         IF WS-FK = SPACES AND L-N = 5 AND EN-KEY(L-ROW) = "trader_llama"
             MOVE "llama_decor" TO WS-FK
             MOVE 7026 TO L-CODE
         END-IF
         IF L-CODE > 0
             CALL "ENTITY-MODEL-FIND" USING WS-FK L-MODEL
             IF L-MODEL = 0
                 MOVE 0 TO L-CODE
             END-IF
         END-IF
         IF L-CODE = 7026 AND EN-BABY(L-ROW) = 1
             MOVE 7027 TO L-CODE
             MOVE CL-MD-BABY(L-MODEL) TO L-MODEL
         END-IF
     END-IF
     GO TO TINT.

*> The model row of the armor piece of the slot WS-WANT.
 ARMOR-MODEL-ROW.
     EVALUATE WS-WANT
         WHEN 1 MOVE "armor_head" TO WS-FK
         WHEN 2 MOVE "armor_chest" TO WS-FK
         WHEN 3 MOVE "armor_legs" TO WS-FK
         WHEN OTHER MOVE "armor_feet" TO WS-FK
     END-EVALUATE
     CALL "ENTITY-MODEL-FIND" USING WS-FK L-MODEL.

*> The type layer draws the head unless the profession texture's hat covers it (34-3 1.5): the no-hat model (rows villager_nohat, zvillager_nohat and their babies) when
*> the profession's hat is full, or partial with a type texture whose hat is full. The hat of each is the `villager.hat` of the .mcmeta of the type texture (folder type
*> also for a baby) and of the profession texture (VILLAGER-HAT).
 HAT-MODEL.
     MOVE 0 TO WS-PROF-HAT WS-TYPE-HAT
     IF EN-VAR2(L-ROW) >= 1 AND EN-VAR2(L-ROW) <= 14
         COMPUTE WS-N = 2000 + EN-VAR2(L-ROW)
         PERFORM HAT-OF
         MOVE WS-HAT TO WS-PROF-HAT
         COMPUTE WS-N = 1001 + EN-VAR(L-ROW)
         PERFORM HAT-OF
         MOVE WS-HAT TO WS-TYPE-HAT
         IF WS-PROF-HAT = 2 OR (WS-PROF-HAT = 1 AND WS-TYPE-HAT = 2)
             MOVE SPACES TO WS-FK
             STRING FUNCTION TRIM(EN-KEY(L-ROW)) "_nohat" DELIMITED BY SIZE INTO WS-FK
             IF EN-KEY(L-ROW) = "zombie_villager"
                 MOVE "zvillager_nohat" TO WS-FK
             END-IF
             IF EN-BABY(L-ROW) = 1
                 STRING FUNCTION TRIM(WS-FK) "~b" DELIMITED BY SIZE INTO WS-FK
             END-IF
             CALL "ENTITY-MODEL-FIND" USING WS-FK L-MODEL
         END-IF
     END-IF.

 HAT-OF.
*>   The texture path of the code WS-N of the villager's key (the type texture of a baby is in the type folder here), then its hat value.
     MOVE EN-KEY(L-ROW) TO WS-FK2
     MOVE SPACES TO WS-VPATH
     CALL "ENTITY-TEX-PATH" USING WS-FK2 WS-N WS-VPATH
     CALL "VILLAGER-HAT" USING CLIENT-STATE WS-VPATH WS-HAT.

 TINT.
*>   The tint of the layer: ENTITY-TINT reads the layer in EN-OVL.
     MOVE 1 TO L-RED L-GREEN L-BLUE
     IF L-CODE > 0
         MOVE EN-OVL(L-ROW) TO WS-NOW
         MOVE L-CODE TO EN-OVL(L-ROW)
         CALL "ENTITY-TINT" USING CLIENT-STATE L-ROW EN-MODEL(L-ROW) L-RED L-GREEN L-BLUE
         MOVE WS-NOW TO EN-OVL(L-ROW)
*>       Worn leather (code 6001, layers 5 to 8): the dyed colour of the piece's stack when it is not 0, else the undyed brown A06540 (54 section 17, 43 section 7.2).
         IF L-CODE = 6001 AND L-N >= 5 AND L-N <= 8
             COMPUTE WS-DYE = EN-EQ-DYE(L-ROW, 7 - WS-WANT)
             IF WS-DYE <= 0
                 MOVE 10511680 TO WS-DYE
             END-IF
             COMPUTE L-RED = FUNCTION INTEGER(WS-DYE / 65536) / 255
             COMPUTE L-GREEN = FUNCTION MOD(FUNCTION INTEGER(WS-DYE / 256), 256) / 255
             COMPUTE L-BLUE = FUNCTION MOD(WS-DYE, 256) / 255
         END-IF
     END-IF
     GOBACK.
 END PROGRAM ENTITY-OVERLAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-ARMOR-ASSET.
*> USING CLIENT-STATE, item registry id, slot out (1 head, 2 chest, 3 legs, 4 feet, 0 not an armor piece of a humanoid), asset out (1 leather, 2 copper, 3 chainmail, 4 iron,
*> 5 gold, 6 diamond, 7 turtle scute, 8 netherite: the equipment asset key of 25-4 section 8): from the item's key, <material>_helmet, _chestplate, _leggings, _boots
*> (golden is the asset gold, turtle_helmet the asset turtle_scute). The asset JSON of a pack may differ: data the replica does not read.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NS                  PIC X(16).
 01 WS-NAME                PIC X(40).
 01 WS-MAX                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TOOL                PIC X.
 01 WS-FOOD                BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 01 WS-MATERIAL            PIC X(20).
 01 WS-PIECE               PIC X(20).
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ITEM                 BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-ASSET                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ITEM L-SLOT L-ASSET.
     MOVE 0 TO L-SLOT L-ASSET
     CALL "CL-ITEM-INFO" USING CLIENT-STATE L-ITEM WS-NS WS-NAME WS-MAX WS-BLOCK WS-TOOL WS-FOOD WS-KNOWN
     MOVE SPACES TO WS-MATERIAL WS-PIECE
     UNSTRING WS-NAME DELIMITED BY "_" INTO WS-MATERIAL WS-PIECE
     EVALUATE WS-PIECE
         WHEN "helmet" MOVE 1 TO L-SLOT
         WHEN "chestplate" MOVE 2 TO L-SLOT
         WHEN "leggings" MOVE 3 TO L-SLOT
         WHEN "boots" MOVE 4 TO L-SLOT
         WHEN OTHER CONTINUE
     END-EVALUATE
     EVALUATE WS-MATERIAL
         WHEN "leather" MOVE 1 TO L-ASSET
         WHEN "copper" MOVE 2 TO L-ASSET
         WHEN "chainmail" MOVE 3 TO L-ASSET
         WHEN "iron" MOVE 4 TO L-ASSET
         WHEN "golden" MOVE 5 TO L-ASSET
         WHEN "diamond" MOVE 6 TO L-ASSET
         WHEN "turtle" MOVE 7 TO L-ASSET
         WHEN "netherite" MOVE 8 TO L-ASSET
         WHEN OTHER MOVE 0 TO L-SLOT
     END-EVALUATE
     IF L-SLOT = 0
         MOVE 0 TO L-ASSET
     END-IF
     GOBACK.
 END PROGRAM ENTITY-ARMOR-ASSET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-BODY-ASSET.
*> USING CLIENT-STATE, item registry id, kind out (1 horse armor, 2 wolf armor, 3 llama carpet, 4 saddle, 0 none), asset out (the index of the asset in the name table
*> of ENTITY-TEX-PATH minus 30: horse armor 1 leather, 2 copper, 4 iron, 5 gold, 6 diamond, 8 netherite; wolf armor 9 armadillo scute; carpet 10 + the dye id): from the
*> item's key (<material>_horse_armor, wolf_armor, <dye>_carpet, saddle; 25-4 section 8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NS                  PIC X(16).
 01 WS-NAME                PIC X(40).
 01 WS-MAX                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TOOL                PIC X.
 01 WS-FOOD                BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 01 WS-MATERIAL            PIC X(20).
 01 WS-I                   BINARY-LONG.
 01 WS-MAT-DATA.
    05 FILLER PIC X(12) VALUE "leather     ".
    05 FILLER PIC X(12) VALUE "copper      ".
    05 FILLER PIC X(12) VALUE "chainmail   ".
    05 FILLER PIC X(12) VALUE "iron        ".
    05 FILLER PIC X(12) VALUE "golden      ".
    05 FILLER PIC X(12) VALUE "diamond     ".
    05 FILLER PIC X(12) VALUE "turtle      ".
    05 FILLER PIC X(12) VALUE "netherite   ".
 01 WS-MAT REDEFINES WS-MAT-DATA.
    05 WS-MT                PIC X(12) OCCURS 8 TIMES.
 01 WS-DYE-DATA.
    05 FILLER PIC X(12) VALUE "white       ".
    05 FILLER PIC X(12) VALUE "orange      ".
    05 FILLER PIC X(12) VALUE "magenta     ".
    05 FILLER PIC X(12) VALUE "light_blue  ".
    05 FILLER PIC X(12) VALUE "yellow      ".
    05 FILLER PIC X(12) VALUE "lime        ".
    05 FILLER PIC X(12) VALUE "pink        ".
    05 FILLER PIC X(12) VALUE "gray        ".
    05 FILLER PIC X(12) VALUE "light_gray  ".
    05 FILLER PIC X(12) VALUE "cyan        ".
    05 FILLER PIC X(12) VALUE "purple      ".
    05 FILLER PIC X(12) VALUE "blue        ".
    05 FILLER PIC X(12) VALUE "brown       ".
    05 FILLER PIC X(12) VALUE "green       ".
    05 FILLER PIC X(12) VALUE "red         ".
    05 FILLER PIC X(12) VALUE "black       ".
 01 WS-DYE REDEFINES WS-DYE-DATA.
    05 WS-DY                PIC X(12) OCCURS 16 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ITEM                 BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-ASSET                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ITEM L-KIND L-ASSET.
     MOVE 0 TO L-KIND L-ASSET
     CALL "CL-ITEM-INFO" USING CLIENT-STATE L-ITEM WS-NS WS-NAME WS-MAX WS-BLOCK WS-TOOL WS-FOOD WS-KNOWN
     IF WS-NAME = "saddle"
         MOVE 4 TO L-KIND
         MOVE 1 TO L-ASSET
     END-IF
     IF WS-NAME = "wolf_armor"
         MOVE 2 TO L-KIND
         MOVE 9 TO L-ASSET
     END-IF
     MOVE SPACES TO WS-MATERIAL
     UNSTRING WS-NAME DELIMITED BY "_horse_armor" INTO WS-MATERIAL
     IF FUNCTION TRIM(WS-NAME) NOT = FUNCTION TRIM(WS-MATERIAL)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
             IF WS-MT(WS-I) = WS-MATERIAL
                 MOVE 1 TO L-KIND
                 MOVE WS-I TO L-ASSET
             END-IF
         END-PERFORM
     END-IF
     MOVE SPACES TO WS-MATERIAL
     UNSTRING WS-NAME DELIMITED BY "_nautilus_armor" INTO WS-MATERIAL
     IF FUNCTION TRIM(WS-NAME) NOT = FUNCTION TRIM(WS-MATERIAL)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
             IF WS-MT(WS-I) = WS-MATERIAL
                 MOVE 5 TO L-KIND
                 MOVE WS-I TO L-ASSET
             END-IF
         END-PERFORM
     END-IF
     MOVE SPACES TO WS-MATERIAL
     UNSTRING WS-NAME DELIMITED BY "_carpet" INTO WS-MATERIAL
     IF FUNCTION TRIM(WS-NAME) NOT = FUNCTION TRIM(WS-MATERIAL)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
             IF WS-DY(WS-I) = WS-MATERIAL
                 MOVE 3 TO L-KIND
                 COMPUTE L-ASSET = 9 + WS-I
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM ENTITY-BODY-ASSET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VILLAGER-HAT.
*> USING CLIENT-STATE, texture path (X(64), relative to assets/minecraft/), hat out (BINARY-LONG: 0 none, 1 partial, 2 full): the `villager.hat` of the texture's
*> .mcmeta in the pack stack (34-3 1.5); a missing file, section or field, another value or text that is no JSON is none. Results are cached per path (64 entries,
*> replaced in turn); VILLAGER-HAT-RESET empties the cache (the pack stack changed).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY JSONDOC.
 01 WS-CACHE.
    05 WS-CE OCCURS 64 TIMES.
       10 WS-CE-PATH       PIC X(64) VALUE SPACES.
       10 WS-CE-HAT        BINARY-LONG VALUE 0.
 01 WS-NEXT                BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-FULL                PIC X(256).
 01 WS-PTR                 BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TEXT                PIC X(4096).
 01 WS-CAP                 BINARY-LONG VALUE 4096.
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-QUERY               PIC X(16).
 01 WS-QUERY-LENGTH        BINARY-LONG.
 01 WS-VALUE               PIC X(16).
 01 WS-VALUE-CAP           BINARY-LONG VALUE 16.
 01 WS-VALUE-LENGTH        BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PATH                 PIC X(64).
 01 L-HAT                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-PATH L-HAT.
     MOVE 0 TO L-HAT WS-HIT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64
         IF WS-CE-PATH(WS-I) = L-PATH AND WS-HIT = 0
             MOVE WS-CE-HAT(WS-I) TO L-HAT
             MOVE 1 TO WS-HIT
         END-IF
     END-PERFORM
     IF WS-HIT = 1
         GOBACK
     END-IF
     MOVE SPACES TO WS-FULL
     MOVE 1 TO WS-PTR
     STRING "assets/minecraft/" DELIMITED BY SIZE FUNCTION TRIM(L-PATH) DELIMITED BY SIZE ".mcmeta" DELIMITED BY SIZE
         INTO WS-FULL WITH POINTER WS-PTR
     COMPUTE WS-LENGTH = WS-PTR - 1
     CALL "PACK-READ" USING CLIENT-STATE WS-FULL WS-LENGTH WS-TEXT WS-CAP WS-TEXT-LENGTH WS-FOUND
     IF WS-FOUND = 1
         CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-TEXT-LENGTH
         IF JD-ERROR = 0
             MOVE "villager.hat" TO WS-QUERY
             MOVE 12 TO WS-QUERY-LENGTH
             CALL "JSON-FIND" USING JSON-DOC WS-QUERY WS-QUERY-LENGTH WS-NODE
             MOVE SPACES TO WS-VALUE
             MOVE 0 TO WS-VALUE-LENGTH
             CALL "JSON-STRING" USING JSON-DOC WS-NODE WS-VALUE WS-VALUE-CAP WS-VALUE-LENGTH
             EVALUATE WS-VALUE
                 WHEN "partial" MOVE 1 TO L-HAT
                 WHEN "full" MOVE 2 TO L-HAT
                 WHEN OTHER MOVE 0 TO L-HAT
             END-EVALUATE
         END-IF
     END-IF
     ADD 1 TO WS-NEXT
     IF WS-NEXT > 64
         MOVE 1 TO WS-NEXT
     END-IF
     MOVE L-PATH TO WS-CE-PATH(WS-NEXT)
     MOVE L-HAT TO WS-CE-HAT(WS-NEXT)
     GOBACK.

     ENTRY "VILLAGER-HAT-RESET".
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64
         MOVE SPACES TO WS-CE-PATH(WS-I)
     END-PERFORM
     GOBACK.
 END PROGRAM VILLAGER-HAT.
