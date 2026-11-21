*> Implementation test (coverage lane A; core/src/health.cob, mob-20-creeper.cob, thrown-44b.cob): a dragon and a minecart hurt through the generic mob damage are handled by their own rules, a
*> creeper cloud made while the projectile table is full leaves no cloud, an eye of ender cannot be spawned then, and the step of a row that is no eye does nothing.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVA-MISC1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROJSTATE.
 COPY DRAGSTATE.
 COPY RULES.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-PROW                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-CTYPE               BINARY-LONG.
 01 WS-CROW                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-TX                  FLOAT-LONG VALUE 100.
 01 WS-TY                  FLOAT-LONG VALUE 150.
 01 WS-TZ                  FLOAT-LONG VALUE 100.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-DMG                 BINARY-LONG VALUE 5.
 01 WS-CAUSE               BINARY-LONG VALUE CAUSE-MOB.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-KIND1               BINARY-LONG VALUE 1.
 01 WS-SURVIVES            BINARY-LONG VALUE 1.
 01 WS-EFFECT              BINARY-LONG VALUE 1.
 01 WS-AMP                 BINARY-LONG VALUE 0.
 01 WS-DUR                 BINARY-LONG VALUE 600.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-HP0                 FLOAT-LONG.
 01 WS-CLOUDS0             BINARY-LONG.
 01 WS-CLOUDS1             BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-ENTITY-ROW(WS-PLAYER) TO WS-PROW
     MOVE 0 TO WS-X
     MOVE 150 TO WS-Y
     MOVE 0 TO WS-Z
*>   The dragon takes damage through its own rule.
     CALL "DRAGON-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-ROW
     MOVE DG-HP TO WS-HP0
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-DMG WS-CAUSE WS-NONE
     MOVE "test cova misc1 damage dealt to the dragon through the generic path is its own health rule (not more than before)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF DG-HP <= WS-HP0
         MOVE 1 TO WS-O
     END-IF
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   A minecart is shaken (hurt time 10) by the same path.
     COMPUTE WS-X = 20
     CALL "MINECART-SPAWN" USING WS-KIND1 WS-DIM WS-X WS-Y WS-Z WS-CROW
     CALL "PJ-FIND" USING EN-ID(WS-CROW) WS-SLOT
     CALL "HEALTH-MOB-DAMAGE" USING WS-CROW WS-ONE WS-CAUSE WS-NONE
     MOVE "test cova misc1 damage dealt to a minecart through the generic path shakes it (hurt time 10)" TO WS-CASE
     MOVE 10 TO WS-E
     MOVE PJ-I4(WS-SLOT) TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   A poisoned creeper's cloud cannot be made while the projectile table is full.
     MOVE "minecraft:creeper" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-CTYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = 40
     CALL "MOB-SPAWN" USING WS-DIM WS-CTYPE WS-X WS-Y WS-Z WS-YAW WS-CROW
     CALL "MEF-ADD" USING EN-ID(WS-CROW) WS-EFFECT WS-AMP WS-DUR WS-FLAGS
     MOVE 0 TO WS-CLOUDS0
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         MOVE 900000 TO PJ-ENT(WS-I)
         ADD WS-I TO PJ-ENT(WS-I)
     END-PERFORM
     CALL "CREEPER-CLOUD" USING WS-CROW
     MOVE "test cova misc1 a creeper cloud with a full projectile table makes no cloud" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE 0 TO WS-O
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         IF PJ-ENT(WS-I) > 0 AND PJ-ENT(WS-I) < 900000
             ADD 1 TO WS-O
         END-IF
     END-PERFORM
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   An eye of ender cannot be spawned either.
     CALL "EYE-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-TX WS-TY WS-TZ WS-SURVIVES WS-NONE WS-ROW
     MOVE "test cova misc1 an eye of ender cannot be spawned with a full projectile table" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-ROW TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         MOVE 0 TO PJ-ENT(WS-I)
     END-PERFORM
     CALL "EYE-STEP" USING WS-PROW
     MOVE "test cova misc1 the eye step of a row that is no eye does nothing" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE EN-USED(WS-PROW) TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-COVA-MISC1.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY COVATEST.
