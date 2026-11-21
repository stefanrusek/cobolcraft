*> Parrot (docs/protocol/19-mobs-land-friendly-and-neutral.md section 17; 18 section 8.2). A parrot is born with a variant 0 to 4 in EN-WOOL (metadata 20, MOB-BORN); seeds tame it
*> (nextInt(10) = 0, the player becomes the owner, Entity Event 7, else 6), the owner's hand toggles the sit order, a cookie kills it. Open items: the poison effect of 900 ticks
*> that a creative player's parrot gets, following the owner, landing on the owner's shoulder and its storage, imitating mobs (sounds), the jukebox party, flight, the tamed
*> parrot's hurt-by-owner rules.
*>   MOB-PARROT-USE USING player row, parrot row

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-PARROT-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-SALT                BINARY-LONG VALUE 44.
 01 WS-BOUND               BINARY-LONG VALUE 10.
 01 WS-DRAW                BINARY-LONG.
 01 WS-EVENT               BINARY-LONG.
 01 WS-OWNER               BINARY-LONG.
 01 WS-CONSUMED            BINARY-LONG VALUE 0.
 01 WS-NEW                 BINARY-LONG.
 01 WS-KEY48               PIC X(48).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ENTITY.
     MOVE SPACES TO WS-KEY48
     IF PL-SLOT-COUNT(L-ROW, PL-HELD(L-ROW) + 1) > 0
         CALL "TOOLUSE-KEY" USING PL-SLOT-ITEM(L-ROW, PL-HELD(L-ROW) + 1) WS-KEY48
     END-IF
     EVALUATE TRUE
         WHEN WS-KEY48 = "cookie"
             CALL "MOB-TAKE" USING L-ROW
             IF PL-MODE(L-ROW) NOT = 1
                 MOVE 0 TO EN-HEALTH(L-ENTITY)
                 CALL "STDMOB-DIE" USING L-ENTITY
             END-IF
         WHEN EN-TAMED(L-ENTITY) = 0 AND (WS-KEY48 = "wheat_seeds" OR "melon_seeds" OR "pumpkin_seeds"
                 OR "beetroot_seeds" OR "torchflower_seeds" OR "pitcher_pod")
             CALL "MOB-TAKE" USING L-ROW
             CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
             MOVE 6 TO WS-EVENT
             IF WS-DRAW = 0
                 MOVE 7 TO WS-EVENT
                 MOVE 1 TO EN-TAMED(L-ENTITY)
                 MOVE PL-UUID(L-ROW) TO EN-OWNER-UUID(L-ENTITY)
             END-IF
             CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
             CALL "ENTITY-EVENT-BUILD" USING EN-ID(L-ENTITY) WS-EVENT PB-BUFFER
             CALL "HEALTH-VIEWERS-SEND" USING L-ENTITY PB-BUFFER
             CALL "PB-FREE" USING PB-BUFFER
             IF WS-DRAW = 0
                 CALL "MOB-DATA-SEND" USING L-ENTITY
             END-IF
         WHEN EN-TAMED(L-ENTITY) = 1
             MOVE 0 TO WS-OWNER
             IF EN-OWNER-UUID(L-ENTITY) = PL-UUID(L-ROW)
                 MOVE 1 TO WS-OWNER
             END-IF
             CALL "M188-SIT-TOGGLE" USING EN-SIT(L-ENTITY) WS-CONSUMED WS-OWNER WS-NEW
             IF WS-NEW NOT = EN-SIT(L-ENTITY)
                 MOVE WS-NEW TO EN-SIT(L-ENTITY)
                 CALL "MOB-DATA-SEND" USING L-ENTITY
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM MOB-PARROT-USE.
