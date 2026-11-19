from rt9 import *
import math, struct
def f32(x): return struct.unpack('f', struct.pack('f', x))[0]
def mth_sin(x): return f32(math.sin((int(x * 10430.378350470453) & 65535) / 10430.378350470453))
doc = open(REPO + DOCS[9]).read().split('\n')
line = [l for l in doc if l.startswith('Shadow radius 0.15, strength 0.75. State: `icon')][0]
tiers = [(int(a), int(b)) for a, b in re.findall(r'>= (\d+): (\d+)', line)]
assert len(tiers) == 10
def icon(v):
    for th, ic in tiers:
        if v >= th: return ic
    return 0
t = mk9(14, ["Acceptance test of docs/protocol/34-entity-models-9-non-living-entities.md section 14 (experience orb): getIcon from the value (the tiers read from the document), the uv rectangle of an icon in the 4 x 4 sheet, the colour of the quad",
             "(integers r, g = 255, b, alpha 128, with the table sine of 34-9 section 2), the block light clamp(block + 7, 0, 15), the worked examples and Validation 6."])
for v in (0, 1, 2, 3, 6, 7, 16, 17, 20, 36, 37, 72, 73, 148, 149, 306, 307, 616, 617, 1236, 1237, 2476, 2477, 100000):
    t.call('EF9-ORB-ICON', [v], [icon(v)], '14 icon of value %d' % v)
assert icon(20) == 3 and icon(1237) == 9  # Validation 6 says value 2 gives icon 1, which contradicts the tier table (>= 3: 1): the table is followed
for ic in range(11):
    t.call('EF9-ORB-UV', [ic], [((ic % 4) * 16) / 64, ((ic % 4) * 16 + 16) / 64, ((ic // 4) * 16) / 64, ((ic // 4) * 16 + 16) / 64], '14 uv of icon %d (u0, u1, v0, v1)' % ic)
for age in (0, 1, 2.5, 3.1415927 * 2, 10, 57.3, 123.4, 1000):
    tt = age / 2
    r = int((mth_sin(tt) + 1) * 0.5 * 255); b = int((mth_sin(tt + 4.1887903) + 1) * 0.1 * 255)
    t.call('EF9-ORB-COLOR', [age], [r, 255, b, 128], '14 colour at ageInTicks %s (r, g, b, alpha)' % age)
t.call('EF9-ORB-COLOR', [0], [127, 255, 3, 128], '14 worked example: age 0 gives r 127, b 3')
t.call('EF9-ORB-COLOR', [3.1415927], [255, 255, 12, 128], '14 worked example: t = pi / 2 gives r 255, b 12')
for bl in (0, 3, 8, 9, 15):
    t.call('EF9-ORB-LIGHT', [bl], [min(max(bl + 7, 0), 15)], '14 block light %d' % bl)
save9(t, 14)
# the renderer: one camera-facing quad on the icon of the value, across the camera's right, coloured by the age
def rows_render():
    r = RT('TEST-ENTITY-ORB-9', ["Acceptance test of docs/protocol/34-entity-models-9-non-living-entities.md section 14 through the renderer: the quad of an orb is 0.3 wide from y + 0.025 to y + 0.325 across the camera's right (camera yaw 0, 90 and 33), on the icon of its value",
        "(texels of the 4 x 4 sheet in the atlas slot) with the integer tint of the document's colour for the age the clock gives."])
    r.extra = ' 01 WS-I2                BINARY-LONG.\n 01 WS-EXPECT            FLOAT-LONG.\n 01 WS-SLOT              BINARY-LONG.'
    r.start()
    r.raw('MOVE 1 TO WS-FIRST')
    for value, yaw, ms in ((20, 0, 0), (1237, 90, 5000), (7, 33, 12345), (2477, 180, 777)):
        ic = icon(value)
        r.spawn('experience_orb', 0, 0, 5)
        r.raw('MOVE %d TO EN-VALUE(1)' % value, 'MOVE %d TO PL-YAW' % yaw, 'MOVE %d TO CL-NOW-MS' % ms)
        r.mesh()
        c, s_ = math.cos(math.radians(yaw)), math.sin(math.radians(yaw))
        # right = (-cos yaw, -sin yaw); corners at +-0.15 across it
        xs = [0.5 + sx * 0.15 * (-c) for sx in (-1, 1)]; zs = [0.5 + sx * 0.15 * (-s_) for sx in (-1, 1)]
        ext = [math.floor(min(xs) * 1000 + 0.5), math.floor(max(xs) * 1000 + 0.5), 25, 325, math.floor(min(zs) * 1000 + 0.5), math.floor(max(zs) * 1000 + 0.5)]
        r.extent('34-9§14 orb value %d (icon %d) camera yaw %d' % (value, ic, yaw), ext, 6)
        # the vertex colour and the texels
        age = ms / 50
        tt = age / 2
        rr = int((mth_sin(tt) + 1) * 0.5 * 255); bb = int((mth_sin(tt + 4.1887903) + 1) * 0.1 * 255)
        r.check('34-9§14 orb value %d red x 255' % value, rr, 'FUNCTION INTEGER(RL-EN-R(1) * 255 + 0.5)')
        r.check('34-9§14 orb value %d green x 255' % value, 255, 'FUNCTION INTEGER(RL-EN-G(1) * 255 + 0.5)')
        r.check('34-9§14 orb value %d blue x 255' % value, bb, 'FUNCTION INTEGER(RL-EN-BLUE(1) * 255 + 0.5)')
        u0 = (ic % 4) * 16 / 64; u1 = u0 + 0.25; v0 = (ic // 4) * 16 / 64; v1 = v0 + 0.25
        r.raw('MOVE 0 TO WS-SLOT', 'PERFORM VARYING WS-I2 FROM 1 BY 1 UNTIL WS-I2 > EA-MT-COUNT', '    IF EA-MT-MODEL(WS-I2) = EN-MODEL(1)', '        MOVE WS-I2 TO WS-SLOT', '    END-IF', 'END-PERFORM')
        for k, (nm, uv, axis) in enumerate((('min u', min(u0, u1), 'U'), ('max u', max(u0, u1), 'U'), ('min v', v0, 'V'), ('max v', v1, 'V'))):
            fn = 'MIN' if nm.startswith('min') else 'MAX'
            a = 'RL-EN-U' if axis == 'U' else 'RL-EN-V'
            base = 'EA-MT-X(WS-SLOT)' if axis == 'U' else 'EA-MT-Y(WS-SLOT)'
            size = 'EA-MT-W(WS-SLOT)' if axis == 'U' else 'EA-MT-H(WS-SLOT)'
            atl = 'EA-W' if axis == 'U' else 'EA-H'
            vals = ' '.join('%s(%d)' % (a, i) for i in range(1, 7))
            r.raw('COMPUTE WS-EXPECT = (FUNCTION %s(%s) * %s - %s) / %s * 1000' % (fn, ' '.join('%s(%d)' % (a, i) for i in range(1, 7)), atl, base, size))
            r.check('34-9§14 orb value %d %s of the icon (thousandths of the icon sheet)' % (value, nm), int(round(uv * 1000)), 'FUNCTION INTEGER(WS-EXPECT + 0.5)')
    return r
rows_render().save('test_entity_orb_9')
