 IDENTIFICATION DIVISION.
 PROGRAM-ID. SEED-DIGIT.
*> USING unit (BINARY-LONG, a UTF-16 code unit), value out (BINARY-LONG): the decimal value 0 to 9 of a unit that
*> Character.digit(c, 10) accepts (the 37 runs of ten of docs/protocol/11 section 12.1 step 3), else -1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STARTS.
    05 FILLER BINARY-LONG VALUE 48.
    05 FILLER BINARY-LONG VALUE 1632.
    05 FILLER BINARY-LONG VALUE 1776.
    05 FILLER BINARY-LONG VALUE 1984.
    05 FILLER BINARY-LONG VALUE 2406.
    05 FILLER BINARY-LONG VALUE 2534.
    05 FILLER BINARY-LONG VALUE 2662.
    05 FILLER BINARY-LONG VALUE 2790.
    05 FILLER BINARY-LONG VALUE 2918.
    05 FILLER BINARY-LONG VALUE 3046.
    05 FILLER BINARY-LONG VALUE 3174.
    05 FILLER BINARY-LONG VALUE 3302.
    05 FILLER BINARY-LONG VALUE 3430.
    05 FILLER BINARY-LONG VALUE 3558.
    05 FILLER BINARY-LONG VALUE 3664.
    05 FILLER BINARY-LONG VALUE 3792.
    05 FILLER BINARY-LONG VALUE 3872.
    05 FILLER BINARY-LONG VALUE 4160.
    05 FILLER BINARY-LONG VALUE 4240.
    05 FILLER BINARY-LONG VALUE 6112.
    05 FILLER BINARY-LONG VALUE 6160.
    05 FILLER BINARY-LONG VALUE 6470.
    05 FILLER BINARY-LONG VALUE 6608.
    05 FILLER BINARY-LONG VALUE 6784.
    05 FILLER BINARY-LONG VALUE 6800.
    05 FILLER BINARY-LONG VALUE 6992.
    05 FILLER BINARY-LONG VALUE 7088.
    05 FILLER BINARY-LONG VALUE 7232.
    05 FILLER BINARY-LONG VALUE 7248.
    05 FILLER BINARY-LONG VALUE 42528.
    05 FILLER BINARY-LONG VALUE 43216.
    05 FILLER BINARY-LONG VALUE 43264.
    05 FILLER BINARY-LONG VALUE 43472.
    05 FILLER BINARY-LONG VALUE 43504.
    05 FILLER BINARY-LONG VALUE 43600.
    05 FILLER BINARY-LONG VALUE 44016.
    05 FILLER BINARY-LONG VALUE 65296.
 01 WS-START-TABLE REDEFINES WS-STARTS.
    05 WS-START            BINARY-LONG OCCURS 37 TIMES.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-UNIT                 BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-UNIT L-VALUE.
     MOVE -1 TO L-VALUE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 37
         IF L-UNIT >= WS-START(WS-I) AND L-UNIT <= WS-START(WS-I) + 9
             COMPUTE L-VALUE = L-UNIT - WS-START(WS-I)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SEED-DIGIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SEED-FROM-TEXT.
*> USING text (PIC X(64), UTF-8 bytes, space padded: CS-SEED-TEXT), seed out (BINARY-DOUBLE), random out
*> (BINARY-LONG): the rule of docs/protocol/11 section 12.1. The text is decoded to UTF-16 code units
*> (a lead byte without enough bytes after it counts as one unit, so any bytes decode); outer units up to
*> 0x20 are trimmed; empty gives random 1 and a seed drawn from FUNCTION RANDOM (seeded once from the
*> clock); a base-10 number (optional sign, Unicode digits, at most the 64-bit range) is its value;
*> anything else is the 32-bit Java string hash of the trimmed units, sign-extended.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CLOCK               PIC X(21).
 01 WS-DRAW                FLOAT-LONG.
 01 WS-UNITS.
    05 WS-UNIT             BINARY-LONG OCCURS 128 TIMES.
 01 WS-DIGITS.
    05 WS-DIGIT            BINARY-LONG OCCURS 128 TIMES.
 01 WS-LIMIT-POS           PIC X(19) VALUE "9223372036854775807".
 01 WS-LIMIT-NEG           PIC X(19) VALUE "9223372036854775808".
 01 WS-LIMIT               PIC X(19).
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-B2                  BINARY-LONG.
 01 WS-B3                  BINARY-LONG.
 01 WS-B4                  BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-NEG                 PIC 9.
 01 WS-OK                  PIC 9.
 01 WS-SIG                 BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-HASH                BINARY-DOUBLE.
 01 WS-LIMIT-DIGIT         BINARY-LONG.
 01 WS-CMP                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(64).
 01 L-SEED                 BINARY-DOUBLE.
 01 L-RANDOM               BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-SEED L-RANDOM.
     MOVE 0 TO WS-N L-RANDOM L-SEED
     MOVE 1 TO WS-I
     PERFORM UNTIL WS-I > 64
         COMPUTE WS-B = FUNCTION ORD(L-TEXT(WS-I:1)) - 1
         MOVE 0 TO WS-B2 WS-B3 WS-B4
         IF WS-I < 64
             COMPUTE WS-B2 = FUNCTION ORD(L-TEXT(WS-I + 1:1)) - 1
         END-IF
         IF WS-I < 63
             COMPUTE WS-B3 = FUNCTION ORD(L-TEXT(WS-I + 2:1)) - 1
         END-IF
         IF WS-I < 62
             COMPUTE WS-B4 = FUNCTION ORD(L-TEXT(WS-I + 3:1)) - 1
         END-IF
         ADD 1 TO WS-N
         EVALUATE TRUE
             WHEN WS-B >= 192 AND WS-B < 224 AND WS-I < 64
                 COMPUTE WS-UNIT(WS-N) = (WS-B - 192) * 64 + WS-B2 - 128
                 ADD 2 TO WS-I
             WHEN WS-B >= 224 AND WS-B < 240 AND WS-I < 63
                 COMPUTE WS-UNIT(WS-N) = (WS-B - 224) * 4096 + (WS-B2 - 128) * 64 + WS-B3 - 128
                 ADD 3 TO WS-I
             WHEN WS-B >= 240 AND WS-B < 248 AND WS-I < 62
                 COMPUTE WS-V = ((WS-B - 240) * 262144 + (WS-B2 - 128) * 4096 + (WS-B3 - 128) * 64
                     + WS-B4 - 128) - 65536
                 COMPUTE WS-UNIT(WS-N) = 55296 + WS-V / 1024
                 ADD 1 TO WS-N
                 COMPUTE WS-UNIT(WS-N) = 56320 + FUNCTION MOD(WS-V, 1024)
                 ADD 4 TO WS-I
             WHEN OTHER
                 MOVE WS-B TO WS-UNIT(WS-N)
                 ADD 1 TO WS-I
         END-EVALUATE
     END-PERFORM
*>   Trim.
     MOVE 1 TO WS-FIRST
     PERFORM UNTIL WS-FIRST > WS-N OR WS-UNIT(WS-FIRST) > 32
         ADD 1 TO WS-FIRST
     END-PERFORM
     MOVE WS-N TO WS-LAST
     PERFORM UNTIL WS-LAST < WS-FIRST OR WS-UNIT(WS-LAST) > 32
         SUBTRACT 1 FROM WS-LAST
     END-PERFORM
     IF WS-FIRST > WS-LAST
         MOVE 1 TO L-RANDOM
         IF WS-READY = 0
             MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
             COMPUTE WS-DRAW = FUNCTION RANDOM(FUNCTION NUMVAL(WS-CLOCK(9:8)))
             MOVE 1 TO WS-READY
         END-IF
         MOVE 0 TO WS-HASH
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
             COMPUTE WS-DRAW = FUNCTION RANDOM
             COMPUTE WS-V = WS-DRAW * 65536
             COMPUTE WS-HASH = WS-HASH * 65536 + WS-V
         END-PERFORM
         MOVE WS-HASH TO L-SEED
         GOBACK
     END-IF
*>   Number.
     MOVE WS-FIRST TO WS-POS
     MOVE 0 TO WS-NEG
     EVALUATE WS-UNIT(WS-POS)
         WHEN 45
             MOVE 1 TO WS-NEG
             ADD 1 TO WS-POS
         WHEN 43
             ADD 1 TO WS-POS
     END-EVALUATE
     MOVE 1 TO WS-OK
     IF WS-POS > WS-LAST
         MOVE 0 TO WS-OK
     END-IF
     MOVE 0 TO WS-SIG
     PERFORM VARYING WS-I FROM WS-POS BY 1 UNTIL WS-I > WS-LAST OR WS-OK = 0
         CALL "SEED-DIGIT" USING WS-UNIT(WS-I) WS-D
         EVALUATE TRUE
             WHEN WS-D < 0
                 MOVE 0 TO WS-OK
             WHEN WS-SIG > 0 OR WS-D > 0
                 ADD 1 TO WS-SIG
                 IF WS-SIG > 19
                     MOVE 0 TO WS-OK
                 ELSE
                     MOVE WS-D TO WS-DIGIT(WS-SIG)
                 END-IF
         END-EVALUATE
     END-PERFORM
     IF WS-OK = 1 AND WS-SIG = 19
         MOVE WS-LIMIT-POS TO WS-LIMIT
         IF WS-NEG = 1
             MOVE WS-LIMIT-NEG TO WS-LIMIT
         END-IF
         MOVE 0 TO WS-CMP
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 19 OR WS-CMP NOT = 0
             COMPUTE WS-LIMIT-DIGIT = FUNCTION ORD(WS-LIMIT(WS-K:1)) - 49
             EVALUATE TRUE
                 WHEN WS-DIGIT(WS-K) > WS-LIMIT-DIGIT
                     MOVE 1 TO WS-CMP
                 WHEN WS-DIGIT(WS-K) < WS-LIMIT-DIGIT
                     MOVE -1 TO WS-CMP
             END-EVALUATE
         END-PERFORM
         IF WS-CMP > 0
             MOVE 0 TO WS-OK
         END-IF
     END-IF
     IF WS-OK = 1
*>       The value is built negative so that the lower bound fits.
         MOVE 0 TO L-SEED
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-SIG
             COMPUTE L-SEED = L-SEED * 10 - WS-DIGIT(WS-K)
         END-PERFORM
         IF WS-NEG = 0
             COMPUTE L-SEED = 0 - L-SEED
         END-IF
         GOBACK
     END-IF
*>   Hash of the trimmed units.
     MOVE 0 TO WS-HASH
     PERFORM VARYING WS-I FROM WS-FIRST BY 1 UNTIL WS-I > WS-LAST
         COMPUTE WS-HASH = FUNCTION MOD(31 * WS-HASH + WS-UNIT(WS-I), 4294967296)
     END-PERFORM
     IF WS-HASH >= 2147483648
         SUBTRACT 4294967296 FROM WS-HASH
     END-IF
     MOVE WS-HASH TO L-SEED
     GOBACK.
 END PROGRAM SEED-FROM-TEXT.
