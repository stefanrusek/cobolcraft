*> The entity replica and the player list (data-model §3 "replica: client"; docs/protocol/05a 0x01,
*> 0x36, 0x37, 0x39, 0x46, 0x47, 0x55, 05b 0x4E, 0x80; 09 §3.2): ENTITY-PACKET applies one of
*> those packets. Add Entity takes a free row (or the row of the same id, replaced); Move Entity
*> applies its VecDelta to the last known position (each Short is 1/4096 block: new =
*> (round(base x 4096) + delta) / 4096; the stepped form applies each step in turn); Teleport
*> Entity sets the position and rotation (CobolCraft sends relative flags 0, absolute); Rotate
*> Head sets the head yaw; Remove Entities frees the rows. Packets about an entity the client does
*> not have are read and ignored. Player Info Update with the action set ADD_PLAYER only (the one
*> CobolCraft sends) keeps each profile's UUID and name (properties skipped); other action sets
*> are ignored. Player Info Remove forgets the profiles. ENTITY-FIND looks an id up, ENTITY-NAME
*> gives the player-list name of an entity's UUID, ENTITIES-CLEAR empties both, ENTITIES-FORGET
*> only the entities (Respawn: the player list stays).
*> Ground items (US5; standin-content §3, §9; 09 §3.3; 05b 0x65, 0x67, 0x7F): Add Entity keeps the
*> initial motion and starts with an empty stack; Set Entity Data keeps the stack of entry index 0
*> with serializer 7 (ITEM_STACK, the loose_item's only metadata) and skips the other entries it can
*> read (a serializer proto does not know ends the list); Set Entity Motion keeps the motion
*> (the server moves the item with Teleport Entity each tick it moves, so the client only stores
*> it); Take Item Entity takes the amount from the collected item's stack and frees the row once
*> nothing is left (a partial pickup leaves the item, standin §9.3).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITIES-CLEAR.
*> USING CLIENT-STATE.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     INITIALIZE EN-STATE
     GOBACK.
 END PROGRAM ENTITIES-CLEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITIES-FORGET.
*> USING CLIENT-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > EN-COUNT
         INITIALIZE EN-ENTITY(WS-R)
     END-PERFORM
     MOVE 0 TO EN-COUNT
     GOBACK.
 END PROGRAM ENTITIES-FORGET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-FIND.
*> USING CLIENT-STATE, entity id, row out (0 = not in the replica).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-ROW.
     MOVE 0 TO L-ROW
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > EN-COUNT OR L-ROW > 0
         IF EN-USED(WS-R) = 1 AND EN-ID(WS-R) = L-ID
             MOVE WS-R TO L-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-NAME.
*> USING CLIENT-STATE, row, name out (PIC X(16)), length out (0 = the UUID is not in the player
*> list).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-P                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-NAME                 PIC X(16).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-NAME L-LENGTH.
     MOVE 0 TO L-LENGTH
     MOVE SPACES TO L-NAME
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > PI-COUNT OR L-LENGTH > 0
         IF PI-USED(WS-P) = 1 AND PI-UUID(WS-P) = EN-UUID(L-ROW)
             MOVE PI-NAME(WS-P) TO L-NAME
             MOVE PI-NAME-LENGTH(WS-P) TO L-LENGTH
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-PACKET.
*> USING CLIENT-STATE, packet PB-BUFFER (PB-POS after the id), packet id (1, 54, 55, 57, 70, 71,
*> 78, 85, 101, 103, 127 or 128).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CONTENT.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ENTITY-VIEW REDEFINES WS-ENTITY-ROW.
    05 FILLER              PIC X(3).
    05 WS-ER-KEY           PIC X(22).
    05 FILLER              PIC X(41).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ROWS                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-PROPS               BINARY-LONG.
 01 WS-STEPS               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-SWELL               FLOAT-LONG.
 01 WS-ACTIONS             BINARY-LONG.
 01 WS-PRESENT             BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-DATA                BINARY-LONG.
 01 WS-UUID                PIC X(16).
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-PITCH               FLOAT-SHORT.
 01 WS-HEAD                FLOAT-SHORT.
 01 WS-D.
    05 WS-DELTA            BINARY-LONG OCCURS 3 TIMES.
 01 WS-POS.
    05 WS-P                FLOAT-LONG OCCURS 3 TIMES.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-CAP            BINARY-LONG VALUE 16.
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-TEXT                PIC X(32767).
 01 WS-TEXT-CAP            BINARY-LONG VALUE 32767.
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-MAX-NAME            BINARY-LONG VALUE 16.
 01 WS-MAX-TEXT            BINARY-LONG VALUE 32767.
 01 WS-COLLECTOR           BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MD-==.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 01 L-PACKET               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE PB-BUFFER L-PACKET.
     EVALUATE L-PACKET
         WHEN 1
*>           Add Entity.
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
             CALL "PB-GET-UUID" USING PB-BUFFER WS-UUID
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-TYPE
             CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-X
             CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-Y
             CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-Z
             CALL "PB-GET-LPVEC3" USING PB-BUFFER WS-VX WS-VY WS-VZ
             CALL "PB-GET-ANGLE" USING PB-BUFFER WS-PITCH
             CALL "PB-GET-ANGLE" USING PB-BUFFER WS-YAW
             CALL "PB-GET-ANGLE" USING PB-BUFFER WS-HEAD
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-DATA
             CALL "ENTITY-FIND" USING CLIENT-STATE WS-ID WS-ROW
             PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > EN-COUNT OR WS-ROW > 0
                 IF EN-USED(WS-R) = 0
                     MOVE WS-R TO WS-ROW
                 END-IF
             END-PERFORM
             IF WS-ROW = 0 AND EN-COUNT < CL-MAX-ENTITIES
                 ADD 1 TO EN-COUNT
                 MOVE EN-COUNT TO WS-ROW
             END-IF
             IF WS-ROW > 0
                 MOVE 1 TO EN-USED(WS-ROW)
                 MOVE 0 TO EN-ON-GROUND(WS-ROW)
                 MOVE WS-ID TO EN-ID(WS-ROW)
                 MOVE WS-TYPE TO EN-TYPE(WS-ROW)
                 MOVE WS-UUID TO EN-UUID(WS-ROW)
                 MOVE WS-X TO EN-X(WS-ROW)
                 MOVE WS-Y TO EN-Y(WS-ROW)
                 MOVE WS-Z TO EN-Z(WS-ROW)
                 MOVE WS-YAW TO EN-YAW(WS-ROW)
                 MOVE WS-PITCH TO EN-PITCH(WS-ROW)
                 MOVE WS-HEAD TO EN-HEAD-YAW(WS-ROW)
                 MOVE WS-VX TO EN-VX(WS-ROW)
                 MOVE WS-VY TO EN-VY(WS-ROW)
                 MOVE WS-VZ TO EN-VZ(WS-ROW)
                 MOVE 0 TO EN-STACK-COUNT(WS-ROW) EN-STACK-ITEM(WS-ROW)
*>               A world of the standard set: EN-TYPE is the entity_type registry id, so keep its key and the model row
*>               of CL-MODELS that draws it (0 = none); a cobolcraft world's EN-TYPE is a stand-in type.
                 MOVE 0 TO EN-VANILLA(WS-ROW) EN-MODEL(WS-ROW) EN-VALUE(WS-ROW) EN-SWELL-BASE(WS-ROW) EN-SWELL-MS(WS-ROW)
                 MOVE -1 TO EN-SWELL-DIR(WS-ROW)
                 MOVE SPACES TO EN-KEY(WS-ROW)
                 IF CT-OPEN = 1 AND CT-SET-TYPE NOT = CT-TYPE-COBOLCRAFT
                     MOVE 1 TO EN-VANILLA(WS-ROW)
                     CALL "ENTITY-ROW-AT" USING WS-TYPE WS-ENTITY-ROW WS-STATUS WS-ROWS
                     IF WS-STATUS = CT-OK
                         MOVE WS-ER-KEY TO EN-KEY(WS-ROW)
                         CALL "ENTITY-MODEL-FIND" USING EN-KEY(WS-ROW) EN-MODEL(WS-ROW)
                     END-IF
                 END-IF
             END-IF
         WHEN 101
*>           Set Entity Data: entries until the 0xFF terminator.
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
             CALL "ENTITY-FIND" USING CLIENT-STATE WS-ID WS-ROW
             MOVE 0 TO MD-MD-INDEX
             PERFORM UNTIL MD-MD-INDEX = PB-MD-END OR PB-ERROR = 1
                 CALL "PB-GET-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
                 IF PB-ERROR = 0 AND MD-MD-INDEX NOT = PB-MD-END
                     CALL "HUD-ENTITY-DATA" USING CLIENT-STATE WS-ID MD-MD-INDEX MD-MD-SERIALIZER MD-MD-INT
                         MD-MD-FLOAT
                 END-IF
                 IF WS-ROW > 0 AND MD-MD-INDEX = 0 AND MD-MD-SERIALIZER = PB-MDS-ITEM-STACK
                     MOVE MD-MD-IS-COUNT TO EN-STACK-COUNT(WS-ROW)
                     MOVE MD-MD-IS-ITEM TO EN-STACK-ITEM(WS-ROW)
                 END-IF
*>               The orb's value (entry 8) and the creeper's swell direction (entry 16), both INT: the swell counter is kept as it was when
*>               the direction changes (CREEPER-SWELL), then runs from there.
                 IF WS-ROW > 0 AND MD-MD-SERIALIZER = PB-MDS-INT
                     IF MD-MD-INDEX = 8 AND EN-KEY(WS-ROW) = "experience_orb"
                         MOVE MD-MD-INT TO EN-VALUE(WS-ROW)
                     END-IF
                     IF MD-MD-INDEX = 16 AND EN-KEY(WS-ROW) = "creeper"
                         CALL "CREEPER-SWELL" USING CLIENT-STATE WS-ROW WS-SWELL
                         COMPUTE EN-SWELL-BASE(WS-ROW) = WS-SWELL
                         MOVE CL-NOW-MS TO EN-SWELL-MS(WS-ROW)
                         MOVE MD-MD-INT TO EN-SWELL-DIR(WS-ROW)
                     END-IF
                 END-IF
             END-PERFORM
         WHEN 103
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
             CALL "PB-GET-LPVEC3" USING PB-BUFFER WS-VX WS-VY WS-VZ
             CALL "ENTITY-FIND" USING CLIENT-STATE WS-ID WS-ROW
             IF WS-ROW > 0
                 MOVE WS-VX TO EN-VX(WS-ROW)
                 MOVE WS-VY TO EN-VY(WS-ROW)
                 MOVE WS-VZ TO EN-VZ(WS-ROW)
             END-IF
         WHEN 127
*>           Take Item Entity: collected, collector, amount.
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-COLLECTOR
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-AMOUNT
             CALL "ENTITY-FIND" USING CLIENT-STATE WS-ID WS-ROW
             IF WS-ROW > 0
                 SUBTRACT WS-AMOUNT FROM EN-STACK-COUNT(WS-ROW)
             END-IF
             IF WS-ROW > 0 AND EN-STACK-COUNT(WS-ROW) <= 0
                 MOVE 0 TO EN-USED(WS-ROW)
             END-IF
         WHEN 54
         WHEN 55
*>           Move Entity Pos (Rot): properties (bit 0 on ground, the rest the step count), the
*>           delta in its linear (no steps) or stepped form, then for Pos Rot the angles.
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-PROPS
             CALL "ENTITY-FIND" USING CLIENT-STATE WS-ID WS-ROW
             DIVIDE WS-PROPS BY 2 GIVING WS-STEPS REMAINDER WS-FLAGS
             MOVE 0 TO WS-P(1) WS-P(2) WS-P(3)
             IF WS-ROW > 0
                 MOVE EN-X(WS-ROW) TO WS-P(1)
                 MOVE EN-Y(WS-ROW) TO WS-P(2)
                 MOVE EN-Z(WS-ROW) TO WS-P(3)
             END-IF
             COMPUTE WS-N = FUNCTION MAX(WS-STEPS, 1)
             PERFORM WS-N TIMES
                 IF WS-STEPS > 0
                     CALL "PB-GET-VARINT" USING PB-BUFFER WS-TICKS
                 END-IF
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
                     CALL "PB-GET-SHORT" USING PB-BUFFER WS-DELTA(WS-K)
                     COMPUTE WS-P(WS-K) = (FUNCTION INTEGER(WS-P(WS-K) * 4096 + 0.5)
                         + WS-DELTA(WS-K)) / 4096
                 END-PERFORM
             END-PERFORM
             IF L-PACKET = 55
                 CALL "PB-GET-ANGLE" USING PB-BUFFER WS-YAW
                 CALL "PB-GET-ANGLE" USING PB-BUFFER WS-PITCH
             END-IF
             IF WS-ROW > 0
                 MOVE WS-P(1) TO EN-X(WS-ROW)
                 MOVE WS-P(2) TO EN-Y(WS-ROW)
                 MOVE WS-P(3) TO EN-Z(WS-ROW)
                 MOVE WS-FLAGS TO EN-ON-GROUND(WS-ROW)
             END-IF
             IF WS-ROW > 0 AND L-PACKET = 55
                 MOVE WS-YAW TO EN-YAW(WS-ROW)
                 MOVE WS-PITCH TO EN-PITCH(WS-ROW)
             END-IF
         WHEN 57
*>           Move Entity Rot: the on-ground flag comes before the angles.
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
             CALL "PB-GET-BOOL" USING PB-BUFFER WS-FLAGS
             CALL "PB-GET-ANGLE" USING PB-BUFFER WS-YAW
             CALL "PB-GET-ANGLE" USING PB-BUFFER WS-PITCH
             CALL "ENTITY-FIND" USING CLIENT-STATE WS-ID WS-ROW
             IF WS-ROW > 0
                 MOVE WS-FLAGS TO EN-ON-GROUND(WS-ROW)
                 MOVE WS-YAW TO EN-YAW(WS-ROW)
                 MOVE WS-PITCH TO EN-PITCH(WS-ROW)
             END-IF
         WHEN 85
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
             CALL "PB-GET-ANGLE" USING PB-BUFFER WS-HEAD
             CALL "ENTITY-FIND" USING CLIENT-STATE WS-ID WS-ROW
             IF WS-ROW > 0
                 MOVE WS-HEAD TO EN-HEAD-YAW(WS-ROW)
             END-IF
         WHEN 128
*>           Teleport Entity: position, current motion, yaw, pitch, relative flags, on ground.
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
             CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-X
             CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-Y
             CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-Z
             PERFORM 3 TIMES
                 CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-V
             END-PERFORM
             CALL "PB-GET-FLOAT" USING PB-BUFFER WS-YAW
             CALL "PB-GET-FLOAT" USING PB-BUFFER WS-PITCH
             CALL "PB-GET-INT" USING PB-BUFFER WS-DATA
             CALL "PB-GET-BOOL" USING PB-BUFFER WS-FLAGS
             CALL "ENTITY-FIND" USING CLIENT-STATE WS-ID WS-ROW
             IF WS-ROW > 0
                 MOVE WS-X TO EN-X(WS-ROW)
                 MOVE WS-Y TO EN-Y(WS-ROW)
                 MOVE WS-Z TO EN-Z(WS-ROW)
                 MOVE WS-YAW TO EN-YAW(WS-ROW)
                 MOVE WS-PITCH TO EN-PITCH(WS-ROW)
                 MOVE WS-FLAGS TO EN-ON-GROUND(WS-ROW)
             END-IF
         WHEN 78
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-COUNT
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1
                 CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
                 CALL "ENTITY-FIND" USING CLIENT-STATE WS-ID WS-ROW
                 IF WS-ROW > 0
                     MOVE 0 TO EN-USED(WS-ROW)
                 END-IF
             END-PERFORM
         WHEN 71
*>           Player Info Update: FixedBitSet(8) actions, then the entries.
             CALL "PB-GET-UBYTE" USING PB-BUFFER WS-ACTIONS
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-COUNT
             IF WS-ACTIONS NOT = 1
                 MOVE 0 TO WS-COUNT
             END-IF
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1
                 CALL "PB-GET-UUID" USING PB-BUFFER WS-UUID
                 MOVE SPACES TO WS-NAME
                 CALL "PB-GET-STRING" USING PB-BUFFER WS-MAX-NAME WS-NAME WS-NAME-CAP
                     WS-NAME-LENGTH
                 CALL "PB-GET-VARINT" USING PB-BUFFER WS-N
                 PERFORM WS-N TIMES
                     CALL "PB-GET-STRING" USING PB-BUFFER WS-MAX-TEXT WS-TEXT WS-TEXT-CAP
                         WS-TEXT-LENGTH
                     CALL "PB-GET-STRING" USING PB-BUFFER WS-MAX-TEXT WS-TEXT WS-TEXT-CAP
                         WS-TEXT-LENGTH
                     CALL "PB-GET-BOOL" USING PB-BUFFER WS-PRESENT
                     IF WS-PRESENT = 1
                         CALL "PB-GET-STRING" USING PB-BUFFER WS-MAX-TEXT WS-TEXT WS-TEXT-CAP
                             WS-TEXT-LENGTH
                     END-IF
                 END-PERFORM
*>               The profile's row: the same UUID, else a free row.
                 MOVE 0 TO WS-ROW
                 PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > PI-COUNT OR WS-ROW > 0
                     IF PI-USED(WS-R) = 1 AND PI-UUID(WS-R) = WS-UUID
                         MOVE WS-R TO WS-ROW
                     END-IF
                 END-PERFORM
                 PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > PI-COUNT OR WS-ROW > 0
                     IF PI-USED(WS-R) = 0
                         MOVE WS-R TO WS-ROW
                     END-IF
                 END-PERFORM
                 IF WS-ROW = 0 AND PI-COUNT < CL-MAX-PLAYER-INFO
                     ADD 1 TO PI-COUNT
                     MOVE PI-COUNT TO WS-ROW
                 END-IF
                 IF WS-ROW > 0
                     MOVE 1 TO PI-USED(WS-ROW)
                     MOVE WS-UUID TO PI-UUID(WS-ROW)
                     MOVE WS-NAME TO PI-NAME(WS-ROW)
                     MOVE WS-NAME-LENGTH TO PI-NAME-LENGTH(WS-ROW)
                 END-IF
             END-PERFORM
         WHEN 70
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-COUNT
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1
                 CALL "PB-GET-UUID" USING PB-BUFFER WS-UUID
                 PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > PI-COUNT
                     IF PI-UUID(WS-R) = WS-UUID
                         MOVE 0 TO PI-USED(WS-R)
                     END-IF
                 END-PERFORM
             END-PERFORM
     END-EVALUATE
     GOBACK.
 END PROGRAM ENTITY-PACKET.
