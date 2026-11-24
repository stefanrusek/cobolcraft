*> Test of 29b part 4 section 13, Hanging and root blocks (core/src/growth-29b-4.cob; T0605): hanging roots (13.1), spore blossom (13.2), pale hanging moss (13.3), mangrove roots (13.4), worked example 12.
*> A case loads its inputs from a text of numbers (LOAD-IN fills WS-I as integers and WS-FX as doubles), calls the program
*> and shows the outputs WS-R(1..WS-N) joined by "/", one group per call; expected values come from the rules and tables of the section.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GROWTH-29B-4-13.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY INTERACT.
 01 WS-ISG.
    05 WS-I1 BINARY-LONG.
    05 WS-I2 BINARY-LONG.
    05 WS-I3 BINARY-LONG.
    05 WS-I4 BINARY-LONG.
    05 WS-I5 BINARY-LONG.
    05 WS-I6 BINARY-LONG.
    05 WS-I7 BINARY-LONG.
    05 WS-I8 BINARY-LONG.
    05 WS-I9 BINARY-LONG.
    05 WS-I10 BINARY-LONG.
    05 WS-I11 BINARY-LONG.
    05 WS-I12 BINARY-LONG.
    05 WS-I13 BINARY-LONG.
    05 WS-I14 BINARY-LONG.
    05 WS-I15 BINARY-LONG.
    05 WS-I16 BINARY-LONG.
 01 WS-IST REDEFINES WS-ISG.
    05 WS-I BINARY-LONG OCCURS 16 TIMES.
 01 WS-FXSG.
    05 WS-FX1 FLOAT-LONG.
    05 WS-FX2 FLOAT-LONG.
    05 WS-FX3 FLOAT-LONG.
    05 WS-FX4 FLOAT-LONG.
    05 WS-FX5 FLOAT-LONG.
    05 WS-FX6 FLOAT-LONG.
    05 WS-FX7 FLOAT-LONG.
    05 WS-FX8 FLOAT-LONG.
    05 WS-FX9 FLOAT-LONG.
    05 WS-FX10 FLOAT-LONG.
    05 WS-FX11 FLOAT-LONG.
    05 WS-FX12 FLOAT-LONG.
    05 WS-FX13 FLOAT-LONG.
    05 WS-FX14 FLOAT-LONG.
    05 WS-FX15 FLOAT-LONG.
    05 WS-FX16 FLOAT-LONG.
 01 WS-FXST REDEFINES WS-FXSG.
    05 WS-FX FLOAT-LONG OCCURS 16 TIMES.
 01 WS-RSG.
    05 WS-R1 BINARY-LONG.
    05 WS-R2 BINARY-LONG.
    05 WS-R3 BINARY-LONG.
    05 WS-R4 BINARY-LONG.
    05 WS-R5 BINARY-LONG.
    05 WS-R6 BINARY-LONG.
    05 WS-R7 BINARY-LONG.
    05 WS-R8 BINARY-LONG.
    05 WS-R9 BINARY-LONG.
    05 WS-R10 BINARY-LONG.
    05 WS-R11 BINARY-LONG.
    05 WS-R12 BINARY-LONG.
    05 WS-R13 BINARY-LONG.
    05 WS-R14 BINARY-LONG.
    05 WS-R15 BINARY-LONG.
    05 WS-R16 BINARY-LONG.
 01 WS-RST REDEFINES WS-RSG.
    05 WS-R BINARY-LONG OCCURS 16 TIMES.
 01 WS-RFSG.
    05 WS-RF1 FLOAT-LONG.
    05 WS-RF2 FLOAT-LONG.
    05 WS-RF3 FLOAT-LONG.
    05 WS-RF4 FLOAT-LONG.
    05 WS-RF5 FLOAT-LONG.
    05 WS-RF6 FLOAT-LONG.
    05 WS-RF7 FLOAT-LONG.
    05 WS-RF8 FLOAT-LONG.
 01 WS-RFST REDEFINES WS-RFSG.
    05 WS-RF FLOAT-LONG OCCURS 8 TIMES.
 01 WS-IN                  PIC X(160).
 01 WS-TOK                 PIC X(24).
 01 WS-P                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-SHOW                PIC -(9)9.
 01 WS-TEXTS.
    05 WS-T1               PIC X(96).
    05 WS-T2               PIC X(96).
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 29b-4§13 Hanging and root blocks: hanging roots survival (13.1 step 1): the state above has a sturdy face toward DOWN (sturdy) (survives)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-ROOTS-SURVIVE" USING WS-I1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-ROOTS-SURVIVE" USING WS-I1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§13 Hanging and root blocks: hanging roots shape update (13.1 step 2): from UP air when it cannot survive; a water tick when waterlogged (direction 2 up, survive," TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "2 0 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-ROOTS-SU" USING WS-I1 WS-I2 WS-I3 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "2 1 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-ROOTS-SU" USING WS-I1 WS-I2 WS-I3 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "2 1 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-ROOTS-SU" USING WS-I1 WS-I2 WS-I3 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "3 0 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-ROOTS-SU" USING WS-I1 WS-I2 WS-I3 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "3 1 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-ROOTS-SU" USING WS-I1 WS-I2 WS-I3 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "1/0 0/1 0/0 0/1 0/0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§13 Hanging and root blocks: hanging roots placement and constants (13.1): waterlogged is a water source at the clicked position (source) (waterlogged); shape 12 wide from" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-ROOTS-PLACE" USING WS-I1 WS-R1 WS-R2 WS-R3 WS-R4
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-ROOTS-PLACE" USING WS-I1 WS-R1 WS-R2 WS-R3 WS-R4
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE "1/12/10/16 0/12/10/16" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§13 Hanging and root blocks: hanging roots constants (13.1): offset type XZ (1), bone meal on the block itself (0)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-ROOTS-CONST" USING  WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "1/0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§13 Hanging and root blocks: spore blossom survival (13.2): canSupportCenter above toward DOWN and the cell is not water (center support above, isWaterAt) (survives)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "1 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-SPORE-SURVIVE" USING WS-I1 WS-I2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-SPORE-SURVIVE" USING WS-I1 WS-I2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-SPORE-SURVIVE" USING WS-I1 WS-I2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-SPORE-SURVIVE" USING WS-I1 WS-I2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§13 Hanging and root blocks: spore blossom shape update (13.2): from UP air when it cannot survive, else the default (direction 2 up, survive) (air)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "2 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-SPORE-SU" USING WS-I1 WS-I2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-SPORE-SU" USING WS-I1 WS-I2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-SPORE-SU" USING WS-I1 WS-I2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-SPORE-SU" USING WS-I1 WS-I2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§13 Hanging and root blocks: spore blossom shape (13.2): column 12 wide from 13 to 16" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-SPORE-CONST" USING  WS-R1 WS-R2 WS-R3
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE "12/13/16" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§13 Hanging and root blocks: pale hanging moss constants (13.3): tip default true (1), base shape 14 wide 0 to 16, tip shape 14 wide 2 to 16 (default tip, base y from, tip y" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-MOSS-CONST" USING  WS-R1 WS-R2 WS-R3
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE "1/0/2" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§13 Hanging and root blocks: pale hanging moss canStayAtPosition (13.3 step 1): the block above can be attached to by its bottom face, or is pale_hanging_moss (attachable," TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "1 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-MOSS-STAY" USING WS-I1 WS-I2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-MOSS-STAY" USING WS-I1 WS-I2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-MOSS-STAY" USING WS-I1 WS-I2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-MOSS-STAY" USING WS-I1 WS-I2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1 1 0 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§13 Hanging and root blocks: pale hanging moss shape update (13.3 step 2, example 12): a block tick when it cannot stay (delay 1); the state takes tip = not (the state below" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "1 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-MOSS-SU" USING WS-I1 WS-I2 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "1 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-MOSS-SU" USING WS-I1 WS-I2 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-MOSS-SU" USING WS-I1 WS-I2 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-MOSS-SU" USING WS-I1 WS-I2 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0/1 0/0 1/1 1/0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§13 Hanging and root blocks: pale hanging moss getTip (13.3 step 3): from pos move DOWN over moss; the tip is the last moss cell (moss cells from pos downward including pos)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-MOSS-TIP" USING WS-I1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-MOSS-TIP" USING WS-I1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "5" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-MOSS-TIP" USING WS-I1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 -2 -4" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§13 Hanging and root blocks: pale hanging moss bone meal (13.3 step 4, example 12): valid when the cell below the tip is air and inside the build height; success always;" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "1 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-MOSS-BONE" USING WS-I1 WS-I2 WS-R1 WS-R2 WS-R3 WS-R4
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE "1 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-MOSS-BONE" USING WS-I1 WS-I2 WS-R1 WS-R2 WS-R3 WS-R4
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE "0 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-MOSS-BONE" USING WS-I1 WS-I2 WS-R1 WS-R2 WS-R3 WS-R4
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE "1/1/1/3 0/1/0/3 0/1/0/3" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-4§13 Hanging and root blocks: mangrove roots (13.4): placement waterlogged is a water source at the clicked position; the shape update schedules a water tick when" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "1 1 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-MROOTS-RULES" USING WS-I1 WS-I2 WS-I3 WS-I4 WS-R1 WS-R2 WS-R3 WS-R4
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 1 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-MROOTS-RULES" USING WS-I1 WS-I2 WS-I3 WS-I4 WS-R1 WS-R2 WS-R3 WS-R4
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE "1 0 1 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-MROOTS-RULES" USING WS-I1 WS-I2 WS-I3 WS-I4 WS-R1 WS-R2 WS-R3 WS-R4
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE "0 1 0 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-MROOTS-RULES" USING WS-I1 WS-I2 WS-I3 WS-I4 WS-R1 WS-R2 WS-R3 WS-R4
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GC4-MROOTS-RULES" USING WS-I1 WS-I2 WS-I3 WS-I4 WS-R1 WS-R2 WS-R3 WS-R4
     MOVE 4 TO WS-N
     PERFORM ADD-N
     MOVE "1/1/1/0 0/0/0/1 0/1/1/0 1/0/0/0 0/0/0/0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 BEGIN-CASE.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     .

 LOAD-IN.
     MOVE 1 TO WS-P
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 16
         MOVE SPACES TO WS-TOK
         IF WS-P <= 160
             UNSTRING WS-IN DELIMITED BY ALL SPACE INTO WS-TOK WITH POINTER WS-P
         END-IF
         COMPUTE WS-FX(WS-K) = FUNCTION NUMVAL(WS-TOK)
         COMPUTE WS-I(WS-K) = FUNCTION NUMVAL(WS-TOK)
     END-PERFORM
     .

 ADD-N.
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-N
         MOVE WS-R(WS-J) TO WS-SHOW
         IF WS-J > 1
             STRING "/" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
         STRING FUNCTION TRIM(WS-SHOW) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-PERFORM
     STRING " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     .

 ADD-TEXT.
     STRING FUNCTION TRIM(WS-T1) "|" FUNCTION TRIM(WS-T2) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     .
 END PROGRAM TEST-GROWTH-29B-4-13.
