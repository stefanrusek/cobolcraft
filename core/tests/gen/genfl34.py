import sys,struct,math
sys.path.insert(0,'core/tests/gen')
from gentest import *
f32=lambda x: struct.unpack('f',struct.pack('f',x))[0]
def axpb(a,x,b): return f32(f32(f32(a)*f32(x))+f32(b))
def m(x,n=1000000): return int(math.floor(x*n+0.5))
OUT=sys.argv[1] if len(sys.argv)>1 else "core/tests"
g=Gen('TEST-FLUIDS-29A-3','29a§3','Water and lava interaction','Test of 29a section 3, Water and lava interaction (core/src/fluids-29a.cob; T0483): LiquidBlock.shouldSpreadLiquid, the lava fizz event and the table of results.')
S='CALL "FL-SHOULD-SPREAD" USING WS-ISG WS-I(11) WS-I(12) WS-I(13) WS-R(1) WS-R(2)'
g.run('water always schedules; lava reacts to water above or beside it (obsidian for a source, cobblestone otherwise) and soul soil with blue ice makes basalt; the first reacting neighbour in the order UP, NORTH, SOUTH, WEST, EAST wins; no reaction schedules the tick',
 ["0 0 0 0 0 0 0 0 0 0 1 0 0","1 0 0 0 0 0 0 0 0 0 1 0 0","1 0 0 0 0 0 0 0 0 0 2 0 1","0 0 1 0 0 0 0 0 0 0 2 0 0","0 0 0 0 0 0 0 0 1 0 2 1 0","0 0 0 0 0 0 0 0 1 0 2 0 0","0 0 1 0 0 1 0 0 0 0 2 1 0","1 0 0 0 0 1 0 0 0 0 2 1 1","0 0 0 0 0 0 0 0 0 0 2 1 0"],S,2,
 "0/1 0/1 1/0 2/0 3/0 0/1 3/0 1/0 0/1")
g.run('the level event 1501 sound pitch is 2.6 + (r1 - r2) * 0.8 in single precision',["0.5 0.25","0.25 0.5","0.0 0.0","0.75 0.0"],'CALL "FL-FIZZ-PITCH" USING WS-FX(1) WS-FX(2) WS-RF(1)\nCOMPUTE WS-R(1) ROUNDED = WS-RF(1) * 1000000',1,
 " ".join(str(m(axpb(f32(a-b),0.8,2.6))) for a,b in ((0.5,0.25),(0.25,0.5),(0,0),(0.75,0)))) 
g.run('each of the 8 fizz particles is at (x + draw, y + 1.2, z + draw)',["10 64 -3 0.25 0.75"],'CALL "FL-FIZZ-PARTICLE" USING WS-I(1) WS-I(2) WS-I(3) WS-FX(4) WS-FX(5) WS-RF(1) WS-RF(2) WS-RF(3)\nCOMPUTE WS-R(1) ROUNDED = WS-RF(1) * 1000\nCOMPUTE WS-R(2) ROUNDED = WS-RF(2) * 1000\nCOMPUTE WS-R(3) ROUNDED = WS-RF(3) * 1000',3,"10250/65200/-2250")
g.write(OUT+'/test_fluids_29a_3.cob')
g=Gen('TEST-FLUIDS-29A-4','29a§4','Lava specifics','Test of 29a section 4, Lava specifics (core/src/fluids-29a.cob; T0485): the random tick offsets and decisions, entity effects and their order, lava ticks and client ambience.')
g.run('canSpreadFireAround: the rule -1 or a player close enough',["-1 0","128 1","128 0"],'CALL "FL-CAN-SPREAD-FIRE" USING WS-I(1) WS-I(2) WS-R(1)',1,"1 1 0")
g.run('fire spread offsets: each step moves (draw - 1, +1, draw - 1) from the previous position when n > 0, and (draw - 1, 0, draw - 1) from the lava cell when n = 0',["1 5 70 5 2 0","1 6 71 4 1 1","0 5 70 5 0 2"],'CALL "FL-LAVA-STEP" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1) WS-R(2) WS-R(3)',3,"6/71/4 6/72/4 4/70/6")
g.run('n > 0: an unloaded position or a motion-blocking block ends the tick, air with a flammable neighbour gets fire, other air goes on; n = 0: fire above a flammable block under an empty cell',
 ["1 0 0 0 0 0 0","1 1 1 1 0 0 0","1 1 1 0 0 0 0","1 1 0 0 0 0 1","1 1 0 0 0 0 0","0 0 0 0 1 1 0","0 1 0 0 1 1 0","0 1 0 0 0 1 0","0 1 0 0 1 0 0"],'CALL "FL-LAVA-DECIDE" USING %s WS-R(1)'%I(*range(1,8)),1,"2 1 0 2 0 2 3 0 0")
g.run('lavaIgnite raises the fire ticks to at least 300 unless the entity is fire-immune',["0 0","0 100","0 400","1 0"],'CALL "FL-IGNITE" USING WS-I(1) WS-I(2) WS-R(1)',1,"300 300 400 0")
g.run('lavaHurt deals 4.0 damage on the server to an entity that is not fire-immune and plays generic.burn unless silent',["0 1 0 1","1 1 0 1","0 0 0 1","0 1 1 1","0 1 0 0"],'CALL "FL-LAVA-HURT" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2)',2,"40/1 0/0 0/0 40/0 40/0")
g.run('the generic.burn pitch is 2.0 + nextFloat * 0.4',["0.5","0.0"],'CALL "FL-BURN-PITCH" USING WS-FX(1) WS-RF(1)\nCOMPUTE WS-R(1) ROUNDED = WS-RF(1) * 1000000',1," ".join(str(m(axpb(r,0.4,2.0))) for r in (0.5,0.0)))
g.run('effects apply in the order freeze, clear freeze, fire ignite, lava ignite (then lavaHurt), extinguish; the pass stops once the entity is dead',["0 0 0 1 1 1","0 0 0 1 1 0","1 1 0 0 0 1","0 0 0 0 0 0"],'CALL "FL-EFFECTS" USING WS-ISG WS-I(6) WS-RSG WS-R(9)',5,
 "4/6/5/0/0 4/6/0/0/0 1/2/0/0/0 0/0/0/0/0")
g.run('while in lava the fall distance halves each tick and the burning damage is skipped',["1 10","0 10"],'CALL "FL-LAVA-TICK" USING WS-I(1) WS-FX(2) WS-RF(1) WS-R(2)\nCOMPUTE WS-R(1) ROUNDED = WS-RF(1) * 1000',2,"5000/1 10000/0")
g.run('lava ambience: pop particle and sound only with air above on a 1 in 100 draw, ambient sound on a 1 in 200 draw',["1 0 0","1 5 0","0 0 7","1 99 199"],'CALL "FL-LAVA-AMBIENCE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2)',2,"1/1 0/1 0/0 0/0")
g.run('water ambience: a flowing non-falling state plays ambient.water on a 1 in 64 draw; a source or falling state spawns an underwater particle on a 1 in 10 draw',["0 0 3","0 5 3","1 0 0","1 0 4"],'CALL "FL-WATER-AMBIENCE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2)',2,"1/0 0/0 0/1 0/0")
g.run('lava.pop sound volume 0.2 + r * 0.2 and pitch 0.9 + r * 0.15; ambient.water volume r * 0.25 + 0.75 and pitch r + 0.5',["0.5 0.5"],'CALL "FL-SOUND-FORMULAS" USING WS-FX(1) WS-FX(2) WS-RF(1) WS-RF(2) WS-RF(3) WS-RF(4)\nCOMPUTE WS-R(1) ROUNDED = WS-RF(1) * 1000000\nCOMPUTE WS-R(2) ROUNDED = WS-RF(2) * 1000000\nCOMPUTE WS-R(3) ROUNDED = WS-RF(3) * 1000000\nCOMPUTE WS-R(4) ROUNDED = WS-RF(4) * 1000000',4,
 "%d/%d/%d/%d"%(m(axpb(.5,.2,.2)),m(axpb(.5,.15,.9)),m(axpb(.5,.25,.75)),m(axpb(.5,1.0,.5))))
g.write(OUT+'/test_fluids_29a_4.cob')
