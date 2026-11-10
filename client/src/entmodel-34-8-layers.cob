*> Entity models part 8: EF8-LAYER model layer(X(32), the ModelLayers field name in upper case) ok(out): builds the model of a layer of 34-8 (ok 0 when the layer is not one of this document). Records: client/copy/CLEMM.cpy.
*> The mesh programs EF8-M-<name> are in client/src/entmodel-34-8-<n>.cob.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-LAYER.
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
         WHEN "SQUID"
             CALL "EF8-M-SQUID" USING EMM-MODEL
         WHEN "SQUID_BABY"
             CALL "EF8-M-SQUID-BABY" USING EMM-MODEL
         WHEN "GLOW_SQUID"
             CALL "EF8-M-SQUID" USING EMM-MODEL
         WHEN "GLOW_SQUID_BABY"
             CALL "EF8-M-SQUID-BABY" USING EMM-MODEL
         WHEN OTHER
             MOVE 0 TO L-OK
     END-EVALUATE
     GOBACK.
 END PROGRAM EF8-LAYER.
