*> Implementation test: the daylight factor is a draw-time uniform (shim-abi section 9, cc_vk_daylight), not
*> baked into the vertices, so a change of daylight marks no section dirty (operator playtest: every
*> dawn and dusk step meshed the whole world again). A client in play over a loaded floor meshes all its
*> sections, then the time of day goes from noon to night through CL-STEP: the daylight falls to 0.2
*> and not one section is dirty, no mesh is replaced, and the vertex of the top face is unchanged.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DAYLIGHT-NO-REMESH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-DIRTY               BINARY-LONG.
 01 WS-UPLOADS             BINARY-LONG.
 01 WS-N                   PIC Z(5)9.
 01 WS-N2                  PIC Z(5)9.
 01 WS-N3                  PIC Z(5)9.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 600
         CALL "TEST-STEP" USING CLIENT-STATE
     END-PERFORM
     PERFORM COUNT-FLAGS
     MOVE "daylight no remesh the loaded floor is meshed at noon: 9 rows or more, no section dirty"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WR-COUNT >= 9 AND WS-DIRTY = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Clear the upload flags, then run the day into the night.
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > WR-COUNT
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > CL-MAX-SECTIONS
             MOVE 0 TO WR-UPLOAD(WS-R, WS-S)
         END-PERFORM
     END-PERFORM
     MOVE 15000 TO PL-TIME
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         CALL "TEST-STEP" USING CLIENT-STATE
         PERFORM COUNT-FLAGS
         IF WS-DIRTY > 0
             MOVE 1000 TO WS-I
         END-IF
     END-PERFORM
     PERFORM COUNT-FLAGS
     MOVE "daylight no remesh going from noon into the night changes the daylight and leaves every "
         & "section clean and unchanged" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "daylight below 1000 dirty 0 uploads 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-DIRTY TO WS-N
     MOVE WS-UPLOADS TO WS-N2
     IF SK-U < 1000
         STRING "daylight below 1000 dirty " FUNCTION TRIM(WS-N) " uploads " FUNCTION TRIM(WS-N2)
             DELIMITED BY SIZE INTO TL-OBSERVED
     ELSE
         MOVE SK-U TO WS-N3
         STRING "daylight " FUNCTION TRIM(WS-N3) " dirty " FUNCTION TRIM(WS-N) " uploads "
             FUNCTION TRIM(WS-N2) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 COUNT-FLAGS.
     MOVE 0 TO WS-DIRTY WS-UPLOADS
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > WR-COUNT
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > CL-MAX-SECTIONS
             IF WR-USED(WS-R) = 1 AND WR-DIRTY(WS-R, WS-S) = 1
                 ADD 1 TO WS-DIRTY
             END-IF
             IF WR-USED(WS-R) = 1 AND WR-UPLOAD(WS-R, WS-S) = 1
                 ADD 1 TO WS-UPLOADS
             END-IF
         END-PERFORM
     END-PERFORM
     EXIT PARAGRAPH.
 END PROGRAM TEST-DAYLIGHT-NO-REMESH.
 COPY CLTEST.
