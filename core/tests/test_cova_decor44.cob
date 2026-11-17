*> Implementation test (coverage lane A; docs/protocol/44 part 9 section 4; core/src/decor-44.cob): the armour slot of boots, leggings and chestplates, the clicked slot on a small stand and the
*> off hand slot, an armor stand that cannot be spawned when the projectile table is full, a swap refused by a slot's remove and place locks, an interaction with a marker stand and an
*> empty-handed click on a stand without arms (it takes the main hand item).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVA-DECOR44.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG VALUE 0.
 01 WS-HITY                FLOAT-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 01 WS-KEYS.
    05 FILLER              PIC X(32) VALUE "minecraft:iron_boots".
    05 FILLER              PIC X(32) VALUE "minecraft:iron_leggings".
    05 FILLER              PIC X(32) VALUE "minecraft:iron_chestplate".
    05 FILLER              PIC X(32) VALUE "minecraft:iron_helmet".
 01 WS-KEY-T REDEFINES WS-KEYS.
    05 WS-KEY32            PIC X(32) OCCURS 4 TIMES.
 01 WS-WANT-SLOTS          PIC X(4) VALUE "1234".
 01 WS-DIGIT               PIC 9.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 0 TO WS-X
     MOVE 150 TO WS-Y
     MOVE 0 TO WS-Z
*>   The projectile table is full: no stand.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         MOVE 900000 TO PJ-ENT(WS-I)
         ADD WS-I TO PJ-ENT(WS-I)
     END-PERFORM
     CALL "ARMOR-STAND-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE "test cova decor44 an armor stand cannot be spawned while the projectile table is full" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-ROW TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         MOVE 0 TO PJ-ENT(WS-I)
     END-PERFORM
*>   The armour slot of each piece (1 boots, 2 leggings, 3 chestplate, 4 helmet).
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE SPACES TO WS-KEY
         MOVE WS-KEY32(WS-I) TO WS-KEY
         CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
         CALL "DECOR-ITEM-SLOT" USING WS-ITEM WS-SLOT
         MOVE WS-I TO WS-DIGIT
         MOVE SPACES TO WS-CASE
         STRING "test cova decor44 armour piece " WS-DIGIT " of the table goes to its slot" DELIMITED BY SIZE INTO WS-CASE
         EVALUATE WS-I
             WHEN 1
                 MOVE 1 TO WS-E
             WHEN 2
                 MOVE 2 TO WS-E
             WHEN 3
                 MOVE 3 TO WS-E
             WHEN OTHER
                 MOVE 4 TO WS-E
         END-EVALUATE
         MOVE WS-SLOT TO WS-O
         CALL "CA-N" USING WS-CASE WS-E WS-O
     END-PERFORM
*>   A stand: the slot hit on a small stand is found at twice the height, the off hand is the slot of an empty main hand.
     CALL "ARMOR-STAND-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-P
     MOVE 1 TO PJ-I1(WS-P)
     MOVE 1 TO PJ-EQ(WS-P, 2)
     MOVE 0.2 TO WS-HITY
     CALL "ARMOR-STAND-SLOT" USING WS-ROW WS-HITY WS-SLOT
     MOVE "test cova decor44 a hit at 0.2 on a small stand with boots is the feet slot (the height counts double)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-SLOT TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE 0 TO PJ-I1(WS-P)
     MOVE 0 TO PJ-EQ(WS-P, 2)
     MOVE 0 TO PJ-EQ(WS-P, 1)
     MOVE 1 TO PJ-EQ(WS-P, 6)
     MOVE 1.0 TO WS-HITY
     CALL "ARMOR-STAND-SLOT" USING WS-ROW WS-HITY WS-SLOT
     MOVE "test cova decor44 a hit on a stand with only an off hand item is the off hand slot 5" TO WS-CASE
     MOVE 5 TO WS-E
     MOVE WS-SLOT TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE 0 TO PJ-EQ(WS-P, 6)
*>   Swap locks: slot 1 with an item and its remove lock (bit 9), then an empty slot with its place lock (bit 17).
     MOVE 1 TO PJ-EQ(WS-P, 2)
     MOVE 512 TO PJ-I2(WS-P)
     MOVE 1 TO WS-SLOT
     CALL "ARMOR-STAND-SWAP" USING WS-ROW WS-SLOT WS-PLAYER WS-OK
     MOVE "test cova decor44 an item in a slot whose remove lock is set is not swapped" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-OK TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE 0 TO PJ-EQ(WS-P, 2)
     MOVE 131072 TO PJ-I2(WS-P)
     CALL "ARMOR-STAND-SWAP" USING WS-ROW WS-SLOT WS-PLAYER WS-OK
     MOVE "test cova decor44 an empty slot whose place lock is set takes nothing" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-OK TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE 0 TO PJ-I2(WS-P)
*>   A marker stand (flag 16) ignores the interaction, as does a spectator.
     MOVE 16 TO PJ-I1(WS-P)
     MOVE 1.0 TO WS-HITY
     CALL "ARMOR-STAND-INTERACT" USING WS-ROW WS-PLAYER WS-HITY WS-DONE
     MOVE "test cova decor44 a marker stand ignores the interaction" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-DONE TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   An empty-handed click on a stand without arms takes the main hand item.
     MOVE 0 TO PJ-I1(WS-P)
     MOVE 1 TO PJ-EQ(WS-P, 1)
     COMPUTE WS-HELD = PL-HELD(WS-PLAYER) + 1
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD)
     MOVE 0 TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD)
     MOVE 0.1 TO WS-HITY
     CALL "ARMOR-STAND-INTERACT" USING WS-ROW WS-PLAYER WS-HITY WS-DONE
     MOVE "test cova decor44 an empty hand on a stand without arms takes the main hand item" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-HELD) TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-COVA-DECOR44.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY COVATEST.
