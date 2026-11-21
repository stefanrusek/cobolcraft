import sys,math,struct
sys.path.insert(0,'core/tests/gen')
from genbe import *
OUT="core/tests"
ONLY=set(int(a) for a in sys.argv[1:])
# Independent Python models of docs/protocol/31-block-entities-2-processing-and-redstone-containers.md sections 4, 7 and 11 (T0873, T0879, T0887; core/src/be-31-2.cob, BE2- programs).
WS=''.join(' 01 WS-%s                 BINARY-LONG.\n'%c for c in 'ABCEFGH')+' 01 WS-EV                BINARY-LONG.\n'+''.join(' 01 WS-O%d                 BINARY-LONG.\n'%i for i in range(1,5))+''.join(' 01 WS-F%s                FLOAT-LONG.\n'%c for c in 'ABC')+''' 01 WS-LIST.
    05 WS-L               BINARY-LONG OCCURS 5 TIMES.
 01 WS-DATA.
    05 WS-D10             BINARY-LONG OCCURS 10 TIMES.
 COPY CTRECIPE.
'''
def GG(n,subj,tasks,desc): return G('TEST-BE-31-2-%d'%n,'31-2§%d'%n,subj,'Test of 31-2 section %d, %s (core/src/be-31-2.cob; %s): %s'%(n,subj,tasks,desc),WS)
def W(g,n):
    if not ONLY or n in ONLY: g.write(OUT+'/test_be_31_2_%d.cob'%n)
def call(name,*args): return 'CALL "%s" USING %s\n'%(name," ".join(args))
def mv(**kw): return ''.join('MOVE %s TO WS-%s\n'%(v,k) for k,v in kw.items())
def mk(typ,key,n):
    return 'MOVE "minecraft:%s" TO WS-KEY\nMOVE %d TO WS-SVL\nMOVE %d TO WS-NV\nMOVE 5 TO WS-X\nMOVE 70 TO WS-Y\nMOVE 5 TO WS-Z\nCALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX\n'%(key,10+len(key),typ)
BS=mk(12,'brewing_stand',5)
RECIPE='MOVE 1 TO RC-COUNT\nMOVE 20 TO RR-SERIALIZER(1)\nMOVE SPACES TO RR-ING(1, 1)\nMOVE SPACES TO RR-ING(1, 2)\nMOVE "cobolcraft:baseplate" TO RR-ING(1, 1)\nMOVE "cobolcraft:greystone" TO RR-ING(1, 2)\nMOVE "cobolcraft:loam" TO RR-RESULT-ID(1)\nMOVE 1 TO RR-RESULT-COUNT(1)\n'
def setslot(i,item,count): return 'MOVE %d TO BE-SLOT-ITEM(WS-IDX, %d)\nMOVE %d TO BE-SLOT-COUNT(WS-IDX, %d)\n'%(item,i,count,i)
# ===== 4
g=GG(4,'Brewing stand','T0873','the faces, the place and take rules, the saved keys, the recipe lookup and the server tick with its brew, cancel and bottle flags.')
body="";exp=[]
for face in (1,0,2):
    body+=mv(A=face)+call('BE2-BREW-FACE','WS-A','WS-LIST','WS-B')+shw('n:WS-B','n:WS-L(1)','n:WS-L(2)','n:WS-L(3)','n:WS-L(4)')
    exp+={1:[1,3,0,0,0],0:[4,0,1,2,3],2:[4,0,1,2,4]}[face]
for slot,glass in [(3,1),(3,0),(0,0),(4,0),(2,0)]:
    body+=mv(A=slot,B=glass)+call('BE2-BREW-TAKE','WS-A','WS-B','WS-C')+shw('n:WS-C'); exp.append(0 if (slot==3 and not glass) else 1)
g.case('faces (4.1): up gives [3], down [0, 1, 2, 3], any side [0, 1, 2, 4] (count and first four shown); a take through a face is allowed except slot 3 holding something that is not a glass bottle',body,[],exp)
def canplace(slot,fuel,level,reagent,inp,empty):
    if slot==4: return int(fuel)
    if not level: return 0
    if slot==3: return int(reagent)
    return int(inp and empty)
body="";exp=[]
for slot,fuel,level,reag,inp,empty in [(4,1,1,0,0,1),(4,0,1,0,0,1),(4,1,0,0,0,1),(3,0,1,1,0,1),(3,0,1,0,0,1),(3,0,0,1,0,1),(0,0,1,0,1,1),(0,0,1,0,1,0),(2,0,1,0,0,1),(1,0,0,0,1,1)]:
    body+=mv(A=slot,B=fuel,C=level,E=reag,F=inp,G=empty)+call('BE2-BREW-PLACE','WS-A','WS-B','WS-C','WS-E','WS-F','WS-G','WS-H')+shw('n:WS-H'); exp.append(canplace(slot,fuel,level,reag,inp,empty))
g.case('canPlaceItem (4.1): slot 4 takes only a brewing_fuel stack; without a level nothing else goes in; slot 3 takes what the recipes accept as reagent; slots 0 to 2 take a potion input into an empty slot only',body,[],exp)
g.case('saved keys (4.2): BrewTime 0, total_brew_time 400, Fuel 0, total_fuel 20 and speed_multiplier 1.0 are the defaults and are written after Items (absent when empty)',BS+'MOVE 2 TO WS-FORM\n'+shw('SAVE'),[],['{BrewTime:0,total_brew_time:400,Fuel:0,total_fuel:20,speed_multiplier:1.000}'])
LBS=nb_begin()+nb_l('Items',10,2)+nb_b('Slot',3)+nb_stack(2,1)+nb_e()+nb_b('Slot',0)+nb_stack(1,1)+nb_e()+nb_i('BrewTime',120)+nb_i('total_brew_time',200)+nb_i('Fuel',7)+nb_i('total_fuel',20)+nb_float('speed_multiplier',2.0)
LBS2=LBS+'MOVE 0 TO WS-A\n'
f=struct.pack('f',2.0)
g.case('load (4.2): the keys load and save back; with BrewTime above 0 the remembered ingredient becomes the item in slot 3 (it is not saved); the speed_multiplier float loads (2.0)',BS+LBS+'PERFORM LOAD-BUFFER\nMOVE 2 TO WS-FORM\n'+shw('SAVE','n:BE-XI(WS-IDX, 6)')+BS+nb_begin()+nb_i('BrewTime',0)+'PERFORM LOAD-BUFFER\n'+shw('n:BE-XI(WS-IDX, 6)'),[],['{Items:[{Slot:0,id:cobolcraft:baseplate,count:1},{Slot:3,id:cobolcraft:greystone,count:1}],BrewTime:120,total_brew_time:200,Fuel:7,total_fuel:20,speed_multiplier:2.000} 2 0'])
body=RECIPE+'MOVE 1 TO WS-A\nMOVE 2 TO WS-B\n'+call('BE2-BREW-LOOKUP','WS-A','WS-B','WS-C','WS-E')+shw('n:WS-C','n:WS-E')+'MOVE 3 TO WS-A\n'+call('BE2-BREW-LOOKUP','WS-A','WS-B','WS-C','WS-E')+shw('n:WS-C')+'MOVE 1 TO WS-A\nMOVE 3 TO WS-B\n'+call('BE2-BREW-LOOKUP','WS-A','WS-B','WS-C','WS-E')+shw('n:WS-C')+'MOVE 99999 TO WS-A\nMOVE 2 TO WS-B\n'+call('BE2-BREW-LOOKUP','WS-A','WS-B','WS-C','WS-E')+shw('n:WS-C')+'MOVE 1 TO WS-A\nMOVE 99999 TO WS-B\n'+call('BE2-BREW-LOOKUP','WS-A','WS-B','WS-C','WS-E')+shw('n:WS-C')
g.case('recipes (4.4): the brewing recipe whose input item and reagent item match the bottle and the ingredient (baseplate + greystone gives loam, row 1); another input or another reagent matches nothing (row 0), as does an unknown item id; the potion_contents condition of a recipe is not evaluated',body,[],[1,3,0,0,0,0])
class Bs:
    def __init__(s): s.bt=0;s.total=400;s.fuel=0;s.tf=20;s.speed=1.0;s.ing=0;s.slots=[(1,1),(1,1),(1,1),(2,1),(3,1)];s.flags=[0,0,0]
    def brewable(s):
        if s.slots[3][1]==0: return False
        return any(s.slots[i][1]>0 and s.slots[i][0]==1 and s.slots[3][0]==2 for i in range(3))
    def tick(s,uses,speed):
        if s.fuel<=0 and uses>0 and s.slots[4][1]>0:
            s.fuel=uses;s.tf=uses;s.speed=speed;s.slots[4]=(s.slots[4][0],s.slots[4][1]-1)
            if s.slots[4][1]==0: s.slots[4]=(0,0)
        br=s.brewable(); done=0
        if s.bt>0:
            s.bt-=1; fin=(s.bt==0)
            if fin and br:
                for i in range(3):
                    if s.slots[i][1]>0 and s.slots[i][0]==1 and s.slots[3][0]==2: s.slots[i]=(3,1)
                s.slots[3]=(s.slots[3][0],s.slots[3][1]-1)
                if s.slots[3][1]==0: s.slots[3]=(0,0)
                done=1
            elif (not br) or s.slots[3][0]!=s.ing: s.bt=0
        elif br and s.fuel>0:
            sp=s.speed if s.speed>0 else 1
            s.fuel-=1; s.bt=int(math.ceil(400/sp)); s.total=s.bt; s.ing=s.slots[3][0]
        fl=[int(s.slots[i][1]>0) for i in range(3)]
        ch=int(fl!=s.flags); s.flags=fl
        return done,ch
def setup_bs():
    b=BS+RECIPE
    for i,(it,c) in enumerate([(1,1),(1,1),(1,1),(2,1),(3,1)]): b+=setslot(i+1,it,c)
    return b
def tick_call(uses,speed): return mv(A=uses)+'COMPUTE WS-FA = %s\n'%speed+call('BE2-BREW-TICK','WS-IDX','WS-A','WS-FA','WS-B','WS-C')
s=Bs(); body=setup_bs(); exp=[]
body+=tick_call(20,1.0)+shw('n:WS-B','n:WS-C','n:BE-XI(WS-IDX, 3)','n:BE-XI(WS-IDX, 1)','n:BE-XI(WS-IDX, 2)','n:BE-XI(WS-IDX, 4)','n:BE-SLOT-COUNT(WS-IDX, 5)','n:BE-XI(WS-IDX, 6)')
r=s.tick(20,1.0); exp+=[r[0],r[1],s.fuel,s.bt,s.total,s.tf,s.slots[4][1],s.ing]
body+='PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 399\n'+call('BE2-BREW-TICK','WS-IDX','WS-A','WS-FA','WS-B','WS-C').replace('USING WS-IDX WS-A','USING WS-IDX WS-O1')+'END-PERFORM\n'+shw('n:BE-XI(WS-IDX, 1)','n:BE-SLOT-ITEM(WS-IDX, 1)')
for i in range(399): s.tick(0,1.0)
exp+=[s.bt,s.slots[0][0]]
body+=call('BE2-BREW-TICK','WS-IDX','WS-O1','WS-FA','WS-B','WS-C')+shw('n:WS-B','n:BE-XI(WS-IDX, 1)','n:BE-SLOT-ITEM(WS-IDX, 1)','n:BE-SLOT-ITEM(WS-IDX, 2)','n:BE-SLOT-ITEM(WS-IDX, 3)','n:BE-SLOT-COUNT(WS-IDX, 4)','n:BE-XI(WS-IDX, 3)')
r=s.tick(0,1.0); exp+=[r[0],s.bt,s.slots[0][0],s.slots[1][0],s.slots[2][0],s.slots[3][1],s.fuel]
g.case('worked example 7 (4.5, 4.6): the first tick loads the fuel (20 uses, the stack of 1 is used up), starts the brew (Fuel 19, BrewTime and total_brew_time 400, the ingredient remembered); the counter is 1 after 400 ticks; on tick 401 it reaches 0 and every bottle with a recipe becomes the output, the ingredient shrinks by one and event 1035 is raised (done, bottles changed, Fuel, BrewTime, total, total_fuel, fuel items, ingredient)',body,[],exp)
s=Bs(); s.slots[4]=(3,1); body=setup_bs(); exp=[]
body+=tick_call(20,2.0)+shw('n:BE-XI(WS-IDX, 1)','n:BE-XI(WS-IDX, 2)')
s.tick(20,2.0); exp+=[s.bt,s.total]
g.case('speed (4.5 step 5, worked example 7): with speed_multiplier 2.0 the brew time is ceil(400 / 2.0) = 200',body,[],exp)
s=Bs(); body=setup_bs(); exp=[]
body+=tick_call(20,1.0)+'MOVE 0 TO BE-SLOT-COUNT(WS-IDX, 4)\n'+tick_call(0,1.0)+shw('n:BE-XI(WS-IDX, 1)','n:WS-B','n:BE-XI(WS-IDX, 3)')
s.tick(20,1.0); s.slots[3]=(2,0); r=s.tick(0,1.0); exp+=[s.bt,r[0],s.fuel]
body+=setup_bs().replace('RECIPE','')+tick_call(20,1.0)+'MOVE 5 TO BE-SLOT-ITEM(WS-IDX, 4)\n'+tick_call(0,1.0)+shw('n:BE-XI(WS-IDX, 1)')
s=Bs(); s.tick(20,1.0); s.slots[3]=(5,1); s.tick(0,1.0); exp+=[s.bt]
body+=BS+RECIPE
for i,(it,c) in enumerate([(4,1),(0,0),(0,0),(2,1),(3,1)]): body+=setslot(i+1,it,c)
body+=tick_call(20,1.0)+shw('n:BE-XI(WS-IDX, 1)','n:BE-XI(WS-IDX, 3)','n:BE-SLOT-COUNT(WS-IDX, 5)')
s=Bs(); s.slots=[(4,1),(0,0),(0,0),(2,1),(3,1)]; s.tick(20,1.0); exp+=[s.bt,s.fuel,s.slots[4][1]]
g.case('cancel and no start (4.5 steps 2, 4, 5, V3): removing the reagent mid-brew or replacing it by another item sets BrewTime 0 on the next tick (the fuel already used stays used); without a recipe for any bottle nothing starts (the fuel stack is still loaded by step 1: BrewTime 0, Fuel 20, no fuel item left)',body,[],exp)
s=Bs(); body=setup_bs(); exp=[]
for step in range(3):
    body+=tick_call(20 if step==0 else 0,1.0)+shw('n:WS-C','n:BE-XI(WS-IDX, 7)','n:BE-XI(WS-IDX, 8)','n:BE-XI(WS-IDX, 9)')
    if step==1: body+='MOVE 0 TO BE-SLOT-COUNT(WS-IDX, 2)\n'; s.slots[1]=(0,0) if False else s.slots[1]
    r=s.tick(20 if step==0 else 0,1.0); exp+=[r[1]]+s.flags
    if step==1: s.slots[1]=(1,0)
g.case('bottle states (4.5 step 6): has_bottle_0..2 follow the three bottle slots and the block is written (flags 2) only when they differ from the last remembered flags (changed 1, then the flags)',body,[],exp)
W(g,4)
# ===== 7
CR=mk(42,'crafter',9)
def lay(items):  # items: dict slot0->count (item X = 2)
    b=''
    for i,c in items.items(): b+=setslot(i+1,2,c)
    return b
g=GG(7,'Crafter','T0879','the slot rules and their worked example, the saved keys, the menu data, the ticker, the neighbour rule, the craft step and the dispense paths.')
body=CR+lay({0:1,4:1})+'MOVE 1 TO WS-A\nMOVE 0 TO WS-B\n'+call('BE2-CRAFTER-SET-STATE','WS-IDX','WS-A','WS-B')+call('BE2-CRAFTER-SIGNAL','WS-IDX','WS-C')+shw('n:WS-C')
body+=CR+lay({0:3,1:3,2:3,3:2,4:3,6:3,7:3,8:3})+call('BE2-CRAFTER-SIGNAL','WS-IDX','WS-C')+shw('n:WS-C')
for slot in (0,3,6,5):
    body+=mv(A=slot,B=2,C=0,E=64)+call('BE2-CRAFTER-CAN-PLACE','WS-IDX','WS-A','WS-B','WS-C','WS-E','WS-F')+shw('n:WS-F')
body+='MOVE 5 TO WS-A\nMOVE 0 TO WS-B\n'+call('BE2-CRAFTER-SET-STATE','WS-IDX','WS-A','WS-B')+'MOVE 3 TO WS-A\nMOVE 2 TO WS-B\nMOVE 0 TO WS-C\nMOVE 64 TO WS-E\n'+call('BE2-CRAFTER-CAN-PLACE','WS-IDX','WS-A','WS-B','WS-C','WS-E','WS-F')+shw('n:WS-F')+call('BE2-CRAFTER-SIGNAL','WS-IDX','WS-C')+shw('n:WS-C')
g.case('worked example 13 (7.2): layout A (slots 0 and 4 filled, slot 1 disabled) gives signal 3; layout B (3 of X in slots 0, 1, 2, 4, 6, 7, 8, 2 in slot 3, slot 5 empty) gives 8; canPlaceItem is false for slot 0 and slot 3 (a smaller or empty later slot), true for slot 6 and for the empty slot 5; with slot 5 disabled slot 3 accepts (the scan skips disabled slots) and the signal counts the disabled slot (9)',body,[],[3,8,0,0,1,1,1,9])
body=CR
exp=[]
for slot,full in [(0,0),(9,0),(-1,0)]:
    body+=mv(A=slot)+call('BE2-CRAFTER-CAN-DISABLE','WS-IDX','WS-A','WS-B')+shw('n:WS-B'); exp.append(1 if 0<=slot<9 else 0)
body+=setslot(3,2,1)+mv(A=2)+call('BE2-CRAFTER-CAN-DISABLE','WS-IDX','WS-A','WS-B')+shw('n:WS-B')+'MOVE 2 TO WS-A\nMOVE 0 TO WS-B\n'+call('BE2-CRAFTER-SET-STATE','WS-IDX','WS-A','WS-B')+call('BE2-CRAFTER-DISABLED','WS-IDX','WS-A','WS-C')+shw('n:WS-C')
body+='MOVE 4 TO WS-A\nMOVE 0 TO WS-B\n'+call('BE2-CRAFTER-SET-STATE','WS-IDX','WS-A','WS-B')+call('BE2-CRAFTER-DISABLED','WS-IDX','WS-A','WS-C')+shw('n:WS-C')+'MOVE 1 TO WS-B\n'+call('BE2-CRAFTER-SET-STATE','WS-IDX','WS-A','WS-B')+call('BE2-CRAFTER-DISABLED','WS-IDX','WS-A','WS-C')+shw('n:WS-C')+'MOVE 99 TO WS-A\n'+call('BE2-CRAFTER-DISABLED','WS-IDX','WS-A','WS-C')+shw('n:WS-C')
body+='MOVE 4 TO WS-A\nMOVE 0 TO WS-B\n'+call('BE2-CRAFTER-SET-STATE','WS-IDX','WS-A','WS-B')+'MOVE 4 TO WS-A\nMOVE 3 TO WS-B\nMOVE 1 TO WS-C\nMOVE 0 TO WS-E\n'+call('BE2-CRAFTER-SET-ITEM','WS-IDX','WS-A','WS-B','WS-C','WS-E')+'MOVE 4 TO WS-A\n'+call('BE2-CRAFTER-DISABLED','WS-IDX','WS-A','WS-C')+shw('n:WS-C','n:BE-SLOT-ITEM(WS-IDX, 5)')
g.case('slot rules (7.2): only an empty slot in range can be disabled; setSlotState ignores a filled slot and works both ways on an empty one; isSlotDisabled is false out of range; setItem re-enables a disabled slot before storing',body,[],exp+[0,0,1,0,0,0,3])
body=CR+setslot(1,2,64)+'MOVE 0 TO WS-A\nMOVE 2 TO WS-B\nMOVE 0 TO WS-C\nMOVE 64 TO WS-E\n'+call('BE2-CRAFTER-CAN-PLACE','WS-IDX','WS-A','WS-B','WS-C','WS-E','WS-F')+shw('n:WS-F')
g.case('full stack (7.2): a slot whose stack already has its maximum count takes no more',body,[],[0])
body=CR+call('BE2-CRAFTER-DATA','WS-IDX','WS-DATA')+shw('n:WS-D10(1)','n:WS-D10(10)')+'MOVE 3 TO WS-A\nMOVE 0 TO WS-B\n'+call('BE2-CRAFTER-SET-STATE','WS-IDX','WS-A','WS-B')+'MOVE 1 TO BE-XI(WS-IDX, 2)\n'+call('BE2-CRAFTER-DATA','WS-IDX','WS-DATA')+shw('n:WS-D10(1)','n:WS-D10(4)','n:WS-D10(5)','n:WS-D10(10)')
g.case('menu data (7.1): ten ints, slot states 0 enabled and 1 disabled for slots 0 to 8, then triggered',body,[],[0,0,0,1,0,1])
body=CR+'MOVE 2 TO WS-FORM\n'+shw('SAVE')+'MOVE 3 TO WS-A\nMOVE 0 TO WS-B\n'+call('BE2-CRAFTER-SET-STATE','WS-IDX','WS-A','WS-B')+'MOVE 6 TO WS-A\nMOVE 0 TO WS-B\n'+call('BE2-CRAFTER-SET-STATE','WS-IDX','WS-A','WS-B')+'MOVE 4 TO BE-XI(WS-IDX, 1)\nMOVE 1 TO BE-XI(WS-IDX, 2)\n'+shw('SAVE')
LCR=nb_begin()+nb_l('Items',10,1)+nb_b('Slot',3)+nb_stack(2,1)+nb_e()+nb_intarr('disabled_slots',[1,3,12])+nb_i('triggered',1)+nb_i('crafting_ticks_remaining',2)
g.case('saved keys (7.1, 7.2): crafting_ticks_remaining, disabled_slots (an empty array is written when none) and triggered; on load every slot is enabled first, then each listed index is disabled when its slot is empty (slot 3 holds an item and stays enabled, 12 is out of range) and triggered is read as an int',body+CR+LCR+'PERFORM LOAD-BUFFER\n'+shw('SAVE','n:BE-XI(WS-IDX, 1)','n:BE-XI(WS-IDX, 2)'),[],['{crafting_ticks_remaining:0,disabled_slots:I[],triggered:0} {crafting_ticks_remaining:4,disabled_slots:I[3,6],triggered:1} {Items:[{Slot:3,id:cobolcraft:greystone,count:1}],crafting_ticks_remaining:2,disabled_slots:I[1],triggered:1} 2 1'])
body=CR
for ct in (2,1,0):
    body+='MOVE %d TO BE-XI(WS-IDX, 1)\n'%ct+call('BE2-CRAFTER-TICK','WS-IDX','WS-B')+shw('n:BE-XI(WS-IDX, 1)','n:WS-B')
body+='MOVE 6 TO BE-XI(WS-IDX, 1)\nMOVE 0 TO WS-C\nPERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 9\nCALL "BE2-CRAFTER-TICK" USING WS-IDX WS-B\nIF WS-B = 1\nCOMPUTE WS-C = WS-J\nEND-IF\nEND-PERFORM\n'+shw('n:BE-XI(WS-IDX, 1)','n:WS-C')
g.case('ticker (7.3): r = crafting_ticks_remaining - 1; below 0 nothing is stored; otherwise it is stored and crafting is reset (set false) when r reaches 0 (after the 6 ticks of a craft the sixth resets it)',body,[],[1,0,0,1,0,0,0,6])
body="";exp=[]
for pw,tr,ent in [(1,0,1),(0,1,1),(1,1,1),(0,0,1),(1,0,0)]:
    body+=mv(A=pw,B=tr,C=ent)+call('BE2-CRAFTER-NEIGHBOR','WS-A','WS-B','WS-C','WS-E','WS-F','WS-G')+shw('n:WS-E','n:WS-F','n:WS-G')
    if not ent: exp+=[0,tr,0]
    elif pw and not tr: exp+=[4,1,0]
    elif tr and not pw: exp+=[0,0,1]
    else: exp+=[0,tr,0]
g.case('neighbourChanged (7.4 step 1): powered and not triggered schedules a tick in 4 and writes triggered true (flags 2); not powered and triggered writes triggered false and crafting false; without the entity or otherwise nothing (schedule, triggered, crafting reset)',body,[],exp)
body=CR+setslot(1,2,3)+setslot(2,3,1)+setslot(9,2,1)
body+='MOVE 1 TO WS-A\nMOVE 0 TO WS-B\n'+call('BE2-CRAFTER-CRAFT','WS-IDX','WS-A','WS-B','WS-E','WS-F')+shw('n:WS-E','n:WS-F','n:BE-XI(WS-IDX, 1)','n:BE-SLOT-COUNT(WS-IDX, 1)','n:BE-SLOT-COUNT(WS-IDX, 2)','n:BE-SLOT-COUNT(WS-IDX, 3)','n:BE-SLOT-COUNT(WS-IDX, 9)')
body+=CR+setslot(1,2,3)+'MOVE 0 TO WS-A\nMOVE 0 TO WS-B\n'+call('BE2-CRAFTER-CRAFT','WS-IDX','WS-A','WS-B','WS-E','WS-F')+shw('n:WS-E','n:WS-F','n:BE-XI(WS-IDX, 1)','n:BE-SLOT-COUNT(WS-IDX, 1)')+'MOVE 1 TO WS-A\nMOVE 1 TO WS-B\n'+call('BE2-CRAFTER-CRAFT','WS-IDX','WS-A','WS-B','WS-E','WS-F')+shw('n:WS-E','n:WS-F','n:BE-SLOT-COUNT(WS-IDX, 1)')
g.case('dispenseFrom (7.4 step 2): a found recipe with a result sets crafting_ticks_remaining 6 and crafting true and shrinks every non-empty slot by 1; no recipe, or a recipe with an empty result, plays event 1050 (the failure click) and changes nothing (event, crafting, ticks, slots)',body,[],[0,1,6,2,0,0,0, 1050,0,0,3, 1050,0,3])
body="";exp=[]
for tg,cr,cnt,mx in [(1,1,5,64),(1,0,70,64),(1,0,64,64),(1,0,5,64),(0,0,5,64)]:
    body+=mv(A=tg,B=cr,C=cnt,E=mx)+call('BE2-CRAFTER-PATH','WS-A','WS-B','WS-C','WS-E','WS-F')+shw('n:WS-F')
    exp.append(0 if not tg else 1 if (cr or cnt>mx) else 2)
for rest in (0,3):
    body+=mv(A=rest)+call('BE2-CRAFTER-DROP','WS-A','WS-B','WS-C','WS-E','WS-F')+shw('n:WS-B','n:WS-C','n:WS-E','n:WS-F'); exp+=[int(rest>0)]*4
g.case('dispenseItem (7.5): with a target that is a crafter, or a stack larger than the target\'s maximum, one item is moved at a time (path 1); with a target and a stack within its maximum the whole stack (path 2); without a target neither; the drop, the advancement trigger and the events 1049 and 2010 happen only when something is left over (drop, advancement, 1049, 2010)',body,[],exp)
W(g,7)
# ===== 11
g=GG(11,'What clients see','T0887','no entity of part 2 sends a block entity data packet; the clients see block states and menu data.')
body="";exp=[]
for t,n in [(0,'furnace'),(27,'smoker'),(28,'blast_furnace'),(12,'brewing_stand'),(18,'hopper'),(5,'dispenser'),(6,'dropper'),(42,'crafter'),(19,'comparator'),(17,'daylight_detector'),(38,'chiseled_bookshelf')]:
    body+='MOVE %d TO WS-A\n'%t+call('BE-SYNC-INFO','WS-A','WS-B','WS-C')+shw('n:WS-B','n:WS-C'); exp+=[0,0]
g.case('no data path (11, 2.6): the furnaces, brewing stand, hopper, dispenser, dropper, crafter, comparator, daylight detector and chiseled bookshelf have tag kind 0 and no Block Entity Data packet',body,[],exp)
body=BS+call('BE-DATA-PACKET','WS-IDX','PB-BUFFER','WS-A') if False else ''
body='CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY\n'+BS+'CALL "BE-DATA-PACKET" USING WS-IDX PB-BUFFER WS-A\nMOVE PB-LENGTH TO WS-B\nCALL "PB-FREE" USING PB-BUFFER\n'+shw('n:WS-A','n:WS-B')+'CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY\n'+CR+'CALL "BE-TAG-ENTRIES" USING WS-IDX PB-BUFFER\nMOVE PB-LENGTH TO WS-B\nCALL "PB-FREE" USING PB-BUFFER\n'+shw('n:WS-B')
g.case('nothing is written (11): no packet is built for a brewing stand (written 0, length 0) and the update tag of a crafter has no entries (length 0)',body,[],[0,0,0])
W(g,11)
