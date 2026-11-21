*> Acceptance test of The entity (T0342; docs/protocol/41-item-entity-physics.md section 1; FR-037): the constants, the fields of a
*> new item entity and their defaults, the constructor draws (bobOffs, yaw, then the random motion of the five-argument
*> constructor), the setters (default delay 10, no delay, never pick up, unlimited and extended lifetime, fake item),
*> hasPickUpDelay, the stack patch handle and the initialisation of a row that another program filled.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ITEMPHYS-41-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CITEMPHYS.
 COPY CITEMS.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-OBSERVED            PIC X(1024).
 01 WS-TMP                 PIC X(1024).
 01 WS-A                   PIC X(16).
 01 WS-B                   PIC X(16).
 01 WS-C                   PIC X(16).
 01 WS-X                   FLOAT-LONG VALUE 20.5.
 01 WS-Y                   FLOAT-LONG VALUE 100.25.
 01 WS-Z                   FLOAT-LONG VALUE 20.5.
 01 WS-VX                  FLOAT-LONG VALUE 0.5.
 01 WS-VY                  FLOAT-LONG VALUE 0.25.
 01 WS-VZ                  FLOAT-LONG VALUE -0.5.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-ITEM                BINARY-LONG VALUE 2.
 01 WS-COUNT               BINARY-LONG VALUE 7.
 01 WS-DELAY               BINARY-LONG VALUE 10.
 01 WS-VAR                 BINARY-LONG VALUE 9.
 01 WS-ROW                 BINARY-LONG.
 01 WS-STATE               BINARY-DOUBLE.
 01 WS-F1                  FLOAT-LONG.
 01 WS-F2                  FLOAT-LONG.
 01 WS-F3                  FLOAT-LONG.
 01 WS-F4                  FLOAT-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-HAS-D               PIC 9.
 01 WS-ID                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE

     MOVE "acceptance US2 41§1 The entity constants: lifetime 6000, never pick up 32767, never ages -32768, health 5, "
         & "default delay 10, thrown delay 40, dispenser delay 0" TO WS-CASE
     MOVE "6000 32767 -32768 5 10 40 0" TO WS-EXPECTED
     MOVE SPACES TO WS-OBSERVED
     STRING IP-LIFETIME " " IP-NEVER-PICKUP " " IP-INFINITE-LIFETIME " " IP-DEFAULT-HEALTH " "
         IP-DELAY-DEFAULT " " IP-DELAY-THROWN " " IP-DELAY-DISPENSER DELIMITED BY SIZE INTO WS-OBSERVED
     PERFORM CHECK

*>   A new entity with explicit motion: the base entity draws bobOffs and the yaw (nextFloat * 360), nothing else.
     CALL "GI-SPAWN-X" USING WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-ITEM WS-COUNT WS-DELAY WS-ROW WS-VAR
     MOVE EN-ID(WS-ROW) TO WS-ID
     MOVE "acceptance US2 41§1 The entity a new item has age 0, health 5, no thrower, no owner, the given delay, stack, patch "
         & "handle and motion" TO WS-CASE
     MOVE "20.50000,100.25000,20.50000 v 0.50000,0.25000,-0.50000 g 0 d 10 a 0 n 7x2 health 5 thrower 0 var 9 owner 0"
         TO WS-EXPECTED
     CALL "ITT-DESCRIBE" USING WS-ROW WS-OBSERVED
     CALL "ITT-I" USING IP-I-HEALTH(WS-ROW) WS-A
     CALL "ITT-I" USING IP-I-THROWER(WS-ROW) WS-B
     CALL "ITT-I" USING IP-I-VAR(WS-ROW) WS-C
     MOVE WS-OBSERVED TO WS-TMP
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-TMP) " health " FUNCTION TRIM(WS-A) " thrower " FUNCTION TRIM(WS-B) " var "
         FUNCTION TRIM(WS-C) " owner " IP-I-HAS-OWNER(WS-ROW) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "acceptance US2 41§1 The entity a new item has age 0, health 5, no thrower, no owner, the given delay, stack, patch "
         & "handle and motion" TO WS-CASE
     PERFORM CHECK

     MOVE "acceptance US2 41§1 The entity the constructor draws bobOffs (nextFloat) and then the yaw (nextFloat * 360) from "
         & "the item's own source" TO WS-CASE
     CALL "IP-ITEM-SEED" USING WS-ID WS-STATE
     CALL "IP-RNG-FLOAT" USING WS-STATE WS-F1
     CALL "IP-RNG-FLOAT" USING WS-STATE WS-F2
     COMPUTE WS-F2 = WS-F2 * 360
     CALL "ITT-F" USING WS-F1 WS-A
     MOVE SPACES TO WS-EXPECTED
     STRING FUNCTION TRIM(WS-A) " ok" DELIMITED BY SIZE INTO WS-EXPECTED
     MOVE EN-YAW(WS-ROW) TO WS-F3
     COMPUTE WS-F3 = WS-F3 - WS-F2
     CALL "ITT-F" USING IP-I-BOB(WS-ROW) WS-A
     MOVE "ok" TO WS-B
     IF FUNCTION ABS(WS-F3) > 0.001
         MOVE "far" TO WS-B
     END-IF
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO WS-OBSERVED
     PERFORM CHECK

*>   The five-argument constructor: after those two draws, x then z of nextDouble * 0.2 - 0.1, and 0.2 for y.
     CALL "GI-SPAWN-RANDOM" USING WS-DIM WS-X WS-Y WS-Z WS-ITEM WS-COUNT WS-VAR WS-DELAY WS-ROW
     MOVE EN-ID(WS-ROW) TO WS-ID
     CALL "IP-ITEM-SEED" USING WS-ID WS-STATE
     CALL "IP-RNG-FLOAT" USING WS-STATE WS-F1
     CALL "IP-RNG-FLOAT" USING WS-STATE WS-F1
     CALL "IP-RNG-DOUBLE" USING WS-STATE WS-F3
     CALL "IP-RNG-DOUBLE" USING WS-STATE WS-F4
     COMPUTE WS-F3 = WS-F3 * 0.2 - 0.1
     COMPUTE WS-F4 = WS-F4 * 0.2 - 0.1
     MOVE "acceptance US2 41§1 The entity the five-argument constructor gives the random motion (nextDouble * 0.2 - 0.1, 0.2, "
         & "nextDouble * 0.2 - 0.1) after the base draws" TO WS-CASE
     CALL "ITT-F" USING WS-F3 WS-A
     CALL "ITT-F" USING WS-F4 WS-B
     MOVE SPACES TO WS-EXPECTED
     STRING FUNCTION TRIM(WS-A) ",0.20000," FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO WS-EXPECTED
     CALL "ITT-F" USING EN-VX(WS-ROW) WS-A
     CALL "ITT-F" USING EN-VY(WS-ROW) WS-B
     CALL "ITT-F" USING EN-VZ(WS-ROW) WS-C
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) "," FUNCTION TRIM(WS-B) "," FUNCTION TRIM(WS-C) DELIMITED BY SIZE INTO WS-OBSERVED
     PERFORM CHECK

*>   The setters.
     MOVE "acceptance US2 41§1 The entity setDefaultPickUpDelay 10, setNoPickUpDelay 0, setNeverPickUp 32767, setUnlimitedLifetime "
         & "age -32768, setExtendedLifetime age -6000, makeFakeItem never pick up plus age 5999" TO WS-CASE
     MOVE SPACES TO WS-OBSERVED
     MOVE 1 TO WS-HAS
     PERFORM VARYING WS-KIND FROM 1 BY 1 UNTIL WS-KIND > 6
         MOVE 3 TO EN-DELAY(WS-ROW)
         MOVE 4 TO EN-AGE(WS-ROW)
         CALL "IP-SETUP" USING WS-ROW WS-KIND
         CALL "ITT-I" USING EN-DELAY(WS-ROW) WS-A
         CALL "ITT-I" USING EN-AGE(WS-ROW) WS-B
         STRING FUNCTION TRIM(WS-A) "/" FUNCTION TRIM(WS-B) " " DELIMITED BY SIZE INTO WS-OBSERVED
             POINTER WS-HAS
     END-PERFORM
     MOVE "10/4 0/4 32767/4 3/-32768 3/-6000 32767/5999" TO WS-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US2 41§1 The entity hasPickUpDelay is pickupDelay above 0, so 32767 counts as delayed and 0 does not"
         TO WS-CASE
     MOVE SPACES TO WS-OBSERVED
     MOVE 1 TO WS-ID
     PERFORM VARYING WS-KIND FROM 1 BY 1 UNTIL WS-KIND > 3
         EVALUATE WS-KIND
             WHEN 1 MOVE 0 TO EN-DELAY(WS-ROW)
             WHEN 2 MOVE 10 TO EN-DELAY(WS-ROW)
             WHEN 3 MOVE 32767 TO EN-DELAY(WS-ROW)
         END-EVALUATE
         CALL "IP-HAS-DELAY" USING WS-ROW WS-HAS
         MOVE WS-HAS TO WS-HAS-D
         STRING WS-HAS-D DELIMITED BY SIZE INTO WS-OBSERVED POINTER WS-ID
     END-PERFORM
     MOVE "011" TO WS-EXPECTED
     PERFORM CHECK

*>   A row another program filled (a tracker row with a stack and a delay, no item record) gets the defaults.
     MOVE "acceptance US2 41§1 The entity a ground item row filled by another program gets the defaults when first used "
         & "(health 5, no thrower, no owner, no patch)" TO WS-CASE
     CALL "ENTITY-ALLOC" USING WS-ROW
     CALL "ENTITY-NEW-ID" USING EN-ID(WS-ROW)
     MOVE CR-LOOSE-ITEM TO EN-TYPE(WS-ROW)
     MOVE 77 TO IP-I-THROWER(WS-ROW) IP-I-VAR(WS-ROW)
     MOVE 1 TO IP-I-HAS-OWNER(WS-ROW)
     CALL "IP-ENSURE" USING WS-ROW
     MOVE IP-I-HEALTH(WS-ROW) TO WS-KIND
     CALL "ITT-I" USING WS-KIND WS-A
     CALL "ITT-I" USING IP-I-THROWER(WS-ROW) WS-B
     CALL "ITT-I" USING IP-I-VAR(WS-ROW) WS-C
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) " " IP-I-HAS-OWNER(WS-ROW)
         DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "5 0 0 0" TO WS-EXPECTED
     PERFORM CHECK
     MOVE "acceptance US2 41§1 The entity IP-ENSURE leaves the record of a row that already belongs to the entity unchanged"
         TO WS-CASE
     MOVE 3 TO IP-I-HEALTH(WS-ROW)
     CALL "IP-ENSURE" USING WS-ROW
     CALL "ITT-I" USING IP-I-HEALTH(WS-ROW) WS-A
     MOVE "3" TO WS-EXPECTED
     MOVE WS-A TO WS-OBSERVED
     PERFORM CHECK
     STOP RUN.

 CHECK.
     CALL "ITT-CHECK" USING WS-CASE WS-EXPECTED WS-OBSERVED.
 END PROGRAM TEST-ITEMPHYS-41-1.

 COPY CORETEST.
 COPY ITEMTEST.
