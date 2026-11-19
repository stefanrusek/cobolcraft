from g9 import *
D = 0.017453292
t = mk9(18, ["Acceptance test of docs/protocol/34-entity-models-9-non-living-entities.md section 18 (worn equipment, cross-reference): the elytra model (both wings, deformation 1.0, the right wing mirrored), the baby elytra (the same scaled by 0.5),",
             "the elytra setupAnim (crouching raises the left wing to y 3; the right wing mirrors yaw and roll) and the shield model (plate and handle)."])
txt = [l for l in open(REPO + DOCS[9]).read().split('\n') if l.startswith('`ElytraModel`')][0]
rows = []
for m in re.finditer(r'`(left_wing|right_wing)` tex \((\d+), (\d+)\)( mirrored,)? (?:cuboid )?origin \(([^)]*)\),? size (\d+) x (\d+) x (\d+), deformation ([0-9.]+), pose off \(([^)]*)\), rot \(([^)]*)\)', txt):
    n, u, v, mir, org, w, h, d, g, off, rot = m.groups()
    rows.append('P %s root %s %s' % (n, ' '.join(x.strip() for x in off.split(',')), ' '.join(x.strip() for x in rot.split(','))))
    rows.append('C %s %s %s %s %s %s %s %s %d' % (n, u, v, ' '.join(x.strip() for x in org.split(',')), w, h, d, g, 1 if mir else 0))
assert len(rows) == 4, rows
layer_check(t, 'ELYTRA', rows, 64, 32, '18')
brows = scale_rows(rows, 0.5)
layer_check(t, 'ELYTRA_BABY', brows, 64, 32, '18 baby (MeshTransformer.scaling 0.5)')
def elytra(crouch, rx, ry, rz):
    y = 3.0 if crouch else 0.0
    return dict(left=(y, rx, ry, rz), right=(y, rx, -ry, -rz))
for crouch, rx, ry, rz in ((0, 0.2617994, 0, -0.2617994), (1, 0.2617994, 0, -0.2617994), (0, 0.9, 0.1, -0.5), (1, 1.2, -0.3, -1.1), (0, 0, 0, 0)):
    t.raw('MOVE "ELYTRA" TO WS-LAYER', 'CALL "EF9-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.setin([crouch, rx, ry, rz]); t.raw('CALL "EF9-ELYTRA-ANIM" USING EMM-MODEL WS-IN')
    e = elytra(crouch, rx, ry, rz)
    for side, name in (('left', 'left_wing'), ('right', 'right_wing')):
        y, x_, yy, z_ = e[side]
        t.cur(name, 'y', y); t.cur(name, 'xrot', x_); t.cur(name, 'yrot', yy); t.cur(name, 'zrot', z_)
srows = []
for r in table9('### 18') if False else []: pass
sh = re.search(r'`ShieldModel` \(texture (\d+) x (\d+), layer `SHIELD`\): `plate` tex \((\d+), (\d+)\) origin \(([^)]*)\) size (\d+) x (\d+) x (\d+); `handle` tex \((\d+), (\d+)\) origin \(([^)]*)\) size (\d+) x (\d+) x (\d+)', txt) or re.search(r'`ShieldModel` \(texture (\d+) x (\d+), layer `SHIELD`\): `plate` tex \((\d+), (\d+)\) origin \(([^)]*)\) size (\d+) x (\d+) x (\d+)\.? ?`handle` tex \((\d+), (\d+)\) origin \(([^)]*)\) size (\d+) x (\d+) x (\d+)', txt)
g = sh.groups()
srows = ['P plate root 0 0 0 0 0 0', 'C plate %s %s %s %s %s %s 0 0' % (g[2], g[3], ' '.join(x.strip() for x in g[4].split(',')), g[5], g[6], g[7]),
         'P handle root 0 0 0 0 0 0', 'C handle %s %s %s %s %s %s 0 0' % (g[8], g[9], ' '.join(x.strip() for x in g[10].split(',')), g[11], g[12], g[13])]
layer_check(t, 'SHIELD', srows, int(g[0]), int(g[1]), '18')
save9(t, 18)
