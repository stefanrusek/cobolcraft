from mesh5 import *
t=mk(5,12,["Acceptance test of docs/protocol/34-entity-models-5-wild-companion-animals-small-creatures.md section 12 (Tadpole): the mesh table (body and tail, texture 16 x 16), the tail swing -f x 0.25 x sin(0.3 A) with f = 1 in water and 1.5 out of water,",
 "the shadow radius 0.14 and the texture path. Mesh rows are the table of the document."],ck=True)
mesh_checks(t,['TADPOLE'],'12')
for water,A in ((1,0),(1,5.5),(0,5.5),(0,12.25),(1,31.4),(0,100)):
    t.raw('MOVE "TADPOLE" TO WS-LAYER','CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.raw('MOVE 3 TO MM-CXROT(2)'); t.setin([water,A]); t.raw('CALL "EF5-TADPOLE-ANIM" USING EMM-MODEL WS-IN')
    f=1 if water else 1.5
    t.cur('tail','yrot',-f*0.25*math.sin(0.3*A)); t.cur('tail','xrot',0); t.cur('tail','y',22); t.cur('body','yrot',0)
t.raw('MOVE SPACES TO WS-X120','CALL "EF5-TADPOLE-TEXTURE" USING WS-X120'); t.text('12 texture','textures/entity/tadpole/tadpole.png','WS-X120')
t.call('EF5-TADPOLE-SHADOW',[],[0.14],'12 shadow radius')
save(t,5,12)
