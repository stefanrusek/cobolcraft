from mesh4 import *
t=mk(4,4,["Acceptance test of docs/protocol/34-entity-models-4-farm-animals-equines.md section 4 (Pig): 4.1 the model pair by model type, the saddle layer (no baby model: a baby pig never shows a saddle), the null variant rule,",
 "setupAnim as the quadruped, 4.2 the geometry of pig, pig_saddle, cold_pig and pig_baby. Mesh rows are the tables of the document; formula values were worked by an independent script."],ck=True)
IDS=['PIG','PIG_SADDLE','COLD_PIG','PIG_BABY']
mesh_checks(t,IDS,'4.2')
for typ,baby,exp in (('normal',0,'PIG'),('normal',1,'PIG_BABY'),('cold',0,'COLD_PIG'),('cold',1,'PIG_BABY')):
    t.raw('MOVE "pig" TO WS-X24','MOVE "%s" TO WS-X40'%typ,'MOVE %d TO WS-FL'%baby,'CALL "EF4-VARIANT-MODEL" USING WS-X24 WS-X40 WS-FL WS-X32')
    t.text('4.1 pig model type %s baby %d'%(typ,baby),exp,'WS-X32')
for baby in (0,1):
    for item in (0,1):
        t.call('EF4-PIG-SADDLE',[item,baby],[1 if (item and not baby) else 0],'4.1 saddle item %d baby %d drawn (pig_saddle layer type, no baby model)'%(item,baby))
t.call('EF4-VARIANT-TEXTURE',[1,0],[0],'4.1 null variant: missing texture')
t.call('EF4-VARIANT-TEXTURE',[0,1],[2],'4.1 baby: the baby texture of the variant')
for lay in IDS:
    for (pitch,yaw,p,s) in ((20,10,1.5,0.5),(-5,-60,9,1)):
        t.raw('MOVE "%s" TO WS-LAYER'%lay,'CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.setin([pitch,yaw,p,s]); t.raw('CALL "EF4-PIG-ANIM" USING EMM-MODEL WS-IN')
        a=math.cos(0.6662*p)*1.4*s; b=math.cos(0.6662*p+math.pi)*1.4*s
        pre='4.1 %s anim pos %s '%(lay,p)
        for part,f,v in (('head','xrot',pitch*D),('head','yrot',yaw*D),('right_hind_leg','xrot',a),('left_hind_leg','xrot',b),('right_front_leg','xrot',b),('left_front_leg','xrot',a)):
            t.raw('MOVE "%s" TO WS-PN'%part,'CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P'); t.num(pre+part+'.'+f,v,'MM-C%s(WS-P)'%f.upper())
save(t,4,4)
