from mesh4 import *
t=mk(4,11,["Acceptance test of docs/protocol/34-entity-models-4-farm-animals-equines.md section 11 (Happy ghast): 11.1 textures, the culling box, the ropes layer condition, 11.2 setupAnim (tentacle swing, the harness body scale, the goggles of",
 "the harness model), 11.3 the geometry of happy_ghast, happy_ghast_baby, the two harness layers and the two ropes layers with the scalings of the document (4; 4 and 0.2375; 4, 0.2375 and 0.2375). Mesh rows are the tables of the",
 "document; formula values were worked by an independent script. A part's local value written by the code (body scale, goggles height) is carried through the layer scaling as in 34-4 8.3."],ck=True)
IDS=['HAPPY_GHAST','HAPPY_GHAST_BABY','HAPPY_GHAST_HARNESS','HAPPY_GHAST_BABY_HARNESS','HAPPY_GHAST_ROPES','HAPPY_GHAST_BABY_ROPES']
mesh_checks(t,IDS,'11.3')
for b,p in ((0,'textures/entity/ghast/happy_ghast.png'),(1,'textures/entity/ghast/happy_ghast_baby.png')):
    t.raw('MOVE %d TO WS-IV(1)'%b,'CALL "EF4-GHAST-TEXTURE" USING WS-IN WS-X120'); t.text('11.1 texture baby %d'%b,p,'WS-X120')
t.raw('CALL "EF4-ROPES-TEXTURE" USING WS-X120'); t.text('11.1 ropes texture','textures/entity/ghast/happy_ghast_ropes.png','WS-X120')
for my,h in ((64,4),(0,2.5),(-3.5,1.5)): t.call('EF4-GHAST-CULL',[my,h],[my-h/2],'11.1 culling box minimum y %s height %s lowered by half the height'%(my,h))
for lh in (0,1):
    for hv in (0,1): t.call('EF4-ROPES-DRAW',[lh,hv],[1 if (lh and hv) else 0],'11.1 ropes: leash holder %d, body item in the harnesses tag %d'%(lh,hv))
for lay in ('HAPPY_GHAST','HAPPY_GHAST_BABY','HAPPY_GHAST_ROPES','HAPPY_GHAST_BABY_ROPES'):
    rows=expected(lay)[0]
    bs=[float(x) for x in [r for r in rows if r.startswith('P body ')][0].split()[9:12]]
    for age in (0,10,37.5):
        for item in (0,1):
            t.raw('MOVE "%s" TO WS-LAYER'%lay,'CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.setin([age,item]); t.raw('CALL "EF4-GHAST-ANIM" USING EMM-MODEL WS-IN')
            pre='11.2 %s age %s harness %d '%(lay,age,item)
            for i in range(9): t.cur('tentacle%d'%i,'xrot',0.2*math.sin(age*0.3+i)+0.4)
            for k,f in enumerate(('xs','ys','zs')): t.cur('body',f,bs[k]*(0.9375 if item else 1))
t.call('EF4-GHAST-TENTACLE',[10,2],[0.2*math.sin(5)+0.4],'11.2 worked example 7: ageInTicks 10, tentacle 2')
for lay in ('HAPPY_GHAST_HARNESS','HAPPY_GHAST_BABY_HARNESS'):
    rows=expected(lay)[0]
    gs=[float(x) for x in [r for r in rows if r.startswith('P goggles ')][0].split()[9:12]][1]
    for rid in (0,1):
        t.raw('MOVE "%s" TO WS-LAYER'%lay,'CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.setin([rid]); t.raw('CALL "EF4-HARNESS-ANIM" USING EMM-MODEL WS-IN')
        pre='11.2 %s ridden %d '%(lay,rid)
        t.cur('goggles','xrot',0 if rid else -0.7854)
        yl=14 if rid else 9
        t.cur('goggles','y',yl*gs+24.016*(1-gs))
save(t,4,11)
