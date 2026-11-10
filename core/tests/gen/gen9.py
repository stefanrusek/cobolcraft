import re,subprocess,sys
src=open('core/tests/gen/nearest.py').read().split("for yw,pt")[0]
ns={}
exec(src,ns)
near=ns['near']; axis=ns['axis']
head=open('core/tests/gen/head9.txt').read()
tail=open('core/tests/gen/tail9.txt').read()
out=[head]
def case(text, calls, exp):
    if len(text)>150:
        text=text[:150].rsplit(' ',1)[0]
    s='     MOVE "acceptance US12 29§9 Using an item on a block: %s" TO TL-CASE\n     PERFORM BEGIN-CASE\n' % text
    for c in calls:
        inp,call,n=c
        s+='     MOVE "%s" TO WS-IN\n     PERFORM LOAD-IN\n' % inp
        for l in call.split('\n'): s+='     %s\n' % l
        if n=='ORDER': s+='     PERFORM ADD-ORDER\n'
        else: s+='     MOVE %d TO WS-N\n     PERFORM ADD-N\n' % n
    s+='     MOVE "%s" TO TL-EXPECTED\n     CALL "TEST-ASSERT" USING TESTLIB-ASSERT\n' % exp
    out.append(s)
def run(name, text, inputs, call, n, exp):
    case(text, [(i,call,n) for i in inputs], exp)
F=lambda *a:" ".join("WS-FX(%d)"%i for i in a)
I=lambda *a:" ".join("WS-I(%d)"%i for i in a)
R=lambda k:" ".join("WS-R(%d)"%i for i in range(1,k+1))
run('r','the eye must be less than attribute + 1.0 from the block unit box: exactly 5.5 away is out, 5.4999 in, attribute 5.5 widens it, y distances count to the box faces',
 ["6.5 0.5 0.5 0 0 0 4.5","6.4999 0.5 0.5 0 0 0 4.5","6.5 0.5 0.5 0 0 0 5.5","1.5 6.0 0.5 0 0 0 5.5","1.5 7.0 0.5 0 0 0 4.5","1.5 -4.4 0.5 0 0 0 4.5","0.5 0.5 0.5 0 0 0 0"],
 'CALL "UI-RANGE-OK" USING %s %s WS-R(1)'%(F(1,2,3),I(4,5,6)+" "+F(7)),1,"0 1 1 1 0 1 1")
run('l','every hit offset from the block centre must be below 1.0000001 in absolute value',
 ["0.5 0.5 1.5 0 0 0","0.5 1.5000002 0.5 0 0 0","0.5 1.5 0.5 0 0 0","-0.4999999 0.5 0.5 0 0 0","-0.6 0.5 0.5 0 0 0","0.5 0.5 -0.6 0 0 0"],
 'CALL "UI-LOCATION-OK" USING %s %s WS-R(1)'%(F(1,2,3),I(4,5,6)),1,"1 0 1 1 0 0")
run('b','above the maximum y is build.tooHigh with maxY, below the minimum y build.tooLow with minY, the limits themselves are fine',
 ["320 -64 319","-65 -64 319","319 -64 319","-64 -64 319"],
 'CALL "UI-BUILD-LIMIT" USING %s WS-R(1) WS-R(2)'%I(1,2,3),2,"1/319 2/-64 0/0 0/0")
for kind,arg,pos,exp,txt in [(1,319,"","build.tooHigh|The height limit for building is 319|1","the build.tooHigh overlay is red and reads The height limit for building is 319"),
   (2,-64,"","build.tooLow|The minimum height for building is -64|1","the build.tooLow overlay is red and reads The minimum height for building is -64"),
   (3,0,"1, 64, 2","build.spawn_protection|1, 64, 2 is under spawn protection|1","the build.spawn_protection overlay takes the short position text as its string argument and is red")]:
    txt=txt[:150].rsplit(' ',1)[0] if len(txt)>150 else txt
    s='     MOVE "acceptance US12 29§9 Using an item on a block: %s" TO TL-CASE\n     PERFORM BEGIN-CASE\n'%txt
    s+='     MOVE "%d %d" TO WS-IN\n     PERFORM LOAD-IN\n     MOVE %s TO WS-POS\n'%(kind,arg,('"'+pos+'"') if pos else 'SPACES')
    s+='     CALL "UI-OVERLAY" USING WS-I(1) WS-I(2) WS-POS WS-KEY WS-TEXT WS-R(1)\n'
    s+='     MOVE WS-R(1) TO WS-SHOW\n     STRING FUNCTION TRIM(WS-KEY) "|" FUNCTION TRIM(WS-TEXT) "|" FUNCTION TRIM(WS-SHOW) DELIMITED BY SIZE INTO TL-OBSERVED\n'
    s+='     MOVE "%s" TO TL-EXPECTED\n     CALL "TEST-ASSERT" USING TESTLIB-ASSERT\n'%exp
    out.append(s)
G='CALL "UI-PACKET-GATE" USING %s WS-R(1) WS-R(2) WS-R(3) WS-R(4)'%I(*range(1,11))
run('g','not loaded is ignored without an ack; a disabled item, range and location stop after the ack; a click beyond the build limit shows its message and stops without a resend (stage 0), before the spawn check',
 ["0 1 1 1 64 -64 319 0 0 1","1 0 1 1 64 -64 319 0 0 1","1 1 0 1 64 -64 319 0 0 1","1 1 1 0 64 -64 319 0 0 1","1 1 1 1 320 -64 319 1 0 1","1 1 1 1 -65 -64 319 0 0 1"],G,4,
 "0/0/0/0 0/0/0/1 0/0/0/1 0/0/0/1 0/1/319/1 0/2/-64/1")
run('g2','spawn protection shows build.spawn_protection and goes to the resend (stage 2); an awaiting position or a refused mayInteract shows build.tooHigh with maxY (stage 3); otherwise the interaction runs (stage 1)',
 ["1 1 1 1 64 -64 319 1 0 1","1 1 1 1 64 -64 319 0 1 1","1 1 1 1 64 -64 319 0 0 0","1 1 1 1 64 -64 319 0 0 1","1 1 1 1 319 -64 319 0 0 1"],G,4,
 "2/3/0/1 3/1/319/1 3/1/319/1 1/0/0/1 1/0/0/1")
A='CALL "UI-PACKET-AFTER" USING %s WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)'%I(*range(1,7))
run('a','a consumed Success that swings calls swing twice and fires ANY_BLOCK_USE; SUCCESS_SERVER tells the acting client too; CONSUME consumes without a swing',
 ["1 1 64 -64 319 1","2 1 64 -64 319 1","3 1 64 -64 319 1","1 0 -64 -64 319 1"],A,5,"0/0/2/0/1 0/0/2/1/1 0/0/0/1/1 0/0/2/0/1")
run('a2','an UP click at the top limit with a placement attempt that was not consumed shows build.tooHigh twice; only chain 2 handles DOWN at the minimum limit; other clicks and non-attempts show nothing',
 ["5 1 319 -64 319 1","4 0 -64 -64 319 1","4 1 318 -64 319 1","4 1 319 -64 319 0","4 2 64 -64 319 1"],A,5,
 "2/0/0/1/0 0/1/0/1/0 0/0/0/1/0 0/0/0/1/0 0/0/0/1/0")
run('rs','the always-sent Block Updates are for the clicked position and the neighbour on the clicked face',["10 64 -3 5","10 64 -3 0"],
 'CALL "UI-RESYNC" USING %s WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-R(6)'%I(1,2,3,4),6,"10/64/-3/11/64/-3 10/64/-3/10/63/-3")
run('sp','a spectator opens a menu (consume) before anything else, teleports through a portal, gets spectator.cannot_teleport without a destination, and otherwise passes',
 ["1 0 0","1 1 1","0 1 1","0 1 0","0 0 0"],'CALL "UI-SPECTATOR-USE" USING %s WS-R(1) WS-R(2)'%I(1,2,3),2,"1/3 1/3 2/3 3/3 0/5")
B='CALL "UI-BLOCK-USE" USING %s WS-R(1) WS-R(2) WS-R(3)'%I(*range(1,7))
run('bu','sneaking with something in either hand skips the block interaction; sneaking with empty hands does not; a consuming useItemOn fires ITEM_USED_ON_BLOCK; TRY_WITH_EMPTY_HAND reaches useWithoutItem only for the main hand',
 ["1 0 1 0 1 1","1 1 1 0 1 1","0 0 0 0 3 5","0 0 0 0 6 3","0 0 0 1 6 3","0 0 0 0 6 5","0 0 0 0 5 3"],B,3,
 "5/0/1 1/1/0 3/1/0 3/2/0 5/0/1 5/0/1 5/0/1")
run('iu','an empty or cooling-down stack passes; creative restores the count; a Success with a different replacement puts it in the hand; a consuming result fires the trigger',
 ["1 0 0 1 0","0 1 0 1 0","0 0 1 1 1","0 0 0 3 1","0 0 0 4 1","0 0 0 1 0"],'CALL "UI-ITEM-USE" USING %s WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)'%I(*range(1,6)),5,
 "0/0/0/0/5 0/0/0/0/5 1/1/1/1/1 1/0/0/1/3 1/0/0/0/4 1/0/0/1/1")
run('ad','a player who cannot build passes unless can_place_on matches the clicked block',["0 0","0 1","1 0","1 1"],'CALL "UI-ADVENTURE" USING WS-I(1) WS-I(2) WS-R(1)',1,"1 0 0 0")
run('ua','only an item-interaction Success awards the item-used statistic',["1 1","3 0","4 1","2 0"],'CALL "UI-USEON-AFTER" USING WS-I(1) WS-I(2) WS-R(1)',1,"1 0 0 0")
run('yr','Direction.fromYRot gives SOUTH 0, WEST 90, NORTH 180, EAST 270 and -90, and rounds to the nearest',["0","90","180","270","-90","44.9","45"],'CALL "UI-FROM-YROT" USING WS-FX(1) WS-R(1)',1,"3 4 2 5 5 3 4")
run('cd','a context without a player faces NORTH, rotation 0 and is not secondary; with a player it uses the body yaw and the secondary flag',["0 90 1","1 90 1","1 90 0"],
 'CALL "UI-CONTEXT-DEFAULTS" USING WS-I(1) WS-FX(2) WS-R(1) WS-RF(1) WS-I(3) WS-R(3)\nCOMPUTE WS-R(2) = WS-RF(1)',3,"2/0/0 4/90/1 4/90/0")
run('pa','a block item or a filled bucket that is not on cooldown is a placement attempt; an empty stack, an empty bucket or another item is not',
 ["0 1 0 0","0 2 1 0","0 2 0 0","1 1 0 0","0 1 0 1","0 0 0 0"],'CALL "UI-PLACEMENT-ATTEMPT" USING %s WS-R(1)'%I(1,2,3,4),1,"1 1 0 0 0 0")
run('cr','default canBeReplaced needs the replaceable flag and an empty stack or another block; the fluid variant is the flag or not solid',
 ["1 1 0 0 0","1 1 0 1 0","1 1 1 1 0","1 0 0 0 0","2 0 0 0 0","2 0 0 0 1","2 1 0 0 1"],'CALL "UI-CAN-BE-REPLACED" USING %s WS-R(1)'%I(*range(1,6)),1,"1 0 1 0 1 0 1")
run('pq','getClickedPos is the clicked position when replaceClicked, else the neighbour on the face; canPlace follows replaceClicked or the neighbour',
 ["1 5 64 5 1","0 5 64 5 1","0 5 64 5 4"],'CALL "UI-PC-QUERY" USING %s WS-R(1) WS-R(2) WS-R(3)'%I(*range(1,6)),3,"5/64/5 5/65/5 4/64/5")
run('pc','canPlace is true when replaceClicked, else whether the state at the relative position can be replaced',["1 0","0 1","0 0"],'CALL "UI-PC-CAN-PLACE" USING WS-I(1) WS-I(2) WS-R(1)',1,"1 1 0")
run('at','at(context, pos, face) puts the hit location at the centre of the given face of pos',["3 64 -2 1","3 64 -2 4","3 64 -2 3"],
 'CALL "UI-PC-AT" USING %s WS-RF(1) WS-RF(2) WS-RF(3)\nCOMPUTE WS-R(1) = WS-RF(1) * 100\nCOMPUTE WS-R(2) = WS-RF(2) * 100\nCOMPUTE WS-R(3) = WS-RF(3) * 100'%I(1,2,3,4),3,"350/6500/-150 300/6450/-150 350/6450/-100")
cases=[(0,0,0),(0,0,1),(0,0,2),(90,0,2),(-90,0,0),(-90,0,2),(180,0,2),(0,-90,1),(270,0,0),(135,-30,1),(0,0,0)]
run('fa','getFacingAxis: X is EAST when -sin(yaw) is above 0, Z is SOUTH when cos(yaw) is above 0 (quantised table: yaw 90 gives SOUTH), Y is UP only for a pitch below 0',
 ["%d %d %d"%c for c in cases],'CALL "UI-FACING-AXIS" USING WS-FX(1) WS-FX(2) WS-I(3) WS-R(1)',1," ".join(str(axis(y,p)[a]) for y,p,a in cases))
oc=[(90,80),(0,0),(90,0),(-90,0),(180,0),(270,0),(45,0),(0,90),(0,-90),(135,-30),(-135,30),(30,10)]
run('no','orderedByNearest follows the decision list over the quantised sine and cosine (yaw 90 gives X, Y, Z: the cosine quantises to 0) and ends with the opposites of the first three',
 ["%d %d"%c for c in oc],'CALL "UI-NEAREST" USING WS-FX(1) WS-FX(2) WS-ORDER','ORDER'," ".join("".join(map(str,near(y,p))) for y,p in oc))
run('nd','getNearestLookingDirections moves the opposite of the clicked face to the front when not replacing the clicked block, shifting the ones before it by one',
 ["3 0 4 5 1 2 1 5","3 0 4 5 1 2 0 5","3 0 4 5 1 2 0 3","3 0 4 5 1 2 0 4","3 0 4 5 1 2 0 2"],'PERFORM LOAD-ORDER\nCALL "UI-NEAREST-DIRS" USING WS-I(7) WS-I(8) WS-ORDER','ORDER',
 "304512 430512 230451 530412 304512")
run('dp','DirectionalPlaceContext: horizontal direction NORTH for a vertical facing, else the facing; rotation is the 2D data value times 90 (-90 for a vertical facing)',
 ["0","1","2","3","4","5"],'CALL "UI-DPC" USING WS-I(1) WS-R(1) WS-R(2)',2,"2/-90 2/-90 2/180 3/0 4/90 5/270")
run('pl','BlockItem.place: a disabled block, a target that cannot be placed, a null context, no state, or a failed write is FAIL; success runs the post-write steps only when the block is the same',
 ["1 1 1 1 1 1","0 1 1 1 1 1","1 0 1 1 1 1","1 1 0 1 1 1","1 1 1 0 1 1","1 1 1 1 0 1","1 1 1 1 1 0"],'CALL "UI-PLACE" USING %s WS-R(1) WS-R(2)'%I(*range(1,7)),2,
 "1/1 4/0 4/0 4/0 4/0 4/0 1/0")
run('ps','the place sound has volume (volume + 1) / 2 and pitch times 0.8 in single precision',["1 1","0.5 1.5","0 0.5"],
 'CALL "UI-PLACE-SOUND" USING WS-FX(1) WS-FX(2) WS-RF(1) WS-RF(2)\nCOMPUTE WS-R(1) ROUNDED = WS-RF(1) * 1000\nCOMPUTE WS-R(2) ROUNDED = WS-RF(2) * 1000000',2,"1000/800000 750/1200000 500/400000")
run('cp','canPlace needs survival when a player exists and mustSurvive, and an unobstructed shape',["1 1 1 1","1 1 0 1","1 0 0 1","0 1 0 1","1 1 1 0","0 0 0 0"],'CALL "UI-CAN-PLACE" USING %s WS-R(1)'%I(1,2,3,4),1,"1 0 1 1 0 0")
run('bb','blocksBuilding is true for living entities, boats, minecarts, end crystals, primed TNT, falling blocks and non-marker armor stands, false for items and other entities',
 ["1 0","2 0","3 0","4 0","5 0","6 0","7 0","7 1","8 0","0 0"],'CALL "UI-BLOCKS-BUILDING" USING WS-I(1) WS-I(2) WS-R(1)',1,"1 1 1 1 1 1 1 0 0 0")
run('eb','an entity obstructs only when not removed, blocksBuilding, not a passenger of the same vehicle, not a spectator and its box intersects the shape',
 ["0 1 0 0 1","1 1 0 0 1","0 0 0 0 1","0 1 1 0 1","0 1 0 1 1","0 1 0 0 0"],'CALL "UI-ENTITY-BLOCKS" USING %s WS-R(1)'%I(*range(1,6)),1,"1 0 0 0 0 0")
run('un','a position is unobstructed when the collision shape is empty or no blocking entity intersects it',["1 5","0 0","0 2"],'CALL "UI-UNOBSTRUCTED" USING WS-I(1) WS-I(2) WS-R(1)',1,"1 1 0")
run('pctx','the placement collision context: descending from the player, placement true, the entity bottom is the player Y, and -Double.MAX_VALUE without a player',["1 1 64","0 0 64"],
 'CALL "UI-PLACEMENT-CTX" USING WS-I(1) WS-I(2) WS-FX(3) WS-R(1) WS-R(2) WS-RF(1)\nCOMPUTE WS-R(3) = WS-RF(1)\nIF WS-RF(1) < -1.0E300\nMOVE 1 TO WS-R(3)\nEND-IF',3,"1/1/64 0/1/1")
run('bi','BlockItem.useOn returns the place result if it consumes, else the transformer result if it consumes, else eating for a consumable, else the first place result',
 ["1 4 0 5","4 1 0 5","4 5 1 3","4 5 0 3","5 5 0 3","3 1 0 5"],'CALL "UI-BLOCKITEM-USEON" USING %s WS-R(1)'%I(1,2,3,4),1,"1 1 3 4 5 3")
run('gm','canUseGameMasterBlocks needs infinite materials and the gamemaster permission',["1 1","1 0","0 1"],'CALL "UI-GM-BLOCKS" USING WS-I(1) WS-I(2) WS-R(1)',1,"1 0 0")
run('bt','the block_entity_data component loads only with a component, a block entity of the same type and, for operator-only types, game master rights',
 ["1 1 1 0 0","1 1 1 1 0","1 1 1 1 1","0 1 1 0 0","1 0 1 0 0","1 1 0 0 0"],'CALL "UI-BE-TAG" USING %s WS-R(1)'%I(*range(1,6)),1,"1 0 1 0 0 0")
run('ui','useItem: a spectator or cooldown passes; an unchanged stack without a use duration returns the result; a failed use of a duration item while not using returns it; otherwise the stack is stored, emptied and the menu resent when not using',
 ["1 0 0 0 0 0 0 0 0 0","0 1 0 0 0 0 0 0 0 0","0 0 1 1 0 1 0 0 0 0","0 0 1 1 30 1 0 0 0 0","0 0 0 0 30 0 1 0 0 0","0 0 0 0 30 0 1 1 0 1","0 0 0 0 0 0 0 1 1 1"],
 'CALL "UI-USEITEM" USING %s WS-R(1) WS-R(2) WS-R(3) WS-R(4)'%I(*range(1,11)),4,"1/0/0/0 1/0/0/0 2/0/0/0 0/0/0/1 3/0/0/0 0/1/0/0 0/1/1/0")
run('wd','Mth.wrapDegrees maps into [-180, 180): 190 to -170, -190 to 170, 180 and -180 to -180',["190","-190","180","-180","540","359","0"],
 'CALL "UI-WRAP-DEGREES" USING WS-FX(1) WS-RF(1)\nCOMPUTE WS-R(1) = WS-RF(1)',1,"-170 170 -180 -180 -180 -1 0")
run('fp','float comparison is exact: neighbouring single-precision values 0.7000000476837158 and 0.699999988079071 differ, equal values give 0',["1 2","2 2","3 2","0.7000000476837158 0.699999988079071","0.699999988079071 0.7000000476837158"],'CALL "FP-CMP" USING WS-FX(1) WS-FX(2) WS-R(1)',1,"-1 0 1 1 -1")
import re as _re
body=_re.sub(r'WS-(I|FX|R|RF)\((\d+)\)',r'WS-\1\2',"".join(out[1:]))
h=head
def decl(name,usage,cnt):
    return "".join(" 01 WS-%s%d %s.\n"%(name,i,usage) for i in range(1,cnt+1))
tbl=lambda grp,name,usage,cnt,red: (" 01 WS-%sG.\n"%grp)+"".join("    05 WS-%s%d %s.\n"%(name,i,usage) for i in range(1,cnt+1))+" 01 WS-%sT REDEFINES WS-%sG.\n    05 WS-%s %s OCCURS %d TIMES.\n"%(grp,grp,name,usage,cnt)
import re
h=re.sub(r" 01 WS-IS\.\n.*?OCCURS 16 TIMES\.\n", tbl('IS','I','BINARY-LONG',16,0), h, flags=re.S)
h=re.sub(r" 01 WS-FXS\.\n.*?OCCURS 16 TIMES\.\n", tbl('FXS','FX','FLOAT-LONG',16,0), h, flags=re.S)
h=re.sub(r" 01 WS-RS\.\n.*?OCCURS 16 TIMES\.\n", tbl('RS','R','BINARY-LONG',16,0), h, flags=re.S)
h=re.sub(r" 01 WS-RFS\.\n.*?OCCURS 4 TIMES\.\n", tbl('RFS','RF','FLOAT-LONG',4,0), h, flags=re.S)
h=h.replace(" 01 WS-ORDER.\n    05 WS-DIR              BINARY-LONG OCCURS 6 TIMES.\n"," 01 WS-ORDER.\n"+"".join("    05 WS-DIR%d BINARY-LONG.\n"%i for i in range(1,7))+" 01 WS-ORDT REDEFINES WS-ORDER.\n    05 WS-DIR BINARY-LONG OCCURS 6 TIMES.\n")
open('core/tests/test_blockupd_29_9.cob','w').write(h+body+tail)
