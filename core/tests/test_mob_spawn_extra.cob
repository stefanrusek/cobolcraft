*> Implementation test of mob spawning in the extra dimension (core/src/mobs.cob, core/copy/MOBS.cpy;
*> standin-content §12.4, §15.4; tasks T1070): in cobolcraft:subroutine (dimension index 1) only
*> abends spawn, at any time of day, on slag in block light 5 or less; sodgrazers never spawn there.
*> Expected columns were computed from the §1.4.1 hash H, the §15.2 floor formula and the §5.2 block
*> light rule (breadth-first through void from the marker glowtubes), independently of the code: Alice
*> at (40.5, 35, 40.5) in the Subroutine gives at Time 100 (day) r = H(1, 40, 40, 100): dx -9, dz -18,
*> column (31, 22), slag at 32, light 0, yaw 0; at 16100 (night) column (36, 58), slag at 32, yaw 135;
*> at 2100 column (51, 55), light 9 at y 35 from the marker of chunk (3, 3) (no spawn); at 3000
*> column (59, 49), slag at 35, light 4 (spawns, yaw 270). Bob at the main spawn point gives at Time
*> 100 the sodgrazer column (23, 19) of acc_us9_spawning (main is unchanged). MOBS-SPAWN-TICK is
*> called directly; the players' chunks are loaded first. Mobs are listed as
*> "<dimension row>:<type>@<x>,<y>,<z> yaw <yaw>".
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-SPAWN-EXTRA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY ENTITYTYPES.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CHUNK               BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-F1                  PIC -(5)9.99.
 01 WS-F2                  PIC -(5)9.99.
 01 WS-F3                  PIC -(5)9.99.
 01 WS-E3                  PIC -(9)9.
 01 WS-TEXT                PIC X(1024).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 1 TO CS-EXTRA-DIMENSIONS

     MOVE "test mob spawn extra given Alice in cobolcraft:subroutine by day (Time 100) then an "
         & "abend, not a sodgrazer, spawns on the slag of column (31, 22) with yaw 0" TO TL-CASE
     PERFORM OPEN-AND-ENTER
     MOVE 100 TO CW-TIME
     PERFORM SPAWN-AND-LIST
     MOVE "2:3@31.50,33.00,22.50 yaw 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test mob spawn extra given Alice in cobolcraft:subroutine at night (Time 16100) then an "
         & "abend spawns on the slag of column (36, 58) with yaw 135" TO TL-CASE
     PERFORM OPEN-AND-ENTER
     MOVE 16100 TO CW-TIME
     PERFORM SPAWN-AND-LIST
     MOVE "2:3@36.50,33.00,58.50 yaw 135" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test mob spawn extra given the chosen column's top block is greystone, not slag (Time "
         & "100), then nothing spawns" TO TL-CASE
     PERFORM OPEN-AND-ENTER
     MOVE DIM-SUBROUTINE TO WS-DIM
     MOVE 31 TO WS-BX
     MOVE 32 TO WS-BY
     MOVE 22 TO WS-BZ
     MOVE 2 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 100 TO CW-TIME
     PERFORM SPAWN-AND-LIST
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test mob spawn extra given the chosen column (51, 55) is in block light 9 from a marker "
         & "glowtube (Time 2100) then nothing spawns" TO TL-CASE
     PERFORM OPEN-AND-ENTER
     MOVE 2100 TO CW-TIME
     PERFORM SPAWN-AND-LIST
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test mob spawn extra given the chosen column (59, 49) is in block light 4 (Time 3000) "
         & "then an abend spawns there with yaw 270" TO TL-CASE
     PERFORM OPEN-AND-ENTER
     MOVE 3000 TO CW-TIME
     PERFORM SPAWN-AND-LIST
     MOVE "2:3@59.50,36.00,49.50 yaw 270" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test mob spawn extra given Alice in the Subroutine and Bob in cobolcraft:main by day "
         & "(Time 100) then each dimension gets its own rule's mob" TO TL-CASE
     PERFORM OPEN-AND-ENTER
     MOVE "Bob" TO WS-NAME
     MOVE 3 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-BOB
     MOVE 5 TO WS-NAME-LENGTH
     MOVE 100 TO CW-TIME
     PERFORM SPAWN-AND-LIST
     MOVE "1:2@23.50,57.00,19.50 yaw 180 2:3@31.50,33.00,22.50 yaw 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test mob spawn extra given hostile-mobs off then nothing spawns in the Subroutine "
         & "(Time 100)" TO TL-CASE
     MOVE 0 TO CS-HOSTILE-MOBS
     PERFORM OPEN-AND-ENTER
     MOVE 100 TO CW-TIME
     PERFORM SPAWN-AND-LIST
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> Opens the world (extra dimensions on); creative Alice joins and is put in cobolcraft:subroutine
*> at (40.5, 35, 40.5); the Subroutine chunks (0..4, 0..4) are loaded.
 OPEN-AND-ENTER.
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE DIM-SUBROUTINE TO PL-DIM(WS-ROW) EN-DIM(PL-ENTITY-ROW(WS-ROW))
     MOVE 40.5 TO PL-X(WS-ROW) PL-Z(WS-ROW)
     MOVE 35 TO PL-Y(WS-ROW)
     MOVE DIM-SUBROUTINE TO WS-DIM
     PERFORM VARYING WS-CX FROM 0 BY 1 UNTIL WS-CX > 4
         PERFORM VARYING WS-CZ FROM 0 BY 1 UNTIL WS-CZ > 4
             CALL "WORLD-CHUNK" USING WS-DIM WS-CX WS-CZ WS-CHUNK
         END-PERFORM
     END-PERFORM.

*> One spawn pass at CW-TIME, then the mobs of every dimension.
 SPAWN-AND-LIST.
     CALL "MOBS-SPAWN-TICK"
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-DIM FROM 1 BY 1 UNTIL WS-DIM > DIM-TABLE-ROWS
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
             IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) >= ET-SODGRAZER AND EN-DIM(WS-E) = WS-DIM
                 MOVE EN-DIM(WS-E) TO WS-E1
                 MOVE EN-TYPE(WS-E) TO WS-E2
                 COMPUTE WS-F1 ROUNDED = EN-X(WS-E)
                 COMPUTE WS-F2 ROUNDED = EN-Y(WS-E)
                 COMPUTE WS-F3 ROUNDED = EN-Z(WS-E)
                 MOVE EN-YAW(WS-E) TO WS-E3
                 STRING FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) "@" FUNCTION TRIM(WS-F1) ","
                     FUNCTION TRIM(WS-F2) "," FUNCTION TRIM(WS-F3) " yaw " FUNCTION TRIM(WS-E3) " "
                     DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
             END-IF
         END-PERFORM
     END-PERFORM.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-SPAWN-EXTRA.

 COPY CORETEST.
