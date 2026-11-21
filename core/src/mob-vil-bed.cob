*> The bed of a sleeping villager (docs/protocol/19 section 22.8, 44 part 3 sections 2.1 and 2.2, 33 section 5.2 for the bed's own states; lane 002-lane-p49q, T37004): while a villager sleeps in its
*> home bed, the bed's `occupied` property is true on both halves (the foot lies one block behind the head, against the facing), so another villager's AcquirePoi and ValidateNearbyPoi (the bed
*> validity: villagers_can_sleep_on_bed and not occupied) see it taken. The block change goes to the viewers (BLOCK-CHANGE). VL-SLEEP-DATA gives the villager's entity data while it sleeps (18 section
*> 1.4: entry 6 the pose, serializer POSE 20, SLEEPING is id 2 (53 section 1); entry 14 the sleeping position, serializer OPTIONAL_BLOCK_POS 11, the head block of the bed).
*> Gap: the sleeping pose lies the model down at the bed in the real game; here the villager stands where it stopped (within 2 blocks of the bed), the pose and the position are on the wire only.
*>   VL-BED-IS-OCCUPIED USING dim, x, y, z (BINARY-LONG block), occupied out     1 when the block there is a bed with occupied = true
*>   VL-BED-OCCUPY USING entity id, flag (1 occupied, 0 free)                     set the property on both halves of the home bed the villager claims (no bed claimed: nothing)
*>   VL-SLEEP-DATA USING row, PB-BUFFER                                           the pose and sleeping position entries of a sleeping villager that claims a bed (nothing otherwise)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-BED-IS-OCCUPIED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STATE                BINARY-LONG.
 01 WS-NAME                 PIC X(16) VALUE "occupied".
 01 WS-KEEP                 PIC X(16) VALUE "keep".
 01 WS-OUT                  BINARY-LONG.
 01 WS-OLD                  PIC X(16).
 LINKAGE SECTION.
 01 L-DIM                   BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 01 L-OCCUPIED              BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-OCCUPIED.
     MOVE 0 TO L-OCCUPIED
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     CALL "SW-SET-PROP" USING WS-STATE WS-NAME WS-KEEP WS-OUT WS-OLD
     IF WS-OLD = "true"
         MOVE 1 TO L-OCCUPIED
     END-IF
     GOBACK.
 END PROGRAM VL-BED-IS-OCCUPIED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-BED-OCCUPY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HOME                 BINARY-LONG VALUE 2.
 01 WS-DIM                  BINARY-LONG.
 01 WS-X                    BINARY-LONG.
 01 WS-Y                    BINARY-LONG.
 01 WS-Z                    BINARY-LONG.
 01 WS-FOUND                BINARY-LONG.
 01 WS-STATE                BINARY-LONG.
 01 WS-NEW                  BINARY-LONG.
 01 WS-NAME                 PIC X(16) VALUE "occupied".
 01 WS-FACING-NAME          PIC X(16) VALUE "facing".
 01 WS-KEEP                 PIC X(16) VALUE "keep".
 01 WS-VALUE                PIC X(16).
 01 WS-OLD                  PIC X(16).
 01 WS-FACING               PIC X(16).
 01 WS-FX                   BINARY-LONG.
 01 WS-FZ                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                    BINARY-LONG.
 01 L-FLAG                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-FLAG.
     CALL "VPX-OF" USING L-ID WS-HOME WS-DIM WS-X WS-Y WS-Z WS-FOUND
     IF WS-FOUND = 0
         GOBACK
     END-IF
     MOVE "false" TO WS-VALUE
     IF L-FLAG = 1
         MOVE "true" TO WS-VALUE
     END-IF
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "SW-SET-PROP" USING WS-STATE WS-FACING-NAME WS-KEEP WS-NEW WS-FACING
     CALL "SW-SET-PROP" USING WS-STATE WS-NAME WS-VALUE WS-NEW WS-OLD
     IF WS-OLD = SPACES
         GOBACK
     END-IF
     IF WS-NEW NOT = WS-STATE
         CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-NEW
     END-IF
*>   The foot is one block behind the head, against the facing (the head lies along the facing from the foot).
     MOVE 0 TO WS-FX WS-FZ
     EVALUATE FUNCTION TRIM(WS-FACING)
         WHEN "north"
             MOVE 1 TO WS-FZ
         WHEN "south"
             MOVE -1 TO WS-FZ
         WHEN "west"
             MOVE 1 TO WS-FX
         WHEN "east"
             MOVE -1 TO WS-FX
     END-EVALUATE
     COMPUTE WS-X = WS-X + WS-FX
     COMPUTE WS-Z = WS-Z + WS-FZ
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "SW-SET-PROP" USING WS-STATE WS-NAME WS-VALUE WS-NEW WS-OLD
     IF WS-OLD NOT = SPACES AND WS-NEW NOT = WS-STATE
         CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-NEW
     END-IF
     GOBACK.
 END PROGRAM VL-BED-OCCUPY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-SLEEP-DATA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==SD-==.
 01 WS-NO                   BINARY-LONG VALUE 0.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-HOME                 BINARY-LONG VALUE 2.
 01 WS-DIM                  BINARY-LONG.
 01 WS-X                    BINARY-LONG.
 01 WS-Y                    BINARY-LONG.
 01 WS-Z                    BINARY-LONG.
 01 WS-FOUND                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 COPY PROTO.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     CALL "VL-FIND" USING EN-ID(L-ROW) WS-NO WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     IF VL-SLEEP(WS-SLOT) = 0
         GOBACK
     END-IF
     CALL "VPX-OF" USING EN-ID(L-ROW) WS-HOME WS-DIM WS-X WS-Y WS-Z WS-FOUND
     IF WS-FOUND = 0
         GOBACK
     END-IF
     INITIALIZE SD-METADATA-ENTRY-X
     MOVE 6 TO SD-MX-INDEX
     MOVE 20 TO SD-MX-SERIALIZER
     MOVE 2 TO SD-MX-INT
     CALL "PB-PUT-METADATA-ENTRY-X" USING PB-BUFFER SD-METADATA-ENTRY-X
     INITIALIZE SD-METADATA-ENTRY-X
     MOVE 14 TO SD-MX-INDEX
     MOVE 11 TO SD-MX-SERIALIZER
     MOVE 1 TO SD-MX-PRESENT
     MOVE WS-X TO SD-MX-POS-X
     MOVE WS-Y TO SD-MX-POS-Y
     MOVE WS-Z TO SD-MX-POS-Z
     CALL "PB-PUT-METADATA-ENTRY-X" USING PB-BUFFER SD-METADATA-ENTRY-X
     GOBACK.
 END PROGRAM VL-SLEEP-DATA.
