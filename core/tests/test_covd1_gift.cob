*> Implementation test (coverage lane D1): VL-GIFT-TICK ignores an entity that is no villager (a trader entry, a removed villager) even with a hero near, and a baby villager
*> throws its gift (the baby table) after the cooldown like an adult.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVD1-GIFT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY VILSTATE.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ITEM-TYPE           BINARY-LONG.
 01 WS-VROW                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-VID                 BINARY-LONG.
 01 WS-HERO                BINARY-LONG VALUE 31.
 01 WS-AMP                 BINARY-LONG VALUE 0.
 01 WS-DUR                 BINARY-LONG VALUE 20000.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     CALL "TEST-STANDARD-TABLES"
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE "N" TO TL-MODE
     MOVE "villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "item" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ITEM-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-ROW) TO WS-X
     MOVE PL-Y(WS-ROW) TO WS-Y
     MOVE PL-Z(WS-ROW) TO WS-Z
     ADD 2 TO WS-X
     CALL "EFFECT-ADD" USING WS-ROW WS-HERO WS-AMP WS-DUR WS-FLAGS
*>   A wandering trader entry (kind 2) next to a hero does not start the gift cooldown.
     CALL "MOB-SPAWN" USING PL-DIM(WS-ROW) WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-VROW
     MOVE EN-ID(WS-VROW) TO WS-VID
     CALL "VL-SETUP" USING WS-VID WS-TWO WS-NO WS-SLOT
     PERFORM 5 TIMES
         CALL "VL-GIFT-TICK" USING WS-VROW
     END-PERFORM
     MOVE "covd1 gift: a trader entry never starts the gift cooldown" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE VL-GIFT-CD(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A removed villager has no slot and is ignored; the call must not create one.
     CALL "VL-REMOVE" USING WS-VID
     CALL "VL-GIFT-TICK" USING WS-VROW
     CALL "VL-FIND" USING WS-VID WS-NO WS-SLOT
     MOVE "covd1 gift: a removed villager stays without slot" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SLOT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A baby villager gives its gift after the cooldown (590 evaluations: none, then 40 more: one).
     CALL "MOB-SPAWN" USING PL-DIM(WS-ROW) WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-VROW
     MOVE -24000 TO EN-MOBAGE(WS-VROW)
     PERFORM COUNT-ITEMS
     MOVE WS-N TO WS-BEFORE
     PERFORM 590 TIMES
         CALL "VL-GIFT-TICK" USING WS-VROW
     END-PERFORM
     PERFORM COUNT-ITEMS
     MOVE "covd1 gift: a baby villager waits for the cooldown" TO TL-CASE
     MOVE WS-BEFORE TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM 40 TIMES
         CALL "VL-GIFT-TICK" USING WS-VROW
     END-PERFORM
     PERFORM COUNT-ITEMS
     MOVE "covd1 gift: a baby villager throws one gift" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-BEFORE + 1
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 COUNT-ITEMS.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-ITEM-TYPE
             ADD 1 TO WS-N
         END-IF
     END-PERFORM.
 END PROGRAM TEST-COVD1-GIFT.
 COPY CORETEST.
