# Writes client/src/entmodel-34-9-1.cob (the registry facts of 34-9 section 1) from the tables of the document.
from g9 import *
def keys_of(cell): return re.findall(r'`([a-z_]+)`', cell)
def renderers():
    out = []
    for r in table9('### 1.1', 0):
        ks = keys_of(list(r.values())[0]); cls = re.findall(r'`([A-Za-z$]+)`', list(r.values())[1])
        if len(cls) == len(ks): pairs = list(zip(ks, cls))
        else: pairs = [(k, cls[0]) for k in ks]
        out += pairs
    return out
def shadow_of(cls):
    t = {'MinecartRenderer': (0.7, 1.0), 'TntMinecartRenderer': (0.7, 1.0), 'ItemEntityRenderer': (0.15, 0.75), 'ExperienceOrbRenderer': (0.15, 0.75), 'FallingBlockRenderer': (0.5, 1.0), 'TntRenderer': (0.5, 1.0)}
    if 'Display' in cls and cls != 'NoopRenderer': return (-1.0, -1.0)   # from the render state (17.1)
    return t.get(cls, (0.0, 1.0))
def hitboxes():
    out = []
    for r in table9('### 1.3', 1):
        v = list(r.values()); w, h = re.match(r'\s*' + NUMR + r' x ' + NUMR, v[1]).groups()
        eye = re.match(r'\s*(' + NUMR + r')\s*$', v[2]); out += [(k, float(w), float(h), float(eye.group(1)) if eye else -1.0) for k in keys_of(v[0])]
    return out
if __name__ == '__main__':
    def lit_(x): return ('%.6f' % x).rstrip('0').rstrip('.') if x != int(x) else str(int(x))
    o = ['*> Entity models part 9, section 1 the renderer registry (docs/protocol/34-entity-models-9-non-living-entities.md; written by client/tests/gen/s9_1.py from the tables of 1.1 and 1.3):',
         '*>   EF9-RENDERER key(X(24)) class(out X(40), spaces for a type this document does not own);',
         '*>   EF9-NOOP key(X(24)) OUT(1 1 when the renderer draws nothing (area_effect_cloud, interaction, marker));',
         '*>   EF9-SHADOW key(X(24)) OUT(1 known, 2 shadow radius, 3 shadow strength; radius -1 = from the render state, 17.1);',
         '*>   EF9-HITBOX key(X(24)) OUT(1 known, 2 width, 3 height, 4 eye height or -1 when the type has no eyeHeight call).', '']
    rs = renderers()
    o += [' IDENTIFICATION DIVISION.', ' PROGRAM-ID. EF9-RENDERER.', ' DATA DIVISION.', ' LINKAGE SECTION.', ' 01 L-KEY                  PIC X(24).', ' 01 L-CLASS                PIC X(40).',
          ' PROCEDURE DIVISION USING L-KEY L-CLASS.', '     MOVE SPACES TO L-CLASS', '     EVALUATE L-KEY']
    for k, c in rs: o += ['         WHEN "%s"' % k, '             MOVE "%s" TO L-CLASS' % c]
    o += ['         WHEN OTHER', '             CONTINUE', '     END-EVALUATE', '     GOBACK.', ' END PROGRAM EF9-RENDERER.', '']
    o += [' IDENTIFICATION DIVISION.', ' PROGRAM-ID. EF9-NOOP.', ' DATA DIVISION.', ' LINKAGE SECTION.', ' 01 L-KEY                  PIC X(24).', ' 01 L-OUT.', '    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.',
          ' PROCEDURE DIVISION USING L-KEY L-OUT.', '     MOVE 0 TO L-O(1)', '     EVALUATE L-KEY']
    for k, c in rs:
        if c == 'NoopRenderer': o.append('         WHEN "%s"' % k)
    o += ['             MOVE 1 TO L-O(1)', '         WHEN OTHER', '             CONTINUE', '     END-EVALUATE', '     GOBACK.', ' END PROGRAM EF9-NOOP.', '']
    o += [' IDENTIFICATION DIVISION.', ' PROGRAM-ID. EF9-SHADOW.', ' DATA DIVISION.', ' LINKAGE SECTION.', ' 01 L-KEY                  PIC X(24).', ' 01 L-OUT.', '    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.',
          ' PROCEDURE DIVISION USING L-KEY L-OUT.', '     MOVE 0 TO L-O(1)', '     MOVE 0 TO L-O(2)', '     MOVE 1 TO L-O(3)', '     EVALUATE L-KEY']
    groups = {}
    for k, c in rs:
        if c != 'NoopRenderer': groups.setdefault(shadow_of(c), []).append(k)
    for (rad, st), ks in groups.items():
        for k in ks: o.append('         WHEN "%s"' % k)
        o += ['             MOVE 1 TO L-O(1)', '             MOVE %s TO L-O(2)' % lit_(rad), '             MOVE %s TO L-O(3)' % lit_(st)]
    o += ['         WHEN OTHER', '             CONTINUE', '     END-EVALUATE', '     GOBACK.', ' END PROGRAM EF9-SHADOW.', '']
    o += [' IDENTIFICATION DIVISION.', ' PROGRAM-ID. EF9-HITBOX.', ' DATA DIVISION.', ' LINKAGE SECTION.', ' 01 L-KEY                  PIC X(24).', ' 01 L-OUT.', '    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.',
          ' PROCEDURE DIVISION USING L-KEY L-OUT.', '     MOVE 0 TO L-O(1) L-O(2) L-O(3) L-O(4)', '     EVALUATE L-KEY']
    for k, w, h, e in hitboxes(): o += ['         WHEN "%s"' % k, '             MOVE 1 TO L-O(1)', '             MOVE %s TO L-O(2)' % lit_(w), '             MOVE %s TO L-O(3)' % lit_(h), '             MOVE %s TO L-O(4)' % lit_(e)]
    o += ['         WHEN OTHER', '             CONTINUE', '     END-EVALUATE', '     GOBACK.', ' END PROGRAM EF9-HITBOX.', '']
    open(REPO + 'client/src/entmodel-34-9-1.cob', 'w').write('\n'.join(o))
