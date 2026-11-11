from mesh4 import *
t=mk(4,2,["Acceptance test of docs/protocol/34-entity-models-4-farm-animals-equines.md section 2 (Cow): 2.1 the variant texture rule (null variant, baby texture, adult texture), 2.2 setupAnim (head angles and the four leg swings,",
 "amplitude 1.4, phase 0.6662, the pose reset first), 2.3 the geometry of the layers cow, cold_cow, warm_cow and cow_baby (every part, cuboid, grow and mirror, texture size). Mesh rows are the tables of the document;",
 "formula values were worked by an independent script."],ck=True)
IDS=['COW','COLD_COW','WARM_COW','COW_BABY']
mesh_checks(t,IDS,'2.3')
for nul,baby,e in ((1,0,0),(1,1,0),(0,0,1),(0,1,2)):
    t.call('EF4-VARIANT-TEXTURE',[nul,baby],[e],'2.1 variant null %d baby %d texture (0 missing, 1 adult asset, 2 baby texture)'%(nul,baby))
for lay in IDS:
    for (pitch,yaw,p,s) in ((12,-30,2.5,0.6),(0,0,0,0),(-45,80,7.25,1)):
        t.raw('MOVE "%s" TO WS-LAYER'%lay,'CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK')
        # dirty the pose first: the reset must undo it
        t.raw('MOVE 3 TO MM-CXROT(2)')
        t.setin([pitch,yaw,p,s])
        t.raw('CALL "EF4-COW-ANIM" USING EMM-MODEL WS-IN')
        a=math.cos(0.6662*p)*1.4*s; b=math.cos(0.6662*p+math.pi)*1.4*s
        pre='2.2 %s pitch %s yaw %s pos %s speed %s '%(lay,pitch,yaw,p,s)
        def c(part,f,v): 
            t.raw('MOVE "%s" TO WS-PN'%part,'CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P')
            t.num(pre+part+'.'+f,v,{'xrot':'MM-CXROT','yrot':'MM-CYROT'}[f]+'(WS-P)')
        c('head','xrot',pitch*D); c('head','yrot',yaw*D)
        c('right_hind_leg','xrot',a); c('left_hind_leg','xrot',b); c('right_front_leg','xrot',b); c('left_front_leg','xrot',a)
        c('body','xrot',1.5707964 if lay!='COW_BABY' else 0)
t.raw('MOVE "NOT_A_LAYER" TO WS-LAYER','CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK')
t.num('an unknown layer id is not built (ok 0; coverage-only addition)',0,'WS-OK')
save(t,4,2)
