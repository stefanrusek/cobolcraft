"""Shared helpers of the generator acceptance tests: run gen_tables.py and read a generated copybook back."""
import os
import re
import subprocess
import sys
import tempfile

TOOLS = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
GENERATOR = os.path.join(TOOLS, "gen", "gen_tables.py")
REPO = os.path.abspath(os.path.join(TOOLS, ".."))
DOCS = os.path.join(REPO, "docs", "protocol")
CHUNK = 400


def run(*arguments):
    return subprocess.run([sys.executable, GENERATOR, *arguments], stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                          text=True)


def generate(docs=None):
    """Generate into a fresh temporary directory; return (directory object, CompletedProcess)."""
    directory = tempfile.TemporaryDirectory()
    extra = ["--docs", docs] if docs else []
    return directory, run("--write", "--out", directory.name, *extra)


class Table:
    """A generated table: rows as dicts keyed by the column names of the copybook (upper case)."""

    def __init__(self, path, prefix):
        with open(path, encoding="ascii") as handle:
            self.text = handle.read()
        self.prefix = prefix
        self.count = int(re.search(r"GEN-%s-ROWS PIC 9\(6\) VALUE (\d+)\." % prefix, self.text).group(1))
        self.width = int(re.search(r"GEN-%s-ROW-WIDTH PIC 9\(4\) VALUE (\d+)\." % prefix, self.text).group(1))
        self.columns = []
        for name, offset in re.findall(r"78 GEN-%s-OFF-([A-Z0-9]+) VALUE (\d+)\." % prefix, self.text):
            width = int(re.search(r"78 GEN-%s-W-%s VALUE (\d+)\." % (prefix, name), self.text).group(1))
            self.columns.append((name, int(offset), width))
        self.literals = re.findall(r'05 FILLER PIC X\((\d+)\) VALUE "(.*)"\.$', self.text, re.M)
        self.data = "".join(v for _, v in self.literals)

    def row(self, number):
        start = (number - 1) * self.width
        raw = self.data[start:start + self.width]
        return {name: raw[off:off + w].strip() for name, off, w in self.columns}

    def rows(self):
        return [self.row(n) for n in range(1, self.count + 1)]
