*> Entity models part 4: EF4-LAYER model layer(X(32), the ModelLayers field name in upper case) ok(out): builds the model of a layer of 34-4 (the scaled layers carry the MeshTransformer.scaling steps of the document);
*> ok 0 when the layer is not one of this document. Records: client/copy/CLEMM.cpy. The mesh programs EF4-M-<name> are in client/src/entmodel-34-4-<n>.cob.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-LAYER.
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
         WHEN "COW"
             CALL "EF4-M-COW" USING EMM-MODEL
         WHEN "COLD_COW"
             CALL "EF4-M-COLD-COW" USING EMM-MODEL
         WHEN "WARM_COW"
             CALL "EF4-M-WARM-COW" USING EMM-MODEL
         WHEN "COW_BABY"
             CALL "EF4-M-COW-BABY" USING EMM-MODEL
         WHEN "MOOSHROOM"
             CALL "EF4-M-COW" USING EMM-MODEL
         WHEN "MOOSHROOM_BABY"
             CALL "EF4-M-COW-BABY" USING EMM-MODEL
         WHEN "WARM_COW_BABY"
             CALL "EF4-M-COW-BABY" USING EMM-MODEL
         WHEN "COLD_COW_BABY"
             CALL "EF4-M-COW-BABY" USING EMM-MODEL
         WHEN "PIG"
             CALL "EF4-M-PIG" USING EMM-MODEL
         WHEN "PIG_SADDLE"
             CALL "EF4-M-PIG-SADDLE" USING EMM-MODEL
         WHEN "COLD_PIG"
             CALL "EF4-M-COLD-PIG" USING EMM-MODEL
         WHEN "PIG_BABY"
             CALL "EF4-M-PIG-BABY" USING EMM-MODEL
         WHEN "SHEEP"
             CALL "EF4-M-SHEEP" USING EMM-MODEL
         WHEN "SHEEP_WOOL"
             CALL "EF4-M-SHEEP-WOOL" USING EMM-MODEL
         WHEN "SHEEP_BABY"
             CALL "EF4-M-SHEEP-BABY" USING EMM-MODEL
         WHEN "SHEEP_WOOL_UNDERCOAT"
             CALL "EF4-M-SHEEP" USING EMM-MODEL
         WHEN "SHEEP_BABY_WOOL"
             CALL "EF4-M-SHEEP-BABY" USING EMM-MODEL
         WHEN OTHER
             MOVE 0 TO L-OK
     END-EVALUATE
     GOBACK.
 END PROGRAM EF4-LAYER.
