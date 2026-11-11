# Entity model generators (34-4 to 34-7)

Python 3 scripts that produce `client/src/entmodel-34-4-*.cob`, `client/src/entmodel-34-5*.cob`, `entmodel-34-6*.cob`, `entmodel-34-7*.cob`
and the matching `client/tests/test_entmodel_34_<part>_*.cob`.
Inputs are only `docs/protocol/34-entity-models-*.md` (tables of parts, cubes and keyframes)
and `specs/002-client-polish/tasks.md` (test titles).

Run: `client/tests/gen/regen.sh` from anywhere. It resets `state/*.json` (the lists of
layers and defined mesh programs, rebuilt in section order), runs `s*.py` (sources),
then `t*.py` (tests). `git diff --stat client/` must show nothing afterwards.

Layout: `g4.py`/`mesh4.py`/`mesh5.py` shared helpers, `tgen.py` test DSL, `doc4.py`/`doc5.py`/`app4.py`/`app5.py`
document table parsers, `kfgen*.py` keyframe program template, `s*.py` source generators,
`t*.py` test generators (`s5_n`/`t5_n` are 34-5 section n; `ref4.py` independent keyframe sampler).

Parts 6 and 7: `mesh6.py`/`mesh7.py` (layer table, EF6-LAYER and EF7-LAYER dispatchers, retain rules), `doc6.py`/`doc7.py` (part tables), `app6.py` (the keyframe tables of 34-6 8.6 and 9.5),
`prog6.py` (small program templates), `rng7.py` (the 48-bit generator of 34-7 1.5), and per section `s6_n.py`/`t6_n.py`, `s7_n.py`/`t7_n.py` (helpers `worm6`, `cube6`, `warden6`, `breeze6`, `guard6`, `blaze7`).
