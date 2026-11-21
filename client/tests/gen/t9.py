from mesh4 import *
t=mk(4,9,["Acceptance test of docs/protocol/34-entity-models-4-farm-animals-equines.md section 9 (Llama and trader llama): 9.1 variants (clamping id map), textures, the chest rule, 9.2 setupAnim, 9.3 the decor layer algorithm",
 "(player carpet, trader carpet, nothing; adult and baby decor models), 9.4 the geometry of llama, llama_baby, llama_decor (grow 0.5), llama_baby_decor (grow 0.2) and the trader aliases, 9.5 llama spit (pose operations, texture, mesh).",
 "Mesh rows are the tables of the document; formula values were worked by an independent script."],ck=True)
IDS=['LLAMA','TRADER_LLAMA','LLAMA_BABY','TRADER_LLAMA_BABY','LLAMA_DECOR','LLAMA_BABY_DECOR','LLAMA_SPIT']
mesh_checks(t,IDS,'9.4')
VAR=['creamy','white','brown','gray']
for vid in (0,1,2,3,4,9,-1):
    o=min(3,max(0,vid))
    t.call('EF4-LLAMA-VARIANT',[vid],[o],'9.1 variant id %d clamps'%vid)
for o in range(4):
    for b in (0,1):
        t.raw('MOVE %d TO WS-IV(1)'%o,'MOVE %d TO WS-IV(2)'%b,'CALL "EF4-LLAMA-TEXTURE" USING WS-IN WS-X120')
        t.text('9.1 variant %d baby %d texture'%(o,b),'textures/entity/llama/llama_%s%s.png'%(VAR[o],'_baby' if b else ''),'WS-X120')
for hc in (0,1):
    for b in (0,1): t.call('EF4-LLAMA-CHEST',[hc,b],[1 if (hc and not b) else 0],'9.1 hasChest %d baby %d state chest'%(hc,b))
for item in (0,1):
  for b in (0,1):
    for tr in (0,1):
        if item and not b: m,bm=1,0
        elif tr: m,bm=2,b
        else: m,bm=0,b
        t.call('EF4-LLAMA-DECOR',[item,b,tr],[m,bm if m else 0],'9.3 carpet item %d baby %d trader %d: mode (0 none, 1 the item carpet, 2 trader carpet), baby decor model'%(item,b,tr))
for lay,baby in (('LLAMA',0),('LLAMA_BABY',1),('TRADER_LLAMA',0),('TRADER_LLAMA_BABY',1)):
    for (pitch,yaw,p,s,hc) in ((14,-25,2.1,0.8,1),(0,0,0,0,0),(-33,60,5,0.3,1)):
        t.raw('MOVE "%s" TO WS-LAYER'%lay,'CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.setin([pitch,yaw,p,s,hc]); t.raw('CALL "EF4-LLAMA-ANIM" USING EMM-MODEL WS-IN')
        a=math.cos(0.6662*p)*1.4*s; b=math.cos(0.6662*p+math.pi)*1.4*s
        pre='9.2 %s pos %s chest %d '%(lay,p,hc)
        for part,f,v in (('head','xrot',pitch*D),('head','yrot',yaw*D),('right_hind_leg','xrot',a),('left_hind_leg','xrot',b),('right_front_leg','xrot',b),('left_front_leg','xrot',a)):
            t.raw('MOVE "%s" TO WS-PN'%part,'CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P'); t.num(pre+part+'.'+f,v,'MM-C%s(WS-P)'%f.upper())
        t.vis('right_chest',hc); t.vis('left_chest',hc)
for xr,yr in ((0,90),(25,-30),(-40,10.5)):
    t.call('EF4-SPIT-OPS',[xr,yr],[3, 1,0,0.15,0, 2,yr-90,0,0, 3,xr,0,0],'9.5 spit pose xRot %s yRot %s (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values)'%(xr,yr))
t.raw('CALL "EF4-SPIT-TEXTURE" USING WS-X120'); t.text('9.5 spit texture','textures/entity/llama/llama_spit.png','WS-X120')
save(t,4,9)
