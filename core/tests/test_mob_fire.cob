*> Implementation test (002-lane-fire, T11110; docs/protocol/18 section 2.5, 17 sections 3.9 and 4.11, 21 section 2.1, 29b-8 section 2.10): mobs set alight.
*> A fire block hurts a mob (1.0, soul fire 2.0) and sets it alight for 160 ticks, powder snow puts it out, the fire-immune species (blaze, ghast, magma cube, strider, wither
*> skeleton, wither, zombified piglin) never burn, Fire Aspect (80 ticks a level) and a burning arrow (100 ticks) set the victim alight, a player victim too.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-FIRE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-ER                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-FIRE                BINARY-LONG.
 01 WS-SOUL                BINARY-LONG.
 01 WS-SNOW                BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-AT                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-MX                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 9.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ZERO2               FLOAT-LONG VALUE 0.
 01 WS-ZERO3               FLOAT-LONG VALUE 0.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-CASE                PIC X(100).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-ENCH-KEY            PIC X(112) VALUE "minecraft:fire_aspect".
 01 WS-ENCH                BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-NONE-HANDLE         BINARY-LONG VALUE 0.
 01 WS-ARROW               BINARY-LONG.
 01 WS-ARROW-TYPE          BINARY-LONG.
 01 WS-BASE                BINARY-LONG VALUE 2000.
 01 WS-OWNER               BINARY-LONG VALUE 0.
 01 WS-NO-ROW              BINARY-LONG VALUE 0.
 01 WS-NO-ROW2             BINARY-LONG VALUE 0.
 01 WS-COW                 BINARY-LONG.
 01 WS-IMMUNE              BINARY-LONG.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/fire-registry".
 01 WS-TICKS               BINARY-LONG VALUE 100.
 01 WS-NAMES.
    05 FILLER              PIC X(20) VALUE "blaze".
    05 FILLER              PIC X(20) VALUE "ghast".
    05 FILLER              PIC X(20) VALUE "magma_cube".
    05 FILLER              PIC X(20) VALUE "strider".
    05 FILLER              PIC X(20) VALUE "wither_skeleton".
    05 FILLER              PIC X(20) VALUE "wither".
    05 FILLER              PIC X(20) VALUE "zombified_piglin".
    05 FILLER              PIC X(20) VALUE "zombie".
    05 FILLER              PIC X(20) VALUE "cow".
    05 FILLER              PIC X(20) VALUE "skeleton".
    05 FILLER              PIC X(20) VALUE "creeper".
 01 WS-LIST REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(20) OCCURS 11 TIMES.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     CALL "REGISTRY-LOAD-ALL" USING WS-DIR WS-STATUS
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-ENTITY-ROW(WS-PLAYER) TO WS-ER
     MOVE "minecraft:fire" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-FIRE
     MOVE "minecraft:soul_fire" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-SOUL
     MOVE "minecraft:powder_snow" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-SNOW
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FX = WS-BX - 4
     COMPUTE WS-FZ = WS-BZ - 4
     COMPUTE WS-FY = WS-BY - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-KIND
     COMPUTE WS-MX = WS-BX + 3
     COMPUTE WS-X = WS-MX + 0.5
     COMPUTE WS-Y = WS-BY
     COMPUTE WS-Z = WS-BZ + 0.5
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COW WS-ENTITY-ROW WS-STATUS

*>   The species table: the immune never burn, the others do.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 11
         MOVE SPACES TO WS-KEY
         STRING "minecraft:" FUNCTION TRIM(WS-NAME(WS-I)) DELIMITED BY SIZE INTO WS-KEY
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
         CALL "MOB-IGNITE" USING WS-ROW WS-TICKS
         MOVE SPACES TO WS-CASE
         STRING "acceptance fire 21-2.1: " FUNCTION TRIM(WS-NAME(WS-I)) " ignited: burning ticks" DELIMITED BY SIZE INTO WS-CASE
         MOVE 100 TO WS-EXP
         IF WS-I <= 7
             MOVE 0 TO WS-EXP
         END-IF
         MOVE EN-BURN(WS-ROW) TO WS-OBS
         CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
         CALL "ENTITY-REMOVE" USING WS-ROW
     END-PERFORM

*>   A fire block hurts and ignites a cow: 1 damage, 160 ticks; soul fire 2.
     MOVE WS-FIRE TO WS-AT
     PERFORM PUT-AT-MOB
     MOVE WS-COW TO WS-TYPE
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE EN-HEALTH(WS-ROW) TO WS-BEFORE
     MOVE 0 TO EN-HURT(WS-ROW)
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance fire 29b-8 2.10: a fire block sets a cow alight for 160 ticks" TO WS-CASE
     MOVE 160 TO WS-EXP
     MOVE EN-BURN(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance fire 17-4.11: a fire block takes 1 health of a cow" TO WS-CASE
     COMPUTE WS-EXP = WS-BEFORE - 1
     MOVE EN-HEALTH(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE WS-AIR TO WS-AT
     PERFORM PUT-AT-MOB
     MOVE WS-SNOW TO WS-AT
     PERFORM PUT-AT-MOB
     MOVE 0 TO EN-HURT(WS-ROW)
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance fire 29a-4.3: powder snow puts a burning cow out" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-BURN(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE WS-AIR TO WS-AT
     PERFORM PUT-AT-MOB
     CALL "ENTITY-REMOVE" USING WS-ROW
     MOVE WS-SOUL TO WS-AT
     PERFORM PUT-AT-MOB
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE EN-HEALTH(WS-ROW) TO WS-BEFORE
     MOVE 0 TO EN-HURT(WS-ROW)
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance fire 17-4.11: soul fire takes 2 health of a cow" TO WS-CASE
     COMPUTE WS-EXP = WS-BEFORE - 2
     MOVE EN-HEALTH(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   A blaze in the fire does not burn.
     MOVE "minecraft:blaze" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 0 TO EN-HURT(WS-ROW)
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance fire 21-2.1: a blaze in a fire block does not burn" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-BURN(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-ROW
     MOVE WS-AIR TO WS-AT
     PERFORM PUT-AT-MOB

*>   Fire Aspect II: 160 ticks on a mob and on a player; none from a plain item; none on a blaze.
     CALL "TOOL-ENCHANT-ID" USING WS-ENCH-KEY WS-ENCH
     MOVE 0 TO WS-HANDLE
     CALL "SP-ADD-ENCHANT" USING WS-HANDLE WS-ENCH WS-LEVEL
     MOVE WS-COW TO WS-TYPE
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "COMBAT-FIRE-ASPECT" USING WS-PLAYER WS-ROW WS-NO-ROW WS-NONE-HANDLE
     MOVE "acceptance fire 28 ignite: an item without Fire Aspect sets nothing alight" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-BURN(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "COMBAT-FIRE-ASPECT" USING WS-PLAYER WS-ROW WS-NO-ROW WS-HANDLE
     MOVE "acceptance fire 28 ignite: Fire Aspect II sets a mob alight for 160 ticks" TO WS-CASE
     MOVE 160 TO WS-EXP
     MOVE EN-BURN(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-ROW
     CALL "COMBAT-FIRE-ASPECT" USING WS-NO-ROW WS-ROW WS-NO-ROW2 WS-HANDLE
     MOVE "acceptance fire 28 ignite: a mob that is gone is not set alight" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-BURN(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO EN-BURN(WS-ER)
     CALL "COMBAT-FIRE-ASPECT" USING WS-NO-ROW WS-NO-ROW2 WS-PLAYER WS-HANDLE
     MOVE "acceptance fire 28 ignite: Fire Aspect II sets a player alight for 160 ticks" TO WS-CASE
     MOVE 160 TO WS-EXP
     MOVE EN-BURN(WS-ER) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO EN-BURN(WS-ER)

*>   A burning arrow: 100 ticks on a mob and on a player, a plain arrow none.
     CALL "ARROW-TYPE" USING WS-ARROW-TYPE
     MOVE WS-COW TO WS-TYPE
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "ARROW-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-ZERO WS-ZERO2 WS-ZERO3 WS-BASE WS-OWNER WS-ARROW
     CALL "ARROW-HIT" USING WS-ARROW WS-ROW WS-NO-ROW
     MOVE "acceptance fire 17-3.9: a plain arrow does not set a mob alight" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-BURN(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO EN-HURT(WS-ROW)
     CALL "ARROW-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-ZERO WS-ZERO2 WS-ZERO3 WS-BASE WS-OWNER WS-ARROW
     MOVE 100 TO EN-BURN(WS-ARROW)
     CALL "ARROW-HIT" USING WS-ARROW WS-ROW WS-NO-ROW
     MOVE "acceptance fire 17-3.9: a burning arrow sets a mob alight for 100 ticks" TO WS-CASE
     MOVE 100 TO WS-EXP
     MOVE EN-BURN(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ARROW-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-ZERO WS-ZERO2 WS-ZERO3 WS-BASE WS-OWNER WS-ARROW
     MOVE 100 TO EN-BURN(WS-ARROW)
     CALL "ARROW-HIT" USING WS-ARROW WS-NO-ROW WS-PLAYER
     MOVE "acceptance fire 17-3.9: a burning arrow sets a player alight for 100 ticks" TO WS-CASE
     MOVE 100 TO WS-EXP
     MOVE EN-BURN(WS-ER) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     STOP RUN.
 PUT-AT-MOB.
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-MX WS-BY WS-BZ WS-AT.
 END PROGRAM TEST-MOB-FIRE.

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
