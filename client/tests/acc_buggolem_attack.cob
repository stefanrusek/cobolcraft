*> Acceptance test (lane buggolem, T42900; operator report of try15: "iron golem can't be killed"): in a world of the standard set the iron golem is of the entity category MISC in
*> the registry (21 section 2: 1.4 x 2.7) but it is a mob, so the left button must attack it: with the look ray meeting its box 2.5 blocks ahead, one press sends Attack (05c 0x01)
*> with the golem's entity id (77 = 0x4d) (the client half of the chain; the unit cases of which entities are attackable are test_entity_attack_box). The core side (the golem takes the hits and dies)
*> is core/tests/test_stdmob_golem.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGGOLEM-ATTACK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-TEXT                PIC X(1024).
 01 WS-KEY                 PIC X(112).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROW-AREA            PIC X(66).
 01 WS-ROW-VIEW REDEFINES WS-ROW-AREA.
    05 FILLER              PIC X(3).
    05 WS-ER-KEY           PIC X(22).
    05 WS-ER-SIZE          PIC X(15).
    05 WS-ER-CATEGORY      PIC X(26).
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     MOVE "iron_golem" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 1 TO EN-COUNT
     MOVE 1 TO EN-USED(1) EN-VANILLA(1)
     MOVE 77 TO EN-ID(1)
     MOVE WS-TYPE TO EN-TYPE(1)
     MOVE WS-ER-KEY TO EN-KEY(1)
     MOVE 0.5 TO EN-X(1)
     MOVE 10.7 TO EN-Y(1)
     MOVE 2.5 TO EN-Z(1)
     CALL "ENTITY-ATTACK-BOX" USING CLIENT-STATE 1 WS-ER-KEY WS-ER-SIZE WS-ER-CATEGORY
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     CALL "TEST-LEFT" USING CLIENT-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "acceptance buggolem given an iron golem (MISC, 77) 2.5 blocks ahead when the left button is pressed then Attack 0x01 with entity id 77 is sent" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "014d" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-BUGGOLEM-ATTACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LEFT.
*> USING CLIENT-STATE: one CL-STEP with the left button going down, then one with it going up.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-EVENT.
    05 WS-KIND             BINARY-LONG.
    05 WS-A                BINARY-LONG.
    05 WS-B                BINARY-LONG.
    05 WS-C                BINARY-LONG.
    05 WS-X                FLOAT-SHORT.
    05 WS-Y                FLOAT-SHORT.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     INITIALIZE WS-EVENT
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND
     MOVE CC-BUTTON-LEFT TO WS-A
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENT WS-ONE
     MOVE CC-EV-BUTTON-UP TO WS-KIND
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENT WS-ONE
     GOBACK.
 END PROGRAM TEST-LEFT.
 COPY CLTEST.
