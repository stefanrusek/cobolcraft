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


PLAY = os.path.join(REPO, "contract", "cases", "play-core-blocks.tsv")
WIRE_CORE = os.path.join(REPO, "contract", "cases", "wire-core.tsv")


class CoreWorldSeams(unittest.TestCase):
    def test_play_core_rows_and_divergence_marks(self):
        seam = gen_contract.read_table(PLAY)
        self.assertEqual(seam.name, "play-core-blocks")
        marked = [r.id for r in seam.rows if gen_contract.known_divergence(r)]
        self.assertEqual(marked, ["!place-light-before-update", "!change-light-before-update", "!break-light-before-update"])

    def test_divergence_row_is_inverted_and_plain_row_is_not(self):
        program = gen_contract.generate(gen_contract.read_table(PLAY))["core/tests/contract_play_core_blocks_core.cob"]
        self.assertIn("known divergence still present", program)
        self.assertEqual(program.count("known divergence still present"), 3)
        self.assertIn('CALL "TEST-JOIN"', program)
        self.assertIn('CALL "TEST-OPEN-WORLD"', program)

    def test_wire_core_has_no_world_head_for_builders_only(self):
        seam = gen_contract.read_table(WIRE_CORE)
        program = gen_contract.generate(seam)["core/tests/contract_wire_core_core.cob"]
        self.assertIn('CALL "SET-HEALTH-BUILD" USING', program)
        self.assertIn('CALL "CHUNK-PACKET-BUILD" USING', program)
        self.assertIn("MOVE 20.0 TO WS-HEALTH", program)

    def test_missing_input_names_the_row(self):
        seam = gen_contract.read_table(PLAY)
        seam.rows[1] = seam.rows[1]._replace(inputs={})
        with self.assertRaises(gen_contract.Problem) as caught:
            gen_contract.generate(seam)
        self.assertIn("place-ack-last", str(caught.exception))

    def test_group_arguments(self):
        seams = gen_contract.read_tables()
        self.assertEqual(gen_contract.only_args(seams, "play"), ["--only", "contract_play_core_blocks_core"])
        self.assertIn("contract_wire_core_core", gen_contract.only_args(seams, "wire"))


class RecordSizes(unittest.TestCase):
    def test_recipe_entry_is_1061_bytes_and_matches_the_probe(self):
        self.assertEqual(gen_contract.record_size(os.path.join(REPO, "contract", "copy", "PROTO.cpy"), "PB-RECIPE-ENTRY"), 1061)
        self.assertEqual(gen_contract.probe_length(REPO, "PB-RECIPE-ENTRY"), 1061)

    def test_sizes_of_groups_occurs_and_pictures(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = os.path.join(tmp, "T.cpy")
            with open(path, "w") as handle:
                handle.write(" 78 N VALUE 3.\n 01 REC.\n    05 A BINARY-LONG.\n    05 B PIC X(10).\n"
                             "    05 G OCCURS N TIMES.\n       10 C FLOAT-LONG.\n       10 D PIC 9.\n 01 OTHER.\n    05 Z BINARY-LONG.\n")
            self.assertEqual(gen_contract.record_size(path, "REC"), 4 + 10 + 3 * 9)
            with self.assertRaises(gen_contract.Problem):
                gen_contract.record_size(path, "MISSING")

    def test_drift_is_reported(self):
        seam = gen_contract.read_table(os.path.join(REPO, "contract", "cases", "content-recipes.tsv"))
        self.assertEqual(gen_contract.check_sizes(seam, REPO), [])
        seam.rows[0] = seam.rows[0]._replace(expected="125")
        problems = gen_contract.check_sizes(seam, REPO)
        self.assertEqual(len(problems), 2)
        self.assertIn("is 1061 bytes in contract/copy, the row expects 125", problems[0])


class Unwired(unittest.TestCase):
    def make_repo(self, host_calls):
        tmp = tempfile.mkdtemp()
        self.addCleanup(shutil.rmtree, tmp)
        for package in gen_contract.SRC_PACKAGES:
            os.makedirs(os.path.join(tmp, package, "src"))
        os.makedirs(os.path.join(tmp, "core", "tests"))
        os.makedirs(os.path.dirname(os.path.join(tmp, gen_contract.CONTRACT_DOCS[0])))
        os.makedirs(os.path.join(tmp, "specs", "f"))
        with open(os.path.join(tmp, gen_contract.CONTRACT_DOCS[0]), "w") as handle:
            handle.write("| `CORE-A` | x | y |\n| `CORE-B` | x | y |\n")
        with open(os.path.join(tmp, "specs", "f", "tasks.md"), "w") as handle:
            handle.write("- [X] T1 wire CORE-A\n- [ ] T2 CORE-B\n")
        with open(os.path.join(tmp, "core", "src", "a.cob"), "w") as handle:
            handle.write(' PROGRAM-ID. CORE-A.\n PROGRAM-ID. CORE-B.\n PROGRAM-ID. LONELY.\n PROGRAM-ID. USED.\n    CALL "USED"\n')
        with open(os.path.join(tmp, "server", "src", "s.cob"), "w") as handle:
            handle.write('    CALL "CORE-A"\n' if host_calls else "*> CALL \"CORE-A\"\n")
        with open(os.path.join(tmp, "core", "tests", "t.cob"), "w") as handle:
            handle.write('    CALL "LONELY"\n')
        return tmp

    def test_done_entry_without_host_caller_is_an_error_and_open_one_a_warning(self):
        entries, strict, programs = gen_contract.unwired_report(self.make_repo(False))
        self.assertEqual(strict, ["CORE-A"])
        self.assertEqual([e[:2] for e in entries], [("CORE-A", []), ("CORE-B", [])])
        self.assertIn(("core", "LONELY", "core/src/a.cob", "tests only"), programs)
        self.assertNotIn("USED", [p[1] for p in programs])
        self.assertIn("ERROR\tCORE-A", gen_contract.format_unwired((entries, strict, programs)))

    def test_host_caller_clears_the_error(self):
        entries, strict, programs = gen_contract.unwired_report(self.make_repo(True))
        self.assertEqual(strict, [])
        self.assertEqual(entries[0][1], ["server"])

    def test_repository_has_no_strict_entry(self):
        self.assertEqual(gen_contract.contract_report(REPO)[1], [])


if __name__ == "__main__":
    unittest.main()
