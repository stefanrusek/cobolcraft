*> The warden's body (lane 002-lane-p49w; docs/protocol/20 section 15 (Anger: touching), 15.4, 44-5 section 3.2 to 3.4, 53 section 1). State: WD-TOUCH-CD and WD-POSE of WARDENSTATE.cpy.
*>   WARDEN-TOUCH USING warden row, slot: LivingEntity.pushEntities -> Warden.doPush, once a tick: when the touch cooldown is absent and the warden is not digging or emerging, the first living entity
*>     (tracker row order) whose box overlaps the warden's (the registry sizes: 0.9 x 2.9 the warden, 0.6 x 1.8 a player) starts the 20-tick touch cooldown and gets increaseAngerAt (35); a player or mob
*>     that cannot be targeted still starts the cooldown, a spectator is not pushed, boxes that only touch at a face do not overlap. Approximation: the order of the overlapping entities is the row order.
*>   WARDEN-POSE-SYNC USING warden row, slot: the pose the warden's state asks for (EMERGING while is_emerging, else DIGGING, ROARING during Roar, SNIFFING from TryToSniff to the end of Sniffing, else
*>     STANDING) is kept in WD-POSE and sent to the viewers as Set Entity Data (index 6) when it changed.
*>   WARDEN-POSE-BUILD USING tracker row, PB-BUFFER (empty): Set Entity Data of the pose (index 6 POSE).
*>   WARDEN-POSE-OF USING tracker row, pose out: WD-POSE of the warden of that row (0 for any other entity).
*>   WARDEN-IN-LIQUID USING warden row, flag out: the warden's box touches water or lava (Entity.isInLiquid).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WARDEN-TOUCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY STDMOBS.
 COPY WARDENSTATE.
 01 WS-E                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-LIVING              BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG VALUE 35.
 01 WS-EX                  FLOAT-LONG.
 01 WS-EY                  FLOAT-LONG.
 01 WS-EZ                  FLOAT-LONG.
 01 WS-HALF                FLOAT-LONG.
 01 WS-HIGH                FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-TOP                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT.
     IF WD-TOUCH-CD(L-SLOT) > 0 OR WD-EMERGE(L-SLOT) > 0 OR WD-DIGGING(L-SLOT) > 0
         GOBACK
     END-IF
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT OR WS-DONE = 1
         MOVE 0 TO WS-LIVING WS-CODE
         IF EN-USED(WS-E) = 1 AND WS-E NOT = L-ROW AND EN-DIM(WS-E) = EN-DIM(L-ROW)
             MOVE EN-X(WS-E) TO WS-EX
             MOVE EN-Y(WS-E) TO WS-EY
             MOVE EN-Z(WS-E) TO WS-EZ
             IF EN-PLAYER(WS-E) > 0
                 IF PL-STATE(EN-PLAYER(WS-E)) = PS-ALIVE AND PL-MODE(EN-PLAYER(WS-E)) NOT = 3
                     MOVE 1 TO WS-LIVING
                     MOVE EN-PLAYER(WS-E) TO WS-CODE
                     MOVE PL-X(WS-CODE) TO WS-EX
                     MOVE PL-Y(WS-CODE) TO WS-EY
                     MOVE PL-Z(WS-CODE) TO WS-EZ
                 END-IF
             ELSE
                 CALL "STDMOB-INDEX" USING EN-TYPE(WS-E) WS-M
                 IF WS-M > 0 AND EN-HEALTH(WS-E) > 0
                     MOVE 1 TO WS-LIVING
                     COMPUTE WS-CODE = CORE-MAX-PLAYERS + WS-E
                 END-IF
             END-IF
         END-IF
         IF WS-LIVING = 1
*>           Box overlap: the half sum of the widths on x and z (strictly less), the entity's box against the warden's from the feet to the height on y.
             COMPUTE WS-HALF = (ET-WIDTH-MILLI(EN-TYPE(L-ROW) + 1) + ET-WIDTH-MILLI(EN-TYPE(WS-E) + 1)) / 2000
             COMPUTE WS-DX = FUNCTION ABS(WS-EX - EN-X(L-ROW))
             COMPUTE WS-DZ = FUNCTION ABS(WS-EZ - EN-Z(L-ROW))
             COMPUTE WS-TOP = EN-Y(L-ROW) + ET-HEIGHT-MILLI(EN-TYPE(L-ROW) + 1) / 1000
             COMPUTE WS-HIGH = WS-EY + ET-HEIGHT-MILLI(EN-TYPE(WS-E) + 1) / 1000
             IF WS-DX < WS-HALF AND WS-DZ < WS-HALF AND WS-EY < WS-TOP AND WS-HIGH > EN-Y(L-ROW)
                 MOVE 1 TO WS-DONE
                 MOVE 20 TO WD-TOUCH-CD(L-SLOT)
                 CALL "WARDEN-INCREASE" USING L-ROW WS-CODE WS-AMOUNT
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM WARDEN-TOUCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WARDEN-POSE-BUILD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WARDENSTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MD-==.
 01 WS-PACKET-ID           BINARY-LONG VALUE 101.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 COPY PROTO.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     CALL "WD-FIND" USING EN-ID(L-ROW) WS-ZERO WS-SLOT
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER EN-ID(L-ROW)
     INITIALIZE MD-METADATA-ENTRY
     MOVE 6 TO MD-MD-INDEX
     MOVE MD-MDS-POSE TO MD-MD-SERIALIZER
     MOVE WD-POSE(WS-SLOT) TO MD-MD-INT
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     MOVE MD-MD-END TO MD-MD-INDEX
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     GOBACK.
 END PROGRAM WARDEN-POSE-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WARDEN-POSE-SYNC.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WARDENSTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-WANTED              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT.
     MOVE 0 TO WS-WANTED
     EVALUATE TRUE
         WHEN WD-EMERGE(L-SLOT) > 0
             MOVE 13 TO WS-WANTED
         WHEN WD-DIGGING(L-SLOT) > 0
             MOVE 14 TO WS-WANTED
         WHEN WD-ROAR(L-SLOT) > 0
             MOVE 11 TO WS-WANTED
         WHEN WD-SNIFFING(L-SLOT) = 1 OR WD-SNIFF(L-SLOT) > 0
             MOVE 12 TO WS-WANTED
     END-EVALUATE
     IF WS-WANTED NOT = WD-POSE(L-SLOT)
         MOVE WS-WANTED TO WD-POSE(L-SLOT)
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "WARDEN-POSE-BUILD" USING L-ROW PB-BUFFER
         CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
         CALL "PB-FREE" USING PB-BUFFER
     END-IF
     GOBACK.
 END PROGRAM WARDEN-POSE-SYNC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WARDEN-POSE-OF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WARDENSTATE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-POSE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-POSE.
     MOVE 0 TO L-POSE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WD-MAX
         IF WD-ID(WS-I) = EN-ID(L-ROW)
             MOVE WD-POSE(WS-I) TO L-POSE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM WARDEN-POSE-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WARDEN-IN-LIQUID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-HEIGHT              FLOAT-LONG VALUE 2.9.
 01 WS-WATER               BINARY-LONG VALUE 1.
 01 WS-LAVA                BINARY-LONG VALUE 2.
 01 WS-HITS                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-FLAG.
     MOVE 0 TO L-FLAG
     CALL "M182-FLUID" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-HEIGHT WS-WATER WS-HITS
     IF WS-HITS = 1
         MOVE 1 TO L-FLAG
     END-IF
     CALL "M182-FLUID" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-HEIGHT WS-LAVA WS-HITS
     IF WS-HITS = 1
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM WARDEN-IN-LIQUID.
