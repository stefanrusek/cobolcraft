*> Implementation test (002-lane-mobsfull-h12; docs/protocol/21 section 5.4): the wither skeleton. Row (health 20, melee attack 4 with no bow, no daylight
*> burning, experience 5, monster spawn rule 2); its melee hit gives the victim Wither (effect 19) amplifier 0 for 200 ticks on every difficulty; the
*> loot table is read from the table of the key (coal in the fixture).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-5-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 COPY EFFECTS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-LOOT-DIR            PIC X(1100) VALUE "core/tests/fixtures/nether-loot".
 01 WS-STATUS              BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-TYPE                BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-N1                  BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-CASE                PIC X(100).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ITEM-KEY            PIC X(112) VALUE "minecraft:coal".
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-COAL                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     CALL "LOOT-LOAD" USING WS-LOOT-DIR WS-STATUS
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     CALL "CONTENT-ITEM-BY-KEY" USING WS-ITEM-KEY WS-COAL WS-ITEM-ROW WS-STATUS
     MOVE "wither_skeleton" TO WS-NAME
     CALL "TEST-TYPE" USING WS-NAME WS-TYPE WS-M
     MOVE "acceptance US15 minecraft:wither_skeleton has a species row" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-M > 41 AND SM-KEY(WS-M) = "wither_skeleton"
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.4 minecraft:wither_skeleton max health 20" TO WS-CASE
     MOVE 20 TO WS-EXP
     CALL "STDMOB-HEALTH" USING WS-TYPE WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.4 minecraft:wither_skeleton melee attack damage 4, no bow" TO WS-CASE
     MOVE 4 TO WS-EXP
     COMPUTE WS-OBS = SM-ATTACK(WS-M) + SM-RANGED(WS-M)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.4 minecraft:wither_skeleton is fire immune (no daylight burning)" TO WS-CASE
     MOVE 0 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP SM-BURNS(WS-M)
     MOVE "acceptance US15 21§5.4 minecraft:wither_skeleton experience 5 and monster spawn rule 2" TO WS-CASE
     MOVE 7 TO WS-EXP
     COMPUTE WS-OBS = SM-XP(WS-M) + SM-SPAWN(WS-M)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   The hit: Wither amplifier 0 for 200 ticks, on Normal and on Easy.
     MOVE 2 TO BW-DIFFICULTY
     CALL "STDMOB-HIT-EFFECT" USING WS-PLAYER WS-M
     MOVE "acceptance US15 21§5.4 a wither skeleton hit gives Wither for 200 ticks (Normal)" TO WS-CASE
     MOVE 200 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF EF-ON(WS-PLAYER, 20) = 1
         MOVE EF-DURATION(WS-PLAYER, 20) TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.4 the Wither of a hit has amplifier 0" TO WS-CASE
     MOVE 0 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EF-AMPLIFIER(WS-PLAYER, 20)
     MOVE 0 TO EF-ON(WS-PLAYER, 20)
     MOVE 1 TO BW-DIFFICULTY
     CALL "STDMOB-HIT-EFFECT" USING WS-PLAYER WS-M
     MOVE "acceptance US15 21§5.4 a wither skeleton hit gives Wither for 200 ticks (Easy)" TO WS-CASE
     MOVE 200 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF EF-ON(WS-PLAYER, 20) = 1
         MOVE EF-DURATION(WS-PLAYER, 20) TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO EF-ON(WS-PLAYER, 20)
     MOVE 2 TO BW-DIFFICULTY
*>   Death: the loot table of the key drops.
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE WS-PLAYER TO EN-KILLER(WS-ROW)
     CALL "STDMOB-DIE" USING WS-ROW
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-N1 FROM 1 BY 1 UNTIL WS-N1 > EN-COUNT
         IF EN-USED(WS-N1) = 1 AND EN-ITEM(WS-N1) = WS-COAL AND EN-ITEM-COUNT(WS-N1) > 0
             ADD EN-ITEM-COUNT(WS-N1) TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "acceptance US15 21§5.4 a killed wither skeleton drops its table (coal)" TO WS-CASE
     MOVE 1 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-COUNT
     GOBACK.
 END PROGRAM TEST-MOB-21-5-4.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY MOBNETHERTEST.
