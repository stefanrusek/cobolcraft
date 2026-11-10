# Entity model generators (34-4 and 34-5)

Python 3 scripts that produce `client/src/entmodel-34-4-*.cob`, `client/src/entmodel-34-5*.cob`
and `client/tests/test_entmodel_34_4_*.cob` / `test_entmodel_34_5_*.cob`.
Inputs are only `docs/protocol/34-entity-models-*.md` (tables of parts, cubes and keyframes)
and `specs/002-client-polish/tasks.md` (test titles).

Run: `client/tests/gen/regen.sh` from anywhere. It resets `state/*.json` (the lists of
layers and defined mesh programs, rebuilt in section order), runs `s*.py` (sources),
then `t*.py` (tests). `git diff --stat client/` must show nothing afterwards.

Layout: `g4.py`/`mesh4.py`/`mesh5.py` shared helpers, `tgen.py` test DSL, `doc4.py`/`doc5.py`/`app4.py`/`app5.py`
document table parsers, `kfgen*.py` keyframe program template, `s*.py` source generators,
`t*.py` test generators (`s5_n`/`t5_n` are 34-5 section n; `ref4.py` independent keyframe sampler).
