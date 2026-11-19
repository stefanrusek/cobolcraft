*> The entity data of the non-mob entities (docs/protocol/21 sections 8.9 and 8.16; 00 section 13.2 serializers), lane p49f. A PROJSTATE entry per entity; the viewers get Set Entity Data (0x65) after Add Entity
*> once the state is complete and again when it changes: DECOR-DATA-SYNC compares a signature kept in PJ-I8 (0 = nothing sent yet; ENTITY-EXTRA-NEEDED is 0 until then) and is called by the spawning programs
*> and, for kinds 11 to 13, by THROWN-TICK. Kinds: 11 armor stand (PJ-I1 flags, PJ-POSE: 15 flags Byte, 16 head, 17 body, 18 left arm, 19 right arm, 20 left leg, 21 right leg, Rotations), 12 item frame and
*> glow item frame (PJ-I1 direction, PJ-I2 item, PJ-I3 rotation: 8 Direction, 9 stack (empty = 0 x 0), 10 VarInt), 13 painting (PJ-I1 direction: 8; the variant 9 is not stored), 44 interaction (PJ-R1 width, PJ-R2
*> height, PJ-I1 response: 8 and 9 Float, 10 Boolean), 45 cushion (PJ-I1 dye colour: 8), 46 mannequin (PJ-I1 main hand 1 right, PJ-I2 model customisation 127, PJ-I3 immovable: 15 humanoid arm, 16 Byte, 18
*> Boolean), 10 minecart (PJ-I4 hurt time, PJ-I5 hurt direction, PJ-R3 damage: 8 and 9 VarInt, 10 Float; a furnace minecart (PJ-I1 4) 13 fuel Boolean), 51 boat paddles (PJ-I1 left, PJ-I2 right: 11 and 12 Boolean), 47 block display (PJ-I1 block state: 23), 48 item display (PJ-I1 item, PJ-I2 display type: 23 stack, 24 Byte).
*> A cushion is sat on by CUSHION-USE (MOB-INTERACT: no secondary use, nobody sits there, the player rides nothing).
*> Lane p49t (T39050): the display entities send the defaults of the common fields 8 to 22 (21 section 8.9.3: DISPLAY-COMMON-PUT) before their own fields; kind 49 is the text display (TDISPLAY-SPAWN:
*> 23 the empty component (the root String of length 0, 3 bytes), 24 line width 200, 25 background 0x40000000, 26 opacity -1, 27 flags 0); the mannequin also sends 17 the empty profile (8 zero bytes) and 19 the
*> description (Boolean true and the network NBT compound {translate: entity.minecraft.mannequin.label}; 21 section 8.16.2). Not done: the painting variant, the interaction entity's attack and interaction records and its response (8.9 gives constants
*> only), the cushion placement (Cushion.canBePlacedAt and the tag cushion_uses_collision_shape are not in the documents), its seat position, breaking and drop (the break is 8.16 but the item-drop rule
*> entity_drops, lightning invulnerability and build permission are not wired), the mannequin's NBT (profile, hidden_layers, pose, description), the marker (never sent), the sounds, the entity NBT of all of them.
*>
*>   DECOR-NEW USING kind, key (PIC X(112)), dim, x, y, z (FLOAT-LONG), row out, slot out   the entity and its state entry, not yet announced (the caller sets the state, then ENTITY-TRACK)
*>   DECOR-PUT USING PB-BUFFER, index, serializer, int, f1, f2, f3, count, item   one metadata entry
*>   DECOR-SIG USING row, slot, signature out
*>   DECOR-DATA-BUILD USING row, PB-BUFFER
*>   DECOR-DATA-SYNC USING row
*>   INTERACTION-SPAWN USING dim, x, y, z, width, height (FLOAT-LONG), response, row out
*>   BDISPLAY-SPAWN USING dim, x, y, z, block state, row out
*>   IDISPLAY-SPAWN USING dim, x, y, z, item, display type, row out
*>   TDISPLAY-SPAWN USING dim, x, y, z, row out
*>   DECOR-PUT-DATA USING PB-BUFFER, index, serializer, present, data (PIC X(64)), length    a metadata entry whose value bytes are given verbatim (component, profile)
*>   DECOR-PUT-QUAT USING PB-BUFFER, index, x, y, z, w (FLOAT-LONG)                           a Quaternion entry (serializer 40)
*>   DISPLAY-COMMON-PUT USING PB-BUFFER                                                      entries 8 to 22 with the defaults of 21 section 8.9.3
*>   MANNEQUIN-SPAWN USING dim, x, y, z, row out
*>   CUSHION-SPAWN USING dim, x, y, z, dye colour, row out
*>   CUSHION-USE USING player row, entity row, used out

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DECOR-NEW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-TYPE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-KEY                  PIC X(112).
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-KEY L-DIM L-X L-Y L-Z L-ROW L-SLOT.
     MOVE 0 TO L-ROW L-SLOT
     CALL "THROWN-TYPE" USING L-KEY WS-TYPE
     IF WS-TYPE = 0
         GOBACK
     END-IF
     CALL "ENTITY-ALLOC" USING L-ROW
     CALL "ENTITY-NEW-ID" USING EN-ID(L-ROW)
     CALL "PJ-ALLOC" USING EN-ID(L-ROW) L-KIND L-SLOT
     IF L-SLOT = 0
         INITIALIZE EN-ENTRY(L-ROW)
         MOVE 0 TO L-ROW
         GOBACK
     END-IF
     MOVE WS-TYPE TO EN-TYPE(L-ROW)
     CALL "ENTITY-SET-UUID" USING L-ROW
     MOVE 1 TO EN-HEALTH(L-ROW)
     MOVE L-DIM TO EN-DIM(L-ROW)
     MOVE L-X TO EN-X(L-ROW)
     MOVE L-Y TO EN-Y(L-ROW)
     MOVE L-Z TO EN-Z(L-ROW)
     GOBACK.
 END PROGRAM DECOR-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DECOR-PUT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MD-==.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 01 L-SERIALIZER           BINARY-LONG.
 01 L-INT                  BINARY-LONG.
 01 L-F1                   FLOAT-LONG.
 01 L-F2                   FLOAT-LONG.
 01 L-F3                   FLOAT-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-INDEX L-SERIALIZER L-INT L-F1 L-F2 L-F3 L-COUNT L-ITEM.
     INITIALIZE MD-METADATA-ENTRY-X
     MOVE L-INDEX TO MD-MX-INDEX
     MOVE L-SERIALIZER TO MD-MX-SERIALIZER
     MOVE L-INT TO MD-MX-INT
     MOVE L-F1 TO MD-MX-FLOAT(1)
     MOVE L-F2 TO MD-MX-FLOAT(2)
     MOVE L-F3 TO MD-MX-FLOAT(3)
     MOVE L-COUNT TO MD-MX-IS-COUNT
     MOVE L-ITEM TO MD-MX-IS-ITEM
     CALL "PB-PUT-METADATA-ENTRY-X" USING PB-BUFFER MD-METADATA-ENTRY-X
     GOBACK.
 END PROGRAM DECOR-PUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DECOR-PUT-DATA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MD-==.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 01 L-SERIALIZER           BINARY-LONG.
 01 L-PRESENT              BINARY-LONG.
 01 L-DATA                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-INDEX L-SERIALIZER L-PRESENT L-DATA L-LENGTH.
     INITIALIZE MD-METADATA-ENTRY-X
     MOVE L-INDEX TO MD-MX-INDEX
     MOVE L-SERIALIZER TO MD-MX-SERIALIZER
     MOVE L-PRESENT TO MD-MX-PRESENT
     MOVE L-LENGTH TO MD-MX-DATA-LENGTH
     MOVE L-DATA(1:L-LENGTH) TO MD-MX-DATA(1:L-LENGTH)
     CALL "PB-PUT-METADATA-ENTRY-X" USING PB-BUFFER MD-METADATA-ENTRY-X
     GOBACK.
 END PROGRAM DECOR-PUT-DATA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DECOR-PUT-QUAT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MD-==.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-W                    FLOAT-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-INDEX L-X L-Y L-Z L-W.
     INITIALIZE MD-METADATA-ENTRY-X
     MOVE L-INDEX TO MD-MX-INDEX
     MOVE 40 TO MD-MX-SERIALIZER
     MOVE L-X TO MD-MX-FLOAT(1)
     MOVE L-Y TO MD-MX-FLOAT(2)
     MOVE L-Z TO MD-MX-FLOAT(3)
     MOVE L-W TO MD-MX-FLOAT(4)
     CALL "PB-PUT-METADATA-ENTRY-X" USING PB-BUFFER MD-METADATA-ENTRY-X
     GOBACK.
 END PROGRAM DECOR-PUT-QUAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DISPLAY-COMMON-PUT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-INDEX               BINARY-LONG.
 01 WS-SER                 BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 01 WS-F1                  FLOAT-LONG.
 01 WS-F2                  FLOAT-LONG.
 01 WS-F3                  FLOAT-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-NOUGHT              FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER.
*>   8 to 10 interpolation start delta, duration and pos-rot duration (VarInt 0), 11 translation (0, 0, 0), 12 scale (1, 1, 1), 13 and 14 the rotations (identity), 15 billboard Byte 0, 16 brightness -1,
*>   17 view range 1.0, 18 shadow radius 0.0, 19 shadow strength 1.0, 20 width 0.0, 21 height 0.0, 22 glow colour -1 (21 section 8.9.3).
     MOVE 1 TO WS-SER
     PERFORM VARYING WS-INDEX FROM 8 BY 1 UNTIL WS-INDEX > 10
         CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-ZERO WS-NOUGHT WS-NOUGHT WS-NOUGHT WS-ZERO WS-ZERO
     END-PERFORM
     MOVE 39 TO WS-SER
     MOVE 11 TO WS-INDEX
     CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-ZERO WS-NOUGHT WS-NOUGHT WS-NOUGHT WS-ZERO WS-ZERO
     MOVE 12 TO WS-INDEX
     CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-ZERO WS-ONE WS-ONE WS-ONE WS-ZERO WS-ZERO
     MOVE 13 TO WS-INDEX
     CALL "DECOR-PUT-QUAT" USING PB-BUFFER WS-INDEX WS-NOUGHT WS-NOUGHT WS-NOUGHT WS-ONE
     MOVE 14 TO WS-INDEX
     CALL "DECOR-PUT-QUAT" USING PB-BUFFER WS-INDEX WS-NOUGHT WS-NOUGHT WS-NOUGHT WS-ONE
     MOVE 15 TO WS-INDEX
     MOVE 0 TO WS-SER
     CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-ZERO WS-NOUGHT WS-NOUGHT WS-NOUGHT WS-ZERO WS-ZERO
     MOVE 16 TO WS-INDEX
     MOVE 1 TO WS-SER
     MOVE -1 TO WS-INT
     CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-INT WS-NOUGHT WS-NOUGHT WS-NOUGHT WS-ZERO WS-ZERO
     MOVE 3 TO WS-SER
     MOVE 17 TO WS-INDEX
     CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-ZERO WS-ONE WS-NOUGHT WS-NOUGHT WS-ZERO WS-ZERO
     MOVE 18 TO WS-INDEX
     CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-ZERO WS-NOUGHT WS-NOUGHT WS-NOUGHT WS-ZERO WS-ZERO
     MOVE 19 TO WS-INDEX
     CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-ZERO WS-ONE WS-NOUGHT WS-NOUGHT WS-ZERO WS-ZERO
     MOVE 20 TO WS-INDEX
     CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-ZERO WS-NOUGHT WS-NOUGHT WS-NOUGHT WS-ZERO WS-ZERO
     MOVE 21 TO WS-INDEX
     CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-ZERO WS-NOUGHT WS-NOUGHT WS-NOUGHT WS-ZERO WS-ZERO
     MOVE 22 TO WS-INDEX
     MOVE 1 TO WS-SER
     CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-INT WS-NOUGHT WS-NOUGHT WS-NOUGHT WS-ZERO WS-ZERO
     GOBACK.
 END PROGRAM DISPLAY-COMMON-PUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DECOR-SIG.
*> 1 + MOD of a weighted sum of the state that is sent; never 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SUM                 BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 01 WS-V                   BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-SIG                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-SIG.
     MOVE 0 TO WS-SUM
     EVALUATE PJ-KIND(L-SLOT)
         WHEN 11
             MOVE PJ-I1(L-SLOT) TO WS-SUM
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 18
                 COMPUTE WS-V = FUNCTION INTEGER(PJ-POSE(L-SLOT, WS-I) * 100 + 100000)
                 COMPUTE WS-SUM = FUNCTION MOD(WS-SUM * 31 + WS-V, 1000000007)
             END-PERFORM
         WHEN 10
             COMPUTE WS-SUM = PJ-I4(L-SLOT) + 64 * (PJ-I5(L-SLOT) + 2) + 1024 * FUNCTION INTEGER(PJ-R3(L-SLOT) * 10)
             IF PJ-I1(L-SLOT) = 4 AND PJ-I3(L-SLOT) > 0
                 ADD 1000000 TO WS-SUM
             END-IF
         WHEN 51
             COMPUTE WS-SUM = PJ-I1(L-SLOT) + 2 * PJ-I2(L-SLOT)
         WHEN 12
             COMPUTE WS-SUM = PJ-I1(L-SLOT) + 8 * PJ-I3(L-SLOT) + 64 * PJ-I2(L-SLOT)
         WHEN 13
             COMPUTE WS-SUM = PJ-I1(L-SLOT) + 8 * PJ-I4(L-SLOT)
         WHEN OTHER
             MOVE PJ-I1(L-SLOT) TO WS-SUM
     END-EVALUATE
     COMPUTE L-SIG = 1 + FUNCTION MOD(WS-SUM, 1000000000)
     GOBACK.
 END PROGRAM DECOR-SIG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DECOR-DATA-BUILD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-PACKET-ID           BINARY-LONG VALUE 101.
 01 WS-SLOT                BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-SER                 BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 01 WS-F1                  FLOAT-LONG.
 01 WS-F2                  FLOAT-LONG.
 01 WS-F3                  FLOAT-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-END                 BINARY-LONG VALUE 255.
 01 WS-SIG                 BINARY-LONG.
 01 WS-DATA                PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-PRESENT             BINARY-LONG.
 01 WS-EMPTY-TEXT          PIC X(3) VALUE LOW-VALUES.
 01 WS-LABEL               PIC X(32) VALUE "entity.minecraft.mannequin.label".
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER EN-ID(L-ROW)
     MOVE 0 TO WS-INT WS-F1 WS-F2 WS-F3 WS-COUNT WS-ITEM
     EVALUATE PJ-KIND(WS-SLOT)
         WHEN 11
             MOVE 15 TO WS-INDEX
             MOVE 0 TO WS-SER
             MOVE PJ-I1(WS-SLOT) TO WS-INT
             CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-INT WS-F1 WS-F2 WS-F3 WS-COUNT WS-ITEM
             MOVE 9 TO WS-SER
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
                 COMPUTE WS-INDEX = 15 + WS-I
                 MOVE PJ-POSE(WS-SLOT, WS-I * 3 - 2) TO WS-F1
                 MOVE PJ-POSE(WS-SLOT, WS-I * 3 - 1) TO WS-F2
                 MOVE PJ-POSE(WS-SLOT, WS-I * 3) TO WS-F3
                 CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-INT WS-F1 WS-F2 WS-F3 WS-COUNT WS-ITEM
             END-PERFORM
         WHEN 12
             MOVE 8 TO WS-INDEX
             MOVE 12 TO WS-SER
             MOVE PJ-I1(WS-SLOT) TO WS-INT
             CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-INT WS-F1 WS-F2 WS-F3 WS-COUNT WS-ITEM
             MOVE 9 TO WS-INDEX
             MOVE 7 TO WS-SER
             IF PJ-I2(WS-SLOT) > 0
                 MOVE 1 TO WS-COUNT
                 MOVE PJ-I2(WS-SLOT) TO WS-ITEM
             END-IF
             CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-INT WS-F1 WS-F2 WS-F3 WS-COUNT WS-ITEM
             MOVE 10 TO WS-INDEX
             MOVE 1 TO WS-SER
             MOVE PJ-I3(WS-SLOT) TO WS-INT
             MOVE 0 TO WS-COUNT WS-ITEM
             CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-INT WS-F1 WS-F2 WS-F3 WS-COUNT WS-ITEM
         WHEN 10
             MOVE 8 TO WS-INDEX
             MOVE 1 TO WS-SER
             MOVE PJ-I4(WS-SLOT) TO WS-INT
             CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-INT WS-F1 WS-F2 WS-F3 WS-COUNT WS-ITEM
             MOVE 9 TO WS-INDEX
             MOVE PJ-I5(WS-SLOT) TO WS-INT
             CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-INT WS-F1 WS-F2 WS-F3 WS-COUNT WS-ITEM
             MOVE 10 TO WS-INDEX
             MOVE 3 TO WS-SER
             MOVE PJ-R3(WS-SLOT) TO WS-F1
             CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-INT WS-F1 WS-F2 WS-F3 WS-COUNT WS-ITEM
             IF PJ-I1(WS-SLOT) = 4
                 MOVE 13 TO WS-INDEX
                 MOVE 8 TO WS-SER
                 MOVE 0 TO WS-INT
                 IF PJ-I3(WS-SLOT) > 0
                     MOVE 1 TO WS-INT
                 END-IF
                 CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-INT WS-F1 WS-F2 WS-F3 WS-COUNT WS-ITEM
             END-IF
         WHEN 51
             MOVE 11 TO WS-INDEX
             MOVE 8 TO WS-SER
             MOVE PJ-I1(WS-SLOT) TO WS-INT
             CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-INT WS-F1 WS-F2 WS-F3 WS-COUNT WS-ITEM
             MOVE 12 TO WS-INDEX
             MOVE PJ-I2(WS-SLOT) TO WS-INT
             CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-INT WS-F1 WS-F2 WS-F3 WS-COUNT WS-ITEM
         WHEN 13
             MOVE 8 TO WS-INDEX
             MOVE 12 TO WS-SER
             MOVE PJ-I1(WS-SLOT) TO WS-INT
             CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-INT WS-F1 WS-F2 WS-F3 WS-COUNT WS-ITEM
*>           9 the variant: a Holder, VarInt registry id + 1 (21 section 8.9.1; ids of 127 or more would need two bytes: the registry has 51 entries). PJ-I4 is the registry id (0: the first entry).
             MOVE LOW-VALUES TO WS-DATA
             COMPUTE WS-INT = PJ-I4(WS-SLOT) + 1
             MOVE FUNCTION CHAR(WS-INT + 1) TO WS-DATA(1:1)
             MOVE 1 TO WS-LENGTH
             MOVE 0 TO WS-PRESENT
             MOVE 9 TO WS-INDEX
             MOVE 34 TO WS-SER
             CALL "DECOR-PUT-DATA" USING PB-BUFFER WS-INDEX WS-SER WS-PRESENT WS-DATA WS-LENGTH
         WHEN 44
             MOVE 8 TO WS-INDEX
             MOVE 3 TO WS-SER
             MOVE PJ-R1(WS-SLOT) TO WS-F1
             CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-INT WS-F1 WS-F2 WS-F3 WS-COUNT WS-ITEM
             MOVE 9 TO WS-INDEX
             MOVE PJ-R2(WS-SLOT) TO WS-F1
             CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-INT WS-F1 WS-F2 WS-F3 WS-COUNT WS-ITEM
             MOVE 10 TO WS-INDEX
             MOVE 8 TO WS-SER
             MOVE PJ-I1(WS-SLOT) TO WS-INT
             CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-INT WS-F1 WS-F2 WS-F3 WS-COUNT WS-ITEM
         WHEN 45
             MOVE 8 TO WS-INDEX
             MOVE 43 TO WS-SER
             MOVE PJ-I1(WS-SLOT) TO WS-INT
             CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-INT WS-F1 WS-F2 WS-F3 WS-COUNT WS-ITEM
         WHEN 46
             MOVE 15 TO WS-INDEX
             MOVE 42 TO WS-SER
             MOVE PJ-I1(WS-SLOT) TO WS-INT
             CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-INT WS-F1 WS-F2 WS-F3 WS-COUNT WS-ITEM
             MOVE 16 TO WS-INDEX
             MOVE 0 TO WS-SER
             MOVE PJ-I2(WS-SLOT) TO WS-INT
             CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-INT WS-F1 WS-F2 WS-F3 WS-COUNT WS-ITEM
*>           17 the empty profile: Either partial (false), no name, no id, no properties, four absent skin patch fields = 8 zero bytes (21 section 8.16.2).
             MOVE LOW-VALUES TO WS-DATA
             MOVE 8 TO WS-LENGTH
             MOVE 0 TO WS-PRESENT
             MOVE 17 TO WS-INDEX
             MOVE 41 TO WS-SER
             CALL "DECOR-PUT-DATA" USING PB-BUFFER WS-INDEX WS-SER WS-PRESENT WS-DATA WS-LENGTH
             MOVE 18 TO WS-INDEX
             MOVE 8 TO WS-SER
             MOVE PJ-I3(WS-SLOT) TO WS-INT
             CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-INT WS-F1 WS-F2 WS-F3 WS-COUNT WS-ITEM
*>           19 the description: Optional component present, the network NBT compound {translate: "entity.minecraft.mannequin.label"} (tag 10, then String tag 8 named "translate").
             MOVE LOW-VALUES TO WS-DATA
             MOVE X"0A08" TO WS-DATA(1:2)
             MOVE X"0009" TO WS-DATA(3:2)
             MOVE "translate" TO WS-DATA(5:9)
             MOVE X"0020" TO WS-DATA(14:2)
             MOVE WS-LABEL TO WS-DATA(16:32)
             MOVE 48 TO WS-LENGTH
             MOVE 1 TO WS-PRESENT
             MOVE 19 TO WS-INDEX
             MOVE 6 TO WS-SER
             CALL "DECOR-PUT-DATA" USING PB-BUFFER WS-INDEX WS-SER WS-PRESENT WS-DATA WS-LENGTH
         WHEN 47
             CALL "DISPLAY-COMMON-PUT" USING PB-BUFFER
             MOVE 23 TO WS-INDEX
             MOVE 14 TO WS-SER
             MOVE PJ-I1(WS-SLOT) TO WS-INT
             CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-INT WS-F1 WS-F2 WS-F3 WS-COUNT WS-ITEM
         WHEN 49
*>           The text display (21 section 8.9.3): the empty component (the network NBT root String tag 8 of length 0), line width 200, background 0x40000000, opacity -1, flags 0.
             CALL "DISPLAY-COMMON-PUT" USING PB-BUFFER
             MOVE X"080000" TO WS-DATA
             MOVE 3 TO WS-LENGTH
             MOVE 0 TO WS-PRESENT
             MOVE 23 TO WS-INDEX
             MOVE 5 TO WS-SER
             CALL "DECOR-PUT-DATA" USING PB-BUFFER WS-INDEX WS-SER WS-PRESENT WS-DATA WS-LENGTH
             MOVE 24 TO WS-INDEX
             MOVE 1 TO WS-SER
             MOVE 200 TO WS-INT
             CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-INT WS-F1 WS-F2 WS-F3 WS-COUNT WS-ITEM
             MOVE 25 TO WS-INDEX
             MOVE 1073741824 TO WS-INT
             CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-INT WS-F1 WS-F2 WS-F3 WS-COUNT WS-ITEM
             MOVE 26 TO WS-INDEX
             MOVE 0 TO WS-SER
             MOVE -1 TO WS-INT
             CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-INT WS-F1 WS-F2 WS-F3 WS-COUNT WS-ITEM
             MOVE 27 TO WS-INDEX
             MOVE 0 TO WS-INT
             CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-INT WS-F1 WS-F2 WS-F3 WS-COUNT WS-ITEM
         WHEN 48
             CALL "DISPLAY-COMMON-PUT" USING PB-BUFFER
             MOVE 23 TO WS-INDEX
             MOVE 7 TO WS-SER
             MOVE 1 TO WS-COUNT
             MOVE PJ-I1(WS-SLOT) TO WS-ITEM
             CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-INT WS-F1 WS-F2 WS-F3 WS-COUNT WS-ITEM
             MOVE 24 TO WS-INDEX
             MOVE 0 TO WS-SER
             MOVE PJ-I2(WS-SLOT) TO WS-INT
             MOVE 0 TO WS-COUNT WS-ITEM
             CALL "DECOR-PUT" USING PB-BUFFER WS-INDEX WS-SER WS-INT WS-F1 WS-F2 WS-F3 WS-COUNT WS-ITEM
     END-EVALUATE
     MOVE 0 TO WS-SER WS-INT
     CALL "DECOR-PUT" USING PB-BUFFER WS-END WS-SER WS-INT WS-F1 WS-F2 WS-F3 WS-COUNT WS-ITEM
     CALL "DECOR-SIG" USING L-ROW WS-SLOT WS-SIG
     MOVE WS-SIG TO PJ-I8(WS-SLOT)
     GOBACK.
 END PROGRAM DECOR-DATA-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DECOR-DATA-SYNC.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-SLOT                BINARY-LONG.
 01 WS-SIG                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     CALL "DECOR-SIG" USING L-ROW WS-SLOT WS-SIG
     IF WS-SIG = PJ-I8(WS-SLOT)
         GOBACK
     END-IF
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "DECOR-DATA-BUILD" USING L-ROW PB-BUFFER
     CALL "GI-VIEWERS-SEND" USING L-ROW PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM DECOR-DATA-SYNC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. INTERACTION-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROJSTATE.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:interaction".
 01 WS-KIND                BINARY-LONG VALUE 44.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-WIDTH                FLOAT-LONG.
 01 L-HEIGHT               FLOAT-LONG.
 01 L-RESPONSE             BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-WIDTH L-HEIGHT L-RESPONSE L-ROW.
     CALL "DECOR-NEW" USING WS-KIND WS-KEY L-DIM L-X L-Y L-Z L-ROW WS-SLOT
     IF L-ROW > 0
         MOVE L-WIDTH TO PJ-R1(WS-SLOT)
         MOVE L-HEIGHT TO PJ-R2(WS-SLOT)
         MOVE L-RESPONSE TO PJ-I1(WS-SLOT)
         CALL "ENTITY-TRACK" USING L-ROW
         CALL "DECOR-DATA-SYNC" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM INTERACTION-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BDISPLAY-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROJSTATE.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:block_display".
 01 WS-KIND                BINARY-LONG VALUE 47.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-ROW.
     CALL "DECOR-NEW" USING WS-KIND WS-KEY L-DIM L-X L-Y L-Z L-ROW WS-SLOT
     IF L-ROW > 0
         MOVE L-STATE TO PJ-I1(WS-SLOT)
         CALL "ENTITY-TRACK" USING L-ROW
         CALL "DECOR-DATA-SYNC" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM BDISPLAY-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IDISPLAY-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROJSTATE.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:item_display".
 01 WS-KIND                BINARY-LONG VALUE 48.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-ITEM L-TYPE L-ROW.
     CALL "DECOR-NEW" USING WS-KIND WS-KEY L-DIM L-X L-Y L-Z L-ROW WS-SLOT
     IF L-ROW > 0
         MOVE L-ITEM TO PJ-I1(WS-SLOT)
         MOVE L-TYPE TO PJ-I2(WS-SLOT)
         CALL "ENTITY-TRACK" USING L-ROW
         CALL "DECOR-DATA-SYNC" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM IDISPLAY-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TDISPLAY-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROJSTATE.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:text_display".
 01 WS-KIND                BINARY-LONG VALUE 49.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-ROW.
     CALL "DECOR-NEW" USING WS-KIND WS-KEY L-DIM L-X L-Y L-Z L-ROW WS-SLOT
     IF L-ROW > 0
         MOVE 1 TO PJ-I1(WS-SLOT)
         CALL "ENTITY-TRACK" USING L-ROW
         CALL "DECOR-DATA-SYNC" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM TDISPLAY-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MANNEQUIN-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:mannequin".
 01 WS-KIND                BINARY-LONG VALUE 46.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-ROW.
     CALL "DECOR-NEW" USING WS-KIND WS-KEY L-DIM L-X L-Y L-Z L-ROW WS-SLOT
     IF L-ROW > 0
         MOVE 1 TO PJ-I1(WS-SLOT)
         MOVE 127 TO PJ-I2(WS-SLOT)
         MOVE 0 TO PJ-I3(WS-SLOT)
         MOVE 20 TO EN-HEALTH(L-ROW)
         CALL "ENTITY-TRACK" USING L-ROW
         CALL "DECOR-DATA-SYNC" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM MANNEQUIN-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CUSHION-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROJSTATE.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:cushion".
 01 WS-KIND                BINARY-LONG VALUE 45.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-COLOUR               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-COLOUR L-ROW.
     CALL "DECOR-NEW" USING WS-KIND WS-KEY L-DIM L-X L-Y L-Z L-ROW WS-SLOT
     IF L-ROW > 0
         MOVE L-COLOUR TO PJ-I1(WS-SLOT)
         CALL "ENTITY-TRACK" USING L-ROW
         CALL "DECOR-DATA-SYNC" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM CUSHION-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CUSHION-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-USED                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ENTITY L-USED.
     MOVE 0 TO L-USED
     CALL "PJ-FIND" USING EN-ID(L-ENTITY) WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     IF PJ-KIND(WS-SLOT) NOT = 45
         GOBACK
     END-IF
     IF PL-SNEAKING(L-PLAYER) = 0 AND EN-RIDER(L-ENTITY) = 0 AND EN-VEHICLE(PL-ENTITY-ROW(L-PLAYER)) = 0
         MOVE L-PLAYER TO EN-RIDER(L-ENTITY)
         MOVE L-ENTITY TO EN-VEHICLE(PL-ENTITY-ROW(L-PLAYER))
         CALL "MOB-RIDE-SEND" USING L-ENTITY
         MOVE 1 TO L-USED
     END-IF
     GOBACK.
 END PROGRAM CUSHION-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOAT-PADDLE.
*> USING connection id, PLAY-SERVERBOUND (a decoded Paddle Boat 0x23: PSB-FLAGS bit 1 left, bit 2 right): the rider of a boat sets the paddle states of the boat it steers (44-8 section 3.5); the viewers get
*> metadata 11 and 12 when they changed. A player who steers no boat changes nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-BOAT                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 51.
 01 WS-LEFT                BINARY-LONG.
 01 WS-RIGHT               BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND.
     MOVE CN-PLAYER(L-ID) TO WS-PLAYER
     MOVE EN-VEHICLE(PL-ENTITY-ROW(WS-PLAYER)) TO WS-BOAT
     IF WS-BOAT = 0
         GOBACK
     END-IF
     IF EN-BT-KIND(WS-BOAT) = 0 OR EN-RIDER(WS-BOAT) NOT = WS-PLAYER
         GOBACK
     END-IF
     CALL "PJ-FIND" USING EN-ID(WS-BOAT) WS-SLOT
     IF WS-SLOT = 0
         CALL "PJ-ALLOC" USING EN-ID(WS-BOAT) WS-KIND WS-SLOT
     END-IF
     IF WS-SLOT = 0
         GOBACK
     END-IF
     COMPUTE WS-RIGHT = FUNCTION INTEGER(PSB-FLAGS / 2)
     COMPUTE WS-LEFT = PSB-FLAGS - 2 * WS-RIGHT
     MOVE WS-LEFT TO PJ-I1(WS-SLOT)
     MOVE WS-RIGHT TO PJ-I2(WS-SLOT)
     CALL "DECOR-DATA-SYNC" USING WS-BOAT
     GOBACK.
 END PROGRAM BOAT-PADDLE.
