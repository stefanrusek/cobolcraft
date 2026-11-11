*> Entity models part 6 section 14 (render types and pipelines used by this part): the facts read for each render type and the renderers that use it.
*> Entry points for the integrator (inputs; strings are X(32) type name and X(24) lower case entity type):
*>   EF6-RENDER-TYPE type(X(32), e.g. entityCutout, entityTranslucent, eyes, entityTranslucentEmissive, energySwirl, breezeWind, outline, entityCutoutZOffset) OUT(64 FLOAT-LONG: 1 found, 2 alpha cutout, 3 blend 1 TRANSLUCENT 2 ADDITIVE, 4 culling 0 off,
*>   5 depth compare 0 default 1 GREATER_THAN_OR_EQUAL, 6 depth writes, 7 per-face lighting 1 yes 0 NO_CARDINAL_LIGHTING, 8 offset texture transform, 9 sort on upload; -1 where the document does not state the fact);
*>   EF6-RENDER-TYPE-USED type(X(32)) entity(X(24)) OUT(1 when the renderer of the entity uses the type).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-RENDER-TYPE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 PIC X(32).
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-TYPE L-OUT.
     MOVE 0 TO L-O(1)
     EVALUATE L-TYPE
         WHEN "entityCutout"
             MOVE 1 TO L-O(1)
             MOVE 0.1 TO L-O(2)
             MOVE -1 TO L-O(3)
             MOVE 0 TO L-O(4)
             MOVE -1 TO L-O(5)
             MOVE -1 TO L-O(6)
             MOVE 1 TO L-O(7)
             MOVE -1 TO L-O(8)
             MOVE -1 TO L-O(9)
         WHEN "entityCutoutZOffset"
             MOVE 1 TO L-O(1)
             MOVE -1 TO L-O(2)
             MOVE -1 TO L-O(3)
             MOVE -1 TO L-O(4)
             MOVE -1 TO L-O(5)
             MOVE -1 TO L-O(6)
             MOVE -1 TO L-O(7)
             MOVE -1 TO L-O(8)
             MOVE -1 TO L-O(9)
         WHEN "entityTranslucent"
             MOVE 1 TO L-O(1)
             MOVE 0.1 TO L-O(2)
             MOVE 1 TO L-O(3)
             MOVE 0 TO L-O(4)
             MOVE -1 TO L-O(5)
             MOVE -1 TO L-O(6)
             MOVE 1 TO L-O(7)
             MOVE -1 TO L-O(8)
             MOVE -1 TO L-O(9)
         WHEN "eyes"
             MOVE 1 TO L-O(1)
             MOVE -1 TO L-O(2)
             MOVE 1 TO L-O(3)
             MOVE -1 TO L-O(4)
             MOVE 1 TO L-O(5)
             MOVE 0 TO L-O(6)
             MOVE -1 TO L-O(7)
             MOVE -1 TO L-O(8)
             MOVE -1 TO L-O(9)
         WHEN "entityTranslucentEmissive"
             MOVE 1 TO L-O(1)
             MOVE 0.1 TO L-O(2)
             MOVE 1 TO L-O(3)
             MOVE 0 TO L-O(4)
             MOVE 1 TO L-O(5)
             MOVE 0 TO L-O(6)
             MOVE 1 TO L-O(7)
             MOVE -1 TO L-O(8)
             MOVE -1 TO L-O(9)
         WHEN "energySwirl"
             MOVE 1 TO L-O(1)
             MOVE -1 TO L-O(2)
             MOVE 2 TO L-O(3)
             MOVE -1 TO L-O(4)
             MOVE 0 TO L-O(5)
             MOVE 1 TO L-O(6)
             MOVE -1 TO L-O(7)
             MOVE 1 TO L-O(8)
             MOVE 1 TO L-O(9)
         WHEN "breezeWind"
             MOVE 1 TO L-O(1)
             MOVE 0.1 TO L-O(2)
             MOVE 1 TO L-O(3)
             MOVE 0 TO L-O(4)
             MOVE -1 TO L-O(5)
             MOVE -1 TO L-O(6)
             MOVE 0 TO L-O(7)
             MOVE 1 TO L-O(8)
             MOVE 1 TO L-O(9)
         WHEN "outline"
             MOVE 1 TO L-O(1)
             MOVE -1 TO L-O(2)
             MOVE -1 TO L-O(3)
             MOVE -1 TO L-O(4)
             MOVE -1 TO L-O(5)
             MOVE -1 TO L-O(6)
             MOVE -1 TO L-O(7)
             MOVE -1 TO L-O(8)
             MOVE -1 TO L-O(9)
     END-EVALUATE
     GOBACK.
 END PROGRAM EF6-RENDER-TYPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-RENDER-TYPE-USED.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 PIC X(32).
 01 L-ENTITY               PIC X(24).
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-TYPE L-ENTITY L-OUT.
     MOVE 0 TO L-O(1)
     EVALUATE L-TYPE
         WHEN "entityCutout"
             EVALUATE L-ENTITY
                 WHEN "creeper"
                 WHEN "enderman"
                 WHEN "silverfish"
                 WHEN "endermite"
                 WHEN "spider"
                 WHEN "slime"
                 WHEN "magma_cube"
                 WHEN "warden"
                 WHEN "shulker_bullet"
                 WHEN "guardian"
                     MOVE 1 TO L-O(1)
             END-EVALUATE
         WHEN "entityCutoutZOffset"
             EVALUATE L-ENTITY
                 WHEN "shulker"
                     MOVE 1 TO L-O(1)
             END-EVALUATE
         WHEN "entityTranslucent"
             EVALUATE L-ENTITY
                 WHEN "breeze"
                 WHEN "slime"
                 WHEN "sulfur_cube"
                 WHEN "elder_guardian"
                 WHEN "shulker_bullet"
                     MOVE 1 TO L-O(1)
             END-EVALUATE
         WHEN "eyes"
             EVALUATE L-ENTITY
                 WHEN "spider"
                 WHEN "enderman"
                 WHEN "phantom"
                     MOVE 1 TO L-O(1)
             END-EVALUATE
         WHEN "entityTranslucentEmissive"
             EVALUATE L-ENTITY
                 WHEN "warden"
                 WHEN "breeze"
                     MOVE 1 TO L-O(1)
             END-EVALUATE
         WHEN "energySwirl"
             EVALUATE L-ENTITY
                 WHEN "creeper"
                     MOVE 1 TO L-O(1)
             END-EVALUATE
         WHEN "breezeWind"
             EVALUATE L-ENTITY
                 WHEN "breeze"
                     MOVE 1 TO L-O(1)
             END-EVALUATE
         WHEN "outline"
             EVALUATE L-ENTITY
                 WHEN "slime"
                     MOVE 1 TO L-O(1)
             END-EVALUATE
     END-EVALUATE
     GOBACK.
 END PROGRAM EF6-RENDER-TYPE-USED.
