*> The state table, the area effect cloud and the generic effect application of lane 002-lane-mobsb6 (docs/protocol/44 part 9 section 3, 21 section 8.5, 44 part 8 section 10).
*> A cloud is a tracker row of the standard entity type area_effect_cloud with an entry of PROJSTATE.cpy (PJ-KIND 3): PJ-TICK its tickCount, PJ-RADIUS the stored radius,
*> PJ-DUR duration (-1 infinite), PJ-WAIT, PJ-REAPP the reapplication delay, PJ-RPT radius per tick, PJ-ROU radius on use, PJ-DUR-USE duration on use, PJ-SCALE the potion
*> duration scale in thousandths, PJ-FX the effects, PJ-V the victims (entity id, tick the entry expires).
*> Gaps: the radius, waiting and particle metadata (8 to 10) are not sent (the viewers draw the default radius 3.0), canBeAffected (undead are not poisoned, and so on) is
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
 END PROGRAM CLOUD-STEP.
