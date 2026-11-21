*> The dispense configuration of the ominous item spawner (docs/protocol/21 section 8.17 and 8.17.1; lane p49t, T39030): OIS-DISPENSE gives, for each of the 13 registered projectile items and the
*> trident, the kind, the uncertainty and the power (thousandths) and the level event override (firework rocket 1004, fire charge 1018, wind charge 1051); OIS-STEP launches each as its entity (arrow,
*> tipped arrow, spectral arrow, trident, eggs, snowball, experience bottle, splash and lingering potion, firework rocket (shot at an angle), small fireball for the fire charge, wind charge) downward at
*> that power, owned by the spawner, and plays the override. Any other item stays an item entity.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-8-17B.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY PROJSTATE.
 COPY CITEMS.
 01 WS-CASE                PIC X(160).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-KEY48               PIC X(48).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-UNC                 BINARY-LONG.
 01 WS-POW                 BINARY-LONG.
 01 WS-EVENT               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-IDN                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-COUNT               BINARY-LONG VALUE 1.
 01 WS-TEXT                PIC X(1024).
 01 WS-SPEED               FLOAT-LONG.
 01 WS-TOL                 FLOAT-LONG.
 01 WS-POWER               FLOAT-LONG.
 01 WS-DOWN                BINARY-LONG.
 01 WS-NAME                PIC X(48).
 01 WS-HITS                BINARY-LONG.
 01 WS-TABLE.
    05 FILLER PIC X(80) VALUE "arrow            |arrow           |1|6000|1100|0".
    05 FILLER PIC X(80) VALUE "tipped_arrow     |arrow           |1|6000|1100|0".
    05 FILLER PIC X(80) VALUE "spectral_arrow   |spectral_arrow  |2|6000|1100|0".
    05 FILLER PIC X(80) VALUE "trident          |trident         |3|6000|1100|0".
    05 FILLER PIC X(80) VALUE "egg              |egg             |4|6000|1100|0".
    05 FILLER PIC X(80) VALUE "blue_egg         |egg             |4|6000|1100|0".
    05 FILLER PIC X(80) VALUE "brown_egg        |egg             |4|6000|1100|0".
    05 FILLER PIC X(80) VALUE "snowball         |snowball        |5|6000|1100|0".
    05 FILLER PIC X(80) VALUE "experience_bottle|experience_bottle|6|3000|1375|0".
    05 FILLER PIC X(80) VALUE "splash_potion    |splash_potion   |7|3000|1375|0".
    05 FILLER PIC X(80) VALUE "lingering_potion |lingering_potion|8|3000|1375|0".
    05 FILLER PIC X(80) VALUE "firework_rocket  |firework_rocket |9|1000|500|1004".
    05 FILLER PIC X(80) VALUE "fire_charge      |small_fireball  |10|6667|1000|1018".
    05 FILLER PIC X(80) VALUE "wind_charge      |wind_charge     |11|6667|1000|1051".
 01 WS-ROWS REDEFINES WS-TABLE.
    05 WS-LINE             PIC X(80) OCCURS 14 TIMES.
 01 WS-ITEM-KEY            PIC X(17).
 01 WS-ENTITY-KEY          PIC X(16).
 01 WS-CELL-KIND           PIC X(3).
 01 WS-CELL-UNC            PIC X(5).
 01 WS-CELL-POW            PIC X(5).
 01 WS-CELL-EVENT          PIC X(5).
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 0 TO WS-CONN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-CONNS
         IF CN-PLAYER(WS-I) = WS-PLAYER
             MOVE WS-I TO WS-CONN
         END-IF
     END-PERFORM
     MOVE PL-X(WS-PLAYER) TO WS-X
     COMPUTE WS-Y = PL-Y(WS-PLAYER) + 20
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 14
         MOVE SPACES TO WS-ITEM-KEY WS-ENTITY-KEY WS-CELL-KIND WS-CELL-UNC WS-CELL-POW WS-CELL-EVENT
         UNSTRING WS-LINE(WS-T) DELIMITED BY "|" INTO WS-ITEM-KEY WS-ENTITY-KEY WS-CELL-KIND WS-CELL-UNC WS-CELL-POW WS-CELL-EVENT
         MOVE SPACES TO WS-KEY
         STRING "minecraft:" FUNCTION TRIM(WS-ITEM-KEY) DELIMITED BY SIZE INTO WS-KEY
         CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
         MOVE SPACES TO WS-KEY48
         MOVE FUNCTION TRIM(WS-ITEM-KEY) TO WS-KEY48
         CALL "OIS-DISPENSE" USING WS-KEY48 WS-KIND WS-UNC WS-POW WS-EVENT
         MOVE SPACES TO WS-CASE
         STRING "acceptance US15 21§8.17.1 " FUNCTION TRIM(WS-ITEM-KEY) " has the kind, uncertainty, power and event of its row"
             DELIMITED BY SIZE INTO WS-CASE
         COMPUTE WS-E = FUNCTION NUMVAL(WS-CELL-KIND) * 1000000000000 + FUNCTION NUMVAL(WS-CELL-UNC) * 100000000
             + FUNCTION NUMVAL(WS-CELL-POW) * 10000 + FUNCTION NUMVAL(WS-CELL-EVENT)
         COMPUTE WS-O = WS-KIND * 1000000000000 + WS-UNC * 100000000 + WS-POW * 10000 + WS-EVENT
         PERFORM CHECK-N
*>       The launch: the entity of the row, owned by the spawner, at the power of the row, going down.
         CALL "OIS-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-ITEM WS-COUNT WS-ROW
         MOVE EN-ID(WS-ROW) TO WS-IDN
         CALL "PJ-FIND" USING WS-IDN WS-SLOT
         MOVE 60 TO PJ-I1(WS-SLOT)
         CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
             CALL "OIS-STEP" USING WS-ROW
         END-PERFORM
         MOVE 0 TO WS-FOUND
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
             IF EN-USED(WS-I) = 1 AND EN-TARGET-ID(WS-I) = WS-IDN AND WS-I NOT = WS-ROW
                 MOVE WS-I TO WS-FOUND
             END-IF
         END-PERFORM
         MOVE SPACES TO WS-CASE
         STRING "acceptance US15 21§8.17.1 " FUNCTION TRIM(WS-ITEM-KEY) " is launched as a " FUNCTION TRIM(WS-ENTITY-KEY)
             " owned by the spawner" DELIMITED BY SIZE INTO WS-CASE
         MOVE 1 TO WS-E
         MOVE 0 TO WS-O
         IF WS-FOUND > 0
             MOVE ET-KEY(EN-TYPE(WS-FOUND) + 1) TO WS-NAME
             MOVE 0 TO WS-HITS
             INSPECT WS-NAME TALLYING WS-HITS FOR ALL FUNCTION TRIM(WS-ENTITY-KEY)
             IF WS-HITS > 0
                 MOVE 1 TO WS-O
             END-IF
         END-IF
         PERFORM CHECK-N
         IF WS-FOUND > 0
             COMPUTE WS-SPEED = FUNCTION SQRT(EN-VX(WS-FOUND) ** 2 + EN-VY(WS-FOUND) ** 2 + EN-VZ(WS-FOUND) ** 2)
             COMPUTE WS-POWER = WS-POW / 1000
             COMPUTE WS-TOL = WS-POWER * 0.0172275 * WS-UNC / 1000 * 1.75 + 0.001
             MOVE SPACES TO WS-CASE
             STRING "acceptance US15 21§8.17.1 " FUNCTION TRIM(WS-ITEM-KEY) " leaves at the speed of its power within its uncertainty"
                 DELIMITED BY SIZE INTO WS-CASE
             MOVE 1 TO WS-E
             MOVE 0 TO WS-O
             IF FUNCTION ABS(WS-SPEED - WS-POWER) <= WS-TOL
                 MOVE 1 TO WS-O
             END-IF
             PERFORM CHECK-N
             MOVE SPACES TO WS-CASE
             STRING "acceptance US15 21§8.17.1 " FUNCTION TRIM(WS-ITEM-KEY) " is launched downward"
                 DELIMITED BY SIZE INTO WS-CASE
             MOVE 1 TO WS-E
             MOVE 0 TO WS-O
             IF EN-VY(WS-FOUND) < 0
                 MOVE 1 TO WS-O
             END-IF
             PERFORM CHECK-N
             MOVE SPACES TO WS-CASE
             STRING "acceptance US15 21§8.17.1 " FUNCTION TRIM(WS-ITEM-KEY) " is launched: level event 3021 and the override if any (Level Event 0x2F count)"
                 DELIMITED BY SIZE INTO WS-CASE
             CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
             MOVE 0 TO WS-O
             INSPECT WS-TEXT TALLYING WS-O FOR ALL " 47"
             MOVE 1 TO WS-E
             IF WS-EVENT > 0
                 MOVE 2 TO WS-E
             END-IF
             PERFORM CHECK-N
             IF WS-KIND = 9
                 CALL "PJ-FIND" USING EN-ID(WS-FOUND) WS-SLOT
                 MOVE "acceptance US15 21§8.17.1 the firework rocket is shot at an angle (no acceleration)" TO WS-CASE
                 MOVE 1 TO WS-E
                 MOVE PJ-I5(WS-SLOT) TO WS-O
                 PERFORM CHECK-N
             END-IF
             CALL "ENTITY-REMOVE" USING WS-FOUND
         END-IF
     END-PERFORM
*>   Another item is not launched and has no configuration.
     MOVE "diamond" TO WS-KEY48
     CALL "OIS-DISPENSE" USING WS-KEY48 WS-KIND WS-UNC WS-POW WS-EVENT
     MOVE "acceptance US15 21§8.17.1 a diamond is no projectile item (kind 0)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-KIND TO WS-O
     PERFORM CHECK-N
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-21-8-17B.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY P49FTEST.
