from mesh6 import *
import s6_spider_data as SP
setlayer('SPIDER',SP.rows(),64,32); setlayer('CAVE_SPIDER',SP.rows(),64,32,[0.7],src='SPIDER')
t=mk(6,6,["Acceptance test of docs/protocol/34-entity-models-6-overworld-hostiles-arthropods-slimes.md section 6 (Spider and cave spider): 6.1 the one mesh and the cave spider layer through scaling 0.7, 6.2 setupAnim (head look and the four leg pairs with",
 "their phases; worked example 15.8), 6.3 textures (one eyes texture for both), shadow radii and the eyes layer. Mesh rows are the table of the document."],ck=True)
t.LP='EF6-LAYER'
mesh_checks(t,['SPIDER','CAVE_SPIDER'],'6.1')
PI=3.1415927
PAIRS=[('hind',0,'right_hind_leg','left_hind_leg'),('middle hind',PI,'right_middle_hind_leg','left_middle_hind_leg'),('middle front',1.5707964,'right_middle_front_leg','left_middle_front_leg'),('front',4.712389,'right_front_leg','left_front_leg')]
def spider(layer,st):
    xr,yr,w,s=st
    P=base_parts(layer); th=w*0.6662
    P['head'][3]=xr*0.017453292; P['head'][4]=yr*0.017453292
    for nm,phi,r,l in PAIRS:
        A=-(math.cos(2*th+phi)*0.4)*s; B=abs(math.sin(th+phi)*0.4)*s
        P[r][4]+=A; P[r][5]+=B; P[l][4]-=A; P[l][5]-=B
    return P
for layer in ('SPIDER','CAVE_SPIDER'):
    for st in ((10,-20,1.0,1.0),(0,0,0,0),(-15,40,3.5,0.4),(25,-90,7.25,0.9)):
        pose_check(t,layer,'EF6-SPIDER-ANIM',st,spider(layer,st))
t.build('SPIDER'); t.setin([0,0,1,1]); t.raw('CALL "EF6-SPIDER-ANIM" USING EMM-MODEL WS-IN')
t.cur('right_hind_leg','yrot',0.7853982-0.09446); t.cur('left_hind_leg','yrot',-0.7853982+0.09446)
t.cur('right_front_leg','yrot',-0.7853982-0.38869); t.cur('right_front_leg','zrot',-0.7853982+0.31447)
for cave,e in ((0,'textures/entity/spider/spider.png'),(1,'textures/entity/spider/cave_spider.png')): text_check(t,'EF6-SPIDER-TEXTURE',[cave,0],'6.3 texture cave %d'%cave,e)
text_check(t,'EF6-SPIDER-TEXTURE',[0,1],'6.3 eyes texture of the spider','textures/entity/spider/spider_eyes.png')
text_check(t,'EF6-SPIDER-TEXTURE',[1,1],'6.3 eyes texture of the cave spider (the same file)','textures/entity/spider/spider_eyes.png')
save(t,6,6)
