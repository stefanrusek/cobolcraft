*> Acceptance test of docs/protocol/42-particles-7-emitters-entities-events-commands.md section 10 (Game events and vibrations): the vibration packet at scheduling, the reload re-send at the interpolated position, the reload flag and the elder guardian effect. Expected texts are computed independently by a script
*> from the document's formulas; each case injects the draws in the documented order and compares the emission list (5 decimals), the sounds and the count of draws consumed.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PARTICLES-42-7-10.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLP6EM.
 COPY TESTLIB.
 01 WS-NAME                PIC X(160).
 01 WS-CLASS               PIC X(24).
 01 WS-INT                 PIC X(300).
 01 WS-DRT                 PIC X(8000).
 01 WS-EXP                 PIC X(8000).
 01 WS-OBS                 PIC X(20000).
 01 WS-OBS2                PIC X(20000).
 01 WS-LEN                 BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-IN.
    05 WS-IV               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-OUT.
    05 WS-OV               FLOAT-LONG OCCURS 64 TIMES.
 01 WS-LIST.
    05 WS-NUM              FLOAT-LONG OCCURS 2100 TIMES.
 01 WS-COUNT               BINARY-LONG.
 01 WS-TEXT                PIC X(8000).
 01 WS-TOK                 PIC X(40).
 01 WS-PTR                 BINARY-LONG.
 01 WS-PTR2                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ED                  PIC -(5)9.99999.
 01 WS-EDC                 PIC -(10)9.
 01 WS-EDS                 PIC 9.99.
 01 WS-EDR                 PIC 9.99999.
 01 WS-V                   FLOAT-LONG.
 01 WS-E                   FLOAT-LONG.
 01 WS-O                   FLOAT-LONG.
 PROCEDURE DIVISION.
     MOVE "vibration scheduled, travel 12 ticks" TO WS-NAME
     MOVE "vibration_start" TO WS-CLASS
     MOVE "1.5 64.5 -2.5 12.0" TO WS-INT
     MOVE SPACES TO WS-DRT
     MOVE SPACES TO WS-EXP
     MOVE "vibration 1.50000 64.50000 -2.50000 0.00000 0.00000 0.00000 "
         & "st=12 (0)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "reload flag 1 remaining 6 of 12 received 1" TO WS-NAME
     MOVE "vibration_reload" TO WS-CLASS
     MOVE "1.0 1.0 64.0 1.0 9.0 70.0 -7.0 6.0 12.0 1.0" TO WS-INT
     MOVE SPACES TO WS-DRT
     MOVE SPACES TO WS-EXP
     MOVE "vibration 5.00000 67.00000 -3.00000 0.00000 0.00000 0.00000 "
         & "st=6 # reload_cleared (0)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "reload flag 1 remaining 12 of 12 received 0" TO WS-NAME
     MOVE "vibration_reload" TO WS-CLASS
     MOVE "1.0 1.0 64.0 1.0 9.0 70.0 -7.0 12.0 12.0 0.0" TO WS-INT
     MOVE SPACES TO WS-DRT
     MOVE SPACES TO WS-EXP
     MOVE "vibration 1.00000 64.00000 1.00000 0.00000 0.00000 0.00000 s"
         & "t=12 (0)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "reload flag 1 remaining 1 of 12 received 1" TO WS-NAME
     MOVE "vibration_reload" TO WS-CLASS
     MOVE "1.0 1.0 64.0 1.0 9.0 70.0 -7.0 1.0 12.0 1.0" TO WS-INT
     MOVE SPACES TO WS-DRT
     MOVE SPACES TO WS-EXP
     MOVE "vibration 8.33333 69.50000 -6.33333 0.00000 0.00000 0.00000 "
         & "st=1 # reload_cleared (0)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE "reload flag 0 remaining 6 of 12 received 1" TO WS-NAME
     MOVE "vibration_reload" TO WS-CLASS
     MOVE "0.0 1.0 64.0 1.0 9.0 70.0 -7.0 6.0 12.0 1.0" TO WS-INT
     MOVE SPACES TO WS-DRT
     MOVE SPACES TO WS-EXP
     MOVE " (0)" TO WS-EXP
     PERFORM RUN-CASE
     MOVE 1.0 TO WS-IV(1)
     CALL "P7-ELDER" USING WS-IN WS-OUT
     MOVE "elder guardian effect parameter 1 (curse sound when it rounds to 1) [1]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.6 TO WS-IV(1)
     CALL "P7-ELDER" USING WS-IN WS-OUT
     MOVE "elder guardian effect parameter 0.6 (curse sound when it rounds to 1) [1]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1.4 TO WS-IV(1)
     CALL "P7-ELDER" USING WS-IN WS-OUT
     MOVE "elder guardian effect parameter 1.4 (curse sound when it rounds to 1) [1]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.4 TO WS-IV(1)
     CALL "P7-ELDER" USING WS-IN WS-OUT
     MOVE "elder guardian effect parameter 0.4 (curse sound when it rounds to 1) [1]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.0 TO WS-IV(1)
     CALL "P7-ELDER" USING WS-IN WS-OUT
     MOVE "elder guardian effect parameter 0 (curse sound when it rounds to 1) [1]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "elder guardian effect spawns at the local player" TO WS-NAME
     MOVE "elder_guardian" TO WS-CLASS
     MOVE "4.0 65.0 4.0" TO WS-INT
     MOVE SPACES TO WS-DRT
     MOVE SPACES TO WS-EXP
     MOVE "elder_guardian 4.00000 65.00000 4.00000 0.00000 0.00000 0.00"
         & "000 (0)" TO WS-EXP
     PERFORM RUN-CASE
 STOP RUN.

 RUN-CASE.
     MOVE WS-INT TO WS-TEXT
     PERFORM PARSE-LIST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE 0 TO WS-IV(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         MOVE WS-NUM(WS-I) TO WS-IV(WS-I)
     END-PERFORM
     MOVE WS-DRT TO WS-TEXT
     PERFORM PARSE-LIST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2048
         MOVE 0.5 TO EM-DRAW(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         MOVE WS-NUM(WS-I) TO EM-DRAW(WS-I)
     END-PERFORM
     MOVE 0 TO EM-COUNT EM-CUR EM-SOUND-COUNT
     CALL "P7-VIBRATION" USING WS-CLASS WS-IN P6-EMITS
     PERFORM RENDER
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-OBS)) TO WS-LEN
     IF WS-LEN > 1000
         MOVE SPACES TO WS-OBS2
         MOVE WS-OBS(1:480) TO WS-OBS2(1:480)
         MOVE "..." TO WS-OBS2(481:3)
         COMPUTE WS-START = WS-LEN - 479
         MOVE WS-OBS(WS-START:480) TO WS-OBS2(484:480)
         MOVE WS-OBS2 TO WS-OBS
     END-IF
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-7§10 Game events and vibrations: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-EXP TO TL-EXPECTED
     MOVE WS-OBS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-7§10 Game events and vibrations: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-7§10 Game events and vibrations: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 PARSE-LIST.
     MOVE 0 TO WS-COUNT
     MOVE 1 TO WS-PTR
     PERFORM UNTIL WS-PTR > 8000 OR WS-TEXT(WS-PTR:) = SPACES
         MOVE SPACES TO WS-TOK
         UNSTRING WS-TEXT DELIMITED BY ALL SPACE INTO WS-TOK WITH POINTER WS-PTR
         IF WS-TOK NOT = SPACES
             ADD 1 TO WS-COUNT
             COMPUTE WS-NUM(WS-COUNT) = FUNCTION NUMVAL(WS-TOK)
         END-IF
     END-PERFORM.

 RENDER.
     MOVE SPACES TO WS-OBS
     MOVE 1 TO WS-PTR2
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EM-COUNT
         IF WS-I > 1
             STRING " | " DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR2
         END-IF
         STRING FUNCTION TRIM(EM-NAME(WS-I)) " " DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR2
         MOVE EM-X(WS-I) TO WS-V
         PERFORM ADD-NUMBER
         MOVE EM-Y(WS-I) TO WS-V
         PERFORM ADD-NUMBER
         MOVE EM-Z(WS-I) TO WS-V
         PERFORM ADD-NUMBER
         MOVE EM-VX(WS-I) TO WS-V
         PERFORM ADD-NUMBER
         MOVE EM-VY(WS-I) TO WS-V
         PERFORM ADD-NUMBER
         MOVE EM-VZ(WS-I) TO WS-V
         PERFORM ADD-LAST-NUMBER
         IF EM-COLOR(WS-I) NOT = 0
             MOVE EM-COLOR(WS-I) TO WS-EDC
             COMPUTE WS-EDS ROUNDED = EM-SCALE(WS-I)
             STRING " c=" FUNCTION TRIM(WS-EDC) " s=" WS-EDS DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR2
         END-IF
         IF EM-COLOR(WS-I) = 0 AND EM-SCALE(WS-I) NOT = 0
             COMPUTE WS-EDR ROUNDED = EM-SCALE(WS-I)
             STRING " r=" WS-EDR DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR2
         END-IF
         IF EM-STATE(WS-I) NOT = 0
             MOVE EM-STATE(WS-I) TO WS-EDC
             STRING " st=" FUNCTION TRIM(WS-EDC) DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR2
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EM-SOUND-COUNT
         STRING " # " FUNCTION TRIM(EM-SOUND(WS-I)) DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR2
     END-PERFORM
     MOVE EM-CUR TO WS-EDC
     STRING " (" FUNCTION TRIM(WS-EDC) ")" DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR2.

 ADD-NUMBER.
     PERFORM ADD-LAST-NUMBER
     STRING " " DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR2.

 ADD-LAST-NUMBER.
     COMPUTE WS-ED ROUNDED = WS-V
     STRING FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR2.
 END PROGRAM TEST-PARTICLES-42-7-10.
