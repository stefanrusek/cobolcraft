*> Entity models part 6: EF7-LAYER model layer(X(32), the ModelLayers field name in upper case) ok(out): builds the model of a layer of 34-7 (ok 0 when the layer is not one of this document). Records: client/copy/CLEMM.cpy.
*> The mesh programs EF7-M-<name> are in client/src/entmodel-34-7-<n>.cob.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-LAYER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-S                   FLOAT-LONG.
 01 WS-MODE                BINARY-LONG.
 01 WS-CNT                 BINARY-LONG.
 01 WS-NAMES.
    05 WS-NM                PIC X(24) OCCURS 8 TIMES.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-LAYER                PIC X(32).
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING EMM-MODEL L-LAYER L-OK.
     MOVE 1 TO L-OK
     EVALUATE L-LAYER
         WHEN "BLAZE"
             CALL "EF7-M-BLAZE" USING EMM-MODEL
         WHEN "GHAST"
             CALL "EF7-M-GHAST" USING EMM-MODEL
             MOVE 4.5 TO WS-S
             CALL "EMD-SCALE-ROOT" USING EMM-MODEL WS-S
         WHEN OTHER
             MOVE 0 TO L-OK
     END-EVALUATE
     GOBACK.
 END PROGRAM EF7-LAYER.
