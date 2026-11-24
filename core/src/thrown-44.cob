*> The state table, the area effect cloud and the generic effect application of lane 002-lane-mobsb6 (docs/protocol/44 part 9 section 3, 21 section 8.5, 44 part 8 section 10).
*> A cloud is a tracker row of the standard entity type area_effect_cloud with an entry of PROJSTATE.cpy (PJ-KIND 3): PJ-TICK its tickCount, PJ-RADIUS the stored radius,
*> PJ-DUR duration (-1 infinite), PJ-WAIT, PJ-REAPP the reapplication delay, PJ-RPT radius per tick, PJ-ROU radius on use, PJ-DUR-USE duration on use, PJ-SCALE the potion
*> duration scale in thousandths, PJ-FX the effects, PJ-V the victims (entity id, tick the entry expires).
*> Gaps: the particle metadata (10) is not sent (radius 8 and waiting 9 are: mob-21-8-5.cob), canBeAffected (undead are not poisoned, and so on) is
*> not tested, the effect list holds at most 4 effects and at most 16 victims are remembered (the oldest slot is reused), no packet shows a mob effect, the owner is only
*> remembered (indirect magic damage has no cause of its own: CAUSE-COMMAND).
*>
*> Entry points:
*>   PJ-FIND USING entity id, slot out                  the state entry of an entity (0 none)
*>   PJ-ALLOC USING entity id, kind, slot out           a cleared entry (0 when the table is full)
*>   PJ-DROP USING tracker row                          free the entry and remove the entity
*>   THROWN-TYPE USING key (PIC X(112)), type id out    the entity type id of a key (0 outside a standard world)
*>   CLOUD-SPAWN USING dim, x, y, z, radius (FLOAT-LONG), duration, wait, reapplication delay, owner entity id, row out (0 when the table is full)
*>   THROWN-INSTANT USING tracker row, player row (one of them 0), effect, amplifier, scale in thousandths: instant_health 5 and instant_damage 6 (44 part 9 section 3)
*>   THROWN-EFFECT-ADD USING tracker row, player row, effect, amplifier, duration
*>   CLOUD-STEP USING tracker row                       one tick (serverTick)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PJ-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROJSTATE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ENT                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ENT L-SLOT.
     MOVE 0 TO L-SLOT
     IF L-ENT > 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX OR L-SLOT > 0
             IF PJ-ENT(WS-I) = L-ENT
                 MOVE WS-I TO L-SLOT
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM PJ-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PJ-ALLOC.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROJSTATE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ENT                  BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ENT L-KIND L-SLOT.
     MOVE 0 TO L-SLOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX OR L-SLOT > 0
         IF PJ-ENT(WS-I) = 0
             MOVE WS-I TO L-SLOT
         END-IF
     END-PERFORM
     IF L-SLOT > 0
         INITIALIZE PJ-ENTRY(L-SLOT)
         MOVE L-ENT TO PJ-ENT(L-SLOT)
         MOVE L-KIND TO PJ-KIND(L-SLOT)
     END-IF
     GOBACK.
 END PROGRAM PJ-ALLOC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PJ-DROP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT > 0
         INITIALIZE PJ-ENTRY(WS-SLOT)
     END-IF
     CALL "ENTITY-REMOVE" USING L-ROW
     GOBACK.
 END PROGRAM PJ-DROP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. THROWN-TYPE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-ROW                 PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(112).
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-TYPE.
     MOVE 0 TO L-TYPE
     IF CT-OPEN = 0 OR CT-SET-TYPE = CT-TYPE-COBOLCRAFT OR CT-SET-TYPE = CT-TYPE-DEBUG
         GOBACK
     END-IF
     CALL "CONTENT-ENTITY-BY-KEY" USING L-KEY L-TYPE WS-ROW WS-STATUS
     IF WS-STATUS NOT = 0
         MOVE 0 TO L-TYPE
     END-IF
     GOBACK.
 END PROGRAM THROWN-TYPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CLOUD-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:area_effect_cloud".
 01 WS-TYPE                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-RADIUS               FLOAT-LONG.
 01 L-DURATION             BINARY-LONG.
 01 L-WAIT                 BINARY-LONG.
 01 L-REAPP                BINARY-LONG.
 01 L-OWNER                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-RADIUS L-DURATION L-WAIT L-REAPP L-OWNER L-ROW.
     MOVE 0 TO L-ROW
     CALL "THROWN-TYPE" USING WS-KEY WS-TYPE
     IF WS-TYPE = 0
         GOBACK
     END-IF
     CALL "ENTITY-ALLOC" USING WS-ROW
     CALL "ENTITY-NEW-ID" USING EN-ID(WS-ROW)
     CALL "PJ-ALLOC" USING EN-ID(WS-ROW) 3 WS-SLOT
     IF WS-SLOT = 0
         INITIALIZE EN-ENTRY(WS-ROW)
         GOBACK
     END-IF
     MOVE WS-TYPE TO EN-TYPE(WS-ROW)
     CALL "ENTITY-SET-UUID" USING WS-ROW
     MOVE L-DIM TO EN-DIM(WS-ROW)
     MOVE L-X TO EN-X(WS-ROW)
     MOVE L-Y TO EN-Y(WS-ROW)
     MOVE L-Z TO EN-Z(WS-ROW)
     MOVE L-OWNER TO PJ-OWNER(WS-SLOT)
     MOVE L-DURATION TO PJ-DUR(WS-SLOT)
     MOVE L-WAIT TO PJ-WAIT(WS-SLOT)
     MOVE L-REAPP TO PJ-REAPP(WS-SLOT)
     MOVE 1000 TO PJ-SCALE(WS-SLOT)
     COMPUTE PJ-RADIUS(WS-SLOT) = FUNCTION MAX(0, FUNCTION MIN(32, L-RADIUS))
     CALL "ENTITY-TRACK" USING WS-ROW
     MOVE WS-ROW TO L-ROW
     GOBACK.
 END PROGRAM CLOUD-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. THROWN-INSTANT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RULES.
 01 WS-UNDEAD              BINARY-LONG.
 01 WS-HEAL                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-MILLI               BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG VALUE CAUSE-COMMAND.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-NONE2               BINARY-LONG VALUE 0.
 01 WS-RESULT              BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-EFFECT               BINARY-LONG.
 01 L-AMP                  BINARY-LONG.
 01 L-SCALE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-PLAYER L-EFFECT L-AMP L-SCALE.
     IF L-EFFECT NOT = 5 AND L-EFFECT NOT = 6
         GOBACK
     END-IF
     MOVE 0 TO WS-UNDEAD
     IF L-PLAYER = 0
         CALL "MEF-UNDEAD" USING L-ROW WS-UNDEAD
     END-IF
     MOVE 0 TO WS-HEAL
     IF (L-EFFECT = 5 AND WS-UNDEAD = 0) OR (L-EFFECT = 6 AND WS-UNDEAD = 1)
         MOVE 1 TO WS-HEAL
     END-IF
     IF WS-HEAL = 1
         COMPUTE WS-BASE = 4 * 2 ** L-AMP
     ELSE
         COMPUTE WS-BASE = 6 * 2 ** L-AMP
     END-IF
     COMPUTE WS-AMOUNT = FUNCTION INTEGER(L-SCALE * WS-BASE / 1000 + 0.5)
     EVALUATE TRUE
         WHEN WS-HEAL = 1 AND L-PLAYER > 0
             COMPUTE PL-HEALTH(L-PLAYER) = FUNCTION MIN(20, PL-HEALTH(L-PLAYER) + WS-AMOUNT)
             CALL "HEALTH-SEND" USING L-PLAYER
         WHEN WS-HEAL = 1
             CALL "MEF-HEAL" USING L-ROW WS-AMOUNT
         WHEN L-PLAYER > 0
             COMPUTE WS-MILLI = WS-AMOUNT * 1000
             CALL "HEALTH-HURT" USING L-PLAYER WS-MILLI WS-CAUSE WS-NONE WS-NONE2 WS-RESULT
         WHEN OTHER
             CALL "MEF-HURT" USING L-ROW WS-AMOUNT
     END-EVALUATE
     GOBACK.
 END PROGRAM THROWN-INSTANT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. THROWN-EFFECT-ADD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-FLAGS               BINARY-LONG VALUE 6.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-EFFECT               BINARY-LONG.
 01 L-AMP                  BINARY-LONG.
 01 L-DUR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-PLAYER L-EFFECT L-AMP L-DUR.
     IF L-PLAYER > 0
         CALL "EFFECT-ADD" USING L-PLAYER L-EFFECT L-AMP L-DUR WS-FLAGS
     ELSE
         CALL "MEF-ADD" USING EN-ID(L-ROW) L-EFFECT L-AMP L-DUR WS-FLAGS
     END-IF
     GOBACK.
 END PROGRAM THROWN-EFFECT-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CLOUD-HIT.
*> USING slot, victim tracker row, victim player row (one 0), r in/out (FLOAT-LONG), gone out: the effects of the cloud on one victim (44 part 9 section 3, step 4e), the radius on
*> use and the duration on use.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-DUR                 BINARY-LONG.
 01 WS-HALF                BINARY-LONG VALUE 500.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-R                    FLOAT-LONG.
 01 L-GONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-ROW L-PLAYER L-R L-GONE.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-FXN(L-SLOT)
         IF PJ-FX-ID(L-SLOT, WS-I) = 5 OR PJ-FX-ID(L-SLOT, WS-I) = 6
             CALL "THROWN-INSTANT" USING L-ROW L-PLAYER PJ-FX-ID(L-SLOT, WS-I) PJ-FX-AMP(L-SLOT, WS-I) WS-HALF
         ELSE
             COMPUTE WS-DUR = FUNCTION INTEGER(PJ-FX-DUR(L-SLOT, WS-I) * PJ-SCALE(L-SLOT) / 1000 + 0.5)
             IF PJ-FX-DUR(L-SLOT, WS-I) = -1
                 MOVE -1 TO WS-DUR
             END-IF
             CALL "THROWN-EFFECT-ADD" USING L-ROW L-PLAYER PJ-FX-ID(L-SLOT, WS-I) PJ-FX-AMP(L-SLOT, WS-I) WS-DUR
         END-IF
     END-PERFORM
     IF PJ-ROU(L-SLOT) NOT = 0
         COMPUTE L-R = L-R + PJ-ROU(L-SLOT)
         IF L-R < 0.5
             MOVE 1 TO L-GONE
         ELSE
             COMPUTE PJ-RADIUS(L-SLOT) = FUNCTION MAX(0, FUNCTION MIN(32, L-R))
         END-IF
     END-IF
     IF L-GONE = 0 AND PJ-DUR-USE(L-SLOT) NOT = 0 AND PJ-DUR(L-SLOT) NOT = -1
         ADD PJ-DUR-USE(L-SLOT) TO PJ-DUR(L-SLOT)
         IF PJ-DUR(L-SLOT) <= 0
             MOVE 1 TO L-GONE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CLOUD-HIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CLOUD-VICTIM.
*> USING slot, entity id, known out (1 when it is already a victim), and CLOUD-VICTIM-ADD below remembers one.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROJSTATE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-ENT                  BINARY-LONG.
 01 L-KNOWN                BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-ENT L-KNOWN.
     MOVE 0 TO L-KNOWN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         IF PJ-V-ENT(L-SLOT, WS-I) = L-ENT
             MOVE 1 TO L-KNOWN
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CLOUD-VICTIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CLOUD-VICTIM-ADD.
*> USING slot, entity id: the victim with the expiry tickCount + reapplication delay, in a free place (else the place with the earliest expiry).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROJSTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-PICK                BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-ENT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-ENT.
     MOVE 1 TO WS-PICK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         IF PJ-V-ENT(L-SLOT, WS-I) = 0
             MOVE WS-I TO WS-PICK
             MOVE 17 TO WS-I
         ELSE
             IF PJ-V-UNTIL(L-SLOT, WS-I) < PJ-V-UNTIL(L-SLOT, WS-PICK)
                 MOVE WS-I TO WS-PICK
             END-IF
         END-IF
     END-PERFORM
     MOVE L-ENT TO PJ-V-ENT(L-SLOT, WS-PICK)
     COMPUTE PJ-V-UNTIL(L-SLOT, WS-PICK) = PJ-TICK(L-SLOT) + PJ-REAPP(L-SLOT)
     GOBACK.
 END PROGRAM CLOUD-VICTIM-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CLOUD-APPLY.
*> USING tracker row, slot, r in/out (FLOAT-LONG), gone out: the application beat (step 4): expired victims dropped, then every living entity in the box that is in range.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY PROJSTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-RC                  FLOAT-LONG.
 01 WS-W                   FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-R                    FLOAT-LONG.
 01 L-GONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-R L-GONE.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         IF PJ-V-ENT(L-SLOT, WS-I) > 0 AND PJ-TICK(L-SLOT) >= PJ-V-UNTIL(L-SLOT, WS-I)
             MOVE 0 TO PJ-V-ENT(L-SLOT, WS-I) PJ-V-UNTIL(L-SLOT, WS-I)
         END-IF
     END-PERFORM
     IF PJ-FXN(L-SLOT) = 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
             MOVE 0 TO PJ-V-ENT(L-SLOT, WS-I) PJ-V-UNTIL(L-SLOT, WS-I)
         END-PERFORM
         GOBACK
     END-IF
     MOVE PJ-RADIUS(L-SLOT) TO WS-RC
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS OR L-GONE = 1
         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ROW(WS-P) > 0 AND PL-STATE(WS-P) = PS-ALIVE AND PL-DIM(WS-P) = EN-DIM(L-ROW)
                 AND PL-MODE(WS-P) < 3
             MOVE 0 TO WS-HIT
             IF FUNCTION ABS(PL-X(WS-P) - EN-X(L-ROW)) <= WS-RC + 0.3 AND FUNCTION ABS(PL-Z(WS-P) - EN-Z(L-ROW)) <= WS-RC + 0.3
                     AND PL-Y(WS-P) <= EN-Y(L-ROW) + 0.5 AND PL-Y(WS-P) + 1.8 >= EN-Y(L-ROW)
                 MOVE 1 TO WS-HIT
             END-IF
             IF WS-HIT = 1
                 MOVE PL-ENTITY-ID(WS-P) TO WS-ID
                 CALL "CLOUD-VICTIM" USING L-SLOT WS-ID WS-KNOWN
                 COMPUTE WS-DX = PL-X(WS-P) - EN-X(L-ROW)
                 COMPUTE WS-DZ = PL-Z(WS-P) - EN-Z(L-ROW)
                 IF WS-KNOWN = 0 AND WS-DX * WS-DX + WS-DZ * WS-DZ <= L-R * L-R
                     CALL "CLOUD-VICTIM-ADD" USING L-SLOT WS-ID
                     CALL "CLOUD-HIT" USING L-SLOT PL-ENTITY-ROW(WS-P) WS-P L-R L-GONE
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT OR L-GONE = 1
         IF EN-USED(WS-E) = 1 AND WS-E NOT = L-ROW AND EN-DIM(WS-E) = EN-DIM(L-ROW) AND EN-HEALTH(WS-E) > 0
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-E) WS-M
             IF WS-M > 0
                 COMPUTE WS-W = ET-WIDTH-MILLI(EN-TYPE(WS-E) + 1) / 2000
                 COMPUTE WS-H = ET-HEIGHT-MILLI(EN-TYPE(WS-E) + 1) / 1000
                 IF FUNCTION ABS(EN-X(WS-E) - EN-X(L-ROW)) <= WS-RC + WS-W AND FUNCTION ABS(EN-Z(WS-E) - EN-Z(L-ROW)) <= WS-RC + WS-W
                         AND EN-Y(WS-E) <= EN-Y(L-ROW) + 0.5 AND EN-Y(WS-E) + WS-H >= EN-Y(L-ROW)
                     MOVE EN-ID(WS-E) TO WS-ID
                     CALL "CLOUD-VICTIM" USING L-SLOT WS-ID WS-KNOWN
                     COMPUTE WS-DX = EN-X(WS-E) - EN-X(L-ROW)
                     COMPUTE WS-DZ = EN-Z(WS-E) - EN-Z(L-ROW)
                     IF WS-KNOWN = 0 AND WS-DX * WS-DX + WS-DZ * WS-DZ <= L-R * L-R
                         CALL "CLOUD-VICTIM-ADD" USING L-SLOT WS-ID
                         CALL "CLOUD-HIT" USING L-SLOT WS-E WS-NONE L-R L-GONE
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CLOUD-APPLY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CLOUD-STEP.
*> USING tracker row: CLOUD-RUN, then the viewers are told of a changed radius or waiting flag (CLOUD-DATA-SYNC, mob-21-8-5.cob) when the cloud is still there.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "CLOUD-RUN" USING L-ROW
     IF EN-USED(L-ROW) = 1
         CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
         IF WS-SLOT > 0
             CALL "CLOUD-DATA-SYNC" USING L-ROW WS-SLOT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CLOUD-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CLOUD-RUN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-GONE                BINARY-LONG.
 01 WS-BEAT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT = 0 OR PJ-KIND(WS-SLOT) NOT = 3
         GOBACK
     END-IF
     ADD 1 TO PJ-TICK(WS-SLOT)
     IF PJ-DUR(WS-SLOT) NOT = -1 AND PJ-TICK(WS-SLOT) - PJ-WAIT(WS-SLOT) >= PJ-DUR(WS-SLOT)
         CALL "PJ-DROP" USING L-ROW
         GOBACK
     END-IF
     IF PJ-TICK(WS-SLOT) < PJ-WAIT(WS-SLOT)
         GOBACK
     END-IF
     MOVE PJ-RADIUS(WS-SLOT) TO WS-R
     IF PJ-RPT(WS-SLOT) NOT = 0
         COMPUTE WS-R = WS-R + PJ-RPT(WS-SLOT)
         IF WS-R < 0.5
             CALL "PJ-DROP" USING L-ROW
             GOBACK
         END-IF
         COMPUTE PJ-RADIUS(WS-SLOT) = FUNCTION MAX(0, FUNCTION MIN(32, WS-R))
     END-IF
     COMPUTE WS-BEAT = FUNCTION MOD(PJ-TICK(WS-SLOT), 5)
     IF WS-BEAT = 0
         MOVE 0 TO WS-GONE
         CALL "CLOUD-APPLY" USING L-ROW WS-SLOT WS-R WS-GONE
         IF WS-GONE = 1
             CALL "PJ-DROP" USING L-ROW
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CLOUD-RUN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. THROWN-SYNC.
*> USING tracker row: the position and motion of a thrown entity to its viewers (Teleport Entity), when it moved since the last one (EN-WAY-X, EN-FLEE-X, EN-WAY-Z hold it).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 128.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF EN-X(L-ROW) = EN-WAY-X(L-ROW) AND EN-Y(L-ROW) = EN-FLEE-X(L-ROW) AND EN-Z(L-ROW) = EN-WAY-Z(L-ROW)
         GOBACK
     END-IF
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "TELEPORT-ENTITY-BUILD" USING EN-ID(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) EN-VX(L-ROW) EN-VY(L-ROW)
         EN-VZ(L-ROW) EN-YAW(L-ROW) EN-PITCH(L-ROW) EN-ON-GROUND(L-ROW) PB-BUFFER
     CALL "GI-VIEWERS-SEND" USING L-ROW PB-BUFFER
     MOVE EN-X(L-ROW) TO EN-WAY-X(L-ROW)
     MOVE EN-Y(L-ROW) TO EN-FLEE-X(L-ROW)
     MOVE EN-Z(L-ROW) TO EN-WAY-Z(L-ROW)
     CALL "ENTITY-TRACK" USING L-ROW
     GOBACK.
 END PROGRAM THROWN-SYNC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. THROWN-SHOOT-FIRST.
*> USING tracker row, before the move (1 before THROWN-FLY2 moves it, 0 after): Projectile.tick's projectile_shoot on the first tick (EN-COOLDOWN 1) of a thrown projectile (30-8 14.2.1), the owner as the
*> source. ThrowableProjectile and AbstractHurtingProjectile (pearls, eggs, potions, skulls, the dragon's fireball) post it after their move and hit test (the hit location, call with 0); the fishing hook runs
*> Projectile.tick early, so its shoot is at the position before the move (call with 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-HOOK                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-BEFORE               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-BEFORE.
     MOVE 0 TO WS-HOOK
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT > 0
         IF PJ-KIND(WS-SLOT) = 7
             MOVE 1 TO WS-HOOK
         END-IF
     END-IF
     IF EN-COOLDOWN(L-ROW) = 1 AND WS-HOOK = L-BEFORE
         CALL "GAME-EVENT-SHOOT" USING L-ROW EN-TARGET-ID(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM THROWN-SHOOT-FIRST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. THROWN-LAND.
*> USING tracker row, hit (1 block, 2 entity), block x, y, z (the cell hit): Projectile.onHit's projectile_land (30-8 14.2.2) for a thrown projectile that THROWN-FLY2 stopped, the projectile as the source: at the hit
*> location (the entity row's position) for an entity, at the centre of the block hit with the block's state for a block. Posted before the class's own effect (the burst, the explosion, the discard). A fishing
*> hook lying on the ground (PJ-I6 above 0: the bobber model runs THROWN-FLY2 for it every tick) lands once, on the tick it reached the ground.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-RESTING             BINARY-LONG.
 01 WS-EV-LAND             PIC X(32) VALUE "projectile_land".
 01 WS-NO-STATE            BINARY-LONG VALUE -1.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HIT                  BINARY-LONG.
 01 L-HX                   BINARY-LONG.
 01 L-HY                   BINARY-LONG.
 01 L-HZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HIT L-HX L-HY L-HZ.
     MOVE 0 TO WS-RESTING
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT > 0
         IF PJ-KIND(WS-SLOT) = 7 AND PJ-I6(WS-SLOT) > 0
             MOVE 1 TO WS-RESTING
         END-IF
     END-IF
     IF WS-RESTING = 1
         GOBACK
     END-IF
     IF L-HIT = 2
         CALL "GAME-EVENT" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-EV-LAND L-ROW WS-NO-STATE
     ELSE
         CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) L-HX L-HY L-HZ WS-STATE
         CALL "GAME-EVENT-CELL" USING EN-DIM(L-ROW) L-HX L-HY L-HZ WS-EV-LAND L-ROW WS-STATE
     END-IF
     GOBACK.
 END PROGRAM THROWN-LAND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. THROWN-FLY2.
*> THROWN-FLY with the drag as a parameter. USING tracker row, gravity, drag (FLOAT-LONG), hit out, entity row out, player row out (44 part 8 section 6.5): the tick count (EN-COOLDOWN) rises, gravity then drag 0.99 change the
*> velocity, and the segment of the new velocity is walked in steps of at most 0.1 block against solid cells and against players and standard mobs other than the owner
*> (EN-TARGET-ID; ARROW-FIND-HIT with its margin). The position ends at the last free point (a block hit, hit 1) or at the sample inside the entity (hit 2); no hit: hit 0
*> and the viewers are told. Water drag 0.8 is open.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-STEPS               BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-QX                  FLOAT-LONG.
 01 WS-QY                  FLOAT-LONG.
 01 WS-QZ                  FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-HCX                 BINARY-LONG.
 01 WS-HCY                 BINARY-LONG.
 01 WS-HCZ                 BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG VALUE 1.
 01 WS-AFTER               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-GRAVITY              FLOAT-LONG.
 01 L-DRAG                 FLOAT-LONG.
 01 L-HIT                  BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-GRAVITY L-DRAG L-HIT L-ENTITY L-PLAYER.
     MOVE 0 TO L-HIT L-ENTITY L-PLAYER
     ADD 1 TO EN-COOLDOWN(L-ROW)
     CALL "THROWN-SHOOT-FIRST" USING L-ROW WS-BEFORE
     COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) - L-GRAVITY
     COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) * L-DRAG
     COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) * L-DRAG
     COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) * L-DRAG
     COMPUTE WS-SPEED = FUNCTION SQRT(EN-VX(L-ROW) * EN-VX(L-ROW) + EN-VY(L-ROW) * EN-VY(L-ROW) + EN-VZ(L-ROW) * EN-VZ(L-ROW))
     COMPUTE WS-STEPS = FUNCTION INTEGER(WS-SPEED / 0.1) + 1
     MOVE EN-X(L-ROW) TO WS-PX
     MOVE EN-Y(L-ROW) TO WS-PY
     MOVE EN-Z(L-ROW) TO WS-PZ
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > WS-STEPS OR L-HIT > 0
         COMPUTE WS-QX = EN-X(L-ROW) + EN-VX(L-ROW) * WS-S / WS-STEPS
         COMPUTE WS-QY = EN-Y(L-ROW) + EN-VY(L-ROW) * WS-S / WS-STEPS
         COMPUTE WS-QZ = EN-Z(L-ROW) + EN-VZ(L-ROW) * WS-S / WS-STEPS
         COMPUTE WS-CX = FUNCTION INTEGER(WS-QX)
         COMPUTE WS-CY = FUNCTION INTEGER(WS-QY)
         COMPUTE WS-CZ = FUNCTION INTEGER(WS-QZ)
         CALL "GI-SOLID-CELL" USING EN-DIM(L-ROW) WS-CX WS-CY WS-CZ WS-SOLID
         IF WS-SOLID = 1
             MOVE 1 TO L-HIT
             MOVE WS-CX TO WS-HCX
             MOVE WS-CY TO WS-HCY
             MOVE WS-CZ TO WS-HCZ
         ELSE
             CALL "ARROW-FIND-HIT" USING L-ROW WS-QX WS-QY WS-QZ L-ENTITY L-PLAYER
             IF L-ENTITY > 0 OR L-PLAYER > 0
                 MOVE 2 TO L-HIT
                 MOVE WS-QX TO WS-PX
                 MOVE WS-QY TO WS-PY
                 MOVE WS-QZ TO WS-PZ
             ELSE
                 MOVE WS-QX TO WS-PX
                 MOVE WS-QY TO WS-PY
                 MOVE WS-QZ TO WS-PZ
             END-IF
         END-IF
     END-PERFORM
     MOVE WS-PX TO EN-X(L-ROW)
     MOVE WS-PY TO EN-Y(L-ROW)
     MOVE WS-PZ TO EN-Z(L-ROW)
     CALL "THROWN-SHOOT-FIRST" USING L-ROW WS-AFTER
     IF L-HIT = 0
         CALL "THROWN-SYNC" USING L-ROW
     ELSE
         CALL "THROWN-LAND" USING L-ROW L-HIT WS-HCX WS-HCY WS-HCZ
     END-IF
     GOBACK.
 END PROGRAM THROWN-FLY2.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. THROWN-FLY.
*> USING tracker row, gravity (FLOAT-LONG), hit out, entity row out, player row out: THROWN-FLY2 with the drag 0.99 of a thrown item.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DRAG                FLOAT-LONG VALUE 0.99.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-GRAVITY              FLOAT-LONG.
 01 L-HIT                  BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-GRAVITY L-HIT L-ENTITY L-PLAYER.
     CALL "THROWN-FLY2" USING L-ROW L-GRAVITY WS-DRAG L-HIT L-ENTITY L-PLAYER
     GOBACK.
 END PROGRAM THROWN-FLY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. THROWN-SPAWN.
*> USING kind, key (PIC X(112)), dim, x, y, z, vx, vy, vz (FLOAT-LONG), owner entity id, row out (0 when it cannot be made): a thrown entity of that kind (PROJSTATE.cpy), facing its velocity,
*> moving by that velocity, owned (EN-TARGET-ID and PJ-OWNER) and told to the viewers.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-TYPE                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-H                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-KEY                  PIC X(112).
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-OWNER                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-KEY L-DIM L-X L-Y L-Z L-VX L-VY L-VZ L-OWNER L-ROW.
     MOVE 0 TO L-ROW
     CALL "THROWN-TYPE" USING L-KEY WS-TYPE
     IF WS-TYPE = 0
         GOBACK
     END-IF
     CALL "ENTITY-ALLOC" USING WS-ROW
     CALL "ENTITY-NEW-ID" USING EN-ID(WS-ROW)
     CALL "PJ-ALLOC" USING EN-ID(WS-ROW) L-KIND WS-SLOT
     IF WS-SLOT = 0
         INITIALIZE EN-ENTRY(WS-ROW)
         GOBACK
     END-IF
     MOVE WS-TYPE TO EN-TYPE(WS-ROW)
     CALL "ENTITY-SET-UUID" USING WS-ROW
     MOVE L-DIM TO EN-DIM(WS-ROW)
     MOVE L-X TO EN-X(WS-ROW) EN-WAY-X(WS-ROW)
     MOVE L-Y TO EN-Y(WS-ROW) EN-FLEE-X(WS-ROW)
     MOVE L-Z TO EN-Z(WS-ROW) EN-WAY-Z(WS-ROW)
     MOVE L-VX TO EN-VX(WS-ROW)
     MOVE L-VY TO EN-VY(WS-ROW)
     MOVE L-VZ TO EN-VZ(WS-ROW)
     MOVE L-OWNER TO EN-TARGET-ID(WS-ROW) PJ-OWNER(WS-SLOT)
     MOVE 1000 TO PJ-SCALE(WS-SLOT)
     COMPUTE WS-H = FUNCTION SQRT(L-VX * L-VX + L-VZ * L-VZ)
     IF WS-H > 0
         COMPUTE EN-PITCH(WS-ROW) = FUNCTION ATAN(L-VY / WS-H) * 180 / FUNCTION PI
     END-IF
     CALL "ENTITY-TRACK" USING WS-ROW
     MOVE WS-ROW TO L-ROW
     GOBACK.
 END PROGRAM THROWN-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. POTION-SPAWN.
*> USING lingering (0 splash, 1 lingering), dim, x, y, z, vx, vy, vz (FLOAT-LONG), owner entity id, row out: the generic thrown potion entity (splash_potion or lingering_potion). The
*> effects are added with POTION-FX; item entities carry no components, so the contents are the caller's.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SPLASH              PIC X(112) VALUE "minecraft:splash_potion".
 01 WS-LINGER              PIC X(112) VALUE "minecraft:lingering_potion".
 01 WS-KIND                BINARY-LONG.
 LINKAGE SECTION.
 01 L-LINGERING            BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-OWNER                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-LINGERING L-DIM L-X L-Y L-Z L-VX L-VY L-VZ L-OWNER L-ROW.
     IF L-LINGERING = 1
         MOVE 2 TO WS-KIND
         CALL "THROWN-SPAWN" USING WS-KIND WS-LINGER L-DIM L-X L-Y L-Z L-VX L-VY L-VZ L-OWNER L-ROW
     ELSE
         MOVE 1 TO WS-KIND
         CALL "THROWN-SPAWN" USING WS-KIND WS-SPLASH L-DIM L-X L-Y L-Z L-VX L-VY L-VZ L-OWNER L-ROW
     END-IF
     GOBACK.
 END PROGRAM POTION-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. POTION-FX.
*> USING tracker row, effect, amplifier, duration: adds an effect to the contents of a potion (at most 4; more are ignored).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-EFFECT               BINARY-LONG.
 01 L-AMP                  BINARY-LONG.
 01 L-DUR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-EFFECT L-AMP L-DUR.
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT > 0 AND PJ-FXN(WS-SLOT) < 4
         ADD 1 TO PJ-FXN(WS-SLOT)
         MOVE L-EFFECT TO PJ-FX-ID(WS-SLOT, PJ-FXN(WS-SLOT))
         MOVE L-AMP TO PJ-FX-AMP(WS-SLOT, PJ-FXN(WS-SLOT))
         MOVE L-DUR TO PJ-FX-DUR(WS-SLOT, PJ-FXN(WS-SLOT))
     END-IF
     GOBACK.
 END PROGRAM POTION-FX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. THROWN-GAP.
*> USING ex, ey, ez (the box's bottom centre), half width, height, margin, hx, hy, hz (the 0.25 box of the thrown entity, bottom centre) (FLOAT-LONG), d2 out: the squared gap between
*> the entity's box inflated by the margin and the thrown entity's box (0 when they overlap).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-GX                  FLOAT-LONG.
 01 WS-GY                  FLOAT-LONG.
 01 WS-GZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-EX                   FLOAT-LONG.
 01 L-EY                   FLOAT-LONG.
 01 L-EZ                   FLOAT-LONG.
 01 L-HW                   FLOAT-LONG.
 01 L-H                    FLOAT-LONG.
 01 L-M                    FLOAT-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HY                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-D2                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-EX L-EY L-EZ L-HW L-H L-M L-HX L-HY L-HZ L-D2.
     COMPUTE WS-GX = FUNCTION MAX(0, FUNCTION ABS(L-EX - L-HX) - (L-HW + L-M + 0.125))
     COMPUTE WS-GZ = FUNCTION MAX(0, FUNCTION ABS(L-EZ - L-HZ) - (L-HW + L-M + 0.125))
     COMPUTE WS-GY = FUNCTION MAX(0, FUNCTION MAX(L-EY - L-M - (L-HY + 0.25), L-HY - (L-EY + L-H + L-M)))
     COMPUTE L-D2 = WS-GX * WS-GX + WS-GY * WS-GY + WS-GZ * WS-GZ
     GOBACK.
 END PROGRAM THROWN-GAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. POTION-EFFECTS.
*> USING slot, tracker row, player row (one 0), intensity in thousandths: the effects of a splash potion on one victim (10.2): instant effects scaled by the intensity, the others with the
*> duration (int)(d t s + 0.5) when it ends later than 20 ticks.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROJSTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-MAPPED              BINARY-LONG.
 01 WS-APPLIES             BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-T                    BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-ROW L-PLAYER L-T.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-FXN(L-SLOT)
         IF PJ-FX-ID(L-SLOT, WS-I) = 5 OR PJ-FX-ID(L-SLOT, WS-I) = 6
             CALL "THROWN-INSTANT" USING L-ROW L-PLAYER PJ-FX-ID(L-SLOT, WS-I) PJ-FX-AMP(L-SLOT, WS-I) L-T
         ELSE
             IF PJ-FX-DUR(L-SLOT, WS-I) = -1
                 MOVE -1 TO WS-MAPPED
                 MOVE 1 TO WS-APPLIES
             ELSE
                 CALL "TOOL-SPLASH-DURATION" USING PJ-FX-DUR(L-SLOT, WS-I) L-T PJ-SCALE(L-SLOT) WS-MAPPED WS-APPLIES
             END-IF
             IF WS-APPLIES = 1
                 CALL "THROWN-EFFECT-ADD" USING L-ROW L-PLAYER PJ-FX-ID(L-SLOT, WS-I) PJ-FX-AMP(L-SLOT, WS-I) WS-MAPPED
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM POTION-EFFECTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. POTION-SPLASH.
*> USING tracker row, slot: onHitAsPotion of a splash potion at the row's position: every living entity within the box inflated by (4, 2, 4) whose squared gap is below 16.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY PROJSTATE.
 01 WS-P                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-MARGIN              FLOAT-LONG.
 01 WS-HW                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-D2M                 BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HY                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-PW                  FLOAT-LONG VALUE 0.3.
 01 WS-PH                  FLOAT-LONG VALUE 1.8.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT.
     COMPUTE WS-MARGIN = FUNCTION MAX(0, FUNCTION MIN(0.3, (EN-COOLDOWN(L-ROW) - 2) / 20))
     MOVE EN-X(L-ROW) TO WS-HX
     MOVE EN-Y(L-ROW) TO WS-HY
     MOVE EN-Z(L-ROW) TO WS-HZ
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ROW(WS-P) > 0 AND PL-STATE(WS-P) = PS-ALIVE AND PL-DIM(WS-P) = EN-DIM(L-ROW) AND PL-MODE(WS-P) < 3
             CALL "THROWN-GAP" USING PL-X(WS-P) PL-Y(WS-P) PL-Z(WS-P) WS-PW WS-PH WS-MARGIN WS-HX WS-HY WS-HZ WS-D2
             COMPUTE WS-D2M = FUNCTION INTEGER(WS-D2 * 1000)
             CALL "TOOL-SPLASH-INTENSITY" USING WS-D2M WS-T
             IF WS-D2 < 16 AND WS-T > 0
                 CALL "POTION-EFFECTS" USING L-SLOT PL-ENTITY-ROW(WS-P) WS-P WS-T
             END-IF
         END-IF
     END-PERFORM
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND WS-E NOT = L-ROW AND EN-DIM(WS-E) = EN-DIM(L-ROW) AND EN-HEALTH(WS-E) > 0
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-E) WS-M
             IF WS-M > 0
                 COMPUTE WS-HW = ET-WIDTH-MILLI(EN-TYPE(WS-E) + 1) / 2000
                 COMPUTE WS-H = ET-HEIGHT-MILLI(EN-TYPE(WS-E) + 1) / 1000
                 CALL "THROWN-GAP" USING EN-X(WS-E) EN-Y(WS-E) EN-Z(WS-E) WS-HW WS-H WS-MARGIN WS-HX WS-HY WS-HZ WS-D2
                 COMPUTE WS-D2M = FUNCTION INTEGER(WS-D2 * 1000)
                 CALL "TOOL-SPLASH-INTENSITY" USING WS-D2M WS-T
                 IF WS-D2 < 16 AND WS-T > 0
                     CALL "POTION-EFFECTS" USING L-SLOT WS-E WS-NONE WS-T
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM POTION-SPLASH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. POTION-REHYDRATE.
*> USING tracker row (a burst thrown potion whose contents are in the potion tag rehydrates_axolotls: PJ-I1 1, set by POTION-LOAD for a potion of water; 44-7 section 8.4): every axolotl whose
*> box meets the potion's box (0.25 wide and tall, bottom centre at the row) inflated by 4.0 horizontally and 2.0 vertically gets air + 1800 (at most 6000). EN-DRY counts the ticks without air
*> (STDMOB-AQUATIC-STEP: the air is 6000 - EN-DRY), so it falls by 1800, not below 0. There is no distance test.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-E                   BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-REACH               FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND WS-E NOT = L-ROW AND EN-DIM(WS-E) = EN-DIM(L-ROW)
             CALL "MOB-SPECIES-KEY" USING WS-E WS-KEY
             IF WS-KEY = "axolotl"
                 COMPUTE WS-REACH = ET-WIDTH-MILLI(EN-TYPE(WS-E) + 1) / 2000 + 4.125
                 COMPUTE WS-H = ET-HEIGHT-MILLI(EN-TYPE(WS-E) + 1) / 1000
                 COMPUTE WS-DX = FUNCTION ABS(EN-X(WS-E) - EN-X(L-ROW))
                 COMPUTE WS-DZ = FUNCTION ABS(EN-Z(WS-E) - EN-Z(L-ROW))
                 IF WS-DX < WS-REACH AND WS-DZ < WS-REACH AND EN-Y(WS-E) < EN-Y(L-ROW) + 2.25 AND EN-Y(WS-E) + WS-H > EN-Y(L-ROW) - 2
                     COMPUTE EN-DRY(WS-E) = FUNCTION MAX(EN-DRY(WS-E) - 1800, 0)
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM POTION-REHYDRATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. POTION-BURST.
*> USING tracker row, hit entity row (0 none): the hit of a potion (10.2). A splash potion applies its effects around the hit point; a lingering one makes a cloud (radius 3.0, radius on
*> use -0.5, duration 600, wait 10, reapplication 20, radius per tick -0.005) at the hit entity or at the potion. The level event 2007 (instant effects) or 2002 with the sound event, the
*> potion discarded. A potion of water rehydrates the axolotls around (POTION-REHYDRATE). Douse fire and water-sensitive mobs (tags of the potion) are open: item entities carry no components.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-CLOUD               BINARY-LONG.
 01 WS-CSLOT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-RADIUS              FLOAT-LONG VALUE 3.0.
 01 WS-DURATION            BINARY-LONG VALUE 600.
 01 WS-WAIT                BINARY-LONG VALUE 10.
 01 WS-REAPP               BINARY-LONG VALUE 20.
 01 WS-DIM                 BINARY-LONG.
 01 WS-EVENT               BINARY-LONG.
 01 WS-SOUND               BINARY-LONG.
 01 WS-DATA                BINARY-LONG VALUE 3694022.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-NONE2               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HIT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HIT.
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     MOVE EN-DIM(L-ROW) TO WS-DIM
     MOVE EN-X(L-ROW) TO WS-X
     MOVE EN-Y(L-ROW) TO WS-Y
     MOVE EN-Z(L-ROW) TO WS-Z
     IF PJ-I1(WS-SLOT) = 1
         CALL "POTION-REHYDRATE" USING L-ROW
     END-IF
     IF PJ-KIND(WS-SLOT) = 1 AND PJ-FXN(WS-SLOT) > 0
         CALL "POTION-SPLASH" USING L-ROW WS-SLOT
     END-IF
     IF PJ-KIND(WS-SLOT) = 2 AND PJ-FXN(WS-SLOT) > 0
         IF L-HIT > 0
             MOVE EN-X(L-HIT) TO WS-X
             MOVE EN-Y(L-HIT) TO WS-Y
             MOVE EN-Z(L-HIT) TO WS-Z
         END-IF
         CALL "CLOUD-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-RADIUS WS-DURATION WS-WAIT WS-REAPP PJ-OWNER(WS-SLOT) WS-CLOUD
         IF WS-CLOUD > 0
             CALL "PJ-FIND" USING EN-ID(WS-CLOUD) WS-CSLOT
             MOVE -0.005 TO PJ-RPT(WS-CSLOT)
             MOVE -0.5 TO PJ-ROU(WS-CSLOT)
             MOVE PJ-SCALE(WS-SLOT) TO PJ-SCALE(WS-CSLOT)
             MOVE PJ-FXN(WS-SLOT) TO PJ-FXN(WS-CSLOT)
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-FXN(WS-SLOT)
                 MOVE PJ-FX(WS-SLOT, WS-I) TO PJ-FX(WS-CSLOT, WS-I)
             END-PERFORM
         END-IF
     END-IF
     MOVE 2002 TO WS-EVENT
     MOVE 1053 TO WS-SOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-FXN(WS-SLOT)
         IF PJ-FX-ID(WS-SLOT, WS-I) = 5 OR PJ-FX-ID(WS-SLOT, WS-I) = 6
             MOVE 2007 TO WS-EVENT
             MOVE 1054 TO WS-SOUND
         END-IF
     END-PERFORM
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "LEVEL-EVENT" USING WS-DIM WS-EVENT WS-CX WS-CY WS-CZ WS-DATA WS-NONE
     CALL "LEVEL-EVENT" USING WS-DIM WS-SOUND WS-CX WS-CY WS-CZ WS-NONE WS-NONE2
     CALL "PJ-DROP" USING L-ROW
     GOBACK.
 END PROGRAM POTION-BURST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. POTION-STEP.
*> USING tracker row: one tick of a thrown potion (gravity 0.05, 44 part 8 section 6.5); a hit bursts it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-GRAVITY             FLOAT-LONG VALUE 0.05.
 01 WS-HIT                 BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "THROWN-FLY" USING L-ROW WS-GRAVITY WS-HIT WS-ENTITY WS-PLAYER
     IF WS-HIT = 1
         CALL "POTION-BURST" USING L-ROW WS-ENTITY
     END-IF
     IF WS-HIT = 2
         IF WS-PLAYER > 0
             MOVE 0 TO WS-ENTITY
         END-IF
         CALL "POTION-BURST" USING L-ROW WS-ENTITY
     END-IF
     GOBACK.
 END PROGRAM POTION-STEP.
