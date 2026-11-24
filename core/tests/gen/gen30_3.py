import sys,random
sys.path.insert(0,'core/tests/gen')
from gen30c import *
SU=Suite(3,'30-3','RS1-','redstone-30-3.cob',[int(a) for a in sys.argv[1:]])
RNG=random.Random(30)
TB=TBL('SG',64)+TBL('PL',64)+TBL('DL',64)+' 01 WS-GRG.\n    05 WS-GR BINARY-LONG OCCURS 4096 TIMES.\n'+TBL('OP',64)+TBL('XL',64)
FL=' 01 WS-FL                 FLOAT-LONG.\n'
ST=lambda d:STEP[d]
# ===== 1
g=SU.gen(1,'Blocks and states','T0728','ids, state numbering, placement, block properties and delays of the piston family.')
RW=[(138,12,2350),(149,12,2373),(150,24,2385),(199,12,3801)]
T(g,'ids (1): sticky_piston 138 12 2350, piston 149 12 2373, piston_head 150 24 2385, moving_piston 199 12 3801 (id, states, first state)','CALL "RS1-PISTON-ROW" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3)',3,[(i,) for i in range(1,5)],lambda i:RW[i-1])
def pst(b,f,a,t): 
    first=RW[b-1][2]
    return first+({1:a*6+f,2:a*6+f,3:f*4+a*2+t,4:f*2+t}[b])
T(g,'state numbering (1): base extended * 6 + facing; head facing * 4 + short * 2 + type; moving facing * 2 + type (block, facing, extended or short, type)','CALL "RS1-PISTON-STATE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1,[(1,2,0,0),(1,5,1,0),(2,0,0,0),(2,3,1,0),(3,2,0,0),(3,5,1,1),(3,1,1,0),(4,0,0,0),(4,5,0,1),(4,3,0,1)],lambda *a:(pst(*a),))
T(g,'placement (1): facing is the opposite of the nearest looking direction','CALL "RS1-DIODE-PLACE" USING WS-I(1) WS-R(1)',1,[(d,) for d in (2,3,4,5)],lambda d:(opp(d),))
T(g,'placement vertical (1): the opposite of the look direction for up and down','CALL "RS1-OPP" USING WS-I(1) WS-R(1)',1,[(0,),(1,)],lambda d:(opp(d),))
T(g,'block properties (1): conductor never; base suffocating only when retracted and light occlusion when extended; head occlusion always; moving none (kind 1 base 2 head 3 moving, extended; conductor, suffocating, occlusion, -1 not stated)','CALL "RS1-PISTON-FLAGS" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3)',3,[(1,0),(1,1),(2,0),(3,0)],lambda k,e:{1:(0,int(not e),e),2:(0,-1,1),3:(0,0,0)}[k])
T(g,'delays (1): the family schedules no block ticks (-1); TICKS_TO_EXTEND 2; the placement on the third tick','CALL "RS1-PISTON-DELAYS" USING WS-R(1) WS-R(2) WS-R(3)',3,[(0,)],lambda x:(-1,2,3))
T(g,'block entity (1): type piston valid only on moving_piston, made only by code (id 11)','CALL "RS1-PISTON-BE" USING WS-I(1) WS-R(1) WS-R(2)',2,[(4,),(1,),(3,)],lambda b:(11,int(b==4)))
SU.write(g)
# ===== 2
g=SU.gen(2,'Triggering a piston','T0730','when the check runs, the power test with quasi-connectivity and the decision table.',TB)
def run(server,old_same,has_be): return int(server and not old_same and not has_be)
T(g,'when the check runs (2.1): on a server, from onPlace only when the old state is not the same block and there is no block entity (server, old same, block entity)','CALL "RS1-PISTON-CHECK-RUN" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(1,0,0),(0,0,0),(1,1,0),(1,0,1)],lambda *a:(run(*a),))
T(g,'head forwards (2.1): a head that can survive sends neighborChanged to the cell behind it','CALL "RS1-HEAD-FORWARD" USING WS-I(1) WS-R(1)',1,[(1,),(0,)],lambda c:(c,))
def nsig(f,t1,t2,t3):
    for d in range(6):
        if d!=f and t1[d]: return 1
    if t2: return 1
    for d in range(1,6):
        if t3[d]: return 1
    return 0
def sigcall(f,t1,t2,t3):
    return setarr('SG',list(t1)+[t2]+list(t3))+'MOVE %d TO WS-I(1)\nCALL "RS1-PISTON-NEIGHBOR-SIGNAL" USING WS-I(1) WS-SGG WS-R(1)'%f
def one(i,n=6): return tuple(1 if k==i else 0 for k in range(n))
NS=[(N,one(5),0,(0,)*6),(N,one(N),0,(0,)*6),(N,one(S_),0,(0,)*6),(N,(0,)*6,0,one(U)),(N,(0,)*6,0,one(E)),(N,(0,)*6,0,one(N)),(N,(0,)*6,0,one(D)),(N,(0,)*6,1,(0,)*6),(E,one(W),0,(0,)*6),(E,one(E),0,(0,)*6),(D,one(U),0,(0,)*6),(N,(0,)*6,0,(0,)*6)]
g.case('power test (2.2, 12.6): any side but the front, the piston cell itself, and the neighbours of the cell above except the one below it; a source in front does not power, a source in front of the cell above does',[("0",sigcall(*c),1) for c in NS]," ".join(show(nsig(*c)) for c in NS))
def decide(pw,ex,ok,tm,te,lt,same,hand):
    if pw and not ex: return (int(ok),0)
    if not pw and ex:
        t=1
        if tm and te and (lt or same or hand): t=2
        return (1,t)
    return (0,0)
DC=[(1,0,1,0,0,0,0,0),(1,0,0,0,0,0,0,0),(0,1,1,0,0,0,0,0),(0,1,1,1,1,1,0,0),(0,1,1,1,1,0,1,0),(0,1,1,1,1,0,0,1),(0,1,1,1,1,0,0,0),(0,1,1,1,0,1,0,0),(0,1,1,0,1,1,0,0),(1,1,1,0,0,0,0,0),(0,0,1,0,0,0,0,0)]
T(g,'decision (2.3): powered and retracted queues extend (type 0) when the resolver succeeds; unpowered and extended queues retract (1) or drop (2) when the moving block at two cells is an extending piston movement of the same facing and progress is below 0.5, ticked this tick or the level is handling a tick; otherwise nothing (queued, type; args powered, extended, resolve ok, two is moving, extending, progress below half, same tick, handling tick)','CALL "RS1-PISTON-DECIDE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-I(8) WS-R(1) WS-R(2)',2,DC,decide)
T(g,'event data (2.3): the facing data value (down 0, up 1, north 2, south 3, west 4, east 5)','CALL "RS1-FROM3D" USING WS-I(1) WS-R(1)',1,[(d,) for d in range(6)],lambda d:(d,))
SU.write(g)
# ===== 3
g=SU.gen(3,'The block event','T0732','the constants, the gate, the extend and contract steps, the sounds and from3D.')
T(g,'constants (3.1): TRIGGER_EXTEND 0, TRIGGER_CONTRACT 1, TRIGGER_DROP 2, PLATFORM_THICKNESS 4','CALL "RS1-PISTON-CONST" USING WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,[(0,)],lambda x:(0,1,2,4))
def j_rem(n): return abs(int(math.fmod(n,6)))
T(g,'from3D (3.1): index |n mod 6| with the Java remainder (6 is down, 7 is up, -1 is up)','CALL "RS1-FROM3D" USING WS-I(1) WS-R(1)',1,[(n,) for n in (-8,-7,-6,-1,0,5,6,7,11,13)],lambda n:(j_rem(n),))
T(g,'data bits (3.1): the low three bits are the facing','CALL "RS1-DATA-FACING" USING WS-I(1) WS-R(1)',1,[(0,),(5,),(8,),(13,)],lambda n:(n&7,))
def gate(server,pw,ty):
    if server and pw and ty in (1,2): return (0,1)
    if server and not pw and ty==0: return (0,2)
    return (1,0)
T(g,'gate (3.2): on a server, powered with type 1 or 2 cancels the retraction (mark extended with flag 2, return false); unpowered with type 0 cancels the extension (false); otherwise it continues (continue, action; server, powered, type)','CALL "RS1-PISTON-GATE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2)',2,[(1,1,1),(1,1,2),(1,0,0),(1,1,0),(1,0,1),(1,0,2),(0,1,1),(0,0,0)],gate)
T(g,'extend (3.2 type 0): when moveBlocks fails return false; else write the extended state with flags 67 (1 + 2 + 64), sound block.piston.extend at volume 0.5, game event BLOCK_ACTIVATE, return true (return, flags, sound, game event)','CALL "RS1-PISTON-EXTEND-STEP" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,[(1,),(0,)],lambda ok:(1,67,1,1) if ok else (0,0,0,0))
PT=[(0,0.0),(0,1.0),(0,0.5),(1,0.0),(1,0.8),(1,0.25)]
def pitch(k,r): return round((r*(0.25 if k==0 else 0.15)+0.6)*1000000)
g.run('pitch (3.2): extend nextFloat * 0.25 + 0.6, contract nextFloat * 0.15 + 0.6 (millionths)',[S(k,0,0)+" "+str(r) for k,r in PT],'CALL "RS1-PISTON-PITCH" USING WS-I(1) WS-FX(4) WS-R(1)',1," ".join(show(pitch(*c)) for c in PT))
def cplan(sticky,found,ty,air,push,pp,ispist):
    if not sticky: return 0
    if found: return 0
    if ty==1 and not air and push and (pp or ispist): return 1
    return 2
CP=[(1,1,1,0,1,1,0),(1,0,1,0,1,1,0),(1,0,1,0,1,0,1),(1,0,1,0,1,0,0),(1,0,2,0,1,1,0),(1,0,1,1,1,1,0),(1,0,1,0,0,1,0),(0,0,1,0,1,1,0)]
T(g,'contract sticky (3.2 types 1 and 2): a found extending movement stays; a type 1 block that is not air, pushable and PUSH_PULL or a piston is pulled (1); otherwise the head is removed (2); a non-sticky piston just removes the head (0) (args sticky, found moving, type, air, pushable, push pull, is a piston)','CALL "RS1-PISTON-CONTRACT-PLAN" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-R(1)',1,CP,lambda *a:(cplan(*a),))
T(g,'contract writes (3.2): the moving base is written with flags 276 (4 + 16 + 256), the head is removed with flags 3; sound block.piston.contract, game event BLOCK_DEACTIVATE; other types change nothing but return true (flags, remove flags, return)','CALL "RS1-PISTON-CONTRACT-STEP" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3)',3,[(1,),(2,),(5,)],lambda t:(276,3,1) if t in (1,2) else (0,0,1))
SU.write(g)
# ===== 5 first (the pushable table is used by 4)
KIND=[(1,0,0,0,0,0,0),(0,0,0,0,0,0,0),(0,0,0,0,0,0,1),(0,0,0,0,0,0,2),(0,0,0,0,3,0,0),(0,0,0,0,2,0,0),(0,0,0,0,1,0,0),(0,1,0,0,3,0,0),(0,1,1,0,3,0,0),(0,0,0,0,0,1,0),(0,0,0,1,0,0,0)]
SIZE=16
def idx(x,y,z): return (y-1)*256+(z-1)*16+x
def kind_at(grid,x,y,z):
    return grid.get((x,y,z),0)
def pushable(k,x,y,z,d,allow,pf,miny,maxy):
    air,pis,ext,unbr,react,be,st=KIND[k]
    if y<miny or y>maxy or not(1<=x<=SIZE) or not(1<=z<=SIZE): return 0
    if air: return 1
    if d==D and y==miny: return 0
    if d==U and y==maxy: return 0
    if pis:
        if ext: return 0
        return int(not be)
    if unbr: return 0
    if react==3: return 0
    if react==2: return int(allow)
    if react==1: return int(d==pf)
    return int(not be)
g=SU.gen(5,'What can be pushed','T0736','isPushable in rule order, the meaning of the push reactions and the entity classes that are ignored.',TB+NAME)
PU=[(0,0,5,3,N,0,2,1,7),(1,4,0,4,N,0,2,1,7),(0,4,4,4,N,0,2,1,7),(1,4,1,4,D,0,2,1,7),(1,4,7,4,U,0,2,1,7),(1,4,5,4,D,0,2,1,7),(8,4,4,4,N,0,2,1,7),(7,4,4,4,N,0,2,1,7),(10,4,4,4,N,0,2,1,7),(4,4,4,4,N,0,2,1,7),(5,4,4,4,N,0,2,1,7),(5,4,4,4,N,1,2,1,7),(6,4,4,4,E,0,E,1,7),(6,4,4,4,N,0,E,1,7),(1,4,4,4,N,0,2,1,7),(9,4,4,4,N,0,2,1,7),(2,4,4,4,N,0,2,1,7),(1,0,4,4,N,0,2,1,7),(1,17,4,4,N,0,2,1,7),(1,4,4,0,N,0,2,1,7),(1,4,4,17,N,0,2,1,7),(1,4,4,4,N,0,2,0,3)]
PU=[c if len(c)==9 else c for c in PU]
PU=[(k,x,y,z,d,a,pf,mn,mx) for (k,x,y,z,d,a,pf,mn,mx) in PU]
T(g,'isPushable (5.1): outside the world, air, vertical limits, an extended piston never, a retracted piston by rule 7, destroy speed -1, then the reaction (IMMOVEABLE no, POPPED only with allowDestroy, PUSH only along the piston facing), then no block entity (kind x y z direction allowDestroy facing minY maxY)','CALL "RS1-PSR-PUSHABLE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-I(8) WS-I(9) WS-R(1)',1,PU,lambda *a:(pushable(*a),))
T(g,'meaning (5.2, 5.3): glazed terracotta (PUSH) moves only along the facing, torches (POPPED) never move and break only on an extension or the forward scan, an unmovable block beside a branch does not block','CALL "RS1-PSR-PUSHABLE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-I(8) WS-I(9) WS-R(1)',1,[(6,3,3,3,E,0,E,1,7),(6,3,3,3,S_,0,E,1,7),(5,3,3,3,E,1,E,1,7),(5,3,3,3,E,0,E,1,7)],lambda *a:(pushable(*a),))
IGN=['AreaEffectCloud','Interaction','OminousItemSpawner','Marker','Display','ArmorStand','Cow','ItemEntity','Player']
def ign(n,mk): return int(n in ('AreaEffectCloud','Interaction','OminousItemSpawner','Marker','Display') or (n=='ArmorStand' and mk))
TN(g,'entity reactions (5.2): AreaEffectCloud, Interaction, OminousItemSpawner, Marker, the Display entities and a marker ArmorStand return IGNORE_ENTITY (1), every other entity PUSH_PULL (0)','CALL "RS1-ENTITY-REACTION" USING WS-NM WS-I(1) WS-R(1)',1,[(n,1) for n in IGN]+[('ArmorStand',0)],lambda n,mk:(ign(n,mk),))
SU.write(g)
# ===== 4 resolver (python literal model of 4.1 to 4.5)
def sticky(k): return KIND[k][6]
def can_stick(a,b):
    sa,sb=sticky(a),sticky(b)
    if sa==2 and sb==1: return False
    if sa==1 and sb==2: return False
    return sa>0 or sb>0
COV={}
def cv(k): COV[k]=COV.get(k,0)+1
def resolve(grid,pp,pf,ext,miny,maxy):
    px,py,pz=pp
    pdir=pf
    push=opp(pf) if not ext else pf
    sx,sy,sz=STEP[pf]
    start=(px+sx*(1 if ext else 2),py+sy*(1 if ext else 2),pz+sz*(1 if ext else 2))
    toPush=[];toDest=[]
    def add(p,d): return (p[0]+STEP[d][0],p[1]+STEP[d][1],p[2]+STEP[d][2])
    def K(p): return grid.get(p,0)
    def pus(p,d,allow,pfc): return pushable(K(p),p[0],p[1],p[2],d,allow,pfc,miny,maxy)
    def line(pos,dr):
        s=K(pos)
        if KIND[s][0]: return True
        if not pus(pos,push,False,dr): return True
        if pos==pp or pos in toPush: return True
        ln=1
        if ln+len(toPush)>12: return False
        if sticky(s):
            cur=pos;prev=s
            while True:
                nx=add(cur,opp(push)); nk=K(nx)
                if KIND[nk][0] or not can_stick(prev,nk) or not pus(nx,push,False,opp(push)) or nx==pp: break
                ln+=1
                if ln+len(toPush)>12: cv('chainlimit'); return False
                cv('chainjoin'); prev=nk;cur=nx
        for i in range(ln-1,-1,-1):
            p=pos
            for _ in range(i): p=add(p,opp(push))
            toPush.append(p)
        count=ln
        p=pos
        while True:
            p=add(p,push)
            if p in toPush:
                cv('collision'); idx0=toPush.index(p)
                A=toPush[:idx0];B=toPush[len(toPush)-count:];C=toPush[idx0:len(toPush)-count]
                toPush[:]=A+B+C
                for i in range(0,idx0+count+1):
                    if i<len(toPush) and sticky(K(toPush[i])):
                        cv('collbranch')
                        if not branch(toPush[i]): cv('collfail'); return False
                return True
            if KIND[K(p)][0]: return True
            if not pus(p,push,True,push) or p==pp: return False
            if KIND[K(p)][4]==2:
                toDest.append(p); return True
            if len(toPush)>=12: return False
            toPush.append(p); count+=1
    def branch(pos):
        s=K(pos)
        for d in range(6):
            if d//2==push//2: continue
            np_=add(pos,d); ns=K(np_)
            if not can_stick(ns,s): continue
            if not line(np_,d): return False
        return True
    s=K(start)
    if not pus(start,push,False,pf):
        if ext and KIND[s][4]==2:
            toDest.append(start); return True,toPush,toDest,push
        return False,toPush,toDest,push
    if not line(start,push): return False,toPush,toDest,push
    i=0
    while i<len(toPush):
        if sticky(K(toPush[i])):
            if not branch(toPush[i]): return False,toPush,toDest,push
        i+=1
    return True,toPush,toDest,push
g=SU.gen(4,'`PistonStructureResolver`','T0734','the resolver on small grids: limit, slime and honey, branches, collisions, destroy list, extension and retraction.',TB)
def gridlines(grid): return "".join('MOVE %d TO WS-GR(%d)\n'%(k,idx(*p)) for p,k in grid.items())
CLR='PERFORM VARYING WS-X FROM 1 BY 1 UNTIL WS-X > 4096\nMOVE 0 TO WS-GR(WS-X)\nEND-PERFORM\n'
EXTRA=" 01 WS-X                  BINARY-LONG.\n"
g.extra+=EXTRA
def enc(p): return idx(*p)
def rcase(grid,pp,pf,ext,miny=1,maxy=7):
    ok,tp,td,pd=resolve(grid,pp,pf,ext,miny,maxy)
    calls=[]
    call=CLR+gridlines(grid)+'MOVE %d TO WS-I(1)\nMOVE %d TO WS-I(2)\nMOVE %d TO WS-I(3)\nMOVE %d TO WS-I(4)\nMOVE %d TO WS-I(5)\nMOVE %d TO WS-I(6)\nMOVE %d TO WS-I(7)\n'%(pp[0],pp[1],pp[2],pf,int(ext),miny,maxy)
    call+='CALL "RS1-PISTON-RESOLVE" USING WS-GRG WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-R(1) WS-R(2) WS-PLG WS-R(3) WS-DLG WS-R(4)\n'
    calls.append(("0",call,4))
    calls.append(("0","".join('MOVE WS-PL(%d) TO WS-R(%d)\n'%(i,i) for i in range(1,13)).rstrip('\n'),12))
    calls.append(("0","".join('MOVE WS-DL(%d) TO WS-R(%d)\n'%(i,i) for i in range(1,5)).rstrip('\n'),4))
    pl=[enc(p) for p in tp]+[0]*(12-len(tp)); dl=[enc(p) for p in td]+[0]*(4-len(td))
    return calls,show(int(ok),len(tp),len(td),pd)+" "+show(pl)+" "+show(dl)
def run(text,cases):
    for n,c in enumerate(cases):
        calls,e=rcase(*c)
        g.case(text+(' [run %d]'%(n+1) if len(cases)>1 else ''),calls,e)
def row(n,k=1,y=4,z=4,x0=5): return {(x0+i,y,z):k for i in range(n)}
# 12.1 and 12.2
run('simple extension (12.1): a stone in front of an east piston is pushed (ok, pushed, destroyed, direction, then the pushed cells, the destroyed cells)',[({(5,4,4):1},(4,4,4),E,True)])
run('push count (12.2): short lines and a line of 12 split over two rows are all pushed',[(row(6,1,4,4,2),(1,4,4),E,True),({(x,4,4):1 for x in range(2,8)}|{(x,5,4):1 for x in range(2,8)},(1,4,4),E,True)])
run('obsidian and torch (12.3): obsidian blocks, a torch at the start cell is destroyed on an extension and the head moves in',[({(5,4,4):4},(4,4,4),E,True),({(5,4,4):5},(4,4,4),E,True),({(5,4,4):5},(4,4,4),E,False)])
run('slime branch (12.4): a slime block drags the stone above it and beside it; a honey block beside slime is not dragged',[({(5,4,4):2,(5,4,5):1,(5,5,4):1},(4,4,4),E,True),({(5,4,4):2,(5,4,5):3,(5,5,4):1},(4,4,4),E,True),({(5,4,4):3,(5,4,5):2},(4,4,4),E,True),({(5,4,4):2,(5,4,5):4,(5,5,4):1},(4,4,4),E,True)])
run('retraction (4.1, 12.5): the start cell is two ahead, blocks move towards the piston; air resolves to nothing; a torch is never destroyed by a retraction',[({(6,4,4):1},(4,4,4),E,False),({},(4,4,4),E,False),({(6,4,4):5},(4,4,4),E,False),({(6,4,4):2,(6,5,4):1},(4,4,4),E,False)])
run('blocked pushes (4.2, 4.3): an immovable block, an extended piston, a chest, bedrock and the world edge stop the push',[({(5,4,4):1,(6,4,4):4},(4,4,4),E,True),({(5,4,4):8},(4,4,4),E,True),({(5,4,4):9},(4,4,4),E,True),({(5,4,4):1,(6,4,4):10},(4,4,4),E,True),({(x,4,4):1 for x in range(5,8)},(4,4,4),E,True),({(4,7,4):1},(4,6,4),U,True)])
run('back chain (4.3 step 5): slime pulls the blocks behind it that stick; the piston cell ends the chain; a stone behind slime joins, a stone behind stone does not start one',[({(5,4,4):1,(6,4,4):2},(4,4,4),E,True),({(5,4,4):2,(6,4,4):1},(4,4,4),E,True),({(5,4,4):2,(6,4,4):2,(7,4,4):1},(3,4,4),E,True)])
run('collision (4.3 step 7.1, 4.4): two branches meeting in one line reorder the list and branch from the earlier entries',[({(3,4,4):2,(3,4,5):1,(4,4,5):1,(5,4,5):1,(4,4,4):1,(5,4,4):2},(2,4,4),E,True),({(3,4,4):2,(3,5,4):1,(4,5,4):1,(4,4,4):2},(2,4,4),E,True)])
rnd=[]
kinds=[1,1,1,1,2,2,3,3,1,2,4,5,6,7,8,9,10]
for n in range(48):
    grid={}
    for x in range(1,8):
        for y in range(1,8):
            for z in range(1,8):
                if RNG.random()<0.5: grid[(x,y,z)]=RNG.choice(kinds)
    pp=(RNG.randint(2,6),RNG.randint(2,6),RNG.randint(2,6))
    grid.pop(pp,None)
    rnd.append((grid,pp,RNG.randint(0,5),RNG.random()<0.6))
rnd2=[]
for n in range(40):
    grid={}
    pf=RNG.choice([E,W,N,S_,U,D]); ext=RNG.random()<0.7
    pp=(8,8,8)
    st=STEP[pf]
    for i in range(1 if ext else 2, RNG.randint(2,8)):
        p=(8+st[0]*i,8+st[1]*i,8+st[2]*i)
        grid[p]=RNG.choice([1,1,1,2,2,3,5,4,6,9])
    for q in range(RNG.randint(0,14)):
        p=(RNG.randint(5,11),RNG.randint(5,11),RNG.randint(5,11))
        if p!=pp and RNG.random()<0.8: grid[p]=RNG.choice([1,1,2,3,4,1,6,10])
    rnd2.append((grid,pp,pf,ext,1,16))
run('line grids (4): 40 runs with a line of blocks in front of (or two cells ahead of) the piston and scattered neighbours agree with the model',rnd2)
TGT={'collision':3,'collfail':2,'chainlimit':2}
found={k:[] for k in TGT}
R2=random.Random(77)
tries=0
while any(len(found[k])<TGT[k] for k in TGT) and tries<200000:
    tries+=1
    grid={}
    for x in range(6,11):
        for y in range(6,10):
            for z in range(6,10):
                if R2.random()<0.55: grid[(x,y,z)]=R2.choice([2,2,3,1,1,5,4,6])
    pf=R2.choice([E,W,N,S_,U,D]); ext=R2.random()<0.8
    pp=(8,8,8); grid.pop(pp,None)
    before=dict(COV)
    r=resolve(grid,pp,pf,ext,1,16)
    for k in TGT:
        if COV.get(k,0)>before.get(k,0) and len(found[k])<TGT[k]: found[k].append((grid,pp,pf,ext,1,16))
for k in TGT:
    if len(found[k])<TGT[k]: sys.stderr.write('NOT FOUND '+k+'\n')
    run('targeted '+k+' (4.3 step 5, 4.4, 7.1): grids found by search that reach the '+{'collision':'collision reorder of two branches','collfail':'failure of a branch run after a collision','chainlimit':'push limit inside a backward chain'}[k],found[k])
run('random grids (4): 48 resolver runs on 7 x 7 x 7 grids of stone, slime, honey, obsidian, torch, glazed, pistons, chest and bedrock agree with the literal model of 4.1 to 4.5',rnd)
run('push limit exact (12.2, 4.3 step 4): 12 stones east of the piston push, a 13th makes the resolver fail',[({(x,4,4):1 for x in range(2,2+n)},(1,4,4),E,True) for n in (12,13)])
SU.write(g)
# ===== 6 moveBlocks
def bucket(x,y,z):
    h=(((y+z*31)*31+x))&0xFFFFFFFF
    return (h^(h>>16))&15
def dec(i):
    i-=1
    return (i%16+1,i//256+1,(i%256)//16+1)
def mplan(ext,f,px,py,pz,headIsHead,push,dest,org):
    ops=[]
    md=f if ext else opp(f)
    hp=(px+STEP[f][0],py+STEP[f][1],pz+STEP[f][2])
    if not ext and headIsHead: ops.append((1,idx(*hp)))
    for d in reversed(dest): ops.append((2,d))
    oldAt=[dec(i) for i in push]
    for p in reversed(push):
        q=dec(p); dst=(q[0]+STEP[md][0],q[1]+STEP[md][1],q[2]+STEP[md][2])
        ops.append((3,idx(*dst)))
        if dst in oldAt: oldAt.remove(dst)
    if ext:
        ops.append((4,idx(*hp)))
        if hp in oldAt: oldAt.remove(hp)
    order=sorted(range(len(oldAt)),key=lambda i:(bucket(oldAt[i][0]+org[0],oldAt[i][1]+org[1],oldAt[i][2]+org[2]),i))
    vac=[oldAt[i] for i in order]
    for q in vac: ops.append((5,idx(*q)))
    for q in vac: ops.append((6,idx(*q)))
    for d in reversed(dest): ops.append((7,d))
    for p in reversed(push): ops.append((8,p))
    if ext: ops.append((9,idx(*hp)))
    return ops
g=SU.gen(6,'`moveBlocks`','T0738','the order of the writes, the vacated-cell map order and the notification order.',TB)
def mcase(text,ext,f,pp,head,push,dest,org=(0,0,0)):
    ops=mplan(ext,f,pp[0],pp[1],pp[2],head,push,dest,org)
    call=setarr('PL',push)+setarr('DL',dest)+'MOVE %d TO WS-I(1)\nMOVE %d TO WS-I(2)\nMOVE %d TO WS-I(3)\nMOVE %d TO WS-I(4)\nMOVE %d TO WS-I(5)\nMOVE %d TO WS-I(6)\nMOVE %d TO WS-I(7)\nMOVE %d TO WS-I(8)\nMOVE %d TO WS-I(9)\nMOVE %d TO WS-I(10)\n'%(int(ext),f,pp[0],pp[1],pp[2],int(head),len(push),len(dest),org[0],org[1])
    call+='MOVE %d TO WS-I(11)\nCALL "RS1-PISTON-MOVEPLAN" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-PLG WS-I(8) WS-DLG WS-I(9) WS-I(10) WS-I(11) WS-R(1) WS-OPG\n'%org[2]
    code=[o*10000+i for o,i in ops]
    calls=[("0",call,1)]
    for k in range(0,len(code),16):
        calls.append(("0","".join('MOVE WS-OP(%d) TO WS-R(%d)\n'%(k+j+1,j+1) for j in range(min(16,len(code)-k))).rstrip('\n'),min(16,len(code)-k)))
    g.case(text,calls,show(len(code))+" "+" ".join(show(code[k:k+16]) for k in range(0,len(code),16)))
P1=idx(5,4,4)
mcase('extension (6 steps 6 to 13, 12.1): the pushed stone gets a moving block at its destination, the head a moving block in the start cell, nothing is vacated; notifications run pushed cells then the head',True,E,(4,4,4),False,[P1],[])
mcase('retraction (6 step 1): the head is removed first, the pulled block moves towards the piston and its old cell is vacated (12.5)',False,E,(4,4,4),True,[idx(6,4,4)],[])
mcase('destroy first (6 steps 5, 11): destroyed blocks are processed from the last entry to the first, then the pushed blocks far end first; notifications destroyed cells first',True,E,(2,4,4),False,[idx(3,4,4),idx(4,4,4)],[idx(5,4,4),idx(5,4,5)])
mcase('slime branches (6 steps 6 to 9): four pushed cells; vacated cells in the HashMap order of the position hash',True,E,(4,4,4),False,[idx(5,4,4),idx(5,5,4),idx(5,4,5),idx(5,3,4)],[])
mcase('map order with large coordinates (6.1): the same cells shifted by an origin change the bucket order',True,E,(4,4,4),False,[idx(5,4,4),idx(5,5,4),idx(5,4,5),idx(5,3,4)],[],(30000000,200,-29999990))
mcase('upward push (6): a vertical move vacates the bottom cell only; stacks in order',True,U,(4,4,4),False,[idx(4,5,4),idx(4,6,4),idx(4,7,4)],[])
mcase('torch destroyed on an extension (12.3): the torch is written as air with flags 18, no block is pushed, the head moves in',True,E,(4,4,4),False,[],[idx(5,4,4)])
rr=[]
for n in range(6):
    k=RNG.randint(1,6); cells=set()
    while len(cells)<k: cells.add((RNG.randint(3,8),RNG.randint(3,8),RNG.randint(3,8)))
    rr.append(sorted(idx(*c) for c in cells))
for n,pl in enumerate(rr):
    mcase('random vacated order [%d] (6.1): the bucket order of positions as the Java HashMap, insertion order inside a bucket'%(n+1),True,RNG.choice([E,W,N,S_,U,D]),(2,2,2),False,pl,[],(RNG.randint(-1000,1000),RNG.randint(0,255),RNG.randint(-1000,1000)))
T(g,'write flags (6, 11): destroyed 18, moving blocks 324, vacated 82, head removal and moving base 276, finished 67, shape-update placement 340, cancelled marker 2','CALL "RS1-PISTON-WRITE-FLAGS" USING WS-I(1) WS-R(1)',1,[(i,) for i in range(1,8)],lambda i:({1:18,2:324,3:82,4:276,5:67,6:340,7:2}[i],))
SU.write(g)
# ===== 7 moving block
g=SU.gen(7,'The moving block and its block entity','T0740','constants, offsets, the tick, the forced finish, collision choices, NBT and the other users of moving_piston.',FL)
T(g,'constants (7.1): TICKS_TO_EXTEND 2, PUSH_OFFSET 0.01 and TICK_MOVEMENT 0.51 (x 100)','CALL "RS1-MBE-CONST" USING WS-R(1) WS-R(2) WS-R(3)',3,[(0,)],lambda x:(2,1,51))
def off(ext,p,d):
    e=(p-1) if ext else (1-p)
    return tuple(round(e*s*1000000) for s in STEP[d])
OF=[(1,0.0,E),(1,0.5,E),(1,1.0,E),(0,0.0,E),(0,0.5,N),(0,1.0,U),(1,0.25,D)]
g.run('offset (7.1): extendedProgress is p - 1 when extending else 1 - p, along step(direction); at progress 0 an extending block sits one cell behind, a retracting one one cell ahead (millionths)',[S(e,0,d)+" "+str(p) for e,p,d in OF],'CALL "RS1-MBE-OFFSET" USING WS-I(1) WS-FX(4) WS-I(3) WS-R(1) WS-R(2) WS-R(3)',3," ".join(show(off(*c)) for c in OF))
GP=[(0.0,0.5,0.0),(0.0,0.5,1.0),(0.5,1.0,0.5),(0.5,1.0,2.0),(1.0,1.0,0.3)]
g.run('getProgress (7.1): lerp(min(partial, 1), progressO, progress) (millionths)',[S(0,0,0)+" "+" ".join(str(x) for x in c) for c in GP],'CALL "RS1-MBE-PROGRESS" USING WS-FX(4) WS-FX(5) WS-FX(6) WS-R(1)',1," ".join(show(round((c[0]+min(c[2],1)*(c[1]-c[0]))*1000000)) for c in GP))
def mtick(po,client,death,still,newair):
    if po>=1:
        if client and death<5: return (1,death+1,0)
        return (2,death,(0 if not still else (1 if newair else 2)))
    return (3,death,0)
TK=[(0.0,0,0,1,0),(0.5,0,0,1,0),(1.0,0,0,1,0),(1.0,0,0,0,0),(1.0,0,0,1,1),(1.0,1,0,1,0),(1.0,1,4,1,0),(1.0,1,5,1,0),(1.0,1,5,0,0)]
g.run('tick (7.2): below 1 the entity advances; at progressO 1 a client entity lingers while deathTicks < 5; then the entity is removed and, when the block is still moving_piston, a state that shape-updates to air is set with flags 340 and destroyed (1) else placed with flags 67 (2) (step 1 linger 2 finish 3 move, deathTicks, finish action)',[str(po)+" "+S(client,death,still,newair) for po,client,death,still,newair in TK],'CALL "RS1-MBE-TICK" USING WS-FX(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1) WS-R(2) WS-R(3)',3," ".join(show(mtick(*c)) for c in TK))
T(g,'advance (7.2 step 3): progress + 0.5 capped at 1 (0, 0.5, 1.0 in two ticks; placed on the third) (millionths)','CALL "RS1-MBE-ADVANCE" USING WS-I(1) WS-R(1)',1,[(0,),(500000,),(1000000,)],lambda p:(min(p+500000,1000000),))
def fin(hl,po,cl,still,src):
    if not hl or not (po<1 or cl): return 0
    if not still: return 1
    return 2 if src else 3
FN=[(0,0.0,0,1,1),(1,1.0,0,1,1),(1,1.0,1,1,1),(1,0.5,0,1,1),(1,0.5,0,1,0),(1,0.5,0,0,0)]
g.run('finalTick (7.4): nothing without a level or at progressO >= 1 on a server; else the entity is removed and, when still moving_piston, a source becomes air (flags 3) and anything else its shape-updated state (0 nothing, 1 removed only, 2 air, 3 place)',[S(hl,po,cl,still,src) for hl,po,cl,still,src in FN],'CALL "RS1-MBE-FINAL" USING WS-I(1) WS-FX(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1)',1," ".join(show(fin(*c)) for c in FN))
def hs(ext,p): return int(ext!=((1-p)<0.25))
HS=[(1,0.0),(1,0.75),(1,0.7500001),(1,0.9),(0,0.0),(0,0.75),(0,0.7500001),(0,1.0)]
g.run('collision head (7.5 step 3): short equals (extending != (1 - progress < 0.25)): extending is short while progress <= 0.75, retracting once progress > 0.75',[S(e,p) for e,p in HS],'CALL "RS1-MBE-HEAD-SHORT" USING WS-I(1) WS-FX(2) WS-R(1)',1," ".join(show(hs(*c)) for c in HS))
RS=[0.0,0.25,0.2500001,0.5,1.0]
g.run('related state (7.5): a retracting source piston uses a head with short = progress > 0.25',[str(p) for p in RS],'CALL "RS1-MBE-REL-SHORT" USING WS-FX(1) WS-R(1)',1," ".join(show(int(p>0.25)) for p in RS))
CL=[(0,1,1,0.5,1),(0,1,1,0.5,0),(1,1,1,0.5,1),(0,0,1,0.5,1),(0,1,0,0.5,1),(0,1,1,1.0,1)]
g.run('collision shape (7.5 steps 1 and 2): the base is the extended base slab only for a retracting source piston base; with progress < 1 and NOCLIP equal to the movement direction only the base is returned (extending, source, moved is a base; base extended, base only)',[S(e,s,b,p,n) for e,s,b,p,n in CL],'CALL "RS1-MBE-COLLISION" USING WS-I(1) WS-I(2) WS-I(3) WS-FX(4) WS-I(5) WS-R(1) WS-R(2)',2," ".join(show(int(not e and s and b),int(p<1 and n)) for e,s,b,p,n in CL))
T(g,'NBT defaults (7.6): blockState air, facing DOWN (0), progress 0.0, extending false, source false','CALL "RS1-MBE-NBT-DEFAULTS" USING WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5,[(0,)],lambda x:(1,0,0,0,0))
T(g,'NBT facing (7.6): saved as the data value, loaded with abs(n mod 6)','CALL "RS1-FROM3D" USING WS-I(1) WS-R(1)',1,[(0,),(5,),(6,),(7,),(-1,),(12,)],lambda n:(abs(int(math.fmod(n,6))),))
T(g,'NBT progress (7.6): saved as progressO (millionths); on load progress and progressO are both set to it','CALL "RS1-MBE-NBT-PROGRESS" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3)',3,[(250000,500000),(0,0),(1000000,1000000)],lambda po,p:(po,po,po))
T(g,'setLevel (7.6): if the registry no longer holds the moved block it becomes air','CALL "RS1-MBE-SETLEVEL" USING WS-I(1) WS-R(1)',1,[(0,),(1,)],lambda h:(0 if h else 1,))
T(g,'falling blocks (7.7): a landing on moving_piston multiplies the delta movement by (0.7, -0.5, 0.7) (x 1000) and places nothing','CALL "RS1-FALLING-MULT" USING WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,[(0,)],lambda x:(700,-500,700,0))
T(g,'block collisions (7.7): mode 0 considers every cell, mode 1 skips states without a large collision shape, mode 2 only moving_piston (mode, moving, large shape)','CALL "RS1-BC-CONSIDER" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(m,mv,l) for m in (0,1,2) for mv in (0,1) for l in (0,1)],lambda m,mv,l:(1 if m==0 else (l if m==1 else mv),))
T(g,'shulker (7.7): a non-air cell blocks unless it is moving_piston at the shulker own position; air never blocks (non air, moving, own)','CALL "RS1-SHULKER-BLOCKED" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(0,0,0),(1,0,0),(1,1,0),(1,1,1),(1,0,1)],lambda n,m,o:(int(n and not (m and o)),))
TAGS={1:(2,3,4),2:(2,3,4),3:(2,3,4),4:(5,),5:(1,2,3,4)}
T(g,'tags (7.7): moving_piston is in dragon_immune, wither_immune and maintains_farmland; piston, sticky_piston, piston_head in mineable/pickaxe; all four in blocks_motion_no_leaves (tag 1 dragon_immune 2 wither_immune 3 maintains_farmland 4 mineable/pickaxe 5 blocks_motion_no_leaves; block 1 piston 2 sticky 3 head 4 moving)','CALL "RS1-PISTON-TAG" USING WS-I(1) WS-I(2) WS-R(1)',1,[(t,b) for t in range(1,6) for b in range(1,5)],lambda t,b:(int({1:b==4,2:b==4,3:b==4,4:b in (1,2,3),5:True}[t]),))
SU.write(g)
# ===== 8 entities
g=SU.gen(8,'Entities','T0742','movement area, overlap depth, the per-tick limit, the push amount, slime, honey and the base fix.',' 01 WS-A6G.\n    05 WS-A6 FLOAT-LONG OCCURS 6 TIMES.\n 01 WS-E6G.\n    05 WS-E6 FLOAT-LONG OCCURS 6 TIMES.\n 01 WS-O6G.\n    05 WS-O6 FLOAT-LONG OCCURS 6 TIMES.\n 01 WS-A3G.\n    05 WS-A3 FLOAT-LONG OCCURS 3 TIMES.\n 01 WS-M3G.\n    05 WS-M3 FLOAT-LONG OCCURS 3 TIMES.\n 01 WS-B3G.\n    05 WS-B3 FLOAT-LONG OCCURS 3 TIMES.\n'+NAME)
def fa(name,vals): return "".join('MOVE %s TO WS-%s(%d)\n'%('%.10f'%v,name,i+1) for i,v in enumerate(vals))
def area(b,d,dl):
    m=dl*(1 if d in (E,S_,U) else -1)
    lo=min(m,0);hi=max(m,0)
    x0,y0,z0,x1,y1,z1=b
    if d==W: x0,x1=x0+lo,x0+hi
    if d==E: x0,x1=x1+lo,x1+hi
    if d==D: y0,y1=y0+lo,y0+hi
    if d==U: y0,y1=y1+lo,y1+hi
    if d==N: z0,z1=z0+lo,z0+hi
    if d==S_: z0,z1=z1+lo,z1+hi
    return tuple(round(v*1000000) for v in (x0,y0,z0,x1,y1,z1))
BX=(1.0,2.0,3.0,2.0,3.0,4.0)
cs_=[];ex=[]
for d in range(6):
    cs_.append(("0",fa('A6',BX)+'MOVE %d TO WS-I(1)\nCALL "RS1-PM-AREA" USING WS-A6G WS-I(1) WS-FX(2) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-R(6)'%d,6)); ex.append(show(area(BX,d,0.5)))
for i,cs in enumerate(cs_): pass
cs2=[(a,b.replace('WS-FX(2)','WS-FX(2)'),c) for a,b,c in cs_]
g.case('getMovementArea (8.1): m = delta * step(axis direction), lo = min(m, 0), hi = max(m, 0); on the axis of dir the slab [min or max + lo, + hi], the other axes keep the extents (delta 0.5, one box, six directions)',[("0 0.5",c[1],6) for c in cs_]," ".join(ex))
def mov(a,e,d):
    return round({E:a[3]-e[0],W:e[3]-a[0],U:a[4]-e[1],D:e[4]-a[1],S_:a[5]-e[2],N:e[5]-a[2]}[d]*1000000)
AR=(1.0,2.0,3.0,1.5,3.0,4.0); EB=(1.25,2.5,3.25,2.0,4.5,3.75)
cs_=[];ex=[]
for d in range(6):
    cs_.append(("0",fa('A6',AR)+fa('E6',EB)+'MOVE %d TO WS-I(1)\nCALL "RS1-PM-MOVEMENT" USING WS-A6G WS-E6G WS-I(1) WS-R(1)'%d,1)); ex.append(show(mov(AR,EB,d)))
g.case('getMovement (8.1): the overlap depth along dir: EAST area.maxX - e.minX, WEST e.maxX - area.minX, UP, DOWN, SOUTH, NORTH likewise (millionths)',cs_," ".join(ex))
def lim(acc,mv):
    if sum(x*x for x in mv)<=1e-7: return (0,0,0),tuple(acc)
    ax=[i for i in range(3) if mv[i]!=0][0]
    na=list(acc); na[ax]=max(-0.51,min(0.51,acc[ax]+mv[ax]))
    al=na[ax]-acc[ax]
    out=[0,0,0]
    if abs(al)<=9.999999747378752e-6: return (0,0,0),tuple(na)
    out[ax]=al
    return tuple(round(v*1000000) for v in out),tuple(na)
LM=[((0.0,0.0,0.0),(0.5,0.0,0.0)),((0.4,0.0,0.0),(0.5,0.0,0.0)),((0.0,0.0,0.0),(0.0,0.0,-0.6)),((0.0,0.0,0.0),(0.0,0.3,0.4)),((0.0,0.0,0.0),(0.0,0.0,0.0000001)),((0.51,0.0,0.0),(0.2,0.0,0.0)),((-0.2,0.0,0.0),(0.3,0.0,0.0)),((0.0,0.0,0.0),(0.000005,0.0,0.0))]
cs_=[];ex=[]
for acc,mv in LM:
    r=lim(acc,mv)
    cs_.append(("0",fa('A3',acc)+fa('M3',mv)+'CALL "RS1-EP-LIMIT" USING WS-A3G WS-M3G WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-R(6)',6)); ex.append(show(r[0],[round(v*1000000) for v in r[1]]))
g.case('limitPistonMovement (8.3): below 1e-7 squared length unchanged; the first non-zero axis in the order X, Y, Z; the accumulator is clamped to +-0.51; a change of at most 9.999999747378752e-6 is dropped (allowed x y z, new accumulator x y z; millionths)',cs_," ".join(ex))
def coll(ig,sl,cs,mp,dl):
    if ig: return (1,0,0)
    if mp<=0: return (1,int(sl and cs),0)
    return (0,int(sl and cs),round((min(mp,dl)+0.01)*1000000))
CO=[(1,0,0,0.3,0.5),(0,0,0,0.0,0.5),(0,0,0,-0.1,0.5),(0,1,1,0.3,0.5),(0,1,0,0.3,0.5),(0,0,0,0.3,0.5),(0,0,0,0.7,0.5),(0,0,0,0.5,0.5)]
g.run('per entity (8.1 steps 1 to 5): IGNORE_ENTITY is skipped; a slime block sets the delta movement to step(dir) for entities that can simulate movement; maxPush <= 0 skips; push = min(maxPush, delta) + 0.01 (skip, set delta, push in millionths)',[S(ig,sl,cs)+" 0 "+str(mp)+" "+str(dl) for ig,sl,cs,mp,dl in CO],'CALL "RS1-EP-COLLIDED" USING WS-I(1) WS-I(2) WS-I(3) WS-FX(5) WS-FX(6) WS-R(1) WS-R(2) WS-R(3)',3," ".join(show(coll(*c)) for c in CO))
def stk(react,og,sup,xin,zin): return int(react==0 and og and (sup or (xin and zin)))
SK=[(0,1,1,0,0),(0,1,0,1,1),(0,1,0,1,0),(0,0,1,1,1),(1,1,1,1,1),(0,1,0,0,0)]
T(g,'sticky test (8.2): the push reaction is PUSH_PULL, the entity is on the ground, and it is supported by the block or its x and z lie inside the area (reaction, on ground, supported, x in, z in)','CALL "RS1-STICKY-MATCH" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1)',1,SK,lambda *a:(stk(*a),))
T(g,'honey (8.2): only a honey block moving horizontally; probe box top 1.500001 (x 1000000)','CALL "RS1-HONEY-PROBE" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2)',2,[(1,N),(1,E),(1,U),(0,E),(1,D)],lambda h,d:(int(h and d>=2),1500001))
def fix(g1,g2,dl):
    d1=g1+0.01;d2=g2+0.01
    if abs(d1-d2)<0.01: return (1,round((min(d1,dl)+0.01)*1000000))
    return (0,0)
FX=[(0.1,0.1,0.5),(0.3,0.1,0.5),(0.495,0.5,0.5),(0.1,0.2,0.2),(0.1,0.1,0.05)]
g.run('fixEntityWithinPistonBase (8.4): d1 = depth + 0.01, d2 = depth of the clipped box + 0.01; when |d1 - d2| < 0.01 the entity is moved by min(d1, delta) + 0.01 along the back direction (apply, amount in millionths)',[S(0,0,0)+" "+" ".join(str(x) for x in c) for c in FX],'CALL "RS1-EP-FIX" USING WS-FX(4) WS-FX(5) WS-FX(6) WS-R(1) WS-R(2)',2," ".join(show(fix(*c)) for c in FX))
T(g,'moveEntityByPiston (8.3): NOCLIP is set to the noclip direction for the move and cleared after; a stuck speed multiplier is not applied to a piston movement but is reset','CALL "RS1-EP-MOVER" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3)',3,[(1,),(0,)],lambda p:(1,int(not p),1))
SU.write(g)
# ===== 9 shapes
g=SU.gen(9,'Shapes, survival and breaking','T0744','the base and head boxes, head survival and breaking, the clone item and the moving block use.')
def base(f,ext):
    if not ext: return (0,0,0,16,16,16)
    b=[0,0,0,16,16,16]
    if f==N: b[2]=4
    if f==S_: b[5]=12
    if f==W: b[0]=4
    if f==E: b[3]=12
    if f==D: b[1]=4
    if f==U: b[4]=12
    return tuple(b)
T(g,'base (9.1): a full cube retracted; extended a 12 thick box flush against the back: north z 4..16, south z 0..12, west x 4..16, east x 0..12, down y 4..16, up y 0..12','CALL "RS1-PISTON-SHAPE-BASE" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-R(6)',6,[(f,e) for e in (0,1) for f in range(6)],base)
def head(f,short,part):
    b=[0,0,0,16,16,16]
    if part==1:
        if f==N: b[5]=4
        if f==S_: b[2]=12
        if f==W: b[3]=4
        if f==E: b[0]=12
        if f==D: b[4]=4
        if f==U: b[1]=12
        return tuple(b)
    b=[6,6,6,10,10,10]
    ln=16 if short else 20
    ax={N:(2,4,ln),S_:(2,ln-16,12),W:(0,4,ln),E:(0,ln-16,12),D:(1,4,ln),U:(1,ln-16,12)}[f]
    a,lo,hi=ax
    if f in (N,W,D): b[a]=4;b[a+3]=ln
    else: b[a]=ln-16 if not short else 0; b[a+3]=12
    return tuple(b)
def headx(f,short,part):
    if part==1: return head(f,short,1)
    b=[6,6,6,10,10,10]
    arm={ (N,0):(2,4,20),(N,1):(2,4,16),(S_,0):(2,-4,12),(S_,1):(2,0,12),(W,0):(0,4,20),(W,1):(0,4,16),(E,0):(0,-4,12),(E,1):(0,0,12),(D,0):(1,4,20),(D,1):(1,4,16),(U,0):(1,-4,12),(U,1):(1,0,12)}[(f,short)]
    a,lo,hi=arm; b[a]=lo; b[a+3]=hi
    return tuple(b)
T(g,'head (9.2): platform 4 thick on the facing side and an arm of 4 x 4, long (extends back 16) or short (12): north z 4..20 or 4..16, south z -4..12 or 0..12, and the rotations (facing, short, part 1 platform 2 arm)','CALL "RS1-PISTON-SHAPE-HEAD" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-R(6)',6,[(f,s,p) for p in (1,2) for s in ((0,) if p==1 else (0,1)) for f in range(6)],headx)
def fitting(ht,bb,ext,same): return int((ht==0 and bb==1 or ht==1 and bb==2) and ext and same)
FT=[(0,1,1,1),(1,2,1,1),(0,2,1,1),(1,1,1,1),(0,1,0,1),(0,1,1,0),(0,0,1,1)]
T(g,'isFittingBase (9.3): piston for a normal head, sticky_piston for a sticky head, extended and the same facing (head type, block behind 1 piston 2 sticky 0 other, extended, same facing)','CALL "RS1-HEAD-FITTING" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1,FT,lambda *a:(fitting(*a),))
T(g,'head survival (9.3): the block behind is a fitting base or a moving_piston with the same facing (fitting, moving, same facing)','CALL "RS1-HEAD-SURVIVE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(1,0,0),(0,1,1),(0,1,0),(0,0,1),(0,0,0)],lambda f,m,s:(int(f or (m and s)),))
T(g,'head updateShape (9.3): the neighbour behind (opp(d) == facing) with a head that cannot survive gives air (direction, facing, canSurvive)','CALL "RS1-WALL-TORCH-SU" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(3,2,0),(3,2,1),(2,2,0),(4,5,0)],lambda d,f,c:(int(d==opp(f) and not c),))
T(g,'creative break (9.3): on a server a creative player breaking the head destroys a fitting base without drops (server, creative, fitting)','CALL "RS1-HEAD-WILL-DESTROY" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(1,1,1),(0,1,1),(1,0,1),(1,1,0)],lambda s,c,f:(int(s and c and f),))
T(g,'removal (9.3): a fitting base behind a removed head is destroyed with drops; a moving_piston behind is not (fitting)','CALL "RS1-HEAD-REMOVED" USING WS-I(1) WS-R(1)',1,[(1,),(0,)],lambda f:(f,))
T(g,'clone item (9.3): piston for the normal head, sticky_piston for the sticky head (1 piston, 2 sticky_piston)','CALL "RS1-HEAD-CLONE" USING WS-I(1) WS-R(1)',1,[(0,),(1,)],lambda t:(t+1,))
T(g,'moving destroy (9.3): the cell behind a moving block that is an extended piston base is removed without drops (behind is an extended base)','CALL "RS1-MOVING-DESTROY" USING WS-I(1) WS-R(1)',1,[(1,),(0,)],lambda b:(b,))
T(g,'moving use and drops (9.3): on a server without a block entity the block is removed and the use consumed (1); otherwise pass (0); drops are those of the moved state when the entity exists (server, block entity; consumed, drops)','CALL "RS1-MOVING-USE" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2)',2,[(1,0),(1,1),(0,0),(0,1)],lambda s,b:(int(s and not b),b))
SU.write(g)
# ===== 10 client
g=SU.gen(10,'Client','T0746','the client branch of the block event, the lingering moving block and the rendering numbers.',FL)
T(g,'client event (10.1): the client skips the power re-check and both cancel rules (client; re-check, cancel rules)','CALL "RS1-CLIENT-EVENT" USING WS-I(1) WS-R(1) WS-R(2)',2,[(1,),(0,)],lambda c:(int(not c),int(not c)))
def mtick2(po,client,death):
    return mtick(po,client,death,1,0)
T(g,'lingering (10.1, 7.2): at progressO >= 1 a client entity waits 5 more ticks (step 1) before it removes itself and places the block (2)','CALL "RS1-MBE-LINGER" USING WS-I(1) WS-R(1) WS-R(2)',2,[(d,) for d in range(7)],lambda d:(1,d+1) if d<5 else (2,d))
def rshort(m,p): return int(p<=0.5) if m==1 else int(p>=0.5)
RH=[(1,0.0),(1,0.5),(1,0.5000001),(2,0.4999999),(2,0.5),(2,1.0)]
g.run('head state drawn (10.2): a pushed block or extending head draws short = progress <= 0.5; a retracting source head short = progress >= 0.5',[S(m,p) for m,p in RH],'CALL "RS1-RENDER-SHORT" USING WS-I(1) WS-FX(2) WS-R(1)',1," ".join(show(rshort(*c)) for c in RH))
T(g,'render view and sampling (10.2): view distance 68; the pushed block or extending head and the retracting head sample the cell behind the movement, the extended base the cell ahead (part 1 pushed or extending, 2 retracting head, 3 retracting base; direction)','CALL "RS1-RENDER-SAMPLE" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,[(p,d) for p in (1,2,3) for d in (E,U)],lambda p,d:(68,)+tuple((-s if p<3 else s) for s in STEP[d]))
T(g,'draws nothing (10.2): nothing is drawn when the moved state is air','CALL "RS1-RENDER-DRAWS" USING WS-I(1) WS-R(1)',1,[(1,),(0,)],lambda a:(int(not a),))
SU.write(g)
# ===== 11 summary
g=SU.gen(11,'Update ordering, pulses and suppression: summary','T0748','the queueing rule, the cancel rules for short pulses, the drop rule and the flag table.')
T(g,'queueing (11.1): checkIfExtend only queues an event; the world is not changed in that call (queued, world changed)','CALL "RS1-PISTON-DECIDE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-I(8) WS-R(1) WS-R(2)',2,[(1,0,1,0,0,0,0,0)],lambda *a:(1,0))
T(g,'0-tick pulse (11.3, 12.8): an extension queued and then unpowered at event time is cancelled with no movement (continue, action); a retraction with power back is marked extended','CALL "RS1-PISTON-GATE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2)',2,[(1,0,0),(1,1,1)],lambda *a:gate(*a))
T(g,'drop rule (11.4): a retraction asked inside a tick leaves the block of a sticky piston (type 2); only a request from outside the tick with the push at least half done pulls it (queued, type)','CALL "RS1-PISTON-DECIDE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-I(8) WS-R(1) WS-R(2)',2,[(0,1,1,1,1,0,0,1),(0,1,1,1,1,0,0,0),(0,1,1,1,1,1,0,0),(0,1,1,1,1,0,1,0)],lambda *a:decide(*a))
FLG={1:18,2:324,3:82,4:276,5:67,6:340,7:2}
T(g,'flags (11.5, 11.6): 18, 82, 276, 324 and 340 all carry flag 16 (no shape updates at write time); 67 and 2 do not; only 67 carries flag 1 (flag, bit; 1 when set)','CALL "RS1-FLAG-BIT" USING WS-I(1) WS-I(2) WS-R(1)',1,[(f,b) for f in (18,82,276,324,340,67,2) for b in (16,1)],lambda f,b:(int(f&b==b),))
T(g,'write flags (11.5): the flags used by the piston code','CALL "RS1-PISTON-WRITE-FLAGS" USING WS-I(1) WS-R(1)',1,[(i,) for i in range(1,8)],lambda i:(FLG[i],))
T(g,'vacated cell order (11.7, 6.1): the BlockPos hash (y + z * 31) * 31 + x spread into 16 buckets; positions (1,0,0) 1, (0,0,1) 961, (0,1,0) 31','CALL "RS1-BLOCKPOS-HASH" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2)',2,[(1,0,0),(0,0,1),(0,1,0),(5,64,3),(-5,64,-3),(300000,20,-3000)],lambda x,y,z:((((y+z*31)*31+x)&0xFFFFFFFF if False else ((((y+z*31)*31+x)+2**31)%2**32-2**31)),bucket(x,y,z)))
SU.write(g)
