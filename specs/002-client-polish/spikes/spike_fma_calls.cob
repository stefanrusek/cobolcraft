 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPIKE-FMA-CALLS.
*> spike (throwaway): IEEE double add and multiply from COBOL with no C glue, by calling libm's fma
*> directly (constitution Principle I): fma(a, b, 0.0) is exactly the rounded product a*b and fma(a, 1.0, b)
*> exactly the rounded sum a+b (single rounding, so equal to Java's separate double operations).
*> Measures 2,000,000 calls and checks one product and one sum against values computed by Python.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG.
 01 WS-A                   FLOAT-LONG VALUE 1.0000001.
 01 WS-B                   FLOAT-LONG VALUE 0.9999999.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-C                   FLOAT-LONG VALUE 0.
 01 WS-P                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-X                   FLOAT-LONG VALUE 0.1.
 01 WS-Y                   FLOAT-LONG VALUE 0.2.
 01 WS-X3                  FLOAT-LONG VALUE 3.
 01 WS-T0                  PIC 9(8).
 01 WS-T1                  PIC 9(8).
 PROCEDURE DIVISION.
     CALL STATIC "fma" USING BY VALUE WS-X BY VALUE WS-ONE BY VALUE WS-Y RETURNING WS-S
     CALL STATIC "fma" USING BY VALUE WS-X BY VALUE WS-X3 BY VALUE WS-ZERO RETURNING WS-P
     DISPLAY "0.1+0.2 = " WS-S " (IEEE: 0.30000000000000004), 0.1*3 = " WS-P " (IEEE: 0.30000000000000004)"
     ACCEPT WS-T0 FROM TIME
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 2000000
         CALL STATIC "fma" USING BY VALUE WS-A BY VALUE WS-B BY VALUE WS-C RETURNING WS-C
     END-PERFORM
     ACCEPT WS-T1 FROM TIME
     DISPLAY "2,000,000 fma calls  " WS-T0 " -> " WS-T1
     STOP RUN.
