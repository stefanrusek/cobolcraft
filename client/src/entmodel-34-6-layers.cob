*> Entity models part 6: EF6-LAYER model layer(X(32), the ModelLayers field name in upper case) ok(out): builds the model of a layer of 34-6 (ok 0 when the layer is not one of this document). Records: client/copy/CLEMM.cpy.
*> The mesh programs EF6-M-<name> are in client/src/entmodel-34-6-<n>.cob.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-LAYER.
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
         WHEN "CREEPER"
             CALL "EF6-M-CREEPER" USING EMM-MODEL
         WHEN "CREEPER_ARMOR"
             CALL "EF6-M-CREEPER-ARMOR" USING EMM-MODEL
         WHEN "ENDERMAN"
             CALL "EF6-M-ENDERMAN" USING EMM-MODEL
         WHEN OTHER
             MOVE 0 TO L-OK
     END-EVALUATE
     GOBACK.
 END PROGRAM EF6-LAYER.
