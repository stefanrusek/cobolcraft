from mesh4 import *
t=mk(4,5,["Acceptance test of docs/protocol/34-entity-models-4-farm-animals-equines.md section 5 (Sheep): 5.1 the texture paths and the undercoat and wool layer rules, 5.2 setupAnim (quadruped, head y offset, head pitch replaced),",
 "5.3 wool layers (which model, sub-order, the outline-only case), 5.4 the geometry of sheep, sheep_wool, sheep_baby (and the undercoat and baby wool ids), 5.5 the dye table (each sheep colour re-derived from the diffuse colour by",
 "the formula and compared with the table), 5.6 the jeb colour cycle. Mesh rows are the tables of the document; formula values were worked by an independent script."],ck=True)
IDS=['SHEEP','SHEEP_WOOL','SHEEP_BABY','SHEEP_WOOL_UNDERCOAT','SHEEP_BABY_WOOL']
mesh_checks(t,IDS,'5.4')
for b,p in ((0,'textures/entity/sheep/sheep.png'),(1,'textures/entity/sheep/sheep_baby.png')):
    t.raw('MOVE %d TO WS-IV(1)'%b,'CALL "EF4-SHEEP-TEXTURE" USING WS-IN WS-X120'); t.text('5.1 texture baby %d'%b,p,'WS-X120')
for inv in (0,1):
  for jeb in (0,1):
    for nw in (0,1):
      for baby in (0,1):
        d=1 if (not inv and (jeb or nw) and not baby) else 0
        t.call('EF4-UNDERCOAT-DRAW',[inv,jeb,nw,baby],[d],'5.3 undercoat invisible %d jeb %d colour not white %d baby %d drawn'%(inv,jeb,nw,baby))
for sh in (0,1):
  for baby in (0,1):
    for inv in (0,1):
      for glow in (0,1):
        if sh: mode=0
        elif inv: mode=2 if glow else 0
        else: mode=1
        t.call('EF4-WOOL-DRAW',[sh,baby,inv,glow],[mode,baby,baby if mode==1 else 0],'5.3 wool sheared %d baby %d invisible %d glowing %d: mode (0 none 1 coloured 2 outline only), model (1 baby), sub-order'%(sh,baby,inv,glow))
# dye table from the document
L=open(REPO+DOCS[4]).read().split('\n')
dyes=[]
for ln in L:
    m=re.match(r'\| (\d+) \| (\w+) \| 0x([0-9A-F]{6}) \| 0x([0-9A-F]{8}) \|',ln)
    if m: dyes.append((int(m.group(1)),m.group(2),int(m.group(3),16),int(m.group(4),16)))
assert len(dyes)==16
def sheepcol(ordn,rgb):
    if ordn==0: return 0xFFE6E6E6
    r,g,b=(rgb>>16)&255,(rgb>>8)&255,rgb&255
    f=lambda c:min(255,max(0,math.floor(c*0.75)))
    return (255<<24)|(f(r)<<16)|(f(g)<<8)|f(b)
for o,n,rgb,col in dyes:
    assert sheepcol(o,rgb)==col,(n,hex(sheepcol(o,rgb)),hex(col))
    t.call('EF4-DYE-COLOUR',[o,rgb],[0xFF000000|rgb,col],'5.5 dye %d %s: opaque diffuse colour and sheep colour'%(o,n))
cols=[d[3] for d in dyes]
def jeb(a):
    i=math.floor(a); step=i//25
    c0=cols[step%16]; c1=cols[(step+1)%16]; tt=((i%25)+(a-i))/25
    out=[]
    for sh in (24,16,8,0):
        x=(c0>>sh)&255; y=(c1>>sh)&255
        out.append(x+math.floor(tt*(y-x)))
    return out
for a in (0,3.5,12.3,24.9,25,37.7,100.25,399.6,401.25,812.75):
    t.call('EF4-JEB-COLOUR',[a],jeb(a)+[ (jeb(a)[0]<<24)|(jeb(a)[1]<<16)|(jeb(a)[2]<<8)|jeb(a)[3] ],'5.6 jeb colour at ageInTicks %s (alpha, red, green, blue, packed ARGB)'%a)
for lay in ('SHEEP','SHEEP_WOOL','SHEEP_BABY'):
    for (pitch,yaw,p,s,pos,ang,ag) in ((12,-30,2.5,0.6,0.8,0.35,1),(0,0,0,0,0,0.9,0.5),(30,20,4,1,0.8,0,0.5),(-5,5,1,.3,0,0,1)):
        t.raw('MOVE "%s" TO WS-LAYER'%lay,'CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.setin([pitch,yaw,p,s,pos,ang,ag]); t.raw('CALL "EF4-SHEEP-ANIM" USING EMM-MODEL WS-IN')
        a=math.cos(0.6662*p)*1.4*s; b=math.cos(0.6662*p+math.pi)*1.4*s
        pre='5.2 %s pos %s eat %s ageScale %s '%(lay,p,pos,ag)
        # head initial y from the rows
        hy=[float(r.split()[4]) for r in SRC['sheep_baby' if lay=='SHEEP_BABY' else ('sheep_wool' if lay=='SHEEP_WOOL' else 'sheep')]['rows'] if r.startswith('P head ')][0]
        for part,f,v in (('head','y',hy+pos*9*ag),('head','xrot',ang),('head','yrot',yaw*D),('right_hind_leg','xrot',a),('left_hind_leg','xrot',b),('right_front_leg','xrot',b),('left_front_leg','xrot',a)):
            t.raw('MOVE "%s" TO WS-PN'%part,'CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P'); t.num(pre+part+'.'+f,v,'MM-C%s(WS-P)'%f.upper())
save(t,4,5)
