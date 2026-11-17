#!/usr/bin/env python3
"""A feature's task list as one file per phase and per lane (test infrastructure, stdlib only).

usage: tasks.py split   FEATURE_DIR          one-time: split FEATURE_DIR/tasks.md into FEATURE_DIR/tasks/
       tasks.py status  FEATURE_DIR [--open] open and done task counts of every file (--open: only files with open tasks)
       tasks.py join    FEATURE_DIR          print the whole task list as one document
       tasks.py absorb  FEATURE_DIR REF      bring in the task changes of a branch that still has the one-file layout

Layout after `split` (FEATURE_DIR is a spec folder such as specs/002-client-polish):

  tasks.md                       the index: header, conventions, and everything that is not a phase or a lane's
                                 list; where a phase was, one line `- [<heading>](tasks/<file>)`
  tasks/phase-<id>.md            a phase of the feature outside the package lanes (`## Phase <number>: ...`)
  tasks/<package>/phase-<id>.md  a phase of a package lane (`#### Phase <number>: ...` under `### Lane: <package>`)
  tasks/lanes/<lane>.md          a lane's own list (`## Lane <name> ...`, `### Lane <name> ...`, or a phase named
                                 after a lane, `## Phase <name>: ...`); the index does not list these: a new lane
                                 adds its file and changes nothing else

A file holds its heading line and everything up to the next phase, lane or heading of the same or a higher
level, unchanged. A heading that occurs twice goes to one file: an exact repeat is dropped, a different one is
kept after the first (`split` names them).

`absorb` is for a branch that left before the split and changed the one-file tasks.md. It splits the branch's
tasks.md and the merge base's the same way and merges each file's changes into this tree's files (a three-way
merge per file, `git merge-file`), so ticks, notes and new lane lists land in the new layout. During a merge
that stopped on tasks.md, run it with MERGE_HEAD: it takes this side's tasks.md first. It prints the files it
changed and exits 1 if a file is left with conflict markers.
"""
import argparse
import os
import re
import subprocess
import sys
import tempfile

INDEX = "tasks.md"
FOLDER = "tasks"
PACKAGE_LANE = re.compile(r"^### Lane: (\S+)")
TOP_PHASE = re.compile(r"^## Phase (\d+[a-z]*)\b")
LANE_PHASE = re.compile(r"^#### Phase (\d+[a-z]*)\b")
LEDGER = re.compile(r"^(##|###) Lane ([^\s:]+)(?=\s|$)|^(##) Phase ([a-z][^\s:]*):")
HEADING = re.compile(r"^(#{1,6}) ")
OPEN = re.compile(r"^\s*- \[ \] ")
DONE = re.compile(r"^\s*- \[[xX]\] ")
POINTER = re.compile(r"^- \[.*\]\(tasks/([^)]+)\)$")
LEDGER_NOTE = [
    "## Lane lists",
    "",
    "Every file in [tasks/lanes/](tasks/lanes/) is one lane's own task list. A new lane adds its own file there",
    "and changes no other file. `python3 tools/tasks.py status <this folder>` counts the open and done tasks of",
    "every file; `python3 tools/tasks.py join <this folder>` prints the whole list as one document.",
]
LAYOUT_NOTE = [
    "**Layout**: this file is the index. Each phase is a file under [tasks/](tasks/), linked where the phase",
    "stood; each lane's own list is a file under [tasks/lanes/](tasks/lanes/) (`tools/tasks.py`). Read the index",
    "and the files of the phases you work on, not the whole list.",
    "",
]


def slug(name):
    """A lane name as a file name: lower case, without the branch prefix `NNN-lane-`."""
    name = re.sub(r"^\d+-lane-", "", name.lower())
    return re.sub(r"[^a-z0-9]+", "-", name).strip("-") or "lane"


def unit_start(line, package):
    """(file path under tasks/, heading level, listed in the index) when `line` starts a unit, else None."""
    match = TOP_PHASE.match(line)
    if match:
        return "phase-%s.md" % match.group(1), 2, True
    match = LANE_PHASE.match(line)
    if match:
        return "%s/phase-%s.md" % (package or "shared", match.group(1)), 4, True
    match = LEDGER.match(line)
    if match:
        level = len(match.group(1) or match.group(3))
        return "lanes/%s.md" % slug(match.group(2) or match.group(4)), level, False
    return None


def split_text(text):
    """({file path under tasks/: text}, index text, [paths that had a different repeat]) of a one-file task list."""
    files, order, repeated = {}, [], []
    index, current, package = [], None, None  # current: (path, level, lines)

    def close():
        nonlocal current
        if current is None:
            return
        path, _, lines = current
        while lines and lines[-1] == "":
            index.append(lines.pop())  # blank lines before the next heading stay with the index
        body = "\n".join(lines) + "\n"
        if path not in files:
            files[path] = body
            order.append(path)
        elif body not in files[path]:
            files[path] += "\n" + body
            repeated.append(path)
        current = None

    for line in text.split("\n"):
        lane = PACKAGE_LANE.match(line)
        start = unit_start(line, package)
        heading = HEADING.match(line)
        if start or (current is not None and heading and len(heading.group(1)) <= current[1]):
            close()
        if lane:
            package = lane.group(1)
        elif heading and len(heading.group(1)) <= 2 and not start:
            package = None
        if start:
            path, level, listed = start
            if listed and path not in files:
                index.append("- [%s](%s/%s)" % (line.lstrip("# "), FOLDER, path))
            current = (path, level, [line])
        elif current is not None:
            current[2].append(line)
        else:
            index.append(line)
    close()
    return files, "\n".join(index), sorted(set(repeated))


def with_notes(index):
    """The index with the layout note before its first `## ` heading and the lane note at its end."""
    lines = index.rstrip("\n").split("\n")
    first = next((n for n, line in enumerate(lines) if line.startswith("## ")), len(lines))
    return "\n".join(lines[:first] + LAYOUT_NOTE + lines[first:] + [""] + LEDGER_NOTE) + "\n"


def counts(text):
    lines = text.split("\n")
    return sum(1 for line in lines if OPEN.match(line)), sum(1 for line in lines if DONE.match(line))


def task_files(feature):
    """Paths under FEATURE/tasks of every task file, sorted."""
    root = os.path.join(feature, FOLDER)
    found = []
    for directory, _, names in os.walk(root):
        found.extend(os.path.relpath(os.path.join(directory, name), root) for name in names if name.endswith(".md"))
    return sorted(found)


def read(path):
    with open(path, encoding="utf-8") as handle:
        return handle.read()


def write(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as handle:
        handle.write(text)


def command_split(feature):
    if os.path.isdir(os.path.join(feature, FOLDER)):
        print("ERROR split: %s exists already" % os.path.join(feature, FOLDER))
        return 1
    text = read(os.path.join(feature, INDEX))
    files, index, repeated = split_text(text)
    before = counts(text)
    after = [counts(body) for body in files.values()] + [counts(index)]
    for path, body in files.items():
        write(os.path.join(feature, FOLDER, path), body)
    write(os.path.join(feature, INDEX), with_notes(index))
    for path in repeated:
        print("REPEATED %s: the heading occurs more than once with different text; all of it is in the file" % path)
    print("split: %d files, %d open and %d done tasks (the one file had %d and %d)"
          % (len(files), sum(a for a, _ in after), sum(b for _, b in after), before[0], before[1]))
    return 0


def command_status(feature, only_open):
    total_open = total_done = 0
    for path in [INDEX] + [os.path.join(FOLDER, p) for p in task_files(feature)]:
        opened, done = counts(read(os.path.join(feature, path)))
        total_open, total_done = total_open + opened, total_done + done
        if opened or (done and not only_open):
            print("%5d open %5d done  %s" % (opened, done, path))
    print("%5d open %5d done  total" % (total_open, total_done))
    return 0


def join_text(feature):
    """The task list as one document: the index with every linked file in its place, then the lane lists."""
    out = []
    for line in read(os.path.join(feature, INDEX)).rstrip("\n").split("\n"):
        match = POINTER.match(line)
        target = os.path.join(feature, FOLDER, match.group(1)) if match else None
        out.append(read(target).rstrip("\n") if target and os.path.isfile(target) else line)
    for path in task_files(feature):
        if path.startswith("lanes/"):
            out.extend(["", read(os.path.join(feature, FOLDER, path)).rstrip("\n")])
    return "\n".join(out) + "\n"


def git(repo, *arguments, check=True):
    done = subprocess.run(["git", "-C", repo, *arguments], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if check and done.returncode != 0:
        raise SystemExit("ERROR git %s: %s" % (" ".join(arguments), done.stderr.strip()))
    return done.stdout if done.returncode == 0 else None


def merge_file(ours, base, theirs):
    """(merged text, True when conflict markers are left) of a three-way merge of three texts."""
    with tempfile.TemporaryDirectory() as scratch:
        paths = []
        for name, text in (("ours", ours), ("base", base), ("theirs", theirs)):
            paths.append(os.path.join(scratch, name))
            write(paths[-1], text)
        done = subprocess.run(["git", "merge-file", "-p", *paths], stdout=subprocess.PIPE, text=True)
        return done.stdout, done.returncode != 0


def command_absorb(feature, reference):
    feature = os.path.abspath(feature)
    repo = git(feature, "rev-parse", "--show-toplevel").strip()
    relative = os.path.relpath(os.path.realpath(feature), os.path.realpath(repo))
    base = git(repo, "merge-base", "HEAD", reference).strip()
    if git(repo, "cat-file", "-e", "%s:%s/%s" % (reference, relative, FOLDER), check=False) is not None:
        print("absorb: %s has the split layout already; merge it as it is" % reference)
        return 0
    theirs = git(repo, "show", "%s:%s/%s" % (reference, relative, INDEX))
    older = git(repo, "show", "%s:%s/%s" % (base, relative, INDEX))
    their_files, their_index, _ = split_text(theirs)
    base_files, base_index, _ = split_text(older)
    # this side's index, also when a merge left tasks.md with conflict markers
    write(os.path.join(feature, INDEX), git(repo, "show", "HEAD:%s/%s" % (relative, INDEX)))
    work = [(INDEX, with_notes(base_index), with_notes(their_index))]
    work += [(os.path.join(FOLDER, path), base_files.get(path, ""), body) for path, body in their_files.items()]
    conflicts = 0
    for path, was, now in work:
        if was == now:
            continue
        target = os.path.join(feature, path)
        ours = read(target) if os.path.isfile(target) else ""
        merged, conflict = merge_file(ours, was, now)
        if merged != ours:
            write(target, merged)
            print(("CONFLICT " if conflict else "changed ") + os.path.join(relative, path))
        conflicts += conflict
    git(repo, "add", "--", os.path.join(relative, INDEX), os.path.join(relative, FOLDER))
    print("absorb: %d files left with conflict markers" % conflicts)
    return 1 if conflicts else 0


def main(argv):
    parser = argparse.ArgumentParser(description="A feature's task list as one file per phase and per lane.")
    commands = parser.add_subparsers(dest="command", required=True)
    for name in ("split", "status", "join", "absorb"):
        sub = commands.add_parser(name)
        sub.add_argument("feature", metavar="FEATURE_DIR")
        if name == "status":
            sub.add_argument("--open", action="store_true", help="only files with open tasks")
        if name == "absorb":
            sub.add_argument("reference", metavar="REF")
    arguments = parser.parse_args(argv)
    if arguments.command == "split":
        return command_split(arguments.feature)
    if arguments.command == "status":
        return command_status(arguments.feature, arguments.open)
    if arguments.command == "join":
        sys.stdout.write(join_text(arguments.feature))
        return 0
    return command_absorb(arguments.feature, arguments.reference)


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
