*> Implementation test (wrap I2 round 5, T24090; docs/protocol/44-residual-mob-questions-7-aquatic.md section 10.1, row Leashing): a nautilus can be leashed unless it is aggravated (an ANGRY_AT or an
*> ATTACK_TARGET memory: EN-ANGER above 0 or an EN-FOE); a zombie nautilus unless aggravated or mob-controlled (its first passenger is a mob: EN-PASS above 0). A lead from a player in reach holds a
*> calm one.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NAUTILUS-LEASH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-KEY24               PIC X(24).
 01 WS-M                   BINARY-LONG.
 01 WS-NAU                 BINARY-LONG.
 01 WS-ZOM                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-CASE                PIC X(200).
 01 WS-EXPECT              BINARY-LONG.
 01 WS-OBSERVE             BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 2
     MOVE "nautilus" TO WS-KEY24
     PERFORM SPAWN-ONE
     MOVE WS-M TO WS-NAU
     MOVE "zombie_nautilus" TO WS-KEY24
     PERFORM SPAWN-ONE
     MOVE WS-M TO WS-ZOM

     CALL "MOB-LEASHABLE" USING WS-NAU WS-OK
     MOVE "implementation 44-7 10.1 a calm nautilus can be leashed" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-OK TO WS-OBSERVE
     PERFORM CHECK
     CALL "MOB-LEASHABLE" USING WS-ZOM WS-OK
     MOVE "implementation 44-7 10.1 a calm zombie nautilus can be leashed" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-OK TO WS-OBSERVE
     PERFORM CHECK

*>   Aggravated: an angry-at memory (EN-ANGER) or an attack target (EN-FOE).
     MOVE 200 TO EN-ANGER(WS-NAU)
     CALL "MOB-LEASHABLE" USING WS-NAU WS-OK
     MOVE "implementation 44-7 10.1 a nautilus with an ANGRY_AT memory cannot be leashed" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-OK TO WS-OBSERVE
     PERFORM CHECK
     MOVE 0 TO EN-ANGER(WS-NAU)
     MOVE WS-ZOM TO EN-FOE(WS-NAU)
     CALL "MOB-LEASHABLE" USING WS-NAU WS-OK
     MOVE "implementation 44-7 10.1 a nautilus with an ATTACK_TARGET cannot be leashed" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-OK TO WS-OBSERVE
     PERFORM CHECK
     MOVE 0 TO EN-FOE(WS-NAU)
     MOVE 200 TO EN-ANGER(WS-ZOM)
     CALL "MOB-LEASHABLE" USING WS-ZOM WS-OK
     MOVE "implementation 44-7 10.1 a zombie nautilus with an ANGRY_AT memory cannot be leashed" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-OK TO WS-OBSERVE
     PERFORM CHECK
     MOVE 0 TO EN-ANGER(WS-ZOM)
     MOVE WS-NAU TO EN-FOE(WS-ZOM)
     CALL "MOB-LEASHABLE" USING WS-ZOM WS-OK
     MOVE "implementation 44-7 10.1 a zombie nautilus with an ATTACK_TARGET cannot be leashed" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-OK TO WS-OBSERVE
     PERFORM CHECK
     MOVE 0 TO EN-FOE(WS-ZOM)

*>   Mob-controlled: a zombie nautilus whose first passenger is a mob (a drowned rider) is refused, a nautilus is not subject to the rule.
     MOVE WS-NAU TO EN-PASS(WS-ZOM)
     CALL "MOB-LEASHABLE" USING WS-ZOM WS-OK
     MOVE "implementation 44-7 10.1 a mob-controlled zombie nautilus cannot be leashed" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-OK TO WS-OBSERVE
     PERFORM CHECK
     MOVE 0 TO EN-PASS(WS-ZOM)
     MOVE WS-ZOM TO EN-PASS(WS-NAU)
     CALL "MOB-LEASHABLE" USING WS-NAU WS-OK
     MOVE "implementation 44-7 10.1 a nautilus carrying a mob can still be leashed" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-OK TO WS-OBSERVE
     PERFORM CHECK
     MOVE 0 TO EN-PASS(WS-NAU)

*>   A lead of a player in reach holds a calm one, not an angry one.
     MOVE 200 TO EN-ANGER(WS-NAU)
     CALL "MOB-LEASH-ATTACH" USING WS-PLAYER WS-NAU WS-OK
     MOVE "implementation 44-7 10.1 the lead is refused by an angry nautilus" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-LEASH(WS-NAU) TO WS-OBSERVE
     PERFORM CHECK
     MOVE 0 TO EN-ANGER(WS-NAU)
     CALL "MOB-LEASH-ATTACH" USING WS-PLAYER WS-NAU WS-OK
     MOVE "implementation 44-7 10.1 the lead of a player in reach holds a calm nautilus" TO WS-CASE
     MOVE WS-PLAYER TO WS-EXPECT
     MOVE EN-LEASH(WS-NAU) TO WS-OBSERVE
     PERFORM CHECK
     STOP RUN.
*> SPAWN-ONE: a mob of the key WS-KEY24 at (x, y, z), its row in WS-M
 SPAWN-ONE.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-KEY24) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-M.
*> CHECK: one numeric assertion of WS-CASE
 CHECK.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-NAUTILUS-LEASH.
 COPY CORETEST.
 COPY MOBSPTEST.
