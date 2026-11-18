*> Entity NBT, part 1: the Entity base keys (docs/protocol/45-entity-nbt-1-shared-model-and-entity-base.md section 5; lane 002-lane-p49c, T15560): a saved entity
*> compound holds, after id, Pos, Motion and Rotation, the always-written keys fall_distance (Double), Fire (Short), Air (Short, 300 less the air lost), OnGround (Byte),
*> Invulnerable (Byte), PortalCooldown (Int) and UUID (Int array of 4) in that order; reading it back restores the on-ground flag, the fire ticks, the air lost and the UUID.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-NBT-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY ETIDS.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG VALUE 1.
 01 WS-CZ                  BINARY-LONG VALUE 2.
 01 WS-TYPE                BINARY-LONG.
 01 WS-MOB                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-ROOT                BINARY-LONG.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-ROOT-TYPE           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PATH                PIC X(128).
 01 WS-TEXT                PIC X(8192).
 01 WS-UUID                PIC X(16).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE DIM-MAIN TO WS-DIM
     MOVE ET-SODGRAZER TO WS-TYPE
     MOVE 20.5 TO WS-X MOVE 55 TO WS-Y MOVE 37.25 TO WS-Z
     MOVE 90 TO WS-YAW
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-MOB
     MOVE 1 TO EN-ON-GROUND(WS-MOB)
     MOVE 40 TO EN-BURN(WS-MOB)
     MOVE 60 TO EN-AIR-LOST(WS-MOB)
     MOVE EN-UUID(WS-MOB) TO WS-UUID
     CALL "PB-RESET" USING PB-BUFFER
     CALL "ENTITY-NBT-WRITE" USING WS-DIM WS-CX WS-CZ PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-ROOT-TYPE
     MOVE PB-POS TO WS-ROOT
     MOVE "T" TO TL-MODE
     MOVE "Entities" TO WS-PATH
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-TEXT
     MOVE "acceptance US15 45-1§5 the base keys follow Rotation in the table order, the six always-written ones at their values" TO TL-CASE
     MOVE "[{id:cobolcraft:sodgrazer,Pos:[20.500,55.000,37.250],Motion:[0.000,0.000,0.000],Rotation:[90.000,0.000],fall_distance:0.000,Fire:40,Air:240,OnGround:1,Invulnerable:0,PortalCooldown:0,UUID:I[0,0,0," TO TL-EXPECTED
     MOVE WS-TEXT(1:FUNCTION LENGTH(FUNCTION TRIM(TL-EXPECTED))) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Reading it back restores on-ground, fire, air lost and the UUID.
     MOVE EN-ID(WS-MOB) TO WS-ROW
     CALL "ENTITY-REMOVE" USING WS-MOB
     MOVE 0 TO PB-POS
     CALL "ENTITY-NBT-READ" USING WS-DIM PB-BUFFER WS-OUTCOME
     MOVE 0 TO WS-MOB
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0 AND EN-TYPE(WS-ROW) = WS-TYPE
             MOVE WS-ROW TO WS-MOB
         END-IF
     END-PERFORM
     MOVE "N" TO TL-MODE
     MOVE "acceptance US15 45-1§5 read back: on ground 1, burning 40, air lost 60" TO TL-CASE
     MOVE 1400060 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-ON-GROUND(WS-MOB) * 1000000 + EN-BURN(WS-MOB) * 10000 + EN-AIR-LOST(WS-MOB)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE "acceptance US15 45-1§5 read back: the saved UUID" TO TL-CASE
     MOVE FUNCTION HEX-OF(WS-UUID) TO TL-EXPECTED
     MOVE FUNCTION HEX-OF(EN-UUID(WS-MOB)) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     STOP RUN.
 END PROGRAM TEST-ENTITY-NBT-1.
 COPY CORETEST.
