*> Entity models part 6: EF6-LAYER model layer(X(32), the ModelLayers field name in upper case) ok(out): builds the model of a layer of 34-6 (ok 0 when the layer is not one of this document). Records: client/copy/CLEMM.cpy.
*> The mesh programs EF6-M-<name> are in client/src/entmodel-34-6-<n>.cob.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-LAYER.
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
         WHEN "CREEPER"
             CALL "EF6-M-CREEPER" USING EMM-MODEL
         WHEN "CREEPER_ARMOR"
             CALL "EF6-M-CREEPER-ARMOR" USING EMM-MODEL
         WHEN "ENDERMAN"
             CALL "EF6-M-ENDERMAN" USING EMM-MODEL
         WHEN "ENDERMITE"
             CALL "EF6-M-ENDERMITE" USING EMM-MODEL
         WHEN "SILVERFISH"
             CALL "EF6-M-SILVERFISH" USING EMM-MODEL
         WHEN "SPIDER"
             CALL "EF6-M-SPIDER" USING EMM-MODEL
         WHEN "CAVE_SPIDER"
             CALL "EF6-M-SPIDER" USING EMM-MODEL
             MOVE 0.7 TO WS-S
             CALL "EMD-SCALE-ROOT" USING EMM-MODEL WS-S
         WHEN "SLIME"
             CALL "EF6-M-SLIME" USING EMM-MODEL
         WHEN "SLIME_OUTER"
             CALL "EF6-M-SLIME-OUTER" USING EMM-MODEL
         WHEN "MAGMA_CUBE"
             CALL "EF6-M-MAGMA-CUBE" USING EMM-MODEL
         WHEN "SULFUR_CUBE"
             CALL "EF6-M-SULFUR-CUBE" USING EMM-MODEL
         WHEN "SULFUR_CUBE_INNER"
             CALL "EF6-M-SULFUR-CUBE-INNER" USING EMM-MODEL
         WHEN "SULFUR_CUBE_SMALL"
             CALL "EF6-M-SULFUR-CUBE-SMALL" USING EMM-MODEL
         WHEN "SULFUR_CUBE_SMALL_INNER"
             CALL "EF6-M-SULFUR-CUBE-SMALL-INNER" USING EMM-MODEL
         WHEN "WARDEN"
             CALL "EF6-M-WARDEN" USING EMM-MODEL
         WHEN "WARDEN_BIOLUMINESCENT"
             CALL "EF6-M-WARDEN" USING EMM-MODEL
             MOVE "head" TO WS-NM(1)
             MOVE "left_arm" TO WS-NM(2)
             MOVE "right_arm" TO WS-NM(3)
             MOVE "left_leg" TO WS-NM(4)
             MOVE "right_leg" TO WS-NM(5)
             MOVE 5 TO WS-CNT
             MOVE 1 TO WS-MODE
             CALL "EF6-RETAIN" USING EMM-MODEL WS-MODE WS-NAMES WS-CNT
         WHEN "WARDEN_PULSATING_SPOTS"
             CALL "EF6-M-WARDEN" USING EMM-MODEL
             MOVE "body" TO WS-NM(1)
             MOVE "head" TO WS-NM(2)
             MOVE "left_arm" TO WS-NM(3)
             MOVE "right_arm" TO WS-NM(4)
             MOVE "left_leg" TO WS-NM(5)
             MOVE "right_leg" TO WS-NM(6)
             MOVE 6 TO WS-CNT
             MOVE 1 TO WS-MODE
             CALL "EF6-RETAIN" USING EMM-MODEL WS-MODE WS-NAMES WS-CNT
         WHEN "WARDEN_TENDRILS"
             CALL "EF6-M-WARDEN" USING EMM-MODEL
             MOVE "left_tendril" TO WS-NM(1)
             MOVE "right_tendril" TO WS-NM(2)
             MOVE 2 TO WS-CNT
             MOVE 1 TO WS-MODE
             CALL "EF6-RETAIN" USING EMM-MODEL WS-MODE WS-NAMES WS-CNT
         WHEN "WARDEN_HEART"
             CALL "EF6-M-WARDEN" USING EMM-MODEL
             MOVE "body" TO WS-NM(1)
             MOVE 1 TO WS-CNT
             MOVE 1 TO WS-MODE
             CALL "EF6-RETAIN" USING EMM-MODEL WS-MODE WS-NAMES WS-CNT
         WHEN "BREEZE"
             CALL "EF6-M-BREEZE-BASE" USING EMM-MODEL
             MOVE "head" TO WS-NM(1)
             MOVE "rods" TO WS-NM(2)
             MOVE 2 TO WS-CNT
             MOVE 2 TO WS-MODE
             CALL "EF6-RETAIN" USING EMM-MODEL WS-MODE WS-NAMES WS-CNT
         WHEN "BREEZE_WIND"
             CALL "EF6-M-BREEZE-BASE" USING EMM-MODEL
             MOVE 128 TO MM-TEXW
             MOVE 128 TO MM-TEXH
             MOVE "wind_body" TO WS-NM(1)
             MOVE 1 TO WS-CNT
             MOVE 2 TO WS-MODE
             CALL "EF6-RETAIN" USING EMM-MODEL WS-MODE WS-NAMES WS-CNT
         WHEN "BREEZE_EYES"
             CALL "EF6-M-BREEZE-BASE" USING EMM-MODEL
             MOVE "eyes" TO WS-NM(1)
             MOVE 1 TO WS-CNT
             MOVE 2 TO WS-MODE
             CALL "EF6-RETAIN" USING EMM-MODEL WS-MODE WS-NAMES WS-CNT
         WHEN "PHANTOM"
             CALL "EF6-M-PHANTOM" USING EMM-MODEL
         WHEN "GUARDIAN"
             CALL "EF6-M-GUARDIAN" USING EMM-MODEL
         WHEN "ELDER_GUARDIAN"
             CALL "EF6-M-GUARDIAN" USING EMM-MODEL
             MOVE 2.35 TO WS-S
             CALL "EMD-SCALE-ROOT" USING EMM-MODEL WS-S
         WHEN OTHER
             MOVE 0 TO L-OK
     END-EVALUATE
     GOBACK.
 END PROGRAM EF6-LAYER.
