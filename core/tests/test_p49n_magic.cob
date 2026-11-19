*> Implementation test (002-lane-p49n; docs/protocol/17 sections 4.9a and 4.12, 20 sections 9.1 and 11): the damage types magic, indirect_magic and wither.
*> A witch takes 0.15 of magic and indirect_magic damage and the full amount of mob_attack and wither damage (20 section 11, tag witch_resistant_to); another mob takes the full
*> magic damage; the instant_damage effect (potion) and poison hurt as magic, wither as wither (17 section 4.9a); a silverfish hurt by magic with no attacker wakes its friends
*> (20 section 9.1, tag always_triggers_silverfish), one hurt by generic damage with no attacker does not; the causes map to the damage types 27, 23 and 49 of 17 section 4.13.1.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-P49N-MAGIC.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY STDMOBS.
 COPY RULES.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-WITCH-TYPE          BINARY-LONG.
 01 WS-ZOMBIE-TYPE         BINARY-LONG.
 01 WS-FISH-TYPE           BINARY-LONG.
 01 WS-WITCH               BINARY-LONG.
 01 WS-ZOMBIE              BINARY-LONG.
 01 WS-FISH                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-CASE                PIC X(100).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG VALUE 6.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-ZERO-AMOUNT         BINARY-LONG VALUE 0.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-EFFECT              BINARY-LONG.
 01 WS-AMP                 BINARY-LONG.
 01 WS-FULL                BINARY-LONG VALUE 1000.
 01 WS-DURATION            BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 40.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-DIR                 PIC X(1100).
 01 WS-SET                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:witch" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-WITCH-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZOMBIE-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:silverfish" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-FISH-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-FX = FUNCTION INTEGER(WS-X) - 20
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) - 20
     COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     COMPUTE WS-X0 = WS-X + 6
     CALL "MOB-SPAWN" USING WS-DIM WS-WITCH-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-WITCH
     COMPUTE WS-X0 = WS-X + 8
     CALL "MOB-SPAWN" USING WS-DIM WS-ZOMBIE-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-ZOMBIE
     COMPUTE WS-X0 = WS-X + 10
     CALL "MOB-SPAWN" USING WS-DIM WS-FISH-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-FISH

*>   A witch takes 0.15 of 6 magic damage: 0.9 of a point (health stays 26, 900 thousandths lost).
     MOVE CAUSE-MAGIC TO WS-CAUSE
     MOVE 0 TO EN-HURT(WS-WITCH)
     CALL "HEALTH-MOB-DAMAGE" USING WS-WITCH WS-DAMAGE WS-CAUSE WS-NONE
     MOVE "acceptance US15 20§11 A witch takes 0.15 of magic damage (6 gives 0.9)" TO WS-CASE
     MOVE 900 TO WS-EXP
     COMPUTE WS-OBS = (26 - EN-HEALTH(WS-WITCH)) * 1000 + EN-HEALTH-MILLI(WS-WITCH)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   Indirect magic takes the same factor: 900 + 900 = 1.8 points lost, health 25 and 800 thousandths.
     MOVE CAUSE-INDIRECT-MAGIC TO WS-CAUSE
     MOVE 0 TO EN-HURT(WS-WITCH)
     CALL "HEALTH-MOB-DAMAGE" USING WS-WITCH WS-DAMAGE WS-CAUSE WS-NONE
     MOVE "acceptance US15 20§11 A witch takes 0.15 of indirect magic damage too" TO WS-CASE
     MOVE 1800 TO WS-EXP
     COMPUTE WS-OBS = (26 - EN-HEALTH(WS-WITCH)) * 1000 + EN-HEALTH-MILLI(WS-WITCH)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   The hurt window blocks a second hit in the same window: nothing more is lost.
*>   Wither damage and mob damage are not witch_resistant_to: the full 6.
     MOVE CAUSE-WITHER TO WS-CAUSE
     MOVE 0 TO EN-HURT(WS-WITCH)
     CALL "HEALTH-MOB-DAMAGE" USING WS-WITCH WS-DAMAGE WS-CAUSE WS-NONE
     MOVE "acceptance US15 20§11 A witch takes the full wither damage" TO WS-CASE
     COMPUTE WS-EXP = 1800 + 6000
     COMPUTE WS-OBS = (26 - EN-HEALTH(WS-WITCH)) * 1000 + EN-HEALTH-MILLI(WS-WITCH)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE CAUSE-MOB TO WS-CAUSE
     MOVE 0 TO EN-HURT(WS-WITCH)
     CALL "HEALTH-MOB-DAMAGE" USING WS-WITCH WS-DAMAGE WS-CAUSE WS-NONE
     MOVE "acceptance US15 20§11 A witch takes the full mob_attack damage" TO WS-CASE
     COMPUTE WS-EXP = 1800 + 12000
     COMPUTE WS-OBS = (26 - EN-HEALTH(WS-WITCH)) * 1000 + EN-HEALTH-MILLI(WS-WITCH)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS

*>   Another mob takes the full magic damage.
     MOVE CAUSE-MAGIC TO WS-CAUSE
     MOVE 0 TO EN-HURT(WS-ZOMBIE)
     CALL "HEALTH-MOB-DAMAGE" USING WS-ZOMBIE WS-DAMAGE WS-CAUSE WS-NONE
     MOVE "acceptance US15 17§4.12 A zombie takes the full magic damage (6 of 20)" TO WS-CASE
     MOVE 14 TO WS-EXP
     MOVE EN-HEALTH(WS-ZOMBIE) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS

*>   An instant_damage splash of full intensity on a fresh witch: 6 x 0.15 = 0.9. Healing (effect 5) on the witch heals nothing (full health), harming hurts as magic.
     COMPUTE WS-X0 = WS-X + 12
     CALL "MOB-SPAWN" USING WS-DIM WS-WITCH-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-WITCH
     MOVE 6 TO WS-EFFECT
     MOVE 0 TO WS-AMP
     CALL "MEF-INSTANT-T" USING WS-WITCH WS-EFFECT WS-AMP WS-FULL
     MOVE "acceptance US15 17§4.9a Instant damage on a witch is magic: 900 thousandths" TO WS-CASE
     MOVE 900 TO WS-EXP
     COMPUTE WS-OBS = (26 - EN-HEALTH(WS-WITCH)) * 1000 + EN-HEALTH-MILLI(WS-WITCH)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   Poison (effect 18) on a witch: 1 point of magic is 0.15; wither (19) is the full 1.
     COMPUTE WS-X0 = WS-X + 14
     CALL "MOB-SPAWN" USING WS-DIM WS-WITCH-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-WITCH
     MOVE 18 TO WS-EFFECT
     MOVE 25 TO WS-DURATION
     CALL "MEF-PERIODIC" USING WS-WITCH WS-EFFECT WS-AMP WS-DURATION
     MOVE "acceptance US15 17§4.9a Poison on a witch hurts as magic: 150 thousandths" TO WS-CASE
     MOVE 150 TO WS-EXP
     COMPUTE WS-OBS = (26 - EN-HEALTH(WS-WITCH)) * 1000 + EN-HEALTH-MILLI(WS-WITCH)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO EN-HURT(WS-WITCH)
     MOVE 19 TO WS-EFFECT
     MOVE 40 TO WS-DURATION
     CALL "MEF-PERIODIC" USING WS-WITCH WS-EFFECT WS-AMP WS-DURATION
     MOVE "acceptance US15 17§4.9a Wither on a witch hurts as wither: the full point" TO WS-CASE
     MOVE 1150 TO WS-EXP
     COMPUTE WS-OBS = (26 - EN-HEALTH(WS-WITCH)) * 1000 + EN-HEALTH-MILLI(WS-WITCH)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS

*>   Silverfish: magic damage with no attacker wakes the friends, generic damage with none does not.
     MOVE CAUSE-COMMAND TO WS-CAUSE
     MOVE 0 TO EN-HURT(WS-FISH)
     CALL "HEALTH-MOB-DAMAGE" USING WS-FISH WS-ZERO-AMOUNT WS-CAUSE WS-NONE
     MOVE "acceptance US15 20§9.1 Generic damage with no attacker does not wake the silverfish friends" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-WAKE(WS-FISH) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE CAUSE-MAGIC TO WS-CAUSE
     MOVE 0 TO EN-HURT(WS-FISH)
     CALL "HEALTH-MOB-DAMAGE" USING WS-FISH WS-DAMAGE WS-CAUSE WS-NONE
     MOVE "acceptance US15 20§9.1 Magic damage with no attacker wakes the silverfish friends (timer 20)" TO WS-CASE
     MOVE 20 TO WS-EXP
     MOVE EN-WAKE(WS-FISH) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "CONTENT-CLOSE"
     MOVE SPACES TO WS-DIR
     MOVE "core/tests/fixtures/p49n-content" TO WS-DIR
     MOVE CT-TYPE-STANDARD TO WS-SET
     CALL "CONTENT-OPEN" USING WS-SET WS-DIR WS-STATUS
*>   The causes map to their damage types by key in the registry of a standard set (17 section 4.13.4: the id is the position, sorted by path).
     CALL "DAMAGE-TYPE-ID" USING CAUSE-MAGIC WS-ID
     MOVE "acceptance US15 17§4.13.1 The cause magic is registry position 2" TO WS-CASE
     MOVE 2 TO WS-EXP
     MOVE WS-ID TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "DAMAGE-TYPE-ID" USING CAUSE-INDIRECT-MAGIC WS-ID
     MOVE "acceptance US15 17§4.13.1 The cause indirect_magic is registry position 1" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-ID TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "DAMAGE-TYPE-ID" USING CAUSE-WITHER WS-ID
     MOVE "acceptance US15 17§4.13.1 The cause wither is registry position 4" TO WS-CASE
     MOVE 4 TO WS-EXP
     MOVE WS-ID TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE CAUSE-MOB TO WS-CAUSE
     CALL "DAMAGE-TYPE-ID" USING WS-CAUSE WS-ID
     MOVE "acceptance US15 17§4.13.1 The cause mob is registry position 3" TO WS-CASE
     MOVE 3 TO WS-EXP
     MOVE WS-ID TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS

     STOP RUN.
 END PROGRAM TEST-P49N-MAGIC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 LINKAGE SECTION.
 01 L-CASE                 PIC X(100).
 01 L-EXPECTED             BINARY-LONG.
 01 L-OBSERVED             BINARY-LONG.
 PROCEDURE DIVISION USING L-CASE L-EXPECTED L-OBSERVED.
     MOVE "N" TO TL-MODE
     MOVE L-CASE TO TL-CASE
     MOVE L-EXPECTED TO TL-EXPECTED-N
     MOVE L-OBSERVED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-CHK.
 COPY CORETEST.
 COPY MOBSPTEST.
