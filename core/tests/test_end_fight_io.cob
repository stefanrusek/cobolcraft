*> Implementation test of the saved dragon fight state in a world (core/src/end-fight-io.cob; docs/protocol/45-entity-nbt-9 section 3, 38 section 1; T1757 persistence): a standard world
*> with the End holds a fight record (a new End's gateway order is the seeded shuffle of 0 to 19), WORLD-SAVE writes it to <world>/dimensions/minecraft/the_end/data/minecraft/ender_dragon_fight.dat,
*> a forgotten record is read back from that file with the dragon_killed flag and the portal location a change made, and a world without the file gets the default (needs_state_scanning).
*> Needs the generated packs (a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-END-FIGHT-IO.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY ENDFIGHT.
 01 WS-SKIP                BINARY-LONG.
 01 WS-GET                 BINARY-LONG VALUE 3.
 01 WS-SET                 BINARY-LONG VALUE 4.
 01 WS-FORGET              BINARY-LONG VALUE 5.
 01 WS-LOAD                BINARY-LONG VALUE 1.
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-ED                  PIC -(7)9.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "acceptance US12 45§3 fight state file: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "END-FIGHT-IO" USING WS-FORGET END-FIGHT
     CALL "END-FIGHT-IO" USING WS-LOAD END-FIGHT
     CALL "END-FIGHT-IO" USING WS-GET END-FIGHT
     MOVE "acceptance US12 45§3 fight state file: a new End starts with needs_state_scanning and the 20 gateways" TO TL-CASE
     COMPUTE TL-OBSERVED-N = EF-GATEWAY-COUNT * 10 + EF-SCAN
     COMPUTE TL-EXPECTED-N = 201
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 1 TO EF-KILLED
     MOVE 1 TO EF-HAS-PORTAL
     MOVE 0 TO EF-PORTAL(1)
     MOVE 61 TO EF-PORTAL(2)
     MOVE 0 TO EF-PORTAL(3)
     CALL "END-FIGHT-IO" USING WS-SET END-FIGHT
     CALL "WORLD-SAVE"
     MOVE SPACES TO WS-FILE
     STRING CW-FOLDER(1:CW-FOLDER-LENGTH) "/dimensions/minecraft/the_end/data/minecraft/ender_dragon_fight.dat" X"00"
         DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     MOVE "acceptance US12 45§3 fight state file: WORLD-SAVE wrote ender_dragon_fight.dat in the End's data folder" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RETURN-CODE TO TL-OBSERVED-N
     MOVE 0 TO RETURN-CODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "END-FIGHT-IO" USING WS-FORGET END-FIGHT
     CALL "END-FIGHT-IO" USING WS-LOAD END-FIGHT
     INITIALIZE END-FIGHT
     CALL "END-FIGHT-IO" USING WS-GET END-FIGHT
     MOVE "acceptance US12 45§3 fight state file: the record read back keeps dragon_killed, the portal y 61 and the 20 gateways" TO TL-CASE
     COMPUTE TL-OBSERVED-N = EF-KILLED * 10000 + EF-PORTAL(2) * 100 + EF-GATEWAY-COUNT
     MOVE 16120 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-END-FIGHT-IO.

 COPY CORETEST.
 COPY PORTALTEST.
