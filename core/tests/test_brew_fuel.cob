*> Test of the brewing fuel (docs/protocol/57-client-closures-2 section 5; 25-5 section 2.4, 31-2 section 4): the data component brewing_fuel (id 86 in the data_component_type registry) is
*> set on blaze_powder only, one blaze powder gives 20 charges (data/minecraft/context_int_provider/brewing/uses_default.json) at the speed multiplier 1.0
*> (context_float_provider/brewing/speed_default.json), and BREW-FUEL gives both for an item (no fuel: 0 charges). Needs the generated packs (CC_GENERATED_DIR): a pass without them.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BREW-FUEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 01 WS-ENV                 PIC X(256).
 01 WS-DIR                 PIC X(256).
 01 WS-FILE                PIC X(300).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-FUELS               BINARY-LONG.
 01 WS-USES                BINARY-LONG.
 01 WS-FAST                BINARY-LONG VALUE 0.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-NAME                PIC X(32) VALUE "brewing_fuel".
 01 WS-VALUE               PIC X(100).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-STATIC-REGISTRY     PIC X(48) VALUE "minecraft:data_component_type".
 01 WS-STATIC-KEY          PIC X(112) VALUE "minecraft:brewing_fuel".
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "N" TO TL-MODE
         MOVE "test brew fuel no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS

     CALL "CONTENT-STATIC-ID" USING WS-STATIC-REGISTRY WS-STATIC-KEY WS-ITEM WS-STATUS
     MOVE "test brew fuel the data component type brewing_fuel is id 86" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 86 TO TL-EXPECTED-N
     MOVE WS-ITEM TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

     MOVE 0 TO WS-FUELS
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= CT-ITEM-COUNT
         CALL "CONTENT-ITEM-COMPONENT" USING WS-I WS-NAME WS-VALUE WS-STATUS
         IF WS-STATUS = CT-OK
             ADD 1 TO WS-FUELS
             MOVE WS-I TO WS-ITEM
         END-IF
     END-PERFORM
     MOVE "minecraft:blaze_powder" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-I WS-ITEM-ROW WS-STATUS
     MOVE WS-FUELS TO WS-E1
     MOVE 0 TO WS-E2
     IF WS-ITEM = WS-I
         MOVE 1 TO WS-E2
     END-IF
     MOVE "test brew fuel exactly one item has the component brewing_fuel and it is blaze_powder" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "BREW-FUEL" USING WS-I WS-FAST WS-USES WS-SPEED
     MOVE WS-USES TO WS-E1
     COMPUTE WS-E2 ROUNDED = WS-SPEED * 100
     MOVE "test brew fuel one blaze powder gives 20 charges at the speed multiplier 1.0 (x 100: 100)" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "20 100" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "minecraft:coal" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     CALL "BREW-FUEL" USING WS-ITEM WS-FAST WS-USES WS-SPEED
     MOVE WS-USES TO WS-E1
     MOVE "test brew fuel coal is no brewing fuel: 0 charges" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-BREW-FUEL.

 COPY CORETEST.
