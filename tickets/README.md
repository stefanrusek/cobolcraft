---
spile: project
project: CobolCraft
prefix: CC
counter: 7
---

# CobolCraft tickets

The CobolCraft tracker follows the [Spile spec](https://sugarmaple.ai/spile.md) (v0.4.0). It holds deferred work
(constitution Development Workflow, SDD 1.4) and the input for the next SDD runs.

- **Tickets:** each ticket is one `CC-NNNN-slug.md` file. The `counter` above is the last allocated ID number.
- **View:** the generated view is in [`views/cobolcraft-view.md`](views/cobolcraft-view.md). Regenerate it with
  `python3 .claude/skills/spile/scripts/view.py tickets` on every ticket change, and commit it with that change.
- **Skill:** how agents work with this tracker is in `.claude/skills/spile/SKILL.md`.
