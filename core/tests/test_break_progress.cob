*> Test of the break progress formula (core/src/breaking.cob; docs/protocol/13 §2.1 and the worked examples of §9;
*> docs/design/cobolcraft-standard-core.md CORE-18 and CORE-27 tables): progress per tick from the hardness, the tool
*> speed, the correct tool for drops, efficiency, haste, fatigue, water and the ground; the break time by the client's
*> single-precision accumulation; the stage floor(10 x progress); the server's 0.7 acceptance; the tool tier rule; and
*> the tool speed and tier the item table reads from the content.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BREAK-PROGRESS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CITEMS.
 01 WS-HARDNESS            BINARY-LONG.
 01 WS-SPEED               BINARY-LONG.
 01 WS-CORRECT             BINARY-LONG.
 01 WS-EFFICIENCY          BINARY-LONG.
 01 WS-HASTE               BINARY-LONG.
 01 WS-FATIGUE             BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-GROUND              BINARY-LONG.
 01 WS-PPM                 BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-RATE                FLOAT-SHORT.
 01 WS-COUNT               BINARY-LONG.
 01 WS-STAGE               BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-REQUIRES            BINARY-LONG.
 01 WS-CLASS-OK            BINARY-LONG.
 01 WS-TOOL-TIER           BINARY-LONG.
 01 WS-BLOCK-TIER          BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.
 01 WS-TEXT                PIC X(200).
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS

     MOVE "test break progress 13§9 stone (hardness 1.5, required tool) with a speed 6.0 tool that is "
         & "correct, standing: 0.13333 per tick, 8 ticks" TO TL-CASE
     PERFORM INIT-INPUTS
     MOVE 1500 TO WS-HARDNESS
     MOVE 6000 TO WS-SPEED
     MOVE 1 TO WS-CORRECT
     PERFORM RATE-AND-TICKS
     MOVE "133333 8" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test break progress 13§9 bare hand on stone (speed 1.0, not correct): 0.006667 per tick, "
         & "151 ticks (accumulation of CORE-27; 13§9 gives 150, the closed formula, at this boundary)" TO TL-CASE
     PERFORM INIT-INPUTS
     MOVE 1500 TO WS-HARDNESS
     MOVE 0 TO WS-CORRECT
     PERFORM RATE-AND-TICKS
     MOVE "6667 151" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test break progress 13§9 dirt (0.5, no tool required) by hand: 0.06667, 15 ticks" TO TL-CASE
     PERFORM INIT-INPUTS
     MOVE 500 TO WS-HARDNESS
     PERFORM RATE-AND-TICKS
     MOVE "66667 15" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test break progress 13§9 Efficiency III on the speed 6.0 tool: speed 6 + 3 x 3 + 1 = 16, "
         & "0.35556, 3 ticks" TO TL-CASE
     PERFORM INIT-INPUTS
     MOVE 1500 TO WS-HARDNESS
     MOVE 6000 TO WS-SPEED
     MOVE 3 TO WS-EFFICIENCY
     PERFORM RATE-AND-TICKS
     MOVE "355556 3" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test break progress 13§9 the same while airborne: divided by 5, 0.07111, 15 ticks" TO TL-CASE
     MOVE 0 TO WS-GROUND
     PERFORM RATE-AND-TICKS
     MOVE "71111 15" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test break progress 13§2.1 step 2: Efficiency adds nothing when the speed is not above 1 "
         & "(bare hand, Efficiency V): unchanged 0.06667 for dirt" TO TL-CASE
     PERFORM INIT-INPUTS
     MOVE 500 TO WS-HARDNESS
     MOVE 5 TO WS-EFFICIENCY
     PERFORM RATE-AND-TICKS
     MOVE "66667 15" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test break progress 13§2.1 step 3: haste with amplifier 2 (Haste III) multiplies by "
         & "1 + 3 x 0.2 = 1.6 (the §9 example text; Haste II is 1.4)" TO TL-CASE
     PERFORM INIT-INPUTS
     MOVE 1500 TO WS-HARDNESS
     MOVE 6000 TO WS-SPEED
     MOVE 3 TO WS-HASTE
     PERFORM RATE-AND-TICKS
     MOVE "213333 5" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test break progress 13§2.1 step 4: Mining Fatigue I multiplies by 0.3 (0.04), fatigue III "
         & "by 0.027" TO TL-CASE
     PERFORM INIT-INPUTS
     MOVE 1500 TO WS-HARDNESS
     MOVE 6000 TO WS-SPEED
     MOVE 1 TO WS-FATIGUE
     PERFORM RATE-AND-TICKS
     MOVE WS-PPM TO WS-EDIT
     MOVE 3 TO WS-FATIGUE
     PERFORM RATE-AND-TICKS
     MOVE WS-PPM TO WS-EDIT2
     MOVE SPACES TO TL-EXPECTED
     MOVE "40000 3600" TO TL-EXPECTED
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test break progress 13§2.1 step 6: eyes in water multiply by 0.2 (0.02667)" TO TL-CASE
     PERFORM INIT-INPUTS
     MOVE 1500 TO WS-HARDNESS
     MOVE 6000 TO WS-SPEED
     MOVE 1 TO WS-WATER
     PERFORM RATE-AND-TICKS
     MOVE "26667 38" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test break progress 13§2.1 step 8: an unbreakable block (hardness -1) has progress 0 and "
         & "never breaks" TO TL-CASE
     PERFORM INIT-INPUTS
     MOVE -1 TO WS-HARDNESS
     PERFORM RATE-AND-TICKS
     MOVE "0 0" TO TL-EXPECTED
     PERFORM CHECK

     PERFORM TABLE-ROW-CASES

     MOVE "test break progress 13§9 stages after 1 to 7 ticks of the 0.1333 rate are 1 2 4 5 6 8 9, "
         & "and the 8th tick reaches 1.067 (stage capped at 9)" TO TL-CASE
     PERFORM INIT-INPUTS
     MOVE 1500 TO WS-HARDNESS
     MOVE 6000 TO WS-SPEED
     MOVE 1 TO WS-CORRECT
     CALL "BREAK-RATE" USING WS-HARDNESS WS-SPEED WS-CORRECT WS-EFFICIENCY WS-HASTE WS-FATIGUE
         WS-WATER WS-GROUND WS-RATE
     MOVE SPACES TO WS-TEXT TL-OBSERVED
     PERFORM VARYING WS-COUNT FROM 1 BY 1 UNTIL WS-COUNT > 8
         CALL "BREAK-STAGE" USING WS-RATE WS-COUNT WS-STAGE
         MOVE WS-STAGE TO WS-EDIT
         STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
         MOVE TL-OBSERVED TO WS-TEXT
         MOVE SPACES TO TL-OBSERVED
     END-PERFORM
     MOVE "1 2 4 5 6 8 9 9" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test break progress 13§9 the server accepts the stop at progress >= 0.7: 4 ticks after the "
         & "start 0.667 refuses, 5 ticks 0.8 accepts" TO TL-CASE
     MOVE 4 TO WS-TICKS
     CALL "BREAK-ACCEPTS" USING WS-RATE WS-TICKS WS-RESULT
     MOVE WS-RESULT TO WS-EDIT
     MOVE 5 TO WS-TICKS
     CALL "BREAK-ACCEPTS" USING WS-RATE WS-TICKS WS-RESULT
     MOVE WS-RESULT TO WS-EDIT2
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "0 1" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     PERFORM TIER-CASES
     PERFORM ITEM-CASES
     STOP RUN.

 INIT-INPUTS.
     MOVE 1000 TO WS-SPEED
     MOVE 1 TO WS-CORRECT
     MOVE 0 TO WS-EFFICIENCY WS-HASTE WS-FATIGUE WS-WATER
     MOVE 1 TO WS-GROUND.

 RATE-AND-TICKS.
     CALL "BREAK-PROGRESS" USING WS-HARDNESS WS-SPEED WS-CORRECT WS-EFFICIENCY WS-HASTE
         WS-FATIGUE WS-WATER WS-GROUND WS-PPM
     CALL "BREAK-TICKS" USING WS-HARDNESS WS-SPEED WS-CORRECT WS-EFFICIENCY WS-HASTE
         WS-FATIGUE WS-WATER WS-GROUND WS-TICKS.

 CHECK.
     MOVE WS-PPM TO WS-EDIT
     MOVE WS-TICKS TO WS-EDIT2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> The CORE-18 / CORE-27 tables of the cobolcraft blocks (hardness x speed): the tick counts of the client model.
 TABLE-ROW-CASES.
     MOVE "test break progress CORE-27 by hand greystone 45, loam 15, turf 18, grit 15, cardstack 21, "
         & "ledger_tile 24, slag 13 (accumulation; the closed formula gives 12), lucite 9, glowtube 6, "
         & "goto_pad 39" TO TL-CASE
     PERFORM INIT-INPUTS
     MOVE SPACES TO WS-TEXT
     MOVE 1500 TO WS-HARDNESS
     PERFORM ADD-TICKS
     MOVE 500 TO WS-HARDNESS
     PERFORM ADD-TICKS
     MOVE 600 TO WS-HARDNESS
     PERFORM ADD-TICKS
     MOVE 500 TO WS-HARDNESS
     PERFORM ADD-TICKS
     MOVE 700 TO WS-HARDNESS
     PERFORM ADD-TICKS
     MOVE 800 TO WS-HARDNESS
     PERFORM ADD-TICKS
     MOVE 400 TO WS-HARDNESS
     PERFORM ADD-TICKS
     MOVE 300 TO WS-HARDNESS
     PERFORM ADD-TICKS
     MOVE 200 TO WS-HARDNESS
     PERFORM ADD-TICKS
     MOVE 1300 TO WS-HARDNESS
     PERFORM ADD-TICKS
     MOVE "45 15 18 15 21 24 13 9 6 39" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test break progress CORE-18 with the matching tool (speed 4.0): greystone 12, loam 4, turf 5, "
         & "grit 4, cardstack 6, ledger_tile 6, slag 3" TO TL-CASE
     MOVE 4000 TO WS-SPEED
     MOVE SPACES TO WS-TEXT
     MOVE 1500 TO WS-HARDNESS
     PERFORM ADD-TICKS
     MOVE 500 TO WS-HARDNESS
     PERFORM ADD-TICKS
     MOVE 600 TO WS-HARDNESS
     PERFORM ADD-TICKS
     MOVE 500 TO WS-HARDNESS
     PERFORM ADD-TICKS
     MOVE 700 TO WS-HARDNESS
     PERFORM ADD-TICKS
     MOVE 800 TO WS-HARDNESS
     PERFORM ADD-TICKS
     MOVE 400 TO WS-HARDNESS
     PERFORM ADD-TICKS
     MOVE "12 4 5 4 6 6 3" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ADD-TICKS.
     CALL "BREAK-TICKS" USING WS-HARDNESS WS-SPEED WS-CORRECT WS-EFFICIENCY WS-HASTE
         WS-FATIGUE WS-WATER WS-GROUND WS-TICKS
     MOVE WS-TICKS TO WS-EDIT
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE TL-OBSERVED TO WS-TEXT.

*> 13 §2.1 correct tool for drops and §2.6 tiers: wooden or golden (0), stone or copper (1), iron (2),
*> diamond and netherite (3); the blocks need none (0), stone (1), iron (2) or diamond (3).
 TIER-CASES.
     MOVE "test break progress 13§2.6 the tier rule: a block that requires no tool takes any tool; a "
         & "required block needs the right class and a tier that reaches the block's" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE 0 TO WS-REQUIRES
     MOVE 0 TO WS-CLASS-OK WS-TOOL-TIER WS-BLOCK-TIER
     PERFORM ADD-CORRECT
     MOVE 1 TO WS-REQUIRES
     PERFORM ADD-CORRECT
     MOVE 1 TO WS-CLASS-OK
     PERFORM ADD-CORRECT
     MOVE 1 TO WS-BLOCK-TIER
     PERFORM ADD-CORRECT
     MOVE 1 TO WS-TOOL-TIER
     PERFORM ADD-CORRECT
     MOVE 2 TO WS-BLOCK-TIER
     PERFORM ADD-CORRECT
     MOVE 2 TO WS-TOOL-TIER
     PERFORM ADD-CORRECT
     MOVE 3 TO WS-BLOCK-TIER
     PERFORM ADD-CORRECT
     MOVE 3 TO WS-TOOL-TIER
     PERFORM ADD-CORRECT
     MOVE "1 0 1 0 1 0 1 0 1" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ADD-CORRECT.
     CALL "BREAK-CORRECT" USING WS-REQUIRES WS-CLASS-OK WS-TOOL-TIER WS-BLOCK-TIER WS-RESULT
     MOVE WS-RESULT TO WS-EDIT
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE TL-OBSERVED TO WS-TEXT.

*> The item table reads the tool rule's speed (content: "tool #tag 4.0") and no tool rule leaves 0.
 ITEM-CASES.
     MOVE "test break progress the item table holds the tool speed 4.0 and the class of the pry_bar "
         & "and the trowel, and no speed for an item without a tool rule" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE "cobolcraft:pry_bar" TO WS-KEY
     PERFORM ADD-ITEM
     MOVE "cobolcraft:trowel" TO WS-KEY
     PERFORM ADD-ITEM
     MOVE "cobolcraft:greystone" TO WS-KEY
     PERFORM ADD-ITEM
     MOVE "1:4000:3 2:4000:3 0:0:0" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ADD-ITEM.
     MOVE 0 TO WS-I
     PERFORM VARYING WS-COUNT FROM 1 BY 1 UNTIL WS-COUNT > IT-COUNT OR WS-I > 0
         IF IT-KEY(WS-COUNT) = WS-KEY
             MOVE WS-COUNT TO WS-I
         END-IF
     END-PERFORM
     MOVE IT-TOOL-CLASS(WS-I) TO WS-EDIT
     MOVE IT-TOOL-SPEED(WS-I) TO WS-EDIT2
     MOVE IT-TOOL-TIER(WS-I) TO WS-EDIT3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-EDIT) ":" FUNCTION TRIM(WS-EDIT2) ":"
         FUNCTION TRIM(WS-EDIT3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE TL-OBSERVED TO WS-TEXT.
 END PROGRAM TEST-BREAK-PROGRESS.

 COPY CORETEST.
