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
                if ln+len(toPush)>12: return False
                prev=nk;cur=nx
        for i in range(ln-1,-1,-1):
            p=pos
            for _ in range(i): p=add(p,opp(push))
            toPush.append(p)
        count=ln
        p=pos
        while True:
            p=add(p,push)
            if p in toPush:
                idx0=toPush.index(p)
                A=toPush[:idx0];B=toPush[len(toPush)-count:];C=toPush[idx0:len(toPush)-count]
                toPush[:]=A+B+C
                for i in range(0,idx0+count+1):
                    if i<len(toPush) and sticky(K(toPush[i])):
                        if not branch(toPush[i]): return False
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
run('random grids (4): 48 resolver runs on 7 x 7 x 7 grids of stone, slime, honey, obsidian, torch, glazed, pistons, chest and bedrock agree with the literal model of 4.1 to 4.5',rnd)
run('push limit exact (12.2, 4.3 step 4): 12 stones east of the piston push, a 13th makes the resolver fail',[({(x,4,4):1 for x in range(2,2+n)},(1,4,4),E,True) for n in (12,13)])
SU.write(g)
