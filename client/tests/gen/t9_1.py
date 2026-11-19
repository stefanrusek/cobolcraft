from s9_1 import *
t = mk9(1, ["Acceptance test of docs/protocol/34-entity-models-9-non-living-entities.md section 1 (the renderer registry): the renderer class of each type of the 1.1 table, the three types that draw nothing (1.2 and Validation 1), the shadow radius and strength of 1.3",
            "and the hitbox and eye height of each type of the 1.3 table; a type this document does not own is not known."],
        extra='\n 01 WS-KEY               PIC X(24).\n 01 WS-CLASS             PIC X(40).')
rs = renderers()
assert len(rs) == 36 or len(rs) > 30, len(rs)
for k, c in rs:
    t.raw('MOVE "%s" TO WS-KEY' % k, 'MOVE SPACES TO WS-CLASS', 'CALL "EF9-RENDERER" USING WS-KEY WS-CLASS'); t.text('1.1 renderer of %s' % k, c, 'WS-CLASS')
    t.raw('CALL "EF9-NOOP" USING WS-KEY WS-OUT'); t.num('1.2 %s draws nothing' % k, 1 if c == 'NoopRenderer' else 0, 'WS-OV(1)')
    if c != 'NoopRenderer':
        rad, st = shadow_of(c)
        t.raw('CALL "EF9-SHADOW" USING WS-KEY WS-OUT'); t.num('1.3 %s shadow known' % k, 1, 'WS-OV(1)'); t.num('1.3 %s shadow radius' % k, rad, 'WS-OV(2)'); t.num('1.3 %s shadow strength' % k, st, 'WS-OV(3)')
assert sum(1 for k, c in rs if c == 'NoopRenderer') == 3 and {k for k, c in rs if c == 'NoopRenderer'} == {'area_effect_cloud', 'interaction', 'marker'}
for k, w, h, e in hitboxes():
    t.raw('MOVE "%s" TO WS-KEY' % k, 'CALL "EF9-HITBOX" USING WS-KEY WS-OUT'); t.num('1.3 %s hitbox known' % k, 1, 'WS-OV(1)'); t.num('1.3 %s width' % k, w, 'WS-OV(2)'); t.num('1.3 %s height' % k, h, 'WS-OV(3)'); t.num('1.3 %s eye height (-1 none)' % k, e, 'WS-OV(4)')
for k in ('pig', 'boat', 'zombie'):
    t.raw('MOVE "%s" TO WS-KEY' % k, 'MOVE "x" TO WS-CLASS', 'CALL "EF9-RENDERER" USING WS-KEY WS-CLASS'); t.text('1.1 %s is not a type of this document' % k, '', 'WS-CLASS')
    t.raw('CALL "EF9-HITBOX" USING WS-KEY WS-OUT'); t.num('1.3 %s has no hitbox here' % k, 0, 'WS-OV(1)')
    t.raw('CALL "EF9-SHADOW" USING WS-KEY WS-OUT'); t.num('1.3 %s has no shadow here' % k, 0, 'WS-OV(1)')
save9(t, 1)
