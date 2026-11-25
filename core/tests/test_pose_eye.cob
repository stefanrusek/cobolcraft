*> Implementation test of the server's eye height per pose (CC-0010; docs/protocol/53 sections 2.1 and 7: the entity's own eye height is "what the server and the
*> picking ray use"; core/src/poses.cob POSE-EYE, health.cob HEALTH-ATTACK): standing 1.62 and crouching 1.27 with a standard content set, 1.6 and 1.25 with
*> the cobolcraft stand-in set, swimming or crawling and fall flying 0.4, sleeping 0.2; an Attack on a chicken (0.7 high) whose box edge is 3.95 blocks away
*> level with the feet is out of reach from a standing eye (1.62 above the feet) and in reach from the eye of a crawling or swimming player (0.4).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-POSE-EYE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
 COPY PROTO.
 COPY RULES.
 COPY BRWORLD.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16) VALUE "Stefan".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 6.
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CHICKEN             BINARY-LONG.
 01 WS-CHICKEN-TYPE        BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-DIM                 BINARY-LONG.
 01 WS-EYE                 FLOAT-LONG.
 01 WS-POSE                BINARY-LONG.
 01 WS-HEALTH              BINARY-LONG.
 01 WS-SHOW                PIC -(2)9.99.
 01 WS-SHOWS               PIC X(60).
 01 WS-PTR                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM

*>   The stand-in set (the world opened as one): 1.6, 1.25 crouching, 0.4 swimming and fall flying, 0.2 sleeping.
     PERFORM EYES
     MOVE "test pose eye: the cobolcraft stand-in set has the eye at 1.60 standing, 1.25 crouching, 0.40 swimming, 0.40 gliding, 0.20 sleeping" TO TL-CASE
     MOVE "   1.60   1.25   0.40   0.40   0.20" TO TL-EXPECTED
     MOVE WS-SHOWS TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A standard set: 1.62, 1.27 crouching, the rest as before.
     CALL "TEST-STANDARD-TABLES"
     PERFORM EYES
     MOVE "test pose eye: a standard set has the eye at 1.62 standing, 1.27 crouching, 0.40 swimming, 0.40 gliding, 0.20 sleeping" TO TL-CASE
     MOVE "   1.62   1.27   0.40   0.40   0.20" TO TL-EXPECTED
     MOVE WS-SHOWS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Attack reach: a chicken at the same level as the feet, its box edge 3.95 blocks from the player (reach 4.0).
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE "minecraft:chicken" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-CHICKEN-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-X = WS-X + 4.15
     MOVE 18000 TO CW-TIME
     CALL "MOB-SPAWN" USING WS-DIM WS-CHICKEN-TYPE WS-X WS-Y WS-Z WS-YAW WS-CHICKEN
     MOVE EN-ID(WS-CHICKEN) TO WS-ID
     MOVE EN-HEALTH(WS-CHICKEN) TO WS-HEALTH
     MOVE "N" TO TL-MODE

     MOVE 0 TO PL-POSE(WS-PLAYER)
     CALL "TEST-ATTACK" USING WS-CONN WS-ID
     MOVE "test pose eye: a standing player (eye 1.62) is out of reach of a chicken whose box edge is 3.95 away level with the feet: health unchanged" TO TL-CASE
     MOVE WS-HEALTH TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-CHICKEN) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 3 TO PL-POSE(WS-PLAYER)
     CALL "TEST-ATTACK" USING WS-CONN WS-ID
     MOVE "test pose eye: a crawling or swimming player (eye 0.4) reaches the same chicken: it is hurt" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-HEALTH(WS-CHICKEN) < WS-HEALTH
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 EYES.
     MOVE SPACES TO WS-SHOWS
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-POSE FROM 1 BY 1 UNTIL WS-POSE > 5
         EVALUATE WS-POSE
             WHEN 1
                 MOVE 0 TO PL-POSE(WS-PLAYER)
             WHEN 2
                 MOVE 5 TO PL-POSE(WS-PLAYER)
             WHEN 3
                 MOVE 3 TO PL-POSE(WS-PLAYER)
             WHEN 4
                 MOVE 1 TO PL-POSE(WS-PLAYER)
             WHEN OTHER
                 MOVE 2 TO PL-POSE(WS-PLAYER)
         END-EVALUATE
         CALL "POSE-EYE" USING WS-PLAYER WS-EYE
         COMPUTE WS-SHOW ROUNDED = WS-EYE
         STRING " " WS-SHOW DELIMITED BY SIZE INTO WS-SHOWS WITH POINTER WS-PTR
     END-PERFORM
     MOVE 0 TO PL-POSE(WS-PLAYER).
 END PROGRAM TEST-POSE-EYE.
 COPY CORETEST.
