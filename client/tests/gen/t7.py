from mesh4 import *
t=mk(4,7,["Acceptance test of docs/protocol/34-entity-models-4-farm-animals-equines.md section 7 (Goat): 7.1 the texture paths, 7.2 setupAnim (quadruped, horn visibility, ramming head pitch, the baby's fixed 22.5 degree tilt),",
 "7.3 the geometry of goat and goat_baby. Mesh rows are the tables of the document; formula values were worked by an independent script."],ck=True)
IDS=['GOAT','GOAT_BABY']
mesh_checks(t,IDS,'7.3')
for b,p in ((0,'textures/entity/goat/goat.png'),(1,'textures/entity/goat/goat_baby.png')):
    t.raw('MOVE %d TO WS-IV(1)'%b,'CALL "EF4-GOAT-TEXTURE" USING WS-IN WS-X120'); t.text('7.1 texture baby %d'%b,p,'WS-X120')
for lay,baby in (('GOAT',0),('GOAT_BABY',1)):
    for (pitch,yaw,p,s,hl,hr,ram) in ((10,-20,1.2,0.5,1,1,0),(15,5,3,.7,0,1,0.8),(-8,40,2,.2,1,0,-0.4),(0,0,0,0,0,0,0)):
        t.raw('MOVE "%s" TO WS-LAYER'%lay,'CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.setin([pitch,yaw,p,s,hl,hr,ram,baby]); t.raw('CALL "EF4-GOAT-ANIM" USING EMM-MODEL WS-IN')
        a=math.cos(0.6662*p)*1.4*s; b=math.cos(0.6662*p+math.pi)*1.4*s
        pre='7.2 %s horns %d%d ramming %s pos %s '%(lay,hl,hr,ram,p)
        hx=pitch*D
        if ram!=0: hx=ram
        elif baby: hx=0.3926991
        for part,f,v in (('head','xrot',hx),('head','yrot',yaw*D),('right_hind_leg','xrot',a),('left_hind_leg','xrot',b),('right_front_leg','xrot',b),('left_front_leg','xrot',a)):
            t.raw('MOVE "%s" TO WS-PN'%part,'CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P'); t.num(pre+part+'.'+f,v,'MM-C%s(WS-P)'%f.upper())
        t.raw('MOVE "left_horn" TO WS-PN','CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P'); t.num(pre+'left_horn visible',hl,'MM-VISIBLE(WS-P)')
        t.raw('MOVE "right_horn" TO WS-PN','CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P'); t.num(pre+'right_horn visible',hr,'MM-VISIBLE(WS-P)')
save(t,4,7)
