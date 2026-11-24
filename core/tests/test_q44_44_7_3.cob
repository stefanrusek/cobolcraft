*> Acceptance test (US15, FR-036; docs/protocol/44-residual-mob-questions-7-aquatic.md section 3, lane 002-lane-p49j-a): the corrections table. Each row names a statement of 21
*> that this document replaces; the rows whose rule the core has are pinned here by one case each (the full cases are in test_q44_44_7_4 to _11): fish flop has no random chance
*> or cooldown (4.1, test_q44_44_7_4), squid XP 1 + nextInt(3) (6.1), squid and dolphin have no breeding food, the baby chances (6.3), the elder value (5), the axolotl rare
*> variant (8.2), rehydration (8.4), play dead (8.3), the dolphin treasure retry probability (7.2: 1/40) and the ChargeAttack roles (10.6).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-7-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-NAME                PIC X(240).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-G                   FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-W                   PIC X(8) VALUE "11111111".
 01 WS-W2                  PIC X(8) VALUE "11111111".
 01 WS-W3                  PIC X(8) VALUE "11111111".
 01 WS-SA                  BINARY-LONG VALUE 0.
 01 WS-SL                  BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-DRAW                BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 0 TO WS-SEEN
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 2
         CALL "Q7-XP-WATER" USING WS-I WS-OBS
         COMPUTE WS-SEEN = WS-SEEN * 10 + WS-OBS
     END-PERFORM
     MOVE "acceptance US15 44-7§3 row 4.5 XP: draws 0, 1, 2 give 1, 2, 3 (123)" TO WS-NAME
     MOVE 123 TO WS-EXP
     MOVE WS-SEEN TO WS-OBS
     PERFORM EXPECT
     MOVE "squid" TO WS-KEY
     CALL "Q7-GROUP-CHANCE" USING WS-KEY WS-F
     MOVE "acceptance US15 44-7§3 row 4.5 Ageable: squid has no breeding, only the spawn group chance 0.05 (x100)" TO WS-NAME
     MOVE 5 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-F * 100
     PERFORM EXPECT
     MOVE 5 TO WS-B
     MOVE 6 TO WS-C
     MOVE 1 TO WS-A
     MOVE 7 TO WS-I
     CALL "Q7-AXO-OFFSPRING" USING WS-I WS-A WS-B WS-C WS-D
     MOVE "acceptance US15 44-7§3 row 4.7 Variants: the rare roll only in offspring; otherwise the coin picks a parent's variant (5)" TO WS-NAME
     MOVE 5 TO WS-EXP
     MOVE WS-D TO WS-OBS
     PERFORM EXPECT
     MOVE 1000 TO WS-D
     CALL "Q7-AXO-REHYDRATE" USING WS-D
     MOVE "acceptance US15 44-7§3 row 4.7 Air: a water potion refills 1800 (1000 to 2800)" TO WS-NAME
     MOVE 2800 TO WS-EXP
     MOVE WS-D TO WS-OBS
     PERFORM EXPECT
     MOVE 1 TO WS-A
     CALL "Q7-ELDER-VALUE" USING WS-A WS-OBS
     MOVE "acceptance US15 44-7§3 row 4.8 Elder guardian: a silent elder sends value 0" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
     MOVE 0 TO WS-A
     CALL "Q7-ELDER-VALUE" USING WS-A WS-OBS
     MOVE "acceptance US15 44-7§3 row 4.8 Elder guardian: otherwise value 1" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     MOVE 1 TO WS-DRAW
     CALL "Q7-JUMP-CAN-USE" USING WS-DRAW WS-W WS-W2 WS-W3 WS-OBS
     MOVE "acceptance US15 44-7§3 row 4.6 jump goal: a draw other than 0 never starts it (1 in 5)" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
     MOVE 0 TO WS-DRAW
     CALL "Q7-JUMP-CAN-USE" USING WS-DRAW WS-W WS-W2 WS-W3 WS-OBS
     MOVE "acceptance US15 44-7§3 row 4.6 jump goal: draw 0 with clear water and air starts it" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     MOVE 2 TO WS-A
     MOVE 0 TO WS-B
     MOVE 100 TO WS-C
     MOVE 0.6 TO WS-F
     MOVE 1.0 TO WS-G
     CALL "Q7-NAU-KNOCKBACK" USING WS-F WS-G WS-SA WS-SL WS-H
     MOVE "acceptance US15 44-7§3 row 4.10 ChargeAttack: knockback force 2.0 x the speed 0.6 (x1000 = 1200); distance 12.0 and detection 11.0 are the limits" TO WS-NAME
     MOVE 1200 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-H * 1000
     PERFORM EXPECT
     MOVE 143 TO WS-H
     MOVE 120 TO WS-G
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     CALL "Q7-NAU-CHARGE-USE" USING WS-ONE WS-ZERO WS-H WS-G WS-A WS-B WS-OBS
     MOVE "acceptance US15 44-7§3 row 4.10 ChargeAttack: 12.0 squared is 144 and 11.0 squared 121, so 143 and 120 still continue" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     STOP RUN.
 EXPECT.
     MOVE WS-NAME TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED-N
     MOVE WS-OBS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-7-3.
