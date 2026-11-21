*> Entity models part 6 (docs/protocol/34-entity-models-6-overworld-hostiles-arthropods-slimes.md): overworld hostiles, arthropods and slimes. Section 1 here (shared facts, 1.1 to 1.3); the models in client/src/entmodel-34-6-<n>.cob.
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF6-BOX-UNWRAP IN(u v w h d) OUT(u0 u1 u2 u3 u4 v0 v1 v2): the face rectangle coordinates of 1.1; EF6-SCALED-Y IN(s, y) OUT(24.016 x (1 - s) + s x y): a vertex after MeshTransformer.scaling(s); EF6-DEG-TO-RAD IN(degrees) OUT(radians, x 0.017453292);
*>   EF6-RETAIN EMM-MODEL mode(BINARY-LONG 1 retainExactParts, 2 retainPartsAndChildren) names(8 X(24)) count(BINARY-LONG): clears the cuboids of the parts the rule does not keep (part cuboids MM-NCUBES = 0);
*>   EF6-INFO entity(X(24), lower case type) OUT(64 FLOAT-LONG: 1 found, 2 texture width, 3 height, 4 shadow radius, 5 flip degrees, 6 layers added, 7 baby texture width, 8 baby texture height) main-layer(X(32), out): the table of 1.3;
*>   EF6-INFO-LAYER entity(X(24)) index(BINARY-LONG, 1-based) name(X(32), out; spaces past the end): the layer classes added after the main model, in order.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-BOX-UNWRAP.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-I(1) TO L-O(1)
     COMPUTE L-O(2) = L-I(1) + L-I(5)
     COMPUTE L-O(3) = L-I(1) + L-I(5) + L-I(3)
     COMPUTE L-O(4) = L-I(1) + 2 * L-I(5) + L-I(3)
     COMPUTE L-O(5) = L-I(1) + 2 * L-I(5) + 2 * L-I(3)
     MOVE L-I(2) TO L-O(6)
     COMPUTE L-O(7) = L-I(2) + L-I(5)
     COMPUTE L-O(8) = L-I(2) + L-I(5) + L-I(4)
     GOBACK.
 END PROGRAM EF6-BOX-UNWRAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-SCALED-Y.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = 24.016 * (1 - L-I(1)) + L-I(1) * L-I(2)
     GOBACK.
 END PROGRAM EF6-SCALED-Y.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-DEG-TO-RAD.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = L-I(1) * 0.017453292
     GOBACK.
 END PROGRAM EF6-DEG-TO-RAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-RETAIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-SELF                BINARY-LONG.
 01 WS-ANC                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-MODE                 BINARY-LONG.
 01 L-NAMES.
    05 L-NAME              PIC X(24) OCCURS 8 TIMES.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING EMM-MODEL L-MODE L-NAMES L-COUNT.
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > MM-COUNT
         MOVE 0 TO WS-SELF WS-ANC
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > L-COUNT
             IF MM-NAME(WS-I) = L-NAME(WS-K)
                 MOVE 1 TO WS-SELF
             END-IF
         END-PERFORM
         MOVE MM-PARENT(WS-I) TO WS-A
         PERFORM UNTIL WS-A < 2
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > L-COUNT
                 IF MM-NAME(WS-A) = L-NAME(WS-K)
                     MOVE 1 TO WS-ANC
                 END-IF
             END-PERFORM
             MOVE MM-PARENT(WS-A) TO WS-A
         END-PERFORM
         IF L-MODE = 1
             IF WS-SELF = 0 OR WS-ANC = 1
                 MOVE 0 TO MM-NCUBES(WS-I)
             END-IF
         ELSE
             IF WS-SELF = 0 AND WS-ANC = 0
                 MOVE 0 TO MM-NCUBES(WS-I)
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EF6-RETAIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-INFO.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ENTITY               PIC X(24).
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 01 L-MAIN                 PIC X(32).
 PROCEDURE DIVISION USING L-ENTITY L-OUT L-MAIN.
     MOVE SPACES TO L-MAIN
     MOVE 0 TO L-O(1) L-O(2) L-O(3) L-O(4) L-O(5) L-O(6) L-O(7) L-O(8)
     EVALUATE L-ENTITY
         WHEN "creeper"
             MOVE "CREEPER" TO L-MAIN
             MOVE 1 TO L-O(1)
             MOVE 64 TO L-O(2)
             MOVE 32 TO L-O(3)
             MOVE 0.5 TO L-O(4)
             MOVE 90 TO L-O(5)
             MOVE 1 TO L-O(6)
             MOVE 64 TO L-O(7)
             MOVE 32 TO L-O(8)
         WHEN "enderman"
             MOVE "ENDERMAN" TO L-MAIN
             MOVE 1 TO L-O(1)
             MOVE 64 TO L-O(2)
             MOVE 32 TO L-O(3)
             MOVE 0.5 TO L-O(4)
             MOVE 90 TO L-O(5)
             MOVE 2 TO L-O(6)
             MOVE 64 TO L-O(7)
             MOVE 32 TO L-O(8)
         WHEN "endermite"
             MOVE "ENDERMITE" TO L-MAIN
             MOVE 1 TO L-O(1)
             MOVE 64 TO L-O(2)
             MOVE 32 TO L-O(3)
             MOVE 0.3 TO L-O(4)
             MOVE 180 TO L-O(5)
             MOVE 0 TO L-O(6)
             MOVE 64 TO L-O(7)
             MOVE 32 TO L-O(8)
         WHEN "silverfish"
             MOVE "SILVERFISH" TO L-MAIN
             MOVE 1 TO L-O(1)
             MOVE 64 TO L-O(2)
             MOVE 32 TO L-O(3)
             MOVE 0.3 TO L-O(4)
             MOVE 180 TO L-O(5)
             MOVE 0 TO L-O(6)
             MOVE 64 TO L-O(7)
             MOVE 32 TO L-O(8)
         WHEN "spider"
             MOVE "SPIDER" TO L-MAIN
             MOVE 1 TO L-O(1)
             MOVE 64 TO L-O(2)
             MOVE 32 TO L-O(3)
             MOVE 0.8 TO L-O(4)
             MOVE 180 TO L-O(5)
             MOVE 1 TO L-O(6)
             MOVE 64 TO L-O(7)
             MOVE 32 TO L-O(8)
         WHEN "cave_spider"
             MOVE "CAVE_SPIDER" TO L-MAIN
             MOVE 1 TO L-O(1)
             MOVE 64 TO L-O(2)
             MOVE 32 TO L-O(3)
             MOVE 0.56 TO L-O(4)
             MOVE 180 TO L-O(5)
             MOVE 1 TO L-O(6)
             MOVE 64 TO L-O(7)
             MOVE 32 TO L-O(8)
         WHEN "slime"
             MOVE "SLIME" TO L-MAIN
             MOVE 1 TO L-O(1)
             MOVE 64 TO L-O(2)
             MOVE 32 TO L-O(3)
             MOVE 0.25 TO L-O(4)
             MOVE 90 TO L-O(5)
             MOVE 1 TO L-O(6)
             MOVE 64 TO L-O(7)
             MOVE 32 TO L-O(8)
         WHEN "magma_cube"
             MOVE "MAGMA_CUBE" TO L-MAIN
             MOVE 1 TO L-O(1)
             MOVE 64 TO L-O(2)
             MOVE 64 TO L-O(3)
             MOVE 0.25 TO L-O(4)
             MOVE 90 TO L-O(5)
             MOVE 0 TO L-O(6)
             MOVE 64 TO L-O(7)
             MOVE 64 TO L-O(8)
         WHEN "sulfur_cube"
             MOVE "SULFUR_CUBE" TO L-MAIN
             MOVE 1 TO L-O(1)
             MOVE 128 TO L-O(2)
             MOVE 128 TO L-O(3)
             MOVE 0.25 TO L-O(4)
             MOVE 90 TO L-O(5)
             MOVE 2 TO L-O(6)
             MOVE 64 TO L-O(7)
             MOVE 64 TO L-O(8)
         WHEN "warden"
             MOVE "WARDEN" TO L-MAIN
             MOVE 1 TO L-O(1)
             MOVE 128 TO L-O(2)
             MOVE 128 TO L-O(3)
             MOVE 0.9 TO L-O(4)
             MOVE 90 TO L-O(5)
             MOVE 5 TO L-O(6)
             MOVE 128 TO L-O(7)
             MOVE 128 TO L-O(8)
         WHEN "breeze"
             MOVE "BREEZE" TO L-MAIN
             MOVE 1 TO L-O(1)
             MOVE 32 TO L-O(2)
             MOVE 32 TO L-O(3)
             MOVE 0.5 TO L-O(4)
             MOVE 90 TO L-O(5)
             MOVE 2 TO L-O(6)
             MOVE 32 TO L-O(7)
             MOVE 32 TO L-O(8)
         WHEN "phantom"
             MOVE "PHANTOM" TO L-MAIN
             MOVE 1 TO L-O(1)
             MOVE 64 TO L-O(2)
             MOVE 64 TO L-O(3)
             MOVE 0.75 TO L-O(4)
             MOVE 90 TO L-O(5)
             MOVE 1 TO L-O(6)
             MOVE 64 TO L-O(7)
             MOVE 64 TO L-O(8)
         WHEN "guardian"
             MOVE "GUARDIAN" TO L-MAIN
             MOVE 1 TO L-O(1)
             MOVE 64 TO L-O(2)
             MOVE 64 TO L-O(3)
             MOVE 0.5 TO L-O(4)
             MOVE 90 TO L-O(5)
             MOVE 0 TO L-O(6)
             MOVE 64 TO L-O(7)
             MOVE 64 TO L-O(8)
         WHEN "elder_guardian"
             MOVE "ELDER_GUARDIAN" TO L-MAIN
             MOVE 1 TO L-O(1)
             MOVE 64 TO L-O(2)
             MOVE 64 TO L-O(3)
             MOVE 1.2 TO L-O(4)
             MOVE 90 TO L-O(5)
             MOVE 0 TO L-O(6)
             MOVE 64 TO L-O(7)
             MOVE 64 TO L-O(8)
         WHEN "shulker"
             MOVE "SHULKER" TO L-MAIN
             MOVE 1 TO L-O(1)
             MOVE 64 TO L-O(2)
             MOVE 64 TO L-O(3)
             MOVE 0 TO L-O(4)
             MOVE 90 TO L-O(5)
             MOVE 0 TO L-O(6)
             MOVE 64 TO L-O(7)
             MOVE 64 TO L-O(8)
         WHEN "shulker_bullet"
             MOVE "SHULKER_BULLET" TO L-MAIN
             MOVE 1 TO L-O(1)
             MOVE 64 TO L-O(2)
             MOVE 32 TO L-O(3)
             MOVE 0 TO L-O(4)
             MOVE 0 TO L-O(5)
             MOVE 0 TO L-O(6)
             MOVE 64 TO L-O(7)
             MOVE 32 TO L-O(8)
     END-EVALUATE
     GOBACK.
 END PROGRAM EF6-INFO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-INFO-LAYER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ENTITY               PIC X(24).
 01 L-INDEX                BINARY-LONG.
 01 L-LAYER-NAME           PIC X(32).
 PROCEDURE DIVISION USING L-ENTITY L-INDEX L-LAYER-NAME.
     MOVE SPACES TO L-LAYER-NAME
     EVALUATE L-ENTITY
         WHEN "creeper"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "CreeperPowerLayer" TO L-LAYER-NAME
             END-EVALUATE
         WHEN "enderman"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "EnderEyesLayer" TO L-LAYER-NAME
                 WHEN 2
                     MOVE "CarriedBlockLayer" TO L-LAYER-NAME
             END-EVALUATE
         WHEN "spider"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "SpiderEyesLayer" TO L-LAYER-NAME
             END-EVALUATE
         WHEN "cave_spider"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "SpiderEyesLayer" TO L-LAYER-NAME
             END-EVALUATE
         WHEN "slime"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "SlimeOuterLayer" TO L-LAYER-NAME
             END-EVALUATE
         WHEN "sulfur_cube"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "SulfurCubeInnerLayer" TO L-LAYER-NAME
                 WHEN 2
                     MOVE "CustomHeadLayer" TO L-LAYER-NAME
             END-EVALUATE
         WHEN "warden"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "LivingEntityEmissiveLayer" TO L-LAYER-NAME
                 WHEN 2
                     MOVE "LivingEntityEmissiveLayer" TO L-LAYER-NAME
                 WHEN 3
                     MOVE "LivingEntityEmissiveLayer" TO L-LAYER-NAME
                 WHEN 4
                     MOVE "LivingEntityEmissiveLayer" TO L-LAYER-NAME
                 WHEN 5
                     MOVE "LivingEntityEmissiveLayer" TO L-LAYER-NAME
             END-EVALUATE
         WHEN "breeze"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "BreezeWindLayer" TO L-LAYER-NAME
                 WHEN 2
                     MOVE "BreezeEyesLayer" TO L-LAYER-NAME
             END-EVALUATE
         WHEN "phantom"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "PhantomEyesLayer" TO L-LAYER-NAME
             END-EVALUATE
     END-EVALUATE
     GOBACK.
 END PROGRAM EF6-INFO-LAYER.
