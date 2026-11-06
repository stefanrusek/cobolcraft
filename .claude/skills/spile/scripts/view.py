#!/usr/bin/env python3
"""Regenerate a Spile project's view doc (spec 0.4.0, "Views"): views/<project>-view.md.

Usage: python3 view.py [project-dir]   (default: tickets)

Stdlib only. Reads the root doc README.md and every ticket (*.md with `spile: ticket`) in the project
directory and its archive/. Advisory: unknown statuses and malformed front matter are rendered, never errors.
"""
import os
import re
import sys

ORDER = ["draft", "refining", "ready", "implementing", "unverified", "verifying"]


def front_matter(path):
    """The flat front matter of a markdown file as a dict of raw strings ({} when there is none)."""
    with open(path, encoding="utf-8") as handle:
        text = handle.read()
    match = re.match(r"---\n(.*?)\n---\n", text, re.S)
    fields = {}
    if not match:
        return fields, text
    for line in match.group(1).splitlines():
        found = re.match(r"([A-Za-z_]+):\s*(.*?)\s*(#.*)?$", line)
        if found and not line.startswith(" "):
            fields[found.group(1)] = found.group(2)
    return fields, text


def title_of(text, ticket_id):
    match = re.search(r"^# " + re.escape(ticket_id) + r":\s*(.+)$", text, re.M)
    return match.group(1).strip() if match else ticket_id


def pr_of(text):
    match = re.search(r"^\s+pr:\s*(\S+)", text, re.M)
    return match.group(1) if match else ""


def load(project):
    tickets = []
    for folder in (project, os.path.join(project, "archive")):
        if not os.path.isdir(folder):
            continue
        for name in sorted(os.listdir(folder)):
            path = os.path.join(folder, name)
            if not name.endswith(".md") or not os.path.isfile(path):
                continue
            fields, text = front_matter(path)
            if fields.get("spile") != "ticket":
                continue
            ticket_id = fields.get("id", name[:-3])
            blocked = fields.get("blocked_by", "[]").strip()
            tickets.append({
                "id": ticket_id,
                "link": os.path.relpath(path, os.path.join(project, "views")),
                "title": title_of(text, ticket_id),
                "type": fields.get("type", ""),
                "status": fields.get("status", ""),
                "owner": fields.get("owner", ""),
                "resolution": fields.get("resolution", ""),
                "blocked": "" if blocked in ("", "[]") else blocked,
                "created": fields.get("created", ""),
                "pr": pr_of(text),
            })
    return tickets


def row(ticket):
    badge = "blocked: " + ticket["blocked"] if ticket["blocked"] else ""
    return "| [{0}]({1}) | {2} | {3} | {4} | {5} | {6} |".format(
        ticket["id"], ticket["link"], ticket["title"], ticket["type"], ticket["owner"], badge, ticket["pr"])


def render(project):
    root, _ = front_matter(os.path.join(project, "README.md"))
    name = root.get("project", os.path.basename(os.path.abspath(project)))
    tickets = load(project)
    open_tickets = [t for t in tickets if t["status"] != "closed"]
    lines = [
        "---",
        "spile: view",
        "project: " + name,
        "---",
        "",
        "# " + name + " view",
        "",
        "> Generated, do not hand-edit. Built from the tickets in `" + os.path.basename(os.path.abspath(project))
        + "/` by `.claude/skills/spile/scripts/view.py`.",
        "",
        "## Needs Attention",
        "",
    ]
    attention = [t for t in open_tickets if t["status"] in ("refining", "unverified") or t["blocked"]]
    if attention:
        lines += ["| ID | Title | Type | Owner | Blocked | PR |", "|---|---|---|---|---|---|"]
        lines += [row(t) for t in attention]
    else:
        lines.append("Nothing needs attention.")
    lines += ["", "## Board", ""]
    statuses = ORDER + sorted({t["status"] for t in open_tickets} - set(ORDER))
    shown = False
    for status in statuses:
        group = [t for t in open_tickets if t["status"] == status]
        if not group:
            continue
        shown = True
        lines += ["### " + (status or "(no status)"), "", "| ID | Title | Type | Owner | Blocked | PR |",
                  "|---|---|---|---|---|---|"]
        lines += [row(t) for t in group]
        lines.append("")
    if not shown:
        lines += ["No open tickets.", ""]
    lines += ["## Recently Closed", ""]
    closed = sorted((t for t in tickets if t["status"] == "closed"), key=lambda t: t["id"], reverse=True)[:15]
    if closed:
        lines += ["| ID | Title | Resolution |", "|---|---|---|"]
        lines += ["| [{0}]({1}) | {2} | {3} |".format(t["id"], t["link"], t["title"], t["resolution"]) for t in closed]
    else:
        lines.append("Nothing closed yet.")
    lines.append("")
    slug = re.sub(r"[^a-z0-9]+", "-", name.lower()).strip("-")
    os.makedirs(os.path.join(project, "views"), exist_ok=True)
    out = os.path.join(project, "views", slug + "-view.md")
    with open(out, "w", encoding="utf-8") as handle:
        handle.write("\n".join(lines))
    return out


if __name__ == "__main__":
    print(render(sys.argv[1] if len(sys.argv) > 1 else "tickets"))
