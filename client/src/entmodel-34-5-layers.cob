*> Entity models part 5: EF5-LAYER model layer(X(32), the ModelLayers field name in upper case) ok(out): builds the model of a layer of 34-5 (ok 0 when the layer is not one of this document). Records: client/copy/CLEMM.cpy.
*> The mesh programs EF5-M-<name> are in client/src/entmodel-34-5-<n>.cob.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-LAYER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-S                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-LAYER                PIC X(32).
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING EMM-MODEL L-LAYER L-OK.
     MOVE 1 TO L-OK
     EVALUATE L-LAYER
         WHEN "WOLF"
             CALL "EF5-M-WOLF" USING EMM-MODEL
         WHEN "WOLF_ARMOR"
             CALL "EF5-M-WOLF-ARMOR" USING EMM-MODEL
         WHEN "WOLF_BABY"
             CALL "EF5-M-WOLF-BABY" USING EMM-MODEL
         WHEN "OCELOT"
             CALL "EF5-M-OCELOT" USING EMM-MODEL
         WHEN "CAT"
             CALL "EF5-M-CAT" USING EMM-MODEL
             MOVE 0.8 TO WS-S
             CALL "EMD-SCALE-ROOT" USING EMM-MODEL WS-S
         WHEN "CAT_COLLAR"
             CALL "EF5-M-CAT-COLLAR" USING EMM-MODEL
             MOVE 0.8 TO WS-S
             CALL "EMD-SCALE-ROOT" USING EMM-MODEL WS-S
         WHEN "OCELOT_BABY"
             CALL "EF5-M-OCELOT-BABY" USING EMM-MODEL
         WHEN "CAT_BABY"
             CALL "EF5-M-CAT-BABY" USING EMM-MODEL
         WHEN "CAT_BABY_COLLAR"
             CALL "EF5-M-CAT-BABY-COLLAR" USING EMM-MODEL
             MOVE 1.01 TO WS-S
             CALL "EMD-SCALE-ROOT" USING EMM-MODEL WS-S
         WHEN OTHER
             MOVE 0 TO L-OK
     END-EVALUATE
     GOBACK.
 END PROGRAM EF5-LAYER.
