*> Float compare without decimals (performance, Risk R-P): a COBOL compare of a FLOAT-LONG converts both sides through decimals, about
*> a microsecond; this one is one cc_f64 subtraction and two integer compares.
*>   FCMP-GT USING a, b (FLOAT-LONG), result out (BINARY-LONG): 1 when a > b, otherwise 0 (a NaN is never greater, nor less)
*> a > b exactly when a - b is a positive number (IEEE gradual underflow: the difference of two different finite doubles is never 0;
*> an infinity minus itself is a NaN). Positive and not a NaN: the bits, as a signed 64 bit value, are above 0 and not above those of
*> +infinity.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FCMP-GT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D                   FLOAT-LONG.
 01 WS-BITS                BINARY-DOUBLE.
 01 WS-INF-BITS            BINARY-DOUBLE VALUE 9218868437227405312.
 LINKAGE SECTION.
 01 L-A                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-RESULT.
     CALL STATIC "cc_f64_sub" USING BY REFERENCE L-A L-B WS-D
     CALL STATIC "cc_f64_f64_bits" USING BY REFERENCE WS-D WS-BITS
     IF WS-BITS > 0 AND WS-BITS <= WS-INF-BITS
         MOVE 1 TO L-RESULT
     ELSE
         MOVE 0 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM FCMP-GT.
