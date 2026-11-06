"""Implementation tests of tools/bootstrap.sh in a scratch repository layout."""
import os
import shutil
import subprocess
import tempfile
import unittest

TOOLS = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
PACKAGES = ["shim", "proto", "core", "server", "client"]


class Bootstrap(unittest.TestCase):
    def setUp(self):
        self.repo = tempfile.mkdtemp(prefix="cobolcraft-bootstrap-")
        self.addCleanup(shutil.rmtree, self.repo)
        os.makedirs(os.path.join(self.repo, "tools"))
        shutil.copy(os.path.join(TOOLS, "bootstrap.sh"), os.path.join(self.repo, "tools", "bootstrap.sh"))
        shaders = os.path.join(self.repo, "shim", "shaders")
        os.makedirs(shaders)
        shutil.copy(os.path.join(TOOLS, "tests", "fixtures", "lint", "good.vert"), os.path.join(shaders, "probe.vert"))

    def run_bootstrap(self, path):
        env = dict(os.environ, PATH=path)
        return subprocess.run(
            ["/bin/sh", os.path.join(self.repo, "tools", "bootstrap.sh")],
            env=env,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
        )

    def path_without(self, command):
        """A PATH holding every command of the current PATH except `command`.

        Each command is an exec wrapper, not a symlink: `brew` derives its prefix from the path it
        was invoked by."""
        directory = tempfile.mkdtemp(prefix="cobolcraft-path-")
        self.addCleanup(shutil.rmtree, directory)
        for entry in os.environ["PATH"].split(os.pathsep):
            if not os.path.isdir(entry):
                continue
            for name in os.listdir(entry):
                real = os.path.join(entry, name)
                target = os.path.join(directory, name)
                if name == command or os.path.lexists(target) or not os.access(real, os.X_OK) or os.path.isdir(real):
                    continue
                with open(target, "w") as handle:
                    handle.write('#!/bin/sh\nexec "%s" "$@"\n' % real)
                os.chmod(target, 0o755)
        return directory

    def test_only_the_missing_command_is_named(self):
        result = self.run_bootstrap(self.path_without("spirv-val"))
        self.assertEqual(
            result.stdout.splitlines()[:2], ["Missing prerequisites:", "  spirv-val (glslang)"], result.stdout
        )

    def assert_names_missing(self, command):
        result = self.run_bootstrap(self.path_without(command))
        self.assertEqual(result.returncode, 1, result.stdout)
        self.assertIn(command, result.stdout)
        self.assertIn("brew install ", result.stdout)
        self.assertFalse(os.path.exists(os.path.join(self.repo, "build")), result.stdout)

    def test_missing_shader_compiler_is_named(self):
        self.assert_names_missing("glslangValidator")

    def test_missing_cobol_compiler_is_named(self):
        self.assert_names_missing("cobc")

    def test_all_present_creates_the_build_tree(self):
        result = self.run_bootstrap(os.environ["PATH"])
        self.assertEqual(result.returncode, 0, result.stdout)
        build = os.path.join(self.repo, "build")
        for directory in ["bin", "shaders"] + [os.path.join(p, d) for p in PACKAGES for d in ("obj", "tests")]:
            self.assertTrue(os.path.isdir(os.path.join(build, directory)), directory)
        self.assertTrue(os.path.isfile(os.path.join(build, "shaders", "probe.vert.spv")))


if __name__ == "__main__":
    unittest.main()
