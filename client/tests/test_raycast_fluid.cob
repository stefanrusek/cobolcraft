*> Implementation test of RAYCAST (client/src/raycast.cob) over fluids (29a section 1.2: a liquid block has no outline shape, so a ray for blocks passes
*> through water and lava and hits what lies behind): looking straight down at a water cell over stone hits the stone (y 9) with the up face; a wet
*> plant (kind 3) and a waterlogged block (kind 4) are hit themselves (y 10).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-RAYCAST-FLUID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-X                   BINARY-LONG VALUE 0.
 01 WS-Y                   BINARY-LONG VALUE 10.
 01 WS-Z                   BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG VALUE 4.
 01 WS-K                   BINARY-LONG.
 01 WS-E                   PIC -(3)9.
 01 WS-F                   PIC -(3)9.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
     MOVE 0 TO ST-OPAQUE(5)
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE 90 TO PL-PITCH
     MOVE 0.5 TO PL-X PL-Z
     MOVE 10 TO PL-Y
     MOVE "T" TO TL-MODE
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         MOVE 0 TO ST-FLUID(5)
         EVALUATE WS-K
             WHEN 1 MOVE 1 TO ST-FLUID(5)
             WHEN 2 MOVE 2 TO ST-FLUID(5)
             WHEN 3 MOVE 3 TO ST-FLUID(5)
             WHEN OTHER MOVE 4 TO ST-FLUID(5)
         END-EVALUATE
         CALL "RAYCAST" USING CLIENT-STATE
         MOVE TG-Y TO WS-E
         MOVE SPACES TO TL-OBSERVED
         MOVE TG-FACE TO WS-F
         STRING TG-HIT " " FUNCTION TRIM(WS-E) " " FUNCTION TRIM(WS-F) DELIMITED BY SIZE INTO TL-OBSERVED
         EVALUATE WS-K
             WHEN 1
                 MOVE "raycast fluid a ray down through water hits the stone under it (y 9, the top face as for any block)" TO TL-CASE
                 MOVE "1 9 1" TO TL-EXPECTED
             WHEN 2
                 MOVE "raycast fluid a ray down through lava hits the stone under it" TO TL-CASE
                 MOVE "1 9 1" TO TL-EXPECTED
             WHEN 3
                 MOVE "raycast fluid a wet plant (kind 3) is hit itself (y 10)" TO TL-CASE
                 MOVE "1 10 1" TO TL-EXPECTED
             WHEN OTHER
                 MOVE "raycast fluid a waterlogged block (kind 4) is hit itself (y 10)" TO TL-CASE
                 MOVE "1 10 1" TO TL-EXPECTED
         END-EVALUATE
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-RAYCAST-FLUID.
 COPY CLTEST.
