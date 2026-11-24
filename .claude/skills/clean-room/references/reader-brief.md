# Reader brief (clean-room dirty room)

Fill in the placeholders and pass this file's body as the subagent prompt.

---

You are the **reader** in a clean-room documentation round for the CobolCraft repository
(`/Users/stefanrusek/Code/cobolcraft`). Your job is to study a shipped artifact and write a specification of the
behaviour below into the project's reference docs, so that implementers can build it without ever seeing the
artifact.

**Artifact:** `<ARTIFACT_PATH>`, SHA-256 `<ARTIFACT_SHA256>`, version `<ARTIFACT_VERSION>`.

**Scope (what the docs must answer):**
<SCOPE: the ticket or spec item, the questions to answer, and the operator decisions that apply>

**Target:** `<TARGET_FILE>`, as <a new document | new section(s) <§> of an existing document>.

## Rules

1. **Reading:** static reading of the artifact only, with `javap -c -p -constants`, `unzip -l` / `unzip -p`, or REA.
   Do not run it.
2. **Code you may not read:** the repository's code: `shim/`, `proto/`, `core/`, `server/`, `client/`, `tests/`,
   `contract/`, `tools/`. Read `docs/` and `.specify/memory/constitution.md` for context and house style. Start with
   `docs/protocol/README.md`, and read one existing document, such as `06-chunk-format.md`, as a model.
3. **Files you may write:** only the target file(s) and `docs/protocol/README.md` (its Documents table, scope sentence
   and conventions). Keep working notes in your scratchpad directory, never in the repository.
4. **Form:** prose, tables, formulas and data schemas only.
   - Data schemas are allowed: JSON Schema, schema-style tables (member, kind, required or optional, allowed
     values, nested forms), grammars and byte layouts describe an interface, not code. A few-line example of a data
     file is fine; do not bulk-copy data files.
   - No source code, decompiled code, or pseudocode that follows the artifact's control flow line by line. Describe
     each algorithm in its own terms: inputs, outputs, steps, constants, invariants and ordering rules.
   - Class, method and field names may be cited in backticks to say where a fact was read. Never present them as
     the design.
5. **Completeness:** an implementer must be able to build the behaviour from your text alone. Every constant, table,
   ordering rule, random-number use (generator, seeding, call order) and edge case the behaviour depends on goes in
   the text. Where it helps, add worked examples with concrete inputs and expected outputs.
6. **Uncertainty:** mark every deduced value "(inferred)". Anything you could not trace goes in the document's
   numbered `## Open questions` section. Never guess silently.
   - **Count files from the archive, not from a listing.** A zip listing includes directory entries, so a count taken
     from `unzip -l` is too high (this inflated the recipe, damage-type, enchantment and loot-table counts in the
     first rounds). Count with `unzip -Z1 <archive> | grep -v '/$' | grep <prefix> | wc -l`.
   - **Recall is not evidence.** You may remember Minecraft's source code and the Minecraft wiki from training, and
     that memory may be about another version. Use it to decide where to look, never as a source: every value,
     formula and ordering you write must be read from the artifact in this round, even when it matches what you
     remember. Anything you could not read is marked "(recalled, not verified)" and listed in Open questions. Do not
     reproduce remembered code or wiki wording; see "Recalled knowledge is not evidence" in the skill.
7. **Header:** a new document starts with the format of `docs/protocol/README.md`'s header table: what it covers,
   the source artifact name and SHA-256, and the method ("Static reading of the shipped bytecode (`javap`), with no
   execution").
8. **No git:** do not commit or push; the orchestrator does.

## Report

When done, report:
- the files and sections written;
- the scope questions answered, each with its section number;
- the scope questions not answered, with the reason;
- the new Open questions.

Do not paste artifact bytecode or decompiled text into the report.
