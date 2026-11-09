*> State shared by the programs of the extraction tool (package extract; docs/protocol/22-extraction-tool.md).
*> Every record is EXTERNAL: the programs of one run share it, and a test reads what a program left there.
*> Package-private; nothing outside extract copies this book.

*> Path areas are PIC X(1100) (FM-PATH-MAX of FORMATS.cpy), space padded or NUL terminated.
*> The options of the command line (22 §7.1), set by EX-ARGS. The game directory defaults to "." (the
*> working directory) and the generated directory to <game directory>/generated.
 01 EX-OPT EXTERNAL.
    05 EXO-JAR              PIC X(1100).
    05 EXO-GAME             PIC X(1100).
    05 EXO-GEN              PIC X(1100).
    05 EXO-JAR-GIVEN        BINARY-LONG.
    05 EXO-FORCE            BINARY-LONG.
    05 EXO-VERIFY           BINARY-LONG.
    05 EXO-DRY              BINARY-LONG.
    05 EXO-QUIET            BINARY-LONG.

*> Message arguments (EX-SAY reads them; the caller fills the ones its code names, 22 §7.4 placeholders in order).
 01 EX-MSG EXTERNAL.
    05 EXM-ARG              PIC X(1100) OCCURS 5 TIMES.

*> The result of a run: the last message (code, exit status of its row of 22 §7.4, the text) and the counts of
*> the plan and the walk (22 §6.1): payload files per pack, skipped jar entries, bytes written.
 01 EX-RES EXTERNAL.
    05 EXR-CODE             BINARY-LONG.
    05 EXR-EXIT             BINARY-LONG.
    05 EXR-LINE             PIC X(2000).
    05 EXR-RESOURCE         BINARY-LONG.
    05 EXR-DATA             BINARY-LONG.
    05 EXR-FEATURE          BINARY-LONG.
    05 EXR-SKIPPED          BINARY-LONG.
    05 EXR-TOTAL            BINARY-LONG.
    05 EXR-WRITTEN          BINARY-LONG.
    05 EXR-BYTES            BINARY-DOUBLE.

*> The jar after EX-CHECK: its path (for the messages of CCX-020 and 021), the open zip handle (ZIP-OPEN; closed by the caller), its size, SHA-256 in lower-case
*> hex, the facts of version.json (22 §2.3) and the accepted-jar row that identified it (92 bytes, 22 §4.1).
 01 EX-CHK EXTERNAL.
    05 EXC-PATH             PIC X(1100).
    05 EXC-ZIP              USAGE POINTER.
    05 EXC-SIZE             BINARY-DOUBLE.
    05 EXC-SHA              PIC X(64).
    05 EXC-ID               PIC X(32).
    05 EXC-ROW              PIC X(92).
    05 EXC-WORLD            BINARY-LONG.
    05 EXC-PROTOCOL         BINARY-LONG.
    05 EXC-RES-MAJOR        BINARY-LONG.
    05 EXC-RES-MINOR        BINARY-LONG.
    05 EXC-DATA-MAJOR       BINARY-LONG.
    05 EXC-DATA-MINOR       BINARY-LONG.

*> The plan of EX-PLAN: the payload entries of the jar in central directory order. EXP-KIND: 1 resource pack,
*> 2 data pack, 3 feature pack, 4 pack.png (written to both packs).
 01 EX-PLAN EXTERNAL.
    05 EXP-COUNT            BINARY-LONG.
    05 EXP-ENTRY            OCCURS 65535 TIMES.
       10 EXP-INDEX         BINARY-LONG.
       10 EXP-KIND          BINARY-LONG.

*> The index being built (22 §6.5): one line per payload file, in a buffer of EXI-CAPACITY bytes.
 78 EXI-CAPACITY           VALUE 16777216.
 01 EX-IDX EXTERNAL.
    05 EXI-ADDR             USAGE POINTER.
    05 EXI-LENGTH           BINARY-LONG.
    05 EXI-LINES            BINARY-LONG.
