*> Entity NBT, part 1 (docs/protocol/45-entity-nbt-1-shared-model-and-entity-base.md sections 5 and 6; lane 002-lane-p49k, T24500): the Entity
*> base keys that ENTITY-NBT-WRITE-MERGE and ENTITY-NBT-ONE share.
*>   ENTITY-BASE-WRITE USING row, PB-BUFFER   fall_distance, Fire, Air, OnGround, Invulnerable, PortalCooldown, then the conditional invulnerable_time,
*>                                            UUID, CustomNameVisible, Silent, NoGravity, Glowing, TicksFrozen and HasVisualFire (each only when set)
*>   ENTITY-BASE-KEY USING PB-BUFFER, tag type, name, EB-DATA, handled   reads one base key into EB-DATA (handled 1), else leaves the tag
*>   ENTITY-BASE-APPLY USING row, EB-DATA     puts what ENTITY-BASE-KEY collected into the loaded row
*>   ENTITY-DOUBLE-CLASS USING double, class  0 finite, 1 NaN, 2 +Infinity, 3 -Infinity
*>   ENTITY-FLOAT-FINITE USING float, flag    1 when the float is finite
*>   ENTITY-VALIDATE USING x y z vx vy vz yaw pitch, valid   the section 5 and 6 rules of Pos, Motion and Rotation
*> Not modelled: CustomName, Tags, data, Team (no name, tag set, custom data or scoreboard in the core; a world of the 26.3 layout keeps them
*> through EXTRA-CAPTURE) and Passengers (the mob and player riders are stored by their vehicle's own keys).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-BASE-WRITE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-DOUBLE              FLOAT-LONG.
 01 WS-AIR                 BINARY-LONG.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-UUID-INTS.
    05 WS-UUID-INT         BINARY-LONG OCCURS 4 TIMES.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 COPY PROTO.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     MOVE "fall_distance" TO WN MOVE 13 TO WL
     MOVE EN-FALL(L-ROW) TO WS-DOUBLE
     CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WN WL WS-DOUBLE
     MOVE "Fire" TO WN MOVE 4 TO WL
     CALL "NBT-WRITE-SHORT" USING PB-BUFFER WN WL EN-BURN(L-ROW)
     MOVE "Air" TO WN MOVE 3 TO WL
     COMPUTE WS-AIR = 300 - EN-AIR-LOST(L-ROW)
     CALL "NBT-WRITE-SHORT" USING PB-BUFFER WN WL WS-AIR
     MOVE "OnGround" TO WN MOVE 8 TO WL
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL EN-ON-GROUND(L-ROW)
     MOVE "Invulnerable" TO WN MOVE 12 TO WL
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL EN-INVULN(L-ROW)
     MOVE "PortalCooldown" TO WN MOVE 14 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL EN-PORTAL-CD(L-ROW)
     IF EN-INVTIME(L-ROW) > 0
         MOVE "invulnerable_time" TO WN MOVE 17 TO WL
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL EN-INVTIME(L-ROW)
     END-IF
     MOVE "UUID" TO WN MOVE 4 TO WL
     CALL "ENTITY-UUID-INTS" USING EN-UUID(L-ROW) WS-UUID-INTS
     CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-FOUR WS-UUID-INTS
     IF EN-NAME-VIS(L-ROW) = 1
         MOVE "CustomNameVisible" TO WN MOVE 17 TO WL
         CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-ONE
     END-IF
     IF EN-SILENT(L-ROW) = 1
         MOVE "Silent" TO WN MOVE 6 TO WL
         CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-ONE
     END-IF
     IF EN-NOGRAV(L-ROW) = 1
         MOVE "NoGravity" TO WN MOVE 9 TO WL
         CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-ONE
     END-IF
     IF EN-GLOW(L-ROW) = 1
         MOVE "Glowing" TO WN MOVE 7 TO WL
         CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-ONE
     END-IF
     IF EN-FROZEN(L-ROW) > 0
         MOVE "TicksFrozen" TO WN MOVE 11 TO WL
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL EN-FROZEN(L-ROW)
     END-IF
     IF EN-VISFIRE(L-ROW) = 1
         MOVE "HasVisualFire" TO WN MOVE 13 TO WL
         CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-ONE
     END-IF
     GOBACK.
 END PROGRAM ENTITY-BASE-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-BASE-KEY.
*> The base keys that need no row: one tag of the compound, read as the narrowing of 45-1 section 1.1 (a Byte flag is true when non-zero;
*> Fire and Air are Shorts, the counters Ints, fall_distance a Double).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-INT-CAPACITY        BINARY-LONG VALUE 4.
 01 WS-INT-COUNT           BINARY-LONG.
 01 WS-INTS.
    05 WS-INT              BINARY-LONG OCCURS 4 TIMES.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-TYPE                 BINARY-LONG.
 01 L-NAME                 PIC X(32).
 COPY EBDATA.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-TYPE L-NAME EB-DATA L-HANDLED.
     MOVE 1 TO L-HANDLED
     EVALUATE TRUE
         WHEN L-NAME = "fall_distance" AND L-TYPE = 6
             CALL "PB-GET-DOUBLE" USING PB-BUFFER EB-FALL
         WHEN L-NAME = "Invulnerable" AND L-TYPE = 1
             CALL "PB-GET-BYTE" USING PB-BUFFER EB-INVULN
         WHEN L-NAME = "PortalCooldown" AND L-TYPE = 3
             CALL "PB-GET-INT" USING PB-BUFFER EB-PORTAL
         WHEN L-NAME = "invulnerable_time" AND L-TYPE = 3
             CALL "PB-GET-INT" USING PB-BUFFER EB-INVTIME
         WHEN L-NAME = "CustomNameVisible" AND L-TYPE = 1
             CALL "PB-GET-BYTE" USING PB-BUFFER EB-NAME-VIS
         WHEN L-NAME = "Silent" AND L-TYPE = 1
             CALL "PB-GET-BYTE" USING PB-BUFFER EB-SILENT
         WHEN L-NAME = "NoGravity" AND L-TYPE = 1
             CALL "PB-GET-BYTE" USING PB-BUFFER EB-NOGRAV
         WHEN L-NAME = "Glowing" AND L-TYPE = 1
             CALL "PB-GET-BYTE" USING PB-BUFFER EB-GLOW
         WHEN L-NAME = "TicksFrozen" AND L-TYPE = 3
             CALL "PB-GET-INT" USING PB-BUFFER EB-FROZEN
         WHEN L-NAME = "HasVisualFire" AND L-TYPE = 1
             CALL "PB-GET-BYTE" USING PB-BUFFER EB-VISFIRE
         WHEN OTHER
             MOVE 0 TO L-HANDLED
     END-EVALUATE
     GOBACK.
 END PROGRAM ENTITY-BASE-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-BASE-APPLY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 COPY EBDATA.
 PROCEDURE DIVISION USING L-ROW EB-DATA.
     MOVE EB-FALL TO EN-FALL(L-ROW)
     MOVE 0 TO EN-INVULN(L-ROW) EN-SILENT(L-ROW) EN-NOGRAV(L-ROW) EN-GLOW(L-ROW) EN-VISFIRE(L-ROW) EN-NAME-VIS(L-ROW)
     IF EB-INVULN NOT = 0
         MOVE 1 TO EN-INVULN(L-ROW)
     END-IF
     IF EB-SILENT NOT = 0
         MOVE 1 TO EN-SILENT(L-ROW)
     END-IF
     IF EB-NOGRAV NOT = 0
         MOVE 1 TO EN-NOGRAV(L-ROW)
     END-IF
     IF EB-GLOW NOT = 0
         MOVE 1 TO EN-GLOW(L-ROW)
     END-IF
     IF EB-VISFIRE NOT = 0
         MOVE 1 TO EN-VISFIRE(L-ROW)
     END-IF
     IF EB-NAME-VIS NOT = 0
         MOVE 1 TO EN-NAME-VIS(L-ROW)
     END-IF
     MOVE EB-PORTAL TO EN-PORTAL-CD(L-ROW)
     MOVE EB-INVTIME TO EN-INVTIME(L-ROW)
     MOVE EB-FROZEN TO EN-FROZEN(L-ROW)
     GOBACK.
 END PROGRAM ENTITY-BASE-APPLY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-DOUBLE-CLASS.
*> A double's IEEE bits (little-endian, the platform's): the exponent is all ones for NaN and the infinities.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HIGH                BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 01 WS-MANTISSA            BINARY-LONG.
 LINKAGE SECTION.
 01 L-DOUBLE               FLOAT-LONG.
 01 L-BYTES                REDEFINES L-DOUBLE PIC X(8).
 01 L-CLASS                BINARY-LONG.
 PROCEDURE DIVISION USING L-DOUBLE L-CLASS.
     MOVE 0 TO L-CLASS
     COMPUTE WS-HIGH = FUNCTION ORD(L-BYTES(8:1)) - 1
     COMPUTE WS-NEXT = FUNCTION ORD(L-BYTES(7:1)) - 1
     IF FUNCTION MOD(WS-HIGH, 128) = 127 AND WS-NEXT >= 240
         COMPUTE WS-MANTISSA = FUNCTION MOD(WS-NEXT, 16)
         PERFORM VARYING WS-NEXT FROM 1 BY 1 UNTIL WS-NEXT > 6
             COMPUTE WS-MANTISSA = WS-MANTISSA + FUNCTION ORD(L-BYTES(WS-NEXT:1)) - 1
         END-PERFORM
         EVALUATE TRUE
             WHEN WS-MANTISSA > 0
                 MOVE 1 TO L-CLASS
             WHEN WS-HIGH >= 128
                 MOVE 3 TO L-CLASS
             WHEN OTHER
                 MOVE 2 TO L-CLASS
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM ENTITY-DOUBLE-CLASS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-FLOAT-FINITE.
*> A float's IEEE bits: the exponent is all ones for NaN and the infinities (45-1 section 6 step 6: the rotation is not clamped).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HIGH                BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-FLOAT                FLOAT-SHORT.
 01 L-BYTES                REDEFINES L-FLOAT PIC X(4).
 01 L-FINITE               BINARY-LONG.
 PROCEDURE DIVISION USING L-FLOAT L-FINITE.
     MOVE 1 TO L-FINITE
     COMPUTE WS-HIGH = FUNCTION ORD(L-BYTES(4:1)) - 1
     COMPUTE WS-NEXT = FUNCTION ORD(L-BYTES(3:1)) - 1
     IF FUNCTION MOD(WS-HIGH, 128) = 127 AND WS-NEXT >= 128
         MOVE 0 TO L-FINITE
     END-IF
     GOBACK.
 END PROGRAM ENTITY-FLOAT-FINITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-CLAMP.
*> USING value (FLOAT-LONG, in and out), limit (FLOAT-LONG): the value held to plus or minus the limit (an infinity becomes the limit).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NEGATIVE            FLOAT-LONG.
 LINKAGE SECTION.
 01 L-VALUE                FLOAT-LONG.
 01 L-LIMIT                FLOAT-LONG.
 PROCEDURE DIVISION USING L-VALUE L-LIMIT.
     COMPUTE WS-NEGATIVE = 0 - L-LIMIT
     IF L-VALUE > L-LIMIT
         MOVE L-LIMIT TO L-VALUE
     END-IF
     IF L-VALUE < WS-NEGATIVE
         MOVE WS-NEGATIVE TO L-VALUE
     END-IF
     GOBACK.
 END PROGRAM ENTITY-CLAMP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-MOTION-LIMIT.
*> USING component (FLOAT-LONG, in and out): a Motion component beyond magnitude 10 becomes 0 (45-1 section 5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-VALUE.
     IF L-VALUE > 10 OR L-VALUE < -10
         MOVE 0 TO L-VALUE
     END-IF
     GOBACK.
 END PROGRAM ENTITY-MOTION-LIMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-VALIDATE.
*> USING x y z (the Pos as read), vx vy vz (the Motion), yaw pitch, valid out (BINARY-LONG): Pos is clamped (x and z to plus or minus 30000512, y to
*> plus or minus 20000000; an infinity becomes the limit); a NaN component of it, or a yaw or pitch that is NaN or infinite, makes valid 0 (the entity
*> is skipped, 45-1 section 6); each Motion component beyond magnitude 10 becomes 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CLASS-X             BINARY-LONG.
 01 WS-CLASS-Y             BINARY-LONG.
 01 WS-CLASS-Z             BINARY-LONG.
 01 WS-FINITE-YAW          BINARY-LONG.
 01 WS-FINITE-PITCH        BINARY-LONG.
 01 WS-LIMIT-XZ            FLOAT-LONG VALUE 30000512.
 01 WS-LIMIT-Y             FLOAT-LONG VALUE 20000000.
 LINKAGE SECTION.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-YAW                  FLOAT-SHORT.
 01 L-PITCH                FLOAT-SHORT.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-VX L-VY L-VZ L-YAW L-PITCH L-VALID.
     MOVE 1 TO L-VALID
     CALL "ENTITY-DOUBLE-CLASS" USING L-X WS-CLASS-X
     CALL "ENTITY-DOUBLE-CLASS" USING L-Y WS-CLASS-Y
     CALL "ENTITY-DOUBLE-CLASS" USING L-Z WS-CLASS-Z
     CALL "ENTITY-FLOAT-FINITE" USING L-YAW WS-FINITE-YAW
     CALL "ENTITY-FLOAT-FINITE" USING L-PITCH WS-FINITE-PITCH
     IF WS-CLASS-X = 1 OR WS-CLASS-Y = 1 OR WS-CLASS-Z = 1 OR WS-FINITE-YAW = 0 OR WS-FINITE-PITCH = 0
         MOVE 0 TO L-VALID
     END-IF
     CALL "ENTITY-CLAMP" USING L-X WS-LIMIT-XZ
     CALL "ENTITY-CLAMP" USING L-Y WS-LIMIT-Y
     CALL "ENTITY-CLAMP" USING L-Z WS-LIMIT-XZ
     CALL "ENTITY-MOTION-LIMIT" USING L-VX
     CALL "ENTITY-MOTION-LIMIT" USING L-VY
     CALL "ENTITY-MOTION-LIMIT" USING L-VZ
     GOBACK.
 END PROGRAM ENTITY-VALIDATE.
