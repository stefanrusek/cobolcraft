*> Value effects (docs/protocol/28 section 5; US14; T2169). An effect list is written in prefix form like the values of ench-4.cob: "add v",
*> "multiply v", "set v", "exponential base power" (v, base and power are level-based expressions), "all_of" (a no-op word that only opens a
*> list); the effects fold left to right, each receiving the previous result.
*>   TOOL-VALUE-FOLD USING effects (PIC X(200)), level, value in (ten-thousandths), value out, status out (0 ok, 1 an invalid clamp, 2 syntax error;
*>     the value is unchanged on an error)
*> remove_binomial (the random draws come from the caller, thousandths of a nextFloat or the Gaussian):
*>   TOOL-BINOMIAL-METHOD USING n, p (thousandths), normal out (1 when n > 128 and n p >= 20 and n (1 - p) >= 20)
*>   TOOL-BINOMIAL-DRAWS USING n, draws out (ceil(n))
*>   TOOL-BINOMIAL-EXACT USING n, p, draws (PIC X(200): the numbers, thousandths), result out (n minus the draws under p), thousandths
*>   TOOL-BINOMIAL-NORMAL USING n, p, Gaussian (thousandths), result out (n - k, k = round(floor(n p) + g sd) clamped to 0 to n, sd = sqrt(n p (1 - p)))

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-VALUE-FOLD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TOKENS.
    05 WS-TOKEN            PIC X(16) OCCURS 60 TIMES.
 01 WS-COUNT               BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-VALUE               FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-NAME                PIC X(16).
 LINKAGE SECTION.
 01 L-EFFECTS              PIC X(200).
 01 L-LEVEL                BINARY-LONG.
 01 L-START                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-EFFECTS L-LEVEL L-START L-RESULT L-STATUS.
     MOVE 0 TO L-STATUS
     MOVE L-START TO L-RESULT
     CALL "TOOL-LBV-TOKENS" USING L-EFFECTS WS-TOKENS WS-COUNT
     COMPUTE WS-VALUE = L-START / 10000
     MOVE 1 TO WS-POS
     PERFORM UNTIL WS-POS > WS-COUNT OR L-STATUS NOT = 0
         MOVE WS-TOKEN(WS-POS) TO WS-NAME
         ADD 1 TO WS-POS
         EVALUATE WS-NAME
             WHEN "all_of"
                 CONTINUE
             WHEN "add"
                 CALL "TOOL-LBV-NODE" USING WS-TOKENS WS-COUNT WS-POS L-LEVEL WS-A L-STATUS
                 COMPUTE WS-VALUE = WS-VALUE + WS-A
             WHEN "multiply"
                 CALL "TOOL-LBV-NODE" USING WS-TOKENS WS-COUNT WS-POS L-LEVEL WS-A L-STATUS
                 COMPUTE WS-VALUE = WS-VALUE * WS-A
             WHEN "set"
                 CALL "TOOL-LBV-NODE" USING WS-TOKENS WS-COUNT WS-POS L-LEVEL WS-A L-STATUS
                 MOVE WS-A TO WS-VALUE
             WHEN "exponential"
                 CALL "TOOL-LBV-NODE" USING WS-TOKENS WS-COUNT WS-POS L-LEVEL WS-A L-STATUS
                 CALL "TOOL-LBV-NODE" USING WS-TOKENS WS-COUNT WS-POS L-LEVEL WS-B L-STATUS
                 COMPUTE WS-VALUE = WS-VALUE * (WS-A ** WS-B)
             WHEN OTHER
                 MOVE 2 TO L-STATUS
         END-EVALUATE
     END-PERFORM
     IF L-STATUS = 0
         COMPUTE L-RESULT ROUNDED = WS-VALUE * 10000
     END-IF
     GOBACK.
 END PROGRAM TOOL-VALUE-FOLD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-BINOMIAL-METHOD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NP                  BINARY-DOUBLE.
 01 WS-NQ                  BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-NORMAL               BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-P L-NORMAL.
     COMPUTE WS-NP = L-N * L-P
     COMPUTE WS-NQ = L-N * (1000 - L-P)
     MOVE 0 TO L-NORMAL
     IF L-N > 128000 AND WS-NP >= 20000000 AND WS-NQ >= 20000000
         MOVE 1 TO L-NORMAL
     END-IF
     GOBACK.
 END PROGRAM TOOL-BINOMIAL-METHOD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-BINOMIAL-DRAWS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-DRAWS                BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-DRAWS.
     COMPUTE L-DRAWS = (L-N + 999) / 1000
     GOBACK.
 END PROGRAM TOOL-BINOMIAL-DRAWS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-BINOMIAL-EXACT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TOKENS.
    05 WS-TOKEN            PIC X(16) OCCURS 60 TIMES.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-DRAWS               BINARY-LONG.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-LIST                 PIC X(200).
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-P L-LIST L-RESULT.
     CALL "TOOL-LBV-TOKENS" USING L-LIST WS-TOKENS WS-COUNT
     CALL "TOOL-BINOMIAL-DRAWS" USING L-N WS-DRAWS
     MOVE 0 TO WS-K
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR WS-I > WS-DRAWS
         IF FUNCTION NUMVAL(WS-TOKEN(WS-I)) < L-P
             ADD 1 TO WS-K
         END-IF
     END-PERFORM
     COMPUTE L-RESULT = L-N - WS-K * 1000
     GOBACK.
 END PROGRAM TOOL-BINOMIAL-EXACT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-BINOMIAL-NORMAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MEAN                FLOAT-LONG.
 01 WS-SD                  FLOAT-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-GAUSS                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-P L-GAUSS L-RESULT.
     COMPUTE WS-MEAN = FUNCTION INTEGER(L-N * L-P / 1000000)
     COMPUTE WS-SD = FUNCTION SQRT(L-N * L-P * (1000 - L-P) / 1000000000)
     COMPUTE WS-K = FUNCTION INTEGER(WS-MEAN + L-GAUSS / 1000 * WS-SD + 0.5)
     COMPUTE WS-MAX = L-N / 1000
     IF WS-K < 0
         MOVE 0 TO WS-K
     END-IF
     IF WS-K > WS-MAX
         MOVE WS-MAX TO WS-K
     END-IF
     COMPUTE L-RESULT = L-N - WS-K * 1000
     GOBACK.
 END PROGRAM TOOL-BINOMIAL-NORMAL.
