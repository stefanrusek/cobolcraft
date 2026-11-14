from mesh6 import *
t=mk(6,14,["Acceptance test of docs/protocol/34-entity-models-6-overworld-hostiles-arthropods-slimes.md section 14 (render types and pipelines): for each of the eight render types the pipeline facts read (alpha cutout, blend, culling, depth compare and writes,",
 "per-face lighting, texture offset transform, sort on upload), -1 where the document says the fact was not traced, and the renderers that use each type."],ck=False)
t.extra_ws+='\n 01 WS-NAME2              PIC X(32).'
# found alpha blend culling depthcmp depthwrite perface offset sort
RT=[('entityCutout',[1,0.1,-1,0,-1,-1,1,-1,-1]),('entityCutoutZOffset',[1,-1,-1,-1,-1,-1,-1,-1,-1]),('entityTranslucent',[1,0.1,1,0,-1,-1,1,-1,-1]),('eyes',[1,-1,1,-1,1,0,-1,-1,-1]),
    ('entityTranslucentEmissive',[1,0.1,1,0,1,0,1,-1,-1]),('energySwirl',[1,-1,2,-1,0,1,-1,1,1]),('breezeWind',[1,0.1,1,0,-1,-1,0,1,1]),('outline',[1,-1,-1,-1,-1,-1,-1,-1,-1])]
for n,v in RT:
    t.raw('MOVE "%s" TO WS-X32'%n,'CALL "EF6-RENDER-TYPE" USING WS-X32 WS-OUT')
    for k,e in enumerate(v,1):
        lab=('found','alpha cutout (-1 not stated)','blend (1 TRANSLUCENT 2 ADDITIVE, -1 not stated)','culling (0 off, -1 not stated)','depth compare (0 default 1 GREATER_THAN_OR_EQUAL, -1 not stated)','depth writes (0 off 1 on, -1 not stated)','per-face lighting (1 yes 0 NO_CARDINAL_LIGHTING, -1 not stated)','offset texture transform (-1 not stated)','sort on upload (-1 not stated)')[k-1]
        t.num('14 %s %s'%(n,lab),e,'WS-OV(%d)'%k)
t.raw('MOVE "noSuchType" TO WS-X32','CALL "EF6-RENDER-TYPE" USING WS-X32 WS-OUT'); t.num('14 an unknown render type is not found',0,'WS-OV(1)')
USE=[('entityCutout',['creeper','enderman','silverfish','endermite','spider','slime','magma_cube','warden','shulker_bullet','guardian']),('entityCutoutZOffset',['shulker']),
     ('entityTranslucent',['breeze','slime','sulfur_cube','elder_guardian','shulker_bullet']),('eyes',['spider','enderman','phantom']),('entityTranslucentEmissive',['warden','breeze']),('energySwirl',['creeper']),('breezeWind',['breeze']),('outline',['slime'])]
ALL=['creeper','enderman','silverfish','endermite','spider','slime','magma_cube','warden','shulker_bullet','guardian','shulker','breeze','sulfur_cube','elder_guardian','phantom','cave_spider']
for n,us in USE:
    for e in ALL:
        t.raw('MOVE "%s" TO WS-X32'%n,'MOVE "%s" TO WS-X24'%e,'CALL "EF6-RENDER-TYPE-USED" USING WS-X32 WS-X24 WS-OUT')
        t.num('14 %s used by %s'%(n,e),1 if e in us else 0,'WS-OV(1)')
save(t,6,14)
