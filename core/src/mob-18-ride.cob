*> Saddles and riding of the horse family and the pig (docs/protocol/18-mob-framework.md sections 1.1.1, 8.4 and 3.1 to 3.5 of 19; 44-7 section 10.4.1).
*> The rider is a player row (EN-RIDER of the mob, EN-VEHICLE of the player's own entity); a saddled mob is controlled by its rider's client, which reports its position with
*> Move Vehicle, so the server does not simulate it (44-7 section 10.4). Open items: a pig is only steered with a carrot on a stick (its boost is not built), the collision test of
*> a reported position, mounting a baby, the horse's rearing and metadata flags, shift is the only dismount, a fence knot for a lead.
*>   MOB-RIDE-SEAT USING key, seat y out     the passenger seat y of a rideable species (0 when it is none), minus the player's vehicle attachment 0.6
*>   MOB-RIDE-SYNC, MOB-RIDE-SEND, MOB-RIDE-STOP, MOB-RIDE-START, MOB-SADDLE-USE, MOB-RIDE-USE, MOB-RIDE-TICK, MOB-RIDE-INPUT, MOB-RIDE-MOVE

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-RIDE-SEAT.
*> USING key (PIC X(24)), seat out (FLOAT-LONG): the seat of 18 section 1.1.1 (horse 1.44375, donkey 1.1125, mule 1.2125, pig 0.86875, camel 2.0 = height 2.375 less 0.375, 44-8 section 12.8) less the player's attachment 0.6; 0 for any other key.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SEATS.
    05 FILLER              PIC X(24) VALUE "horse".
    05 FILLER              FLOAT-LONG VALUE 1.44375.
    05 FILLER              PIC X(24) VALUE "donkey".
    05 FILLER              FLOAT-LONG VALUE 1.1125.
    05 FILLER              PIC X(24) VALUE "mule".
    05 FILLER              FLOAT-LONG VALUE 1.2125.
    05 FILLER              PIC X(24) VALUE "pig".
    05 FILLER              FLOAT-LONG VALUE 0.86875.
    05 FILLER              PIC X(24) VALUE "camel".
    05 FILLER              FLOAT-LONG VALUE 2.0.
*>  The strider has no passenger attachment in 18 section 1.1.1 (open): 0.
    05 FILLER              PIC X(24) VALUE "strider".
    05 FILLER              FLOAT-LONG VALUE 0.
 01 WS-TABLE REDEFINES WS-SEATS.
    05 WS-SEAT OCCURS 6 TIMES.
       10 WS-SEAT-KEY      PIC X(24).
       10 WS-SEAT-Y        FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(24).
 01 L-SEAT                 FLOAT-LONG.
 PROCEDURE DIVISION USING L-KEY L-SEAT.
     MOVE 0 TO L-SEAT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         IF WS-SEAT-KEY(WS-I) = L-KEY
             COMPUTE L-SEAT = WS-SEAT-Y(WS-I) - 0.6
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MOB-RIDE-SEAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-RIDE-SYNC.
*> USING mob row: each rider (EN-RIDER, and EN-RIDER2 of a camel) is put at the mob's seat and its entity moved for the other viewers. A camel's seat is (0, y, z) rotated by
*> -yaw (44-8 section 12.8): z 0.5 for the front seat, -0.7 for the rear seat when there are two riders.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(24).
 01 WS-SEAT                FLOAT-LONG.
 01 WS-RIDER               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-RADIANS             FLOAT-LONG.
 01 WS-GROUND              BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF EN-BT-KIND(L-ROW) > 0
         CALL "BOAT-SYNC" USING L-ROW
         GOBACK
     END-IF
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     CALL "MOB-RIDE-SEAT" USING WS-KEY WS-SEAT
     PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > 2
         MOVE EN-RIDER(L-ROW) TO WS-RIDER
         IF WS-SLOT = 2
             MOVE EN-RIDER2(L-ROW) TO WS-RIDER
         END-IF
         IF WS-RIDER > 0
             MOVE 0 TO WS-Z
             IF WS-KEY = "camel"
                 MOVE 0.5 TO WS-Z
                 IF WS-SLOT = 2
                     MOVE -0.7 TO WS-Z
                 END-IF
             END-IF
             COMPUTE WS-RADIANS = EN-YAW(L-ROW) * FUNCTION PI / 180
             COMPUTE PL-X(WS-RIDER) = EN-X(L-ROW) - WS-Z * FUNCTION SIN(WS-RADIANS)
             COMPUTE PL-Y(WS-RIDER) = EN-Y(L-ROW) + WS-SEAT
             COMPUTE PL-Z(WS-RIDER) = EN-Z(L-ROW) + WS-Z * FUNCTION COS(WS-RADIANS)
             CALL "ENTITY-MOVE" USING PL-ENTITY-ROW(WS-RIDER) PL-X(WS-RIDER) PL-Y(WS-RIDER) PL-Z(WS-RIDER)
                 PL-YAW(WS-RIDER) PL-PITCH(WS-RIDER) WS-GROUND
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MOB-RIDE-SYNC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-RIDE-SEND.
*> USING mob row: Set Passengers (0x6D) of the mob to its viewers: the entity ids of the riders (the first, then the second of a camel), or none.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-PACKET-ID           BINARY-LONG VALUE 109.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-COUNT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE 0 TO WS-COUNT
     IF EN-RIDER(L-ROW) > 0
         ADD 1 TO WS-COUNT
     END-IF
     IF EN-RIDER2(L-ROW) > 0
         ADD 1 TO WS-COUNT
     END-IF
     IF EN-PASS(L-ROW) > 0
         ADD 1 TO WS-COUNT
     END-IF
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER EN-ID(L-ROW)
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-COUNT
     IF EN-RIDER(L-ROW) > 0
         CALL "PB-PUT-VARINT" USING PB-BUFFER PL-ENTITY-ID(EN-RIDER(L-ROW))
     END-IF
     IF EN-RIDER2(L-ROW) > 0
         CALL "PB-PUT-VARINT" USING PB-BUFFER PL-ENTITY-ID(EN-RIDER2(L-ROW))
     END-IF
     IF EN-PASS(L-ROW) > 0
         CALL "PB-PUT-VARINT" USING PB-BUFFER EN-ID(EN-PASS(L-ROW))
     END-IF
     CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM MOB-RIDE-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-RIDE-STOP.
*> USING mob row (EN-RIDER > 0): the first rider dismounts, in place (a camel's second rider takes the front seat), and the viewers get Set Passengers.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-RIDER               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE EN-RIDER(L-ROW) TO WS-RIDER
     MOVE 0 TO EN-VEHICLE(PL-ENTITY-ROW(WS-RIDER))
     MOVE EN-RIDER2(L-ROW) TO EN-RIDER(L-ROW)
     MOVE 0 TO EN-RIDER2(L-ROW)
     CALL "MOB-RIDE-SEND" USING L-ROW
     GOBACK.
 END PROGRAM MOB-RIDE-STOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-RIDE-LEAVE2.
*> USING mob row (EN-RIDER2 > 0): the second rider of a camel dismounts, in place; the first stays and the viewers get Set Passengers.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE 0 TO EN-VEHICLE(PL-ENTITY-ROW(EN-RIDER2(L-ROW))) EN-RIDER2(L-ROW)
     CALL "MOB-RIDE-SEND" USING L-ROW
     GOBACK.
 END PROGRAM MOB-RIDE-LEAVE2.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-RIDE-START.
*> USING player row, mob row, started out: the player mounts a rideable mob (19 section 3.5 step 4; section 2.1): it is an adult with no rider, the player is not sneaking and rides
*> nothing, and a pig needs its saddle; a camel with one rider takes a second (19 section 3.8: fewer than 2 passengers). The rider is put on the seat and the viewers get Set Passengers.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(24).
 01 WS-TAKEN               BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-STARTED              BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ROW L-STARTED.
     MOVE 0 TO L-STARTED WS-TAKEN
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     IF PL-SNEAKING(L-PLAYER) = 0 AND EN-VEHICLE(PL-ENTITY-ROW(L-PLAYER)) = 0 AND EN-MOBAGE(L-ROW) >= 0
         EVALUATE TRUE
             WHEN EN-RIDER(L-ROW) = 0 AND (EN-SADDLE(L-ROW) = 1 OR (WS-KEY NOT = "pig" AND WS-KEY NOT = "strider"))
                 MOVE L-PLAYER TO EN-RIDER(L-ROW)
                 MOVE 1 TO WS-TAKEN
             WHEN EN-RIDER(L-ROW) > 0 AND EN-RIDER2(L-ROW) = 0 AND WS-KEY = "camel"
                 MOVE L-PLAYER TO EN-RIDER2(L-ROW)
                 MOVE 1 TO WS-TAKEN
         END-EVALUATE
     END-IF
     IF WS-TAKEN = 1
         MOVE L-ROW TO EN-VEHICLE(PL-ENTITY-ROW(L-PLAYER))
         CALL "MOB-RIDE-SYNC" USING L-ROW
         CALL "MOB-RIDE-SEND" USING L-ROW
         MOVE 1 TO L-STARTED
     END-IF
     GOBACK.
 END PROGRAM MOB-RIDE-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-SADDLE-USE.
*> USING player row, mob row, saddled out: a saddle in the main hand goes into the saddle slot of an adult that has none; a horse must be tame (19 section 3.1), a pig need not be.
*> The player's stack loses one and the viewers get Set Equipment (slot 7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY PROTO REPLACING LEADING ==PB-== BY ==EQ-==.
 COPY PROTO.
 01 WS-PACKET-ID           BINARY-LONG VALUE 104.
 01 WS-SLOT                BINARY-LONG VALUE 7.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-KEY                 PIC X(24).
 01 WS-ITEM-KEY            PIC X(112) VALUE "minecraft:saddle".
 01 WS-ITEM                BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-SADDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ROW L-SADDLED.
     MOVE 0 TO L-SADDLED
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     IF EN-SADDLE(L-ROW) = 0 AND EN-MOBAGE(L-ROW) >= 0 AND (EN-TAMED(L-ROW) = 1 OR WS-KEY = "pig" OR WS-KEY = "strider")
         CALL "MOB-TAKE" USING L-PLAYER
         MOVE 1 TO EN-SADDLE(L-ROW) L-SADDLED
         CALL "CONTENT-ITEM-BY-KEY" USING WS-ITEM-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
         CALL "PB-PUT-VARINT" USING PB-BUFFER EN-ID(L-ROW)
         CALL "PB-PUT-UBYTE" USING PB-BUFFER WS-SLOT
         INITIALIZE EQ-ITEMSTACK-X
         MOVE 1 TO EQ-ISX-COUNT
         MOVE WS-ITEM TO EQ-ISX-ITEM
         CALL "PB-PUT-ITEM-STACK" USING PB-BUFFER EQ-ITEMSTACK-X
         CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
         CALL "PB-FREE" USING PB-BUFFER
     END-IF
     GOBACK.
 END PROGRAM MOB-SADDLE-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-RIDE-USE.
*> USING player row, mob row, held key (PIC X(24)), handled out: the main hand on a rideable mob: a saddle is put on, an empty hand mounts. 0 for any other species or item.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(24).
 01 WS-SEAT                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-HELD                 PIC X(24).
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ROW L-HELD L-HANDLED.
     MOVE 0 TO L-HANDLED
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     CALL "MOB-RIDE-SEAT" USING WS-KEY WS-SEAT
     IF WS-SEAT NOT = 0
         EVALUATE TRUE
             WHEN L-HELD = "saddle"
                 CALL "MOB-SADDLE-USE" USING L-PLAYER L-ROW L-HANDLED
             WHEN L-HELD = SPACES
                 CALL "MOB-RIDE-START" USING L-PLAYER L-ROW L-HANDLED
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM MOB-RIDE-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-RIDE-TICK.
*> USING mob row (EN-RIDER > 0), done out: one tick of a ridden mob. The rider is put on the seat. An untamed horse, donkey or mule runs RunAroundLikeCrazy (19 section 3.4):
*> with chance 1 / 50 a tick, nextInt(100) below the temper tames it to its rider (Entity Event 7), else the temper rises by 5, the rider is thrown and Entity Event 6 is sent.
*> done is 1 for a saddled mob, which the rider's client controls (no AI, no physics).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-KEY                 PIC X(24).
 01 WS-COUNT               BINARY-LONG VALUE 3.
 01 WS-ARGS.
    05 WS-ARG              BINARY-DOUBLE OCCURS 16 TIMES.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-DRAW                BINARY-LONG.
 01 WS-TAMED               BINARY-LONG.
 01 WS-DELTA               BINARY-LONG VALUE 5.
 01 WS-EVENT               BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-HELD                BINARY-LONG.
 01 WS-HELD-KEY            PIC X(48).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-DONE.
     MOVE EN-SADDLE(L-ROW) TO L-DONE
     CALL "MOB-RIDE-SYNC" USING L-ROW
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
*>   A strider is controlled only by a rider that holds a warped fungus on a stick (44-6 section 8.1); otherwise it walks on its own with the rider on it.
     IF WS-KEY = "strider" AND L-DONE = 1
         MOVE 0 TO L-DONE
         COMPUTE WS-HELD = PL-HELD(EN-RIDER(L-ROW)) + 1
         IF PL-SLOT-COUNT(EN-RIDER(L-ROW), WS-HELD) > 0
             CALL "TOOLUSE-KEY" USING PL-SLOT-ITEM(EN-RIDER(L-ROW), WS-HELD) WS-HELD-KEY
             IF WS-HELD-KEY = "warped_fungus_on_a_stick"
                 MOVE 1 TO L-DONE
             END-IF
         END-IF
     END-IF
     IF EN-TAMED(L-ROW) = 0 AND WS-KEY NOT = "pig" AND WS-KEY NOT = "camel" AND WS-KEY NOT = "strider"
         MOVE EN-ID(L-ROW) TO WS-ARG(1)
         MOVE CW-TIME TO WS-ARG(2)
         MOVE 41 TO WS-ARG(3)
         CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
         IF FUNCTION MOD(WS-R, 50) = 0
             COMPUTE WS-DRAW = FUNCTION MOD(WS-R / 50, 100)
             CALL "M19-HORSE-TAME" USING EN-TEMPER(L-ROW) WS-DRAW WS-TAMED
             MOVE 6 TO WS-EVENT
             IF WS-TAMED = 1
                 MOVE 7 TO WS-EVENT
                 MOVE 1 TO EN-TAMED(L-ROW)
                 MOVE PL-UUID(EN-RIDER(L-ROW)) TO EN-OWNER-UUID(L-ROW)
             ELSE
                 CALL "M19-HORSE-TEMPER" USING EN-TEMPER(L-ROW) WS-DELTA
                 CALL "MOB-RIDE-STOP" USING L-ROW
             END-IF
             CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
             CALL "ENTITY-EVENT-BUILD" USING EN-ID(L-ROW) WS-EVENT PB-BUFFER
             CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
             CALL "PB-FREE" USING PB-BUFFER
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MOB-RIDE-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-RIDE-INPUT.
*> USING connection id, PLAY-SERVERBOUND (a decoded Player Input 0x2B): the shift key (0x20) ends the ride of a player on a mob (the key bits are PSB-FLAGS).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-VEHICLE             BINARY-LONG.
 01 WS-SHIFT               BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND.
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     MOVE EN-VEHICLE(PL-ENTITY-ROW(WS-ROW)) TO WS-VEHICLE
     COMPUTE WS-SHIFT = PSB-FLAGS / 32
     IF WS-VEHICLE > 0 AND FUNCTION MOD(WS-SHIFT, 2) = 1
         IF EN-RIDER2(WS-VEHICLE) = WS-ROW
             CALL "MOB-RIDE-LEAVE2" USING WS-VEHICLE
         ELSE
             CALL "MOB-RIDE-STOP" USING WS-VEHICLE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MOB-RIDE-INPUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-RIDE-MOVE.
*> USING connection id, PLAY-SERVERBOUND (a decoded Move Vehicle 0x22: PSB-X to PSB-PITCH, PSB-FLAGS): the position report of the rider's client (44-7 section 10.4.1). Nothing for a
*> player who rides nothing. A mob that the player does not control (no saddle) or a report with moved2 - v2 > 100 (squared distance from the mob's position less its squared velocity)
*> is not applied and the player gets a Move Vehicle with the mob's own position. Otherwise the mob is moved to the report and the rider follows.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-PACKET-ID           BINARY-LONG VALUE 58.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-ROW                 BINARY-LONG.
 01 WS-VEHICLE             BINARY-LONG.
 01 WS-MOVED2              FLOAT-LONG.
 01 WS-V2                  FLOAT-LONG.
 01 WS-GROUND              BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND.
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     MOVE EN-VEHICLE(PL-ENTITY-ROW(WS-ROW)) TO WS-VEHICLE
     IF WS-VEHICLE = 0
         GOBACK
     END-IF
     COMPUTE WS-MOVED2 = (PSB-X - EN-X(WS-VEHICLE)) ** 2 + (PSB-Y - EN-Y(WS-VEHICLE)) ** 2 + (PSB-Z - EN-Z(WS-VEHICLE)) ** 2
     COMPUTE WS-V2 = EN-VX(WS-VEHICLE) ** 2 + EN-VY(WS-VEHICLE) ** 2 + EN-VZ(WS-VEHICLE) ** 2
     IF EN-SADDLE(WS-VEHICLE) = 0 OR WS-MOVED2 - WS-V2 > 100
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
         CALL "PB-PUT-DOUBLE" USING PB-BUFFER EN-X(WS-VEHICLE)
         CALL "PB-PUT-DOUBLE" USING PB-BUFFER EN-Y(WS-VEHICLE)
         CALL "PB-PUT-DOUBLE" USING PB-BUFFER EN-Z(WS-VEHICLE)
         CALL "PB-PUT-FLOAT" USING PB-BUFFER EN-YAW(WS-VEHICLE)
         CALL "PB-PUT-FLOAT" USING PB-BUFFER EN-PITCH(WS-VEHICLE)
         CALL "CORE-SEND" USING L-ID PB-BUFFER
         CALL "PB-FREE" USING PB-BUFFER
         GOBACK
     END-IF
     MOVE FUNCTION MOD(PSB-FLAGS, 2) TO WS-GROUND
     CALL "ENTITY-MOVE" USING WS-VEHICLE PSB-X PSB-Y PSB-Z PSB-YAW PSB-PITCH WS-GROUND
     MOVE PSB-YAW TO PL-YAW(WS-ROW)
     CALL "MOB-RIDE-SYNC" USING WS-VEHICLE
     CALL "CHUNKS-FOLLOW" USING L-ID
     GOBACK.
 END PROGRAM MOB-RIDE-MOVE.
