*> Acceptance test of Rendering facts needed on the client (T0354; docs/protocol/41-item-entity-physics.md section 7; FR-037): the number
*> of rendered copies of a stack, the bobbing height (table sine), the spin, the visual yaw, the copy offsets of thick and flat
*> models (the random source seeded with the item id plus the damage, 187 for an empty stack) and the shadow constants.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ITEMPHYS-41-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CITEMPHYS.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-OBSERVED            PIC X(1024).
 01 WS-A                   PIC X(16).
 01 WS-B                   PIC X(16).
 01 WS-T1                  PIC X(64).
 01 WS-T2                  PIC X(64).
 01 WS-T3                  PIC X(64).
 01 WS-COUNT               BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-AGE                 FLOAT-LONG.
 01 WS-BOB                 FLOAT-LONG.
 01 WS-MIN-Y               FLOAT-LONG.
 01 WS-RESULT              FLOAT-LONG.
 01 WS-AGE-INT             BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-DEPTH               FLOAT-LONG.
 01 WS-STATE               BINARY-DOUBLE.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-R1                  FLOAT-LONG.
 01 WS-R2                  FLOAT-LONG.
 01 WS-R3                  FLOAT-LONG.
 01 WS-OX                  FLOAT-LONG.
 01 WS-OY                  FLOAT-LONG.
 01 WS-OZ                  FLOAT-LONG.
 01 WS-OFFSETS.
    05 WS-COPY OCCURS 5 TIMES.
       10 WS-CX            FLOAT-LONG.
       10 WS-CY            FLOAT-LONG.
       10 WS-CZ            FLOAT-LONG.
 PROCEDURE DIVISION.
     MOVE "acceptance US2 41§7 Rendering facts needed on the client the shadow radius is 0.15 and its strength 0.75" TO WS-CASE
     MOVE "150 750" TO WS-EXPECTED
     MOVE SPACES TO WS-OBSERVED
     STRING IP-SHADOW-RADIUS-MILLI " " IP-SHADOW-STRENGTH-MILLI DELIMITED BY SIZE INTO WS-OBSERVED
     PERFORM CHECK

*>   The copies of a stack: 1 up to 1, 2 up to 16, 3 up to 32, 4 up to 48, else 5.
     MOVE "acceptance US2 41§7 Rendering facts needed on the client a stack is drawn as 1 copy up to 1 item, 2 up to 16, 3 up to "
         & "32, 4 up to 48 and 5 above" TO WS-CASE
     MOVE SPACES TO WS-OBSERVED
     MOVE 1 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         EVALUATE WS-I
             WHEN 1 MOVE 1 TO WS-COUNT
             WHEN 2 MOVE 2 TO WS-COUNT
             WHEN 3 MOVE 16 TO WS-COUNT
             WHEN 4 MOVE 17 TO WS-COUNT
             WHEN 5 MOVE 32 TO WS-COUNT
             WHEN 6 MOVE 33 TO WS-COUNT
             WHEN 7 MOVE 48 TO WS-COUNT
             WHEN 8 MOVE 49 TO WS-COUNT
             WHEN 9 MOVE 64 TO WS-COUNT
             WHEN 10 MOVE 0 TO WS-COUNT
         END-EVALUATE
         CALL "IP-RENDER-AMOUNT" USING WS-COUNT WS-AMOUNT
         CALL "ITT-I" USING WS-AMOUNT WS-A
         STRING FUNCTION TRIM(WS-A) DELIMITED BY SIZE INTO WS-OBSERVED POINTER WS-N
     END-PERFORM
     MOVE "1223344551" TO WS-EXPECTED
     PERFORM CHECK

*>   Bobbing: (sin(age / 10 + bob) * 0.1 + 0.1) + (-minY + 0.0625) with the table sine.
     MOVE "acceptance US2 41§7 Rendering facts needed on the client the bob height is sin(age / 10 + bobOffs) * 0.1 + 0.1 - minY + "
         & "0.0625: 0.1625 at age 0, 0.2625 a quarter wave later and 0.2625 for a model starting 0.1 below" TO WS-CASE
     MOVE 0 TO WS-AGE WS-BOB WS-MIN-Y
     CALL "IP-BOB-Y" USING WS-AGE WS-BOB WS-MIN-Y WS-RESULT
     CALL "ITT-F" USING WS-RESULT WS-A
     MOVE WS-A TO WS-T1
     MOVE 15.707963 TO WS-AGE
     CALL "IP-BOB-Y" USING WS-AGE WS-BOB WS-MIN-Y WS-RESULT
     CALL "ITT-F" USING WS-RESULT WS-A
     MOVE WS-A TO WS-T2
     MOVE 0 TO WS-AGE
     MOVE -0.1 TO WS-MIN-Y
     CALL "IP-BOB-Y" USING WS-AGE WS-BOB WS-MIN-Y WS-RESULT
     CALL "ITT-F" USING WS-RESULT WS-A
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-T1) " " FUNCTION TRIM(WS-T2) " " FUNCTION TRIM(WS-A) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "0.16250 0.26250 0.26250" TO WS-EXPECTED
     PERFORM CHECK

*>   The spin: age / 20 + bobOffs radians; the visual yaw 180 - ((age + 0.5) / 20 + bobOffs) / 2 pi * 360 degrees.
     MOVE "acceptance US2 41§7 Rendering facts needed on the client the spin is age / 20 + bobOffs radians and the visual yaw "
         & "180 - ((age + 0.5) / 20 + bobOffs) / (2 pi) * 360 degrees" TO WS-CASE
     MOVE 40 TO WS-AGE
     MOVE 1 TO WS-BOB
     CALL "IP-SPIN" USING WS-AGE WS-BOB WS-RESULT
     CALL "ITT-F" USING WS-RESULT WS-A
     MOVE WS-A TO WS-T1
     MOVE 0 TO WS-AGE-INT
     MOVE 0 TO WS-BOB
     CALL "IP-VISUAL-YAW" USING WS-AGE-INT WS-BOB WS-RESULT
     CALL "ITT-F" USING WS-RESULT WS-A
     MOVE WS-A TO WS-T2
     MOVE 10 TO WS-AGE-INT
     COMPUTE WS-BOB = FUNCTION PI
     CALL "IP-VISUAL-YAW" USING WS-AGE-INT WS-BOB WS-RESULT
     CALL "ITT-F" USING WS-RESULT WS-A
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-T1) " " FUNCTION TRIM(WS-T2) " " FUNCTION TRIM(WS-A) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "3.00000 178.56761 -30.08028" TO WS-EXPECTED
     PERFORM CHECK

*>   Copy offsets of a thick model (depth above 0.0625): the first copy unmoved, each further one offset by (r * 2 - 1) * 0.15 on
*>   x, y and z; the random source is seeded with item + damage.
     MOVE 7 TO WS-ITEM
     MOVE 2 TO WS-DAMAGE
     MOVE 0.1 TO WS-DEPTH
     MOVE 3 TO WS-AMOUNT
     CALL "IP-RENDER-OFFSETS" USING WS-ITEM WS-DAMAGE WS-DEPTH WS-AMOUNT WS-OFFSETS
     MOVE 9 TO WS-SEED
     CALL "IP-RNG-SEED" USING WS-STATE WS-SEED
     MOVE SPACES TO WS-EXPECTED
     MOVE "0.00000,0.00000,0.00000" TO WS-EXPECTED
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > 3
         PERFORM DRAW-3
         COMPUTE WS-OX = (WS-R1 * 2 - 1) * 0.15
         COMPUTE WS-OY = (WS-R2 * 2 - 1) * 0.15
         COMPUTE WS-OZ = (WS-R3 * 2 - 1) * 0.15
         CALL "ITT-V3" USING WS-OX WS-OY WS-OZ WS-T1
         MOVE FUNCTION TRIM(WS-EXPECTED) TO WS-T3
         MOVE SPACES TO WS-EXPECTED
         STRING FUNCTION TRIM(WS-T3) " " FUNCTION TRIM(WS-T1) DELIMITED BY SIZE INTO WS-EXPECTED
     END-PERFORM
     MOVE SPACES TO WS-OBSERVED
     PERFORM DESCRIBE-COPIES
     MOVE "acceptance US2 41§7 Rendering facts needed on the client a thick model draws the first copy unmoved and the others offset "
         & "by (r * 2 - 1) * 0.15 on x, y and z from the source seeded with item + damage" TO WS-CASE
     PERFORM CHECK

*>   A flat model (depth 0.03): spacing 1.5 * depth along z centred on the group, the other copies offset in x and y by half that.
     MOVE 0.03 TO WS-DEPTH
     MOVE 2 TO WS-AMOUNT
     CALL "IP-RENDER-OFFSETS" USING WS-ITEM WS-DAMAGE WS-DEPTH WS-AMOUNT WS-OFFSETS
     CALL "IP-RNG-SEED" USING WS-STATE WS-SEED
     PERFORM DRAW-3
     COMPUTE WS-OX = (WS-R1 * 2 - 1) * 0.15 * 0.5
     COMPUTE WS-OY = (WS-R2 * 2 - 1) * 0.15 * 0.5
     MOVE "0.00000,0.00000,-0.02250" TO WS-T1
     MOVE 0.0225 TO WS-OZ
     CALL "ITT-V3" USING WS-OX WS-OY WS-OZ WS-T2
     MOVE SPACES TO WS-EXPECTED
     STRING FUNCTION TRIM(WS-T1) " " FUNCTION TRIM(WS-T2) DELIMITED BY SIZE INTO WS-EXPECTED
     MOVE SPACES TO WS-OBSERVED
     MOVE 2 TO WS-AMOUNT
     PERFORM DESCRIBE-COPIES
     MOVE "acceptance US2 41§7 Rendering facts needed on the client a flat model spaces its copies 1.5 * depth along z around the "
         & "centre and offsets the others by (r * 2 - 1) * 0.15 * 0.5 on x and y" TO WS-CASE
     PERFORM CHECK

*>   One copy: nothing is offset; an empty stack seeds the source with 187.
     MOVE 1 TO WS-AMOUNT
     MOVE 0.1 TO WS-DEPTH
     CALL "IP-RENDER-OFFSETS" USING WS-ITEM WS-DAMAGE WS-DEPTH WS-AMOUNT WS-OFFSETS
     MOVE SPACES TO WS-OBSERVED
     PERFORM DESCRIBE-COPIES
     MOVE "acceptance US2 41§7 Rendering facts needed on the client one copy is drawn unmoved" TO WS-CASE
     MOVE "0.00000,0.00000,0.00000" TO WS-EXPECTED
     PERFORM CHECK
     MOVE 0 TO WS-ITEM
     MOVE 0 TO WS-DAMAGE
     MOVE 2 TO WS-AMOUNT
     CALL "IP-RENDER-OFFSETS" USING WS-ITEM WS-DAMAGE WS-DEPTH WS-AMOUNT WS-OFFSETS
     MOVE 187 TO WS-SEED
     CALL "IP-RNG-SEED" USING WS-STATE WS-SEED
     PERFORM DRAW-3
     COMPUTE WS-OX = (WS-R1 * 2 - 1) * 0.15
     CALL "ITT-F" USING WS-OX WS-A
     CALL "ITT-F" USING WS-CX(2) WS-B
     MOVE "acceptance US2 41§7 Rendering facts needed on the client an empty stack seeds the offsets with 187" TO WS-CASE
     MOVE WS-A TO WS-EXPECTED
     MOVE WS-B TO WS-OBSERVED
     PERFORM CHECK
     STOP RUN.

 DRAW-3.
     CALL "IP-RNG-FLOAT" USING WS-STATE WS-R1
     CALL "IP-RNG-FLOAT" USING WS-STATE WS-R2
     CALL "IP-RNG-FLOAT" USING WS-STATE WS-R3.

*> WS-OBSERVED = the offsets of the first WS-AMOUNT copies, "x,y,z" separated by one space.
 DESCRIBE-COPIES.
     MOVE SPACES TO WS-OBSERVED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-AMOUNT
         CALL "ITT-V3" USING WS-CX(WS-I) WS-CY(WS-I) WS-CZ(WS-I) WS-T1
         MOVE FUNCTION TRIM(WS-OBSERVED) TO WS-T3
         MOVE SPACES TO WS-OBSERVED
         IF WS-I = 1
             MOVE WS-T1 TO WS-OBSERVED
         ELSE
             STRING FUNCTION TRIM(WS-T3) " " FUNCTION TRIM(WS-T1) DELIMITED BY SIZE INTO WS-OBSERVED
         END-IF
     END-PERFORM.

 CHECK.
     CALL "ITT-CHECK" USING WS-CASE WS-EXPECTED WS-OBSERVED.
 END PROGRAM TEST-ITEMPHYS-41-7.

 COPY CORETEST.
 COPY ITEMTEST.
