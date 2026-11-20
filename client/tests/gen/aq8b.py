# Layers of 34-8 sections 3 to 7 read from the part tables of the document (docpose.py); the equipment layers of the nautilus, the chest parts of the boats and the water patch are built from the text of 6.3, 6.4 and 7.1.
from mesh8 import *
from docpose import rows_pose
def define_aq():
    setlayer('DOLPHIN', rows_pose('### 3.1', 0), 64, 64); setlayer('DOLPHIN_BABY', rows_pose('### 3.1', 1), 64, 64)
    setlayer('AXOLOTL', rows_pose('### 4.1', 0), 64, 64); setlayer('AXOLOTL_BABY', rows_pose('### 4.3', 0, rootname='baby_root'), 32, 32)
    setlayer('COD', rows_pose('### 5.1', 0), 32, 32)
    setlayer('SALMON', rows_pose('### 5.2', 0), 32, 32)
    setlayer('SALMON_SMALL', rows_pose('### 5.2', 0), 32, 32, sc=(0.5,)); setlayer('SALMON_LARGE', rows_pose('### 5.2', 0), 32, 32, sc=(1.5,))
    for k, n in enumerate(('SMALL', 'MEDIUM', 'BIG')): setlayer('PUFFERFISH_' + n, rows_pose('### 5.3', k), 32, 32)
    for k, n in enumerate(('SMALL', 'LARGE')):
        setlayer('TROPICAL_' + n, rows_pose('### 5.4', k), 32, 32)
        setlayer('TROPICAL_%s_PATTERN' % n, rows_pose('### 5.4', k, allgrow='0.008'), 32, 32)
    adult = rows_pose('### 6.1', 0, rootname='nroot')
    setlayer('NAUTILUS', adult, 128, 128); setlayer('ZOMBIE_NAUTILUS', adult, 128, 128)
    setlayer('NAUTILUS_BABY', rows_pose('### 6.2', 0, rootname='nroot'), 64, 64)
    shell = ['C shell 0 0 -7 -10 -7 14 10 16 %s 0', 'C shell 0 26 -7 0 -7 14 8 20 %s 0', 'C shell 48 26 -7 0 6 14 8 0 %s 0']
    def swap(rows, boxes):
        out = []; done = False
        for r in rows:
            if r.startswith('C shell '):
                if not done: out += boxes; done = True
                continue
            out.append(r)
        return out
    setlayer('NAUTILUS_SADDLE', swap(adult, [shell[0] % '0.2']), 128, 128)
    setlayer('NAUTILUS_ARMOR', swap(adult, [shell[0] % '0.01', shell[1] % '0.01', shell[2] % '0']), 128, 128)
    coral = ['P corals shell 8 4.5 -8 0 0 0'] + rows_pose('### 6.4', 0)
    setlayer('ZOMBIE_NAUTILUS_CORAL', adult + coral, 128, 128)
    boat = rows_pose('### 7.1', 0)
    cb = ['P chest_bottom root -2 -5 -6 0 -1.5707964 0', 'C chest_bottom 0 76 0 0 0 12 8 12 0 0', 'P chest_lid root -2 -9 -6 0 -1.5707964 0', 'C chest_lid 0 59 0 0 0 12 4 12 0 0',
          'P chest_lock root -1 -6 -1 0 -1.5707964 0', 'C chest_lock 0 59 0 0 0 2 4 1 0 0']
    raft = rows_pose('### 7.1', 1)
    rc = ['P chest_bottom root -2 -10.1 -6 0 -1.5707964 0', 'C chest_bottom 0 76 0 0 0 12 8 12 0 0', 'P chest_lid root -2 -14.1 -6 0 -1.5707964 0', 'C chest_lid 0 59 0 0 0 12 4 12 0 0',
          'P chest_lock root -1 -11.1 -1 0 -1.5707964 0', 'C chest_lock 0 59 0 0 0 2 4 1 0 0']
    setlayer('BOAT', boat, 128, 64); setlayer('CHEST_BOAT', boat + cb, 128, 128)
    setlayer('RAFT', raft, 128, 64); setlayer('CHEST_RAFT', raft + rc, 128, 128)
    setlayer('BOAT_WATER_PATCH', ['P water_patch root 0 -3 1 1.5707964 0 0', 'C water_patch 0 0 -14 -9 -3 28 16 3 0 0'], 0, 0)
