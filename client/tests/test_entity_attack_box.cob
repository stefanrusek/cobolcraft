*> Implementation test (lane buggolem, T42900; 19 section 19, 21 section 2): which entity rows of a standard world the left button can attack. A living mob is attackable
*> whatever its category: the iron golem, the snow golem, the copper golem and the villager are MISC in the registry (21 section 2) but have health and are hit like any mob
*> (operator report of try15: an iron golem of a village could not be killed, the crosshair passed through it). Items, experience orbs and arrows stay unattackable; boats,
*> minecarts, armor stands and end crystals stay attackable; the box is width / 2 and height of the registry size text.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-ATTACK-BOX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY TESTLIB.
 01 WS-KEY                 PIC X(22).
 01 WS-SIZE                PIC X(15).
 01 WS-CATEGORY            PIC X(26).
 01 WS-CASE                PIC X(120).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE "iron_golem" TO WS-KEY
     MOVE "1.4 x 2.7" TO WS-SIZE
     MOVE "MISC" TO WS-CATEGORY
     MOVE "acceptance US15 19-19 an iron golem (MISC, 1.4 x 2.7) can be attacked" TO WS-CASE
     MOVE 1 TO WS-EXP
     PERFORM RUN-BOX
     MOVE "acceptance US15 19-19 the iron golem box is 0.7 half width and 2.7 high (in hundredths)" TO WS-CASE
     MOVE 7027 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(EN-BOX-HALF(WS-ROW) * 100 + 0.5) * 100 + FUNCTION INTEGER(EN-BOX-HEIGHT(WS-ROW) * 10 + 0.5)
     PERFORM CHK
     MOVE "snow_golem" TO WS-KEY
     MOVE "0.7 x 1.9" TO WS-SIZE
     MOVE "acceptance US15 19-20 a snow golem (MISC) can be attacked" TO WS-CASE
     MOVE 1 TO WS-EXP
     PERFORM RUN-BOX
     MOVE "copper_golem" TO WS-KEY
     MOVE "0.49 x 0.98" TO WS-SIZE
     MOVE "acceptance US15 19-21 a copper golem (MISC) can be attacked" TO WS-CASE
     PERFORM RUN-BOX
     MOVE "villager" TO WS-KEY
     MOVE "0.6 x 1.95" TO WS-SIZE
     MOVE "acceptance US15 19-22 a villager (MISC) can be attacked" TO WS-CASE
     PERFORM RUN-BOX
     MOVE "cow" TO WS-KEY
     MOVE "0.9 x 1.4" TO WS-SIZE
     MOVE "CREATURE" TO WS-CATEGORY
     MOVE "acceptance US15 21-2 a cow (CREATURE) can be attacked" TO WS-CASE
     PERFORM RUN-BOX
     MOVE "oak_boat" TO WS-KEY
     MOVE "1.375 x 0.5625" TO WS-SIZE
     MOVE "MISC" TO WS-CATEGORY
     MOVE "acceptance US15 21-2 a boat can be attacked" TO WS-CASE
     PERFORM RUN-BOX
     MOVE "armor_stand" TO WS-KEY
     MOVE "0.5 x 1.975" TO WS-SIZE
     MOVE "acceptance US15 21-2 an armor stand can be attacked" TO WS-CASE
     PERFORM RUN-BOX
     MOVE "item" TO WS-KEY
     MOVE "0.25 x 0.25" TO WS-SIZE
     MOVE "acceptance US15 21-2 a ground item cannot be attacked" TO WS-CASE
     MOVE 0 TO WS-EXP
     PERFORM RUN-BOX
     MOVE "experience_orb" TO WS-KEY
     MOVE "0.5 x 0.5" TO WS-SIZE
     MOVE "acceptance US15 21-2 an experience orb cannot be attacked" TO WS-CASE
     PERFORM RUN-BOX
     MOVE "arrow" TO WS-KEY
     MOVE "acceptance US15 21-2 an arrow cannot be attacked" TO WS-CASE
     PERFORM RUN-BOX
     STOP RUN.
 RUN-BOX.
     CALL "ENTITY-ATTACK-BOX" USING CLIENT-STATE WS-ROW WS-KEY WS-SIZE WS-CATEGORY
     MOVE EN-BOX-ATTACK(WS-ROW) TO WS-OBS
     PERFORM CHK.
 CHK.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED-N
     MOVE WS-OBS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTITY-ATTACK-BOX.
