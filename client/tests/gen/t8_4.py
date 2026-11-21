from aq8b import *
define_aq()
t=mk(8,4,["Acceptance test of docs/protocol/34-entity-models-8-aquatic-nautilus-boats.md section 4 (axolotl): 4.1 the adult mesh (21 boxes of parts including the six grown boxes G = 0.001), 4.3 the baby mesh (texture 32 x 32, the part root is baby_root here),",
 "4.4 the variant textures (ids 0 to 4, an id outside the range gives lucy). The adult setupAnim and the binary animators (4.2, 4.5) and the seven baby keyframe animations (4.4, Appendix A.1) are proved by test_entmodel_axolotl of lane p70e (T28700, T28701)."],ck=True)
t.LP='EF8-LAYER'
t.extra_ws+='\n 01 WS-X60               PIC X(60).'
mesh_checks(t,['AXOLOTL','AXOLOTL_BABY'],'4')
VARIANTS=['lucy','wild','gold','cyan','blue']
for i,v in list(enumerate(VARIANTS,1))+[(9,'lucy'),(0,'lucy')]:
    for baby in (0,1):
        t.raw('MOVE %d TO WS-IV(1)'%i,'MOVE %d TO WS-IV(2)'%baby,'MOVE SPACES TO WS-X60','CALL "EF8-AXOLOTL-TEXTURE" USING WS-IN WS-X60'); t.text('4.4 variant slot %d baby %d texture'%(i,baby),'axolotl/axolotl_%s%s.png'%(v,'_baby' if baby else ''),'WS-X60')
save(t,8,4)
