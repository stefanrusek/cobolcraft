*> Real-data test (skipped as a pass without the generated packs; docs/protocol/36-structures-3-jigsaw-assembly.md section 14, the piece PoolElementStructurePiece): on whole assemblies (world seed
*> 12345, the synthetic surface of TJ-SURFACE: the plains village, the pillager outpost, the ancient city and the trial chambers) every piece has the fields of 14.1 (a jigsaw piece of type 60
*> with a real element, its origin, rotation and the structure's liquid settings) and the box 14.2 recomputes on loading (the element's box at the piece's origin and rotation) is the stored box:
*> equal in x, z and at the bottom, and equal at the top except where the expansion hack made the stored one taller. NOT built: the NBT form of the piece (14.2: PosX..Z, ground_level_delta,
*> pool_element, rotation, junctions, liquid_settings), pieces are rebuilt from the world seed and the chunk, never saved.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-3-14.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 COPY STRUCTTPL.
 COPY STRUCTJIG.
 COPY JIGTEST.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-M1                  BINARY-LONG VALUE 0.
 01 WS-M2                  BINARY-LONG VALUE 0.
 01 WS-M3                  BINARY-LONG VALUE 0.
 01 WS-M4                  BINARY-LONG VALUE 0.
 01 WS-STRUCT              BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-PAR                 BINARY-LONG.
 01 WS-CHD                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-NAME                PIC X(40).
 01 WS-LABEL               PIC X(40).
 01 WS-CASE-TAB.
    05 FILLER PIC X(24) VALUE "village_plains".
    05 FILLER BINARY-LONG VALUE 5.
    05 FILLER BINARY-LONG VALUE 7.
    05 FILLER PIC X(24) VALUE "pillager_outpost".
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-LONG VALUE -2.
    05 FILLER PIC X(24) VALUE "ancient_city".
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-LONG VALUE 4.
    05 FILLER PIC X(24) VALUE "trial_chambers".
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
 01 WS-CASES REDEFINES WS-CASE-TAB.
    05 WC-REC OCCURS 4 TIMES.
       10 WC-NAME          PIC X(24).
       10 WC-CX            BINARY-LONG.
       10 WC-CZ            BINARY-LONG.
 01 WS-BOX.
    05 WS-B                BINARY-LONG OCCURS 6 TIMES.
 01 WS-PIECES-TOTAL        BINARY-LONG.
 01 WS-BAD-FIELD           BINARY-LONG.
 01 WS-BAD-BOX             BINARY-LONG.
 01 WS-BAD-LIQ             BINARY-LONG.
 01 WS-BAD-NAMEPOS         BINARY-LONG.
 01 WS-WANT-LIQ            BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "acceptance US12 36-3§14 The piece: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "GEN-WORLD-SETUP"
     CALL "JIG-RESET"
     MOVE 1 TO TJ-SURFACE
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         MOVE SPACES TO WS-NAME
         STRING "minecraft:" FUNCTION TRIM(WC-NAME(WS-K)) DELIMITED BY SIZE INTO WS-NAME
         MOVE 0 TO WS-STRUCT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
             IF SDT-KEY(WS-I) = WS-NAME
                 MOVE WS-I TO WS-STRUCT
             END-IF
         END-PERFORM
         MOVE WC-CX(WS-K) TO WS-CX
         MOVE WC-CZ(WS-K) TO WS-CZ
         CALL "STRUCT-FIND-POINT" USING WS-STRUCT CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
         MOVE WC-NAME(WS-K) TO WS-LABEL
         MOVE 0 TO WS-BAD-FIELD WS-BAD-BOX WS-BAD-LIQ
         MOVE SDT-JIG-LIQ(WS-STRUCT) TO WS-WANT-LIQ
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SP-COUNT
*>           14.1: the piece type, the element, the liquid settings of the structure
             IF SP-TYPE(WS-I) NOT = 60 OR SP-F1(WS-I) < 2
                 ADD 1 TO WS-BAD-FIELD
             END-IF
             IF SP-T-LIQ(WS-I) NOT = WS-WANT-LIQ
                 ADD 1 TO WS-BAD-LIQ
             END-IF
*>           14.2: the box recomputed from the element, the position and the rotation is the stored box, except where the expansion hack made the stored one taller (a list and a feature element take the same recomputation)
             MOVE SP-F1(WS-I) TO WS-ROW
             CALL "JIG-EL-BOX" USING WS-ROW SP-T-X(WS-I) SP-T-Y(WS-I) SP-T-Z(WS-I) SP-T-ROT(WS-I) WS-BOX
             IF WS-B(1) NOT = SP-X0(WS-I) OR WS-B(3) NOT = SP-Z0(WS-I) OR WS-B(4) NOT = SP-X1(WS-I) OR WS-B(6) NOT = SP-Z1(WS-I)
                 ADD 1 TO WS-BAD-BOX
             END-IF
             IF WS-B(2) NOT = SP-Y0(WS-I) OR WS-B(5) > SP-Y1(WS-I)
                 ADD 1 TO WS-BAD-BOX
             END-IF
             IF SDT-JIG-HACK(WS-STRUCT) = 0 AND WS-B(5) NOT = SP-Y1(WS-I)
                 ADD 1 TO WS-BAD-BOX
             END-IF
         END-PERFORM
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-3§14.1 " FUNCTION TRIM(WS-LABEL) ": every piece is a jigsaw piece (type 60) of a real element"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE SP-COUNT TO TL-EXPECTED-N
         COMPUTE TL-OBSERVED-N = SP-COUNT - WS-BAD-FIELD
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-3§14.1 " FUNCTION TRIM(WS-LABEL) ": every piece carries the structure's liquid settings (ignore_waterlogging only for the trial chambers)"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO TL-EXPECTED-N
         MOVE WS-BAD-LIQ TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-3§14.2 " FUNCTION TRIM(WS-LABEL) ": the box recomputed from the element, position and rotation is the stored one (x, z, bottom; the top only differs under the expansion hack)"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO TL-EXPECTED-N
         MOVE WS-BAD-BOX TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     MOVE 0 TO TJ-SURFACE
     STOP RUN.
 END PROGRAM TEST-STRUCT-36-3-14.

 COPY JIGSEAM.

 COPY NOSPAWN.
 COPY CORETEST.
