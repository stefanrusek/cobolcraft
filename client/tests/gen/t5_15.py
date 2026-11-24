from mesh5 import *
import app5
t=mk(5,15,["Acceptance test of docs/protocol/34-entity-models-5-wild-companion-animals-small-creatures.md section 15 (keyframe tables) and the section 17 validation counts: for each of the six animation classes the number of animations, the channels",
 "and the keyframes summed over every channel read back from the loaded tables (fox baby 30 keyframes and 18 channels, bat 51 and 20, frog 185 and 43, armadillo adult 362 and 51, armadillo baby 393 and 59, sniffer 524 and 99). The per-channel sampling",
 "is tested in the section tests that own each table; this test is a coverage-only addition over programs those sections created."],ck=False)
t.extra_ws+='\n'+""" 01 WS-BONE               PIC X(24).
 01 WS-TARGET             BINARY-LONG.
 01 WS-KEYS               BINARY-LONG.
 01 WS-ANIM               BINARY-LONG.
 01 WS-I2                 BINARY-LONG.
 01 WS-SUMK               BINARY-LONG.
 01 WS-SUMC               BINARY-LONG."""
TAB=[('15.1','EF5F',['FOX_BABY_WALK'],'15.1',30,18),('15.2','EF5B',['BAT_RESTING','BAT_FLYING'],'15.2',51,20),('15.3','EF5G',[a['name'] for a in app5.parse('15.3')],'15.3',185,43),
     ('15.4','EF5A',[a['name'] for a in app5.parse('15.4')],'15.4',362,51),('15.5','EF5D',[a['name'] for a in app5.parse('15.5')],'15.5',393,59),('15.6','EF5S',[a['name'] for a in app5.parse('15.6')],'15.6',524,99)]
for tag,pre,names,doc,keys,chans in TAB:
    t.raw('MOVE 0 TO WS-SUMK WS-SUMC')
    for ai,nm in enumerate(names,1):
        a=app5.parse(doc)[ai-1]
        t.raw('MOVE %d TO WS-ANIM'%ai,'MOVE %s TO WS-IV(1)'%lit(ai),'CALL "%s-ANIM-INFO" USING WS-IN WS-OUT'%pre)
        t.num('%s %s channels'%(tag,nm),len(a['ch']),'WS-OV(3)')
        t.raw('ADD WS-OV(3) TO WS-SUMC','PERFORM VARYING WS-I2 FROM 1 BY 1 UNTIL WS-I2 > WS-OV(3)','    CALL "%s-ANIM-BONE" USING WS-ANIM WS-I2 WS-BONE WS-TARGET WS-KEYS'%pre,'    ADD WS-KEYS TO WS-SUMK','END-PERFORM')
    t.num('%s %s total keyframes over all channels (section 17)'%(tag,pre),keys,'WS-SUMK')
    t.num('%s %s total channels (section 17)'%(tag,pre),chans,'WS-SUMC')
save(t,5,15)
