*> The scratch and the hooks of STRUCT-PLACE (core/src/struct-place.cob; docs/protocol/36-structures-2 sections 5 and 7.4). EXTERNAL, core-private.
*> PW-REC holds the processed block records of one placement in absolute positions (5.2): the state is the template state until the write (5.3 mirrors and rotates it);
*> PW-LX..PW-LZ and PW-TSTATE are the template-local position and the template state of the record (the `originals` of finalizeProcessing). PW-PLACED lists the records
*> that were written, in order, PW-PEND the records that wait for the waterlogging pass (0 once done). PW-G-PLACED and PW-G-DONE are one flag per cell of the chunk window
*> (cell index (y - min y) * 256 + z * 16 + x + 1, the layout of CELLS.cpy): the cells written (the set bits of the shape grid, 5.5) and the cells whose fluid is a source
*> that the template wrote (`fluidDone`, 5.3 step 8).
*> STRUCT-SHAPE-TRACE records the calls of the updateShape hook while SHT-ON is 1 and, then, turns the state SHT-FROM into SHT-TO (a test aid that makes the writes of
*> 5.5 observable while the hook has no rules); STRUCT-BE-HOOK-STATE counts the calls of the block entity hook.
 78 PW-MAX               VALUE 65536.
 01 STRUCT-PLACE-WORK EXTERNAL.
    05 PW-COUNT             BINARY-LONG.
    05 PW-PLACED-COUNT      BINARY-LONG.
    05 PW-PEND-COUNT        BINARY-LONG.
    05 PW-MIN-X             BINARY-LONG.
    05 PW-MIN-Y             BINARY-LONG.
    05 PW-MIN-Z             BINARY-LONG.
    05 PW-MAX-X             BINARY-LONG.
    05 PW-MAX-Y             BINARY-LONG.
    05 PW-MAX-Z             BINARY-LONG.
    05 PW-REC OCCURS 65536 TIMES.
       10 PW-X              BINARY-LONG.
       10 PW-Y              BINARY-LONG.
       10 PW-Z              BINARY-LONG.
       10 PW-STATE          BINARY-LONG.
       10 PW-TSTATE         BINARY-LONG.
       10 PW-LX             BINARY-SHORT.
       10 PW-LY             BINARY-SHORT.
       10 PW-LZ             BINARY-SHORT.
       10 PW-NBT            BINARY-LONG.
       10 PW-LOOT           BINARY-LONG.
       10 PW-SEED           BINARY-DOUBLE.
    05 PW-PLACED            BINARY-LONG OCCURS 65536 TIMES.
    05 PW-PEND              BINARY-LONG OCCURS 65536 TIMES.
    05 PW-G-PLACED          BINARY-CHAR UNSIGNED OCCURS 98304 TIMES.
    05 PW-G-DONE            BINARY-CHAR UNSIGNED OCCURS 98304 TIMES.
 78 SHT-MAX               VALUE 2048.
 01 STRUCT-SHAPE-TRACE EXTERNAL.
    05 SHT-ON               BINARY-LONG.
    05 SHT-COUNT            BINARY-LONG.
    05 SHT-FROM             BINARY-LONG.
    05 SHT-TO               BINARY-LONG.
    05 SHT-ENTRY OCCURS 2048 TIMES.
       10 SHT-X             BINARY-LONG.
       10 SHT-Y             BINARY-LONG.
       10 SHT-Z             BINARY-LONG.
       10 SHT-DIR           BINARY-LONG.
       10 SHT-NSTATE        BINARY-LONG.
 01 STRUCT-BE-HOOK-STATE EXTERNAL.
    05 SBH-CALLS            BINARY-LONG.
    05 SBH-X                BINARY-LONG.
    05 SBH-Y                BINARY-LONG.
    05 SBH-Z                BINARY-LONG.
    05 SBH-STATE            BINARY-LONG.
*> Filter result (STRUCT-FILTER-BLOCKS, 3.5): up to 4096 records.
 01 STRUCT-FILTER EXTERNAL.
    05 SF-COUNT             BINARY-LONG.
    05 SF-REC OCCURS 4096 TIMES.
       10 SF-X              BINARY-LONG.
       10 SF-Y              BINARY-LONG.
       10 SF-Z              BINARY-LONG.
       10 SF-STATE          BINARY-LONG.
       10 SF-NBT            BINARY-LONG.
