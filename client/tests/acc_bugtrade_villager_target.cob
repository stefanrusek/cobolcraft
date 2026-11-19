*> Acceptance test (002-lane-bugtrade; operator report try15: "can't interact with villagers (farmer)", right click on a villager did nothing): in a world of the standard set
*> the villager, the iron golem, the snow golem, the copper golem and the mannequin are of the entity category MISC in the registry (21 section 3: villager, MISC, 0.6 x 1.95), but the
*> game still aims at them (they are living entities), so the right button sends Interact to a villager (opens the trades) and the left button attacks a golem. The client took the
*> category MISC for "a boat, a projectile, an item" and gave those mobs no hit box, so the look ray never met a villager and no Interact was sent (the core side, acc_bugtrade_village,
*> opens the trading window). Expected: a villager aimed at 2.5 blocks ahead is the entity target (TG-ENTITY-HIT 1, TG-ENTITY its id); the MISC things that are not hit (an arrow, a
*> dropped item, an area effect cloud) still are not; the right button on the villager sends Interact (05c 0x1A).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGTRADE-VILLAGER-TARGET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
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
 01 WS-NAMES.
    05 WS-NAME-DATA        PIC X(24) OCCURS 9 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-LIST.
    05 FILLER PIC X(24) VALUE "villager            1   ".
    05 FILLER PIC X(24) VALUE "iron_golem          1   ".
    05 FILLER PIC X(24) VALUE "snow_golem          1   ".
    05 FILLER PIC X(24) VALUE "copper_golem        1   ".
    05 FILLER PIC X(24) VALUE "mannequin           1   ".
    05 FILLER PIC X(24) VALUE "wandering_trader    1   ".
    05 FILLER PIC X(24) VALUE "arrow               0   ".
    05 FILLER PIC X(24) VALUE "item                0   ".
    05 FILLER PIC X(24) VALUE "area_effect_cloud   0   ".
 01 WS-LIST-VIEW REDEFINES WS-LIST.
    05 WS-L OCCURS 9 TIMES.
       10 WS-L-KEY         PIC X(20).
       10 WS-L-WANT        PIC 9.
       10 FILLER           PIC X(3).
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     MOVE "N" TO TL-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         MOVE SPACES TO WS-KEY
         MOVE WS-L-KEY(WS-I) TO WS-KEY
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
         CALL "RAYCAST" USING CLIENT-STATE
         MOVE TG-ENTITY-HIT TO WS-HIT
         MOVE SPACES TO TL-CASE
         STRING "acceptance bugtrade given a " FUNCTION TRIM(WS-L-KEY(WS-I)) " (category " FUNCTION TRIM(WS-ER-CATEGORY)
             ") 2.5 blocks ahead when the look ray is cast then target 1 or 0 as listed" DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-L-WANT(WS-I) TO TL-EXPECTED-N
         MOVE WS-HIT TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.
 END PROGRAM ACC-BUGTRADE-VILLAGER-TARGET.
 COPY CLTEST.
