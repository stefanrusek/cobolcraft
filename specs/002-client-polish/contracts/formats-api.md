# Contract: `formats` library (`formats` -> `content`, `core`, `server`, `client`, `extract`)

**Status**: frozen at plan time (constitution 3.3). Materialized in Foundational as `contract/copy/FORMATS.cpy`
(constants and record shapes). Package `formats` builds `build/formats/libformats.a` over `shim`.

**What it is.** The file-format readers three programs share. Every program below except those marked *new* exists
today in `client/src` under the same `PROGRAM-ID` and is moved unchanged (R1), with its tests, so the move is a
rename of the owning package and no caller changes its `CALL`.

| Program (`CALL STATIC`) | Parameters | Behaviour | Origin |
|---|---|---|---|
| `JSON-PARSE`, `JSON-FIND`, `JSON-ELEMENT`, `JSON-MEMBER`, `JSON-STRING`, `JSON-KEY`, `JSON-DECODE`, `UTF8-ENCODE`, `UTF8-DECODE` and their helpers | as `client/src/json.cob` (document buffer in `JSONDOC.cpy`) | The lenient reader the client uses for models, block states, atlases, `pack.mcmeta`. | moved |
| `JSON-STRICT` | text buffer, length, OUT document (`JSONDOC.cpy` shape), OUT error offset and code | The strict reader of 23 §3.2 (no comments, no trailing commas, duplicate keys rejected, as the registry loader requires). Returns 0 or a reason code. | new |
| `ZIP-OPEN`, `ZIP-CLOSE`, `ZIP-COUNT`, `ZIP-NAME`, `ZIP-FIND`, `ZIP-SIZE`, `ZIP-READ` | as `client/src/zip.cob` (`CLZIP.cpy` renamed `FMZIP.cpy`) | Central-directory reader with name lookup; methods 0 and 8; rejects zip64, several disks and encryption with a reason (22 §8.4). Extended (new) with: a name index (hash) so lookup does not scan (22 §8.4 last paragraph), and `ZIP-CRC-CHECK` comparing an entry's CRC-32 with its central record. | moved + extended |
| `ZIP-READ-RANGE` | zip handle, entry number, OUT buffer, capacity | Inflates one entry into a caller buffer of at least the central size; the extraction tool's per-entry call (22 §7.3 step 7). | new |
| `CRC32` | buffer, length, running value (BINARY-LONG UNSIGNED) -> value | Zip CRC-32; the 9 bytes `123456789` give `cbf43926` (22 §7.2). | new |
| `SHA256-INIT`, `SHA256-UPDATE`, `SHA256-FINAL` | context (opaque pointer in `FMSHA.cpy`), buffer, length / OUT 32 bytes | Direct OpenSSL `EVP_MD_CTX_*` calls from COBOL, no glue (spike `spike_jar_digest`). `abc` gives `ba7816bf...15ad`. | new |
| `PNG-DECODE` | as `client/src/png.cob` | Decodes the PNG kinds of 22 §2.8 (all colour types and bit depths the jar and Faithful use; 22 Open question 7 is closed by a Foundational docs round before this changes). | moved + extended |
| `REGEX-*` | as `client/src/regex.cob` (`CLREGEX.cpy` renamed `FMREGEX.cpy`) | Used by `pack.mcmeta` filters and connected-texture rules. | moved |
| `FILE-READ-AT`, `FILE-WRITE`, `DIR-ENSURE`, `DIR-RENAME`, `DIR-REMOVE-TREE`, `FILE-EXISTS` | path (z-string), offset, buffer, length, OUT status | Thin COBOL wrappers over `CBL_OPEN_FILE`, `CBL_READ_FILE`, `CBL_WRITE_FILE`, `CBL_CREATE_DIR`, `CBL_RENAME_FILE`, `CBL_DELETE_DIR`, `CBL_CHECK_FILE_EXIST` (spike: all return 0) plus `cc_fs_list` for the tree walk of removal; `FILE-READ-ALL` of `client/src/packs/source.cob` is moved here. | new + moved |

**Consumers' obligations.** `extract` uses `ZIP-*`, `CRC32`, `SHA256-*`, `FILE-*`, `DIR-*`; `content` uses
`JSON-STRICT`, `ZIP-*`, `FILE-*`; `client` keeps every current caller; `core` and `server` use `content`
and `FILE-*`. No program of `formats` reads a game rule or a world type.

**Contract tests.** `formats/tests/contract_formats_provider.cob` (the programs above return the documented
values for the vectors of 22 §12 T2, T3, T15 and for fixtures under `contract/fixtures/formats/`) and one
`contract_formats_consumer.cob` in each of `content`, `client`, `extract` calling the programs the way that
package does. Fixtures are small hand-made zip, JSON and PNG files; the real jar and Faithful files are inputs of
`extract`'s tests (plan "Test environment").
