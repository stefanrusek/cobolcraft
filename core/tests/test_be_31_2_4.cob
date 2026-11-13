*> Test of 31-2 section 4, Brewing stand (core/src/be-31-2.cob; T0873): the faces, the place and take rules, the saved keys, the recipe lookup and the server tick with its brew, cancel and bottle flags.
*> Each case runs its statements and shows the items joined by single spaces ("n" integers, "f" floats x 1e6, "t" text up to a stored length).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BE-31-2-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BESTATE.
 COPY PROTO.
 COPY COREAPI.
 COPY CITEMS.
 01 WS-SHOW                PIC -(10)9.
 01 WS-PTR                 BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-OUT                 PIC X(8192).
 01 WS-CAPACITY            BINARY-LONG VALUE 8192.
 01 WS-T10                 BINARY-LONG VALUE 10.
 01 WS-FORM                BINARY-LONG VALUE 1.
 01 WS-D                   BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(48).
 01 WS-NM                  PIC X(32).
 01 WS-NML                 BINARY-LONG.
 01 WS-SV                  PIC X(256).
 01 WS-SVL                 BINARY-LONG.
 01 WS-NV                  BINARY-LONG.
 01 WS-LV                  BINARY-DOUBLE.
 01 WS-FV                  FLOAT-SHORT.
 01 WS-IA.
    05 WS-IAV              BINARY-LONG OCCURS 8 TIMES.
 01 WS-LT                  BINARY-LONG.
 01 WS-LC                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-KP                  BINARY-LONG VALUE 0.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-A                 BINARY-LONG.
 01 WS-B                 BINARY-LONG.
 01 WS-C                 BINARY-LONG.
 01 WS-E                 BINARY-LONG.
 01 WS-F                 BINARY-LONG.
 01 WS-G                 BINARY-LONG.
 01 WS-H                 BINARY-LONG.
 01 WS-EV                BINARY-LONG.
 01 WS-O1                 BINARY-LONG.
 01 WS-O2                 BINARY-LONG.
 01 WS-O3                 BINARY-LONG.
 01 WS-O4                 BINARY-LONG.
 01 WS-FA                FLOAT-LONG.
 01 WS-FB                FLOAT-LONG.
 01 WS-FC                FLOAT-LONG.
 01 WS-LIST.
    05 WS-L               BINARY-LONG OCCURS 5 TIMES.
 01 WS-DATA.
    05 WS-D10             BINARY-LONG OCCURS 10 TIMES.
 COPY CTRECIPE.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "acceptance US12 31-2§4 Brewing stand: faces (4.1): up gives [3], down [0, 1, 2, 3], any side [0, 1, 2, 4] (count and first four shown); a take through a face is allowed except slot 3 holding something that is not a glass bottle" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 1 TO WS-A
     CALL "BE2-BREW-FACE" USING WS-A WS-LIST WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-L(1) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-L(2) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-L(3) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-L(4) TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-A
     CALL "BE2-BREW-FACE" USING WS-A WS-LIST WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-L(1) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-L(2) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-L(3) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-L(4) TO WS-SHOW
     PERFORM ADD-N
     MOVE 2 TO WS-A
     CALL "BE2-BREW-FACE" USING WS-A WS-LIST WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-L(1) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-L(2) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-L(3) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-L(4) TO WS-SHOW
     PERFORM ADD-N
     MOVE 3 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE2-BREW-TAKE" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 3 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE2-BREW-TAKE" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE2-BREW-TAKE" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 4 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE2-BREW-TAKE" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 2 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE2-BREW-TAKE" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 3 0 0 0 4 0 1 2 3 4 0 1 2 4 1 0 1 1 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-2§4 Brewing stand: canPlaceItem (4.1): slot 4 takes only a brewing_fuel stack; without a level nothing else goes in; slot 3 takes what the recipes accept as reagent; slots 0 to 2 take a potion input into an" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 4 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-E
     MOVE 0 TO WS-F
     MOVE 1 TO WS-G
     CALL "BE2-BREW-PLACE" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE 4 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-E
     MOVE 0 TO WS-F
     MOVE 1 TO WS-G
     CALL "BE2-BREW-PLACE" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE 4 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-E
     MOVE 0 TO WS-F
     MOVE 1 TO WS-G
     CALL "BE2-BREW-PLACE" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE 3 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-E
     MOVE 0 TO WS-F
     MOVE 1 TO WS-G
     CALL "BE2-BREW-PLACE" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE 3 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-E
     MOVE 0 TO WS-F
     MOVE 1 TO WS-G
     CALL "BE2-BREW-PLACE" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE 3 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 1 TO WS-E
     MOVE 0 TO WS-F
     MOVE 1 TO WS-G
     CALL "BE2-BREW-PLACE" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-E
     MOVE 1 TO WS-F
     MOVE 1 TO WS-G
     CALL "BE2-BREW-PLACE" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-E
     MOVE 1 TO WS-F
     MOVE 0 TO WS-G
     CALL "BE2-BREW-PLACE" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE 2 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-E
     MOVE 0 TO WS-F
     MOVE 1 TO WS-G
     CALL "BE2-BREW-PLACE" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-E
     MOVE 1 TO WS-F
     MOVE 1 TO WS-G
     CALL "BE2-BREW-PLACE" USING WS-A WS-B WS-C WS-E WS-F WS-G WS-H
     MOVE WS-H TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 0 1 1 0 0 1 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-2§4 Brewing stand: saved keys (4.2): BrewTime 0, total_brew_time 400, Fuel 0, total_fuel 20 and speed_multiplier 1.0 are the defaults and are written after Items (absent when empty)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:brewing_stand" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 12 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "{BrewTime:0,total_brew_time:400,Fuel:0,total_fuel:20,speed_multiplier:1.000}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-2§4 Brewing stand: load (4.2): the keys load and save back; with BrewTime above 0 the remembered ingredient becomes the item in slot 3 (it is not saved); the speed_multiplier float loads (2.0)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:brewing_stand" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 12 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "Items" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE 10 TO WS-LT
     MOVE 2 TO WS-LC
     PERFORM NB-L
     MOVE "Slot" TO WS-NM
     MOVE 4 TO WS-NML
     MOVE 3 TO WS-NV
     PERFORM NB-B
     MOVE 2 TO WS-ITEM
     MOVE 1 TO WS-NV
     PERFORM NB-STACK
     PERFORM NB-E
     MOVE "Slot" TO WS-NM
     MOVE 4 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-B
     MOVE 1 TO WS-ITEM
     MOVE 1 TO WS-NV
     PERFORM NB-STACK
     PERFORM NB-E
     MOVE "BrewTime" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 120 TO WS-NV
     PERFORM NB-I
     MOVE "total_brew_time" TO WS-NM
     MOVE 15 TO WS-NML
     MOVE 200 TO WS-NV
     PERFORM NB-I
     MOVE "Fuel" TO WS-NM
     MOVE 4 TO WS-NML
     MOVE 7 TO WS-NV
     PERFORM NB-I
     MOVE "total_fuel" TO WS-NM
     MOVE 10 TO WS-NML
     MOVE 20 TO WS-NV
     PERFORM NB-I
     MOVE "speed_multiplier" TO WS-NM
     MOVE 16 TO WS-NML
     COMPUTE WS-FV = 2.0
     PERFORM NB-FLOAT
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE BE-XI(WS-IDX, 6) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:brewing_stand" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 12 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "BrewTime" TO WS-NM
     MOVE 8 TO WS-NML
     MOVE 0 TO WS-NV
     PERFORM NB-I
     PERFORM LOAD-BUFFER
     MOVE BE-XI(WS-IDX, 6) TO WS-SHOW
     PERFORM ADD-N
     MOVE "{Items:[{Slot:0,id:cobolcraft:baseplate,count:1},{Slot:3,id:cobolcraft:greystone,count:1}],BrewTime:" &
         "120,total_brew_time:200,Fuel:7,total_fuel:20,speed_multiplier:2.000} 2 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-2§4 Brewing stand: recipes (4.4): the brewing recipe whose input item and reagent item match the bottle and the ingredient (baseplate + greystone gives loam, row 1); another input or another reagent matches" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 1 TO RC-COUNT
     MOVE 20 TO RR-SERIALIZER(1)
     MOVE SPACES TO RR-ING(1, 1)
     MOVE SPACES TO RR-ING(1, 2)
     MOVE "cobolcraft:baseplate" TO RR-ING(1, 1)
     MOVE "cobolcraft:greystone" TO RR-ING(1, 2)
     MOVE "cobolcraft:loam" TO RR-RESULT-ID(1)
     MOVE 1 TO RR-RESULT-COUNT(1)
     MOVE 1 TO WS-A
     MOVE 2 TO WS-B
     CALL "BE2-BREW-LOOKUP" USING WS-A WS-B WS-C WS-E
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 3 TO WS-A
     CALL "BE2-BREW-LOOKUP" USING WS-A WS-B WS-C WS-E
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 3 TO WS-B
     CALL "BE2-BREW-LOOKUP" USING WS-A WS-B WS-C WS-E
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 99999 TO WS-A
     MOVE 2 TO WS-B
     CALL "BE2-BREW-LOOKUP" USING WS-A WS-B WS-C WS-E
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 99999 TO WS-B
     CALL "BE2-BREW-LOOKUP" USING WS-A WS-B WS-C WS-E
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 3 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-2§4 Brewing stand: worked example 7 (4.5, 4.6): the first tick loads the fuel (20 uses, the stack of 1 is used up), starts the brew (Fuel 19, BrewTime and total_brew_time 400, the ingredient remembered); the" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:brewing_stand" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 12 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 1 TO RC-COUNT
     MOVE 20 TO RR-SERIALIZER(1)
     MOVE SPACES TO RR-ING(1, 1)
     MOVE SPACES TO RR-ING(1, 2)
     MOVE "cobolcraft:baseplate" TO RR-ING(1, 1)
     MOVE "cobolcraft:greystone" TO RR-ING(1, 2)
     MOVE "cobolcraft:loam" TO RR-RESULT-ID(1)
     MOVE 1 TO RR-RESULT-COUNT(1)
     MOVE 1 TO BE-SLOT-ITEM(WS-IDX, 1)
     MOVE 1 TO BE-SLOT-COUNT(WS-IDX, 1)
     MOVE 1 TO BE-SLOT-ITEM(WS-IDX, 2)
     MOVE 1 TO BE-SLOT-COUNT(WS-IDX, 2)
     MOVE 1 TO BE-SLOT-ITEM(WS-IDX, 3)
     MOVE 1 TO BE-SLOT-COUNT(WS-IDX, 3)
     MOVE 2 TO BE-SLOT-ITEM(WS-IDX, 4)
     MOVE 1 TO BE-SLOT-COUNT(WS-IDX, 4)
     MOVE 3 TO BE-SLOT-ITEM(WS-IDX, 5)
     MOVE 1 TO BE-SLOT-COUNT(WS-IDX, 5)
     MOVE 20 TO WS-A
     COMPUTE WS-FA = 1.0
     CALL "BE2-BREW-TICK" USING WS-IDX WS-A WS-FA WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 3) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 2) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 4) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SLOT-COUNT(WS-IDX, 5) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 6) TO WS-SHOW
     PERFORM ADD-N
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 399
     CALL "BE2-BREW-TICK" USING WS-IDX WS-O1 WS-FA WS-B WS-C
     END-PERFORM
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SLOT-ITEM(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     CALL "BE2-BREW-TICK" USING WS-IDX WS-O1 WS-FA WS-B WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SLOT-ITEM(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SLOT-ITEM(WS-IDX, 2) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SLOT-ITEM(WS-IDX, 3) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SLOT-COUNT(WS-IDX, 4) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 3) TO WS-SHOW
     PERFORM ADD-N
     MOVE "0 1 19 400 400 20 0 2 1 1 1 0 3 3 3 0 19" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-2§4 Brewing stand: speed (4.5 step 5, worked example 7): with speed_multiplier 2.0 the brew time is ceil(400 / 2.0) = 200" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:brewing_stand" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 12 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 1 TO RC-COUNT
     MOVE 20 TO RR-SERIALIZER(1)
     MOVE SPACES TO RR-ING(1, 1)
     MOVE SPACES TO RR-ING(1, 2)
     MOVE "cobolcraft:baseplate" TO RR-ING(1, 1)
     MOVE "cobolcraft:greystone" TO RR-ING(1, 2)
     MOVE "cobolcraft:loam" TO RR-RESULT-ID(1)
     MOVE 1 TO RR-RESULT-COUNT(1)
     MOVE 1 TO BE-SLOT-ITEM(WS-IDX, 1)
     MOVE 1 TO BE-SLOT-COUNT(WS-IDX, 1)
     MOVE 1 TO BE-SLOT-ITEM(WS-IDX, 2)
     MOVE 1 TO BE-SLOT-COUNT(WS-IDX, 2)
     MOVE 1 TO BE-SLOT-ITEM(WS-IDX, 3)
     MOVE 1 TO BE-SLOT-COUNT(WS-IDX, 3)
     MOVE 2 TO BE-SLOT-ITEM(WS-IDX, 4)
     MOVE 1 TO BE-SLOT-COUNT(WS-IDX, 4)
     MOVE 3 TO BE-SLOT-ITEM(WS-IDX, 5)
     MOVE 1 TO BE-SLOT-COUNT(WS-IDX, 5)
     MOVE 20 TO WS-A
     COMPUTE WS-FA = 2.0
     CALL "BE2-BREW-TICK" USING WS-IDX WS-A WS-FA WS-B WS-C
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 2) TO WS-SHOW
     PERFORM ADD-N
     MOVE "200 200" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-2§4 Brewing stand: cancel and no start (4.5 steps 2, 4, 5, V3): removing the reagent mid-brew or replacing it by another item sets BrewTime 0 on the next tick (the fuel already used stays used); without a" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:brewing_stand" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 12 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 1 TO RC-COUNT
     MOVE 20 TO RR-SERIALIZER(1)
     MOVE SPACES TO RR-ING(1, 1)
     MOVE SPACES TO RR-ING(1, 2)
     MOVE "cobolcraft:baseplate" TO RR-ING(1, 1)
     MOVE "cobolcraft:greystone" TO RR-ING(1, 2)
     MOVE "cobolcraft:loam" TO RR-RESULT-ID(1)
     MOVE 1 TO RR-RESULT-COUNT(1)
     MOVE 1 TO BE-SLOT-ITEM(WS-IDX, 1)
     MOVE 1 TO BE-SLOT-COUNT(WS-IDX, 1)
     MOVE 1 TO BE-SLOT-ITEM(WS-IDX, 2)
     MOVE 1 TO BE-SLOT-COUNT(WS-IDX, 2)
     MOVE 1 TO BE-SLOT-ITEM(WS-IDX, 3)
     MOVE 1 TO BE-SLOT-COUNT(WS-IDX, 3)
     MOVE 2 TO BE-SLOT-ITEM(WS-IDX, 4)
     MOVE 1 TO BE-SLOT-COUNT(WS-IDX, 4)
     MOVE 3 TO BE-SLOT-ITEM(WS-IDX, 5)
     MOVE 1 TO BE-SLOT-COUNT(WS-IDX, 5)
     MOVE 20 TO WS-A
     COMPUTE WS-FA = 1.0
     CALL "BE2-BREW-TICK" USING WS-IDX WS-A WS-FA WS-B WS-C
     MOVE 0 TO BE-SLOT-COUNT(WS-IDX, 4)
     MOVE 0 TO WS-A
     COMPUTE WS-FA = 1.0
     CALL "BE2-BREW-TICK" USING WS-IDX WS-A WS-FA WS-B WS-C
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 3) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:brewing_stand" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 12 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 1 TO RC-COUNT
     MOVE 20 TO RR-SERIALIZER(1)
     MOVE SPACES TO RR-ING(1, 1)
     MOVE SPACES TO RR-ING(1, 2)
     MOVE "cobolcraft:baseplate" TO RR-ING(1, 1)
     MOVE "cobolcraft:greystone" TO RR-ING(1, 2)
     MOVE "cobolcraft:loam" TO RR-RESULT-ID(1)
     MOVE 1 TO RR-RESULT-COUNT(1)
     MOVE 1 TO BE-SLOT-ITEM(WS-IDX, 1)
     MOVE 1 TO BE-SLOT-COUNT(WS-IDX, 1)
     MOVE 1 TO BE-SLOT-ITEM(WS-IDX, 2)
     MOVE 1 TO BE-SLOT-COUNT(WS-IDX, 2)
     MOVE 1 TO BE-SLOT-ITEM(WS-IDX, 3)
     MOVE 1 TO BE-SLOT-COUNT(WS-IDX, 3)
     MOVE 2 TO BE-SLOT-ITEM(WS-IDX, 4)
     MOVE 1 TO BE-SLOT-COUNT(WS-IDX, 4)
     MOVE 3 TO BE-SLOT-ITEM(WS-IDX, 5)
     MOVE 1 TO BE-SLOT-COUNT(WS-IDX, 5)
     MOVE 20 TO WS-A
     COMPUTE WS-FA = 1.0
     CALL "BE2-BREW-TICK" USING WS-IDX WS-A WS-FA WS-B WS-C
     MOVE 5 TO BE-SLOT-ITEM(WS-IDX, 4)
     MOVE 0 TO WS-A
     COMPUTE WS-FA = 1.0
     CALL "BE2-BREW-TICK" USING WS-IDX WS-A WS-FA WS-B WS-C
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:brewing_stand" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 12 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 1 TO RC-COUNT
     MOVE 20 TO RR-SERIALIZER(1)
     MOVE SPACES TO RR-ING(1, 1)
     MOVE SPACES TO RR-ING(1, 2)
     MOVE "cobolcraft:baseplate" TO RR-ING(1, 1)
     MOVE "cobolcraft:greystone" TO RR-ING(1, 2)
     MOVE "cobolcraft:loam" TO RR-RESULT-ID(1)
     MOVE 1 TO RR-RESULT-COUNT(1)
     MOVE 4 TO BE-SLOT-ITEM(WS-IDX, 1)
     MOVE 1 TO BE-SLOT-COUNT(WS-IDX, 1)
     MOVE 0 TO BE-SLOT-ITEM(WS-IDX, 2)
     MOVE 0 TO BE-SLOT-COUNT(WS-IDX, 2)
     MOVE 0 TO BE-SLOT-ITEM(WS-IDX, 3)
     MOVE 0 TO BE-SLOT-COUNT(WS-IDX, 3)
     MOVE 2 TO BE-SLOT-ITEM(WS-IDX, 4)
     MOVE 1 TO BE-SLOT-COUNT(WS-IDX, 4)
     MOVE 3 TO BE-SLOT-ITEM(WS-IDX, 5)
     MOVE 1 TO BE-SLOT-COUNT(WS-IDX, 5)
     MOVE 20 TO WS-A
     COMPUTE WS-FA = 1.0
     CALL "BE2-BREW-TICK" USING WS-IDX WS-A WS-FA WS-B WS-C
     MOVE BE-XI(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 3) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SLOT-COUNT(WS-IDX, 5) TO WS-SHOW
     PERFORM ADD-N
     MOVE "0 0 19 0 0 20 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-2§4 Brewing stand: bottle states (4.5 step 6): has_bottle_0..2 follow the three bottle slots and the block is written (flags 2) only when they differ from the last remembered flags (changed 1, then the flags)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:brewing_stand" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 12 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 1 TO RC-COUNT
     MOVE 20 TO RR-SERIALIZER(1)
     MOVE SPACES TO RR-ING(1, 1)
     MOVE SPACES TO RR-ING(1, 2)
     MOVE "cobolcraft:baseplate" TO RR-ING(1, 1)
     MOVE "cobolcraft:greystone" TO RR-ING(1, 2)
     MOVE "cobolcraft:loam" TO RR-RESULT-ID(1)
     MOVE 1 TO RR-RESULT-COUNT(1)
     MOVE 1 TO BE-SLOT-ITEM(WS-IDX, 1)
     MOVE 1 TO BE-SLOT-COUNT(WS-IDX, 1)
     MOVE 1 TO BE-SLOT-ITEM(WS-IDX, 2)
     MOVE 1 TO BE-SLOT-COUNT(WS-IDX, 2)
     MOVE 1 TO BE-SLOT-ITEM(WS-IDX, 3)
     MOVE 1 TO BE-SLOT-COUNT(WS-IDX, 3)
     MOVE 2 TO BE-SLOT-ITEM(WS-IDX, 4)
     MOVE 1 TO BE-SLOT-COUNT(WS-IDX, 4)
     MOVE 3 TO BE-SLOT-ITEM(WS-IDX, 5)
     MOVE 1 TO BE-SLOT-COUNT(WS-IDX, 5)
     MOVE 20 TO WS-A
     COMPUTE WS-FA = 1.0
     CALL "BE2-BREW-TICK" USING WS-IDX WS-A WS-FA WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 7) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 8) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 9) TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-A
     COMPUTE WS-FA = 1.0
     CALL "BE2-BREW-TICK" USING WS-IDX WS-A WS-FA WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 7) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 8) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 9) TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO BE-SLOT-COUNT(WS-IDX, 2)
     MOVE 0 TO WS-A
     COMPUTE WS-FA = 1.0
     CALL "BE2-BREW-TICK" USING WS-IDX WS-A WS-FA WS-B WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 7) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 8) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 9) TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 1 1 1 0 1 1 1 1 1 0 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     STOP RUN.

 BEGIN-CASE.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     .

 ADD-N.
     STRING FUNCTION TRIM(WS-SHOW) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     .

*> Saves entity WS-IDX in form WS-FORM, renders the compound and appends it to TL-OBSERVED.
 SAVE-RENDER.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "BE-SAVE" USING WS-IDX WS-FORM PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     MOVE 0 TO WS-LEN
     MOVE SPACES TO WS-OUT
     CALL "TEST-NBT-RENDER" USING PB-BUFFER WS-T10 WS-OUT WS-LEN
     CALL "PB-FREE" USING PB-BUFFER
     STRING WS-OUT(1:WS-LEN) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     .

*> The NBT builders of the cases (name WS-NM and length WS-NML, text WS-SV and length WS-SVL, number WS-NV, list type WS-LT and count WS-LC).
 NB-S.
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WS-NM WS-NML WS-SV WS-SVL
     .
 NB-I.
     CALL "NBT-WRITE-INT" USING PB-BUFFER WS-NM WS-NML WS-NV
     .
 NB-LONG.
     CALL "NBT-WRITE-LONG" USING PB-BUFFER WS-NM WS-NML WS-LV
     .
 NB-IA.
     CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WS-NM WS-NML WS-LC WS-IA
     .
 NB-FLOAT.
     CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WS-NM WS-NML WS-FV
     .
 NB-B.
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WS-NM WS-NML WS-NV
     .
 NB-C.
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WS-NM WS-NML
     .
 NB-E.
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     .
 NB-STACK.
     MOVE 0 TO WS-KP
     CALL "PNBT-STACK-WRITE" USING PB-BUFFER WS-ITEM WS-NV WS-KP
     .
 NB-L.
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WS-NM WS-NML WS-LT WS-LC
     .

*> Loads entity WS-IDX from the compound the case built in PB-BUFFER (the closing End tag is written here).
 LOAD-BUFFER.
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "BE-LOAD" USING WS-IDX PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     .
 END PROGRAM TEST-BE-31-2-4.

 COPY CORETEST.
