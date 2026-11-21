#### Phase 56: US1-client — start-up check and banner

- [x] T2948 [US1-client] Write test `client/tests/test_args.cob` cases for `--generated-dir` (22 §5.1) and the default `<game dir>/generated`
- [x] T2949 [US1-client] Add `--generated-dir` to `client/src/args.cob` and `client/copy/CLARGS.cpy`
- [x] T2950 [US1-client] Write acceptance test `client/tests/acc_f2us1_banner.cob` (US1-3): with no valid packs the title screen shows the built-in-language banner `cobolcraft.packs.*` (`docs/protocol/22-extraction-tool.md` §9.2) stating the status and how to build the packs; with valid packs the banner is absent; the cobolcraft type is unaffected [FR-001, FR-002; SC-012]
- [x] T2951 [US1-client] Implement the start-up `CORE-PACKS-STATUS` call, the banner state and the title screen banner in `client/src/main.cob` and `client/src/screens/title.cob`
- [x] T2952 [US1-client] Write acceptance test `client/tests/acc_f2us1_loaders.cob` (US1-4, real input): after a real extraction into `build/generated-test/` the client's content open of the standard set reports no loader error [FR-001, FR-002; SC-012]
- [x] T2953 [US1-client] Gate: run `make gate-client` and record the command and real output
