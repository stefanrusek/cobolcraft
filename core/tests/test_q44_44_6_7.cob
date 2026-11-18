*> Zombification (docs/protocol/44-residual-mob-questions-6-nether.md section 7; lane 002-lane-p49c, T15500): piglins and hoglins convert where the
*> piglins_zombify attribute holds (everywhere but the Nether), after more than 300 AI steps, with the immunity flag off; finishConversion runs whatever
*> the difficulty (only the sound is gated by Peaceful), so a Peaceful world converts too.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-6-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY BRWORLD.
 COPY DIMENSIONS.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-HTYPE               BINARY-LONG.
 01 WS-ZGTYPE              BINARY-LONG.
 01 WS-P2                  BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-DIM-SAVED           BINARY-LONG.
 01 WS-NETHER              BINARY-LONG VALUE 0.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-E1                  PIC 9.
 01 WS-E2                  PIC 999.
 01 WS-E3                  PIC 9.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE "N" TO TL-MODE
     MOVE "piglin" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "hoglin" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-HTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "zoglin" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZGTYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-ROW) TO WS-X
     MOVE PL-Y(WS-ROW) TO WS-Y
     MOVE PL-Z(WS-ROW) TO WS-Z
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 5
         IF DM-KEY(WS-D) = "minecraft:the_nether"
             MOVE WS-D TO WS-NETHER
         END-IF
     END-PERFORM
*>   Peaceful: the conversion still runs on the 301st step.
     CALL "BR-WORLD-READY"
     MOVE 0 TO BW-DIFFICULTY
     CALL "MOB-SPAWN" USING PL-DIM(WS-ROW) WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-P2
     PERFORM 300 TIMES
         CALL "PIGLIN-ZOMBIFY" USING WS-P2 WS-DONE
     END-PERFORM
     MOVE "acceptance US15 44-6§7 Zombification peaceful: 300 steps do not convert" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-DONE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PIGLIN-ZOMBIFY" USING WS-P2 WS-DONE
     MOVE "acceptance US15 44-6§7 Zombification peaceful: the 301st step converts (only the sound is gated)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-DONE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Peaceful hoglin the same.
     CALL "MOB-SPAWN" USING PL-DIM(WS-ROW) WS-HTYPE WS-X WS-Y WS-Z WS-YAW WS-P2
     PERFORM 301 TIMES
         CALL "PIGLIN-ZOMBIFY" USING WS-P2 WS-DONE
     END-PERFORM
     MOVE "acceptance US15 44-6§7 Zombification peaceful hoglin becomes a zoglin" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-DONE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The Nether: the counter never runs and nothing converts.
     MOVE 2 TO BW-DIFFICULTY
     CALL "MOB-SPAWN" USING PL-DIM(WS-ROW) WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-P2
     MOVE WS-NETHER TO EN-DIM(WS-P2)
     MOVE 200 TO EN-ZOMBIFY(WS-P2)
     PERFORM 400 TIMES
         CALL "PIGLIN-ZOMBIFY" USING WS-P2 WS-DONE
     END-PERFORM
     MOVE "acceptance US15 44-6§7 Zombification in the Nether: no conversion, counter reset" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0 000 1" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-DONE TO WS-E1
     MOVE EN-ZOMBIFY(WS-P2) TO WS-E2
     MOVE EN-USED(WS-P2) TO WS-E3
     STRING WS-E1 " " WS-E2 " " WS-E3 DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
*>   Immune: never converts; the counter resets.
     MOVE PL-DIM(WS-ROW) TO EN-DIM(WS-P2)
     MOVE 1 TO EN-PIG-IMMUNE(WS-P2)
     PERFORM 400 TIMES
         CALL "PIGLIN-ZOMBIFY" USING WS-P2 WS-DONE
     END-PERFORM
     MOVE "acceptance US15 44-6§7 Zombification the immunity flag stops it" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0 000 1" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-DONE TO WS-E1
     MOVE EN-ZOMBIFY(WS-P2) TO WS-E2
     MOVE EN-USED(WS-P2) TO WS-E3
     STRING WS-E1 " " WS-E2 " " WS-E3 DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     STOP RUN.
 END PROGRAM TEST-Q44-44-6-7.
 COPY CORETEST.
