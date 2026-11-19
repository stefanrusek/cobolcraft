*> Villagers in beds, kicked out of them, and where somebody stands when it leaves a bed (lane bugsleep, operator report of try19: "when I try to get in to the bed it says it's occupied, but
*> normally we kick the entity out of the bed instead. Villagers are invisible in beds."; docs/protocol/33 section 5.2 step 4, 19 section 22.8, 18 section 1.4 entry 14 and 6, 53 pose SLEEPING).
*> A villager that starts sleeping (VL-BRAIN) lies in the middle of the head half of its bed at the mattress height (51 R-E3), the bed is occupied and the viewers are sent its pose SLEEPING (id 2)
*> and the bed position (entry 14); when it wakes (the activity is not rest, or a player takes the bed) the bed is free, the viewers are sent the standing pose and no bed position, and it
*> stands beside the bed. The bed is kept in VL-BED-X, VL-BED-Y, VL-BED-Z while VL-SLEEP is 1.
*> Entry points:
*>   SLEEP-STAND-UP USING dimension, head x, y, z (BINARY-LONG), feet x, y, z out (FLOAT-LONG): a free cell beside the bed (a cell next to either half with room for a body and a solid floor, the
*>     middle of it at the height of the bed's cell), else the middle of the cell above the head half
*>   VSLEEP-HEAD USING dimension, x, y, z (the claimed bed block), head x, y, z out, ok out (BINARY-LONG): the head half of the claimed bed (the claim itself for a block that has no
*>     partner), ok 0 when the bed is occupied
*>   VSLEEP-SEND USING row, present (BINARY-LONG), x, y, z: Set Entity Data (pose and entry 14) of a villager row to everybody who sees it
*>   VSLEEP-START USING row, head x, y, z: the villager of that row lies down in the bed (the caller sets VL-SLEEP and VL-LAST-SLEPT)
*>   VSLEEP-WAKE USING row, slot: stopSleeping: awake, bed free, standing beside the bed, VL-LAST-WOKEN is the tick (does nothing when it does not sleep)
*>   VSLEEP-KICK USING dimension, head x, y, z, kicked out (BINARY-LONG): the villagers sleeping in that bed wake (BedBlock.kickVillagerOutOfBed); kicked is the number
*>   VSLEEP-PAIR USING player row, entity row: a player's client got a villager: when it sleeps the client is sent its pose and bed position
*>   VSLEEP-GONE USING entity row: a villager row is about to be removed: a bed it sleeps in is free again

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SLEEP-STAND-UP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-PART                BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-SIDE                BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Y2                  BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OX                   FLOAT-LONG.
 01 L-OY                   FLOAT-LONG.
 01 L-OZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-OX L-OY L-OZ.
*>   The foot lies one step along the head's facing against it (BED-PART of the head state).
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     CALL "BED-PART" USING WS-STATE WS-PART WS-DX WS-DZ
     COMPUTE WS-FX = L-X + WS-DX
     COMPUTE WS-FZ = L-Z + WS-DZ
     COMPUTE L-OX = L-X + 0.5
     COMPUTE L-OY = L-Y + 1
     COMPUTE L-OZ = L-Z + 0.5
     MOVE 0 TO WS-DONE
     COMPUTE WS-Y1 = L-Y + 1
     COMPUTE WS-Y2 = L-Y - 1
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 7 OR WS-DONE = 1
*>       Cells 0 to 3 are the head's four neighbours, 4 to 7 the foot's (+x, -x, +z, -z); the two halves themselves are no place to stand.
         MOVE L-X TO WS-CX
         MOVE L-Z TO WS-CZ
         IF WS-K > 3
             MOVE WS-FX TO WS-CX
             MOVE WS-FZ TO WS-CZ
         END-IF
         COMPUTE WS-SIDE = FUNCTION MOD(WS-K, 4)
         EVALUATE WS-SIDE
             WHEN 0
                 ADD 1 TO WS-CX
             WHEN 1
                 SUBTRACT 1 FROM WS-CX
             WHEN 2
                 ADD 1 TO WS-CZ
             WHEN 3
                 SUBTRACT 1 FROM WS-CZ
         END-EVALUATE
         MOVE 1 TO WS-OK
         IF (WS-CX = L-X AND WS-CZ = L-Z) OR (WS-CX = WS-FX AND WS-CZ = WS-FZ)
             MOVE 0 TO WS-OK
         END-IF
         IF WS-OK = 1
             CALL "WORLD-GET-BLOCK" USING L-DIM WS-CX L-Y WS-CZ WS-STATE
             IF WS-STATE NOT = 0 AND CB-SOLID(CB-S-BLOCK(WS-STATE + 1) + 1) = 1
                 MOVE 0 TO WS-OK
             END-IF
             CALL "WORLD-GET-BLOCK" USING L-DIM WS-CX WS-Y1 WS-CZ WS-STATE
             IF WS-STATE NOT = 0 AND CB-SOLID(CB-S-BLOCK(WS-STATE + 1) + 1) = 1
                 MOVE 0 TO WS-OK
             END-IF
             CALL "WORLD-GET-BLOCK" USING L-DIM WS-CX WS-Y2 WS-CZ WS-STATE
             IF WS-STATE = 0 OR CB-SOLID(CB-S-BLOCK(WS-STATE + 1) + 1) = 0
                 MOVE 0 TO WS-OK
             END-IF
         END-IF
         IF WS-OK = 1
             COMPUTE L-OX = WS-CX + 0.5
             MOVE L-Y TO L-OY
             COMPUTE L-OZ = WS-CZ + 0.5
             MOVE 1 TO WS-DONE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SLEEP-STAND-UP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VSLEEP-HEAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-HEAD-STATE          BINARY-LONG.
 01 WS-PART                BINARY-LONG.
 01 WS-HEAD-PART           BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-OCC-NAME            PIC X(24) VALUE "occupied".
 01 WS-OCC-TEXT            PIC X(32).
 01 WS-OCC-FOUND           BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-HX                   BINARY-LONG.
 01 L-HY                   BINARY-LONG.
 01 L-HZ                   BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-HX L-HY L-HZ L-OK.
     MOVE L-X TO L-HX
     MOVE L-Y TO L-HY
     MOVE L-Z TO L-HZ
     MOVE 1 TO L-OK
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     CALL "BED-PART" USING WS-STATE WS-PART WS-DX WS-DZ
*>   A foot's head half is one step along the facing; it counts when it is the same bed's head.
     IF WS-PART = 1
         COMPUTE L-HX = L-X + WS-DX
         COMPUTE L-HZ = L-Z + WS-DZ
         CALL "WORLD-GET-BLOCK" USING L-DIM L-HX L-HY L-HZ WS-HEAD-STATE
         CALL "BED-PART" USING WS-HEAD-STATE WS-HEAD-PART WS-DX WS-DZ
         IF WS-HEAD-PART NOT = 2
             MOVE L-X TO L-HX
             MOVE L-Z TO L-HZ
         END-IF
     END-IF
     CALL "WORLD-GET-BLOCK" USING L-DIM L-HX L-HY L-HZ WS-HEAD-STATE
     CALL "PS-GET" USING WS-HEAD-STATE WS-OCC-NAME WS-OCC-TEXT WS-OCC-FOUND
     IF WS-OCC-FOUND = 1 AND FUNCTION TRIM(WS-OCC-TEXT) = "true"
         MOVE 0 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM VSLEEP-HEAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VSLEEP-SEND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-PRESENT              BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-PRESENT L-X L-Y L-Z.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "VSLEEP-BUILD" USING L-ROW L-PRESENT L-X L-Y L-Z PB-BUFFER
     CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM VSLEEP-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VSLEEP-BUILD.
*> USING row, present, x, y, z, PB-BUFFER (initialised): the Set Entity Data packet: entry 6 the pose (2 SLEEPING with a bed position, else 0 STANDING), entry 14 the position (OPTIONAL_BLOCK_POS).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-PACKET-ID           BINARY-LONG VALUE 101.
 01 WS-POSE-INDEX          BINARY-LONG VALUE 6.
 01 WS-POSE-SERIALIZER     BINARY-LONG VALUE 20.
 01 WS-POS-INDEX           BINARY-LONG VALUE 14.
 01 WS-POS-SERIALIZER      BINARY-LONG VALUE 11.
 01 WS-END                 BINARY-LONG VALUE 255.
 01 WS-POSE                BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ROW                  BINARY-LONG.
 01 L-PRESENT              BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-PRESENT L-X L-Y L-Z PB-BUFFER.
     MOVE 0 TO WS-POSE
     IF L-PRESENT = 1
         MOVE 2 TO WS-POSE
     END-IF
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER EN-ID(L-ROW)
     CALL "PB-PUT-UBYTE" USING PB-BUFFER WS-POSE-INDEX
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-POSE-SERIALIZER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-POSE
     CALL "PB-PUT-UBYTE" USING PB-BUFFER WS-POS-INDEX
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-POS-SERIALIZER
     CALL "PB-PUT-BOOL" USING PB-BUFFER L-PRESENT
     IF L-PRESENT = 1
         CALL "PB-PUT-POSITION" USING PB-BUFFER L-X L-Y L-Z
     END-IF
     CALL "PB-PUT-UBYTE" USING PB-BUFFER WS-END
     GOBACK.
 END PROGRAM VSLEEP-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VSLEEP-START.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 01 WS-YES                 BINARY-LONG VALUE 1.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 01 WS-SX                  FLOAT-LONG.
 01 WS-SY                  FLOAT-LONG.
 01 WS-SZ                  FLOAT-LONG.
 01 WS-SYAW                FLOAT-SHORT.
 01 WS-SPITCH              FLOAT-SHORT.
 01 WS-SGROUND             BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z.
     CALL "VL-FIND" USING EN-ID(L-ROW) WS-NO WS-SLOT
     MOVE L-X TO VL-BED-X(WS-SLOT)
     MOVE L-Y TO VL-BED-Y(WS-SLOT)
     MOVE L-Z TO VL-BED-Z(WS-SLOT)
     CALL "SLEEP-OCCUPIED" USING EN-DIM(L-ROW) L-X L-Y L-Z WS-YES
*>   startSleeping puts the villager at the bed position: the middle of the head half, on the mattress (51 R-E3: 9 sixteenths).
     COMPUTE WS-SX = L-X + 0.5
     COMPUTE WS-SY = L-Y + 0.5625
     COMPUTE WS-SZ = L-Z + 0.5
     MOVE EN-YAW(L-ROW) TO WS-SYAW
     MOVE EN-PITCH(L-ROW) TO WS-SPITCH
     MOVE EN-ON-GROUND(L-ROW) TO WS-SGROUND
     CALL "ENTITY-MOVE" USING L-ROW WS-SX WS-SY WS-SZ WS-SYAW WS-SPITCH WS-SGROUND
     CALL "VSLEEP-SEND" USING L-ROW WS-YES L-X L-Y L-Z
     GOBACK.
 END PROGRAM VSLEEP-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VSLEEP-WAKE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-HX                  BINARY-LONG.
 01 WS-HY                  BINARY-LONG.
 01 WS-HZ                  BINARY-LONG.
 01 WS-SX                  FLOAT-LONG.
 01 WS-SY                  FLOAT-LONG.
 01 WS-SZ                  FLOAT-LONG.
 01 WS-SYAW                FLOAT-SHORT.
 01 WS-SPITCH              FLOAT-SHORT.
 01 WS-SGROUND             BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO-X              BINARY-LONG VALUE 0.
 01 WS-ZERO-Y              BINARY-LONG VALUE 0.
 01 WS-ZERO-Z              BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT.
     IF VL-SLEEP(L-SLOT) = 0
         GOBACK
     END-IF
     MOVE VL-BED-X(L-SLOT) TO WS-HX
     MOVE VL-BED-Y(L-SLOT) TO WS-HY
     MOVE VL-BED-Z(L-SLOT) TO WS-HZ
     MOVE 0 TO VL-SLEEP(L-SLOT)
     MOVE CW-TICKS TO VL-LAST-WOKEN(L-SLOT)
     CALL "SLEEP-OCCUPIED" USING EN-DIM(L-ROW) WS-HX WS-HY WS-HZ WS-ZERO
     CALL "SLEEP-STAND-UP" USING EN-DIM(L-ROW) WS-HX WS-HY WS-HZ WS-SX WS-SY WS-SZ
     MOVE EN-YAW(L-ROW) TO WS-SYAW
     MOVE EN-PITCH(L-ROW) TO WS-SPITCH
     MOVE EN-ON-GROUND(L-ROW) TO WS-SGROUND
     CALL "ENTITY-MOVE" USING L-ROW WS-SX WS-SY WS-SZ WS-SYAW WS-SPITCH WS-SGROUND
     CALL "VSLEEP-SEND" USING L-ROW WS-ZERO WS-ZERO-X WS-ZERO-Y WS-ZERO-Z
     GOBACK.
 END PROGRAM VSLEEP-WAKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VSLEEP-KICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 01 WS-S                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-KICKED               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-KICKED.
     MOVE 0 TO L-KICKED
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > VL-MAX
         IF VL-ID(WS-S) > 0 AND VL-SLEEP(WS-S) = 1 AND VL-BED-X(WS-S) = L-X AND VL-BED-Y(WS-S) = L-Y
                 AND VL-BED-Z(WS-S) = L-Z
             MOVE 0 TO WS-FOUND
             PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT OR WS-FOUND = 1
                 IF EN-USED(WS-ROW) = 1 AND EN-ID(WS-ROW) = VL-ID(WS-S) AND EN-DIM(WS-ROW) = L-DIM
                     MOVE 1 TO WS-FOUND
                     CALL "VSLEEP-WAKE" USING WS-ROW WS-S
                     ADD 1 TO L-KICKED
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM VSLEEP-KICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VSLEEP-PAIR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 COPY PROTO.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-YES                 BINARY-LONG VALUE 1.
 01 WS-SLOT                BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ROW.
     CALL "VL-FIND" USING EN-ID(L-ROW) WS-NO WS-SLOT
     IF WS-SLOT > 0 AND VL-SLEEP(WS-SLOT) = 1
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "VSLEEP-BUILD" USING L-ROW WS-YES VL-BED-X(WS-SLOT) VL-BED-Y(WS-SLOT) VL-BED-Z(WS-SLOT) PB-BUFFER
         CALL "CORE-SEND" USING PL-CONN(L-PLAYER) PB-BUFFER
         CALL "PB-FREE" USING PB-BUFFER
     END-IF
     GOBACK.
 END PROGRAM VSLEEP-PAIR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VSLEEP-GONE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "VL-FIND" USING EN-ID(L-ROW) WS-NO WS-SLOT
     IF WS-SLOT > 0 AND VL-SLEEP(WS-SLOT) = 1
         CALL "SLEEP-OCCUPIED" USING EN-DIM(L-ROW) VL-BED-X(WS-SLOT) VL-BED-Y(WS-SLOT) VL-BED-Z(WS-SLOT) WS-NO
     END-IF
     GOBACK.
 END PROGRAM VSLEEP-GONE.
