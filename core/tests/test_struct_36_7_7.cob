*> Acceptance test of the woodland mansion piece class (docs/protocol/36-structures-7-woodland-mansion.md section 7; core/src/struct-man-start.cob MAN-PIECES; T13503): on the generated vanilla-data
*> (CC_GENERATED_DIR, read only; passes as skipped without it) the pieces of a start are template pieces of woodland_mansion/<name> with the placer's position, rotation and mirror, generation depth 0,
*> pivot (0, 0, 0), one shared processor list (ignore_structure_block) and the template's box turned by the rotation.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-7-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTPIECE.
 COPY STRUCTMAN.
 COPY STRUCTDATA.
 COPY STRUCTTPL.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-KEY                 PIC X(80).
 01 WS-ON                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TRIES               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-ID                  PIC X(96).
 01 WS-ROW                 BINARY-LONG.
 01 WS-BAD2                BINARY-LONG.
 01 WS-BAD3                BINARY-LONG.
 01 WS-BAD4                BINARY-LONG.
 01 WS-PROC1               BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-ED                  PIC -(9)9.
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
         MOVE "acceptance US12 36-7§7 The piece class: no generated packs here, skipped" TO TL-CASE
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
     MOVE "minecraft:mansion" TO WS-KEY
     CALL "STRUCT-GATE" USING WS-KEY WS-ON
     MOVE CW-SEED TO WS-SEED
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-CX FROM 0 BY 7 UNTIL WS-CX > 700 OR WS-FOUND = 1
         MOVE 40 TO WS-CZ
         CALL "MAN-FIND-POINT" USING WS-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
         IF WS-VALID = 1
             MOVE 1 TO WS-FOUND
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-7§7 The piece class: a start was found" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-FOUND = 0
         STOP RUN
     END-IF
     MOVE 0 TO WS-BAD
     MOVE 0 TO WS-BAD2
     MOVE 0 TO WS-BAD3
     MOVE 0 TO WS-BAD4
     MOVE SP-T-PROC(1) TO WS-PROC1
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SP-COUNT
         MOVE SPACES TO WS-ID
         STRING "minecraft:woodland_mansion/" FUNCTION TRIM(ME-NAME(WS-I)) DELIMITED BY SIZE INTO WS-ID
         MOVE SP-T-ROW(WS-I) TO WS-ROW
         IF TP-KEY(WS-ROW) NOT = WS-ID
             ADD 1 TO WS-BAD
         END-IF
         IF SP-T-ROT(WS-I) NOT = ME-ROT(WS-I) OR SP-T-MIR(WS-I) NOT = ME-MIR(WS-I) OR SP-T-X(WS-I) NOT = ME-X(WS-I)
             OR SP-T-Y(WS-I) NOT = ME-Y(WS-I) OR SP-T-Z(WS-I) NOT = ME-Z(WS-I)
             ADD 1 TO WS-BAD2
         END-IF
         IF SP-T-PIV-X(WS-I) NOT = 0 OR SP-T-PIV-Y(WS-I) NOT = 0 OR SP-T-PIV-Z(WS-I) NOT = 0 OR SP-T-PROC(WS-I) NOT = WS-PROC1
             OR WS-PROC1 = 0 OR SP-T-KIND(WS-I) NOT = 5 OR SP-DEPTH(WS-I) NOT = 0
             ADD 1 TO WS-BAD3
         END-IF
*>       the box is the template box (section 2.1): an odd rotation swaps x and z
         MOVE SP-T-ROT(WS-I) TO WS-R
         COMPUTE WS-SX = SP-X1(WS-I) - SP-X0(WS-I) + 1
         COMPUTE WS-SZ = SP-Z1(WS-I) - SP-Z0(WS-I) + 1
         COMPUTE WS-SY = SP-Y1(WS-I) - SP-Y0(WS-I) + 1
         IF FUNCTION MOD(WS-R, 2) = 0
             IF WS-SX NOT = TP-SX(WS-ROW) OR WS-SZ NOT = TP-SZ(WS-ROW)
                 ADD 1 TO WS-BAD4
             END-IF
         ELSE
             IF WS-SX NOT = TP-SZ(WS-ROW) OR WS-SZ NOT = TP-SX(WS-ROW)
                 ADD 1 TO WS-BAD4
             END-IF
         END-IF
         IF WS-SY NOT = TP-SY(WS-ROW)
             ADD 1 TO WS-BAD4
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-7§7 The piece class: the template location is woodland_mansion/<name>" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-7§7 The piece class: position, rotation and mirror are the placer's" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD2 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-7§7 The piece class: depth 0, pivot (0, 0, 0), one processor list for all, kind 5" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD3 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-7§7 The piece class: the box is the template box turned by the rotation" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD4 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-STRUCT-36-7-7.

 COPY NOSPAWN.
 COPY CORETEST.
