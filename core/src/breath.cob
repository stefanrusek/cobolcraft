*> The air supply and drowning of a player (docs/protocol/18 section 2.5 item 4, 17 section 4.12, 29a section 8.2 for the eye): BREATH-TICK runs once a
*> tick for every alive player (HEALTH-TICK). A survival player whose eye (feet + 1.6) is inside water loses 1 of the air supply (PL-AIR, 300 at most);
*> at -20 or less it is reset to 0 and the player takes 2 drown damage (HEALTH-DAMAGE, CAUSE-DROWN), so that damage repeats every 20 ticks; out of
*> water the air refills by 4 a tick up to 300. A creative player breathes anywhere (the abilities of a creative player are invulnerable). The player
*> is sent Set Entity Data (slot 1, the Int air) whenever it changed. Respiration (oxygen_bonus) slows the loss. Not done: water breathing, bubble columns, the bubble
*> particles are the client's (Entity Event 67 is sent; the client does not wire it yet).

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
 COPY CMENU.
 COPY RULES.
 COPY PROTO.
 01 WS-BONUS               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-ENCH-ID             BINARY-LONG.
 01 WS-ENCH-KEY            PIC X(112).
 01 WS-IN                  BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG VALUE 2.
 01 WS-CAUSE               BINARY-LONG VALUE CAUSE-DROWN.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-NONE2               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-EVENT               BINARY-LONG VALUE 67.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE PL-AIR(L-ROW) TO WS-OLD
     IF PL-MODE(L-ROW) = 1
         MOVE RULE-MAX-AIR TO PL-AIR(L-ROW)
     ELSE
         CALL "BREATH-EYE-IN-WATER" USING L-ROW WS-IN
         IF WS-IN = 1
*>           Respiration of the helmet is oxygen_bonus b: the air is lost with probability 1 / (b + 1) (a hash of the tick and the player stands for the draw).
             MOVE 0 TO WS-BONUS
             IF MN-EQUIP-COUNT(L-ROW, 4) > 0
                 MOVE "minecraft:respiration" TO WS-ENCH-KEY
                 CALL "TOOL-ENCHANT-ID" USING WS-ENCH-KEY WS-ENCH-ID
                     IF WS-ENCH-ID >= 0
                     CALL "SP-ENCHANT-LEVEL" USING MN-EQUIP-VAR(L-ROW, 4) WS-ENCH-ID WS-BONUS
                 END-IF
             END-IF
             COMPUTE WS-DRAW = FUNCTION MOD(CW-TICKS * 7 + L-ROW * 3, WS-BONUS + 1)
             IF WS-DRAW = 0
                 SUBTRACT 1 FROM PL-AIR(L-ROW)
             END-IF
             IF PL-AIR(L-ROW) <= -20
                 MOVE 0 TO PL-AIR(L-ROW)
*>               Entity Event 67 (the drown bubbles, 42 section 7) to the player and to those who see it.
                 CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
                 CALL "ENTITY-EVENT-BUILD" USING PL-ENTITY-ID(L-ROW) WS-EVENT PB-BUFFER
                 CALL "CORE-SEND" USING PL-CONN(L-ROW) PB-BUFFER
                 CALL "HEALTH-VIEWERS-SEND" USING PL-ENTITY-ROW(L-ROW) PB-BUFFER
                 CALL "PB-FREE" USING PB-BUFFER
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

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLUID-TOUCHES-WATER.
*> USING dimension row, feet x, y, z (FLOAT-LONG), wet out (BINARY-LONG 1 or 0): the box of a player (feet up to 1.8) touches water: one of the cells
*> of its column from the feet's cell up holds water whose surface (the cell's y plus 1 under water, else amount / 9) is not below the feet (29a 8.2
*> step 6, in the column of the feet only). Touching water ends a fall (8.3 step 2: resetFallDistance).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-YA                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-FLUID               BINARY-LONG.
 01 WS-A-STATE             BINARY-LONG.
 01 WS-A-FLUID             BINARY-LONG.
 01 WS-A-KIND              BINARY-LONG.
 01 WS-A-AMOUNT            BINARY-LONG.
 01 WS-A-FALLING           BINARY-LONG.
 01 WS-A-SOLID             BINARY-LONG.
 01 WS-A-HOLDS             BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-FALLING             BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-HOLDS               BINARY-LONG.
 01 WS-SAME                BINARY-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-TOP                 FLOAT-LONG.
 01 WS-HIGH                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-WET                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-WET.
     MOVE 0 TO L-WET
     COMPUTE WS-X = FUNCTION INTEGER(L-X)
     COMPUTE WS-Z = FUNCTION INTEGER(L-Z)
     COMPUTE WS-Y0 = FUNCTION INTEGER(L-Y)
     COMPUTE WS-HIGH = L-Y + 1.8
     COMPUTE WS-Y1 = FUNCTION INTEGER(WS-HIGH)
     PERFORM VARYING WS-Y FROM WS-Y0 BY 1 UNTIL WS-Y > WS-Y1 OR L-WET = 1
         CALL "FLUID-CELL" USING L-DIM WS-X WS-Y WS-Z WS-STATE WS-FLUID WS-KIND WS-AMOUNT WS-FALLING WS-SOLID WS-HOLDS
         IF WS-FLUID = 1
             COMPUTE WS-YA = WS-Y + 1
             CALL "FLUID-CELL" USING L-DIM WS-X WS-YA WS-Z WS-A-STATE WS-A-FLUID WS-A-KIND WS-A-AMOUNT WS-A-FALLING WS-A-SOLID
                 WS-A-HOLDS
             MOVE 0 TO WS-SAME
             IF WS-A-FLUID = 1
                 MOVE 1 TO WS-SAME
             END-IF
             CALL "FL-HEIGHT" USING WS-AMOUNT WS-SAME WS-HEIGHT
             COMPUTE WS-TOP = WS-Y + WS-HEIGHT
             IF WS-TOP >= L-Y
                 MOVE 1 TO L-WET
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FLUID-TOUCHES-WATER.
