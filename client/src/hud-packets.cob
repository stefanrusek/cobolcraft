*> The packets behind the status HUD (docs/protocol/49 section 1; 05b 0x87 Update Mob Effect, 0x4F Remove Mob Effect, 0x86 Update Attributes, 0x6D Set
*> Passengers, 0x65 Set Entity Data for the values it carries): they are read with proto's codecs and kept for the local player in CLIENT-STATE
*> (effects.cob, hearts.cob). HUD-NEW-PLAYER starts a new local player object (Login, Respawn; 39 section 8.4): the Set Health flash is armed again,
*> no damage cooldown and no blink, no vehicle. HUD-ENTITY-DATA keeps the air supply (slot 1) and ticks frozen (slot 7) of the local player and the health
*> (slot 9) of the vehicle; HUD-ATTRIBUTE keeps the armor (id 1) and max_health (id 23) attribute values of the local player and the max_health of the
*> vehicle (the mount hearts, min(30, (floor(max + 0.5)) div 2)).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HUD-NEW-PLAYER.
*> USING CLIENT-STATE.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO HB-FLASH-ARMED HB-COOLDOWN HB-BLINK HB-BLINK-TIME PL-MOUNT-HEARTS PL-MOUNT-HEALTH
     MOVE -1 TO PL-VEHICLE
     GOBACK.
 END PROGRAM HUD-NEW-PLAYER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAY-EFFECT-READ.
*> USING CLIENT-STATE, packet (Update Mob Effect): entity id, effect id, amplifier, duration, flags; for the local player the effect is set.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-EFFECT              BINARY-LONG.
 01 WS-AMP                 BINARY-LONG.
 01 WS-DUR                 BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 PROCEDURE DIVISION USING CLIENT-STATE PB-BUFFER.
     CALL "PB-GET-UPDATE-MOB-EFFECT" USING PB-BUFFER WS-ENTITY WS-EFFECT WS-AMP WS-DUR WS-FLAGS
     IF PB-ERROR = 0 AND WS-ENTITY = PL-ENTITY-ID
         CALL "EFFECT-SET" USING CLIENT-STATE WS-EFFECT WS-AMP WS-DUR WS-FLAGS
     END-IF
     GOBACK.
 END PROGRAM PLAY-EFFECT-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAY-REMOVE-EFFECT-READ.
*> USING CLIENT-STATE, packet (Remove Mob Effect): entity id and effect id; for the local player the effect is dropped.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-EFFECT              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 PROCEDURE DIVISION USING CLIENT-STATE PB-BUFFER.
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-ENTITY
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-EFFECT
     IF PB-ERROR = 0 AND WS-ENTITY = PL-ENTITY-ID
         CALL "EFFECT-REMOVE" USING CLIENT-STATE WS-EFFECT
     END-IF
     GOBACK.
 END PROGRAM PLAY-REMOVE-EFFECT-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HUD-ATTRIBUTE.
*> USING CLIENT-STATE, entity id, attribute id, value (FLOAT-LONG): the value of the local player's armor and max_health, and of the vehicle's max_health.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HEARTS              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ENTITY               BINARY-LONG.
 01 L-ATTRIBUTE            BINARY-LONG.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ENTITY L-ATTRIBUTE L-VALUE.
     EVALUATE TRUE
         WHEN L-ENTITY = PL-ENTITY-ID AND L-ATTRIBUTE = 1
             COMPUTE PL-ARMOR = FUNCTION INTEGER(L-VALUE)
         WHEN L-ENTITY = PL-ENTITY-ID AND L-ATTRIBUTE = 23
             MOVE L-VALUE TO PL-MAX-HEALTH
         WHEN L-ENTITY = PL-VEHICLE AND L-ATTRIBUTE = 23
             COMPUTE WS-HEARTS = FUNCTION INTEGER(L-VALUE + 0.5) / 2
             MOVE FUNCTION MIN(30, WS-HEARTS) TO PL-MOUNT-HEARTS
     END-EVALUATE
     GOBACK.
 END PROGRAM HUD-ATTRIBUTE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAY-ATTRIBUTES-READ.
*> USING CLIENT-STATE, packet (Update Attributes): per snapshot the base value plus its modifiers (operation 0 adds to the base, 1 adds base x amount,
*> 2 multiplies the result by 1 + amount, in that order), handed to HUD-ATTRIBUTE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PBATTR.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-BASE                FLOAT-LONG.
 01 WS-VALUE               FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 PROCEDURE DIVISION USING CLIENT-STATE PB-BUFFER.
     CALL "PB-GET-UPDATE-ATTRIBUTES" USING PB-BUFFER PB-ATTRIBUTES
     IF PB-ERROR = 1
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-AT-COUNT
         MOVE PB-AT-BASE(WS-I) TO WS-BASE
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > PB-AT-MOD-COUNT(WS-I)
             IF PB-AT-MOD-OPERATION(WS-I, WS-J) = 0
                 ADD PB-AT-MOD-AMOUNT(WS-I, WS-J) TO WS-BASE
             END-IF
         END-PERFORM
         MOVE WS-BASE TO WS-VALUE
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > PB-AT-MOD-COUNT(WS-I)
             IF PB-AT-MOD-OPERATION(WS-I, WS-J) = 1
                 COMPUTE WS-VALUE = WS-VALUE + WS-BASE * PB-AT-MOD-AMOUNT(WS-I, WS-J)
             END-IF
         END-PERFORM
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > PB-AT-MOD-COUNT(WS-I)
             IF PB-AT-MOD-OPERATION(WS-I, WS-J) = 2
                 COMPUTE WS-VALUE = WS-VALUE * (1 + PB-AT-MOD-AMOUNT(WS-I, WS-J))
             END-IF
         END-PERFORM
         CALL "HUD-ATTRIBUTE" USING CLIENT-STATE PB-AT-ENTITY PB-AT-ATTRIBUTE(WS-I) WS-VALUE
     END-PERFORM
     GOBACK.
 END PROGRAM PLAY-ATTRIBUTES-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAY-PASSENGERS-READ.
*> USING CLIENT-STATE, packet (Set Passengers): the vehicle's entity id and its passengers; the local player riding it makes it PL-VEHICLE, the local
*> player missing from the list of the vehicle he rode ends the ride (the mount row goes).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VEHICLE             BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-ME                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 PROCEDURE DIVISION USING CLIENT-STATE PB-BUFFER.
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-VEHICLE
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-COUNT
     MOVE 0 TO WS-ME
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1
         CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
         IF WS-ID = PL-ENTITY-ID
             MOVE 1 TO WS-ME
         END-IF
     END-PERFORM
     IF PB-ERROR = 0
         IF WS-ME = 1
             MOVE WS-VEHICLE TO PL-VEHICLE
         END-IF
         IF WS-ME = 0 AND PL-VEHICLE = WS-VEHICLE
             MOVE -1 TO PL-VEHICLE
             MOVE 0 TO PL-MOUNT-HEARTS PL-MOUNT-HEALTH
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PLAY-PASSENGERS-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HUD-ENTITY-DATA.
*> USING CLIENT-STATE, entity id, slot, serializer, integer value, float value: one Set Entity Data entry: slot 1 (an Int, the air supply) and slot 7
*> (an Int, ticks frozen) of the local player; slot 9 (a Float, health) of the vehicle ridden, kept as ceil(health) for the mount row.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-H                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ENTITY               BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-SERIALIZER           BINARY-LONG.
 01 L-INT                  BINARY-LONG.
 01 L-FLOAT                FLOAT-SHORT.
 PROCEDURE DIVISION USING CLIENT-STATE L-ENTITY L-SLOT L-SERIALIZER L-INT L-FLOAT.
     EVALUATE TRUE
         WHEN L-ENTITY = PL-ENTITY-ID AND L-SLOT = 1 AND L-SERIALIZER = 1
             MOVE L-INT TO PL-AIR
         WHEN L-ENTITY = PL-ENTITY-ID AND L-SLOT = 7 AND L-SERIALIZER = 1
             MOVE L-INT TO PL-TICKS-FROZEN
         WHEN L-ENTITY = PL-VEHICLE AND L-SLOT = 9 AND L-SERIALIZER = 3
             COMPUTE WS-H = FUNCTION INTEGER(L-FLOAT)
             IF L-FLOAT > WS-H
                 ADD 1 TO WS-H
             END-IF
             MOVE WS-H TO PL-MOUNT-HEALTH
     END-EVALUATE
     GOBACK.
 END PROGRAM HUD-ENTITY-DATA.
