#### Phase 8: US1-formats — strict JSON, ZIP index and CRC, hashes, files

**Goal**: the readers the extraction tool and the loaders need (22 §7, 23 §3.2). **Independent Test**: `formats/tests/contract_formats_provider.cob` returns the documented values for the vectors of 22 §12 T2, T3, T15.

- [x] T0115 [US1-formats] Write contract test cases in `formats/tests/contract_formats_provider.cob` for `CRC32` (`123456789` gives `cbf43926`, 22 §7.2), `SHA256-*` (`abc` gives `ba7816bf...15ad`) and the 22 §12 T2, T3, T15 vectors
- [x] T0116 [P] [US1-formats] Write test `formats/tests/test_crc32.cob` (running value across buffers, empty buffer)
- [x] T0117 [US1-formats] Implement `CRC32` in `formats/src/crc32.cob`
- [x] T0118 [P] [US1-formats] Write test `formats/tests/test_sha256.cob` (init/update/final in pieces, 32-byte output, `abc`, the empty string)
- [x] T0119 [US1-formats] Implement `SHA256-INIT`, `SHA256-UPDATE`, `SHA256-FINAL` in `formats/src/sha256.cob` with direct OpenSSL `EVP_MD_CTX_*` calls (`FMSHA` context; link `-lcrypto` in `formats/Makefile`)
- [x] T0120 [P] [US1-formats] Write test `formats/tests/test_json_strict.cob`: accept valid documents, reject comments, trailing commas and duplicate keys, return the error offset and reason code (23 §3.2)
- [x] T0121 [US1-formats] Implement `JSON-STRICT` in `formats/src/json-strict.cob`
- [x] T0122 [P] [US1-formats] Write test `formats/tests/test_zip_index.cob`: name lookup through a hash index over a 10,000-entry central directory without scanning (22 §8.4 last paragraph)
- [x] T0123 [US1-formats] Add the name hash index to `ZIP-FIND` in `formats/src/zip.cob`
- [x] T0124 [P] [US1-formats] Write test `formats/tests/test_zip_crc_range.cob`: `ZIP-CRC-CHECK` accepts a good entry and rejects the bad-CRC fixture; `ZIP-READ-RANGE` inflates one entry into a caller buffer; zip64, several disks and encryption are rejected with a reason (22 §8.4)
- [x] T0125 [US1-formats] Implement `ZIP-CRC-CHECK` and `ZIP-READ-RANGE` and the rejections in `formats/src/zip.cob`
- [x] T0126 [P] [US1-formats] Write test `formats/tests/test_files_io.cob` for `FILE-READ-AT`, `FILE-WRITE`, `FILE-EXISTS` with status words (a missing file, an unwritable folder)
- [x] T0127 [US1-formats] Implement `FILE-READ-AT`, `FILE-WRITE`, `FILE-EXISTS` in `formats/src/files.cob` over `CBL_OPEN_FILE`, `CBL_READ_FILE`, `CBL_WRITE_FILE`, `CBL_CHECK_FILE_EXIST`
- [x] T0128 [P] [US1-formats] Write test `formats/tests/test_dirs.cob` for `DIR-ENSURE` (nested), `DIR-RENAME` (atomic swap of a directory), `DIR-REMOVE-TREE` (tree walk through `cc_fs_list`)
- [x] T0129 [US1-formats] Implement `DIR-ENSURE`, `DIR-RENAME`, `DIR-REMOVE-TREE` in `formats/src/dirs.cob`
- [x] T0130 [P] [US1-formats] Write test `formats/tests/test_png_kinds.cob`: `PNG-DECODE` decodes every kind Round PNG lists, using the `contract/fixtures/formats/` PNGs
- [x] T0131 [US1-formats] Extend `PNG-DECODE` in `formats/src/png.cob` for the kinds Round PNG lists
- [x] T0132 [US1-formats] Write implementation tests in `formats/tests/test_formats_cover.cob` for any line of `formats/src` the tests above leave unexecuted (`make coverage` lists them)
- [x] T0133 [US1-formats] Gate: run `make gate-formats` and record the command and real output
