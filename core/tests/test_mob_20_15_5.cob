*> Acceptance test (lane p49r; docs/protocol/20 section 15.3): the sonic boom damage type. 10.0 scaled by the difficulty for a player whatever the cause (scaling `always`: Peaceful 0, Easy 6, Normal 10,
*> Hard 15), bypassing armor and enchantments (a diamond chestplate takes nothing off), not Resistance (Hard, Resistance I: 15 x 0.8 = 12), not a creative player, and the extra push of the behaviour
*> (2.5 x on x and z, 0.5 x on y, times 1 - knockback resistance) happens only when the damage call hurt the target. The Damage Event names the warden as its source.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-15-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY CMENU.
 COPY BRWORLD.
 COPY WARDENSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(1024).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-WARDEN              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-CHEST               BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 16.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-AMOUNT              BINARY-LONG VALUE 10.
 01 WS-RESISTANCE          BINARY-LONG VALUE 10.
 01 WS-AMPLIFIER           BINARY-LONG VALUE 0.
 01 WS-DURATION            BINARY-LONG VALUE 2000.
 01 WS-FLAGS               BINARY-LONG VALUE 4.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-I                   BINARY-LONG.
 01 WS-TEXT                PIC X(4096).
 01 WS-NEEDLE              PIC X(40).
 01 WS-SOURCE-TEXT         PIC Z(5)9.
 01 WS-HITS                BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE "minecraft:warden" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:diamond_chestplate" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-CHEST WS-ITEM-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-FX = FUNCTION INTEGER(WS-X) - 4
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) - 8
     COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     COMPUTE WS-X0 = WS-X + 6
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-WARDEN
     MOVE 0 TO PL-MODE(WS-PLAYER)
*>   Scaling by the difficulty: Peaceful 0, Easy 6, Normal 10, Hard 15 (health left of 20).
     MOVE 0 TO BW-DIFFICULTY
     MOVE "Peaceful does 0" TO TL-CASE
     MOVE 20000 TO TL-EXPECTED-N
     PERFORM BOOM
     MOVE 1 TO BW-DIFFICULTY
     MOVE "Easy does 6" TO TL-CASE
     MOVE 14000 TO TL-EXPECTED-N
     PERFORM BOOM
     MOVE 2 TO BW-DIFFICULTY
     MOVE "Normal does 10" TO TL-CASE
     MOVE 10000 TO TL-EXPECTED-N
     PERFORM BOOM
     MOVE 3 TO BW-DIFFICULTY
     MOVE "Hard does 15" TO TL-CASE
     MOVE 5000 TO TL-EXPECTED-N
     PERFORM BOOM
*>   Armor is bypassed: a diamond chestplate changes nothing.
     MOVE WS-CHEST TO MN-EQUIP-ITEM(WS-PLAYER, 3)
     MOVE 1 TO MN-EQUIP-COUNT(WS-PLAYER, 3)
     MOVE 0 TO MN-EQUIP-VAR(WS-PLAYER, 3)
     MOVE "Hard through a diamond chestplate still does 15" TO TL-CASE
     MOVE 5000 TO TL-EXPECTED-N
     PERFORM BOOM
     MOVE "the armor piece is not worn down by a bypassing source" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE MN-EQUIP-VAR(WS-PLAYER, 3) TO TL-OBSERVED-N
     PERFORM CASE-LINE
*>   Resistance I still reduces it by 20 percent: 15 becomes 12.
     CALL "EFFECT-ADD" USING WS-PLAYER WS-RESISTANCE WS-AMPLIFIER WS-DURATION WS-FLAGS
     MOVE "Hard with Resistance I does 12" TO TL-CASE
     MOVE 8000 TO TL-EXPECTED-N
     PERFORM BOOM
     CALL "EFFECT-REMOVE" USING WS-PLAYER WS-RESISTANCE
     MOVE 0 TO MN-EQUIP-ITEM(WS-PLAYER, 3) MN-EQUIP-COUNT(WS-PLAYER, 3)
*>   A creative player takes nothing.
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE "a creative player takes nothing" TO TL-CASE
     MOVE 20000 TO TL-EXPECTED-N
     PERFORM BOOM
     MOVE 0 TO PL-MODE(WS-PLAYER)
*>   The Damage Event names the warden as its source (entity id + 1).
     MOVE 2 TO BW-DIFFICULTY
     MOVE "Normal does 10" TO TL-CASE
     MOVE 10000 TO TL-EXPECTED-N
     PERFORM BOOM
     COMPUTE WS-SOURCE-TEXT = EN-ID(WS-WARDEN) + 1
     MOVE SPACES TO WS-NEEDLE
     STRING " source " DELIMITED BY SIZE FUNCTION TRIM(WS-SOURCE-TEXT LEADING) DELIMITED BY SIZE " |" DELIMITED BY SIZE INTO WS-NEEDLE
     MOVE 0 TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL FUNCTION TRIM(WS-NEEDLE TRAILING)
     MOVE "the Damage Event names the warden as source" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-HITS > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CASE-LINE
*>   The behaviour: the boom of the 34th tick uses the same damage (Hard, 15) and pushes the player; with the hurt window still open for a higher hit it pushes nothing.
     MOVE 3 TO BW-DIFFICULTY
     CALL "WD-FIND" USING EN-ID(WS-WARDEN) WS-ONE WS-SLOT
     MOVE WS-PLAYER TO EN-TARGET(WS-WARDEN)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-WARDEN)
     MOVE 0 TO WD-SONIC-CD(WS-SLOT)
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     CALL "TEST-DRAIN-HEALTH" USING PL-CONN(WS-PLAYER) WS-TEXT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 34
         CALL "WARDEN-SONIC" USING WS-WARDEN WS-FLAGS
     END-PERFORM
     MOVE "the sonic boom of the behaviour does 15 on Hard" TO TL-CASE
     MOVE 5000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PL-HEALTH(WS-PLAYER) * 1000
     PERFORM CASE-LINE
     STOP RUN.

 CASE-LINE.
     MOVE SPACES TO WS-ITEM-ROW
     STRING "acceptance US15 20§15.3 Sonic boom: " DELIMITED BY SIZE FUNCTION TRIM(TL-CASE) DELIMITED BY SIZE INTO WS-ITEM-ROW
     MOVE WS-ITEM-ROW TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .

*> One boom on the player at full health: HEALTH-SONIC-BOOM; TL-EXPECTED-N the health left in thousandths.
 BOOM.
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     CALL "TEST-DRAIN-HEALTH" USING PL-CONN(WS-PLAYER) WS-TEXT
     CALL "HEALTH-SONIC-BOOM" USING WS-PLAYER WS-AMOUNT WS-WARDEN WS-RESULT
     CALL "TEST-DRAIN-HEALTH" USING PL-CONN(WS-PLAYER) WS-TEXT
     COMPUTE TL-OBSERVED-N ROUNDED = PL-HEALTH(WS-PLAYER) * 1000
     PERFORM CASE-LINE
     .
 END PROGRAM TEST-MOB-20-15-5.
 COPY CORETEST.
 COPY MOBSPTEST.
