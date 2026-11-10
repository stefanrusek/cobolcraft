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
g.run('persistence 4.7 and the forced tick 4.8: HurtEntities defaults to the anvil tag, FallHurtMax 40, DropItem true, TileEntityData written only when present; the duplicate ticks when exactly one of source and target is the End',["1 1 0 0 0","0 0 0 1 1","0 0 1 0 1","0 0 1 1 1","0 0 0 0 1"],'CALL "GB-FALL-NBT" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-I(3) WS-I(4) WS-I(5) WS-R(5)',5,"1/40/1/1/0 0/40/1/0/1 0/40/1/0/1 0/40/1/0/0 0/40/1/0/0")
g.write(OUT+'/test_growth_29b_1_4.cob')
