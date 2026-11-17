#### Phase 54: US21-server — start-up log lines for the manual run

- [x] T2936 [US21-server] Write test `server/tests/test_startup_lines.cob`: the server prints the world type, the generated directory, the registry counts and "Done" lines that the manual run of `quickstart.md` §9 records (done 002-lane-sdd; wording is a design record in contracts/core-host-delta.md section 5; the ready line is the "Done" line)
- [x] T2937 [US21-server] Implement the lines in `server/src/console.cob` (done 002-lane-sdd in `server/src/world-open.cob`, not console.cob)
- [ ] T2938 [US21-server] Gate: run `make gate-server` and record the command and real output
