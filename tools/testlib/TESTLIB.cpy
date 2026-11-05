*> Assertion record of the COBOL test library (contracts/test-harness.md §3, research R9).
*> A test program fills it and calls TEST-ASSERT, which prints exactly one line:
*>   TEST <case> PASS
*>   TEST <case> FAIL expected=<x> observed=<y>
*> Text mode compares TL-EXPECTED with TL-OBSERVED (trailing spaces are not significant);
*> number mode compares TL-EXPECTED-N with TL-OBSERVED-N.
 01 TESTLIB-ASSERT.
    05 TL-CASE          PIC X(240).
    05 TL-MODE          PIC X.
       88 TL-TEXT       VALUE "T".
       88 TL-NUMBER     VALUE "N".
    05 TL-EXPECTED      PIC X(1024).
    05 TL-OBSERVED      PIC X(1024).
    05 TL-EXPECTED-N    BINARY-DOUBLE SIGNED.
    05 TL-OBSERVED-N    BINARY-DOUBLE SIGNED.
