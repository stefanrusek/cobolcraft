*> Mth.atan2 for the mob code (docs/protocol/44-residual-mob-questions-x1-continuation.md section 11.1, 10 section 16.4; lane 002-lane-p49s, T38580). The table routine itself is the shim's
*> cc_f64_atan2_mth (the two 257-entry tables, the Newton step of the inverse square root and the cubic correction, argument order (y, x)); these programs give it to the core.
*>   MTH-ATAN2 USING y, x (FLOAT-LONG), angle out (FLOAT-LONG, radians)            Mth.atan2(y, x); (0, 0) is 0
*>   MTH-ATAN2-DEG USING y, x (FLOAT-LONG), degrees out (FLOAT-LONG)               Mth.atan2(y, x) x 57.2957763671875 (Mth.RAD_TO_DEG, the float constant the look and move controls use)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MTH-ATAN2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-Y                    FLOAT-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-ANGLE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-Y L-X L-ANGLE.
     CALL STATIC "cc_f64_atan2_mth" USING BY REFERENCE L-Y L-X L-ANGLE
     GOBACK.
 END PROGRAM MTH-ATAN2.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MTH-ATAN2-DEG.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-Y                    FLOAT-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-DEG                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-Y L-X L-DEG.
     CALL STATIC "cc_f64_atan2_mth" USING BY REFERENCE L-Y L-X L-DEG
     COMPUTE L-DEG = L-DEG * 57.2957763671875
     GOBACK.
 END PROGRAM MTH-ATAN2-DEG.
