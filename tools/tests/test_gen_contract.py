"""Implementation tests of tools/gen/gen_contract.py: table parsing, generated programs, the wiring check and the
seam selection of `contract-affected`."""
import os
import shutil
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "gen"))
import gen_contract

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
TABLE = os.path.join(REPO, "contract", "cases", "wire-chat.tsv")


class Table(unittest.TestCase):
    def test_wire_chat_rows(self):
        seam = gen_contract.read_table(TABLE)
        self.assertEqual(seam.name, "wire-chat")
        self.assertEqual([r.id for r in seam.rows],
                         ["chat-send-decode", "chat-line-build", "chat-send", "chat-command-send", "chat-history"])
        self.assertEqual(seam.rows[0].expected, "9 0 message hello length 5")
        self.assertEqual(seam.rows[1].inputs, {"name": "Alice", "message": "hello"})
        self.assertEqual(seam.rows[4].fixtures[1], "play-s2c-7c-system-chat-command-feedback")

    def test_bad_row_names_its_line(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = os.path.join(tmp, "x.tsv")
            with open(path, "w") as handle:
                handle.write("# seam: x\nid\top\tentry\n")
            with self.assertRaises(gen_contract.Problem) as caught:
                gen_contract.read_table(path)
            self.assertIn("line 2", str(caught.exception))


class Generation(unittest.TestCase):
    def test_one_program_per_owner(self):
        seam = gen_contract.read_table(TABLE)
        programs = gen_contract.generate(seam)
        self.assertEqual(sorted(programs), ["client/tests/contract_wire_chat_client.cob", "core/tests/contract_wire_chat_core.cob"])
        client = programs["client/tests/contract_wire_chat_client.cob"]
        self.assertIn('CALL "CLP-CHAT" USING', client)
        self.assertIn("contract/fixtures/wire/play-c2s-09-chat.hex", client)
        self.assertIn('CALL "PLAY-DECODE" USING', programs["core/tests/contract_wire_chat_core.cob"])

    def test_unknown_op_rejected(self):
        seam = gen_contract.read_table(TABLE)
        seam.rows[0] = seam.rows[0]._replace(op="nope")
        with self.assertRaises(gen_contract.Problem):
            gen_contract.generate(seam)


class Wiring(unittest.TestCase):
    def make_repo(self, call):
        tmp = tempfile.mkdtemp()
        self.addCleanup(shutil.rmtree, tmp)
        for package in ("core", "client"):
            os.makedirs(os.path.join(tmp, package, "src"))
        with open(os.path.join(tmp, "core", "src", "a.cob"), "w") as handle:
            handle.write('     CALL "PLAY-DECODE" USING A\n     CALL "CHAT-LINE-BUILD" USING B\n')
        with open(os.path.join(tmp, "client", "src", "b.cob"), "w") as handle:
            handle.write('     CALL "CLP-CHAT" USING A\n     CALL "CLP-CHAT-COMMAND" USING A\n     CALL "PROTO-PACKET" USING A\n' if call else "")
        return tmp

    def test_all_called(self):
        seam = gen_contract.read_table(TABLE)
        self.assertEqual(gen_contract.check_wiring(seam, self.make_repo(True)), [])

    def test_missing_call_names_entry(self):
        seam = gen_contract.read_table(TABLE)
        problems = gen_contract.check_wiring(seam, self.make_repo(False))
        self.assertEqual(len(problems), 3)
        self.assertIn("CLP-CHAT has no CALL", problems[0])

    def test_prefix_name_is_not_a_call(self):
        # CALL "CLP-CHAT-COMMAND" must not satisfy CLP-CHAT
        seam = gen_contract.read_table(TABLE)
        tmp = self.make_repo(False)
        with open(os.path.join(tmp, "client", "src", "b.cob"), "w") as handle:
            handle.write('     CALL "CLP-CHAT-COMMAND" USING A\n     CALL "PROTO-PACKET" USING A\n')
        problems = gen_contract.check_wiring(seam, tmp)
        self.assertEqual(len(problems), 1)
        self.assertIn("CLP-CHAT has no CALL", problems[0])

    def test_repository_is_wired(self):
        self.assertEqual(gen_contract.check_wiring(gen_contract.read_table(TABLE), REPO), [])


class Affected(unittest.TestCase):
    def test_changed_path_selects_seam(self):
        seams = [gen_contract.read_table(TABLE)]
        self.assertEqual(gen_contract.affected(seams, ["client/src/screens/chat.cob"]), ["wire-chat"])
        self.assertEqual(gen_contract.affected(seams, ["proto/src/buffer.cob"]), ["wire-chat"])
        self.assertEqual(gen_contract.affected(seams, ["README.md"]), [])


if __name__ == "__main__":
    unittest.main()
