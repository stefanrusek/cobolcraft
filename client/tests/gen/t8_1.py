from mesh8 import *
from fam8 import *
t=mk(8,1,["Acceptance test of docs/protocol/34-entity-models-8-aquatic-nautilus-boats.md section 1 (family overview): 1.1 the entity type table (base shadow radius, the model layers baked), 1.2 the texture paths including the axolotl variants, the tropical fish bases and the 11 boat woods,",
 "1.3 hitbox, eye height and name tag height, and the baby rule (the baby model only; the age scale reaches the shadow)."],ck=False)
t.extra_ws+='\n 01 WS-X60               PIC X(60).'
for e,sh,lay,hb in ENT:
    t.raw('MOVE "%s" TO WS-X24'%e,'CALL "EF8-ENTITY" USING WS-X24 WS-OUT')
    t.num('1.1 %s found'%e,1,'WS-OV(1)'); t.num('1.1 %s base shadow radius (-1 computed from the puff state)'%e,sh,'WS-OV(2)'); t.num('1.1 %s model layers'%e,len(lay),'WS-OV(3)')
    for i,l in enumerate(lay,1):
        t.raw('MOVE "%s" TO WS-X24'%e,'MOVE %d TO WS-FL'%i,'CALL "EF8-ENTITY-LAYER" USING WS-X24 WS-FL WS-X32'); t.text('1.1 %s layer %d'%(e,i),l,'WS-X32')
    t.call('EF8-HITBOX-DUMMY',[],[0],'') if False else None
    t.raw('MOVE "%s" TO WS-X24'%e,'CALL "EF8-HITBOX" USING WS-X24 WS-OUT')
    t.num('1.3 %s hitbox width'%e,hb[0],'WS-OV(1)'); t.num('1.3 %s hitbox height'%e,hb[1],'WS-OV(2)'); t.num('1.3 %s eye height'%e,hb[2],'WS-OV(3)'); t.num('1.3 %s name tag height (the box height)'%e,hb[1],'WS-OV(4)')
t.raw('MOVE "creeper" TO WS-X24','CALL "EF8-ENTITY" USING WS-X24 WS-OUT'); t.num('1.1 an entity of another part is not found',0,'WS-OV(1)')
t.raw('MOVE "squid" TO WS-X24','MOVE 9 TO WS-FL','MOVE "x" TO WS-X32','CALL "EF8-ENTITY-LAYER" USING WS-X24 WS-FL WS-X32'); t.text('1.1 a layer past the end is blank','','WS-X32')
for e,ks in TEX:
    for k,p in ks:
        t.raw('MOVE "%s" TO WS-X24'%e,'MOVE %d TO WS-FL'%k,'MOVE SPACES TO WS-X60','CALL "EF8-TEXTURE" USING WS-X24 WS-FL WS-X60'); t.text('1.2 %s texture kind %d'%(e,k),p,'WS-X60')
for i,v in list(enumerate(VARIANTS,1))+[(9,'lucy')]:
    for baby in (0,1):
        t.raw('MOVE %d TO WS-IV(1)'%i,'MOVE %d TO WS-IV(2)'%baby,'MOVE SPACES TO WS-X60','CALL "EF8-AXOLOTL-TEXTURE" USING WS-IN WS-X60'); t.text('1.2 axolotl variant %s baby %d'%(v,baby),'axolotl/axolotl_%s%s.png'%(v,'_baby' if baby else ''),'WS-X60')
for w in WOODS:
    for ch in (0,1):
        t.raw('MOVE "%s" TO WS-X24'%w,'MOVE %d TO WS-FL'%ch,'MOVE SPACES TO WS-X60','CALL "EF8-BOAT-TEXTURE" USING WS-X24 WS-FL WS-X60'); t.text('1.2 boat %s chest %d'%(w,ch),'%s/%s.png'%('chest_boat' if ch else 'boat',w),'WS-X60')
for b,sc,ag,e in ((0,1,1,0.7),(1,1,0.5,0.35),(1,2,0.5,0.7)):
    t.call('EF8-BABY-SHADOW',[0.7,sc,ag,b],[e if b else 0.7*sc*ag if False else 0.7*sc],'1.3 shadow radius base 0.7 scale %s ageScale %s baby %d (only the age scale differs)'%(sc,ag,b))
save(t,8,1)
