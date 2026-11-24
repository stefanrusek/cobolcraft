#### Phase 6: US11-shim — IEEE double arithmetic by reference

**Goal**: bit-exact terrain arithmetic at affordable speed (R5, Risk R-P). **Independent Test**: `test_cc_f64.c` against independently computed IEEE vectors.

- [x] T0103 [US11-shim] Create `shim/tests/gen_f64_vectors.py` (stdlib `struct`) writing `shim/tests/f64_vectors.txt` with operand/result pairs for every `cc_f64_*` function, computed independently of the C code
- [x] T0104 [US11-shim] Write test `shim/tests/test_cc_f64_arith.c` for add, sub, mul, div, floor, sqrt over the vectors (`0.1 + 0.2` gives `343333333333D33F`)
- [x] T0105 [US11-shim] Write test `shim/tests/test_cc_f64_text.c` for `cc_f64_from_text` (nearest double of a decimal text, `strtod`)
- [x] T0106 [US11-shim] Write test `shim/tests/test_cc_f64_libm.c` for each libm wrapper Round LIBM named
- [x] T0107 [US11-shim] Implement add, sub, mul, div, floor, sqrt (`fma`-based add and mul) in `shim/src/cc_f64.c`
- [x] T0108 [US11-shim] Implement `cc_f64_from_text` in `shim/src/cc_f64.c`
- [x] T0109 [US11-shim] Implement the libm wrappers in `shim/src/cc_f64.c` and register the file in `shim/Makefile`
- [x] T0110 [US11-shim] Extend `shim/tests/contract_shim_provider.c` with the `cc_f64_*` entry points
- [x] T0111 [US11-shim] Gate: run `make gate-shim` and record the command and real output
