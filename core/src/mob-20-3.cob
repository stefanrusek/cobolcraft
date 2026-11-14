*> Shared tables of the overworld hostile mobs (002-lane-mobsfull-h3; docs/protocol/20 section 3).
*>
*> Entry points:
*>   STDMOB-DIFFICULTY USING difficulty id, time, inhabited time (BINARY-DOUBLE ticks), moon brightness (thousandths), eff out (thousandths)
*>   STDMOB-SPECIAL USING eff (thousandths), multiplier out (thousandths)
*>   STDMOB-BRIGHTNESS USING light 0 to 15, ambient (thousandths), brightness out (thousandths)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-DIFFICULTY.
*> Effective (local) difficulty (3.2). a = clamp((T - 72000) / 1440000, 0, 1) x 0.25; base = 0.75 + a; b = clamp(I / 3600000, 0, 1) x (1 on Hard, else
*> 0.75) + clamp(M x 0.25, 0, a), halved on Easy; eff = difficulty id x (base + b); Peaceful 0. All in thousandths (truncated).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   BINARY-DOUBLE.
 01 WS-B                   BINARY-DOUBLE.
 01 WS-M                   BINARY-DOUBLE.
 01 WS-T                   BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-DIFFICULTY           BINARY-LONG.
 01 L-TIME                 BINARY-DOUBLE.
 01 L-INHABITED            BINARY-DOUBLE.
 01 L-MOON                 BINARY-LONG.
 01 L-EFF                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIFFICULTY L-TIME L-INHABITED L-MOON L-EFF.
     MOVE 0 TO L-EFF
     IF L-DIFFICULTY = 0
         GOBACK
     END-IF
     COMPUTE WS-T = FUNCTION MAX(0, FUNCTION MIN(1440000, L-TIME - 72000))
     COMPUTE WS-A = WS-T * 250 / 1440000
     COMPUTE WS-B = FUNCTION MAX(0, FUNCTION MIN(3600000, L-INHABITED)) * 750 / 3600000
     IF L-DIFFICULTY = 3
         COMPUTE WS-B = FUNCTION MAX(0, FUNCTION MIN(3600000, L-INHABITED)) * 1000 / 3600000
     END-IF
     COMPUTE WS-M = FUNCTION MAX(0, FUNCTION MIN(WS-A, L-MOON * 250 / 1000))
     COMPUTE WS-B = WS-B + WS-M
     IF L-DIFFICULTY = 1
         COMPUTE WS-B = WS-B / 2
     END-IF
     COMPUTE L-EFF = L-DIFFICULTY * (750 + WS-A + WS-B)
     GOBACK.
 END PROGRAM STDMOB-DIFFICULTY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-SPECIAL.
*> The special multiplier of an effective difficulty (3.2): 0 below 2, 1 above 4, else (eff - 2) / 2 (thousandths).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EFF                  BINARY-LONG.
 01 L-MULT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-EFF L-MULT.
     EVALUATE TRUE
         WHEN L-EFF < 2000
             MOVE 0 TO L-MULT
         WHEN L-EFF > 4000
             MOVE 1000 TO L-MULT
         WHEN OTHER
             COMPUTE L-MULT = (L-EFF - 2000) / 2
     END-EVALUATE
     GOBACK.
 END PROGRAM STDMOB-SPECIAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-BRIGHTNESS.
*> Light-dependent brightness (3.3): v = l / (60 - 3 l) (f / (4 - 3 f) with f = l / 15), result v + ambient (1 - v), thousandths. Light 13 and more is above 0.5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-V                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-LIGHT                BINARY-LONG.
 01 L-AMBIENT              BINARY-LONG.
 01 L-B                    BINARY-LONG.
 PROCEDURE DIVISION USING L-LIGHT L-AMBIENT L-B.
     COMPUTE WS-V = L-LIGHT * 1000 / (60 - 3 * L-LIGHT)
     COMPUTE L-B = WS-V + L-AMBIENT * (1000 - WS-V) / 1000
     GOBACK.
 END PROGRAM STDMOB-BRIGHTNESS.
