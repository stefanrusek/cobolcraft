*> The air supply and drowning of a player (docs/protocol/18 section 2.5 item 4, 17 section 4.12, 29a section 8.2 for the eye): BREATH-TICK runs once a
*> tick for every alive player (HEALTH-TICK). A survival player whose eye (feet + 1.6) is inside water loses 1 of the air supply (PL-AIR, 300 at most);
*> at -20 or less it is reset to 0 and the player takes 2 drown damage (HEALTH-DAMAGE, CAUSE-DROWN), so that damage repeats every 20 ticks; out of
*> water the air refills by 4 a tick up to 300. A creative player breathes anywhere (the abilities of a creative player are invulnerable). The player
*> is sent Set Entity Data (slot 1, the Int air) whenever it changed. Not done: the oxygen_bonus and water-breathing rules, bubble columns, the drowning
*> particles (Entity Event 67).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREATH-EYE-IN-WATER.
*> USING player row, in water out (BINARY-LONG 1 or 0): the eye of the player is in the water of its cell: the cell holds water and the eye is not above its
*> surface (the cell's y plus 1 under water, else amount / 9).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-YA                  BINARY-LONG.
 01 WS-EYE                 FLOAT-LONG.
 01 WS-TOP                 FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-FLUID               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-FALLING             BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-HOLDS               BINARY-LONG.
 01 WS-A-FLUID             BINARY-LONG.
 01 WS-SAME                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-IN                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-IN.
     MOVE 0 TO L-IN
     COMPUTE WS-EYE = PL-Y(L-ROW) + 1.6
     COMPUTE WS-X = FUNCTION INTEGER(PL-X(L-ROW))
     COMPUTE WS-Y = FUNCTION INTEGER(WS-EYE)
     COMPUTE WS-Z = FUNCTION INTEGER(PL-Z(L-ROW))
     CALL "FLUID-CELL" USING PL-DIM(L-ROW) WS-X WS-Y WS-Z WS-STATE WS-FLUID WS-KIND WS-AMOUNT WS-FALLING WS-SOLID WS-HOLDS
     IF WS-FLUID = 1
         COMPUTE WS-YA = WS-Y + 1
         CALL "FLUID-CELL" USING PL-DIM(L-ROW) WS-X WS-YA WS-Z WS-STATE WS-A-FLUID WS-KIND WS-AMOUNT WS-FALLING WS-SOLID WS-HOLDS
         MOVE 0 TO WS-SAME
         IF WS-A-FLUID = 1
             MOVE 1 TO WS-SAME
         END-IF
         CALL "FLUID-CELL" USING PL-DIM(L-ROW) WS-X WS-Y WS-Z WS-STATE WS-FLUID WS-KIND WS-AMOUNT WS-FALLING WS-SOLID WS-HOLDS
         CALL "FL-HEIGHT" USING WS-AMOUNT WS-SAME WS-HEIGHT
         COMPUTE WS-TOP = WS-Y + WS-HEIGHT
         IF WS-EYE <= WS-TOP
             MOVE 1 TO L-IN
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BREATH-EYE-IN-WATER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AIR-DATA-BUILD.
*> USING entity id, air (BINARY-LONG), PB-BUFFER: Set Entity Data 0x65 (05b): the entity id, one entry (index 1, serializer 1 Int, the air supply), the 0xFF end.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MD-==.
 01 WS-PACKET-ID           BINARY-LONG VALUE 101.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ENTITY-ID            BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY-ID L-AIR PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ENTITY-ID
     INITIALIZE MD-METADATA-ENTRY
     MOVE 1 TO MD-MD-INDEX
     MOVE MD-MDS-INT TO MD-MD-SERIALIZER
     MOVE L-AIR TO MD-MD-INT
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     MOVE MD-MD-END TO MD-MD-INDEX
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     GOBACK.
 END PROGRAM AIR-DATA-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREATH-TICK.
*> USING player row (BINARY-LONG): one tick of the rules above for one alive player.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RULES.
 COPY PROTO.
 01 WS-IN                  BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG VALUE 2.
 01 WS-CAUSE               BINARY-LONG VALUE CAUSE-DROWN.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-NONE2               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE PL-AIR(L-ROW) TO WS-OLD
     IF PL-MODE(L-ROW) = 1
         MOVE RULE-MAX-AIR TO PL-AIR(L-ROW)
     ELSE
         CALL "BREATH-EYE-IN-WATER" USING L-ROW WS-IN
         IF WS-IN = 1
             SUBTRACT 1 FROM PL-AIR(L-ROW)
             IF PL-AIR(L-ROW) <= -20
                 MOVE 0 TO PL-AIR(L-ROW)
                 CALL "HEALTH-DAMAGE" USING L-ROW WS-DAMAGE WS-CAUSE WS-NONE WS-NONE2
             END-IF
         ELSE
             COMPUTE PL-AIR(L-ROW) = FUNCTION MIN(RULE-MAX-AIR, PL-AIR(L-ROW) + 4)
         END-IF
     END-IF
     IF PL-AIR(L-ROW) NOT = WS-OLD
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "AIR-DATA-BUILD" USING PL-ENTITY-ID(L-ROW) PL-AIR(L-ROW) PB-BUFFER
         CALL "CORE-SEND" USING PL-CONN(L-ROW) PB-BUFFER
         CALL "PB-FREE" USING PB-BUFFER
     END-IF
     GOBACK.
 END PROGRAM BREATH-TICK.
