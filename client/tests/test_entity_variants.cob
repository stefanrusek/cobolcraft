 *> Variant data of the mobs (docs/protocol 54 section 5, 19 section 1.3, 34-4..8): the Set Entity Data entry that holds the variant is kept in the replica row, the
 *> variant becomes the texture code of the atlas slot and a texture path, mobs of different variants have their own slots.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-VARIANTS.
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
 01 WS-S                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-K20                 PIC X(20).
 01 WS-PATH                PIC X(64).
 01 WS-MODEL               BINARY-LONG.
 01 WS-SERIAL              BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 01 WS-INT2                BINARY-LONG.
 01 WS-INT3                BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-KEY24               PIC X(24).
 01 WS-CASES-DATA.
    05 FILLER PIC X(20) VALUE "cow".
    05 FILLER PIC 99 VALUE 3.
    05 FILLER PIC X(64) VALUE "textures/entity/cow/cow_warm.png".
    05 FILLER PIC X(20) VALUE "cow~b".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(64) VALUE "textures/entity/cow/cow_cold_baby.png".
    05 FILLER PIC X(20) VALUE "pig".
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC X(64) VALUE "textures/entity/pig/pig_temperate.png".
    05 FILLER PIC X(20) VALUE "chicken".
    05 FILLER PIC 99 VALUE 3.
    05 FILLER PIC X(64) VALUE "textures/entity/chicken/chicken_warm.png".
    05 FILLER PIC X(20) VALUE "frog".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(64) VALUE "textures/entity/frog/frog_cold.png".
    05 FILLER PIC X(20) VALUE "wolf".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(64) VALUE "textures/entity/wolf/wolf_ashen.png".
    05 FILLER PIC X(20) VALUE "wolf".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC X(64) VALUE "textures/entity/wolf/wolf.png".
    05 FILLER PIC X(20) VALUE "wolf~b".
    05 FILLER PIC 99 VALUE 6.
    05 FILLER PIC X(64) VALUE "textures/entity/wolf/wolf_snowy_baby.png".
    05 FILLER PIC X(20) VALUE "cat".
    05 FILLER PIC 99 VALUE 3.
    05 FILLER PIC X(64) VALUE "textures/entity/cat/cat_british_shorthair.png".
    05 FILLER PIC X(20) VALUE "horse".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC X(64) VALUE "textures/entity/horse/horse_brown.png".
    05 FILLER PIC X(20) VALUE "horse~b".
    05 FILLER PIC 99 VALUE 7.
    05 FILLER PIC X(64) VALUE "textures/entity/horse/horse_darkbrown_baby.png".
    05 FILLER PIC X(20) VALUE "llama".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC X(64) VALUE "textures/entity/llama/llama_gray.png".
    05 FILLER PIC X(20) VALUE "rabbit".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC X(64) VALUE "textures/entity/rabbit/white_splotched.png".
    05 FILLER PIC X(20) VALUE "rabbit".
    05 FILLER PIC 99 VALUE 8.
    05 FILLER PIC X(64) VALUE "textures/entity/rabbit/caerbannog.png".
    05 FILLER PIC X(20) VALUE "axolotl".
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC X(64) VALUE "textures/entity/axolotl/axolotl_blue.png".
    05 FILLER PIC X(20) VALUE "axolotl~b".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(64) VALUE "textures/entity/axolotl/axolotl_lucy_baby.png".
    05 FILLER PIC X(20) VALUE "parrot".
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC X(64) VALUE "textures/entity/parrot/parrot_grey.png".
    05 FILLER PIC X(20) VALUE "fox".
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC X(64) VALUE "textures/entity/fox/fox_snow.png".
    05 FILLER PIC X(20) VALUE "fox~b".
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC X(64) VALUE "textures/entity/fox/fox_snow_baby.png".
    05 FILLER PIC X(20) VALUE "panda".
    05 FILLER PIC 99 VALUE 3.
    05 FILLER PIC X(64) VALUE "textures/entity/panda/panda_worried.png".
    05 FILLER PIC X(20) VALUE "panda~b".
    05 FILLER PIC 99 VALUE 3.
    05 FILLER PIC X(64) VALUE "textures/entity/panda/worried_panda_baby.png".
    05 FILLER PIC X(20) VALUE "mooshroom".
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC X(64) VALUE "textures/entity/cow/mooshroom_brown.png".
    05 FILLER PIC X(20) VALUE "zombie".
    05 FILLER PIC 99 VALUE 3.
    05 FILLER PIC X(64) VALUE SPACES.
 01 WS-CASES REDEFINES WS-CASES-DATA.
    05 WS-C OCCURS 23 TIMES.
       10 WS-C-KEY         PIC X(20).
       10 WS-C-CODE        PIC 99.
       10 WS-C-PATH        PIC X(64).
 01 WS-CODE-L               BINARY-LONG.
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
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 23
         MOVE SPACES TO WS-PATH
         MOVE WS-C-CODE(WS-I) TO WS-CODE-L
         CALL "ENTITY-TEX-PATH" USING WS-C-KEY(WS-I) WS-CODE-L WS-PATH
         MOVE "T" TO TL-MODE
         MOVE SPACES TO TL-CASE
         STRING "acceptance variants texture of " FUNCTION TRIM(WS-C-KEY(WS-I)) " code " WS-C-CODE(WS-I) DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-C-PATH(WS-I) TO TL-EXPECTED
         MOVE WS-PATH TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   Set Entity Data: the entry that holds the variant of the type (wolf 23, cow 18, villager 19) is kept; another entry of the type is not.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "wolf" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 1 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE "N" TO TL-MODE
     MOVE "acceptance variants a spawned mob has no variant yet" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     MOVE EN-VAR(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 18 TO WS-INDEX
     MOVE 25 TO WS-SERIAL
     MOVE 5 TO WS-INT
     MOVE 0 TO WS-INT2 WS-INT3
     CALL "ENTITY-VARIANT-SET" USING CLIENT-STATE 1 WS-INDEX WS-SERIAL WS-INT WS-INT2 WS-INT3
     MOVE "acceptance variants wolf entry 18 is not the variant" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     MOVE EN-VAR(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 23 TO WS-INDEX
     CALL "ENTITY-VARIANT-SET" USING CLIENT-STATE 1 WS-INDEX WS-SERIAL WS-INT WS-INT2 WS-INT3
     MOVE "acceptance variants wolf entry 23 is the variant" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE EN-VAR(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "villager" TO EN-KEY(1)
     MOVE 19 TO WS-INDEX
     MOVE 18 TO WS-SERIAL
     MOVE 2 TO WS-INT
     MOVE 4 TO WS-INT2
     MOVE 3 TO WS-INT3
     CALL "ENTITY-VARIANT-SET" USING CLIENT-STATE 1 WS-INDEX WS-SERIAL WS-INT WS-INT2 WS-INT3
     MOVE "acceptance variants villager data is type, profession and level" TO TL-CASE
     MOVE 243 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-VAR(1) * 100 + EN-VAR2(1) * 10 + EN-VAR3(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Slots: a cow of variant warm and a cow of variant cold draw from two slots with their texture codes.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE "cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 1 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE 2 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE 2 TO EN-VAR(1)
     MOVE 0 TO EN-VAR(2)
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "acceptance variants two cows of different variants take two slots" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE EA-MT-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-N
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > EA-MT-COUNT
         IF EA-MT-TEX(WS-S) = 3
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "acceptance variants the warm cow's slot has texture code 3" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance variants both cows are meshed as whole cuboids" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF RL-EN-COUNT >= 72 AND FUNCTION MOD(RL-EN-COUNT, 36) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-ENTITY-VARIANTS.

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

