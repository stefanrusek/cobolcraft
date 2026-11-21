"""spike (throwaway): generate a COBOL copybook shaped like the largest generated registry table
(30,000 block-state rows, 1,200 block rows of 16 columns, 1,500 item rows) so that cobc compile time,
object size and start-up cost can be measured (plan R-3). Usage: spike_gen_table.py <out.cpy> <style>
style 'filler': one FILLER VALUE per column (the style of core/copy/BLOCKS.cpy);
style 'packed': one fixed-width text row per record in a PIC X table, parsed by a loader.
style 'blob': the same bytes in rows of 400 characters, one literal per row (a free-format source line is limited to 512 bytes)."""
import sys
out, style = sys.argv[1], sys.argv[2]
with open(out, 'w') as f:
    if style == 'filler':
        f.write(' 01 BLOCK-DATA.\n')
        for i in range(1200):
            f.write('    05 FILLER.\n')
            f.write('       10 FILLER PIC X(48) VALUE "minecraft:block_%d".\n' % i)
            for c in range(15):
                f.write('       10 FILLER BINARY-LONG VALUE %d.\n' % (i * 7 + c))
        f.write(' 01 STATE-DATA.\n')
        for i in range(30000):
            f.write('    05 FILLER.\n')
            for c in range(3):
                f.write('       10 FILLER BINARY-LONG VALUE %d.\n' % (i + c))
    elif style == 'packed':
        f.write(' 01 BLOCK-DATA.\n')
        for i in range(1200):
            f.write('    05 FILLER PIC X(120) VALUE "minecraft:block_%d %s".\n' % (i, ' '.join(str(i * 7 + c) for c in range(15))))
        f.write(' 01 STATE-DATA.\n')
        for i in range(30000):
            f.write('    05 FILLER PIC X(24) VALUE "%d %d %d".\n' % (i, i + 1, i + 2))
    else:
        # 'blob': the same bytes as 'packed', but in rows of 400 characters, one literal per row (a free-format source line is limited to 512 bytes)
        rows = ['minecraft:block_%d %s' % (i, ' '.join(str(i * 7 + c) for c in range(15))) for i in range(1200)]
        rows = [r.ljust(120) for r in rows]
        text = ''.join(rows) + ''.join(('%d %d %d' % (i, i + 1, i + 2)).ljust(24) for i in range(30000))
        f.write(' 01 BLOB-DATA.\n')
        for k in range(0, len(text), 400):
            chunk = text[k:k + 400]
            f.write('    05 FILLER PIC X(%d) VALUE "%s".\n' % (len(chunk), chunk))
        f.write(' 01 BLOCK-DATA PIC X(1).\n 01 STATE-DATA PIC X(1).\n')
