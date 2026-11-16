*> Overlay layers of the mobs: a layer is the model of the mob drawn once more with a texture of its own, slightly larger so that it lies over the body
*> (the opaque entity mesh has no depth test that would let a coplanar layer through, see ENTITY-MODEL-EMIT). Their texture codes (ENTITY-TEX-CODE, ENTITY-TEX-PATH):
*> 1000 + n the type texture of a villager or zombie villager (34-3 1.5, n = type id + 1 in the registry order of 54 section 5; a baby takes the baby folder), 2000 + n its
*> profession texture, 3000 + n its level texture (n = level 1 to 5), 4000 + n the horse's markings (34-4 8.5), 5000 + n the collar of a wolf or cat (34-5 2 and 3,
*> tinted by ENTITY-TINT with the dye of EN-X2).
*> Gap (docs hold no data): the hat value of the villager textures' .mcmeta decides whether the type layer draws the head (34-3 1.5); the replica does not read it
*> and the type layer always draws the whole model.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-OVERLAY.
*> USING CLIENT-STATE, replica row, layer number 1 to 4, code out (BINARY-LONG, 0 when the row has no such layer), red, green, blue out (FLOAT-LONG: the tint of the layer).
*> Villager and zombie villager: 1 type (known data only), 2 profession (not for a baby, id 1 to 14), 3 level (not for a baby, a nitwit or no profession; clamped to 1 to 5).
*> Horse: 1 markings (entry 19 value / 256 of 1 to 4). Wolf and cat: 1 collar when tame (flags bit 4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NOW                 BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-MARK                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-CODE                 BINARY-LONG.
 01 L-RED                  FLOAT-LONG.
 01 L-GREEN                FLOAT-LONG.
 01 L-BLUE                 FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-N L-CODE L-RED L-GREEN L-BLUE.
     MOVE 0 TO L-CODE
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
