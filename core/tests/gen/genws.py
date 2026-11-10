import sys,math,struct
sys.path.insert(0,'core/tests/gen')
from gentest import *
OUT=sys.argv[1] if len(sys.argv)>1 else "core/tests"
def m(x,n=1000000): return int(math.floor(x*n+0.5))
def RF(k,scale=1000000): return 'COMPUTE WS-R(%d) ROUNDED = WS-RF(%d) * %d'%(k,k,scale)
f32=lambda x: struct.unpack('f',struct.pack('f',x))[0]
BD=" 01 WS-BD1 BINARY-DOUBLE.\n 01 WS-BD2 BINARY-DOUBLE.\n 01 WS-BD3 BINARY-DOUBLE.\n 01 WS-BD4 BINARY-DOUBLE.\n"
def S(*a): return " ".join(str(x) for x in a)
def GG(n,sec,subj,comment,extra=""): return Gen('TEST-WORLDSIM-33-%d'%n,'33§%d'%n,subj,'Test of 33 section %d, %s (core/src/worldsim-33.cob; %s): '%(n,subj,comment[0])+comment[1],extra)
# ============ 1
g=GG(1,1,'Server tick order',('T0499','the pause when empty, the Set Time heartbeat, the autosave countdown, the latency broadcast, the status rebuild, which steps stand still when the game is frozen and the order of the levels.'))
def pause(pl,sp,sec,e):
    P=sec*20; paused=save=0
    if P>0:
        e = e+1 if (pl==0 and sp==0) else 0
        paused=int(e>=P); save=int(e==P)
    return e,paused,save
pc=[(0,0,60,1198),(0,0,60,1199),(0,0,60,1200),(0,0,60,1500),(1,0,60,1500),(0,1,60,100),(0,0,0,5000),(0,0,-3,5000),(0,0,1,19),(0,0,1,20)]
g.run('pause when empty: P = seconds * 20; the counter counts empty ticks, the tick pauses at P with one autosave on the first such tick; 0 or less disables it; a player or a sprint resets it',[S(*c) for c in pc],'MOVE WS-I(4) TO WS-R(1)\nCALL "WT-PAUSE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-R(3)',3," ".join("%d/%d/%d"%pause(*c) for c in pc))
g.run('the Set Time heartbeat is sent when the tick count is a multiple of 20',["1","19","20","21","40","100"],'CALL "WT-HEARTBEAT" USING WS-I(1) WS-R(1)',1,"0 0 1 0 1 1")
def auto(l,r):
    l-=1; s=0
    if l<=0:
        s=1; l=max(100,int(r*300))
    return l,s
ac=[(5,20.0),(1,20.0),(0,20.0),(1,0.1),(1,1000.0),(2,20.0)]
g.run('autosave: the countdown falls by 1; at 0 or below the world is saved and the countdown restarts at max(100, (int)(rate * 300))',[S(*c) for c in ac],'MOVE WS-I(1) TO WS-R(1)\nCALL "WT-AUTOSAVE" USING WS-R(1) WS-FX(2) WS-R(2)',2," ".join("%d/%d"%auto(*c) for c in ac))
g.run('the latency update is broadcast when the counter exceeds 600, and the counter resets',["0","599","600","601"],'MOVE WS-I(1) TO WS-R(1)\nCALL "WT-LATENCY" USING WS-R(1) WS-R(2)',2,"1/0 600/0 0/1 0/1")
g.extra=BD
g.run('the cached status is rebuilt after at least 5 seconds',["4999999999","5000000000","6000000000","0"],'COMPUTE WS-BD1 = WS-FX(1)\nCALL "WT-STATUS" USING WS-BD1 WS-R(1)',1,"0 1 1 0")
g.run('while the game is frozen only the clock tick (step 3) and the game tests (step 9) stand still; every other step of tickChildren runs',[S(i,0) for i in range(1,13)]+["3 1","9 1"],'CALL "WT-CHILD-RUNS" USING WS-I(1) WS-I(2) WS-R(1)',1,"1 1 0 1 1 1 1 1 0 1 1 1 1 1")
g.run('levels tick in the order overworld, Nether, End',["1","2","3"],'CALL "WT-LEVEL-ORDER" USING WS-I(1) WS-R(1)',1,"1 2 3")
g.write(OUT+'/test_worldsim_33_1.cob')
# ============ 2
g=GG(2,2,'Level tick order',('T0501','the steps behind the tick manager, the empty-level counter and entity phase, the chunk loop decisions, randomBlockPos and the random tick counts.'))
g.run('a frozen game runs the sleep check, skyDarken, the chunk source, the empty counter and the entity phase; the border, weather, time, scheduled ticks, raids and block events stand still',[S(i,0) for i in range(1,13)]+["2 1","6 1","9 1"],'CALL "WL-STEP-RUNS" USING WS-I(1) WS-I(2) WS-R(1)',1,"1 0 1 1 0 0 0 1 0 1 1 1 1 1 1")
def emp(t,n,e):
    if t: e=0
    if n: e+=1
    return e,int(e<300)
ec=[(1,1,299),(0,1,298),(0,1,299),(0,0,299),(1,0,500),(0,1,0)]
g.run('empty-level counter: tickets reset it, a normal tick adds 1; entities and block entities run while it is below 300',[S(*c) for c in ec],'MOVE WS-I(3) TO WS-R(1)\nCALL "WL-EMPTY" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2)',2," ".join("%d/%d"%emp(*c) for c in ec))
g.run('a spawning chunk tick: thunder in the entity-ticking range; an empty category list stops the chunk; spawning needs the border and entity-ticking permission',["1 0 1","1 1 1","0 0 1","1 0 0"],'CALL "WL-CHUNK-STEPS" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2)',2,"1/1 1/0 0/1 1/0")
g.run('an ice and snow attempt is made when nextInt(48) is 0',["0","1","47"],'CALL "WL-ICE-ATTEMPT" USING WS-I(1) WS-R(1)',1,"1 0 0")
def rp(r,x0,y0,z0,mask):
    v=(r*3+1013904223)&0xffffffff
    if v>=2**31: v-=2**32
    i=v>>2
    return v,x0+(i&15),y0+((i>>16)&mask),z0+((i>>8)&15)
rc=[(0,32,64,-48,15),(1013904223,0,0,0,15),(2000000000,-16,-64,16,15),(-5,10,10,10,15),(123456789,0,0,0,7)]
g.run('randomBlockPos: randValue * 3 + 1013904223 in 32-bit wrapping arithmetic, i = randValue >> 2, x + (i & 15), y + ((i >> 16) & mask), z + ((i >> 8) & 15); worked example 5: 0 gives 7, 11, 12',[S(*c) for c in rc],'MOVE WS-I(1) TO WS-R(1)\nCALL "WL-RANDOM-POS" USING WS-R(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(2) WS-R(3) WS-R(4)\nCOMPUTE WS-R(1) = FUNCTION MOD(WS-R(1), 100000000)',4," ".join("/".join(str(v) for v in ((rp(*c)[0]%10**8,)+rp(*c)[1:])) for c in rc))
g.run('random tick work: random_tick_speed ice attempts per chunk; speed positions per section with random-ticking content, none otherwise or at speed 0 (worked example 9: 12 positions for 4 sections)',["3 1","3 0","0 1","1 1","20 1"],'CALL "WL-RANDOM-WORK" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2)',2,"3/3 3/0 0/0 1/1 20/20")
g.write(OUT+'/test_worldsim_33_2.cob')
# ============ 3
g=GG(3,3,'Game time, clocks and timelines',('T0503','the clock advance, manager writes, time markers, timelines, keyframe and weather lerps, skyDarken, brightness predicates, the moon and the Set Time rate.'))
def clock(p,r,t,adv,pa):
    if adv and not pa:
        p=p+r; n=math.floor(p); p-=n; t+=n
    return p,t
cc=[(0,0.5,100,1,0),(0.5,0.5,100,1,0),(0,2,100,1,0),(0.25,0.5,5,0,0),(0,1,5,1,1),(0.75,0.5,10,1,0),(0,0.25,0,1,0)]
g.run('the clock advance: partial += rate, n = floor(partial), partial -= n, total += n, only with advance_time and an unpaused clock',[S(*c) for c in cc],'MOVE WS-I(3) TO WS-R(2)\nCALL "WC-CLOCK" USING WS-FX(1) WS-FX(2) WS-R(2) WS-I(4) WS-I(5) WS-RF(1)\n'+RF(1),2," ".join("%d/%d"%(m(clock(*c)[0]),clock(*c)[1]) for c in cc))
def addt(t,k,p,st):
    return (k,0) if st else (max(0,t+k),p)
at=[(100,50,0.5,0),(100,-500,0.5,0),(100,50,0.5,1),(0,-1,0.25,0),(7,0,0.5,1)]
g.run('manager writes: setTotalTicks sets the total and resets the partial tick; addTicks adds and clamps the total at 0',[S(*c) for c in at],'MOVE WS-I(1) TO WS-R(2)\nMOVE WS-FX(3) TO WS-RF(1)\nCALL "WC-ADD-TICKS" USING WS-R(2) WS-I(2) WS-RF(1) WS-I(4)\n'+RF(1),2," ".join("%d/%d"%(m(addt(*c)[1]),addt(*c)[0]) for c in at))
def mk(t,pe,tot):
    if pe==0: return int(t==tot),t
    c=tot%pe; d=t-c
    return int(t==c),(tot+d if d>0 else tot+pe+d)
mc=[(0,24000,15000),(13000,24000,5000),(1000,24000,1000),(6000,0,100),(6000,0,6000),(0,24000,24000),(18000,24000,49000)]
g.extra=BD
g.run('time markers: occursAt, and resolveTimeToMoveTo strictly in the future for a period (night skip 15000 to 24000)',[S(*c) for c in mc],'CALL "WC-MARKER" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-BD1\nMOVE WS-BD1 TO WS-R(2)',2," ".join("%d/%d"%mk(*c) for c in mc))
g.run('moveToTimeMarker: no marker is NO_TIME_MARKER_FOUND (1), an occurring one NOT_MOVED (2), else moved (0)',["0 0","0 1","1 1","1 0"],'CALL "WC-MOVE-STATUS" USING WS-I(1) WS-I(2) WS-R(1)',1,"1 1 2 0")
g.run('timelines: current ticks are the total mod the period (the total without one) and the period count is floor(total / period)',["50000 24000","5 0","192000 192000","0 24000","23999 24000"],'CALL "WC-TIMELINE" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2)',2,"2000/2 5/0 0/1 0/0 23999/0")
g.run('keyframe lerp: linear for numbers; booleans and enums hold the earlier value until the progress reaches 1.0',["0.5 0 10 1","0.5 0 10 0","1.0 0 10 0","0.25 15 3.9 1","0.0 2 5 0"],'CALL "WC-KEYFRAME" USING WS-FX(1) WS-FX(2) WS-FX(3) WS-I(4) WS-RF(1)\n'+RF(1),1," ".join(str(m(v)) for v in (5,0,10,15+0.25*(3.9-15),2)))
g.run('skyDarken = (int)(15.0f - L): day 0, the night plateau 11, dusk tick 12523 gives 4, dawn tick 23478 gives 3, full rain 3, full thunder 5',["15","4.0","10.99778","11.00388","11.5625","9.19921875"],'CALL "WC-SKY-DARKEN" USING WS-FX(1) WS-R(1)',1," ".join(str(int(f32(15.0-v))) for v in (15,4.0,10.99778,11.00388,11.5625,9.19921875)))
g.run('brightness: with no fixed time bright when skyDarken < 4, else dark; a fixed time is neither; the effective sky brightness is max(0, sky - skyDarken)',["0 0 15","0 3 15","0 4 15","1 0 15","0 11 5","1 11 15"],'CALL "WC-OUTSIDE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-R(3)',3,"1/0/15 1/0/12 0/1/11 0/0/15 0/1/0 0/0/4")
def wsky(v,r,t):
    rr=r-t
    if rr>0: v=v+rr*((v+0.3125*(4-v))-v)
    if t>0: v=v+t*((v+0.52734375*(4-v))-v)
    return v
wc=[(15,1,0),(15,1,1),(15,0.5,0),(15,0,0),(15,0.5,0.5),(10,1,0)]
g.run('weather layers on sky_light_level: rain level minus thunder level blends towards 4.0 with alpha 0.3125, the thunder level with alpha 0.52734375: full rain 11.5625, full thunder 9.19921875',[S(*c) for c in wc],'CALL "WC-WEATHER-SKY" USING WS-FX(1) WS-FX(2) WS-FX(3) WS-RF(1)\n'+RF(1),1," ".join(str(m(wsky(*c))) for c in wc))
g.run('state change lerp: numbers lerp by the weather level; booleans and enums switch as soon as the level is above 0',["0.5 0 10 1","0.001 0 1 0","0 0 1 0","1 5 9 1","0.0 5 9 1"],'CALL "WC-STATE-LERP" USING WS-FX(1) WS-FX(2) WS-FX(3) WS-I(4) WS-RF(1)\n'+RF(1),1," ".join(str(m(v)) for v in (5,1,0,9,5)))
def moon(t):
    ph=(t//24000)%8; d=[4,3,2,1,0,1,2,3][ph]
    return ph,d/4,d*0.125
mt=[0,24000,48000,72000,96000,120000,144000,168000,191999,192000,215999]
g.run('the moon: a phase per 24000 ticks of the 192000 cycle, brightness 1, .75, .5, .25, 0, .25, .5, .75; the slime chance falls from 0.5 by 0.125 per phase to 0.0 at new moon',[str(t) for t in mt],'CALL "WC-MOON" USING WS-I(1) WS-R(1) WS-RF(1) WS-RF(2)\nCOMPUTE WS-R(2) ROUNDED = WS-RF(1) * 1000\nCOMPUTE WS-R(3) ROUNDED = WS-RF(2) * 1000',3," ".join("%d/%d/%d"%(moon(t)[0],round(moon(t)[1]*1000),round(moon(t)[2]*1000)) for t in mt))
g.run('Set Time carries rate 0.0 when the clock is paused or advance_time is false, else the rate',["0 1 1.0","1 1 1.0","0 0 2.0","0 1 0.5"],'CALL "WC-SET-TIME-RATE" USING WS-I(1) WS-I(2) WS-FX(3) WS-RF(1)\n'+RF(1),1,"1000000 0 0 500000")
g.write(OUT+'/test_worldsim_33_3.cob')
# ============ 4
g=GG(4,4,'Weather',('T0505','the weather flags and levels, the cycle with its timers, smoothing, packets, setting and resetting, temperature and precipitation, freezing, snow, cauldrons and the lightning gates.'))
g.run('a level can have weather when its dimension type has sky light and no ceiling and it is not the End',["1 0 0","1 1 0","0 0 0","1 0 1"],'CALL "WW-CAN-HAVE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,"1 0 0 0")
def isw(can,r,t):
    return int(can and r>0.2), int(can and t*r>0.9)
wl=[(1,0.2,1.0),(1,0.20000002,1.0),(1,0.19,0.0),(1,1.0,0.9),(1,1.0,0.9024988),(1,0.5,1.0),(0,1.0,1.0),(1,1.0,0.0)]
g.run('isRaining is rainLevel > 0.2 (after 20 steps of 0.01f the level 0.20000002 is above 0.2) and isThundering is thunderLevel x rainLevel > 0.9, only where weather exists',[S(*c) for c in wl],'CALL "WW-IS" USING WS-I(1) WS-FX(2) WS-FX(3) WS-R(1) WS-R(2)',2," ".join("%d/%d"%isw(c[0],c[1],c[2]) for c in wl))
g.run('the four distributions: rain delay 12000 to 180000, rain duration 12000 to 24000, thunder delay 12000 to 180000, thunder duration 3600 to 15600',["1","2","3","4"],'CALL "WW-RANGE" USING WS-I(1) WS-R(1) WS-R(2)',2,"12000/180000 12000/24000 12000/180000 3600/15600")
def cyc(clear,tt,rt,th,ra,ts,rs):
    td=rd=0
    if clear>0:
        clear-=1; tt=0 if th else 1; rt=0 if ra else 1; th=ra=0
        return clear,tt,rt,th,ra,0,0
    if tt>0:
        tt-=1
        if tt==0: th=1-th
    else: td=1; tt=ts
    if rt>0:
        rt-=1
        if rt==0: ra=1-ra
    else: rd=1; rt=rs
    return clear,tt,rt,th,ra,td,rd
cy=[(0,0,0,0,0,15000,20000),(0,2,3,0,0,1,1),(0,1,1,0,0,9,9),(0,0,0,1,1,5000,7000),(1,0,0,1,0,9,9),(2,5,5,0,1,9,9),(6000,0,0,0,0,9,9),(0,1,0,1,1,5000,3600),(0,0,1,0,0,12345,999)]
g.run('the weather cycle A: a clear countdown leaves thunderTime and rainTime 1 (0 for flags that were on) with both flags off, so a storm follows; otherwise timers count down and toggle at 0 without a draw, and a timer at 0 draws duration (flag on) or delay (flag off)',[S(*c) for c in cy],
 'MOVE WS-I(1) TO WS-R(1)\nMOVE WS-I(2) TO WS-R(2)\nMOVE WS-I(3) TO WS-R(3)\nMOVE WS-I(4) TO WS-R(4)\nMOVE WS-I(5) TO WS-R(5)\nCALL "WW-CYCLE" USING WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-I(6) WS-I(7) WS-R(6) WS-R(7)',7," ".join("/".join(str(v) for v in cyc(*c)) for c in cy))
def smooth(l,fl):
    l=f32(l+f32(0.01) if fl else l-f32(0.01)); return min(1.0,max(0.0,l))
sm=[(0.0,1),(0.19999999,1),(0.20000002,0),(1.0,1),(0.995,1),(0.0,0),(0.005,0),(1.0,0)]
g.run('level smoothing: +0.01f when raining or thundering, else -0.01f, in single precision, clamped to 0 to 1',[S(*c) for c in sm],'MOVE WS-FX(1) TO WS-RF(1)\nCALL "WW-SMOOTH" USING WS-RF(1) WS-I(2)\n'+RF(1),1," ".join(str(m(smooth(*c))) for c in sm))
def pk(o,r,ot,t,was,is_):
    return int(o!=r),int(ot!=t),(1 if (was and not is_) else 2 if (not was and is_) else 0)
pp=[(0.5,0.51,0.0,0.0,0,0),(0.5,0.5,0.1,0.11,0,0),(0.19,0.2,0,0,0,1),(0.21,0.2,0,0,1,0),(1,1,0,0,1,1),(0.2,0.21,0.3,0.31,0,1)]
g.run('packets C: Game Event 7 and 8 to this dimension when the levels changed; a change of isRaining sends stop (2) or start (1) raining to everybody',[S(*c) for c in pp],'CALL "WW-PACKETS" USING WS-FX(1) WS-FX(2) WS-FX(3) WS-FX(4) WS-I(5) WS-I(6) WS-R(1) WS-R(2) WS-R(3)',3," ".join("/".join(str(v) for v in pk(*c)) for c in pp))
g.run('setWeatherParameters writes thunderTime = rainTime; the sleep reset zeroes both times and both flags and leaves the clear time',["6000 0 0 0 0","0 12000 1 1 0","500 9000 1 0 0","77 1234 1 1 1","0 0 0 0 1"],'CALL "WW-SET" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5,"6000/0/0/0/0 0/12000/12000/1/1 500/9000/9000/1/0 77/0/0/0/0 0/0/0/0/0")
def temp(b,y,sea,n):
    lim=sea+17
    return b if y<=lim else b-(n*8+y-lim)*0.05/40.0
tc=[(0.25,160,63,0.0),(0.25,161,63,0.0),(0.8,63,63,0.5),(0.5,80,63,0.0),(0.5,100,63,0.25),(0.25,80,63,0.0)]
g.run('temperature: up to sea level + 17 the base; above it T0 - (N x 8 + y - (sea + 17)) x 0.05 / 40; example 4.5: base 0.25 at y = 160 is 0.15, at y = 161 below it',[S(*c) for c in tc],'CALL "WW-TEMPERATURE" USING WS-FX(1) WS-I(2) WS-I(3) WS-FX(4) WS-RF(1)\n'+RF(1),1," ".join(str(m(temp(*c))) for c in tc))
g.run('precipitation: NONE without it, SNOW when the temperature is below 0.15f, else RAIN; warm enough is at least 0.15f',["0 0.5","1 0.5","1 0.15","1 0.1499","1 -0.5","0 -0.5"],'CALL "WW-PRECIPITATION" USING WS-I(1) WS-FX(2) WS-R(1) WS-R(2)',2,"0/1 1/1 1/1 2/0 2/0 0/0")
g.run('shouldFreeze: not warm enough, inside the build height, block light below 10, source water in a liquid block and not all four horizontal neighbours water',["0 1 5 1 0","1 1 5 1 0","0 0 5 1 0","0 1 10 1 0","0 1 9 0 0","0 1 5 1 1","0 1 0 1 0"],'CALL "WW-FREEZE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1)',1,"1 0 0 0 0 0 1")
def snow(h,rn,sn,ins,lt,air,lay,ls,sv):
    lim=min(h,8); a=0; n=ls
    if rn and h>0 and sn and ins and lt<10 and (air or lay) and sv:
        if lay and ls<lim: a=2; n=ls+1
        if air: a=1; n=1
    return a,n
sw=[(1,1,1,1,0,1,0,0,1),(1,1,1,1,0,0,1,1,1),(1,1,1,1,0,0,1,2,1),(3,1,1,1,0,0,1,2,1),(8,1,1,1,0,0,1,7,1),(20,1,1,1,0,0,1,8,1),(0,1,1,1,0,1,0,0,1),(1,0,1,1,0,1,0,0,1),(1,1,0,1,0,1,0,0,1),(1,1,1,1,10,1,0,0,1),(1,1,1,1,0,1,0,0,0),(1,1,1,1,0,0,0,0,1)]
g.run('snow: with max_snow_accumulation_height above 0, rain, snow precipitation, inside the height, block light below 10, air or a snow layer and survival: air becomes one layer, a layer below min(h, 8) grows by one',[S(*c) for c in sw],'CALL "WW-SNOW" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-I(8) WS-I(9) WS-R(1) WS-R(2)',2," ".join("%d/%d"%snow(*c) for c in sw))
def caul(p,e,l,d):
    if (p==1 and d<0.05) or (p==2 and d<0.1):
        if e: return p,1
        if (not e) and 0<l<3: return p,l+1
    return 0,l
cl=[(1,1,0,0.04),(1,1,0,0.05),(2,1,0,0.09),(2,1,0,0.1),(1,0,1,0.0),(1,0,2,0.0),(1,0,3,0.0),(2,0,2,0.05),(1,0,0,0.0)]
g.run('cauldrons: an empty one fills to level 1 with nextFloat below 0.05 (rain) or 0.1 (snow); a layered one of the same kind below level 3 gains one',[S(*c) for c in cl],'CALL "WW-CAULDRON" USING WS-I(1) WS-I(2) WS-I(3) WS-FX(4) WS-R(1) WS-R(2)',2," ".join("%d/%d"%caul(*c) for c in cl))
def thu(r,t,d,ra,sm,db,e,rod):
    st=int(r and t and d==0 and ra); tr=int(st and sm and (not rod) and db<e*0.01)
    return st,tr,tr
tu=[(1,1,0,1,1,0.0,1.5,0),(1,1,0,1,1,0.5,1.5,0),(1,1,0,1,1,0.0,1.5,1),(1,1,0,1,0,0.0,1.5,0),(1,1,5,1,1,0.0,1.5,0),(1,0,0,1,1,0.0,1.5,0),(0,1,0,1,1,0.0,1.5,0),(1,1,0,0,1,0.0,1.5,0),(1,1,0,1,1,0.0149,1.5,0),(1,1,0,1,1,0.0151,1.5,0)]
g.run('tickThunder: a strike needs rain, thunder, nextInt(100000) = 0 and rain at the target; the skeleton trap needs spawn_mobs, nextDouble < e x 0.01 and no lightning rod; the bolt is visual only when a trap',[S(*c) for c in tu],'CALL "WW-THUNDER" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-FX(6) WS-FX(7) WS-I(8) WS-R(1) WS-R(2) WS-R(3)',3," ".join("/".join(str(v) for v in thu(*c)) for c in tu))
g.write(OUT+'/test_worldsim_33_4.cob')
# ============ 5
g=GG(5,5,'Sleeping',('T0507','the bed rule test, sleepersNeeded and the status checks, the announce text, the sleep counter, startSleepInBed in order, the range test, the bed use steps and the night skip.'))
g.run('bed rule test: always is true, never false, when_dark is the dark-outside predicate',["0 0","0 1","1 0","1 1","2 0","2 1"],'CALL "WS-RULE-TEST" USING WS-I(1) WS-I(2) WS-R(1)',1,"1 1 0 1 0 0")
def needed(a,p):
    pr=(a*p+2**31)%2**32-2**31
    q=f32(pr/100.0); c=math.ceil(q)
    return max(1,min(c,2147483647))
nd=[(3,50),(4,100),(3,100),(1,0),(0,100),(10,1),(3,101),(3,150),(100,2147483647),(70000,50000),(2,33)]
g.run('sleepersNeeded: max(1, ceil(active x pct / 100.0f)) with the product a wrapping 32-bit int: three active at 50 percent need 2 (worked example 3)',[S(*c) for c in nd],'CALL "WS-NEEDED" USING WS-I(1) WS-I(2) WS-R(1)',1," ".join(str(needed(*c)) for c in nd))
def enough(sl,ac,dp,pc):
    n=needed(ac,pc)
    return int(sl>=n),int(dp>=n),int(sl>=n and dp>=n),int(pc<=100)
en=[(2,3,2,50),(2,3,1,50),(1,3,2,50),(0,0,0,100),(1,1,0,100),(1,1,1,100),(1,1,1,101),(1,1,1,0)]
g.run('enough sleeping and enough deeply sleeping are both needed for the skip; percentages above 100 forbid skipping nights',[S(*c) for c in en],'CALL "WS-ENOUGH" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4," ".join("/".join(str(v) for v in enough(*c)) for c in en))
def supd(a,s,oa,os_): return int((a!=oa or s!=os_) and (os_>0 or s>0))
su=[(3,1,3,0),(3,0,3,1),(3,0,3,0),(4,0,3,0),(3,2,3,2),(2,1,3,1),(0,0,0,0)]
g.run('the sleep status counts as changed when a count differs and the old or new sleeping count is above 0',[S(*c) for c in su],'CALL "WS-STATUS-UPDATE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1," ".join(str(supd(*c)) for c in su))
g.run('announcement: nothing above 100 percent; skipping the night when enough sleep; else players sleeping with the counts',["100 1 2 2","100 0 1 3","101 0 1 3","50 0 0 2","150 1 3 3"],'CALL "WS-ANNOUNCE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2) WS-R(3)',3,"1/0/0 2/1/3 0/0/0 2/0/2 0/0/0")
def cnt(sl,ref,c):
    wake=long=0
    if sl:
        c=min(100,c+1)
        if ref: wake=1
    elif c>0:
        c+=1
        if c>=110: c=0
    if sl and c>=100: long=1
    return c,wake,long
ct=[(1,0,0),(1,0,98),(1,0,99),(1,0,100),(1,1,10),(0,0,0),(0,0,5),(0,0,108),(0,0,109)]
g.run('the sleep counter: a sleeper counts up to 100 and wakes when the rule refuses; a waker keeps counting and resets at 110; sleeping long enough is a counter of 100',[S(*c) for c in ct],'MOVE WS-I(3) TO WS-R(1)\nCALL "WS-COUNTER" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3)',3," ".join("/".join(str(v) for v in cnt(*c)) for c in ct))
def start(busy,cs,csp,rng,free,cr,mon,fail,pct):
    if busy: return 1,0,0,0
    if not rng: return 2,0,0,0
    if not free: return 3,0,0,0
    sp=int(csp)
    if not cs: return 4,sp,0,0
    if (not cr) and mon: return 5,sp,0,0
    return (1 if fail else 0),sp,int(pct>100),1
ss=[(1,1,1,1,1,0,0,0,100),(0,1,1,0,1,0,0,0,100),(0,1,1,1,0,0,0,0,100),(0,0,1,1,1,0,0,0,100),(0,0,0,1,1,0,0,0,100),(0,1,1,1,1,0,1,0,100),(0,1,1,1,1,1,1,0,100),(0,1,1,1,1,0,0,0,100),(0,1,0,1,1,0,0,1,100),(0,1,1,1,1,0,0,0,150)]
g.run('startSleepInBed in order: busy, range, obstruction; the respawn point is set before the sleep test; then the rule, monsters (not for creative), the failure, the not-possible overlay above 100 percent; the list updates on success',[S(*c) for c in ss],'CALL "WS-START" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-I(8) WS-I(9) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4," ".join("/".join(str(v) for v in start(*c)) for c in ss))
def rng(x,y,z,b,o):
    def w(bx,by,bz): return abs(x-(bx+0.5))<=3.0 and abs(y-by)<=2.0 and abs(z-(bz+0.5))<=3.0
    return int(w(*b) or w(*o))
rr=[(0.5,64,0.5,0,64,0,1,64,0),(3.5,64,0.5,0,64,0,1,64,0),(3.51,64,0.5,0,64,0,1,64,0),(3.51,64,0.5,0,64,0,3,64,0),(0.5,66,0.5,0,64,0,1,64,0),(0.5,66.01,0.5,0,64,0,1,64,0),(0.5,64,-2.5,0,64,0,0,64,-1),(10.5,64,0.5,0,64,0,1,64,0),(-2.5,62,3.5,0,64,0,1,64,0)]
g.run('range: |x - (bx + 0.5)| <= 3.0, |y - by| <= 2.0, |z - (bz + 0.5)| <= 3.0 for the clicked bed position or the other half',[S(*c) for c in rr],'CALL "WS-RANGE" USING WS-FX(1) WS-FX(2) WS-FX(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-I(8) WS-I(9) WS-R(1)',1," ".join(str(rng(c[0],c[1],c[2],c[3:6],c[6:9])) for c in rr))
def ub(h,s,d,o,k):
    if not s: return 0
    if d: return 1
    if o and k: return 2
    if o: return 3
    return 4
ubc=[(1,0,0,0,0),(1,1,1,0,0),(1,1,0,1,1),(1,1,0,1,0),(1,1,0,0,0),(0,1,0,0,0),(1,1,1,1,1)]
g.run('using a bed: no same bed at the head is consumed; destroy-on-use sends the message and destroys; an occupied bed kicks a villager (2) or shows the text (3); else sleeping starts (4)',[S(*c) for c in ubc],'CALL "WS-USE-BED" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1)',1," ".join(str(ub(*c)) for c in ubc))
g.run('night skip: the clock moves only with advance_time and a default clock, everybody wakes, the weather resets only with advance_weather and rain',["1 1 1 1","1 1 1 0","0 1 1 1","1 0 1 1","1 1 0 1","0 0 0 0"],'CALL "WS-NIGHT-SKIP" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2) WS-R(3)',3,"1/1/1 1/1/0 0/1/1 0/1/1 1/1/0 0/1/0")
g.write(OUT+'/test_worldsim_33_5.cob')
# ============ 6
g=GG(6,6,'World spawn, initial spawn search, respawn',('T0509','RespawnData, the 121-cell spiral, the column order, the provisional spawn, the column checks, the spawn finder fitness and probes, the first-spawn candidates, the spawn-height fixup, the effective data and spawn protection.'))
def wrap(yaw,pitch):
    y=((yaw+180)%360)-180
    return y,max(-90,min(90,pitch))
wp=[(0,0),(190,100),(-190,-100),(180,0),(-180,0),(540,91),(360,-90),(90,45)]
g.run('RespawnData: yaw wrapped to -180 to 180, pitch clamped to -90 to 90',[S(*c) for c in wp],'CALL "WP-RESPAWN-DATA" USING WS-FX(1) WS-FX(2) WS-RF(1) WS-RF(2)\n'+RF(1,1000)+'\n'+RF(2,1000),2," ".join("%d/%d"%(m(wrap(*c)[0],1000),m(wrap(*c)[1],1000)) for c in wp))
def spiral(n):
    x=z=0; dx,dz=0,-1
    for _ in range(n-1):
        if x==z or (x<0 and x==-z) or (x>0 and x==1-z): dx,dz=-dz,dx
        x+=dx; z+=dz
    return x,z
si=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,25,26,27,121]
g.run('the spiral of 6.2: (0,0), (1,0), (1,1), (0,1), (-1,1), (-1,0), (-1,-1), (0,-1), (1,-1), (2,-1), (2,0), (2,1), (2,2) ...',[str(i) for i in si],'CALL "WP-SPIRAL" USING WS-I(1) WS-R(1) WS-R(2)',2," ".join("%d/%d"%spiral(i) for i in si))
g.run('the spiral visits exactly the 121 cells of [-5, 5] x [-5, 5]; the sum of the offsets and the extremes are checked by the last cell and the cells 26 and 121',["26","121"],'CALL "WP-SPIRAL" USING WS-I(1) WS-R(1) WS-R(2)',2,"%d/%d %d/%d"%(spiral(26)+spiral(121)))
assert sorted(spiral(i) for i in range(1,122))==sorted((a,b) for a in range(-5,6) for b in range(-5,6))
g.run('the columns of a chunk: x is the outer loop and z the inner, both ascending from the chunk minimum (example 6: chunk (3, -2): (48, -32) ... (48, -17), (49, -32))',["1 48 -32","2 48 -32","16 48 -32","17 48 -32","256 48 -32"],'CALL "WP-COLUMN" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2)',2,"48/-32 48/-31 48/-17 49/-32 63/-17")
g.run('provisional spawn: the origin chunk minimum plus (8, y, 8): chunk (3, -2) with y 64 gives (56, 64, -24)',["3 -2 64","0 0 64","-1 -1 80"],'CALL "WP-PROVISIONAL" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-R(3)',3,"56/64/-24 8/64/8 -8/80/-8")
def lr(ceil,sh,mo,mn,sf,fl):
    top=sh if ceil else mo
    rej=int(top<mn or (sf<=top and sf>fl))
    return top,rej
lc=[(1,64,70,-64,65,60),(0,64,70,-64,71,60),(0,64,70,-64,70,60),(0,64,70,-64,70,70),(0,64,-100,-64,0,0),(1,64,70,-64,64,60),(1,64,70,-64,64,64)]
g.run('column checks: the top is the spawn height with a ceiling else the motion-blocking height; a top below the minimum is rejected; a surface at or below the top and above the ocean floor (water-covered) is rejected',[S(*c) for c in lc],'CALL "WP-LEVEL-RESPAWN" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1) WS-R(2)',2," ".join("%d/%d"%lr(*c) for c in lc))
g.run('one cell of the downward scan: a fluid rejects the column, a full up face returns y + 1, else go on',["1 0","1 1","0 1","0 0"],'CALL "WP-LEVEL-COLUMN" USING WS-I(1) WS-I(2) WS-R(1)',1,"1 1 2 0")
g.extra=BD
def quant(v): return int(f32(v*10000.0))
qc=[(0.5,-1100,10000),(-0.11,-1100,10000),(1.2,-1100,10000),(-0.3,-1100,10000),(0.0,-1000,-1600),(-0.7,-1000,-1600)]
def dist(q,lo,hi): return q-hi if q-hi>0 else max(lo-q,0)
g.run('quantised density: q(v) = (long)(v x 10000.0f); distance(v) is v - max above 0, else max(min - v, 0)',[S(*c) for c in qc],'COMPUTE WS-BD1 = WS-FX(2)\nCOMPUTE WS-BD2 = WS-FX(3)\nCALL "WP-QUANT" USING WS-FX(1) WS-BD3 WS-BD1 WS-BD2 WS-BD4\nMOVE WS-BD3 TO WS-R(1)\nMOVE WS-BD4 TO WS-R(2)',2," ".join("%d/%d"%(quant(c[0]),dist(quant(c[0]),c[1],c[2])) for c in qc))
def fit(mm,x,z): return mm*4194304+x*x+z*z,(x>>2)<<2,(z>>2)<<2
ft=[(0,512,0),(0,513,0),(810000,0,0),(0,-513,-3),(0,0,0),(1,-1,-1)]
g.run('fitness = m x 2048^2 + x^2 + z^2 on the unaligned coordinates (example 7: 262144, 263169), the density sampled at the biome-grid aligned point',[S(*c) for c in ft],'COMPUTE WS-BD1 = WS-FX(1)\nCALL "WP-FITNESS" USING WS-BD1 WS-I(2) WS-I(3) WS-BD2 WS-R(2) WS-R(3)\nCOMPUTE WS-R(1) = WS-BD2 / 1000000000\nCOMPUTE WS-R(4) = FUNCTION MOD(WS-BD2, 1000000000)',4," ".join("%d/%d/%d/%d"%(fit(*c)[0]//10**9,fit(*c)[1],fit(*c)[2],fit(*c)[0]%10**9) for c in ft))
def probe(cx,cz,a,r,st):
    f=lambda v: struct.unpack('f',struct.pack('f',v))[0]
    x=cx+int(math.sin(a)*r); z=cz+int(math.cos(a)*r)
    na=a+st/r; nr=r
    if na>6.283185307179586: na=0.0; nr=r+st
    return x,z,na,nr
pr=[(0,0,0.0,512.0,512),(0,0,0.0,32.0,32),(10,-4,1.5,64.0,32),(0,0,6.2,32.0,32),(-100,50,3.14159,1024.0,512)]
g.run('a probe of a search pass: (c.x + (int)(sin(angle) x radius), c.z + (int)(cos(angle) x radius)), then angle += step / radius and above 2 pi back to 0 with radius += step',[S(*c) for c in pr],'CALL "WP-PROBE" USING WS-I(1) WS-I(2) WS-FX(3) WS-FX(4) WS-I(5) WS-R(1) WS-R(2) WS-RF(1) WS-RF(2)\nCOMPUTE WS-R(3) ROUNDED = WS-RF(1) * 100000\nCOMPUTE WS-R(4) ROUNDED = WS-RF(2) * 100',4," ".join("%d/%d/%d/%d"%(probe(*c)[0],probe(*c)[1],m(probe(*c)[2],100000),m(probe(*c)[3],100)) for c in pr))
def cand(rule,bd,off,i,sx,sz):
    r=max(0,rule)
    if bd<r: r=bd
    if bd<=1: r=1
    n=2*r+1; cnt=min(1024,n*n); cop=cnt-1 if cnt<=16 else 17
    k=(off+cop*i)%cnt
    return sx+k%n-r,sz+k//n-r,cnt,r
cd=[(10,100,100,0,0,0),(10,100,100,1,0,0),(10,5,3,2,0,0),(10,1,0,0,0,0),(0,100,0,0,5,5),(-4,100,2,3,5,5),(1,100,7,1,0,0),(2,100,4,6,100,-100),(100,100,1000,5,0,0),(10,0,4,1,0,0),(8,100,280,0,0,0)]
g.run('findSpawn candidates: the radius is lowered to the border distance (1 when that is 1 or less); n = 2 radius + 1; count = min(1024, n^2); stride 17 above 16 candidates; example: radius 10, offset 100: i = 0 gives (6, -6), i = 1 gives (2, -5)',[S(*c) for c in cd],'CALL "WP-CANDIDATE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4," ".join("/".join(str(v) for v in cand(*c)) for c in cd))
def fix(start,mn,mx,bl):
    y=start
    while not (bl[y-mn]=='0' or y>=mx): y+=1
    y-=1
    while not (y<=mn or bl[y-mn]=='1'): y-=1
    y+=1
    return y
fx=[(5,0,9,"1111100000"),(0,0,9,"0000000000"),(3,0,9,"1111111111"),(5,0,9,"1100000011"),(1,0,9,"0011111110")]
g.case('fixupSpawnHeight: up while blocked and below the maximum, down one then down while free above the minimum, then up one',[('0','MOVE "%s" TO WS-T1\nMOVE %d TO WS-I(1)\nMOVE %d TO WS-I(2)\nMOVE %d TO WS-I(3)\nCALL "WP-FIXUP" USING WS-I(1) WS-I(2) WS-I(3) WS-T1 WS-R(1)'%(b,s,mn,mx),1) for s,mn,mx,b in fx]," ".join(str(fix(*c)) for c in fx))
g.run('the effective respawn data keeps a stored position inside the border (minimum inclusive, maximum exclusive) and replaces one outside',["0 0 -50 50 -50 50","-50 0 -50 50 -50 50","50 0 -50 50 -50 50","49 49 -50 50 -50 50","60 0 -50 50 -50 50","0 -51 -50 50 -50 50"],'CALL "WP-EFFECTIVE" USING WS-I(1) WS-I(2) WS-FX(3) WS-FX(4) WS-FX(5) WS-FX(6) WS-R(1)',1,"1 1 0 1 0 0")
def prot(same,ops,isop,rad,dx,dz): return int(same and ops and not isop and rad>0 and max(abs(dx),abs(dz))<=rad)
pt=[(1,1,0,16,16,16),(1,1,0,16,17,0),(1,1,0,16,0,-17),(1,1,1,16,0,0),(1,0,0,16,0,0),(0,1,0,16,0,0),(1,1,0,0,0,0),(1,1,0,16,-16,5)]
g.run('spawn protection: the spawn dimension, a non-empty operator list, a non-operator, a property above 0 and a square max(|dx|, |dz|) within it',[S(*c) for c in pt],'CALL "WP-PROTECTED" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1)',1," ".join(str(prot(*c)) for c in pt))
g.write(OUT+'/test_worldsim_33_6.cob')
# ============ 7
g=GG(7,7,'World border',('T0511','static and moving extents, the per-tick lerp, geometry, damage and the close-to-border test.'))
def ext(c,s,a): return max(-a,min(a,c-s/2)),max(-a,min(a,c+s/2))
ec=[(0,100,29999984),(10,100,29999984),(0,59999968,29999984),(0,59999968,100),(-20,10,5),(0,1,29999984)]
g.run('a static extent: clamp(c - S / 2, -A, A) and clamp(c + S / 2, -A, A)',[S(*c) for c in ec],'CALL "WB-EXTENT" USING WS-FX(1) WS-FX(2) WS-FX(3) WS-RF(1) WS-RF(2)\n'+RF(1,10)+'\n'+RF(2,10),2," ".join("%d/%d"%(m(ext(*c)[0],10),m(ext(*c)[1],10)) for c in ec))
def mov(fr,to,du,pr):
    pr-=1; size=fr+(du-pr)/du*(to-fr); st=0
    if pr<=0: size=to; st=1
    return pr,size,(1 if to<fr else 2),abs(fr-to)/du,st
mv=[(100,200,200,150),(100,200,200,1),(200,100,200,2),(100,200,200,200),(100,100,10,5),(60000,10,6000,6000)]
g.run('a moving extent: the progress counts down, the size is lerp((D - progress) / D, from, to) (example 8: 125 with 150 of 200 remaining after the tick), the extent turns static at 0 and the last size is exactly the target; speed is |from - to| / duration',[S(*c) for c in mv],
 'MOVE WS-I(4) TO WS-R(1)\nCALL "WB-MOVING" USING WS-FX(1) WS-FX(2) WS-I(3) WS-R(1) WS-RF(1) WS-R(2) WS-RF(2) WS-R(3)\nCOMPUTE WS-R(4) ROUNDED = WS-RF(1) * 1000\nCOMPUTE WS-R(5) ROUNDED = WS-RF(2) * 1000000',5,
 " ".join("%d/%d/%d/%d/%d"%(mov(*c)[0],mov(*c)[2],mov(*c)[4],m(mov(*c)[1],1000),m(mov(*c)[3],1000000)) for c in mv))
def geo(x,z,mg,b):
    mnx,mxx,mnz,mxz=b; eps=0.000009999999747378752
    w=int(mnx-mg<=x<mxx+mg and mnz-mg<=z<mxz+mg)
    d=min(z-mnz,mxz-z,x-mnx,mxx-x)
    cx=min(max(x,mnx),mxx-eps); cz=min(max(z,mnz),mxz-eps)
    return w,d,cx,cz
B=(-50,50,-50,50)
gc=[(10,0,0),(-50,0,0),(50,0,0),(49.999,0,0),(60,0,0),(60,0,15),(0,-70,0),(10,0,2)]
g.run('geometry: the minimum edge is inside and the maximum edge outside; the distance to the border is the smallest of the four (example 8: 40 at x = 10); the clamp keeps 1.0E-5f inside the maximum edge',["%s %s %s -50 50 -50 50"%c for c in gc],'CALL "WB-GEOMETRY" USING WS-FX(1) WS-FX(2) WS-FX(3) WS-FX(4) WS-FX(5) WS-FX(6) WS-FX(7) WS-R(1) WS-RF(1) WS-RF(2) WS-RF(3)\nCOMPUTE WS-R(2) ROUNDED = WS-RF(1) * 1000\nCOMPUTE WS-R(3) ROUNDED = WS-RF(2) * 100000\nCOMPUTE WS-R(4) ROUNDED = WS-RF(3) * 100000',4,
 " ".join("%d/%d/%d/%d"%(geo(c[0],c[1],c[2],B)[0],m(geo(c[0],c[1],c[2],B)[1],1000),m(geo(c[0],c[1],c[2],B)[2],100000),m(geo(c[0],c[1],c[2],B)[3],100000)) for c in gc))
def dmg(pl,wall,w,d,sf,pb):
    if wall: return 1,0
    if pl and not w:
        dd=d+sf
        if dd<0 and pb>0: return 0,max(1,math.floor(-dd*pb))
    return 0,0
dc=[(1,1,0,-10,5,0.2),(1,0,0,-10,5,0.2),(1,0,1,-10,5,0.2),(0,0,0,-10,5,0.2),(1,0,0,-100,5,0.2),(1,0,0,-4,5,0.2),(1,0,0,-10,5,0.0),(1,0,0,-5.5,5,0.2),(1,0,0,-31,5,0.2)]
g.run('damage: in a wall 1.0 and no border test; a player whose box is outside takes max(1, floor(-d x damage per block)) when d = distance + safe zone is below 0 (example 8: 1); other entities take none',[S(*c) for c in dc],'CALL "WB-DAMAGE" USING WS-I(1) WS-I(2) WS-I(3) WS-FX(4) WS-FX(5) WS-FX(6) WS-RF(1) WS-RF(2)\n'+RF(1,1000)+'\n'+RF(2,1000),2," ".join("%d/%d"%(m(dmg(*c)[0],1000),m(dmg(*c)[1],1000)) for c in dc))
def cl(d,x,z,sd,b):
    mm=max(1,sd); mnx,mxx,mnz,mxz=b
    return int(d<2*mm and mnx-mm<=x<mxx+mm and mnz-mm<=z<mxz+mm)
cs=[(1,49,0,0.6),(1.5,49,0,0.6),(2,49,0,0.6),(2.5,49,0,2.0),(3,49,0,2.0),(1,52,0,0.6),(1,51,0,0.6),(1,-51,0,3.0)]
g.run('close to the border: m = max(1, larger box side); the distance below 2m and the position within the bounds with margin m',["%s %s %s %s -50 50 -50 50"%c for c in cs],'CALL "WB-CLOSE" USING WS-FX(1) WS-FX(2) WS-FX(3) WS-FX(4) WS-FX(5) WS-FX(6) WS-FX(7) WS-FX(8) WS-R(1)',1," ".join(str(cl(c[0],c[1],c[2],c[3],B)) for c in cs))
g.write(OUT+'/test_worldsim_33_7.cob')
# ============ 8
g=GG(8,8,'Game rules',('T0513','the rule change hook, the spawning flag and its stale case, invulnerability, explosion interactions, cramming, minecart speed, portal delay and permission, the movement check, fire distance, limited crafting, global sound events and the drop gates.'))
g.run('a rule change: reduced_debug_info sends Entity Event 22 (true) or 23 (false), limited_crafting Game Event 12, immediate_respawn Game Event 11, locator_bar re-evaluates, spawn_monsters refreshes the flags, advance_time sends a full Set Time',["1 1","1 0","2 1","2 0","3 1","4 0","5 1","6 1","0 1"],'CALL "GR-CHANGE" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2)',2,"1/22 1/23 2/1 2/0 3/1 4/0 5/1 6/1 0/1")
def spw(mb,mo,ch,st):
    lv=int(mb and mo)
    if ch in (2,3): st=lv
    return lv,st
sp=[(1,1,0,0),(1,0,0,1),(0,1,1,1),(0,1,2,1),(1,1,2,0),(1,1,3,0),(0,0,3,1),(1,1,1,0)]
g.run('isSpawningMonsters is spawn_mobs and spawn_monsters; the stored flag is refreshed only by a spawn_monsters or difficulty change, so a spawn_mobs change leaves it stale (8.5)',[S(*c) for c in sp],'MOVE WS-I(4) TO WS-R(2)\nCALL "GR-SPAWNING" USING WS-I(1) WS-I(2) WS-R(1) WS-I(3) WS-R(2)',2," ".join("%d/%d"%spw(*c) for c in sp))
def inv(f1,f2,f3,f4,r1,r2,r3,r4,pl): return int(pl and ((f1 and not r1) or (f2 and not r2) or (f3 and not r3) or (f4 and not r4)))
iv=[(1,0,0,0,0,1,1,1,1),(1,0,0,0,1,0,0,0,1),(0,1,0,0,1,0,1,1,1),(0,0,1,0,1,1,0,1,1),(0,0,0,1,1,1,1,0,1),(0,0,0,0,0,0,0,0,1),(1,0,0,0,0,1,1,1,0),(1,1,1,1,0,0,0,0,1)]
g.run('a player is invulnerable to drowning, fall, fire and freezing damage while the matching rule is false; mobs are unaffected',[S(*c) for c in iv],'CALL "GR-INVULNERABLE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-I(8) WS-I(9) WS-R(1)',1," ".join(str(inv(*c)) for c in iv))
def exp_(i,bd,gr,md,td):
    if i==0: return 0
    if i==1: return 1+bd
    if i==2: return (1+md) if gr else 0
    if i==3: return 1+td
    return 3
ex=[(0,1,1,1,1),(1,0,1,1,1),(1,1,1,0,0),(2,1,1,0,1),(2,1,1,1,0),(2,1,0,1,1),(3,0,1,1,0),(3,0,1,1,1),(4,0,0,0,0)]
g.run('explosion interaction: NONE keeps; BLOCK by block_explosion_drop_decay; MOB keeps without mob_griefing, else by mob_explosion_drop_decay; TNT by tnt_explosion_drop_decay; TRIGGER only triggers',[S(*c) for c in ex],'CALL "GR-EXPLOSION" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1)',1," ".join(str(exp_(*c)) for c in ex))
def cr(l,t,f,d): return 6.0 if (l>0 and t>l-1 and d==0 and f>l-1) else 0.0
cm=[(24,30,30,0),(24,30,30,1),(24,20,20,0),(24,24,24,0),(24,23,23,0),(24,30,23,0),(24,30,24,0),(0,30,30,0),(1,1,1,0),(1,0,0,0)]
g.run('cramming (example 10): with max_entity_cramming 24, 30 pushable non-passenger entities give 6.0 damage on a draw of 0, 20 give none; 0 disables it',[S(*c) for c in cm],'CALL "GR-CRAMMING" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-RF(1)\n'+RF(1,1000),1," ".join(str(m(cr(*c),1000)) for c in cm))
g.run('max_minecart_speed: rule x (0.5 in water, else 1.0) / 20 blocks per tick',["8 0","8 1","1000 0","1 1"],'CALL "GR-MINECART" USING WS-I(1) WS-I(2) WS-RF(1)\n'+RF(1),1," ".join(str(m(v)) for v in (8/20.0,8/20.0*0.5,50.0,1/20.0*0.5)))
def por(cre,cr_,df,ne,al,pl): 
    d=0
    if pl: d=max(0,cr_ if cre else df)
    return d,int(not (ne and not al))
pc=[(1,0,80,0,1,1),(0,0,80,0,1,1),(0,0,-5,0,1,1),(1,-3,80,0,1,1),(0,0,80,0,1,0),(0,0,80,1,0,1),(0,0,80,1,1,1),(0,0,80,0,0,1)]
g.run('portal rules: the creative delay for a creative player, the default delay for other players (floor 0), 0 for other entities; entering the Nether is refused only when the rule is false',[S(*c) for c in pc],'CALL "GR-PORTAL" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1) WS-R(2)',2," ".join("%d/%d"%por(*c) for c in pc))
def mvc(ex,pr,gl,er): return int(not (ex or not pr or (gl and not er)))
mc=[(0,1,0,1),(1,1,0,1),(0,0,0,1),(0,1,1,0),(0,1,1,1),(0,1,0,0)]
g.run('the movement check is skipped for a single-player owner or a player changing dimension, when player_movement_check is false, and for a gliding player when elytra_movement_check is false',[S(*c) for c in mc],'CALL "GR-MOVEMENT-CHECK" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1," ".join(str(mvc(*c)) for c in mc))
g.run('fire spread near a player: always for -1, else a player strictly closer than the radius (a player exactly r away does not count)',["-1 5000.0","128 127.9","128 128.0","128 129.5","0 0.0","0 0.5"],'CALL "GR-FIRE-NEAR" USING WS-I(1) WS-FX(2) WS-R(1)',1,"1 1 0 0 0 0")
g.run('limited_crafting: a non-special recipe is allowed only when the recipe book holds it; special recipes always',["1 0 0","1 0 1","1 1 0","0 0 0"],'CALL "GR-LIMITED-CRAFTING" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,"0 1 1 1")
g.extra=BD
g.run('global sound events: off is an ordinary event; on, a same-level player within 32 blocks hears it at the event, a farther one 32 blocks from itself towards the event, another level at its own position',["0 1 100","1 1 1023","1 1 1024","1 1 5000","1 0 5","1 0 99999"],'COMPUTE WS-BD1 = WS-FX(3)\nCALL "GR-GLOBAL-SOUND" USING WS-I(1) WS-I(2) WS-BD1 WS-R(1)',1,"0 1 2 2 3 3")
g.run('drop gates: block_drops stops popResource of a non-empty stack, mob_drops stops a baby, entity_drops stops dropped items',["1 1 0 0","1 0 0 0","1 1 1 0","2 1 0 1","2 1 0 0","2 0 0 0","3 1 0 0","3 0 0 0"],'CALL "GR-DROPS" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1,"1 0 0 0 1 0 1 0")
g.write(OUT+'/test_worldsim_33_8.cob')
# ============ 9
g=GG(9,9,'Difficulty',('T0515','setDifficulty with its lock and hardcore rule, damage scaling, the difficulty sites of 9.3 and the time and moon inputs of local difficulty.'))
def dset(d,f,l,h):
    if f or not l: return (3 if h else d),1
    return -1,0
ds=[(1,0,0,0),(1,0,1,0),(1,1,1,0),(2,0,0,1),(0,0,0,1),(0,1,1,1),(3,0,1,1)]
g.run('setDifficulty: ignored unless forced or not locked; a hardcore world always stores HARD',[S(*c) for c in ds],'MOVE -1 TO WS-R(1)\nCALL "DF-SET" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2)',2," ".join("%d/%d"%dset(*c) for c in ds))
def scale(d,x):
    return {0:0.0,1:min(x/2+1,x),2:x,3:x*3/2}[d]
sc=[(0,6),(1,6),(1,1),(1,0.5),(2,6),(3,6),(3,3),(1,2)]
g.run('damage scaling of attacks on a player: Peaceful 0, Easy min(d / 2 + 1, d), Normal d, Hard d x 3 / 2',[S(*c) for c in sc],'CALL "DF-SCALE" USING WS-I(1) WS-FX(2) WS-RF(1)\n'+RF(1),1," ".join(str(m(scale(*c))) for c in sc))
def sites(d,dr,mo,at,cl):
    return int(mo and d!=0 and at and dr<d and cl),(4 if d>=2 else 0),d*7,int(d!=0)
st=[(1,0,1,1,1),(1,1,1,1,1),(2,1,1,1,1),(3,2,1,1,1),(3,3,1,1,1),(0,0,1,1,1),(2,0,0,1,1),(2,0,1,0,1),(2,0,1,1,0)]
g.run('difficulty sites: a portal piglin needs spawning, not Peaceful, the attribute, nextInt(2000) < difficulty id and a close player (1/2000, 1/1000, 3/2000); a main strike starts 4 fires on Normal or Hard; the fire odds hold id x 7; Peaceful disables the gated behaviours',[S(*c) for c in st],'CALL "DF-SITES" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4," ".join("/".join(str(v) for v in sites(*c)) for c in st))
g.extra=BD
g.run('local difficulty inputs: an unloaded chunk uses inhabited time 0 and moon 0; the time input is the overworld clock total, not the game time',["1 5000 0.75 100 24000","0 5000 0.75 100 24000","1 0 0.0 7 7","0 9 1.0 24000 100"],'COMPUTE WS-BD1 = WS-FX(4)\nCOMPUTE WS-BD2 = WS-FX(5)\nCALL "DF-INSTANCE" USING WS-I(1) WS-I(2) WS-FX(3) WS-BD1 WS-BD2 WS-R(1) WS-RF(1) WS-BD3\nCOMPUTE WS-R(2) ROUNDED = WS-RF(1) * 1000\nMOVE WS-BD3 TO WS-R(3)',3,"5000/750/24000 0/0/24000 0/0/7 0/0/100")
g.write(OUT+'/test_worldsim_33_9.cob')
# ============ 10
g=GG(10,10,'What is saved where',('T0517','the file and fields of each saved item of the 26.3 layout.'))
items=[(1,"level.dat","Time,spawn,difficulty_settings,GameType,LevelName,allowCommands,initialized,version"),(2,"data/minecraft/weather.dat","clear_weather_time,rain_time,thunder_time,raining,thundering"),(3,"data/minecraft/world_clocks.dat","total_ticks,partial_tick,rate,paused"),(4,"data/minecraft/game_rules.dat","rule values keyed by rule id"),(5,"minecraft/world_border.dat","center_x,center_z,damage_per_block,safe_zone,warning_blocks,warning_time,size,lerp_time,lerp_target")]
g.extra=" 01 WS-F48 PIC X(48).\n 01 WS-F160 PIC X(160).\n"
for i,f,fl in items:
    g.case('item %d: %s'%(i,f),[("%d"%i,'CALL "SV-LAYOUT" USING WS-I(1) WS-F48 WS-F160\nSTRING FUNCTION TRIM(WS-F48) "|" FUNCTION TRIM(WS-F160) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR',0)],"%s|%s"%(f,fl))
g.write(OUT+'/test_worldsim_33_10.cob')
