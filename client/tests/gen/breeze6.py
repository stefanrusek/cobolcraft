from mesh6 import *
import app6
HB=[('-5','-5','-4.2','10','3','4','4','24'),('-4','-8','-4','8','8','8','0','0')]
def cubes(name,bs):
    return ['C %s %s %s %s %s %s %s %s %s 0 0'%(name,b[6],b[7],b[0],b[1],b[2],b[3],b[4],b[5]) for b in bs]
ROD=[('-1','0','-3','2','8','2','0','17')]
def rows():
    r=['P body root 0 0 0 0 0 0','P rods body 0 8 0 0 0 0']
    r.append('P rod_1 rods 2.5981 -3 1.5 -2.7489 -1.0472 3.1416'); r+=cubes('rod_1',ROD)
    r.append('P rod_2 rods -2.5981 -3 1.5 -2.7489 1.0472 3.1416'); r+=cubes('rod_2',ROD)
    r.append('P rod_3 rods 0 -3 -3 0.3927 0 0'); r+=cubes('rod_3',ROD)
    r.append('P head body 0 4 0 0 0 0'); r+=cubes('head',HB)
    r.append('P eyes head 0 0 0 0 0 0'); r+=cubes('eyes',HB)
    r.append('P wind_body root 0 0 0 0 0 0')
    r.append('P wind_bottom wind_body 0 24 0 0 0 0'); r+=cubes('wind_bottom',[('-2.5','-7','-2.5','5','7','5','1','83')])
    r.append('P wind_mid wind_bottom 0 -7 0 0 0 0'); r+=cubes('wind_mid',[('-6','-6','-6','12','6','12','74','28'),('-4','-6','-4','8','6','8','78','32'),('-2.5','-6','-2.5','5','6','5','49','71')])
    r.append('P wind_top wind_mid 0 -6 0 0 0 0'); r+=cubes('wind_top',[('-9','-8','-9','18','8','18','0','0'),('-6','-8','-6','12','8','12','6','6'),('-2.5','-8','-2.5','5','8','5','105','57')])
    return r
LAYERS=['BREEZE','BREEZE_WIND','BREEZE_EYES']
def define():
    setlayer('BREEZE_BASE',rows(),32,32)
    setlayer('BREEZE',rows(),32,32,src='BREEZE_BASE',retain=(2,['head','rods']))
    setlayer('BREEZE_WIND',rows(),128,128,src='BREEZE_BASE',retain=(2,['wind_body']))
    setlayer('BREEZE_EYES',rows(),32,32,src='BREEZE_BASE',retain=(2,['eyes']))
IDS=['BREEZE_BASE']
AN=app6.parse(6,'### 9.5'); NM=[a['name'] for a in AN]
