*> Acceptance test of docs/protocol/34-entity-models-6-overworld-hostiles-arthropods-slimes.md section 14 (render types and pipelines): for each of the eight render types the pipeline facts read (alpha cutout, blend, culling, depth compare and writes,
*> per-face lighting, texture offset transform, sort on upload), -1 where the document says the fact was not traced, and the renderers that use each type.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-6-14.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLEMM.
 COPY TESTLIB.
 01 WS-NAME                PIC X(160).
 01 WS-E                   FLOAT-LONG.
 01 WS-O                   FLOAT-LONG.
 01 WS-IN.
    05 WS-IV                FLOAT-LONG OCCURS 32 TIMES.
 01 WS-OUT.
    05 WS-OV                FLOAT-LONG OCCURS 64 TIMES.

 01 WS-X32               PIC X(32).
 01 WS-X32B              PIC X(32).
 01 WS-X120              PIC X(120).
 01 WS-X24               PIC X(24).
 01 WS-X40               PIC X(40).
 01 WS-FL                BINARY-LONG.
 01 WS-NAME2              PIC X(32).
 PROCEDURE DIVISION.
     MOVE "entityCutout" TO WS-X32
     CALL "EF6-RENDER-TYPE" USING WS-X32 WS-OUT
     MOVE "14 entityCutout found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 entityCutout alpha cutout (-1 not stated)" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 entityCutout blend (1 TRANSLUCENT 2 ADDITIVE, -1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 entityCutout culling (0 off, -1 not stated)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 entityCutout depth compare (0 default 1 GREATER_THAN_OR_EQUAL, -1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 entityCutout depth writes (0 off 1 on, -1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 entityCutout per-face lighting (1 yes 0 NO_CARDINAL_LIGHTING, -1 not stated)" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 entityCutout offset texture transform (-1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 entityCutout sort on upload (-1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityCutoutZOffset" TO WS-X32
     CALL "EF6-RENDER-TYPE" USING WS-X32 WS-OUT
     MOVE "14 entityCutoutZOffset found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 entityCutoutZOffset alpha cutout (-1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 entityCutoutZOffset blend (1 TRANSLUCENT 2 ADDITIVE, -1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 entityCutoutZOffset culling (0 off, -1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 entityCutoutZOffset depth compare (0 default 1 GREATER_THAN_OR_EQUAL, -1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 entityCutoutZOffset depth writes (0 off 1 on, -1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 entityCutoutZOffset per-face lighting (1 yes 0 NO_CARDINAL_LIGHTING, -1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 entityCutoutZOffset offset texture transform (-1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 entityCutoutZOffset sort on upload (-1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityTranslucent" TO WS-X32
     CALL "EF6-RENDER-TYPE" USING WS-X32 WS-OUT
     MOVE "14 entityTranslucent found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 entityTranslucent alpha cutout (-1 not stated)" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 entityTranslucent blend (1 TRANSLUCENT 2 ADDITIVE, -1 not stated)" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 entityTranslucent culling (0 off, -1 not stated)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 entityTranslucent depth compare (0 default 1 GREATER_THAN_OR_EQUAL, -1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 entityTranslucent depth writes (0 off 1 on, -1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 entityTranslucent per-face lighting (1 yes 0 NO_CARDINAL_LIGHTING, -1 not stated)" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 entityTranslucent offset texture transform (-1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 entityTranslucent sort on upload (-1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "eyes" TO WS-X32
     CALL "EF6-RENDER-TYPE" USING WS-X32 WS-OUT
     MOVE "14 eyes found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 eyes alpha cutout (-1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 eyes blend (1 TRANSLUCENT 2 ADDITIVE, -1 not stated)" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 eyes culling (0 off, -1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 eyes depth compare (0 default 1 GREATER_THAN_OR_EQUAL, -1 not stated)" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 eyes depth writes (0 off 1 on, -1 not stated)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 eyes per-face lighting (1 yes 0 NO_CARDINAL_LIGHTING, -1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 eyes offset texture transform (-1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 eyes sort on upload (-1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityTranslucentEmissive" TO WS-X32
     CALL "EF6-RENDER-TYPE" USING WS-X32 WS-OUT
     MOVE "14 entityTranslucentEmissive found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 entityTranslucentEmissive alpha cutout (-1 not stated)" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 entityTranslucentEmissive blend (1 TRANSLUCENT 2 ADDITIVE, -1 not stated)" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 entityTranslucentEmissive culling (0 off, -1 not stated)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 entityTranslucentEmissive depth compare (0 default 1 GREATER_THAN_OR_EQUAL, -1 not stated)" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 entityTranslucentEmissive depth writes (0 off 1 on, -1 not stated)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 entityTranslucentEmissive per-face lighting (1 yes 0 NO_CARDINAL_LIGHTING, -1 not stated)" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 entityTranslucentEmissive offset texture transform (-1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 entityTranslucentEmissive sort on upload (-1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "energySwirl" TO WS-X32
     CALL "EF6-RENDER-TYPE" USING WS-X32 WS-OUT
     MOVE "14 energySwirl found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 energySwirl alpha cutout (-1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 energySwirl blend (1 TRANSLUCENT 2 ADDITIVE, -1 not stated)" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 energySwirl culling (0 off, -1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 energySwirl depth compare (0 default 1 GREATER_THAN_OR_EQUAL, -1 not stated)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 energySwirl depth writes (0 off 1 on, -1 not stated)" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 energySwirl per-face lighting (1 yes 0 NO_CARDINAL_LIGHTING, -1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 energySwirl offset texture transform (-1 not stated)" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 energySwirl sort on upload (-1 not stated)" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "breezeWind" TO WS-X32
     CALL "EF6-RENDER-TYPE" USING WS-X32 WS-OUT
     MOVE "14 breezeWind found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 breezeWind alpha cutout (-1 not stated)" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 breezeWind blend (1 TRANSLUCENT 2 ADDITIVE, -1 not stated)" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 breezeWind culling (0 off, -1 not stated)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 breezeWind depth compare (0 default 1 GREATER_THAN_OR_EQUAL, -1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 breezeWind depth writes (0 off 1 on, -1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 breezeWind per-face lighting (1 yes 0 NO_CARDINAL_LIGHTING, -1 not stated)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 breezeWind offset texture transform (-1 not stated)" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 breezeWind sort on upload (-1 not stated)" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "outline" TO WS-X32
     CALL "EF6-RENDER-TYPE" USING WS-X32 WS-OUT
     MOVE "14 outline found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 outline alpha cutout (-1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 outline blend (1 TRANSLUCENT 2 ADDITIVE, -1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 outline culling (0 off, -1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 outline depth compare (0 default 1 GREATER_THAN_OR_EQUAL, -1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 outline depth writes (0 off 1 on, -1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 outline per-face lighting (1 yes 0 NO_CARDINAL_LIGHTING, -1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 outline offset texture transform (-1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 outline sort on upload (-1 not stated)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "noSuchType" TO WS-X32
     CALL "EF6-RENDER-TYPE" USING WS-X32 WS-OUT
     MOVE "14 an unknown render type is not found" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityCutout" TO WS-X32
     MOVE "creeper" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityCutout used by creeper" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityCutout" TO WS-X32
     MOVE "enderman" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityCutout used by enderman" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityCutout" TO WS-X32
     MOVE "silverfish" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityCutout used by silverfish" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityCutout" TO WS-X32
     MOVE "endermite" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityCutout used by endermite" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityCutout" TO WS-X32
     MOVE "spider" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityCutout used by spider" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityCutout" TO WS-X32
     MOVE "slime" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityCutout used by slime" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityCutout" TO WS-X32
     MOVE "magma_cube" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityCutout used by magma_cube" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityCutout" TO WS-X32
     MOVE "warden" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityCutout used by warden" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityCutout" TO WS-X32
     MOVE "shulker_bullet" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityCutout used by shulker_bullet" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityCutout" TO WS-X32
     MOVE "guardian" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityCutout used by guardian" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityCutout" TO WS-X32
     MOVE "shulker" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityCutout used by shulker" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityCutout" TO WS-X32
     MOVE "breeze" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityCutout used by breeze" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityCutout" TO WS-X32
     MOVE "sulfur_cube" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityCutout used by sulfur_cube" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityCutout" TO WS-X32
     MOVE "elder_guardian" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityCutout used by elder_guardian" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityCutout" TO WS-X32
     MOVE "phantom" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityCutout used by phantom" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityCutout" TO WS-X32
     MOVE "cave_spider" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityCutout used by cave_spider" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityCutoutZOffset" TO WS-X32
     MOVE "creeper" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityCutoutZOffset used by creeper" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityCutoutZOffset" TO WS-X32
     MOVE "enderman" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityCutoutZOffset used by enderman" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityCutoutZOffset" TO WS-X32
     MOVE "silverfish" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityCutoutZOffset used by silverfish" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityCutoutZOffset" TO WS-X32
     MOVE "endermite" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityCutoutZOffset used by endermite" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityCutoutZOffset" TO WS-X32
     MOVE "spider" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityCutoutZOffset used by spider" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityCutoutZOffset" TO WS-X32
     MOVE "slime" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityCutoutZOffset used by slime" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityCutoutZOffset" TO WS-X32
     MOVE "magma_cube" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityCutoutZOffset used by magma_cube" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityCutoutZOffset" TO WS-X32
     MOVE "warden" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityCutoutZOffset used by warden" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityCutoutZOffset" TO WS-X32
     MOVE "shulker_bullet" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityCutoutZOffset used by shulker_bullet" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityCutoutZOffset" TO WS-X32
     MOVE "guardian" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityCutoutZOffset used by guardian" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityCutoutZOffset" TO WS-X32
     MOVE "shulker" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityCutoutZOffset used by shulker" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityCutoutZOffset" TO WS-X32
     MOVE "breeze" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityCutoutZOffset used by breeze" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityCutoutZOffset" TO WS-X32
     MOVE "sulfur_cube" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityCutoutZOffset used by sulfur_cube" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityCutoutZOffset" TO WS-X32
     MOVE "elder_guardian" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityCutoutZOffset used by elder_guardian" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityCutoutZOffset" TO WS-X32
     MOVE "phantom" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityCutoutZOffset used by phantom" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityCutoutZOffset" TO WS-X32
     MOVE "cave_spider" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityCutoutZOffset used by cave_spider" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityTranslucent" TO WS-X32
     MOVE "creeper" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityTranslucent used by creeper" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityTranslucent" TO WS-X32
     MOVE "enderman" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityTranslucent used by enderman" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityTranslucent" TO WS-X32
     MOVE "silverfish" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityTranslucent used by silverfish" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityTranslucent" TO WS-X32
     MOVE "endermite" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityTranslucent used by endermite" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityTranslucent" TO WS-X32
     MOVE "spider" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityTranslucent used by spider" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityTranslucent" TO WS-X32
     MOVE "slime" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityTranslucent used by slime" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityTranslucent" TO WS-X32
     MOVE "magma_cube" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityTranslucent used by magma_cube" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityTranslucent" TO WS-X32
     MOVE "warden" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityTranslucent used by warden" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityTranslucent" TO WS-X32
     MOVE "shulker_bullet" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityTranslucent used by shulker_bullet" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityTranslucent" TO WS-X32
     MOVE "guardian" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityTranslucent used by guardian" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityTranslucent" TO WS-X32
     MOVE "shulker" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityTranslucent used by shulker" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityTranslucent" TO WS-X32
     MOVE "breeze" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityTranslucent used by breeze" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityTranslucent" TO WS-X32
     MOVE "sulfur_cube" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityTranslucent used by sulfur_cube" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityTranslucent" TO WS-X32
     MOVE "elder_guardian" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityTranslucent used by elder_guardian" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityTranslucent" TO WS-X32
     MOVE "phantom" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityTranslucent used by phantom" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityTranslucent" TO WS-X32
     MOVE "cave_spider" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityTranslucent used by cave_spider" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "eyes" TO WS-X32
     MOVE "creeper" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 eyes used by creeper" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "eyes" TO WS-X32
     MOVE "enderman" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 eyes used by enderman" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "eyes" TO WS-X32
     MOVE "silverfish" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 eyes used by silverfish" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "eyes" TO WS-X32
     MOVE "endermite" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 eyes used by endermite" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "eyes" TO WS-X32
     MOVE "spider" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 eyes used by spider" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "eyes" TO WS-X32
     MOVE "slime" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 eyes used by slime" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "eyes" TO WS-X32
     MOVE "magma_cube" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 eyes used by magma_cube" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "eyes" TO WS-X32
     MOVE "warden" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 eyes used by warden" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "eyes" TO WS-X32
     MOVE "shulker_bullet" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 eyes used by shulker_bullet" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "eyes" TO WS-X32
     MOVE "guardian" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 eyes used by guardian" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "eyes" TO WS-X32
     MOVE "shulker" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 eyes used by shulker" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "eyes" TO WS-X32
     MOVE "breeze" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 eyes used by breeze" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "eyes" TO WS-X32
     MOVE "sulfur_cube" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 eyes used by sulfur_cube" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "eyes" TO WS-X32
     MOVE "elder_guardian" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 eyes used by elder_guardian" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "eyes" TO WS-X32
     MOVE "phantom" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 eyes used by phantom" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "eyes" TO WS-X32
     MOVE "cave_spider" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 eyes used by cave_spider" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityTranslucentEmissive" TO WS-X32
     MOVE "creeper" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityTranslucentEmissive used by creeper" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityTranslucentEmissive" TO WS-X32
     MOVE "enderman" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityTranslucentEmissive used by enderman" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityTranslucentEmissive" TO WS-X32
     MOVE "silverfish" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityTranslucentEmissive used by silverfish" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityTranslucentEmissive" TO WS-X32
     MOVE "endermite" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityTranslucentEmissive used by endermite" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityTranslucentEmissive" TO WS-X32
     MOVE "spider" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityTranslucentEmissive used by spider" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityTranslucentEmissive" TO WS-X32
     MOVE "slime" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityTranslucentEmissive used by slime" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityTranslucentEmissive" TO WS-X32
     MOVE "magma_cube" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityTranslucentEmissive used by magma_cube" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityTranslucentEmissive" TO WS-X32
     MOVE "warden" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityTranslucentEmissive used by warden" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityTranslucentEmissive" TO WS-X32
     MOVE "shulker_bullet" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityTranslucentEmissive used by shulker_bullet" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityTranslucentEmissive" TO WS-X32
     MOVE "guardian" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityTranslucentEmissive used by guardian" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityTranslucentEmissive" TO WS-X32
     MOVE "shulker" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityTranslucentEmissive used by shulker" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityTranslucentEmissive" TO WS-X32
     MOVE "breeze" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityTranslucentEmissive used by breeze" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityTranslucentEmissive" TO WS-X32
     MOVE "sulfur_cube" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityTranslucentEmissive used by sulfur_cube" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityTranslucentEmissive" TO WS-X32
     MOVE "elder_guardian" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityTranslucentEmissive used by elder_guardian" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityTranslucentEmissive" TO WS-X32
     MOVE "phantom" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityTranslucentEmissive used by phantom" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "entityTranslucentEmissive" TO WS-X32
     MOVE "cave_spider" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 entityTranslucentEmissive used by cave_spider" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "energySwirl" TO WS-X32
     MOVE "creeper" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 energySwirl used by creeper" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "energySwirl" TO WS-X32
     MOVE "enderman" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 energySwirl used by enderman" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "energySwirl" TO WS-X32
     MOVE "silverfish" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 energySwirl used by silverfish" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "energySwirl" TO WS-X32
     MOVE "endermite" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 energySwirl used by endermite" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "energySwirl" TO WS-X32
     MOVE "spider" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 energySwirl used by spider" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "energySwirl" TO WS-X32
     MOVE "slime" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 energySwirl used by slime" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "energySwirl" TO WS-X32
     MOVE "magma_cube" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 energySwirl used by magma_cube" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "energySwirl" TO WS-X32
     MOVE "warden" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 energySwirl used by warden" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "energySwirl" TO WS-X32
     MOVE "shulker_bullet" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 energySwirl used by shulker_bullet" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "energySwirl" TO WS-X32
     MOVE "guardian" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 energySwirl used by guardian" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "energySwirl" TO WS-X32
     MOVE "shulker" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 energySwirl used by shulker" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "energySwirl" TO WS-X32
     MOVE "breeze" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 energySwirl used by breeze" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "energySwirl" TO WS-X32
     MOVE "sulfur_cube" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 energySwirl used by sulfur_cube" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "energySwirl" TO WS-X32
     MOVE "elder_guardian" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 energySwirl used by elder_guardian" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "energySwirl" TO WS-X32
     MOVE "phantom" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 energySwirl used by phantom" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "energySwirl" TO WS-X32
     MOVE "cave_spider" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 energySwirl used by cave_spider" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "breezeWind" TO WS-X32
     MOVE "creeper" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 breezeWind used by creeper" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "breezeWind" TO WS-X32
     MOVE "enderman" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 breezeWind used by enderman" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "breezeWind" TO WS-X32
     MOVE "silverfish" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 breezeWind used by silverfish" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "breezeWind" TO WS-X32
     MOVE "endermite" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 breezeWind used by endermite" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "breezeWind" TO WS-X32
     MOVE "spider" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 breezeWind used by spider" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "breezeWind" TO WS-X32
     MOVE "slime" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 breezeWind used by slime" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "breezeWind" TO WS-X32
     MOVE "magma_cube" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 breezeWind used by magma_cube" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "breezeWind" TO WS-X32
     MOVE "warden" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 breezeWind used by warden" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "breezeWind" TO WS-X32
     MOVE "shulker_bullet" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 breezeWind used by shulker_bullet" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "breezeWind" TO WS-X32
     MOVE "guardian" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 breezeWind used by guardian" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "breezeWind" TO WS-X32
     MOVE "shulker" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 breezeWind used by shulker" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "breezeWind" TO WS-X32
     MOVE "breeze" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 breezeWind used by breeze" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "breezeWind" TO WS-X32
     MOVE "sulfur_cube" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 breezeWind used by sulfur_cube" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "breezeWind" TO WS-X32
     MOVE "elder_guardian" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 breezeWind used by elder_guardian" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "breezeWind" TO WS-X32
     MOVE "phantom" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 breezeWind used by phantom" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "breezeWind" TO WS-X32
     MOVE "cave_spider" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 breezeWind used by cave_spider" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "outline" TO WS-X32
     MOVE "creeper" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 outline used by creeper" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "outline" TO WS-X32
     MOVE "enderman" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 outline used by enderman" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "outline" TO WS-X32
     MOVE "silverfish" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 outline used by silverfish" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "outline" TO WS-X32
     MOVE "endermite" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 outline used by endermite" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "outline" TO WS-X32
     MOVE "spider" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 outline used by spider" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "outline" TO WS-X32
     MOVE "slime" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 outline used by slime" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "outline" TO WS-X32
     MOVE "magma_cube" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 outline used by magma_cube" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "outline" TO WS-X32
     MOVE "warden" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 outline used by warden" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "outline" TO WS-X32
     MOVE "shulker_bullet" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 outline used by shulker_bullet" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "outline" TO WS-X32
     MOVE "guardian" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 outline used by guardian" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "outline" TO WS-X32
     MOVE "shulker" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 outline used by shulker" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "outline" TO WS-X32
     MOVE "breeze" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 outline used by breeze" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "outline" TO WS-X32
     MOVE "sulfur_cube" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 outline used by sulfur_cube" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "outline" TO WS-X32
     MOVE "elder_guardian" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 outline used by elder_guardian" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "outline" TO WS-X32
     MOVE "phantom" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 outline used by phantom" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "outline" TO WS-X32
     MOVE "cave_spider" TO WS-X24
     CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT
     MOVE "14 outline used by cave_spider" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-6§14 Render types and pipelines used by this part: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-6§14 Render types and pipelines used by this part: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-6-14.
