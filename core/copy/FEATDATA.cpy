*> The compiled feature data of the feature stage (core/src/feat-data.cob compiles the JSON of worldgen/placed_feature and worldgen/feature elements into these
*> tables; core/src/feat-run.cob runs them). EXTERNAL. A placed feature (PF) is a modifier list and a feature; a feature (FT) a type and parameters; a modifier (MD)
*> a kind (the id of worldgen/placement_modifier_type, 35-1 section 3.2) and integer arguments; a predicate (PR) a type (the id of block_predicate_type, 35-2 3.1)
*> with an offset and children; a provider (PV) a block state provider. Anything the compiler does not know marks the placed feature unsupported (PF-STATUS 2): the
*> stage skips it, so no partly understood feature is ever placed.
 78 FD-MAX-PF            VALUE 1024.
 78 FD-MAX-MD            VALUE 8192.
 78 FD-MAX-FT            VALUE 2048.
 78 FD-MAX-CH            VALUE 16384.
 78 FD-MAX-PR            VALUE 4096.
 78 FD-MAX-POOL          VALUE 65536.
 78 FD-MAX-PV            VALUE 2048.
 01 FEAT-DATA EXTERNAL.
    05 FD-DIR               PIC X(1100).
    05 FD-GEN               BINARY-LONG.
    05 FD-PF-COUNT          BINARY-LONG.
    05 FD-MD-COUNT          BINARY-LONG.
    05 FD-FT-COUNT          BINARY-LONG.
    05 FD-CH-COUNT          BINARY-LONG.
    05 FD-PR-COUNT          BINARY-LONG.
    05 FD-POOL-COUNT        BINARY-LONG.
    05 FD-PV-COUNT          BINARY-LONG.
    05 FD-BAD               BINARY-LONG.
*>  placed features: PF-STATUS 0 stub (not compiled), 1 compiled, 2 unsupported; the modifiers PF-MD-FIRST on for PF-MD-COUNT; the feature index PF-FT
    05 FD-PF OCCURS 1024 TIMES.
       10 PF-KEY            PIC X(80).
       10 PF-STATUS         BINARY-LONG.
       10 PF-MD-FIRST       BINARY-LONG.
       10 PF-MD-COUNT       BINARY-LONG.
       10 PF-FT             BINARY-LONG.
*>  modifiers: MD-KIND, MD-A to MD-D, MD-PR (predicate, second predicate MD-PR2), MD-P twelve provider integers, MD-F a float
    05 FD-MD OCCURS 8192 TIMES.
       10 MD-KIND           BINARY-LONG.
       10 MD-A              BINARY-LONG.
       10 MD-B              BINARY-LONG.
       10 MD-C              BINARY-LONG.
       10 MD-D              BINARY-LONG.
       10 MD-PR             BINARY-LONG.
       10 MD-PR2            BINARY-LONG.
       10 MD-P              BINARY-LONG OCCURS 12 TIMES.
       10 MD-F              FLOAT-LONG.
*>  features: FT-TYPE the id of worldgen/feature_type (-1 unsupported); FT-A, FT-B, FT-C parameters (children from CH-ROW FT-A for FT-B rows, FT-C the default placed feature)
    05 FD-FT OCCURS 2048 TIMES.
       10 FT-KEY            PIC X(80).
       10 FT-TYPE           BINARY-LONG.
       10 FT-A              BINARY-LONG.
       10 FT-B              BINARY-LONG.
       10 FT-C              BINARY-LONG.
       10 FT-D              BINARY-LONG.
       10 FT-E              BINARY-LONG.
       10 FT-F              FLOAT-LONG.
    05 FD-CH OCCURS 16384 TIMES.
       10 CH-PF             BINARY-LONG.
       10 CH-W              BINARY-LONG.
       10 CH-F              FLOAT-LONG.
*>  predicates: PR-TYPE (0 unsupported), the offset PR-OX, PR-OY, PR-OZ, PR-A and PR-B parameters, PR-POOL and PR-N a slice of the pool, PR-CHILD the first child and PR-NEXT the next sibling
    05 FD-PR OCCURS 4096 TIMES.
       10 PR-TYPE           BINARY-LONG.
       10 PR-OX             BINARY-LONG.
       10 PR-OY             BINARY-LONG.
       10 PR-OZ             BINARY-LONG.
       10 PR-A              BINARY-LONG.
       10 PR-B              BINARY-LONG.
       10 PR-C              BINARY-LONG.
       10 PR-D              BINARY-LONG.
       10 PR-E              BINARY-LONG.
       10 PR-F              BINARY-LONG.
       10 PR-POOL           BINARY-LONG.
       10 PR-N              BINARY-LONG.
       10 PR-CHILD          BINARY-LONG.
       10 PR-NEXT           BINARY-LONG.
    05 FD-POOL              BINARY-LONG OCCURS 65536 TIMES.
*>  providers: PV-TYPE 1 simple (PV-A the state), 2 weighted (PV-POOL, PV-N pairs state and weight in the pool), 3 random_block (PV-POOL, PV-N block indices); 0 unsupported
    05 FD-PV OCCURS 2048 TIMES.
       10 PV-TYPE           BINARY-LONG.
       10 PV-A              BINARY-LONG.
       10 PV-POOL           BINARY-LONG.
       10 PV-N              BINARY-LONG.
