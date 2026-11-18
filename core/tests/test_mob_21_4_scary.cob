*> Acceptance test (US15, FR-036, SC-008; docs/protocol/21 section 4.3 with the tag not_scary_for_pufferfish of 3.6): the scary-mob test of the pufferfish for mobs. A mob that is a living entity of the
*> world and whose type is not in the tag (a pig) within 2 blocks of its box starts the puff goal; the members of the tag (cod, squid, dolphin, glow squid, guardian, nautilus, turtle) do not;
*> a state above 0 stings a mob whose box meets its box inflated by 0.3 (1 + state damage, Poison for 60 x state ticks) and not one 2 blocks away.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-4-SCARY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-PUFFER              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-OTHER               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-POISON              BINARY-LONG VALUE 18.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-NAMES.
    05 FILLER PIC X(24) VALUE "cod".
    05 FILLER PIC X(24) VALUE "squid".
    05 FILLER PIC X(24) VALUE "dolphin".
    05 FILLER PIC X(24) VALUE "glow_squid".
    05 FILLER PIC X(24) VALUE "guardian".
    05 FILLER PIC X(24) VALUE "nautilus".
    05 FILLER PIC X(24) VALUE "turtle".
 01 WS-NAME-TABLE REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(24) OCCURS 7 TIMES.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     CALL "AQ-TEST-TANK" USING WS-PLAYER WS-DIM WS-X0 WS-Y0 WS-Z0
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:pufferfish" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-PUFFER WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-Y = WS-Y0 + 3.5
     COMPUTE WS-Z = WS-Z0 + 5.5
*>   The members of the tag next to it (2 blocks away) leave it deflated.
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 7
         COMPUTE WS-X = WS-X0 + 5.5
         CALL "MOB-SPAWN" USING WS-DIM WS-PUFFER WS-X WS-Y WS-Z WS-YAW WS-ROW
         MOVE SPACES TO WS-KEY
         STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-NAME(WS-S)) DELIMITED BY SIZE INTO WS-KEY
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
         COMPUTE WS-X = WS-X0 + 7.5
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-OTHER
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
             ADD 1 TO CW-TIME
             CALL "MOB-STEP" USING WS-ROW
         END-PERFORM
         MOVE SPACES TO TL-CASE
         STRING "acceptance US15 3.6 a " DELIMITED BY SIZE FUNCTION TRIM(WS-NAME(WS-S)) DELIMITED BY SIZE
             " (tag not_scary_for_pufferfish) does not make a pufferfish puff" DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO TL-EXPECTED-N
         MOVE EN-VARIANT(WS-ROW) TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         CALL "ENTITY-REMOVE" USING WS-OTHER
         CALL "ENTITY-REMOVE" USING WS-ROW
     END-PERFORM
*>   A pig 2 blocks away is scary: puff, no sting.
     COMPUTE WS-X = WS-X0 + 5.5
     CALL "MOB-SPAWN" USING WS-DIM WS-PUFFER WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:pig" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = WS-X0 + 7.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-OTHER
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance US15 21§4.3 a pig within 2 blocks makes the pufferfish puff to state 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-VARIANT(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 45
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 21§4.3 and to state 2 after 41 ticks" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE EN-VARIANT(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE "acceptance US15 21§4.3 a mob 2 blocks away is not stung (pig health 10)" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-OTHER) TO TL-OBSERVED-N
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-OTHER
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   A pig on the pufferfish: stung for 1 + state = 2 (state 1 on the first tick) and poisoned for 60 x state ticks.
     COMPUTE WS-X = WS-X0 + 5.5
     CALL "MOB-SPAWN" USING WS-DIM WS-PUFFER WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-OTHER
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance US15 21§4.3 a pig touching the pufferfish takes 1 + state damage (10 to 8)" TO TL-CASE
     MOVE 8 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-OTHER) TO TL-OBSERVED-N
     PERFORM CHECK-N
     CALL "MEF-LEVEL" USING EN-ID(WS-OTHER) WS-POISON WS-LEVEL WS-TICKS
     MOVE "acceptance US15 21§4.3 and Poison amplifier 0 for 60 x state ticks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-LEVEL = 1 AND WS-TICKS = 60
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     STOP RUN.
 CHECK-N.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-21-4-SCARY.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY AQUATEST.
