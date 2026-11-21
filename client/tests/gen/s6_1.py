from mesh6 import *
hdr='''*> Entity models part 6 (docs/protocol/34-entity-models-6-overworld-hostiles-arthropods-slimes.md): overworld hostiles, arthropods and slimes. Section 1 here (shared facts, 1.1 to 1.3); the models in client/src/entmodel-34-6-<n>.cob.
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF6-BOX-UNWRAP IN(u v w h d) OUT(u0 u1 u2 u3 u4 v0 v1 v2): the face rectangle coordinates of 1.1; EF6-SCALED-Y IN(s, y) OUT(24.016 x (1 - s) + s x y): a vertex after MeshTransformer.scaling(s); EF6-DEG-TO-RAD IN(degrees) OUT(radians, x 0.017453292);
*>   EF6-RETAIN EMM-MODEL mode(BINARY-LONG 1 retainExactParts, 2 retainPartsAndChildren) names(8 X(24)) count(BINARY-LONG): clears the cuboids of the parts the rule does not keep (part cuboids MM-NCUBES = 0);
*>   EF6-INFO entity(X(24), lower case type) OUT(64 FLOAT-LONG: 1 found, 2 texture width, 3 height, 4 shadow radius, 5 flip degrees, 6 layers added, 7 baby texture width, 8 baby texture height) main-layer(X(32), out): the table of 1.3;
*>   EF6-INFO-LAYER entity(X(24)) index(BINARY-LONG, 1-based) name(X(32), out; spaces past the end): the layer classes added after the main model, in order.
'''
SUM=[('creeper','CREEPER',64,32,0.5,90,['CreeperPowerLayer']),('enderman','ENDERMAN',64,32,0.5,90,['EnderEyesLayer','CarriedBlockLayer']),('endermite','ENDERMITE',64,32,0.3,180,[]),
 ('silverfish','SILVERFISH',64,32,0.3,180,[]),('spider','SPIDER',64,32,0.8,180,['SpiderEyesLayer']),('cave_spider','CAVE_SPIDER',64,32,0.56,180,['SpiderEyesLayer']),
 ('slime','SLIME',64,32,0.25,90,['SlimeOuterLayer']),('magma_cube','MAGMA_CUBE',64,64,0.25,90,[]),('sulfur_cube','SULFUR_CUBE',128,128,0.25,90,['SulfurCubeInnerLayer','CustomHeadLayer']),
 ('warden','WARDEN',128,128,0.9,90,['LivingEntityEmissiveLayer']*5),('breeze','BREEZE',32,32,0.5,90,['BreezeWindLayer','BreezeEyesLayer']),('phantom','PHANTOM',64,64,0.75,90,['PhantomEyesLayer']),
 ('guardian','GUARDIAN',64,64,0.5,90,[]),('elder_guardian','ELDER_GUARDIAN',64,64,1.2,90,[]),('shulker','SHULKER',64,64,0,90,[]),('shulker_bullet','SHULKER_BULLET',64,32,0,0,[])]
def lit_(x): return lit(x) if not isinstance(x,int) else str(x)
info='';lay=''
for ent,layer,w,h,sh,fl,lays in SUM:
    bw,bh=(64,64) if ent=='sulfur_cube' else (w,h)
    info+='         WHEN "%s"\n             MOVE "%s" TO L-MAIN\n             MOVE 1 TO L-O(1)\n             MOVE %d TO L-O(2)\n             MOVE %d TO L-O(3)\n             MOVE %s TO L-O(4)\n             MOVE %d TO L-O(5)\n             MOVE %d TO L-O(6)\n             MOVE %d TO L-O(7)\n             MOVE %d TO L-O(8)\n'%(ent,layer,w,h,lit_(sh),fl,len(lays),bw,bh)
    if lays:
        lay+='         WHEN "%s"\n             EVALUATE L-INDEX\n'%ent
        for k,l in enumerate(lays,1): lay+='                 WHEN %d\n                     MOVE "%s" TO L-LAYER-NAME\n'%(k,l)
        lay+='             END-EVALUATE\n'
body=r''' IDENTIFICATION DIVISION.
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
'''+info+r'''     END-EVALUATE
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
'''+lay+r'''     END-EVALUATE
     GOBACK.
 END PROGRAM EF6-INFO-LAYER.
'''
open(REPO+'client/src/entmodel-34-6.cob','w').write(hdr+'\n'+body)
