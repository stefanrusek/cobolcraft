*> The look of an item stack from its components, for the drawing (lane itemcomp, T9611): STACK-LOOK USING PB-ITEMSTACK-X, dye out, glint out, potion out.
*>   dye: the RGB of dyed_color (47: an Int, the low 24 bits), -1 when the patch has none (43 section 7: the tint source dye); glint: 1 when enchantments (13) or stored_enchantments (45)
*>   list at least one enchantment, or enchantment_glint_override (21) is true; an override of false ends the glint (17 section 1.2); potion: the registry id of potion_contents (53), -1 when
*>   the stack names none. A component the patch removes is as absent.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STACK-LOOK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-OVERRIDE            BINARY-LONG.
 01 WS-SHIFT               BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-REMOVED             BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-DYE                  BINARY-LONG.
 01 L-GLINT                BINARY-LONG.
 01 L-POTION               BINARY-LONG.
 PROCEDURE DIVISION USING PB-ITEMSTACK-X L-DYE L-GLINT L-POTION.
     MOVE -1 TO L-DYE L-POTION
     MOVE 0 TO L-GLINT
     MOVE -1 TO WS-OVERRIDE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-ISX-ADDED-COUNT
         EVALUATE PB-ISX-TYPE(WS-I)
             WHEN 13 WHEN 45
                 IF PB-ISX-VALUE-LENGTH(WS-I) > 0 AND FUNCTION ORD(PB-ISX-VALUE(WS-I)(1:1)) > 1
                     MOVE 1 TO L-GLINT
                 END-IF
             WHEN 21
                 COMPUTE WS-OVERRIDE = FUNCTION ORD(PB-ISX-VALUE(WS-I)(1:1)) - 1
             WHEN 47
                 COMPUTE L-DYE = FUNCTION MOD(FUNCTION ORD(PB-ISX-VALUE(WS-I)(2:1)) - 1, 256) * 65536
                     + FUNCTION MOD(FUNCTION ORD(PB-ISX-VALUE(WS-I)(3:1)) - 1, 256) * 256
                     + FUNCTION MOD(FUNCTION ORD(PB-ISX-VALUE(WS-I)(4:1)) - 1, 256)
             WHEN 53
                 IF FUNCTION ORD(PB-ISX-VALUE(WS-I)(1:1)) = 2
                     MOVE 1 TO WS-SHIFT
                     MOVE 0 TO WS-DONE L-POTION
                     PERFORM VARYING WS-K FROM 2 BY 1 UNTIL WS-K > 5 OR WS-DONE = 1
                         COMPUTE WS-BYTE = FUNCTION ORD(PB-ISX-VALUE(WS-I)(WS-K:1)) - 1
                         COMPUTE L-POTION = L-POTION + FUNCTION MOD(WS-BYTE, 128) * WS-SHIFT
                         COMPUTE WS-SHIFT = WS-SHIFT * 128
                         IF WS-BYTE < 128
                             MOVE 1 TO WS-DONE
                         END-IF
                     END-PERFORM
                 END-IF
         END-EVALUATE
     END-PERFORM
     IF WS-OVERRIDE = 1
         MOVE 1 TO L-GLINT
     END-IF
     IF WS-OVERRIDE = 0
         MOVE 0 TO L-GLINT
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-ISX-REMOVED-COUNT
         MOVE PB-ISX-REMOVED(WS-I) TO WS-REMOVED
         IF WS-REMOVED = 47
             MOVE -1 TO L-DYE
         END-IF
         IF WS-REMOVED = 53
             MOVE -1 TO L-POTION
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STACK-LOOK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STACK-TINT.
*> USING PB-ITEMSTACK-X, dye out, potion out: the dye colour (dyed_color 47, the RGB) and the potion (potion_contents 53, the potion id) of STACK-LOOK, each plus 1 so that 0 means the stack has
*> none: the form the player slots keep them in (PL-STACK-DYE and PL-STACK-POTION of CLSTATE; the icon's tint sources of 43 section 7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DYE                 BINARY-LONG.
 01 WS-GLINT               BINARY-LONG.
 01 WS-POTION              BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-DYE                  BINARY-LONG.
 01 L-POTION               BINARY-LONG.
 PROCEDURE DIVISION USING PB-ITEMSTACK-X L-DYE L-POTION.
     CALL "STACK-LOOK" USING PB-ITEMSTACK-X WS-DYE WS-GLINT WS-POTION
     COMPUTE L-DYE = WS-DYE + 1
     COMPUTE L-POTION = WS-POTION + 1
     GOBACK.
 END PROGRAM STACK-TINT.
