from mesh4 import *
t=mk(4,6,["Acceptance test of docs/protocol/34-entity-models-4-farm-animals-equines.md section 6 (Chicken): 6.1 the model pair by model type, the flap interpolation, the null variant rule, 6.2 setupAnim (leg swings, wing flap, head turn for the",
 "adult and cold chicken only), 6.3 the geometry of chicken, cold_chicken and chicken_baby. Mesh rows are the tables of the document; formula values were worked by an independent script."],ck=True)
IDS=['CHICKEN','COLD_CHICKEN','CHICKEN_BABY']
mesh_checks(t,IDS,'6.3')
for typ,baby,exp in (('normal',0,'CHICKEN'),('normal',1,'CHICKEN_BABY'),('cold',0,'COLD_CHICKEN'),('cold',1,'CHICKEN_BABY')):
    t.raw('MOVE "chicken" TO WS-X24','MOVE "%s" TO WS-X40'%typ,'MOVE %d TO WS-FL'%baby,'CALL "EF4-VARIANT-MODEL" USING WS-X24 WS-X40 WS-FL WS-X32')
    t.text('6.1 chicken model type %s baby %d'%(typ,baby),exp,'WS-X32')
t.call('EF4-VARIANT-TEXTURE',[1,1],[0],'6.1 null variant: missing texture')
for pt,o,n in ((0.25,1,3),(0.5,0,2),(1,4,6.5),(0.75,2,2)):
    t.call('EF4-CHICKEN-FLAP',[pt,o,n],[o+pt*(n-o)],'6.1 flap lerp partial %s from %s to %s'%(pt,o,n))
for lay in IDS:
    for (pitch,yaw,p,s,fl,fs) in ((10,-20,1.2,0.5,0.7,0.9),(0,0,0,0,0,0),(-30,45,5.5,1,2.2,0.3)):
        t.raw('MOVE "%s" TO WS-LAYER'%lay,'CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.setin([pitch,yaw,p,s,fl,fs]); t.raw('CALL "EF4-CHICKEN-ANIM" USING EMM-MODEL WS-IN')
        w=(math.sin(fl)+1)*fs
        pre='6.2 %s pos %s flap %s '%(lay,p,fl)
        vals=[('right_leg','xrot',math.cos(0.6662*p)*1.4*s),('left_leg','xrot',math.cos(0.6662*p+math.pi)*1.4*s),('right_wing','zrot',w),('left_wing','zrot',-w)]
        if lay!='CHICKEN_BABY': vals+=[('head','xrot',pitch*D),('head','yrot',yaw*D)]
        for part,f,v in vals:
            t.raw('MOVE "%s" TO WS-PN'%part,'CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P'); t.num(pre+part+'.'+f,v,'MM-C%s(WS-P)'%f.upper())
    t.raw('MOVE "head" TO WS-PN','CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P')
    t.num('6.2 %s has a head part (the baby has none)'%lay,0 if lay=='CHICKEN_BABY' else 1,'FUNCTION MIN(WS-P, 1)')
save(t,4,6)
