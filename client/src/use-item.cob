*> The use of a bow, crossbow, trident or shield by the local player (12 section 6.6; 17 sections 3.6, 3.9 and 3.10): the client keeps the state of the use that the first-person hand
*> poses from (PL-USE-KIND, PL-USE-HAND, PL-USE-START, PL-USE-DURATION, PL-USE-SLOT; HAND-MESH reads it). USE-ITEM-CLASS names the use animation of an item by its key, USE-ITEM-AMMO
*> asks whether a projectile is available, USE-ITEM-INPUT begins and ends the use on the right button (Use Item 0x43 with the hand that uses; Player Action 6, release use item, when it
*> ends), and USE-ITEM-LOADED tells a crossbow with a charged projectile. Not driven: the block pose of an item that is not a shield (no vanilla item has it), brush, spear, spyglass,
*> horn and bundle (no pose of 12 section 6.6 for them).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. USE-ITEM-CLASS.
*> USING CLIENT-STATE, item id, class out (the HAND-ARM kind of the item's use: 2 bow, 3 crossbow, 4 trident, 8 shield, 0 any other item or an unknown one): by the item's key.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NS                  PIC X(16).
 01 WS-PATH                PIC X(40).
 01 WS-MAX                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TOOL                PIC X.
 01 WS-FOOD                BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ITEM                 BINARY-LONG.
 01 L-CLASS                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ITEM L-CLASS.
     MOVE 0 TO L-CLASS
     IF L-ITEM >= 0
         CALL "CL-ITEM-INFO" USING CLIENT-STATE L-ITEM WS-NS WS-PATH WS-MAX WS-BLOCK WS-TOOL WS-FOOD WS-KNOWN
         IF WS-KNOWN = 1 AND WS-NS = "minecraft"
             EVALUATE WS-PATH
                 WHEN "bow" MOVE 2 TO L-CLASS
                 WHEN "crossbow" MOVE 3 TO L-CLASS
                 WHEN "trident" MOVE 4 TO L-CLASS
                 WHEN "shield" MOVE 8 TO L-CLASS
                 WHEN OTHER CONTINUE
             END-EVALUATE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM USE-ITEM-CLASS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. USE-ITEM-AMMO.
*> USING CLIENT-STATE, class (2 bow, 3 crossbow), ammo out (1 when a projectile is available, 17 section 3.9: a creative player has infinite materials; else an item of the tag arrows,
*> arrow, tipped_arrow or spectral_arrow, in the off hand or any slot of the inventory; a crossbow also takes a firework_rocket).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-NS                  PIC X(16).
 01 WS-PATH                PIC X(40).
 01 WS-MAX                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TOOL                PIC X.
 01 WS-FOOD                BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CLASS                BINARY-LONG.
 01 L-AMMO                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CLASS L-AMMO.
     MOVE 0 TO L-AMMO
     IF PL-MODE = 1
         MOVE 1 TO L-AMMO
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 36 OR L-AMMO = 1
         MOVE -1 TO WS-ITEM
         IF WS-I < 36 AND PL-SLOT-COUNT(WS-I + 1) > 0
             MOVE PL-SLOT-ITEM(WS-I + 1) TO WS-ITEM
         END-IF
         IF WS-I = 36 AND PL-OFFHAND-COUNT > 0
             MOVE PL-OFFHAND-ITEM TO WS-ITEM
         END-IF
         IF WS-ITEM >= 0
             CALL "CL-ITEM-INFO" USING CLIENT-STATE WS-ITEM WS-NS WS-PATH WS-MAX WS-BLOCK WS-TOOL WS-FOOD WS-KNOWN
             IF WS-KNOWN = 1 AND WS-NS = "minecraft"
                 IF WS-PATH = "arrow" OR "tipped_arrow" OR "spectral_arrow"
                     MOVE 1 TO L-AMMO
                 END-IF
                 IF L-CLASS = 3 AND WS-PATH = "firework_rocket"
                     MOVE 1 TO L-AMMO
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM USE-ITEM-AMMO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. USE-ITEM-LOADED.
*> USING CLIENT-STATE, hand (0 main, 1 off), loaded out (1 when the stack in that hand is a crossbow with charged_projectiles that are not empty, 17 section 3.9).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ITEM                BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-HAND                 BINARY-LONG.
 01 L-LOADED               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-HAND L-LOADED.
     MOVE 0 TO L-LOADED
     IF L-HAND = 0 AND PL-SLOT-COUNT(PL-HELD + 1) > 0 AND PL-SLOT-CHARGED(PL-HELD + 1) = 1
         MOVE PL-SLOT-ITEM(PL-HELD + 1) TO WS-ITEM
         CALL "USE-ITEM-CLASS" USING CLIENT-STATE WS-ITEM WS-CLASS
         IF WS-CLASS = 3
             MOVE 1 TO L-LOADED
         END-IF
     END-IF
     IF L-HAND = 1 AND PL-OFFHAND-COUNT > 0 AND PL-OFFHAND-CHARGED = 1
         MOVE PL-OFFHAND-ITEM TO WS-ITEM
         CALL "USE-ITEM-CLASS" USING CLIENT-STATE WS-ITEM WS-CLASS
         IF WS-CLASS = 3
             MOVE 1 TO L-LOADED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM USE-ITEM-LOADED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. USE-ITEM-SEND.
*> USING CLIENT-STATE, hand (0 main, 1 off): Use Item (05c 0x43) with that hand, the next sequence number and the facing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-CONN                BINARY-LONG VALUE CONN-GAME.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-HAND                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-HAND.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     ADD 1 TO CT-SEQUENCE
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-USE-ITEM-HAND" USING PB-BUFFER L-HAND CT-SEQUENCE PL-YAW PL-PITCH
     CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
     GOBACK.
 END PROGRAM USE-ITEM-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. USE-ITEM-INPUT.
*> USING CLIENT-STATE: every frame in play. The right button pressed on the world screen with the main hand holding a bow (with a projectile), a crossbow that is not loaded (with a
*> projectile), a trident or a shield begins the use (Use Item with the main hand; the use state is kept); with the main hand holding none of them the off hand is tried the same way
*> (a shield in the off hand is raised by right-click, 17 section 3.6). A loaded crossbow in the main hand is fired by the same press: Use Item is sent, no use begins. The use ends,
*> with Player Action 6 (release use item), when the button is released, the held slot changes, the world screen is left or the player dies.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CCSHIM.
 01 WS-ITEM                BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-HAND                BINARY-LONG.
 01 WS-AMMO                BINARY-LONG.
 01 WS-LOADED              BINARY-LONG.
 01 WS-FOOD                BINARY-LONG.
 01 WS-IBLOCK              BINARY-LONG.
 01 WS-ITOOL               PIC X.
 01 WS-ACTION6             BINARY-LONG VALUE 6.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF PL-USE-KIND > 0
         IF IN-BUTTON-DOWN(CC-BUTTON-RIGHT + 1) = 0 OR PL-HELD NOT = PL-USE-SLOT OR SM-SCREEN NOT = SCR-WORLD OR PL-HEALTH <= 0
             MOVE 0 TO PL-USE-KIND
             CALL "CONTROLS-SEND-ITEM-ACTION" USING CLIENT-STATE WS-ACTION6
         END-IF
         GOBACK
     END-IF
     IF IN-BUTTON-PRESSED(CC-BUTTON-RIGHT + 1) = 0 OR SM-SCREEN NOT = SCR-WORLD OR PL-HEALTH <= 0 OR PL-EATING = 1 OR PL-MODE = 3
         GOBACK
     END-IF
*>   The main hand first; a hand with food or a block of its own has no such use, then the off hand is tried when the main hand holds nothing that uses.
     MOVE 0 TO WS-HAND
     MOVE 0 TO WS-CLASS
     IF PL-SLOT-COUNT(PL-HELD + 1) > 0
         MOVE PL-SLOT-ITEM(PL-HELD + 1) TO WS-ITEM
         CALL "USE-ITEM-CLASS" USING CLIENT-STATE WS-ITEM WS-CLASS
         CALL "CL-ITEM-FLAGS" USING CLIENT-STATE WS-ITEM WS-IBLOCK WS-ITOOL WS-FOOD
     ELSE
         MOVE 0 TO WS-FOOD
     END-IF
     IF WS-CLASS = 0 AND WS-FOOD = 0 AND PL-OFFHAND-COUNT > 0
         MOVE 1 TO WS-HAND
         MOVE PL-OFFHAND-ITEM TO WS-ITEM
         CALL "USE-ITEM-CLASS" USING CLIENT-STATE WS-ITEM WS-CLASS
     END-IF
     IF WS-CLASS = 0
         GOBACK
     END-IF
     MOVE 0 TO WS-LOADED
     CALL "USE-ITEM-LOADED" USING CLIENT-STATE WS-HAND WS-LOADED
     MOVE 1 TO WS-AMMO
     IF WS-CLASS = 2 OR WS-CLASS = 3
         CALL "USE-ITEM-AMMO" USING CLIENT-STATE WS-CLASS WS-AMMO
     END-IF
*>   A loaded crossbow is fired, with no use beginning; one without a projectile begins nothing.
     IF WS-LOADED = 1
         CALL "USE-ITEM-SEND" USING CLIENT-STATE WS-HAND
         GOBACK
     END-IF
     IF WS-AMMO = 0
         GOBACK
     END-IF
     CALL "USE-ITEM-SEND" USING CLIENT-STATE WS-HAND
     MOVE WS-CLASS TO PL-USE-KIND
     MOVE WS-HAND TO PL-USE-HAND
     MOVE CL-NOW-MS TO PL-USE-START
     MOVE PL-HELD TO PL-USE-SLOT
     MOVE 0 TO PL-USE-DURATION
     IF WS-CLASS = 3
         MOVE CL-CROSSBOW-MS TO PL-USE-DURATION
     END-IF
     GOBACK.
 END PROGRAM USE-ITEM-INPUT.
