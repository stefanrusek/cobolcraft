*> Acceptance test, US17-1 and US17-2 core half (spec US17 scenarios 1, 2; FR-007, FR-016, FR-017;
*> contracts/core-host-api.md §2 CORE-OPEN-TO-OTHERS): a single-player world (host kind 1) whose
*> host Hosty plays over a memory connection is opened to others with a guest mode and a
*> guest-operator choice; a guest joining over a network connection plays in the host's world with
*> that mode, the host holds operator status, and the guest holds it only if the host allowed it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US17-GUESTS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-HOST-NAME           PIC X(16) VALUE "Hosty".
 01 WS-BOB-NAME            PIC X(16) VALUE "Bob".
 01 WS-LENGTH-5            BINARY-LONG VALUE 5.
 01 WS-LENGTH-3            BINARY-LONG VALUE 3.
 01 WS-HOST                BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-GUEST-MODE          BINARY-LONG.
 01 WS-GUEST-OPERATOR      BINARY-LONG.
 01 WS-TEXT                PIC X(256).
 01 WS-EDIT                PIC -(9)9.
 PROCEDURE DIVISION.
*>   A creative single-player world, opened with guests in survival and no guest operators.
     MOVE 0 TO WS-GUEST-MODE WS-GUEST-OPERATOR
     PERFORM OPEN-AND-JOIN
     MOVE "acceptance US17-1/US17-2 given a world opened with guest mode survival and no guest "
         & "operators when a guest joins over a network connection then the guest plays in survival "
         & "without operator status and the host keeps creative as operator" TO TL-CASE
     MOVE "network play; host mode 1 op 1; guest mode 0 op 0; online 2" TO TL-EXPECTED
     PERFORM CHECK

*>   The same world, opened with guests in creative who may use operator commands.
     MOVE 1 TO WS-GUEST-MODE WS-GUEST-OPERATOR
     PERFORM OPEN-AND-JOIN
     MOVE "acceptance US17-1/US17-2 given a world opened with guest mode creative and guest "
         & "operators allowed when a guest joins over a network connection then the guest plays in "
         & "creative with operator status" TO TL-CASE
     MOVE "network play; host mode 1 op 1; guest mode 1 op 1; online 2" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> A new single-player world with Hosty in play, opened to others with WS-GUEST-MODE and
*> WS-GUEST-OPERATOR, then Bob joins over a network connection; WS-TEXT describes the outcome.
 OPEN-AND-JOIN.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 1 TO CS-DEFAULT-MODE CS-HOST-KIND
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE WS-HOST-NAME TO CS-HOST-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     CALL "TEST-JOIN" USING WS-HOST-NAME WS-LENGTH-5 WS-HOST
     CALL "CORE-OPEN-TO-OTHERS" USING WS-GUEST-MODE WS-GUEST-OPERATOR
     CALL "TEST-JOIN-NETWORK" USING WS-BOB-NAME WS-LENGTH-3 WS-BOB
     MOVE SPACES TO WS-TEXT
     IF CN-KIND(WS-BOB) = CORE-CONN-NETWORK AND CN-PHASE(WS-BOB) = PH-PLAY
         MOVE "network play;" TO WS-TEXT
     END-IF
     MOVE PL-MODE(CN-PLAYER(WS-HOST)) TO WS-EDIT
     STRING FUNCTION TRIM(WS-TEXT) " host mode " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
         INTO WS-TEXT
     MOVE PL-OPERATOR(CN-PLAYER(WS-HOST)) TO WS-EDIT
     STRING FUNCTION TRIM(WS-TEXT) " op " FUNCTION TRIM(WS-EDIT) ";" DELIMITED BY SIZE
         INTO WS-TEXT
     MOVE PL-MODE(CN-PLAYER(WS-BOB)) TO WS-EDIT
     STRING FUNCTION TRIM(WS-TEXT) " guest mode " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
         INTO WS-TEXT
     MOVE PL-OPERATOR(CN-PLAYER(WS-BOB)) TO WS-EDIT
     STRING FUNCTION TRIM(WS-TEXT) " op " FUNCTION TRIM(WS-EDIT) ";" DELIMITED BY SIZE
         INTO WS-TEXT
     CALL "CORE-STATUS-GET" USING CORE-STATUS
     MOVE CST-PLAYERS-ONLINE TO WS-EDIT
     STRING FUNCTION TRIM(WS-TEXT) " online " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
         INTO WS-TEXT.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 END PROGRAM ACC-US17-GUESTS.

 COPY CORETEST.
