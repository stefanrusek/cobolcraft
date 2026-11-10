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
         WHEN OTHER
             MOVE 0 TO L-OK
     END-EVALUATE
     GOBACK.
 END PROGRAM EF4-LAYER.
