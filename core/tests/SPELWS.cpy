*> Working storage shared by the tests of the underground features of 35-6 (test_feat_35_6_5 to _7; SPELPROC.cpy has the paragraphs). The world of the cases is chunk (1, 2): stone y 40 to 62, air 63 to 69,
*> stone 70 to 80 (WS-MS is the model's copy of the cells, WS-MX, WS-MY, WS-MZ the model's cursor, WS-MV the state read or to write).
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/spel".
 01 WS-PTR                 USAGE POINTER.
 01 WS-A                   PIC X(304640) BASED.
 01 WS-MODEL.
    05 WS-MS               BINARY-LONG OCCURS 98304 TIMES.
 01 WS-MX                  BINARY-LONG.
 01 WS-MY                  BINARY-LONG.
 01 WS-MZ                  BINARY-LONG.
 01 WS-MV                  BINARY-LONG.
 01 WS-MB                  BINARY-LONG.
 01 WS-MIDX                BINARY-LONG.
 01 WS-NCH                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-FT                  BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-CX                  BINARY-LONG VALUE 1.
 01 WS-CZ                  BINARY-LONG VALUE 2.
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-OK                  BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-KEY                 PIC X(112).
 01 WS-NAME                PIC X(48).
 01 WS-FTKEY               PIC X(80).
 01 WS-PAIRS               PIC X(160).
 01 WS-CASE                PIC X(200).
 01 WS-OBS                 BINARY-LONG.
 01 WS-EXP                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-REG                 PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:dripstone_replaceable_blocks".
 01 WS-STATUS              BINARY-LONG.
 01 WS-IDS.
    05 WS-ID               BINARY-LONG OCCURS 8 TIMES.
 01 WS-SET.
    05 WS-SETB             BINARY-LONG OCCURS 4 TIMES.
 01 WS-B-STONE             BINARY-LONG.
 01 WS-B-BASE              BINARY-LONG.
 01 WS-B-POINTED           BINARY-LONG.
 01 WS-B-WATER             BINARY-LONG.
 01 WS-B-LAVA              BINARY-LONG.
 01 WS-S-BASE              BINARY-LONG.
 01 WS-S-WATER             BINARY-LONG.
 01 WS-S-AIR               BINARY-LONG.
 01 WS-S-STONE             BINARY-LONG.
*> directions by ordinal (DOWN 0, UP 1, NORTH 2, SOUTH 3, WEST 4, EAST 5): the step
 01 WS-STEPS.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
 01 WS-STEP-T REDEFINES WS-STEPS.
    05 WS-STEP OCCURS 6 TIMES.
       10 WS-SX            BINARY-LONG.
       10 WS-SY            BINARY-LONG.
       10 WS-SZ            BINARY-LONG.
 01 WS-GX                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-GZ                  BINARY-LONG.
 01 WS-TIP                 BINARY-LONG.
 01 WS-HT                  BINARY-LONG.
 01 WS-MERGE               BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-KD                  BINARY-LONG.
 01 WS-PIECES.
    05 WS-PC               BINARY-LONG OCCURS 16 TIMES.
 01 WS-NP                  BINARY-LONG.
 01 WS-WLF                 BINARY-LONG.
 01 WS-THICKS.
    05 FILLER PIC X(9) VALUE "tip_merge".
    05 FILLER PIC X(9) VALUE "tip      ".
    05 FILLER PIC X(9) VALUE "frustum  ".
    05 FILLER PIC X(9) VALUE "middle   ".
    05 FILLER PIC X(9) VALUE "base     ".
 01 WS-THICK-T REDEFINES WS-THICKS.
    05 WS-THICK            PIC X(9) OCCURS 5 TIMES.
