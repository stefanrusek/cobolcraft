from mesh6 import *
from prog6 import *
RT=[('entityCutout',[1,0.1,-1,0,-1,-1,1,-1,-1],['creeper','enderman','silverfish','endermite','spider','slime','magma_cube','warden','shulker_bullet','guardian']),
    ('entityCutoutZOffset',[1,-1,-1,-1,-1,-1,-1,-1,-1],['shulker']),
    ('entityTranslucent',[1,0.1,1,0,-1,-1,1,-1,-1],['breeze','slime','sulfur_cube','elder_guardian','shulker_bullet']),
    ('eyes',[1,-1,1,-1,1,0,-1,-1,-1],['spider','enderman','phantom']),
    ('entityTranslucentEmissive',[1,0.1,1,0,1,0,1,-1,-1],['warden','breeze']),
    ('energySwirl',[1,-1,2,-1,0,1,-1,1,1],['creeper']),
    ('breezeWind',[1,0.1,1,0,-1,-1,0,1,1],['breeze']),
    ('outline',[1,-1,-1,-1,-1,-1,-1,-1,-1],['slime'])]
hdr='''*> Entity models part 6 section 14 (render types and pipelines used by this part): the facts read for each render type and the renderers that use it.
*> Entry points for the integrator (inputs; strings are X(32) type name and X(24) lower case entity type):
*>   EF6-RENDER-TYPE type(X(32), e.g. entityCutout, entityTranslucent, eyes, entityTranslucentEmissive, energySwirl, breezeWind, outline, entityCutoutZOffset) OUT(64 FLOAT-LONG: 1 found, 2 alpha cutout, 3 blend 1 TRANSLUCENT 2 ADDITIVE, 4 culling 0 off,
*>   5 depth compare 0 default 1 GREATER_THAN_OR_EQUAL, 6 depth writes, 7 per-face lighting 1 yes 0 NO_CARDINAL_LIGHTING, 8 offset texture transform, 9 sort on upload; -1 where the document does not state the fact);
*>   EF6-RENDER-TYPE-USED type(X(32)) entity(X(24)) OUT(1 when the renderer of the entity uses the type).
'''
cases='';used=''
for n,v,us in RT:
    cases+='         WHEN "%s"\n'%n
    for k,x in enumerate(v,1): cases+='             MOVE %s TO L-O(%d)\n'%(('%g'%x),k)
    used+='         WHEN "%s"\n             EVALUATE L-ENTITY\n%s                     MOVE 1 TO L-O(1)\n             END-EVALUATE\n'%(n,''.join('                 WHEN "%s"\n'%u for u in us))
body=''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-RENDER-TYPE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 PIC X(32).
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-TYPE L-OUT.
     MOVE 0 TO L-O(1)
     EVALUATE L-TYPE
'''+cases+'''     END-EVALUATE
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
'''+used+'''     END-EVALUATE
     GOBACK.
 END PROGRAM EF6-RENDER-TYPE-USED.
'''
open(REPO+'client/src/entmodel-34-6-14.cob','w').write(hdr+'\n'+body)
