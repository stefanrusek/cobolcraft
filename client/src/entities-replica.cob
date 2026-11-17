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
 PROGRAM-ID. ENTITY-ATTACK-BOX.
*> USING CLIENT-STATE, entity row, registry key (PIC X(22)), size text ("0.6 x 1.95", PIC X(15)), category (PIC X(26)): the attack box of a
*> standard entity row (21 section 2: width x height; the box is centred on the entity's x and z, from its y up). The left button attacks a
*> living entity (category other than MISC), a player, and the MISC entities that can be hit: boats, minecarts, armor stands, end crystals.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-WIDTH               PIC X(15).
 01 WS-HEIGHT              PIC X(15).
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-KEY                  PIC X(22).
 01 L-SIZE                 PIC X(15).
 01 L-CATEGORY             PIC X(26).
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-KEY L-SIZE L-CATEGORY.
     MOVE SPACES TO WS-WIDTH WS-HEIGHT
     UNSTRING L-SIZE DELIMITED BY " x " INTO WS-WIDTH WS-HEIGHT
     COMPUTE EN-BOX-HALF(L-ROW) = FUNCTION NUMVAL(WS-WIDTH) / 2
     COMPUTE EN-BOX-HEIGHT(L-ROW) = FUNCTION NUMVAL(WS-HEIGHT)
     MOVE 0 TO WS-N
     INSPECT L-KEY TALLYING WS-N FOR ALL "boat" ALL "raft" ALL "minecart" ALL "armor_stand" ALL "end_crystal"
     MOVE 0 TO EN-BOX-ATTACK(L-ROW)
     IF L-CATEGORY NOT = "MISC" OR L-KEY = "player" OR WS-N > 0
         MOVE 1 TO EN-BOX-ATTACK(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM ENTITY-ATTACK-BOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-PACKET.
*> USING CLIENT-STATE, packet PB-BUFFER (PB-POS after the id), packet id (1, 54, 55, 57, 70, 71,
*> 78, 85, 101, 103, 104, 123, 127 or 128). 104 is Set Equipment (EN-EQ). 123 is Swing Animation (54 section 2.1); the walk animation is ticked by ENTITIES-ANIM-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CONTENT.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ENTITY-VIEW REDEFINES WS-ENTITY-ROW.
    05 FILLER              PIC X(3).
    05 WS-ER-KEY           PIC X(22).
    05 WS-ER-SIZE          PIC X(15).
    05 WS-ER-CATEGORY      PIC X(26).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ROWS                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-BABY-INDEX          BINARY-LONG.
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
 01 WS-HAND                BINARY-LONG.
 01 WS-SWTYPE              BINARY-LONG.
 01 WS-DUR                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
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
                 MOVE 0 TO EN-BOX-ATTACK(WS-ROW)
                 MOVE 0 TO EN-VANILLA(WS-ROW) EN-MODEL(WS-ROW) EN-VALUE(WS-ROW) EN-SWELL-BASE(WS-ROW) EN-SWELL-MS(WS-ROW)
                 MOVE 0 TO EN-FLAGS(WS-ROW) EN-POSE(WS-ROW)
*>               The walk animation and the swing start at rest (54 section 1.1); the position of the previous tick is this one.
                 MOVE 0 TO EN-WALK-SPEED-OLD(WS-ROW) EN-WALK-SPEED(WS-ROW) EN-WALK-POS(WS-ROW)
                 MOVE 1 TO EN-WALK-SCALE(WS-ROW)
                 MOVE WS-X TO EN-OX(WS-ROW)
                 MOVE WS-Y TO EN-OY(WS-ROW)
                 MOVE WS-Z TO EN-OZ(WS-ROW)
                 MOVE 0 TO EN-MOB-FLAGS(WS-ROW) EN-BABY(WS-ROW)
                 MOVE 0 TO EN-SW-ACTIVE(WS-ROW) EN-SW-TICKS(WS-ROW) EN-SW-DUR(WS-ROW) EN-SW-HAND(WS-ROW) EN-SW-TYPE(WS-ROW)
                 MOVE 0 TO EN-SW-ANIM(WS-ROW) EN-AGE(WS-ROW)
                 MOVE 0 TO EN-SQ(WS-ROW) EN-SQ-OLD(WS-ROW) EN-SQ-TGT(WS-ROW) EN-WOG(WS-ROW)
                 MOVE 0 TO EN-DRY(WS-ROW) EN-TM(WS-ROW) EN-TA(WS-ROW) EN-RS(WS-ROW) EN-XR(WS-ROW) EN-ZR(WS-ROW)
*>               The squid's tentacle speed, 0.1 to 0.2 (21 section 4.5 draws it at random; the client keeps a value from the entity id).
                 COMPUTE EN-TS(WS-ROW) = 0.1 + FUNCTION MOD(WS-ID * 37, 100) / 1000
                 MOVE 0 TO EN-FA(WS-ROW)
                 MOVE 0 TO EN-TGT(WS-ROW)
                 MOVE 0 TO EN-BHT(WS-ROW) EN-BHD(WS-ROW) EN-BDM(WS-ROW) EN-BBT(WS-ROW) EN-BBM(WS-ROW) EN-BBA(WS-ROW) EN-BUW(WS-ROW)
                 MOVE 22 TO EN-FL(WS-ROW)
                 MOVE -1 TO EN-VAR(WS-ROW) EN-VAR2(WS-ROW) EN-VAR3(WS-ROW)
                 MOVE 0 TO EN-X1(WS-ROW) EN-OVL(WS-ROW) EN-OVN(WS-ROW)
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
                     MOVE 0 TO EN-EQ(WS-ROW, WS-I)
                     MOVE -1 TO EN-EQ-DYE(WS-ROW, WS-I)
                     MOVE 0 TO EN-EQ-TRIM-MAT(WS-ROW, WS-I) EN-EQ-TRIM-PAT(WS-ROW, WS-I) EN-EQ-FOIL(WS-ROW, WS-I)
                 END-PERFORM
                 MOVE -1 TO EN-HB-BASE(WS-ROW, 1) EN-HB-BASE(WS-ROW, 2)
                 MOVE 0 TO EN-HB-COUNT(WS-ROW, 1) EN-HB-COUNT(WS-ROW, 2)
                 MOVE 0 TO EN-HAND-OK(WS-ROW, 1) EN-HAND-OK(WS-ROW, 2)
                 MOVE 14 TO EN-X2(WS-ROW)
                 MOVE -1 TO EN-X3(WS-ROW)
                 MOVE -1 TO EN-SWELL-DIR(WS-ROW)
                 MOVE SPACES TO EN-KEY(WS-ROW)
                 IF CT-OPEN = 1 AND CT-SET-TYPE NOT = CT-TYPE-COBOLCRAFT
                     MOVE 1 TO EN-VANILLA(WS-ROW)
                     CALL "ENTITY-ROW-AT" USING WS-TYPE WS-ENTITY-ROW WS-STATUS WS-ROWS
                     IF WS-STATUS = CT-OK
                         MOVE WS-ER-KEY TO EN-KEY(WS-ROW)
                         CALL "ENTITY-MODEL-FIND" USING EN-KEY(WS-ROW) EN-MODEL(WS-ROW)
                         CALL "ENTITY-ATTACK-BOX" USING CLIENT-STATE WS-ROW WS-ER-KEY WS-ER-SIZE WS-ER-CATEGORY
                     END-IF
                 END-IF
             END-IF
         WHEN 101
*>           Set Entity Data: entries until the 0xFF terminator.
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
             CALL "ENTITY-FIND" USING CLIENT-STATE WS-ID WS-ROW
             MOVE 0 TO MD-MD-INDEX
             PERFORM UNTIL MD-MD-INDEX = PB-MD-END OR PB-ERROR = 1
                 CALL "PB-GET-METADATA-ENTRY-X" USING PB-BUFFER MD-METADATA-ENTRY-X
                 MOVE MD-MX-INDEX TO MD-MD-INDEX
                 MOVE MD-MX-SERIALIZER TO MD-MD-SERIALIZER
                 MOVE MD-MX-INT TO MD-MD-INT
                 MOVE MD-MX-FLOAT(1) TO MD-MD-FLOAT
                 MOVE MD-MX-IS-COUNT TO MD-MD-IS-COUNT
                 MOVE MD-MX-IS-ITEM TO MD-MD-IS-ITEM
                 IF PB-ERROR = 0 AND MD-MD-INDEX NOT = PB-MD-END AND WS-ROW > 0
                     CALL "ENTITY-VARIANT-SET" USING CLIENT-STATE WS-ROW MD-MD-INDEX MD-MD-SERIALIZER MD-MD-INT
                         MD-MX-INT-2 MD-MX-INT-3 MD-MX-LONG
                 END-IF
                 IF PB-ERROR = 0 AND MD-MD-INDEX NOT = PB-MD-END AND WS-ROW > 0
                     CALL "ENTITY-BOAT-SET" USING CLIENT-STATE WS-ROW MD-MD-INDEX MD-MD-SERIALIZER MD-MD-INT MD-MD-FLOAT
                 END-IF
                 IF PB-ERROR = 0 AND MD-MD-INDEX NOT = PB-MD-END
                     CALL "HUD-ENTITY-DATA" USING CLIENT-STATE WS-ID MD-MD-INDEX MD-MD-SERIALIZER MD-MD-INT
                         MD-MD-FLOAT
                 END-IF
*>               The item stack of a stand-in loose item is entry 0; the item entity of a standard world has it as entry 8 (21 App A DATA_ITEM).
                 IF WS-ROW > 0 AND MD-MD-SERIALIZER = PB-MDS-ITEM-STACK
                         AND (MD-MD-INDEX = 0 OR (MD-MD-INDEX = 8 AND EN-VANILLA(WS-ROW) = 1 AND EN-KEY(WS-ROW) = "item"))
                     MOVE MD-MD-IS-COUNT TO EN-STACK-COUNT(WS-ROW)
                     MOVE MD-MD-IS-ITEM TO EN-STACK-ITEM(WS-ROW)
                 END-IF
*>               The orb's value (entry 8) and the creeper's swell direction (entry 16), both INT: the swell counter is kept as it was when
*>               the direction changes (CREEPER-SWELL), then runs from there.
*>               The shared flags byte (entry 0) and the pose (entry 6) of a player (53 section 10).
                 IF WS-ROW > 0 AND MD-MD-INDEX = 0 AND MD-MD-SERIALIZER = PB-MDS-BYTE
                     MOVE MD-MD-INT TO EN-FLAGS(WS-ROW)
                 END-IF
                 IF WS-ROW > 0 AND MD-MD-INDEX = 6 AND MD-MD-SERIALIZER = PB-MDS-POSE
                     MOVE MD-MD-INT TO EN-POSE(WS-ROW)
                 END-IF
*>               A mob's flags byte (entry 15: bit 4 aggressive, 54 section 2.3) and an ageable mob's baby flag (entry 16, BOOLEAN).
                 IF WS-ROW > 0 AND MD-MD-INDEX = 15 AND MD-MD-SERIALIZER = PB-MDS-BYTE
                     MOVE MD-MD-INT TO EN-MOB-FLAGS(WS-ROW)
                 END-IF
                 IF WS-ROW > 0 AND MD-MD-SERIALIZER = PB-MDS-BOOLEAN
                     CALL "ENTITY-BABY-INDEX" USING EN-KEY(WS-ROW) WS-BABY-INDEX
                     IF MD-MD-INDEX = WS-BABY-INDEX
                         MOVE MD-MD-INT TO EN-BABY(WS-ROW)
                     END-IF
                 END-IF
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
*>               A teleport is no walking: the position of the previous tick is the new one.
                 MOVE WS-X TO EN-OX(WS-ROW)
                 MOVE WS-Y TO EN-OY(WS-ROW)
                 MOVE WS-Z TO EN-OZ(WS-ROW)
             END-IF
         WHEN 104
*>           Set Equipment: entity id, then (slot byte, stack) pairs, every pair but the last with bit 0x80 on the byte (05b 0x68).
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
             CALL "ENTITY-FIND" USING CLIENT-STATE WS-ID WS-ROW
             MOVE 128 TO WS-SLOT
             PERFORM UNTIL WS-SLOT < 128 OR PB-ERROR = 1
                 CALL "PB-GET-UBYTE" USING PB-BUFFER WS-SLOT
                 CALL "PB-GET-ITEM-STACK" USING PB-BUFFER MD-ITEMSTACK-X
                 IF PB-ERROR = 0 AND WS-ROW > 0 AND FUNCTION MOD(WS-SLOT, 128) < 8
                     MOVE MD-ISX-ITEM TO EN-EQ(WS-ROW, FUNCTION MOD(WS-SLOT, 128) + 1)
                     IF MD-ISX-COUNT <= 0
                         MOVE 0 TO EN-EQ(WS-ROW, FUNCTION MOD(WS-SLOT, 128) + 1)
                     END-IF
                     COMPUTE WS-I = FUNCTION MOD(WS-SLOT, 128)
                     CALL "ENTITY-EQ-COMPONENTS" USING CLIENT-STATE WS-ROW WS-I MD-ITEMSTACK-X
                 END-IF
             END-PERFORM
         WHEN 123
*>           Swing Animation: entity id, hand, animation type, duration (54 section 2.1; ignored for an unknown entity).
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-HAND
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-SWTYPE
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-DUR
             CALL "ENTITY-FIND" USING CLIENT-STATE WS-ID WS-ROW
             IF WS-ROW > 0
                 CALL "ENTITY-SWING-START" USING CLIENT-STATE WS-ROW WS-HAND WS-SWTYPE WS-DUR
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

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-EQ-COMPONENTS.
*> USING CLIENT-STATE, replica row, equipment slot ordinal 0 to 7, the stack of Set Equipment (PB-ITEMSTACK-X): keeps the components the models draw in EN-EQX of the
*> slot and, for the hands (0 and 1), EN-HB: dyed_color 47 (the low 24 bits of the Int, 54 section 17), trim 58 (both holders as registry position + 1; an inline holder of
*> unknown length reads as no trim), the glint (enchantment_glint_override 21 when present, else enchantments 13 non-empty: 54 section 19.2), base_color 75 and the
*> first 16 layers of banner_patterns 74 (holder, 0 for an inline pattern, and dye id; 54 section 22). Everything is reset first: an empty stack or one without them clears.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-L                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-OVERRIDE            BINARY-LONG.
 01 WS-ENCHANTED           BINARY-LONG.
 01 WS-B1                  BINARY-LONG.
 01 WS-B2                  BINARY-LONG.
 01 WS-B3                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 COPY PROTO.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-SLOT PB-ITEMSTACK-X.
     MOVE -1 TO EN-EQ-DYE(L-ROW, L-SLOT + 1)
     MOVE 0 TO EN-EQ-TRIM-MAT(L-ROW, L-SLOT + 1) EN-EQ-TRIM-PAT(L-ROW, L-SLOT + 1) EN-EQ-FOIL(L-ROW, L-SLOT + 1)
     IF L-SLOT < 2
         MOVE -1 TO EN-HB-BASE(L-ROW, L-SLOT + 1)
         MOVE 0 TO EN-HB-COUNT(L-ROW, L-SLOT + 1)
     END-IF
     IF PB-ISX-COUNT <= 0
         GOBACK
     END-IF
     MOVE -1 TO WS-OVERRIDE
     MOVE 0 TO WS-ENCHANTED
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > PB-ISX-ADDED-COUNT
         MOVE PB-ISX-VALUE-LENGTH(WS-K) TO WS-LEN
         IF WS-LEN > 0
             COMPUTE WS-B1 = FUNCTION ORD(PB-ISX-VALUE(WS-K)(1:1)) - 1
         ELSE
             MOVE 0 TO WS-B1
         END-IF
         EVALUATE PB-ISX-TYPE(WS-K)
             WHEN 47
                 IF WS-LEN >= 4
                     COMPUTE WS-B1 = FUNCTION ORD(PB-ISX-VALUE(WS-K)(2:1)) - 1
                     COMPUTE WS-B2 = FUNCTION ORD(PB-ISX-VALUE(WS-K)(3:1)) - 1
                     COMPUTE WS-B3 = FUNCTION ORD(PB-ISX-VALUE(WS-K)(4:1)) - 1
                     COMPUTE EN-EQ-DYE(L-ROW, L-SLOT + 1) = WS-B1 * 65536 + WS-B2 * 256 + WS-B3
                 END-IF
             WHEN 58
                 IF WS-LEN >= 2 AND WS-B1 > 0
                     COMPUTE WS-B2 = FUNCTION ORD(PB-ISX-VALUE(WS-K)(2:1)) - 1
                     IF WS-B2 > 0
                         MOVE WS-B1 TO EN-EQ-TRIM-MAT(L-ROW, L-SLOT + 1)
                         MOVE WS-B2 TO EN-EQ-TRIM-PAT(L-ROW, L-SLOT + 1)
                     END-IF
                 END-IF
             WHEN 21
                 MOVE WS-B1 TO WS-OVERRIDE
             WHEN 13
                 IF WS-B1 > 0
                     MOVE 1 TO WS-ENCHANTED
                 END-IF
             WHEN 75
                 IF L-SLOT < 2
                     MOVE WS-B1 TO EN-HB-BASE(L-ROW, L-SLOT + 1)
                 END-IF
             WHEN 74
                 IF L-SLOT < 2
                     *>   A count of 128 or more is a two-byte VarInt: keep the first 16 of whatever follows is not read (the count reads as 16 and the layers are not walked).
                     IF WS-B1 >= 128
                         MOVE 16 TO EN-HB-COUNT(L-ROW, L-SLOT + 1)
                     ELSE
                         MOVE 0 TO EN-HB-COUNT(L-ROW, L-SLOT + 1)
                         MOVE 2 TO WS-P
                         PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > WS-B1 OR WS-N > 16 OR WS-P > WS-LEN
                             COMPUTE WS-B2 = FUNCTION ORD(PB-ISX-VALUE(WS-K)(WS-P:1)) - 1
                             ADD 1 TO WS-P
                             MOVE WS-B2 TO EN-HB-PAT(L-ROW, L-SLOT + 1, WS-N)
                             IF WS-B2 = 0
                            *>           An inline pattern: two Strings (a one-byte length each), skipped.
                                 PERFORM 2 TIMES
                                     IF WS-P <= WS-LEN
                                         COMPUTE WS-L = FUNCTION ORD(PB-ISX-VALUE(WS-K)(WS-P:1)) - 1
                                         COMPUTE WS-P = WS-P + 1 + WS-L
                                     END-IF
                                 END-PERFORM
                             END-IF
                             IF WS-P <= WS-LEN
                                 COMPUTE EN-HB-DYE(L-ROW, L-SLOT + 1, WS-N) = FUNCTION ORD(PB-ISX-VALUE(WS-K)(WS-P:1)) - 1
                                 ADD 1 TO WS-P
                                 ADD 1 TO EN-HB-COUNT(L-ROW, L-SLOT + 1)
                             END-IF
                         END-PERFORM
                     END-IF
                 END-IF
             WHEN OTHER
                 CONTINUE
         END-EVALUATE
     END-PERFORM
     IF WS-OVERRIDE >= 0
         MOVE WS-OVERRIDE TO EN-EQ-FOIL(L-ROW, L-SLOT + 1)
     ELSE
         MOVE WS-ENCHANTED TO EN-EQ-FOIL(L-ROW, L-SLOT + 1)
     END-IF
     GOBACK.
 END PROGRAM ENTITY-EQ-COMPONENTS.
