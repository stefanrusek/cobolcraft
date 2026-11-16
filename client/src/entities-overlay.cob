*> Overlay layers of the mobs: a layer is the model of the mob drawn once more with a texture of its own, slightly larger so that it lies over the body
*> (the opaque entity mesh has no depth test that would let a coplanar layer through, see ENTITY-MODEL-EMIT). Their texture codes (ENTITY-TEX-CODE, ENTITY-TEX-PATH):
*> 1000 + n the type texture of a villager or zombie villager (34-3 1.5, n = type id + 1 in the registry order of 54 section 5; a baby takes the baby folder), 2000 + n its
*> profession texture, 3000 + n its level texture (n = level 1 to 5), 4000 + n the horse's markings (34-4 8.5), 5000 + n the collar of a wolf or cat (34-5 2 and 3,
*> tinted by ENTITY-TINT with the dye of EN-X2).
*> Gap (docs hold no data): the hat value of the villager textures' .mcmeta decides whether the type layer draws the head (34-3 1.5); the replica does not read it
*> and the type layer always draws the whole model.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-OVERLAY.
*> USING CLIENT-STATE, replica row, layer number 1 to 8, code out (BINARY-LONG, 0 when the row has no such layer), red, green, blue out (FLOAT-LONG: the tint of the layer),
*> model row out (0: the row's own model; the armor pieces of layers 5 to 8 have their own).
*> Villager and zombie villager: 1 type (known data only), 2 profession (not for a baby, id 1 to 14), 3 level (not for a baby, a nitwit or no profession; clamped to 1 to 5).
*> Zombie, husk, drowned, skeletons, piglins (adults): 5 chest, 6 legs, 7 feet, 8 head armor piece (code 6000 + asset of ENTITY-ARMOR-ASSET) with the model row armor_<slot>.
*> Horse: 1 markings (entry 19 value / 256 of 1 to 4). Wolf and cat: 1 collar when tame (flags bit 4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NOW                 BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-MARK                BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ASSET               BINARY-LONG.
 01 WS-FK                  PIC X(24).
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
             IF L-N >= 5 AND L-N <= 8 AND EN-BABY(L-ROW) = 0
                 EVALUATE L-N
                     WHEN 5 MOVE 2 TO WS-WANT
                     WHEN 6 MOVE 3 TO WS-WANT
                     WHEN 7 MOVE 4 TO WS-WANT
                     WHEN OTHER MOVE 1 TO WS-WANT
                 END-EVALUATE
*>               Equipment slot ordinal 2 feet, 3 legs, 4 chest, 5 head: EN-EQ index ordinal + 1; the item's own slot must be the slot drawn.
                 COMPUTE WS-ITEM = EN-EQ(L-ROW, 7 - WS-WANT)
                 IF WS-ITEM > 0
                     CALL "ENTITY-ARMOR-ASSET" USING CLIENT-STATE WS-ITEM WS-SLOT WS-ASSET
                     IF WS-SLOT = WS-WANT
                         COMPUTE L-CODE = 6000 + WS-ASSET
                         EVALUATE WS-WANT
                             WHEN 1 MOVE "armor_head" TO WS-FK
                             WHEN 2 MOVE "armor_chest" TO WS-FK
                             WHEN 3 MOVE "armor_legs" TO WS-FK
                             WHEN OTHER MOVE "armor_feet" TO WS-FK
                         END-EVALUATE
                         CALL "ENTITY-MODEL-FIND" USING WS-FK L-MODEL
                     END-IF
                 END-IF
             END-IF
         WHEN OTHER
             CONTINUE
     END-EVALUATE
*>   The tint of the layer: ENTITY-TINT reads the layer in EN-OVL.
     MOVE 1 TO L-RED L-GREEN L-BLUE
     IF L-CODE > 0
         MOVE EN-OVL(L-ROW) TO WS-NOW
         MOVE L-CODE TO EN-OVL(L-ROW)
         CALL "ENTITY-TINT" USING CLIENT-STATE L-ROW EN-MODEL(L-ROW) L-RED L-GREEN L-BLUE
         MOVE WS-NOW TO EN-OVL(L-ROW)
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
