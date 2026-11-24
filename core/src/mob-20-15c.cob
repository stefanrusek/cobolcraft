*> The warden's body (lane 002-lane-p49w; docs/protocol/20 section 15 (Anger: touching), 15.4, 44-5 section 3.2 to 3.4, 53 section 1). State: WD-TOUCH-CD and WD-POSE of WARDENSTATE.cpy.
*>   WARDEN-TOUCH USING warden row, slot: LivingEntity.pushEntities -> Warden.doPush, once a tick (20 section 15.5, 15.6): when the touch cooldown is absent, the first pushable entity (WARDEN-PUSHABLE, tracker
*>     row order) whose box overlaps the warden's (the registry sizes: 0.9 x 2.9 the warden, 0.6 x 1.8 a player) starts the 20-tick touch cooldown, gets increaseAngerAt (35, when it can be targeted) and its block
*>     position becomes the disturbance location (WARDEN-DISTURB); boxes that only touch at a face do not overlap. Approximation: the query order of the overlapping entities is the row order.
*>   WARDEN-PUSHABLE USING warden row, entity row, code out, x, y, z out: EntitySelector.pushableBy (the candidate rules).
*>   WARDEN-POSE-SYNC USING warden row, slot: the pose the warden's state asks for (EMERGING while is_emerging, else DIGGING, ROARING during Roar, SNIFFING from TryToSniff to the end of Sniffing, else
*>     STANDING) is kept in WD-POSE and sent to the viewers as Set Entity Data (index 6) when it changed.
*>   WARDEN-POSE-BUILD USING tracker row, PB-BUFFER (empty): Set Entity Data of the pose (index 6 POSE).
*>   WARDEN-POSE-OF USING tracker row, pose out: WD-POSE of the warden of that row (0 for any other entity).
*>   WARDEN-IN-LIQUID USING warden row, flag out: the warden's box touches water or lava (Entity.isInLiquid).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WARDEN-PUSHABLE.
*> USING warden row, entity row, code out, x, y, z out (FLOAT-LONG): EntitySelector.pushableBy(warden) for one tracker row (20 section 15.5). CODE is the suspect code of the entity (a player row, or 64 + the tracker row)
*> when it is a candidate, else 0; X Y Z its position. The candidates: a player that is alive and not a spectator (a creative player is one), a standard mob that is alive, and a boat, raft or minecart; an item entity, an
*> orb, an arrow and the other entities are never candidates (their isPushable is false). isPushable of a living entity is false on a climbable block; a bat is not pushable (the core has no bat row: it is no standard mob and never a candidate), a parrot is, a creaking only while its
*> CAN_MOVE flag is set, a horse (the family of AbstractHorse, llamas and camels included) only without a passenger, and another warden only while it is neither digging nor emerging.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY STDMOBS.
 COPY WARDENSTATE.
 01 WS-REGISTRY            PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:climbable".
 01 WS-M                   BINARY-LONG.
 01 WS-LIVING              BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-CLIMB               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-KEY                 PIC X(48).
 01 WS-CAN                 BINARY-LONG.
 COPY CBLOCKS.
 LINKAGE SECTION.
 01 L-WARDEN               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-CODE                 BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-WARDEN L-ROW L-CODE L-X L-Y L-Z.
     MOVE 0 TO L-CODE WS-LIVING
     IF EN-USED(L-ROW) NOT = 1 OR L-ROW = L-WARDEN OR EN-DIM(L-ROW) NOT = EN-DIM(L-WARDEN)
         GOBACK
     END-IF
     MOVE EN-X(L-ROW) TO L-X
     MOVE EN-Y(L-ROW) TO L-Y
     MOVE EN-Z(L-ROW) TO L-Z
     IF EN-PLAYER(L-ROW) > 0
         IF PL-STATE(EN-PLAYER(L-ROW)) = PS-ALIVE AND PL-MODE(EN-PLAYER(L-ROW)) NOT = 3
             MOVE 1 TO WS-LIVING
             MOVE EN-PLAYER(L-ROW) TO L-CODE
             MOVE PL-X(L-CODE) TO L-X
             MOVE PL-Y(L-CODE) TO L-Y
             MOVE PL-Z(L-CODE) TO L-Z
         END-IF
     ELSE
         CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
         IF WS-M > 0
             IF EN-HEALTH(L-ROW) > 0
                 MOVE 1 TO WS-LIVING
                 COMPUTE L-CODE = CORE-MAX-PLAYERS + L-ROW
                 MOVE SM-KEY(WS-M) TO WS-KEY
                 EVALUATE TRUE
                     WHEN WS-KEY = "creaking"
                         CALL "CREAKING-FROZEN" USING L-ROW WS-CAN
                         IF WS-CAN = 1
                             MOVE 0 TO L-CODE
                         END-IF
                     WHEN WS-KEY = "horse" OR WS-KEY = "donkey" OR WS-KEY = "mule" OR WS-KEY = "skeleton_horse"
                             OR WS-KEY = "zombie_horse" OR WS-KEY = "llama" OR WS-KEY = "trader_llama" OR WS-KEY = "camel"
                         IF EN-RIDER(L-ROW) > 0 OR EN-RIDER2(L-ROW) > 0
                             MOVE 0 TO L-CODE
                         END-IF
                         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
                             IF EN-USED(WS-I) = 1 AND EN-MOUNT(WS-I) = L-ROW
                                 MOVE 0 TO L-CODE
                             END-IF
                         END-PERFORM
*>               Bat.isPushable is false (the bat has a mob row since lane p49f).
                     WHEN WS-KEY = "bat"
                         MOVE 0 TO L-CODE
                     WHEN WS-KEY = "warden"
                         CALL "WD-FIND" USING EN-ID(L-ROW) WS-ZERO WS-SLOT
                         IF WS-SLOT > 0
                             IF WD-EMERGE(WS-SLOT) > 0 OR WD-DIGGING(WS-SLOT) > 0
                                 MOVE 0 TO L-CODE
                             END-IF
                         END-IF
                 END-EVALUATE
             END-IF
         ELSE
*>           AbstractBoat and AbstractMinecart override isPushable to true
             MOVE ET-KEY(EN-TYPE(L-ROW) + 1) TO WS-KEY
             MOVE 0 TO WS-N
             INSPECT WS-KEY TALLYING WS-N FOR ALL "boat" ALL "raft" ALL "minecart"
             IF WS-N > 0
                 COMPUTE L-CODE = CORE-MAX-PLAYERS + L-ROW
             END-IF
         END-IF
     END-IF
*>   LivingEntity.isPushable: not on a climbable block (the block at the entity's block position)
     IF WS-LIVING = 1 AND L-CODE > 0
         COMPUTE WS-BX = FUNCTION INTEGER(L-X)
         COMPUTE WS-BY = FUNCTION INTEGER(L-Y)
         COMPUTE WS-BZ = FUNCTION INTEGER(L-Z)
         CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) WS-BX WS-BY WS-BZ WS-STATE
         IF WS-STATE > 0
             MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
             CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG WS-BLOCK WS-CLIMB
             IF WS-CLIMB = 1
                 MOVE 0 TO L-CODE
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM WARDEN-PUSHABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WARDEN-TOUCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY WARDENSTATE.
 01 WS-E                   BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
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
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT.
     IF WD-TOUCH-CD(L-SLOT) > 0
         GOBACK
     END-IF
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT OR WS-DONE = 1
         CALL "WARDEN-PUSHABLE" USING L-ROW WS-E WS-CODE WS-EX WS-EY WS-EZ
         IF WS-CODE > 0
*>           Box overlap: the half sum of the widths on x and z (strictly less), the entity's box against the warden's from the feet to the height on y.
             COMPUTE WS-HALF = (ET-WIDTH-MILLI(EN-TYPE(L-ROW) + 1) + ET-WIDTH-MILLI(EN-TYPE(WS-E) + 1)) / 2000
             COMPUTE WS-DX = FUNCTION ABS(WS-EX - EN-X(L-ROW))
             COMPUTE WS-DZ = FUNCTION ABS(WS-EZ - EN-Z(L-ROW))
             COMPUTE WS-TOP = EN-Y(L-ROW) + ET-HEIGHT-MILLI(EN-TYPE(L-ROW) + 1) / 1000
             COMPUTE WS-HIGH = WS-EY + ET-HEIGHT-MILLI(EN-TYPE(WS-E) + 1) / 1000
             IF WS-DX < WS-HALF AND WS-DZ < WS-HALF AND WS-EY < WS-TOP AND WS-HIGH > EN-Y(L-ROW)
*>               Warden.doPush: the cooldown starts for any pushed entity, the anger goes to it (when it can be targeted), the disturbance location is its block position (15.6)
                 MOVE 1 TO WS-DONE
                 MOVE 20 TO WD-TOUCH-CD(L-SLOT)
                 CALL "WARDEN-INCREASE" USING L-ROW WS-CODE WS-AMOUNT
                 COMPUTE WS-BX = FUNCTION INTEGER(WS-EX)
                 COMPUTE WS-BY = FUNCTION INTEGER(WS-EY)
                 COMPUTE WS-BZ = FUNCTION INTEGER(WS-EZ)
                 CALL "WARDEN-DISTURB" USING L-ROW WS-BX WS-BY WS-BZ
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
