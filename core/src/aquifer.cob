*> Aquifers (docs/protocol/10 section 9; T0421). AQUIFER-PREP is the step program of the aquifer stage of the generation job (one quart
*> column of the surface scan of 9.4 per step, 121 steps): step 0 also sets the aquifer up (positional factory of minecraft:aquifer,
*> the four noises, the density functions it reads); the last step derives skipSamplingAboveY. AQUIFER-SUBSTANCE is computeSubstance
*> of 9.2 for one block. Without the function minecraft:overworld/preliminary_surface_level in the loaded data there is no aquifer
*> (the job's GJ-AQ-READY stays 0) and the substance is the global fluid picker alone: lava below y -54, water below the sea level 63.
*> Arithmetic that decides a result is IEEE double through cc_f64_*; centres, statuses and surface levels are memoised per job.
*> Fluid status: level (BINARY-LONG) and type (1 water, 2 lava); at(y) is the type when y < level, else air. Kind out of
*> AQUIFER-SUBSTANCE: 0 none (the default block), 1 air, 2 water, 3 lava.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AQ-NOISE.
*> USING job, which (1 barrier, 2 floodedness, 3 spread, 4 lava), x, y, z (BINARY-LONG), result out (FLOAT-LONG): the noise at
*> (x * 1.0, y * yscale, z * 1.0) (9.1; 0 when the data does not define the noise).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-SCALES.
    05 WS-SCALE            FLOAT-LONG OCCURS 4 TIMES.
 01 WS-TEXT-1              PIC X(24) VALUE Z"0.5".
 01 WS-TEXT-2              PIC X(24) VALUE Z"0.67".
 01 WS-TEXT-3              PIC X(24) VALUE Z"0.7142857142857143".
 01 WS-TEXT-4              PIC X(24) VALUE Z"1.0".
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YS                  FLOAT-LONG.
 01 WS-H                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 01 L-WHICH                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-JOB L-WHICH L-X L-Y L-Z L-RESULT.
     IF WS-READY = 0
         CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-TEXT-1 WS-SCALE(1)
         CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-TEXT-2 WS-SCALE(2)
         CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-TEXT-3 WS-SCALE(3)
         CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-TEXT-4 WS-SCALE(4)
         MOVE 1 TO WS-READY
     END-IF
     MOVE 0 TO L-RESULT
     EVALUATE L-WHICH
         WHEN 1
             MOVE J-AQ-BARRIER TO WS-H
         WHEN 2
             MOVE J-AQ-FLOOD TO WS-H
         WHEN 3
             MOVE J-AQ-SPREAD TO WS-H
         WHEN OTHER
             MOVE J-AQ-LAVA TO WS-H
     END-EVALUATE
     IF WS-H = 0
         GOBACK
     END-IF
     MOVE L-X TO WS-X
     MOVE L-Y TO WS-Y
     MOVE L-Z TO WS-Z
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-Y WS-SCALE(L-WHICH) WS-YS
     CALL "NOISE-GET" USING WS-H WS-X WS-YS WS-Z L-RESULT
     GOBACK.
 END PROGRAM AQ-NOISE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AQ-SURFACE-LEVEL.
*> USING job, block x, block z (BINARY-LONG), level out (BINARY-LONG): 9.4 surfaceLevel(x, z) = floor(preliminary_surface_level at the
*> quart-aligned column), memoised by column.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-QX                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-TRIES               BINARY-LONG.
 01 WS-Y                   BINARY-LONG VALUE 0.
 01 WS-V                   FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 PROCEDURE DIVISION USING L-JOB L-X L-Z L-LEVEL.
     COMPUTE WS-QX = FUNCTION INTEGER(L-X / 4) * 4
     COMPUTE WS-QZ = FUNCTION INTEGER(L-Z / 4) * 4
     COMPUTE WS-SLOT = FUNCTION MOD(FUNCTION INTEGER(L-X / 4) * 31 + FUNCTION INTEGER(L-Z / 4) * 17, 2048) + 1
     MOVE 0 TO WS-TRIES
     PERFORM UNTIL J-AQ-S-USED(WS-SLOT) = 0 OR WS-TRIES >= 2048
         IF J-AQ-S-X(WS-SLOT) = WS-QX AND J-AQ-S-Z(WS-SLOT) = WS-QZ
             MOVE J-AQ-S-VALUE(WS-SLOT) TO L-LEVEL
             GOBACK
         END-IF
         ADD 1 TO WS-SLOT
         ADD 1 TO WS-TRIES
         IF WS-SLOT > 2048
             MOVE 1 TO WS-SLOT
         END-IF
     END-PERFORM
     CALL "DENSITY-NODE" USING J-AQ-ROOT-PSL WS-QX WS-Y WS-QZ WS-V
     CALL STATIC "cc_f64_floor" USING BY REFERENCE WS-V WS-F
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-F L-LEVEL
*>   a full memo (never so in a chunk's own demand) leaves the level unremembered
     IF WS-TRIES < 2048
         MOVE 1 TO J-AQ-S-USED(WS-SLOT)
         MOVE WS-QX TO J-AQ-S-X(WS-SLOT)
         MOVE WS-QZ TO J-AQ-S-Z(WS-SLOT)
         MOVE L-LEVEL TO J-AQ-S-VALUE(WS-SLOT)
     END-IF
     GOBACK.
 END PROGRAM AQ-SURFACE-LEVEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AQUIFER-PREP.
*> USING job: step GJ-SUB (0 to 120) of the aquifer stage: step 0 sets the aquifer up, every step reads the surface level of one quart
*> column of the 11 x 11 columns of 9.4 (from the cell x chunk x - 1 to the offset 9 of the cell chunk x + 1, z likewise) and keeps the
*> largest; the last step sets skipSamplingAboveY = fromGridY(gridY(maxSurface + 8 + 12) - 1, 11) - 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY DENSITY.
 COPY GENSTAGE.
 01 WS-KIND-FN             BINARY-LONG VALUE 1.
 01 WS-KEY-PSL             PIC X(112) VALUE "minecraft:overworld/preliminary_surface_level".
 01 WS-KEY-ERO             PIC X(112) VALUE "minecraft:overworld/erosion".
 01 WS-KEY-DEP             PIC X(112) VALUE "minecraft:overworld/depth".
 01 WS-N-BARRIER           PIC X(112) VALUE "minecraft:aquifer_barrier".
 01 WS-N-FLOOD             PIC X(112) VALUE "minecraft:aquifer_fluid_level_floodedness".
 01 WS-N-SPREAD            PIC X(112) VALUE "minecraft:aquifer_fluid_level_spread".
 01 WS-N-LAVA              PIC X(112) VALUE "minecraft:aquifer_lava".
 01 WS-NAME                PIC X(64) VALUE "minecraft:aquifer".
 01 WS-LENGTH              BINARY-LONG VALUE 17.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-HASHED== LEADING ==XR-== BY ==WS-H-==.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-FAC== LEADING ==XR-== BY ==WS-F-==.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 PROCEDURE DIVISION USING L-JOB.
     IF J-SUB = 0
         MOVE 0 TO J-AQ-READY
         CALL "WG-FIND" USING WS-KIND-FN WS-KEY-PSL J-AQ-ROOT-PSL
         IF J-AQ-ROOT-PSL = 0
             GOBACK
         END-IF
         CALL "WG-FIND" USING WS-KIND-FN WS-KEY-ERO J-AQ-ROOT-ERO
         CALL "WG-FIND" USING WS-KIND-FN WS-KEY-DEP J-AQ-ROOT-DEP
         CALL "DENSITY-NOISE-HANDLE" USING WS-N-BARRIER J-AQ-BARRIER
         CALL "DENSITY-NOISE-HANDLE" USING WS-N-FLOOD J-AQ-FLOOD
         CALL "DENSITY-NOISE-HANDLE" USING WS-N-SPREAD J-AQ-SPREAD
         CALL "DENSITY-NOISE-HANDLE" USING WS-N-LAVA J-AQ-LAVA
         CALL "XORO-FROM-HASH" USING DN-FACTORY WS-NAME WS-LENGTH WS-HASHED
         CALL "XORO-FORK-POSITIONAL" USING WS-HASHED WS-FAC
         MOVE WS-F-LO TO J-AQ-FLO
         MOVE WS-F-HI TO J-AQ-FHI
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 315
             MOVE 0 TO J-AQ-HAVE(WS-I) J-AQ-STAT(WS-I)
         END-PERFORM
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2048
             MOVE 0 TO J-AQ-S-USED(WS-I)
         END-PERFORM
         MOVE -65 TO J-AQ-MAX-SURFACE
         MOVE 1 TO J-AQ-READY
     END-IF
     IF J-AQ-READY = 0
         GOBACK
     END-IF
     ADD 1 TO GS-AQUIFER
     DIVIDE J-SUB BY 11 GIVING WS-I REMAINDER WS-J
     COMPUTE WS-X = (J-CX - 1) * 16 + WS-I * 4
     COMPUTE WS-Z = (J-CZ - 1) * 16 + WS-J * 4
     CALL "AQ-SURFACE-LEVEL" USING L-JOB WS-X WS-Z WS-LEVEL
     IF WS-LEVEL > J-AQ-MAX-SURFACE
         MOVE WS-LEVEL TO J-AQ-MAX-SURFACE
     END-IF
     IF J-SUB = 120
         COMPUTE WS-G = FUNCTION INTEGER((J-AQ-MAX-SURFACE + 8 + 12) / 12) - 1
         COMPUTE J-AQ-SKIP-Y = WS-G * 12 + 11 - 1
     END-IF
     GOBACK.
 END PROGRAM AQUIFER-PREP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AQ-PICKER.
*> USING y (BINARY-LONG), level out, type out (1 water, 2 lava): the global fluid status at that y (9.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-Y                    BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-Y L-LEVEL L-TYPE.
     IF L-Y < -54
         MOVE -54 TO L-LEVEL
         MOVE 2 TO L-TYPE
     ELSE
         MOVE 63 TO L-LEVEL
         MOVE 1 TO L-TYPE
     END-IF
     GOBACK.
 END PROGRAM AQ-PICKER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AQ-AT.
*> USING level, type, y (BINARY-LONG), fluid out (0 air, 1 water, 2 lava): status.at(y).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LEVEL                BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 PROCEDURE DIVISION USING L-LEVEL L-TYPE L-Y L-FLUID.
     IF L-Y < L-LEVEL
         MOVE L-TYPE TO L-FLUID
     ELSE
         MOVE 0 TO L-FLUID
     END-IF
     GOBACK.
 END PROGRAM AQ-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AQ-SIMILARITY.
*> USING a, b (BINARY-LONG squared distances), result out (FLOAT-LONG): 1 - (b - a) / 25.0 (9.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D                   FLOAT-LONG.
 01 WS-25                  FLOAT-LONG VALUE 25.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-Q                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-R                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-A L-B L-R.
     COMPUTE WS-D = L-B - L-A
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-D WS-25 WS-Q
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-ONE WS-Q L-R
     GOBACK.
 END PROGRAM AQ-SIMILARITY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AQ-PRESSURE.
*> USING job, x, y, z, level A, type A, level B, type B (BINARY-LONG), result out (FLOAT-LONG): 9.2 pressure(x, y, z, sA, sB); the
*> barrier noise is sampled only when needed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FA                  BINARY-LONG.
 01 WS-FB                  BINARY-LONG.
 01 WS-DIFF                BINARY-LONG.
 01 WS-SUM                 BINARY-LONG.
 01 WS-WHICH               BINARY-LONG VALUE 1.
 01 WS-HALF-F              FLOAT-LONG VALUE 0.5.
 01 WS-TWO                 FLOAT-LONG VALUE 2.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-THREE               FLOAT-LONG VALUE 3.
 01 WS-1-5                 FLOAT-LONG VALUE 1.5.
 01 WS-2-5                 FLOAT-LONG VALUE 2.5.
 01 WS-3-0                 FLOAT-LONG VALUE 3.
 01 WS-10                  FLOAT-LONG VALUE 10.
 01 WS-SUMF                FLOAT-LONG.
 01 WS-MID                 FLOAT-LONG.
 01 WS-YF                  FLOAT-LONG.
 01 WS-OFF                 FLOAT-LONG.
 01 WS-HALF                FLOAT-LONG.
 01 WS-DIFFF               FLOAT-LONG.
 01 WS-ABS                 FLOAT-LONG.
 01 WS-K                   FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-Q                   FLOAT-LONG.
 01 WS-BARRIER             FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-LA                   BINARY-LONG.
 01 L-TA                   BINARY-LONG.
 01 L-LB                   BINARY-LONG.
 01 L-TB                   BINARY-LONG.
 01 L-R                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-JOB L-X L-Y L-Z L-LA L-TA L-LB L-TB L-R.
     CALL "AQ-AT" USING L-LA L-TA L-Y WS-FA
     CALL "AQ-AT" USING L-LB L-TB L-Y WS-FB
     IF (WS-FA = 1 AND WS-FB = 2) OR (WS-FA = 2 AND WS-FB = 1)
         MOVE WS-TWO TO L-R
         GOBACK
     END-IF
     COMPUTE WS-DIFF = FUNCTION ABS(L-LA - L-LB)
     IF WS-DIFF = 0
         MOVE WS-ZERO TO L-R
         GOBACK
     END-IF
     COMPUTE WS-SUM = L-LA + L-LB
     MOVE WS-SUM TO WS-SUMF
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-HALF-F WS-SUMF WS-MID
     MOVE L-Y TO WS-YF
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-YF WS-HALF-F WS-T
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-T WS-MID WS-OFF
     MOVE WS-DIFF TO WS-DIFFF
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-DIFFF WS-TWO WS-HALF
     CALL STATIC "cc_f64_abs_f64" USING BY REFERENCE WS-OFF WS-ABS
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-HALF WS-ABS WS-K
     IF WS-OFF > 0
         CALL STATIC "cc_f64_add" USING BY REFERENCE WS-ZERO WS-K WS-V
         IF WS-V > 0
             CALL STATIC "cc_f64_div" USING BY REFERENCE WS-V WS-1-5 WS-Q
         ELSE
             CALL STATIC "cc_f64_div" USING BY REFERENCE WS-V WS-2-5 WS-Q
         END-IF
     ELSE
         CALL STATIC "cc_f64_add" USING BY REFERENCE WS-THREE WS-K WS-V
         IF WS-V > 0
             CALL STATIC "cc_f64_div" USING BY REFERENCE WS-V WS-3-0 WS-Q
         ELSE
             CALL STATIC "cc_f64_div" USING BY REFERENCE WS-V WS-10 WS-Q
         END-IF
     END-IF
     IF WS-Q < -2 OR WS-Q > 2
         MOVE WS-ZERO TO WS-BARRIER
     ELSE
         CALL "AQ-NOISE" USING L-JOB WS-WHICH L-X L-Y L-Z WS-BARRIER
     END-IF
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-BARRIER WS-Q WS-T
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-TWO WS-T L-R
     GOBACK.
 END PROGRAM AQ-PRESSURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AQ-STATUS.
*> USING job, cell index, level out, type out: 9.3 status of a grid cell (computed once) from the cell's centre, which AQ-CENTER has
*> already put in the cell.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OFFSETS.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -2.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE -3.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -2.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -2.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 1.
 01 WS-OFFSET-TABLE REDEFINES WS-OFFSETS.
    05 WS-OFFSET OCCURS 13 TIMES.
       10 WS-OX            BINARY-LONG.
       10 WS-OZ            BINARY-LONG.
 01 WS-GLOBAL-LEVEL        BINARY-LONG.
 01 WS-GLOBAL-TYPE         BINARY-LONG.
 01 WS-MIN-RAW             BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-RAW                 BINARY-LONG.
 01 WS-ADJ                 BINARY-LONG.
 01 WS-CENTRE              BINARY-LONG.
 01 WS-HIGH                BINARY-LONG.
 01 WS-FL                  BINARY-LONG.
 01 WS-FT                  BINARY-LONG.
 01 WS-FLUID               BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-D7                  FLOAT-LONG.
 01 WS-D9                  FLOAT-LONG.
 01 WS-E                   FLOAT-LONG.
 01 WS-E1                  FLOAT-LONG.
 01 WS-E2                  FLOAT-LONG.
 01 WS-W                   FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-LO                  FLOAT-LONG.
 01 WS-HI                  FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-M-ONE               FLOAT-LONG VALUE -1.
 01 WS-64                  FLOAT-LONG VALUE 64.
 01 WS-DEPTH-TERM          FLOAT-LONG.
 01 WS-OP-SUB              BINARY-LONG VALUE 2.
 01 WS-TXT-M03             PIC X(8) VALUE Z"-0.3".
 01 WS-TXT-08              PIC X(8) VALUE Z"0.8".
 01 WS-TXT-M08             PIC X(8) VALUE Z"-0.8".
 01 WS-TXT-04              PIC X(8) VALUE Z"0.4".
 01 WS-TXT-M0225           PIC X(8) VALUE Z"-0.225".
 01 WS-TXT-09              PIC X(8) VALUE Z"0.9".
 01 WS-TXT-03              PIC X(8) VALUE Z"0.3".
 01 WS-C-M03               FLOAT-LONG.
 01 WS-C-08                FLOAT-LONG.
 01 WS-C-M08               FLOAT-LONG.
 01 WS-C-04                FLOAT-LONG.
 01 WS-C-M0225             FLOAT-LONG.
 01 WS-C-09                FLOAT-LONG.
 01 WS-C-03                FLOAT-LONG.
 01 WS-TMP                 FLOAT-LONG.
 01 WS-SETUP               BINARY-LONG VALUE 0.
 01 WS-N10                 FLOAT-LONG VALUE 10.
 01 WS-WHICH               BINARY-LONG.
 01 WS-GX                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-GZ                  BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-N                   FLOAT-LONG.
 01 WS-THREE               FLOAT-LONG VALUE 3.
 01 WS-Q                   FLOAT-LONG.
 01 WS-QI                  BINARY-LONG.
 01 WS-LAVA-ABS            FLOAT-LONG.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 01 L-CELL                 BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-JOB L-CELL L-LEVEL L-TYPE.
     IF J-AQ-STAT(L-CELL) = 1
         MOVE J-AQ-LEVEL(L-CELL) TO L-LEVEL
         MOVE J-AQ-TYPE(L-CELL) TO L-TYPE
         GOBACK
     END-IF
     IF WS-SETUP = 0
         CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-TXT-M03 WS-C-M03
         CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-TXT-08 WS-C-08
         CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-TXT-M08 WS-C-M08
         CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-TXT-04 WS-C-04
         CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-TXT-M0225 WS-C-M0225
         CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-TXT-09 WS-C-09
         CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-TXT-03 WS-C-03
         MOVE WS-C-M0225 TO WS-TMP
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-TMP WS-C-M0225
         MOVE WS-C-09 TO WS-TMP
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-TMP WS-C-09
         MOVE 1 TO WS-SETUP
     END-IF
     CALL "AQ-PICKER" USING J-AQ-PY(L-CELL) WS-GLOBAL-LEVEL WS-GLOBAL-TYPE
     MOVE 999999 TO WS-MIN-RAW
     COMPUTE WS-ABOVE = J-AQ-PY(L-CELL) + 12
     COMPUTE WS-BELOW = J-AQ-PY(L-CELL) - 12
     MOVE 0 TO WS-FLAG WS-DONE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 13 OR WS-DONE = 1
         COMPUTE WS-BX = J-AQ-PX(L-CELL) + WS-OX(WS-I) * 16
         COMPUTE WS-BZ = J-AQ-PZ(L-CELL) + WS-OZ(WS-I) * 16
         CALL "AQ-SURFACE-LEVEL" USING L-JOB WS-BX WS-BZ WS-RAW
         COMPUTE WS-ADJ = WS-RAW + 8
         MOVE 0 TO WS-CENTRE
         IF WS-OX(WS-I) = 0 AND WS-OZ(WS-I) = 0
             MOVE 1 TO WS-CENTRE
         END-IF
         IF WS-CENTRE = 1 AND WS-BELOW > WS-ADJ
             MOVE WS-GLOBAL-LEVEL TO L-LEVEL
             MOVE WS-GLOBAL-TYPE TO L-TYPE
             MOVE 1 TO WS-DONE
         END-IF
         IF WS-DONE = 0
             MOVE 0 TO WS-HIGH
             IF WS-ABOVE > WS-ADJ
                 MOVE 1 TO WS-HIGH
             END-IF
             IF WS-HIGH = 1 OR WS-CENTRE = 1
                 CALL "AQ-PICKER" USING WS-ADJ WS-FL WS-FT
                 CALL "AQ-AT" USING WS-FL WS-FT WS-ADJ WS-FLUID
                 IF WS-FLUID NOT = 0
                     IF WS-CENTRE = 1
                         MOVE 1 TO WS-FLAG
                     END-IF
                     IF WS-HIGH = 1
                         MOVE WS-FL TO L-LEVEL
                         MOVE WS-FT TO L-TYPE
                         MOVE 1 TO WS-DONE
                     END-IF
                 END-IF
             END-IF
         END-IF
         IF WS-DONE = 0 AND WS-RAW < WS-MIN-RAW
             MOVE WS-RAW TO WS-MIN-RAW
         END-IF
     END-PERFORM
     IF WS-DONE = 0
*>       computeSurfaceLevel (9.3): the exclusion zone, the flooded and spread terms, then the level
         MOVE WS-ZERO TO WS-E1
         MOVE WS-ZERO TO WS-E2
         IF J-AQ-ROOT-ERO > 0
             CALL "DENSITY-NODE" USING J-AQ-ROOT-ERO J-AQ-PX(L-CELL) J-AQ-PY(L-CELL) J-AQ-PZ(L-CELL) WS-E1
         END-IF
         IF J-AQ-ROOT-DEP > 0
             CALL "DENSITY-NODE" USING J-AQ-ROOT-DEP J-AQ-PX(L-CELL) J-AQ-PY(L-CELL) J-AQ-PZ(L-CELL) WS-E2
         END-IF
         CALL "DENSITY-F32" USING WS-OP-SUB WS-C-M0225 WS-E1 WS-T
         CALL "DENSITY-F32" USING WS-OP-SUB WS-E2 WS-C-09 WS-U
         IF WS-U < 0
             MOVE WS-ZERO TO WS-U
         END-IF
         IF WS-U < WS-T
             MOVE WS-U TO WS-E
         ELSE
             MOVE WS-T TO WS-E
         END-IF
         IF WS-E > 0
             MOVE WS-M-ONE TO WS-D7
             MOVE WS-M-ONE TO WS-D9
         ELSE
             COMPUTE WS-DEPTH-TERM = (WS-MIN-RAW + 8) - J-AQ-PY(L-CELL)
             MOVE WS-ZERO TO WS-W
             IF WS-FLAG = 1
                 CALL STATIC "cc_f64_div" USING BY REFERENCE WS-DEPTH-TERM WS-64 WS-T
                 CALL STATIC "cc_f64_clamp_f64" USING BY REFERENCE WS-T WS-ZERO WS-ONE WS-U
                 CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-ZERO WS-ONE WS-V
                 CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-U WS-V WS-T
                 CALL STATIC "cc_f64_add" USING BY REFERENCE WS-ONE WS-T WS-W
             END-IF
             MOVE 2 TO WS-WHICH
             CALL "AQ-NOISE" USING L-JOB WS-WHICH J-AQ-PX(L-CELL) J-AQ-PY(L-CELL) J-AQ-PZ(L-CELL) WS-F
             CALL STATIC "cc_f64_clamp_f64" USING BY REFERENCE WS-F WS-M-ONE WS-ONE WS-T
             MOVE WS-T TO WS-F
*>           lo = map(w, 1, 0, -0.3, 0.8): t = (w - 1) / (0 - 1), lo = -0.3 + t * (0.8 - -0.3); hi likewise with -0.8, 0.4
             CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-W WS-ONE WS-T
             CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-ZERO WS-ONE WS-U
             CALL STATIC "cc_f64_div" USING BY REFERENCE WS-T WS-U WS-Q
             CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-C-08 WS-C-M03 WS-U
             CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-Q WS-U WS-T
             CALL STATIC "cc_f64_add" USING BY REFERENCE WS-C-M03 WS-T WS-LO
             CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-C-04 WS-C-M08 WS-U
             CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-Q WS-U WS-T
             CALL STATIC "cc_f64_add" USING BY REFERENCE WS-C-M08 WS-T WS-HI
             CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-F WS-HI WS-D7
             CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-F WS-LO WS-D9
         END-IF
         EVALUATE TRUE
             WHEN WS-D9 > 0
                 MOVE WS-GLOBAL-LEVEL TO WS-LEVEL
             WHEN WS-D7 > 0
*>               randomizedLevel: base + quantize(spread * 10, 3), at most the smallest raw level
                 COMPUTE WS-GX = FUNCTION INTEGER(J-AQ-PX(L-CELL) / 16)
                 COMPUTE WS-GY = FUNCTION INTEGER(J-AQ-PY(L-CELL) / 40)
                 COMPUTE WS-GZ = FUNCTION INTEGER(J-AQ-PZ(L-CELL) / 16)
                 COMPUTE WS-BASE = WS-GY * 40 + 20
                 MOVE 3 TO WS-WHICH
                 CALL "AQ-NOISE" USING L-JOB WS-WHICH WS-GX WS-GY WS-GZ WS-N
                 CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-N WS-N10 WS-T
                 CALL STATIC "cc_f64_div" USING BY REFERENCE WS-T WS-THREE WS-U
                 CALL STATIC "cc_f64_floor" USING BY REFERENCE WS-U WS-V
                 CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-V WS-QI
                 COMPUTE WS-LEVEL = WS-BASE + WS-QI * 3
                 IF WS-MIN-RAW < WS-LEVEL
                     MOVE WS-MIN-RAW TO WS-LEVEL
                 END-IF
             WHEN OTHER
                 MOVE -32512 TO WS-LEVEL
         END-EVALUATE
         MOVE WS-LEVEL TO L-LEVEL
         MOVE WS-GLOBAL-TYPE TO L-TYPE
         IF WS-LEVEL <= -10 AND WS-LEVEL NOT = -32512 AND WS-GLOBAL-TYPE NOT = 2
             COMPUTE WS-GX = FUNCTION INTEGER(J-AQ-PX(L-CELL) / 64)
             COMPUTE WS-GY = FUNCTION INTEGER(J-AQ-PY(L-CELL) / 40)
             COMPUTE WS-GZ = FUNCTION INTEGER(J-AQ-PZ(L-CELL) / 64)
             MOVE 4 TO WS-WHICH
             CALL "AQ-NOISE" USING L-JOB WS-WHICH WS-GX WS-GY WS-GZ WS-F
             CALL STATIC "cc_f64_abs_f64" USING BY REFERENCE WS-F WS-LAVA-ABS
             IF WS-LAVA-ABS > WS-C-03
                 MOVE 2 TO L-TYPE
             END-IF
         END-IF
     END-IF
     MOVE 1 TO J-AQ-STAT(L-CELL)
     MOVE L-LEVEL TO J-AQ-LEVEL(L-CELL)
     MOVE L-TYPE TO J-AQ-TYPE(L-CELL)
     GOBACK.
 END PROGRAM AQ-STATUS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AQ-CENTER.
*> USING job, cell x, cell y, cell z (the grid indices), cell index out: the cell's index in the job's table (cell x - (chunk x - 1)) * 105 +
*> (cell z - (chunk z - 1)) * 35 + cell y + 7 + 1, with its centre computed on first use (9.2 step 4): R = P_aquifer.at(cell), then
*> px = (cx << 4) + R.nextInt(10), py = cy * 12 + R.nextInt(9), pz = (cz << 4) + R.nextInt(10), the draws in that order.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-FAC== LEADING ==XR-== BY ==WS-F-==.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-RND== LEADING ==XR-== BY ==WS-R-==.
 01 WS-BOUND-X             BINARY-LONG VALUE 10.
 01 WS-BOUND-Y             BINARY-LONG VALUE 9.
 01 WS-DRAW                BINARY-LONG.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 01 L-CX                   BINARY-LONG.
 01 L-CY                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-JOB L-CX L-CY L-CZ L-INDEX.
     COMPUTE L-INDEX = (L-CX - (J-CX - 1)) * 105 + (L-CZ - (J-CZ - 1)) * 35 + L-CY + 7 + 1
     IF J-AQ-HAVE(L-INDEX) = 1
         GOBACK
     END-IF
     MOVE J-AQ-FLO TO WS-F-LO
     MOVE J-AQ-FHI TO WS-F-HI
     CALL "XORO-AT" USING WS-FAC L-CX L-CY L-CZ WS-RND
     CALL "XORO-NEXT-INT" USING WS-RND WS-BOUND-X WS-DRAW
     COMPUTE J-AQ-PX(L-INDEX) = L-CX * 16 + WS-DRAW
     CALL "XORO-NEXT-INT" USING WS-RND WS-BOUND-Y WS-DRAW
     COMPUTE J-AQ-PY(L-INDEX) = L-CY * 12 + WS-DRAW
     CALL "XORO-NEXT-INT" USING WS-RND WS-BOUND-X WS-DRAW
     COMPUTE J-AQ-PZ(L-INDEX) = L-CZ * 16 + WS-DRAW
     MOVE 1 TO J-AQ-HAVE(L-INDEX)
     GOBACK.
 END PROGRAM AQ-CENTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AQUIFER-SUBSTANCE.
*> USING job, x, y, z (BINARY-LONG), density (FLOAT-LONG, 0 or less: the caller has handled the solid case), kind out (BINARY-LONG:
*> 0 none = the default block, 1 air, 2 water, 3 lava): computeSubstance of 9.2 from step 2 on.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-GL                  BINARY-LONG.
 01 WS-GT                  BINARY-LONG.
 01 WS-FLUID               BINARY-LONG.
 01 WS-GX0                 BINARY-LONG.
 01 WS-GY0                 BINARY-LONG.
 01 WS-GZ0                 BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-CIDX                BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-DIST                BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-NEAR.
    05 WS-NEAR-ENTRY OCCURS 4 TIMES.
       10 WS-ND            BINARY-LONG.
       10 WS-NC            BINARY-LONG.
 01 WS-D1                  BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 01 WS-D3                  BINARY-LONG.
 01 WS-L1                  BINARY-LONG.
 01 WS-T1                  BINARY-LONG.
 01 WS-L2                  BINARY-LONG.
 01 WS-T2                  BINARY-LONG.
 01 WS-L3                  BINARY-LONG.
 01 WS-T3                  BINARY-LONG.
 01 WS-YM1                 BINARY-LONG.
 01 WS-SIM12               FLOAT-LONG.
 01 WS-SIM13               FLOAT-LONG.
 01 WS-SIM23               FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 01 WS-P12                 FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-D                    FLOAT-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-JOB L-X L-Y L-Z L-D L-KIND.
     CALL "AQ-PICKER" USING L-Y WS-GL WS-GT
     CALL "AQ-AT" USING WS-GL WS-GT L-Y WS-FLUID
     IF J-AQ-READY = 0 OR L-Y > J-AQ-SKIP-Y OR WS-FLUID = 2
         CALL "AQ-KIND" USING WS-FLUID L-KIND
         GOBACK
     END-IF
*>   the four nearest centres, nearest first; a newer candidate goes before an equal one
     COMPUTE WS-GX0 = FUNCTION INTEGER((L-X - 5) / 16)
     COMPUTE WS-GY0 = FUNCTION INTEGER((L-Y + 1) / 12)
     COMPUTE WS-GZ0 = FUNCTION INTEGER((L-Z - 5) / 16)
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         MOVE 999999999 TO WS-ND(WS-K)
         MOVE 0 TO WS-NC(WS-K)
     END-PERFORM
     PERFORM VARYING WS-DX FROM 0 BY 1 UNTIL WS-DX > 1
         PERFORM VARYING WS-DY FROM -1 BY 1 UNTIL WS-DY > 1
             PERFORM VARYING WS-DZ FROM 0 BY 1 UNTIL WS-DZ > 1
                 COMPUTE WS-A = WS-GX0 + WS-DX
                 COMPUTE WS-B = WS-GY0 + WS-DY
                 COMPUTE WS-J = WS-GZ0 + WS-DZ
                 CALL "AQ-CENTER" USING L-JOB WS-A WS-B WS-J WS-CIDX
                 COMPUTE WS-DIST = (J-AQ-PX(WS-CIDX) - L-X) * (J-AQ-PX(WS-CIDX) - L-X)
                     + (J-AQ-PY(WS-CIDX) - L-Y) * (J-AQ-PY(WS-CIDX) - L-Y)
                     + (J-AQ-PZ(WS-CIDX) - L-Z) * (J-AQ-PZ(WS-CIDX) - L-Z)
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                     IF WS-DIST <= WS-ND(WS-K)
                         PERFORM VARYING WS-J FROM 4 BY -1 UNTIL WS-J <= WS-K
                             MOVE WS-NEAR-ENTRY(WS-J - 1) TO WS-NEAR-ENTRY(WS-J)
                         END-PERFORM
                         MOVE WS-DIST TO WS-ND(WS-K)
                         MOVE WS-CIDX TO WS-NC(WS-K)
                         MOVE 5 TO WS-K
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE WS-ND(1) TO WS-D1
     MOVE WS-ND(2) TO WS-D2
     MOVE WS-ND(3) TO WS-D3
     CALL "AQ-STATUS" USING L-JOB WS-NC(1) WS-L1 WS-T1
     CALL "AQ-SIMILARITY" USING WS-D1 WS-D2 WS-SIM12
     CALL "AQ-AT" USING WS-L1 WS-T1 L-Y WS-BLOCK
     CALL "AQ-STATUS" USING L-JOB WS-NC(2) WS-L2 WS-T2
     IF WS-SIM12 <= 0
         MOVE WS-BLOCK TO WS-FLUID
         CALL "AQ-KIND" USING WS-FLUID L-KIND
         GOBACK
     END-IF
     COMPUTE WS-YM1 = L-Y - 1
     CALL "AQ-PICKER" USING WS-YM1 WS-GL WS-GT
     CALL "AQ-AT" USING WS-GL WS-GT WS-YM1 WS-FLUID
     IF WS-BLOCK = 1 AND WS-FLUID = 2
         MOVE WS-BLOCK TO WS-FLUID
         CALL "AQ-KIND" USING WS-FLUID L-KIND
         GOBACK
     END-IF
     CALL "AQ-PRESSURE" USING L-JOB L-X L-Y L-Z WS-L1 WS-T1 WS-L2 WS-T2 WS-P
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-SIM12 WS-P WS-P12
     CALL STATIC "cc_f64_add" USING BY REFERENCE L-D WS-P12 WS-S
     IF WS-S > 0
         MOVE 0 TO L-KIND
         GOBACK
     END-IF
     CALL "AQ-STATUS" USING L-JOB WS-NC(3) WS-L3 WS-T3
     CALL "AQ-SIMILARITY" USING WS-D1 WS-D3 WS-SIM13
     IF WS-SIM13 > 0
         CALL "AQ-PRESSURE" USING L-JOB L-X L-Y L-Z WS-L1 WS-T1 WS-L3 WS-T3 WS-P
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-SIM12 WS-SIM13 WS-U
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-U WS-P WS-P12
         CALL STATIC "cc_f64_add" USING BY REFERENCE L-D WS-P12 WS-S
         IF WS-S > 0
             MOVE 0 TO L-KIND
             GOBACK
         END-IF
     END-IF
     CALL "AQ-SIMILARITY" USING WS-D2 WS-D3 WS-SIM23
     IF WS-SIM23 > 0
         CALL "AQ-PRESSURE" USING L-JOB L-X L-Y L-Z WS-L2 WS-T2 WS-L3 WS-T3 WS-P
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-SIM12 WS-SIM23 WS-U
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-U WS-P WS-P12
         CALL STATIC "cc_f64_add" USING BY REFERENCE L-D WS-P12 WS-S
         IF WS-S > 0
             MOVE 0 TO L-KIND
             GOBACK
         END-IF
     END-IF
     MOVE WS-BLOCK TO WS-FLUID
     CALL "AQ-KIND" USING WS-FLUID L-KIND
     GOBACK.

 END PROGRAM AQUIFER-SUBSTANCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AQ-KIND.
*> USING fluid (0 air, 1 water, 2 lava), kind out (1 air, 2 water, 3 lava): the substance kind of a fluid.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FLUID                BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-FLUID L-KIND.
     EVALUATE L-FLUID
         WHEN 1
             MOVE 2 TO L-KIND
         WHEN 2
             MOVE 3 TO L-KIND
         WHEN OTHER
             MOVE 1 TO L-KIND
     END-EVALUATE
     GOBACK.
 END PROGRAM AQ-KIND.
