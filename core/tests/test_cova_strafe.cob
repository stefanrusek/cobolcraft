*> Implementation test (coverage lane A; docs/protocol/20 section 5; core/src/arrows.cob STDMOB-SHOOT): a skeleton that keeps a player in sight within 15 blocks strafes, and over many
*> ticks it reverses its circling direction (a draw below 0.3 flips it every 20 strafe ticks), so both directions are seen.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVA-STRAFE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SEEN0               BINARY-LONG.
 01 WS-SEEN1               BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 40.
 01 WS-KIND1               BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 20
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 20
     COMPUTE WS-FLOOR = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FLOOR WS-KIND1
     MOVE "minecraft:skeleton" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-X = WS-X + 8
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "STDMOB-INDEX" USING WS-TYPE WS-M
     MOVE WS-PLAYER TO EN-TARGET(WS-ROW)
     MOVE 0 TO WS-SEEN0 WS-SEEN1
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1500
         MOVE WS-X TO EN-X(WS-ROW)
         MOVE WS-Z TO EN-Z(WS-ROW)
         CALL "STDMOB-SHOOT" USING WS-ROW WS-M WS-STOP
         IF EN-STRAFE-CW(WS-ROW) = 0
             MOVE 1 TO WS-SEEN0
         ELSE
             MOVE 1 TO WS-SEEN1
         END-IF
     END-PERFORM
     MOVE "test cova strafe a skeleton in sight circles both ways over many ticks" TO WS-CASE
     MOVE 2 TO WS-E
     COMPUTE WS-O = WS-SEEN0 + WS-SEEN1
     CALL "CA-N" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-COVA-STRAFE.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY COVATEST.
