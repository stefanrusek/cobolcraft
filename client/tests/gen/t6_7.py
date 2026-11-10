from cube6 import *
define()
t=mk(6,7,["Acceptance test of docs/protocol/34-entity-models-6-overworld-hostiles-arthropods-slimes.md section 7 (Slime, magma cube and sulfur cube): 7.1 to 7.3 the meshes (slime inner and outer, the magma cube slices, the four sulfur cube layers),",
 "7.2 the magma cube slice wave (example 15.4), 7.4 the common size and squish scale (example 15.3), the slight downscale, shadow and the squish tick of AbstractCubeMob, 7.5 the slime outer layer decision, 7.6 magma texture and block light,",
 "7.7 the sulfur cube: baby selection, fuse remaining ticks, body item classification, scale stack (example 15.14), inner layer overlay and draw mode, custom head transform and textures."],ck=True)
t.LP='EF6-LAYER'
mesh_checks(t,IDS,'7')
for sq in (0.5,0,-0.3,1.2,0.25):
    P=base_parts('MAGMA_CUBE')
    for i in range(8): P['cube%d'%i][1]=-(4-i)*max(0,sq)*1.7
    pose_check(t,'MAGMA_CUBE','EF6-MAGMA-ANIM',[sq],P)
t.build('MAGMA_CUBE'); t.setin([0.5]); t.raw('CALL "EF6-MAGMA-ANIM" USING EMM-MODEL WS-IN')
for i,y in enumerate((-3.4,-2.55,-1.7,-0.85,0,0.85,1.7,2.55)): t.cur('cube%d'%i,'y',y)
def cscale(n,sq,contained=0):
    q=0 if contained else sq/(n*0.5+1); r=1/(q+1); return [r*n,n/r,r*n]
for n,sq in ((2,0.5),(4,-0.3),(1,0),(8,0.9),(127,-0.5),(3,1)):
    t.call('EF6-CUBE-SCALE',[n,sq,0],cscale(n,sq),'7.4 size %d squish %s scale (x, y, z)'%(n,sq))
t.call('EF6-CUBE-SCALE',[2,0.5,0],[1.6,2.5,1.6],'7.4 example 15.3 slime size 2 squish 0.5')
t.call('EF6-CUBE-SCALE',[4,-0.3,0],[4.44444,3.6,4.44444],'7.4 example 15.3 size 4 squish -0.3')
for n,sq in ((3,0.7),(1,-0.4)): t.call('EF6-CUBE-SCALE',[n,sq,1],cscale(n,sq,1),'7.7 size %d squish %s holding a block does not squish'%(n,sq))
t.call('EF6-CUBE-DOWNSCALE',[],[2,2,0.999,0.999,0.999,1,0,0.001,0],'7.4 downscaleSlightly (count; code 2 scale, 1 translate; three values each)')
for n in (1,2,4.5,127): t.call('EF6-CUBE-SHADOW',[n],[n*0.25],'7.4 shadow radius size %s'%n)
def tick(sq,tg,ground,was,magma):
    o=sq; sq=sq+(tg-sq)*0.5; land=0; off=0
    if ground and not was: tg=-0.5; land=1
    if (not ground) and was: tg=1; off=1
    was=ground; tg*= (0.9 if magma else 0.6)
    return [o,sq,tg,was,land,off]
for sq,tg,gr,wa,mg in ((0,0,1,1,0),(0.2,1,0,1,0),(0.4,-0.5,1,0,0),(-0.2,0.3,0,0,1),(0.1,0.5,1,0,1),(0.7,0.7,0,1,1),(0,0,0,0,0)):
    t.call('EF6-CUBE-TICK',[sq,tg,gr,wa,mg],tick(sq,tg,gr,wa,mg),'7.4 squish tick squish %s target %s on ground %d was on ground %d magma %d (old squish, squish, target, was on ground, landed, took off)'%(sq,tg,gr,wa,mg))
for gl,inv,dr,ol in ((0,0,1,0),(1,0,1,0),(0,1,0,0),(1,1,1,1)):
    t.call('EF6-SLIME-OUTER',[gl,inv],[dr,ol],'7.5 outer layer glowing %d invisible %d (draw, outline instead of translucent)'%(gl,inv))
for k,e in ((0,'textures/entity/slime/slime.png'),(1,'textures/entity/slime/magmacube.png'),(2,'textures/entity/sulfur_cube/sulfur_cube_outer.png'),(3,'textures/entity/sulfur_cube/sulfur_cube_outer_small.png'),(4,'textures/entity/sulfur_cube/sulfur_cube_inner.png'),(5,'textures/entity/sulfur_cube/sulfur_cube_inner_small.png')):
    text_check(t,'EF6-CUBE-TEXTURE',[k],'7 texture kind %d'%k,e)
t.call('EF6-MAGMA-BLOCKLIGHT',[],[15],'7.6 block light level')
for f,p,pr,e in ((5,0.5,1,5.5),(-1,0.5,0,0),(0,0,1,1),(3.2,0.25,1,3.95),(10,0,1,11),(7,0.5,0,0)):
    t.call('EF6-SULFUR-FUSE',[f,p,pr],[e],'7.7 fuseRemainingTicks fuse %s partial %s primed %d'%(f,p,pr))
for emp,bi,sk,e in ((1,0,0,0),(0,1,1,1),(0,1,0,2),(0,0,0,2),(1,1,1,0)):
    t.call('EF6-SULFUR-BODY',[emp,bi,sk],[e],'7.7 body item empty %d block item %d skull %d (0 nothing, 1 worn head, 2 contained block)'%(emp,bi,sk))
def swell(f): return 0.3*max(0,min(1,1-f/10))**4
def sops(baby,inv,n,sq,cont,fuse):
    ops=[(2,0.999,0.999,0.999),(1,0,0.001,0)]
    c=cscale(n,sq,cont); ops.append((2,c[0],c[1],c[2]))
    if 0<fuse<10: s=1+swell(fuse); ops.append((2,s,s,s))
    y0=1.24 if baby else 0.98; s=1.0 if baby else 0.5; h=(0 if inv else 1)/16
    ops.append((2,s,s,s)); ops.append((1,0,y0-h,0))
    return [len(ops)]+[x for o in ops for x in o]
for baby,inv,n,sq,cont,fuse in ((0,0,1,0,0,0),(1,0,1,0,0,0),(0,0,2,0.5,0,5),(1,1,3,-0.2,0,1),(0,0,4,0.3,1,9),(0,1,2,0.1,0,10),(1,0,1,0.2,0,12)):
    t.call('EF6-SULFUR-SCALE-OPS',[baby,inv,n,sq,cont,fuse],sops(baby,inv,n,sq,cont,fuse),'7.7 scale stack baby %d invisible %d size %d squish %s contained %d fuse remaining %s (count; code 1 translate 2 scale; values)'%(baby,inv,n,sq,cont,fuse))
t.call('EF6-SULFUR-SCALE-OPS',[0,0,1,0,0,5],sops(0,0,1,0,0,5),'7.7 example 15.14 adult swell at fuse 5')
t.call('EF6-SULFUR-SWELL',[5],[0.01875],'7.7 example 15.14 swell at fuse 5')
t.call('EF6-SULFUR-SWELL',[1],[0.19683],'7.7 example 15.14 swell at fuse 1')
t.call('EF6-SULFUR-SWELL',[12],[0],'7.7 swell is clamped at 0 past the fuse range (coverage-only addition)')
t.call('EF6-SULFUR-SWELL',[-3],[0.3*(1.3)**0 if False else 0.3],'7.7 swell is clamped at 1 for a negative fuse (coverage-only addition)')
t.call('EF6-SULFUR-SWELL',[9],[0.00003],'7.7 example 15.14 swell at fuse 9')
for f,r,e in ((3.2,1,1),(7.3,1,0),(0,1,1),(-1,1,0),(12,1,1),(3.2,0,0),(5,1,0)):
    t.call('EF6-SULFUR-LIT',[f,r],[e],'7.7 overlay white fuse %s fuse remaining positive %d'%(f,r))
for worn,cont,baby,inv in ((1,0,0,0),(0,1,0,0),(0,1,1,0),(0,0,0,0),(0,0,1,0),(0,0,0,1),(0,1,0,1)):
    if worn: e=[0]
    elif cont:
        ops=[(6,180,0,0)]+([(2,0.5,0.5,0.5)] if baby else [])+[(1,-0.5,-0.518,-0.5)]
        e=[1,len(ops)]+[x for o in ops for x in o]
    elif inv: e=[0]
    else: e=[2]
    t.call('EF6-SULFUR-INNER',[worn,cont,baby,inv],e,'7.7 inner layer worn head %d contained %d baby %d invisible %d (mode 0 skip 1 block 2 inner model at order -1; block ops count and ops)'%(worn,cont,baby,inv))
t.call('EF6-SULFUR-HEAD',[],[0,0.625,0.84210527,0.84210527],'7.7 custom head transforms (yOffset, skullYOffset, horizontal scale, vertical scale)')
save(t,6,7)
