*> Villagers leaving beds, kicked out of them, and where somebody stands when it leaves a bed (lane bugsleep, operator report of try19: "when I try to get in to the bed it says it's occupied, but
*> normally we kick the entity out of the bed instead. Villagers are invisible in beds."; docs/protocol/33 section 5.2 step 4, 19 section 22.8, 18 section 1.4 entry 14 and 6, 53 pose SLEEPING).
*> Going to sleep is VL-BRAIN-SLEEP (mob-vil-brain.cob: the bed occupied, the villager on the mattress, the pose and bed position through MOB-DATA-BUILD and VL-SLEEP-DATA, which also
*> serve a client that pairs with a sleeping villager). Waking here: the bed is free, the villager stands beside the bed and the viewers are sent the standing pose and no bed position.
*> The bed of a villager is its home claim (VPX-OF kind 2, the head half of the bed).
*> Entry points:
*>   SLEEP-STAND-UP USING dimension, head x, y, z (BINARY-LONG), feet x, y, z out (FLOAT-LONG): a free cell beside the bed (a cell next to either half with room for a body and a solid floor, the
*>     middle of it at the height of the bed's cell), else the middle of the cell above the head half
*>   VSLEEP-SEND USING row: Set Entity Data of a villager row that woke (pose STANDING, no entry 14 position) to everybody who sees it
*>   VSLEEP-WAKE USING row, slot: stopSleeping: awake, VL-LAST-WOKEN is the tick, no new sleep for 40 ticks, bed free, standing beside the bed (does nothing when it does not sleep)
*>   VSLEEP-KICK USING dimension, head x, y, z, kicked out (BINARY-LONG): the villagers sleeping in that bed wake (BedBlock.kickVillagerOutOfBed); kicked is the number

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
 PROGRAM-ID. VSLEEP-SEND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "VSLEEP-BUILD" USING L-ROW PB-BUFFER
     CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM VSLEEP-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VSLEEP-BUILD.
*> USING row, PB-BUFFER (initialised): the Set Entity Data packet of a villager that woke: entry 6 the pose 0 STANDING, entry 14 the position absent (OPTIONAL_BLOCK_POS).
*> (The sleeping form goes with every MOB-DATA-BUILD through VL-SLEEP-DATA.)
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-PACKET-ID           BINARY-LONG VALUE 101.
 01 WS-POSE-INDEX          BINARY-LONG VALUE 6.
 01 WS-POSE-SERIALIZER     BINARY-LONG VALUE 20.
 01 WS-POS-INDEX           BINARY-LONG VALUE 14.
 01 WS-POS-SERIALIZER      BINARY-LONG VALUE 11.
 01 WS-END                 BINARY-LONG VALUE 255.
 01 WS-STANDING            BINARY-LONG VALUE 0.
 01 WS-ABSENT              BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER EN-ID(L-ROW)
     CALL "PB-PUT-UBYTE" USING PB-BUFFER WS-POSE-INDEX
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-POSE-SERIALIZER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-STANDING
     CALL "PB-PUT-UBYTE" USING PB-BUFFER WS-POS-INDEX
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-POS-SERIALIZER
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ABSENT
     CALL "PB-PUT-UBYTE" USING PB-BUFFER WS-END
     GOBACK.
 END PROGRAM VSLEEP-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VSLEEP-WAKE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 COPY VLMEM.
 01 WS-HOME                BINARY-LONG VALUE 2.
 01 WS-DIM                 BINARY-LONG.
 01 WS-HX                  BINARY-LONG.
 01 WS-HY                  BINARY-LONG.
 01 WS-HZ                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-SX                  FLOAT-LONG.
 01 WS-SY                  FLOAT-LONG.
 01 WS-SZ                  FLOAT-LONG.
 01 WS-SYAW                FLOAT-SHORT.
 01 WS-SPITCH              FLOAT-SHORT.
 01 WS-SGROUND             BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT.
     IF VL-SLEEP(L-SLOT) = 0
         GOBACK
     END-IF
     MOVE 0 TO VL-SLEEP(L-SLOT)
     MOVE CW-TICKS TO VL-LAST-WOKEN(L-SLOT)
     COMPUTE VM-T(L-SLOT, TM-SLEEP-OK) = CW-TICKS + 40
     CALL "VPX-OF" USING EN-ID(L-ROW) WS-HOME WS-DIM WS-HX WS-HY WS-HZ WS-FOUND
     CALL "VL-BED-OCCUPY" USING EN-ID(L-ROW) WS-ZERO
     IF WS-FOUND = 1 AND WS-DIM = EN-DIM(L-ROW)
         CALL "SLEEP-STAND-UP" USING EN-DIM(L-ROW) WS-HX WS-HY WS-HZ WS-SX WS-SY WS-SZ
         MOVE EN-YAW(L-ROW) TO WS-SYAW
         MOVE EN-PITCH(L-ROW) TO WS-SPITCH
         MOVE EN-ON-GROUND(L-ROW) TO WS-SGROUND
         CALL "ENTITY-MOVE" USING L-ROW WS-SX WS-SY WS-SZ WS-SYAW WS-SPITCH WS-SGROUND
     END-IF
     CALL "VSLEEP-SEND" USING L-ROW
     GOBACK.
 END PROGRAM VSLEEP-WAKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VSLEEP-KICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 01 WS-HOME                BINARY-LONG VALUE 2.
 01 WS-S                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-HX                  BINARY-LONG.
 01 WS-HY                  BINARY-LONG.
 01 WS-HZ                  BINARY-LONG.
 01 WS-CLAIMED             BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-KICKED               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-KICKED.
     MOVE 0 TO L-KICKED
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > VL-MAX
         IF VL-ID(WS-S) > 0 AND VL-SLEEP(WS-S) = 1
             CALL "VPX-OF" USING VL-ID(WS-S) WS-HOME WS-DIM WS-HX WS-HY WS-HZ WS-CLAIMED
             IF WS-CLAIMED = 1 AND WS-DIM = L-DIM AND WS-HX = L-X AND WS-HY = L-Y AND WS-HZ = L-Z
                 MOVE 0 TO WS-FOUND
                 PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT OR WS-FOUND = 1
                     IF EN-USED(WS-ROW) = 1 AND EN-ID(WS-ROW) = VL-ID(WS-S)
                         MOVE 1 TO WS-FOUND
                         CALL "VSLEEP-WAKE" USING WS-ROW WS-S
                         ADD 1 TO L-KICKED
                     END-IF
                 END-PERFORM
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM VSLEEP-KICK.
