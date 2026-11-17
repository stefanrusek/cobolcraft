*> Implementation test (coverage lane A; docs/protocol/18 section 8.4, 20 section 7.1; core/src/mob-mount.cob): a skeleton riding a spider counts its attack cooldown down on each tick.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVA-MOUNT.
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
 01 WS-STYPE               BINARY-LONG.
 01 WS-KTYPE               BINARY-LONG.
 01 WS-SPIDER              BINARY-LONG.
 01 WS-RIDER               BINARY-LONG.
 01 WS-MOUNTED             BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:spider" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-STYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:skeleton" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-KTYPE WS-ENTITY-ROW WS-STATUS
     MOVE 100 TO WS-X
     MOVE 150 TO WS-Y
     MOVE 100 TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-STYPE WS-X WS-Y WS-Z WS-YAW WS-SPIDER
     CALL "MOB-SPAWN" USING WS-DIM WS-KTYPE WS-X WS-Y WS-Z WS-YAW WS-RIDER
     CALL "MOB-MOUNT" USING WS-RIDER WS-SPIDER WS-MOUNTED
     MOVE 5 TO EN-COOLDOWN(WS-RIDER)
     CALL "MOB-MOUNT-STEP" USING WS-RIDER WS-DONE
     MOVE "test cova mount a skeleton on a spider counts its cooldown down by one" TO WS-CASE
     MOVE 4 TO WS-E
     MOVE EN-COOLDOWN(WS-RIDER) TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-COVA-MOUNT.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY COVATEST.
