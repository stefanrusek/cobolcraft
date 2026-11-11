from mesh8 import *
t=mk(8,0,["Acceptance test of docs/protocol/34-entity-models-8-aquatic-nautilus-boats.md section 0 (conventions and engine facts): 0.1 the part draw ops and the box extent with grow, 0.2 the root scaling pose (0.5 and 1.5), 0.3 the sine and cosine table values,",
 "0.4 the animation clock in milliseconds and applyWalk, 0.5 the baby model swap, the entity render type and the shadow radius."],ck=False)
SC=10430.378350470453
def ops(p):
    x,y,z,rx,ry,rz,sx,sy,sz=p; o=[(1,x/16,y/16,z/16)]
    if rx or ry or rz: o.append((7,rz,ry,rx))
    if sx!=1 or sy!=1 or sz!=1: o.append((2,sx,sy,sz))
    return [len(o)]+[v for q in o for v in q]
for p in ((0,0,0,0,0,0,1,1,1),(8,-16,4,0.5,0.1,0.2,1,1,1),(1,2,3,0,0,0,0.5,0.5,0.5)):
    t.call('EF8-PART-OPS',list(p),ops(p),'0.1 part ops for pose %s (count; code 1 translate, 7 rotationZYX z y x, 2 scale)'%(p,))
for o,s,g in ((-6,12,0.02),(0,8,0),(-1,2,0.5)):
    t.call('EF8-BOX-EXTENT',[o,s,g],[o-g,o+s+g],'0.1 box extent origin %s size %s grow %s (from, to)'%(o,s,g))
for s in (0.5,1.5,1,2):
    t.call('EF8-ROOT-POSE',[s],[s,24.016*(1-s)],'0.2 root pose scale %s (scale, y)'%s)
t.call('EF8-ROOT-POSE',[0.5],[0.5,12.008],'0.2 s 0.5 gives scale 0.5 and y +12.008'); t.call('EF8-ROOT-POSE',[1.5],[1.5,-12.008],'0.2 s 1.5 gives scale 1.5 and y -12.008')
for x in (0,0.5,1,2.5,-1.2,10,100.3):
    t.call('EF8-MTH-SIN',[x],[math.sin(((int(x*SC))&65535)/SC)],'0.3 Mth.sin(%s) table entry'%x)
    t.call('EF8-MTH-COS',[x],[math.sin(((int(x*SC+16384.0))&65535)/SC)],'0.3 Mth.cos(%s) table entry'%x)
for a,s0 in ((10,0),(10.5,4),(3.25,3),(100,-2)):
    t.call('EF8-ANIM-MS',[a,s0],[int((a-s0)*50)],'0.4 animation time ms age %s start %s'%(a,s0))
for p,sp,a,b in ((2.0,0.4,1.5,2.5),(0.5,0.2,1,2.5),(3.5,1,9,100)):
    t.call('EF8-WALK',[p,sp,a,b],[int(p*50*a),min(sp*b,1)],'0.4 applyWalk pos %s speed %s factors %s %s (ms, strength)'%(p,sp,a,b))
for baby in (0,1): t.call('EF8-AGEABLE-MODEL',[baby],[baby],'0.5 baby model swap baby %d'%baby)
for r,sc,ag in ((0.7,1,1),(0.7,2,0.5),(0.5,1,0.5)): t.call('EF8-SHADOW',[r,sc,ag],[r*sc,r*sc*ag],'0.5 shadow radius base %s scale %s ageScale %s (base x scale, with ageScale)'%(r,sc,ag))
text_check(t,'EF8-RENDER-TYPE',[0],'0.5 default render type name','entityCutout')
save(t,8,0)
