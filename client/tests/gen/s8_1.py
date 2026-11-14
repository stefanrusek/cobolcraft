from mesh8 import *
from prog6 import *
from fam8 import *
hdr='''*> Entity models part 8 section 1 (family overview): the entity type table (1.1), the texture file rules (1.2), hitbox, eye height, name tag height and the baby rule (1.3).
*> Entry points for the integrator (inputs; strings are X(24) lower case entity type, boats are "boat" and "raft", texture paths are relative to textures/entity/):
*>   EF8-ENTITY entity OUT(64 FLOAT-LONG: 1 found, 2 base shadow radius (-1 for the pufferfish, computed from its puff state), 3 model layers); EF8-ENTITY-LAYER entity index(BINARY-LONG) name(X(32), out; spaces past the end);
*>   EF8-HITBOX entity OUT(width, height, eye height, name tag height = the box height); EF8-TEXTURE entity kind(BINARY-LONG 1 adult or first, 2 baby or second) path(X(60), out); EF8-AXOLOTL-TEXTURE IN(variant 1 lucy 2 wild 3 gold 4 cyan 5 blue, baby) path(X(60), out);
*>   EF8-BOAT-TEXTURE wood(X(24)) chest(BINARY-LONG) path(X(60), out); EF8-BABY-SHADOW IN(base radius, scale, ageScale, baby) OUT(radius): the age scale reaches only the shadow.
'''
def g(x): return '%g'%x
ent='';lay='';hit='';tx=''
for e,sh,ls,hb in ENT:
    ent+='         WHEN "%s"\n             MOVE 1 TO L-O(1)\n             MOVE %s TO L-O(2)\n             MOVE %d TO L-O(3)\n'%(e,g(sh),len(ls))
    hit+='         WHEN "%s"\n             MOVE %s TO L-O(1)\n             MOVE %s TO L-O(2)\n             MOVE %s TO L-O(3)\n             MOVE %s TO L-O(4)\n'%(e,g(hb[0]),g(hb[1]),g(hb[2]),g(hb[1]))
    lay+='         WHEN "%s"\n             EVALUATE L-INDEX\n'%e
    for k,l in enumerate(ls,1): lay+='                 WHEN %d\n                     MOVE "%s" TO L-NAME\n'%(k,l)
    lay+='             END-EVALUATE\n'
for e,ks in TEX:
    tx+='         WHEN "%s"\n             EVALUATE L-KIND\n'%e
    for k,p in ks: tx+='                 WHEN %d\n                     MOVE "%s" TO L-PATH\n'%(k,p)
    tx+='             END-EVALUATE\n'
def mod(name,ws,params,body,call):
    return ' IDENTIFICATION DIVISION.\n PROGRAM-ID. %s.\n DATA DIVISION.\n%s LINKAGE SECTION.\n%s PROCEDURE DIVISION USING %s.\n%s     GOBACK.\n END PROGRAM %s.\n\n'%(name,ws,params,call,body,name)
OUT=' 01 L-OUT.\n    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.\n'
extra=mod('EF8-ENTITY','',' 01 L-ENTITY               PIC X(24).\n'+OUT,'     MOVE 0 TO L-O(1) L-O(2) L-O(3)\n     EVALUATE L-ENTITY\n'+ent+'     END-EVALUATE\n','L-ENTITY L-OUT')
extra+=mod('EF8-ENTITY-LAYER','',' 01 L-ENTITY               PIC X(24).\n 01 L-INDEX                BINARY-LONG.\n 01 L-NAME                 PIC X(32).\n','     MOVE SPACES TO L-NAME\n     EVALUATE L-ENTITY\n'+lay+'     END-EVALUATE\n','L-ENTITY L-INDEX L-NAME')
extra+=mod('EF8-HITBOX','',' 01 L-ENTITY               PIC X(24).\n'+OUT,'     MOVE 0 TO L-O(1) L-O(2) L-O(3) L-O(4)\n     EVALUATE L-ENTITY\n'+hit+'     END-EVALUATE\n','L-ENTITY L-OUT')
extra+=mod('EF8-TEXTURE','',' 01 L-ENTITY               PIC X(24).\n 01 L-KIND                 BINARY-LONG.\n 01 L-PATH                 PIC X(60).\n','     MOVE SPACES TO L-PATH\n     EVALUATE L-ENTITY\n'+tx+'     END-EVALUATE\n','L-ENTITY L-KIND L-PATH')
vs=''.join('         WHEN %d\n             MOVE "%s" TO WS-V\n'%(i,v) for i,v in enumerate(VARIANTS,1))
extra+=mod('EF8-AXOLOTL-TEXTURE',' WORKING-STORAGE SECTION.\n 01 WS-V                   PIC X(8).\n',' 01 L-IN.\n    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.\n 01 L-PATH                 PIC X(60).\n','     MOVE SPACES TO L-PATH WS-V\n     EVALUATE L-I(1)\n'+vs+'         WHEN OTHER\n             MOVE "lucy" TO WS-V\n     END-EVALUATE\n     IF L-I(2) NOT = 0\n         STRING "axolotl/axolotl_" FUNCTION TRIM(WS-V) "_baby.png" DELIMITED BY SIZE INTO L-PATH\n     ELSE\n         STRING "axolotl/axolotl_" FUNCTION TRIM(WS-V) ".png" DELIMITED BY SIZE INTO L-PATH\n     END-IF\n','L-IN L-PATH')
extra+=mod('EF8-BOAT-TEXTURE','',' 01 L-WOOD                 PIC X(24).\n 01 L-CHEST                BINARY-LONG.\n 01 L-PATH                 PIC X(60).\n','     MOVE SPACES TO L-PATH\n     IF L-CHEST NOT = 0\n         STRING "chest_boat/" FUNCTION TRIM(L-WOOD) ".png" DELIMITED BY SIZE INTO L-PATH\n     ELSE\n         STRING "boat/" FUNCTION TRIM(L-WOOD) ".png" DELIMITED BY SIZE INTO L-PATH\n     END-IF\n','L-WOOD L-CHEST L-PATH')
extra+=prog('EF8-BABY-SHADOW','     COMPUTE L-O(1) = L-I(1) * L-I(2)\n     IF L-I(4) NOT = 0\n         COMPUTE L-O(1) = L-O(1) * L-I(3)\n     END-IF\n')
write_section_src(1,hdr,[],extra)
