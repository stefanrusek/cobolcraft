*> How clients learn about block changes (docs/protocol/29 section 7): the changed positions of the tick, per chunk and section
*> (BC-ENTRY, a set: BC-POS is the 12-bit section-relative position x << 8 | z << 4 | y), and the acknowledgement each connection
*> owes (BC-ACK holds the highest sequence received plus 1; 0 = none).
 78 BC-MAX-ENTRIES               VALUE 16384.
 01 BLOCK-CHANGES EXTERNAL.
    05 BC-COUNT                  BINARY-LONG.
    05 BC-ENTRY OCCURS 16384 TIMES.
       10 BC-DIM                 BINARY-LONG.
       10 BC-CX                  BINARY-LONG.
       10 BC-CZ                  BINARY-LONG.
       10 BC-SEC                 BINARY-LONG.
       10 BC-POS                 BINARY-LONG.
    05 BC-ACK                    BINARY-LONG OCCURS 64 TIMES.
