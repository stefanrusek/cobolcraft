"""spike (throwaway): facts about the user's inputs that the plan relies on, read as data
(docs/protocol/22 section 12 T1, T15; the Faithful pack's size classes for atlas planning)."""
import zipfile, collections, struct, sys
for path in sys.argv[1:]:
    z = zipfile.ZipFile(path)
    infos = z.infolist()
    files = [i for i in infos if not i.filename.endswith('/')]
    print(path.split('/')[-1], 'records', len(infos), 'files', len(files),
          'methods', dict(collections.Counter(i.compress_type for i in files)))
    sizes = collections.Counter()
    blocks = 0
    for i in files:
        n = i.filename
        if n.startswith('assets/minecraft/textures/block/') and n.endswith('.png'):
            d = z.read(n)[:24]
            w, h = struct.unpack('>II', d[16:24]); sizes[(w, h)] += 1; blocks += 1
    print('  block textures', blocks, 'by size', dict(sizes.most_common(6)))
    print('  block mcmeta', sum(1 for i in files if i.filename.startswith('assets/minecraft/textures/block/') and i.filename.endswith('.mcmeta')))
    print('  top dirs', sorted({i.filename.split('/')[0] for i in infos}))
