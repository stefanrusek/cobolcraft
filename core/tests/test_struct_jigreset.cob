*> Targeted test of the suspicion that JIG-RESET wipes all twelve jigsaw memo slots when the tables fill after a trial chambers assembly (core/src/struct-jig.cob JIG-FIND-POINT, struct-jig-pool.cob
*> JIG-RESET; T51501 round 6 task 3; real data, world seed 3, skipped as a pass without the generated packs). The counter is JIG-GEN of STRUCTJIG.cpy, which JIG-RESET adds 1 to and which every memo slot
*> carries (MS-GEN): a slot whose stamp differs from JIG-GEN is not answered. The trial chambers start of chunk (-135, -60) is assembled (272 pieces, the tables then hold more than 100 template rows, the
*> limit at which the next assembly empties them first); asked again it is answered from the memo (JIG-GEN unchanged, a tenth of the time); then another jigsaw structure (the pillager outpost, an
*> unrelated start) is assembled, which empties the tables (JIG-GEN + 1) and with them the memo, and the trial chambers start is asked a third time. The PROBE lines print the table fill, the JIG-GEN values
*> and the three times.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-JIGRESET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 COPY STRUCTJIG.
 COPY STRUCTTPL.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-KEY                 PIC X(80) VALUE "minecraft:trial_chambers".
 01 WS-KEY2                PIC X(80) VALUE "minecraft:pillager_outpost".
 01 WS-CX                  BINARY-LONG VALUE -135.
 01 WS-CZ                  BINARY-LONG VALUE -60.
 01 WS-OX                  BINARY-LONG VALUE 3.
 01 WS-OZ                  BINARY-LONG VALUE 3.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROW2                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-PIECES              BINARY-LONG.
 01 WS-GEN0                BINARY-LONG.
 01 WS-GEN1                BINARY-LONG.
 01 WS-GEN2                BINARY-LONG.
 01 WS-GEN3                BINARY-LONG.
 01 WS-GEN4                BINARY-LONG.
 01 WS-TP-FILL             BINARY-LONG.
 01 WS-JE-FILL             BINARY-LONG.
 01 WS-JN-FILL             BINARY-LONG.
 01 WS-CLOCK               PIC X(21).
 01 WS-T0                  BINARY-LONG.
 01 WS-T1                  BINARY-LONG.
 01 WS-COLD-MS             BINARY-LONG.
 01 WS-WARM-MS             BINARY-LONG.
 01 WS-AFTER-MS            BINARY-LONG.
 01 WS-AFTER2-MS           BINARY-LONG.
 01 WS-EDIT                PIC Z(7)9.
 01 WS-EDIT2               PIC Z(7)9.
 01 WS-EDIT3               PIC Z(7)9.
 01 WS-EDIT4               PIC Z(7)9.
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
         MOVE "test struct jigreset no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE "3" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "STRUCT-GATE-RESET"
     CALL "STRUCT-GATE-ON" USING WS-KEY
     CALL "STRUCT-GATE-ON" USING WS-KEY2
     MOVE 0 TO WS-ROW WS-ROW2
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         IF SDT-KEY(WS-I) = WS-KEY
             MOVE WS-I TO WS-ROW
         END-IF
         IF SDT-KEY(WS-I) = WS-KEY2
             MOVE WS-I TO WS-ROW2
         END-IF
     END-PERFORM
     MOVE "test struct jigreset given the data when the structures are looked up then the trial chambers and the pillager outpost are loaded" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ROW > 0 AND WS-ROW2 > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-ROW = 0 OR WS-ROW2 = 0
         STOP RUN
     END-IF
*>   every cache empty, then the first assembly of the trial chambers start
     CALL "JIG-RESET"
     CALL "STRUCT-TPL-RESET"
     MOVE JIG-GEN TO WS-GEN0
     MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
     PERFORM CLOCK-MS
     MOVE WS-T0 TO WS-T1
     CALL "STRUCT-FIND-POINT" USING WS-ROW CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-V
     MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
     PERFORM CLOCK-MS
     COMPUTE WS-COLD-MS = WS-T0 - WS-T1
     MOVE JIG-GEN TO WS-GEN1
     MOVE SP-COUNT TO WS-PIECES
     MOVE TP-COUNT TO WS-TP-FILL
     MOVE JE-COUNT TO WS-JE-FILL
     MOVE JN-USED TO WS-JN-FILL
     MOVE "test struct jigreset given the trial chambers start of chunk (-135,-60) when it is assembled then it has more than 100 pieces" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-V = 1 AND WS-PIECES > 100
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test struct jigreset given the assembled trial chambers when the tables are read then more than 100 templates are loaded (the limit for emptying them before the next assembly)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-TP-FILL > 100
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test struct jigreset given the empty tables when the trial chambers are assembled then JIG-RESET was not called by that assembly" TO TL-CASE
     MOVE WS-GEN0 TO TL-EXPECTED-N
     MOVE WS-GEN1 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the same start again: the memo
     MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
     PERFORM CLOCK-MS
     MOVE WS-T0 TO WS-T1
     CALL "STRUCT-FIND-POINT" USING WS-ROW CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-V
     MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
     PERFORM CLOCK-MS
     COMPUTE WS-WARM-MS = WS-T0 - WS-T1
     MOVE JIG-GEN TO WS-GEN2
     MOVE "test struct jigreset given an assembled start when it is asked again then JIG-RESET was not called and the memo answered in under a tenth of the time" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-GEN2 = WS-GEN1 AND WS-WARM-MS * 10 < WS-COLD-MS
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   an unrelated jigsaw start
     CALL "STRUCT-FIND-POINT" USING WS-ROW2 CW-SEED WS-OX WS-OZ WS-X WS-Y WS-Z WS-V
     MOVE JIG-GEN TO WS-GEN3
     MOVE WS-GEN1 TO WS-EDIT
     MOVE WS-GEN3 TO WS-EDIT2
     MOVE WS-TP-FILL TO WS-EDIT3
     MOVE WS-JE-FILL TO WS-EDIT4
     DISPLAY "PROBE after the trial chambers: JIG-GEN " FUNCTION TRIM(WS-EDIT) ", after an unrelated jigsaw start " FUNCTION TRIM(WS-EDIT2)
         ", templates " FUNCTION TRIM(WS-EDIT3) ", elements " FUNCTION TRIM(WS-EDIT4)
     MOVE "test struct jigreset given the tables filled by the trial chambers when another jigsaw structure is assembled then JIG-RESET ran once" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-GEN1 + 1
     MOVE WS-GEN3 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the trial chambers start a third time: the memo slot of it went with the reset (JIG-GEN stamp), so it is assembled again
     MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
     PERFORM CLOCK-MS
     MOVE WS-T0 TO WS-T1
     CALL "STRUCT-FIND-POINT" USING WS-ROW CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-V
     MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
     PERFORM CLOCK-MS
     COMPUTE WS-AFTER-MS = WS-T0 - WS-T1
     MOVE JIG-GEN TO WS-GEN4
     MOVE WS-COLD-MS TO WS-EDIT
     MOVE WS-WARM-MS TO WS-EDIT2
     MOVE WS-AFTER-MS TO WS-EDIT3
     DISPLAY "PROBE trial chambers start: first " FUNCTION TRIM(WS-EDIT) " ms, memo " FUNCTION TRIM(WS-EDIT2) " ms, after the unrelated start " FUNCTION TRIM(WS-EDIT3) " ms"
     MOVE "test struct jigreset given the memo of the trial chambers start when an unrelated jigsaw start emptied the tables then the start is assembled again (not answered in under a tenth of the first time)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-AFTER-MS * 10 >= WS-COLD-MS
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test struct jigreset given the reassembled start when the pieces are counted then they are the same number of pieces as the first assembly" TO TL-CASE
     MOVE WS-PIECES TO TL-EXPECTED-N
     MOVE SP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 CLOCK-MS.
     COMPUTE WS-T0 = FUNCTION NUMVAL(WS-CLOCK(9:2)) * 3600000 + FUNCTION NUMVAL(WS-CLOCK(11:2)) * 60000
         + FUNCTION NUMVAL(WS-CLOCK(13:2)) * 1000 + FUNCTION NUMVAL(WS-CLOCK(15:2)) * 10.
 END PROGRAM TEST-STRUCT-JIGRESET.

 COPY NOSPAWN.
 COPY CORETEST.
