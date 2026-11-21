"""Implementation tests of the real-input convention: tools/testlib/testinput.cob (TEST-INPUT-PATH;
contracts/test-harness-delta.md "Test inputs")."""
import os
import shutil
import subprocess
import tempfile
import unittest

TOOLS = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
REPO = os.path.join(TOOLS, "..")
DRIVER = """\
 IDENTIFICATION DIVISION.
 PROGRAM-ID. DRIVER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CASE PIC X(240) VALUE "real input case".
 01 WS-NAME PIC X(256) VALUE "present.bin".
 01 WS-PATH PIC X(1024).
 PROCEDURE DIVISION.
     CALL "TEST-INPUT-PATH" USING WS-CASE WS-NAME WS-PATH
     DISPLAY "PATH " FUNCTION TRIM(WS-PATH TRAILING)
     STOP RUN.
"""


class TestInputPath(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.scratch = tempfile.mkdtemp(prefix="cobolcraft-inputs-")
        source = os.path.join(cls.scratch, "driver.cob")
        with open(source, "w") as handle:
            handle.write(DRIVER)
        cls.program = os.path.join(cls.scratch, "driver")
        subprocess.run(
            ["cobc", "-x", "-free", "-debug", "-std=default", "-fstatic-call", "-o", cls.program, source,
             os.path.join(TOOLS, "testlib", "testinput.cob")],
            check=True,
        )

    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(cls.scratch)

    def run_driver(self, cwd, inputs):
        env = {k: v for k, v in os.environ.items() if k != "COBOLCRAFT_INPUTS"}
        if inputs is not None:
            env["COBOLCRAFT_INPUTS"] = inputs
        return subprocess.run([self.program], cwd=cwd, env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

    def make_repo(self, directory, name="present.bin"):
        os.makedirs(os.path.join(directory, "tmp"))
        with open(os.path.join(directory, "tmp", name), "w") as handle:
            handle.write("x")

    def test_default_is_tmp_under_the_working_directory(self):
        with tempfile.TemporaryDirectory() as repo:
            self.make_repo(repo)
            result = self.run_driver(repo, None)
        self.assertEqual((result.returncode, result.stdout), (0, "PATH tmp/present.bin\n"))

    def test_environment_variable_selects_the_folder(self):
        with tempfile.TemporaryDirectory() as repo, tempfile.TemporaryDirectory() as inputs:
            with open(os.path.join(inputs, "present.bin"), "w") as handle:
                handle.write("x")
            result = self.run_driver(repo, inputs)
        self.assertEqual((result.returncode, result.stdout), (0, "PATH %s/present.bin\n" % inputs))

    def test_empty_variable_means_the_default(self):
        with tempfile.TemporaryDirectory() as repo:
            self.make_repo(repo)
            result = self.run_driver(repo, "")
        self.assertEqual((result.returncode, result.stdout), (0, "PATH tmp/present.bin\n"))

    def test_missing_file_fails_loudly_with_the_path(self):
        with tempfile.TemporaryDirectory() as repo:
            result = self.run_driver(repo, None)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout, "TEST real input case FAIL expected=file observed=missing tmp/present.bin\n")

    def test_missing_file_in_the_variable_folder_names_that_path(self):
        with tempfile.TemporaryDirectory() as repo, tempfile.TemporaryDirectory() as inputs:
            self.make_repo(repo)
            result = self.run_driver(repo, inputs)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(
            result.stdout,
            "TEST real input case FAIL expected=file observed=missing %s/present.bin\n" % inputs,
        )


if __name__ == "__main__":
    unittest.main()
