import sys,math
sys.path.insert(0,'core/tests/gen')
from gentest import *
OUT=sys.argv[1] if len(sys.argv)>1 else "core/tests"
def m(x,n=1000000): return int(math.floor(x*n+0.5))
def S(*a): return " ".join(str(x) for x in a)
def RF(k,scale=1000000): return 'COMPUTE WS-R(%d) ROUNDED = WS-RF(%d) * %d'%(k,k,scale)
def GG(n,subj,tasks,desc): return Gen('TEST-GROWTH-29B-1-%d'%n,'29b-1§%d'%n,subj,'Test of 29b part 1 section %d, %s (core/src/growth-29b-1.cob; %s): %s'%(n,subj,tasks,desc),'')
BD=" 01 WS-BD1 BINARY-DOUBLE.\n 01 WS-BD2 BINARY-DOUBLE.\n"
# ===== 1
g=GG(1,'Scope, siblings, cross-reference','T0521','the block-name table of 1.3: owner part and section of the listed blocks.')
keys=[("sand",1,32),("red_sand",1,32),("gravel",1,32),("suspicious_sand",1,35),("suspicious_gravel",1,35),("white_concrete_powder",1,33),("light_blue_concrete_powder",1,33),("anvil",1,34),("chipped_anvil",1,34),("damaged_anvil",1,34),("dragon_egg",1,36),("scaffolding",1,37),("pointed_dripstone",6,38),("sulfur_spike",6,38),("mangrove_propagule",2,74),("stone",0,0),("concrete_powder",0,0)]
g.case('block names of 1.3 map to their owning part and section (x10); other names to none',[("0",'MOVE "minecraft:%s" TO WS-T1\nCALL "GB-PART" USING WS-T1 WS-R(1) WS-R(2)'%k,2) for k,_,_ in keys]," ".join("%d/%d"%(p,s) for _,p,s in keys))
g.write(OUT+'/test_growth_29b_1_1.cob')
# ===== 2
g=GG(2,'The shared model','T0523','trigger kinds, probability notation and the random tick rate.')
g.case('trigger codes of 2.2: RT, ST, PL, NU, SU, EV, ET; only ST is a scheduled tick',[("%d"%t,'MOVE SPACES TO WS-T1\nCALL "GB-TRIGGER" USING WS-I(1) WS-T1 WS-R(1)\nCOMPUTE WS-R(2) = FUNCTION ORD(WS-T1(1:1))\nCOMPUTE WS-R(3) = FUNCTION ORD(WS-T1(2:1))',3) for t in range(1,8)]," ".join("%d/%d/%d"%(1 if c=="ST" else 0,ord(c[0])+1,ord(c[1])+1) for c in ["RT","ST","PL","NU","SU","EV","ET"]))
def prob(nt,a,b,p,dr,fd):
    if nt==1: return int(dr==0),1
    if nt==2: return int(fd<p),1
    if a>=b: return a,0
    return dr+a,1
pc=[(1,7,0,0.0,0,0.0),(1,7,0,0.0,3,0.0),(1,1,0,0.0,0,0.0),(2,0,0,0.45,0,0.449),(2,0,0,0.45,0,0.451),(2,0,0,0.1,0,0.0),(3,2,5,0.0,3,0.0),(3,2,5,0.0,0,0.0),(3,5,2,0.0,0,0.0),(3,2,2,0.0,0,0.0)]
g.run('probability notation 2.4: 1/N is true on a draw of 0; P(p) on a float draw below p; U(a, b) is a when a >= b without a draw, else the draw plus a',[S(*c) for c in pc],'CALL "GB-PROBABILITY" USING WS-I(1) WS-I(2) WS-I(3) WS-FX(4) WS-I(5) WS-FX(6) WS-R(1) WS-R(2)',2," ".join("%d/%d"%prob(*c) for c in pc))
g.extra=BD
rc=[(3,7),(3,1),(0,5),(1,1),(3,4096),(20,3)]
g.run('random tick rate 2.4: speed / 4096 random ticks per game tick, and speed / (4096 N) for a 1/N effect (per random tick x 10^6, per game tick x 10^9)',[S(*c) for c in rc],'CALL "GB-RATE" USING WS-I(1) WS-I(2) WS-BD1 WS-BD2\nMOVE WS-BD1 TO WS-R(1)\nMOVE WS-BD2 TO WS-R(2)',2," ".join("%d/%d"%(m(c[0]/4096.0),m(c[0]/(4096.0*c[1]),1000000000)) for c in rc))
g.write(OUT+'/test_growth_29b_1_2.cob')
# ===== 3
g=GG(3,'Falling block rules','T0525','isFree, the scheduled fall decision, tick delays, concrete powder, anvils, brushable blocks, the dragon egg and scaffolding.')
fr=[(a,f,l,r) for a in (0,1) for f in (0,1) for l in (0,1) for r in (0,1)]
g.run('isFree: air, tag fire, a liquid or a replaceable state',[S(*c) for c in fr],'CALL "GB-IS-FREE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1," ".join(str(int(any(c))) for c in fr))
g.run('the scheduled tick falls only when the cell below is free and y >= minY',["1 66 0","1 0 0","1 -1 0","0 66 0","1 5 5"],'CALL "GB-FALL-DECIDE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,"1 1 0 0 1")
g.run('tick delays: 2, dragon egg 5, scaffolding 1, brushable 2',["1","2","3","4"],'CALL "GB-DELAY" USING WS-I(1) WS-R(1)',1,"2 5 1 2")
def touches(w,st,own):
    for d in range(6):
        if w[d] and not st[d] and (d>0 or own): return 1
    return 0
tc=[([0]*6,[0]*6,0),([0,0,1,0,0,0],[0]*6,0),([0,0,1,0,0,0],[0,0,1,0,0,0],0),([1,0,0,0,0,0],[0]*6,0),([1,0,0,0,0,0],[0]*6,1),([0,1,0,0,0,0],[0]*6,0),([0,0,0,0,0,1],[0,0,0,0,0,0],1),([1,1,1,1,1,1],[1,1,1,1,1,1],1)]
g.run('touchesLiquid (3.3): six directions down first; a water neighbour with a non-sturdy face counts; the cell below only when the own cell is water',[S(*(c[1] and c[0]+c[1]+[c[2]])) for c in tc],'CALL "GB-TOUCHES" USING WS-I(13) WS-ISG WS-R(1)',1," ".join(str(touches(*c)) for c in tc))
sc=[(0,0,1),(1,0,1),(0,1,0),(0,1,1),(1,1,1),(0,1,2),(1,1,2),(0,0,3)]
g.run('concrete powder (3.3): shouldSolidify for placement (1) and landing (3) is canSolidify or touchesLiquid; a shape update (2) solidifies only when it touches liquid',[S(*c) for c in sc],'CALL "GB-SOLIDIFY" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1," ".join(str((c[1] if c[2]==2 else int(c[0] or c[1]))) for c in sc))
g.run('anvil (3.4): anvil becomes chipped, chipped damaged, damaged null (-1); hurt 2.0 per block, maximum 40; events 1031 (land) and 1029 (broken) unless silent',["0 0","1 0","2 0","0 1","2 1"],'CALL "GB-ANVIL" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5,"1/20/40/1031/1029 2/20/40/1031/1029 -1/20/40/1031/1029 1/20/40/0/0 -1/20/40/0/0")
g.run('brushable blocks (3.5): the reset runs when there is a block entity; the fall needs a free cell below and y >= minY and disables the drop',["1 1 1","0 1 1","1 0 1","1 1 0"],'CALL "GB-BRUSHABLE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-R(3)',3,"1/1/1 0/1/1 1/0/0 1/0/0")
g.run('dragon egg (3.6): the offset of an attempt is (a1 - a2, b1 - b2, c1 - c2) from the six draws',["10 3 2 7 0 15","0 0 0 0 0 0","15 0 7 0 15 0"],'CALL "GB-EGG-OFFSET" USING WS-ISG WS-R(1) WS-R(2) WS-R(3)',3,"7/-5/-15 0/0/0 15/7/15")
def sd(sc_,st,b,ns):
    if (not sc_) and st: return 0
    d=7
    if sc_: d=min(d,b)
    for n in ns: d=min(d,n+1)
    return d
sdc=[(0,1,0,[7,7,7,7]),(0,0,0,[7,7,7,7]),(1,0,2,[7,7,7,7]),(1,0,0,[7,7,7,7]),(1,0,5,[3,7,7,7]),(0,0,0,[1,7,7,7]),(0,0,0,[6,7,6,7]),(1,1,4,[7,7,2,7])]
g.run('scaffolding distance (3.7): 0 over a sturdy non-scaffolding block, else the minimum of 7, the distance below when scaffolding and each neighbour + 1',[S(*(c[3] and [c[2]]+c[3]+[c[0],c[1]])) for c in sdc],'CALL "GB-SCAFFOLD-DISTANCE" USING WS-I(6) WS-I(7) WS-ISG WS-R(1)',1," ".join(str(sd(*c)) for c in sdc))
def st(o,n,b):
    bot=int(n>0 and not b)
    act = 3 if (n==7 and o==7) else 2 if n==7 else 1 if n!=o else 0
    return bot,act
stc=[(7,7,0),(3,7,0),(0,3,0),(3,3,0),(3,3,1),(0,0,0),(7,0,1),(2,5,1)]
g.run('scaffolding tick (3.7): a new distance of 7 falls when the old one was 7 and else destroys with drops; a changed state is written; bottom is distance above 0 with no scaffolding below',[S(*c) for c in stc],'CALL "GB-SCAFFOLD-TICK" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2)',2," ".join("%d/%d"%st(*c) for c in stc))
g.write(OUT+'/test_growth_29b_1_3.cob')
# ===== 4
g=GG(4,'The falling block entity','T0527','the per-tick motion, landing, expiry, fall damage with the anvil chip, persistence defaults and the forced tick.')
exp=[]; vy=0.0; dist=0.0
for i in range(10):
    vy-=0.04; dist-=vy; vy*=0.98; exp.append(m(dist,100000))
g.run('worked example 8.1: the fall distance after ten ticks (vy - 0.04, move, x 0.98) is 0.04, 0.1192, 0.236816, 0.39208, ...',["0"],'MOVE 0 TO WS-RF(1)\nMOVE 0 TO WS-RF(2)\nPERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 10\n    CALL "GB-FALL-STEP" USING WS-RF(1) WS-RF(2)\n    COMPUTE WS-R(WS-K) ROUNDED = WS-RF(2) * 100000\nEND-PERFORM',10," ".join(map(str,exp)).replace(" ","/"))
def land(pi,ca,re,su,bf,dr,ru,wr):
    if pi: return 0
    if ca: return 1
    if re and su and not bf: return 2 if wr else (3 if (dr and ru) else 4)
    return 5 if (dr and ru) else 6
lc=[(1,0,1,1,0,1,1,1),(0,1,1,1,0,1,1,1),(0,0,1,1,0,1,1,1),(0,0,1,1,0,1,1,0),(0,0,1,1,0,0,1,0),(0,0,0,1,0,1,1,1),(0,0,1,0,0,1,1,1),(0,0,1,1,1,1,1,1),(0,0,1,1,1,1,0,1),(0,0,1,1,1,0,1,1)]
g.run('landing 4.3: a moving piston stops, cancelDrop discards, a replaceable cell with survival and a solid cell below is placed (or retried/dropped when the write fails), anything else discards with an item when allowed',[S(*c) for c in lc],'CALL "GB-LAND" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-I(8) WS-R(1)',1," ".join(str(land(*c)) for c in lc))
def ex(t,y,mn,mx,d,r):
    e=int((t>100 and (y<=mn or y>mx)) or t>600); return e,int(e and d and r)
ec=[(100,64,0,255,1,1),(101,64,0,255,1,1),(101,0,0,255,1,1),(101,256,0,255,1,1),(101,-5,0,255,0,1),(601,64,0,255,1,1),(601,64,0,255,1,0),(600,64,0,255,1,1)]
g.run('expiry 4.4: time > 100 outside the height range or time > 600 expires; the item only with dropItem and entity_drops',[S(*c) for c in ec],'CALL "GB-EXPIRY" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1) WS-R(2)',2," ".join("%d/%d"%ex(*c) for c in ec))
def fd(dist,per,mx,hurts,anvil,draw):
    if not hurts: return 0,0.0,0,0
    n=math.ceil(dist-1)
    if n<0: return 0,0.0,0,0
    dmg=min(math.floor(n*per),mx)
    chip=0
    if anvil and dmg>0 and draw<0.05+n*0.05: chip=1
    return n,float(dmg),chip,int(anvil and dmg>0)
fc=[(2.0,2.0,40,1,1,0.09),(2.0,2.0,40,1,1,0.11),(4.0,2.0,40,1,1,0.19),(4.0,2.0,40,1,1,0.21),(21.0,2.0,40,1,0,0.0),(22.0,2.0,40,1,0,0.0),(2.0,2.0,40,0,1,0.0),(-1.0,2.0,40,1,1,0.0),(1.0,2.0,40,1,1,0.0),(3.5,0.0,40,1,1,0.0)]
g.run('fall damage 4.6 (worked example 8.2): n = ceil(distance - 1), damage = min(floor(n x 2.0), 40), the anvil chips when nextFloat < 0.05 + n x 0.05 (drawn only for an anvil with damage)',[S(*c) for c in fc],'CALL "GB-FALL-DAMAGE" USING WS-FX(1) WS-FX(2) WS-I(3) WS-I(4) WS-I(5) WS-FX(6) WS-R(1) WS-RF(1) WS-R(3) WS-R(4)\n'+RF(1,1000).replace('WS-R(1)','WS-R(2)'),4," ".join("%d/%d/%d/%d"%(fd(*c)[0],m(fd(*c)[1],1000),fd(*c)[2],fd(*c)[3]) for c in fc))
g.run('persistence 4.7 and the forced tick 4.8: HurtEntities defaults to the anvil tag, FallHurtMax 40, DropItem true, TileEntityData written only when present; the duplicate ticks when exactly one of source and target is the End',["1 1 0 0 0","0 0 0 1 0","0 0 1 0 1","0 0 1 1 1","0 0 0 0 1"],'CALL "GB-FALL-NBT" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-I(3) WS-I(4) WS-I(5) WS-R(5)',5,"1/40/1/1/0 0/40/1/0/1 0/40/1/0/1 0/40/1/0/0 0/40/1/0/0")
g.write(OUT+'/test_growth_29b_1_4.cob')
# ===== 5
g=GG(5,'The bone meal framework','T0529','the item flow of 5.3, the bush spreader of 5.4 and the bee growth goal of 5.5.')
def bm(v,su,sv,st,wa):
    p=s=e=r=0
    if v:
        r=1
        if sv:
            s=e=1; p=su
    elif st and wa:
        r=2; e=sv
    return p,s,e,r
bc=[(1,1,1,0,0),(1,0,1,0,0),(1,1,0,0,0),(0,0,1,1,1),(0,0,1,1,0),(0,0,1,0,1),(0,0,0,1,1),(1,0,1,1,1)]
g.run('bone meal item (5.3): a valid target shrinks the stack on the server whether or not the success test passes (V16), performs only on success; otherwise the water plant branch needs a sturdy face; events 1505 data 15',[S(*c) for c in bc],'CALL "GB-BONEMEAL-ITEM" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4," ".join("/".join(map(str,bm(*c))) for c in bc))
g.extra=" 01 WS-ORD.\n    05 WS-OR BINARY-LONG OCCURS 4 TIMES.\n"
def bush(air,sv,order):
    valid=int(any(a and s for a,s in zip(air,sv))); ch=0
    for d in order:
        if air[d-1] and sv[d-1]: ch=d; break
    return valid,ch
bu=[([1,0,0,0],[1,0,0,0],[2,3,4,1]),([1,0,0,0],[0,0,0,0],[1,2,3,4]),([0,1,1,0],[0,1,1,0],[3,2,1,4]),([0,1,1,0],[0,1,1,0],[4,1,2,3]),([0,0,0,0],[0,0,0,0],[1,2,3,4]),([1,1,1,1],[1,1,1,1],[4,3,2,1]),([1,0,1,0],[0,1,0,1],[1,2,3,4])]
g.run('bush spreader (5.4): valid when a horizontal neighbour is air and survivable; the first direction of the shuffled order that is, is chosen',[S(*(a+b+o)) for a,b,o in bu],'MOVE WS-I(9) TO WS-OR(1)\nMOVE WS-I(10) TO WS-OR(2)\nMOVE WS-I(11) TO WS-OR(3)\nMOVE WS-I(12) TO WS-OR(4)\nCALL "GB-BUSH-SPREAD" USING WS-ISG WS-ORD WS-R(1) WS-R(2)',2," ".join("%d/%d"%bush(*c) for c in bu))
def bg(gr,dr,ne,hi,td):
    return int(gr<10 and dr>=0.3 and ne and hi), int(td==0)
bgc=[(0,0.5,1,1,0),(9,0.5,1,1,5),(10,0.5,1,1,0),(0,0.29,1,1,0),(0,0.31,1,1,0),(0,0.5,0,1,0),(0,0.5,1,0,0)]
g.run('bee growth goal (5.5): false at 10 or more crops or when nextFloat < 0.3, else true with nectar and a hive; the goal ticks on a nextInt(30) draw of 0',[S(*c) for c in bgc],'CALL "GB-BEE-GATE" USING WS-I(1) WS-FX(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1) WS-R(2)',2," ".join("%d/%d"%bg(*c) for c in bgc))
def bgrow(k,a,mx,v):
    n=-1
    if k==1 and a<mx: n=a+1
    elif k==2 and a<7: n=a+1
    elif k==3 and a<3: n=a+1
    elif k==4 and v: n=a
    return n,int(n>=0)
bgr=[(1,3,7,0),(1,7,7,0),(1,2,3,0),(2,6,7,0),(2,7,7,0),(3,2,3,0),(3,3,3,0),(4,0,0,1),(4,0,0,0),(5,1,7,0),(6,1,7,0)]
g.run('bee growth (5.5): a crop (below its maximum), a stem (below 7), a sweet berry bush (below 3) gain 1; cave vines only when the mob bone meal is valid; anything else, pitcher crops included, nothing',[S(*c) for c in bgr],'CALL "GB-BEE-GROW" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2)',2," ".join("%d/%d"%bgrow(*c) for c in bgr))
g.write(OUT+'/test_growth_29b_1_5.cob')
# ===== 6
g=GG(6,'Crop growth helpers','T0531','the CropBlock predicates, getGrowthSpeed (V14), the random tick and bone meal.')
def cs(a,mx,l,su): return int(a>=mx),int(a<mx),int(l>=8),int(l>=8 and su)
cst=[(0,7,15,1),(7,7,15,1),(3,7,7,1),(3,7,8,1),(3,7,8,0),(0,3,0,1)]
g.run('crop predicates (6.1): isMaxAge, randomly ticking while below the maximum, light 8 and the supports_crops ground to survive',[S(*c) for c in cst],'CALL "GB-CROP-STATE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4," ".join("/".join(map(str,cs(*c))) for c in cst))
def speed(cl,ax,az,dg):
    f=1.0
    for i,c in enumerate(cl):
        s=float(c)
        if i!=4: s/=4
        f+=s
    if (ax and az) or dg: f/=2
    return f
spc=[([0,0,0,0,1,0,0,0,0],0,0,0),([0,0,0,0,3,0,0,0,0],0,0,0),([3]*9,0,0,0),([1]*9,0,0,0),([0,0,0,0,3,0,0,0,0],1,0,0),([0,0,0,0,3,0,0,0,0],1,1,0),([0,0,0,0,3,0,0,0,0],0,0,1),([3]*9,1,1,0),([0,0,0,0,0,0,0,0,0],0,0,0)]
g.run('getGrowthSpeed (6.3, V14): 1 plus the cell below (1 dry, 3 hydrated) and a quarter of each neighbour of it; halved once when the same crop is along x and z or at a diagonal; values 2, 4, 10, 4',[S(*(c[0]+list(c[1:]))) for c in spc],'CALL "GB-CROP-SPEED" USING WS-ISG WS-RF(1)\n'+RF(1,10000),1," ".join(str(m(speed(*c),10000)) for c in spc))
def ct(l,a,mx,sp,dr):
    if l>=9 and a<mx:
        b=int(25.0/sp)+1; return b,int(dr==0)
    return 0,0
ctc=[(15,2,7,10.0,0),(15,2,7,10.0,1),(15,2,7,2.0,0),(15,7,7,2.0,0),(8,2,7,2.0,0),(9,2,7,4.0,0),(15,0,7,0.5,0),(15,0,7,25.0,3)]
g.run('crop random tick (6.2, example 8.5): light 9 and age below the maximum; the draw is nextInt(int(25 / speed) + 1) and a 0 grows it (speed 10 gives 3)',[S(*c) for c in ctc],'CALL "GB-CROP-TICK" USING WS-I(1) WS-I(2) WS-I(3) WS-FX(4) WS-I(5) WS-R(1) WS-R(2)',2," ".join("%d/%d"%ct(*c) for c in ctc))
def cb(a,mx,d):
    return (1,min(mx,a+d+2)) if a<mx else (0,a)
cbc=[(2,7,3),(2,7,0),(6,7,3),(7,7,0),(0,3,1),(2,3,3),(1,7,2)]
g.run('crop bone meal (6.4, example 8.6): valid below the maximum; new age = min(max, age + U(2, 5)), the draw being nextInt(4) (3 gives 5)',[S(*c) for c in cbc],'CALL "GB-CROP-BONEMEAL" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2)',2," ".join("%d/%d"%cb(*c) for c in cbc))
g.write(OUT+'/test_growth_29b_1_6.cob')
# ===== 7
g=GG(7,'Saplings and the tree growth trigger','T0533','SaplingBlock, the weighted pick, the grower table, canGrow, the 2 x 2 search and growTree with its rollback.')
def sp(l,d7,stg,sv,cg,ins,fd):
    return int(l>=9 and d7==0),stg,int(sv and cg and ins),int(fd<0.45)
spt=[(12,0,0,1,1,1,0.44),(12,3,0,1,1,1,0.46),(8,0,1,1,1,1,0.2),(9,0,1,0,1,1,0.5),(9,0,1,1,0,1,0.5),(9,0,1,1,1,0,0.5)]
g.run('sapling (7.1): a random tick advances with light 9 and a nextInt(7) of 0; bone meal is valid on a server with canGrow and room, and succeeds on nextFloat < 0.45 (V16: the stack shrinks either way)',[S(*c) for c in spt],'CALL "GB-SAPLING" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-FX(7) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4," ".join("/".join(map(str,sp(*c))) for c in spt))
def wt(ws,d):
    t=sum(ws)
    if not t: return 0,0
    left=d
    for i,w in enumerate(ws):
        if w:
            left-=w
            if left<0: return i+1,1
    return 0,1
wtc=[([9,1,0,0],0),([9,1,0,0],8),([9,1,0,0],9),([1,0,0,0],0),([0,0,0,0],0),([15,85,0,0],14),([15,85,0,0],15),([1,1,1,0],2),([1,1,1,0],1)]
g.run('weighted pick (7.2, example 8.7): an empty list draws nothing; else the first entry whose cumulative range holds nextInt(total): oak 9 and fancy oak 1 give 0 to 8 oak and 9 fancy',[S(*(c[0]+[c[1]])) for c in wtc],'CALL "GB-WEIGHTED" USING WS-ISG WS-I(5) WS-R(1) WS-R(2)',2," ".join("%d/%d"%wt(*c) for c in wtc))
gr=[(10,0,10,1),(1,2,0,1),(100,0,0,1),(1,0,0,1),(1,0,1,1),(1,1,0,1),(1,0,0,1),(1,0,1,1),(0,1,0,0),(0,1,0,0),(3,0,0,1)]
g.run('grower table (7.4): total weights of trees, mega trees and flower trees and the shortest tree type of OAK, SPRUCE, MANGROVE, AZALEA, BIRCH, JUNGLE, ACACIA, CHERRY, DARK_OAK, PALE_OAK, POPLAR',[str(i) for i in range(1,12)],'CALL "GB-GROWER" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4," ".join("/".join(map(str,c)) for c in gr))
def cg(nn,me,grp,dx,dy,dz):
    return (grp if (nn and me) else 1),int(-2<=dx<=2 and -1<=dy<=1 and -2<=dz<=2)
cgt=[(1,1,1,0,0,0),(1,1,0,0,0,0),(0,1,0,0,0,0),(1,0,0,0,0,0),(0,0,0,2,1,-2),(0,0,0,3,0,0),(0,0,0,0,-2,0),(0,0,0,-2,-1,2)]
g.run('canGrow (7.2, V17): a missing normal pick with a mega pick needs a 2 x 2 group; otherwise true; the flowers box is -2 to 2, -1 to 1, -2 to 2 (V20)',[S(*c) for c in cgt],'CALL "GB-TREE-CAN-GROW" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1) WS-R(2)',2," ".join("%d/%d"%cg(*c) for c in cgt))
def tb(fl):
    sqs=[(0,0),(0,-1),(-1,0),(-1,-1)]
    for i,(dx,dz) in enumerate(sqs):
        if all(fl[i*4:i*4+4]): return dx,dz,1
    return 0,0,0
tbc=[[1]*16,[0]*16,[0]*4+[1]*4+[0]*8,[0]*8+[1]*4+[0]*4,[0]*12+[1]*4,[1,1,1,0]+[0]*12,[0]*4+[1]*4+[1]*4+[1]*4]
g.run('2 x 2 search (7.2): the squares (0, 0), (0, -1), (-1, 0), (-1, -1) in that order; the first whose four cells hold the sapling',[S(*c) for c in tbc],'CALL "GB-TWO-BY-TWO" USING WS-ISG WS-R(1) WS-R(2) WS-R(3)',3," ".join("/".join(map(str,tb(c))) for c in tbc))
def gt(me,rg,gp,nm,nr,pl):
    if me and rg and gp: return 1,int(not pl),pl
    if nm and nr: return 2,int(not pl),pl
    return 0,0,0
gtt=[(1,1,1,0,0,1),(1,1,1,0,0,0),(1,1,0,1,1,1),(1,0,1,1,1,0),(0,0,0,1,1,1),(0,0,0,1,1,0),(0,0,0,0,0,1),(0,0,0,1,0,1)]
g.run('growTree (7.3, V18): a registered mega feature with a 2 x 2 group is tried alone and restored on failure; otherwise the single tree (restored on failure); no pick, no tree; removal flags 818, restore 260',[S(*c) for c in gtt],'CALL "GB-GROW-TREE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4," ".join("%d/%d/%d/818"%gt(*c) for c in gtt))
g.write(OUT+'/test_growth_29b_1_7.cob')
