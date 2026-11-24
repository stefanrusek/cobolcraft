*> Acceptance test of docs/protocol/43-tint-sources.md section 9 (team colours): the 16 rows in enum
*> order, ids 0 to 15, as the value of the matching chat text colour.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TINT-43-9.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-TEAMS               PIC X(96) VALUE
     "0000000000AA00AA0000AAAAAA0000AA00AAFFAA00AAAAAA5555555555FF55FF5555FFFFFF5555FF55FFFFFF55FFFFFF".
 01 WS-TEAMS-R REDEFINES WS-TEAMS.
    05 WS-TEAM             PIC X(6) OCCURS 16 TIMES.
 01 WS-NAMES               PIC X(240) VALUE
     "black          dark_blue      dark_green     dark_aqua      " &
     "dark_red       dark_purple    gold           gray           " &
     "dark_gray      blue           green          aqua           " &
     "red            light_purple   yellow         white          ".
 01 WS-NAMES-R REDEFINES WS-NAMES.
    05 WS-TNAME            PIC X(15) OCCURS 16 TIMES.
 01 WS-ID                  BINARY-LONG.
 01 WS-COLOUR              BINARY-DOUBLE.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              PIC X(8).
 01 WS-DI                  PIC 99.
 01 WS-OUT                 BINARY-LONG.
 01 WS-NAME                PIC X(15).
 PROCEDURE DIVISION.
     PERFORM VARYING WS-ID FROM 0 BY 1 UNTIL WS-ID > 15
         MOVE WS-ID TO WS-DI
         CALL "TINT-TEAM" USING WS-ID WS-COLOUR
         MOVE SPACES TO WS-CASE WS-EXPECT
         STRING "acceptance US11 43§9 Team colours: team " WS-DI DELIMITED BY SIZE INTO WS-CASE
         STRING "00" WS-TEAM(WS-ID + 1) DELIMITED BY SIZE INTO WS-EXPECT
         CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
         MOVE WS-TNAME(WS-ID + 1) TO WS-NAME
         CALL "TINT-TEAM-ID" USING WS-NAME WS-OUT
         MOVE WS-OUT TO TL-OBSERVED-N
         MOVE "acceptance US11 43§9 Team colours: the name gives the id" TO TL-CASE
         MOVE "N" TO TL-MODE
         MOVE WS-ID TO TL-EXPECTED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     MOVE 16 TO WS-ID
     CALL "TINT-TEAM" USING WS-ID WS-COLOUR
     MOVE "acceptance US11 43§9 Team colours: id 16 is none (-1)" TO WS-CASE
     MOVE "FFFFFFFF" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
     MOVE "reset" TO WS-NAME
     CALL "TINT-TEAM-ID" USING WS-NAME WS-OUT
         MOVE WS-OUT TO TL-OBSERVED-N
     MOVE "acceptance US11 43§9 Team colours: an unknown name has no id" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-TINT-43-9.
 COPY TINTTEST.
