*> The charge cursors of one sculk spreader run (docs/protocol/35-worldgen-features-6-underground.md section 8.3, 8.4; core/src/feat-sculk.cob). EXTERNAL: the programs of the spreader share it.
*> At most 32 cursors (SC-N); a cursor has its position, its charge, the update delay and the decay delay, and the facings of the last multiface block it stood on (SC-HASF 0 null,
*> 1 a set: SC-FACES six characters "0" or "1" by direction ordinal).
 78 SC-MAX               VALUE 32.
 01 FEAT-SCULK EXTERNAL.
    05 SC-N                 BINARY-LONG.
    05 SC-CUR OCCURS 32 TIMES.
       10 SC-X              BINARY-LONG.
       10 SC-Y              BINARY-LONG.
       10 SC-Z              BINARY-LONG.
       10 SC-CHARGE         BINARY-LONG.
       10 SC-UPD            BINARY-LONG.
       10 SC-DECAY          BINARY-LONG.
       10 SC-HASF           BINARY-LONG.
       10 SC-FACES          PIC X(6).
