from mesh6 import *
import app6
WROWS=doc6.rows_from(6,'### 8.1')
ALL=['head','left_arm','right_arm','left_leg','right_leg']
def define():
    setlayer('WARDEN',WROWS,128,128)
    setlayer('WARDEN_BIOLUMINESCENT',WROWS,128,128,src='WARDEN',retain=(1,ALL))
    setlayer('WARDEN_PULSATING_SPOTS',WROWS,128,128,src='WARDEN',retain=(1,['body','head','left_arm','right_arm','left_leg','right_leg']))
    setlayer('WARDEN_TENDRILS',WROWS,128,128,src='WARDEN',retain=(1,['left_tendril','right_tendril']))
    setlayer('WARDEN_HEART',WROWS,128,128,src='WARDEN',retain=(1,['body']))
IDS=['WARDEN','WARDEN_BIOLUMINESCENT','WARDEN_PULSATING_SPOTS','WARDEN_TENDRILS','WARDEN_HEART']
AN=app6.parse(6,'### 8.6'); NM=[a['name'] for a in AN]
