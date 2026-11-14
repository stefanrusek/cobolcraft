*> Implementation test (002-lane-mobsfull-h15; docs/protocol/18 section 3.2 travelInAir, vertical part): a standard mob moves by the velocity it has, then gravity 0.08 is
*> subtracted and the vertical drag 0.98 applied (the stand-in 0.05 and 0.96 stay for the cobolcraft set's mobs, standin section 12.2). A mob resting on a floor keeps
*> the velocity -0.0784 that the blocked move leaves, so it stays on the ground.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-3-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-COW-TYPE            BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 9.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Y0                  FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-HX                  FLOAT-LONG VALUE 0.
 01 WS-HZ                  FLOAT-LONG VALUE 0.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-CASE                PIC X(100).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COW-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FX = WS-BX - 4
     COMPUTE WS-FZ = WS-BZ - 4
     COMPUTE WS-FY = WS-BY - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-KIND
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE WS-Z = WS-BZ + 0.5
     COMPUTE WS-Y0 = WS-BY + 40
     MOVE WS-Y0 TO WS-Y
     CALL "MOB-SPAWN" USING WS-DIM WS-COW-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
*>   Tick 1 moves by 0 and leaves -0.0784; tick 2 moves down 0.0784 and leaves -0.155232; tick 3 moves 0.155232, leaves -0.23052736; tick 4 moves 0.23052736.
     CALL "MOB-PHYSICS" USING WS-ROW WS-HX WS-HZ WS-YAW
     COMPUTE WS-OBS ROUNDED = EN-VY(WS-ROW) * 1000000
     MOVE "acceptance US15 18§3.2 travel: after the first tick the velocity is (0 - 0.08) x 0.98" TO WS-CASE
     MOVE -78400 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     COMPUTE WS-OBS ROUNDED = (WS-Y0 - EN-Y(WS-ROW)) * 1000000
     MOVE "acceptance US15 18§3.2 travel: the first tick moves by the old velocity, 0" TO WS-CASE
     MOVE 0 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "MOB-PHYSICS" USING WS-ROW WS-HX WS-HZ WS-YAW
     COMPUTE WS-OBS ROUNDED = (WS-Y0 - EN-Y(WS-ROW)) * 1000000
     MOVE "acceptance US15 18§3.2 travel: the second tick falls 0.0784" TO WS-CASE
     MOVE 78400 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "MOB-PHYSICS" USING WS-ROW WS-HX WS-HZ WS-YAW
     CALL "MOB-PHYSICS" USING WS-ROW WS-HX WS-HZ WS-YAW
     COMPUTE WS-OBS ROUNDED = (WS-Y0 - EN-Y(WS-ROW)) * 1000000
     MOVE "acceptance US15 18§3.2 travel: four ticks have fallen 0.0784 + 0.155232 + 0.23052736" TO WS-CASE
     MOVE 464159 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     COMPUTE WS-OBS ROUNDED = EN-VY(WS-ROW) * 1000000
     MOVE "acceptance US15 18§3.2 travel: and the velocity is -0.3043168" TO WS-CASE
     MOVE -304317 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   The ground: a mob standing on the floor is on the ground from the second tick on and stays there.
     CALL "ENTITY-REMOVE" USING WS-ROW
     MOVE WS-BY TO WS-Y
     CALL "MOB-SPAWN" USING WS-DIM WS-COW-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         CALL "MOB-PHYSICS" USING WS-ROW WS-HX WS-HZ WS-YAW
     END-PERFORM
     MOVE "acceptance US15 18§3.2 travel: a mob on the floor is on the ground" TO WS-CASE
     MOVE 1 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-ON-GROUND(WS-ROW)
     COMPUTE WS-OBS ROUNDED = (EN-Y(WS-ROW) - WS-BY) * 1000000
     MOVE "acceptance US15 18§3.2 travel: at the height of the floor" TO WS-CASE
     MOVE 0 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     COMPUTE WS-OBS ROUNDED = EN-VY(WS-ROW) * 1000000
     MOVE "acceptance US15 18§3.2 travel: resting leaves the velocity -0.0784" TO WS-CASE
     MOVE -78400 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     STOP RUN.
 END PROGRAM TEST-MOB-18-3-2.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 LINKAGE SECTION.
 01 L-CASE                 PIC X(100).
 01 L-EXPECTED             BINARY-LONG.
 01 L-OBSERVED             BINARY-LONG.
 PROCEDURE DIVISION USING L-CASE L-EXPECTED L-OBSERVED.
     MOVE "N" TO TL-MODE
     MOVE L-CASE TO TL-CASE
     MOVE L-EXPECTED TO TL-EXPECTED-N
     MOVE L-OBSERVED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-CHK.
 COPY CORETEST.
 COPY MOBSPTEST.
