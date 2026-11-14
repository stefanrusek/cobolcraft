 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPIKE-NOISE-SPEED.
*> spike (throwaway): how fast GnuCOBOL 3.2 evaluates one improved-Perlin (gradient) noise sample, the
*> unit of work of the terrain density functions (docs/protocol/10). Measures samples per second with
*> the permutation table, a trilinear fade interpolation and 8 gradient dot products in the standard
*> improved-noise form, using BINARY-LONG indexing and FLOAT-LONG arithmetic (the types the engine
*> will use). The values are not the game's noise; only the cost of the arithmetic is measured.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PERM.
    05 WS-P                BINARY-LONG OCCURS 512 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-W                   FLOAT-LONG.
 01 WS-XI                  BINARY-LONG.
 01 WS-YI                  BINARY-LONG.
 01 WS-ZI                  BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-AA                  BINARY-LONG.
 01 WS-AB                  BINARY-LONG.
 01 WS-BA                  BINARY-LONG.
 01 WS-BB                  BINARY-LONG.
 01 WS-SUM                 FLOAT-LONG VALUE 0.
 01 WS-R                   FLOAT-LONG.
 01 WS-T0                  PIC 9(8).
 01 WS-T1                  PIC 9(8).
 01 WS-MS                  BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-D1                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-D3                  FLOAT-LONG.
 01 WS-D4                  FLOAT-LONG.
 01 WS-D5                  FLOAT-LONG.
 01 WS-D6                  FLOAT-LONG.
 01 WS-D7                  FLOAT-LONG.
 01 WS-D8                  FLOAT-LONG.
 01 WS-L1                  FLOAT-LONG.
 01 WS-L2                  FLOAT-LONG.
 01 WS-L3                  FLOAT-LONG.
 01 WS-L4                  FLOAT-LONG.
 01 WS-M1                  FLOAT-LONG.
 01 WS-M2                  FLOAT-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         COMPUTE WS-P(WS-I) = FUNCTION MOD(WS-I * 167 + 13, 256)
         MOVE WS-P(WS-I) TO WS-P(WS-I + 256)
     END-PERFORM
     ACCEPT WS-T0 FROM TIME
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 1000000
         COMPUTE WS-X = WS-N * 0.0137
         COMPUTE WS-Y = WS-N * 0.0071
         COMPUTE WS-Z = WS-N * 0.0093
         COMPUTE WS-XI = FUNCTION INTEGER(WS-X)
         COMPUTE WS-YI = FUNCTION INTEGER(WS-Y)
         COMPUTE WS-ZI = FUNCTION INTEGER(WS-Z)
         COMPUTE WS-FX = WS-X - WS-XI
         COMPUTE WS-FY = WS-Y - WS-YI
         COMPUTE WS-FZ = WS-Z - WS-ZI
         COMPUTE WS-U = WS-FX * WS-FX * WS-FX * (WS-FX * (WS-FX * 6 - 15) + 10)
         COMPUTE WS-V = WS-FY * WS-FY * WS-FY * (WS-FY * (WS-FY * 6 - 15) + 10)
         COMPUTE WS-W = WS-FZ * WS-FZ * WS-FZ * (WS-FZ * (WS-FZ * 6 - 15) + 10)
         COMPUTE WS-XI = FUNCTION MOD(WS-XI, 256) + 1
         COMPUTE WS-YI = FUNCTION MOD(WS-YI, 256) + 1
         COMPUTE WS-ZI = FUNCTION MOD(WS-ZI, 256) + 1
         COMPUTE WS-A = WS-P(WS-XI) + WS-YI
         COMPUTE WS-B = WS-P(WS-XI + 1) + WS-YI
         COMPUTE WS-AA = WS-P(WS-A) + WS-ZI
         COMPUTE WS-AB = WS-P(WS-A + 1) + WS-ZI
         COMPUTE WS-BA = WS-P(WS-B) + WS-ZI
         COMPUTE WS-BB = WS-P(WS-B + 1) + WS-ZI
         COMPUTE WS-D1 = FUNCTION MOD(WS-P(WS-AA), 3) * WS-FX + WS-FY - WS-FZ
         COMPUTE WS-D2 = FUNCTION MOD(WS-P(WS-BA), 3) * (WS-FX - 1) + WS-FY - WS-FZ
         COMPUTE WS-D3 = FUNCTION MOD(WS-P(WS-AB), 3) * WS-FX + (WS-FY - 1) - WS-FZ
         COMPUTE WS-D4 = FUNCTION MOD(WS-P(WS-BB), 3) * (WS-FX - 1) + (WS-FY - 1) - WS-FZ
         COMPUTE WS-D5 = FUNCTION MOD(WS-P(WS-AA + 1), 3) * WS-FX + WS-FY - (WS-FZ - 1)
         COMPUTE WS-D6 = FUNCTION MOD(WS-P(WS-BA + 1), 3) * (WS-FX - 1) + WS-FY - (WS-FZ - 1)
         COMPUTE WS-D7 = FUNCTION MOD(WS-P(WS-AB + 1), 3) * WS-FX + (WS-FY - 1) - (WS-FZ - 1)
         COMPUTE WS-D8 = FUNCTION MOD(WS-P(WS-BB + 1), 3) * (WS-FX - 1) + (WS-FY - 1) - (WS-FZ - 1)
         COMPUTE WS-L1 = WS-D1 + WS-U * (WS-D2 - WS-D1)
         COMPUTE WS-L2 = WS-D3 + WS-U * (WS-D4 - WS-D3)
         COMPUTE WS-L3 = WS-D5 + WS-U * (WS-D6 - WS-D5)
         COMPUTE WS-L4 = WS-D7 + WS-U * (WS-D8 - WS-D7)
         COMPUTE WS-M1 = WS-L1 + WS-V * (WS-L2 - WS-L1)
         COMPUTE WS-M2 = WS-L3 + WS-V * (WS-L4 - WS-L3)
         COMPUTE WS-R = WS-M1 + WS-W * (WS-M2 - WS-M1)
         ADD WS-R TO WS-SUM
     END-PERFORM
     ACCEPT WS-T1 FROM TIME
     DISPLAY "1,000,000 samples, checksum " WS-SUM
     DISPLAY "time of day HHMMSScc before " WS-T0 " after " WS-T1
     STOP RUN.
