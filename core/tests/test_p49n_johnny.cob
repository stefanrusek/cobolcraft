*> Implementation test (002-lane-p49n; docs/protocol/20 section 13.1, 45-6 section 2): Johnny, a vindicator with the Johnny flag (the Byte key Johnny, or the custom name "Johnny").
*> A Johnny vindicator takes any living entity of its follow range (12) that is not an illager friend (evoker, illusioner, pillager, vindicator) as its foe, walks to it and
*> hits it; an ordinary vindicator ignores a cow. A baby is a target too (only villagers' babies are spared). Johnny is false for another species and for another name.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-P49N-JOHNNY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY ENKEEP.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-VIND                BINARY-LONG.
 01 WS-COW                 BINARY-LONG.
 01 WS-PILL                BINARY-LONG.
 01 WS-VILL                BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-WALK                BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 40.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-CASE                PIC X(100).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-JOHNNY              BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     MOVE 2 TO PL-MODE(WS-PLAYER)
     COMPUTE WS-FX = FUNCTION INTEGER(WS-X) - 20
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) - 20
     COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     COMPUTE WS-X0 = WS-X + 6
     COMPUTE WS-Z0 = WS-Z + 6
     MOVE "minecraft:vindicator" TO WS-KEY
     CALL "PN-SPAWN" USING WS-DIM WS-KEY WS-X0 WS-Y WS-Z0 WS-VIND
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-VIND) WS-M
     COMPUTE WS-X0 = WS-X + 9
     MOVE "minecraft:cow" TO WS-KEY
     CALL "PN-SPAWN" USING WS-DIM WS-KEY WS-X0 WS-Y WS-Z0 WS-COW
     COMPUTE WS-X0 = WS-X + 3
     MOVE "minecraft:pillager" TO WS-KEY
     CALL "PN-SPAWN" USING WS-DIM WS-KEY WS-X0 WS-Y WS-Z0 WS-PILL

*>   An ordinary vindicator takes neither the cow nor the pillager.
     CALL "JOHNNY-IS" USING WS-VIND WS-JOHNNY
     MOVE "acceptance US15 20§13.1 A new vindicator is not Johnny" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-JOHNNY TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "MOBVS-TICK" USING WS-VIND WS-M WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 20§13.1 An ordinary vindicator has no foe among the cow and the pillager" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-WALK TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS

*>   Johnny by the key: it walks to the cow 3 blocks away, ignoring the pillager 3 blocks the other way (an illager friend).
     MOVE 1 TO EK-SPX-SET(WS-VIND, 2)
     MOVE 1 TO EK-SPX-NUM(WS-VIND, 2)
     CALL "JOHNNY-IS" USING WS-VIND WS-JOHNNY
     MOVE "acceptance US15 45-6§2 The Johnny key makes a vindicator Johnny" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-JOHNNY TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE EN-HEALTH(WS-COW) TO WS-BEFORE
     MOVE 0 TO EN-PET-CD(WS-VIND)
     CALL "MOBVS-TICK" USING WS-VIND WS-M WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 20§13.1 Johnny walks towards the cow (east of it)" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-WALK = 1 AND WS-HX > 0
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   In reach it hits the cow.
     COMPUTE EN-X(WS-VIND) = EN-X(WS-COW) - 1
     MOVE 0 TO EN-PET-CD(WS-VIND)
     CALL "MOBVS-TICK" USING WS-VIND WS-M WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 20§13.1 Johnny hits the cow in reach" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF EN-HEALTH(WS-COW) < WS-BEFORE
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   A villager is the foe of a higher priority (target 3) than Johnny's own goal (4): with the cow 3 blocks away and a villager 8 blocks away it walks to the villager (west).
     COMPUTE WS-X0 = WS-X - 2
     MOVE "minecraft:villager" TO WS-KEY
     CALL "PN-SPAWN" USING WS-DIM WS-KEY WS-X0 WS-Y WS-Z0 WS-VILL
     COMPUTE EN-X(WS-VIND) = WS-X + 6
     MOVE 0 TO EN-FOE(WS-VIND) EN-FOE-ID(WS-VIND) EN-PATH-TICKS(WS-VIND) EN-WAY-X(WS-VIND) EN-WAY-Z(WS-VIND)
     CALL "MOBVS-TICK" USING WS-VIND WS-M WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 20§13.1 A villager comes before Johnny's own foes (it walks west)" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-WALK = 1 AND WS-HX < 0
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-VILL
*>   Without the cow in range only the pillager is there: no foe.
     MOVE 0 TO EN-HEALTH(WS-COW)
     MOVE 0 TO EN-FOE(WS-VIND) EN-FOE-ID(WS-VIND)
     COMPUTE EN-X(WS-VIND) = WS-X + 6
     CALL "MOBVS-TICK" USING WS-VIND WS-M WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 20§13.1 Johnny ignores an illager (illager_friends)" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-WALK TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   A cow beyond the follow range 12 is not taken.
     MOVE 20 TO EN-HEALTH(WS-COW)
     COMPUTE EN-X(WS-COW) = WS-X + 6 + 13
     CALL "MOBVS-TICK" USING WS-VIND WS-M WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 20§13.1 Johnny does not take a cow 13 blocks away (follow range 12)" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-WALK TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS

*>   The custom name "Johnny" (a String tag: u16 length 6 and the bytes) sets it as well, another name does not.
     MOVE 0 TO EK-SPX-SET(WS-VIND, 2)
     MOVE 0 TO EK-SPX-NUM(WS-VIND, 2)
     MOVE 8 TO EK-NAME-TYPE(WS-VIND)
     MOVE 8 TO EK-NAME-LEN(WS-VIND)
     MOVE SPACES TO EK-NAME-RAW(WS-VIND)
     MOVE FUNCTION CHAR(1) TO EK-NAME-RAW(WS-VIND)(1:1)
     MOVE FUNCTION CHAR(7) TO EK-NAME-RAW(WS-VIND)(2:1)
     MOVE "Johnny" TO EK-NAME-RAW(WS-VIND)(3:6)
     CALL "JOHNNY-IS" USING WS-VIND WS-JOHNNY
     MOVE "acceptance US15 20§13.1 The custom name Johnny makes a vindicator Johnny" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-JOHNNY TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "Johnnx" TO EK-NAME-RAW(WS-VIND)(3:6)
     CALL "JOHNNY-IS" USING WS-VIND WS-JOHNNY
     MOVE "acceptance US15 20§13.1 Another custom name does not" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-JOHNNY TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   Only vindicators are Johnny.
     MOVE "Johnny" TO EK-NAME-RAW(WS-PILL)(3:6)
     MOVE 8 TO EK-NAME-TYPE(WS-PILL)
     MOVE 8 TO EK-NAME-LEN(WS-PILL)
     CALL "JOHNNY-IS" USING WS-PILL WS-JOHNNY
     MOVE "acceptance US15 20§13.1 A pillager is never Johnny" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-JOHNNY TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     STOP RUN.
 END PROGRAM TEST-P49N-JOHNNY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PN-SPAWN.
*> USING dim, key (PIC X(112)), x, y, z (FLOAT-LONG), row out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-KEY                  PIC X(112).
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-KEY L-X L-Y L-Z L-ROW.
     CALL "CONTENT-ENTITY-BY-KEY" USING L-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING L-DIM WS-TYPE L-X L-Y L-Z WS-YAW L-ROW
     GOBACK.
 END PROGRAM PN-SPAWN.

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
