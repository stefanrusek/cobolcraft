---
name: clean-room
description: Extend CobolCraft's reference docs (docs/protocol/, docs/design/) with behaviour read from a shipped artifact such as the vanilla client jar, through a clean-room process. A reader agent studies the artifact and writes prose and tables only, a separate reviewer checks the result for contamination and completeness, and implementers then work from the docs alone (constitution Principle II). Use when a spec, ticket or implement phase needs behaviour that docs/protocol/ does not yet describe ("spec it from the jar", "clean-room round", "extend the docs", world generation, gameplay mechanics, rendering details).
---

# Clean-room doc extension

Principle II: implementation MUST work from `docs/protocol/` only, and implementers MUST NOT read the shipped
client jar's bytecode. When the docs are missing, ambiguous or wrong, the docs are updated first. This skill is
how that update is made from an artifact, without the artifact's contents reaching anyone who writes code.

## Roles

There are three roles, and each runs in its own fresh subagent. One agent never plays two roles.

| Role | May read | May write | Must not |
|---|---|---|---|
| **Orchestrator** (this session) | the request, `docs/`, the reader's and reviewer's reports | the briefs, the commit | open the artifact, or quote artifact content in briefs to implementers |
| **Reader** (the dirty room) | the artifact (static reading only), `docs/` | only the target files under `docs/protocol/` or `docs/design/`, plus a scratch notes file outside the repository | read or edit code in the repository (`shim/`, `proto/`, `core/`, `server/`, `client/`, `tests/`, `contract/`), copy code |
| **Reviewer** | the reader's doc diff, `docs/`, and the artifact when it checks a claim | a review report only | edit the docs, which go back to the reader |

Implementers (speckit-implement phases, other agents) only ever see the committed docs. Briefs to implementers
cite doc sections and never repeat artifact findings that are not in the docs.

## Recalled knowledge is not evidence

Observed in the first rounds (operator, 2026-11-06): although the game is closed source, the models that run the
reader and reviewer roles carry Minecraft source code from their training data, and almost certainly the Minecraft
wiki as well. Such recall is useful for knowing where to look, and it is unreliable as a source: it may describe an
older version (26.3's worldgen, spawning, lighting and environment code differ from the 1.18 to 1.21 code in many
places), a mod or a different edition, or a plausible guess. It is also itself a contamination path, since it is
source or wiki text that no one has checked against this artifact. Constitution 1.1 already says agent memory MUST NOT
serve as an input to any phase; this section applies that rule here.

- **Evidence is the artifact.** A value, formula, ordering or behaviour goes into the docs only if it was read from the
  artifact in this round. A value that merely agrees with what the agent remembers is still read before it is written.
- **Recall steers, it never fills.** Remembered names, constants and structures are hypotheses to look up. Where the
  artifact differs from recall, the artifact wins and the difference is worth a note in the doc.
- **Mark what was not read.** A statement taken from recall, a wiki-style "well-known value" or "as in earlier
  versions", or an illustration that was not read, is marked "(recalled, not verified)", and it is listed in the
  document's Open questions. Marked values never stand in for the numbers an implementer needs.
- **No transcribed recall.** Prose that reproduces the structure or wording of remembered source code or wiki pages is
  contamination, like pasted decompiled code. It is rewritten in the doc's own terms from what was read.
- **Reviewers test for it.** The reviewer treats a claim with no visible trace to the artifact as suspect: typical
  signs are round or "textbook" numbers, behaviour that matches an older version, wiki phrasing, and values given
  without a class or data file to cite. Each such claim is verified against the artifact, and the report says which
  ones matched, which differed, and which could not be traced. A matching value does not clear a doc that reads like
  recall.

## Procedure

1. **Scope.** Write down what behaviour is needed and why: the ticket or spec item, the questions the docs must
   answer, and the target file. The target is either an existing document (a new section) or a new numbered one,
   for example `docs/protocol/10-world-generation.md`.
   - Game design that CobolCraft sets itself goes in `docs/design/`.
   - Behaviour read from an artifact goes in `docs/protocol/`.
   - When the operator's decision for the feature supersedes an earlier requirement, cite that decision in the scope.
2. **Artifact.** The operator supplies the artifact path; it is never committed.
   - Run `.claude/skills/clean-room/scripts/artifact-id.sh <path>` to get its SHA-256.
   - If the artifact is the one already recorded in `docs/protocol/README.md`, the new text says so.
   - A different artifact, such as a newer jar, is recorded with its own name, SHA-256 and version in the new
     document's header and in the README's Documents table.
3. **Reader.** Launch a fresh `general-purpose` subagent with `references/reader-brief.md`, with its placeholders
   filled in. Its output is the doc change plus a short report: sections written, anything not found, and open
   questions.
4. **Review.** Launch a second fresh subagent with `references/review-brief.md`.
   - If the review finds problems, resume the **reader** with the review's findings, and run a fresh review again.
   - Allow at most 3 rounds. Anything still unresolved becomes an Open question in the doc, or a stop and a question
     to the operator.
5. **Index.** The reader updates `docs/protocol/README.md`:
   - the Documents table;
   - the scope sentence: today it says "It does not cover gameplay, content, worldgen or rendering", and that changes
     when such a document is added;
   - any new convention.
6. **Commit.** Use a `docs(protocol): …` or `docs(design): …` commit naming the artifact SHA-256 and "clean-room
   reader/reviewer". Push per the run's rules. Only then do spec, plan or implement phases use the new text.
7. **Hand-off.** Downstream specs and tasks cite the new sections by number. If an implementer finds a gap, it goes
   back through this procedure; nobody opens the artifact to fill it.

## Doc rules (what the reader writes)

These match how 00 to 08 were written:
- **Form:** prose, tables and formulas only. No source code, no decompiled code, and no pseudocode that mirrors the
  artifact's control flow line by line. Describe behaviour, data layouts, constants, formulas and algorithms in
  their own terms (inputs, outputs, steps, invariants).
- **Names:** artifact class, method and field names may be cited as references in backticks, as 02 and 07 do, to
  say where something was read. They are never presented as the design.
- **Uncertainty:** every value is either read directly or marked "(inferred)". Untraced behaviour goes in the
  document's numbered `## Open questions` section, never guessed silently.
- **Header:** each document starts with what it covers, its source artifact (name and SHA-256) and the method used,
  for example "Static reading of the shipped bytecode (`javap`), with no execution".
- **Self-contained:** an implementer must be able to build the behaviour from the docs alone. Every constant,
  table and ordering rule an implementation needs is in the text.
- **Testable:** where it helps, the reader adds worked examples (inputs and expected outputs), so implementers can
  write tests from the docs.

## Tools for reading an artifact

- `javap -c -p -constants -classpath <jar> <class>` (needs a JDK on PATH). Extract a class with `unzip -p`.
- The `reverse-engineer-anything` skill (REA) for JVM and native artifacts, when it is available.
- Static reading only. The reader does not run the artifact unless the operator explicitly allows execution for
  this round, and then it records that in the document's method line.
