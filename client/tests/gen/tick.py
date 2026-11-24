#!/usr/bin/env python3
"""Task tick helper (test infrastructure, not part of the gate). usage (from the repo root):
tick.py T3250,T3251 "note"  - turns `- [ ] T3250 ...` into `- [X] ...` in specs/002-client-polish/tasks.md
and appends the note in parentheses; an id that is missing or already ticked stops with an assertion."""
import sys,re
p='specs/002-client-polish/tasks.md'
s=open(p).read()
ids=[i.lstrip('T') for i in sys.argv[1].split(',')]
note=sys.argv[2]
for i in ids:
    pat=re.compile(r'^- \[ \] (T%s )(.*)$'%i, re.M)
    m=pat.search(s)
    assert m, i
    line=m.group(0).replace('- [ ]','- [X]',1)
    if note:
        line=line.rstrip()+' ('+note+')'
    s=s[:m.start()]+line+s[m.end():]
open(p,'w').write(s)
