 *> Overlay layers of the mobs (docs/protocol 34-3 section 1.5 villager type, profession and level layers, 34-4 8.5 horse markings, 34-5 2.5 wolf textures and collar,
 *> 3 cat collar, fox sleeping textures): ENTITY-OVERLAY lists the layers of a replica row, ENTITY-TEX-PATH maps their codes to texture paths, the metadata entries that
 *> hold the tame flags, collar colour, anger end time and fox flags are kept in the row, and ENTITIES-MESH draws each layer once more with its own atlas slot.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-OVERLAYS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY CLMODELS.
 COPY TESTLIB.
 01 WS-KEY                 PIC X(112).
 01 WS-ROW-AREA            PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG VALUE 10.5.
 01 WS-Y                   FLOAT-LONG VALUE 64.
 01 WS-Z                   FLOAT-LONG VALUE 10.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ID                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-I-D                 PIC 9.
 01 WS-N                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-K20                 PIC X(20).
 01 WS-PATH                PIC X(64).
 01 WS-RED                 FLOAT-LONG.
 01 WS-GREEN               FLOAT-LONG.
 01 WS-BLUE                FLOAT-LONG.
 01 WS-OVM                 BINARY-LONG.
 01 WS-MODEL               BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-SERIAL              BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 01 WS-INT2                BINARY-LONG.
 01 WS-INT3                BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-BASE-COUNT          BINARY-LONG.
 01 WS-CASES-DATA.
    05 FILLER PIC X(20) VALUE "villager".
    05 FILLER PIC 9999 VALUE 1003.
    05 FILLER PIC X(64) VALUE "textures/entity/villager/type/plains.png".
    05 FILLER PIC X(20) VALUE "villager~b".
    05 FILLER PIC 9999 VALUE 1007.
    05 FILLER PIC X(64) VALUE "textures/entity/villager/baby/taiga.png".
    05 FILLER PIC X(20) VALUE "villager".
    05 FILLER PIC 9999 VALUE 2002.
    05 FILLER PIC X(64) VALUE "textures/entity/villager/profession/butcher.png".
    05 FILLER PIC X(20) VALUE "villager".
    05 FILLER PIC 9999 VALUE 2014.
    05 FILLER PIC X(64) VALUE "textures/entity/villager/profession/weaponsmith.png".
    05 FILLER PIC X(20) VALUE "villager".
    05 FILLER PIC 9999 VALUE 3001.
    05 FILLER PIC X(64) VALUE "textures/entity/villager/profession_level/stone.png".
    05 FILLER PIC X(20) VALUE "villager".
    05 FILLER PIC 9999 VALUE 3005.
    05 FILLER PIC X(64) VALUE "textures/entity/villager/profession_level/diamond.png".
    05 FILLER PIC X(20) VALUE "zombie_villager".
    05 FILLER PIC 9999 VALUE 1001.
    05 FILLER PIC X(64) VALUE "textures/entity/zombie_villager/type/desert.png".
    05 FILLER PIC X(20) VALUE "zombie_villager~b".
    05 FILLER PIC 9999 VALUE 1002.
    05 FILLER PIC X(64) VALUE "textures/entity/zombie_villager/baby/jungle.png".
    05 FILLER PIC X(20) VALUE "zombie_villager".
    05 FILLER PIC 9999 VALUE 3004.
    05 FILLER PIC X(64) VALUE "textures/entity/zombie_villager/profession_level/emerald.png".
    05 FILLER PIC X(20) VALUE "horse".
    05 FILLER PIC 9999 VALUE 4001.
    05 FILLER PIC X(64) VALUE "textures/entity/horse/horse_markings_white.png".
    05 FILLER PIC X(20) VALUE "horse".
    05 FILLER PIC 9999 VALUE 4002.
    05 FILLER PIC X(64) VALUE "textures/entity/horse/horse_markings_whitefield.png".
    05 FILLER PIC X(20) VALUE "horse".
    05 FILLER PIC 9999 VALUE 4003.
    05 FILLER PIC X(64) VALUE "textures/entity/horse/horse_markings_whitedots.png".
    05 FILLER PIC X(20) VALUE "horse~b".
    05 FILLER PIC 9999 VALUE 4004.
    05 FILLER PIC X(64) VALUE "textures/entity/horse/horse_markings_blackdots_baby.png".
    05 FILLER PIC X(20) VALUE "wolf".
    05 FILLER PIC 9999 VALUE 5001.
    05 FILLER PIC X(64) VALUE "textures/entity/wolf/wolf_collar.png".
    05 FILLER PIC X(20) VALUE "wolf~b".
    05 FILLER PIC 9999 VALUE 5001.
    05 FILLER PIC X(64) VALUE "textures/entity/wolf/wolf_collar_baby.png".
    05 FILLER PIC X(20) VALUE "cat".
    05 FILLER PIC 9999 VALUE 5001.
    05 FILLER PIC X(64) VALUE "textures/entity/cat/cat_collar.png".
    05 FILLER PIC X(20) VALUE "cat~b".
    05 FILLER PIC 9999 VALUE 5001.
    05 FILLER PIC X(64) VALUE "textures/entity/cat/cat_collar_baby.png".
    05 FILLER PIC X(20) VALUE "wolf".
    05 FILLER PIC 9999 VALUE 104.
    05 FILLER PIC X(64) VALUE "textures/entity/wolf/wolf_tame.png".
    05 FILLER PIC X(20) VALUE "wolf".
    05 FILLER PIC 9999 VALUE 202.
    05 FILLER PIC X(64) VALUE "textures/entity/wolf/wolf_black_angry.png".
    05 FILLER PIC X(20) VALUE "wolf~b".
    05 FILLER PIC 9999 VALUE 105.
    05 FILLER PIC X(64) VALUE "textures/entity/wolf/wolf_rusty_tame_baby.png".
    05 FILLER PIC X(20) VALUE "wolf~b".
    05 FILLER PIC 9999 VALUE 204.
    05 FILLER PIC X(64) VALUE "textures/entity/wolf/wolf_angry_baby.png".
    05 FILLER PIC X(20) VALUE "fox".
    05 FILLER PIC 9999 VALUE 101.
    05 FILLER PIC X(64) VALUE "textures/entity/fox/fox_sleep.png".
    05 FILLER PIC X(20) VALUE "fox".
    05 FILLER PIC 9999 VALUE 102.
    05 FILLER PIC X(64) VALUE "textures/entity/fox/fox_snow_sleep.png".
    05 FILLER PIC X(20) VALUE "fox~b".
    05 FILLER PIC 9999 VALUE 101.
    05 FILLER PIC X(64) VALUE "textures/entity/fox/fox_sleep_baby.png".
    05 FILLER PIC X(20) VALUE "fox~b".
    05 FILLER PIC 9999 VALUE 102.
    05 FILLER PIC X(64) VALUE "textures/entity/fox/fox_snow_sleep_baby.png".
 01 WS-CASES REDEFINES WS-CASES-DATA.
    05 WS-C OCCURS 25 TIMES.
       10 WS-C-KEY         PIC X(20).
       10 WS-C-CODE        PIC 9999.
       10 WS-C-PATH        PIC X(64).
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE 0 TO PK-COUNT
     CALL "ENTITY-ATLAS-BUILD" USING CLIENT-STATE
     MOVE 256 TO PL-HEIGHT
     MOVE 0 TO SK-U
     MOVE 10 TO WS-EYE(1) WS-EYE(3)
     MOVE 64 TO WS-EYE(2)
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
*>   Texture paths of the codes.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 25
         MOVE SPACES TO WS-PATH
         MOVE WS-C-CODE(WS-I) TO WS-CODE
         CALL "ENTITY-TEX-PATH" USING WS-C-KEY(WS-I) WS-CODE WS-PATH
         MOVE "T" TO TL-MODE
         MOVE SPACES TO TL-CASE
         STRING "acceptance overlays path " WS-C-KEY(WS-I) WS-C-CODE(WS-I) DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-C-PATH(WS-I) TO TL-EXPECTED
         MOVE WS-PATH TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   Villager: type plains (2), profession armorer (1), level 3: three layers, in the order of the document; a baby has the type layer only.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 1 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE 2 TO EN-VAR(1)
     MOVE 1 TO EN-VAR2(1)
     MOVE 3 TO EN-VAR3(1)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 WS-I WS-CODE WS-RED WS-GREEN WS-BLUE WS-OVM
         MOVE "N" TO TL-MODE
         MOVE SPACES TO TL-CASE
         MOVE WS-I TO WS-I-D
         STRING "acceptance overlays villager layer " WS-I-D DELIMITED BY SIZE INTO TL-CASE
         EVALUATE WS-I
             WHEN 1 MOVE 1003 TO TL-EXPECTED-N
             WHEN 2 MOVE 2001 TO TL-EXPECTED-N
             WHEN 3 MOVE 3003 TO TL-EXPECTED-N
             WHEN OTHER MOVE 0 TO TL-EXPECTED-N
         END-EVALUATE
         MOVE WS-CODE TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     MOVE 0 TO EA-MT-COUNT
     MOVE 1 TO EN-BABY(1)
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 2 WS-CODE WS-RED WS-GREEN WS-BLUE WS-OVM
     MOVE "acceptance overlays a baby villager has no profession layer" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 1 WS-CODE WS-RED WS-GREEN WS-BLUE WS-OVM
     MOVE "acceptance overlays a baby villager has its type layer" TO TL-CASE
     MOVE 1003 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-BABY(1)
*>   Profession none (0) and nitwit (11): no profession layer, a nitwit has no level layer either; a level beyond 5 is clamped; an unknown type has no type layer.
     MOVE 0 TO EN-VAR2(1)
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 2 WS-CODE WS-RED WS-GREEN WS-BLUE WS-OVM
     MOVE "acceptance overlays profession none has no layer 2" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 3 WS-CODE WS-RED WS-GREEN WS-BLUE WS-OVM
     MOVE "acceptance overlays profession none has no level layer" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 11 TO EN-VAR2(1)
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 2 WS-CODE WS-RED WS-GREEN WS-BLUE WS-OVM
     MOVE "acceptance overlays a nitwit has a profession layer" TO TL-CASE
     MOVE 2011 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 3 WS-CODE WS-RED WS-GREEN WS-BLUE WS-OVM
     MOVE "acceptance overlays a nitwit has no level layer" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO EN-VAR2(1)
     MOVE 9 TO EN-VAR3(1)
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 3 WS-CODE WS-RED WS-GREEN WS-BLUE WS-OVM
     MOVE "acceptance overlays a level beyond 5 is clamped" TO TL-CASE
     MOVE 3005 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-VAR3(1)
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 3 WS-CODE WS-RED WS-GREEN WS-BLUE WS-OVM
     MOVE "acceptance overlays a level below 1 is clamped" TO TL-CASE
     MOVE 3001 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -1 TO EN-VAR(1) EN-VAR2(1) EN-VAR3(1)
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 1 WS-CODE WS-RED WS-GREEN WS-BLUE WS-OVM
     MOVE "acceptance overlays a villager without data has no layers" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A villager with the three layers is meshed four times (body and three layers), each layer in an atlas slot of its own.
     MOVE 2 TO EN-VAR(1)
     MOVE 1 TO EN-VAR2(1)
     MOVE 3 TO EN-VAR3(1)
     MOVE 0 TO EA-MT-COUNT
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "acceptance overlays a villager with three layers takes four slots" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 4 TO TL-EXPECTED-N
     MOVE EA-MT-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance overlays the four meshes have the same number of vertices" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF RL-EN-COUNT > 0 AND FUNCTION MOD(RL-EN-COUNT, 4) = 0 AND FUNCTION MOD(RL-EN-COUNT / 4, 36) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-BASE-COUNT = RL-EN-COUNT / 4
     MOVE -1 TO EN-VAR(1) EN-VAR2(1) EN-VAR3(1)
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "acceptance overlays without data only the body is meshed" TO TL-CASE
     MOVE WS-BASE-COUNT TO TL-EXPECTED-N
     MOVE RL-EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A zombie villager uses the same layers; a witch or a cow has none.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "zombie_villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 1 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE 0 TO EN-VAR(1)
     MOVE 5 TO EN-VAR2(1)
     MOVE 2 TO EN-VAR3(1)
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 2 WS-CODE WS-RED WS-GREEN WS-BLUE WS-OVM
     MOVE "acceptance overlays zombie villager profession layer" TO TL-CASE
     MOVE 2005 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 1 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 1 WS-CODE WS-RED WS-GREEN WS-BLUE WS-OVM
     MOVE "acceptance overlays a cow has no layers" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Horse: colour 2 with markings 3 (variant entry 19 = colour + 256 x markings): layer 1 is the markings 3; markings 0 give none; a donkey has none.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "horse" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 1 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     COMPUTE EN-VAR(1) = 2 + 3 * 256
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 1 WS-CODE WS-RED WS-GREEN WS-BLUE WS-OVM
     MOVE "acceptance overlays horse markings layer" TO TL-CASE
     MOVE 4003 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO EN-VAR(1)
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 1 WS-CODE WS-RED WS-GREEN WS-BLUE WS-OVM
     MOVE "acceptance overlays horse without markings has no layer" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "donkey" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 1 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     COMPUTE EN-VAR(1) = 2 + 3 * 256
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 1 WS-CODE WS-RED WS-GREEN WS-BLUE WS-OVM
     MOVE "acceptance overlays a donkey has no markings layer" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Metadata of a wolf: flags (entry 18, bit 4 tame), collar (21), anger end time (22, a LONG); of a cat: flags 18, collar 23; of a fox: flags 19.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "wolf" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 1 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE "N" TO TL-MODE
     MOVE "acceptance overlays a spawned wolf is not tame, red collar, not angry" TO TL-CASE
     MOVE 14 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-X1(1) * 100 + EN-X2(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 18 TO WS-INDEX
     MOVE 0 TO WS-SERIAL WS-INT2 WS-INT3
     MOVE 4 TO WS-INT
     MOVE 0 TO WS-LONG
     CALL "ENTITY-VARIANT-SET" USING CLIENT-STATE 1 WS-INDEX WS-SERIAL WS-INT WS-INT2 WS-INT3 WS-LONG
     MOVE "acceptance overlays wolf entry 18 is the tamable flags" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE EN-X1(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 21 TO WS-INDEX
     MOVE 1 TO WS-SERIAL
     MOVE 3 TO WS-INT
     CALL "ENTITY-VARIANT-SET" USING CLIENT-STATE 1 WS-INDEX WS-SERIAL WS-INT WS-INT2 WS-INT3 WS-LONG
     MOVE "acceptance overlays wolf entry 21 is the collar colour" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE EN-X2(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 22 TO WS-INDEX
     MOVE 2 TO WS-SERIAL
     MOVE 5000 TO WS-LONG
     CALL "ENTITY-VARIANT-SET" USING CLIENT-STATE 1 WS-INDEX WS-SERIAL WS-INT WS-INT2 WS-INT3 WS-LONG
     MOVE "acceptance overlays wolf entry 22 is the anger end time" TO TL-CASE
     MOVE 5000 TO TL-EXPECTED-N
     MOVE EN-X3(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 17 TO WS-INDEX
     MOVE 1 TO WS-SERIAL
     MOVE 9 TO WS-INT
     CALL "ENTITY-VARIANT-SET" USING CLIENT-STATE 1 WS-INDEX WS-SERIAL WS-INT WS-INT2 WS-INT3 WS-LONG
     MOVE "acceptance overlays wolf entry 17 is none of them" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE EN-X2(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Wolf textures: tamed (flag 4) the tame texture, angry (end time above the clock) the angry one, tame wins; the collar layer only when tamed, tinted by the dye
*>   (3 light blue: 0x3AB3DA of the diffuse table), its code 5001.
     MOVE 0 TO EN-VAR(1)
     MOVE 1000 TO PL-DAY-TICKS
     CALL "ENTITY-MODEL-ROW" USING CLIENT-STATE 1 WS-MODEL
     CALL "ENTITY-TEX-CODE" USING CLIENT-STATE 1 WS-MODEL WS-CODE
     MOVE "acceptance overlays a tame wolf of variant 0 has the tame texture code 101" TO TL-CASE
     MOVE 101 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 1 WS-CODE WS-RED WS-GREEN WS-BLUE WS-OVM
     MOVE "acceptance overlays a tame wolf has the collar layer" TO TL-CASE
     MOVE 5001 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5001 TO EN-OVL(1)
     CALL "ENTITY-TINT" USING CLIENT-STATE 1 WS-MODEL WS-RED WS-GREEN WS-BLUE
     MOVE 0 TO EN-OVL(1)
     MOVE "acceptance overlays the collar of dye 3 is tinted 0x3A in red" TO TL-CASE
     MOVE 58 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-RED * 255
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-X1(1)
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 1 WS-CODE WS-RED WS-GREEN WS-BLUE WS-OVM
     MOVE "acceptance overlays a wild wolf has no collar layer" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-TEX-CODE" USING CLIENT-STATE 1 WS-MODEL WS-CODE
     MOVE "acceptance overlays an angry wolf has the angry texture code 201" TO TL-CASE
     MOVE 201 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 500 TO PL-DAY-TICKS
     MOVE 5000 TO EN-X3(1)
     MOVE 4 TO EN-X1(1)
     CALL "ENTITY-TEX-CODE" USING CLIENT-STATE 1 WS-MODEL WS-CODE
     MOVE "acceptance overlays tame wins over angry" TO TL-CASE
     MOVE 101 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-X1(1)
     MOVE 9000 TO PL-DAY-TICKS
     CALL "ENTITY-TEX-CODE" USING CLIENT-STATE 1 WS-MODEL WS-CODE
     MOVE "acceptance overlays an expired anger is the wild texture" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Cat: tamed (flags 18 bit 4) collar layer with entry 23; a fox: sleeping (flag 19 bit 32) the sleep texture code + 100.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "cat" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 1 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE 18 TO WS-INDEX
     MOVE 0 TO WS-SERIAL
     MOVE 4 TO WS-INT
     CALL "ENTITY-VARIANT-SET" USING CLIENT-STATE 1 WS-INDEX WS-SERIAL WS-INT WS-INT2 WS-INT3 WS-LONG
     MOVE 23 TO WS-INDEX
     MOVE 1 TO WS-SERIAL
     MOVE 11 TO WS-INT
     CALL "ENTITY-VARIANT-SET" USING CLIENT-STATE 1 WS-INDEX WS-SERIAL WS-INT WS-INT2 WS-INT3 WS-LONG
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 1 WS-CODE WS-RED WS-GREEN WS-BLUE WS-OVM
     MOVE "acceptance overlays a tame cat has the collar layer" TO TL-CASE
     MOVE 5001 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance overlays the cat's collar colour is entry 23" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     MOVE EN-X2(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "fox" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 1 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE 1 TO EN-VAR(1)
     MOVE 19 TO WS-INDEX
     MOVE 0 TO WS-SERIAL
     MOVE 32 TO WS-INT
     CALL "ENTITY-VARIANT-SET" USING CLIENT-STATE 1 WS-INDEX WS-SERIAL WS-INT WS-INT2 WS-INT3 WS-LONG
     CALL "ENTITY-MODEL-ROW" USING CLIENT-STATE 1 WS-MODEL
     CALL "ENTITY-TEX-CODE" USING CLIENT-STATE 1 WS-MODEL WS-CODE
     MOVE "acceptance overlays a sleeping snow fox has the code 102" TO TL-CASE
     MOVE 102 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-INT
     CALL "ENTITY-VARIANT-SET" USING CLIENT-STATE 1 WS-INDEX WS-SERIAL WS-INT WS-INT2 WS-INT3 WS-LONG
     CALL "ENTITY-TEX-CODE" USING CLIENT-STATE 1 WS-MODEL WS-CODE
     MOVE "acceptance overlays a fox that is not sleeping has the code 2" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Panda genes (19 section 8: main gene entry 21, hidden gene 22): a dominant main gene shows; a recessive one (brown 4, weak 5) shows only when the hidden gene is the
*>   same, else the normal panda.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "panda" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 1 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE 21 TO WS-INDEX
     MOVE 0 TO WS-SERIAL
     MOVE 4 TO WS-INT
     CALL "ENTITY-VARIANT-SET" USING CLIENT-STATE 1 WS-INDEX WS-SERIAL WS-INT WS-INT2 WS-INT3 WS-LONG
     CALL "ENTITY-MODEL-ROW" USING CLIENT-STATE 1 WS-MODEL
     CALL "ENTITY-TEX-CODE" USING CLIENT-STATE 1 WS-MODEL WS-CODE
     MOVE "acceptance overlays a brown panda without the hidden gene is the normal panda" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 22 TO WS-INDEX
     CALL "ENTITY-VARIANT-SET" USING CLIENT-STATE 1 WS-INDEX WS-SERIAL WS-INT WS-INT2 WS-INT3 WS-LONG
     CALL "ENTITY-TEX-CODE" USING CLIENT-STATE 1 WS-MODEL WS-CODE
     MOVE "acceptance overlays a brown panda with the hidden gene brown is brown" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 21 TO WS-INDEX
     MOVE 1 TO WS-INT
     CALL "ENTITY-VARIANT-SET" USING CLIENT-STATE 1 WS-INDEX WS-SERIAL WS-INT WS-INT2 WS-INT3 WS-LONG
     CALL "ENTITY-TEX-CODE" USING CLIENT-STATE 1 WS-MODEL WS-CODE
     MOVE "acceptance overlays a lazy panda is lazy whatever the hidden gene" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-ENTITY-OVERLAYS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MM-SPAWN.
*> USING CLIENT-STATE, entity id, type (registry id), x y z (FLOAT-LONG), yaw (FLOAT-SHORT, also the head yaw): Add Entity.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-ADD                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-UUID                PIC X(16) VALUE LOW-VALUES.
 01 WS-V0                  FLOAT-LONG VALUE 0.
 01 WS-V1                  FLOAT-LONG VALUE 0.
 01 WS-V2                  FLOAT-LONG VALUE 0.
 01 WS-A0                  FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-YAW                  FLOAT-SHORT.
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-TYPE L-X L-Y L-Z L-YAW.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ID
     CALL "PB-PUT-UUID" USING PB-BUFFER WS-UUID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-TYPE
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-X
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Y
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Z
     CALL "PB-PUT-LPVEC3" USING PB-BUFFER WS-V0 WS-V1 WS-V2
     CALL "PB-PUT-ANGLE" USING PB-BUFFER WS-A0
     CALL "PB-PUT-ANGLE" USING PB-BUFFER L-YAW
     CALL "PB-PUT-ANGLE" USING PB-BUFFER L-YAW
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     MOVE 0 TO PB-POS
     CALL "ENTITY-PACKET" USING CLIENT-STATE PB-BUFFER WS-ADD
     GOBACK.
 END PROGRAM MM-SPAWN.

